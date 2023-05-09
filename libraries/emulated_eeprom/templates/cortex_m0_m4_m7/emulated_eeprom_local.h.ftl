/*******************************************************************************
  EEPROM Emulator Local definitions and data structures

  Company:
    Microchip Technology Inc.

  File Name:
    emulated_eeprom_local.h

  Summary:
    EEPROM Emulator Library local definitions and data structures

  Description:
    This file defines data structures used internally by the EEPROM Emulator library.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2021 Microchip Technology Inc. and its subsidiaries.
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
//DOM-IGNORE-END

#ifndef EEPROM_EMULATOR_LOCAL_H
#define EEPROM_EMULATOR_LOCAL_H

#include "emulated_eeprom_definitions.h"
#include "osal/osal.h"

#ifdef __cplusplus
extern "C" {
#endif

/* MISRA C-2012 Rule 5.4 deviated:2 Deviation record ID -  H3_MISRAC_2012_R_5_4_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:2 "MISRA C-2012 Rule 5.4" "H3_MISRAC_2012_R_5_4_DR_1"
</#if>
#define EEPROM_EMULATOR_ROW_SIZE                                ${EEPROM_EMULATOR_ROW_SIZE}
#define EEPROM_EMULATOR_PAGES_PER_ROW                           ${EEPROM_EMULATOR_PAGES_PER_ROW}U
#define EEPROM_EMULATOR_PAGE_SIZE                               ${EEPROM_EMULATOR_PAGE_SIZE}U
#define EEPROM_EMULATOR_INVALID_PAGE_NUMBER                     0xFFFFU
#define EEPROM_EMULATOR_INVALID_ROW_NUMBER                      0xFFFFU
#define EEPROM_EMULATOR_HEADER_SIZE                             4U
#define EEPROM_EMULATOR_NUM_PHYSICAL_PAGES                      ${EEPROM_EMULATOR_NUM_PHYSICAL_PAGES}U
#define EEPROM_EMULATOR_NUM_LOGICAL_PAGES                       ${EEPROM_EMULATOR_NUM_LOGICAL_PAGES}U
#define EEPROM_EMULATOR_LOGICAL_SIZE_BYTES                      ${EEPROM_EMULATOR_EEPROM_LOGICAL_SIZE}
#define EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW               (EEPROM_EMULATOR_PAGES_PER_ROW>>1)

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 5.4"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */

<#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED?? && EEPROM_EMULATOR_RWWEE_ENABLED??>

    <#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED == true && EEPROM_EMULATOR_RWWEE_ENABLED == true>
    <#lt>#define EEPROM_EMULATOR_NUM_MAIN_ARRAY_PHY_PAGES                ${EEPROM_EMULATOR_MAIN_ARRAY_NUM_PHYSICAL_PAGES}
    </#if>

    <#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED == true>
    <#lt>#define EEPROM_EMULATOR_MAIN_ARRAY_EEPROM_START_ADDRESS        0x${EEPROM_EMULATOR_EEPROM_START_ADDRESS?upper_case}
    </#if>

    <#if EEPROM_EMULATOR_RWWEE_ENABLED == true>
    <#lt>#define EEPROM_EMULATOR_RWWEE_START_ADDRESS                    0x${EEPROM_EMULATOR_RWWEE_START_ADDRESS}
    </#if>

<#else>
#define EEPROM_EMULATOR_EEPROM_START_ADDRESS                   0x${EEPROM_EMULATOR_EEPROM_START_ADDRESS?upper_case}
</#if>

/** Size of the user data portion of each logical EEPROM page, in bytes. */
#define EEPROM_EMULATOR_PAGE_DATA_SIZE                         (EEPROM_EMULATOR_PAGE_SIZE - EEPROM_EMULATOR_HEADER_SIZE)

/**
 * \internal
 * \brief Structure describing emulated pages of EEPROM data.
 */
typedef struct
{
    /** Header information of the EEPROM page. */
    struct
    {
        uint16_t logical_page;

        /* The final version string is of 4 bytes.
         * 2 bytes are stored in page 0 header and remaining 2 bytes in page 1 header of each row. */
        uint16_t version_str;
    } header;

    /** Data content of the EEPROM page. */
    uint8_t data[EEPROM_EMULATOR_PAGE_DATA_SIZE];
}EEPROM_PAGE;

/**
 * \internal
 * \brief Internal device instance struct.
 */
typedef struct
{
    /** Initialization state of the EEPROM emulator. */
    bool initialized;
<#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED?? && EEPROM_EMULATOR_RWWEE_ENABLED??>
    <#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED == true>

    <#lt>    /** Absolute byte pointer to the first byte of FLASH where the emulated EEPROM is stored. */
    <#lt>    EEPROM_PAGE* main_array;
    </#if>
    <#if EEPROM_EMULATOR_RWWEE_ENABLED == true>

    <#lt>    /** Absolute byte pointer to the first byte of RWWEE memory where the emulated EEPROM is stored. */
    <#lt>    EEPROM_PAGE* rwwee;
    </#if>
<#else>

    /** Absolute byte pointer to the first byte of FLASH where the emulated EEPROM is stored. */
    EEPROM_PAGE* main_array;
</#if>
<#if (EEPROM_EMULATOR_NUM_PHYSICAL_PAGES <= 256) >

    /** Mapping array from logical EEPROM pages to physical FLASH pages. */
    uint8_t page_map[EEPROM_EMULATOR_NUM_LOGICAL_PAGES];
<#else>

    /** Mapping array from logical EEPROM pages to physical FLASH pages. */
    uint16_t page_map[EEPROM_EMULATOR_NUM_LOGICAL_PAGES];
</#if>

    /** Row number for the spare row (used by next write). */
    uint16_t spare_row;

    /** Buffer to hold the currently cached page. */
    EEPROM_PAGE cache;

    /** Indicates if the cache contains valid data. */
    bool cache_active;

    /** Indicates library status */
    EMU_EEPROM_STATUS status;

    /* Mutex to synchronize multiple simultaneous access */
    OSAL_MUTEX_DECLARE (EmulatedEEPROMAccessLock);

}EEPROM_MODULE;


/** @} */

#ifdef __cplusplus
}
#endif

#endif /* EEPROM_EMULATOR_LOCAL_H */
