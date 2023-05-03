<#list 0..(GEN_APP_TASK_COUNT - 1) as i>
    <#assign GEN_APP_TASK_NAME = "GEN_APP_TASK_NAME_" + i>
    <#assign GEN_APP_TASK_ENABLE = "GEN_APP_TASK_ENABLE_" + i>
    <#if SELECT_RTOS == "FreeRTOS" && .vars[GEN_APP_TASK_ENABLE] == true>
        <#lt>/* Declaration of  ${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks task handle */
        <#lt>extern TaskHandle_t x${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks;

    </#if>
</#list>