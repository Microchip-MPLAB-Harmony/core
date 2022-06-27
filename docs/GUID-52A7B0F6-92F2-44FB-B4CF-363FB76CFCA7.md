# SYS\_FS\_EVENT\_HANDLER Typedef

**Parent topic:**[Library Interface](GUID-42556FDF-A632-49FE-8A5E-9303A926578C.md)

## C

```c
typedef void (* SYS_FS_EVENT_HANDLER)
(
    SYS_FS_EVENT event,
    void* eventData,
    uintptr_t context
);
```

## Summary

Pointer to the File system Handler function.

## Description

This data type defines the required function signature for the<br />file system event handling callback function. A client must register<br />a pointer to an event handling function whose function signature \(parameter<br />and return value types\) match the types specified by this function pointer<br />in order to receive event call backs from the file system.

## Parameters

|Param|Description|
|-----|-----------|
|event|Identifies the type of event|
|eventData|Handle returned from the media operation requests|
|context|Value identifying the context of the application that registered the event handling function|

## Returns

None.

## Remarks

None.

