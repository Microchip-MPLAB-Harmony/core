<#list 0..(GEN_APP_TASK_COUNT - 1) as i>
    <#assign GEN_APP_TASK_NAME = "GEN_APP_TASK_NAME_" + i>
    <#assign GEN_APP_RTOS_TASK_USE_DELAY = "GEN_APP_RTOS_TASK_" + i + "_USE_DELAY">
    <#assign GEN_APP_RTOS_TASK_DELAY = "GEN_APP_RTOS_TASK_" + i + "_DELAY">
    <#assign GEN_APP_TASK_ENABLE = "GEN_APP_TASK_ENABLE_" + i>
    <#assign GEN_APP_RTOS_TASK_USE_FPU_CONTEXT = "GEN_APP_RTOS_TASK_" + i + "_OPT_USE_FPU_CONTEXT">
    <#if SELECT_RTOS == "FreeRTOS" && .vars[GEN_APP_TASK_ENABLE] == true>
        <#lt>/* Handle for the ${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks. */
        <#lt>static TaskHandle_t x${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks;

        <#lt>static void l${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks(  void *pvParameters  )
        <#lt>{   <#if .vars[GEN_APP_RTOS_TASK_USE_FPU_CONTEXT]?? && .vars[GEN_APP_RTOS_TASK_USE_FPU_CONTEXT] == true>
        <#lt>    portTASK_USES_FLOATING_POINT();
        <#lt>
        <#lt>    </#if>
        <#lt>    while(true)
        <#lt>    {
        <#lt>        ${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks();
        <#if .vars[GEN_APP_RTOS_TASK_USE_DELAY] == true>
        <#lt>        vTaskDelay(${.vars[GEN_APP_RTOS_TASK_DELAY]}U / portTICK_PERIOD_MS);
        </#if>
        <#lt>    }
        <#lt>}
    </#if>
</#list>