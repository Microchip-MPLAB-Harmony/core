<#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>void _DRV_MEMORY_${INDEX?string}_Tasks(  void *pvParameters  )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_MEMORY_Tasks(sysObj.drvMemory${INDEX?string});
             <#if DRV_MEMORY_RTOS_USE_DELAY >
    <#lt>        vTaskDelay(DRV_MEMORY_RTOS_DELAY_IDX${INDEX?string} / portTICK_PERIOD_MS);
             </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>TX_THREAD      _DRV_MEMORY_${INDEX?string}_Task_TCB;
    <#lt>uint8_t*       _DRV_MEMORY_${INDEX?string}_Task_Stk_Ptr;

    <#lt>static void _DRV_MEMORY_${INDEX?string}_Tasks( ULONG thread_input )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_MEMORY_Tasks(sysObj.drvMemory${INDEX?string});
    <#if DRV_MEMORY_RTOS_USE_DELAY == true>
        <#lt>        tx_thread_sleep((ULONG)(DRV_MEMORY_RTOS_DELAY_IDX${INDEX?string} / (TX_TICK_PERIOD_MS)));
    </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
    <#lt>OS_TCB  _DRV_MEMORY_${INDEX?string}_Tasks_TCB;
    <#lt>CPU_STK _DRV_MEMORY_${INDEX?string}_TasksStk[DRV_MEMORY_STACK_SIZE_IDX${INDEX?string}];

    <#lt>void _DRV_MEMORY_${INDEX?string}_Tasks(  void *pvParameters  )
    <#lt>{
    <#if DRV_MEMORY_RTOS_USE_DELAY == true>
    <#lt>    OS_ERR os_err;
    </#if>
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_MEMORY_Tasks(sysObj.drvMemory${INDEX?string});
    <#if DRV_MEMORY_RTOS_USE_DELAY == true>
    <#lt>        OSTimeDly(DRV_MEMORY_RTOS_DELAY_IDX${INDEX?string} , OS_OPT_TIME_DLY, &os_err);
    </#if>
    <#lt>    }
    <#lt>}
</#if>