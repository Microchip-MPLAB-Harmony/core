# DRV\_AT25DF\_Status Function

**Parent topic:**[Library Interface](GUID-6D9FA3F1-00EF-4C4D-AC06-CF95F5137ACB.md)

## C

```c
SYS_STATUS DRV_AT25DF_Status( const SYS_MODULE_INDEX drvIndex )
```

## Summary

Gets the current status of the AT25DF driver module.

## Description

This routine provides the current status of the AT25DF driver module.

## Preconditions

Function DRV\_AT25DF\_Initialize should have been called before calling this function.

## Parameters

|Param|Description|
|-----|-----------|
|drvIndex|Identifier for the instance used to initialize driver|

## Returns

*SYS\_STATUS\_READY* - Indicates that the driver is ready and accept requests for new operations.

*SYS\_STATUS\_UNINITIALIZED* - Indicates the driver is not initialized.

## Example

```c
SYS_STATUS status;

status = DRV_AT25DF_Status(DRV_AT25DF_INDEX);

if (status == SYS_STATUS_READY)
{
    // AT25DF driver is initialized and ready to accept requests.
}
```

## Remarks

None.

