/*******************************************************************************
  SPI Driver Implementation.

  Company:
    Microchip Technology Inc.

  File Name:
    drv_spi.c

  Summary:
    Source code for the SPI driver dynamic implementation.

  Description:
    This file contains the source code for the dynamic implementation of the
    SPI driver.
*******************************************************************************/

//DOM-IGNORE-BEGIN
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
//DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <string.h>
#include "configuration.h"
#include "driver/spi/drv_spi.h"
<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == false>
<#if core.DMA_ENABLE?has_content && DRV_SPI_SYS_DMA_ENABLE == true>
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
#include "system/cache/sys_cache.h"
</#if>
</#if>
</#if>
#include "system/debug/sys_debug.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data
// *****************************************************************************
// *****************************************************************************

/* This is the driver instance object array. */
<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == true>
static CACHE_ALIGN DRV_SPI_OBJ gDrvSPIObj[DRV_SPI_INSTANCES_NUMBER];
<#else>
static DRV_SPI_OBJ gDrvSPIObj[DRV_SPI_INSTANCES_NUMBER];
<#if core.DMA_ENABLE?has_content && DRV_SPI_SYS_DMA_ENABLE == true>
/* Dummy data being transmitted by TX DMA */
static CACHE_ALIGN uint8_t txDummyData[CACHE_ALIGNED_SIZE_GET(4)];
</#if>
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: File scope functions
// *****************************************************************************
// *****************************************************************************

static inline uint32_t  lDRV_SPI_MAKE_HANDLE(uint16_t token, uint8_t drvIndex, uint8_t clientIndex)
{
    return (((uint32_t)token << 16) | ((uint32_t)drvIndex << 8) | clientIndex);
}

static inline uint16_t lDRV_SPI_UPDATE_TOKEN(uint16_t token)
{
    token++;

    if (token >= DRV_SPI_TOKEN_MAX)
    {
        token = 1;
    }

    return token;
}

static DRV_SPI_CLIENT_OBJ* lDRV_SPI_DriverHandleValidate(DRV_HANDLE handle)
{
    /* This function returns the pointer to the client object that is
       associated with this handle if the handle is valid. Returns NULL
       otherwise. */

    uint32_t drvInstance = 0;
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ*)NULL;

    if((handle != DRV_HANDLE_INVALID) && (handle != 0U))
    {
        /* Extract the drvInstance value from the handle */
        drvInstance = ((handle & DRV_SPI_INSTANCE_INDEX_MASK) >> 8);

        if (drvInstance >= DRV_SPI_INSTANCES_NUMBER)
        {
            return (NULL);
        }

        if ((handle & DRV_SPI_CLIENT_INDEX_MASK) >= gDrvSPIObj[drvInstance].nClientsMax)
        {
            return (NULL);
        }

        /* Extract the client index and obtain the client object */
        clientObj = &((DRV_SPI_CLIENT_OBJ *)gDrvSPIObj[drvInstance].clientObjPool)[handle & DRV_SPI_CLIENT_INDEX_MASK];

        if ((clientObj->clientHandle != handle) || (clientObj->inUse == false))
        {
            return (NULL);
        }
    }

    return(clientObj);
}

<#if core.DMA_ENABLE?has_content && DRV_SPI_SYS_DMA_ENABLE == true>
<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == true>
static bool lDRV_SPI_StartDMATransfer(
    DRV_SPI_OBJ* dObj,
    void* pTransmitData,
    size_t txSize,
    void* pReceiveData,
    size_t rxSize
)
{
    uint32_t size = 0;
    /* To avoid unused build error */
    (void) size;

    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)dObj->activeClient;

    dObj->nBytesTransferred = 0;
    dObj->txPending = txSize;
    dObj->rxPending = rxSize;

    /* Initialize the dummy data buffer with 0xFF */
    memset(dObj->dummyDataBuffer, 0xFF, sizeof(dObj->dummyDataBuffer));

    SYS_DMA_AddressingModeSetup(dObj->rxDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_INCREMENTED);
    SYS_DMA_AddressingModeSetup(dObj->txDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_INCREMENTED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);

    if(clientObj->setup.dataBits == DRV_SPI_DATA_BITS_8)
    {
        SYS_DMA_DataWidthSetup(dObj->rxDMAChannel, SYS_DMA_WIDTH_8_BIT);
        SYS_DMA_DataWidthSetup(dObj->txDMAChannel, SYS_DMA_WIDTH_8_BIT);
    }
    else if (clientObj->setup.dataBits <= DRV_SPI_DATA_BITS_16)
    {
        SYS_DMA_DataWidthSetup(dObj->rxDMAChannel, SYS_DMA_WIDTH_16_BIT);
        SYS_DMA_DataWidthSetup(dObj->txDMAChannel, SYS_DMA_WIDTH_16_BIT);
    }
    else
    {
        SYS_DMA_DataWidthSetup(dObj->rxDMAChannel, SYS_DMA_WIDTH_32_BIT);
        SYS_DMA_DataWidthSetup(dObj->txDMAChannel, SYS_DMA_WIDTH_32_BIT);
    }

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
        (void) SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)pReceiveData, size);
        (void) SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)pTransmitData, (const void*)dObj->txAddress, size);
    }
    else
    {
        if (dObj->rxPending > 0)
        {
            /* txPending is 0. Need to use the dummy data buffer for transmission.
             * Find out the max data that can be received, given the limited size of the dummy data buffer.
             */
            (dObj->rxPending > sizeof(dObj->dummyDataBuffer)) ?
                (size = sizeof(dObj->dummyDataBuffer)): (size = dObj->rxPending);

            /* Calculate the remaining rx bytes and total bytes transferred */
            dObj->rxPending -= size;
            dObj->nBytesTransferred += size;

            /* Always set up the rx channel first */
            (void) SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)pReceiveData, size);
            (void) SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)dObj->dummyDataBuffer, (const void*)dObj->txAddress, size);

        }
        else
        {
            /* rxPending is 0. Need to use the dummy data buffer for reception.
             * Find out the max data that can be transmitted, given the limited size of the dummy data buffer.
             */
            (dObj->txPending > sizeof(dObj->dummyDataBuffer)) ?
                (size = sizeof(dObj->dummyDataBuffer)): (size = dObj->txPending);

            /* Calculate the remaining tx bytes and total bytes transferred */
            dObj->txPending -= size;
            dObj->nBytesTransferred += size;

            /* Always set up the rx channel first */
            (void) SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)dObj->dummyDataBuffer, size);
            (void) SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)pTransmitData, (const void*)dObj->txAddress, size);
        }
    }

    return true;
}
<#else>
static bool lDRV_SPI_StartDMATransfer(
    DRV_SPI_OBJ* dObj,
    void* pTransmitData,
    size_t txSize,
    void* pReceiveData,
    size_t rxSize
)
{
    uint32_t size = 0;
    /* To avoid unused build error */
    (void) size;

    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)dObj->activeClient;

    dObj->txDummyDataSize = 0;
    dObj->rxDummyDataSize = 0;
    dObj->pNextTransmitData = (uintptr_t)NULL;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    if (txSize != 0)
    {
        /* Clean cache lines to push the transmit buffer data to the main memory */
        SYS_CACHE_CleanDCache_by_Addr((uint32_t *)pTransmitData, txSize);
    }
    if (rxSize != 0)
    {
        /* Invalidate the receive buffer to force the CPU to read from the main memory */
        SYS_CACHE_InvalidateDCache_by_Addr((uint32_t *)pReceiveData, rxSize);
    }
</#if>

    if(clientObj->setup.dataBits == DRV_SPI_DATA_BITS_8)
    {
        SYS_DMA_DataWidthSetup(dObj->rxDMAChannel, SYS_DMA_WIDTH_8_BIT);
        SYS_DMA_DataWidthSetup(dObj->txDMAChannel, SYS_DMA_WIDTH_8_BIT);
    }
    else if (clientObj->setup.dataBits <= DRV_SPI_DATA_BITS_16)
    {
        SYS_DMA_DataWidthSetup(dObj->rxDMAChannel, SYS_DMA_WIDTH_16_BIT);
        SYS_DMA_DataWidthSetup(dObj->txDMAChannel, SYS_DMA_WIDTH_16_BIT);
    }
    else
    {
        SYS_DMA_DataWidthSetup(dObj->rxDMAChannel, SYS_DMA_WIDTH_32_BIT);
        SYS_DMA_DataWidthSetup(dObj->txDMAChannel, SYS_DMA_WIDTH_32_BIT);
    }

    if (rxSize >= txSize)
    {
        /* Dummy data will be sent by the TX DMA */
        dObj->txDummyDataSize = (rxSize - txSize);
    }
    else
    {
        /* Dummy data will be received by the RX DMA */
        dObj->rxDummyDataSize = (txSize - rxSize);
    }

    if (rxSize == 0)
    {
        /* Configure the RX DMA channel - to receive dummy data */
        SYS_DMA_AddressingModeSetup(dObj->rxDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);
        size = dObj->rxDummyDataSize;
        dObj->rxDummyDataSize = 0;
        (void) SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)&dObj->rxDummyData, size);
    }
    else
    {
        /* Configure the RX DMA channel - to receive data in receive buffer */
        SYS_DMA_AddressingModeSetup(dObj->rxDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_INCREMENTED);

        (void) SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)pReceiveData, rxSize);
    }

    if (txSize == 0)
    {
        /* Configure the TX DMA channel - to send dummy data */
        SYS_DMA_AddressingModeSetup(dObj->txDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);
        size = dObj->txDummyDataSize;
        dObj->txDummyDataSize = 0;
        (void) SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)txDummyData, (const void*)dObj->txAddress, size);
    }
    else
    {
        /* Configure the transmit DMA channel - to send data from transmit buffer */
        SYS_DMA_AddressingModeSetup(dObj->txDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_INCREMENTED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);

        /* The DMA transfer is split into two for the case where
         * rxSize > 0 && rxSize < txSize
         */
        if (dObj->rxDummyDataSize > 0)
        {
            size = rxSize;
            dObj->pNextTransmitData = (uintptr_t)&((uint8_t*)pTransmitData)[rxSize];
        }
        else
        {
            size = txSize;
        }

        (void) SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)pTransmitData, (const void*)dObj->txAddress, size);
    }

    return true;
}
</#if>
</#if>

static void lDRV_SPI_PlibCallbackHandler(uintptr_t contextHandle)
{
    DRV_SPI_OBJ* dObj = (DRV_SPI_OBJ *)contextHandle;
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)NULL;

    clientObj = (DRV_SPI_CLIENT_OBJ*)dObj->activeClient;

    if(clientObj->setup.chipSelect != SYS_PORT_PIN_NONE)
    {
        /* De-assert Chip Select if it is defined by user */
        if (clientObj->setup.csPolarity == DRV_SPI_CS_POLARITY_ACTIVE_LOW)
        {
            SYS_PORT_PinSet(clientObj->setup.chipSelect);
        }
        else
        {
            SYS_PORT_PinClear(clientObj->setup.chipSelect);
        }
    }

    dObj->transferStatus = DRV_SPI_TRANSFER_STATUS_COMPLETE;

    /* Unblock the application thread */
    (void) OSAL_SEM_PostISR( &dObj->transferDone);
}

/* MISRA C-2012 Rule 10.4 False positive:4  Deviation record ID -  H3_MISRAC_2012_R_10_4_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block fp:4 "MISRA C-2012 Rule 10.4" "H3_MISRAC_2012_R_10_4_DR_1"
</#if>

/* Locks the SPI driver for exclusive use by a client */
static bool DRV_SPI_ExclusiveUse( const DRV_HANDLE handle, bool useExclusive )
{
    DRV_SPI_CLIENT_OBJ* clientObj = NULL;
    DRV_SPI_OBJ* dObj = (DRV_SPI_OBJ*)NULL;
    bool isSuccess = false;

    /* Validate the driver handle */
    clientObj = lDRV_SPI_DriverHandleValidate(handle);

    if (clientObj != NULL)
    {
        dObj = clientObj->dObj;

        if (useExclusive == true)
        {
            if (dObj->drvInExclusiveMode == true)
            {
                if (dObj->exclusiveUseClientHandle == handle)
                {
                    dObj->exclusiveUseCntr++;
                    isSuccess = true;
                }
            }
            else
            {
                /* Guard against multiple threads trying to lock the driver */
                if (OSAL_MUTEX_Lock(&dObj->mutexExclusiveUse , OSAL_WAIT_FOREVER ) == OSAL_RESULT_FAIL)
                {
                    isSuccess = false;
                }
                else
                {
                    dObj->drvInExclusiveMode = true;
                    dObj->exclusiveUseClientHandle = handle;
                    dObj->exclusiveUseCntr++;
                    isSuccess = true;
                }
            }
        }
        else
        {
            if (dObj->exclusiveUseClientHandle == handle)
            {
                if (dObj->exclusiveUseCntr > 0U)
                {
                    dObj->exclusiveUseCntr--;
                    if (dObj->exclusiveUseCntr == 0U)
                    {
                        dObj->exclusiveUseClientHandle = DRV_HANDLE_INVALID;
                        dObj->drvInExclusiveMode = false;

                        (void) OSAL_MUTEX_Unlock( &dObj->mutexExclusiveUse);
                    }
                }
                isSuccess = true;
            }
        }
    }

    return isSuccess;
}

<#if core.DMA_ENABLE?has_content && DRV_SPI_SYS_DMA_ENABLE == true>
<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == true>
void lDRV_SPI_TX_DMA_CallbackHandler(
    SYS_DMA_TRANSFER_EVENT event,
    uintptr_t context
)
{
    /* Do nothing */
}

void lDRV_SPI_RX_DMA_CallbackHandler(
    SYS_DMA_TRANSFER_EVENT event,
    uintptr_t context
)
{
    DRV_SPI_OBJ* dObj = (DRV_SPI_OBJ *)context;
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)NULL;
    uint32_t size;
    uint32_t index;

    if (dObj->rxPending > 0)
    {
        /* txPending is 0. Need to use the dummy data buffer for transmission.
         * Find out the max data that can be received, given the limited size of the dummy data buffer.
         */
        (dObj->rxPending > sizeof(dObj->dummyDataBuffer)) ?
            (size = sizeof(dObj->dummyDataBuffer)): (size = dObj->rxPending);

        index = dObj->nBytesTransferred;

        /* Calculate the remaining rx bytes and total bytes transferred */
        dObj->rxPending -= size;
        dObj->nBytesTransferred += size;

        /* Always set up the rx channel first */
        (void) SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)&((uint8_t*)dObj->pReceiveData)[index], size);
        (void) SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)dObj->dummyDataBuffer, (const void*)dObj->txAddress, size);

    }
    else if (dObj->txPending > 0)
    {
        /* rxPending is 0. Need to use the dummy data buffer for reception.
         * Find out the max data that can be transmitted, given the limited size of the dummy data buffer.
         */
        (dObj->txPending > sizeof(dObj->dummyDataBuffer)) ?
            (size = sizeof(dObj->dummyDataBuffer)): (size = dObj->txPending);

        index = dObj->nBytesTransferred;

        /* Calculate the remaining tx bytes and total bytes transferred */
        dObj->txPending -= size;
        dObj->nBytesTransferred += size;

        /* Always set up the rx channel first */
        (void) SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)dObj->dummyDataBuffer, size);
        (void) SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)&((uint8_t*)dObj->pTransmitData)[index], (const void*)dObj->txAddress, size);
    }
    else
    {
        /* Transfer complete. De-assert Chip Select if it is defined by user. */
        clientObj = (DRV_SPI_CLIENT_OBJ*)dObj->activeClient;

        /* Make sure the shift register is empty before de-asserting the CS line */
        while (dObj->spiPlib->isTransmitterBusy())
        {
            /* Do Nothing */
        }

        /* De-assert Chip Select if it is defined by user */
        if(clientObj->setup.chipSelect != SYS_PORT_PIN_NONE)
        {
            if (clientObj->setup.csPolarity == DRV_SPI_CS_POLARITY_ACTIVE_LOW)
            {
                SYS_PORT_PinSet(clientObj->setup.chipSelect);
            }
            else
            {
                SYS_PORT_PinClear(clientObj->setup.chipSelect);
            }
        }

        if(event == SYS_DMA_TRANSFER_COMPLETE)
        {
            dObj->transferStatus = DRV_SPI_TRANSFER_STATUS_COMPLETE;
        }
        else
        {
            dObj->transferStatus = DRV_SPI_TRANSFER_STATUS_ERROR;
        }

        /* Unblock the application thread */
        (void) OSAL_SEM_PostISR( &dObj->transferDone);
    }
}

<#else>
void lDRV_SPI_TX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{
    DRV_SPI_OBJ* dObj = (DRV_SPI_OBJ *)context;

    if (dObj->txDummyDataSize > 0)
    {
        /* Configure DMA channel to transmit (dummy data) from the same location
         * (Source address not incremented) */
        SYS_DMA_AddressingModeSetup(dObj->txDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);

        /* Configure the transmit DMA channel */
        (void) SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)txDummyData, (const void*)dObj->txAddress, dObj->txDummyDataSize);

        dObj->txDummyDataSize = 0;
    }
}

void lDRV_SPI_RX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{
    DRV_SPI_OBJ* dObj = (DRV_SPI_OBJ *)context;
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)NULL;

    if (dObj->rxDummyDataSize > 0)
    {
        /* Configure DMA to receive dummy data */
        SYS_DMA_AddressingModeSetup(dObj->rxDMAChannel, SYS_DMA_SOURCE_ADDRESSING_MODE_FIXED, SYS_DMA_DESTINATION_ADDRESSING_MODE_FIXED);

        (void) SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)&dObj->rxDummyData, dObj->rxDummyDataSize);

        (void) SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)dObj->pNextTransmitData, (const void*)dObj->txAddress, dObj->rxDummyDataSize);

        dObj->rxDummyDataSize = 0;
    }
    else
    {
        clientObj = (DRV_SPI_CLIENT_OBJ*)dObj->activeClient;

        /* Make sure the shift register is empty before de-asserting the CS line */
        while (dObj->spiPlib->isTransmitterBusy())
        {
            /* Do Nothing */
        }

        /* De-assert Chip Select if it is defined by user */
        if(clientObj->setup.chipSelect != SYS_PORT_PIN_NONE)
        {
            if (clientObj->setup.csPolarity == DRV_SPI_CS_POLARITY_ACTIVE_LOW)
            {
                SYS_PORT_PinSet(clientObj->setup.chipSelect);
            }
            else
            {
                SYS_PORT_PinClear(clientObj->setup.chipSelect);
            }
        }

        if(event == SYS_DMA_TRANSFER_COMPLETE)
        {
            dObj->transferStatus = DRV_SPI_TRANSFER_STATUS_COMPLETE;
        }
        else
        {
            dObj->transferStatus = DRV_SPI_TRANSFER_STATUS_ERROR;
        }

        /* Unblock the application thread */
        (void) OSAL_SEM_PostISR( &dObj->transferDone);
    }
}
</#if>
</#if>
// *****************************************************************************
// *****************************************************************************
// Section: SPI Driver Common Interface Implementation
// *****************************************************************************
// *****************************************************************************

/* MISRA C-2012 Rule 11.1, 11.3, 11.8 deviated below. Deviation record ID -
    H3_MISRAC_2012_R_11_1_DR_1, H3_MISRAC_2012_R_11_3_DR_1 & H3_MISRAC_2012_R_11_8_DR_1*/
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance block \
(deviate:2 "MISRA C-2012 Rule 11.1" "H3_MISRAC_2012_R_11_1_DR_1" )\
(deviate:1 "MISRA C-2012 Rule 11.3" "H3_MISRAC_2012_R_11_3_DR_1" )\
(deviate:1 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1" )
</#if>
SYS_MODULE_OBJ DRV_SPI_Initialize( const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT * const init )
{
    DRV_SPI_OBJ* dObj     = (DRV_SPI_OBJ *)NULL;
    DRV_SPI_INIT* spiInit = (DRV_SPI_INIT *)init;
<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == false>
<#if core.DMA_ENABLE?has_content && DRV_SPI_SYS_DMA_ENABLE == true>
    size_t  txDummyDataIdx;
</#if>
</#if>

    /* Validate the request */
    if(drvIndex >= DRV_SPI_INSTANCES_NUMBER)
    {
        SYS_DEBUG_MESSAGE(SYS_ERROR_ERROR, "Invalid driver instance");
        return SYS_MODULE_OBJ_INVALID;
    }

    if(gDrvSPIObj[drvIndex].inUse == true)
    {
        SYS_DEBUG_MESSAGE(SYS_ERROR_ERROR, "Instance already in use");
        return SYS_MODULE_OBJ_INVALID;
    }

    /* Allocate the driver object */
    dObj = &gDrvSPIObj[drvIndex];

    /* Update the driver parameters */
    dObj->spiPlib               = spiInit->spiPlib;
    dObj->clientObjPool         = spiInit->clientObjPool;
    dObj->nClientsMax           = spiInit->numClients;
    dObj->nClients              = 0;
    dObj->activeClient          = 0U;
    dObj->spiTokenCount         = 1;
    dObj->isExclusive           = false;
<#if core.DMA_ENABLE?has_content && DRV_SPI_SYS_DMA_ENABLE == true>
    dObj->txDMAChannel          = spiInit->dmaChannelTransmit;
    dObj->rxDMAChannel          = spiInit->dmaChannelReceive;
    dObj->txAddress             = spiInit->spiTransmitAddress;
    dObj->rxAddress             = spiInit->spiReceiveAddress;
</#if>
    dObj->remapDataBits         = spiInit->remapDataBits;
    dObj->remapClockPolarity    = spiInit->remapClockPolarity;
    dObj->remapClockPhase       = spiInit->remapClockPhase;
    dObj->drvInExclusiveMode        = false;
    dObj->exclusiveUseCntr          = 0;

<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == false>
<#if core.DMA_ENABLE?has_content && DRV_SPI_SYS_DMA_ENABLE == true>
    for (txDummyDataIdx = 0; txDummyDataIdx < sizeof(txDummyData); txDummyDataIdx++)
    {
        txDummyData[txDummyDataIdx] = 0xFF;
    }
</#if>

<#if core.DMA_ENABLE?has_content && DRV_SPI_SYS_DMA_ENABLE == true && core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    if (dObj->txDMAChannel != SYS_DMA_CHANNEL_NONE)
    {
        /* Clean cache lines having source buffer before submitting a transfer
         * request to DMA to load the latest data in the cache to the main
         * memory */
        SYS_CACHE_CleanDCache_by_Addr((uint32_t *)txDummyData, sizeof(txDummyData));
    }
</#if>
</#if>

    if (OSAL_MUTEX_Create(&dObj->transferMutex) == OSAL_RESULT_FAIL)
    {
        /*  If the mutex was not created because the memory required to
            hold the mutex could not be allocated then NULL is returned. */
        return SYS_MODULE_OBJ_INVALID;
    }

    if (OSAL_MUTEX_Create(&dObj->clientMutex) == OSAL_RESULT_FAIL)
    {
        /*  If the mutex was not created because the memory required to
            hold the mutex could not be allocated then NULL is returned. */
        return SYS_MODULE_OBJ_INVALID;
    }

    if (OSAL_SEM_Create(&dObj->transferDone,OSAL_SEM_TYPE_BINARY, 0, 0) == OSAL_RESULT_FAIL)
    {
        /* There was insufficient heap memory available for the semaphore to
        be created successfully. */
        return SYS_MODULE_OBJ_INVALID;
    }

    if(OSAL_MUTEX_Create(&(dObj->mutexExclusiveUse)) != OSAL_RESULT_SUCCESS)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

<#if core.DMA_ENABLE?has_content && DRV_SPI_SYS_DMA_ENABLE == true>
    if((dObj->txDMAChannel != SYS_DMA_CHANNEL_NONE) && (dObj->rxDMAChannel != SYS_DMA_CHANNEL_NONE))
    {
        /* Register call-backs with the DMA System Service */
        SYS_DMA_ChannelCallbackRegister(dObj->txDMAChannel, lDRV_SPI_TX_DMA_CallbackHandler, (uintptr_t)dObj);

        SYS_DMA_ChannelCallbackRegister(dObj->rxDMAChannel, lDRV_SPI_RX_DMA_CallbackHandler, (uintptr_t)dObj);
    }
    else
    {
        /* Register a callback with PLIB.
         * dObj as a context parameter will be used to distinguish the events
         * from different instances. */
        dObj->spiPlib->callbackRegister(&lDRV_SPI_PlibCallbackHandler, (uintptr_t)dObj);
    }
<#else>
    /* Register a callback with PLIB.
     * dObj as a context parameter will be used to distinguish the events
     * from different instances. */
    dObj->spiPlib->callbackRegister(&lDRV_SPI_PlibCallbackHandler, (uintptr_t)dObj);

</#if>
    dObj->inUse = true;

    /* Update the status */
    dObj->status = SYS_STATUS_READY;

    /* Return the object structure */
    return ( (SYS_MODULE_OBJ)drvIndex );
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.3"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"
</#if>
/* MISRAC 2012 deviation block end */

SYS_STATUS DRV_SPI_Status( SYS_MODULE_OBJ object)
{
    /* Validate the request */
    if( (object == SYS_MODULE_OBJ_INVALID) || (object >= DRV_SPI_INSTANCES_NUMBER) )
    {
        SYS_DEBUG_MESSAGE(SYS_ERROR_ERROR, "Invalid system object handle");
        return SYS_STATUS_UNINITIALIZED;
    }

    return (gDrvSPIObj[object].status);
}

DRV_HANDLE DRV_SPI_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    DRV_SPI_CLIENT_OBJ* clientObj = NULL;
    DRV_SPI_OBJ* dObj = NULL;
    uint8_t iClient;

    /* Validate the request */
    if (drvIndex >= DRV_SPI_INSTANCES_NUMBER)
    {
        SYS_DEBUG_MESSAGE(SYS_ERROR_ERROR, "Invalid Driver Instance");
        return DRV_HANDLE_INVALID;
    }

    dObj = &gDrvSPIObj[drvIndex];

    if(dObj->status != SYS_STATUS_READY)
    {
        SYS_DEBUG_MESSAGE(SYS_ERROR_ERROR, "Was the driver initialized?");
        return DRV_HANDLE_INVALID;
    }

    /* Acquire the instance specific mutex to protect the instance specific
     * client pool
     */
    if (OSAL_MUTEX_Lock(&dObj->clientMutex , OSAL_WAIT_FOREVER ) == OSAL_RESULT_FAIL)
    {
        return DRV_HANDLE_INVALID;
    }

    if(dObj->isExclusive)
    {
        /* This means the another client has opened the driver in exclusive
           mode. So the driver cannot be opened by any other client. */
        (void) OSAL_MUTEX_Unlock( &dObj->clientMutex);
        return DRV_HANDLE_INVALID;
    }

    if((dObj->nClients > 0U) && (((uint32_t)ioIntent & (uint32_t)DRV_IO_INTENT_EXCLUSIVE) != 0U))
    {
        /* This means the driver was already opened and another driver was
           trying to open it exclusively.  We cannot give exclusive access in
           this case */
        (void) OSAL_MUTEX_Unlock( &dObj->clientMutex);
        return DRV_HANDLE_INVALID;
    }

    for(iClient = 0; iClient != dObj->nClientsMax; iClient++)
    {
        if(false == ((DRV_SPI_CLIENT_OBJ *)dObj->clientObjPool)[iClient].inUse)
        {
            /* This means we have a free client object to use */
            clientObj = &((DRV_SPI_CLIENT_OBJ *)dObj->clientObjPool)[iClient];
            clientObj->inUse = true;
            clientObj->dObj = dObj;
            clientObj->ioIntent = ioIntent;
            clientObj->setup.chipSelect = SYS_PORT_PIN_NONE;
            clientObj->setupChanged = false;

            if(((uint32_t)ioIntent & (uint32_t)DRV_IO_INTENT_EXCLUSIVE) != 0U)
            {
                /* Set the driver exclusive flag */
                dObj->isExclusive = true;
            }

            dObj->nClients++;

            /* Generate and save the client handle in the client object, which will
             * be then used to verify the validity of the client handle.
             */
            clientObj->clientHandle = (DRV_HANDLE)lDRV_SPI_MAKE_HANDLE(dObj->spiTokenCount, (uint8_t)drvIndex, iClient);

            /* Increment the instance specific token counter */
            dObj->spiTokenCount = lDRV_SPI_UPDATE_TOKEN(dObj->spiTokenCount);

            break;
        }
    }

    (void) OSAL_MUTEX_Unlock(&dObj->clientMutex);

    /* Driver index is the handle */
    return (clientObj != NULL) ? ((DRV_HANDLE)clientObj->clientHandle) : DRV_HANDLE_INVALID;
}

void DRV_SPI_Close( DRV_HANDLE handle )
{
    /* This function closes the client, The client
       object is deallocated and returned to the
       pool.
    */
    DRV_SPI_CLIENT_OBJ* clientObj;
    DRV_SPI_OBJ* dObj;

    /* Validate the handle */
    clientObj = lDRV_SPI_DriverHandleValidate(handle);

    if(clientObj != NULL)
    {
        dObj = (DRV_SPI_OBJ *)clientObj->dObj;

        /* Acquire the client mutex to protect the client pool */
        if (OSAL_MUTEX_Lock(&dObj->clientMutex , OSAL_WAIT_FOREVER ) == OSAL_RESULT_SUCCESS)
        {
            /* Release the mutex if the client being closed was using the driver in exclusive mode */
            if (dObj->exclusiveUseClientHandle == handle)
            {
                dObj->drvInExclusiveMode = false;
                dObj->exclusiveUseCntr = 0;
                dObj->exclusiveUseClientHandle = DRV_HANDLE_INVALID;

                /* Release the exclusive use mutex (if held by the client) */
                (void) OSAL_MUTEX_Unlock( &dObj->mutexExclusiveUse);
            }

            /* Reduce the number of clients */
            dObj->nClients--;

            /* Reset the exclusive flag */
            dObj->isExclusive = false;

            /* De-allocate the object */
            clientObj->inUse = false;

            /* Release the client mutex */
            (void) OSAL_MUTEX_Unlock( &dObj->clientMutex );
        }
    }
}

bool DRV_SPI_TransferSetup( const DRV_HANDLE handle, DRV_SPI_TRANSFER_SETUP* setup )
{
    DRV_SPI_CLIENT_OBJ* clientObj = NULL;
    bool isSuccess = false;

    /* Validate the handle */
    clientObj = lDRV_SPI_DriverHandleValidate(handle);

    if((clientObj != NULL) && (setup != NULL))
    {
        /* Save the required setup in client object which can be used while
        processing queue requests. */
        clientObj->setup = *setup;

        /* Update the flag denoting that setup has been changed dynamically */
        clientObj->setupChanged = true;

        isSuccess = true;
    }
    return isSuccess;
}

bool DRV_SPI_WriteTransfer(const DRV_HANDLE handle, void* pTransmitData,  size_t txSize )
{
    return DRV_SPI_WriteReadTransfer(handle, pTransmitData, txSize, NULL, 0);
}

bool DRV_SPI_ReadTransfer(const DRV_HANDLE handle, void* pReceiveData,  size_t rxSize )
{
    return DRV_SPI_WriteReadTransfer(handle, NULL, 0, pReceiveData, rxSize);
}

bool DRV_SPI_WriteReadTransfer(const DRV_HANDLE handle,
    void* pTransmitData,
    size_t txSize,
    void* pReceiveData,
    size_t rxSize
)
{
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)NULL;
    DRV_SPI_OBJ* dObj = (DRV_SPI_OBJ *)NULL;
    DRV_SPI_TRANSFER_SETUP setupRemap;
    bool isTransferInProgress = false;
    bool isSuccess = false;
    static bool isExclusiveUseMutexAcquired = false;

    /* Validate the driver handle */
    clientObj = lDRV_SPI_DriverHandleValidate(handle);

    if((clientObj != NULL) && (((txSize > 0U) && (pTransmitData != NULL)) ||
        ((rxSize > 0U) && (pReceiveData != NULL)))
    )
    {
        dObj = clientObj->dObj;

        if ((dObj->drvInExclusiveMode == true) && (dObj->exclusiveUseClientHandle != handle))
        {
            if (OSAL_MUTEX_Lock(&dObj->mutexExclusiveUse , OSAL_WAIT_FOREVER ) == OSAL_RESULT_FAIL)
            {
                return isSuccess;
            }
            else
            {
                isExclusiveUseMutexAcquired = true;
            }
        }

        /* Block other clients/threads from accessing the PLIB */
        if (OSAL_MUTEX_Lock(&dObj->transferMutex, OSAL_WAIT_FOREVER ) == OSAL_RESULT_SUCCESS)
        {
            /* Update the PLIB Setup if current request is from a different client or
            setup has been changed dynamically for the client */
            if ((dObj->activeClient != (uintptr_t)clientObj) || (clientObj->setupChanged == true))
            {
                setupRemap = clientObj->setup;
                setupRemap.clockPolarity = (DRV_SPI_CLOCK_POLARITY)dObj->remapClockPolarity[clientObj->setup.clockPolarity];
                setupRemap.clockPhase = (DRV_SPI_CLOCK_PHASE)dObj->remapClockPhase[clientObj->setup.clockPhase];
                setupRemap.dataBits = (DRV_SPI_DATA_BITS)dObj->remapDataBits[clientObj->setup.dataBits];

                (void) dObj->spiPlib->setup(&setupRemap, USE_FREQ_CONFIGURED_IN_CLOCK_MANAGER);
                clientObj->setupChanged = false;
            }

            if(clientObj->setup.chipSelect != SYS_PORT_PIN_NONE)
            {
                /* Assert Chip Select if it is defined by user */
                if (clientObj->setup.csPolarity == DRV_SPI_CS_POLARITY_ACTIVE_LOW)
                {
                    SYS_PORT_PinClear(clientObj->setup.chipSelect);
                }
                else
                {
                    SYS_PORT_PinSet(clientObj->setup.chipSelect);
                }
            }

            /* Active client allows de-asserting the chip select line in ISR routine */
            dObj->activeClient = (uintptr_t)clientObj;

            if((clientObj->setup.dataBits > DRV_SPI_DATA_BITS_8) && (clientObj->setup.dataBits <= DRV_SPI_DATA_BITS_16))
            {
                /* Both SPI and DMA PLIB expect size in terms of bytes, hence multiply transmit and receive sizes by 2 */
                rxSize = rxSize << 1;
                txSize = txSize << 1;
            }
            else if ((clientObj->setup.dataBits > DRV_SPI_DATA_BITS_16) && (clientObj->setup.dataBits <= DRV_SPI_DATA_BITS_32))
            {
                /* Both SPI and DMA PLIB expect size in terms of bytes, hence multiply transmit and receive sizes by 2 */
                rxSize = rxSize << 2;
                txSize = txSize << 2;
            }
            else
            {
                /* Nothing to do */
            }

<#if core.DMA_ENABLE?has_content && DRV_SPI_SYS_DMA_ENABLE == true>
            if((dObj->txDMAChannel != SYS_DMA_CHANNEL_NONE) && ((dObj->rxDMAChannel != SYS_DMA_CHANNEL_NONE)))
            {
<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == true>
                dObj->pReceiveData = pReceiveData;
                dObj->pTransmitData = pTransmitData;
</#if>

                if (lDRV_SPI_StartDMATransfer(dObj, pTransmitData, txSize, pReceiveData, rxSize) == true)
                {
                    isTransferInProgress = true;
                }
            }
            else
            {
                if (dObj->spiPlib->writeRead(pTransmitData, txSize, pReceiveData, rxSize) == true)
                {
                    isTransferInProgress = true;
                }
            }

<#else>
            if (dObj->spiPlib->writeRead(pTransmitData, txSize, pReceiveData, rxSize) == true)
            {
                isTransferInProgress = true;
            }

</#if>
            if (isTransferInProgress == true)
            {
                /* Wait till transfer completes. This semaphore is released from the ISR */
                if (OSAL_SEM_Pend( &dObj->transferDone, OSAL_WAIT_FOREVER ) == OSAL_RESULT_SUCCESS)
                {
                    if (dObj->transferStatus == DRV_SPI_TRANSFER_STATUS_COMPLETE)
                    {
                        isSuccess = true;
                    }
                }
            }

            /* Release the mutex to allow other clients/threads to access the PLIB */
            (void) OSAL_MUTEX_Unlock(&dObj->transferMutex);
        }

        if (isExclusiveUseMutexAcquired == true)
        {
            isExclusiveUseMutexAcquired = false;

            (void) OSAL_MUTEX_Unlock( &dObj->mutexExclusiveUse);
        }
    }
    return isSuccess;
}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 10.4"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */

bool DRV_SPI_Lock( const DRV_HANDLE handle, bool lock )
{
    return DRV_SPI_ExclusiveUse( handle, lock );
}