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
* © 2018 Microchip Technology Inc. and its subsidiaries.
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
    if( (SYS_DMA_CHANNEL_NONE != dObj->txDMAChannel) || (SYS_DMA_CHANNEL_NONE != dObj->rxDMAChannel))
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
    if( (SYS_DMA_CHANNEL_NONE != dObj->txDMAChannel) || (SYS_DMA_CHANNEL_NONE != dObj->rxDMAChannel))
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

static void _DRV_I2S_BufferQueueTask( DRV_I2S_OBJ *object, DRV_I2S_DIRECTION direction,
    DRV_I2S_BUFFER_EVENT event)
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

                if( (SYS_DMA_CHANNEL_NONE != dObj->rxDMAChannel))
                {
                    SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void *)dObj->rxAddress,
                        (const void *)newObj->rxbuffer, newObj->size);

#if defined (__DCACHE_PRESENT) && (__DCACHE_PRESENT == 1U)
                        /************ code specific to SAM E70 ********************/
                        // Check if the data cache is enabled
                        if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
                        {
                            uint32_t bufferSize = newObj->size;
                            // if this is half word transfer, need to multiply size by 2
                            if (dObj->dmaDataLength == 16)
                            {
                                bufferSize *= 2;
                            }
                            // if this is full word transfer, need to multiply size by 4
                            else if (dObj->dmaDataLength == 32)
                            {
                                bufferSize *= 4;
                            }
                            // Invalidate cache to force CPU to read from SRAM instead
                            SCB_InvalidateDCache_by_Addr((uint32_t*)newObj->rxbuffer, bufferSize);
                        }
                        /************ end of E70 specific code ********************/
#endif
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

                if( (SYS_DMA_CHANNEL_NONE != dObj->txDMAChannel))
                {
#if defined (__DCACHE_PRESENT) && (__DCACHE_PRESENT == 1U)
                    /************ code specific to SAM E70 ********************/
                    // Check if the data cache is enabled
                    if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
                    {
                        uint32_t bufferSize = newObj->size;
                        // if this is half word transfer, need to divide size by 2
                        if (dObj->dmaDataLength == 16)
                        {
                            bufferSize *= 2;
                        }
                        // if this is full word transfer, need to divide size by 4
                        else if (dObj->dmaDataLength == 32)
                        {
                            bufferSize *= 4;
                        }
                        // Flush cache to SRAM so DMA reads correct data
                        SCB_CleanDCache_by_Addr((uint32_t*)newObj->txbuffer, bufferSize);
                    }
                    /************ end of E70 specific code ********************/
#endif
                    SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)newObj->txbuffer,
                        (const void *)dObj->txAddress, newObj->size);
                }
            }
        }
    }
    else
    {
        /* Queue purge has been called. Do nothing. */
    }
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
    if(SYS_DMA_CHANNEL_NONE != dObj->txDMAChannel)
    {
        SYS_DMA_ChannelCallbackRegister(dObj->txDMAChannel, _DRV_I2S_TX_DMA_CallbackHandler, (uintptr_t)dObj);
    }

    if(SYS_DMA_CHANNEL_NONE != dObj->rxDMAChannel)
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
void DRV_I2S_BufferEventHandlerSet( const DRV_HANDLE handle,
    const DRV_I2S_BUFFER_EVENT_HANDLER eventHandler, const uintptr_t context )
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
}

// *****************************************************************************
void DRV_I2S_WriteBufferAdd( DRV_HANDLE handle, void * buffer, const size_t size,
    DRV_I2S_BUFFER_HANDLE * bufferHandle)
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
    bufferObj->txbuffer     = buffer;
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

        if( (SYS_DMA_CHANNEL_NONE != dObj->txDMAChannel))
        {
#if defined (__DCACHE_PRESENT) && (__DCACHE_PRESENT == 1U)
            /************ code specific to SAM E70 ********************/
            // Check if the data cache is enabled
            if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
            {
                // Flush cache to SRAM so DMA reads correct data
                SCB_CleanDCache_by_Addr((uint32_t*)bufferObj->txbuffer, bufferObj->size);
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
            SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)bufferObj->txbuffer,
                (const void *)dObj->txAddress, bufferObj->size);
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
}

// *****************************************************************************
/* Function:
	void DRV_I2S_BufferAddWriteRead(const DRV_HANDLE handle,
                                        DRV_I2S_BUFFER_HANDLE	*bufferHandle,
                                        void *transmitBuffer, void *receiveBuffer,
                                        size_t size)

  Summary:
    Schedule a non-blocking driver write-read operation.
	<p><b>Implementation:</b> Dynamic</p>

  Description:
    This function schedules a non-blocking write-read operation. The function
    returns with a valid buffer handle in the bufferHandle argument if the
    write-read request was scheduled successfully. The function adds the request
    to the hardware instance queue and returns immediately. While the request is
    in the queue, the application buffer is owned by the driver and should not
    be modified. The function returns DRV_I2S_BUFFER_HANDLE_INVALID:
    - if a buffer could not be allocated to the request
    - if the input buffer pointer is NULL
    - if the client opened the driver for read only or write only
    - if the buffer size is 0
    - if the queue is full or the queue depth is insufficient
    If the requesting client registered an event callback with the driver,
    the driver will issue a DRV_I2S_BUFFER_EVENT_COMPLETE event if the buffer
    was processed successfully of DRV_I2S_BUFFER_EVENT_ERROR event if the
    buffer was not processed successfully.

  Remarks:
    This function is thread safe in a RTOS application. It can be called from
    within the I2S Driver Buffer Event Handler that is registered by this
    client. It should not be called in the event handler associated with another
    I2S driver instance. It should not otherwise be called directly in an ISR.

    This function is useful when there is valid read expected for every
    I2S write. The transmit and receive size must be same.

*/
void DRV_I2S_WriteReadBufferAdd(const DRV_HANDLE handle,
    void *transmitBuffer, void *receiveBuffer,
    size_t size, DRV_I2S_BUFFER_HANDLE	*bufferHandle)
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

    if((size == 0) || (NULL == transmitBuffer) || (NULL == receiveBuffer))
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
    bufferObj->txbuffer     = transmitBuffer;
    bufferObj->rxbuffer     = receiveBuffer;
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

        if( (SYS_DMA_CHANNEL_NONE != dObj->rxDMAChannel) && (SYS_DMA_CHANNEL_NONE != dObj->txDMAChannel))
        {
            uint32_t bufferSize = bufferObj->size;
            // if this is half word transfer, need to divide size by 2
            if (dObj->dmaDataLength == 16)
            {
                bufferSize /= 2;
            }
            // if this is full word transfer, need to divide size by 4
            else if (dObj->dmaDataLength == 32)
            {
                bufferSize /= 4;
            }
            SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void *)dObj->rxAddress,
                (const void *)bufferObj->rxbuffer, bufferSize);

#if defined (__DCACHE_PRESENT) && (__DCACHE_PRESENT == 1U)
            /************ code specific to SAM E70 ********************/
            // Check if the data cache is enabled
            if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
            {
                // Invalidate cache to force CPU to read from SRAM instead
                SCB_InvalidateDCache_by_Addr((uint32_t*)bufferObj->rxbuffer, bufferObj->size);

                // Flush cache to SRAM so DMA reads correct data
                SCB_CleanDCache_by_Addr((uint32_t*)bufferObj->txbuffer, bufferObj->size);
            }
            /************ end of E70 specific code ********************/
#endif
            SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)bufferObj->txbuffer,
                (const void *)dObj->txAddress, bufferSize);
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
}

// *****************************************************************************
void DRV_I2S_ReadBufferAdd( DRV_HANDLE handle, void * buffer, const size_t size,
    DRV_I2S_BUFFER_HANDLE * bufferHandle)
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
    bufferObj->rxbuffer        = buffer;
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

        if( (SYS_DMA_CHANNEL_NONE != dObj->rxDMAChannel))
        {
            uint32_t bufferSize = bufferObj->size;
            // if this is half word transfer, need to divide size by 2
            if (dObj->dmaDataLength == 16)
            {
                bufferSize /= 2;
            }
            // if this is full word transfer, need to divide size by 4
            else if (dObj->dmaDataLength == 32)
            {
                bufferSize /= 4;
            }

            SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void *)dObj->rxAddress,
                (const void *)bufferObj->rxbuffer, bufferSize);

#if defined (__DCACHE_PRESENT) && (__DCACHE_PRESENT == 1U)
            /************ code specific to SAM E70 ********************/
            // Check if the data cache is enabled
            if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
            {
                // Invalidate cache to force CPU to read from SRAM instead
                SCB_InvalidateDCache_by_Addr((uint32_t*)bufferObj->rxbuffer, bufferObj->size);
            }
            /************ end of E70 specific code ********************/
#endif
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

<#if DRV_I2S_DMA_LL_ENABLE == true>
__attribute__((__aligned__(32))) static XDMAC_DESCRIPTOR_CONTROL _firstDescriptorControl =
{
    .fetchEnable = 1,
    .sourceUpdate = 1,
    .destinationUpdate = 1,
    .view = 1
};

void _LinkedListCallBack(XDMAC_TRANSFER_EVENT event, uintptr_t contextHandle)
{
    if ((XDMAC_TRANSFER_COMPLETE==event) && (contextHandle!=(uintptr_t)NULL))
    {
        DRV_I2S_LL_CALLBACK callBack = (DRV_I2S_LL_CALLBACK)contextHandle;
        callBack();
    }
}

void DRV_I2S_InitWriteLinkedListTransfer(DRV_HANDLE handle, XDMAC_DESCRIPTOR_VIEW_1* pLinkedListDesc,
    uint16_t currDescrip, uint16_t nextDescrip, uint8_t* buffer, uint32_t bufferSize)
{
    DRV_I2S_OBJ * dObj = NULL;
    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return;
    }
    dObj = &gDrvI2SObj[handle];

    // if currDescrip same as nextDescrip, then will loop
    pLinkedListDesc[currDescrip].mbr_nda = (uint32_t)&pLinkedListDesc[nextDescrip];
    pLinkedListDesc[currDescrip].mbr_sa = (uint32_t)buffer;
    pLinkedListDesc[currDescrip].mbr_da = (uint32_t)dObj->txAddress;
    // if this is half word transfer, need to divide size by 2
    if (dObj->dmaDataLength == 16)
    {
        bufferSize /= 2;
    }
    // if this is full word transfer, need to divide size by 4
    else if (dObj->dmaDataLength == 32)
    {
        bufferSize /= 4;
    }
    pLinkedListDesc[currDescrip].mbr_ubc.blockDataLength = bufferSize;
    pLinkedListDesc[currDescrip].mbr_ubc.nextDescriptorControl.fetchEnable = 1;
    pLinkedListDesc[currDescrip].mbr_ubc.nextDescriptorControl.sourceUpdate = 1;
    pLinkedListDesc[currDescrip].mbr_ubc.nextDescriptorControl.destinationUpdate = 0;
    pLinkedListDesc[currDescrip].mbr_ubc.nextDescriptorControl.view = 1;
}

void DRV_I2S_StartWriteLinkedListTransfer(DRV_HANDLE handle, XDMAC_DESCRIPTOR_VIEW_1* pLinkedListDesc,
        DRV_I2S_LL_CALLBACK callBack, bool blockInt)
{
    DRV_I2S_OBJ * dObj = NULL;
    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return;
    }
    dObj = &gDrvI2SObj[handle];

    if( (SYS_DMA_CHANNEL_NONE != dObj->txDMAChannel))
    {
#if defined (__DCACHE_PRESENT) && (__DCACHE_PRESENT == 1U)
        /************ code specific to SAM E70 ********************/
        // Check if the data cache is enabled
        if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
        {
            // Flush cache to SRAM so DMA reads correct data
            SCB_CleanDCache_by_Addr((uint32_t*)&_firstDescriptorControl, sizeof(XDMAC_DESCRIPTOR_CONTROL));
            SCB_CleanDCache_by_Addr((uint32_t*)&pLinkedListDesc[0], sizeof(XDMAC_DESCRIPTOR_VIEW_1));
            uint32_t bufferSize = pLinkedListDesc[0].mbr_ubc.blockDataLength;
            // if this is half word transfer, need to multiply size by 2
            if (dObj->dmaDataLength == 16)
            {
                bufferSize *= 2;
            }
            // if this is full word transfer, need to multiply size by 4
            else if (dObj->dmaDataLength == 32)
            {
                bufferSize *= 4;
            }
            SCB_CleanDCache_by_Addr((uint32_t*)pLinkedListDesc[0].mbr_sa, bufferSize);
        }
        /************ end of E70 specific code ********************/
#endif
        XDMAC_ChannelLinkedListTransfer(dObj->txDMAChannel, (uint32_t)&pLinkedListDesc[0], &_firstDescriptorControl);

        if ((void*)NULL!=callBack)
        {
            XDMAC_ChannelCallbackRegister(dObj->txDMAChannel,(XDMAC_CHANNEL_CALLBACK)_LinkedListCallBack, (uintptr_t)callBack);

            if (blockInt)
            {
                // disable end of linked list interrupt, and enable end of block instead
                XDMAC_REGS->XDMAC_CHID[dObj->txDMAChannel].XDMAC_CID= XDMAC_CID_LID_Msk ;
                XDMAC_REGS->XDMAC_CHID[dObj->txDMAChannel].XDMAC_CIE= XDMAC_CIE_BIE_Msk ;
            }
        }
    }
}

void DRV_I2S_WriteNextLinkedListTransfer(DRV_HANDLE handle, XDMAC_DESCRIPTOR_VIEW_1* pLinkedListDesc,
        uint16_t currDescrip, uint16_t nextDescrip, uint16_t nextNextDescrip, uint8_t* buffer, uint32_t bufferSize)
{
    DRV_I2S_OBJ * dObj = NULL;
    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return;
    }
    dObj = &gDrvI2SObj[handle];

#if defined (__DCACHE_PRESENT) && (__DCACHE_PRESENT == 1U)
    /************ code specific to SAM E70 ********************/
    // Check if the data cache is enabled
    if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
    {
        // Flush cache to SRAM so DMA reads correct data
        SCB_CleanDCache_by_Addr((uint32_t*)&pLinkedListDesc[currDescrip], sizeof(XDMAC_DESCRIPTOR_VIEW_1));
        SCB_CleanDCache_by_Addr((uint32_t*)&pLinkedListDesc[nextDescrip], sizeof(XDMAC_DESCRIPTOR_VIEW_1));
        SCB_CleanDCache_by_Addr((uint32_t*)buffer, bufferSize);
    }
    /************ end of E70 specific code ********************/
#endif
    pLinkedListDesc[nextDescrip].mbr_sa = (uint32_t)buffer;
    // if this is half word transfer, need to divide size by 2
    if (dObj->dmaDataLength == 16)
    {
        bufferSize /= 2;
    }
    // if this is full word transfer, need to divide size by 4
    else if (dObj->dmaDataLength == 32)
    {
        bufferSize /= 4;
    }
    pLinkedListDesc[nextDescrip].mbr_ubc.blockDataLength = bufferSize;
    // if nextDescrip same as nextNextDescrip, then will loop
    pLinkedListDesc[nextDescrip].mbr_nda = (uint32_t)&pLinkedListDesc[nextNextDescrip];
    // switch from currDescrip to nextDescrip next time
    pLinkedListDesc[currDescrip].mbr_nda = (uint32_t)&pLinkedListDesc[nextDescrip];
}

void DRV_I2S_InitReadLinkedListTransfer(DRV_HANDLE handle, XDMAC_DESCRIPTOR_VIEW_1* pLinkedListDesc,
    uint16_t currDescrip, uint16_t nextDescrip, uint8_t* buffer, uint32_t bufferSize)
{
    DRV_I2S_OBJ * dObj = NULL;
    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return;
    }
    dObj = &gDrvI2SObj[handle];

    // if currDescrip same as nextDescrip, then will loop
    pLinkedListDesc[currDescrip].mbr_nda = (uint32_t)&pLinkedListDesc[nextDescrip];
    pLinkedListDesc[currDescrip].mbr_sa = (uint32_t)dObj->rxAddress;
    pLinkedListDesc[currDescrip].mbr_da = (uint32_t)buffer;
    // if this is half word transfer, need to divide size by 2
    if (dObj->dmaDataLength == 16)
    {
        bufferSize /= 2;
    }
    // if this is full word transfer, need to divide size by 4
    else if (dObj->dmaDataLength == 32)
    {
        bufferSize /= 4;
    }
    pLinkedListDesc[currDescrip].mbr_ubc.blockDataLength = bufferSize;
    pLinkedListDesc[currDescrip].mbr_ubc.nextDescriptorControl.fetchEnable = 1;
    pLinkedListDesc[currDescrip].mbr_ubc.nextDescriptorControl.sourceUpdate = 0;
    pLinkedListDesc[currDescrip].mbr_ubc.nextDescriptorControl.destinationUpdate = 1;
    pLinkedListDesc[currDescrip].mbr_ubc.nextDescriptorControl.view = 1;
}

void DRV_I2S_StartReadLinkedListTransfer(DRV_HANDLE handle, XDMAC_DESCRIPTOR_VIEW_1* pLinkedListDesc,
            DRV_I2S_LL_CALLBACK callBack, bool blockInt)
{
    DRV_I2S_OBJ * dObj = NULL;
    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return;
    }
    dObj = &gDrvI2SObj[handle];

    if( (SYS_DMA_CHANNEL_NONE != dObj->rxDMAChannel))
    {
#if defined (__DCACHE_PRESENT) && (__DCACHE_PRESENT == 1U)
        /************ code specific to SAM E70 ********************/
        // Check if the data cache is enabled
        if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
        {
            // Flush cache to SRAM so DMA reads correct data
            SCB_CleanDCache_by_Addr((uint32_t*)&_firstDescriptorControl, sizeof(XDMAC_DESCRIPTOR_CONTROL));
            SCB_CleanDCache_by_Addr((uint32_t*)&pLinkedListDesc[0], sizeof(XDMAC_DESCRIPTOR_VIEW_1));
        }
        /************ end of E70 specific code ********************/
#endif

        XDMAC_ChannelLinkedListTransfer(dObj->rxDMAChannel, (uint32_t)&pLinkedListDesc[0], &_firstDescriptorControl);

#if defined (__DCACHE_PRESENT) && (__DCACHE_PRESENT == 1U)
        /************ code specific to SAM E70 ********************/
        // Check if the data cache is enabled
        if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
        {
            uint32_t bufferSize = pLinkedListDesc[0].mbr_ubc.blockDataLength;
            // if this is half word transfer, need to multiply size by 2
            if (dObj->dmaDataLength == 16)
            {
                bufferSize *= 2;
            }
            // if this is full word transfer, need to multiply size by 4
            else if (dObj->dmaDataLength == 32)
            {
                bufferSize *= 4;
            }
            // Invalidate cache to force CPU to read from SRAM instead
            SCB_InvalidateDCache_by_Addr((uint32_t*)pLinkedListDesc[0].mbr_da, bufferSize);
        }
        /************ end of E70 specific code ********************/

        if ((void*)NULL!=callBack)
        {
            XDMAC_ChannelCallbackRegister(dObj->rxDMAChannel,(XDMAC_CHANNEL_CALLBACK)_LinkedListCallBack, (uintptr_t)callBack);

            if (blockInt)
            {
                // disable end of linked list interrupt, and enable end of block instead
                XDMAC_REGS->XDMAC_CHID[dObj->rxDMAChannel].XDMAC_CID= XDMAC_CID_LID_Msk ;
                XDMAC_REGS->XDMAC_CHID[dObj->rxDMAChannel].XDMAC_CIE= XDMAC_CIE_BIE_Msk ;
            }
        }
#endif
    }
}

void DRV_I2S_ReadNextLinkedListTransfer(DRV_HANDLE handle, XDMAC_DESCRIPTOR_VIEW_1* pLinkedListDesc,
        uint16_t currDescrip, uint16_t nextDescrip, uint16_t nextNextDescrip, uint8_t* buffer, uint32_t bufferSize)
{
    DRV_I2S_OBJ * dObj = NULL;
    if( false == _DRV_I2S_ValidateClientHandle(dObj, handle))
    {
        return;
    }
    dObj = &gDrvI2SObj[handle];

#if defined (__DCACHE_PRESENT) && (__DCACHE_PRESENT == 1U)
    /************ code specific to SAM E70 ********************/
    // Check if the data cache is enabled
    if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
    {
        // Flush cache to SRAM so DMA reads correct data
        SCB_CleanDCache_by_Addr((uint32_t*)&pLinkedListDesc[currDescrip], sizeof(XDMAC_DESCRIPTOR_VIEW_1));
        SCB_CleanDCache_by_Addr((uint32_t*)&pLinkedListDesc[nextDescrip], sizeof(XDMAC_DESCRIPTOR_VIEW_1));
    }
    /************ end of E70 specific code ********************/
#endif
    pLinkedListDesc[nextDescrip].mbr_da = (uint32_t)buffer;
    // if this is half word transfer, need to divide size by 2
    uint32_t blockLength = bufferSize;
    if (dObj->dmaDataLength == 16)
    {
        blockLength /= 2;
    }
    // if this is full word transfer, need to divide size by 4
    else if (dObj->dmaDataLength == 32)
    {
        blockLength /= 4;
    }
    pLinkedListDesc[nextDescrip].mbr_ubc.blockDataLength = blockLength;
    // if nextDescrip same as nextNextDescrip, then will loop
    pLinkedListDesc[nextDescrip].mbr_nda = (uint32_t)&pLinkedListDesc[nextNextDescrip];
    // switch from currDescrip to nextDescrip next time
    pLinkedListDesc[currDescrip].mbr_nda = (uint32_t)&pLinkedListDesc[nextDescrip];
#if defined (__DCACHE_PRESENT) && (__DCACHE_PRESENT == 1U)
    /************ code specific to SAM E70 ********************/
    // Check if the data cache is enabled
    if( (SCB->CCR & SCB_CCR_DC_Msk) == SCB_CCR_DC_Msk)
    {
        // Invalidate cache to force CPU to read from SRAM instead
        SCB_InvalidateDCache_by_Addr((uint32_t*)buffer, bufferSize);
    }
    /************ end of E70 specific code ********************/
#endif
}

</#if>