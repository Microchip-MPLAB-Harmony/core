// <editor-fold defaultstate="collapsed" desc="SYS_TIME Initialization Data">

const TIME_PLIB_API sysTimePlibAPI = {
    .timerCallbackSet = (TIME_CallbackSet)${.vars["${SYS_TIME_PLIB?lower_case}"].CALLBACK_API_NAME},
    .timerCounterGet = (TIME_CounterGet)${.vars["${SYS_TIME_PLIB?lower_case}"].COUNTER_GET_API_NAME},
    <#if .vars["${SYS_TIME_PLIB?lower_case}"].PERIOD_SET_API_NAME?has_content>
     .timerPeriodSet = (TIME_PeriodSet)${.vars["${SYS_TIME_PLIB?lower_case}"].PERIOD_SET_API_NAME},
    </#if>
    .timerFrequencyGet = (TIME_FrequencyGet)${.vars["${SYS_TIME_PLIB?lower_case}"].FREQUENCY_GET_API_NAME},
    .timerCompareSet = (TIME_CompareSet)${.vars["${SYS_TIME_PLIB?lower_case}"].COMPARE_SET_API_NAME},
    .timerStart = (TIME_Start)${.vars["${SYS_TIME_PLIB?lower_case}"].TIMER_START_API_NAME},
    .timerStop = (TIME_Stop)${.vars["${SYS_TIME_PLIB?lower_case}"].TIMER_STOP_API_NAME}
};

const SYS_TIME_INIT sysTimeInitData =
{
    .timePlib = &sysTimePlibAPI,
    .hwTimerIntNum = ${.vars["${SYS_TIME_PLIB?lower_case}"].IRQ_ENUM_NAME},
};

// </editor-fold>