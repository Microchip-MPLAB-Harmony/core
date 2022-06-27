# DRV\_AT25DF\_PageWrite Function

**Parent topic:**[Library Interface](GUID-6D9FA3F1-00EF-4C4D-AC06-CF95F5137ACB.md)

## C

```c
bool DRV_AT25DF_PageWrite(const DRV_HANDLE handle, void *txData, uint32_t address)
```

## Summary

Writes one page of data starting at the specified address.

## Description

This function schedules a non-blocking write operation for writing<br />one page of data starting from the given address of the FLASH.

The requesting client should call DRV\_AT25DF\_TransferStatusGet API to know<br />the current status of the request OR the requesting client can register a<br />callback function with the driver to get notified of the status.

## Preconditions

DRV\_AT25DF\_Open must have been called to obtain a valid opened device handle. "address" provided must be page boundary aligned in order to avoid overwriting the data in the beginning of the page.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open routine|
|txData|The source buffer containing data to be written to the AT25DF FLASH|
|address|Write memory start address from where the data should be written. It must be page boundary aligned in order to avoid overwriting the data in the beginning of the page.|

## Returns

*true*

-   if the write request is accepted.


*false*

-   if handle is invalid

-   if the pointer to the transmit data is NULL

-   if the driver is busy handling another transfer request


## Example

```c
#define PAGE_SIZE 256
#define MEM_ADDRESS 0x0

uint8_t CACHE_ALIGN writeBuffer[PAGE_SIZE];

// myHandle is the handle returned from DRV_AT25DF_Open API.
// In the below example, the transfer status is polled. However, application can
// register a callback and get notified when the transfer is complete.

if (DRV_AT25DF_PageWrite(myHandle, writeBuffer, MEM_ADDRESS) != true)
{
    // Error handling here
}
else
{
    // Wait for write to be completed
    while(DRV_AT25DF_TransferStatusGet(myHandle) == DRV_AT25DF_TRANSFER_STATUS_BUSY);
}
```

## Remarks

None.

