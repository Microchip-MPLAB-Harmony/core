/*******************************************************************************
  Reset System Service Source File

  Company:
    Microchip Technology Inc.

  File Name:
    sys_reset.c

  Summary:
    Reset System Service source file.

  Description:
    This source file contains the function implementations of the APIs
    supported by the module.
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

#include "device.h"
#include "system/reset/sys_reset.h"

void __attribute__((noreturn)) SYS_RESET_SoftwareReset(void)
{
<#if core.CoreArchitecture?contains("MIPS")>
    __builtin_disable_interrupts();

    /* Unlock System */
    SYSKEY = 0x00000000;
    SYSKEY = 0xAA996655;
    SYSKEY = 0x556699AA;

    RSWRSTSET = _RSWRST_SWRST_MASK;

    /* Read RSWRST register to trigger reset */
    (void) RSWRST;

    /* Prevent any unwanted code execution until reset occurs */
    while(1);
<#elseif core.CoreArchitecture?contains("ARM") || core.CoreArchitecture?contains("CORTEX-A")>
    /* Issue reset command */
    RSTC_REGS->RSTC_CR = RSTC_CR_KEY_PASSWD | RSTC_CR_PROCRST_Msk;
    /* Wait for command processing */
    while( RSTC_REGS->RSTC_SR & (uint32_t)RSTC_SR_SRCMP_Msk );

    /* Prevent any unwanted code execution until reset occurs */
    while(1);
<#else> <#-- it will be Cortex M Architecture -->
    NVIC_SystemReset();
</#if>
}

/*******************************************************************************
 End of File
*/
