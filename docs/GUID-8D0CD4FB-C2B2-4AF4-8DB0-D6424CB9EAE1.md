# DRV\_MEMORY\_AsyncEraseWrite Function

**Parent topic:**[Library Interface](GUID-E18B0923-4286-4E08-A2EB-9A482E0063AE.md)

## C

```c
void DRV_MEMORY_AsyncEraseWrite
(
    const DRV_HANDLE handle,
    DRV_MEMORY_COMMAND_HANDLE * commandHandle,
    void * sourceBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);
```

## Summary

Erase and Write data for the specified number of memory blocks in Asynchronous mode.

## Description

This function combines the step of erasing a sector and then writing the<br />page. The application can use this function if it wants to avoid having to<br />explicitly delete a sector in order to update the pages contained in the<br />sector.

This function schedules a non-blocking operation to erase and write blocks<br />of data into attached device memory.

The function returns with a valid command handle in the commandHandle argument<br />if the write request was scheduled successfully. The function adds the request<br />to the hardware instance queue and returns immediately.

While the request is in the queue, the application buffer is owned by the driver<br />and should not be modified.

The function returns DRV\_MEMORY\_COMMAND\_HANDLE\_INVALID in the commandHandle<br />argument under the following circumstances:

-   if a buffer could not be allocated to the request

-   if the sourceBuffer pointer is NULL

-   if the client opened the driver for read only

-   if the number of blocks to be written is either zero or more than the number of blocks actually available

-   if the driver handle is invalid


If the requesting client registered an event callback with the driver, the<br />driver will issue a DRV\_MEMORY\_EVENT\_COMMAND\_COMPLETE event if the buffer<br />was processed successfully or DRV\_MEMORY\_EVENT\_COMMAND\_ERROR event if the<br />buffer was not processed successfully.

If the requesting client has not registered any transfer handler callback<br />with the driver, he can call DRV\_MEMORY\_CommandStatusGet\(\) API to know<br />the current status of the request.

## Precondition

The DRV\_MEMORY\_Open\(\) must have been called with DRV\_IO\_INTENT\_WRITE or DRV\_IO\_INTENT\_READWRITE as a parameter to obtain a valid opened device handle.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open function|
|commandHandle|Pointer to an argument that will contain the return command handle. If NULL, then command handle is not returned.|
|sourceBuffer|The source buffer containing data to be programmed into media device memory|
|blockStart|Write block start where the write should begin.|
|nBlock|Total number of blocks to be written.|

## Returns

The command handle is returned in the commandHandle argument. It Will be DRV\_MEMORY\_COMMAND\_HANDLE\_INVALID if the request was not queued.

## Example

```c
#define BUFFER_SIZE 4096
uint8_t buffer[BUFFER_SIZE];

// Use DRV_MEMORY_GeometryGet () to find the write region geometry.
uint32_t blockStart = 0x0;
uint32_t nBlock = BUFFER_SIZE / block_size; // block_size for write geometry
DRV_MEMORY_COMMAND_HANDLE commandHandle;

// memoryHandle is the handle returned by the DRV_MEMORY_Open function.
// Client registers an event handler with driver

// Event is received when the erase-write request is completed.
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

DRV_MEMORY_AsyncEraseWrite(memoryHandle, &commandHandle, &myBuffer, blockStart, nBlock);

if(DRV_MEMORY_COMMAND_HANDLE_INVALID == commandHandle)
{
    // Error handling here
}

// Wait for erase to be completed
while(!xfer_done);

```

## Remarks

This API is supported in Both Bare-Metal and RTOS environment.

