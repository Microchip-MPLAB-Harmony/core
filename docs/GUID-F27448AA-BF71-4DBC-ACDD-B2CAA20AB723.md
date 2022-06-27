# SYS\_TIME\_Deinitialize Function

**Parent topic:**[Library Interface](GUID-3D84F884-122D-4A4A-95DA-DFD8C2E84650.md)

## C

```c
void SYS_TIME_Deinitialize ( SYS_MODULE_OBJ object )
```

## Summary

Deinitializes the specific module instance of the SYS TIMER module

## Description

This function deinitializes the specific module instance disabling its<br />operation \(and any hardware for driver modules\). Resets all of the internal<br />data structures and fields for the specified instance to the default settings.

## Precondition

The SYS\_TIME\_Initialize function should have been called before calling this function.

## Parameters

|Param|Description|
|-----|-----------|
|object|SYS TIMER object handle, returned from SYS\_TIME\_Initialize|

## Returns

None.

## Example

```c
// Handle "objSysTime" value must have been returned from SYS_TIME_Initialize.

SYS_TIME_Deinitialize (objSysTime);

if (SYS_TIME_Status (objSysTime) != SYS_STATUS_UNINITIALIZED)
{
    // Check again later if you need to know
    // when the SYS TIME is De-initialized.
}
```

## Remarks

Once the Initialize operation has been called, the De-initialize operation must be called before the Initialize operation can be called again.

