<#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>static void lDRV_MEMORY_${INDEX?string}_Tasks(  void *pvParameters  )
    <#lt>{
    <#lt>    while(true)
    <#lt>    {
    <#lt>        DRV_MEMORY_Tasks(sysObj.drvMemory${INDEX?string});
             <#if DRV_MEMORY_RTOS_USE_DELAY >
    <#lt>        vTaskDelay(DRV_MEMORY_RTOS_DELAY_IDX${INDEX?string} / portTICK_PERIOD_MS);
             </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>TX_THREAD      lDRV_MEMORY_${INDEX?string}_Task_TCB;
    <#lt>uint8_t*       lDRV_MEMORY_${INDEX?string}_Task_Stk_Ptr;

    <#lt>static void lDRV_MEMORY_${INDEX?string}_Tasks( ULONG thread_input )
    <#lt>{
    <#lt>    while(true)
    <#lt>    {
    <#lt>        DRV_MEMORY_Tasks(sysObj.drvMemory${INDEX?string});
    <#if DRV_MEMORY_RTOS_USE_DELAY == true>
        <#lt>        tx_thread_sleep((ULONG)(DRV_MEMORY_RTOS_DELAY_IDX${INDEX?string} / (TX_TICK_PERIOD_MS)));
    </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
    <#lt>OS_TCB  lDRV_MEMORY_${INDEX?string}_Tasks_TCB;
    <#lt>CPU_STK lDRV_MEMORY_${INDEX?string}_TasksStk[DRV_MEMORY_STACK_SIZE_IDX${INDEX?string}];

    <#lt>static void lDRV_MEMORY_${INDEX?string}_Tasks(  void *pvParameters  )
    <#lt>{
    <#if DRV_MEMORY_RTOS_USE_DELAY == true>
    <#lt>    OS_ERR os_err;
    </#if>
    <#lt>    while(true)
    <#lt>    {
    <#lt>        DRV_MEMORY_Tasks(sysObj.drvMemory${INDEX?string});
    <#if DRV_MEMORY_RTOS_USE_DELAY == true>
    <#lt>        OSTimeDly(DRV_MEMORY_RTOS_DELAY_IDX${INDEX?string} , OS_OPT_TIME_DLY, &os_err);
    </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MbedOS">
    <#lt>static void lDRV_MEMORY_${INDEX?string}_Tasks( void *pvParameters )
    <#lt>{
    <#lt>    while(true)
    <#lt>    {
    <#lt>        DRV_MEMORY_Tasks(sysObj.drvMemory${INDEX?string});
    <#if DRV_MEMORY_RTOS_USE_DELAY == true>
        <#lt>    thread_sleep_for((uint32_t)(DRV_MEMORY_RTOS_DELAY_IDX${INDEX?string} / MBED_OS_TICK_PERIOD_MS));
    </#if>
    <#lt>    }
    <#lt>}
</#if>