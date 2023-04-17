// <editor-fold defaultstate="collapsed" desc="SYS_TIME Initialization Data">

/* MISRA C-2012 Rule 11.1 deviated:2 Deviation record ID -  H3_MISRAC_2012_R_11_1_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:2 "MISRA C-2012 Rule 11.1" "H3_MISRAC_2012_R_11_1_DR_1"    
</#if>

static const SYS_TIME_PLIB_INTERFACE sysTimePlibAPI = {
    .timerCallbackSet = (SYS_TIME_PLIB_CALLBACK_REGISTER)${.vars["${SYS_TIME_PLIB?lower_case}"].CALLBACK_API_NAME},
    .timerStart = (SYS_TIME_PLIB_START)${.vars["${SYS_TIME_PLIB?lower_case}"].TIMER_START_API_NAME},
    .timerStop = (SYS_TIME_PLIB_STOP)${.vars["${SYS_TIME_PLIB?lower_case}"].TIMER_STOP_API_NAME},
    .timerFrequencyGet = (SYS_TIME_PLIB_FREQUENCY_GET)${.vars["${SYS_TIME_PLIB?lower_case}"].FREQUENCY_GET_API_NAME},
    <#if SYS_TIME_USE_SYSTICK == true>
    .timerInterruptRestore = (SYS_TIME_PLIB_INTERRUPT_RESTORE)${.vars["${SYS_TIME_PLIB?lower_case}"].INTERRUPT_RESTORE_API_NAME},
    .timerInterruptDisable = (SYS_TIME_PLIB_INTERRUPT_DISABLE)${.vars["${SYS_TIME_PLIB?lower_case}"].INTERRUPT_DISABLE_API_NAME},
    </#if>
    <#if .vars["${SYS_TIME_PLIB?lower_case}"].PERIOD_SET_API_NAME?has_content>
    .timerPeriodSet = (SYS_TIME_PLIB_PERIOD_SET)${.vars["${SYS_TIME_PLIB?lower_case}"].PERIOD_SET_API_NAME},
    <#else>
    .timerPeriodSet = (SYS_TIME_PLIB_PERIOD_SET)NULL,
    </#if>
    <#if SYS_TIME_OPERATING_MODE == "TICKLESS">
    .timerCompareSet = (SYS_TIME_PLIB_COMPARE_SET)${.vars["${SYS_TIME_PLIB?lower_case}"].COMPARE_SET_API_NAME},
    .timerCounterGet = (SYS_TIME_PLIB_COUNTER_GET)${.vars["${SYS_TIME_PLIB?lower_case}"].COUNTER_GET_API_NAME},
    </#if>
};

static const SYS_TIME_INIT sysTimeInitData =
{
    .timePlib = &sysTimePlibAPI,
    .hwTimerIntNum = ${.vars["${SYS_TIME_PLIB?lower_case}"].IRQ_ENUM_NAME},
};

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.1"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>    
</#if>
/* MISRAC 2012 deviation block end */
// </editor-fold>