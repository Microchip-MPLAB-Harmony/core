<#if HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>void _DRV_SDSPI_${INDEX?string}_Tasks(  void *pvParameters  )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_SDSPI_Tasks(sysObj.drvSDSPI${INDEX?string});
             <#if DRV_SDSPI_RTOS_USE_DELAY >
    <#lt>        vTaskDelay(${DRV_SDSPI_RTOS_DELAY} / portTICK_PERIOD_MS);
             </#if>
    <#lt>    }
    <#lt>}
</#if>
