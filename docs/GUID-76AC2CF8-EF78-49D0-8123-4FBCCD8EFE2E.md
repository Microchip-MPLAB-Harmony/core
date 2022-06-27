# SYS\_DEBUG\_Initialize Function

**Parent topic:**[Library Interface](GUID-3CBAD06F-CC26-46CB-AF78-AE7790F210D6.md)

## C

```c
SYS_MODULE_OBJ SYS_DEBUG_Initialize(
    const SYS_MODULE_INDEX index,
    const SYS_MODULE_INIT* const init
)
```

## Summary

Initializes the global error level and specific module instance.

## Description

This function initializes the global error level. It also initializes any<br />internal system debug module data structures.

## Precondition

None.

## Parameters

|Param|Description|
|-----|-----------|
|index|Index for the instance to be initialized.|
|init|Pointer to a data structure containing any data necessary to initialize the debug service. This pointer may be null if no data is required because static overrides have been provided.|

## Returns

If successful, returns SYS\_MODULE\_OBJ\_STATIC. Otherwise, it returns SYS\_MODULE\_OBJ\_INVALID.

## Example

```c
SYS_MODULE_OBJ objectHandle;
SYS_DEBUG_INIT debugInit =
{
    .moduleInit = {0},
    .errorLevel = SYS_DEBUG_GLOBAL_ERROR_LEVEL,
    .consoleIndex = 0,
};

objectHandle = SYS_DEBUG_Initialize(SYS_DEBUG_INDEX_0, (SYS_MODULE_INIT*)&debugInit);

if (objectHandle == SYS_MODULE_OBJ_INVALID)
{
    // Handle error
}
```

## Remarks

This routine should only be called once during system initialization.

