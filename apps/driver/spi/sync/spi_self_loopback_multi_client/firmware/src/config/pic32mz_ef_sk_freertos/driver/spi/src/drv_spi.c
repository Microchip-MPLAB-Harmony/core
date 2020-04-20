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
#include "system/debug/sys_debug.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data
// *****************************************************************************
// *****************************************************************************

/* This is the driver instance object array. */
static CACHE_ALIGN DRV_SPI_OBJ gDrvSPIObj[DRV_SPI_INSTANCES_NUMBER];

// *****************************************************************************
// *****************************************************************************
// Section: File scope functions
// *****************************************************************************
// *****************************************************************************

static inline uint32_t  _DRV_SPI_MAKE_HANDLE(uint16_t token, uint8_t drvIndex, uint8_t clientIndex)
{
    return ((token << 16) | (drvIndex << 8) | clientIndex);
}

static inline uint16_t _DRV_SPI_UPDATE_TOKEN(uint16_t token)
{
    token++;

    if (token >= DRV_SPI_TOKEN_MAX)
    {
        token = 1;
    }

    return token;
}

static DRV_SPI_CLIENT_OBJ* _DRV_SPI_DriverHandleValidate(DRV_HANDLE handle)
{
    /* This function returns the pointer to the client object that is
       associated with this handle if the handle is valid. Returns NULL
       otherwise. */

    uint32_t drvInstance = 0;
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ*)NULL;

    if((handle != DRV_HANDLE_INVALID) && (handle != 0))
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

static bool _DRV_SPI_StartDMATransfer(
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
    else
    {
        /* If its DMA mode and SPI data bits is other than 8 bit, then divide transmit and receive sizes by 2 */
        rxSize = rxSize >> 1;
        txSize = txSize >> 1;

        SYS_DMA_DataWidthSetup(dObj->rxDMAChannel, SYS_DMA_WIDTH_16_BIT);
        SYS_DMA_DataWidthSetup(dObj->txDMAChannel, SYS_DMA_WIDTH_16_BIT);
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
        SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)pReceiveData, size);
        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)pTransmitData, (const void*)dObj->txAddress, size);
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
            SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)pReceiveData, size);
            SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)dObj->dummyDataBuffer, (const void*)dObj->txAddress, size);

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
            SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)dObj->dummyDataBuffer, size);
            SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)pTransmitData, (const void*)dObj->txAddress, size);
        }
    }

    return true;
}

static void _DRV_SPI_PlibCallbackHandler(uintptr_t contextHandle)
{
    DRV_SPI_OBJ* dObj = (DRV_SPI_OBJ *)contextHandle;
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)NULL;

    clientObj = (DRV_SPI_CLIENT_OBJ*)dObj->activeClient;

    if(clientObj->setup.chipSelect != SYS_PORT_PIN_NONE)
    {
        /* De-assert Chip Select if it is defined by user */
        SYS_PORT_PinWrite(clientObj->setup.chipSelect, !((bool)(clientObj->setup.csPolarity)));
    }

    dObj->transferStatus = DRV_SPI_TRANSFER_STATUS_COMPLETE;

    /* Unblock the application thread */
    OSAL_SEM_PostISR( &dObj->transferDone);
}

void _DRV_SPI_TX_DMA_CallbackHandler(
    SYS_DMA_TRANSFER_EVENT event,
    uintptr_t context
)
{
    /* Do nothing */
}

void _DRV_SPI_RX_DMA_CallbackHandler(
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
        SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)&((uint8_t*)dObj->pReceiveData)[index], size);
        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)dObj->dummyDataBuffer, (const void*)dObj->txAddress, size);

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
        SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)dObj->dummyDataBuffer, size);
        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)&((uint8_t*)dObj->pTransmitData)[index], (const void*)dObj->txAddress, size);
    }
    else
    {
        /* Transfer complete. De-assert Chip Select if it is defined by user. */
        clientObj = (DRV_SPI_CLIENT_OBJ*)dObj->activeClient;

        /* Make sure the shift register is empty before de-asserting the CS line */
        while (dObj->spiPlib->isBusy());

        /* De-assert Chip Select if it is defined by user */
        if(clientObj->setup.chipSelect != SYS_PORT_PIN_NONE)
        {
            SYS_PORT_PinWrite(clientObj->setup.chipSelect, !((bool)(clientObj->setup.csPolarity)));
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
        OSAL_SEM_PostISR( &dObj->transferDone);
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: SPI Driver Common Interface Implementation
// *****************************************************************************
// *****************************************************************************

SYS_MODULE_OBJ DRV_SPI_Initialize( const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT * const init )
{
    DRV_SPI_OBJ* dObj     = (DRV_SPI_OBJ *)NULL;
    DRV_SPI_INIT* spiInit = (DRV_SPI_INIT *)init;

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
    dObj->activeClient          = (uintptr_t)NULL;
    dObj->spiTokenCount         = 1;
    dObj->isExclusive           = false;
    dObj->txDMAChannel          = spiInit->dmaChannelTransmit;
    dObj->rxDMAChannel          = spiInit->dmaChannelReceive;
    dObj->txAddress             = spiInit->spiTransmitAddress;
    dObj->rxAddress             = spiInit->spiReceiveAddress;
    dObj->remapDataBits         = spiInit->remapDataBits;
    dObj->remapClockPolarity    = spiInit->remapClockPolarity;
    dObj->remapClockPhase       = spiInit->remapClockPhase;


    if (OSAL_MUTEX_Create(&dObj->transferMutex) == OSAL_RESULT_FALSE)
    {
        /*  If the mutex was not created because the memory required to
            hold the mutex could not be allocated then NULL is returned. */
        return SYS_MODULE_OBJ_INVALID;
    }

    if (OSAL_MUTEX_Create(&dObj->clientMutex) == OSAL_RESULT_FALSE)
    {
        /*  If the mutex was not created because the memory required to
            hold the mutex could not be allocated then NULL is returned. */
        return SYS_MODULE_OBJ_INVALID;
    }

    if (OSAL_SEM_Create(&dObj->transferDone,OSAL_SEM_TYPE_BINARY, 0, 0) == OSAL_RESULT_FALSE)
    {
        /* There was insufficient heap memory available for the semaphore to
        be created successfully. */
        return SYS_MODULE_OBJ_INVALID;
    }

    if((dObj->txDMAChannel != SYS_DMA_CHANNEL_NONE) && (dObj->rxDMAChannel != SYS_DMA_CHANNEL_NONE))
    {
        /* Register call-backs with the DMA System Service */
        SYS_DMA_ChannelCallbackRegister(dObj->txDMAChannel, _DRV_SPI_TX_DMA_CallbackHandler, (uintptr_t)dObj);

        SYS_DMA_ChannelCallbackRegister(dObj->rxDMAChannel, _DRV_SPI_RX_DMA_CallbackHandler, (uintptr_t)dObj);
    }
    else
    {
        /* Register a callback with PLIB.
         * dObj as a context parameter will be used to distinguish the events
         * from different instances. */
        dObj->spiPlib->callbackRegister(&_DRV_SPI_PlibCallbackHandler, (uintptr_t)dObj);
    }
    dObj->inUse = true;

    /* Update the status */
    dObj->status = SYS_STATUS_READY;

    /* Return the object structure */
    return ( (SYS_MODULE_OBJ)drvIndex );
}

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
    if (OSAL_MUTEX_Lock(&dObj->clientMutex , OSAL_WAIT_FOREVER ) == OSAL_RESULT_FALSE)
    {
        return DRV_HANDLE_INVALID;
    }

    if(dObj->isExclusive)
    {
        /* This means the another client has opened the driver in exclusive
           mode. So the driver cannot be opened by any other client. */
        OSAL_MUTEX_Unlock( &dObj->clientMutex);
        return DRV_HANDLE_INVALID;
    }

    if((dObj->nClients > 0) && (ioIntent & DRV_IO_INTENT_EXCLUSIVE))
    {
        /* This means the driver was already opened and another driver was
           trying to open it exclusively.  We cannot give exclusive access in
           this case */
        OSAL_MUTEX_Unlock( &dObj->clientMutex);
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

            if(ioIntent & DRV_IO_INTENT_EXCLUSIVE)
            {
                /* Set the driver exclusive flag */
                dObj->isExclusive = true;
            }

            dObj->nClients++;

            /* Generate and save the client handle in the client object, which will
             * be then used to verify the validity of the client handle.
             */
            clientObj->clientHandle = (DRV_HANDLE)_DRV_SPI_MAKE_HANDLE(dObj->spiTokenCount, (uint8_t)drvIndex, iClient);

            /* Increment the instance specific token counter */
            dObj->spiTokenCount = _DRV_SPI_UPDATE_TOKEN(dObj->spiTokenCount);

            break;
        }
    }

    OSAL_MUTEX_Unlock(&dObj->clientMutex);

    /* Driver index is the handle */
    return clientObj ? ((DRV_HANDLE)clientObj->clientHandle) : DRV_HANDLE_INVALID;
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
    clientObj = _DRV_SPI_DriverHandleValidate(handle);

    if(clientObj != NULL)
    {
        dObj = (DRV_SPI_OBJ *)clientObj->dObj;

        /* Acquire the client mutex to protect the client pool */
        if (OSAL_MUTEX_Lock(&dObj->clientMutex , OSAL_WAIT_FOREVER ) == OSAL_RESULT_TRUE)
        {
            /* Reduce the number of clients */
            dObj->nClients--;

            /* Reset the exclusive flag */
            dObj->isExclusive = false;

            /* De-allocate the object */
            clientObj->inUse = false;

            /* Release the client mutex */
            OSAL_MUTEX_Unlock( &dObj->clientMutex );
        }
    }
}

bool DRV_SPI_TransferSetup( const DRV_HANDLE handle, DRV_SPI_TRANSFER_SETUP* setup )
{
    DRV_SPI_CLIENT_OBJ* clientObj = NULL;
    DRV_SPI_OBJ* dObj = (DRV_SPI_OBJ *)NULL;
    DRV_SPI_TRANSFER_SETUP setupRemap;
    bool isSuccess = false;

    /* Validate the handle */
    clientObj = _DRV_SPI_DriverHandleValidate(handle);

    if((clientObj != NULL) && (setup != NULL))
    {
        dObj = clientObj->dObj;

        setupRemap = *setup;

        setupRemap.clockPolarity = (DRV_SPI_CLOCK_POLARITY)dObj->remapClockPolarity[setup->clockPolarity];
        setupRemap.clockPhase = (DRV_SPI_CLOCK_PHASE)dObj->remapClockPhase[setup->clockPhase];
        setupRemap.dataBits = (DRV_SPI_DATA_BITS)dObj->remapDataBits[setup->dataBits];

        if ((setupRemap.clockPhase != DRV_SPI_CLOCK_PHASE_INVALID) && (setupRemap.clockPolarity != DRV_SPI_CLOCK_POLARITY_INVALID)
            && (setupRemap.dataBits != DRV_SPI_DATA_BITS_INVALID))
        {
            /* Save the required setup in client object which can be used while
             * processing queue requests.
             */
            clientObj->setup = setupRemap;
            clientObj->setupChanged = true;
            isSuccess = true;
        }
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
    bool isTransferInProgress = false;
    bool isSuccess = false;

    /* Validate the driver handle */
    clientObj = _DRV_SPI_DriverHandleValidate(handle);

    if((clientObj != NULL) && (((txSize > 0) && (pTransmitData != NULL)) ||
        ((rxSize > 0) && (pReceiveData != NULL)))
    )
    {
        dObj = clientObj->dObj;

        /* Block other clients/threads from accessing the PLIB */
        if (OSAL_MUTEX_Lock(&dObj->transferMutex, OSAL_WAIT_FOREVER ) == OSAL_RESULT_TRUE)
        {
            /* Update the PLIB Setup if current request is from a different client or
            setup has been changed dynamically for the client */
            if ((dObj->activeClient != (uintptr_t)clientObj) || (clientObj->setupChanged == true))
            {
                dObj->spiPlib->setup(&clientObj->setup, _USE_FREQ_CONFIGURED_IN_CLOCK_MANAGER);
                clientObj->setupChanged = false;
            }

            if(clientObj->setup.chipSelect != SYS_PORT_PIN_NONE)
            {
                /* Assert Chip Select if it is defined by user */
                SYS_PORT_PinWrite(clientObj->setup.chipSelect, (bool)(clientObj->setup.csPolarity));
            }

            /* Active client allows de-asserting the chip select line in ISR routine */
            dObj->activeClient = (uintptr_t)clientObj;

            if((dObj->txDMAChannel != SYS_DMA_CHANNEL_NONE) && ((dObj->rxDMAChannel != SYS_DMA_CHANNEL_NONE)))
            {
                dObj->pReceiveData = pReceiveData;
                dObj->pTransmitData = pTransmitData;

                if (_DRV_SPI_StartDMATransfer(dObj, pTransmitData, txSize, pReceiveData, rxSize) == true)
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

            if (isTransferInProgress == true)
            {
                /* Wait till transfer completes. This semaphore is released from the ISR */
                if (OSAL_SEM_Pend( &dObj->transferDone, OSAL_WAIT_FOREVER ) == OSAL_RESULT_TRUE)
                {
                    if (dObj->transferStatus == DRV_SPI_TRANSFER_STATUS_COMPLETE)
                    {
                        isSuccess = true;
                    }
                }
            }

            /* Release the mutex to allow other clients/threads to access the PLIB */
            OSAL_MUTEX_Unlock(&dObj->transferMutex);
        }
    }
    return isSuccess;
}