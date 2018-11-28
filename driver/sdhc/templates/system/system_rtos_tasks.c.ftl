<#if HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>void _DRV_SDHC_Tasks(  void *pvParameters  )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_SDHC_Tasks(sysObj.drvSDHC);
             <#if DRV_SDHC_RTOS_USE_DELAY >
    <#lt>        vTaskDelay(${DRV_SDHC_RTOS_DELAY} / portTICK_PERIOD_MS);
             </#if>
    <#lt>    }
    <#lt>}
</#if>