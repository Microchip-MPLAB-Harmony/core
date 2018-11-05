<#if SYS_COMMAND_ENABLE == true>
    <#if HarmonyCore.SELECT_RTOS == "FreeRTOS">
        <#lt>void _SYS_CMD_Tasks(  void *pvParameters  )
        <#lt>{
        <#lt>    while(1)
        <#lt>    {
        <#lt>        SYS_CMD_Tasks();
                 <#if SYS_COMMAND_RTOS_USE_DELAY >
        <#lt>        vTaskDelay(${SYS_COMMAND_RTOS_DELAY} / portTICK_PERIOD_MS);
                 </#if>
        <#lt>    }
        <#lt>}
    </#if>
</#if>