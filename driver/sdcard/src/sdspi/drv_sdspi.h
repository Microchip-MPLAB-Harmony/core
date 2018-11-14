/*******************************************************************************
  SD Card (SPI) Driver Interface Definition

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdspi.h

  Summary:
    SD Card (SPI) Library Interface header.

  Description:
    The SD Card (SPI) Driver Library provides a interface to access the SD Card
    over SPI interface.
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

#ifndef _DRV_SDSPI_H
#define _DRV_SDSPI_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <stdio.h>
#include <stdbool.h>
#include "driver/driver.h"
#include "system/system.h"
#include "drv_sdspi_definitions.h"
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
/* SDSPI Driver Events

   Summary
    Identifies the possible events that can result from a request.

   Description
    This enumeration identifies the possible events that can result from a
    read or a write request issued by the client.

   Remarks:
    One of these values is passed in the "event" parameter of the event
    handling callback function that client registered with the driver by
    calling the DRV_SDSPI_EventHandlerSet function when a request is completed.
*/

typedef enum
{
    /* Operation has been completed successfully. */
    DRV_SDSPI_EVENT_COMMAND_COMPLETE = SYS_MEDIA_EVENT_BLOCK_COMMAND_COMPLETE,

    /* There was an error during the operation */
    DRV_SDSPI_EVENT_COMMAND_ERROR = SYS_MEDIA_EVENT_BLOCK_COMMAND_ERROR

} DRV_SDSPI_EVENT;

typedef enum
{
    /*Done OK and ready */
    DRV_SDSPI_COMMAND_COMPLETED          = SYS_MEDIA_COMMAND_COMPLETED,

    /*Scheduled but not started */
    DRV_SDSPI_COMMAND_QUEUED             = SYS_MEDIA_COMMAND_QUEUED,

    /*Currently being in transfer */
    DRV_SDSPI_COMMAND_IN_PROGRESS        = SYS_MEDIA_COMMAND_IN_PROGRESS,

    /*Unknown Command */
    DRV_SDSPI_COMMAND_ERROR_UNKNOWN      = SYS_MEDIA_COMMAND_UNKNOWN,

} DRV_SDSPI_COMMAND_STATUS;

typedef SYS_MEDIA_BLOCK_COMMAND_HANDLE  DRV_SDSPI_COMMAND_HANDLE;

// *****************************************************************************
/* SDSPI Driver Invalid Command Handle.

  Summary:
    SDSPI Driver's Invalid Command Handle.

  Description:
    This value defines the SDSPI Driver Invalid Command Handle. This value
    is returned by read or write routines when the command request was not
    accepted.

  Remarks:
    None.
*/

#define DRV_SDSPI_COMMAND_HANDLE_INVALID SYS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID

// *****************************************************************************
/* SDSPI Driver Event Handler Function Pointer

   Summary
    Pointer to a SDSPI Driver Event handler function

   Description
    This data type defines the required function signature for the SDSPI event
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
    void APP_MySDSPIEventHandler
    (
        DRV_SDSPI_EVENT event,
        DRV_SDSPI_COMMAND_HANDLE commandHandle,
        uintptr_t context
    )
    {
        MY_APP_DATA_STRUCT pAppData = (MY_APP_DATA_STRUCT) context;

        switch(event)
        {
            case DRV_SDSPI_EVENT_COMMAND_COMPLETE:

                // Handle the completed buffer.
                break;

            case DRV_SDSPI_EVENT_COMMAND_ERROR:
            default:

                // Handle error.
                break;
        }
    }
    </code>

  Remarks:
    If the event is DRV_SDSPI_EVENT_COMMAND_COMPLETE, it means that the
    write or a erase operation was completed successfully.

    If the event is DRV_SDSPI_EVENT_COMMAND_ERROR, it means that the scheduled
    operation was not completed successfully.

    The context parameter contains the handle to the client context, provided
    at the time the event handling function was  registered using the
    DRV_SDSPI_EventHandlerSet function. This context handle value is
    passed back to the client as the "context" parameter.  It can be any value
    necessary to identify the client context or instance (such as a pointer to
    the client's data) instance of the client that made the read/write/erase
    request.
*/
typedef SYS_MEDIA_EVENT_HANDLER     DRV_SDSPI_EVENT_HANDLER;

// *****************************************************************************
// *****************************************************************************
// Section: DRV_SDSPI Driver Module Interface Routines
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    SYS_MODULE_OBJ DRV_SDSPI_Initialize
     (
         const SYS_MODULE_INDEX index,
         const SYS_MODULE_INIT  * const init
     );

  Summary:
    Initializes the SD Card driver.
	<p><b>Implementation:</b> Dynamic</p>

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
    DRV_SDSPI_INIT      drvSDSPI0InitData;
    SYS_MODULE_OBJ      objectHandle;

    // Populate the SD Card initialization structure

    objectHandle = DRV_SDSPI_Initialize(DRV_SDSPI_INDEX_0, (SYS_MODULE_INIT *)&drvSDSPI0InitData);
    if (SYS_MODULE_OBJ_INVALID == objectHandle)
    {
        // Handle error
    }
    </code>

  Remarks:
    This routine must be called before any other SD Card routine is called.

    This routine should only be called once during system initialization.

    This routine will NEVER block for hardware access. If the operation requires
    time to allow the hardware to reinitialize, it will be reported by the
    DRV_SDSPI_Status operation. The system must use DRV_SDSPI_Status to find out
    when the driver is in the ready state.

*/

SYS_MODULE_OBJ DRV_SDSPI_Initialize(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT * const init
);

// *****************************************************************************
/* Function:
    SYS_STATUS DRV_SDSPI_Status
     (
         SYS_MODULE_OBJ object
     );

  Summary:
    Provides the current status of the SD Card driver module.
	<p><b>Implementation:</b> Dynamic</p>

  Description:
    This routine provides the current status of the SD Card driver module.

  Precondition:
    Function DRV_SDSPI_Initialize must have been called before calling this
    function

  Parameters:
    object                    - Driver object handle, returned from the
                                DRV_SDSPI_Initialize routine

  Returns:
    SYS_STATUS_READY          - Indicates that the driver has been initialized
                                and is ready to accept requests from the client.

    SYS_STATUS_UNINITIALIZED   - Indicates that the driver has not been
                                 initialized.

  Example:
    <code>
    SYS_MODULE_OBJ      object;     // Returned from DRV_SDSPI_Initialize
    SYS_STATUS          status;

    status = DRV_SDSPI_Status(object);

    if (SYS_STATUS_UNINITIALIZED == status)
    {
        // Driver is uninitialized
    }
    </code>

  Remarks:
    This operation can be used to determine if the driver is initialized or not.
    This routine will NEVER block waiting for hardware.
*/
SYS_STATUS DRV_SDSPI_Status( const SYS_MODULE_OBJ object );

// *****************************************************************************
/* Function:
    DRV_HANDLE DRV_SDSPI_Open
     (
         const SYS_MODULE_INDEX drvIndex,
         const DRV_IO_INTENT    intent
     );

  Summary:
    Opens the specified SD Card driver instance and returns a handle to it.
	<p><b>Implementation:</b> Dynamic</p>

  Description:
    This routine opens the specified SD Card driver instance and provides a
    handle that must be provided to all other client-level operations to
    identify the caller and the instance of the driver.

  Precondition:
    Function DRV_SDSPI_Initialize must have been called before calling this
    function.

  Parameters:
    drvIndex    - Identifier for the object instance to be opened

    intent      - Zero or more of the values from the enumeration
                  DRV_IO_INTENT "ORed" together to indicate the intended use
                  of the driver. Supports only DRV_IO_INTENT_EXCLUSIVE.

  Returns:
    If successful, the routine returns a valid open-instance handle (a number
    identifying both the caller and the module instance).

    If an error occurs, the return value is DRV_HANDLE_INVALID.

  Example:
    <code>
    DRV_HANDLE  handle;

    handle = DRV_SDSPI_Open (DRV_SDSPI_INDEX_0, DRV_IO_INTENT_EXCLUSIVE);

    if (DRV_HANDLE_INVALID == handle)
    {
        // Unable to open the driver
    }
    </code>

  Remarks:
    The handle returned is valid until the DRV_SDSPI_Close routine is called.
    This routine may block for other client-level operations to complete.
*/
DRV_HANDLE DRV_SDSPI_Open(const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent);

// *****************************************************************************
/* Function:
    void DRV_SDSPI_Close
     (
         DRV_HANDLE handle
     );

  Summary:
    Closes an opened-instance of the SD Card driver.
	<p><b>Implementation:</b> Dynamic</p>

  Description:
    This routine closes an opened-instance of the SD Card driver, invalidating
    the handle.

  Precondition:
    The DRV_SDSPI_Initialize routine must have been called for the specified
    SD Card driver instance.

    DRV_SDSPI_Open must have been called to obtain a valid opened device
    handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open routine

  Returns:
    None

  Example:
    <code>
    DRV_HANDLE handle;  // Returned from DRV_SDSPI_Open

    DRV_SDSPI_Close (handle);
    </code>

  Remarks:
    After calling this routine, the handle passed in "handle" must not be used
    with any of the remaining driver routines.  A new handle must be obtained by
    calling DRV_SDSPI_Open before the caller may use the driver again.

    Note:
    Usually there is no need for the driver client to verify that the Close
    operation has completed.
*/
void DRV_SDSPI_Close(const DRV_HANDLE handle);

// *****************************************************************************
/* Function:
    void DRV_SDSPI_Tasks
     (
         SYS_MODULE_OBJ object
     );

  Summary:
    Maintains the driver's state machine.
	<p><b>Implementation:</b> Dynamic</p>

  Description:
    This routine is used to maintain the driver's internal state machine.
    For synchronous driver, the task routine periodically checks for SD card
    attach/detach event and initializes the SD card.

  Precondition:
    The DRV_SDSPI_Initialize routine must have been called for the specified
    SDSPI driver instance.

  Parameters:
    object      - Object handle for the specified driver instance (returned from
                  DRV_SDSPI_Initialize)

  Returns:
    None

  Example:
    <code>
    //sysObj.drvSDSPI0 is returned by the driver initialization routine

    //For asynchronous driver
    while (true)
    {
        DRV_SDSPI_Tasks (sysObj.drvSDSPI0);

        // Perform other tasks
    }

    //For synchronous driver
    while(1)
    {
        DRV_SDSPI_Tasks(sysObj.drvSDSPI0);

        // Yield and allow other threads to run
        vTaskDelay(100 / portTICK_PERIOD_MS);
    }
    </code>

  Remarks:
    This routine is normally not called directly by an application. For
    asynchronous driver, this routine is called from the system's Tasks routine
    (SYS_Tasks). For synchronous driver, this routine is called from a separate
    RTOS thread.
*/

void DRV_SDSPI_Tasks ( SYS_MODULE_OBJ object );

// *****************************************************************************
/* Function:
    bool DRV_SDSPI_SyncRead (
        const DRV_HANDLE handle,
        void* targetBuffer,
        uint32_t blockStart,
        uint32_t nBlock
    );

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

    If the requesting client registered an event callback with the driver, the
    driver will issue a DRV_SDSPI_EVENT_COMMAND_COMPLETE event if the
    request was processed successfully or DRV_SDSPI_EVENT_COMMAND_ERROR
    event if the request was not processed successfully.

  Precondition:
    The DRV_SDSPI_Initialize routine must have been called for the specified SDSPI
    driver instance.

    DRV_SDSPI_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle        - A valid open-instance handle, returned from the driver's
                    open function

    targetBuffer  - Buffer into which the data read from the SD Card will be placed

    blockStart    - Start block address of the SD Card from where the read should begin.

    nBlock        - Total number of blocks to be read.

  Returns:
    Returns true if the request was executed successfully. Returns false if the
    request was not executed successfully.

  Example:
    <code>
    #define MY_BUFFER_SIZE 1024
    uint8_t myBuffer[MY_BUFFER_SIZE];

    // address should be block aligned.
    uint32_t blockStart = 0x00;
    uint32_t nBlock = 2;

    // mySDSPIHandle is the handle returned
    // by the DRV_SDSPI_Open function.

    if (DRV_SDSPI_Read(mySDSPIHandle, myBuffer, blockStart, nBlock) == true)
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

bool DRV_SDSPI_SyncRead (
    const DRV_HANDLE handle,
    void* targetBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);

// *****************************************************************************
/* Function:
    bool DRV_SDSPI_SyncWrite(
        const DRV_HANDLE handle,
        void* sourceBuffer,
        uint32_t blockStart,
        uint32_t nBlock
    );

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
    The DRV_SDSPI_Initialize() routine must have been called for the specified
    SDSPI driver instance.

    DRV_SDSPI_Open() routine must have been called to obtain a valid opened device
    handle.

  Parameters:
    handle        - A valid open-instance handle, returned from the driver's
                    open function

    sourceBuffer  - The source buffer containing data to be programmed to the SD Card.

    blockStart    - Start block address of SD Card where the writes should begin.

    nBlock        - Total number of blocks to be written.

  Returns:
    Returns true if the request was executed successfully. Returns false if the
    request was not successful.

  Example:
    <code>

    #define MY_BUFFER_SIZE          1024
    uint8_t myBuffer[MY_BUFFER_SIZE];

    // address should be block aligned.
    uint32_t blockStart = 0x00;
    uint32_t nBlock = 2;

    // mySDSPIHandle is the handle returned
    // by the DRV_SDSPI_Open function.

    if (DRV_SDSPI_Write(mySDSPIHandle, myBuffer, blockStart, nBlock) == true)
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
bool DRV_SDSPI_SyncWrite(
    const DRV_HANDLE handle,
    void* sourceBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);

// *****************************************************************************
/* Function:
    bool DRV_SDSPI_IsAttached
    (
        const DRV_HANDLE handle
    );

  Summary:
    Returns the physical attach status of the SD Card.

  Description:
    This function returns the physical attach status of the SD Card.

  Precondition:
    The DRV_SDSPI_Initialize() routine must have been called for the specified
    SDSPI driver instance.

    The DRV_SDSPI_Open() routine must have been called to obtain a valid opened
    device handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open function

  Returns:
    Returns false if the handle is invalid; otherwise returns the attach status
    of the SD Card. Returns true if the SD Card is attached and initialized by the
    SDSPI driver otherwise returns false.

  Example:
    <code>


    bool isSDSPIAttached;
    isSDSPIAttached = DRV_SDSPI_isAttached(drvSDSPIHandle);

    </code>

  Remarks:
    None.
*/

bool DRV_SDSPI_IsAttached(const DRV_HANDLE handle);

// *****************************************************************************
/* Function:
    bool DRV_SDSPI_IsWriteProtected
    (
        const DRV_HANDLE handle
    );

  Summary:
    Returns the write protect status of the SDSPI.

  Description:
    This function returns true if the SD Card is write protected otherwise it
    returns false.

  Precondition:
    The DRV_SDSPI_Initialize() routine must have been called for the specified
    SDSPI driver instance.

    The DRV_SDSPI_Open() routine must have been called to obtain a valid opened
    device handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open function

  Returns:
    Returns true if the attached SD Card is write protected. If the configured
    write protect GPIO pin is read High by the driver then the card is write
    protected. The status of the write protect GPIO pin is read by the driver
    during SD card initialization.
    Returns false if the handle is not valid, or if the SD Card is not write
    protected.

  Example:
    <code>

    bool isWriteProtected;
    isWriteProtected = DRV_SDSPI_IsWriteProtected(drvSDSPIHandle);

    </code>

  Remarks:
    None.
*/

bool DRV_SDSPI_IsWriteProtected( const DRV_HANDLE handle );

// *****************************************************************************
/* Function:
    SYS_FS_MEDIA_GEOMETRY * DRV_SDSPI_GeometryGet
    (
        const DRV_HANDLE handle
    );

  Summary:
    Returns the geometry of the device.

  Description:
    This API gives the following geometrical details of the SD Card.
    - Media Property
    - Number of Read/Write/Erase regions in the SD Card
    - Number of Blocks and their size in each region of the device

  Precondition:
    The DRV_SDSPI_Initialize() routine must have been called for the
    specified SDSPI driver instance.

    The DRV_SDSPI_Open() routine must have been called to obtain a valid opened device
    handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open function

  Returns:
    SYS_FS_MEDIA_GEOMETRY - Pointer to structure which holds the media geometry information.

  Example:
    <code>

    SYS_FS_MEDIA_GEOMETRY * SDSPIGeometry;
    uint32_t readBlockSize, writeBlockSize, eraseBlockSize;
    uint32_t nReadBlocks, nReadRegions, totalSize;

    SDSPIGeometry = DRV_SDSPI_GeometryGet(SDSPIOpenHandle1);

    readBlockSize  = SDSPIGeometry->geometryTable->blockSize;
    nReadBlocks = SDSPIGeometry->geometryTable->numBlocks;
    nReadRegions = SDSPIGeometry->numReadRegions;

    writeBlockSize  = (SDSPIGeometry->geometryTable +1)->blockSize;
    eraseBlockSize  = (SDSPIGeometry->geometryTable +2)->blockSize;

    totalSize = readBlockSize * nReadBlocks * nReadRegions;

    </code>

  Remarks:
    None.
*/
SYS_MEDIA_GEOMETRY * DRV_SDSPI_GeometryGet ( const DRV_HANDLE handle );

// *****************************************************************************
/* Function:
    void DRV_SDSPI_EventHandlerSet
    (
        const DRV_HANDLE handle,
        const void * eventHandler,
        const uintptr_t context
    );

  Summary:
    Allows a client to identify an event handling function for the driver to
    call back when queued operation has completed.

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
    The DRV_SDSPI_Initialize() routine must have been called for the specified
    SDSPI driver instance.

    The DRV_SDSPI_Open() routine must have been called to obtain a valid opened
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
    <code>
    // myAppObj is an application specific state data object.
    MY_APP_OBJ myAppObj;

    uint8_t myBuffer[MY_BUFFER_SIZE];
    uint32_t blockStart, nBlock;
    DRV_SDSPI_COMMAND_HANDLE commandHandle;

    // drvSDSPIHandle is the handle returned
    // by the DRV_SDSPI_Open function.

    // Client registers an event handler with driver. This is done once.

    DRV_SDSPI_EventHandlerSet(drvSDSPIHandle, APP_SDSPIEventHandler, (uintptr_t)&myAppObj);

    DRV_SDSPI_Read(drvSDSPIHandle, &commandHandle, &myBuffer, blockStart, nBlock);

    if(DRV_SDSPI_COMMAND_HANDLE_INVALID == commandHandle)
    {
        // Error handling here
    }

    // Event Processing Technique. Event is received when operation is done.

    void APP_SDSPIEventHandler(DRV_SDSPI_EVENT event,
            DRV_SDSPI_COMMAND_HANDLE handle, uintptr_t context)
    {
        // The context handle was set to an application specific
        // object. It is now retrievable easily in the event handler.
        MY_APP_OBJ myAppObj = (MY_APP_OBJ *) context;

        switch(event)
        {
            case DRV_SDSPI_EVENT_COMMAND_COMPLETE:

                // This means the data was transferred.
                break;

            case DRV_SDSPI_EVENT_COMMAND_ERROR:

                // Error handling here.

                break;

            default:
                break;
        }
    }
    </code>

  Remarks:
    If the client does not want to be notified when the queued operation
    has completed, it does not need to register a callback.
*/
void DRV_SDSPI_EventHandlerSet
(
    const DRV_HANDLE handle,
    const void * eventHandler,
    const uintptr_t context
);

// *****************************************************************************
/* Function:
    DRV_SDSPI_COMMAND_STATUS DRV_SDSPI_CommandStatus
    (
        const DRV_HANDLE handle,
        const DRV_SDSPI_COMMAND_HANDLE commandHandle
    );

  Summary:
    Gets the current status of the command.

  Description:
    This routine gets the current status of the command. The application must use
    this routine where the status of a scheduled command needs to be polled on. The
    function may return DRV_SDSPI_COMMAND_HANDLE_INVALID in a case where the command
    handle has expired. A command handle expires when the internal buffer object
    is re-assigned to another read or write request. It is recommended that this
    function be called regularly in order to track the command status correctly.

    The application can alternatively register an event handler to receive read or
    write operation completion events.

  Preconditions:
    The DRV_SDSPI_Initialize() routine must have been called.

    The DRV_SDSPI_Open() must have been called to obtain a valid opened device handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open routine

  Returns:
    A DRV_SDSPI_COMMAND_STATUS value describing the current status of the command.
    Returns DRV_SDSPI_COMMAND_HANDLE_INVALID if the client handle or the command
    handle is not valid.

  Example:
    <code>
    DRV_HANDLE                    handle;         // Returned from DRV_SDSPI_Open
    DRV_SDSPI_COMMAND_HANDLE      commandHandle;
    DRV_SDSPI_COMMAND_STATUS      status;

    status = DRV_SDSPI_CommandStatus(handle, commandHandle);
    if(status == DRV_SDSPI_COMMAND_COMPLETED)
    {
        // Operation Done
    }
    </code>

  Remarks:
    This routine will not block for hardware access and will immediately return
    the current status.
*/

DRV_SDSPI_COMMAND_STATUS DRV_SDSPI_CommandStatus(
    const DRV_HANDLE handle,
    const DRV_SDSPI_COMMAND_HANDLE commandHandle
);

#ifdef __cplusplus
}
#endif

    
void DRV_SDSPI_FS_Read (
    const DRV_HANDLE handle,
    DRV_SDSPI_COMMAND_HANDLE* commandHandle,
    void* targetBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);

void DRV_SDSPI_FS_Write(
    const DRV_HANDLE handle,
    DRV_SDSPI_COMMAND_HANDLE* commandHandle,
    void* sourceBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);

#include "driver/sdcard/sdspi/src/drv_sdspi_local.h"

#endif // #ifndef _DRV_SDSPI_H
/*******************************************************************************
 End of File
*/
