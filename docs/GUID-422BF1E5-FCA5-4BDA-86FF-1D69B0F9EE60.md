# DRV\_MEMORY\_AsyncRead Function

**Parent topic:**[Library Interface](GUID-E18B0923-4286-4E08-A2EB-9A482E0063AE.md)

## C

```c
void DRV_MEMORY_AsyncRead
(
    const DRV_HANDLE handle,
    DRV_MEMORY_COMMAND_HANDLE *commandHandle,
    void *targetBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);
```

## Summary

Reads data for the specified number of memory blocks in Asynchronous mode.

## Description

This function schedules a non-blocking read operation for reading blocks of<br />data from the memory device attached.

The function returns with a valid command handle in the commandHandle argument<br />if the request was scheduled successfully.

The function adds the request to the hardware instance queue and returns<br />immediately. While the request is in the queue, the application<br />buffer is owned by the driver and should not be modified.

The function returns DRV\_MEMORY\_COMMAND\_HANDLE\_INVALID in the commandHandle argument<br />under the following circumstances:

-   if a buffer object could not be allocated to the request

-   if the target buffer pointer is NULL

-   if the client opened the driver for write only

-   if the number of blocks to be read is either zero or more than the number of blocks actually available

-   if the driver handle is invalid


## Precondition

DRV\_MEMORY\_Open\(\) must have been called with DRV\_IO\_INTENT\_READ or DRV\_IO\_INTENT\_READWRITE as the ioIntent to obtain a valid opened device handle.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open function|
|commandHandle|Pointer to an argument that will contain the command handle|
|targetBuffer|Buffer into which the data read from the media device memory will be placed|
|blockStart|Block start from where the data should be read.|
|nBlock|Total number of blocks to be read.|

## Returns

The command handle is returned in the commandHandle argument. It will be DRV\_MEMORY\_COMMAND\_HANDLE\_INVALID if the request was not successful.

## Example

```c
uint8_t readBuffer[BUFFER_SIZE];

// Use DRV_MEMORY_GeometryGet () to find the read region geometry.
// Find the block address from which to read data.
uint32_t blockStart = 0x0;
uint32_t nBlock = BUFFER_SIZE;
DRV_MEMORY_COMMAND_HANDLE commandHandle;
bool xfer_done = false;

// memoryHandle is the handle returned by the DRV_MEMORY_Open function.

// Event is received when the read request is completed.
void appTransferHandler
(
    DRV_MEMORY_EVENT event,
    DRV_MEMORY_COMMAND_HANDLE commandHandle,
    uintptr_t context
)
{
    switch(event)
    {
        case DRV_MEMORY_EVENT_COMMAND_COMPLETE:
        {
            xfer_done = true;
            break;
        }

        case DRV_MEMORY_EVENT_COMMAND_ERROR:
        {
            // Handle Error
            break;
        }

        default:
        {
            break;
        }
    }
}

DRV_MEMORY_TransferHandlerSet(memoryHandle, appTransferHandler, (uintptr_t)NULL);

DRV_MEMORY_AsyncRead(memoryHandle, &commandHandle, &readBuffer, blockStart, nBlock);

if(DRV_MEMORY_COMMAND_HANDLE_INVALID == commandHandle)
{
    // Error handling here
}

while(!xfer_done);

```

## Remarks

This API is supported in Both Bare-Metal and RTOS environment.

