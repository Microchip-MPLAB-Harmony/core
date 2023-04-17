/******************************************************************************
  SST26 Driver SPI Interface Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sst26_spi_interface.c

  Summary:
    SST26 Driver Interface implementation

  Description:
    This interface file segregates the SST26 protocol from the underlying
    hardware layer implementation for SPI PLIB and SPI driver
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

// *****************************************************************************
// *****************************************************************************
// Section: Include Files
// *****************************************************************************
// *****************************************************************************

#include <string.h>
#include "drv_sst26_spi_interface.h"

<#if DRV_SST26_INTERFACE_TYPE != "SPI_DRV">
<#if DRV_SST26_TX_RX_DMA == true>

<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == true>

static uint8_t __ALIGNED(4) dummyDataBuffer[CACHE_ALIGNED_SIZE_GET(256)];

static void lDRV_SST26_StartDMATransfer(DRV_SST26_OBJECT* dObj, DRV_SST26_TRANSFER_OBJ* transferObj)
{
    uint32_t size = 0;
    /* To avoid unused build error */
    (void) size;

    /* Initialize the dummy data buffer with 0xFF */
    memset(dummyDataBuffer, 0xFF, sizeof(dummyDataBuffer));

    dObj->nBytesTransferred = 0;

    dObj->txPending = transferObj->txSize;
    dObj->rxPending = transferObj->rxSize;

    SYS_DMA_AddressingModeSetup(dObj->rxDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_INCREMENTED);
    SYS_DMA_AddressingModeSetup(dObj->txDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_INCREMENTED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);

    if ((dObj->txPending > 0) && (dObj->rxPending > 0))
    {
        /* Find the lower value among rxPending and txPending*/

        (dObj->txPending >= dObj->rxPending) ?
            (size = dObj->rxPending) : (size = dObj->txPending);

        /* Calculate the remaining tx/rx bytes and total bytes transferred */
        dObj->rxPending -= size;
        dObj->txPending -= size;
        dObj->nBytesTransferred += size;

        /* Always set up the rx channel first */
        SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)transferObj->pReceiveData, size);
        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)transferObj->pTransmitData, (const void*)dObj->txAddress, size);
    }
    else
    {
        if (dObj->rxPending > 0)
        {
            /* txPending is 0. Need to use the dummy data buffer for transmission.
             * Find out the max data that can be received, given the limited size of the dummy data buffer.
             */
            (dObj->rxPending > sizeof(dummyDataBuffer)) ?
                (size = sizeof(dummyDataBuffer)): (size = dObj->rxPending);

            /* Calculate the remaining rx bytes and total bytes transferred */
            dObj->rxPending -= size;
            dObj->nBytesTransferred += size;

            /* Always set up the rx channel first */
            SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)transferObj->pReceiveData, size);
            SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)dummyDataBuffer, (const void*)dObj->txAddress, size);

        }
        else
        {
            /* rxPending is 0. Need to use the dummy data buffer for reception.
             * Find out the max data that can be transmitted, given the limited size of the dummy data buffer.
             */
            (dObj->txPending > sizeof(dummyDataBuffer)) ?
                (size = sizeof(dummyDataBuffer)): (size = dObj->txPending);

            /* Calculate the remaining tx bytes and total bytes transferred */
            dObj->txPending -= size;
            dObj->nBytesTransferred += size;

            /* Always set up the rx channel first */
            SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)dummyDataBuffer, size);
            SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)transferObj->pTransmitData, (const void*)dObj->txAddress, size);
        }
    }
}
void DRV_SST26_TX_DMA_CallbackHandler(
    SYS_DMA_TRANSFER_EVENT event,
    uintptr_t context
)
{
    /* Do nothing */
}

void DRV_SST26_RX_DMA_CallbackHandler(
    SYS_DMA_TRANSFER_EVENT event,
    uintptr_t context
)
{
    uint32_t size;
    uint32_t index;
    DRV_SST26_OBJECT* dObj = (DRV_SST26_OBJECT*)context;

    if (dObj->rxPending > 0)
    {
        /* txPending is 0. Need to use the dummy data buffer for transmission.
         * Find out the max data that can be received, given the limited size of the dummy data buffer.
         */
        (dObj->rxPending > sizeof(dummyDataBuffer)) ?
            (size = sizeof(dummyDataBuffer)): (size = dObj->rxPending);

        index = dObj->nBytesTransferred;

        /* Calculate the remaining rx bytes and total bytes transferred */
        dObj->rxPending -= size;
        dObj->nBytesTransferred += size;

        /* Always set up the rx channel first */
        SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)&((uint8_t*)dObj->transferDataObj.pReceiveData)[index], size);
        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)dummyDataBuffer, (const void*)dObj->txAddress, size);

    }
    else if (dObj->txPending > 0)
    {
        /* rxPending is 0. Need to use the dummy data buffer for reception.
         * Find out the max data that can be transmitted, given the limited size of the dummy data buffer.
         */
        (dObj->txPending > sizeof(dummyDataBuffer)) ?
            (size = sizeof(dummyDataBuffer)): (size = dObj->txPending);

        index = dObj->nBytesTransferred;

        /* Calculate the remaining tx bytes and total bytes transferred */
        dObj->txPending -= size;
        dObj->nBytesTransferred += size;

        /* Always set up the rx channel first */
        SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)dummyDataBuffer, size);
        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)&((uint8_t*)dObj->transferDataObj.pTransmitData)[index], (const void*)dObj->txAddress, size);
    }
    else
    {
        /* Make sure the shift register is empty before de-asserting the CS line */
        while (dObj->sst26Plib->isBusy());

        dObj->transferDataObj.txSize = dObj->transferDataObj.rxSize = 0;
        dObj->transferDataObj.pTransmitData = dObj->transferDataObj.pReceiveData = NULL;

        DRV_SST26_Handler();
    }
}

<#else>

static CACHE_ALIGN uint8_t txDummyData[CACHE_ALIGNED_SIZE_GET(4)];

static void lDRV_SST26_StartDMATransfer(DRV_SST26_OBJECT* dObj, DRV_SST26_TRANSFER_OBJ* transferObj)
{
    uint32_t size = 0;
    /* To avoid unused build error */
    (void) size;

    dObj->txDummyDataSize = 0;
    dObj->rxDummyDataSize = 0;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
     /* Clean cache to push the data in transmit buffer to the main memory */
    SYS_CACHE_CleanDCache_by_Addr((uint32_t *)transferObj->pTransmitData, transferObj->txSize);

    /* Invalidate the receive buffer to force the CPU to load from main memory */
    SYS_CACHE_InvalidateDCache_by_Addr((uint32_t *)transferObj->pReceiveData, transferObj->rxSize);
</#if>

    if (transferObj->rxSize >= transferObj->txSize)
    {
        /* Dummy data will be sent by the TX DMA */
        dObj->txDummyDataSize = (transferObj->rxSize - transferObj->txSize);
    }
    else
    {
        /* Dummy data will be received by the RX DMA */
        dObj->rxDummyDataSize = (transferObj->txSize - transferObj->rxSize);
    }

    if (transferObj->rxSize == 0)
    {
        /* Configure the RX DMA channel - to receive dummy data */
        SYS_DMA_AddressingModeSetup(dObj->rxDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);
        size = dObj->rxDummyDataSize;
        dObj->rxDummyDataSize = 0;
        SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)&dObj->rxDummyData, size);
    }
    else
    {
        /* Configure the RX DMA channel - to receive data in receive buffer */
        SYS_DMA_AddressingModeSetup(dObj->rxDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_INCREMENTED);
        SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)transferObj->pReceiveData, transferObj->rxSize);
    }

    if (transferObj->txSize == 0)
    {
        /* Configure the TX DMA channel - to send dummy data */
        SYS_DMA_AddressingModeSetup(dObj->txDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);
        size = dObj->txDummyDataSize;
        dObj->txDummyDataSize = 0;
        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)txDummyData, (const void*)dObj->txAddress, size);
    }
    else
    {
        /* Configure the transmit DMA channel - to send data from transmit buffer */
        SYS_DMA_AddressingModeSetup(dObj->txDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_INCREMENTED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);

        /* The DMA transfer is split into two for the case where rxSize > 0 && rxSize < txSize */
        if (dObj->rxDummyDataSize > 0)
        {
            size = transferObj->rxSize;
        }
        else
        {
            size = transferObj->txSize;
        }
        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)transferObj->pTransmitData, (const void*)dObj->txAddress, size);
    }
}

void DRV_SST26_TX_DMA_CallbackHandler(
    SYS_DMA_TRANSFER_EVENT event,
    uintptr_t context
)
{
    DRV_SST26_OBJECT* dObj = (DRV_SST26_OBJECT*)context;

    if (dObj->txDummyDataSize > 0)
    {
        /* Configure DMA channel to transmit (dummy data) from the same location
         * (Source address not incremented) */
        SYS_DMA_AddressingModeSetup(dObj->txDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);

        /* Configure the transmit DMA channel */
        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void*)txDummyData, (const void*)dObj->txAddress, dObj->txDummyDataSize);

        dObj->txDummyDataSize = 0;
    }
}

void DRV_SST26_RX_DMA_CallbackHandler(
    SYS_DMA_TRANSFER_EVENT event,
    uintptr_t context
)
{
    DRV_SST26_OBJECT* dObj = (DRV_SST26_OBJECT*)context;

    if (dObj->rxDummyDataSize > 0)
    {
        /* Configure DMA to receive dummy data */
        SYS_DMA_AddressingModeSetup(dObj->rxDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);

        SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)&dObj->rxDummyData, dObj->rxDummyDataSize);

        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)&((uint8_t*)dObj->transferDataObj.pTransmitData)[dObj->transferDataObj.rxSize], (const void*)dObj->txAddress, dObj->rxDummyDataSize);

        dObj->rxDummyDataSize = 0;
    }
    else
    {
        /* Make sure the shift register is empty before de-asserting the CS line */
        while (dObj->sst26Plib->isBusy());

        dObj->transferDataObj.txSize = dObj->transferDataObj.rxSize = 0;
        dObj->transferDataObj.pTransmitData = dObj->transferDataObj.pReceiveData = NULL;

        DRV_SST26_Handler();
    }
}
</#if>

<#else>

void DRV_SST26_SPIPlibCallbackHandler(uintptr_t context )
{
    DRV_SST26_OBJECT* dObj = (DRV_SST26_OBJECT*)context;

    dObj->transferDataObj.txSize = dObj->transferDataObj.rxSize = 0;
    dObj->transferDataObj.pTransmitData = dObj->transferDataObj.pReceiveData = NULL;

    DRV_SST26_Handler();
}
</#if>

<#else>
void DRV_SST26_SPIDriverEventHandler(
    DRV_SPI_TRANSFER_EVENT event,
    DRV_SPI_TRANSFER_HANDLE transferHandle,
    uintptr_t context
)
{
    DRV_SST26_OBJECT* dObjt = (DRV_SST26_OBJECT*)context;

    dObjt->transferDataObj.txSize = dObjt->transferDataObj.rxSize = 0;
    dObjt->transferDataObj.pTransmitData = dObjt->transferDataObj.pReceiveData = NULL;

    DRV_SST26_Handler();
}
</#if>

void DRV_SST26_InterfaceInit(DRV_SST26_OBJECT* dObj, DRV_SST26_INIT* sst26Init)
{
<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == false && DRV_SST26_TX_RX_DMA == true>
    size_t  txDummyDataIdx;
</#if>

<#if DRV_SST26_INTERFACE_TYPE == "SPI_DRV">
    dObj->spiDrvIndex = sst26Init->spiDrvIndex;
<#else>
    /* Initialize the attached memory device functions */
    dObj->sst26Plib = sst26Init->sst26Plib;
<#if DRV_SST26_TX_RX_DMA == true>
    dObj->txDMAChannel = sst26Init->txDMAChannel;
    dObj->rxDMAChannel = sst26Init->rxDMAChannel;
    dObj->txAddress = sst26Init->txAddress;
    dObj->rxAddress = sst26Init->rxAddress;

<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == false >
    for (txDummyDataIdx = 0; txDummyDataIdx < sizeof(txDummyData); txDummyDataIdx++)
    {
        txDummyData[txDummyDataIdx] = 0xFF;
    }
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    /* Clean cache lines to push the dummy data to the main memory */
    SYS_CACHE_CleanDCache_by_Addr((uint32_t *)txDummyData, sizeof(txDummyData));
</#if>
</#if>
    SYS_DMA_DataWidthSetup(dObj->rxDMAChannel, SYS_DMA_WIDTH_8_BIT);
    SYS_DMA_DataWidthSetup(dObj->txDMAChannel, SYS_DMA_WIDTH_8_BIT);

    /* Register callbacks for DMA */
    SYS_DMA_ChannelCallbackRegister(dObj->txDMAChannel, DRV_SST26_TX_DMA_CallbackHandler, (uintptr_t)dObj);
    SYS_DMA_ChannelCallbackRegister(dObj->rxDMAChannel, DRV_SST26_RX_DMA_CallbackHandler, (uintptr_t)dObj);
<#else>
    dObj->sst26Plib->callbackRegister(DRV_SST26_SPIPlibCallbackHandler, (uintptr_t)dObj);
</#if>
</#if>
}

bool DRV_SST26_SPIWriteRead(
    DRV_SST26_OBJECT* dObj,
    DRV_SST26_TRANSFER_OBJ* transferObj
)
{
    bool isSuccess = true;
<#if DRV_SST26_INTERFACE_TYPE == "SPI_DRV">
    DRV_SPI_TRANSFER_HANDLE transferHandle;
</#if>

    SYS_PORT_PinClear(dObj->chipSelectPin);

    dObj->transferStatus    = DRV_SST26_TRANSFER_BUSY;
<#if DRV_SST26_INTERFACE_TYPE == "SPI_DRV">
    DRV_SPI_WriteReadTransferAdd (dObj->spiDrvHandle, transferObj->pTransmitData, transferObj->txSize, transferObj->pReceiveData, transferObj->rxSize, &transferHandle);
    if (transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
    {
        isSuccess = false;
    }
<#else>
<#if DRV_SST26_TX_RX_DMA == true>
    lDRV_SST26_StartDMATransfer(dObj, transferObj);
<#else>
    (void) dObj->sst26Plib->writeRead (transferObj->pTransmitData, transferObj->txSize, transferObj->pReceiveData, transferObj->rxSize);
</#if>
</#if>
    return isSuccess;
}
