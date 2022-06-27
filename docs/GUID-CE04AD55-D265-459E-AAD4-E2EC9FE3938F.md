# DRV\_I2C\_TRANSFER\_EVENT\_HANDLER Typedef

**Parent topic:**[Library Interface](GUID-5A5146D2-73C2-43B1-8ADE-95E0184AF1A5.md)

## C

```c
typedef void (*DRV_I2C_TRANSFER_EVENT_HANDLER )( DRV_I2C_TRANSFER_EVENT event, DRV_I2C_TRANSFER_HANDLE transferHandle, uintptr_t context );

```

## Summary

Pointer to a I2C Driver Transfer Event handler function

## Description

This data type defines the required function signature for the I2C driver<br />buffer event handling callback function. A client must register a pointer<br />using the buffer event handling function whose function signature \(parameter<br />and return value types\) match the types specified by this function pointer<br />in order to receive buffer related event calls back from the driver.

The parameters and return values are described here and<br />a partial example implementation is provided.

## Parameters

|Param|Description|
|-----|-----------|
|event|Identifies the type of event|
|transferHandle|Handle identifying the buffer to which the vent relates|
|context|Value identifying the context of the application that registered the event handling function.|

## Returns

None.

## Example

```c
void APP_MyTransferEventHandler( DRV_I2C_TRANSFER_EVENT event,
DRV_I2C_TRANSFER_HANDLE transferHandle,
uintptr_t context )
{
    MY_APP_DATA_STRUCT* pAppData = (MY_APP_DATA_STRUCT*) context;
    
    switch(event)
    {
        case DRV_I2C_TRANSFER_EVENT_COMPLETE:
        {
            // Handle the completed buffer.
            break;
        }
        
        case DRV_I2C_TRANSFER_EVENT_ERROR:
        default:
        {
            // Handle error.
            break;
        }
    }
}
```

## Remarks

If the event is DRV\_I2C\_TRANSFER\_EVENT\_COMPLETE, it means that the data was transferred successfully.

If the event is DRV\_I2C\_TRANSFER\_EVENT\_ERROR, it means that the data was not transferred successfully.

The transferHandle parameter contains the transfer handle of the transfer that associated with the event. And transferHandle will be valid while the transfer request is in the queue and during callback, unless an error occurred. After callback returns, the driver will retire the transfer handle.

The context parameter contains the a handle to the client context, provided at the time the event handling function was registered using the DRV\_I2C\_TransferEventHandlerSet function. This context handle value is passed back to the client as the "context" parameter. It can be any value necessary to identify the client context or instance \(such as a pointer to the client's data\) instance of the client that made the buffer add request.

The event handler function executes in the peripheral's interrupt context. It is recommended of the application to not perform process intensive or blocking operations with in this function.

The DRV\_I2C\_ReadTransferAdd, DRV\_I2C\_WriteTransferAdd and DRV\_I2C\_WriteReadTransferAdd functions can be called in the event handler to add a buffer to the driver queue. These functions can only be called to add buffers to the driver whose event handler is running. For example, I2C2 driver buffers cannot be added in I2C1 driver event handler.

