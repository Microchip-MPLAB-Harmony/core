# DRV\_I2C\_TransferSetup Function

**Parent topic:**[Library Interface](GUID-5A5146D2-73C2-43B1-8ADE-95E0184AF1A5.md)

## C

```c
bool DRV_I2C_TransferSetup ( DRV_HANDLE handle, DRV_I2C_TRANSFER_SETUP* setup )
```

## Summary

Sets the dynamic transfer setup of the driver.

## Description

This function should be used to update any of the DRV\_I2C\_TRANSFER\_SETUP<br />parameters for the selected client of the driver dynamically. It is mainly<br />helpful for multi client scenario where different clients need different<br />setup like clock speed. The DRV\_I2C\_TransferSetup function must be called<br />before submitting any I2C driver read/write requests.

## Preconditions

DRV\_I2C\_Open must have been called to obtain a valid opened device handle.

In case of asynchronous driver, all transfer requests from the queue must have been processed.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open routine|
|setup|Pointer to the structure containing the new configuration settings|

## Returns

None.

## Example

```c
// myI2CHandle is the handle returned by the DRV_I2C_Open function.
DRV_I2C_TRANSFER_SETUP setup;

setup.clockSpeed = 400000;

DRV_I2C_TransferSetup ( myI2CHandle, &setup );
```

## Remarks

None.

