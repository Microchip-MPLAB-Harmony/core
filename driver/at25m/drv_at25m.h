/*******************************************************************************
  DRV_AT25M Driver Interface Definition

  Company:
    Microchip Technology Inc.

  File Name:
    drv_at25m.h

  Summary:
    AT25M EEPROM Library Interface header.

  Description:
    The AT25M Driver Library provides a interface to access the AT25M external
    EEPROM.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
Copyright (c) 2018 released Microchip Technology Inc. All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED AS IS WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR
CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF
SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
*******************************************************************************/
//DOM-IGNORE-END

#ifndef _DRV_AT25M_H
#define _DRV_AT25M_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <stdio.h>
#include <stdbool.h>
#include "driver/driver.h"
#include "system/system.h"
#include "drv_at25m_definitions.h"

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
/* DRV_AT25M Transfer Status

 Summary:
    Defines the data type for AT25M Driver transfer status.

 Description:
    This will be used to indicate the current transfer status of the
    AT25M EEPROM driver operations.

 Remarks:
    None.
*/

typedef enum
{
    /* Transfer is being processed */
    DRV_AT25M_TRANSFER_BUSY,
    
    /* Transfer is successfully completed*/
    DRV_AT25M_TRANSFER_COMPLETED,
    
    /* Transfer had error or first transfer request is not made */
    DRV_AT25M_TRANSFER_ERROR
    
} DRV_AT25M_TRANSFER_STATUS;

// *****************************************************************************
/* DRV_AT25M Geometry data

 Summary:
    Defines the data type for AT25M EEPROM Geometry details.

 Description:
    This will be used to get the geometry details of the attached AT25M EEPROM
    device.

 Remarks:
    None.
*/

typedef struct
{
    uint32_t readBlockSize;
    uint32_t readNumBlocks;
    uint32_t readNumRegions;

    uint32_t writeBlockSize;
    uint32_t writeNumBlocks;
    uint32_t writeNumRegions;

    uint32_t eraseBlockSize;
    uint32_t eraseNumBlocks;
    uint32_t eraseNumRegions;

    uint32_t blockStartAddress;
    
} DRV_AT25M_GEOMETRY;

// *****************************************************************************
// *****************************************************************************
// Section: DRV_AT25M Driver Module Interface Routines
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    void DRV_AT25M_Initialize( void );
    
  Summary:
    Initializes the AT25M EEPROM device

  Description:
    This routine initializes the AT25M EEPROM device driver making it ready for
    clients to open and use. The initialization data is specified by the init
    parameter. It is a single instance driver, so this API should be called
    only once.

  Precondition:
    None.
  
  Parameters:
    index - Identifier for the instance to be initialized

    init  - Pointer to the init data structure containing any data necessary to
            initialize the driver.

  Returns:
    If successful, returns a valid handle to a driver instance object.
    Otherwise, returns SYS_MODULE_OBJ_INVALID.
  
  Example:
    <code>
    SYS_MODULE_OBJ   sysObjDrvAT25M0;
    
    DRV_AT25M_PLIB_INTERFACE drvAT25M0PlibAPI = {
        .writeRead = (DRV_WRITEREAD)SPI0_WriteRead,
        .write = (DRV_WRITE)SPI0_Write,
        .read = (DRV_READ)SPI0_Read,
        .isBusy = (DRV_IS_BUSY)SPI0_IsBusy,
        .errorGet = (DRV_ERROR_GET)SPI0_ErrorGet,
        .callbackRegister = (DRV_CALLBACK_REGISTER)SPI0_CallbackRegister,
    };

    DRV_AT25M_INIT drvAT25M0InitData =
    {
        .spiPlib = &drvAT25M0PlibAPI,
        .numClients = 1,
        .chipSelectPin = SYS_PORT_PIN_PA5,
        .holdPin = SYS_PORT_PIN_PA0,
        .writeProtectPin = SYS_PORT_PIN_PD11,
        .blockStartAddress = 0x0,
    };

    sysObjDrvAT25M0 = DRV_AT25M_Initialize(DRV_AT25M_INDEX_0, (SYS_MODULE_INIT *)&drvAT25M0InitData);

    </code>

  Remarks:
    This routine must be called before any other DRV_AT25M routine is called.
    This routine should only be called once during system initialization.
    This routine will block for hardware access.
*/

SYS_MODULE_OBJ DRV_AT25M_Initialize( const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT * const init);

// *****************************************************************************
/* Function:
    DRV_HANDLE DRV_AT25M_Open
    (
        const SYS_MODULE_INDEX drvIndex,
        const DRV_IO_INTENT ioIntent
    )

  Summary:
    Opens the specified AT25M driver instance and returns a handle to it.

  Description:
    This routine opens the specified AT25M driver instance and provides a
    handle that must be provided to all other client-level operations to
    identify the caller and the instance of the driver. The ioIntent
    parameter defines how the client interacts with this driver instance.

    This driver is a single client driver, so DRV_AT25M_Open API should be
    called only once until driver is closed.
    
  Precondition:
    Function DRV_AT25M_Initialize must have been called before calling this
    function.

  Parameters:
    drvIndex  - Identifier for the object instance to be opened

    intent -    Zero or more of the values from the enumeration DRV_IO_INTENT
                "ORed" together to indicate the intended use of the driver.

  Returns:
    If successful, the routine returns a valid open-instance handle (a number
    identifying both the caller and the module instance).

    If an error occurs, the return value is DRV_HANDLE_INVALID. Error can occur
    - if the  driver has been already opened once and in use.
    - if the driver peripheral instance being opened is not initialized or is
      invalid.

  Example:
    <code>
    DRV_HANDLE handle;

    handle = DRV_AT25M_Open(DRV_AT25M_INDEX_0, DRV_IO_INTENT_READWRITE);
    if (handle == DRV_HANDLE_INVALID)
    {
        // Unable to open the driver
        // May be the driver is not initialized
    }
    </code>

  Remarks:
    The handle returned is valid until the DRV_AT25M_Close routine is called.
    This routine will NEVER block waiting for hardware.
*/
DRV_HANDLE DRV_AT25M_Open(const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent);

// *****************************************************************************
/* Function:
    void DRV_AT25M_Close( DRV_Handle handle )

  Summary:
    Closes opened-instance of the AT25M driver.

  Description:
    This routine closes opened-instance of the AT25M driver, invalidating the
    handle. A new handle must be obtained by calling DRV_AT25M_Open
    before the caller may use the driver again.

  Precondition:
    DRV_AT25M_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle -    A valid open-instance handle, returned from the driver's
                open routine

  Returns:
    None.

  Example:
    <code>
    // 'handle', returned from the DRV_AT25M_Open

    DRV_AT25M_Close(handle);

    </code>

  Remarks:
    None.
*/
void DRV_AT25M_Close(const DRV_HANDLE handle);

// *****************************************************************************
/* Function:
    bool DRV_AT25M_Read(const DRV_HANDLE handle, void *rxData, uint32_t rxDataLength, uint32_t address );

  Summary:
    Reads 'n' bytes of data from the specified start address of EEPROM.

  Description:
    This function schedules a non-blocking read operation for requested number
    of data bytes from given address of EEPROM.

    The requesting client should call DRV_AT25M_TransferStatusGet() API to know
    the current status of the request.
    
  Precondition:
    DRV_AT25M_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle         - A valid open-instance handle, returned from the driver's
                      open routine
    *rxData        - Buffer pointer into which the data read from the DRV_AT25M
                      Flash memory will be placed.

    rxDataLength   - Total number of bytes to be read.

    address        - Read memory start address from where the data should be
                      read.

  Returns:
    false
    - if handle is not right
    - if the driver is busy handling another transfer request

    true
    - if the read request is accepted.

  Example:
    <code>

    #define BUFFER_SIZE  1024
    #define MEM_ADDRESS  0x0

    uint8_t readBuffer[BUFFER_SIZE];
    
    // myHandle is the handle returned from DRV_AT25M_Open API.
    if (true != DRV_AT25M_Read(myHandle, &readBuffer, BUFFER_SIZE, MEM_ADDRESS))
    {
        // Error handling here
    }

    </code>

  Remarks:
    None.
*/

bool DRV_AT25M_Read(const DRV_HANDLE handle, void *rxData, uint32_t rxDataLength, uint32_t address );

// *****************************************************************************
/* Function:
    bool DRV_AT25M_PageWrite(const DRV_HANDLE handle, uint32_t *txData, uint32_t txDataLength, uint32_t address);

  Summary:
    Writes 'n' bytes of data starting at the specified address.

  Description:
    This function schedules a non-blocking write operation for writing
    txDataLength bytes of data starting from given address of EEPROM. 

    The requesting client should call DRV_AT25M_TransferStatusGet() API to know
    the current status of the request.

  Preconditions:
    DRV_AT25M_Open must have been called to obtain a valid opened device handle.
   
  Parameters:
    handle         - A valid open-instance handle, returned from the driver's
                      open routine
    *txData        - The source buffer containing data to be programmed into AT25M 
                      EEPROM

    txDataLength   - Total number of bytes to be written. It should not be greater
                      than page size

    address        - Write memory start address from where the data should be
                      written

  Returns:
    false
    - if handle is not right
    - if the driver is busy handling another transfer request

    true
    - if the write request is successfully accepted.

  Example:
    <code>

    #define PAGE_SIZE    256
    #define BUFFER_SIZE  1024
    #define MEM_ADDRESS  0x0

    uint8_t writeBuffer[BUFFER_SIZE];
 
    // myHandle is the handle returned from DRV_AT25M_Open API.
     
    if (true != DRV_AT25M_PageWrite(myHandle, &writeBuffer, PAGE_SIZE, MEM_ADDRESS))
    {
        // Error handling here
    }
    else
    {
        // Wait for write to be completed
        while(DRV_AT25M_TRANSFER_BUSY == DRV_AT25M_TransferStatusGet(myHandle));
    }
    </code>

  Remarks:
    None.
*/

bool DRV_AT25M_PageWrite(const DRV_HANDLE handle, void *txData, uint32_t txDataLength, uint32_t address );

// *****************************************************************************
/* Function:
    DRV_AT25M_TRANSFER_STATUS DRV_AT25M_TransferStatusGet(const DRV_HANDLE handle);

  Summary:
    Gets the current status of the transfer request.

  Description:
    This routine gets the current status of the transfer request.

  Preconditions:
    DRV_AT25M_PageWrite or DRV_AT25M_Read must have been called to obtain the
    status of transfer.

  Parameters:
    handle      - A valid open-instance handle, returned from the driver's
                   open routine

  Returns:
    One of the status element from the enum DRV_AT25M_TRANSFER_STATUS.
 
  Example:
    <code>
    // myHandle is the handle returned from DRV_AT25M_Open API.
    
    if (DRV_AT25M_TRANSFER_COMPLETED == DRV_AT25M_TransferStatusGet(myHandle))
    {
        // Operation Done
    }
    </code>

  Remarks:
    None.
*/

DRV_AT25M_TRANSFER_STATUS DRV_AT25M_TransferStatusGet(const DRV_HANDLE handle);

// *****************************************************************************
/* Function:
    bool DRV_AT25M_GeometryGet(const DRV_HANDLE handle, DRV_AT25M_GEOMETRY *geometry);

  Summary:
    Returns the geometry of the device.

  Description:
    This API gives the following geometrical details of the DRV_AT25M Flash:
    - Number of Read/Write/Erase Blocks and their size in each region of the device

  Precondition:
    DRV_AT25M_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle      - A valid open-instance handle, returned from the driver's
                   open routine
    *geometry   - pointer to flash device geometry table instance

  Returns:
    false
    - if handle is invalid

    true
    - if able to get the geometry details of the flash

  Example:
    <code> 
    
    DRV_AT25M_GEOMETRY eepromGeometry;
    uint32_t readBlockSize, writeBlockSize, eraseBlockSize;
    uint32_t nReadBlocks, nReadRegions, totalFlashSize;

    // myHandle is the handle returned from DRV_AT25M_Open API.
    
    DRV_AT25M_GeometryGet(myHandle, &eepromGeometry);

    readBlockSize  = eepromGeometry.readBlockSize;
    nReadBlocks = eepromGeometry.readNumBlocks;
    nReadRegions = eepromGeometry.readNumRegions;

    writeBlockSize  = eepromGeometry.writeBlockSize;
    eraseBlockSize  = eepromGeometry.eraseBlockSize;

    totalFlashSize = readBlockSize * nReadBlocks * nReadRegions;

    </code>

  Remarks:
    None.
*/

bool DRV_AT25M_GeometryGet(const DRV_HANDLE handle, DRV_AT25M_GEOMETRY *geometry);

#ifdef __cplusplus
}
#endif

#include "driver/at25m/src/drv_at25m_local.h"

#endif // #ifndef _DRV_AT25M_H
/*******************************************************************************
 End of File
*/