# DRV\_MX25L\_ChipErase Function

**Parent topic:**[Library Interface](GUID-410DBBCC-D224-45B2-B881-7BFB0DFF0EFC.md)

## C

```c
bool DRV_MX25L_ChipErase( const DRV_HANDLE handle );
```

## Summary

Erase entire flash memory.

## Description

This function schedules a non-blocking chip erase operation of flash memory.

The requesting client should call DRV\_MX25L\_TransferStatusGet\(\) API to know<br />the current status of the request.

The request is sent in QUAD\_MODE to flash device.

## Preconditions

The DRV\_MX25L\_Open\(\) routine must have been called for the specified MX25L driver instance.

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
DRV_HANDLE handle; // Returned from DRV_MX25L_Open

if(DRV_MX25L_ChipErase(handle) == false)
{
    // Error handling here
}

// Wait for erase to be completed
while(DRV_MX25L_TransferStatusGet(handle) == DRV_MX25L_TRANSFER_BUSY);

```

## Remarks

This routine will block wait until erase request is submitted successfully.

Client should wait until erase is complete to send next transfer request.

