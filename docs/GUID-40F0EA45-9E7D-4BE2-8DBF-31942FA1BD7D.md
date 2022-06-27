# DRV\_MEMORY\_GeometryGet Function

**Parent topic:**[Library Interface](GUID-E18B0923-4286-4E08-A2EB-9A482E0063AE.md)

## C

```c
SYS_MEDIA_GEOMETRY* DRV_MEMORY_GeometryGet
(
    const DRV_HANDLE handle
);
```

## Summary

Returns the geometry of the memory device.

## Description

This API gives the following geometrical details of the attached memory device:

-   Media Property

-   Number of Read/Write/Erase regions in the memory device

-   Number of Blocks and their size in each region of the device


## Precondition

The DRV\_MEMORY\_Open\(\) routine must have been called to obtain a valid opened device handle.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open function|

## Returns

*SYS\_MEDIA\_GEOMETRY* - Pointer to structure which holds the media geometry information.

## Example

```c
SYS_MEDIA_GEOMETRY geometry;
uint32_t readBlockSize, writeBlockSize, eraseBlockSize;
uint32_t nReadBlocks, nReadRegions, totalFlashSize;

if (true != DRV_MEMORY_GeometryGet(&geometry))
{
    // Handle Error
}

readBlockSize = geometry.geometryTable[SYS_MEDIA_GEOMETRY_TABLE_READ_ENTRY].blockSize;
nReadBlocks = geometry.geometryTable[SYS_MEDIA_GEOMETRY_TABLE_READ_ENTRY].numBlocks;
nReadRegions = geometry.numReadRegions;

writeBlockSize = geometry.geometryTable[SYS_MEDIA_GEOMETRY_TABLE_WRITE_ENTRY].blockSize;
eraseBlockSize = geometry.geometryTable[SYS_MEDIA_GEOMETRY_TABLE_ERASE_ENTRY].blockSize;

totalFlashSize = readBlockSize * nReadBlocks * nReadRegions;

```

## Remarks

Refer sys\_media.h for definition of SYS\_MEDIA\_GEOMETRY.

