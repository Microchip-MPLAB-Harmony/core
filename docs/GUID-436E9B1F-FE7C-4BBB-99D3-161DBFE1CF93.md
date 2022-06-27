# DRV\_AT25\_EVENT\_HANDLER Typedef

**Parent topic:**[Library Interface](GUID-FC2766BD-E5AF-4007-BA9A-D1E179E8AF51.md)

## C

```c
typedef void (*DRV_AT25_EVENT_HANDLER )( DRV_AT25_TRANSFER_STATUS event, uintptr_t context );

```

## Summary

Pointer to a AT25 Driver Event handler function

## Description

This data type defines the required function signature for the AT25 driver<br />event handling callback function. A client must register a pointer<br />using the event handling function whose function signature \(parameter<br />and return value types\) match the types specified by this function pointer<br />in order to receive transfer related event calls back from the driver.

The parameters and return values are described here and<br />a partial example implementation is provided.

## Parameters

|Param|Description|
|-----|-----------|
|event|Identifies the type of event|
|context|Value identifying the context of the application that registered the event handling function.|

## Returns

None.

## Example

```c
void APP_MyTransferEventHandler( DRV_AT25_TRANSFER_STATUS event, uintptr_t context )
{
    MY_APP_DATA_STRUCT* pAppData = (MY_APP_DATA_STRUCT*) context;
    
    switch(event)
    {
        case DRV_AT25_TRANSFER_STATUS_COMPLETED:
        
        // Handle the transfer complete event.
        break;
        
        case DRV_AT25_TRANSFER_STATUS_ERROR:
        default:
        
        // Handle error.
        break;
    }
}
```

## Remarks

If the event is DRV\_AT25\_TRANSFER\_STATUS\_COMPLETED, it means that the data was transferred successfully.

If the event is DRV\_AT25\_TRANSFER\_STATUS\_ERROR, it means that the data was not transferred successfully.

The context parameter contains the handle to the client context, provided at the time the event handling function was registered using the DRV\_AT25\_EventHandlerSet function. This context handle value is passed back to the client as the "context" parameter.

It can be any value necessary to identify the client context or instance \(such as a pointer to the client's data\) instance of the client that made the buffer add request. The event handler function executes in the driver's interrupt context.

It is recommended of the application to not perform process intensive or blocking operations with in this function. The DRV\_AT25\_Read, DRV\_AT25\_Write and DRV\_AT25\_PageWrite functions can be called in the event handler to submit a request to the driver.

