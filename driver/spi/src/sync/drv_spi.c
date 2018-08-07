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
Copyright (c) 2018 released Microchip Technology Inc.  All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute Software
only when embedded on a Microchip microcontroller or digital  signal  controller
that is integrated into your product or third party  product  (pursuant  to  the
sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED AS IS  WITHOUT  WARRANTY  OF  ANY  KIND,
EITHER EXPRESS  OR  IMPLIED,  INCLUDING  WITHOUT  LIMITATION,  ANY  WARRANTY  OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A  PARTICULAR  PURPOSE.
IN NO EVENT SHALL MICROCHIP OR  ITS  LICENSORS  BE  LIABLE  OR  OBLIGATED  UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION,  BREACH  OF  WARRANTY,  OR
OTHER LEGAL  EQUITABLE  THEORY  ANY  DIRECT  OR  INDIRECT  DAMAGES  OR  EXPENSES
INCLUDING BUT NOT LIMITED TO ANY  INCIDENTAL,  SPECIAL,  INDIRECT,  PUNITIVE  OR
CONSEQUENTIAL DAMAGES, LOST  PROFITS  OR  LOST  DATA,  COST  OF  PROCUREMENT  OF
SUBSTITUTE  GOODS,  TECHNOLOGY,  SERVICES,  OR  ANY  CLAIMS  BY  THIRD   PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE  THEREOF),  OR  OTHER  SIMILAR  COSTS.
*******************************************************************************/
//DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
#include "configuration.h"
//#include "system/debug/sys_debug.h"
#include "driver/spi/drv_spi.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data
// *****************************************************************************
// *****************************************************************************

/* This is the driver instance object array. */
DRV_SPI_OBJ gDrvSPIObj[DRV_SPI_INSTANCES_NUMBER] ;

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

static void _DRV_SPI_ConfigureDMA(DMA_CHANNEL dmaChannel, DRV_SPI_CONFIG_DMA cfgDMA)
{
    uint32_t config;

    config = _DRV_SPI_DMAChannelSettingsGet(dmaChannel);

    switch(cfgDMA)
    {
        case DRV_SPI_CONFIG_DMA_TX_DUMMY_DATA_XFER:
            /* Source address (SAM) is fixed*/
            config &= ~(0x03U << 16);
            break;
        case DRV_SPI_CONFIG_DMA_TX_BUFFER_DATA_XFER:
            /* Source address (SAM) is incremented */
            config &= ~(0x03U << 16);
            config |= (0x01U << 16);
            break;
        case DRV_SPI_CONFIG_DMA_RX_DUMMY_DATA_XFER:
            /* Destination address (DAM) is fixed */
            config &= ~(0x03U << 18);
            break;
        case DRV_SPI_CONFIG_DMA_RX_BUFFER_DATA_XFER:
            /* Destination address (DAM) is incremented */
            config &= ~(0x03U << 18);
            config |= (0x01U << 18);
            break;
        default:
            break;
    }

    _DRV_SPI_DMAChannelSettingsSet(dmaChannel, (XDMAC_CHANNEL_CONFIG)config);
}

static void _DRV_SPI_ConfigureDmaDataWidth(DMA_CHANNEL dmaChannel, DRV_SPI_DMA_WIDTH DmaWidth)
{
    uint32_t config;

    config = _DRV_SPI_DMAChannelSettingsGet(dmaChannel);
    config &= ~(0x03U << 11);
    config |= (DmaWidth << 11);

    _DRV_SPI_DMAChannelSettingsSet(dmaChannel, (XDMAC_CHANNEL_CONFIG)config);
}

static bool _DRV_SPI_StartDMATransfer(
    DRV_SPI_OBJ* hDriver,
    void* pTransmitData,
    size_t txSize,
    void* pReceiveData,
    size_t rxSize
)
{
    uint32_t temp;
    /* To avoid build error when DMA mode is not used */
    (void)temp;

    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)hDriver->activeClient;

    hDriver->txDummyDataSize = 0;
    hDriver->rxDummyDataSize = 0;
    hDriver->pNextTransmitData = (uintptr_t)NULL;

    if(clientObj->setup.dataBits == DRV_SPI_DATA_BITS_8_BIT)
    {
        _DRV_SPI_ConfigureDmaDataWidth(hDriver->rxDMAChannel, DRV_SPI_DMA_WIDTH_8_BIT);
        _DRV_SPI_ConfigureDmaDataWidth(hDriver->txDMAChannel, DRV_SPI_DMA_WIDTH_8_BIT);
    }
    else
    {
        /* If its DMA mode and SPI data bits is other than 8 bit, then divide transmit and receive sizes by 2 */
        rxSize = rxSize >> 1;
        txSize = txSize >> 1;

        _DRV_SPI_ConfigureDmaDataWidth(hDriver->rxDMAChannel, DRV_SPI_DMA_WIDTH_16_BIT);
        _DRV_SPI_ConfigureDmaDataWidth(hDriver->txDMAChannel, DRV_SPI_DMA_WIDTH_16_BIT);
    }

    if (rxSize >= txSize)
    {
        /* Dummy data will be sent by the TX DMA */
        hDriver->txDummyDataSize = (rxSize - txSize);
    }
    else
    {
        /* Dummy data will be received by the RX DMA */
        hDriver->rxDummyDataSize = (txSize - rxSize);
    }

    if (rxSize == 0)
    {
        /* Configure the RX DMA channel - to receive dummy data */
        _DRV_SPI_ConfigureDMA(hDriver->rxDMAChannel, DRV_SPI_CONFIG_DMA_RX_DUMMY_DATA_XFER);
        temp = hDriver->rxDummyDataSize;
        hDriver->rxDummyDataSize = 0;
        SYS_DMA_ChannelTransfer(hDriver->rxDMAChannel, (const void*)hDriver->rxAddress, (const void *)&hDriver->rxDummyData, temp);
    }
    else
    {
        /* Configure the RX DMA channel - to receive data in receive buffer */
        _DRV_SPI_ConfigureDMA(hDriver->rxDMAChannel, DRV_SPI_CONFIG_DMA_RX_BUFFER_DATA_XFER);
        SYS_DMA_ChannelTransfer(hDriver->rxDMAChannel, (const void*)hDriver->rxAddress, (const void *)pReceiveData, rxSize);
    }

    if (txSize == 0)
    {
        /* Configure the TX DMA channel - to send dummy data */
        _DRV_SPI_ConfigureDMA(hDriver->txDMAChannel, DRV_SPI_CONFIG_DMA_TX_DUMMY_DATA_XFER);
        temp = hDriver->txDummyDataSize;
        hDriver->txDummyDataSize = 0;
        SYS_DMA_ChannelTransfer(hDriver->txDMAChannel, (const void *)&hDriver->txDummyData, (const void*)hDriver->txAddress, temp);
    }
    else
    {
        /* Configure the transmit DMA channel - to send data from transmit buffer */
        _DRV_SPI_ConfigureDMA(hDriver->txDMAChannel, DRV_SPI_CONFIG_DMA_TX_BUFFER_DATA_XFER);

        /* The DMA transfer is split into two for the case where
         * rxSize > 0 && rxSize < txSize
         */
        if (hDriver->rxDummyDataSize > 0)
        {
            hDriver->pNextTransmitData = (uintptr_t)&((uint8_t*)pTransmitData)[rxSize];
            SYS_DMA_ChannelTransfer(hDriver->txDMAChannel, (const void *)pTransmitData, (const void*)hDriver->txAddress, rxSize);
        }
        else
        {
            SYS_DMA_ChannelTransfer(hDriver->txDMAChannel, (const void *)pTransmitData, (const void*)hDriver->txAddress, txSize);
        }
    }

    return true;
}

static void _DRV_SPI_PlibCallbackHandler(uintptr_t contextHandle)
{
    DRV_SPI_OBJ* dObj = (DRV_SPI_OBJ *)contextHandle;
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)NULL;
    DRV_SPI_ERROR error;

    error = dObj->spiPlib->errorGet();

    clientObj = (DRV_SPI_CLIENT_OBJ*)dObj->activeClient;

    if(clientObj->setup.chipSelect != SYS_PORT_PIN_NONE)
    {
        /* De-assert Chip Select if it is defined by user */
        SYS_PORT_PinWrite(clientObj->setup.chipSelect, !((bool)(clientObj->setup.csPolarity)));
    }

    if (error == DRV_SPI_ERROR_NONE)
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

void _DRV_SPI_TX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{
    DRV_SPI_OBJ* dObj = (DRV_SPI_OBJ *)context;

    if (dObj->txDummyDataSize > 0)
    {
        /* Configure DMA channel to transmit (dummy data) from the same location
         * (Source address not incremented)
        */
        _DRV_SPI_ConfigureDMA(dObj->txDMAChannel, DRV_SPI_CONFIG_DMA_TX_DUMMY_DATA_XFER);

        /* Configure the transmit DMA channel */
        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)&dObj->txDummyData, (const void*)dObj->txAddress, dObj->txDummyDataSize);

        dObj->txDummyDataSize = 0;
    }
}

void _DRV_SPI_RX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{
    DRV_SPI_OBJ* dObj = (DRV_SPI_OBJ *)context;
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)NULL;

    if (dObj->rxDummyDataSize > 0)
    {
        /* Configure DMA to receive dummy data */
        _DRV_SPI_ConfigureDMA(dObj->rxDMAChannel, DRV_SPI_CONFIG_DMA_RX_DUMMY_DATA_XFER);

        SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)&dObj->rxDummyData, dObj->rxDummyDataSize);

        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)dObj->pNextTransmitData, (const void*)dObj->txAddress, dObj->rxDummyDataSize);

        dObj->rxDummyDataSize = 0;
    }
    else
    {
        clientObj = (DRV_SPI_CLIENT_OBJ*)dObj->activeClient;

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

// *****************************************************************************
/* Function:
    SYS_MODULE_OBJ DRV_SPI_Initialize
    (
        const SYS_MODULE_INDEX drvIndex,
        const SYS_MODULE_INIT * const init
    )

  Summary:
    Dynamic implementation of DRV_SPI_Initialize system interface function.

  Remarks:
    See drv_spi.h for usage information.
*/

SYS_MODULE_OBJ DRV_SPI_Initialize( const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT * const init )
{
    DRV_SPI_OBJ* dObj     = (DRV_SPI_OBJ *)NULL;
    DRV_SPI_INIT* spiInit = (DRV_SPI_INIT *)init;

    /* Validate the request */
    if(drvIndex >= DRV_SPI_INSTANCES_NUMBER)
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Invalid driver instance");
        return SYS_MODULE_OBJ_INVALID;
    }

    if(gDrvSPIObj[drvIndex].inUse == true)
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Instance already in use");
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
    dObj->txDummyData           = 0xFFFFFFFF;

    dObj->baudRateInHz          = spiInit->baudRateInHz;
    dObj->clockPhase            = spiInit->clockPhase;
    dObj->clockPolarity         = spiInit->clockPolarity;
    dObj->dataBits              = spiInit->dataBits;

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

    if((dObj->txDMAChannel != DMA_CHANNEL_NONE) && (dObj->rxDMAChannel != DMA_CHANNEL_NONE))
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

// *****************************************************************************
/* Function:
    SYS_STATUS DRV_SPI_Status( SYS_MODULE_OBJ object )

  Summary:
    Dynamic implementation of DRV_SPI_Status system interface function.

  Remarks:
    See drv_spi.h for usage information.
*/

SYS_STATUS DRV_SPI_Status( SYS_MODULE_OBJ object)
{
    /* Validate the request */
    if( (object == SYS_MODULE_OBJ_INVALID) || (object >= DRV_SPI_INSTANCES_NUMBER) )
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Invalid system object handle");
        return SYS_STATUS_UNINITIALIZED;
    }

    return (gDrvSPIObj[object].status);
}

// *****************************************************************************
/* Function:
    DRV_HANDLE DRV_SPI_Open( const SYS_MODULE_INDEX index,
                             const DRV_IO_INTENT    ioIntent )

  Summary:
    Dynamic implementation of DRV_SPI_Open client interface function.

  Remarks:
    See drv_spi.h for usage information.
*/

DRV_HANDLE DRV_SPI_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    DRV_SPI_CLIENT_OBJ* clientObj = NULL;
    DRV_SPI_OBJ* dObj = NULL;
    uint8_t iClient;

    /* Validate the request */
    if (drvIndex >= DRV_SPI_INSTANCES_NUMBER)
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Invalid Driver Instance");
        return DRV_HANDLE_INVALID;
    }

    dObj = &gDrvSPIObj[drvIndex];

    if(dObj->status != SYS_STATUS_READY)
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Was the driver initialized?");
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

            clientObj->hDriver = dObj;

            clientObj->ioIntent = ioIntent;
            clientObj->setup.baudRateInHz   = dObj->baudRateInHz;
            clientObj->setup.clockPhase     = dObj->clockPhase;
            clientObj->setup.clockPolarity  = dObj->clockPolarity;
            clientObj->setup.dataBits       = dObj->dataBits;
            clientObj->setup.chipSelect     = SYS_PORT_PIN_NONE;
            clientObj->setupChanged = true;

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

// *****************************************************************************
/* Function:
    void DRV_SPI_Close ( DRV_HANDLE handle)

  Summary:
    Dynamic implementation of DRV_SPI_Close client interface function.

  Remarks:
    See drv_spi.h for usage information.
*/

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
        dObj = (DRV_SPI_OBJ *)clientObj->hDriver;

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

// *****************************************************************************
/* Function:
    bool DRV_SPI_TransferSetup
    (
        const DRV_HANDLE handle,
        DRV_SPI_TRANSFER_SETUP * setup
    )

  Summary:
    Setup the driver for a client.

  Remarks:
    See drv_spi.h for usage information.
*/
bool DRV_SPI_TransferSetup( const DRV_HANDLE handle, DRV_SPI_TRANSFER_SETUP* setup )
{
    DRV_SPI_CLIENT_OBJ* clientObj = NULL;
    bool isSuccess = false;

    /* Validate the handle */
    clientObj = _DRV_SPI_DriverHandleValidate(handle);

    if((clientObj != NULL) && (setup != NULL))
    {
        /* Save the required setup in client object which can be used while
         * processing queue requests.
        */
        clientObj->setup = *setup;
        clientObj->setupChanged = true;
        isSuccess = true;
    }
    return isSuccess;
}

// *****************************************************************************
// *****************************************************************************
// Section: SPI Driver Transfer Interface Implementation
// *****************************************************************************
// *****************************************************************************
// *****************************************************************************
bool DRV_SPI_WriteTransfer(const DRV_HANDLE handle, void* pTransmitData,  size_t txSize )
{
    return DRV_SPI_WriteReadTransfer(handle, pTransmitData, txSize, NULL, 0);
}

bool DRV_SPI_ReadTransfer(const DRV_HANDLE handle, void* pReceiveData,  size_t rxSize )
{
    return DRV_SPI_WriteReadTransfer(handle, NULL, 0, pReceiveData, rxSize);
}

// *****************************************************************************
/* Function:
    bool DRV_SPI_WriteReadTransfer
    (
    const DRV_HANDLE handle,
    void* pTransmitData,
    size_t txSize,
    void* pReceiveData,
    size_t rxSize
    )

  Summary:
    Dynamic implementation of DRV_SPI_WriteReadTransfer system interface function.

  Remarks:
    See drv_spi.h for usage information.
*/

bool DRV_SPI_WriteReadTransfer(const DRV_HANDLE handle,
    void* pTransmitData,
    size_t txSize,
    void* pReceiveData,
    size_t rxSize
)
{
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)NULL;
    DRV_SPI_OBJ* hDriver = (DRV_SPI_OBJ *)NULL;
    bool isTransferInProgress = false;
    bool isSuccess = false;

    /* Validate the driver handle */
    clientObj = _DRV_SPI_DriverHandleValidate(handle);

    if((clientObj != NULL) && (((txSize > 0) && (pTransmitData != NULL)) || \
        ((rxSize > 0) && (pReceiveData != NULL)))
    )
    {
        hDriver = clientObj->hDriver;

        /* Block other clients/threads from accessing the PLIB */
        if (OSAL_MUTEX_Lock(&hDriver->transferMutex, OSAL_WAIT_FOREVER ) == OSAL_RESULT_TRUE)
        {
            /* Update the PLIB Setup if current request is from a different client or
            setup has been changed dynamically for the client */
            if ((hDriver->activeClient != (uintptr_t)clientObj) || (clientObj->setupChanged == true))
            {
                hDriver->spiPlib->setup(&clientObj->setup, _USE_FREQ_CONFIGURED_IN_CLOCK_MANAGER);
                clientObj->setupChanged = false;
            }

            if(clientObj->setup.chipSelect != SYS_PORT_PIN_NONE)
            {
                /* Assert Chip Select if it is defined by user */
                SYS_PORT_PinWrite(clientObj->setup.chipSelect, (bool)(clientObj->setup.csPolarity));
            }

            /* Active client allows de-asserting the chip select line in ISR routine */
            hDriver->activeClient = (uintptr_t)clientObj;

            if((hDriver->txDMAChannel != DMA_CHANNEL_NONE) && ((hDriver->rxDMAChannel != DMA_CHANNEL_NONE)))
            {
                if (_DRV_SPI_StartDMATransfer(hDriver, pTransmitData, txSize, pReceiveData, rxSize) == true)
                {
                    isTransferInProgress = true;
                }
            }
            else
            {
                if (hDriver->spiPlib->writeRead(pTransmitData, txSize, pReceiveData, rxSize) == true)
                {
                    isTransferInProgress = true;
                }
            }

            if (isTransferInProgress == true)
            {
                /* Wait till transfer completes. This semaphore is released from the ISR */
                if (OSAL_SEM_Pend( &hDriver->transferDone, OSAL_WAIT_FOREVER ) == OSAL_RESULT_TRUE)
                {
                    if (hDriver->transferStatus == DRV_SPI_TRANSFER_STATUS_COMPLETE)
                    {
                        isSuccess = true;
                    }
                }
            }
            /* Release the mutex to allow other clients/threads to access the PLIB */
            OSAL_MUTEX_Unlock(&hDriver->transferMutex);
        }
    }
    return isSuccess;
}
/*******************************************************************************
 End of File
*/