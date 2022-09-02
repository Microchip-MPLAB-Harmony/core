/*******************************************************************************
  SST26 Driver SPI Interface Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sst26_spi_interface.h

  Summary:
    SST26 Driver PLIB Interface implementation

  Description:
    This interface file segregates the SST26 protocol from the underlying
    hardware layer implementation.
*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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

#ifndef DRV_SST26_SPI_INTERFACE_H
#define DRV_SST26_SPI_INTERFACE_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "drv_sst26_local.h"

<#if DRV_SST26_INTERFACE_TYPE == "SPI_DRV">
#include "driver/spi/drv_spi.h"
<#else>
<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == false && DRV_SST26_TX_RX_DMA == true && core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
#include "system/cache/sys_cache.h"
</#if>
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: Data Type Definitions
// *****************************************************************************
// *****************************************************************************
<#if DRV_SST26_INTERFACE_TYPE == "SPI_DRV">
void DRV_SST26_SPIDriverEventHandler(
    DRV_SPI_TRANSFER_EVENT event,
    DRV_SPI_TRANSFER_HANDLE transferHandle,
    uintptr_t context
);
<#else>
<#if DRV_SST26_TX_RX_DMA == true>
void DRV_SST26_TX_DMA_CallbackHandler(
    SYS_DMA_TRANSFER_EVENT event,
    uintptr_t context
);
void DRV_SST26_RX_DMA_CallbackHandler(
    SYS_DMA_TRANSFER_EVENT event,
    uintptr_t context
);
<#else>
void DRV_SST26_SPIPlibCallbackHandler(uintptr_t context );
</#if>
</#if>

void DRV_SST26_InterfaceInit(DRV_SST26_OBJECT* dObj, DRV_SST26_INIT* sst26Init);

bool DRV_SST26_SPIWriteRead(
    DRV_SST26_OBJECT* dObj,
    DRV_SST26_TRANSFER_OBJ* transferObj
);

#endif //#ifndef DRV_SST26_SPI_INTERFACE_H