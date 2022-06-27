# DRV\_MX25L\_TransferStatusGet Function

**Parent topic:**[Library Interface](GUID-410DBBCC-D224-45B2-B881-7BFB0DFF0EFC.md)

## C

```c
DRV_MX25L_TRANSFER_STATUS DRV_MX25L_TransferStatusGet( const DRV_HANDLE handle );
```

## Summary

Gets the current status of the transfer request.

## Description

This routine gets the current status of the transfer request. The application<br />must use this routine where the status of a scheduled request needs to be<br />polled on.

## Preconditions

The DRV\_MX25L\_Open\(\) routine must have been called for the specified MX25L driver instance.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open routine|

## Returns

*DRV\_MX25L\_TRANSFER\_ERROR\_UNKNOWN* - If the flash status register read request fails

*DRV\_MX25L\_TRANSFER\_BUSY* - If the current transfer request is still being processed

*DRV\_MX25L\_TRANSFER\_COMPLETED* - If the transfer request is completed

## Example

```c
DRV_HANDLE handle; // Returned from DRV_MX25L_Open

if (DRV_MX25L_TransferStatusGet(handle) == DRV_MX25L_TRANSFER_COMPLETED)
{
    // Operation Done
}
```

## Remarks

This routine will block for hardware access.

