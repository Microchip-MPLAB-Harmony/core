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
<#if (core.DMA_ENABLE?has_content) && (core.DMA_ENABLE = true)>
<#if core.DMA_IP?? && core.DMA_IP == "dma_03639">
	uint32_t config;
	uint32_t ras_value;
	uint32_t was_value;
	
	config = (uint32_t)${core.DMA_INSTANCE_NAME}_ChannelSettingsGet((${core.DMA_NAME}_CHANNEL)channel);
	
	ras_value = (config & 0x70) >> 4;
	was_value = config & 0x07;
	
	if (sourceAddrMode == SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED)
	{
		if (ras_value < 3)
		{
			ras_value += 3;			
		}		
	}
	else
	{
		if (ras_value >= 3)
		{
			ras_value -= 3;			
		}	
	}	 
		
	if (destAddrMode == SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED)
	{
		if (was_value < 3)
		{
			was_value += 3;			
		}		
	}
	else
	{
		if (was_value >= 3)
		{
			was_value -= 3;			
		}	
	}	 
	config = (config & ~0x77) | ( (ras_value << 4) | was_value );
	(void) ${core.DMA_INSTANCE_NAME}_ChannelSettingsSet((${core.DMA_NAME}_CHANNEL)channel, (${core.DMA_NAME}_CHANNEL_CONFIG)config);
	
<#else>
	uint32_t config;

    config = (uint32_t)${core.DMA_INSTANCE_NAME}_ChannelSettingsGet((${core.DMA_NAME}_CHANNEL)channel);
    config &= ~(${core.DMA_SRC_AM_MASK}U | ${core.DMA_DST_AM_MASK}U);

    config |= (uint32_t)sourceAddrMode | (uint32_t)destAddrMode;

    (void) ${core.DMA_INSTANCE_NAME}_ChannelSettingsSet((${core.DMA_NAME}_CHANNEL)channel, (${core.DMA_NAME}_CHANNEL_CONFIG)config);
</#if>	
</#if>	
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
<#if (core.DMA_ENABLE?has_content) && (core.DMA_ENABLE = true)>
<#if core.DMA_IP?? && core.DMA_IP == "dma_03639">

	uint32_t config;
	uint32_t ras_value;
	uint32_t was_value;
	
	config = (uint32_t)${core.DMA_INSTANCE_NAME}_ChannelSettingsGet((${core.DMA_NAME}_CHANNEL)channel);
	
	ras_value = (config & 0x70) >> 4;
	was_value = config & 0x07;

	if (ras_value < 3)
	{		
		ras_value = dataWidth;		
	}	
	else
	{	
		ras_value = 0x03 + dataWidth;
	}
	
	if (was_value < 3)
	{		
		was_value = dataWidth;		
	}	
	else
	{	
		was_value = 0x03 + dataWidth;
	}
	
	
	config = (config & ~0x77) | ( (ras_value << 4) | was_value );
	(void) ${core.DMA_INSTANCE_NAME}_ChannelSettingsSet((${core.DMA_NAME}_CHANNEL)channel, (${core.DMA_NAME}_CHANNEL_CONFIG)config);
	    
<#else>
	uint32_t config;

    config = (uint32_t)${core.DMA_INSTANCE_NAME}_ChannelSettingsGet((${core.DMA_NAME}_CHANNEL)channel);

    config &= ~(${core.DMA_DATA_WIDTH_MASK}U);
    config |= (uint32_t)dataWidth;

    (void) ${core.DMA_INSTANCE_NAME}_ChannelSettingsSet((${core.DMA_NAME}_CHANNEL)channel, (${core.DMA_NAME}_CHANNEL_CONFIG)config);
</#if>	
</#if>	
}
