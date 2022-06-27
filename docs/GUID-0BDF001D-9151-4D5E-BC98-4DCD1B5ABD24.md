# OSAL\_RESULT Enum

**Parent topic:**[Library Interface](GUID-2729150D-D502-4BC4-BB41-653718EF531C.md)

## C

```c
typedef enum OSAL_RESULT
{
    OSAL_RESULT_NOT_IMPLEMENTED = -1,
    OSAL_RESULT_FALSE = 0,
    OSAL_RESULT_TRUE = 1
} OSAL_RESULT;
```

## Summary

Enumerated type representing the general return value from OSAL functions.

## Description

This enum represents possible return types from OSAL functions.

## Remarks

These enum values are the possible return values from OSAL functions where a standard success/fail type response is required. The majority of OSAL functions will return this type with a few exceptions.

