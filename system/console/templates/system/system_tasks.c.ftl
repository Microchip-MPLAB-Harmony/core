<#if SYS_COMMAND_ENABLE == true>
    <#if HarmonyCore.SELECT_RTOS == "BareMetal">
        <#lt>SYS_CMD_Tasks();
    <#elseif HarmonyCore.SELECT_RTOS == "FreeRTOS">
        <#lt>    xTaskCreate( _SYS_CMD_Tasks,
        <#lt>        "SYS_CMD_TASKS",
        <#lt>        SYS_CMD_RTOS_STACK_SIZE,
        <#lt>        (void*)NULL,
        <#lt>        SYS_CMD_RTOS_TASK_PRIORITY,
        <#lt>        (TaskHandle_t*)NULL
        <#lt>    );
    </#if>
</#if>
