<#if HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>void _DRV_SDCARD_Tasks( void *pvParameters )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_SDCARD_Tasks(sysObj.drvSDCard${INDEX?string});
             <#if DRV_SDCARD_RTOS_USE_DELAY == true>
    <#lt>        vTaskDelay(DRV_SDCARD_RTOS_DELAY_IDX${INDEX?string} / portTICK_PERIOD_MS);
             </#if>
    <#lt>    }
    <#lt>}
</#if>