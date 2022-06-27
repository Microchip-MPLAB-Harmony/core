# DRV\_AT25DF\_TRANSFER\_STATUS Enum

**Parent topic:**[Library Interface](GUID-6D9FA3F1-00EF-4C4D-AC06-CF95F5137ACB.md)

## C

```c
typedef enum
{
    /* Transfer is being processed */
    DRV_AT25DF_TRANSFER_STATUS_BUSY,

    /* Transfer is successfully completed*/
    DRV_AT25DF_TRANSFER_STATUS_COMPLETED,

    /* Transfer had error */
    DRV_AT25DF_TRANSFER_STATUS_ERROR

} DRV_AT25DF_TRANSFER_STATUS;

```

## Summary

Defines the data type for AT25DF Driver transfer status.

## Description

This will be used to indicate the current transfer status of the<br />AT25DF FLASH driver operations.

## Remarks

None.

