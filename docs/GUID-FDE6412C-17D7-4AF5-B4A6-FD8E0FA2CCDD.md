# DRV\_SDSPI\_Status Function

**Parent topic:**[Library Interface](GUID-7A1B4F41-7CC6-49CF-941E-25265059D247.md)

## C

```c
SYS_STATUS DRV_SDSPI_Status
(
    SYS_MODULE_OBJ object
)
```

## Summary

Provides the current status of the SDSPI driver module.

## Description

This routine provides the current status of the SDSPI driver module.

## Precondition

Function DRV\_SDSPI\_Initialize must have been called before calling this function

## Parameters

|Param|Description|
|-----|-----------|
|object|Driver object handle, returned from the DRV\_SDSPI\_Initialize routine|

## Returns

*SYS\_STATUS\_READY* - Indicates that the driver has been initialized and is ready to accept requests from the client.

*SYS\_STATUS\_UNINITIALIZED* - Indicates that the driver has not been initialized.

## Example

```c
SYS_MODULE_OBJ object; // Returned from DRV_SDSPI_Initialize
SYS_STATUS status;

status = DRV_SDSPI_Status(object);

if (status == SYS_STATUS_READY)
{
    // Driver is initialized and ready.
}
```

## Remarks

This operation can be used to determine if the driver is initialized or not.

