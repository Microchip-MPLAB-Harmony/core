/*******************************************************************************
  Operating System Abstraction Layer Basic Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    osal_impl_basic.h

  Summary:
    Header file for the OSAL Basic implementation.

  Description:
    This file defines the additions or variations to the OSAL base implementation.
 Where it is logical or possible to implement an OSAL function in a simple form
 without an RTOS being present then the function has been defined here and
 implemented either here as an inline or #define. Longer functions that are part
 of the basic implementation may also be found in the file osal.c
 The best way to consider this file is detailing any deviations from the osal.h
 definitions OR as the complete implementation of those functions when pretending
 to support BASIC operations.
 *******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
 *******************************************************************************/
// DOM-IGNORE-END

#ifndef OSAL_IMPL_BASIC_H
#define OSAL_IMPL_BASIC_H

#ifdef __cplusplus
extern "C" {
#endif

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include "system/int/sys_int.h"
#include "device.h"
<#if ENABLE_OSAL_TIMEOUT_FEATURE == true>
#include "peripheral/${OSAL_TIMEOUT_PERIPHERAL?lower_case}/plib_${OSAL_TIMEOUT_PERIPHERAL?lower_case}.h"
</#if>


typedef uint8_t                         OSAL_SEM_HANDLE_TYPE;
typedef uint8_t                         OSAL_MUTEX_HANDLE_TYPE;
typedef uint32_t                        OSAL_CRITSECT_DATA_TYPE;
typedef uint32_t                        OSAL_TICK_TYPE;
typedef uint32_t                        OSAL_SEM_COUNT_TYPE;

#define OSAL_WAIT_FOREVER               (OSAL_TICK_TYPE)~0U
#define OSAL_NO_WAIT                    (OSAL_TICK_TYPE)0

#define OSAL_SEM_DECLARE(semID)         OSAL_SEM_HANDLE_TYPE        semID
#define OSAL_MUTEX_DECLARE(mutexID)     OSAL_MUTEX_HANDLE_TYPE      mutexID

// *****************************************************************************
/* Macro: OSAL_ASSERT
 */

#define OSAL_ASSERT(test, message)      test

// *****************************************************************************
/* OSAL Result type

  Summary:
    Enumerated type representing the general return value from OSAL functions.

  Description:
    This enum represents possible return types from OSAL functions.

  Remarks:
    These enum values are the possible return values from OSAL functions
    where a standard success/fail type response is required. The majority
    of OSAL functions will return this type with a few exceptions.
*/

typedef enum OSAL_SEM_TYPE
{
  OSAL_SEM_TYPE_BINARY,
  OSAL_SEM_TYPE_COUNTING
} OSAL_SEM_TYPE;

typedef enum OSAL_CRIT_TYPE
{
  OSAL_CRIT_TYPE_LOW,
  OSAL_CRIT_TYPE_HIGH
} OSAL_CRIT_TYPE;

typedef enum OSAL_RESULT
{
  OSAL_RESULT_NOT_IMPLEMENTED = -1,
  OSAL_RESULT_FALSE = 0,
  OSAL_RESULT_FAIL = 0,
  OSAL_RESULT_TRUE = 1,
  OSAL_RESULT_SUCCESS = 1,
} OSAL_RESULT;

// *****************************************************************************
// *****************************************************************************
// Section: Section: Interface Routines Group Declarations
// *****************************************************************************
// *****************************************************************************
__STATIC_INLINE OSAL_RESULT OSAL_SEM_Create(OSAL_SEM_HANDLE_TYPE* semID, OSAL_SEM_TYPE type, OSAL_SEM_COUNT_TYPE maxCount, OSAL_SEM_COUNT_TYPE initialCount);
__STATIC_INLINE OSAL_RESULT OSAL_SEM_Delete(OSAL_SEM_HANDLE_TYPE* semID);
__STATIC_INLINE OSAL_RESULT OSAL_SEM_Pend(OSAL_SEM_HANDLE_TYPE* semID, OSAL_TICK_TYPE waitMS);
__STATIC_INLINE OSAL_RESULT OSAL_SEM_Post(OSAL_SEM_HANDLE_TYPE* semID);
__STATIC_INLINE OSAL_RESULT OSAL_SEM_PostISR(OSAL_SEM_HANDLE_TYPE* semID);
__STATIC_INLINE OSAL_SEM_COUNT_TYPE OSAL_SEM_GetCount(OSAL_SEM_HANDLE_TYPE* semID);

__STATIC_INLINE OSAL_CRITSECT_DATA_TYPE OSAL_CRIT_Enter(OSAL_CRIT_TYPE severity);
__STATIC_INLINE void OSAL_CRIT_Leave(OSAL_CRIT_TYPE severity, OSAL_CRITSECT_DATA_TYPE status);

__STATIC_INLINE OSAL_RESULT OSAL_MUTEX_Create(OSAL_MUTEX_HANDLE_TYPE* mutexID);
__STATIC_INLINE OSAL_RESULT OSAL_MUTEX_Delete(OSAL_MUTEX_HANDLE_TYPE* mutexID);
__STATIC_INLINE OSAL_RESULT OSAL_MUTEX_Lock(OSAL_MUTEX_HANDLE_TYPE* mutexID, OSAL_TICK_TYPE waitMS);
__STATIC_INLINE OSAL_RESULT OSAL_MUTEX_Unlock(OSAL_MUTEX_HANDLE_TYPE* mutexID);

__STATIC_INLINE void* OSAL_Malloc(size_t size);
__STATIC_INLINE void OSAL_Free(void* pData);

OSAL_RESULT OSAL_Initialize(void);

__STATIC_INLINE const char* OSAL_Name(void);

// *****************************************************************************
// *****************************************************************************
// Section: Interface Routines Group Defintions
// *****************************************************************************
// *****************************************************************************

/* Critical Section group */
// *****************************************************************************
/* Function: OSAL_CRITSECT_DATA_TYPE OSAL_CRIT_Enter(OSAL_CRIT_TYPE severity)
 */
static OSAL_CRITSECT_DATA_TYPE OSAL_CRIT_Enter(OSAL_CRIT_TYPE severity)
{
    bool readData;
  if(severity == OSAL_CRIT_TYPE_LOW)
  {
    return (0);
  }
  /*if priority is set to HIGH the user wants interrupts disabled*/
  readData = SYS_INT_Disable();
  return ((uint32_t)readData);
}

// *****************************************************************************
/* Function: void OSAL_CRIT_Leave(OSAL_CRIT_TYPE severity, OSAL_CRITSECT_DATA_TYPE status)
 */
static void OSAL_CRIT_Leave(OSAL_CRIT_TYPE severity, OSAL_CRITSECT_DATA_TYPE status)
{
  if(severity == OSAL_CRIT_TYPE_LOW)
  {
    return;
  }
  /*if priority is set to HIGH the user wants interrupts re-enabled to the state
  they were before disabling.*/
  SYS_INT_Restore((bool)status);
}

// *****************************************************************************
/* MISRA C-2012 Rule 10.3 False positive:11 Deviation record ID -  H3_MISRAC_2012_R_10_3_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block fp:11 "MISRA C-2012 Rule 10.3" "H3_MISRAC_2012_R_10_3_DR_1"
</#if>
/* Function: OSAL_RESULT OSAL_SEM_Create(OSAL_SEM_HANDLE_TYPE semID, OSAL_SEM_TYPE type,
                                OSAL_SEM_COUNT_TYPE maxCount, OSAL_SEM_COUNT_TYPE initialCount)
 */
static OSAL_RESULT __attribute__((always_inline)) OSAL_SEM_Create(OSAL_SEM_HANDLE_TYPE* semID, OSAL_SEM_TYPE type,
                                OSAL_SEM_COUNT_TYPE maxCount, OSAL_SEM_COUNT_TYPE initialCount)
{
    OSAL_CRITSECT_DATA_TYPE IntState;

    if (semID == NULL)
    {
        return OSAL_RESULT_FAIL;
    }

    IntState = OSAL_CRIT_Enter(OSAL_CRIT_TYPE_HIGH);

    if (type == OSAL_SEM_TYPE_COUNTING)
    {
        *semID = initialCount;
    }
    else
    {
        *semID = (initialCount == 0U)? 0U : 1U;
    }

    OSAL_CRIT_Leave(OSAL_CRIT_TYPE_HIGH,IntState);

    return OSAL_RESULT_SUCCESS;
}

// *****************************************************************************
/* Function: OSAL_RESULT OSAL_SEM_Delete(OSAL_SEM_HANDLE_TYPE semID)
 */
static OSAL_RESULT __attribute__((always_inline)) OSAL_SEM_Delete(OSAL_SEM_HANDLE_TYPE* semID)
{
   return (OSAL_RESULT_SUCCESS);
}

// *****************************************************************************
/* Function: OSAL_RESULT OSAL_SEM_Pend(OSAL_SEM_HANDLE_TYPE semID, OSAL_TICK_TYPE waitMS)
 */
static  OSAL_RESULT __attribute__((always_inline)) OSAL_SEM_Pend(OSAL_SEM_HANDLE_TYPE* semID, OSAL_TICK_TYPE waitMS)
{
    volatile OSAL_SEM_HANDLE_TYPE* sem = semID;
    OSAL_CRITSECT_DATA_TYPE IntState;

    if (sem == NULL)
    {
        return OSAL_RESULT_FAIL;
    }

    if (waitMS == OSAL_WAIT_FOREVER)
    {
        while (*sem == 0U){}
    }
    <#if ENABLE_OSAL_TIMEOUT_FEATURE == true>
    else
    {
        if (waitMS != OSAL_NO_WAIT)
        {
            ${OSAL_TIMEOUT_PERIPHERAL}_TIMEOUT timeout;

            ${OSAL_TIMEOUT_PERIPHERAL}_StartTimeOut(&timeout, waitMS);

            while ((${OSAL_TIMEOUT_PERIPHERAL}_IsTimeoutReached(&timeout) == false) && (*sem == 0U)){}
        }
    }
    </#if>
    if (*sem > 0U)
    {
        IntState = OSAL_CRIT_Enter(OSAL_CRIT_TYPE_HIGH);
        (*sem)--;
        OSAL_CRIT_Leave(OSAL_CRIT_TYPE_HIGH,IntState);
        return OSAL_RESULT_SUCCESS;
    }
    else
    {
        return OSAL_RESULT_FAIL;
    }
}

// *****************************************************************************
/* Function: OSAL_RESULT OSAL_SEM_Post(OSAL_SEM_HANDLE_TYPE semID)
 */
static OSAL_RESULT __attribute__((always_inline)) OSAL_SEM_Post(OSAL_SEM_HANDLE_TYPE* semID)
{
  OSAL_CRITSECT_DATA_TYPE IntState;

    if (semID == NULL)
    {
        return OSAL_RESULT_FAIL;
    }

    IntState = OSAL_CRIT_Enter(OSAL_CRIT_TYPE_HIGH);
    (*semID)++;
    OSAL_CRIT_Leave(OSAL_CRIT_TYPE_HIGH,IntState);

    return OSAL_RESULT_SUCCESS;
}

// *****************************************************************************
/* Function: OSAL_RESULT OSAL_SEM_PostISR(OSAL_SEM_HANDLE_TYPE semID)
 */
static OSAL_RESULT __attribute__((always_inline)) OSAL_SEM_PostISR(OSAL_SEM_HANDLE_TYPE* semID)
{
    if (semID == NULL)
    {
        return OSAL_RESULT_FAIL;
    }
    (*semID)++;
    return OSAL_RESULT_SUCCESS;
}

// *****************************************************************************
/* Function: OSAL_SEM_COUNT_TYPE OSAL_SEM_GetCount(OSAL_SEM_HANDLE_TYPE semID)
 */
static OSAL_SEM_COUNT_TYPE __attribute__((always_inline)) OSAL_SEM_GetCount(OSAL_SEM_HANDLE_TYPE* semID)
{
    return *semID;
}

// *****************************************************************************
/* Function: OSAL_RESULT OSAL_MUTEX_Create(OSAL_MUTEX_HANDLE_TYPE mutexID)
 */
static OSAL_RESULT __attribute__((always_inline)) OSAL_MUTEX_Create(OSAL_MUTEX_HANDLE_TYPE* mutexID)
{
    if (mutexID == NULL)
    {
        return OSAL_RESULT_FAIL;
    }
    *mutexID = 1;
    return OSAL_RESULT_SUCCESS;
}

// *****************************************************************************
/* Function: OSAL_RESULT OSAL_MUTEX_Delete(OSAL_MUTEX_HANDLE_TYPE mutexID)
 */
static OSAL_RESULT __attribute__((always_inline)) OSAL_MUTEX_Delete(OSAL_MUTEX_HANDLE_TYPE* mutexID)
{
  return (OSAL_RESULT_SUCCESS);
}
// *****************************************************************************
/* Function: OSAL_RESULT OSAL_MUTEX_Lock(OSAL_MUTEX_HANDLE_TYPE mutexID, OSAL_TICK_TYPE waitMS)
 */
static OSAL_RESULT __attribute__((always_inline)) OSAL_MUTEX_Lock(OSAL_MUTEX_HANDLE_TYPE* mutexID, uint32_t waitMS)
{
    if (mutexID == NULL)
    {
        return OSAL_RESULT_FAIL;
    }
    if (waitMS == OSAL_WAIT_FOREVER)
    {
        while (*mutexID == 0U){}
    }
    <#if ENABLE_OSAL_TIMEOUT_FEATURE == true>
    else
    {
        if (waitMS != OSAL_NO_WAIT)
        {
            ${OSAL_TIMEOUT_PERIPHERAL}_TIMEOUT timeout;

            ${OSAL_TIMEOUT_PERIPHERAL}_StartTimeOut(&timeout, waitMS);

            while ((${OSAL_TIMEOUT_PERIPHERAL}_IsTimeoutReached(&timeout) == false) && (*mutexID == 0U)){}
        }
    }
    </#if>
    if (*mutexID == 1U)
    {
        *mutexID = 0;
        return OSAL_RESULT_SUCCESS;
    }
    else
    {
        return OSAL_RESULT_FAIL;
    }
}

// *****************************************************************************
/* Function: OSAL_RESULT OSAL_MUTEX_Unlock(OSAL_MUTEX_HANDLE_TYPE mutexID)
 */
static OSAL_RESULT __attribute__((always_inline)) OSAL_MUTEX_Unlock(OSAL_MUTEX_HANDLE_TYPE* mutexID)
{
    if (mutexID == NULL)
    {
        return OSAL_RESULT_FAIL;
    }
    *mutexID = 1;
    return OSAL_RESULT_SUCCESS;
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 10.3"
</#if>
/* MISRAC 2012 deviation block end */
// *****************************************************************************
/* MISRA C-2012 Rule 4.12 devaited:1, 21.3 deviated:2 Deviation record ID -
   H3_MISRAC_2012_R_4_12_DR_1 & H3_MISRAC_2012_R_21_3_DR_1*/
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance block \
(deviate:1 "MISRA C-2012 Directive 4.12" "H3_MISRAC_2012_D_4_12_DR_1" )\
(deviate:2 "MISRA C-2012 Rule 21.3" "H3_MISRAC_2012_R_21_3_DR_1" )
</#if>

/* Function: void* OSAL_Malloc(size_t size)
 */
static void* __attribute__((always_inline)) OSAL_Malloc(size_t size)
{
    return malloc(size);
}

// *****************************************************************************
/* Function: void OSAL_Free(void* pData)
 */
static void __attribute__((always_inline)) OSAL_Free(void* pData)
{
    free(pData);
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Directive 4.12"
#pragma coverity compliance end_block "MISRA C-2012 Rule 21.3"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */
// Initialization and Diagnostics
// *****************************************************************************

// *****************************************************************************
/* Function: const char* OSAL_Name()
 */
static const char* __attribute__((always_inline)) OSAL_Name(void)
{
  return((const char*) "BASIC");
}


#ifdef __cplusplus
}
#endif

#endif // _OSAL_IMPL_BASIC_H

/*******************************************************************************
 End of File
 */




