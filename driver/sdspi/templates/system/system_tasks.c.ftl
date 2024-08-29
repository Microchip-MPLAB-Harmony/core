<#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "BareMetal">
    <#lt>DRV_SDSPI_Tasks(sysObj.drvSDSPI${INDEX?string});
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>    (void) xTaskCreate( lDRV_SDSPI_${INDEX?string}_Tasks,
    <#lt>        "DRV_SD_${INDEX?string}_TASKS",
    <#lt>        DRV_SDSPI_STACK_SIZE_IDX${INDEX?string},
    <#lt>        (void*)NULL,
    <#lt>        DRV_SDSPI_PRIORITY_IDX${INDEX?string} <#if FreeRTOS.FREERTOS_MPU_PORT_ENABLE == true> | portPRIVILEGE_BIT </#if>,
    <#lt>        (TaskHandle_t*)NULL
    <#lt>    );
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>    tx_byte_allocate(&byte_pool_0,
    <#lt>       (VOID **) &lDRV_SDSPI_${INDEX?string}_Task_Stk_Ptr,
    <#lt>        DRV_SDSPI_STACK_SIZE_IDX${INDEX?string},
    <#lt>        TX_NO_WAIT
    <#lt>    );

    <#lt>    tx_thread_create(&lDRV_SDSPI_${INDEX?string}_Task_TCB,
    <#lt>        "DRV_SDSPI${INDEX?string}_TASKS",
    <#lt>        lDRV_SDSPI_${INDEX?string}_Tasks,
    <#lt>        ${INDEX?string},
    <#lt>        lDRV_SDSPI_${INDEX?string}_Task_Stk_Ptr,
    <#lt>        DRV_SDSPI_STACK_SIZE_IDX${INDEX?string},
    <#lt>        DRV_SDSPI_PRIORITY_IDX${INDEX?string},
    <#lt>        DRV_SDSPI_PRIORITY_IDX${INDEX?string},
    <#lt>        TX_NO_TIME_SLICE,
    <#lt>        TX_AUTO_START
    <#lt>    );
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
    <#assign DRV_SDSPI_RTOS_TASK_OPTIONS = "OS_OPT_TASK_NONE" + DRV_SDSPI_RTOS_TASK_OPT_STK_CHK?then(' | OS_OPT_TASK_STK_CHK', '') + DRV_SDSPI_RTOS_TASK_OPT_STK_CLR?then(' | OS_OPT_TASK_STK_CLR', '') + DRV_SDSPI_RTOS_TASK_OPT_SAVE_FP?then(' | OS_OPT_TASK_SAVE_FP', '') + DRV_SDSPI_RTOS_TASK_OPT_NO_TLS?then(' | OS_OPT_TASK_NO_TLS', '')>
    <#lt>    OSTaskCreate((OS_TCB      *)&_DRV_SDSPI_${INDEX?string}_Tasks_TCB,
    <#lt>                 (CPU_CHAR    *)"DRV_SDSPI${INDEX?string}_TASKS",
    <#lt>                 (OS_TASK_PTR  )_DRV_SDSPI_${INDEX?string}_Tasks,
    <#lt>                 (void        *)0,
    <#lt>                 (OS_PRIO      )DRV_SDSPI_PRIORITY_IDX${INDEX?string},
    <#lt>                 (CPU_STK     *)&_DRV_SDSPI_${INDEX?string}_TasksStk[0],
    <#lt>                 (CPU_STK_SIZE )0u,
    <#lt>                 (CPU_STK_SIZE )DRV_SDSPI_STACK_SIZE_IDX${INDEX?string},
    <#if MicriumOSIII.UCOSIII_CFG_TASK_Q_EN == true>
    <#lt>                 (OS_MSG_QTY   )DRV_SDSPI_RTOS_TASK_MSG_QTY_IDX${INDEX?string},
    <#else>
    <#lt>                 (OS_MSG_QTY   )0u,
    </#if>
    <#if MicriumOSIII.UCOSIII_CFG_SCHED_ROUND_ROBIN_EN == true>
    <#lt>                 (OS_TICK      )DRV_SDSPI_RTOS_TASK_TIME_QUANTA_IDX${INDEX?string},
    <#else>
    <#lt>                 (OS_TICK      )0u,
    </#if>
    <#lt>                 (void        *)0,
    <#lt>                 (OS_OPT       )(${DRV_SDSPI_RTOS_TASK_OPTIONS}),
    <#lt>                 (OS_ERR      *)&os_err);
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MbedOS">
    <#lt>    Thread DRV_SDSPI_${INDEX?string}_thread((osPriority)(osPriorityNormal + (DRV_SDSPI_PRIORITY_IDX${INDEX?string} - 1)), DRV_SDSPI_STACK_SIZE_IDX${INDEX?string}, NULL, "_DRV_SDSPI_${INDEX?string}_Tasks");
    <#lt>    DRV_SDSPI_${INDEX?string}_thread.start(callback(_DRV_SDSPI_${INDEX?string}_Tasks, (void *)NULL));
</#if>
