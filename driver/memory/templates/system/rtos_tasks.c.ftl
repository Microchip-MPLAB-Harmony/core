<#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
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
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>TX_THREAD      _DRV_MEMORY_${INDEX?string}_Task_TCB;
    <#lt>uint8_t*       _DRV_MEMORY_${INDEX?string}_Task_Stk_Ptr;

    <#lt>static void _DRV_MEMORY_${INDEX?string}_Tasks( ULONG thread_input )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_MEMORY_Tasks(sysObj.drvMemory${INDEX?string});
    <#if DRV_MEMORY_RTOS_USE_DELAY == true>
        <#lt>        tx_thread_sleep((ULONG)(${DRV_MEMORY_RTOS_DELAY} / (TX_TICK_PERIOD_MS)));
    </#if>
    <#lt>    }
    <#lt>}
</#if>