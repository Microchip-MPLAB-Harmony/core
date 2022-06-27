# I2C\_BB\_TransferSetup Function

**Parent topic:**[Library Interface](GUID-6CBA8AA0-7EF7-44B1-8D12-CD6A3067E53A.md)

## C

```c
bool I2C_BB_TransferSetup(I2CBB_TRANSFER_SETUP* setup, uint32_t tmrSrcClkFreq )
```

## Summary

Dynamic setup of I2C Bit Bang Library.

## Description

This API is generally used when there are multiple clients on the same I2C bus<br />having different I2C clock speed. In such a case, the I2C\_BB\_TransferSetup API<br />must be called to set the appropriate I2C bus speed before starting the I2C<br />transfer for the I2C slave.

## Precondition

I2C\_BB\_Initialize must have been called for the associated I2C instance. The transfer status should not be busy.

## Parameters

|Param|Description|
|-----|-----------|
|setup|Pointer to the structure containing the transfer setup.|
|tmrSrcClkFreq|Timer Peripheral Clock Source Frequency.|

## Returns

*true* - Transfer setup was updated Successfully.

*false* - Failure while updating transfer setup.

## Example

```c
I2C_TRANSFER_SETUP setup;

setup.clkSpeed = 400000;

// Make sure that the I2C is not busy before changing the I2C clock frequency
if (I2C_BB_IsBusy() == false)
{
    if (I2C_BB_TransferSetup( &setup, 0 ) == true)
    {
        // Transfer Setup updated successfully
    }
}
```

## Remarks

The timer period will be changed based on the new I2C clock speed, when an I2C request is submitted

