# EMU\_EEPROM\_PageBufferCommit Function

**Parent topic:**[Library Interface](GUID-000B6F77-4664-4A72-9723-F697040A7436.md)

## C

```c
EMU_EEPROM_STATUS EMU_EEPROM_PageBufferCommit(void)
```

## Summary

Commits any cached data to physical non-volatile memory

## Description

Commits the internal SRAM caches to physical non-volatile memory, to ensure<br />that any outstanding cached data is preserved. This function should be called<br />prior to a system reset or shutdown to prevent data loss.

## Precondition

Function EMU\_EEPROM\_Initialize should have been called before calling this function.

## Parameters

None

## Returns

*EMU\_EEPROM\_STATUS* - Enum of type EMU\_EEPROM\_STATUS. Status code indicating<br />the status of the operation.

## Example

```c
EMU_EEPROM_PageBufferCommit();
```

## Remarks

None

