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
Copyright (c) 2017 released Microchip Technology Inc.  All rights reserved.

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
#include "driver/usart/drv_usart.h"
#include "drv_usart_local.h"

//SYS_DEBUG is not available yet, hence commented for now.
//#include "system/debug/sys_debug.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data
// *****************************************************************************
// *****************************************************************************

/* This is the driver instance object array. */
DRV_USART_OBJ gDrvUSARTObj[DRV_USART_INSTANCES_NUMBER] ;

// *****************************************************************************
// *****************************************************************************
// Section: File scope functions
// *****************************************************************************
// *****************************************************************************

static void _DRV_USART_TX_PLIB_CallbackHandler( uintptr_t context )
{
    DRV_USART_OBJ *dObj = (DRV_USART_OBJ *)context;    

    dObj->txRequestStatus = DRV_USART_REQUEST_STATUS_COMPLETE;

    OSAL_SEM_PostISR(&dObj->txTransferDone);
}

static void _DRV_USART_RX_PLIB_CallbackHandler( uintptr_t context )
{
    DRV_USART_OBJ *dObj = (DRV_USART_OBJ *)context;
    DRV_USART_CLIENT_OBJ* clientObj = (DRV_USART_CLIENT_OBJ*)dObj->currentRxClient;

    clientObj->errors = dObj->usartPlib->errorGet();

    if(clientObj->errors == DRV_USART_ERROR_NONE)
    {
        dObj->rxRequestStatus = DRV_USART_REQUEST_STATUS_COMPLETE;
    }
    else
    {
        dObj->rxRequestStatus = DRV_USART_REQUEST_STATUS_ERROR;
    }

    OSAL_SEM_PostISR(&dObj->rxTransferDone);
}

static void _DRV_USART_TX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{
    DRV_USART_OBJ *dObj = (DRV_USART_OBJ *)context;    

    if(event == SYS_DMA_TRANSFER_COMPLETE)
    {
        dObj->txRequestStatus = DRV_USART_REQUEST_STATUS_COMPLETE;
    }
    else if(event == SYS_DMA_TRANSFER_ERROR)
    {
        dObj->txRequestStatus = DRV_USART_REQUEST_STATUS_ERROR;
    }

    OSAL_SEM_PostISR(&dObj->txTransferDone);
}

static void _DRV_USART_RX_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{
    DRV_USART_OBJ *dObj = (DRV_USART_OBJ *)context;    

    if(event == SYS_DMA_TRANSFER_COMPLETE)
    {
        dObj->rxRequestStatus = DRV_USART_REQUEST_STATUS_COMPLETE;
    }
    else if(event == SYS_DMA_TRANSFER_ERROR)
    {
        dObj->rxRequestStatus = DRV_USART_REQUEST_STATUS_ERROR;
    }

    OSAL_SEM_PostISR(&dObj->rxTransferDone);
}

static DRV_USART_CLIENT_OBJ* DRV_USART_DriverHandleValidate(DRV_HANDLE handle)
{
    /* This function returns the pointer to the client object that is
       associated with this handle if the handle is valid. Returns NULL
       otherwise. 
    */
    uint32_t drvInstance = 0;
    DRV_USART_CLIENT_OBJ* clientObj = NULL;

    if((handle != DRV_HANDLE_INVALID) && (handle != 0))
    {
        /* Extract the instance value from the handle */
        drvInstance = ((handle & DRV_USART_INSTANCE_MASK) >> 8);

        clientObj = &((DRV_USART_CLIENT_OBJ *)gDrvUSARTObj[drvInstance].clientObjPool)[handle & DRV_USART_INDEX_MASK];

        if ((handle != clientObj->clientHandle) || (clientObj->inUse == false))
        {
            return (NULL);
        }
    }

    return(clientObj);
}

// *****************************************************************************
// *****************************************************************************
// Section: USART Driver Common Interface Implementation
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
SYS_MODULE_OBJ DRV_USART_Initialize( const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT * const init )
{
    DRV_USART_OBJ *dObj = NULL;
    DRV_USART_INIT *usartInit = (DRV_USART_INIT *)init ;

    /* Validate the request */
    if(drvIndex >= DRV_USART_INSTANCES_NUMBER)
    {
        //SYS_DEBUG(SYS_ERROR_ERROR, "Invalid driver instance");
        return SYS_MODULE_OBJ_INVALID;
    }

    if(gDrvUSARTObj[drvIndex].inUse != false)
    {
        //SYS_DEBUG(SYS_ERROR_ERROR, "Instance already in use");
        return SYS_MODULE_OBJ_INVALID;
    }

    /* Allocate the driver object */
    dObj                        = &gDrvUSARTObj[drvIndex];
    dObj->inUse                 = true;
    dObj->usartPlib             = usartInit->usartPlib;
    dObj->clientObjPool         = usartInit->clientObjPool;
    dObj->nClientsMax           = usartInit->numClients;
    dObj->nClients              = 0;
    dObj->currentRxClient       = (uintptr_t)NULL;
    dObj->currentTxClient       = (uintptr_t)NULL;
    dObj->isExclusive           = false;
    dObj->usartTokenCount       = 1;  
    dObj->txDMAChannel          = usartInit->dmaChannelTransmit;
    dObj->rxDMAChannel          = usartInit->dmaChannelReceive;
    dObj->txAddress             = usartInit->usartTransmitAddress;
    dObj->rxAddress             = usartInit->usartReceiveAddress;    

    if (OSAL_MUTEX_Create(&dObj->instanceMutex) == OSAL_RESULT_FALSE)
    {
        /*  If the mutex was not created because the memory required to
            hold the mutex could not be allocated then NULL is returned. */
        return SYS_MODULE_OBJ_INVALID;
    }

    if (OSAL_MUTEX_Create(&dObj->txMutex) == OSAL_RESULT_FALSE)
    {
        /*  If the mutex was not created because the memory required to
            hold the mutex could not be allocated then NULL is returned. */
        return SYS_MODULE_OBJ_INVALID;
    }

    if (OSAL_MUTEX_Create(&dObj->rxMutex) == OSAL_RESULT_FALSE)
    {
        /*  If the mutex was not created because the memory required to
            hold the mutex could not be allocated then NULL is returned. */
        return SYS_MODULE_OBJ_INVALID;
    }

    if (OSAL_SEM_Create(&dObj->txTransferDone, OSAL_SEM_TYPE_BINARY, 0, 0) == OSAL_RESULT_FALSE)
    {
        /* There was insufficient memory available for the semaphore to
        be created successfully. */
        return SYS_MODULE_OBJ_INVALID;
    }

    if (OSAL_SEM_Create(&dObj->rxTransferDone, OSAL_SEM_TYPE_BINARY, 0, 0) == OSAL_RESULT_FALSE)
    {
        /* There was insufficient memory available for the semaphore to
        be created successfully. */
        return SYS_MODULE_OBJ_INVALID;
    }

    /* Register a callback with either DMA or USART PLIB based on configuration.
     * dObj is used as a context parameter, that will be used to distinguish the
     * events for different driver instances. */
    if(dObj->txDMAChannel != DMA_CHANNEL_NONE)
    {
        SYS_DMA_ChannelCallbackRegister(dObj->txDMAChannel, _DRV_USART_TX_DMA_CallbackHandler, (uintptr_t)dObj);
    }
    else
    {
        dObj->usartPlib->writeCallbackRegister(_DRV_USART_TX_PLIB_CallbackHandler, (uintptr_t)dObj);
        (void)_DRV_USART_TX_DMA_CallbackHandler;
    }

    if(dObj->rxDMAChannel != DMA_CHANNEL_NONE)
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

// *****************************************************************************
SYS_STATUS DRV_USART_Status( SYS_MODULE_OBJ object)
{
    /* Validate the request */
    if( (object == SYS_MODULE_OBJ_INVALID) || (object >= DRV_USART_INSTANCES_NUMBER) )
    {
        //SYS_DEBUG(SYS_ERROR_ERROR, "Invalid system object handle");
        return SYS_STATUS_UNINITIALIZED;
    }

    return (gDrvUSARTObj[object].status);
}

// *****************************************************************************
DRV_HANDLE DRV_USART_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    DRV_USART_OBJ *dObj = NULL;
    DRV_USART_CLIENT_OBJ *clientObj = NULL;
    uint32_t iClient;

    /* Validate the request */
    if (drvIndex >= DRV_USART_INSTANCES_NUMBER)
    {
        //SYS_DEBUG(SYS_ERROR_ERROR, "Invalid Driver Instance");
        return DRV_HANDLE_INVALID;
    }

    dObj = &gDrvUSARTObj[drvIndex];

    if(dObj->status != SYS_STATUS_READY)
    {
        //SYS_DEBUG(SYS_ERROR_ERROR, "Was the driver initialized?");
        return DRV_HANDLE_INVALID;
    }

    /* Acquire the instance specific mutex to protect the instance specific
     * client pool
     */
    if (OSAL_MUTEX_Lock(&dObj->instanceMutex , OSAL_WAIT_FOREVER ) == OSAL_RESULT_FALSE)
    {
        return DRV_HANDLE_INVALID;
    }

    if(dObj->isExclusive)
    {
        /* This means the another client has opened the driver in exclusive
           mode. The driver cannot be opened again */
        OSAL_MUTEX_Unlock( &dObj->instanceMutex);
        return DRV_HANDLE_INVALID;
    }

    if((dObj->nClients > 0) && (ioIntent & DRV_IO_INTENT_EXCLUSIVE))
    {
        /* This means the driver was already opened and another driver was
           trying to open it exclusively.  We cannot give exclusive access in
           this case */
        OSAL_MUTEX_Unlock( &dObj->instanceMutex);
        return(DRV_HANDLE_INVALID);
    }

    /* Enter here only if the lock was obtained */

    for(iClient = 0; iClient != dObj->nClientsMax; iClient++)
    {        
        if(false == ((DRV_USART_CLIENT_OBJ *)dObj->clientObjPool)[iClient].inUse)
        {
            /* This means we have a free client object to use */
            
            clientObj = &((DRV_USART_CLIENT_OBJ *)dObj->clientObjPool)[iClient];
                        
            clientObj->inUse        = true;

            clientObj->hDriver      = dObj;

            clientObj->ioIntent     = ioIntent;

            clientObj->errors       = DRV_USART_ERROR_NONE;

            if(ioIntent & DRV_IO_INTENT_EXCLUSIVE)
            {
                /* Set the driver exclusive flag */
                dObj->isExclusive = true;
            }

            dObj->nClients ++;

            /* Generate and save client handle in the client object, which will
             * be then used to verify the validity of the client handle.
             */
            clientObj->clientHandle = DRV_USART_MAKE_HANDLE(dObj->usartTokenCount, drvIndex, iClient);

            /* Increment the instance specific token counter */
            DRV_USART_UPDATE_TOKEN(dObj->usartTokenCount);

            break;
        }
    }

    OSAL_MUTEX_Unlock(&dObj->instanceMutex);

    /* Driver index is the handle */
    return clientObj ? ((DRV_HANDLE)clientObj->clientHandle) : DRV_HANDLE_INVALID;
}

bool DRV_USART_SerialSetup( const DRV_HANDLE handle, DRV_USART_SERIAL_SETUP* setup )
{
    DRV_USART_OBJ * dObj = NULL;

    /* Validate the request */
    if(DRV_USART_DriverHandleValidate(handle) == NULL)
    {
        return DRV_USART_ERROR_NONE;
    }

    /* Clock source cannot be modified dynamically, so passing the '0' to pick
     * the configured clock source value */
    return dObj->usartPlib->serialSetup(setup, 0);
}

// *****************************************************************************
void DRV_USART_Close( DRV_HANDLE handle )
{
    DRV_USART_CLIENT_OBJ* clientObj;
    DRV_USART_OBJ* dObj;

    /* Validate the handle */
    clientObj = DRV_USART_DriverHandleValidate(handle);

    if(clientObj != NULL)
    {
        dObj = (DRV_USART_OBJ *)clientObj->hDriver;

        /* Acquire the instance specifc mutex to protect the instance specific
         * client pool
         */
        if (OSAL_MUTEX_Lock(&dObj->instanceMutex , OSAL_WAIT_FOREVER ) == OSAL_RESULT_TRUE)
        {
            /* Reduce the number of clients */
            dObj->nClients --;

            /* Reset the exclusive flag */
            dObj->isExclusive = false;

            /* De-allocate the object */
            clientObj->inUse = false;

            /* Release the instance specific mutex */
            OSAL_MUTEX_Unlock( &dObj->instanceMutex );
        }
    }
}

DRV_USART_ERROR DRV_USART_ErrorGet( const DRV_HANDLE handle )
{
    DRV_USART_CLIENT_OBJ* clientObj;
    DRV_USART_ERROR errors = DRV_USART_ERROR_NONE;

    /* Validate the handle */
    clientObj = DRV_USART_DriverHandleValidate(handle);

    if(clientObj != NULL)
    {
        errors = clientObj->errors;
    }

    return errors;
}
// *****************************************************************************
bool DRV_USART_Write
(
    const DRV_HANDLE handle,
    void* buffer,
    const size_t numbytes
)
{
    DRV_USART_CLIENT_OBJ* clientObj = (DRV_USART_CLIENT_OBJ *)NULL;
    DRV_USART_OBJ* dObj = NULL;
    bool isSuccess = false;

    /* Validate the driver handle */
    clientObj = DRV_USART_DriverHandleValidate(handle);

    if((clientObj != NULL) && (numbytes != 0) && (buffer != NULL))
    {
        dObj = clientObj->hDriver;

        /* Obtain transmit mutex */
        if (OSAL_MUTEX_Lock(&dObj->txMutex, OSAL_WAIT_FOREVER) == OSAL_RESULT_TRUE)
        {
            /* Error is cleared for every new transfer */
            clientObj->errors = DRV_USART_ERROR_NONE;

            dObj->currentTxClient = (uintptr_t)clientObj;

            if( dObj->txDMAChannel != DMA_CHANNEL_NONE)
            {
                SYS_DMA_ChannelTransfer(dObj->txDMAChannel, (const void *)buffer, (const void *)dObj->txAddress, numbytes);
            }
            else
            {
                dObj->usartPlib->write(buffer, numbytes);
            }

            /* Wait for transfer to complete */
            if (OSAL_SEM_Pend(&dObj->txTransferDone, OSAL_WAIT_FOREVER) == OSAL_RESULT_TRUE)
            {
                if (dObj->txRequestStatus == DRV_USART_REQUEST_STATUS_COMPLETE)
                {
                   isSuccess = true;
                }                
            }
            /* Release transmit mutex */
            OSAL_MUTEX_Unlock(&dObj->txMutex);
        }
    }
    return isSuccess;
}

// *****************************************************************************
bool DRV_USART_Read
(
    const DRV_HANDLE handle,
    void* buffer,
    const size_t numbytes
)
{
    DRV_USART_CLIENT_OBJ* clientObj = (DRV_USART_CLIENT_OBJ *)NULL;
    DRV_USART_OBJ* dObj = NULL;
    bool isSuccess = false;

    /* Validate the driver handle */
    clientObj = DRV_USART_DriverHandleValidate(handle);

    if((clientObj != NULL) && (numbytes != 0) && (buffer != NULL))
    {
        dObj = clientObj->hDriver;

        /* Obtain receive mutex */
        if (OSAL_MUTEX_Lock(&dObj->rxMutex, OSAL_WAIT_FOREVER) == OSAL_RESULT_TRUE)
        {
            /* Error is cleared for every new transfer */
            clientObj->errors = DRV_USART_ERROR_NONE;

            dObj->currentRxClient = (uintptr_t)clientObj;

            if(dObj->rxDMAChannel != DMA_CHANNEL_NONE)
            {
                SYS_DMA_ChannelTransfer(dObj->rxDMAChannel, (const void *)dObj->rxAddress, (const void *)buffer, numbytes);
            }
            else
            {
                dObj->usartPlib->read(buffer, numbytes);
            }

            /* Wait for transfer to complete */
            if (OSAL_SEM_Pend(&dObj->rxTransferDone, OSAL_WAIT_FOREVER) == OSAL_RESULT_TRUE)
            {
                /* Check and return status */
                if (dObj->rxRequestStatus == DRV_USART_REQUEST_STATUS_COMPLETE)
                {
                    isSuccess = true;
                }                
            }
            /* Release receive mutex */
            OSAL_MUTEX_Unlock(&dObj->rxMutex);
        }
    }
    return isSuccess;
}
