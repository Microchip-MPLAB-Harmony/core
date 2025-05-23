/*******************************************************************************
  DMA System Service Library Interface Header File

  Company
    Microchip Technology Inc.

  File Name
    sys_dma.h

  Summary
    DMA system service library interface.

  Description
    This file defines the interface to the DMA system service library.
    This library provides access to and control of the DMA controller.

  Remarks:
    DMA controller initialize will be done from within the MCC.

*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2025 Microchip Technology Inc. and its subsidiaries.
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

#ifndef SYS_DMA_H    // Guards against multiple inclusion
#define SYS_DMA_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

/*  This section lists the other files that are included in this file.
*/
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Data Types
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* DMA Channels

  Summary:
    This lists the set of channels available for data transfer using DMA.

  Description:
    This lists the set of channels available for data transfer using DMA.

  Remarks:
    None.
*/

typedef enum
{
<#if core.DMA_CHANNEL_COUNT?has_content>
<#list 0..(core.DMA_CHANNEL_COUNT - 1) as i>
    SYS_DMA_CHANNEL_${i},

</#list>
</#if>

    SYS_DMA_CHANNEL_NONE = 0xFFFFFFFFU

} SYS_DMA_CHANNEL;

// *****************************************************************************
/* DMA Transfer Events

   Summary:
    Enumeration of possible DMA transfer events.

   Description:
    This data type provides an enumeration of all possible DMA transfer
    events.

   Remarks:
    None.

*/
typedef enum
{
    /* Data was transferred successfully. */
    SYS_DMA_TRANSFER_COMPLETE = 1,

    /* Error while processing the request */
    SYS_DMA_TRANSFER_ERROR

} SYS_DMA_TRANSFER_EVENT;

// *****************************************************************************
/* DMA Source addressing modes

   Summary:
    Enumeration of possible DMA source addressing modes.

   Description:
    This data type provides an enumeration of all possible DMA source
    addressing modes.

   Remarks:
    None.
*/
/* MISRA C-2012 Rule 5.2 deviated:8 Deviation record ID -  H3_MISRAC_2012_R_5_2_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:8 "MISRA C-2012 Rule 5.2" "H3_MISRAC_2012_R_5_2_DR_1"
</#if>

typedef enum
{
<#if core.DMA_SRC_FIXED_AM_VALUE?has_content>
    /* Source address is always fixed */
    SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED = ${core.DMA_SRC_FIXED_AM_VALUE},

</#if>
<#if core.DMA_SRC_INCREMENTED_AM_VALUE?has_content>
    /* Source address is incremented after every transfer */
    SYS_DMA_SOURCE_ADDRESSING_MODE_INCREMENTED = ${core.DMA_SRC_INCREMENTED_AM_VALUE},

</#if>
<#if core.DMA_SRC_DECREMENTED_AM_VALUE?has_content>
    /* Source address is decremented after every transfer */
    SYS_DMA_SOURCE_ADDRESSING_MODE_DECREMENTED = ${core.DMA_SRC_DECREMENTED_AM_VALUE},

</#if>
    SYS_DMA_SOURCE_ADDRESSING_MODE_NONE = -1

} SYS_DMA_SOURCE_ADDRESSING_MODE;

// *****************************************************************************
/* DMA destination addressing modes

   Summary:
    Enumeration of possible DMA destination addressing modes.

   Description:
    This data type provides an enumeration of all possible DMA destination
    addressing modes.

   Remarks:
    None.
*/
typedef enum
{
<#if core.DMA_DST_FIXED_AM_VALUE?has_content>
    /* Destination address is always fixed */
    SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED = ${core.DMA_DST_FIXED_AM_VALUE},

</#if>
<#if core.DMA_DST_INCREMENTED_AM_VALUE?has_content>
    /* Destination address is incremented after every transfer */
    SYS_DMA_DESTINATION_ADDRESSING_MODE_INCREMENTED = ${core.DMA_DST_INCREMENTED_AM_VALUE},

</#if>
<#if core.DMA_DST_DECREMENTED_AM_VALUE?has_content>
    /* Destination address is decremented after every transfer */
    SYS_DMA_DESTINATION_ADDRESSING_MODE_DECREMENTED = ${core.DMA_DST_DECREMENTED_AM_VALUE},

</#if>
    SYS_DMA_DESTINATION_ADDRESSING_MODE_NONE = -1

} SYS_DMA_DESTINATION_ADDRESSING_MODE;
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 5.2"
</#if>
/* MISRAC 2012 deviation block end */

// *****************************************************************************
/* DMA data width

   Summary:
    Enumeration of possible DMA data width

   Description:
    This data type provides an enumeration of all possible DMA data width.

   Remarks:
    None.
*/

typedef enum
{
<#if core.DMA_DATA_WIDTH_BYTE_VALUE?has_content>
    /* DMA data width 8 bit */
    SYS_DMA_WIDTH_8_BIT = ${core.DMA_DATA_WIDTH_BYTE_VALUE},

</#if>
<#if core.DMA_DATA_WIDTH_HALFWORD_VALUE?has_content>
    /* DMA data width 16 bit */
    SYS_DMA_WIDTH_16_BIT = ${core.DMA_DATA_WIDTH_HALFWORD_VALUE},

</#if>
<#if core.DMA_DATA_WIDTH_WORD_VALUE?has_content>
    /* DMA data width 32 bit */
    SYS_DMA_WIDTH_32_BIT =  ${core.DMA_DATA_WIDTH_WORD_VALUE},

</#if>
    SYS_DMA_WIDTH_NONE = -1

} SYS_DMA_WIDTH;

// *****************************************************************************
/* DMA Transfer Event Handler Function

   Summary:
    Pointer to a DMA Transfer Event handler function.

   Description:
    This data type defines a DMA Transfer Event Handler Function.

    A DMA client must register a transfer event handler function of this
    type to receive transfer related events from the DMA System Service.

    If the event is SYS_DMA_TRANSFER_COMPLETE, this means that the data
    was transferred successfully.

    If the event is SYS_DMA_TRANSFER_ERROR, this means that the data was
    not transferred successfully.

    The contextHandle parameter contains the context handle that was provided by
    the client at the time of registering the event handler. This context handle
    can be anything that the client consider helpful or necessary to identify
    the client context object associated with the channel of the DMA that
    generated the event.

    The event handler function executes in an interrupt context of DMA.
    It is recommended to the application not to perform process intensive
    operations with in this function.

   Remarks:
    None.

*/
typedef void (*SYS_DMA_CHANNEL_CALLBACK) (SYS_DMA_TRANSFER_EVENT event, uintptr_t contextHandle);

// *****************************************************************************
// *****************************************************************************
// Section: Interface Routines
// *****************************************************************************
// *****************************************************************************

/* The following functions make up the methods (set of possible operations) of
   this interface.
*/

/* Refer to sys_dma_mapping.h header file for all sys_dma functions mapped to plib interfaces */
#include "sys_dma_mapping.h"


//******************************************************************************
/* Function:
    void SYS_DMA_AddressingModeSetup(SYS_DMA_CHANNEL channel, SYS_DMA_SOURCE_ADDRESSING_MODE sourceAddrMode, SYS_DMA_DESTINATION_ADDRESSING_MODE destAddrMode);

  Summary:
    Setup addressing mode of selected DMA channel.

  Description:
    This function sets the addressing mode of selected DMA channel.

    Any ongoing transaction of the specified XDMAC channel will be aborted when
    this function is called.

  Precondition:
    DMA Controller should have been initialized.

  Parameters:
    channel - A specific DMA channel
    sourceAddrMode -  Source addressing mode of type SYS_DMA_SOURCE_ADDRESSING_MODE
    destAddrMode - Destination addressing mode of type SYS_DMA_DESTINATION_ADDRESSING_MODE

  Returns:
    None.

  Example:
    <code>
        SYS_DMA_AddressingModeSetup(SYS_DMA_CHANNEL_1, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);
    </code>

  Remarks:
    None.
*/
void SYS_DMA_AddressingModeSetup(SYS_DMA_CHANNEL channel, SYS_DMA_SOURCE_ADDRESSING_MODE sourceAddrMode, SYS_DMA_DESTINATION_ADDRESSING_MODE destAddrMode);

//******************************************************************************
/* Function:
    void SYS_DMA_DataWidthSetup(SYS_DMA_CHANNEL channel, SYS_DMA_WIDTH dataWidth);

  Summary:
    Setup data width of selected DMA channel.

  Description:
    This function sets data width of selected DMA channel.

    Any ongoing transaction of the specified XDMAC channel will be aborted when
    this function is called.

  Precondition:
    DMA Controller should have been initialized.

  Parameters:
    channel - A specific DMA channel
    dataWidth -  Data width of DMA transfer of type SYS_DMA_WIDTH

  Returns:
    None.

  Example:
    <code>
        SYS_DMA_DataWidthSetup(SYS_DMA_CHANNEL_1, SYS_DMA_WIDTH_16_BIT);
    </code>

  Remarks:
    None.
*/
void SYS_DMA_DataWidthSetup(SYS_DMA_CHANNEL channel, SYS_DMA_WIDTH dataWidth);

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    }

#endif
// DOM-IGNORE-END

#endif //SYS_DMA_H
