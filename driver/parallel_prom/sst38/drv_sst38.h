/*******************************************************************************
  SST38 Driver Interface Definition

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sst38.h

  Summary:
    SST38 Driver Interface Definition

  Description:
    The SST38 driver provides a simple interface to manage the SST38VF series
    of Parallel Flash Memory connected to Microchip microcontrollers. This file
    defines the interface definition for the SST38 driver.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2022 Microchip Technology Inc. and its subsidiaries.
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

#ifndef DRV_SST38_H
#define DRV_SST38_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include "drv_sst38_definitions.h"

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
    SST38 Driver Transfer Status

 Description:
    This data type will be used to indicate the current transfer status for SST38
    driver.

 Remarks:
    None.
*/

typedef enum
{
    /* Transfer is being processed */
    DRV_SST38_TRANSFER_BUSY,
    /* Transfer is successfully completed*/
    DRV_SST38_TRANSFER_COMPLETED,
    /* Transfer had error*/
    DRV_SST38_TRANSFER_ERROR_UNKNOWN,
} DRV_SST38_TRANSFER_STATUS;

// *****************************************************************************
/* DRV_SST38 Geometry data

 Summary:
    Defines the data type for SST38 PROM Geometry details.

 Description:
    This will be used to get the geometry details of the attached SST38 PROM
    device.

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
} DRV_SST38_GEOMETRY;

// *****************************************************************************
// *****************************************************************************
// Section: SST38Driver Module Interface Routines
// *****************************************************************************
// *****************************************************************************


// *****************************************************************************
/* Function:
    SYS_MODULE_OBJ DRV_SST38_Initialize
    (
        const SYS_MODULE_INDEX drvIndex,
        const SYS_MODULE_INIT *const init
    );

  Summary:
    Initializes the SST38 Driver

  Description:
    This routine initializes the SST38 driver making it ready for client to use.

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
    This code snippet shows an example of initializing the SST38 Driver
    with SST38 Parallel flash device attached.

    <code>
    SYS_MODULE_OBJ  objectHandle;

    const DRV_SST38_PLIB_INTERFACE drvSST38PlibAPI = {
        .write              = (DRV_SST38_PLIB_WRITE)HEMC_Write8,
        .read               = (DRV_SST38_PLIB_READ)HEMC_Read8,
        .eccDisable         = (DRV_SST38_PLIB_ECC_DISABLE)HEMC_DisableECC,
        .eccEnable          = (DRV_SST38_PLIB_ECC_ENABLE)HEMC_EnableECC,
    };

    const DRV_SST38_INIT drvSST38InitData =
    {
        .sst38Plib         = &drvSST38PlibAPI,
    };

    objectHandle = DRV_SST38_Initialize((SYS_MODULE_INDEX)DRV_SST38_INDEX, (SYS_MODULE_INIT *)&drvSST38InitData);

    if (SYS_MODULE_OBJ_INVALID == objectHandle)
    {
        printf("Initialization Error");
    }
    </code>

  Remarks:
    This routine must be called before any other SST38 driver routine is called.

    This routine should only be called once during system initialization.
*/

SYS_MODULE_OBJ DRV_SST38_Initialize
(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT *const init
);

// ****************************************************************************
/* Function:
    DRV_HANDLE DRV_SST38_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent );

  Summary:
    Opens the specified SST38 driver instance and returns a handle to it

  Description:
    This routine opens the specified SST38 driver instance and provides a handle.

    This handle must be provided to all other client-level operations to identify
    the caller and the instance of the driver.

  Preconditions:
    Function DRV_SST38_Initialize must have been called before calling this
    function.

    The driver should be in ready state to accept the request. Can be checked by
    calling DRV_SST38_Status().

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

    handle = DRV_SST38_Open(DRV_SST38_INDEX);
    if (DRV_HANDLE_INVALID == handle)
    {
        printf("Unable to open the driver");
    }
    </code>

  Remarks:
    The handle returned is valid until the DRV_SST38_Close routine is called.

    If the driver has already been opened, it should not be opened again.
*/

DRV_HANDLE DRV_SST38_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent );

// *****************************************************************************
/* Function:
    void DRV_SST38_Close( const DRV_HANDLE handle );

  Summary:
    Closes an opened-instance of the SST38 driver

  Description:
    This routine closes an opened-instance of the SST38 driver, invalidating
    the handle.

  Precondition:
    DRV_SST38_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open routine

  Returns:
    None

  Example:
    <code>
    DRV_HANDLE handle;

    DRV_SST38_Close(handle);
    </code>

  Remarks:
    After calling this routine, the handle passed in "handle" must not be used
    with any of the remaining driver routines. A new handle must be obtained by
    calling DRV_SST38_Open before the caller may use the driver again.

    Usually there is no need for the driver client to verify that the Close
    operation has completed.
*/

void DRV_SST38_Close( const DRV_HANDLE handle );

// *************************************************************************
/* Function:
    SYS_STATUS DRV_SST38_Status( const SYS_MODULE_INDEX drvIndex );

  Summary:
    Gets the current status of the SST38 driver module.

  Description:
    This routine provides the current status of the SST38 driver module.

  Preconditions:
    Function DRV_SST38_Initialize should have been called before calling
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

    Status = DRV_SST38_Status(DRV_SST38_INDEX);

    if (status == SYS_STATUS_READY)
    {
        printf("SST38 driver is initialized and ready to accept requests.");
    }
    </code>

  Remarks:
    None.
*/

SYS_STATUS DRV_SST38_Status( const SYS_MODULE_INDEX drvIndex );



// *****************************************************************************
/* Function:
  bool DRV_SST38_ReadProductId( const DRV_HANDLE handle, uint16_t* manufacturer, uint16_t* device );

  Summary:
    Reads Manufacturer and Device ID of the SST38 device.

  Description:
    This function schedules a blocking operation for reading the Manufacturer and Device ID.
    This information can be used to get the flash device geometry.

  Precondition:
    The DRV_SST38_Open() routine must have been called for the
    specified SST38 driver instance.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open routine
    manufacturer - Pointer to 8 bit variable that will be updated with read manufacturer value.
    device - Pointer to 8 bit variable that will be updated with read device value.

  Returns:
    true  - if the read is successfully completed

    false - if command fails

  Example:
    <code>

    DRV_HANDLE handle;
    uint8_t manufacturer = 0;
    uint8_t device = 0;

    if(DRV_SST38_ReadProductId(appData.handle, &manufacturer, &device) == false)
    {
        printf("Error handling here");
    }

    </code>

  Remarks:
    None.
*/

bool DRV_SST38_ReadProductId( const DRV_HANDLE handle, uint16_t* manufacturer, uint16_t* device );

// **************************************************************************
/* Function:
    bool DRV_SST38_SectorErase( const DRV_HANDLE handle, uint32_t address );

  Summary:
    Erase the sector from the specified block start address.

  Description:
    This function schedules a blocking sector erase operation of flash memory.
    Each Sector is of 4 KByte.

  Preconditions:
    The DRV_SST38_Open() routine must have been called for the
    specified SST38 driver instance.

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

    if(DRV_SST38_SectorErase(handle, sectorStart) == false)
    {
        printf("Error handling here");
    }

    </code>

  Remarks:
    None.
*/

bool DRV_SST38_SectorErase( const DRV_HANDLE handle, uint32_t address );

// **************************************************************************
/* Function:
    bool DRV_SST38_ChipErase( const DRV_HANDLE handle );

  Summary:
    Erase entire flash memory.

  Description:
    This function schedules a blocking chip erase operation of flash memory.

  Preconditions:
    The DRV_SST38_Open() routine must have been called for the
    specified SST38 driver instance.

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

    if(DRV_SST38_ChipErase(handle) == flase)
    {
        printf("Error handling here");
    }

    </code>

  Remarks:
    None.
*/

bool DRV_SST38_ChipErase( const DRV_HANDLE handle );

// *****************************************************************************
/* Function:
    bool DRV_SST38_Read( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address );

  Summary:
    Reads n bytes of data from the specified start address of flash memory.

  Description:
    This function schedules a blocking operation for reading requested
    number of data bytes from the flash memory.

  Precondition:
    The DRV_SST38_Open() routine must have been called for the
    specified SST38 driver instance.

  Parameters:
    handle          - A valid open-instance handle, returned from the driver's
                      open routine

    *rx_data        - Buffer pointer into which the data read from the SST38
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

    if (DRV_SST38_Read(handle, (void *)&readBuffer, BUFFER_SIZE, MEM_ADDRESS) == false)
    {
        printf("Error handling here");
    }

    </code>

  Remarks:
    None.
*/

bool DRV_SST38_Read( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address );

// *****************************************************************************
/* Function:
    bool DRV_SST38_PageWrite( const DRV_HANDLE handle, void *tx_data, uint32_t address );

  Summary:
    Writes one page of data starting at the specified address.

  Description:
    This function schedules a blocking write operation for writing maximum one page
    of data into flash memory.

  Preconditions:
    The DRV_SST38_Open() routine must have been called for the
    specified SST38 driver instance.

    The flash address location which has to be written, must have been erased
    before using the SST38_xxxErase() routine.

    The flash address has to be a Page aligned address.

  Parameters:
    handle          - A valid open-instance handle, returned from the driver's
                      open routine

    *tx_data        - The source buffer containing data to be programmed into SST38
                      Flash

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

    if(false == DRV_SST38_SectorErase(handle))
    {
        printf("Error handling here");
    }

    for (uint32_t j = 0; j < BUFFER_SIZE; j += PAGE_SIZE)
    {
        if (DRV_SST38_PageWrite(handle, (void *)&writeBuffer[j], (MEM_ADDRESS + j)) == false)
        {
            status = false;
            break;
        }

        status = true;
    }

    if(status == false)
    {
        printf("Error handling here");
    }

    </code>

  Remarks:
    None.
*/

bool DRV_SST38_PageWrite( const DRV_HANDLE handle, void *tx_data, uint32_t address );


// *****************************************************************************
/* Function:
    bool DRV_SST38_GeometryGet(const DRV_HANDLE handle, DRV_SST38_GEOMETRY *geometry)

  Summary:
    Returns the geometry of the device.

  Description:
    This API gives the following geometrical details of the DRV_SST38 PROM:
    - Number of Read/Write/Erase Blocks and their size in each region of the device

  Precondition:
    DRV_SST38_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle      - A valid open-instance handle, returned from the driver's
                   open routine
    geometry    - Pointer to flash device geometry table instance

  Returns:
    true - if able to get the geometry details of the flash

    false - if handle is invalid

  Example:
    <code>

    DRV_SST38_GEOMETRY flashGeometry;
    uint32_t readBlockSize, writeBlockSize, eraseBlockSize;
    uint32_t nReadBlocks, nReadRegions, totalFlashSize;

    DRV_SST38_GeometryGet(myHandle, &flashGeometry);

    readBlockSize  = flashGeometry.readBlockSize;
    nReadBlocks = flashGeometry.readNumBlocks;
    nReadRegions = flashGeometry.readNumRegions;

    writeBlockSize  = flashGeometry.writeBlockSize;
    eraseBlockSize  = flashGeometry.eraseBlockSize;

    totalFlashSize = readBlockSize * nReadBlocks * nReadRegions;

    </code>

  Remarks:
    None.
*/

bool DRV_SST38_GeometryGet(const DRV_HANDLE handle, DRV_SST38_GEOMETRY *geometry);

// *****************************************************************************
/* Function:
    DRV_SST38_TRANSFER_STATUS DRV_SST38_TransferStatusGet(const DRV_HANDLE handle);

  Summary:
    Gets the current status of the transfer request.

  Description:
    This routine gets the current status of the transfer request.

  Preconditions:
    The DRV_SST38_Open() routine must have been called for the
    specified SST38 driver instance.

  Parameters:
    handle          - A valid open-instance handle, returned from the driver's
                      open routine

  Returns:
    DRV_SST38_TRANSFER_ERROR_UNKNOWN - If the handle is invalid.

    DRV_SST38_TRANSFER_BUSY - If the current transfer request is still being processed

    DRV_SST38_TRANSFER_COMPLETED - If the transfer request is completed

  Example:
    <code>

    DRV_HANDLE handle;

    if (DRV_SST38_TransferStatusGet(handle) == DRV_SST38_TRANSFER_COMPLETED)
    {
    }
    </code>

  Remarks:
    None.
*/

DRV_SST38_TRANSFER_STATUS DRV_SST38_TransferStatusGet(const DRV_HANDLE handle);

#ifdef __cplusplus
}
#endif

#endif // #ifndef DRV_SST38_H
/*******************************************************************************
 End of File
*/