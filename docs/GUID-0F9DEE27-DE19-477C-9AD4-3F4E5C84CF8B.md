# SYS\_FS\_EVENT Enum

**Parent topic:**[Library Interface](GUID-42556FDF-A632-49FE-8A5E-9303A926578C.md)

## C

```c
typedef enum
{
    /* Media has been mounted successfully. */
    SYS_FS_EVENT_MOUNT,
    
    /* Media has been mounted successfully.
     * Media has to be formatted as there is no filesystem present.
    */
    SYS_FS_EVENT_MOUNT_WITH_NO_FILESYSTEM,
    
    /* Media has been unmounted successfully. */
    SYS_FS_EVENT_UNMOUNT,
    
    /* There was an error during the operation */
    SYS_FS_EVENT_ERROR
} SYS_FS_EVENT;

```

## Summary

Identifies the possible file system events.

## Description

This enumeration identifies the possible events that can result from a<br />file system.

## Remarks

One of these values is passed in the "event" parameter of the event handling callback function that client registered with the file system by setting the event handler when media mount or unmount is completed.

