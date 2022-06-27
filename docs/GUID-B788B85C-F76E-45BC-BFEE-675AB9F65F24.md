# DRV\_NAND\_FLASH\_Initialize Function

**Parent topic:**[Library Interface](GUID-B826AB75-F4E4-4A5B-8189-23C99CCF9936.md)

## C

```c
SYS_MODULE_OBJ DRV_NAND_FLASH_Initialize
(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT *const init
)
```

## Summary

Initializes the NAND FLASH Driver

## Description

This routine initializes the NAND FLASH driver making it ready for client to use.

-   Get the data address of NAND Flash


## Precondition

None.

## Parameters

|Param|Description|
|-----|-----------|
|drvIndex|Identifier for the instance to be initialized|
|init|Pointer to a data structure containing any data necessary to initialize the driver.|

## Returns

If successful, returns a valid handle to a driver instance object. Otherwise it returns SYS\_MODULE\_OBJ\_INVALID.

## Example

```c
// This code snippet shows an example of initializing the NAND FLASH Driver
// with NAND FLASH device attached.

SYS_MODULE_OBJ objectHandle;

const DRV_NAND_FLASH_PLIB_INTERFACE drvNandFlashPlibAPI = {
    .DataAddressGet = SMC_DataAddressGet,
    .CommandWrite = SMC_CommandWrite,
    .CommandWrite16 = SMC_CommandWrite16,
    .AddressWrite = SMC_AddressWrite,
    .AddressWrite16 = SMC_AddressWrite16,
    .DataWrite = SMC_DataWrite,
    .DataWrite16 = SMC_DataWrite16,
    .DataRead = SMC_DataRead,
    .DataRead16 = SMC_DataRead16,
    .DataPhaseStart = PMECC_DataPhaseStart,
    .StatusIsBusy = PMECC_StatusIsBusy,
    .ErrorGet = PMECC_ErrorGet,
    .RemainderGet = PMECC_RemainderGet,
    .ECCGet = PMECC_ECCGet,
    .ErrorLocationGet = PMERRLOC_ErrorLocationGet,
    .ErrorLocationDisable = PMERRLOC_ErrorLocationDisable,
    .SigmaSet = PMERRLOC_SigmaSet,
    .ErrorLocationFindNumOfRoots = PMERRLOC_ErrorLocationFindNumOfRoots
};

const DRV_NAND_FLASH_INIT drvNandFlashInitData =
{
    .nandFlashPlib = &drvNandFlashPlibAPI,
};

objectHandle = DRV_NAND_FLASH_Initialize((SYS_MODULE_INDEX)DRV_NAND_FLASH_INDEX, (SYS_MODULE_INIT *)&drvNandFlashInitData);

if (SYS_MODULE_OBJ_INVALID == objectHandle)
{
    // Handle error
}
```

## Remarks

This routine must be called before any other NAND FLASH driver routine is called.

This routine should only be called once during system initialization.

