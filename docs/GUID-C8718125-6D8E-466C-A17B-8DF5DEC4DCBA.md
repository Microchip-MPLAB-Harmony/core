# DRV\_NAND\_FLASH\_SkipBlock\_BlockCheck Function

**Parent topic:**[Library Interface](GUID-B826AB75-F4E4-4A5B-8189-23C99CCF9936.md)

## C

```c
bool DRV_NAND_FLASH_SkipBlock_BlockCheck(const DRV_HANDLE handle, uint16_t blockNum)
```

## Summary

Checks whether NAND Flash block is bad or good.

## Description

This routine returns false if the given block of NAND Flash device is bad otherwise true.

## Preconditions

The DRV\_NAND\_FLASH\_Open\(\) routine must have been called for the specified NAND FLASH driver instance.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open routine|
|blockNum|Block number to check|

## Returns

*true* - If block is good

*false* - If block is bad

## Example

```c
uint16_t blockNum = 0;
DRV_HANDLE handle; // Returned from DRV_NAND_FLASH_Open

if (DRV_NAND_FLASH_SkipBlock_BlockCheck(handle, blockNum))
// Block is good
}
```

## Remarks

This routine will block for hardware access.

