# SYS\_TIME\_DelayUS Function

**Parent topic:**[Library Interface](GUID-3D84F884-122D-4A4A-95DA-DFD8C2E84650.md)

## C

```c
SYS_TIME_RESULT SYS_TIME_DelayUS ( uint32_t us, SYS_TIME_HANDLE* handle )
```

## Summary

This function is used to generate a delay of a given number of microseconds.

## Description

The function will internally create a single shot timer which will be auto<br />deleted when the application calls SYS\_TIME\_DelayIsComplete routine and<br />the delay has expired. The function will return immediately, requiring the<br />caller to use SYS\_TIME\_DelayIsComplete routine to check the delay timer's<br />status.

## Precondition

The SYS\_TIME\_Initialize function must have been called before calling this function.

## Parameters

|Param|Description|
|-----|-----------|
|us|The desired number of microseconds to delay.|
|handle|Address of the variable to receive the timer handle value.|

## Returns

*SYS\_TIME\_SUCCESS* - If the call succeeded.

*SYS\_TIME\_ERROR* - If the call failed, either because the requested delay is<br />zero, or the passed handle is invalid or there is not enough room to queue in the request in the SYS Time's internal queue.

## Example

```c
SYS_TIME_HANDLE timer = SYS_TIME_HANDLE_INVALID;

if (SYS_TIME_DelayUS(50, &timer) != SYS_TIME_SUCCESS)
{
    // Handle error
}
else if (SYS_TIME_DelayIsComplete(timer) != true)
{
    // Wait till the delay has not expired
    while (SYS_TIME_DelayIsComplete(timer) == false);
}
```

## Remarks

Will delay the requested number of microseconds or longer depending on system performance. In tick-based mode, the requested delay will be ceiled to the next timer tick.

For example, if the timer tick is set to 1 msec and the requested delay is 1500 usec, a delay of 2 msec will be generated.

Delay values of 0 will return SYS\_TIME\_ERROR.

Will return SYS\_TIME\_ERROR if timer handle pointer is NULL.

