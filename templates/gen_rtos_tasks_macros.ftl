<#list 0..(GEN_APP_TASK_COUNT - 1) as i>
    <#assign GEN_APP_TASK_NAME = "GEN_APP_TASK_NAME_" + i>
    <#assign GEN_APP_RTOS_TASK_SIZE_BYTES = "GEN_APP_RTOS_TASK_" + i + "_SIZE">
    <#assign GEN_APP_RTOS_TASK_PRIO = "GEN_APP_RTOS_TASK_" + i + "_PRIO">
    <#assign GEN_APP_TASK_ENABLE = "GEN_APP_TASK_ENABLE_" + i>
    <#if SELECT_RTOS == "FreeRTOS" && .vars[GEN_APP_TASK_ENABLE] == true>
    <#lt>    /* Create OS Thread for ${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks. */
    <#lt>    (void) xTaskCreate((TaskFunction_t) l${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks,
    <#lt>                "${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks",
    <#lt>                ${.vars[GEN_APP_RTOS_TASK_SIZE_BYTES] / 4},
    <#lt>                NULL,
    <#lt>                ${.vars[GEN_APP_RTOS_TASK_PRIO]},
    <#lt>                &x${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks);

    </#if>
</#list>