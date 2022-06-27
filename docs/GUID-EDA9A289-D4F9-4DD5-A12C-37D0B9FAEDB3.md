# DRV\_AT24\_TRANSFER\_STATUS Enum

**Parent topic:**[Library Interface](GUID-354A36E3-7E0B-4DD0-8485-DDFD792B525C.md)

## C

```c
typedef enum
{
    /* Transfer is being processed */
    DRV_AT24_TRANSFER_STATUS_BUSY,

    /* Transfer is successfully completed */
    DRV_AT24_TRANSFER_STATUS_COMPLETED,

    /* Transfer had error */
    DRV_AT24_TRANSFER_STATUS_ERROR

} DRV_AT24_TRANSFER_STATUS;

```

## Summary

Defines the data type for AT24 Driver transfer status.

## Description

This will be used to indicate the current transfer status of the<br />AT24 EEPROM driver operations.

## Remarks

None.

