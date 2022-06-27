# DRV\_USART\_ReadAbort Function

**Parent topic:**[Library Interface](GUID-80FC4C27-64D2-411F-BE4A-4C4A8BD80604.md)

## C

```c
bool DRV_USART_ReadAbort(const DRV_HANDLE handle)
```

## Summary

Aborts an on-going read request

## Description

This function aborts an on-going read transfer. No callback is given for<br />the on-going request being aborted. When USART is configured for non-dma<br />transfers, application may call the DRV\_USART\_BufferCompletedBytesGet\(\)<br />API \(before calling the DRV\_USART\_ReadAbort API\)to find out how many bytes<br />have been received for the on-going read request.

## Precondition

DRV\_USART\_Open must have been called to obtain a valid opened device handle.

## Parameters

|Param|Description|
|-----|-----------|
|handle|Handle of the communication channel as return by the DRV\_USART\_Open function.|

## Returns

*true* - operation was successful

*false* - error in running the API

## Example

```c
// myUSARTHandle is the handle returned
// by the DRV_USART_Open function.

// For non-DMA based transfers DRV_USART_BufferCompletedBytesGet() can be
// called to find out the number of bytes received before aborting the
// request.

uint32_t processedBytes;

processedBytes= DRV_USART_BufferCompletedBytesGet(bufferHandle);

DRV_USART_ReadAbort(myUSARTHandle);
```

## Remarks

This function is thread safe in a RTOS application. Calling this function does not have any impact on the read/write requests that may be pending in the transfer queue. To purge the read/write request queues call the DRV\_USART\_ReadQueuePurge\(\) and DRV\_USART\_WriteQueuePurge\(\) APIs.

