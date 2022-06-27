# DRV\_SPI\_TransferSetup Function

**Parent topic:**[Library Interface](GUID-2960D7B8-65FA-447F-AD81-B1E62002A04B.md)

## C

```c
bool DRV_SPI_TransferSetup ( DRV_HANDLE handle, DRV_SPI_TRANSFER_SETUP * setup )
```

## Summary

Sets the dynamic configuration of the driver including chip select pin.

## Description

This function is used to update any of the DRV\_SPI\_TRANSFER\_SETUP<br />parameters for the selected client of the driver dynamically. For single<br />client scenario, if GPIO has to be used for chip select, then calling this<br />API with appropriate GPIO pin information becomes mandatory. For multi<br />client scenario where different clients need different setup like baud rate,<br />clock settings, chip select etc, then also calling this API is mandatory.

Note that all the elements of setup structure must be filled appropriately<br />before using this API.

## Preconditions

DRV\_SPI\_Open must have been called to obtain a valid opened device handle.

## Parameters

|Param|Description|
|-----|-----------|
|handle|A valid open-instance handle, returned from the driver's open routine|
|\*setup|A structure containing the new configuration settings|

## Returns

None.

## Example

```c
// mySPIHandle is the handle returned by the DRV_SPI_Open function.
DRV_SPI_TRANSFER_SETUP setup;

setup.baudRateInHz = 10000000;
setup.clockPhase = DRV_SPI_CLOCK_PHASE_TRAILING_EDGE;
setup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
setup.dataBits = DRV_SPI_DATA_BITS_16;
setup.chipSelect = SYS_PORT_PIN_PC5;
setup.csPolarity = DRV_SPI_CS_POLARITY_ACTIVE_LOW;

DRV_SPI_TransferSetup ( mySPIHandle, &setup );
```

## Remarks

None.

