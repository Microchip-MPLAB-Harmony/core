/*******************************************************************************
  I2S Driver Interface Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_i2s.h

  Summary:
    I2S Driver Interface Header File

  Description:
    The I2S device driver provides a simple interface to manage the I2S or
    SSC modules on Microchip PIC32 microcontrollers.  This file provides the
    interface definition for the I2S driver.
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

#ifndef DRV_I2S_H
#define DRV_I2S_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include "drv_i2s_definitions.h"

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Data Types
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* I2S Driver Buffer Handle

  Summary:
    Handle identifying a read or write buffer passed to the driver.

  Description:
    A buffer handle value is returned by a call to the DRV_I2S_ReadBufferAdd
    or DRV_I2S_WriteBufferAdd functions. This handle is associated with the
    buffer passed into the function and it allows the application to track the
    completion of the data from (or into) that buffer.  The buffer handle value
    returned from the "buffer add" function is returned back to the client
    by the "event handler callback" function registered with the driver.

    The buffer handle assigned to a client request expires when the client has
    been notified of the completion of the buffer transfer (after event handler
    function that notifies the client returns) or after the buffer has been
    retired by the driver if no event handler callback was set.

  Remarks:
    None
*/

typedef uintptr_t DRV_I2S_BUFFER_HANDLE;

// *****************************************************************************
/* I2S Driver Invalid Buffer Handle

  Summary:
    Definition of an invalid buffer handle.

  Description:
    This is the definition of an invalid buffer handle. An invalid buffer handle
    is returned by DRV_I2S_ReadBufferAdd and DRV_I2S_WriteBufferAdd
    functions if the buffer add request was not successful.

  Remarks:
    None
*/

#define DRV_I2S_BUFFER_HANDLE_INVALID /*DOM-IGNORE-BEGIN*/((DRV_I2S_BUFFER_HANDLE)(-1))/*DOM-IGNORE-END*/

// *****************************************************************************
/* I2S Driver Buffer Events

   Summary
    Identifies the possible events that can result from a buffer add request.

   Description
    This enumeration identifies the possible events that can result from a
    buffer add request caused by the client calling either the
    DRV_I2S_ReadBufferAdd or DRV_I2S_WriteBufferAdd functions.

   Remarks:
    One of these values is passed in the "event" parameter of the event
    handling callback function that the client registered with the driver by
    calling the DRV_I2S_BufferEventHandlerSet function when a buffer
    transfer request is completed.

*/

typedef enum
{
    /* All data from or to the buffer was transferred successfully. */
    DRV_I2S_BUFFER_EVENT_COMPLETE,

    /* There was an error while processing the buffer transfer request. */
    DRV_I2S_BUFFER_EVENT_ERROR,

    DRV_I2S_BUFFER_EVENT_ABORT,

} DRV_I2S_BUFFER_EVENT;

// *****************************************************************************
/* I2S Driver Errors

  Summary:
    Defines the different types of errors for I2S driver

  Description:
    This data type defines the different types of errors for I2S driver.
    DRV_I2S_ERROR_NONE : No errors
    DRV_I2S_ERROR_OVERRUN : Receive Overflow error
    DRV_I2S_ERROR_PARITY : Parity error
    DRV_I2S_ERROR_FRAMING : Framing error

  Remarks:
    This structure is implementation specific. It is fully defined in
    drv_i2s_definitions.h.
*/

//typedef enum _DRV_I2S_ERROR DRV_I2S_ERROR;

// *****************************************************************************
/* I2S Driver Serial Setup Data

  Summary:
    Defines the data required to dynamically set the serial settings.

  Description:
    This data type defines the data required to dynamically set the serial
    settings for the specific I2S driver instance.

  Remarks:
    This structure is implementation specific. It is fully defined in
    drv_i2s_definitions.h.
*/

typedef struct _DRV_I2S_SERIAL_SETUP DRV_I2S_SERIAL_SETUP;

// *****************************************************************************
/* I2S Driver Initialization Data

  Summary:
    Defines the data required to initialize the I2S driver

  Description:
    This data type defines the data required to initialize the
    I2S driver.

  Remarks:
    This structure is implementation specific. It is fully defined in
    drv_i2s_definitions.h.
*/

//typedef struct _DRV_I2S_INIT DRV_I2S_INIT;

// *****************************************************************************
/* I2S Driver Buffer Event Handler Function Pointer

   Summary
    Pointer to a I2S Driver Buffer Event handler function

   Description
    This data type defines the required function signature for the I2S driver
    buffer event handling callback function. A client must register a pointer
    using the buffer event handling function whose function signature (parameter
    and return value types) match the types specified by this function pointer
    in order to receive buffer related event calls back from the driver.

    The parameters and return values are described here and
    a partial example implementation is provided.

  Parameters:
    event - Identifies the type of event

    bufferHandle - Handle identifying the buffer to which the vent relates

    context - Value identifying the context of the application that
    registered the event handling function.

  Returns:
    None.

  Example:
    <code>
    void APP_MyBufferEventHandler( DRV_I2S_BUFFER_EVENT event,
                                   DRV_I2S_BUFFER_HANDLE bufferHandle,
                                   uintptr_t context )
    {
        MY_APP_DATA_STRUCT pAppData = (MY_APP_DATA_STRUCT) context;

        switch(event)
        {
            case DRV_I2S_BUFFER_EVENT_COMPLETE:

                // Handle the completed buffer.
                break;

            case DRV_I2S_BUFFER_EVENT_ERROR:
            default:

                // Handle error.
                break;
        }
    }
    </code>

  Remarks:
    If the event is DRV_I2S_BUFFER_EVENT_COMPLETE, it means that the data was
    transferred successfully.

    If the event is DRV_I2S_BUFFER_EVENT_ERROR, it means that the data was not
    transferred successfully. The DRV_I2S_BufferCompletedBytesGet function can
    be called to find out how many bytes were processed.

    The bufferHandle parameter contains the buffer handle of the buffer that
    associated with the event. And bufferHandle will be valid while the buffer
    request is in the queue and during callback, unless an error occurred.
    After callback returns, the driver will retire the buffer handle.

    The context parameter contains the a handle to the client context,
    provided at the time the event handling function was registered using the
    DRV_I2S_BufferEventHandlerSet function.  This context handle value is
    passed back to the client as the "context" parameter.  It can be any value
    necessary to identify the client context or instance (such as a pointer to
    the client's data) instance of the client that made the buffer add request.

    The event handler function executes in the peripheral's interrupt
    context when the driver is configured for interrupt mode operation. It is
    recommended of the application to not perform process intensive or blocking
    operations with in this function.

    The DRV_I2S_ReadBufferAdd and DRV_I2S_WriteBufferAdd functions can
    be called in the event handler to add a buffer to the driver queue. These
    functions can only be called to add buffers to the driver whose event
    handler is running. For example, I2S2 driver buffers cannot be added in
    I2S1 driver event handler.
*/

typedef void ( *DRV_I2S_BUFFER_EVENT_HANDLER )( DRV_I2S_BUFFER_EVENT event, DRV_I2S_BUFFER_HANDLE bufferHandle, uintptr_t context );

// *****************************************************************************
// *****************************************************************************
// Section: I2S Driver System Interface Routines
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    SYS_MODULE_OBJ DRV_I2S_Initialize
    (
        const SYS_MODULE_INDEX index,
        const SYS_MODULE_INIT * const init
    )

  Summary:
    Initializes the I2S instance for the specified driver index.

  Description:
    This routine initializes the I2S driver instance for the specified driver
    index, making it ready for clients to open and use it. The initialization
    data is specified by the init parameter. The initialization may fail if the
    number of driver objects allocated are insufficient or if the specified
    driver instance is already initialized. The driver instance index is
    independent of the I2S module ID. For example, driver instance 0 can be
    assigned to I2S2.

  Precondition:
    None.

  Parameters:
    index - Identifier for the instance to be initialized

    init - Pointer to the init data structure containing any data necessary to
    initialize the driver.

  Returns:
    If successful, returns a valid handle to a driver instance object.
    Otherwise, returns SYS_MODULE_OBJ_INVALID.

  Example:
    <code>
    // The following code snippet shows an example I2S driver initialization.

    SYS_MODULE_OBJ              objectHandle;

    I2S_PLIB_API drvUsart0PlibAPI = {
        {
            .readCallbackRegister = I2S1_ReadCallbackRegister,
            .read = I2S1_Read,
            .readIsBusy = I2S1_ReadIsBusy,
            .readCountGet = I2S1_ReadCountGet,
            .writeCallbackRegister = I2S1_WriteCallbackRegister,
            .write = I2S1_Write,
            .writeIsBusy = I2S1_WriteIsBusy,
            .writeCountGet = I2S1_WriteCountGet,
            .errorGet = I2S1_ErrorGet
        }
    };

    DRV_I2S_INIT drvUsart0InitData =
    {
        .i2sPlib = &drvUsart0PlibAPI,
        .interruptI2S = I2S1_IRQn,
        .queueSizeTransmit = DRV_I2S_XMIT_QUEUE_SIZE_IDX0,
        .queueSizeReceive = DRV_I2S_RCV_QUEUE_SIZE_IDX0,
        .dmaChannelTransmit = SYS_DMA_CHANNEL_NONE,
        .dmaChannelReceive = SYS_DMA_CHANNEL_NONE,
        .i2sTransmitAddress = I2S1_TRANSMIT_ADDRESS,
        .i2sReceiveAddress = I2S1_RECEIVE_ADDRESS,
        .interruptDMA = XDMAC_IRQn
    };

    objectHandle = DRV_I2S_Initialize(DRV_I2S_INDEX_1,
        (SYS_MODULE_INIT*)&drvUsart0InitData);
    if (SYS_MODULE_OBJ_INVALID == objectHandle)
    {
        // Handle error
    }
    </code>

  Remarks:
    This routine must be called before any other I2S routine is called.

    This routine should only be called once during system initialization.
    This routine will NEVER block for hardware access.
*/

SYS_MODULE_OBJ DRV_I2S_Initialize( const SYS_MODULE_INDEX index, const SYS_MODULE_INIT * const init );

// *****************************************************************************
/* Function:
    SYS_STATUS DRV_I2S_Status( SYS_MODULE_OBJ object )

  Summary:
    Gets the current status of the I2S driver module.

  Description:
    This routine provides the current status of the I2S driver module.

  Precondition:
    Function DRV_I2S_Initialize should have been called before calling this
    function.

  Parameters:
    object - Driver object handle, returned from the
    DRV_I2S_Initialize routine

  Returns:
    SYS_STATUS_READY - Initialization have succeeded and the I2S is
    ready for additional operations

    SYS_STATUS_DEINITIALIZED - Indicates that the driver has been
    deinitialized

  Example:
    <code>
    SYS_MODULE_OBJ      object;     // Returned from DRV_I2S_Initialize
    SYS_STATUS          i2sStatus;

    i2sStatus = DRV_I2S _Status(object);
    if (SYS_STATUS_READY == i2sStatus)
    {
        // This means the driver can be opened using the
        // DRV_I2S_Open() function.
    }
    </code>

  Remarks:
    A driver can opened only when its status is SYS_STATUS_READY.
*/

SYS_STATUS DRV_I2S_Status( SYS_MODULE_OBJ object);

// *****************************************************************************
// *****************************************************************************
// Section: I2S Driver Common Client Interface Routines
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    DRV_HANDLE DRV_I2S_Open
    (
        const SYS_MODULE_INDEX index,
        const DRV_IO_INTENT ioIntent
    )

  Summary:
    Opens the specified I2S driver instance and returns a handle to it.

  Description:
    This routine opens the specified I2S driver instance and provides a
    handle that must be provided to all other client-level operations to
    identify the caller and the instance of the driver. The ioIntent
    parameter defines how the client interacts with this driver instance.

    Specifying a DRV_IO_INTENT_EXCLUSIVE will cause the driver to provide
    exclusive access to this client. The driver cannot be opened by any
    other client.

  Precondition:
    Function DRV_I2S_Initialize must have been called before calling this
    function.

  Parameters:
    index - Identifier for the object instance to be opened

    intent - Zero or more of the values from the enumeration DRV_IO_INTENT
    "ORed" together to indicate the intended useof the driver.
    See function description for details.

  Returns:
    If successful, the routine returns a valid open-instance handle (a number
    identifying both the caller and the module instance).

    If an error occurs, the return value is DRV_HANDLE_INVALID. Error can occur
    - if the number of client objects allocated via DRV_I2S_CLIENTS_NUMBER is
      insufficient.
    - if the client is trying to open the driver but driver has been opened
      exclusively by another client.
    - if the driver peripheral instance being opened is not initialized or is
      invalid.
    - if the client is trying to open the driver exclusively, but has already
      been opened in a non exclusive mode by another client.
    - if the driver is not ready to be opened, typically when the initialize
      routine has not completed execution.

  Example:
    <code>
    DRV_HANDLE handle;

    handle = DRV_I2S_Open(DRV_I2S_INDEX_0, DRV_IO_INTENT_EXCLUSIVE);
    if (DRV_HANDLE_INVALID == handle)
    {
        // Unable to open the driver
        // May be the driver is not initialized or the initialization
        // is not complete.
    }
    </code>

  Remarks:
    The handle returned is valid until the DRV_I2S_Close routine is called.
    This routine will NEVER block waiting for hardware. If the requested intent
    flags are not supported, the routine will return DRV_HANDLE_INVALID. This
    function is thread safe in a RTOS application.
*/

DRV_HANDLE DRV_I2S_Open( const SYS_MODULE_INDEX index, const DRV_IO_INTENT ioIntent );

// *****************************************************************************
/* Function:
    void DRV_I2S_Close( DRV_Handle handle )

  Summary:
    Closes an opened-instance of the I2S driver.

  Description:
    This routine closes an opened-instance of the I2S driver, invalidating the
    handle. Any buffers in the driver queue that were submitted by this client
    will be removed. A new handle must be obtained by calling DRV_I2S_Open
    before the caller may use the driver again.

  Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle - A valid open-instance handle, returned from the driver's
    open routine

  Returns:
    None.

  Example:
    <code>
    // 'handle', returned from the DRV_I2S_Open

    DRV_I2S_Close(handle);

    </code>

  Remarks:
    None.
*/

void DRV_I2S_Close( const DRV_HANDLE handle);

// *****************************************************************************
/* Function:
    DRV_I2S_ERROR DRV_I2S_ErrorGet( const DRV_HANDLE handle )

   Summary:
    Gets the I2S hardware errors associated with the client.

   Description:
    This function returns the errors associated with the given client.
    The call to this function also clears all the associated error flags.

   Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.

   Parameters:
    handle - A valid open-instance handle, returned from the driver's
    open routine

   Returns:
    Errors occurred as listed by DRV_I2S_ERROR.
    This function reports multiple I2S errors if occurred.

  Example:
    <code>
    // 'handle', returned from the DRV_I2S_Open

    if (DRV_I2S_ERROR_OVERRUN & DRV_I2S_ErrorGet(handle))
    {
        //Errors are cleared by the driver, take respective action
        //for the overrun error case.
    }
    </code>

  Remarks:
    I2S errors are normally associated with the receiver.
    The driver clears all the errors internally and only returns the
    occurred error information for the client.
*/

DRV_I2S_ERROR DRV_I2S_ErrorGet( const DRV_HANDLE handle );

// *****************************************************************************
/* Function:
    bool DRV_I2S_SerialSetup(const DRV_HANDLE handle,
        DRV_I2S_SERIAL_SETUP * setup)

   Summary:
    Sets the I2S serial communication settings dynamically.

   Description:
    This function sets the I2S serial communication settings dynamically.

   Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.
    The I2S transmit or receive transfer status should not be busy.

   Parameters:
    handle - A valid open-instance handle, returned from the driver's
    open routine
    setup - Pointer to the structure containing the serial setup.

   Returns:
    true - Serial setup was updated successfully.
    false - Failure while updating serial setup.

   Example:
    <code>
    // 'handle', returned from the DRV_I2S_Open

    DRV_I2S_SERIAL_SETUP setup = {
            115200,
            DRV_I2S_DATA_8_BIT,
            DRV_I2S_PARITY_ODD,
            DRV_I2S_STOP_1_BIT
        };

    DRV_I2S_SerialSetup(handle, &setup);
    </code>

   Remarks:
    None.
*/

bool DRV_I2S_SerialSetup(const DRV_HANDLE handle, DRV_I2S_SERIAL_SETUP * setup);

// *****************************************************************************
// *****************************************************************************
// Section: I2S Driver Buffer Queuing Model Interface Routines
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    void DRV_I2S_BufferEventHandlerSet
    (
        const DRV_HANDLE handle,
        const DRV_I2S_BUFFER_EVENT_HANDLER eventHandler,
        const uintptr_t context
    )

  Summary:
    Allows a client to identify a buffer event handling function for the driver
    to call back when queued buffer transfers have finished.

  Description:
    This function allows a client to register a buffer event handling function
    with the driver to call back when queued buffer transfers have finished.
    When a client calls either the DRV_I2S_ReadBufferAdd or
    DRV_I2S_WriteBufferAdd function, it is provided with a handle identifying
    the buffer that was added to the driver's buffer queue.  The driver will
    pass this handle back to the client by calling "eventHandler" function when
    the buffer transfer has completed.

    The event handler should be set before the client performs any "buffer add"
    operations that could generate events. The event handler once set, persists
    until the client closes the driver or sets another event handler (which
    could be a "NULL" pointer to indicate no callback).

  Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle - A valid open-instance handle, returned from the driver's open
    routine.

    eventHandler - Pointer to the event handler function.

    context - The value of parameter will be passed back to the client
    unchanged, when the eventHandler function is called.  It can be used to
    identify any client specific data object that identifies the instance of the
    client module (for example, it may be a pointer to the client module's state
    structure).

  Returns:
    None.

  Example:
    <code>
    // myAppObj is an application specific state data object.
    MY_APP_OBJ myAppObj;

    uint8_t mybuffer[MY_BUFFER_SIZE];
    DRV_I2S_BUFFER_HANDLE bufferHandle;

    // myI2SHandle is the handle returned
    // by the DRV_I2S_Open function.

    // Client registers an event handler with driver. This is done once

    DRV_I2S_BufferEventHandlerSet( myI2SHandle, APP_I2SBufferEventHandler,
                                     (uintptr_t)&myAppObj );

    DRV_I2S_ReadBufferAdd(myI2Shandle, myBuffer, MY_BUFFER_SIZE,
        &bufferHandle);

    if(DRV_I2S_BUFFER_HANDLE_INVALID == bufferHandle)
    {
        // Error handling here
    }

    // Event is received when the buffer is processed.

    void APP_I2SBufferEventHandler(DRV_I2S_BUFFER_EVENT event,
            DRV_I2S_BUFFER_HANDLE handle, uintptr_t context)
    {
        // The context handle was set to an application specific
        // object. It is now retrievable easily in the event handler.
        MY_APP_OBJ myAppObj = (MY_APP_OBJ *) context;

        switch(event)
        {
            case DRV_I2S_BUFFER_EVENT_COMPLETE:
                // This means the data was transferred.
                break;

            case DRV_I2S_BUFFER_EVENT_ERROR:
                // Error handling here.
                break;

            default:
                break;
        }
    }
    </code>

  Remarks:
    If the client does not want to be notified when the queued buffer transfer
    has completed, it does not need to register a callback. This function is
    thread safe when called in a RTOS application.
*/

void DRV_I2S_BufferEventHandlerSet( const DRV_HANDLE handle, const DRV_I2S_BUFFER_EVENT_HANDLER eventHandler, const uintptr_t context );

// *****************************************************************************
/* Function:
    void DRV_I2S_WriteBufferAdd
    (
        const DRV_HANDLE handle,
        void * buffer,
        size_t size,
        DRV_I2S_BUFFER_HANDLE * bufferHandle
    );

  Summary:
    Queues a write operation.

  Description:
    This function schedules a non-blocking write operation. The function returns
    with a valid buffer handle in the bufferHandle argument if the write request
    was scheduled successfully.  The function adds the request to the driver
    instance transmit queue and returns immediately. While the request is in the
    queue, the application buffer is owned by the driver and should not be
    modified.  On returning, the bufferHandle parameter may be
    DRV_I2S_BUFFER_HANDLE_INVALID for the following reasons:
    - if a buffer could not be allocated to the request
    - if the input buffer pointer is NULL
    - if the client opened the driver for read-only
    - if the buffer size is 0
    - if the transmit queue is full or the queue depth is insufficient

    If the requesting client registered an event callback with the driver, the
    driver will issue a DRV_I2S_BUFFER_EVENT_COMPLETE event if the buffer was
    processed successfully or a DRV_I2S_BUFFER_EVENT_ERROR event if the buffer
    was not processed successfully.

  Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle - Handle of the communication channel as return by the
    DRV_I2S_Open function.

    buffer - Data to be transmitted.

    size - Buffer size in bytes.

    bufferHandle - Pointer to an argument that will contain the return
    buffer handle.

  Returns:
    The bufferHandle parameter will contain the return buffer handle. This will
    be DRV_I2S_BUFFER_HANDLE_INVALID if the function was not successful.

  Example:
    <code>

    MY_APP_OBJ myAppObj;
    uint8_t mybuffer[MY_BUFFER_SIZE];
    DRV_I2S_BUFFER_HANDLE bufferHandle;

    // myI2SHandle is the handle returned
    // by the DRV_I2S_Open function.

    DRV_I2S_WriteBufferAdd(myI2Shandle, myBuffer, MY_BUFFER_SIZE,
        &bufferHandle);

    if(DRV_I2S_BUFFER_HANDLE_INVALID == bufferHandle)
    {
        // Error handling here
    }

    // Event is received when
    // the buffer is processed.
    </code>

  Remarks:
    This function is thread safe in a RTOS application. It can be called from
    within the I2S Driver Buffer Event Handler that is registered by this
    client. It should not be called in the event handler associated with another
    I2S driver instance. It should not otherwise be called directly in an ISR.

*/

void DRV_I2S_WriteBufferAdd( const DRV_HANDLE handle, void * buffer, const size_t size, DRV_I2S_BUFFER_HANDLE * bufferHandle);

// *****************************************************************************
/* Function:
	void DRV_I2S_BufferAddWriteRead(const DRV_HANDLE handle,                                        
        void *transmitBuffer, void *receiveBuffer,
        size_t size, DRV_I2S_BUFFER_HANDLE	*bufferHandle)

  Summary:
    Queues a write/read operation.

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

  Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle - Handle of the communication channel as return by the
    DRV_I2S_Open function.

    transmitBuffer - Data to be transmitted.

    receiveBuffer - Will hold data that is received.

    size - Buffer size in bytes (same for both buffers)

    bufferHandle - Pointer to an argument that will contain the return
    buffer handle.

  Returns:
    The bufferHandle parameter will contain the return buffer handle. This will
    be DRV_I2S_BUFFER_HANDLE_INVALID if the function was not successful.

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
    size_t size, DRV_I2S_BUFFER_HANDLE	*bufferHandle);

// *****************************************************************************
/* Function:
    void DRV_I2S_ReadBufferAdd
    (
        const DRV_HANDLE handle,
        void * buffer,
        const size_t size,
        DRV_I2S_BUFFER_HANDLE * bufferHandle
    )

  Summary:
    Queues a read operation.

  Description:
    This function schedules a non-blocking read operation. The function returns
    with a valid buffer handle in the bufferHandle argument if the read request
    was scheduled successfully. The function adds the request to the hardware
    instance receive queue and returns immediately. While the request is in the
    queue, the application buffer is owned by the driver and should not be
    modified. The function returns DRV_I2S_BUFFER_HANDLE_INVALID in the
    bufferHandle argument:
    - if a buffer could not be allocated to the request
    - if the input buffer pointer is NULL
    - if the buffer size is 0
    - if the read queue size is full or queue depth is insufficient.
    - if the driver handle is invalid

    If the requesting client registered an event callback with the driver, the
    driver will issue a DRV_I2S_BUFFER_EVENT_COMPLETE event if the buffer was
    processed successfully of DRV_I2S_BUFFER_EVENT_ERROR event if the buffer
    was not processed successfully.

  Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle - Handle of the communication channel as returned by the
    DRV_I2S_Open function.

    buffer - Buffer where the received data will be stored.

    size - Buffer size in bytes.

    bufferHandle - Pointer to an argument that will contain the return
    buffer handle.

  Returns:
     The buffer handle is returned in the bufferHandle argument. This is
     DRV_I2S_BUFFER_HANDLE_INVALID if the request was not successful.

  Example:
    <code>

    MY_APP_OBJ myAppObj;
    uint8_t mybuffer[MY_BUFFER_SIZE];
    DRV_I2S_BUFFER_HANDLE bufferHandle;

    // myI2SHandle is the handle returned
    // by the DRV_I2S_Open function.

    DRV_I2S_ReadBufferAdd(myI2Shandle, myBuffer, MY_BUFFER_SIZE,
        &bufferHandle);

    if(DRV_I2S_BUFFER_HANDLE_INVALID == bufferHandle)
    {
        // Error handling here
    }

    // Event is received when the buffer is processed.
    </code>

  Remarks:
    This function is thread safe in a RTOS application. It can be called from
    within the I2S Driver Buffer Event Handler that is registered by the
    client. It should not be called in the event handler associated with another
    I2S driver instance. It should not be called directly in an ISR.

*/

void DRV_I2S_ReadBufferAdd( const DRV_HANDLE handle, void * buffer, const size_t size, DRV_I2S_BUFFER_HANDLE * const bufferHandle);

// *****************************************************************************
/* Function:
    size_t DRV_I2S_BufferCompletedBytesGet
    (
        DRV_I2S_BUFFER_HANDLE bufferHandle
    );

  Summary:
    Returns the number of bytes that have been processed for the
    specified buffer request.

  Description:
    The client can use this function, in a case where the buffer is terminated
    due to an error, to obtain the number of bytes that have been processed.
    Or in any other use case. This function can be used for non-DMA buffer
    transfers only. It cannot be used when the I2S driver is configured to
    use DMA.

  Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.

    Either the DRV_I2S_ReadBufferAdd or DRV_I2S_WriteBufferAdd function
    must have been called and a valid buffer handle returned.

  Parameters:
    bufferhandle - Handle for the buffer of which the processed number of
    bytes to be obtained.

  Returns:
    Returns the number of bytes that have been processed for this buffer.

    Returns DRV_I2S_BUFFER_HANDLE_INVALID for an invalid or an expired
    buffer handle.

  Example:
    <code>
    // myAppObj is an application specific object.
    MY_APP_OBJ myAppObj;

    uint8_t mybuffer[MY_BUFFER_SIZE];
    DRV_I2S_BUFFER_HANDLE bufferHandle;

    // myI2SHandle is the handle returned
    // by the DRV_I2S_Open function.

    // Client registers an event handler with driver. This is done once

    DRV_I2S_BufferEventHandlerSet( myI2SHandle, APP_I2SBufferEventHandle,
                                     (uintptr_t)&myAppObj );

    DRV_I2S_ReadBufferAdd( myI2Shandle, myBuffer, MY_BUFFER_SIZE,
        bufferHandle);

    if(DRV_I2S_BUFFER_HANDLE_INVALID == bufferHandle)
    {
        // Error handling here
    }

    // Event Processing Technique. Event is received when
    // the buffer is processed.

    void APP_I2SBufferEventHandler( DRV_I2S_BUFFER_EVENT event,
            DRV_I2S_BUFFER_HANDLE bufferHandle, uintptr_t contextHandle )
    {
        // The context handle was set to an application specific
        // object. It is now retrievable easily in the event handler.
        MY_APP_OBJ myAppObj = (MY_APP_OBJ *) contextHandle;
        size_t processedBytes;

        switch(event)
        {
            case DRV_I2S_BUFFER_EVENT_COMPLETE:
                // This means the data was transferred.
                break;

            case DRV_I2S_BUFFER_EVENT_ERROR:
                // Error handling here.
                // We can find out how many bytes have been processed in this
                // buffer request prior to the error.
                processedBytes= DRV_I2S_BufferCompletedBytesGet(bufferHandle);
                break;

            default:
                break;
        }
    }
    </code>

  Remarks:
    This function is expected to work in non-DMA mode only.
    This function is thread safe when used in a RTOS application.
    If called from the callback, it must not call an OSAL mutex or critical
    section.
*/

size_t DRV_I2S_BufferCompletedBytesGet( DRV_I2S_BUFFER_HANDLE bufferHandle );

// *****************************************************************************
/* Function:
    DRV_I2S_BUFFER_EVENT DRV_I2S_BufferStatusGet
    (
        const DRV_I2S_BUFFER_HANDLE bufferHandle
    )

  Summary:
    Returns the transmit/receive request status.

  Description:
    This function can be used to poll the status of the queued buffer request
    if the application doesn't prefer to use the event handler (callback)
    function to get notified.

  Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.

    Either the DRV_I2S_ReadBufferAdd or DRV_I2S_WriteBufferAdd function
    must have been called and a valid buffer handle returned.

  Parameters:
    bufferhandle - Handle for the buffer of which the processed number of
    bytes to be obtained.

  Returns:
    The success or error event of the buffer.

  Example:
  <code>
    // myAppObj is an application specific object.
    MY_APP_OBJ myAppObj;

    uint8_t mybuffer[MY_BUFFER_SIZE];
    DRV_I2S_BUFFER_HANDLE bufferHandle;
    DRV_I2S_BUFFER_EVENT event;

    // myI2SHandle is the handle returned
    // by the DRV_I2S_Open function.

    // Client registers an event handler with driver. This is done once

    DRV_I2S_BufferEventHandlerSet( myI2SHandle, APP_I2SBufferEventHandle,
                                     (uintptr_t)&myAppObj );

    DRV_I2S_ReadBufferAdd( myI2Shandle, myBuffer, MY_BUFFER_SIZE,
        bufferHandle);

    if(DRV_I2S_BUFFER_HANDLE_INVALID == bufferHandle)
    {
        // Error handling here
    }

    //Check the status of the buffer
    //This call can be used to wait until the buffer is processed.
    event  = DRV_I2S_BufferStatusGet(bufferHandle);
  </code>

  Remarks:
    This function returns error event if the buffer handle is invalid.

*/

DRV_I2S_BUFFER_EVENT DRV_I2S_BufferStatusGet( const DRV_I2S_BUFFER_HANDLE bufferHandle );

// *****************************************************************************
/* Function:
    bool DRV_I2S_WriteQueuePurge( const DRV_HANDLE handle )

  Summary:
    Removes all buffer requests from the write queue.

  Description:
    This function removes all the buffer requests from the write queue.
    The client can use this function to purge the queue on timeout or to remove
    unwanted stalled buffer requests or in any other use case.

  Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle - Handle of the communication channel as returned by the
    DRV_I2S_Open function.

  Returns:
    True - Write queue purge is successful.
    False - Write queue purge has failed.

  Example:
    <code>
    // myI2SHandle is the handle returned by the DRV_I2S_Open function.
    // Use DRV_I2S_WriteBufferAdd to queue write requests

    // Application timeout function, where remove queued buffers.
    void APP_TimeOut(void)
    {
        if(false == DRV_I2S_WriteQueuePurge(myI2Shandle))
        {
            //Couldn't purge the write queue, try again.
        }
        else
        {
            //Queue purge successful.
        }
    }
    </code>

  Remarks:
    This function is thread safe when used in an RTOS environment.
    Avoid this function call from within the callback.
*/

bool DRV_I2S_WriteQueuePurge( const DRV_HANDLE handle );

// *****************************************************************************
/* Function:
    bool DRV_I2S_ReadQueuePurge( const DRV_HANDLE handle )

  Summary:
    Removes all buffer requests from the read queue.

  Description:
    This function removes all the buffer requests from the read queue.
    The client can use this function to purge the queue on timeout or to remove
    unwanted stalled buffer requests or in any other use case.

  Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle - Handle of the communication channel as returned by the
    DRV_I2S_Open function.

  Returns:
    True - Read queue purge is successful.
    False - Read queue purge has failed.

  Example:
    <code>
    // myI2SHandle is the handle returned by the DRV_I2S_Open function.
    // Use DRV_I2S_ReadBufferAdd to queue read requests

    // Application timeout function, where remove queued buffers.
    void APP_TimeOut(void)
    {
        if(false == DRV_I2S_ReadQueuePurge(myI2Shandle))
        {
            //Couldn't purge the read queue, try again.
        }
        else
        {
            //Queue purge successful.
        }
    }
    </code>

  Remarks:
    This function is thread safe when used in an RTOS environment.
    Avoid this function call from within the callback.
*/

bool DRV_I2S_ReadQueuePurge( const DRV_HANDLE handle );

// *****************************************************************************
// *****************************************************************************
// Section: I2S Driver Synchronous(Blocking Model) Transfer Interface Routines
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    bool DRV_I2S_WriteBuffer
    (
        const DRV_HANDLE handle,
        void * buffer,
        const size_t size
    );

  Summary:
    This is a blocking function that writes data over I2S.

  Description:
    This function does a blocking write operation. The function blocks till
    the data write is complete.
    Function will return false to report failure. The failure will occur for
    the following reasons:
    - if the handle is invalid
    - if the input buffer pointer is NULL
    - if the buffer size is 0

  Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle - Handle of the communication channel as return by the
    DRV_I2S_Open function.

    buffer - Pointer to the data to be transmitted.

    size - Buffer size in bytes.

  Returns:
    true - write is successful
    false - error has occurred

  Example:
    <code>

    MY_APP_OBJ myAppObj;
    uint8_t myBuffer[MY_BUFFER_SIZE];

    // myI2SHandle is the handle returned
    // by the DRV_I2S_Open function.

    if (DRV_I2S_WriteBuffer(myI2SHandle, myBuffer, MY_BUFFER_SIZE) == false)
    {
        // Error: Verify the input parameters
    }
    </code>

  Remarks:
    This function is thread safe in a RTOS application.
    This function should not be called from an interrupt context.
*/
bool DRV_I2S_WriteBuffer( const DRV_HANDLE handle, void * buffer, const size_t size);

// *****************************************************************************
/* Function:
    bool DRV_I2S_ReadBuffer
    (
        const DRV_HANDLE handle,
        void * buffer,
        const size_t size
    );

  Summary:
    This is a blocking function that reads data over I2S.

  Description:
    This function does a blocking read operation. The function blocks till
    the data read is complete or error has occurred during read.
    Function will return false to report failure. The failure will occur for
    the following reasons:
    - if the handle is invalid
    - if the input buffer pointer is NULL
    - if the buffer size is 0
    - Hardware errors

  Precondition:
    DRV_I2S_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle - Handle of the communication channel as return by the
    DRV_I2S_Open function.

    buffer - Pointer to the receive buffer.

    size - Buffer size in bytes.

  Returns:
    true - read is successful
    false - error has occurred

  Example:
    <code>

    MY_APP_OBJ myAppObj;
    uint8_t myBuffer[MY_BUFFER_SIZE];

    // myI2SHandle is the handle returned
    // by the DRV_I2S_Open function.

    if (DRV_I2S_ReadBuffer(myI2SHandle, myBuffer, MY_BUFFER_SIZE) == false)
    {
        // Error handling here
    }
    </code>

  Remarks:
    This function is thread safe in a RTOS application.
    This function should not be called from an interrupt context.
*/
bool DRV_I2S_ReadBuffer( const DRV_HANDLE handle, void * buffer, const size_t size);

// *****************************************************************************
/* Function:
    uint32_t DRV_I2S_LRCLK_Sync (const DRV_HANDLE handle, const uint32_t sample_rate);
    
  Summary:
    Synchronize to the start of the I2S LRCLK (left/right clock) signal
    
  Description:
    This function waits until low-tohigh transition of the I2S LRCLK (left/right clock)
    signal (high-low if Left-Jusitified format, this is determined by the PLIB).
    In the case where this signal is generated from a codec or other external
    source, this allows the caller to synchronize calls to the DMA with the LRCLK signal
    so the left/right channel association is valid.
  
  Precondition:
    None.
  
  Parameters:
    None.
  
  Returns:
    true if the function was successful, false if a timeout occurred (no transitions seen)
    
  Example:
    <code>
        // myI2SHandle is the handle returned
        // by the DRV_I2S_Open function.

        DRV_I2S_LRCLK_Sync(myI2SHandle, 48000);
    </code>
    
  Remarks:
    None.                                            
*/
bool DRV_I2S_LRCLK_Sync (const DRV_HANDLE handle, const uint32_t sample_rate);

<#if DRV_I2S_DMA_LL_ENABLE == true>
typedef void (*DRV_I2S_LL_CALLBACK)();
void DRV_I2S_InitWriteLinkedListTransfer(DRV_HANDLE handle, XDMAC_DESCRIPTOR_VIEW_1* pLinkedListDesc,
    uint16_t currDescrip, uint16_t nextDescrip, uint8_t* buffer, uint32_t bufferSize);
void DRV_I2S_StartWriteLinkedListTransfer(DRV_HANDLE handle, XDMAC_DESCRIPTOR_VIEW_1* pLinkedListDesc,
    DRV_I2S_LL_CALLBACK callBack, bool blockInt);
void DRV_I2S_WriteNextLinkedListTransfer(DRV_HANDLE handle, XDMAC_DESCRIPTOR_VIEW_1* pLinkedListDesc,
    uint16_t currDescrip, uint16_t nextDescrip, uint16_t nextNextDescrip, uint8_t* buffer, uint32_t bufferSize);
void DRV_I2S_InitReadLinkedListTransfer(DRV_HANDLE handle, XDMAC_DESCRIPTOR_VIEW_1* pLinkedListDesc,
    uint16_t currDescrip, uint16_t nextDescrip, uint8_t* buffer, uint32_t bufferSize);
void DRV_I2S_StartReadLinkedListTransfer(DRV_HANDLE handle, XDMAC_DESCRIPTOR_VIEW_1* pLinkedListDesc,
    DRV_I2S_LL_CALLBACK callBack, bool blockInt);
void DRV_I2S_ReadNextLinkedListTransfer(DRV_HANDLE handle, XDMAC_DESCRIPTOR_VIEW_1* pLinkedListDesc,
    uint16_t currDescrip, uint16_t nextDescrip, uint16_t nextNextDescrip, uint8_t* buffer, uint32_t bufferSize);
</#if>

#include "driver/i2s/src/drv_i2s_local.h"

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END


#endif // #ifndef DRV_I2S_H

