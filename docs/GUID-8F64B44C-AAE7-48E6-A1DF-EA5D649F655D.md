# SYS\_FS\_MEDIA\_MANAGER\_SectorWrite Function

**Parent topic:**[Library Interface](GUID-42556FDF-A632-49FE-8A5E-9303A926578C.md)

## C

```c
SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE SYS_FS_MEDIA_MANAGER_SectorWrite
(
    uint16_t diskNo,
    uint32_t sector,
    uint8_t * dataBuffer,
    uint32_t noSectors
);
```

## Summary

Writes a sector to the specified media.

## Description

This function writes to a sector of the specified media \(disk\). This is<br />the function in the media manager layer. This function in turn calls the<br />specific sector write function from the list of function pointers of the<br />media driver.

## Precondition

None.

## Parameters

|Param|Description|
|-----|-----------|
|diskNo|media number|
|sector|Sector \# to which data to be written|
|dataBuffer|pointer to buffer which holds the data to be written|
|noSectors|Number of sectors to be written|

## Returns

Buffer handle of type SYS\_FS\_MEDIA\_BLOCK\_COMMAND\_HANDLE.

