<#if HarmonyCore.SELECT_RTOS == "BareMetal">
    <#lt>DRV_SDSPI_Tasks(sysObj.drvSDSPI${INDEX?string});
<#elseif HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>    xTaskCreate( _DRV_SDSPI_${INDEX?string}_Tasks,
    <#lt>        "DRV_SD_${INDEX?string}_TASKS",
    <#lt>        DRV_SDSPI_STACK_SIZE_IDX${INDEX?string},
    <#lt>        (void*)NULL,
    <#lt>        DRV_SDSPI_PRIORITY_IDX${INDEX?string},
    <#lt>        (TaskHandle_t*)NULL
    <#lt>    );
</#if>
