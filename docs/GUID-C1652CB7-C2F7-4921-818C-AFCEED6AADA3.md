# SYS\_MEDIA\_EVENT\_HANDLER Typedef

**Parent topic:**[Common System Services Library](GUID-B6B51E48-2D3D-42F8-8493-3405F1639A9E.md)

## C

```c
typedef void (* SYS_MEDIA_EVENT_HANDLER)
(
    SYS_MEDIA_BLOCK_EVENT event,
    SYS_MEDIA_BLOCK_COMMAND_HANDLE commandHandle,
    uintptr_t context
);

```

## Summary

Pointer to the Media Event Handler function.

## Description

This data type defines the required function signature for the media event<br />handling callback function. A client must register a pointer to an event<br />handling function whose function signature \(parameter and return value<br />types\) match the types specified by this function pointer in order to<br />receive event calls back from the driver.

## Parameters

|Param|Description|
|-----|-----------|
|event|Identifies the type of event|
|commandHandle|Handle returned from the media operation requests|
|context|Value identifying the context of the application that registered the event handling function|

## Returns

None.

## Remarks

None.

