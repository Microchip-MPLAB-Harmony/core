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

#define SYS_CMD_ENABLE
#define SYS_CMD_DEVICE_MAX_INSTANCES       SYS_CONSOLE_DEVICE_MAX_INSTANCES
#define SYS_CMD_PRINT_BUFFER_SIZE          ${SYS_COMMAND_PRINT_BUFFER_SIZE}
#define SYS_CMD_BUFFER_DMA_READY
<#if SYS_COMMAND_CONSOLE_ENABLE == true>
    <#lt>#define SYS_CMD_REMAP_SYS_CONSOLE_MESSAGE
</#if>
<#if SYS_COMMAND_DEBUG_ENABLE == true>
    <#lt>#define SYS_CMD_REMAP_SYS_DEBUG_MESSAGE
</#if>
<#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS != "BareMetal">
    <#lt>/* Command System Service RTOS Configurations*/
    <#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
        <#lt>#define SYS_CMD_RTOS_STACK_SIZE                ${SYS_COMMAND_RTOS_STACK_SIZE / 4}
    <#else>
        <#lt>#define SYS_CMD_RTOS_STACK_SIZE                ${SYS_COMMAND_RTOS_STACK_SIZE}
    </#if>
    <#lt>#define SYS_CMD_RTOS_TASK_PRIORITY             ${SYS_COMMAND_RTOS_TASK_PRIORITY}
        <#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
        <#lt>#define SYS_CMD_RTOS_TASK_MSG_QTY              ${SYS_COMMAND_RTOS_TASK_MSG_QTY}u
        <#lt>#define SYS_CMD_RTOS_TASK_TIME_QUANTA          ${SYS_COMMAND_RTOS_TASK_TIME_QUANTA}u
    </#if>
</#if>
