/*******************************************************************************
  PMU PLIB

  Company:
    Microchip Technology Inc.

  File Name:
    plib_pmu.h

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

#ifndef _ARM_CORTEX_A7_PMU_H
#define _ARM_CORTEX_A7_PMU_H

#include <stdbool.h>
#include "definitions.h"
#include "device.h"


/* Provide C++ Compatibility */
#ifdef __cplusplus
extern "C" {
#endif


/* Performance Monitor Control Register (PMCR) Masks */
typedef enum 
{
    PMCR_MASK_E          = (1UL << 0),
    PMCR_MASK_P          = (1UL << 1),
    PMCR_MASK_C          = (1UL << 2),
    PMCR_MASK_D          = (1UL << 3),
    PMCR_MASK_X          = (1UL << 4),
    PMCR_MASK_DP         = (1UL << 5),
    _PMCR_MASK_RESERVED_ = ( 31UL <<  6),
    PMCR_MASK_N          = ( 31UL << 11),
    PMCR_MASK_IDCODE     = (255UL << 16),
    PMCR_MASK_IMP        = (255UL << 24)
} PMCR_MASK;

/* Performance Monitor Control Register (PMCR) Bit Offsets */
typedef enum 
{
    PMCR_OFFSET_E          = 0UL,
    PMCR_OFFSET_P          = 1UL,
    PMCR_OFFSET_C          = 2UL,
    PMCR_OFFSET_D          = 3UL,
    PMCR_OFFSET_X          = 4UL,
    PMCR_OFFSET_DP         = 5UL,
    _PMCR_OFFSET_RESERVED_ = 6UL,
    PMCR_OFFSET_N          = 11UL,
    PMCR_OFFSET_IDCODE     = 16UL,
    PMCR_OFFSET_IMP        = 24UL
} PMCR_OFFSET;

/* Event Type Select Register (PMXEVTYPER) */
typedef enum 
{
    PMU_EVENT_SwIncr = 0UL,
    PMU_EVENT_ICacheMiss,
    PMU_EVENT_ITLBMiss,
    PMU_EVENT_DCacheMiss,
    PMU_EVENT_DCacheAccess,
    PMU_EVENT_DTCLMiss,
    PMU_EVENT_DRead,
    PMU_EVENT_DWrite,
    PMU_EVENT_Instruction,
    PMU_EVENT_ExceptionTaken,
    PMU_EVENT_ExceptionReturn,
    PMU_EVENT_ContextIDR,
    PMU_EVENT_PCSwChange,
    PMU_EVENT_BranchInstr,
    PMU_EVENT_Return,
    PMU_EVENT_UnalignedAccess,
    PMU_EVENT_BranchNotPredict,
    PMU_EVENT_CycleCount,
    PMU_EVENT_BranchTaken
} PMU_EVENT_TYPE;

/* Local Functions */
__STATIC_FORCEINLINE uint32_t __get_PMCR(void)
{
    uint32_t result;
    __get_CP(15, 0, result, 9, 12, 0);
    return result;
}

__STATIC_FORCEINLINE void __set_PMCR(uint32_t value)
{
    __set_CP(15, 0, value, 9, 12, 0);
}

/* Count Enable Set Register (PMCNTENSET) */
__STATIC_FORCEINLINE uint32_t __get_PMCNTENSET(void)
{
    uint32_t result;
    __get_CP(15, 0, result, 9, 12, 1);
    return result;
}

__STATIC_FORCEINLINE void __set_PMCNTENSET(uint32_t value)
{
    __set_CP(15, 0, value, 9, 12, 1);
}

/* Count Enable Clear Register (PMCNTENCLR) */
__STATIC_FORCEINLINE uint32_t __get_PMCNTENCLR(void)
{
    uint32_t result;
    __get_CP(15, 0, result, 9, 12, 2);
    return result;
}

__STATIC_FORCEINLINE void __set_PMCNTENCLR(uint32_t value)
{
    __set_CP(15, 0, value, 9, 12, 2);
}

/* Overflow Flag Status Register (PMOVSR) */
__STATIC_FORCEINLINE uint32_t __get_PMOVSR(void)
{
    uint32_t result;
    __get_CP(15, 0, result, 9, 12, 3);
    return result;
}

__STATIC_FORCEINLINE void __set_PMOVSR(uint32_t value)
{
    __set_CP(15, 0, value, 9, 12, 3);
}

/* Software Increment Register (PMSWINC) */
__STATIC_FORCEINLINE void __set_PMSWINC(uint32_t value)
{
    __set_CP(15, 0, value, 9, 12, 4);
}

/* Event Counter Selection Register (PMSELR) */
__STATIC_FORCEINLINE uint32_t __get_PMSELR(void)
{
    uint32_t result;
    __get_CP(15, 0, result, 9, 12, 5);
    return result & 0x1F;
}

__STATIC_FORCEINLINE void __set_PMSELR(uint32_t value)
{
    __set_CP(15, 0, value & 0x1F, 9, 12, 5);
}

/* Cycle Count Register (PMCCNTR) */
__STATIC_FORCEINLINE uint32_t __get_PMCCNTR(void)
{
    uint32_t result;
    __get_CP(15, 0, result, 9, 13, 0);
    return result;
}

__STATIC_FORCEINLINE void __set_PMCCNTR(uint32_t value)
{
    __set_CP(15, 0, value, 9, 13, 0);
}

/* Event Type Register (PMXEVTYPER) */
__STATIC_FORCEINLINE uint32_t __get_PMXEVTYPER(void)
{
    uint32_t result;
    __get_CP(15, 0, result, 9, 13, 1);
    return result & 0xFF;
}

__STATIC_FORCEINLINE void __set_PMXEVTYPER(uint32_t value)
{
    __set_CP(15, 0, value & 0xFF, 9, 13, 1);
}

/* Event Count Register (PMXEVCNTR) */
__STATIC_FORCEINLINE uint32_t __get_PMXEVCNTR(void)
{
    uint32_t result;
    __get_CP(15, 0, result, 9, 13, 2);
    return result;
}

__STATIC_FORCEINLINE void __set_PMXEVCNTR(uint32_t value)
{
    __set_CP(15, 0, value, 9, 13, 2);
}

/* User Enable Register (PMUSERENR) */
__STATIC_FORCEINLINE uint32_t __get_PMUSERENR(void)
{
    uint32_t result;
    __get_CP(15, 0, result, 9, 14, 0);
    return result & 0x1;
}

__STATIC_FORCEINLINE void __set_PMUSERENR(uint32_t value)
{
    __set_CP(15, 0, value & 0x1, 9, 14, 0);
}

/* Interrupt Enable Set Register (PMINTENSET) */
__STATIC_FORCEINLINE uint32_t __get_PMINTENSET(void)
{
    uint32_t result;
    __get_CP(15, 0, result, 9, 14, 1);
    return result & 1U;
}

__STATIC_FORCEINLINE void __set_PMINTENSET(uint32_t value)
{
    __set_CP(15, 0, value, 9, 14, 1);
}

/* Interrupt Enable Clear Register (PMINTENCLR) */
__STATIC_FORCEINLINE uint32_t __get_PMINTENCLR(void)
{
    uint32_t result;
    __get_CP(15, 0, result, 9, 14, 2);
    return result & 1U;
}

__STATIC_FORCEINLINE void __set_PMINTENCLR(uint32_t value)
{
    __set_CP(15, 0, value, 9, 14, 2);
}

/* Check index of the event counter */
bool __PMU_CheckCounterIndex(uint8_t event_counter_index);

/* Return the number of event counters available on the chip */
__STATIC_FORCEINLINE uint8_t PMU_GetNumEventCounters(void)
{
    return (__get_PMCR() & PMCR_MASK_N ) >> PMCR_OFFSET_N;
}

/* Enable/Disable event and cycle counters */
__STATIC_FORCEINLINE void PMU_EnableCounters(void)
{
    __set_PMCR(__get_PMCR() | PMCR_MASK_E);
}
__STATIC_FORCEINLINE void PMU_DisableCounters(void)
{
    __set_PMCR(__get_PMCR() & ~PMCR_MASK_E);
}

/* Start event and/or cycle counters */
void PMU_StartAllCounters(void);

/* Stop event and/or cycle counters */
void PMU_StopAllCounters(void);

/* Reset counters */
__STATIC_FORCEINLINE void PMU_ResetAllCounters(void)
{
    __set_PMCR(__get_PMCR() | PMCR_MASK_C | PMCR_MASK_P);
}

/* Select which type of event is counted by the counter */
uint32_t PMU_ConfigureEventCounter(uint8_t event_counter_index, PMU_EVENT_TYPE event_type);

/* Read the values actually counted */
__STATIC_FORCEINLINE uint32_t PMU_ReadCycleCounterValue(void)
{
    return __get_PMCCNTR();
}
uint32_t PMU_ReadEventCounterValue(uint8_t event_counter_index, uint32_t* p_event_counter_value);

/* Write the values of the counter */
__STATIC_FORCEINLINE void PMU_WriteCycleCounterValue(uint32_t value)
{
    __set_PMCCNTR(value);
}
uint32_t PMU_WriteEventCounterValue(uint8_t event_counter_index, uint32_t event_counter_value);

/* Start event and/or cycle counters */
__STATIC_FORCEINLINE void PMU_StartCycleCounter(void)
{
    __set_PMCNTENSET(1UL << 31);
}
__STATIC_FORCEINLINE void PMU_StartEventCountersByMask(uint32_t event_counter_mask)
{
    __set_PMCNTENSET(event_counter_mask);
}
__STATIC_FORCEINLINE void PMU_StopEventCountersByMask(uint32_t event_counter_mask)
{
    __set_PMCNTENCLR(event_counter_mask);
}

/* Reset counters */
__STATIC_FORCEINLINE void PMU_ResetCycleCounter(void)
{
    __set_PMCR(__get_PMCR() | PMCR_MASK_C);
}
__STATIC_FORCEINLINE void PMU_ResetEventCounters(void)
{
    __set_PMCR(__get_PMCR() | PMCR_MASK_P);
}

/* Increment event counter by software */
__STATIC_FORCEINLINE void PMU_IncrementMultipleEventCounters(uint32_t event_counter_mask)
{
    __set_PMSWINC(event_counter_mask);
}

/* Enable overflow interrupt */
__STATIC_FORCEINLINE void PMU_EnableCycleCounterInterrupt(void)
{
    __set_PMINTENSET(1UL << 31);
}
__STATIC_FORCEINLINE void PMU_EnableEventCounterInterruptByMask(uint32_t event_counter_mask)
{
    __set_PMINTENSET(event_counter_mask);
}

/* Disable overflow interrupt */
__STATIC_FORCEINLINE void PMU_DisableCycleCounterInterrupt(void)
{
    __set_PMINTENCLR(1UL << 31);
}
__STATIC_FORCEINLINE void PMU_DisableEventCounterInterruptByMask(uint32_t event_counter_mask)
{
    __set_PMINTENCLR(event_counter_mask);
}

/* Low-level functions */
bool PMU_ClearCycleCounterOverflow(void);
uint32_t PMU_ClearEventCounterOverflow(uint8_t event_counter_index, bool* p_event_counter_overflow);
uint32_t PMU_IncrementEventCounter(uint8_t event_counter_index);
void PMU_EnableAllCounterInterrupt(void);
void PMU_DisableAllCounterInterrupt(void);

/* Advanced high-level functions */
uint32_t PMU_GetCountersMask(bool cycle_counter, uint8_t num_event_counter);
uint32_t PMU_GetEventCountersMask(uint8_t num_event_counter);
uint32_t PMU_GetAllEventCountersMask(void);
uint32_t PMU_GetCycleCounterMask(void);
uint32_t PMU_GetAllCountersMask(void);

uint32_t PMU_StartEventCounterByIndex(uint8_t event_counter_index);
uint32_t PMU_StopEventCounterByIndex(uint8_t event_counter_index);

uint8_t PMU_ReadAllEventCounterValues(uint32_t *p_event_counter_values, uint8_t num_event_counter_to_read);
uint8_t PMU_WriteAllEventCounterValues(uint32_t *p_event_counter_values, uint8_t num_event_counter_to_read);
uint8_t PMU_ClearAllEventCounterOverflows(bool* p_event_counter_overflows, uint8_t event_counter_overflows_len);

uint32_t PMU_EnableEventCounterInterruptByIndex(uint8_t event_counter_index);
void PMU_EnableAllEventCounterInterrupt(void);
uint32_t PMU_DisableEventCounterInterruptByIndex(uint8_t event_counter_index);
void PMU_DisableAllEventCounterInterrupt(void);

void PMU_Enable(void);
void PMU_Idle_Enter(void);
void PMU_Idle_Exit(void);
float PMU_ComputeCpuLoad(void);


#ifdef __cplusplus
}
#endif

#endif /* _ARM_CORTEX_A7_PMU_H */

