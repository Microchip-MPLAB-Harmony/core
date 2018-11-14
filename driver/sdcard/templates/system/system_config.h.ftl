<#--
/*******************************************************************************
  SDCARD Driver Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
    system_config.h.ftl

  Summary:
    SDCARD Driver Freemarker Template File

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
/* SDCARD Driver Common Configuration Options */
#define DRV_SDCARD_INSTANCES_NUMBER             1

/* SDCARD Driver Instance 0 Configuration Options */
#define DRV_SDCARD_INDEX_0                      0
<#if HarmonyCore.SELECT_RTOS != "BareMetal">
    <#lt>/* SDHC Driver Instance RTOS Configurations*/
    <#lt>#define DRV_SDCARD_STACK_SIZE_IDX${INDEX?string}                        ${DRV_SDCARD_RTOS_STACK_SIZE}
    <#lt>#define DRV_SDCARD_PRIORITY_IDX${INDEX?string}                          ${DRV_SDCARD_RTOS_TASK_PRIORITY}
    <#lt>#define DRV_SDCARD_RTOS_DELAY_IDX${INDEX?string}                        ${DRV_SDCARD_RTOS_DELAY}
</#if>
<#if DRV_SDCARD_SELECT_PROTOCOL == "SDSPI">
    <#lt>/* SDSPI Driver Common Configuration Options */
    <#lt>#define DRV_SDSPI_INSTANCES_NUMBER                                      1
    <#lt>/* SDSPI Driver Instance ${INDEX?string} Configuration Options */
    <#lt>#define DRV_SDSPI_INDEX_${INDEX?string}                                 ${INDEX?string}
    <#lt>#define DRV_SDSPI_CLIENTS_NUMBER_IDX${INDEX?string}                     ${DRV_SDSPI_NUM_CLIENTS?string}
    <#lt>#define DRV_SDSPI_CHIP_SELECT_PIN_IDX${INDEX?string}                    ${DRV_SDSPI_CHIP_SELECT_PIN?string}
    <#lt>#define DRV_SDSPI_SPEED_HZ_IDX${INDEX?string}                           ${DRV_SDSPI_SPEED_HZ?string}

    <#if DRV_SDSPI_TX_RX_DMA == true>
    <#lt>#define DRV_SDSPI_XMIT_DMA_CH_IDX${INDEX?string}                        SYS_DMA_CHANNEL_${DRV_SDSPI_TX_DMA_CHANNEL}
        <#lt>#define DRV_SDSPI_RCV_DMA_CH_IDX${INDEX?string}                     SYS_DMA_CHANNEL_${DRV_SDSPI_RX_DMA_CHANNEL}
    </#if>

    <#if DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING == true>
        <#lt>#define DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECK
        <#lt>#define DRV_SDSPI_WRITE_PROTECT_PIN_IDX${INDEX?string}              ${DRV_SDSPI_WRITE_PROTECT_PIN?string}
    </#if>
<#elseif DRV_SDCARD_SELECT_PROTOCOL == "SDHC">
    <#lt>/*** SDHC Driver Configuration ***/
    <#lt>/* SDHC Driver Global Configuration Options */
    <#lt>#define DRV_SDHC_INSTANCES_NUMBER                                       ${DRV_SDHC_INSTANCES_NUMBER}
    <#lt><#-- Driver Instances -->
    <#lt>#define DRV_SDHC_CLIENTS_NUMBER                                         ${DRV_SDHC_CLIENTS_NUMBER}
    <#lt>#define DRV_SDHC_BUFFER_OBJ_NUMBER                                      ${DRV_SDHC_BUFFER_OBJECT_NUMBER}
    <#lt>#define DRV_SDHC_CARD_DETECT_ENABLE                                     ${DRV_SDHC_SDCDEN?c}
    <#lt>#define DRV_SDHC_WRITE_PROTECT_ENABLE                                   ${DRV_SDHC_SDWPEN?c}
</#if>
<#--
/*******************************************************************************
 End of File
*/
-->
