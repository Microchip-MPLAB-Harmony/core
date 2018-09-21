/*******************************************************************************
  DMA System Service Library Implementation Source File

  Company
    Microchip Technology Inc.

  File Name
    sys_dma.c

  Summary
    DMA system service library interface implementation.

  Description
    This file implements the interface to the DMA system service library.

  Remarks:
    DMA controller initialize will be done from within the MCC.

*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
Copyright (c) 2017 released Microchip Technology Inc.  All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR
CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF
SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
*******************************************************************************/
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
#include "system/dma/sys_dma.h"

//******************************************************************************
/* Function:
    void SYS_DMA_AddressingModeSetup(SYS_DMA_CHANNEL channel, SYS_DMA_SOURCE_ADDRESSING_MODE sourceAddrMode, SYS_DMA_DESTINATION_ADDRESSING_MODE destAddrMode);

  Summary:
    Setup addressing mode of selected DMA channel.

  Remarks:
    Check sys_dma.h for more info.
*/
void SYS_DMA_AddressingModeSetup(SYS_DMA_CHANNEL channel, SYS_DMA_SOURCE_ADDRESSING_MODE sourceAddrMode, SYS_DMA_DESTINATION_ADDRESSING_MODE destAddrMode)
{
    uint32_t config;

    config = ${core.DMA_INSTANCE_NAME}_ChannelSettingsGet(channel);
    config &= ~(${core.DMA_SRC_AM_MASK} | ${core.DMA_DST_AM_MASK});

    config |= sourceAddrMode | destAddrMode;

    ${core.DMA_INSTANCE_NAME}_ChannelSettingsSet(channel, config);
}

//******************************************************************************
/* Function:
    void SYS_DMA_DataWidthSetup(SYS_DMA_CHANNEL channel, SYS_DMA_WIDTH dataWidth);

  Summary:
    Setup data width of selected DMA channel.

  Remarks:
    Check sys_dma.h for more info.
*/
void SYS_DMA_DataWidthSetup(SYS_DMA_CHANNEL channel, SYS_DMA_WIDTH dataWidth)
{
    uint32_t config;

    config = ${core.DMA_INSTANCE_NAME}_ChannelSettingsGet(channel);

    config &= ~(${core.DMA_DATA_WIDTH_MASK});
    config |= dataWidth;

    ${core.DMA_INSTANCE_NAME}_ChannelSettingsSet(channel, config);
}
