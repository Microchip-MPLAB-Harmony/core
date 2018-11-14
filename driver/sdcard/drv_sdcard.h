/*******************************************************************************
  SD Card Driver Interface Definition

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdcard.h

  Summary:
    SD Card Library Interface header.

  Description:
    The SD Card Driver Library provides a common interface to access SD Card
    interfaced over different protocols.
*******************************************************************************/

// DOM-IGNORE-BEGIN
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
// DOM-IGNORE-END

#ifndef _DRV_SDCARD_H
#define _DRV_SDCARD_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <stdio.h>
#include <stdbool.h>
#include "driver/driver.h"
#include "system/system.h"
#include "system/system_media.h"

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
/* SDCARD Driver Events

   Summary
    Identifies the possible events that can result from a request.

   Description
    This enumeration identifies the possible events that can result from a
    read or a write request issued by the client.

   Remarks:
    One of these values is passed in the "event" parameter of the event
    handling callback function that client registered with the driver by
    calling the DRV_SDCARD_EventHandlerSet function when a request is completed.
*/

typedef enum
{
    /* Operation has been completed successfully. */
    DRV_SDCARD_EVENT_COMMAND_COMPLETE = SYS_MEDIA_EVENT_BLOCK_COMMAND_COMPLETE,

    /* There was an error during the operation. */
    DRV_SDCARD_EVENT_COMMAND_ERROR = SYS_MEDIA_EVENT_BLOCK_COMMAND_ERROR

} DRV_SDCARD_EVENT;

typedef enum
{
    /*Done OK and ready */
    DRV_SDCARD_COMMAND_COMPLETED          = SYS_MEDIA_COMMAND_COMPLETED,

    /*Scheduled but not started */
    DRV_SDCARD_COMMAND_QUEUED             = SYS_MEDIA_COMMAND_QUEUED,

    /*Currently being in transfer */
    DRV_SDCARD_COMMAND_IN_PROGRESS        = SYS_MEDIA_COMMAND_IN_PROGRESS,

    /*Error */
    DRV_SDCARD_COMMAND_ERROR_UNKNOWN      = SYS_MEDIA_COMMAND_UNKNOWN,

} DRV_SDCARD_COMMAND_STATUS;

typedef SYS_MEDIA_BLOCK_COMMAND_HANDLE  DRV_SDCARD_COMMAND_HANDLE;

// *****************************************************************************
/* SDCARD Driver Invalid Command Handle.

  Summary:
    SDCARD Driver's Invalid Command Handle.

  Description:
    This value defines the SDCARD Driver Invalid Command Handle. This value
    is returned by read or write routines when the command request was not
    accepted.

  Remarks:
    None.
*/

#define DRV_SDCARD_COMMAND_HANDLE_INVALID SYS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID

// *****************************************************************************
/* SDCARD Driver Event Handler Function Pointer

   Summary
    Pointer to a SDCARD Driver Event handler function

   Description
    This data type defines the required function signature for the SDCARD event
    handling callback function. A client must register a pointer to an event
    handling function whose function signature (parameter and return value
    types) match the types specified by this function pointer in order to
    receive event calls back from the driver.

    The parameters and return values are described here and a partial example
    implementation is provided.

  Parameters:
    event           - Identifies the type of event

    commandHandle   - Handle returned from the Read/Write requests

    context         - Value identifying the context of the application that
                      registered the event handling function

  Returns:
    None.

  Example:
    <code>
    void APP_MySDCARDEventHandler
    (
        DRV_SDCARD_EVENT event,
        DRV_SDCARD_COMMAND_HANDLE commandHandle,
        uintptr_t context
    )
    {
        MY_APP_DATA_STRUCT* pAppData = (MY_APP_DATA_STRUCT*) context;

        switch(event)
        {
            case DRV_SDCARD_EVENT_COMMAND_COMPLETE:

                // Handle the completed buffer.
                break;

            case DRV_SDCARD_EVENT_COMMAND_ERROR:
            default:

                // Handle error.
                break;
        }
    }
    </code>

  Remarks:
    If the event is DRV_SDCARD_EVENT_COMMAND_COMPLETE, it means that the
    scheduled operation was completed successfully.

    If the event is DRV_SDCARD_EVENT_COMMAND_ERROR, it means that the scheduled
    operation was not completed successfully.

    The context parameter contains the handle to the client context, provided
    at the time the event handling function was  registered using the
    DRV_SDCARD_EventHandlerSet function. This context handle value is
    passed back to the client as the "context" parameter.  It can be any value
    necessary to identify the client context or instance (such as a pointer to
    the client's data) instance of the client that made the read/write/erase
    request.
*/
typedef SYS_MEDIA_EVENT_HANDLER     DRV_SDCARD_EVENT_HANDLER;

// *****************************************************************************
// *****************************************************************************
// Section: DRV_SDCARD Driver Module Interface Routines
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    SYS_MODULE_OBJ DRV_SDCARD_Initialize
     (
         const SYS_MODULE_INDEX drvIndex,
         const SYS_MODULE_INI* const init
     )

  Summary:
    Initializes the SD Card driver.

  Description:
    This routine initializes the SD Card driver, making it ready for clients to
    open and use the driver.

  Precondition:
    None.

  Parameters:
    drvIndex        - Index for the driver instance to be initialized

    init            - Pointer to a data structure containing any data necessary
                      to initialize the driver.

  Returns:
    If successful, returns a valid handle to a driver object. Otherwise, it
    returns SYS_MODULE_OBJ_INVALID.

  Example:
    <code>
    SYS_MODULE_OBJ      objectHandle;

    //Example shows SD card driver instance 0 initialization data for SD-SPI protocol
    const DRV_SDCARD_INIT drvSDCard0InitData =
    {
        .initialize = DRV_SDSPI_Initialize,
        .open = DRV_SDSPI_Open,
        .close = DRV_SDSPI_Close,
        .status = DRV_SDSPI_Status,
        .tasks = DRV_SDSPI_Tasks,
        .eventHandlerSet = DRV_SDSPI_EventHandlerSet,
        .commandStatus = (void*)DRV_SDSPI_CommandStatus,
        .geometryGet = DRV_SDSPI_GeometryGet,
        .isAttached = DRV_SDSPI_IsAttached,
        .isWriteProtected = DRV_SDSPI_IsWriteProtected,
        .readSync = DRV_SDSPI_SyncRead,
        .writeSync = DRV_SDSPI_SyncWrite,
        .readAsync = NULL,
        .writeAsync = NULL,
        .fsRead = DRV_SDSPI_FS_Read,
        .fsWrite = DRV_SDSPI_FS_Write,
        .sdDriverInitData = (const SYS_MODULE_INIT *)&drvSDSPI0InitData,
        .isFsEnabled = true,
    };   
    
    objectHandle = DRV_SDCARD_Initialize(DRV_SDCARD_INDEX_0,(SYS_MODULE_INIT *)&drvSDCard0InitData);
    if (objectHandle == SYS_MODULE_OBJ_INVALID)
    {
        // Handle error
    }
    </code>

  Remarks:
    This routine must be called before any other SD Card routine is called.

    This routine should only be called once during system initialization.

    The system must use DRV_SDCARD_Status to find out when the driver is in the
    ready state.

*/

SYS_MODULE_OBJ DRV_SDCARD_Initialize(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT * const init
);

// *****************************************************************************
/* Function:
    SYS_STATUS DRV_SDCARD_Status
     (
         SYS_MODULE_OBJ object
     )

  Summary:
    Provides the current status of the SDCARD driver module.

  Description:
    This routine provides the current status of the SDCARD driver module.

  Precondition:
    Function DRV_SDCARD_Initialize must have been called before calling this
    function

  Parameters:
    object                    - Driver object handle, returned from the
                                DRV_SDCARD_Initialize routine

  Returns:
    SYS_STATUS_READY          - Indicates that the driver has been initialized
                                and is ready to accept requests from the client.

    SYS_STATUS_UNINITIALIZED   - Indicates that the driver has not been
                                 initialized.

  Example:
    <code>
    // "object" - Returned from DRV_SDCARD_Initialize
    SYS_STATUS          status;

    status = DRV_SDCARD_Status(object);

    if (status == SYS_STATUS_READY)
    {
        // Driver is initialized and ready.
    }
    </code>

  Remarks:
    This operation can be used to determine if the driver is initialized or not.
*/
SYS_STATUS DRV_SDCARD_Status( SYS_MODULE_OBJ object );

// *****************************************************************************
/* Function:
    DRV_HANDLE DRV_SDCARD_Open
     (
         const SYS_MODULE_INDEX drvIndex,
         const DRV_IO_INTENT    ioIntent
     )

  Summary:
    Opens the specified SD Card driver instance and returns a handle to it.

  Description:
    This routine opens the specified SD Card driver instance and provides a
    handle that must be provided to all other client-level operations to
    identify the caller and the instance of the driver.

  Precondition:
    Function DRV_SDCARD_Initialize must have been called before calling this
    function.

  Parameters:
    drvIndex    - Identifier for the object instance to be opened

    ioIntent    - Zero or more of the values from the enumeration
                  DRV_IO_INTENT "ORed" together to indicate the intended use
                  of the driver. Supports only DRV_IO_INTENT_EXCLUSIVE.

  Returns:
    If successful, the routine returns a valid open-instance handle (a number
    identifying both the caller and the module instance).

    If an error occurs, the return value is DRV_HANDLE_INVALID.

  Example:
    <code>
    DRV_HANDLE  handle;

    handle = DRV_SDCARD_Open (DRV_SDCARD_INDEX_0, DRV_IO_INTENT_EXCLUSIVE);

    if (handle == DRV_HANDLE_INVALID)
    {
        // Unable to open the driver
    }
    </code>

  Remarks:
    The handle returned is valid until the DRV_SDCARD_Close routine is called.
    This routine may block for other client-level operations to complete.
*/
DRV_HANDLE DRV_SDCARD_Open(const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent);

// *****************************************************************************
/* Function:
    void DRV_SDCARD_Close
     (
         const DRV_HANDLE handle
     )

  Summary:
    Closes an opened-instance of the SD Card driver.

  Description:
    This routine closes an opened-instance of the SD Card driver, invalidating
    the handle.

  Precondition:
    The DRV_SDCARD_Initialize routine must have been called for the specified
    SD Card driver instance.

    DRV_SDCARD_Open must have been called to obtain a valid opened device
    handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open routine

  Returns:
    None

  Example:
    <code>
    // "handle" is the driver handle returned by the DRV_SDCARD_Open function

    DRV_SDCARD_Close (handle);
    </code>

  Remarks:
    After calling this routine, the handle passed in "handle" must not be used
    with any of the remaining driver routines.  A new handle must be obtained by
    calling DRV_SDCARD_Open before the caller may use the driver again.
    This routine may block for other client-level operations to complete.

    Note:
    Usually there is no need for the driver client to verify that the Close
    operation has completed.
*/
void DRV_SDCARD_Close(const DRV_HANDLE handle);

// *****************************************************************************
/* Function:
    void DRV_SDCARD_Tasks
     (
         SYS_MODULE_OBJ object
     )

  Summary:
    Maintains the driver's state machine.

  Description:
    For asynchronous driver, this routine is used to maintain the driver's 
    internal state machine.
    For synchronous driver, the task routine periodically checks for SD card
    attach/detach event and initializes the SD card.

  Precondition:
    The DRV_SDCARD_Initialize routine must have been called for the specified
    SDCARD driver instance.

  Parameters:
    object      - Object handle for the specified driver instance (returned from
                  DRV_SDCARD_Initialize)

  Returns:
    None

  Example:
    <code>
    //sysObj.drvSDCARD0 is returned by the driver initialization routine

    //Example of Synchronous driver task routine run from a separate RTOS thread.
    while(1)
    {
        DRV_SDCARD_Tasks(sysObj.drvSDCARD0);

        // Yield and allow other threads to run.
        vTaskDelay(100 / portTICK_PERIOD_MS);
    }
    
    //Example of Asynchronous driver task routine run from SYS_Tasks().
    while(1)
    {
        DRV_SDCARD_Tasks(sysObj.drvSDCARD0);

        //Other task routines
    }
    </code>

  Remarks:
    This routine is normally not called directly by an application.
*/

void DRV_SDCARD_Tasks ( SYS_MODULE_OBJ object );

// *****************************************************************************
/* Function:
    bool DRV_SDCARD_SyncRead (
        const DRV_HANDLE handle,
        void* targetBuffer,
        uint32_t blockStart,
        uint32_t nBlock
    )

  Summary:
    Reads blocks of data from the specified block address of the SD Card.

  Description:
    This function performs a blocking read operation to read blocks of data
    from the SD Card. The function returns true if the request was successfully
    executed; returns false otherwise.
    The function returns false under following conditions:
    - if the driver handle is invalid
    - if the target buffer pointer is NULL
    - if the number of blocks to be read is zero or more than the actual number
      of blocks available.
    - Error during the read operation

  Precondition:
    The DRV_SDCARD_Initialize routine must have been called for the specified SDCARD
    driver instance.

    DRV_SDCARD_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle        - A valid open-instance handle, returned from the driver's
                    open function

    targetBuffer  - Buffer into which the data read from the SD Card will be placed

    blockStart    - Starting block address of the SD Card from where the read should begin.

    nBlock        - Total number of blocks to be read.

  Returns:
    true - If the request was executed successfully.

    false - If there was an error executing the request.

  Example:
    <code>
    #define MY_BUFFER_SIZE 1024
    uint8_t myBuffer[MY_BUFFER_SIZE];

    // Address must be block aligned.
    uint32_t blockStart = 0x00;
    uint32_t nBlock = 2;

    // mySDCARDHandle is the handle returned by the DRV_SDCARD_Open function.

    if (DRV_SDCARD_SyncRead(mySDCARDHandle, myBuffer, blockStart, nBlock) == true)
    {
        // Read successful
    }
    else
    {
        // Error handling here
    }

    </code>

  Remarks:
    None.
*/

bool DRV_SDCARD_SyncRead (
    const DRV_HANDLE handle,
    void* targetBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);

// *****************************************************************************
/* Function:
    void DRV_SDCARD_AsyncRead
    (
        const DRV_HANDLE handle,
        DRV_SDCARD_COMMAND_HANDLE *commandHandle,
        void *targetBuffer,
        uint32_t blockStart,
        uint32_t nBlock
    )

  Summary:
    Reads blocks of data from the specified block address of the SD Card.

  Description:
    This function schedules a non-blocking read operation for reading blocks
    of data from the SD Card. The function returns with a valid buffer handle
    in the commandHandle argument if the read request was scheduled successfully.
    The function adds the request to the hardware instance queue and returns
    immediately. While the request is in the queue, the application buffer is
    owned by the driver and should not be modified. The function returns
    DRV_SDCARD_COMMAND_HANDLE_INVALID in the commandHandle argument under the
    following circumstances:
    - if the driver handle is invalid
    - if the target buffer pointer is NULL
    - if the number of blocks to be read is zero or more than the actual number
      of blocks available
    - if a buffer object could not be allocated to the request
    - if the client opened the driver in write only mode

    If the requesting client registered an event callback with the driver, the
    driver will issue a DRV_SDCARD_EVENT_COMMAND_COMPLETE event if the
    buffer was processed successfully or DRV_SDCARD_EVENT_COMMAND_ERROR
    event if the buffer was not processed successfully.

  Precondition:
    DRV_SDCARD_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle        - A valid open-instance handle, returned from the driver's
                    open function

    commandHandle - Pointer to an argument that will contain the return buffer
                    handle

    targetBuffer  - Buffer into which the data read from the SD Card will be placed

    blockStart    - Start block address of the SD Card from where the read should begin.

    nBlock        - Total number of blocks to be read.

  Returns:
    The buffer handle is returned in the commandHandle argument. It will be
    DRV_SDCARD_COMMAND_HANDLE_INVALID if the request was not successful.

  Example:
    <code>

    uint8_t myBuffer[MY_BUFFER_SIZE];

    // address should be block aligned.
    uint32_t blockStart = 0x00;
    uint32_t    nBlock = 2;
    DRV_SDCARD_COMMAND_HANDLE commandHandle;
    MY_APP_OBJ myAppObj;

    // mySDCARDHandle is the handle returned by the DRV_SDCARD_Open function.

    DRV_SDCARD_EventHandlerSet(mySDCARDHandle, APP_SDCardEventHandler, (uintptr_t)&myAppObj);

    DRV_SDCARD_AsyncRead(mySDCARDHandle, &commandHandle, myBuffer, blockStart, nBlock);

    if(commandHandle == DRV_SDCARD_COMMAND_HANDLE_INVALID)
    {
        // Error handling here
    }
    else
    {
        // Read Successful
    }
    
    // Event is received when the buffer is processed.

    void APP_SDCardEventHandler(DRV_SDCARD_EVENT event,
            DRV_SDCARD_COMMAND_HANDLE commandHandle, uintptr_t contextHandle)
    {
        // contextHandle points to myAppObj.

        switch(event)
        {
            case DRV_SDCARD_EVENT_COMMAND_COMPLETE:

                // This means the data was transferred.
                break;

            case DRV_SDCARD_EVENT_COMMAND_ERROR:

                // Error handling here.
                break;

            default:
                break;
        }
    }

    </code>

  Remarks:
    None.
*/

void DRV_SDCARD_AsyncRead
(
    const DRV_HANDLE handle,
    DRV_SDCARD_COMMAND_HANDLE *commandHandle,
    void *targetBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);

// *****************************************************************************
/* Function:
    bool DRV_SDCARD_SyncWrite(
        const DRV_HANDLE handle,
        void* sourceBuffer,
        uint32_t blockStart,
        uint32_t nBlock
    )

  Summary:
    Writes blocks of data starting at the specified address of the SD Card.

  Description:
    This function performs a blocking write operation to write blocks of data to
    the SD Card. The function returns true if the request was successfully
    executed. The function returns false under the following circumstances:
    - if the driver handle is invalid
    - if the source buffer pointer is NULL
    - if the number of blocks to be written is either zero or more than the number
      of blocks actually available
    - if the SD card is write-protected
    - if there was an error during the SD card write operation

  Precondition:
    The DRV_SDCARD_Initialize routine must have been called for the specified
    SDCARD driver instance.

    DRV_SDCARD_Open routine must have been called to obtain a valid opened device
    handle.

  Parameters:
    handle        - A valid open-instance handle, returned from the driver's
                    open function

    sourceBuffer  - The source buffer containing data to be written to the SD Card.

    blockStart    - Starting block address of SD Card where the writes should begin.

    nBlock        - Total number of blocks to be written.

  Returns:
    true - If the request was executed successfully.

    false - If there was an error executing the request.

  Example:
    <code>

    #define MY_BUFFER_SIZE          1024
    uint8_t myBuffer[MY_BUFFER_SIZE];

    // Address must be block aligned.
    uint32_t blockStart = 0x00;
    uint32_t nBlock = 2;

    // mySDCARDHandle is the handle returned by the DRV_SDCARD_Open function.

    if (DRV_SDCARD_SyncWrite(mySDCARDHandle, myBuffer, blockStart, nBlock) == true)
    {
        // Write is successful
    }
    else
    {
        // Error handling here
    }
    </code>

  Remarks:
    None.
*/
bool DRV_SDCARD_SyncWrite(
    const DRV_HANDLE handle,
    void* sourceBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);

// *****************************************************************************
/* Function:
    void DRV_SDCARD_AsyncWrite(
        const DRV_HANDLE handle,
        DRV_SDCARD_COMMAND_HANDLE* commandHandle,
        void* sourceBuffer,
        uint32_t blockStart,
        uint32_t nBlock
    )

  Summary:
    Writes blocks of data starting at the specified address of the SD Card.

  Description:
    This function schedules a non-blocking write operation for writing blocks
    of data to the SD Card. The function returns with a valid buffer handle
    in the commandHandle argument if the write request was scheduled successfully.
    The function adds the request to the driver instance queue and returns
    immediately. While the request is in the queue, the application buffer is
    owned by the driver and should not be modified. The function returns
    DRV_SDCARD_COMMAND_HANDLE_INVALID in the commandHandle argument under the
    following circumstances:
    - if a buffer object could not be allocated to the request
    - if the source buffer pointer is NULL
    - if the client opened the driver for read only
    - if the number of blocks to be written is either zero or more than the number
      of blocks actually available
    - if the write queue size is full or queue depth is insufficient
    - if the driver handle is invalid

    If the requesting client registered an event callback with the driver, the
    driver will issue a DRV_SDCARD_EVENT_COMMAND_COMPLETE event if the
    buffer was processed successfully or DRV_SDCARD_EVENT_COMMAND_ERROR
    event if the buffer was not processed successfully.

  Precondition:
    DRV_SDCARD_Open() routine must have been called to obtain a valid opened device
    handle. DRV_IO_INTENT_WRITE or DRV_IO_INTENT_READWRITE must have been specified
    as a parameter to this routine.

  Parameters:
    handle        - A valid open-instance handle, returned from the driver's
                    open function

    commandHandle - Pointer to an argument that will contain the return buffer
                    handle

    sourceBuffer  - The source buffer containing data to be programmed to the SD Card.

    blockStart    - Start block address of SD Card where the writes should begin.

    nBlock        - Total number of blocks to be written.

  Returns:
    The buffer handle is returned in the commandHandle argument. It will be
    DRV_SDCARD_COMMAND_HANDLE_INVALID if the request was not successful.

  Example:
    <code>

    uint8_t myBuffer[MY_BUFFER_SIZE];

    // address should be block aligned.
    uint32_t blockStart = 0x00;
    uint32_t nBlock = 2;
    DRV_SDCARD_COMMAND_HANDLE commandHandle;
    MY_APP_OBJ myAppObj;

    // mySDCARDHandle is the handle returned by the DRV_SDCARD_Open function.

    // Client registers an event handler with driver

    DRV_SDCARD_EventHandlerSet(mySDCARDHandle, APP_SDCardEventHandler, (uintptr_t)&myAppObj);

    DRV_SDCARD_AsyncWrite(mySDCARDHandle, &commandHandle, &myBuffer, blockStart, nBlock);

    if(commandHandle == DRV_SDCARD_COMMAND_HANDLE_INVALID)
    {
        // Error handling here
    }

    // Event is received when the buffer is processed.

    void APP_SDCardEventHandler(DRV_SDCARD_EVENT event,
            DRV_SDCARD_COMMAND_HANDLE commandHandle, uintptr_t contextHandle)
    {
        // contextHandle points to myAppObj.

        switch(event)
        {
            case DRV_SDCARD_EVENT_COMMAND_COMPLETE:

                // This means the data was transferred.
                break;

            case DRV_SDCARD_EVENT_COMMAND_ERROR:

                // Error handling here.
                break;

            default:
                break;
        }
    }

    </code>

  Remarks:
    None.
*/

void DRV_SDCARD_AsyncWrite(
    const DRV_HANDLE handle,
    DRV_SDCARD_COMMAND_HANDLE* commandHandle,
    void* sourceBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);

// *****************************************************************************
/* Function:
    bool DRV_SDCARD_IsAttached
    (
        const DRV_HANDLE handle
    )

  Summary:
    Returns the physical attach status of the SD Card.

  Description:
    This function returns the physical attach status of the SD Card.

  Precondition:
    The DRV_SDCARD_Initialize routine must have been called for the specified
    SDCARD driver instance.

    The DRV_SDCARD_Open routine must have been called to obtain a valid opened
    device handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open function

  Returns:
    true - If the SD Card is attached and initialized by the SDCARD driver.

    false - If the handle is invalid

  Example:
    <code>

    bool isSDCARDAttached;

    // mySDCARDHandle is the handle returned by the DRV_SDCARD_Open function.
    isSDCARDAttached = DRV_SDCARD_IsAttached(mySDCARDHandle);

    if (isSDCARDAttached == true)
    {
        // SD Card is attached and initialized by the SDCARD driver.
    }

    </code>

  Remarks:
    None.
*/

bool DRV_SDCARD_IsAttached(const DRV_HANDLE handle);

// *****************************************************************************
/* Function:
    bool DRV_SDCARD_IsWriteProtected
    (
        const DRV_HANDLE handle
    )

  Summary:
    Returns the write protect status of the SD Card.

  Description:
    This function returns true if the SD Card is write protected otherwise it
    returns false.

  Precondition:
    The DRV_SDCARD_Initialize routine must have been called for the specified
    SDCARD driver instance.

    The DRV_SDCARD_Open routine must have been called to obtain a valid opened
    device handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open function

  Returns:
    true  - If the attached SD Card is write protected. If the configured
    write protect GPIO pin is read High by the driver then the card is write
    protected. The status of the write protect GPIO pin is read by the driver
    during the media (SD Card) initialization.

    false - If the handle is not valid, or if the SD Card is not write
    protected.

  Example:
    <code>

    bool isWriteProtected;
    // mySDCARDHandle is the handle returned by the DRV_SDCARD_Open function.
    isWriteProtected = DRV_SDCARD_IsWriteProtected(mySDCARDHandle);

    if (isWriteProtected == true)
    {
        //SD Card is write protected.
    }

    </code>

  Remarks:
    None.
*/

bool DRV_SDCARD_IsWriteProtected( const DRV_HANDLE handle );

// *****************************************************************************
/* Function:
    SYS_MEDIA_GEOMETRY* DRV_SDCARD_GeometryGet
    (
        const DRV_HANDLE handle
    )

  Summary:
    Returns the geometry of the device.

  Description:
    This API gives the following geometrical details of the SD Card.
    - Media Property
    - Number of Read/Write/Erase regions in the SD Card
    - Number of Blocks and their size in each region of the device

  Precondition:
    The DRV_SDCARD_Initialize routine must have been called for the
    specified SDCARD driver instance.

    The DRV_SDCARD_Open routine must have been called to obtain a valid opened device
    handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open function

  Returns:
    SYS_MEDIA_GEOMETRY - Pointer to structure which holds the media geometry information.

  Example:
    <code>

    SYS_MEDIA_GEOMETRY* SDCARDGeometry;
    uint32_t readBlockSize, writeBlockSize, eraseBlockSize;
    uint32_t nReadBlocks, nReadRegions, totalSize;

    // mySDCARDHandle is the handle returned by the DRV_SDCARD_Open function.
    SDCARDGeometry = DRV_SDCARD_GeometryGet(mySDCARDHandle);

    readBlockSize  = SDCARDGeometry->geometryTable->blockSize;
    nReadBlocks = SDCARDGeometry->geometryTable->numBlocks;
    nReadRegions = SDCARDGeometry->numReadRegions;

    writeBlockSize  = (SDCARDGeometry->geometryTable +1)->blockSize;
    eraseBlockSize  = (SDCARDGeometry->geometryTable +2)->blockSize;

    totalSize = readBlockSize * nReadBlocks * nReadRegions;

    </code>

  Remarks:
    Refer to the "system/system_media.h" for the declaration of the SYS_MEDIA_GEOMETRY
    structure.
*/
SYS_MEDIA_GEOMETRY * DRV_SDCARD_GeometryGet ( const DRV_HANDLE handle );

// *****************************************************************************
/* Function:
    void DRV_SDCARD_EventHandlerSet
    (
        const DRV_HANDLE handle,
        const void* eventHandler,
        const uintptr_t context
    )

  Summary:
    For asynchronous SDCard driver, this function allows a client to identify 
    an event handling function for the driver to call back when queued operation 
    has completed. For the synchronous SDCard driver, the event handler is only 
    used by the file system to register for events from the synchronous SDCard 
    driver. Application using the synchronous SDCard driver must not use this API.

  Description:
    This function allows a client to identify an event handling function for
    the driver to call back when queued operation has completed.
    When a client queues a request for a read or a write operation, it is provided
    with a handle identifying the buffer that was added to the driver's buffer queue.
    The driver will pass this handle back to the client by calling "eventHandler"
    function when the queued operation has completed.

    The event handler should be set before the client performs any read or write
    operations that could generate events. The event handler once set, persists
    until the client closes the driver or sets another event handler (which could
    be a "NULL" pointer to indicate no callback).

  Precondition:
    The DRV_SDCARD_Initialize routine must have been called for the specified
    SDCARD driver instance.

    The DRV_SDCARD_Open routine must have been called to obtain a valid opened
    device handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open function

    eventHandler - Pointer to the event handler function implemented by the user

    context      - The value of parameter will be passed back to the client
                   unchanged, when the eventHandler function is called. It can
                   be used to identify any client specific data object that
                   identifies the instance of the client module (for example,
                   it may be a pointer to the client module's state structure).

  Returns:
    None.

  Example:
    For synchronous mode, this API is internally used only by the file system service,
    and not by the client application.
    The following example shows how clients of asynchronous SDCard driver can 
    register an event handler and develop an event handling routine to handle SDCard 
    events.
    <code>
    // myAppObj is an application specific state data object.
    MY_APP_OBJ myAppObj;

    uint8_t myBuffer[MY_BUFFER_SIZE];
    uint32_t blockStart, nBlock;
    DRV_SDCARD_COMMAND_HANDLE commandHandle;

    // mySDCARDHandle is the handle returned by the DRV_SDCARD_Open function.

    // Client registers an event handler with driver. This is done once.

    DRV_SDCARD_EventHandlerSet(mySDCARDHandle, APP_SDCardEventHandler, (uintptr_t)&myAppObj);

    DRV_SDCARD_Read(mySDCARDHandle, &commandHandle, myBuffer, blockStart, nBlock);

    if(commandHandle == DRV_SDCARD_COMMAND_HANDLE_INVALID)
    {
        // Error handling here
    }

    // Event Processing Technique. Event is received when operation is done.

    void APP_SDCardEventHandler(DRV_SDCARD_EVENT event,
            DRV_SDCARD_COMMAND_HANDLE handle, uintptr_t context)
    {
        // The context handle was set to an application specific
        // object. It is now retrievable easily in the event handler.
        MY_APP_OBJ* myAppObj = (MY_APP_OBJ *) context;

        switch(event)
        {
            case DRV_SDCARD_EVENT_COMMAND_COMPLETE:

                // This means the data was transferred.
                break;

            case DRV_SDCARD_EVENT_COMMAND_ERROR:

                // Error handling here.

                break;

            default:
                break;
        }
    }
    </code>

  Remarks:
    If the client does not want to be notified when the queued operation
    has completed, it does not need to register a callback. Application using
    the synchronous mode of the SDCARD driver must not use this API.
*/
void DRV_SDCARD_EventHandlerSet
(
    const DRV_HANDLE handle,
    const void * eventHandler,
    const uintptr_t context
);

// *****************************************************************************
/* Function:
    DRV_SDCARD_COMMAND_STATUS DRV_SDCARD_CommandStatus
    (
        const DRV_HANDLE handle,
        const DRV_SDCARD_COMMAND_HANDLE commandHandle
    )

  Summary:
    For asynchronous mode, this function returns the current status of the command. 
    For synchronous mode, the command status is only used by the file system. 
    The application must not use this API with the SDCARD driver in the synchronous mode.

  Description:
    This routine gets the current status of the command. The application must use
    this routine where the status of a scheduled command needs to be polled on. The
    function may return DRV_SDCARD_COMMAND_HANDLE_INVALID in a case where the command
    handle has expired. A command handle expires when the internal buffer object
    is re-assigned to another read or write request. It is recommended that this
    function be called regularly in order to track the command status correctly.

    The application can alternatively register an event handler to receive read or
    write operation completion events.

  Preconditions:
    The DRV_SDCARD_Initialize routine must have been called.

    The DRV_SDCARD_Open must have been called to obtain a valid opened device handle.

    A read or write request must have been submitted to the SDCARD driver.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open routine
    commandHandle - Handle to the command whose status is to be known.

  Returns:
    A DRV_SDCARD_COMMAND_STATUS value describing the current status of the command.
    Returns DRV_SDCARD_COMMAND_ERROR_UNKNOWN if the client handle or the command
    handle is not valid.

  Example:
    For synchronous mode, this API is internally used only by the file
    system service.
    The below example is provided for asynchronous mode of SDCard driver.
    <code>
    DRV_HANDLE                     handle;         // Returned from DRV_SDCARD_Open
    DRV_SDCARD_COMMAND_HANDLE      commandHandle;
    DRV_SDCARD_COMMAND_STATUS      status;

    status = DRV_SDCARD_CommandStatus(handle, commandHandle);
    if(status == DRV_SDCARD_COMMAND_COMPLETED)
    {
        // Operation Done
    }
    </code>

  Remarks:
    Application using the synchronous SDCARD driver must not use this API.
*/

DRV_SDCARD_COMMAND_STATUS DRV_SDCARD_CommandStatus(
    const DRV_HANDLE handle,
    const DRV_SDCARD_COMMAND_HANDLE commandHandle
);

// DOM-IGNORE-BEGIN

// *****************************************************************************
/* Function:
    void DRV_SDCARD_FS_Read
    (
        const DRV_HANDLE handle,
        DRV_SDCARD_COMMAND_HANDLE* commandHandle,
        void* targetBuffer,
        uint32_t blockStart,
        uint32_t nBlock
    )

  Summary:
    This routine provides a common interface to the file system to perform a media 
    read operation irrespective of the asynchronous/synchronous media driver.

  Description:
    This function is internally used by the file system. Application must not use this
    function.

  Preconditions:
    The DRV_SDCARD_Initialize routine must have been called.

    The DRV_SDCARD_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle        - A valid open-instance handle, returned from the driver's
                    open function

    commandHandle - Pointer to an argument that will contain the return buffer
                    handle

    targetBuffer  - Buffer into which the data read from the SD Card will be placed

    blockStart    - Start block address of the SD Card from where the read should begin.

    nBlock        - Total number of blocks to be read.

  Returns:
    The buffer handle is returned in the commandHandle argument. It will be
    DRV_SDCARD_COMMAND_HANDLE_INVALID if the request was not successful.

  Example:
    None. This function is internally used by the file system.

  Remarks:
    Client application must not use this API.
*/

void DRV_SDCARD_FS_Read(
    const DRV_HANDLE handle,
    DRV_SDCARD_COMMAND_HANDLE* commandHandle,
    void* targetBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);

// *****************************************************************************
/* Function:
    void DRV_SDCARD_FS_Write
    (
        const DRV_HANDLE handle,
        DRV_SDCARD_COMMAND_HANDLE* commandHandle,
        void* sourceBuffer,
        uint32_t blockStart,
        uint32_t nBlock
    )

  Summary:
    This routine provides a common interface to the file system to perform a media 
    write operation irrespective of the asynchronous/synchronous media driver.

  Description:
    This function is internally used by the file system. Application must not use this
    function.

  Preconditions:
    The DRV_SDCARD_Initialize routine must have been called.

    The DRV_SDCARD_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle        - A valid open-instance handle, returned from the driver's
                    open function

    commandHandle - Pointer to an argument that will contain the return buffer
                    handle

    sourceBuffer  - The source buffer containing data to be programmed to the SD Card.

    blockStart    - Start block address of SD Card where the writes should begin.

    nBlock        - Total number of blocks to be written.

  Returns:
    The buffer handle is returned in the commandHandle argument. It will be
    DRV_SDCARD_COMMAND_HANDLE_INVALID if the request was not successful.

  Example:
    None. This function is internally used by the file system.

  Remarks:
    Client application must not use this API.
*/

void DRV_SDCARD_FS_Write(
    const DRV_HANDLE handle,
    DRV_SDCARD_COMMAND_HANDLE* commandHandle,
    void* sourceBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);

// DOM-IGNORE-END

#ifdef __cplusplus
}
#endif

//#include "driver/sdcard/sdspi/drv_sdspi_local.h"

#endif // #ifndef _DRV_SDSPI_H
/*******************************************************************************
 End of File
*/
