# DRV\_AT24\_Write Function

**Parent topic:**[Library Interface](GUID-354A36E3-7E0B-4DD0-8485-DDFD792B525C.md)

## C

```c
bool DRV_AT24_Write(const DRV_HANDLE handle, void *txData, uint32_t txDataLength, uint32_t address)
```

## Summary

Writes 'n' bytes of data starting at the specified address.

## Description

This function schedules a non-blocking write operation for writing<br />txDataLength bytes of data starting from given address of EEPROM.

The requesting client should call DRV\_AT24\_TransferStatusGet API to know<br />the current status of the request OR the requesting client can register a<br />callback function with the driver to get notified of the status.

## Preconditions

DRV\_AT24\_Open must have been called to obtain a valid opened device handle.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open routine|
|txData|The source buffer containing data to be programmed into AT24 EEPROM|
|txDataLength|Total number of bytes to be written.|
|address|Memory start address from where the data should be written|

## Returns

*true*

-   if the write request is accepted.


*false*

-   if handle is invalid

-   if the pointer to transmit buffer is NULL or number of bytes to write is 0

-   if the driver is busy handling another transfer request


## Example

```c
#define BUFFER_SIZE 1024
#define MEM_ADDRESS 0x00

uint8_t CACHE_ALIGN writeBuffer[BUFFER_SIZE];

// myHandle is the handle returned from DRV_AT24_Open API.
// In the below example, the transfer status is polled. However, application can
// register a callback and get notified when the transfer is complete.

if (DRV_AT24_Write(myHandle, writeBuffer, BUFFER_SIZE, MEM_ADDRESS) != true)
{
    // Error handling here
}
else
{
    // Wait for write to be completed
    while(DRV_AT24_TransferStatusGet(myHandle) == DRV_AT24_TRANSFER_STATUS_BUSY);
}
```

## Remarks

None.

