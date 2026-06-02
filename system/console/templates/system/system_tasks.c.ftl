<#--
/*******************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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
<#if SYS_CONSOLE_DEVICE_SET == "USB_CDC">
<#if HarmonyCore.SELECT_RTOS == "BareMetal">
    <#lt>SYS_CONSOLE_Tasks(SYS_CONSOLE_INDEX_${INDEX?string});
<#elseif HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>    xTaskCreate( lSYS_CONSOLE_${INDEX?string}_Tasks,
    <#lt>        "SYS_CONSOLE_${INDEX?string}_TASKS",
    <#lt>        SYS_CONSOLE_RTOS_STACK_SIZE_IDX${INDEX?string},
    <#lt>        (void*)NULL,
    <#lt>        SYS_CONSOLE_RTOS_TASK_PRIORITY_IDX${INDEX?string} <#if FreeRTOS.FREERTOS_MPU_PORT_ENABLE == true> | portPRIVILEGE_BIT </#if>,
    <#lt>        (TaskHandle_t*)NULL
    <#lt>    );
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>    tx_byte_allocate(&byte_pool_0,
    <#lt>        (VOID **) &lSYS_CONSOLE_${INDEX?string}_Task_Stk_Ptr,
    <#lt>        SYS_CONSOLE_RTOS_STACK_SIZE_IDX${INDEX?string},
    <#lt>        TX_NO_WAIT
    <#lt>    );

    <#lt>    tx_thread_create(&lSYS_CONSOLE_${INDEX?string}_Task_TCB,
    <#lt>        "SYS_CONSOLE_${INDEX?string}_TASKS",
    <#lt>        lSYS_CONSOLE_${INDEX?string}_Tasks,
    <#lt>        0,
    <#lt>        lSYS_CONSOLE_${INDEX?string}_Task_Stk_Ptr,
    <#lt>        SYS_CONSOLE_RTOS_STACK_SIZE_IDX${INDEX?string},
    <#lt>        SYS_CONSOLE_RTOS_TASK_PRIORITY_IDX${INDEX?string},
    <#lt>        SYS_CONSOLE_RTOS_TASK_PRIORITY_IDX${INDEX?string},
    <#lt>        TX_NO_TIME_SLICE,
    <#lt>        TX_AUTO_START
    <#lt>    );
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
    <#assign SYS_CONSOLE_RTOS_TASK_OPTIONS = "OS_OPT_TASK_NONE" + SYS_CONSOLE_RTOS_TASK_OPT_STK_CHK?then(' | OS_OPT_TASK_STK_CHK', '') + SYS_CONSOLE_RTOS_TASK_OPT_STK_CLR?then(' | OS_OPT_TASK_STK_CLR', '') + SYS_CONSOLE_RTOS_TASK_OPT_SAVE_FP?then(' | OS_OPT_TASK_SAVE_FP', '') + SYS_CONSOLE_RTOS_TASK_OPT_NO_TLS?then(' | OS_OPT_TASK_NO_TLS', '')>
    <#lt>    OSTaskCreate((OS_TCB      *)&_SYS_CONSOLE_${INDEX?string}_Task_TCB,
    <#lt>                 (CPU_CHAR    *)"SYS_CONSOLE_${INDEX?string}_TASKS",
    <#lt>                 (OS_TASK_PTR  )_SYS_CONSOLE_${INDEX?string}_Tasks,
    <#lt>                 (void        *)0,
    <#lt>                 (OS_PRIO      )SYS_CONSOLE_RTOS_TASK_PRIORITY_IDX${INDEX?string},
    <#lt>                 (CPU_STK     *)&_SYS_CONSOLE_${INDEX?string}_TasksStk[0],
    <#lt>                 (CPU_STK_SIZE )0u,
    <#lt>                 (CPU_STK_SIZE )SYS_CONSOLE_RTOS_STACK_SIZE_IDX${INDEX?string},
    <#if MicriumOSIII.UCOSIII_CFG_TASK_Q_EN == true>
    <#lt>                 (OS_MSG_QTY   )SYS_CONSOLE_RTOS_TASK_MSG_QTY_IDX${INDEX?string},
    <#else>
    <#lt>                 (OS_MSG_QTY   )0u,
    </#if>
    <#if MicriumOSIII.UCOSIII_CFG_SCHED_ROUND_ROBIN_EN == true>
    <#lt>                 (OS_TICK      )SYS_CONSOLE_RTOS_TASK_TIME_QUANTA_IDX${INDEX?string},
    <#else>
    <#lt>                 (OS_TICK      )0u,
    </#if>
    <#lt>                 (void        *)0,
    <#lt>                 (OS_OPT       )(${SYS_CONSOLE_RTOS_TASK_OPTIONS}),
    <#lt>                 (OS_ERR      *)&os_err);
<#elseif HarmonyCore.SELECT_RTOS == "MbedOS">
    <#lt>    Thread SYS_CONSOLE_${INDEX?string}_thread((osPriority)(osPriorityNormal + (SYS_CONSOLE_RTOS_TASK_PRIORITY_IDX${INDEX?string} - 1)), SYS_CONSOLE_RTOS_STACK_SIZE_IDX${INDEX?string}, NULL, "_SYS_CONSOLE_${INDEX?string}_Tasks");
    <#lt>    SYS_CONSOLE_${INDEX?string}_thread.start(callback(_SYS_CONSOLE_${INDEX?string}_Tasks, (void *)NULL));
</#if>
</#if>
