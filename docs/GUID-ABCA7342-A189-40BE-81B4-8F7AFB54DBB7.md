# DRV\_SDSPI\_Open Function

**Parent topic:**[Library Interface](GUID-7A1B4F41-7CC6-49CF-941E-25265059D247.md)

## C

```c
DRV_HANDLE DRV_SDSPI_Open
(
    const SYS_MODULE_INDEX drvIndex,
    const DRV_IO_INTENT ioIntent
)
```

## Summary

Opens the specified SD Card driver instance and returns a handle to it.

## Description

This routine opens the specified SD Card driver instance and provides a<br />handle that must be provided to all other client-level operations to<br />identify the caller and the instance of the driver.

## Precondition

Function DRV\_SDSPI\_Initialize must have been called before calling this function.

## Parameters

|Param|Description|
|-----|-----------|
|drvIndex|Identifier for the object instance to be opened|
|ioIntent|Zero or more of the values from the enumeration DRV\_IO\_INTENT "ORed" together to indicate the intended use of the driver. Supports only DRV\_IO\_INTENT\_EXCLUSIVE.|

## Returns

If successful, the routine returns a valid open-instance handle \(a number identifying both the caller and the module instance\).

If an error occurs, the return value is DRV\_HANDLE\_INVALID.

## Example

```c
DRV_HANDLE handle;

handle = DRV_SDSPI_Open (DRV_SDSPI_INDEX_0, DRV_IO_INTENT_EXCLUSIVE);

if (handle == DRV_HANDLE_INVALID)
{
    // Unable to open the driver
}
```

## Remarks

The handle returned is valid until the DRV\_SDSPI\_Close routine is called. This routine may block for other client-level operations to complete.

