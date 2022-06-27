# DRV\_SDSPI\_AsyncRead Function

**Parent topic:**[Library Interface](GUID-7A1B4F41-7CC6-49CF-941E-25265059D247.md)

## C

```c
void DRV_SDSPI_AsyncRead (
    const DRV_HANDLE handle,
    DRV_SDSPI_COMMAND_HANDLE* commandHandle,
    void* targetBuffer,
    uint32_t blockStart,
    uint32_t nBlocks
)
```

## Summary

Reads blocks of data from the specified block address of the SD Card.

## Description

This function schedules a non-blocking read operation for reading blocks<br />of data from the SD Card. The function returns with a valid buffer handle<br />in the commandHandle argument if the read request was scheduled successfully.<br />The function adds the request to the hardware instance queue and returns<br />immediately. While the request is in the queue, the application buffer is<br />owned by the driver and should not be modified. The function returns<br />DRV\_SDSPI\_COMMAND\_HANDLE\_INVALID in the commandHandle argument under the<br />following circumstances:

-   if the driver handle is invalid

-   if the target buffer pointer is NULL

-   if the number of blocks to be read is zero or more than the actual number of blocks available.

-   Error during the read operation


## Precondition

The DRV\_SDSPI\_Initialize routine must have been called for the specified SDSPI driver instance.

DRV\_SDSPI\_Open must have been called to obtain a valid opened device handle.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open function|
|commandHandle|Pointer to an argument that will contain the return buffer handle|
|targetBuffer|Buffer into which the data read from the SD Card will be placed|
|blockStart|Starting block address of the SD Card from where the read should begin.|
|nBlock|Total number of blocks to be read.|

## Returns

The buffer handle is returned in the commandHandle argument. It will be DRV\_SDSPI\_COMMAND\_HANDLE\_INVALID if the request was not successful.

## Example

```c
uint8_t CACHE_ALIGN myBuffer[MY_BUFFER_SIZE];

// address should be block aligned.
uint32_t blockStart = 0x00;
uint32_t nBlock = 2;
DRV_SDSPI_COMMAND_HANDLE commandHandle;
MY_APP_OBJ myAppObj;

// Event is received when
// the buffer is processed.

void APP_SDSPIEventHandler(
    DRV_SDSPI_EVENT event,
    DRV_SDSPI_COMMAND_HANDLE commandHandle,
    uintptr_t contextHandle
)
{
    // contextHandle points to myAppObj.
    
    switch(event)
    {
        case DRV_SDSPI_EVENT_COMMAND_COMPLETE:
        {
            // This means the data was transferred successfully
            break;
        }
        
        case DRV_SDSPI_EVENT_COMMAND_ERROR:
        {
            // Error handling here
            break;
        }
        
        default:
        {
            break;
        }
    }
}

// mySDSPIHandle is the handle returned
// by the DRV_SDSPI_Open function.

// Client registers an event handler with driver
DRV_SDSPI_EventHandlerSet(mySDSPIHandle, APP_SDSPIEventHandler, (uintptr_t)&myAppObj);

DRV_SDSPI_AsyncRead(mySDSPIHandle, &commandHandle, &myBuffer[0], blockStart, nBlock);

if(commandHandle == DRV_SDMMC_COMMAND_HANDLE_INVALID)
{
    // Error handling here
}
else
{
    // Read Successfully queued
}
```

## Remarks

None.

