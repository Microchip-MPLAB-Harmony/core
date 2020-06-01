<#--
/*******************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*******************************************************************************/
-->
<#if HarmonyCore.SELECT_RTOS == "BareMetal">
    <#lt>DRV_SDMMC_Tasks(sysObj.drvSDMMC${INDEX?string});
<#elseif HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>    xTaskCreate( _DRV_SDMMC${INDEX?string}_Tasks,
    <#lt>        "DRV_SDMMC${INDEX?string}_Tasks",
    <#lt>        DRV_SDMMC_STACK_SIZE_IDX${INDEX?string},
    <#lt>        (void*)NULL,
    <#lt>        DRV_SDMMC_PRIORITY_IDX${INDEX?string},
    <#lt>        (TaskHandle_t*)NULL
    <#lt>    );
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>    tx_byte_allocate(&byte_pool_0,
    <#lt>       (VOID **) &_DRV_SDMMC_${INDEX?string}_Task_Stk_Ptr,
    <#lt>        DRV_SDMMC_STACK_SIZE_IDX${INDEX?string},
    <#lt>        TX_NO_WAIT
    <#lt>    );

    <#lt>    tx_thread_create(&_DRV_SDMMC_${INDEX?string}_Task_TCB,
    <#lt>        "DRV_SDMMC${INDEX?string}_TASKS",
    <#lt>        _DRV_SDMMC_${INDEX?string}_Tasks,
    <#lt>        ${INDEX?string},
    <#lt>        _DRV_SDMMC_${INDEX?string}_Task_Stk_Ptr,
    <#lt>        DRV_SDMMC_STACK_SIZE_IDX${INDEX?string},
    <#lt>        DRV_SDMMC_PRIORITY_IDX${INDEX?string},
    <#lt>        DRV_SDMMC_PRIORITY_IDX${INDEX?string},
    <#lt>        TX_NO_TIME_SLICE,
    <#lt>        TX_AUTO_START
    <#lt>    );
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
    <#assign DRV_SDMMC_RTOS_TASK_OPTIONS = "OS_OPT_TASK_NONE" + DRV_SDMMC_RTOS_TASK_OPT_STK_CHK?then(' | OS_OPT_TASK_STK_CHK', '') + DRV_SDMMC_RTOS_TASK_OPT_STK_CLR?then(' | OS_OPT_TASK_STK_CLR', '') + DRV_SDMMC_RTOS_TASK_OPT_SAVE_FP?then(' | OS_OPT_TASK_SAVE_FP', '') + DRV_SDMMC_RTOS_TASK_OPT_NO_TLS?then(' | OS_OPT_TASK_NO_TLS', '')>
    <#lt>    OSTaskCreate((OS_TCB      *)&_DRV_SDMMC_${INDEX?string}_Tasks_TCB,
    <#lt>                 (CPU_CHAR    *)"DRV_SDMMC${INDEX?string}_TASKS",
    <#lt>                 (OS_TASK_PTR  )_DRV_SDMMC_${INDEX?string}_Tasks,
    <#lt>                 (void        *)0,
    <#lt>                 (OS_PRIO      )DRV_SDMMC_PRIORITY_IDX${INDEX?string},
    <#lt>                 (CPU_STK     *)&_DRV_SDMMC_${INDEX?string}_TasksStk[0],
    <#lt>                 (CPU_STK_SIZE )0u,
    <#lt>                 (CPU_STK_SIZE )DRV_SDMMC_STACK_SIZE_IDX${INDEX?string},
    <#if MicriumOSIII.UCOSIII_CFG_TASK_Q_EN == true>
    <#lt>                 (OS_MSG_QTY   )DRV_SDMMC_RTOS_TASK_MSG_QTY_IDX${INDEX?string},
    <#else>
    <#lt>                 (OS_MSG_QTY   )0u,
    </#if>
    <#if MicriumOSIII.UCOSIII_CFG_SCHED_ROUND_ROBIN_EN == true>
    <#lt>                 (OS_TICK      )DRV_SDMMC_RTOS_TASK_TIME_QUANTA_IDX${INDEX?string},
    <#else>
    <#lt>                 (OS_TICK      )0u,
    </#if>
    <#lt>                 (void        *)0,
    <#lt>                 (OS_OPT       )(${DRV_SDMMC_RTOS_TASK_OPTIONS}),
    <#lt>                 (OS_ERR      *)&os_err);
<#elseif HarmonyCore.SELECT_RTOS == "MbedOS">
    <#lt>    Thread DRV_SDMMC${INDEX?string}_thread((osPriority)(osPriorityNormal + (DRV_SDMMC_PRIORITY_IDX${INDEX?string} - 1)), DRV_SDMMC_STACK_SIZE_IDX${INDEX?string}, NULL, "_DRV_SDMMC${INDEX?string}_Tasks");
    <#lt>    DRV_SDMMC${INDEX?string}_thread.start(callback(_DRV_SDMMC_${INDEX?string}_Tasks, (void *)NULL));
</#if>


