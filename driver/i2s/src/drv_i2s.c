/*******************************************************************************
  I2S Driver Implementation.

  Company:
    Microchip Technology Inc.

  File Name:
    drv_i2s.c

  Summary:
    Source code for the I2S driver dynamic implementation.

  Description:
    This file contains the source code for the dynamic implementation of the
    I2S driver.
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
#include "driver/i2s/drv_i2s.h"
#include "drv_i2s_local.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data
// *****************************************************************************
// *****************************************************************************

/* This is the driver instance object array. */
DRV_I2S_OBJ gDrvI2SObj[DRV_I2S_INSTANCES_NUMBER] ;

/* This is the array of I2S Driver Buffet object. */
DRV_I2S_BUFFER_OBJ gDrvI2SBufferObj[DRV_I2S_QUEUE_DEPTH_COMBINED];

/* This a global token counter used to generate unique buffer handles */
static uint16_t gDrvI2STokenCount = 0;

// *****************************************************************************
// *****************************************************************************
// Section: File scope functions
// *****************************************************************************
// *****************************************************************************
static bool _DRV_I2S_ValidateClientHandle(DRV_I2S_OBJ * object, DRV_HANDLE handle)
{
    if(DRV_HANDLE_INVALID == handle)
    {
        return false;
    }

    object = &gDrvI2SObj[handle];

    if(false == object->clientInUse)
    {
        return false;
    }

    return true;
}

static bool _DRV_I2S_ResourceLock(DRV_I2S_OBJ * object)
{
    DRV_I2S_OBJ * dObj = object;

    /* Grab a mutex to avoid other threads to modify driver resource
     * asynchronously. */
    if(OSAL_MUTEX_Lock(&(dObj->mutexDriverInstance), OSAL_WAIT_FOREVER) != OSAL_RESULT_TRUE)
    {
        return false;
    }

    /* We will disable I2S and/or DMA interrupt so that the driver resource
     * is not updated asynchronously. */
    if( (DMA_CHANNEL_NONE != dObj->txDMAChannel) || (DMA_CHANNEL_NONE != dObj->rxDMAChannel))
    {
        SYS_INT_SourceDisable(dObj->interruptDMA);
    }

    SYS_INT_SourceDisable(dObj->interruptI2S);

    return true;
}

static bool _DRV_I2S_ResourceUnlock(DRV_I2S_OBJ * object)
{
    DRV_I2S_OBJ * dObj = object;

    /* Restore the interrupt and release mutex. */
    if( (DMA_CHANNEL_NONE != dObj->txDMAChannel) || (DMA_CHANNEL_NONE != dObj->rxDMAChannel))
    {
        SYS_INT_SourceEnable(dObj->interruptDMA);
    }

    SYS_INT_SourceEnable(dObj->interruptI2S);

    OSAL_MUTEX_Unlock(&(dObj->mutexDriverInstance));

    return true;
}

static DRV_I2S_BUFFER_OBJ * _DRV_I2S_BufferObjectGet( void )
{
    unsigned int i = 0;

    /* Search the buffer pool for a free buffer object */
    while(i < DRV_I2S_QUEUE_DEPTH_COMBINED)
    {
        if(false == gDrvI2SBufferObj[i].inUse)
        {
            /* This means this object is free. */
            /* Assign a handle to this buffer. The buffer handle must be unique.
             * To do this, we construct the buffer handle out of the
             * gDrvI2STokenCount and allocated buffer index. Note that
             * gDrvI2STokenCount is incremented and wrapped around when the
             * value reaches OxFFFF. We do avoid a case where the token value
             * becomes 0xFFFF and the buffer index also becomes 0xFFFF */
            gDrvI2SBufferObj[i].bufferHandle = _DRV_I2S_MAKE_HANDLE(gDrvI2STokenCount, i);

            /* Update the token number. */
            _DRV_I2S_UPDATE_BUFFER_TOKEN(gDrvI2STokenCount);

            return &gDrvI2SBufferObj[i];
        }

        i++;
    }

    /* This means we could not find a buffer. This will happen if the the
     * DRV_I2S_QUEUE_DEPTH_COMBINED parameter is configured to be less */
    return NULL;
}

static void _DRV_I2S_BufferObjectRelease( DRV_I2S_BUFFER_OBJ * object )
{
    DRV_I2S_BUFFER_OBJ *bufferObj = object;

    /* Reset the buffer object */
    bufferObj->inUse = false;
    bufferObj->next = NULL;
    bufferObj->currentState = DRV_I2S_BUFFER_IS_FREE;
}

static bool _DRV_I2S_WriteBufferQueuePurge( DRV_I2S_OBJ * object )
{
    DRV_I2S_OBJ * dObj = object;
    DRV_I2S_BUFFER_OBJ * iterator = NULL;
    DRV_I2S_BUFFER_OBJ * nextBufferObj = NULL;

    _DRV_I2S_ResourceLock(dObj);

    iterator = dObj->queueWrite;

    while(iterator != NULL)
    {
        nextBufferObj = iterator->next;
        _DRV_I2S_BufferObjectRelease(iterator);
        iterator = nextBufferObj;
    }

    /* Make the head pointer to NULL */
    dObj->queueSizeCurrentWrite = 0;
    dObj->queueWrite = NULL;

    _DRV_I2S_ResourceUnlock(dObj);

    return true;
}

static bool _DRV_I2S_ReadBufferQueuePurge( DRV_I2S_OBJ * object )
{
    DRV_I2S_OBJ * dObj = object;
    DRV_I2S_BUFFER_OBJ * iterator = NULL;
    DRV_I2S_BUFFER_OBJ * nextBufferObj = NULL;

    _DRV_I2S_ResourceLock(dObj);

    iterator = dObj->queueRead;

    while(iterator != NULL)
    {
        nextBufferObj = iterator->next;
        _DRV_I2S_BufferObjectRelease(iterator);
        iterator = nextBufferObj;
    }

    /* Make the head pointer to NULL */
    dObj->queueSizeCurrentRead = 0;
    dObj->queueRead = NULL;

    _DRV_I2S_ResourceUnlock(dObj);

    return true;
}

static void _DRV_I2S_BufferQueueTask( DRV_I2S_OBJ *object, DRV_I2S_DIRECTION direction, DRV_I2S_BUFFER_EVENT event)
{
    DRV_I2S_OBJ * dObj = object;
    DRV_I2S_BUFFER_OBJ *currentObj = NULL;
    DRV_I2S_BUFFER_OBJ *newObj = NULL;

    if((false == dObj->inUse) || (SYS_STATUS_READY != dObj->status))
    {
        return;
    }

    /* Get the buffer object at queue head */
    if(DRV_I2S_DIRECTION_RX == direction)
    {
        currentObj = dObj->queueRead;
    }
    else if(DRV_I2S_DIRECTION_TX == direction)
    {
        currentObj = dObj->queueWrite;
    }

    if(currentObj != NULL)
    {

        currentObj->status = event;

        if(DRV_I2S_BUFFER_EVENT_ERROR != currentObj->status)
        {
            /* Buffer transfer was successful, hence set completed bytes to
             * requested buffer size */
            currentObj->nCount = currentObj->size;
        }

        if((dObj->eventHandler != NULL))
        {
            dObj->eventHandler(currentObj->status, currentObj->bufferHandle, dObj->context);
        }

        /* Get the next buffer object in the queue and deallocate the current
         * buffer */
        newObj = currentObj->next;
        _DRV_I2S_BufferObjectRelease(currentObj);

        /* Update the new buffer object head and submit it */
        if(DRV_I2S_DIRECTION_RX == direction)
        {
            dObj->queueRead = newObj;
            dObj->queueSizeCurrentRead --;
            if (newObj != NULL)
            {
                newObj->currentState = DRV_I2S_BUFFER_IS_PROCESSING;

                if( (DMA_CHANNEL_NONE != dObj->rxDMAChannel))
                {
                    SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void *)dObj->rxAddress, (const void *)newObj->buffer, newObj->size);
                }
            }
        }
        else if(DRV_I2S_DIRECTION_TX == direction)
        {
            dObj->queueWrite = newObj;
            dObj->queueSizeCurrentWrite --;
            if (newObj != NULL)
            {
                newObj->currentState = DRV_I2S_BUFFER_IS_PROCESSING;

                if( (DMA_CHANNEL_NONE != dObj->txDMAChannel))
                {
#if defined(__SAME70Q21B__) || defined(__ATSAME70Q21B__)
                    /************ code specific to SAM E70 ********************/
                    /* Check if the data cache is enabled */
                    if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
                    {
                        /* The data cache lines have to be flushed in case of DMA write to avoid 
                         * coherency */
                        SCB_CleanDCache();
                    }
                    /************ end of E70 specific code ********************/
#endif
                    SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)newObj->buffer, (const void *)dObj->txAddress, newObj->size);
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

static void _DRV_I2S_TX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{
    DRV_I2S_OBJ *dObj = (DRV_I2S_OBJ *)context;

    if(SYS_DMA_TRANSFER_COMPLETE == event)
    {
        _DRV_I2S_BufferQueueTask(dObj, DRV_I2S_DIRECTION_TX, DRV_I2S_BUFFER_EVENT_COMPLETE);
    }
    else if(SYS_DMA_TRANSFER_ERROR == event)
    {
        _DRV_I2S_BufferQueueTask(dObj, DRV_I2S_DIRECTION_TX, DRV_I2S_BUFFER_EVENT_ERROR);
    }

    return;
}

static void _DRV_I2S_RX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{
    DRV_I2S_OBJ *dObj = (DRV_I2S_OBJ *)context;

    if(SYS_DMA_TRANSFER_COMPLETE == event)
    {
        _DRV_I2S_BufferQueueTask(dObj, DRV_I2S_DIRECTION_RX, DRV_I2S_BUFFER_EVENT_COMPLETE);
    }
    else if(SYS_DMA_TRANSFER_ERROR == event)
    {
        _DRV_I2S_BufferQueueTask(dObj, DRV_I2S_DIRECTION_RX, DRV_I2S_BUFFER_EVENT_ERROR);
    }

    return;
}

// *****************************************************************************
// *****************************************************************************
// Section: I2S Driver Common Interface Implementation
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
SYS_MODULE_OBJ DRV_I2S_Initialize( const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT * const init )
{
    DRV_I2S_OBJ *dObj = NULL;
    DRV_I2S_INIT *i2sInit = (DRV_I2S_INIT *)init ;

    /* Validate the request */
    if(DRV_I2S_INSTANCES_NUMBER <= drvIndex)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    if(false != gDrvI2SObj[drvIndex].inUse)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    /* Allocate the driver object */
    dObj = &gDrvI2SObj[drvIndex];
    dObj->inUse = true;
    dObj->clientInUse           = false;
    dObj->i2sPlib             = i2sInit->i2sPlib;
    dObj->queueSizeRead         = i2sInit->queueSize;
    dObj->queueSizeWrite        = i2sInit->queueSize;
    dObj->interruptI2S        = i2sInit->interruptI2S;
    dObj->queueSizeCurrentRead  = 0;
    dObj->queueSizeCurrentWrite = 0;
    dObj->queueRead             = NULL;
    dObj->queueWrite            = NULL;
    dObj->txDMAChannel          = i2sInit->dmaChannelTransmit;
    dObj->rxDMAChannel          = i2sInit->dmaChannelReceive;
    dObj->txAddress             = i2sInit->i2sTransmitAddress;
    dObj->rxAddress             = i2sInit->i2sReceiveAddress;
    dObj->interruptDMA          = i2sInit->interruptDMA;
    dObj->dmaDataLength         = i2sInit->dmaDataLength;  

    /* Create the Mutexes needed for RTOS mode. These calls always passes in the
     * non-RTOS mode */
    if(OSAL_RESULT_TRUE != OSAL_MUTEX_Create(&(dObj->mutexDriverInstance)))
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    /* Register a callback with DMA.
     * dObj is used as a context parameter, that will be used to distinguish the
     * events for different driver instances. */
    if(DMA_CHANNEL_NONE != dObj->txDMAChannel)
    {
        SYS_DMA_ChannelCallbackRegister(dObj->txDMAChannel, _DRV_I2S_TX_DMA_CallbackHandler, (uintptr_t)dObj);
    }

    if(DMA_CHANNEL_NONE != dObj->rxDMAChannel)
    {
        SYS_DMA_ChannelCallbackRegister(dObj->rxDMAChannel, _DRV_I2S_RX_DMA_CallbackHandler, (uintptr_t)dObj);
    }

    /* Update the status */
    dObj->status = SYS_STATUS_READY;

    /* Return the object structure */
    return ( (SYS_MODULE_OBJ)drvIndex );
}

// *****************************************************************************
SYS_STATUS DRV_I2S_Status( SYS_MODULE_OBJ object)
{
    /* Validate the request */
    if( (SYS_MODULE_OBJ_INVALID == object) || (DRV_I2S_INSTANCES_NUMBER <= object) )
    {
        return SYS_STATUS_UNINITIALIZED;
    }

    return (gDrvI2SObj[object].status);
}

// *****************************************************************************
DRV_HANDLE DRV_I2S_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    DRV_I2S_OBJ *dObj = NULL;

    /* Validate the request */
    if (DRV_I2S_INSTANCES_NUMBER <= drvIndex)
    {
        return DRV_HANDLE_INVALID;
    }

    dObj = &gDrvI2SObj[drvIndex];

    if((SYS_STATUS_READY != dObj->status) || (false == dObj->inUse))
    {
        return DRV_HANDLE_INVALID;
    }

    if(true == dObj->clientInUse)
    {
        /* This driver supports only one client per instance */
        return DRV_HANDLE_INVALID;
    }

    /* Grab client object here */
    dObj->clientInUse  = true;
    dObj->eventHandler = NULL;
    dObj->context      = (uintptr_t)NULL;

    /* Driver index is the handle */
    return (DRV_HANDLE)drvIndex;
}

// *****************************************************************************
void DRV_I2S_Close( DRV_HANDLE handle )
{
    DRV_I2S_OBJ * dObj = NULL;

    /* Validate the request */
    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return;
    }

    dObj = &gDrvI2SObj[handle];

    if(false == _DRV_I2S_WriteBufferQueuePurge(dObj))
    {
        return;
    }

    if(false == _DRV_I2S_ReadBufferQueuePurge(dObj))
    {
        return;
    }

    dObj->clientInUse = false;

    return;
}

DRV_I2S_ERROR DRV_I2S_ErrorGet( const DRV_HANDLE handle )
{
    DRV_I2S_OBJ * dObj = NULL;
    DRV_I2S_ERROR errors = DRV_I2S_ERROR_NONE;

    /* Validate the request */
    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return DRV_I2S_ERROR_NONE;
    }

    dObj = &gDrvI2SObj[handle];
    errors = dObj->errors;
    dObj->errors = DRV_I2S_ERROR_NONE;

    return errors;
}

// *****************************************************************************
// *****************************************************************************
// Section: I2S Driver Buffer Queue Interface Implementation
// *****************************************************************************
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
void DRV_I2S_BufferEventHandlerSet( const DRV_HANDLE handle, const DRV_I2S_BUFFER_EVENT_HANDLER eventHandler, const uintptr_t context )
{
    DRV_I2S_OBJ * dObj = NULL;

    /* Validate the Request */
    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return;
    }

    dObj = &gDrvI2SObj[handle];

    dObj->eventHandler = eventHandler;
    dObj->context = context;

    return;
}

// *****************************************************************************
void DRV_I2S_WriteBufferAdd( DRV_HANDLE handle, void * buffer, const size_t size, DRV_I2S_BUFFER_HANDLE * bufferHandle)
{
    DRV_I2S_OBJ * dObj = NULL;
    DRV_I2S_BUFFER_OBJ * bufferObj = NULL;
    DRV_I2S_BUFFER_OBJ * iterator = NULL;

    /* Validate the Request */
    if (bufferHandle == NULL)
    {
        return;
    }

    *bufferHandle = DRV_I2S_BUFFER_HANDLE_INVALID;

    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return;
    }

    dObj = &gDrvI2SObj[handle];

    if((size == 0) || (NULL == buffer))
    {
        return;
    }

    if(dObj->queueSizeCurrentWrite >= dObj->queueSizeWrite)
    {
        return;
    }

    _DRV_I2S_ResourceLock(dObj);

    /* Search the buffer pool for a free buffer object */
    bufferObj = _DRV_I2S_BufferObjectGet();

    if(NULL == bufferObj)
    {
        /* Couldn't able to get the buffer object */
        _DRV_I2S_ResourceUnlock(dObj);
        return;
    }

    /* Configure the buffer object */
    bufferObj->size         = size;
    bufferObj->nCount       = 0;
    bufferObj->inUse        = true;
    bufferObj->buffer       = buffer;
    bufferObj->dObj         = dObj;
    bufferObj->next         = NULL;
    bufferObj->currentState = DRV_I2S_BUFFER_IS_IN_QUEUE;

    *bufferHandle = bufferObj->bufferHandle;

    dObj->queueSizeCurrentWrite ++;

    if(dObj->queueWrite == NULL)
    {
        /* This is the first buffer in the queue */
        dObj->queueWrite = bufferObj;

        /* Because this is the first buffer in the queue, we need to submit the
         * buffer to the DMA to start processing. */
        bufferObj->currentState = DRV_I2S_BUFFER_IS_PROCESSING;

        if( (DMA_CHANNEL_NONE != dObj->txDMAChannel))
        {
#if defined(__SAME70Q21B__) || defined(__ATSAME70Q21B__)
            /************ code specific to SAM E70 ********************/
            /* Check if the data cache is enabled */
            if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
            {
                /* The data cache lines have to be flushed in case of DMA write to avoid 
                 * coherency */
                SCB_CleanDCache();
            }
            /************ end of E70 specific code ********************/
#endif            
            // if this is half word transfer, need to divide size by 2           
            if (dObj->dmaDataLength == 16)
            {
                bufferObj->size /= 2;
            }
            // if this is full word transfer, need to divide size by 4
            else if (dObj->dmaDataLength == 32)
            {
                bufferObj->size /= 4;
            }
            SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)bufferObj->buffer, (const void *)dObj->txAddress, bufferObj->size);
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

    _DRV_I2S_ResourceUnlock(dObj);

    return;
}

// *****************************************************************************
void DRV_I2S_ReadBufferAdd( DRV_HANDLE handle, void * buffer, const size_t size, DRV_I2S_BUFFER_HANDLE * bufferHandle)
{
    DRV_I2S_OBJ * dObj = NULL;
    DRV_I2S_BUFFER_OBJ * bufferObj = NULL;
    DRV_I2S_BUFFER_OBJ * iterator = NULL;

    /* Validate the Request */
    if (bufferHandle == NULL)
    {
        return;
    }

    *bufferHandle = DRV_I2S_BUFFER_HANDLE_INVALID;

    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return;
    }

    dObj = &gDrvI2SObj[handle];

    if((size == 0) || (NULL == buffer))
    {
        return;
    }

    if(dObj->queueSizeCurrentRead >= dObj->queueSizeRead)
    {
        return;
    }

    _DRV_I2S_ResourceLock(dObj);

    /* Search the buffer pool for a free buffer object */
    bufferObj = _DRV_I2S_BufferObjectGet();

    if(NULL == bufferObj)
    {
        /* Couldn't able to get the buffer object */
        _DRV_I2S_ResourceUnlock(dObj);
        return;
    }

    /* Configure the buffer object */
    bufferObj->size            = size;
    bufferObj->nCount          = 0;
    bufferObj->inUse           = true;
    bufferObj->buffer          = buffer;
    bufferObj->dObj            = dObj;
    bufferObj->next            = NULL;
    bufferObj->currentState    = DRV_I2S_BUFFER_IS_IN_QUEUE;

    *bufferHandle = bufferObj->bufferHandle;

    dObj->queueSizeCurrentRead ++;

    if(dObj->queueRead == NULL)
    {
        /* This is the first buffer in the queue */
        dObj->queueRead = bufferObj;

        /* Because this is the first buffer in the queue, we need to submit the
         * buffer to the DMA to start processing. */
        bufferObj->currentState    = DRV_I2S_BUFFER_IS_PROCESSING;

        if( (DMA_CHANNEL_NONE != dObj->rxDMAChannel))
        {
            SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void *)dObj->rxAddress, (const void *)bufferObj->buffer, bufferObj->size);
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

    _DRV_I2S_ResourceUnlock(dObj);

    return;
}

// *****************************************************************************
size_t DRV_I2S_BufferCompletedBytesGet( DRV_I2S_BUFFER_HANDLE bufferHandle )
{
    DRV_I2S_BUFFER_OBJ * bufferObj = NULL;
    size_t processedBytes = DRV_I2S_BUFFER_HANDLE_INVALID;

    /* Validate the Request */
    if(DRV_I2S_BUFFER_HANDLE_INVALID == bufferHandle)
    {
        return DRV_I2S_BUFFER_HANDLE_INVALID;
    }

    /* The buffer index is the contained in the lower 16 bits of the buffer
     * handle */
    bufferObj = &gDrvI2SBufferObj[bufferHandle & _DRV_I2S_BUFFER_TOKEN_MAX];

    /* Check if the buffer is currently submitted */
    if( bufferObj->currentState != DRV_I2S_BUFFER_IS_PROCESSING )
    {
        /* get the nCount of buffer object */
        processedBytes = bufferObj->nCount;
    }

    /* Return the processed number of bytes..
     * If the buffer handle is invalid or bufferObj is expired
     * then return DRV_I2S_BUFFER_HANDLE_INVALID */
    return processedBytes;
}

// *****************************************************************************
DRV_I2S_BUFFER_EVENT DRV_I2S_BufferStatusGet( const DRV_I2S_BUFFER_HANDLE bufferHandle )
{
    DRV_I2S_BUFFER_OBJ * bufferObj = NULL;

    /* Validate the Request */
    if(DRV_I2S_BUFFER_HANDLE_INVALID == bufferHandle)
    {
        return DRV_I2S_BUFFER_EVENT_ERROR;
    }

    /* The buffer index is the contained in the lower 16 bits of the buffer
     * handle */
    bufferObj = &gDrvI2SBufferObj[bufferHandle & _DRV_I2S_BUFFER_TOKEN_MAX];

    return bufferObj->status;
}

// *****************************************************************************
bool DRV_I2S_WriteQueuePurge( const DRV_HANDLE handle )
{
    DRV_I2S_OBJ * dObj = NULL;

    /* Validate the Request */
    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return false;
    }

    dObj = &gDrvI2SObj[handle];

    return _DRV_I2S_WriteBufferQueuePurge(dObj);
}

// *****************************************************************************
bool DRV_I2S_ReadQueuePurge( const DRV_HANDLE handle )
{
    DRV_I2S_OBJ * dObj = NULL;

    /* Validate the Request */
    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return false;
    }

    dObj = &gDrvI2SObj[handle];

    return _DRV_I2S_ReadBufferQueuePurge(dObj);
}
