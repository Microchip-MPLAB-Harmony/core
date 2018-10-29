<#list 0..(GEN_APP_TASK_COUNT - 1) as i>
    <#assign GEN_APP_TASK_NAME = "GEN_APP_TASK_NAME_" + i>
    <#assign GEN_APP_RTOS_TASK_SIZE = "GEN_APP_RTOS_TASK_" + i + "_SIZE">
    <#assign GEN_APP_RTOS_TASK_PRIO = "GEN_APP_RTOS_TASK_" + i + "_PRIO">
    <#if SELECT_RTOS == "FreeRTOS">
    <#lt>    /* Create OS Thread for ${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks. */
    <#lt>    xTaskCreate((TaskFunction_t) _${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks,
    <#lt>                "${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks",
    <#lt>                ${.vars[GEN_APP_RTOS_TASK_SIZE]},
    <#lt>                NULL,
    <#lt>                ${.vars[GEN_APP_RTOS_TASK_PRIO]},
    <#lt>                &x${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks);

    </#if>
</#list>