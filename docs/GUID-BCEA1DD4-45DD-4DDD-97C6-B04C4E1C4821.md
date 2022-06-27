# SYS\_STATUS Enum

**Parent topic:**[Common System Services Library](GUID-B6B51E48-2D3D-42F8-8493-3405F1639A9E.md)

## C

```c
typedef enum
{
    // Indicates that a non-system defined error has occurred. The caller
    // must call the extended status routine for the module in question to
    // identify the error.
    SYS_STATUS_ERROR_EXTENDED = -10,

    /*An unspecified error has occurred.*/
    SYS_STATUS_ERROR = -1,

    // The module has not yet been initialized
    SYS_STATUS_UNINITIALIZED = 0,

    // An operation is currently in progress
    SYS_STATUS_BUSY = 1,

    // Any previous operations have succeeded and the module is ready for
    // additional operations
    SYS_STATUS_READY = 2,

    // Indicates that the module is in a non-system defined ready/run state.
    // The caller must call the extended status routine for the module in
    // question to identify the state.
    SYS_STATUS_READY_EXTENDED = 10

} SYS_STATUS;

```

## Summary

Identifies the current status/state of a system module \(including device drivers\).

## Description

This enumeration identifies the current status/state of a system module<br />\(including device drivers\).

## Remarks

This enumeration is the return type for the system-level status routine defined by each device driver or system module \(for example, DRV\_I2C\_Status\).

