# DRV\_SDMMC\_IsAttached Function

**Parent topic:**[Library Interface](GUID-D15D1321-065D-4EA7-A00C-D277A8A66F8D.md)

## C

```c
bool DRV_SDMMC_IsAttached ( const DRV_HANDLE handle );
```

## Summary

Returns the physical attach status of the SD Card.

## Description

This function returns the physical attach status of the SD Card.

## Precondition

The DRV\_SDMMC\_Initialize routine must have been called for the specified SDMMC driver instance. The DRV\_SDMMC\_Open routine must have been called to obtain a valid opened device handle.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open function|

## Returns

Returns false if the handle is invalid otherwise returns the attach status of the SD Card. Returns true if the SD Card is attached and initialized by the SDMMC driver otherwise returns false.

## Example

```c
// drvSDMMCHandle is the handle returned
// by the DRV_SDMMC_Open function.

bool isSDMMCAttached;
isSDMMCAttached = DRV_SDMMC_isAttached(drvSDMMCHandle);

```

## Remarks

None.

