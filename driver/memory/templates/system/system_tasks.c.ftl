<#if Harmony.SELECT_RTOS == "BareMetal">
    <#lt>    DRV_MEMORY_Tasks(sysObj.drvMemory${INDEX?string});
<#elseif Harmony.SELECT_RTOS == "FreeRTOS">
    <#lt>    xTaskCreate( _DRV_MEMORY_${INDEX?string}_Tasks,
    <#lt>        "DRV_MEM_${INDEX?string}_TASKS",
    <#lt>        DRV_MEMORY_STACK_SIZE_IDX${INDEX?string},
    <#lt>        (void*)NULL,
    <#lt>        DRV_MEMORY_PRIORITY_IDX${INDEX?string},
    <#lt>        (TaskHandle_t*)NULL
    <#lt>    );
</#if>