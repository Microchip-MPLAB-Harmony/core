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

<#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>void _SYS_FS_Tasks(  void *pvParameters  )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        SYS_FS_Tasks();
             <#if SYS_FS_RTOS_USE_DELAY >
    <#lt>        vTaskDelay(${SYS_FS_RTOS_DELAY} / portTICK_PERIOD_MS);
             </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>TX_THREAD      _SYS_FS_Task_TCB;
    <#lt>uint8_t*       _SYS_FS_Task_Stk_Ptr;

    <#lt>static void _SYS_FS_Tasks( ULONG thread_input )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        SYS_FS_Tasks();
             <#if SYS_FS_RTOS_USE_DELAY >
    <#lt>        tx_thread_sleep((ULONG)(${SYS_FS_RTOS_DELAY} / (TX_TICK_PERIOD_MS)));
             </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
    <#lt>OS_TCB  _SYS_FS_Tasks_TCB;
    <#lt>CPU_STK _SYS_FS_TasksStk[SYS_FS_STACK_SIZE];

    <#lt>void _SYS_FS_Tasks(  void *pvParameters  )
    <#lt>{
    <#if SYS_FS_RTOS_USE_DELAY == true>
    <#lt>    OS_ERR os_err;
    </#if>
    <#lt>    while(1)
    <#lt>    {
    <#lt>        SYS_FS_Tasks();
    <#if SYS_FS_RTOS_USE_DELAY == true>
    <#lt>        OSTimeDly(${SYS_FS_RTOS_DELAY} , OS_OPT_TIME_DLY, &os_err);
    </#if>
    <#lt>    }
    <#lt>}
</#if>

<#--
/*******************************************************************************
 End of File
*/
-->
