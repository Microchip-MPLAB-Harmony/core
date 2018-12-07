/*******************************************************************************
  USART Driver Implementation.

  Company:
    Microchip Technology Inc.

  File Name:
    drv_usart.c

  Summary:
    Source code for the USART driver dynamic implementation.

  Description:
    This file contains the source code for the dynamic implementation of the
    USART driver.
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

#include "configuration.h"
#include "driver/usart/drv_usart.h"
#include "drv_usart_local.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data
// *****************************************************************************
// *****************************************************************************

/* This is the driver instance object array. */
static DRV_USART_OBJ gDrvUSARTObj[DRV_USART_INSTANCES_NUMBER] ;

/* This is the array of USART Driver Buffet object. */
static DRV_USART_BUFFER_OBJ gDrvUSARTBufferObj[DRV_USART_QUEUE_DEPTH_COMBINED];

/* This a global token counter used to generate unique buffer handles */
static uint16_t gDrvUSARTTokenCount = 0;

// *****************************************************************************
// *****************************************************************************
// Section: File scope functions
// *****************************************************************************
// *****************************************************************************

static bool _DRV_USART_ValidateClientHandle(DRV_USART_OBJ * object, DRV_HANDLE handle)
{
    if((handle == DRV_HANDLE_INVALID) || (handle >= DRV_USART_INSTANCES_NUMBER))
    {
        return false;
    }

    object = &gDrvUSARTObj[handle];

    if(object->clientInUse == false)
    {
        return false;
    }

    return true;
}

static bool _DRV_USART_ResourceLock(DRV_USART_OBJ * object)
{
    DRV_USART_OBJ * dObj = object;

    /* We will allow buffers to be added in the interrupt
       context of the SPI driver. But we must make
       sure that if we are inside interrupt, then we should
       not modify mutex. */
    if(dObj->interruptNestingCount == 0)
    {
        /* Grab a mutex. This is okay because we are not in an
           interrupt context */
        if(OSAL_MUTEX_Lock(&(dObj->mutexDriverInstance), OSAL_WAIT_FOREVER) == OSAL_RESULT_TRUE)
        {
            /* We will disable interrupts so that the queue
               status does not get updated asynchronously */
            if((dObj->txDMAChannel != SYS_DMA_CHANNEL_NONE) || (dObj->rxDMAChannel != SYS_DMA_CHANNEL_NONE))
            {
                SYS_INT_SourceDisable(dObj->interruptDMA);
            }
            SYS_INT_SourceDisable(dObj->interruptUSART);

            return true;
        }
        else
        {
            /* If everything is good, this part of code is not executed in an
             * RTOS environment */
            return false;
        }
    }

    return true;
}

static void _DRV_USART_ResourceUnlock(DRV_USART_OBJ * object)
{
    DRV_USART_OBJ * dObj = object;

    /* Restore the interrupt and release mutex. */
    if( (dObj->txDMAChannel != SYS_DMA_CHANNEL_NONE) || (dObj->rxDMAChannel != SYS_DMA_CHANNEL_NONE))
    {
        SYS_INT_SourceEnable(dObj->interruptDMA);
    }

    SYS_INT_SourceEnable(dObj->interruptUSART);

    if(dObj->interruptNestingCount == 0)
    {
        /* Mutex is never acquired from the interrupt context and hence should
         * never be released if in interrupt context.
         */
        OSAL_MUTEX_Unlock(&(dObj->mutexDriverInstance));
    }
}

static DRV_USART_BUFFER_OBJ * _DRV_USART_BufferObjectGet( void )
{
    unsigned int i = 0;

    /* Search the buffer pool for a free buffer object */
    while(i < DRV_USART_QUEUE_DEPTH_COMBINED)
    {
        if(gDrvUSARTBufferObj[i].inUse == false)
        {
            /* This means this object is free. */
            /* Assign a handle to this buffer. The buffer handle must be unique.
             * To do this, we construct the buffer handle out of the
             * gDrvUSARTTokenCount and allocated buffer index. Note that
             * gDrvUSARTTokenCount is incremented and wrapped around when the
             * value reaches OxFFFF. We do avoid a case where the token value
             * becomes 0xFFFF and the buffer index also becomes 0xFFFF */
            gDrvUSARTBufferObj[i].bufferHandle = _DRV_USART_MAKE_HANDLE(gDrvUSARTTokenCount, i);

            /* Update the token number. */
            _DRV_USART_UPDATE_BUFFER_TOKEN(gDrvUSARTTokenCount);

            return &gDrvUSARTBufferObj[i];
        }

        i++;
    }

    /* This means we could not find a buffer. This will happen if the the
     * DRV_USART_QUEUE_DEPTH_COMBINED parameter is configured to be less */
    return NULL;
}

static void _DRV_USART_BufferObjectRelease( DRV_USART_BUFFER_OBJ * object )
{
    DRV_USART_BUFFER_OBJ *bufferObj = object;

    /* Reset the buffer object */
    bufferObj->inUse = false;
    bufferObj->next = NULL;
    bufferObj->currentState = DRV_USART_BUFFER_IS_FREE;
}

static bool _DRV_USART_WriteBufferQueuePurge( DRV_USART_OBJ * object )
{
    DRV_USART_OBJ * dObj = object;
    DRV_USART_BUFFER_OBJ * iterator = NULL;
    DRV_USART_BUFFER_OBJ * nextBufferObj = NULL;

    iterator = dObj->queueWrite;

    while(iterator != NULL)
    {
        nextBufferObj = iterator->next;
        _DRV_USART_BufferObjectRelease(iterator);
        iterator = nextBufferObj;
    }

    /* Make the head pointer to NULL */
    dObj->queueSizeCurrentWrite = 0;
    dObj->queueWrite = NULL;

    return true;
}

static bool _DRV_USART_ReadBufferQueuePurge( DRV_USART_OBJ * object )
{
    DRV_USART_OBJ * dObj = object;
    DRV_USART_BUFFER_OBJ * iterator = NULL;
    DRV_USART_BUFFER_OBJ * nextBufferObj = NULL;

    iterator = dObj->queueRead;

    while(iterator != NULL)
    {
        nextBufferObj = iterator->next;
        _DRV_USART_BufferObjectRelease(iterator);
        iterator = nextBufferObj;
    }

    /* Make the head pointer to NULL */
    dObj->queueSizeCurrentRead = 0;
    dObj->queueRead = NULL;

    return true;
}

static void _DRV_USART_BufferQueueTask( DRV_USART_OBJ *object, DRV_USART_DIRECTION direction, DRV_USART_BUFFER_EVENT event)
{
    DRV_USART_OBJ * dObj = object;
    DRV_USART_BUFFER_OBJ *currentObj = NULL;
    DRV_USART_BUFFER_OBJ *newObj = NULL;

    if((dObj->inUse == false) || (dObj->status != SYS_STATUS_READY))
    {
        return;
    }

    /* Get the buffer object at queue head */
    if(direction == DRV_USART_DIRECTION_RX)
    {
        currentObj = dObj->queueRead;
    }
    else if(direction == DRV_USART_DIRECTION_TX)
    {
        currentObj = dObj->queueWrite;
    }

    if(currentObj != NULL)
    {
        currentObj->status = event;

        if(currentObj->status == DRV_USART_BUFFER_EVENT_ERROR)
        {
            if( (dObj->rxDMAChannel != SYS_DMA_CHANNEL_NONE))
            {
                /* DMA mode doesn't return number of bytes completed in case of
                 * an error. */
            }
            else
            {
                currentObj->nCount = dObj->usartPlib->readCountGet();
            }
        }
        else
        {
            /* Buffer transfer was successful, hence set completed bytes to
             * requested buffer size */
            currentObj->nCount = currentObj->size;
        }

        if (DATA_CACHE_ENABLED == true)
        {
            if((direction == DRV_USART_DIRECTION_RX) && (SYS_DMA_CHANNEL_NONE != dObj->rxDMAChannel))
            {
                /* Invalidate cache lines having received buffer before using it
                 * to load the latest data in the actual memory to the cache */
                DCACHE_INVALIDATE_BY_ADDR((uint32_t *)currentObj->buffer, currentObj->size);
            }
        }

        if((dObj->eventHandler != NULL))
        {
            dObj->interruptNestingCount++;

            dObj->eventHandler(currentObj->status, currentObj->bufferHandle, dObj->context);

            dObj->interruptNestingCount--;
        }

        /* Get the next buffer object in the queue and deallocate the current
         * buffer */
        newObj = currentObj->next;
        _DRV_USART_BufferObjectRelease(currentObj);

        /* Update the new buffer object head and submit it to the PLIB */
        if(direction == DRV_USART_DIRECTION_RX)
        {
            dObj->queueRead = newObj;
            dObj->queueSizeCurrentRead --;

            if (newObj != NULL)
            {
                newObj->currentState = DRV_USART_BUFFER_IS_PROCESSING;

                if( (dObj->rxDMAChannel != SYS_DMA_CHANNEL_NONE))
                {
                    SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void *)dObj->rxAddress, (const void *)newObj->buffer, newObj->size);
                }
                else
                {
                    dObj->usartPlib->read(newObj->buffer, newObj->size);
                }
            }
        }
        else if(direction == DRV_USART_DIRECTION_TX)
        {
            dObj->queueWrite = newObj;
            dObj->queueSizeCurrentWrite --;
            if (newObj != NULL)
            {
                newObj->currentState = DRV_USART_BUFFER_IS_PROCESSING;

                if((dObj->txDMAChannel != SYS_DMA_CHANNEL_NONE))
                {
                    if (DATA_CACHE_ENABLED == true)
                    {
                        /* Clean cache lines having source buffer before submitting a transfer
                         * request to DMA to load the latest data in the cache to the actual
                         * memory */
                        DCACHE_CLEAN_BY_ADDR((uint32_t *)newObj->buffer, newObj->size);
                    }

                    SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)newObj->buffer, (const void *)dObj->txAddress, newObj->size);
                }
                else
                {
                    dObj->usartPlib->write(newObj->buffer, newObj->size);
                }
            }
        }
    }
    else
    {
        /* Queue purge has been called. Do nothing. */
    }

    return;
}

static void _DRV_USART_TX_PLIB_CallbackHandler( uintptr_t context )
{
    DRV_USART_OBJ *dObj = (DRV_USART_OBJ *)context;

    _DRV_USART_BufferQueueTask(dObj, DRV_USART_DIRECTION_TX, DRV_USART_BUFFER_EVENT_COMPLETE);

    return;
}

static DRV_USART_ERROR _DRV_USART_GetErrorType(const uint32_t* remapError, uint32_t errorMask)
{
    DRV_USART_ERROR error = DRV_USART_ERROR_NONE;

    for (uint32_t i = 0; i < 3; i++)
    {
        if (remapError[i] == errorMask)
        {
            error = (DRV_USART_ERROR)(i+1);
            break;
        }
    }
    return error;
}

static void _DRV_USART_RX_PLIB_CallbackHandler( uintptr_t context )
{
    DRV_USART_OBJ *dObj = (DRV_USART_OBJ *)context;
    uint32_t errorMask;

    errorMask = dObj->usartPlib->errorGet();

    if(errorMask == (uint32_t) DRV_USART_ERROR_NONE)
    {
        dObj->errors = DRV_USART_ERROR_NONE;
        _DRV_USART_BufferQueueTask(dObj, DRV_USART_DIRECTION_RX, DRV_USART_BUFFER_EVENT_COMPLETE);
    }
    else
    {
        dObj->errors = _DRV_USART_GetErrorType(dObj->remapError, errorMask);
        _DRV_USART_BufferQueueTask(dObj, DRV_USART_DIRECTION_RX, DRV_USART_BUFFER_EVENT_ERROR);
    }

    return;
}

static void _DRV_USART_TX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{
    DRV_USART_OBJ *dObj = (DRV_USART_OBJ *)context;

    if(event == SYS_DMA_TRANSFER_COMPLETE)
    {
        _DRV_USART_BufferQueueTask(dObj, DRV_USART_DIRECTION_TX, DRV_USART_BUFFER_EVENT_COMPLETE);
    }
    else if(event == SYS_DMA_TRANSFER_ERROR)
    {
        _DRV_USART_BufferQueueTask(dObj, DRV_USART_DIRECTION_TX, DRV_USART_BUFFER_EVENT_ERROR);
    }

    return;
}

static void _DRV_USART_RX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{
    DRV_USART_OBJ *dObj = (DRV_USART_OBJ *)context;

    if(event == SYS_DMA_TRANSFER_COMPLETE)
    {
        _DRV_USART_BufferQueueTask(dObj, DRV_USART_DIRECTION_RX, DRV_USART_BUFFER_EVENT_COMPLETE);
    }
    else if(event == SYS_DMA_TRANSFER_ERROR)
    {
        _DRV_USART_BufferQueueTask(dObj, DRV_USART_DIRECTION_RX, DRV_USART_BUFFER_EVENT_ERROR);
    }

    return;
}

// *****************************************************************************
// *****************************************************************************
// Section: USART Driver Common Interface Implementation
// *****************************************************************************
// *****************************************************************************

SYS_MODULE_OBJ DRV_USART_Initialize( const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT * const init )
{
    DRV_USART_OBJ *dObj = NULL;
    DRV_USART_INIT *usartInit = (DRV_USART_INIT *)init ;

    /* Validate the request */
    if(drvIndex >= DRV_USART_INSTANCES_NUMBER)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    if(gDrvUSARTObj[drvIndex].inUse != false)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    /* Allocate the driver object */
    dObj = &gDrvUSARTObj[drvIndex];

    /* Create the Mutexes needed for RTOS mode. These calls always passes in the
     * non-RTOS mode */
    if(OSAL_MUTEX_Create(&dObj->mutexDriverInstance) != OSAL_RESULT_TRUE)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    dObj->inUse                 = true;
    dObj->clientInUse           = false;
    dObj->usartPlib             = usartInit->usartPlib;
    dObj->queueSizeRead         = usartInit->queueSizeReceive;
    dObj->queueSizeWrite        = usartInit->queueSizeTransmit;
    dObj->interruptUSART        = usartInit->interruptUSART;
    dObj->queueSizeCurrentRead  = 0;
    dObj->queueSizeCurrentWrite = 0;
    dObj->queueRead             = NULL;
    dObj->queueWrite            = NULL;
    dObj->txDMAChannel          = usartInit->dmaChannelTransmit;
    dObj->rxDMAChannel          = usartInit->dmaChannelReceive;
    dObj->txAddress             = usartInit->usartTransmitAddress;
    dObj->rxAddress             = usartInit->usartReceiveAddress;
    dObj->interruptDMA          = usartInit->interruptDMA;
    dObj->interruptNestingCount = 0;
    dObj->remapDataWidth        = usartInit->remapDataWidth;
    dObj->remapParity           = usartInit->remapParity;
    dObj->remapStopBits         = usartInit->remapStopBits;
    dObj->remapError            = usartInit->remapError;

    /* Register a callback with either DMA or USART PLIB based on configuration.
     * dObj is used as a context parameter, that will be used to distinguish the
     * events for different driver instances. */
    if(dObj->txDMAChannel != SYS_DMA_CHANNEL_NONE)
    {
        SYS_DMA_ChannelCallbackRegister(dObj->txDMAChannel, _DRV_USART_TX_DMA_CallbackHandler, (uintptr_t)dObj);
    }
    else
    {
        dObj->usartPlib->writeCallbackRegister(_DRV_USART_TX_PLIB_CallbackHandler, (uintptr_t)dObj);
        (void)_DRV_USART_TX_DMA_CallbackHandler;
    }

    if(dObj->rxDMAChannel != SYS_DMA_CHANNEL_NONE)
    {
        SYS_DMA_ChannelCallbackRegister(dObj->rxDMAChannel, _DRV_USART_RX_DMA_CallbackHandler, (uintptr_t)dObj);
    }
    else
    {
        dObj->usartPlib->readCallbackRegister(_DRV_USART_RX_PLIB_CallbackHandler, (uintptr_t)dObj);
        (void)_DRV_USART_RX_DMA_CallbackHandler;
    }

    /* Update the status */
    dObj->status = SYS_STATUS_READY;

    /* Return the object structure */
    return ( (SYS_MODULE_OBJ)drvIndex );
}

SYS_STATUS DRV_USART_Status( SYS_MODULE_OBJ object)
{
    /* Validate the request */
    if( (object == SYS_MODULE_OBJ_INVALID) || (object >= DRV_USART_INSTANCES_NUMBER) )
    {
        return SYS_STATUS_UNINITIALIZED;
    }

    return (gDrvUSARTObj[object].status);
}

DRV_HANDLE DRV_USART_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    DRV_USART_OBJ *dObj = NULL;
    DRV_HANDLE drvHandle = DRV_HANDLE_INVALID;

    /* Validate the request */
    if (drvIndex >= DRV_USART_INSTANCES_NUMBER)
    {
        return drvHandle;
    }

    dObj = &gDrvUSARTObj[drvIndex];

    if (_DRV_USART_ResourceLock(dObj) == false)
    {
        return drvHandle;
    }

    if((dObj->status == SYS_STATUS_READY) && (dObj->inUse == true) && (dObj->clientInUse == false))
    {
        /* Grab client object here */
        dObj->clientInUse  = true;
        dObj->eventHandler = NULL;
        dObj->context      = (uintptr_t)NULL;
        drvHandle = (DRV_HANDLE)drvIndex;
    }

    _DRV_USART_ResourceUnlock(dObj);

    /* Driver index is the handle */
    return drvHandle;
}

void DRV_USART_Close( DRV_HANDLE handle )
{
    DRV_USART_OBJ * dObj = NULL;

    /* Validate the request */
    if(_DRV_USART_ValidateClientHandle(dObj, handle) == false)
    {
        return;
    }

    dObj = &gDrvUSARTObj[handle];

    if (_DRV_USART_ResourceLock(dObj) == false)
    {
        return;
    }

    if(_DRV_USART_WriteBufferQueuePurge(dObj) == false)
    {
        _DRV_USART_ResourceUnlock(dObj);
        return;
    }

    if(_DRV_USART_ReadBufferQueuePurge(dObj) == false)
    {
        _DRV_USART_ResourceUnlock(dObj);
        return;
    }

    dObj->clientInUse = false;

    _DRV_USART_ResourceUnlock(dObj);

}

DRV_USART_ERROR DRV_USART_ErrorGet( const DRV_HANDLE handle )
{
    DRV_USART_OBJ * dObj = NULL;
    DRV_USART_ERROR errors = DRV_USART_ERROR_NONE;

    /* Validate the request */
    if(_DRV_USART_ValidateClientHandle(dObj, handle) == false)
    {
        return errors;
    }

    dObj = &gDrvUSARTObj[handle];

    if (_DRV_USART_ResourceLock(dObj) == false)
    {
        return errors;
    }

    errors = dObj->errors;
    dObj->errors = DRV_USART_ERROR_NONE;

    _DRV_USART_ResourceUnlock(dObj);

    return errors;
}

bool DRV_USART_SerialSetup( const DRV_HANDLE handle, DRV_USART_SERIAL_SETUP* setup )
{
    DRV_USART_OBJ * dObj = NULL;
    DRV_USART_SERIAL_SETUP setupRemap;
    bool isSuccess = false;

    /* Validate the request */
    if(_DRV_USART_ValidateClientHandle(dObj, handle) == false)
    {
        return isSuccess;
    }

    if (setup == NULL)
    {
        return isSuccess;
    }

    dObj = &gDrvUSARTObj[handle];

    setupRemap.dataWidth = (DRV_USART_DATA_BIT)dObj->remapDataWidth[setup->dataWidth];
    setupRemap.parity = (DRV_USART_DATA_BIT)dObj->remapParity[setup->parity];
    setupRemap.stopBits = (DRV_USART_DATA_BIT)dObj->remapStopBits[setup->stopBits];
    setupRemap.baudRate = setup->baudRate;

    if((setupRemap.dataWidth != DRV_USART_DATA_BIT_INVALID) && (setupRemap.parity != DRV_USART_PARITY_INVALID) && (setupRemap.stopBits != DRV_USART_STOP_BIT_INVALID))
    {
        /* Clock source cannot be modified dynamically, so passing the '0' to pick
         * the configured clock source value */
         isSuccess = dObj->usartPlib->serialSetup(&setupRemap, 0);
    }
    return isSuccess;
}

// *****************************************************************************
// *****************************************************************************
// Section: USART Driver Buffer Queue Interface Implementation
// *****************************************************************************
// *****************************************************************************

void DRV_USART_BufferEventHandlerSet( const DRV_HANDLE handle, const DRV_USART_BUFFER_EVENT_HANDLER eventHandler, const uintptr_t context )
{
    DRV_USART_OBJ * dObj = NULL;

    /* Validate the Request */
    if(_DRV_USART_ValidateClientHandle(dObj, handle) == false)
    {
        return;
    }

    dObj = &gDrvUSARTObj[handle];

    if (_DRV_USART_ResourceLock(dObj) == false)
    {
        return;
    }

    dObj->eventHandler = eventHandler;
    dObj->context = context;

    _DRV_USART_ResourceUnlock(dObj);

    return;
}

void DRV_USART_WriteBufferAdd( DRV_HANDLE handle, void * buffer, const size_t size, DRV_USART_BUFFER_HANDLE * bufferHandle)
{
    DRV_USART_OBJ * dObj = NULL;
    DRV_USART_BUFFER_OBJ * bufferObj = NULL;
    DRV_USART_BUFFER_OBJ * iterator = NULL;

    /* Validate the Request */
    if (bufferHandle == NULL)
    {
        return;
    }

    *bufferHandle = DRV_USART_BUFFER_HANDLE_INVALID;

    if((size == 0) || (buffer == NULL))
    {
        return;
    }

    if(_DRV_USART_ValidateClientHandle(dObj, handle) == false)
    {
        return;
    }

    dObj = &gDrvUSARTObj[handle];

    if (_DRV_USART_ResourceLock(dObj) == false)
    {
        return;
    }

    if(dObj->queueSizeCurrentWrite >= dObj->queueSizeWrite)
    {
        _DRV_USART_ResourceUnlock(dObj);
        return;
    }

    /* Search the buffer pool for a free buffer object */
    bufferObj = _DRV_USART_BufferObjectGet();

    if(bufferObj == NULL)
    {
        /* Couldn't able to get the buffer object */
        _DRV_USART_ResourceUnlock(dObj);
        return;
    }

    /* Configure the buffer object */
    bufferObj->size         = size;
    bufferObj->nCount       = 0;
    bufferObj->inUse        = true;
    bufferObj->buffer       = buffer;
    bufferObj->dObj         = dObj;
    bufferObj->next         = NULL;
    bufferObj->currentState = DRV_USART_BUFFER_IS_IN_QUEUE;
    bufferObj->status       = DRV_USART_BUFFER_EVENT_PENDING;

    *bufferHandle = bufferObj->bufferHandle;

    dObj->queueSizeCurrentWrite ++;

    if(dObj->queueWrite == NULL)
    {
        /* This is the first buffer in the queue */
        dObj->queueWrite = bufferObj;

        /* Because this is the first buffer in the queue, we need to submit the
         * buffer to the PLIB to start processing. */
        bufferObj->currentState = DRV_USART_BUFFER_IS_PROCESSING;

        if(dObj->txDMAChannel != SYS_DMA_CHANNEL_NONE)
        {
            if (DATA_CACHE_ENABLED == true)
            {
                /* Clean cache lines having source buffer before submitting a transfer
                 * request to DMA to load the latest data in the cache to the actual
                 * memory */
                DCACHE_CLEAN_BY_ADDR((uint32_t *)buffer, size);
            }

            SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)bufferObj->buffer, (const void *)dObj->txAddress, bufferObj->size);
        }
        else
        {
            dObj->usartPlib->write(bufferObj->buffer, bufferObj->size);
        }
    }
    else
    {
        /* This means the write queue is not empty. We must add
         * the buffer object to the end of the queue */
        iterator = dObj->queueWrite;
        while(iterator->next != NULL)
        {
            /* Get the next buffer object */
            iterator = iterator->next;
        }

        iterator->next = bufferObj;
    }

    _DRV_USART_ResourceUnlock(dObj);

    return;
}

void DRV_USART_ReadBufferAdd( DRV_HANDLE handle, void * buffer, const size_t size, DRV_USART_BUFFER_HANDLE * bufferHandle)
{
    DRV_USART_OBJ * dObj = NULL;
    DRV_USART_BUFFER_OBJ * bufferObj = NULL;
    DRV_USART_BUFFER_OBJ * iterator = NULL;

    /* Validate the Request */
    if (bufferHandle == NULL)
    {
        return;
    }

    *bufferHandle = DRV_USART_BUFFER_HANDLE_INVALID;

    if((size == 0) || (buffer == NULL))
    {
        return;
    }

    if(_DRV_USART_ValidateClientHandle(dObj, handle) == false)
    {
        return;
    }

    dObj = &gDrvUSARTObj[handle];

    if (_DRV_USART_ResourceLock(dObj) == false)
    {
        return;
    }

    if(dObj->queueSizeCurrentRead >= dObj->queueSizeRead)
    {
        _DRV_USART_ResourceUnlock(dObj);
        return;
    }

    /* Search the buffer pool for a free buffer object */
    bufferObj = _DRV_USART_BufferObjectGet();

    if(bufferObj == NULL)
    {
        /* Couldn't able to get the buffer object */
        _DRV_USART_ResourceUnlock(dObj);
        return;
    }

    /* Configure the buffer object */
    bufferObj->size            = size;
    bufferObj->nCount          = 0;
    bufferObj->inUse           = true;
    bufferObj->buffer          = buffer;
    bufferObj->dObj            = dObj;
    bufferObj->next            = NULL;
    bufferObj->currentState    = DRV_USART_BUFFER_IS_IN_QUEUE;
    bufferObj->status          = DRV_USART_BUFFER_EVENT_PENDING;

    *bufferHandle = bufferObj->bufferHandle;

    dObj->queueSizeCurrentRead ++;

    if(dObj->queueRead == NULL)
    {
        /* This is the first buffer in the queue */
        dObj->queueRead = bufferObj;

        /* Because this is the first buffer in the queue, we need to submit the
         * buffer to the PLIB to start processing. */
        bufferObj->currentState    = DRV_USART_BUFFER_IS_PROCESSING;

        if(dObj->rxDMAChannel != SYS_DMA_CHANNEL_NONE)
        {
            SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void *)dObj->rxAddress, (const void *)bufferObj->buffer, bufferObj->size);
        }
        else
        {
            dObj->usartPlib->read(bufferObj->buffer, bufferObj->size);
        }
    }
    else
    {
        /* This means the write queue is not empty. We must add
         * the buffer object to the end of the queue */
        iterator = dObj->queueRead;
        while(iterator->next != NULL)
        {
            /* Get the next buffer object */
            iterator = iterator->next;
        }
        iterator->next = bufferObj;
    }

    _DRV_USART_ResourceUnlock(dObj);

    return;
}

size_t DRV_USART_BufferCompletedBytesGet( DRV_USART_BUFFER_HANDLE bufferHandle )
{
    DRV_USART_OBJ *dObj = NULL;
    DRV_USART_BUFFER_OBJ * bufferObj = NULL;
    size_t processedBytes = DRV_USART_BUFFER_HANDLE_INVALID;

    /* Validate the Request */
    if(bufferHandle == DRV_USART_BUFFER_HANDLE_INVALID)
    {
        return processedBytes;
    }

    /* The buffer index is the contained in the lower 16 bits of the buffer
     * handle */
    bufferObj = &gDrvUSARTBufferObj[bufferHandle & _DRV_USART_BUFFER_TOKEN_MAX];

    dObj = bufferObj->dObj;

    if (_DRV_USART_ResourceLock(dObj) == false)
    {
        return processedBytes;
    }

    /* Check if the buffer is currently submitted to PLIB */
    if(bufferObj->currentState == DRV_USART_BUFFER_IS_PROCESSING)
    {
        /* Get the number of bytes processed by PLIB. */
        if(dObj->queueWrite == bufferObj)
        {
            processedBytes = dObj->usartPlib->writeCountGet();
        }
        else if(dObj->queueRead == bufferObj)
        {
            processedBytes = dObj->usartPlib->readCountGet();
        }
    }
    else
    {
        /* Buffer is not with PLIB, so get the nCount of buffer object */
        processedBytes = bufferObj->nCount;
    }

    _DRV_USART_ResourceUnlock(dObj);

    /* Return the processed number of bytes..
     * If the buffer handle is invalid or bufferObj is expired
     * then return DRV_USART_BUFFER_HANDLE_INVALID */
    return processedBytes;
}

DRV_USART_BUFFER_EVENT DRV_USART_BufferStatusGet( const DRV_USART_BUFFER_HANDLE bufferHandle )
{
    DRV_USART_BUFFER_OBJ * bufferObj = NULL;

    /* Validate the Request */
    if(bufferHandle == DRV_USART_BUFFER_HANDLE_INVALID)
    {
        return DRV_USART_BUFFER_EVENT_ERROR;
    }

    /* The buffer index is the contained in the lower 16 bits of the buffer
     * handle */
    bufferObj = &gDrvUSARTBufferObj[bufferHandle & _DRV_USART_BUFFER_TOKEN_MAX];

    return bufferObj->status;
}

bool DRV_USART_WriteQueuePurge( const DRV_HANDLE handle )
{
    DRV_USART_OBJ * dObj = NULL;
    bool status = false;

    /* Validate the Request */
    if( _DRV_USART_ValidateClientHandle(dObj, handle) == false)
    {
        return status;
    }

    dObj = &gDrvUSARTObj[handle];

    if (_DRV_USART_ResourceLock(dObj) == false)
    {
        return status;
    }

    status = _DRV_USART_WriteBufferQueuePurge(dObj);

    _DRV_USART_ResourceUnlock(dObj);

    return status;
}

bool DRV_USART_ReadQueuePurge( const DRV_HANDLE handle )
{
    DRV_USART_OBJ * dObj = NULL;
    bool status = false;

    /* Validate the Request */
    if(_DRV_USART_ValidateClientHandle(dObj, handle) == false)
    {
        return status;
    }

    dObj = &gDrvUSARTObj[handle];

    if (_DRV_USART_ResourceLock(dObj) == false)
    {
        return status;
    }

    status = _DRV_USART_ReadBufferQueuePurge(dObj);

    _DRV_USART_ResourceUnlock(dObj);

    return status;
}
