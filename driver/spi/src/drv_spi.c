/*******************************************************************************
  SPI Driver Implementation.

  Company:
    Microchip Technology Inc.

  File Name:
    drv_spi.c

  Summary:
    Source code for the SPI driver implementation.

  Description:
    This file contains the source code for the implementation of the SPI driver.
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
#include "driver/spi/drv_spi.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data
// *****************************************************************************
// *****************************************************************************

/* This is the driver instance object array. */
DRV_SPI_OBJ gDrvSPIObj[DRV_SPI_INSTANCES_NUMBER] ;

/* This a global token counter used to generate unique buffer handles */
static uint16_t gDrvSPITokenCount = 0;

// *****************************************************************************
// *****************************************************************************
// Section: File scope functions
// *****************************************************************************
// *****************************************************************************
static void _DRV_SPI_TX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context);
static void _DRV_SPI_RX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context);

static bool _DRV_SPI_ResourceLock(DRV_SPI_OBJ * dObj)
{
    bool interruptWasEnabled;
    
    /* Disable SPI or DMA interrupt so that the driver resource
     * is not updated asynchronously. */
    if((dObj->txDMAChannel != DMA_CHANNEL_NONE) && (dObj->rxDMAChannel != DMA_CHANNEL_NONE))
    {
        interruptWasEnabled = SYS_INT_SourceDisable(dObj->interruptDMA);
    }
    else
    {
        interruptWasEnabled = SYS_INT_SourceDisable(dObj->interruptSPI);
    }
    
    return interruptWasEnabled;
}

static void _DRV_SPI_ResourceUnlock(DRV_SPI_OBJ * dObj, bool interruptWasEnabled)
{
    /* Restore the interrupt if it was enabled */
    if(interruptWasEnabled == true)
    {
        if((dObj->txDMAChannel != DMA_CHANNEL_NONE) && (dObj->rxDMAChannel != DMA_CHANNEL_NONE))
        {
            SYS_INT_SourceEnable(dObj->interruptDMA);
        }
        else
        {
            SYS_INT_SourceEnable(dObj->interruptSPI);
        }
    }
}

static DRV_SPI_CLIENT_OBJ * _DRV_SPI_DriverHandleValidate(DRV_HANDLE handle)
{
    /* This function returns the pointer to the client object that is
       associated with this handle if the handle is valid. Returns NULL
       otherwise. */

    DRV_SPI_CLIENT_OBJ * clientObj;

    if((handle == DRV_HANDLE_INVALID) || (handle == 0))
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Invalid Driver Handle");
        return(NULL);
    }

    clientObj = (DRV_SPI_CLIENT_OBJ *)handle;

    if(!clientObj->inUse)
    {
        return(NULL);
    }

    return(clientObj);
}

static void _DRV_SPI_TransferQueueFlush( DRV_SPI_CLIENT_OBJ * clientObj )
{
    DRV_SPI_OBJ * dObj = clientObj->hDriver;
    bool interruptWasEnabled = false;
    uint8_t currentIndex = NULL_INDEX;
    uint8_t previousIndex = NULL_INDEX;
    uint8_t savedNextIndex = NULL_INDEX;
    
    /* Disable the interrupt to safeguard queue, enable it back when queue operations are done */
    interruptWasEnabled =  _DRV_SPI_ResourceLock(dObj);
    
    dObj->queueTailIndex = NULL_INDEX;
    currentIndex = dObj->queueHeadIndex;
    while(currentIndex != NULL_INDEX)
    {
        
        savedNextIndex = dObj->transferArray[currentIndex].nextIndex;
        if(clientObj == (DRV_SPI_CLIENT_OBJ *)dObj->transferArray[currentIndex].hClient)
        {
            /* That means this transfer object is owned
               by this client. This transfer object should
               be removed. The following code removes
               the object from a linked list queue. */
            
            if (previousIndex == NULL_INDEX)
            {
                dObj->queueHeadIndex = dObj->transferArray[currentIndex].nextIndex;
            }
            else
            {
                dObj->transferArray[previousIndex].nextIndex = dObj->transferArray[currentIndex].nextIndex;
            }
            
            /* Now put the freed object into the free pool */
            dObj->transferArray[currentIndex].nextIndex = dObj->freePoolHeadIndex;
            dObj->freePoolHeadIndex = currentIndex;
        }
        else
        {
            dObj->queueTailIndex = currentIndex;
            previousIndex = currentIndex;
        }
        currentIndex = savedNextIndex;
    }

    /* Enable back the interrupt if it was enabled earlier */
    _DRV_SPI_ResourceUnlock(dObj, interruptWasEnabled);
}

static void _DRV_SPI_ConfigureDMA(DMA_CHANNEL dmaChannel, DRV_SPI_CONFIG_DMA cfgDMA)
{    
    uint32_t config;
    
    config = XDMAC_ChannelSettingsGet(dmaChannel);
    
    switch(cfgDMA)
    {
        case DRV_SPI_CONFIG_DMA_TX_DUMMY_DATA_XFER:
        {
            /* Source address (SAM) is fixed*/
            config &= ~(0x03U << 16);
            break;
        }
        case DRV_SPI_CONFIG_DMA_TX_BUFFER_DATA_XFER:
        {
            /* Source address (SAM) is incremented */
            config &= ~(0x03U << 16);
            config |= (0x01U << 16);
            break;
        }
        case DRV_SPI_CONFIG_DMA_RX_DUMMY_DATA_XFER:
        {
            /* Destination address (DAM) is fixed */
            config &= ~(0x03U << 18);
            break;
        }
        case DRV_SPI_CONFIG_DMA_RX_BUFFER_DATA_XFER:
        {
            /* Destination address (DAM) is incremented */
            config &= ~(0x03U << 18);
            config |= (0x01U << 18);
            break;
        }
        default:            
            break;
    }
    
    XDMAC_ChannelSettingsSet(dmaChannel, (XDMAC_CHANNEL_CONFIG)config);
}

static void _DRV_SPI_StartDMATransfer(DRV_SPI_TRANSFER_OBJ    *transferObj)
{ 
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)transferObj->hClient;
    DRV_SPI_OBJ *hDriver = (DRV_SPI_OBJ *)clientObj->hDriver;
    
    hDriver->txDummyDataSize = 0;
    hDriver->rxDummyDataSize = 0;                                    

    if (transferObj->rxSize >= transferObj->txSize)
    {                                
        /* Dummy data will be sent by the TX DMA */
        hDriver->txDummyDataSize = (transferObj->rxSize - transferObj->txSize);                  
    }   
    else
    {
        /* Dummy data will be received by the RX DMA */
        hDriver->rxDummyDataSize = (transferObj->txSize - transferObj->rxSize);
    }
    
    /* Register callbacks for DMA */ 
    SYS_DMA_ChannelCallbackRegister(hDriver->txDMAChannel, _DRV_SPI_TX_DMA_CallbackHandler, (uintptr_t)transferObj);       
    SYS_DMA_ChannelCallbackRegister(hDriver->rxDMAChannel, _DRV_SPI_RX_DMA_CallbackHandler, (uintptr_t)transferObj);
    
    if (transferObj->rxSize == 0)
    {
        /* Configure the RX DMA channel - to receive dummy data */
        _DRV_SPI_ConfigureDMA(hDriver->rxDMAChannel, DRV_SPI_CONFIG_DMA_RX_DUMMY_DATA_XFER);                    
        SYS_DMA_ChannelTransfer(hDriver->rxDMAChannel, (const void*)hDriver->rxAddress, (const void *)&hDriver->rxDummyData, hDriver->rxDummyDataSize);
        hDriver->rxDummyDataSize = 0;
    }               
    else
    {
        /* Configure the RX DMA channel - to receive data in receive buffer */
        _DRV_SPI_ConfigureDMA(hDriver->rxDMAChannel, DRV_SPI_CONFIG_DMA_RX_BUFFER_DATA_XFER);                    
        SYS_DMA_ChannelTransfer(hDriver->rxDMAChannel, (const void*)hDriver->rxAddress, (const void *)transferObj->pReceiveData, transferObj->rxSize);                
    }

    if (transferObj->txSize == 0)
    {
        /* Configure the TX DMA channel - to send dummy data */
        _DRV_SPI_ConfigureDMA(hDriver->txDMAChannel, DRV_SPI_CONFIG_DMA_TX_DUMMY_DATA_XFER);                    
        SYS_DMA_ChannelTransfer(hDriver->txDMAChannel, (const void *)&hDriver->txDummyData, (const void*)hDriver->txAddress, hDriver->txDummyDataSize);                                                        
        hDriver->txDummyDataSize = 0;                
    }
    else
    {
        /* Configure the transmit DMA channel - to send data from transmit buffer */
        _DRV_SPI_ConfigureDMA(hDriver->txDMAChannel, DRV_SPI_CONFIG_DMA_TX_BUFFER_DATA_XFER);                    
        
        /* The DMA transfer is split into two for the case where rxSize > 0 && rxSize < txSize */
        if (hDriver->rxDummyDataSize > 0)
        {                    
            SYS_DMA_ChannelTransfer(hDriver->txDMAChannel, (const void *)transferObj->pTransmitData, (const void*)hDriver->txAddress, transferObj->rxSize);
        }
        else
        {
            SYS_DMA_ChannelTransfer(hDriver->txDMAChannel, (const void *)transferObj->pTransmitData, (const void*)hDriver->txAddress, transferObj->txSize);                                                        
        }                
    }
}

static void _DRV_SPI_ReleaseBufferObject(DRV_SPI_TRANSFER_OBJ    *transferObj)
{
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)transferObj->hClient;
    DRV_SPI_OBJ *dObj = (DRV_SPI_OBJ *)clientObj->hDriver;
    uint8_t     tempQueueHeadIndex = dObj->queueHeadIndex;
    
    /* Get the next buffer in the queue and deallocate this buffer */
    dObj->queueHeadIndex = transferObj->nextIndex;
    transferObj->nextIndex = dObj->freePoolHeadIndex;
    dObj->freePoolHeadIndex = tempQueueHeadIndex;   
}

static void _DRV_SPI_UpdateTransferSetupAndAssertCS(DRV_SPI_CLIENT_OBJ* clientObj)
{
    DRV_SPI_OBJ *dObj = (DRV_SPI_OBJ *)clientObj->hDriver;
    
    /* Update the PLIB Setup if current request is from a different client or 
    setup has been changed dynamically for the client */
    if((dObj->transferArray[dObj->freePoolHeadIndex].hClient != clientObj) || (clientObj->setupChanged == true))  
    {
        dObj->spiPlib->setup(&clientObj->setup, _USE_FREQ_CONFIGURED_IN_CLOCK_MANAGER);
        clientObj->setupChanged = false;
    }
    
    /* Assert chip select if configured */
    if(clientObj->setup.chipSelect != SYS_PORT_PIN_NONE)
    {
        SYS_PORT_PinWrite(clientObj->setup.chipSelect, (bool)(clientObj->setup.csPolarity)); 
    }
}
        
static void _DRV_SPI_PlibCallbackHandler(void* contextHandle)
{
    DRV_SPI_OBJ             *dObj             = (DRV_SPI_OBJ *)contextHandle;
    DRV_SPI_CLIENT_OBJ      *clientObj        = (DRV_SPI_CLIENT_OBJ *)NULL;
    DRV_SPI_TRANSFER_OBJ    *transferObj      = (DRV_SPI_TRANSFER_OBJ *)NULL;
    DRV_SPI_ERROR           errorStatus;
    
    if((!dObj->inUse) || (dObj->status != SYS_STATUS_READY))
    {
        /* This instance of the driver is not initialized. Don't
         * do anything */
        return;
    }
    
    transferObj = &dObj->transferArray[dObj->queueHeadIndex];
    clientObj = (DRV_SPI_CLIENT_OBJ *)transferObj->hClient;
    
    /* De-assert Chip Select if it is defined by user */
    if(clientObj->setup.chipSelect != SYS_PORT_PIN_NONE)
    { 
        SYS_PORT_PinWrite(clientObj->setup.chipSelect, !((bool)(clientObj->setup.csPolarity))); 
    }
       
    errorStatus = dObj->spiPlib->errorGet();
    
	if(errorStatus == DRV_SPI_ERROR_NONE)
	{
		transferObj->event = DRV_SPI_TRANSFER_EVENT_COMPLETE;
	}
	else
	{
		transferObj->event = DRV_SPI_TRANSFER_EVENT_ERROR;
	}
		
    if(clientObj->eventHandler != NULL)
    {   
        clientObj->eventHandler(transferObj->event, transferObj->transferHandle, clientObj->context);    
    }

    _DRV_SPI_ReleaseBufferObject(transferObj);

    /* Process the next transfer in queue */
    if(dObj->queueHeadIndex != NULL_INDEX)
    {
        transferObj = &dObj->transferArray[dObj->queueHeadIndex];
        clientObj = (DRV_SPI_CLIENT_OBJ *)transferObj->hClient;
        
        _DRV_SPI_UpdateTransferSetupAndAssertCS(clientObj);
        
        dObj->spiPlib->writeRead(transferObj->pTransmitData, transferObj->txSize, transferObj->pReceiveData, transferObj->rxSize);
    }
}

static void _DRV_SPI_TX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{
    DRV_SPI_TRANSFER_OBJ    *transferObj      = (DRV_SPI_TRANSFER_OBJ *)context;
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)transferObj->hClient;
    DRV_SPI_OBJ *dObj = (DRV_SPI_OBJ *)clientObj->hDriver;   
    
    if (dObj->txDummyDataSize > 0)        
    {    
        /* Configure DMA channel to transmit (dummy data) from the same location 
         * (Source address not incremented) */
        _DRV_SPI_ConfigureDMA(dObj->txDMAChannel, DRV_SPI_CONFIG_DMA_TX_DUMMY_DATA_XFER);

        /* Configure the transmit DMA channel */
        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)&dObj->txDummyData, (const void*)dObj->txAddress, dObj->txDummyDataSize);

        dObj->txDummyDataSize = 0;    
    }
}

static void _DRV_SPI_RX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{  
    DRV_SPI_TRANSFER_OBJ    *transferObj      = (DRV_SPI_TRANSFER_OBJ *)context;
    DRV_SPI_CLIENT_OBJ* clientObj = (DRV_SPI_CLIENT_OBJ *)transferObj->hClient;
    DRV_SPI_OBJ *dObj = (DRV_SPI_OBJ *)clientObj->hDriver;
    
    if (dObj->rxDummyDataSize > 0)
    {
        _DRV_SPI_ConfigureDMA(dObj->rxDMAChannel, DRV_SPI_CONFIG_DMA_RX_DUMMY_DATA_XFER);
        
        SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void*)dObj->rxAddress, (const void *)&dObj->rxDummyData, dObj->rxDummyDataSize);
        
        SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)&((uint8_t*)transferObj->pTransmitData)[transferObj->rxSize], (const void*)dObj->txAddress, dObj->rxDummyDataSize);                                                        
        
        dObj->rxDummyDataSize = 0;
    }
    else
    {                
        /* De-assert Chip Select if it is defined by user */
        if(clientObj->setup.chipSelect != SYS_PORT_PIN_NONE)
        { 
            SYS_PORT_PinWrite(clientObj->setup.chipSelect, !((bool)(clientObj->setup.csPolarity))); 
        }
        
        /* Set the events */
        if(event == SYS_DMA_TRANSFER_COMPLETE)
        {
            transferObj->event = DRV_SPI_TRANSFER_EVENT_COMPLETE;
        }
        else if(event == SYS_DMA_TRANSFER_ERROR)
        {
            transferObj->event = DRV_SPI_TRANSFER_EVENT_ERROR;
        }
        
        /* Call the event handler if it was registered with the driver */
        if(clientObj->eventHandler != NULL)
        {   
            clientObj->eventHandler(transferObj->event, transferObj->transferHandle, clientObj->context);    
        }
        
        _DRV_SPI_ReleaseBufferObject(transferObj);
        
        /* Process the next transfer in queue */
        if(dObj->queueHeadIndex != NULL_INDEX)
        {
            transferObj = &dObj->transferArray[dObj->queueHeadIndex];
            clientObj = (DRV_SPI_CLIENT_OBJ *)transferObj->hClient;
            _DRV_SPI_UpdateTransferSetupAndAssertCS(clientObj);
            _DRV_SPI_StartDMATransfer(transferObj);
        }   
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

  Remarks:
    See drv_spi.h for usage information.
*/

SYS_MODULE_OBJ DRV_SPI_Initialize( const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT * const init )
{
    DRV_SPI_OBJ *dObj     = (DRV_SPI_OBJ *)NULL;
    DRV_SPI_INIT *spiInit = (DRV_SPI_INIT *)init;
    size_t  freePoolIndex;
    
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
    dObj->inUse = true;
    
    /* Update the driver parameters */
    dObj->spiPlib               = spiInit->spiPlib;
    dObj->interruptSPI          = spiInit->interruptSPI;
    dObj->transferArray         =(DRV_SPI_TRANSFER_OBJ *)spiInit->transferObjPool;
    dObj->transferQueueSize     = spiInit->queueSize;
    dObj->freePoolHeadIndex     = 0;
    dObj->queueHeadIndex        = NULL_INDEX;
    dObj->queueTailIndex        = NULL_INDEX;
    dObj->clientObjPool         = spiInit->clientObjPool;
    dObj->nClientsMax           = spiInit->numClients;
    dObj->nClients              = 0;
    dObj->isExclusive           = false;
    dObj->txDMAChannel          = spiInit->dmaChannelTransmit;
    dObj->rxDMAChannel          = spiInit->dmaChannelReceive;
    dObj->txAddress             = spiInit->spiTransmitAddress;
    dObj->rxAddress             = spiInit->spiReceiveAddress;    
    dObj->txDummyData           = 0xFFFFFFFF; 
    
    /* initialize buffer free pool*/
    for(freePoolIndex=0; freePoolIndex < spiInit->queueSize-1; freePoolIndex++)
    {
        dObj->transferArray[freePoolIndex].nextIndex = freePoolIndex + 1;
    }
    dObj->transferArray[freePoolIndex].nextIndex = NULL_INDEX;
         
    if((dObj->txDMAChannel == DMA_CHANNEL_NONE) || (dObj->rxDMAChannel == DMA_CHANNEL_NONE))
    {                                
        /* Register a callback with SPI PLIB.
        * dObj as a context parameter will be used to distinguish the events 
        * from different instances. */
        dObj->spiPlib->callbackRegister(&_DRV_SPI_PlibCallbackHandler, (void*)dObj);
    }
    else
    {
        /* This means DMA has to be used for SPI transfer. 
        DMA Callbacks will be set for every transfer later. */
    }

    /* Update the status */
    dObj->status = SYS_STATUS_READY;

    /* Return the object structure */
    return ( (SYS_MODULE_OBJ)drvIndex );
}

// *****************************************************************************
/* Function:
    SYS_STATUS DRV_SPI_Status( SYS_MODULE_OBJ object )

  Remarks:
    See drv_spi.h for usage information.
*/

SYS_STATUS DRV_SPI_Status( SYS_MODULE_OBJ object)
{
    /* Validate the request */
    if((object == SYS_MODULE_OBJ_INVALID) || (object >= DRV_SPI_INSTANCES_NUMBER))
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Invalid system object handle");
        return SYS_STATUS_UNINITIALIZED;
    }
    
    return (gDrvSPIObj[object].status);
}

// *****************************************************************************
/* Function:
    DRV_HANDLE DRV_SPI_Open( const SYS_MODULE_INDEX drvIndex,
                             const DRV_IO_INTENT    ioIntent )

  Remarks:
    See drv_spi.h for usage information.
*/

DRV_HANDLE DRV_SPI_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    DRV_SPI_CLIENT_OBJ *clientObj;
    DRV_SPI_OBJ *dObj = NULL;
    unsigned int iClient;

    /* Validate the request */
    if (drvIndex >= DRV_SPI_INSTANCES_NUMBER)
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Invalid Driver Instance");
        return DRV_HANDLE_INVALID;
    }

    dObj = &gDrvSPIObj[drvIndex];

    if((dObj->status != SYS_STATUS_READY) || (dObj->inUse == false))
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Was the driver initialized?");
        return DRV_HANDLE_INVALID;
    }
    
    /* Take care of Exclusive mode intent of driver */
    if(dObj->isExclusive)
    {
        /* This means the another client has opened the driver in exclusive
           mode. So the driver cannot be opened by any other client. */
        return DRV_HANDLE_INVALID;
    }
    if((dObj->nClients > 0) && (ioIntent & DRV_IO_INTENT_EXCLUSIVE))
    {
        /* This means the driver was already opened and another driver was
           trying to open it exclusively.  We cannot give exclusive access in
           this case */
        return(DRV_HANDLE_INVALID);
    }

    for(iClient = 0; iClient != dObj->nClientsMax; iClient++)
    {
        clientObj = &((DRV_SPI_CLIENT_OBJ *)dObj->clientObjPool)[iClient];
        
        if(!clientObj->inUse)
        {
            /* This means we have a free client object to use */
            clientObj->inUse        = true;
            clientObj->hDriver      = dObj;

            /* This driver will always work on Non-Blocking mode */
            clientObj->ioIntent     = (ioIntent | DRV_IO_INTENT_NONBLOCKING);
            
            /* Initialize other elements in Client Object */
            clientObj->eventHandler = NULL;
            clientObj->context      = NULL;
            clientObj->setup.chipSelect = SYS_PORT_PIN_NONE;
            
            if(ioIntent & DRV_IO_INTENT_EXCLUSIVE)
            {
                /* Set the driver exclusive flag */
                dObj->isExclusive = true;
            }

            dObj->nClients ++;
            
            /* Update the client status */
            clientObj->status = DRV_SPI_CLIENT_STATUS_READY;
            return ((DRV_HANDLE) clientObj );
        }
    }

    /* If we have reached here, it means we could not find a spare client object */
    return DRV_HANDLE_INVALID;
}

// *****************************************************************************
/* Function:
    void DRV_SPI_Close ( DRV_HANDLE handle)

  Summary:
    Closes the driver.

  Description:
    This function closes the driver for the client which had "handle"
    associated with it. 

  Remarks:
    See drv_spi.h for usage information.
*/

void DRV_SPI_Close( DRV_HANDLE handle )
{
    /* This function closes the client, The client objects are
       deallocated and returned to the free pool. */

    DRV_SPI_CLIENT_OBJ * clientObj;
    DRV_SPI_OBJ * dObj;
    
    /* Validate the driver handle */
    clientObj = _DRV_SPI_DriverHandleValidate(handle);
    if(clientObj == NULL)
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Invalid Driver Handle");
        return;
    }
    
    dObj = (DRV_SPI_OBJ *)clientObj->hDriver;

    /* Remove all buffers that this client owns from the driver queue. */
    _DRV_SPI_TransferQueueFlush(clientObj);
  
    /* Reduce the number of clients */
    dObj->nClients--;

    /* Reset the exclusive flag */
    dObj->isExclusive = false;

    /* De-allocate the client object */
    clientObj->status = DRV_SPI_CLIENT_STATUS_CLOSED;
    clientObj->inUse = false;

    return;
}

// *****************************************************************************
/* Function:
    void DRV_SPI_TransferEventHandlerSet
    (
        const DRV_HANDLE handle,
        const DRV_SPI_TRANSFER_EVENT_HANDLER eventHandler,
        void* context
    )

  Summary:
    Registers transfer callback function.

  Description:
    This function is used to register the callback function to be invoked
    upon completion of a transfer request.

  Remarks:
    See drv_spi.h for usage information.
*/

void DRV_SPI_TransferEventHandlerSet( const DRV_HANDLE handle, const DRV_SPI_TRANSFER_EVENT_HANDLER eventHandler, void* context )
{
    DRV_SPI_CLIENT_OBJ * clientObj = NULL;

    /* Validate the driver handle */
    clientObj = _DRV_SPI_DriverHandleValidate(handle);
    if(clientObj == NULL)
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Invalid Driver Handle");
        return;
    }
    
    /* Save the event handler and context */
    clientObj->eventHandler = eventHandler;
    clientObj->context = context;
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

  Description:
    This function setup the driver for a client.

  Remarks:
    See drv_spi.h for usage information.
*/
bool DRV_SPI_TransferSetup( const DRV_HANDLE handle, DRV_SPI_TRANSFER_SETUP * setup )
{
    DRV_SPI_CLIENT_OBJ * clientObj = NULL;

    /* Validate the driver handle */
    clientObj = _DRV_SPI_DriverHandleValidate(handle);
    if(clientObj == NULL)
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Invalid Driver Handle");
        return false;
    }
    
    if(setup == NULL)
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Invalid input setup");
        return false;
    }
     
    /* Save the required setup in client object which can be used while
    processing queue requests. */
    clientObj->setup = *setup;
    
    /* Update the flag denoting that setup has been changed dynamically */
    clientObj->setupChanged = true;  
    
    return true;
}

// *****************************************************************************
// *****************************************************************************
// Section: SPI Driver Transfer Queue Interface Implementation
// *****************************************************************************
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    void DRV_SPI_WriteReadTransferAdd
    ( 
        const DRV_HANDLE handle,
        void*       pTransmitData,
		size_t      txSize,		
        void*       pReceiveData, 
        size_t      rxSize,
        DRV_SPI_TRANSFER_HANDLE * const transferHandle
    )

  Summary:
    Function to add WriteRead transfer request.

  Remarks:
    See drv_spi.h for usage information.
*/

void DRV_SPI_WriteReadTransferAdd
(
    const DRV_HANDLE handle,
    void*       pTransmitData,
    size_t      txSize,		
    void*       pReceiveData, 
    size_t      rxSize,
    DRV_SPI_TRANSFER_HANDLE * const transferHandle
)

{
    DRV_SPI_CLIENT_OBJ          * clientObj         = (DRV_SPI_CLIENT_OBJ *)NULL;
    DRV_SPI_OBJ                 * hDriver           = (DRV_SPI_OBJ *)NULL;
    DRV_SPI_TRANSFER_OBJ        * transferObj       = (DRV_SPI_TRANSFER_OBJ *)NULL;
    bool                        interruptWasEnabled = false;
    uint8_t                     nextFreePoolHeadIndex;
    
    *transferHandle = DRV_SPI_TRANSFER_HANDLE_INVALID;
    
    /* Validate the driver handle */
    clientObj = _DRV_SPI_DriverHandleValidate(handle);
    if((clientObj != NULL) && (transferHandle != NULL) && (((txSize > 0) && (pTransmitData != NULL)) || ((rxSize > 0) && (pReceiveData != NULL))))
    {
   
        hDriver = clientObj->hDriver; 
        if(hDriver->freePoolHeadIndex == NULL_INDEX)
        {
            /* This means we could not find a buffer. This
               will happen if the the transfer queue size
               parameter is configured to be less */

            SYS_ASSERT(false, "Insufficient Queue Depth");
            return;
        }

        /* Disable the interrupt to safeguard queue, enable it back when queue operations are done */
        interruptWasEnabled =  _DRV_SPI_ResourceLock(hDriver);
        
        /* Allocate a free object from the free pool */
        transferObj = &hDriver->transferArray[hDriver->freePoolHeadIndex];
        
        /* Save the next free pool head index */
        nextFreePoolHeadIndex = hDriver->transferArray[hDriver->freePoolHeadIndex].nextIndex;
        
        /* Configure the object */   
        transferObj->pReceiveData   = pReceiveData;
        transferObj->pTransmitData  = pTransmitData;
        transferObj->txSize         = txSize;
        transferObj->rxSize         = rxSize;
        transferObj->event          = DRV_SPI_TRANSFER_EVENT_PENDING;
        transferObj->nextIndex      = NULL_INDEX;
        
        /* Update transferHandle object with unique ID.
        ID is combination of an incrementing token and allocated location from the free pool */
        transferObj->transferHandle = (gDrvSPITokenCount << 16) | hDriver->freePoolHeadIndex;

        /* Update the Token for next time */
        gDrvSPITokenCount++;
        if (gDrvSPITokenCount >= _DRV_SPI_TRANSFER_TOKEN_MAX)
        {
            gDrvSPITokenCount = 0;
        }
        
        /* Update the unique transfer handle in output parameter. 
        This handle can be used by user to poll the status of transfer operation */
        *transferHandle = transferObj->transferHandle;
            
        if(hDriver->queueHeadIndex == NULL_INDEX)
        {
            /* It means this is the first buffer in the queue */
            
            /* Since this is the only buffer in the queue, queue head and queue tail should point to the same location */
            hDriver->queueHeadIndex = hDriver->freePoolHeadIndex;
            hDriver->queueTailIndex = hDriver->freePoolHeadIndex;

            _DRV_SPI_UpdateTransferSetupAndAssertCS(clientObj);
                
            /* Update free pool head pointer to point to next free element in the free pool */
            hDriver->freePoolHeadIndex = nextFreePoolHeadIndex;
            
            /* Save clientObj */
            transferObj->hClient = clientObj;
            
            /* Because this is the first request in the queue, we need to trigger the transfer either
            with DMA or PLIB based on MHC configuration */
            if((hDriver->txDMAChannel != DMA_CHANNEL_NONE) && (hDriver->rxDMAChannel != DMA_CHANNEL_NONE))
            {                                     
                _DRV_SPI_StartDMATransfer(transferObj);
            }
            else
            {
                hDriver->spiPlib->writeRead(transferObj->pTransmitData, transferObj->txSize, transferObj->pReceiveData, transferObj->rxSize);
            }            
        }
        else
        {
            /* It means there are already one or more buffer in the queue */
            
            /* take the free object from free pool, add in the queue and update the queue linked list */
            hDriver->transferArray[hDriver->queueTailIndex].nextIndex = hDriver->freePoolHeadIndex;
            hDriver->queueTailIndex = hDriver->freePoolHeadIndex;
            
            /* Update free pool head pointer to point to next free element in the free pool */
            hDriver->freePoolHeadIndex = nextFreePoolHeadIndex;
            
            /* Save clientObj */
            transferObj->hClient = clientObj;
        }
        
        /* Enable back the interrupt if it was enabled earlier */
        _DRV_SPI_ResourceUnlock(hDriver, interruptWasEnabled);
    }
    return;  
}

// *****************************************************************************
/* Function:
    DRV_SPI_TRANSFER_EVENT DRV_SPI_TransferStatusGet
    (
        const DRV_HANDLE handle,
        const DRV_SPI_TRANSFER_HANDLE transferHandle
    )

  Summary:
    Function to poll transfer status.

  Remarks:
    See drv_spi.h for usage information.
*/

DRV_SPI_TRANSFER_EVENT DRV_SPI_TransferStatusGet( const DRV_HANDLE handle, const DRV_SPI_TRANSFER_HANDLE transferHandle )
{
    DRV_SPI_OBJ          * dObj        = NULL;
    DRV_SPI_CLIENT_OBJ   * clientObj   = NULL;
    uint16_t             transferIndex;
    
    /* Validate the driver handle */
    clientObj = _DRV_SPI_DriverHandleValidate(handle);
    if(clientObj == NULL)
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Invalid Transfer Handle");
        return DRV_SPI_HANDLE_INVALID;
    }
    
    dObj = clientObj->hDriver;
    
    /* transferHandle has transferIndex and token both, mask out transferIndex */
    transferIndex = transferHandle & _DRV_SPI_TRANSFER_INDEX_MASK;
    
    /* Validate the transferIndex and corresponding request */
    if(transferIndex >= dObj->transferQueueSize)
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Transfer Handle Invalid");
        return DRV_SPI_TRANSFER_HANDLE_INVALID_OR_EXPIRED;
    }
    else if(transferHandle != dObj->transferArray[transferIndex].transferHandle)
    {
        SYS_DEBUG(SYS_ERROR_ERROR, "Transfer Handle Expired");
        return DRV_SPI_TRANSFER_HANDLE_INVALID_OR_EXPIRED;
    }
    else
    {
        return dObj->transferArray[transferIndex].event;
    }    
}

/*******************************************************************************
 End of File
*/