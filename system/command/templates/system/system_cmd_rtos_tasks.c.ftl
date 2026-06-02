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
<#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>TaskHandle_t xSYS_CMD_Tasks;
    <#lt>static void lSYS_CMD_Tasks(  void *pvParameters  )
    <#lt>{
    <#lt>    while(true)
    <#lt>    {
    <#lt>        (void) SYS_CMD_Tasks();
             <#if SYS_COMMAND_RTOS_USE_DELAY >
    <#lt>        vTaskDelay(${SYS_COMMAND_RTOS_DELAY}U / portTICK_PERIOD_MS);
             </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>TX_THREAD      lSYS_CMD_Task_TCB;
    <#lt>uint8_t*       lSYS_CMD_Task_Stk_Ptr;

    <#lt>static void lSYS_CMD_Tasks( ULONG thread_input )
    <#lt>{
    <#lt>    while(true)
    <#lt>    {
    <#lt>        (void) SYS_CMD_Tasks();
             <#if SYS_COMMAND_RTOS_USE_DELAY >
    <#lt>        tx_thread_sleep((ULONG)(${SYS_COMMAND_RTOS_DELAY}U / (TX_TICK_PERIOD_MS)));
             </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
    <#lt>OS_TCB  _SYS_CMD_Tasks_TCB;
    <#lt>CPU_STK _SYS_CMD_TasksStk[SYS_CMD_RTOS_STACK_SIZE];

    <#lt>static void _SYS_CMD_Tasks(  void *pvParameters  )
    <#lt>{
    <#if SYS_COMMAND_RTOS_USE_DELAY == true>
    <#lt>    OS_ERR os_err;
    </#if>
    <#lt>    while(true)
    <#lt>    {
    <#lt>        (void) SYS_CMD_Tasks();
    <#if SYS_COMMAND_RTOS_USE_DELAY == true>
    <#lt>        OSTimeDly(${SYS_COMMAND_RTOS_DELAY}U , OS_OPT_TIME_DLY, &os_err);
    </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MbedOS">
    <#lt>static void _SYS_CMD_Tasks( void *pvParameters )
    <#lt>{
    <#lt>    while(true)
    <#lt>    {
    <#lt>        (void) SYS_CMD_Tasks();
             <#if SYS_COMMAND_RTOS_USE_DELAY == true>
    <#lt>        thread_sleep_for((uint32_t)(${SYS_COMMAND_RTOS_DELAY}U / MBED_OS_TICK_PERIOD_MS));
             </#if>
    <#lt>    }
    <#lt>}
</#if>

