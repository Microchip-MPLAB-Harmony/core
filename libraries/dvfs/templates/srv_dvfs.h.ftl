/* ************************************************************************** */
/** Descriptive File Name

  @Company
    Microchip Technology

  @File Name
    srv_dvfs.h

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

#ifndef _DVFS_LIB_H    /* Guard against multiple inclusion */
#define _DVFS_LIB_H

#include <stdint.h>
#include <stdbool.h>

/* ************************************************************************** */
/* Section: Included Files                                                    */
/* ************************************************************************** */

/* Provide C++ Compatibility */
#ifdef __cplusplus
extern "C"
{
#endif

// *****************************************************************************
// Section: Data Types
// *****************************************************************************

/** Identify the DVFS states available */
typedef enum
{
    DVFS_STATE_NEG3 = 0,  // Lowest CPU performance
    DVFS_STATE_NEG2,
    DVFS_STATE_NEG1,
    DVFS_STATE_0,         // Highest CPU performance
    DVFS_STATE_1,
    DVFS_STATE_2,
    DVFS_STATE_3,         // Lowest CPU performance
    DVFS_NB_STATES
} dvfs_state_t;

/** Specify the voltage and frequency for a DVFS state */
typedef struct
{
    dvfs_state_t level;
    uint16_t voltage;
    uint8_t freq_ratio;
} dvfs_config_t;

/** Specify the hysteresis temperature values for a DVFS state */
typedef struct
{
    float low;
    float high;
    dvfs_state_t state;
} thermal_threshold_t;

// *****************************************************************************
// Section: Interface Functions
// *****************************************************************************

/**
  @Function
    uint32_t DVFS_Initialize(void);

  @Summary
    Initialize all peripherals and variables required to handle DVFS functionalities.

  @Description
    Opens access to the I2C devices: MCP16502 and optionally PAC1934.
    Configures the SECUMOD to enable automatic temperature monitoring and registers the associated interrupt routine
    that switches the CPU operating mode when the temperature reaches a critical threshold.
    Configures the system timer and registers the associated interrupt routine that measures the temperature periodically.

  @Parameters
    None

  @Returns
    Return code:
    <ul>
      <li>EXIT_SUCCESS   Indicates it ran successfully
      <li>EXIT_FAILURE   Indicates an error occurred
    </ul>

  @Example
    @code
    if (DVFS_Initialize() != EXIT_SUCCESS)
    {
        printf("An error occurred\n\r");
        return 3;
    }
 */
uint32_t DVFS_Initialize(void);

/**
  @Function
    void DVFS_Task(void);

  @Summary
    Perform the DVFS operations in parallel with other tasks.

  @Description
    Checks if the timer was triggered. If so, the function:
    <ul>
      <li>Reads the temperature currently measured by the sensor in the ADC.
      <li>Determines the DVFS state corresponding to this temperature.
      <li>If the state has changed, modifies the voltage and frequency of the CPU corresponding to this new DVFS state.
      <li>Optionally, if the PAC1934 has been enabled, a measurement of the real voltage, current, and power is read from the PAC1934.
    </ul>

  @Precondition
    The DVFS service must have been initialized; "DVFS_Initialize" must have been called first.

  @Parameters
    None

  @Returns
    None
 */
void DVFS_Task(void);

/**
  @Function
    void DVFS_Enable(void);

  @Summary
    Enable all DVFS functionalities.

  @Description
    All functionalities associated with DVFS activity are enabled.

  @Precondition
    The DVFS service must have been initialized; "DVFS_Initialize" must have been called first.

  @Parameters
    None

  @Returns
    None

  @Example
    @code
    DVFS_Enable();
 */
void DVFS_Enable(void);

/**
  @Function
    void DVFS_Disable(void);

  @Summary
    Disable all DVFS functionalities.

  @Description
    All functionalities associated with DVFS activity are disabled.

  @Precondition
    The DVFS service must have been initialized; "DVFS_Initialize" must have been called first.

  @Parameters
    None

  @Returns
    None

  @Example
    @code
    DVFS_Disable();
 */
void DVFS_Disable(void);

/**
  @Function
    dvfs_state_t DVFS_ComputeStateFromTemperature(const float input_temp);

  @Summary
    Compute the DVFS state associated with a temperature value.

  @Description
    Determines the evolution of the temperature by comparing the input value with the previous temperature.
    This temperature trend is needed to determine the hysteresis path to follow in order to determine
    which DVFS state this temperature corresponds to.

  @Precondition
    The DVFS service must have been initialized; "DVFS_Initialize" must have been called first.

  @Parameters
    @param input_temp Temperature for which to compute the DVFS state.

  @Returns
    The identifier of the DVFS state corresponding to this input temperature.

  @Example
    @code
    float temp = TEMP_Get(TEMP_CELSIUS);
    dvfs_state_t next_dvfs_state = DVFS_ComputeStateFromTemperature(temp);
    printf("Temperature: %0.1f => DVFS level = %u", temp, next_dvfs_state);
 */
dvfs_state_t DVFS_ComputeStateFromTemperature(const float input_temp);

/**
  @Function
    uint32_t DVFS_SetState(const dvfs_state_t next_state);

  @Summary
    Change the voltage and frequency of the CPU in accordance with the provided DVFS state.

  @Description
    <ul>
      <li>Compares the requested DVFS state with the current DVFS state.
      <li>If different, gets the voltage and frequency corresponding to the requested DVFS state.
      <li>Reads the current value of the voltage command (from the PMIC) and the current frequency.
      <li>Depending on the evolution of the DVFS state, the order in which voltage and frequency are changed differs:
          if the DVFS state goes down (frequency is decreased), the frequency is changed first, then the voltage;
          if the DVFS state goes up (frequency is increased), the voltage is changed first, then the frequency.
      <li>To change the voltage, a new write command is sent to the PMIC.
      <li>To change the frequency, the ratio of the CPU frequency is overwritten with the new value.
    </ul>

  @Precondition
    The DVFS service must have been initialized; "DVFS_Initialize" must have been called first.

  @Parameters
    @param next_state Identifier of the DVFS state to change to.

  @Returns
    Return code:
    <ul>
      <li>EXIT_SUCCESS   Indicates it ran successfully
      <li>EXIT_FAILURE   Indicates an error occurred
    </ul>

  @Example
    @code
    dvfs_state_t next_dvfs_state = DVFS_STATE_0;
    if (DVFS_SetState(next_dvfs_state) != EXIT_SUCCESS)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to change to DVFS state %u", next_dvfs_state);
    }
 */
uint32_t DVFS_SetState(const dvfs_state_t next_state);

uint8_t DVFS_GetCpuRatio(void);

/* Provide C++ Compatibility */
#ifdef __cplusplus
}
#endif

#endif /* _DVFS_LIB_H */

/* *****************************************************************************
 End of File
 */
