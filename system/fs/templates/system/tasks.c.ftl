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

<#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "BareMetal">
    <#lt>SYS_FS_Tasks();
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>    xTaskCreate( _SYS_FS_Tasks,
    <#lt>        "SYS_FS_TASKS",
    <#lt>        SYS_FS_STACK_SIZE,
    <#lt>        (void*)NULL,
    <#lt>        SYS_FS_PRIORITY,
    <#lt>        (TaskHandle_t*)NULL
    <#lt>    );
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>    tx_byte_allocate(&byte_pool_0,
    <#lt>        (VOID **) &_SYS_FS_Task_Stk_Ptr,
    <#lt>        SYS_FS_STACK_SIZE,
    <#lt>        TX_NO_WAIT
    <#lt>    );

    <#lt>    tx_thread_create(&_SYS_FS_Task_TCB,
    <#lt>        "SYS_FS_TASKS",
    <#lt>        _SYS_FS_Tasks,
    <#lt>        0,
    <#lt>        _SYS_FS_Task_Stk_Ptr,
    <#lt>        SYS_FS_STACK_SIZE,
    <#lt>        SYS_FS_PRIORITY,
    <#lt>        SYS_FS_PRIORITY,
    <#lt>        TX_NO_TIME_SLICE,
    <#lt>        TX_AUTO_START
    <#lt>    );
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
    <#assign SYS_FS_RTOS_TASK_OPTIONS = "OS_OPT_TASK_NONE" + SYS_FS_RTOS_TASK_OPT_STK_CHK?then(' | OS_OPT_TASK_STK_CHK', '') + SYS_FS_RTOS_TASK_OPT_STK_CLR?then(' | OS_OPT_TASK_STK_CLR', '') + SYS_FS_RTOS_TASK_OPT_SAVE_FP?then(' | OS_OPT_TASK_SAVE_FP', '') + SYS_FS_RTOS_TASK_OPT_NO_TLS?then(' | OS_OPT_TASK_NO_TLS', '')>
    <#lt>    OSTaskCreate((OS_TCB      *)&_SYS_FS_Tasks_TCB,
    <#lt>                 (CPU_CHAR    *)"SYS_FS_TASKS",
    <#lt>                 (OS_TASK_PTR  )_SYS_FS_Tasks,
    <#lt>                 (void        *)0,
    <#lt>                 (OS_PRIO      )SYS_FS_PRIORITY,
    <#lt>                 (CPU_STK     *)&_SYS_FS_TasksStk[0],
    <#lt>                 (CPU_STK_SIZE )0u,
    <#lt>                 (CPU_STK_SIZE )SYS_FS_STACK_SIZE,
    <#if MicriumOSIII.UCOSIII_CFG_TASK_Q_EN == true>
    <#lt>                 (OS_MSG_QTY   )SYS_FS_RTOS_TASK_MSG_QTY,
    <#else>
    <#lt>                 (OS_MSG_QTY   )0u,
    </#if>
    <#if MicriumOSIII.UCOSIII_CFG_SCHED_ROUND_ROBIN_EN == true>
    <#lt>                 (OS_TICK      )SYS_FS_RTOS_TASK_TIME_QUANTA,
    <#else>
    <#lt>                 (OS_TICK      )0u,
    </#if>
    <#lt>                 (void        *)0,
    <#lt>                 (OS_OPT       )(${SYS_FS_RTOS_TASK_OPTIONS}),
    <#lt>                 (OS_ERR      *)&os_err);
</#if>
<#--
/*******************************************************************************
 End of File
*/
-->
