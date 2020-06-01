<#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>void _DRV_SDSPI_${INDEX?string}_Tasks(  void *pvParameters  )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_SDSPI_Tasks(sysObj.drvSDSPI${INDEX?string});
             <#if DRV_SDSPI_RTOS_USE_DELAY >
    <#lt>        vTaskDelay(${DRV_SDSPI_RTOS_DELAY} / portTICK_PERIOD_MS);
             </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>TX_THREAD      _DRV_SDSPI_${INDEX?string}_Task_TCB;
    <#lt>uint8_t*       _DRV_SDSPI_${INDEX?string}_Task_Stk_Ptr;

    <#lt>static void _DRV_SDSPI_${INDEX?string}_Tasks( ULONG thread_input )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_SDSPI_Tasks(sysObj.drvSDSPI${INDEX?string});
    <#if DRV_SDSPI_RTOS_USE_DELAY == true>
        <#lt>        tx_thread_sleep((ULONG)(${DRV_SDSPI_RTOS_DELAY} / (TX_TICK_PERIOD_MS)));
    </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
    <#lt>OS_TCB  _DRV_SDSPI_${INDEX?string}_Tasks_TCB;
    <#lt>CPU_STK _DRV_SDSPI_${INDEX?string}_TasksStk[DRV_SDSPI_STACK_SIZE_IDX${INDEX?string}];

    <#lt>void _DRV_SDSPI_${INDEX?string}_Tasks(  void *pvParameters  )
    <#lt>{
    <#if DRV_SDSPI_RTOS_USE_DELAY == true>
    <#lt>    OS_ERR os_err;
    </#if>
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_SDSPI_Tasks(sysObj.drvSDSPI${INDEX?string});
    <#if DRV_SDSPI_RTOS_USE_DELAY == true>
    <#lt>        OSTimeDly(${DRV_SDSPI_RTOS_DELAY} , OS_OPT_TIME_DLY, &os_err);
    </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MbedOS">
    <#lt>static void _DRV_SDSPI_${INDEX?string}_Tasks( void *pvParameters )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_SDSPI_Tasks(sysObj.drvSDSPI${INDEX?string});
    <#if DRV_SDSPI_RTOS_USE_DELAY == true>
        <#lt>    thread_sleep_for((uint32_t)(${DRV_SDSPI_RTOS_DELAY} / MBED_OS_TICK_PERIOD_MS));
    </#if>
    <#lt>    }
    <#lt>}
</#if>
