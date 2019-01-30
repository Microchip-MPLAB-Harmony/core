<#--
/*******************************************************************************
  SDMMC Driver Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdmmc.h.ftl

  Summary:
    SDMMC Driver Freemarker Template File

  Description:

*******************************************************************************/

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

/*** SDMMC Driver Instance ${INDEX?string} Configuration ***/
<#-- Driver Instances -->
#define DRV_SDMMC_INDEX_${INDEX?string}                                ${INDEX?string}
#define DRV_SDMMC_CLIENTS_NUMBER_IDX${INDEX?string}                    ${DRV_SDMMC_CLIENTS_NUMBER}
#define DRV_SDMMC_QUEUE_SIZE_IDX${INDEX?string}                        ${DRV_SDMMC_BUFFER_OBJECT_NUMBER}
<#if DRV_SDMMC_BUS_SPEED == "DEFAULT_SPEED">
    <#lt>#define DRV_SDMMC_CONFIG_SPEED_MODE_IDX${INDEX?string}                 DRV_SDMMC_CONFIG_SPEED_MODE_DEFAULT
<#else>
    <#lt>#define DRV_SDMMC_CONFIG_SPEED_MODE_IDX${INDEX?string}                 DRV_SDMMC_CONFIG_SPEED_MODE_HIGH
</#if>
<#if DRV_SDMMC_TRANSFER_BUS_WIDTH == "1-bit">
    <#lt>#define DRV_SDMMC_CONFIG_BUS_WIDTH_IDX${INDEX?string}                  DRV_SDMMC_CONFIG_BUS_WIDTH_1_BIT
<#else>
    <#lt>#define DRV_SDMMC_CONFIG_BUS_WIDTH_IDX${INDEX?string}                  DRV_SDMMC_CONFIG_BUS_WIDTH_4_BIT
</#if>


<#if HarmonyCore.SELECT_RTOS != "BareMetal">
    <#lt>/* SDMMC Driver Instance ${INDEX?string} RTOS Configurations*/
    <#lt>#define DRV_SDMMC_STACK_SIZE_IDX${INDEX?string}                         ${DRV_SDMMC_RTOS_STACK_SIZE}
    <#lt>#define DRV_SDMMC_PRIORITY_IDX${INDEX?string}                           ${DRV_SDMMC_RTOS_TASK_PRIORITY}
    <#lt>#define DRV_SDMMC_RTOS_DELAY_IDX${INDEX?string}                         ${DRV_SDMMC_RTOS_DELAY}
</#if>

