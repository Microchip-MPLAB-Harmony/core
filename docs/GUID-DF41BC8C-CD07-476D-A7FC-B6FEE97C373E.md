# DRV\_SST26\_ChipErase Function

**Parent topic:**[Library Interface](GUID-9FCC5D93-AC38-4FA0-88B8-A6C5A9BAF6EF.md)

## C

```c
bool DRV_SST26_ChipErase( const DRV_HANDLE handle );
```

## Summary

Erase entire flash memory.

## Description

This function schedules a non-blocking chip erase operation of flash memory.

The requesting client should call DRV\_SST26\_TransferStatusGet\(\) API to know<br />the current status of the request.

## Preconditions

The DRV\_SST26\_Open\(\) routine must have been called for the specified SST26 driver instance.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open routine|

## Returns

*true*

-   if the erase request is successfully sent to the flash


*false*

-   if Write enable fails before sending sector erase command to flash

-   if chip erase command itself fails


## Example

```c
DRV_HANDLE handle; // Returned from DRV_SST26_Open

if(DRV_SST26_ChipErase(handle) == flase)
{
    // Error handling here
}

// Wait for erase to be completed
while(DRV_SST26_TransferStatusGet(handle) == DRV_SST26_TRANSFER_BUSY);

```

## Remarks

None.

