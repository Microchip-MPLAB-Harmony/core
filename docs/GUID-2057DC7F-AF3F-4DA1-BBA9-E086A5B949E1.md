# SYS\_FS\_MEDIA\_MANAGER\_SectorRead Function

**Parent topic:**[Library Interface](GUID-42556FDF-A632-49FE-8A5E-9303A926578C.md)

## C

```c
SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE SYS_FS_MEDIA_MANAGER_SectorRead
(
    uint16_t diskNo,
    uint8_t * dataBuffer,
    uint32_t sector,
    uint32_t noSectors
);
```

## Summary

Reads a specified media sector.

## Description

This function reads a specified media \(disk\) sector. This is the function<br />in the media manager layer. This function in turn calls the specific<br />sector read function from the list of function pointers of the media<br />driver.

## Precondition

None.

## Parameters

|Param|Description|
|-----|-----------|
|diskNo|Media number|
|dataBuffer|Pointer to buffer where data to be placed after read|
|sector|Sector numer to be read|
|noSectors|Number of sectors to read|

## Returns

Buffer handle of type SYS\_FS\_MEDIA\_BLOCK\_COMMAND\_HANDLE.

