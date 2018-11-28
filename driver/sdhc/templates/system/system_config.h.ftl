<#--
/*******************************************************************************
  SDHC Driver Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdhc.h.ftl

  Summary:
    SDHC Driver Freemarker Template File

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


/*** SDHC Driver Configuration ***/
<#-- Driver Instances -->
#define DRV_SDHC_CLIENTS_NUMBER ${DRV_SDHC_CLIENTS_NUMBER}
#define DRV_SDHC_BUFFER_QUEUE_SIZE ${DRV_SDHC_BUFFER_QUEUE_SIZE}
#define DRV_SDHC_CARD_DETECT_ENABLE  ${DRV_SDHC_SDCDEN?c}
#define	DRV_SDHC_WRITE_PROTECT_ENABLE  ${DRV_SDHC_SDWPEN?c}

<#if HarmonyCore.SELECT_RTOS != "BareMetal">
    <#lt>/* SDHC Driver Instance RTOS Configurations*/
    <#lt>#define DRV_SDHC_STACK_SIZE           ${DRV_SDHC_RTOS_STACK_SIZE}
    <#lt>#define DRV_SDHC_PRIORITY             ${DRV_SDHC_RTOS_TASK_PRIORITY}
</#if>

<#--
/*******************************************************************************
 End of File
*/
-->
