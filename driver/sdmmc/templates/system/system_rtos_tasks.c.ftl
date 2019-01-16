<#if HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>void _DRV_SDMMC${INDEX?string}_Tasks(  void *pvParameters  )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_SDMMC_Tasks(sysObj.drvSDMMC${INDEX?string});
             <#if DRV_SDMMC_RTOS_USE_DELAY >
    <#lt>        vTaskDelay(DRV_SDMMC_RTOS_DELAY_IDX${INDEX?string} / portTICK_PERIOD_MS);
             </#if>
    <#lt>    }
    <#lt>}
</#if>