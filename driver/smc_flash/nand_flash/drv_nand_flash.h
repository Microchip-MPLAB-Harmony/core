/*******************************************************************************
  NAND FLASH Driver Interface Definition

  Company:
    Microchip Technology Inc.

  File Name:
    drv_nand_flash.h

  Summary:
    NAND FLASH Driver Interface Definition

  Description:
    The NAND FLASH driver provides a simple interface to manage the NAND FLASH series
    of SQI Flash Memory connected to Microchip microcontrollers. This file
    defines the interface definition for the NAND FLASH driver.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2020 Microchip Technology Inc. and its subsidiaries.
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

#ifndef DRV_NAND_FLASH_H
#define DRV_NAND_FLASH_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <stdio.h>
#include <stdbool.h>
#include "drv_nand_flash_definitions.h"

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
    NAND FLASH Driver Transfer Status

 Description:
    This data type will be used to indicate the current transfer status for NAND FLASH
    driver.

 Remarks:
    None.
*/

typedef enum
{
    /* Transfer is being processed */
    DRV_NAND_FLASH_TRANSFER_BUSY,
    /* Transfer is successfully completed */
    DRV_NAND_FLASH_TRANSFER_COMPLETED,
    /* Transfer is failed from NAND Flash */
    DRV_NAND_FLASH_TRANSFER_FAIL,
    /* Transfer had unknown error */
    DRV_NAND_FLASH_TRANSFER_ERROR_UNKNOWN,
} DRV_NAND_FLASH_TRANSFER_STATUS;

/*
 Summary:
    NAND FLASH Device geometry.

 Description:
    This data type will be used to get the characteristics of the
    NAND FLASH Device.

 Remarks:
    None.
*/

typedef struct
{
    /* Identifier for the device */
    uint8_t deviceId;

    /* Data Bus Width (8/16) */
    uint8_t dataBusWidth;

    /* Size of the device in bytes */
    uint32_t deviceSize;

    /* Size of the data area of a page in bytes */
    uint32_t pageSize;

    /* Size of the spare area of a page in bytes */
    uint16_t spareSize;

    /* Size of one block in bytes */
    uint32_t blockSize;

    /* Number of logical units */
    uint8_t numberOfLogicalUnits;

    /* Number of bits of ECC correction */
    uint8_t eccCorrectability;

} DRV_NAND_FLASH_GEOMETRY;

/*
 Summary:
    NAND FLASH Device data.

 Description:
    This data type will be used to store the data of the
    NAND FLASH Device.

 Remarks:
    None.
*/

typedef struct
{
    /* NAND Flash Geometry */
    DRV_NAND_FLASH_GEOMETRY nandFlashGeometry;

    /* NAND Flash data address */
    uint32_t dataAddress;

    /* NAND Flash spare/ecc buffer */
    CACHE_ALIGN uint8_t spareBuffer[512];

} DRV_NAND_FLASH_DATA;

// *****************************************************************************
// *****************************************************************************
// Section: NAND FLASH Driver Module Interface Routines
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    SYS_MODULE_OBJ DRV_NAND_FLASH_Initialize
    (
        const SYS_MODULE_INDEX drvIndex,
        const SYS_MODULE_INIT *const init
    )

  Summary:
    Initializes the NAND FLASH Driver

  Description:
    This routine initializes the NAND FLASH driver making it ready for client to use.
    - Get the data address of NAND Flash

  Precondition:
    None.

  Parameters:
    drvIndex -  Identifier for the instance to be initialized

    init     -  Pointer to a data structure containing any data necessary to
                initialize the driver.

  Returns:
    If successful, returns a valid handle to a driver instance object.
    Otherwise it returns SYS_MODULE_OBJ_INVALID.

  Example:
    <code>    

    SYS_MODULE_OBJ  objectHandle;

    const DRV_NAND_FLASH_PLIB_INTERFACE drvNandFlashPlibAPI = {
        .DataAddressGet              = SMC_DataAddressGet,
        .CommandWrite                = SMC_CommandWrite,
        .CommandWrite16              = SMC_CommandWrite16,
        .AddressWrite                = SMC_AddressWrite,
        .AddressWrite16              = SMC_AddressWrite16,
        .DataWrite                   = SMC_DataWrite,
        .DataWrite16                 = SMC_DataWrite16,
        .DataRead                    = SMC_DataRead,
        .DataRead16                  = SMC_DataRead16,
        .DataPhaseStart              = PMECC_DataPhaseStart,
        .StatusIsBusy                = PMECC_StatusIsBusy,
        .ErrorGet                    = PMECC_ErrorGet,
        .RemainderGet                = PMECC_RemainderGet,
        .ECCGet                      = PMECC_ECCGet,
        .ErrorLocationGet            = PMERRLOC_ErrorLocationGet,
        .ErrorLocationDisable        = PMERRLOC_ErrorLocationDisable,
        .SigmaSet                    = PMERRLOC_SigmaSet,
        .ErrorLocationFindNumOfRoots = PMERRLOC_ErrorLocationFindNumOfRoots
    };

    const DRV_NAND_FLASH_INIT drvNandFlashInitData =
    {
        .nandFlashPlib         = &drvNandFlashPlibAPI,
    };

    objectHandle = DRV_NAND_FLASH_Initialize((SYS_MODULE_INDEX)DRV_NAND_FLASH_INDEX, (SYS_MODULE_INIT *)&drvNandFlashInitData);

    if (SYS_MODULE_OBJ_INVALID == objectHandle)
    {
       
    }
    </code>

  Remarks:
    This routine must be called before any other NAND FLASH driver routine is called.

    This routine should only be called once during system initialization.
*/

SYS_MODULE_OBJ DRV_NAND_FLASH_Initialize
(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT *const init
);

// ****************************************************************************
/* Function:
    DRV_HANDLE DRV_NAND_FLASH_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )

  Summary:
    Opens the specified NAND FLASH driver instance and returns a handle to it

  Description:
    This routine opens the specified NAND FLASH driver instance and provides a handle.

    This handle must be provided to all other client-level operations to identify
    the caller and the instance of the driver.
    - Reset NAND Flash
    - Gets and stores NAND Flash Geometry to use in driver
    - Initializes PMECC descriptor if PMECC is enabled

  Preconditions:
    Function DRV_NAND_FLASH_Initialize must have been called before calling this
    function.

    Driver should be in ready state to accept the request. Can be checked by
    calling DRV_NAND_FLASH_Status().

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
        - If the driver hardware instance being opened is not initialized.
        - Fail to reset NAND Flash OR fail to read NAND Flash Geometry
        - Invalid PMECC configurations for NAND Flash if PMECC is enabled

  Example:
    <code>
    DRV_HANDLE handle;

    handle = DRV_NAND_FLASH_Open((SYS_MODULE_INDEX)DRV_NAND_FLASH_INDEX, DRV_IO_INTENT_READWRITE);
    if (DRV_HANDLE_INVALID == handle)
    {
        
    }
    </code>

  Remarks:
    The handle returned is valid until the DRV_NAND_FLASH_Close routine is called.

    If the driver has already been opened, it should not be opened again.

    This routine will block wait for hardware access.
*/

DRV_HANDLE DRV_NAND_FLASH_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent );

// *****************************************************************************
/* Function:
    void DRV_NAND_FLASH_Close( const DRV_HANDLE handle )

  Summary:
    Closes an opened-instance of the NAND FLASH driver

  Description:
    This routine closes an opened-instance of the NAND FLASH driver, invalidating
    the handle.

  Precondition:
    DRV_NAND_FLASH_Open must have been called to obtain a valid opened device handle.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open routine

  Returns:
    None

  Example:
    <code>
    DRV_HANDLE handle;  

    DRV_NAND_FLASH_Close(handle);
    </code>

  Remarks:
    After calling this routine, the handle passed in "handle" must not be used
    with any of the remaining driver routines. A new handle must be obtained by
    calling DRV_NAND_FLASH_Open before the caller may use the driver again.

    Usually there is no need for the driver client to verify that the Close
    operation has completed.
*/

void DRV_NAND_FLASH_Close( const DRV_HANDLE handle );

// *************************************************************************
/* Function:
    SYS_STATUS DRV_NAND_FLASH_Status( const SYS_MODULE_INDEX drvIndex )

  Summary:
    Gets the current status of the NAND FLASH driver module.

  Description:
    This routine provides the current status of the NAND FLASH driver module.

  Preconditions:
    Function DRV_NAND_FLASH_Initialize should have been called before calling
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

    Status = DRV_NAND_FLASH_Status(DRV_NAND_FLASH_INDEX);
    </code>

  Remarks:
    This routine will NEVER block wait for hardware.
*/

SYS_STATUS DRV_NAND_FLASH_Status( const SYS_MODULE_INDEX drvIndex );

// *****************************************************************************
/* Function:
    bool DRV_NAND_FLASH_ResetFlash(const DRV_HANDLE handle)

  Summary:
    Reset the flash device to standby mode.

  Description:
    This function schedules a blocking operation for resetting the flash device to
    standby mode. All the volatile bits and settings will be cleared then,
    which makes the device return to the default status as power on.

  Precondition:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle       - A valid open-instance handle, returned from the driver's
                   open routine

  Returns:
    true - Flash reset is completed successfully

    false - Flash reset is failed

  Example:
    <code>
    DRV_HANDLE handle;  
    if(true != DRV_NAND_FLASH_ResetFlash(handle))
    {
        
    }
    </code>

  Remarks:
    This routine will block wait for hardware access.
*/

bool DRV_NAND_FLASH_ResetFlash(const DRV_HANDLE handle);

// *****************************************************************************
/* Function:
    DRV_NAND_FLASH_TRANSFER_STATUS DRV_NAND_FLASH_TransferStatusGet(const DRV_HANDLE handle)

  Summary:
    Gets the current status of the transfer request.

  Description:
    This routine gets the current status of the transfer request. The application
    must use this routine where the status of a scheduled request needs to be
    polled on.

  Preconditions:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle          - A valid open-instance handle, returned from the driver's
                      open routine

  Returns:
    DRV_NAND_FLASH_TRANSFER_ERROR_UNKNOWN
    - If invalid handle

    DRV_NAND_FLASH_TRANSFER_BUSY
    - If the current transfer request is still being processed

    DRV_NAND_FLASH_TRANSFER_COMPLETED
    - If the transfer request is completed

    DRV_NAND_FLASH_TRANSFER_FAIL
    - If the transfer is failed

  Example:
    <code>

    DRV_HANDLE handle; 

    if (DRV_NAND_FLASH_TRANSFER_COMPLETED == DRV_NAND_FLASH_TransferStatusGet(handle))
    {
       
    }
    </code>

  Remarks:
    This routine will block wait for hardware access.
*/

DRV_NAND_FLASH_TRANSFER_STATUS DRV_NAND_FLASH_TransferStatusGet(const DRV_HANDLE handle);

// *****************************************************************************
/* Function:
    bool DRV_NAND_FLASH_IdRead(const DRV_HANDLE handle, uint32_t *readId, uint8_t address)

  Summary:
    Gets identifier codes from NAND Flash.

  Description:
    This routine read identifier codes from NAND Flash.

  Preconditions:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle          - A valid open-instance handle, returned from the driver's
                      open routine
    readId          - Pointer to 32-bit unsigned int into which ID will be stored
    address         - Address to be send after command cycle. Address 0x20 is used for ONFI compliant Flash.

  Returns:
    true - If ID read successfully from the flash

    false  - If invalid handle

  Example:
    <code>

    #define NAND_FLASH_ADDR_ONFI_SIGNATURE    0x20
    uint32_t readId = 0;
    DRV_HANDLE handle;  

    if (DRV_NAND_FLASH_IdRead(handle, &readId, NAND_FLASH_ADDR_ONFI_SIGNATURE))
    {
        
    }
    </code>

  Remarks:
    This routine will block for hardware access.
*/

bool DRV_NAND_FLASH_IdRead(const DRV_HANDLE handle, uint32_t *readId, uint8_t address);

// *****************************************************************************
/* Function:
    bool DRV_NAND_FLASH_FeatureSet(const DRV_HANDLE handle, uint8_t *featureData, uint8_t featureDataSize, uint8_t featureAddress)

  Summary:
    Enables or disables target specific features.

  Description:
    This routine enables or disables target specific features to NAND Flash.

  Preconditions:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle          - A valid open-instance handle, returned from the driver's
                      open routine
    featureData     - Pointer to source buffer containing subfeature data to be programmed into NAND Flash
    featureDataSize - Total number of subfeature data bytes to be written
    featureAddress  - Specific feature address to be send after command cycle.

  Returns:
    true - If specific feature is enabled or disabled successfully to the flash

    false  - If invalid handle

  Example:
    <code>
    i.e. Disable NAND Flash ECC controller if NAND Flash supports internal ECC controller
    #define NAND_FLASH_TARGET_DISABLE_INTERNAL_ECC    0x90
    uint8_t featureData[4] = {0, 0, 0, 0};
    DRV_HANDLE handle;  

    if (DRV_NAND_FLASH_FeatureSet(handle, featureData, sizeof(featureData), NAND_FLASH_TARGET_DISABLE_INTERNAL_ECC))
    {
       
    }
    </code>

  Remarks:
    This routine will block for hardware access.
*/

bool DRV_NAND_FLASH_FeatureSet(const DRV_HANDLE handle, uint8_t *featureData, uint8_t featureDataSize, uint8_t featureAddress);

// *****************************************************************************
/* Function:
    bool DRV_NAND_FLASH_FeatureGet(const DRV_HANDLE handle, uint8_t *featureData, uint8_t featureDataSize, uint8_t featureAddress)

  Summary:
    Read target specific features.

  Description:
    This routine reads target specific features from NAND Flash.

  Preconditions:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle          - A valid open-instance handle, returned from the driver's
                      open routine
    featureData     - Pointer to destination buffer into which subfeature data to be placed from NAND Flash
    featureDataSize - Total number of subfeature data bytes to be read
    featureAddress  - Specific feature address to be send after command cycle.

  Returns:
    true - If specific feature is read successfully from the flash

    false - If invalid handle

  Example:
    <code>
    i.e. Read NAND Flash ECC controller if NAND Flash supports internal ECC controller
    #define NAND_FLASH_TARGET_DISABLE_INTERNAL_ECC    0x90
    uint8_t featureData[4];
    DRV_HANDLE handle;  

    if (DRV_NAND_FLASH_FeatureGet(handle, featureData, sizeof(featureData), NAND_FLASH_TARGET_DISABLE_INTERNAL_ECC))
    {
        
    }
    </code>

  Remarks:
    This routine will block for hardware access.
*/

bool DRV_NAND_FLASH_FeatureGet(const DRV_HANDLE handle, uint8_t *featureData, uint8_t featureDataSize, uint8_t featureAddress);

// *****************************************************************************
/* Function:
    bool DRV_NAND_FLASH_ParameterPageRead(const DRV_HANDLE handle, uint8_t *parameterPage, uint32_t size);

  Summary:
    Returns the Parameter page of the NAND Flash device.

  Description:
    This routine reads the parameter page of the NAND Flash device. It reads target's organization,
    features, timings and other behavioural parameters of NAND Flash device.

  Precondition:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle            - A valid open-instance handle, returned from the driver's
                        open routine

    parameterPage     - Pointer to destination buffer into which parameter page to be placed from NAND Flash
    size              - Total number of parameter page data bytes to be read

  Returns:
    true - If parameter page is successfully read from the NAND Flash

    false - If parameter page read is failed

  Example:
    <code>

    DRV_HANDLE handle;  
    uint8_t parameterPage[116];

    if (DRV_NAND_FLASH_ParameterPageRead(handle, parameterPage, sizeof(parameterPage)))
    {
        
    }
    </code>

  Remarks:
    This routine will block wait for hardware access.
*/

bool DRV_NAND_FLASH_ParameterPageRead(const DRV_HANDLE handle, uint8_t *parameterPage, uint32_t size);

// *****************************************************************************
/* Function:
    bool DRV_NAND_FLASH_GeometryGet( const DRV_HANDLE handle, DRV_NAND_FLASH_GEOMETRY *geometry );

  Summary:
    Returns the geometry of the NAND Flash device.

  Description:
    This API gives the following geometrical details of the NAND Flash:
    - deviceId (JEDEC Manufacturer ID)
    - Bus Width
    - Number of data bytes per page
    - Number of spare bytes per page
    - Block Size
    - Device Size
    - Number of logical units
    - Number of bits of ECC correction

  Precondition:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle            - A valid open-instance handle, returned from the driver's
                        open routine

    geometry          - Pointer to destination geometry buffer into which geometry to be placed

  Returns:
    true - If geometry is successfully read from the NAND Flash

    false  - If geometry read is failed

  Example:
    <code>

    DRV_HANDLE handle;  
    DRV_NAND_FLASH_GEOMETRY nandFlashFlashGeometry;

    if (DRV_NAND_FLASH_GeometryGet(handle, &nandFlashFlashGeometry))
    {
       
    }
    </code>

  Remarks:
    This routine will block wait for hardware access.
*/

bool DRV_NAND_FLASH_GeometryGet( const DRV_HANDLE handle, DRV_NAND_FLASH_GEOMETRY *geometry );

// *****************************************************************************
/* Function:
    bool DRV_NAND_FLASH_SkipBlock_BlockCheck(const DRV_HANDLE handle, uint16_t blockNum)

  Summary:
    Checks whether NAND Flash block is bad or good.

  Description:
    This routine returns false if the given block of NAND Flash device is bad otherwise true.

  Preconditions:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle          - A valid open-instance handle, returned from the driver's
                      open routine
    blockNum        - Block number to check

  Returns:
    true - If block is good

    false - If block is bad

  Example:
    <code>

    uint16_t blockNum = 0;
    DRV_HANDLE handle;  

    if (DRV_NAND_FLASH_SkipBlock_BlockCheck(handle, blockNum))
        
    }
    </code>

  Remarks:
    This routine will block for hardware access.
*/

bool DRV_NAND_FLASH_SkipBlock_BlockCheck(const DRV_HANDLE handle, uint16_t blockNum);

// *****************************************************************************
/* Function:
    bool DRV_NAND_FLASH_SkipBlock_BlockTag(const DRV_HANDLE handle, uint16_t blockNum, bool badBlock)

  Summary:
    Tag NAND Flash block to bad or good.

  Description:
    This routine tags given block of NAND Flash device to bad or good.

  Preconditions:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle          - A valid open-instance handle, returned from the driver's
                      open routine
    blockNum        - Block number to be tagged
    badBlock        - 1 - Block to be tagged as bad block.
                      0 - If block to be tagged as good block.

  Returns:
    true - If given block is tagged as bad or good

    false - If failed to tag a block

  Example:
    <code>

    uint16_t blockNum = 0;
    DRV_HANDLE handle;  

    if (DRV_NAND_FLASH_SkipBlock_BlockTag(handle, blockNum, 1))
        
    }
    </code>

  Remarks:
    This routine will block for hardware access.
*/

bool DRV_NAND_FLASH_SkipBlock_BlockTag(const DRV_HANDLE handle, uint16_t blockNum, bool badBlock);

// **************************************************************************
/* Function:
    bool DRV_NAND_FLASH_SkipBlock_BlockErase(const DRV_HANDLE handle, uint16_t blockNum, bool disableBlockCheck)

  Summary:
    Erase a block.

  Description:
    This function schedules a blocking block erase operation of flash memory. It erases a given block.

  Preconditions:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle            - A valid open-instance handle, returned from the driver's
                      open routine
    blockNum          - Block number to be erased
    disableBlockCheck - 0 - Block will be checked as good before erasing a given block.
                        1 - Block will not check before erasing a given block.

  Returns:
    true - If the block erase is successfully completed

    false - If block erase fails

  Example:
    <code>

    uint16_t blockNum = 0;
    DRV_HANDLE handle;  

    if(DRV_NAND_FLASH_SkipBlock_BlockErase(handle, blockNum, 0))
    {
        
    }

    </code>

  Remarks:
    This routine will block wait until erase request is completed successfully.

    Client should wait until erase is complete to send next transfer request.
*/

bool DRV_NAND_FLASH_SkipBlock_BlockErase(const DRV_HANDLE handle, uint16_t blockNum, bool disableBlockCheck);

// *****************************************************************************
/* Function:
    bool DRV_NAND_FLASH_SkipBlock_PageRead(
        const DRV_HANDLE handle,
        uint16_t blockNum,
        uint16_t pageNum,
        uint8_t *data,
        uint8_t *spare,
        bool disableBlockCheck
    );

  Summary:
    Reads the data and/or the spare area of a page of given block from NAND Flash.

  Description:
    This function schedules a blocking operation for reading the data and/or the spare area
    of a page of given block from NAND Flash.

  Precondition:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle            - A valid open-instance handle, returned from the driver's
                      open routine
    blockNum          - Block number to read page from
    pageNum           - Page number to read inside the given block
    data              - Pointer to destination data buffer
    spare             - Pointer to destination spare buffer.
    disableBlockCheck - 0 - Block will be checked as good before reading a page.
                        1 - Block will not check before reading a page.

  Returns:
    true  - If Page read is successfully completed

    false - If Page read fails

  Example:
    <code>

    DRV_HANDLE handle;  
    uint16_t blockNum = 3;
    uint16_t pageNum = 0;
    static uint8_t pageBuffer[4096 + 224];

    if (DRV_NAND_FLASH_SkipBlock_PageRead(handle, blockNum, pageNum, pageBuffer, 0, 0))
    {
       
    }

    </code>

  Remarks:
    This routine will block waiting until read request is completed successfully.
*/

bool DRV_NAND_FLASH_SkipBlock_PageRead(
    const DRV_HANDLE handle,
    uint16_t blockNum,
    uint16_t pageNum,
    uint8_t *data,
    uint8_t *spare,
    bool disableBlockCheck
);

// *****************************************************************************
/* Function:
    bool DRV_NAND_FLASH_SkipBlock_BlockRead(const DRV_HANDLE handle, uint16_t blockNum, uint8_t *data, bool disableBlockCheck)

  Summary:
    Reads the data of a whole block from NAND Flash.

  Description:
    This function schedules a blocking operation for reading the data of a whole block from NAND Flash.

  Precondition:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle            - A valid open-instance handle, returned from the driver's
                      open routine
    blockNum          - Block number to read
    data              - Pointer to destination data buffer
    disableBlockCheck - 0 - Block will be checked as good before reading a given block.
                        1 - Block will not check before reading a given block.

  Returns:
    true - If Block read is successfully completed

    false - If Block read fails

  Example:
    <code>

    DRV_HANDLE handle; 
    uint16_t blockNum = 3;
    static uint8_t blockBuffer[262144 + 14336];

    if (DRV_NAND_FLASH_SkipBlock_BlockRead(handle, blockNum, blockBuffer, 0))
    {
        
    }

    </code>

  Remarks:
    This routine will block waiting until read request is completed successfully.
*/

bool DRV_NAND_FLASH_SkipBlock_BlockRead(const DRV_HANDLE handle, uint16_t blockNum, uint8_t *data, bool disableBlockCheck);

// *****************************************************************************
/* Function:
    bool DRV_NAND_FLASH_SkipBlock_PageWrite(
        const DRV_HANDLE handle,
        uint16_t blockNum,
        uint16_t pageNum,
        uint8_t *data,
        uint8_t *spare,
        bool disableBlockCheck
    );

  Summary:
    Writes the data and/or the spare area of a page of given block to NAND Flash.

  Description:
    This function schedules a blocking operation for writing the data and/or the spare area
    of a page of given block to NAND Flash.

  Precondition:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle            - A valid open-instance handle, returned from the driver's open routine
    blockNum          - Block number to write page
    pageNum           - Page number to write inside the given block
    data              - Pointer to source data buffer
    spare             - Pointer to source spare buffer.
    disableBlockCheck - 0 - Block will be checked as good before writing a page.
                        1 - Block will not check before writing a page.

  Returns:
    true - If Page write is successfully completed

    false - If Page write fails

  Example:
    <code>

    DRV_HANDLE handle;  
    uint16_t blockNum = 3;
    uint16_t pageNum = 0;
    static uint8_t pageBuffer[4096 + 224];

    memset(pageBuffer, 0x55, sizeof(pageBuffer));
    if (DRV_NAND_FLASH_SkipBlock_PageWrite(handle, blockNum, pageNum, pageBuffer, 0, 0))
    {
        
    }

    </code>

  Remarks:
    This routine will block wait until write request is submitted successfully.

    Client should wait until write is complete to send next transfer request.
*/

bool DRV_NAND_FLASH_SkipBlock_PageWrite(
    const DRV_HANDLE handle,
    uint16_t blockNum,
    uint16_t pageNum,
    uint8_t *data,
    uint8_t *spare,
    bool disableBlockCheck
);

// *****************************************************************************
/* Function:
    bool DRV_NAND_FLASH_SkipBlock_BlockWrite(const DRV_HANDLE handle, uint16_t blockNum, uint8_t *data, bool disableBlockCheck)

  Summary:
    Writes the data of a whole block to NAND Flash.

  Description:
    This function schedules a blocking operation for writing the data of a whole block to NAND Flash.

  Precondition:
    The DRV_NAND_FLASH_Open() routine must have been called for the
    specified NAND FLASH driver instance.

  Parameters:
    handle            - A valid open-instance handle, returned from the driver's open routine
    blockNum          - Block number to write
    data              - Pointer to source data buffer
    disableBlockCheck - 0 - Block will be checked as good before writing a given block.
                        1 - Block will not check before writing a given block.

  Returns:
    true  - If Block write is successfully completed

    false - If Block write fails

  Example:
    <code>

    DRV_HANDLE handle;  
    uint16_t blockNum = 3;
    static uint8_t blockBuffer[262144 + 14336];

    memset(blockBuffer, 0x55, sizeof(blockBuffer));

    if (DRV_NAND_FLASH_SkipBlock_BlockWrite(handle, blockNum, blockBuffer, 0))
    {
        
    }

    </code>

  Remarks:
    This routine will block wait until write request is submitted successfully.

    Client should wait until write is complete to send next transfer request.
*/

bool DRV_NAND_FLASH_SkipBlock_BlockWrite(const DRV_HANDLE handle, uint16_t blockNum, uint8_t *data, bool disableBlockCheck);

#ifdef __cplusplus
}
#endif

#endif // #ifndef DRV_NAND_FLASH_H
/*******************************************************************************
 End of File
*/