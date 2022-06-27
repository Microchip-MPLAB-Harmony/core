# DRV\_SST26\_Open Function

**Parent topic:**[Library Interface](GUID-9FCC5D93-AC38-4FA0-88B8-A6C5A9BAF6EF.md)

## C

```c
DRV_HANDLE DRV_SST26_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent );
```

## Summary

Opens the specified SST26 driver instance and returns a handle to it

## Description

This routine opens the specified SST26 driver instance and provides a handle.

It performs the following blocking operations:

-   Resets the Flash Device

-   Puts it on QUAD IO Mode

-   Unlocks the flash if DRV\_SST26\_Open was called with write intent.


This handle must be provided to all other client-level operations to identify<br />the caller and the instance of the driver.

## Preconditions

Function DRV\_SST26\_Initialize must have been called before calling this function. Driver should be in ready state to accept the request. Can be checked by calling DRV\_SST26\_Status\(\).

## Parameters

|Param|Description|
|-----|-----------|
|drvIndex|Identifier for the instance to be opened|
|ioIntent|Zero or more of the values from the enumeration DRV\_IO\_INTENT "ORed" together to indicate the intended use of the driver|

## Returns

*If successful,* the routine returns a valid open-instance handle \(a number identifying both the caller and the module instance\).

*If an error occurs,* DRV\_HANDLE\_INVALID is returned. Errors can occur under the following circumstances:

-   if the driver hardware instance being opened is not initialized.


## Example

```c
DRV_HANDLE handle;

handle = DRV_SST26_Open(DRV_SST26_INDEX);
if (DRV_HANDLE_INVALID == handle)
{
    // Unable to open the driver
}
```

## Remarks

The handle returned is valid until the DRV\_SST26\_Close routine is called. If the driver has already been opened, it should not be opened again.

