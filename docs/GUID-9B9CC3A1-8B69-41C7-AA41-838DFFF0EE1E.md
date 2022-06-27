# DRV\_SDMMC\_EVENT Enum

**Parent topic:**[Library Interface](GUID-D15D1321-065D-4EA7-A00C-D277A8A66F8D.md)

## C

```c
typedef enum
{
    /* Operation has been completed successfully. */
    DRV_SDMMC_EVENT_COMMAND_COMPLETE = SYS_MEDIA_EVENT_BLOCK_COMMAND_COMPLETE,

    /* There was an error during the operation */
    DRV_SDMMC_EVENT_COMMAND_ERROR = SYS_MEDIA_EVENT_BLOCK_COMMAND_ERROR

} DRV_SDMMC_EVENT;

```

## Summary

Identifies the possible events that can result from a request.

## Description

This enumeration identifies the possible events that can result from a<br />read or a write request issued by the client.

One of these values is passed in the "event" parameter of the event<br />handling callback function that client registered with the driver by<br />calling the DRV\_SDMMC\_EventHandlerSet function when a request is completed.

## Remarks

Refer sys\_media.h for SYS\_MEDIA\_XXX definitions.

