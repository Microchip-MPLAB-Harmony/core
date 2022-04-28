/* TIME System Service Configuration Options */
#define SYS_TIME_INDEX_0                            (0)
#define SYS_TIME_MAX_TIMERS                         (${SYS_TIME_MAX_TIMERS?string})
#define SYS_TIME_HW_COUNTER_WIDTH                   (${.vars["${SYS_TIME_PLIB?lower_case}"].TIMER_WIDTH})
<#if SYS_TIME_OPERATING_MODE == "TICKLESS">
#define SYS_TIME_HW_COUNTER_PERIOD                  (${.vars["${SYS_TIME_PLIB?lower_case}"].TIMER_PERIOD_MAX}U)
#define SYS_TIME_HW_COUNTER_HALF_PERIOD             (SYS_TIME_HW_COUNTER_PERIOD>>1)
#define SYS_TIME_CPU_CLOCK_FREQUENCY                (${core.CPU_CLOCK_FREQUENCY})
<#if core.CoreArchitecture == "CORTEX-M7">
    <#lt>#define SYS_TIME_COMPARE_UPDATE_EXECUTION_CYCLES    (900)
</#if>
<#if core.CoreArchitecture == "CORTEX-M0PLUS">
    <#lt>#define SYS_TIME_COMPARE_UPDATE_EXECUTION_CYCLES    (200)
</#if>
<#if core.CoreArchitecture == "CORTEX-M23">
    <#lt>#define SYS_TIME_COMPARE_UPDATE_EXECUTION_CYCLES    (160)
</#if>
<#if core.CoreArchitecture == "CORTEX-A5">
    <#lt>#define SYS_TIME_COMPARE_UPDATE_EXECUTION_CYCLES    (2200)
</#if>
<#if core.CoreArchitecture == "CORTEX-M4">
    <#lt>#define SYS_TIME_COMPARE_UPDATE_EXECUTION_CYCLES    (188)
</#if>
<#if core.PRODUCT_FAMILY?contains("PIC32MZ") || core.PRODUCT_FAMILY?contains("PIC32MK") >
    <#lt>#define SYS_TIME_COMPARE_UPDATE_EXECUTION_CYCLES    (620)
</#if>
<#if core.PRODUCT_FAMILY?contains("PIC32MX") || core.PRODUCT_FAMILY?contains("PIC32MM")>
    <#lt>#define SYS_TIME_COMPARE_UPDATE_EXECUTION_CYCLES    (460)
</#if>
<#if core.CoreArchitecture?matches("ARM926.*")>
    <#lt>#define SYS_TIME_COMPARE_UPDATE_EXECUTION_CYCLES    (470)
</#if>
<#if core.CoreArchitecture == "CORTEX-A7">
    <#lt>#define SYS_TIME_COMPARE_UPDATE_EXECUTION_CYCLES    (936)
</#if>
<#else>
<#assign SYS_TICK_FREQ = (SYS_TIME_ACHIEVABLE_TICK_RATE_HZ/100000)>
#define SYS_TIME_TICK_FREQ_IN_HZ                    (${SYS_TICK_FREQ?string["0.#####"]})
</#if>
