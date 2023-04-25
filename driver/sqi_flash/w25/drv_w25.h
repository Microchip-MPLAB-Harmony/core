/*******************************************************************************
  W25 Driver Interface Definition

  Company:
    Microchip Technology Inc.

  File Name:
    drv_w25.h

  Summary:
    W25 Driver Interface Definition

  Description:
    The W25 driver provides a simple interface to manage the W25 series
    of SQI Flash Memory connected to Microchip microcontrollers. This file
    defines the interface definition for the W25 driver.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2023 Microchip Technology Inc. and its subsidiaries.
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

#ifndef DRV_W25_H
#define DRV_W25_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include "drv_w25_definitions.h"

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

/*
 Summary:
    W25 Driver Transfer Status

 Description:
    This data type will be used to indicate the current transfer status for W25
    driver.

 Remarks:
    None.
*/

typedef enum
{
    /* Transfer is being processed */
    DRV_W25_TRANSFER_BUSY,
    /* Transfer is successfully completed*/
    DRV_W25_TRANSFER_COMPLETED,
    /* Transfer had error*/
    DRV_W25_TRANSFER_ERROR_UNKNOWN,
} DRV_W25_TRANSFER_STATUS;

/*
 Summary:
    W25 Device Geometry data.

 Description:
    This data type will be used to get the geometry details of the
    W25 flash device.

 Remarks:
    None.
*/

typedef struct
{
    uint32_t read_blockSize;
    uint32_t read_numBlocks;
    uint32_t numReadRegions;

    uint32_t write_blockSize;
    uint32_t write_numBlocks;
    uint32_t numWriteRegions;

    uint32_t erase_blockSize;
    uint32_t erase_numBlocks;
    uint32_t numEraseRegions;

    uint32_t blockStartAddress;
} DRV_W25_GEOMETRY;

// *****************************************************************************
// *****************************************************************************
// Section: W25 Driver Module Interface Routines
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    SYS_MODULE_OBJ DRV_W25_Initialize
    (
        const SYS_MODULE_INDEX drvIndex,
        const SYS_MODULE_INIT *const init
    );

  Summary:
    Initializes the W25 Driver

  Description:
    This routine initializes the W25 driver making it ready for client to use.

  Precondition:
    None.

  Parameters:
    drvIndex -  Identifier for the instance to be initialized

    init     -  Pointer to a data structure containing any data necessary to
                initialize the driver.

  Returns:
    If successful, returns a valid driver instance object.
    Otherwise it returns SYS_MODULE_OBJ_INVALID.

  Example:
    <code>    

    SYS_MODULE_OBJ  objectHandle;

    const DRV_W25_PLIB_INTERFACE drvW25PlibAPI =
    {
        .Write               = QMSPI0_Write,
        .Read                = QMSPI0_Read,
        .DMATransferRead     = QMSPI0_DMATransferRead,
        .DMATransferWrite    = QMSPI0_DMATransferWrite
    };

    const DRV_W25_INIT drvW25InitData =
    {
        .w25Plib         = &drvW25PlibAPI,
    };

    objectHandle = DRV_W25_Initialize((SYS_MODULE_INDEX)DRV_W25_INDEX, (SYS_MODULE_INIT *)&drvW25InitData);

    if (SYS_MODULE_OBJ_INVALID == objectHandle)
    {
        
    }
    </code>

  Remarks:
    This routine must be called before any other W25 driver routine is called.

    This routine should only be called once during system initialization.
*/

SYS_MODULE_OBJ DRV_W25_Initialize
(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT *const init
);

// ****************************************************************************
/* Function:
    DRV_HANDLE DRV_W25_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent );

  Summary:
    Opens the specified W25 driver instance and returns a handle to it

  Description:
    This routine opens the specified W25 driver instance and provides a handle.

    It performs the following blocking operations:
    - Resets the Flash Device
    - Puts it on QUAD IO Mode
    - Unlocks the flash if DRV_W25_Open was called with write intent.

    This handle must be provided to all other client-level operations to identify
    the caller and the instance of the driver.

  Preconditions:
    Function DRV_W25_Initialize must have been called before calling this
    function.

    Driver should be in ready state to accept the request. Can be checked by
    calling DRV_W25_Status().

  Parameters:
    drvIndex   -  Identifier for the instance to be opened

    ioIntent   -  Zero or more of the values from the enumeration
                  DRV_IO_INTENT "ORed" together to indicate the intended use
                  of the driver

  Returns:
    If successful, the routine returns a valid open-instance handle (a
    number identifying both the caller and the module instance).

    If an error occurs, DRV_HANDLE_INVALID is returned. Errors can occur
    under the following circumstances:
        - if the driver hardware instance being opened is not initialized.

  Example:
    <code>
    DRV_HANDLE handle;

    handle = DRV_W25_Open(DRV_W25_INDEX);
    if (DRV_HANDLE_INVALID == handle)
    {
        
    }
    </code>

  Remarks:
    The handle returned is valid until the DRV_W25_Close routine is called.

    If the driver has already been opened, it should not be opened again.
*/

DRV_HANDLE DRV_W25_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent );

// *****************************************************************************
/* Function:
    void DRV_W25_Close( const DRV_HANDLE handle );

  Summary:
    Closes an opened-instance of the W25 driver

  Description:
    This routine closes an opened-instance of the W25 driver, invalidating
    the handle.

  Precondition:
    DRV_W25_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open routine

  Returns:
    None

  Example:
    <code>
    DRV_HANDLE handle;  

    DRV_W25_Close(handle);
    </code>

  Remarks:
    After calling this routine, the handle passed in "handle" must not be used
    with any of the remaining driver routines. A new handle must be obtained by
    calling DRV_W25_Open before the caller may use the driver again.

    Usually there is no need for the driver client to verify that the Close
    operation has completed.
*/

void DRV_W25_Close( const DRV_HANDLE handle );

// *************************************************************************
/* Function:
    SYS_STATUS DRV_W25_Status( const SYS_MODULE_INDEX drvIndex );

  Summary:
    Gets the current status of the W25 driver module.

  Description:
    This routine provides the current status of the W25 driver module.

  Preconditions:
    Function DRV_W25_Initialize should have been called before calling
    this function.

  Parameters:
    drvIndex   -  Identifier for the instance used to initialize driver

  Returns:
    SYS_STATUS_READY - Indicates that the driver is ready and accept
    requests for new operations.

    SYS_STATUS_UNINITIALIZED - Indicates the driver is not initialized.

    SYS_STATUS_BUSY - Indicates the driver is in busy state.

  Example:
    <code>
    SYS_STATUS          Status;

    Status = DRV_W25_Status(DRV_W25_INDEX);

    if (status == SYS_STATUS_READY)
    {
        
    }
    </code>

  Remarks:
    None.
*/

SYS_STATUS DRV_W25_Status( const SYS_MODULE_INDEX drvIndex );

// *****************************************************************************
/* Function:
    bool DRV_W25_UnlockFlash( const DRV_HANDLE handle );

  Summary:
    Unlocks the flash device for Erase and Program operations.

  Description:
    This function schedules a blocking operation for unlocking the flash blocks
    globally. This allows to perform erase and program operations on the flash.

  Precondition:
    The DRV_W25_Open() routine must have been called for the
    specified W25 driver instance.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open routine

  Returns:
    true
        - if the unlock is successfully completed

    false
        - if Write enable fails before sending unlock command to flash and
        - if Unlock flash command itself fails

  Example:
    <code>
    DRV_HANDLE handle;  

    if(DRV_W25_UnlockFlash(handle) == false)
    {
        
    }

    </code>

  Remarks:
    None.
*/

bool DRV_W25_UnlockFlash( const DRV_HANDLE handle );

// *****************************************************************************
/* Function:
    bool DRV_W25_ReadJedecId( const DRV_HANDLE handle, void *jedec_id );

  Summary:
    Reads JEDEC-ID of the flash device.

  Description:
    This function schedules a blocking operation for reading the JEDEC-ID.
    This information can be used to get the flash device geometry.

  Precondition:
    The DRV_W25_Open() routine must have been called for the
    specified W25 driver instance.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open routine

  Returns:
    true  - if the read is successfully completed

    false - if read jedec-id command fails

  Example:
    <code>

    DRV_HANDLE handle;  
    uint32_t jedec_id = 0;

    if(DRV_W25_ReadJedecId(handle, &jedec_id) == false)
    {
       
    }

    </code>

  Remarks:
    None.
*/

bool DRV_W25_ReadJedecId( const DRV_HANDLE handle, void *jedec_id );

// **************************************************************************
/* Function:
    bool DRV_W25_SectorErase( const DRV_HANDLE handle, uint32_t address );

  Summary:
    Erase the sector from the specified block start address.

  Description:
    This function schedules a non-blocking sector erase operation of flash memory.
    Each Sector is of 4 KByte.

    The requesting client should call DRV_W25_TransferStatusGet() API to know
    the current status of the request.

  Preconditions:
    The DRV_W25_Open() routine must have been called for the
    specified W25 driver instance.

  Parameters:
    handle        - A valid open-instance handle, returned from the driver's
                   open routine

    address       - block start address from where a sector needs to be erased.

  Returns:
    true
        - if the erase request is successfully sent to the flash

    false
        - if Write enable fails before sending sector erase command to flash
        - if sector erase command itself fails

  Example:
    <code>

    DRV_HANDLE handle;  
    uint32_t sectorStart = 0;

    if(DRV_W25_SectorErase(handle, sectorStart) == false)
    {
        
    }
    
    while(DRV_W25_TRANSFER_BUSY == DRV_W25_TransferStatusGet(handle));

    </code>

  Remarks:
    None.
*/

bool DRV_W25_SectorErase( const DRV_HANDLE handle, uint32_t address );

// **************************************************************************
/* Function:
    bool DRV_W25_BlockErase( const DRV_HANDLE handle, uint32_t address );

  Summary:
    Erase a block from the specified block start address.

  Description:
    This function schedules a non-blocking block erase operation of flash memory.
    The block size can be 8 KByte, 32KByte or 64 KByte.

    The requesting client should call DRV_W25_TransferStatusGet() API to know
    the current status of the request.

  Preconditions:
    The DRV_W25_Open() routine must have been called for the
    specified W25 driver instance.

  Parameters:
    handle        - A valid open-instance handle, returned from the driver's
                   open routine

    address       - block start address to be erased.

  Returns:
    true
        - if the erase request is successfully sent to the flash

    false
        - if Write enable fails before sending sector erase command to flash
        - if block erase command itself fails

  Example:
    <code>

    DRV_HANDLE handle;  
    uint32_t blockStart = 0;

    if(DRV_W25_SectorErase(handle, blockStart) == false)
    {
       
    }
    
    while(DRV_W25_TransferStatusGet(handle) == DRV_W25_TRANSFER_BUSY);

    </code>

  Remarks:
    None.
*/

bool DRV_W25_BlockErase( const DRV_HANDLE handle, uint32_t address );

// **************************************************************************
/* Function:
    bool DRV_W25_ChipErase( const DRV_HANDLE handle );

  Summary:
    Erase entire flash memory.

  Description:
    This function schedules a non-blocking chip erase operation of flash memory.

    The requesting client should call DRV_W25_TransferStatusGet() API to know
    the current status of the request.

  Preconditions:
    The DRV_W25_Open() routine must have been called for the
    specified W25 driver instance.

  Parameters:
    handle        - A valid open-instance handle, returned from the driver's
                    open routine

  Returns:
    true
        - if the erase request is successfully sent to the flash

    false
        - if Write enable fails before sending sector erase command to flash
        - if chip erase command itself fails

  Example:
    <code>

    DRV_HANDLE handle;  

    if(DRV_W25_ChipErase(handle) == flase)
    {
        
    }
    
    while(DRV_W25_TransferStatusGet(handle) == DRV_W25_TRANSFER_BUSY);

    </code>

  Remarks:
    None.
*/

bool DRV_W25_ChipErase( const DRV_HANDLE handle );

// *****************************************************************************
/* Function:
    bool DRV_W25_Read( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address );

  Summary:
    Reads n bytes of data from the specified start address of flash memory.

  Description:
    This function schedules a blocking operation for reading requested
    number of data bytes from the flash memory.

  Precondition:
    The DRV_W25_Open() routine must have been called for the
    specified W25 driver instance.

  Parameters:
    handle          - A valid open-instance handle, returned from the driver's
                      open routine

    *rx_data        - Buffer pointer into which the data read from the W25
                      Flash memory will be placed.

    rx_data_length  - Total number of bytes to be read.

    address         - Read memory start address from where the data should be
                      read.

  Returns:
    true - if number of bytes requested are read from flash memory

    false - if read command itself fails

  Example:
    <code>

    #define BUFFER_SIZE  1024
    #define MEM_ADDRESS  0x0

    DRV_HANDLE handle;  
    uint8_t CACHE_ALIGN readBuffer[BUFFER_SIZE];

    if (DRV_W25_Read(handle, (void *)&readBuffer, BUFFER_SIZE, MEM_ADDRESS) == false)
    {
        
    }
    
    while(DRV_W25_TransferStatusGet(handle) == DRV_W25_TRANSFER_BUSY);

    </code>

  Remarks:
    None.
*/

bool DRV_W25_Read( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address );

// *****************************************************************************
/* Function:
    bool DRV_W25_PageWrite( const DRV_HANDLE handle, void *tx_data, uint32_t tx_data_length, uint32_t address );

  Summary:
    Writes one page of data starting at the specified address.

  Description:
    This function schedules a non-blocking write operation for writing maximum one page
    of data into flash memory.

    The requesting client should call DRV_W25_TransferStatusGet() API to know
    the current status of the request.

  Preconditions:
    The DRV_W25_Open() routine must have been called for the
    specified W25 driver instance.

    The flash address location which has to be written, must have been erased
    before using the W25_xxxErase() routine.

    The flash address has to be a Page aligned address.

  Parameters:
    handle          - A valid open-instance handle, returned from the driver's
                      open routine

    *tx_data        - The source buffer containing data to be programmed into W25
                      Flash

    tx_data_length  - Total number of bytes to be written. should not be greater
                      than page size

    address         - Write memory start address from where the data should be
                      written

  Returns:
    true
        - if the write request is successfully sent to the flash

    false
        - if Write enable fails before sending sector erase command to flash
        - if write command itself fails

  Example:
    <code>

    #define PAGE_SIZE    256
    #define BUFFER_SIZE  1024
    #define MEM_ADDRESS  0x0

    DRV_HANDLE handle; 
    uint8_t CACHE_ALIGN writeBuffer[BUFFER_SIZE];
    bool status = false;

    if(false == DRV_W25_SectorErase(handle))
    {
        
    }
    
    while(DRV_W25_TransferStatusGet(handle) == DRV_W25_TRANSFER_BUSY);

    for (uint32_t j = 0; j < BUFFER_SIZE; j += PAGE_SIZE)
    {
        if (DRV_W25_PageWrite(handle, (void *)&writeBuffer[j], (MEM_ADDRESS + j)) == false)
        {
            status = false;
            break;
        }
        
        while(DRV_W25_TransferStatusGet(handle) == DRV_W25_TRANSFER_BUSY);
        status = true;
    }

    if(status == false)
    {
        
    }

    </code>

  Remarks:
    None.
*/

bool DRV_W25_PageWrite( const DRV_HANDLE handle, void *tx_data, uint32_t address );

// *****************************************************************************
/* Function:
    DRV_W25_TRANSFER_STATUS DRV_W25_TransferStatusGet( const DRV_HANDLE handle );

  Summary:
    Gets the current status of the transfer request.

  Description:
    This routine gets the current status of the transfer request. The application
    must use this routine where the status of a scheduled request needs to be
    polled on.

  Preconditions:
    The DRV_W25_Open() routine must have been called for the
    specified W25 driver instance.

  Parameters:
    handle          - A valid open-instance handle, returned from the driver's
                      open routine

  Returns:
    DRV_W25_TRANSFER_ERROR_UNKNOWN - If the flash status register read request fails

    DRV_W25_TRANSFER_BUSY - If the current transfer request is still being processed

    DRV_W25_TRANSFER_COMPLETED - If the transfer request is completed

  Example:
    <code>

    DRV_HANDLE handle; 

    if (DRV_W25_TransferStatusGet(handle) == DRV_W25_TRANSFER_COMPLETED)
    {
       
    }
    </code>

  Remarks:
    None.
*/

DRV_W25_TRANSFER_STATUS DRV_W25_TransferStatusGet( const DRV_HANDLE handle );

// *****************************************************************************
/* Function:
    bool DRV_W25_GeometryGet( const DRV_HANDLE handle, W25_GEOMETRY *geometry );

  Summary:
    Returns the geometry of the device.

  Description:
    This API gives the following geometrical details of the W25 Flash:
    - Number of Read/Write/Erase Blocks and their size in each region of the device
    - Flash block start address.

  Precondition:
    The DRV_W25_Open() routine must have been called for the
    specified W25 driver instance.

  Parameters:
    handle            - A valid open-instance handle, returned from the driver's
                        open routine

    *geometry_table   - pointer to flash device geometry table instance

  Returns:
    true  - if able to get the geometry details of the flash

    false - if read device id fails

  Example:
    <code>

    DRV_HANDLE handle;  

    DRV_W25_GEOMETRY w25FlashGeometry;

    uint32_t readBlockSize, writeBlockSize, eraseBlockSize;
    uint32_t nReadBlocks, nReadRegions, totalFlashSize;

    DRV_W25_GeometryGet(handle, &w25FlashGeometry);

    readBlockSize  = w25FlashGeometry.read_blockSize;
    nReadBlocks = w25FlashGeometry.read_numBlocks;
    nReadRegions = w25FlashGeometry.numReadRegions;

    writeBlockSize  = w25FlashGeometry.write_blockSize;
    eraseBlockSize  = w25FlashGeometry.erase_blockSize;

    totalFlashSize = readBlockSize * nReadBlocks * nReadRegions;

    </code>

  Remarks:
    This API is more useful when used to interface with Memory driver.
*/

bool DRV_W25_GeometryGet( const DRV_HANDLE handle, DRV_W25_GEOMETRY *geometry );

// *****************************************************************************
/* Function:
bool DRV_W25_ReadStatus( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length );
Summary:
Read the status register of the Flash device.
Description:
This routine read the status register of the Flash device. The application
must use this routine where the status of a scheduled request needs to be
polled on
Preconditions:
The DRV_W25_Open() routine must have been called for the
specified W25 driver instance.
Parameters:
handle - A valid open-instance handle, returned from the driver's
open routine
rx_data         - Buffer pointer into which the register status read from the W25
                  Flash memory will be placed.

rx_data_length  - Total number of bytes to be read. It should not be greater than
                  size of the status register.
Returns:
true - if status register is read from flash memory
false - if status register command fails
Example:
<code>
DRV_HANDLE handle; 
uint8_t reg_status = 0;

if (DRV_W25_ReadStatus(handle, (void *)&reg_status, 1) == false)
{
    return status;
}
</code>
Remarks:
None.
*/
bool DRV_W25_ReadStatus( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length );


#ifdef __cplusplus
}
#endif

#endif // #ifndef DRV_W25_H
/*******************************************************************************
 End of File
*/