<#if drv_memory.DRV_MEMORY_COMMON_MODE == "Asynchronous" >
    <#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "BareMetal">
        <#lt>DRV_MEMORY_Tasks(sysObj.drvMemory${INDEX?string});
    <#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
        <#lt>    xTaskCreate( _DRV_MEMORY_${INDEX?string}_Tasks,
        <#lt>        "DRV_MEM_${INDEX?string}_TASKS",
        <#lt>        DRV_MEMORY_STACK_SIZE_IDX${INDEX?string},
        <#lt>        (void*)NULL,
        <#lt>        DRV_MEMORY_PRIORITY_IDX${INDEX?string},
        <#lt>        (TaskHandle_t*)NULL
        <#lt>    );
    <#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
        <#lt>    tx_byte_allocate(&byte_pool_0,
        <#lt>       (VOID **) &_DRV_MEMORY_${INDEX?string}_Task_Stk_Ptr,
        <#lt>        DRV_MEMORY_STACK_SIZE_IDX${INDEX?string},
        <#lt>        TX_NO_WAIT);

        <#lt>    tx_thread_create(&_DRV_MEMORY_${INDEX?string}_Task_TCB,
        <#lt>        "DRV_MEM_${INDEX?string}_TASKS",
        <#lt>        _DRV_MEMORY_${INDEX?string}_Tasks,
        <#lt>        ${INDEX?string},
        <#lt>        _DRV_MEMORY_${INDEX?string}_Task_Stk_Ptr,
        <#lt>        DRV_MEMORY_STACK_SIZE_IDX${INDEX?string},
        <#lt>        DRV_MEMORY_PRIORITY_IDX${INDEX?string},
        <#lt>        DRV_MEMORY_PRIORITY_IDX${INDEX?string},
        <#lt>        TX_NO_TIME_SLICE,
        <#lt>        TX_AUTO_START
        <#lt>        );
    </#if>
</#if>