# DRV\_SDSPI\_COMMAND\_STATUS Enum

**Parent topic:**[Library Interface](GUID-7A1B4F41-7CC6-49CF-941E-25265059D247.md)

## C

```c
typedef enum
{
    /*Done OK and ready */
    DRV_SDSPI_COMMAND_COMPLETED = SYS_MEDIA_COMMAND_COMPLETED,

    /*Scheduled but not started */
    DRV_SDSPI_COMMAND_QUEUED = SYS_MEDIA_COMMAND_QUEUED,

    /*Currently being in transfer */
    DRV_SDSPI_COMMAND_IN_PROGRESS = SYS_MEDIA_COMMAND_IN_PROGRESS,

    /*Unknown Command */
    DRV_SDSPI_COMMAND_ERROR_UNKNOWN = SYS_MEDIA_COMMAND_UNKNOWN,

} DRV_SDSPI_COMMAND_STATUS;

```

## Summary

Identifies the possible events that can result from a request.

## Description

This enumeration identifies the possible status values of a read or write<br />buffer request submitted to the driver.

One of these values is returned by the DRV\_SDSPI\_CommandStatusGet routine.

## Remarks

Refer sys\_media.h for SYS\_MEDIA\_XXX definitions.

