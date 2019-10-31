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
<#if HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>void _DRV_SDMMC${INDEX?string}_Tasks(  void *pvParameters  )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_SDMMC_Tasks(sysObj.drvSDMMC${INDEX?string});
             <#if DRV_SDMMC_RTOS_USE_DELAY >
    <#lt>        vTaskDelay(DRV_SDMMC_RTOS_DELAY_IDX${INDEX?string} / portTICK_PERIOD_MS);
             </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>TX_THREAD      _DRV_SDMMC_${INDEX?string}_Task_TCB;
    <#lt>uint8_t*       _DRV_SDMMC_${INDEX?string}_Task_Stk_Ptr;

    <#lt>static void _DRV_SDMMC_${INDEX?string}_Tasks( ULONG thread_input )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_SDMMC_Tasks(sysObj.drvSDMMC${INDEX?string});
    <#if DRV_SDMMC_RTOS_USE_DELAY == true>
        <#lt>        tx_thread_sleep((ULONG)(DRV_SDMMC_RTOS_DELAY_IDX${INDEX?string} / (TX_TICK_PERIOD_MS)));
    </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
    <#lt>OS_TCB  _DRV_SDMMC_${INDEX?string}_Tasks_TCB;
    <#lt>CPU_STK _DRV_SDMMC_${INDEX?string}_TasksStk[DRV_SDMMC_STACK_SIZE_IDX${INDEX?string}];

    <#lt>void _DRV_SDMMC_${INDEX?string}_Tasks(  void *pvParameters  )
    <#lt>{
    <#if DRV_SDMMC_RTOS_USE_DELAY == true>
    <#lt>    OS_ERR os_err;
    </#if>
    <#lt>    while(1)
    <#lt>    {
    <#lt>        DRV_SDMMC_Tasks(sysObj.drvSDMMC${INDEX?string});
    <#if DRV_SDMMC_RTOS_USE_DELAY == true>
    <#lt>        OSTimeDly(DRV_SDMMC_RTOS_DELAY_IDX${INDEX?string} , OS_OPT_TIME_DLY, &os_err);
    </#if>
    <#lt>    }
    <#lt>}
</#if>