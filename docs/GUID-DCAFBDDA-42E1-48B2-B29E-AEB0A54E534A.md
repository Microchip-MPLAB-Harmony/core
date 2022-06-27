# OSAL\_MUTEX\_Lock Function

**Parent topic:**[Library Interface](GUID-2729150D-D502-4BC4-BB41-653718EF531C.md)

## C

```c
OSAL_RESULT OSAL_MUTEX_Lock(OSAL_MUTEX_HANDLE_TYPE* mutexID, uint16_t waitMS)
```

## Summary

Locks a mutex.

## Description

This function locks a mutex, waiting for the specified time-out. If it cannot<br />be obtained or the time-out period elapses 'false' is returned.

## Precondition

Mutex must have been created.

## Parameters

|Param|Description|
|-----|-----------|
|mutexID|Pointer to the mutex handle|
|waitMS|Time-out value in milliseconds: 0 - do not wait return immediately, OSAL\_WAIT\_FOREVER - wait until mutex is obtained before returning, Other values - time-out delay|

## Returns

*OSAL\_RESULT\_TRUE* - Mutex successfully obtained

*OSAL\_RESULT\_FALSE* - Mutex failed to be obtained or time-out occurred

## Example

```c
...
if (OSAL_MUTEX_Lock(&mutexData, 1000) == OSAL_RESULT_TRUE)
{
    // manipulate the shared data
    ...
    
    // unlock the mutex
    OSAL_MUTEX_Unlock(&mutexData);
}
```

## Remarks

None.

