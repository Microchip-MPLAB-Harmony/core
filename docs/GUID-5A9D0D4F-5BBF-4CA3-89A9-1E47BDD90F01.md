# DRV\_AT25DF\_GeometryGet Function

**Parent topic:**[Library Interface](GUID-6D9FA3F1-00EF-4C4D-AC06-CF95F5137ACB.md)

## C

```c
bool DRV_AT25DF_GeometryGet(const DRV_HANDLE handle, DRV_AT25DF_GEOMETRY *geometry)
```

## Summary

Returns the geometry of the device.

## Description

This API gives the following geometrical details of the DRV\_AT25DF Flash:

-   Number of Read/Write/Erase Blocks and their size in each region of the device


## Precondition

DRV\_AT25DF\_Open must have been called to obtain a valid opened device handle.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open routine|
|geometry|Pointer to flash device geometry table instance|

## Returns

*true* - if able to get the geometry details of the flash

*false* - if handle is invalid

## Example

```c
DRV_AT25DF_GEOMETRY flashGeometry;
uint32_t readBlockSize, writeBlockSize, eraseBlockSize;
uint32_t nReadBlocks, nReadRegions, totalFlashSize;

// myHandle is the handle returned from DRV_AT25DF_Open API.

DRV_AT25DF_GeometryGet(myHandle, &flashGeometry);

readBlockSize = flashGeometry.readBlockSize;
nReadBlocks = flashGeometry.readNumBlocks;
nReadRegions = flashGeometry.readNumRegions;

writeBlockSize = flashGeometry.writeBlockSize;
eraseBlockSize = flashGeometry.eraseBlockSize;

totalFlashSize = readBlockSize * nReadBlocks * nReadRegions;

```

## Remarks

None.

