<#list 0..(GEN_APP_TASK_COUNT - 1) as i>
    <#assign GEN_APP_TASK_NAME = "GEN_APP_TASK_NAME_" + i>
    <#assign GEN_APP_RTOS_TASK_USE_DELAY = "GEN_APP_RTOS_TASK_" + i + "_USE_DELAY">
    <#assign GEN_APP_RTOS_TASK_DELAY = "GEN_APP_RTOS_TASK_" + i + "_DELAY">
    <#if SELECT_RTOS == "FreeRTOS">
        <#lt>/* Handle for the ${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks. */
        <#lt>TaskHandle_t x${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks;

        <#lt>void _${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks(  void *pvParameters  )
        <#lt>{
        <#lt>    while(1)
        <#lt>    {
        <#lt>        ${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks();
        <#if .vars[GEN_APP_RTOS_TASK_USE_DELAY] == true>
        <#lt>        vTaskDelay(${.vars[GEN_APP_RTOS_TASK_DELAY]} / portTICK_PERIOD_MS);
        </#if>
        <#lt>    }
        <#lt>}
    </#if>
</#list>