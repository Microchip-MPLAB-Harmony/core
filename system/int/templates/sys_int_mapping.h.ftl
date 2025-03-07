/*******************************************************************************
  Interrupt System Service Mapping File

  Company:
    Microchip Technology Inc.

  File Name:
    sys_int_mapping.h

  Summary:
    Interrupt System Service mapping file.

  Description:
    This header file contains the mapping of the APIs defined in the API header
    to either the function implementations or macro implementation or the
    specific variant implementation.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/******************************************************************************
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
//DOM-IGNORE-END

#ifndef SYS_INT_MAPPING_H
#define SYS_INT_MAPPING_H

// *****************************************************************************
// *****************************************************************************
// Section: Interrupt System Service Mapping
// *****************************************************************************
// *****************************************************************************

/* MISRA C-2012 Rule 5.8 deviated:6 Deviation record ID -  H3_MISRAC_2012_R_5_8_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:6 "MISRA C-2012 Rule 5.8" "H3_MISRAC_2012_R_5_8_DR_1"
</#if>

<#if __PROCESSOR?matches("ATSAMA5.*") ||  __PROCESSOR?matches("SAM9X.*") >
<#elseif __PROCESSOR?matches("SAMA7.*") >
    <#lt>#define SYS_INT_IsEnabled()                 ((CPSR_I_Msk & __get_CPSR()) == 0)
    <#lt>#define SYS_INT_SourceEnable( source )      GIC_EnableIRQ( source )
    <#lt>#define SYS_INT_SourceIsEnabled( source )   GIC_GetEnableIRQ( source )
    <#lt>#define SYS_INT_SourceStatusGet( source )   GIC_GetPendingIRQ( source )
    <#lt>#define SYS_INT_SourceStatusSet( source )   GIC_SetPendingIRQ( source )
    <#lt>#define SYS_INT_SourceStatusClear( source ) GIC_ClearPendingIRQ( source )
<#elseif (core.CoreArchitecture == "PIC32A") || (core.CoreArchitecture == "dsPIC33A")>
        <#lt>#define SYS_INT_IsEnabled()                 ((bool)(SRbits.IPL != 7U))
        <#lt>#define SYS_INT_SourceEnable( source )      INTC_SourceEnable( source )
        <#lt>#define SYS_INT_SourceIsEnabled( source )   INTC_SourceIsEnabled( source )
        <#lt>#define SYS_INT_SourceStatusGet( source )   INTC_SourceStatusGet( source )
        <#lt>#define SYS_INT_SourceStatusSet( source )   INTC_SourceStatusSet( source )
        <#lt>#define SYS_INT_SourceStatusClear( source ) INTC_SourceStatusClear( source )
<#else>
    <#if core.PRODUCT_FAMILY?matches("PIC32M.*") == false>
        <#lt>#define SYS_INT_IsEnabled()                 ( __get_PRIMASK() == 0 )
        <#lt>#define SYS_INT_SourceEnable( source )      NVIC_EnableIRQ( source )
        <#lt>#define SYS_INT_SourceIsEnabled( source )   NVIC_GetEnableIRQ( source )
        <#lt>#define SYS_INT_SourceStatusGet( source )   NVIC_GetPendingIRQ( source )
        <#lt>#define SYS_INT_SourceStatusSet( source )   NVIC_SetPendingIRQ( source )
        <#lt>#define SYS_INT_SourceStatusClear( source ) NVIC_ClearPendingIRQ( source )
    <#else>
        <#lt>#define SYS_INT_IsEnabled()                 ((bool)(_CP0_GET_STATUS() & 0x01))
        <#lt>#define SYS_INT_SourceEnable( source )      EVIC_SourceEnable( source )
        <#lt>#define SYS_INT_SourceIsEnabled( source )   EVIC_SourceIsEnabled( source )
        <#lt>#define SYS_INT_SourceStatusGet( source )   EVIC_SourceStatusGet( source )
        <#lt>#define SYS_INT_SourceStatusSet( source )   EVIC_SourceStatusSet( source )
        <#lt>#define SYS_INT_SourceStatusClear( source ) EVIC_SourceStatusClear( source )
    </#if>
</#if>

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 5.8"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */

#endif // SYS_INT_MAPPING_H
