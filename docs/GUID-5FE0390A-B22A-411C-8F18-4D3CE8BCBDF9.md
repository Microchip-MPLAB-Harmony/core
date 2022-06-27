# DRV\_SST26\_UnlockFlash Function

**Parent topic:**[Library Interface](GUID-9FCC5D93-AC38-4FA0-88B8-A6C5A9BAF6EF.md)

## C

```c
bool DRV_SST26_UnlockFlash( const DRV_HANDLE handle );
```

## Summary

Unlocks the flash device for Erase and Program operations.

## Description

This function schedules a blocking operation for unlocking the flash blocks<br />globally. This allows to perform erase and program operations on the flash.

## Precondition

The DRV\_SST26\_Open\(\) routine must have been called for the specified SST26 driver instance.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open routine|

## Returns

*true*<br />- if the unlock is successfully completed

*false*<br />- if Write enable fails before sending unlock command to flash and<br />- if Unlock flash command itself fails

## Example

```c
DRV_HANDLE handle; // Returned from DRV_SST26_Open

if(DRV_SST26_UnlockFlash(handle) == false)
{
    // Error handling here
}

```

## Remarks

None.

