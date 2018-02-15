// <editor-fold defaultstate="collapsed" desc="SYS_TIME Initialization Data">

TIME_PLIB_API sysTimePlibAPI = {
    .timerCallbackSet = (TIME_CallbackSet)${SYS_TIME_PLIB}_TimerCallbackRegister,
    .timerCounterGet = (TIME_CounterGet)${SYS_TIME_PLIB}_TimerCounterGet,
    .timerPeriodSet = (TIME_PeriodSet)${SYS_TIME_PLIB}_TimerPeriodSet,
    .timerStart = (TIME_Start)${SYS_TIME_PLIB}_TimerStart,
    .timerStop = (TIME_Stop)${SYS_TIME_PLIB}_TimerStop
};

SYS_TIME_INIT sysTimeInitData =
{
    .timePlib = &sysTimePlibAPI,
    .timeInterrupt = ${SYS_TIME_PLIB}_IRQn,
    .timeFrequency = ${SYS_TIME_PLIB}_TimerFrequencyGet(),
    .timeUnitResolution = SYS_TIME_RESOLUTION
};

// </editor-fold>