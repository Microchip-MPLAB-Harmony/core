# DRV\_SDMMC\_EVENT\_HANDLER Typedef

**Parent topic:**[Library Interface](GUID-D15D1321-065D-4EA7-A00C-D277A8A66F8D.md)

## C

```c
typedef SYS_MEDIA_EVENT_HANDLER DRV_SDMMC_EVENT_HANDLER;

```

## Summary

Pointer to a SDMMCDriver Event handler function

## Description

This data type defines the required function signature for the SDMMC event<br />handling callback function. A client must register a pointer to an event<br />handling function whose function signature \(parameter and return value<br />types\) match the types specified by this function pointer in order to<br />receive event calls back from the driver.

If the event is DRV\_SDMMC\_EVENT\_COMMAND\_COMPLETE, it means that the<br />write or a read operation was completed successfully.

If the event is DRV\_SDMMC\_EVENT\_COMMAND\_ERROR, it means that the operation<br />was not completed successfully.

The context parameter contains the handle to the client context, provided<br />at the time the event handling function was registered using the<br />DRV\_SDMMC\_EventHandlerSet function. This context handle value is<br />passed back to the client as the "context" parameter. It can be any value<br />necessary to identify the client context or instance \(such as a pointer to<br />the client's data\) instance of the client that made the read/write<br />request.

## Parameters

|Param|Description|
|-----|-----------|
|event|Identifies the type of event|
|commandHandle|Handle returned from the Read/Write requests|
|context|Value identifying the context of the application that registered the event handling function|

## Returns

None.

## Example

```c
void APP_MySDMMCEventHandler
(
    DRV_SDMMC_EVENT event,
    DRV_SDMMC_COMMAND_HANDLE commandHandle,
    uintptr_t context
)
{
    MY_APP_DATA_STRUCT* pAppData = (MY_APP_DATA_STRUCT* ) context;
    
    switch(event)
    {
        case DRV_SDMMC_EVENT_COMMAND_COMPLETE:
        {
            // Handle the completed buffer.
            break;
        }
        
        case DRV_SDMMC_EVENT_COMMAND_ERROR:
        default:
        {
            // Handle error.
            break;
        }
    }
}
```

## Remarks

Refer sys\_media.h for definition of SYS\_MEDIA\_EVENT\_HANDLER.

