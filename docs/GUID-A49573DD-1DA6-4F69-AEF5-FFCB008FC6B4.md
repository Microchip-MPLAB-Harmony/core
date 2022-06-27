# DRV\_IO\_BUFFER\_TYPES Enum

**Parent topic:**[Common Driver Library](GUID-DFB9A1FE-5BBB-4A10-A4B0-430BA7B9AF94.md)

## C

```c
typedef enum
{
    // Operation does not apply to any buffer
    DRV_IO_BUFFER_TYPE_NONE = 0x00,

    // Operation applies to read buffer
    DRV_IO_BUFFER_TYPE_READ = 0x01,

    // Operation applies to write buffer
    DRV_IO_BUFFER_TYPE_WRITE = 0x02,

    // Operation applies to both read and write buffers
    DRV_IO_BUFFER_TYPE_RW = DRV_IO_BUFFER_TYPE_READ|DRV_IO_BUFFER_TYPE_WRITE

} DRV_IO_BUFFER_TYPES;

```

## Summary

Identifies to which buffer a device operation will apply.

## Description

This enumeration identifies to which buffer \(read, write, both, or neither\)<br />a device operation will apply. This is used for "flush" \(or similar\)<br />operations.

