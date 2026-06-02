/*******************************************************************************
  PMU PLIB

  Company:
    Microchip Technology Inc.

  File Name:
    plib_pmu.c

  Summary:
    This C source file implements a driver for a Performance Monitoring Unit (PMU)
    in an embedded system. The driver provides a set of functions to configure, 
    control, and read hardware event and cycle counters, which are used to monitor 
    processor performance metrics such as instruction counts, branch events, and cycle counts. 
    The code supports enabling/disabling counters, reading/writing their values, handling overflows, 
    and managing interrupts for performance analysis and debugging.

  Remarks:
    None.
*******************************************************************************/

/*
Copyright (C) 2025, Microchip Technology Inc., and its subsidiaries. All rights reserved.

The software and documentation is provided by Microchip and its contributors "as is" and any express,
implied or statutory warranties, including, but not limited to, the implied warranties of merchantability,
fitness for a particular purpose and non-infringement of third party intellectual property rights are
disclaimed to the fullest extent permitted by law. In no event shall Microchip or its contributors be
liable for any direct, indirect, incidental, special,exemplary, or consequential damages (including,
but not limited to, procurement of substitute goods or services; loss of use, data, or profits;
or business interruption) however caused and on any theory of liability, whether in contract, strict liability,
or tort (including negligence or otherwise) arising in any way out of the use of the software and documentation,
even if advised of the possibility of such damage.

Except as expressly permitted hereunder and subject to the applicable license terms for any third-party software
incorporated in the software and any applicable open source software license terms, no license or other rights,
whether express or implied, are granted under any patent or other intellectual property rights of Microchip or any third party.
*/

#include <stdio.h>
#include "plib_pmu.h"

/**
 * @brief Check if the given event counter index is valid.
 * @param event_counter_index Index to check.
 * @return true if valid, false otherwise (and logs an error).
 */
bool __PMU_CheckCounterIndex(uint8_t event_counter_index)
{
    uint8_t num_counter_max = PMU_GetNumEventCounters();
    bool result = true;

    if (event_counter_index >= num_counter_max)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nEvent counter index %u is out of range [0:%u]\n\r",
                  event_counter_index, num_counter_max);
        result = false;
    }
    return result;
}

/**
 * @brief Get a bitmask for the specified number of event and/or cycle counters.
 * @param cycle_counter If true, include the cycle counter in the mask.
 * @param num_event_counter Number of event counters to include in the mask.
 * @return Bitmask representing the selected counters.
 */
uint32_t PMU_GetCountersMask(bool cycle_counter, uint8_t num_event_counter)
{
    uint32_t mask = cycle_counter ? (1UL << 31) : 0;

    if (num_event_counter > 0)
    {
        uint32_t num_evnt_cnt_max = PMU_GetNumEventCounters();
        uint32_t num_evnt_cnt_select = ( num_event_counter < num_evnt_cnt_max ) ? 
                                         num_event_counter : num_evnt_cnt_max;
        // Set lower num_evnt_cnt_select bits to 1
        mask |= (1UL << num_evnt_cnt_select) - 1;
    }
    return mask;
}

/**
 * @brief Get a bitmask for the specified number of event counters.
 * @param num_event_counter Number of event counters to include.
 * @return Bitmask for the event counters.
 */
uint32_t PMU_GetEventCountersMask(uint8_t num_event_counter)
{
    return PMU_GetCountersMask(false, num_event_counter);
}

/**
 * @brief Get a bitmask for all available event counters.
 * @return Bitmask for all event counters.
 */
uint32_t PMU_GetAllEventCountersMask(void)
{
    return PMU_GetCountersMask(false, PMU_GetNumEventCounters());
}

/**
 * @brief Get a bitmask for the cycle counter only.
 * @return Bitmask for the cycle counter.
 */
uint32_t PMU_GetCycleCounterMask(void)
{
    return PMU_GetCountersMask(true, 0);
}

/**
 * @brief Get a bitmask for all event and cycle counters.
 * @return Bitmask for all counters.
 */
uint32_t PMU_GetAllCountersMask(void)
{
    return PMU_GetCountersMask( true, PMU_GetNumEventCounters() );
}

/**
 * @brief Enable all event and cycle counters by setting the enable bit in PMCR.
 */
void PMU_EnableAllCounters(void)
{
    uint32_t mask = __get_PMCR();
    __set_PMCR(mask | 1UL);
}

/**
 * @brief Disable all event and cycle counters by clearing the enable bit in PMCR.
 */
void PMU_DisableAllCounters(void)
{
    uint32_t mask = __get_PMCR();
    __set_PMCR(mask & ~1UL);
}

/**
 * @brief Start a specific event counter by index.
 * @param event_counter_index Index of the event counter to start.
 * @return EXIT_SUCCESS or EXIT_FAILURE.
 */
uint32_t PMU_StartEventCounterByIndex(uint8_t event_counter_index)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PMU_CheckCounterIndex(event_counter_index))
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nDetected an error with the event counter index %u\n\r", event_counter_index);
        ret = EXIT_FAILURE;
    }
    else
    {
        __set_PMCNTENSET(1UL << event_counter_index);
    }
    return ret;
}


/**
 * @brief Start all event and cycle counters.
 */
void PMU_StartAllCounters(void)
{
    uint32_t mask = PMU_GetAllCountersMask();
    __set_PMCNTENSET(mask);
}

/**
 * @brief Stop a specific event counter by index.
 * @param event_counter_index Index of the event counter to stop.
 * @return EXIT_SUCCESS or EXIT_FAILURE.
 */
uint32_t PMU_StopEventCounterByIndex(uint8_t event_counter_index)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PMU_CheckCounterIndex(event_counter_index))
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nDetected an error with the event counter index %u\n\r",
                  event_counter_index);
        ret = EXIT_FAILURE;
    }
    else
    {
        __set_PMCNTENCLR(1UL << event_counter_index);
    }
    return ret;
}

/**
 * @brief Stop all event and cycle counters.
 */
void PMU_StopAllCounters(void)
{
    uint32_t mask = PMU_GetAllCountersMask();
    __set_PMCNTENCLR(mask);
}

/**
 * @brief Configure an event counter to monitor a specific event type.
 * @param event_counter_index Index of the event counter to configure.
 * @param event_type Event type to monitor.
 * @return EXIT_SUCCESS or EXIT_FAILURE.
 */
uint32_t PMU_ConfigureEventCounter(uint8_t event_counter_index, PMU_EVENT_TYPE event_type)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PMU_CheckCounterIndex(event_counter_index))
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nDetected an error with the event counter index %u\n\r",
                  event_counter_index);
        ret = EXIT_FAILURE;
    }
    else if (event_type > PMU_EVENT_BranchTaken)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nEvent type %u is out of range [0:%u]\n\r", event_type, PMU_EVENT_BranchTaken);
        ret = EXIT_FAILURE;
    }
    else
    {
        // Select the event counter
        __set_PMSELR(event_counter_index);
        // Set the event type to monitor
        __set_PMXEVTYPER(event_type);
    }
    return ret;
}

/**
 * @brief Read the value of a specific event counter.
 * @param event_counter_index Index of the event counter to read.
 * @param p_event_counter_value Pointer to store the counter value.
 * @return EXIT_SUCCESS or EXIT_FAILURE.
 */
uint32_t PMU_ReadEventCounterValue(uint8_t event_counter_index, uint32_t* p_event_counter_value)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PMU_CheckCounterIndex(event_counter_index))
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nDetected an error with the event counter index %u\n\r",
                  event_counter_index);
        ret = EXIT_FAILURE;
    }
    else
    {
        // Select the event counter to read
        __set_PMSELR(event_counter_index);
        // Read the event counter value
        if (p_event_counter_value == NULL)
        {
            ret = EXIT_FAILURE;
        }
        else
        {
            *p_event_counter_value = __get_PMXEVCNTR();
        }
    }
    return ret;
}

/**
 * @brief Read the values of all event counters up to num_event_counter_to_read.
 * @param p_event_counter_values Array to store the counter values.
 * @param num_event_counter_to_read Number of counters to read.
 * @return Number of counters actually read.
 */
uint8_t PMU_ReadAllEventCounterValues(uint32_t *p_event_counter_values, uint8_t num_event_counter_to_read)
{
    uint8_t curr_index = 0;
    for(; (curr_index < num_event_counter_to_read) && (curr_index < PMU_GetNumEventCounters()); curr_index++)
    {
        // Select the event counter to read
        __set_PMSELR(curr_index);
        // Read the event counter value
        p_event_counter_values[curr_index] = __get_PMXEVCNTR();
    }
    return curr_index;
}

/**
 * @brief Write a value to a specific event counter.
 * @param event_counter_index Index of the event counter to write.
 * @param event_counter_value Value to write.
 * @return EXIT_SUCCESS or EXIT_FAILURE.
 */
uint32_t PMU_WriteEventCounterValue(uint8_t event_counter_index, uint32_t event_counter_value)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PMU_CheckCounterIndex(event_counter_index))
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nDetected an error with the event counter index %u\n\r",
                  event_counter_index);
        ret = EXIT_FAILURE;
    }
    else
    {
        // Select the event counter to write
        __set_PMSELR(event_counter_index);
        // Write the event counter value
        __set_PMXEVCNTR(event_counter_value);
    }
    return ret;
}


/**
 * @brief Write values to all event counters up to num_event_counter_to_write.
 * @param p_event_counter_values Array of values to write.
 * @param num_event_counter_to_write Number of counters to write.
 * @return Number of counters actually written.
 */
uint8_t PMU_WriteAllEventCounterValues(uint32_t *p_event_counter_values, uint8_t num_event_counter_to_write)
{
    uint8_t curr_index = 0;

    for(; ( curr_index < num_event_counter_to_write ) && ( curr_index < PMU_GetNumEventCounters() ); curr_index ++ )
    {
        __set_PMSELR(curr_index);
        __set_PMXEVCNTR(p_event_counter_values[curr_index]);
    }
    return curr_index;
}

/**
 * @brief Clear the cycle counter overflow flag.
 * @return true if overflow was present and cleared, false otherwise.
 */
bool PMU_ClearCycleCounterOverflow(void)
{
    uint32_t value = __get_PMOVSR();
    uint32_t mask = 1UL << 31;
    bool result = false;

    if (value & mask)
    {
        __set_PMOVSR(mask);
        result = true;
    }
    return result;
}

/**
 * @brief Clear the overflow flag for a specific event counter.
 * @param event_counter_index Index of the event counter.
 * @param p_event_counter_overflow Pointer to store overflow status (true if overflowed).
 * @return EXIT_SUCCESS or EXIT_FAILURE.
 */
uint32_t PMU_ClearEventCounterOverflow(uint8_t event_counter_index, bool* p_event_counter_overflow)
{
    uint32_t ret = EXIT_SUCCESS;
    uint32_t value = 0UL;
    uint32_t mask = 0UL;

    if (!__PMU_CheckCounterIndex(event_counter_index))
    { 
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nDetected an error with the event counter index %u\n\r", event_counter_index);
        ret = EXIT_FAILURE;
    }
    else
    {
        value = __get_PMOVSR();
        mask = 1UL << event_counter_index;

        if (value & mask)
        {
            *p_event_counter_overflow = true;
            __set_PMOVSR(mask);
        }
        else
        {
            *p_event_counter_overflow = false;
        }
    }
    return ret;
}


/**
 * @brief Clear all event counter overflow flags.
 * @param p_event_counter_overflows Array to store overflow status for each counter.
 * @param event_counter_overflows_len Length of the array.
 * @return Number of counters checked.
 */
uint8_t PMU_ClearAllEventCounterOverflows(bool* p_event_counter_overflows, uint8_t event_counter_overflows_len)
{
    uint8_t count_index = 0;
    uint32_t clear_mask = PMU_GetEventCountersMask( -1 );
    uint8_t num_evt_cnt = 0 ;
    uint32_t value = 0 ;

    if ( ( event_counter_overflows_len > PMU_GetNumEventCounters() ) )
    {
        num_evt_cnt = PMU_GetNumEventCounters() ;
    }
    else
    {
        num_evt_cnt = event_counter_overflows_len ;
    }

    if ( p_event_counter_overflows != NULL ) 
    {
        value = __get_PMOVSR();

        for(; count_index < num_evt_cnt; count_index ++ )
        {
            if ( value & ( 1UL << count_index ) )
            {
                p_event_counter_overflows[ count_index ] = true ;
            }
            else
            {
                p_event_counter_overflows[ count_index ] = false ;
            }
        }
    }
    __set_PMOVSR(clear_mask);
    return count_index;
}

/**
 * @brief Increment a specific event counter by software.
 * @param event_counter_index Index of the event counter to increment.
 * @return EXIT_SUCCESS or EXIT_FAILURE.
 */
uint32_t PMU_IncrementEventCounter(uint8_t event_counter_index)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PMU_CheckCounterIndex(event_counter_index))
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nDetected an error with the event counter index %u\n\r", event_counter_index);
        ret = EXIT_FAILURE;
    }
    else
    {
        __set_PMSWINC(1UL << event_counter_index);
    }
    return ret;
}

/**
 * @brief Enable overflow interrupt for a specific event counter.
 * @param event_counter_index Index of the event counter.
 * @return EXIT_SUCCESS or EXIT_FAILURE.
 */
uint32_t PMU_EnableEventCounterInterruptByIndex(uint8_t event_counter_index)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PMU_CheckCounterIndex(event_counter_index))
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nDetected an error with the event counter index %u\n\r", event_counter_index);
        ret = EXIT_FAILURE;
    }
    else
    {
        __set_PMINTENSET(1UL << event_counter_index);
    }
    return ret;
}


/**
 * @brief Enable overflow interrupt for all event counters.
 */
void PMU_EnableAllEventCounterInterrupt(void)
{
    uint32_t evt_mask = PMU_GetAllEventCountersMask();
    __set_PMINTENSET(evt_mask);
}

/**
 * @brief Enable overflow interrupt for all event and cycle counters.
 */
void PMU_EnableAllCounterInterrupt(void)
{
    uint32_t evt_mask = PMU_GetAllCountersMask();
    __set_PMINTENSET(evt_mask);
}

/**
 * @brief Disable overflow interrupt for a specific event counter.
 * @param event_counter_index Index of the event counter.
 * @return EXIT_SUCCESS or EXIT_FAILURE.
 */
uint32_t PMU_DisableEventCounterInterruptByIndex(uint8_t event_counter_index)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PMU_CheckCounterIndex(event_counter_index))
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nDetected an error with the event counter index %u\n\r", event_counter_index);
        ret = EXIT_FAILURE;
    }
    else
    {
        __set_PMINTENCLR(1UL << event_counter_index);
    }
    return ret;
}

/**
 * @brief Disable overflow interrupt for all event counters.
 */
void PMU_DisableAllEventCounterInterrupt(void)
{
    uint32_t evt_mask = PMU_GetAllEventCountersMask();
    __set_PMINTENCLR(evt_mask);
}

/**
 * @brief Disable overflow interrupt for all event and cycle counters.
 */
void PMU_DisableAllCounterInterrupt(void)
{
    uint32_t evt_mask = PMU_GetAllCountersMask();
    __set_PMINTENCLR(evt_mask);
}


// PMU initialization to count CPU cycles
void PMU_Enable(void)
{
    // Enable user-mode access to the performance counters
    asm volatile ("MCR p15, 0, %0, c9, c14, 0" : : "r"(1)); // Allow user-mode access to PMU
    // Enable all counters (including cycle counter)
    asm volatile ("MCR p15, 0, %0, c9, c12, 0" : : "r"(1));
    // Reset all event counters and the cycle counter
    asm volatile ("MCR p15, 0, %0, c9, c12, 2" : : "r"(0xFFFFFFFF));
    // Enable the cycle counter specifically
    asm volatile ("MCR p15, 0, %0, c9, c12, 1" : : "r"(1 << 31));
}

// Read the current value of the cycle counter (PMCCNTR)
static inline uint32_t PMU_GetCycleCount(void)
{
    uint32_t value;
    asm volatile ("MRC p15, 0, %0, c9, c13, 0" : "=r"(value)); // Read cycle counter register
    return value;
}

// Global variables for idle time measurement
volatile uint64_t idle_cycles = 0; // Accumulated idle cycles
static uint32_t idle_start = 0;    // Cycle count at idle entry

// Call this at the start of the idle period
void PMU_Idle_Enter(void)
{
    idle_start = PMU_GetCycleCount();
}

// Call this at the end of the idle period
void PMU_Idle_Exit(void)
{
    uint32_t idle_end = PMU_GetCycleCount();
    // Handle 32-bit counter overflow
    if (idle_end >= idle_start)
        idle_cycles += (idle_end - idle_start);
    else
        idle_cycles += (0xFFFFFFFF - idle_start + 1) + idle_end;
}

// Compute CPU load as a percentage (call periodically, e.g., every 1 second)
float PMU_ComputeCpuLoad(void)
{
    static uint64_t last_idle_cycles = 0;   // Idle cycles at last measurement
    static uint32_t last_total_cycles = 0;  // Total cycles at last measurement

    uint32_t total_cycles_now = PMU_GetCycleCount(); // Current total cycles
    uint64_t idle_cycles_now = idle_cycles;          // Current idle cycles

    uint32_t total_cycles_elapsed = total_cycles_now - last_total_cycles; // Cycles since last check
    uint64_t idle_cycles_elapsed = idle_cycles_now - last_idle_cycles;    // Idle cycles since last check

    // Calculate CPU load: 1.0 - (idle time / total time)
    if (total_cycles_elapsed == 0)
    {
        return 0.0f;
    }
    float cpu_load = 1.0f - ((float)idle_cycles_elapsed / (float)total_cycles_elapsed);

    // Update last values for next measurement
    last_total_cycles = total_cycles_now;
    last_idle_cycles = idle_cycles_now;

    return (cpu_load * 100.0f); // Return CPU load as a percentage
}
