<#if Harmony.SELECT_RTOS == "FreeRTOS">
    <#lt>void _DRV_MEMORY_${INDEX?string}_Tasks(  void *pvParameters  )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_MEMORY_Tasks(sysObj.drvMemory${INDEX?string});
             <#if DRV_MEMORY_RTOS_USE_DELAY >
    <#lt>        vTaskDelay(${DRV_MEMORY_RTOS_DELAY} / portTICK_PERIOD_MS);
             </#if>
    <#lt>    }
    <#lt>}
</#if>