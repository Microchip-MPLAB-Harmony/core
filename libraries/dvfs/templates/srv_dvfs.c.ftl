/* ************************************************************************** */
/** Descriptive File Name

  @Company
    Microchip Technology

  @File Name
    srv_dvfs.c

  @Summary
    Provides the interface and control functions for Dynamic Voltage and Frequency Scaling (DVFS) in embedded systems.

  @Description
    This file defines the interface, data types, and function prototypes for the 
    Dynamic Voltage and Frequency Scaling (DVFS) service. DVFS is a power management
    technique that dynamically adjusts the CPU's voltage and frequency according to
    system workload and temperature, optimizing power consumption and thermal performance.
    The service provides initialization, state management, and runtime control functions to enable,
    disable, and operate DVFS, as well as utilities for mapping temperature readings to 
    DVFS states and applying the corresponding hardware settings.
 */
/* ************************************************************************** */

/* ************************************************************************** */
/* Section: Included Files                                                    */
/* ************************************************************************** */

#include "definitions.h"
#include "srv_dvfs.h"

/* ************************************************************************** */
/* Section: File Scope or Global Data                                         */
/* ************************************************************************** */

#define TEMP_MONITOR_PERIOD_MS      ${dvfs_thermal_monitor_period_ms} // Temperature monitoring period in milliseconds

<#if dvfs_pac_enable == true>
#define PAC_ERROR_MARGIN_PERCENT    10

static const pac193x_r_sense_mOhms_t PAC_RSENSE = {PAC_RSENSE_1, PAC_RSENSE_2, PAC_RSENSE_3, PAC_RSENSE_4};

</#if>
// Declare a mutex for thread-safe access to DVFS state and resources
static OSAL_MUTEX_DECLARE(DVFS_Mutex);

// Flag set by the temperature monitoring interrupt to trigger DVFS task
static volatile bool DVFS_ThermalInterruptHit;

// Handle for the periodic temperature monitoring timer
static SYS_TIME_HANDLE DVFS_TimerHandler = SYS_TIME_HANDLE_INVALID;

// Current DVFS state
static dvfs_state_t DVFS_StateCurrent = DVFS_STATE_0;

// Maximum allowed DVFS state based on temperature
static dvfs_state_t DVFS_StateMax = DVFS_NB_STATES - 1;

// Table of DVFS configuration parameters for each state
static const dvfs_config_t DVFS_State_Config[DVFS_NB_STATES] =
{
    { .level = DVFS_STATE_NEG3, .voltage = ${dvfs_neg3_voltage}, .freq_ratio = ${dvfs_neg3_freq_threshold} }, // ${dvfs_neg3_frequency} MHz CPU clock shall be the slowest
    { .level = DVFS_STATE_NEG2, .voltage = ${dvfs_neg2_voltage}, .freq_ratio = ${dvfs_neg2_freq_threshold} }, // ${dvfs_neg2_frequency} MHz
    { .level = DVFS_STATE_NEG1, .voltage = ${dvfs_neg1_voltage}, .freq_ratio = ${dvfs_neg1_freq_threshold} }, // ${dvfs_neg1_frequency} MHz
    { .level = DVFS_STATE_0,    .voltage = ${dvfs_0_voltage}, .freq_ratio = ${dvfs_0_freq_threshold} }, // ${dvfs_0_frequency} MHz CPU clock shall be the fastest
    { .level = DVFS_STATE_1,    .voltage = ${dvfs_1_voltage}, .freq_ratio = ${dvfs_1_freq_threshold} }, // ${dvfs_1_frequency} MHz
    { .level = DVFS_STATE_2,    .voltage = ${dvfs_2_voltage}, .freq_ratio = ${dvfs_2_freq_threshold} }, // ${dvfs_2_frequency} MHz
    { .level = DVFS_STATE_3,    .voltage = ${dvfs_3_voltage}, .freq_ratio = ${dvfs_3_freq_threshold} }  // ${dvfs_3_frequency} MHz CPU clock shall be the slowest
};

// Table of temperature thresholds for each DVFS state
static const thermal_threshold_t DVFS_ThermalThresholds[DVFS_NB_STATES] =
{
    { .low = ${dvfs_neg3_threshold_down}.0, .high = ${dvfs_neg3_threshold_up}.0, .state = DVFS_STATE_NEG3 },
    { .low = ${dvfs_neg2_threshold_down}.0, .high = ${dvfs_neg2_threshold_up}.0, .state = DVFS_STATE_NEG2 },
    { .low = ${dvfs_neg1_threshold_down}.0, .high = ${dvfs_neg1_threshold_up}.0, .state = DVFS_STATE_NEG1 },
    { .low = ${dvfs_0_threshold_down}.0, .high = ${dvfs_0_threshold_up}.0, .state = DVFS_STATE_0 },
    { .low = ${dvfs_1_threshold_down}.0, .high = ${dvfs_1_threshold_up}.0, .state = DVFS_STATE_1 },
    { .low = ${dvfs_2_threshold_down}.0, .high = ${dvfs_2_threshold_up}.0, .state = DVFS_STATE_2 },
    { .low = ${dvfs_3_threshold_down}.0, .high = ${dvfs_3_threshold_up}.0, .state = DVFS_STATE_3 }
};

/* ************************************************************************** */
/* Section: Local Functions                                                   */
/* ************************************************************************** */

/**
 * @brief Lock the DVFS mutex for thread-safe operations.
 * @return OSAL_RESULT_TRUE if the mutex was successfully locked.
 */
static uint32_t __DVFS_Lock(void)
{
    return OSAL_MUTEX_Lock(&DVFS_Mutex, OSAL_WAIT_FOREVER);
}

/**
 * @brief Unlock the DVFS mutex.
 */
static void __DVFS_Unlock(void)
{
    (void)OSAL_MUTEX_Unlock(&DVFS_Mutex);
}


/**
 * @brief Set the CPU clock ratio in the hardware register.
 * @param cpu_ratio The new CPU frequency ratio to set.
 */
static void __DVFS_SetCpuCkRatio(const uint8_t cpu_ratio)
{
    PMC_REGS->PMC_CPU_RATIO = PMC_CPU_RATIO_RATIO(cpu_ratio);
}

/**
 * @brief Timer callback for periodic temperature monitoring.
 *        Sets a flag to trigger the DVFS task.
 * @param context Unused parameter.
 */
static void __DVFS_ThermalMonitoringInterrupt(uintptr_t context)
{
    (void)context;
    DVFS_ThermalInterruptHit = true;
}

/**
 * @brief Callback for critical temperature interrupt from SECUMOD.
 *        If a high temperature alarm is detected, initiates CPU shutdown.
 * @param system_status Current system status.
 * @param status Alarm status flags.
 * @param context Unused parameter.
 */
static void __DVFS_CriticalTemperatureInterrupt(SECUMOD_SYS_STATUS system_status, SECUMOD_ALARM_STATUS status, uintptr_t context)
{
    SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\r\nSystem status: 0x%08lX  /  alarm status: 0x%08lX", system_status, status);

    bool is_temp_high_alarm = (status & SECUMOD_SR_TPMH_Msk) >> SECUMOD_SR_TPMH_Pos;

    if (is_temp_high_alarm)
    {
<#if behavior_when_critical == "shutdown">
        SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\r\nJunction temperature is too high: shut CPU down");
        SHDWC_REGS->SHDW_CR = SHDW_CR_KEY_PASSWD | SHDW_CR_SHDW_1; // Shutdown
<#else>
        SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\r\nJunction temperature is too high: switch CPU to low-power mode");
        SHDWC_REGS->SHDW_CR = SHDW_CR_KEY_PASSWD | SHDW_CR_LPMEN_1; // Switch to low power mode
</#if>
    }
}

/* ************************************************************************** */
/* Section: Interface Functions                                               */
/* ************************************************************************** */
/**
 * @brief Get the current CPU frequency ratio from the hardware register.
 * @return The current CPU frequency ratio.
 */
uint8_t DVFS_GetCpuRatio(void)
{
    return (PMC_REGS->PMC_CPU_RATIO & PMC_CPU_RATIO_RATIO_Msk) >> PMC_CPU_RATIO_RATIO_Pos;
}

/**
 * @brief Initialize the DVFS service, including mutex, PMIC, SECUMOD, and timer.
 * @return EXIT_SUCCESS on success, EXIT_FAILURE on error.
 */
uint32_t DVFS_Initialize(void)
{
    SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nDVFS Init");

    // Initialize mutex
    if (OSAL_MUTEX_Create(&DVFS_Mutex) == OSAL_RESULT_FALSE)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to create DVFS mutex");
        return EXIT_FAILURE;
    }

    // Initialize I2C access to PMIC (required for voltage changes)
    if (PMIC_Open(PMIC_I2C_ADDR) != EXIT_SUCCESS)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to open PMIC");
        return EXIT_FAILURE;
    }
    uint8_t sys_addr, sys_id;
    if (PMIC_GetDeviceInfo(&sys_addr, &sys_id) != EXIT_SUCCESS)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read PMIC registers");
        return EXIT_FAILURE;
    }
    SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nPMIC IDs: address=0x%X, ID=0x%X", sys_addr, sys_id);
    SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\r\nPMIC access is open");
<#if dvfs_pac_enable == true>

    // Initialize PAC (optional)
    if (PAC_Open(PAC1934_I2C_ADDR, PAC_RSENSE) != EXIT_SUCCESS)
    {
        SYS_DEBUG_MESSAGE(SYS_ERROR_WARNING, "\r\nCannot open access to PAC193x");
    } 
    else if (PAC_SetSampleRate(8) != EXIT_SUCCESS)
    {
        SYS_DEBUG_MESSAGE(SYS_ERROR_WARNING, "\r\nCannot access PAC193x registers");
    } 
    else
    {
        SYS_DEBUG_MESSAGE(SYS_ERROR_INFO, "\r\nPAC193x access is open");
    }
</#if>

    // Register SECUMOD callback
    SECUMOD_CallbackRegister(__DVFS_CriticalTemperatureInterrupt, (uintptr_t)NULL, SECUMOD_ALARM_TEMPERATURE_HIGH);

    // Ensure SECUMOD is in normal mode
    secumod_sys_status_t sys_status;
    SECUMOD_GetSystemStatus(&sys_status);
    if (sys_status.backup_is_active) 
    {
        secumod_sys_ctrl_t sys_ctrl = { false };
        sys_ctrl.activate_normal = true;
        SECUMOD_SetSystemControl(sys_ctrl);
        SECUMOD_GetSystemStatus(&sys_status);
        if (sys_status.backup_is_active)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nCould not switch Security Module to normal operating mode");
        } 
        else
        {
            SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\r\nSwitched Security Module to normal operating mode");
        }
    }

    // Start periodic temperature monitoring
    DVFS_ThermalInterruptHit = false;
    DVFS_TimerHandler = SYS_TIME_CallbackRegisterMS(__DVFS_ThermalMonitoringInterrupt, (uintptr_t)NULL, TEMP_MONITOR_PERIOD_MS, SYS_TIME_PERIODIC);
    if (DVFS_TimerHandler == SYS_TIME_HANDLE_INVALID)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to register temperature monitoring callback");
        return EXIT_FAILURE;
    }

    DVFS_Enable();
<#if dvfs_show_thermal_metadata == true>
    // Output thermal metadata headers for external logging
    SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\r\nTHERMAL_HEADERSIZE=%u", DVFS_NB_STATES);
    for (int state = DVFS_STATE_0; state < DVFS_NB_STATES; state++)
    {
        thermal_threshold_t threshold = DVFS_ThermalThresholds[state];
        SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\r\nTHERMAL_HEADERDATA=%u;%0.1f;%0.1f", state, threshold.low, threshold.high);
    }
</#if>
    return EXIT_SUCCESS;
}

/**
 * @brief Main DVFS task, called periodically to check temperature and update DVFS state.
 */
void DVFS_Task(void)
{
    if (DVFS_ThermalInterruptHit)
    {
        DVFS_ThermalInterruptHit = false;

        SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\r\nCPU load %.2f%%,", PMU_ComputeCpuLoad());

        // Read current temperature in Celsius
        float temp = TEMP_Get(TEMP_CELSIUS);

        // Compute the maximum allowed DVFS state based on temperature
        DVFS_StateMax = DVFS_ComputeStateFromTemperature(temp);
        SYS_DEBUG_PRINT(SYS_ERROR_INFO, " Temp: %0.1fC,", temp);

        uint32_t pmic_voltage_mv;
        pmic_mode_t pmic_mode;
        if (PMIC_GetRegulatorSettings(PMIC_VDDCPU_REGULATOR_ID, PMIC_STATE_A, &pmic_voltage_mv, &pmic_mode, NULL) != EXIT_SUCCESS)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read PMIC");
        }
        else
        {
            uint8_t current_freq_ratio = DVFS_GetCpuRatio();

            SYS_DEBUG_PRINT(SYS_ERROR_INFO, " voltage:%d,", pmic_voltage_mv);
            SYS_DEBUG_PRINT(SYS_ERROR_INFO, " freq_ratio 0x%X,", current_freq_ratio);

            LED_GREEN_Toggle();

            // Apply the new DVFS state if needed
            if (DVFS_SetState(DVFS_StateMax) != EXIT_SUCCESS)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to change to DVFS state  %u", DVFS_StateMax);
            }
<#if dvfs_show_thermal_metadata == true>
            // Output current thermal metadata for logging
            dvfs_config_t next_dvfs_config = DVFS_State_Config[DVFS_StateMax];
            SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\r\nTHERMAL_METADATA=(%0.1f;%u;%u;%u)", temp, DVFS_StateMax, next_dvfs_config.voltage, next_dvfs_config.freq_ratio);
</#if>
<#if dvfs_pac_enable == true>
            pac_measure_t voltage_mV;
            pac_measure_t power_in_mW;

            if ( PAC_GetAllMeasures( PAC_VDDCPU_MONITOR_ID, true, &voltage_mV, NULL, &power_in_mW, NULL ) != EXIT_SUCCESS )
            {
                SYS_DEBUG_MESSAGE(SYS_ERROR_WARNING, "\r\nFailed to read PAC measures");
            }
            else
            {
                SYS_DEBUG_PRINT(SYS_ERROR_INFO, " PAC voltage %lu mV, power %lu mW,", voltage_mV.unipolar, power_in_mW.unipolar);
            }
            SYS_DEBUG_PRINT(SYS_ERROR_INFO, " DVFS lev %lu", DVFS_StateMax);
            SYS_DEBUG_PRINT(SYS_ERROR_INFO, " Freq set to %d MHz", ((current_freq_ratio+1) * SYS_TIME_CPU_CLOCK_FREQUENCY)/16/1000/1000);
        }
<#if dvfs_show_thermal_metadata == true>
        // Send PAC metadata
        SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\r\nPAC_METADATA = (%lu; %lu)", voltage_mV.unipolar, power_in_mW.unipolar);
</#if>
</#if>
    }
}

/**
 * @brief Enable the DVFS service by starting the temperature monitoring timer.
 */
void DVFS_Enable(void)
{
    __DVFS_Lock();
    if (DVFS_TimerHandler != SYS_TIME_HANDLE_INVALID)
    {
        SYS_TIME_TimerStart(DVFS_TimerHandler);
        SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\r\nStarted Thermal management service");
    }
    else
    {
        SYS_DEBUG_PRINT(SYS_ERROR_WARNING, "\r\nCould not start an uninitialized timer");
    }
    __DVFS_Unlock();
}

/**
 * @brief Disable the DVFS service by stopping the temperature monitoring timer.
 */
void DVFS_Disable(void)
{
    __DVFS_Lock();
    if (DVFS_TimerHandler != SYS_TIME_HANDLE_INVALID)
    {
        SYS_TIME_TimerStop(DVFS_TimerHandler);
        SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\r\nStopped thermal management service");
    }
    else
    {
        SYS_DEBUG_PRINT(SYS_ERROR_WARNING, "\r\nCould not stop an uninitialized timer");
    }
    __DVFS_Unlock();
}

/**
 * @brief Compute the appropriate DVFS state based on the current temperature.
 *        Uses hysteresis to avoid rapid state changes.
 * @param input_temp The current temperature in Celsius.
 * @return The computed DVFS state.
 */
dvfs_state_t DVFS_ComputeStateFromTemperature(const float input_temp)
{
    static float prev_input_temp = -100.0;
    dvfs_state_t dvfs_state = DVFS_StateCurrent;

    if (input_temp >= prev_input_temp)
    {
        // Temperature is rising: check for higher states
        uint32_t i = dvfs_state + 1;
        while (i < DVFS_NB_STATES && input_temp >= DVFS_ThermalThresholds[i].high)
        {
            dvfs_state = DVFS_ThermalThresholds[i].state;
            i++;
        }
    }
    else
    {
        // Temperature is falling: check for lower states
        int32_t i = (int32_t)dvfs_state - 1;
        while (i >= 0 && input_temp <= DVFS_ThermalThresholds[i + 1].low)
        {
            dvfs_state = DVFS_ThermalThresholds[i].state;
            i--;
        }
    }
    SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nPrevious temperature: %0.1f, current temperature: %0.1f  => next DVFS level: %u", prev_input_temp, input_temp, dvfs_state);
    prev_input_temp = input_temp;

    return dvfs_state;
}

/**
 * @brief Set the DVFS state by adjusting CPU frequency and voltage as needed.
 *        Ensures safe transitions by changing frequency and voltage in the correct order.
 * @param next_state The desired DVFS state.
 * @return EXIT_SUCCESS on success, EXIT_FAILURE on error.
 */
uint32_t DVFS_SetState(const dvfs_state_t next_state)
{
    __DVFS_Lock();

    // Early exit if already in the requested state
    if (next_state == DVFS_StateCurrent)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nDVFS is already in state %u", DVFS_StateCurrent);
        __DVFS_Unlock();
        return EXIT_SUCCESS;
    }

    // Read current hardware state
    uint32_t pmic_voltage_mv;
    pmic_mode_t pmic_mode;
    if (PMIC_GetRegulatorSettings(PMIC_VDDCPU_REGULATOR_ID, PMIC_STATE_A, &pmic_voltage_mv, &pmic_mode, NULL) != EXIT_SUCCESS)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read PMIC");
        __DVFS_Unlock();
        return EXIT_FAILURE;
    }

    // Read current CPU frequency ratio
    uint8_t current_freq_ratio = DVFS_GetCpuRatio();

    // Get target DVFS configuration
    dvfs_config_t config = DVFS_State_Config[next_state];

    // Apply DVFS transition
    if (next_state > DVFS_StateCurrent)
    {
        // If increasing performance: lower frequency first, then voltage
        if (current_freq_ratio != config.freq_ratio)
        {
            __DVFS_SetCpuCkRatio(config.freq_ratio);
            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nChanged CPU clock ratio from %u to %u", current_freq_ratio, config.freq_ratio);
        }
        else
        {
            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nCPU clock ratio is already set to %u", current_freq_ratio);
        }

        if (pmic_voltage_mv != config.voltage)
        {
            if (PMIC_SetRegulatorSettings(PMIC_VDDCPU_REGULATOR_ID, PMIC_STATE_A, config.voltage, pmic_mode) != EXIT_SUCCESS)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to change DVFS state to %u", next_state);
                __DVFS_Unlock();
                return EXIT_FAILURE;
            }
            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nChanged PMIC voltage from %u to %u", pmic_voltage_mv, config.voltage);
        }
        else
        {
            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nPMIC voltage is already set to %u", pmic_voltage_mv);
        }
    }
    else
    {
        // If decreasing performance: lower voltage first, then increase frequency
        if (pmic_voltage_mv != config.voltage)
        {
            if (PMIC_SetRegulatorSettings(PMIC_VDDCPU_REGULATOR_ID, PMIC_STATE_A, config.voltage, pmic_mode) != EXIT_SUCCESS)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to change DVFS state to %u", next_state);
                __DVFS_Unlock();
                return EXIT_FAILURE;
            }
            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nChanged PMIC voltage from %u to %u", pmic_voltage_mv, config.voltage);
        }
        else
        {
            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nPMIC voltage is already set to %u", pmic_voltage_mv);
        }

        if (current_freq_ratio != config.freq_ratio)
        {
            __DVFS_SetCpuCkRatio(config.freq_ratio);
            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nChanged CPU clock ratio from %u to %u", current_freq_ratio, config.freq_ratio);
        }
        else
        {
            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nCPU clock ratio is already set to %u", current_freq_ratio);
        }
    }

    // Update state and unlock
    SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nDVFS state has changed from %lu to %lu", DVFS_StateCurrent, next_state);
    DVFS_StateCurrent = next_state;
    __DVFS_Unlock();

    return EXIT_SUCCESS;
}

/* *****************************************************************************
 End of File
 */
