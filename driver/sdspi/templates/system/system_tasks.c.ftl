<#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "BareMetal">
    <#lt>DRV_SDSPI_Tasks(sysObj.drvSDSPI${INDEX?string});
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>    xTaskCreate( _DRV_SDSPI_${INDEX?string}_Tasks,
    <#lt>        "DRV_SD_${INDEX?string}_TASKS",
    <#lt>        DRV_SDSPI_STACK_SIZE_IDX${INDEX?string},
    <#lt>        (void*)NULL,
    <#lt>        DRV_SDSPI_PRIORITY_IDX${INDEX?string},
    <#lt>        (TaskHandle_t*)NULL
    <#lt>    );
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>    tx_byte_allocate(&byte_pool_0,
    <#lt>       (VOID **) &_DRV_SDSPI_${INDEX?string}_Task_Stk_Ptr,
    <#lt>        DRV_SDSPI_STACK_SIZE_IDX${INDEX?string},
    <#lt>        TX_NO_WAIT
    <#lt>    );

    <#lt>    tx_thread_create(&_DRV_SDSPI_${INDEX?string}_Task_TCB,
    <#lt>        "DRV_SDSPI${INDEX?string}_TASKS",
    <#lt>        _DRV_SDSPI_${INDEX?string}_Tasks,
    <#lt>        ${INDEX?string},
    <#lt>        _DRV_SDSPI_${INDEX?string}_Task_Stk_Ptr,
    <#lt>        DRV_SDSPI_STACK_SIZE_IDX${INDEX?string},
    <#lt>        DRV_SDSPI_PRIORITY_IDX${INDEX?string},
    <#lt>        DRV_SDSPI_PRIORITY_IDX${INDEX?string},
    <#lt>        TX_NO_TIME_SLICE,
    <#lt>        TX_AUTO_START
    <#lt>    );
</#if>
