# MEMORY\_DEVICE\_GEOMETRY Struct

**Parent topic:**[Library Interface](GUID-E18B0923-4286-4E08-A2EB-9A482E0063AE.md)

## C

```c
typedef struct
{
    uint32_t read_blockSize;
    uint32_t read_numBlocks;
    uint32_t numReadRegions;

    uint32_t write_blockSize;
    uint32_t write_numBlocks;
    uint32_t numWriteRegions;

    uint32_t erase_blockSize;
    uint32_t erase_numBlocks;
    uint32_t numEraseRegions;

    uint32_t blockStartAddress;
} MEMORY_DEVICE_GEOMETRY;

```

## Summary

Memory Device Geometry Table.

## Description

This Data Structure is used by Memory driver to get<br />the media geometry details.

The Media attached to memory driver needs to fill in<br />this data structure when GEOMETRY\_GET is called.

## Remarks

None.

