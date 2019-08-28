// <editor-fold defaultstate="collapsed" desc="SYS_TIME Initialization Data">

const SYS_TIME_PLIB_INTERFACE sysTimePlibAPI = {
    .timerCallbackSet = (SYS_TIME_PLIB_CALLBACK_REGISTER)${.vars["${SYS_TIME_PLIB?lower_case}"].CALLBACK_API_NAME},
    .timerCounterGet = (SYS_TIME_PLIB_COUNTER_GET)${.vars["${SYS_TIME_PLIB?lower_case}"].COUNTER_GET_API_NAME},
    <#if .vars["${SYS_TIME_PLIB?lower_case}"].PERIOD_SET_API_NAME?has_content>
    .timerPeriodSet = (SYS_TIME_PLIB_PERIOD_SET)${.vars["${SYS_TIME_PLIB?lower_case}"].PERIOD_SET_API_NAME},
    </#if>
    .timerFrequencyGet = (SYS_TIME_PLIB_FREQUENCY_GET)${.vars["${SYS_TIME_PLIB?lower_case}"].FREQUENCY_GET_API_NAME},
    .timerCompareSet = (SYS_TIME_PLIB_COMPARE_SET)${.vars["${SYS_TIME_PLIB?lower_case}"].COMPARE_SET_API_NAME},
    .timerStart = (SYS_TIME_PLIB_START)${.vars["${SYS_TIME_PLIB?lower_case}"].TIMER_START_API_NAME},
    .timerStop = (SYS_TIME_PLIB_STOP)${.vars["${SYS_TIME_PLIB?lower_case}"].TIMER_STOP_API_NAME}
};

const SYS_TIME_INIT sysTimeInitData =
{
    .timePlib = &sysTimePlibAPI,
    .hwTimerIntNum = ${.vars["${SYS_TIME_PLIB?lower_case}"].IRQ_ENUM_NAME},
};

// </editor-fold>