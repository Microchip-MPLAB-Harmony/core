/*******************************************************************************
  Cache System Service Library Implementation Source File

  Company
    Microchip Technology Inc.

  File Name
    sys_cache.c

  Summary
    Cache System Service Library interface implementation.

  Description
    This file implements the interface to the Cache System Service Library.

*******************************************************************************/

// DOM-IGNORE-BEGIN
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
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
#include "device.h"
#include "system/cache/sys_cache.h"
<#if core.L2CC_ENABLE?? >
#include "peripheral/l2cc/plib_l2cc.h"
</#if>

#define DATA_CACHE_IS_ENABLED            (__get_SCTLR() & (uint32_t)SCTLR_C_Msk)
#define INSTRUCTION_CACHE_IS_ENABLED     (__get_SCTLR() & (uint32_t)SCTLR_I_Msk)
<#if core.L2CC_ENABLE?? >
#define L2_DATA_CACHE_IS_ENABLED         (L2CC_REGS->L2CC_CR & L2CC_CR_L2CEN_Msk)
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: Local Functions
// *****************************************************************************
// *****************************************************************************

<#if core.INSTRUCTION_CACHE_ENABLE?? >
/*
 * Enable Instruction Cache by setting I bit in SCTLR register.
 */
static inline void L1C_EnableICache(void)
{
    __set_SCTLR( __get_SCTLR() | SCTLR_I_Msk );
    __ISB();
}

/*
 * Disable Instruction Cache by clearing I bit in SCTLR register.
 */
static inline void L1C_DisableICache(void)
{
    __set_SCTLR( __get_SCTLR() & (~SCTLR_I_Msk) );
    __ISB();
}
</#if>

<#if core.DATA_CACHE_ENABLE?? >
/*
 * Enable Data Cache by setting C bit in SCTLR register.
 */
static inline void L1C_EnableDCache(void)
{
    __set_SCTLR( __get_SCTLR() | SCTLR_C_Msk );
    __ISB();
}

/*
 * Disable Data Cache by clearing C bit in SCTLR register.
 */
static inline void L1C_DisableDCache(void)
{
    __set_SCTLR( __get_SCTLR() & (~SCTLR_C_Msk) );
    __ISB();
}
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: System Cache Interface Functions
// *****************************************************************************
// *****************************************************************************

/*
 * Enables both Data and Instruction Caches by setting C and I bits in SCTLR register.
 */
void SYS_CACHE_EnableCaches (void)
{
<#if core.DATA_CACHE_ENABLE?? && core.INSTRUCTION_CACHE_ENABLE?? >
    <#lt>    if ((DATA_CACHE_IS_ENABLED == 0) && (INSTRUCTION_CACHE_IS_ENABLED == 0)) // If Data and Instruction Caches are disabled
    <#lt>    {
    <#lt>        L1C_EnableCaches();
    <#lt>    }
</#if>
}

/*
 * Disables both Data and Instruction Caches by clearing C and I bits in SCTLR register.
 */
void SYS_CACHE_DisableCaches (void)
{
<#if core.DATA_CACHE_ENABLE?? && core.INSTRUCTION_CACHE_ENABLE?? >
    <#lt>    if (DATA_CACHE_IS_ENABLED && INSTRUCTION_CACHE_IS_ENABLED) // If Data and Instruction Caches are enabled
    <#lt>    {
    <#lt>        L1C_DisableCaches();
    <#lt>    }
</#if>
}

void SYS_CACHE_EnableICache (void)
{
<#if core.INSTRUCTION_CACHE_ENABLE?? >
    <#lt>    if (INSTRUCTION_CACHE_IS_ENABLED == 0) // If Instruction Cache is disabled
    <#lt>    {
    <#lt>        L1C_EnableICache();
    <#lt>    }
</#if>
}

void SYS_CACHE_DisableICache (void)
{
<#if core.INSTRUCTION_CACHE_ENABLE?? >
    <#lt>    if (INSTRUCTION_CACHE_IS_ENABLED) // If Instruction Cache is enabled
    <#lt>    {
    <#lt>        L1C_DisableICache();
    <#lt>    }
</#if>
}

void SYS_CACHE_InvalidateICache (void)
{
<#if core.INSTRUCTION_CACHE_ENABLE?? >
    <#lt>    if (INSTRUCTION_CACHE_IS_ENABLED) // If Instruction Cache is enabled
    <#lt>    {
    <#lt>        L1C_InvalidateICacheAll();
    <#lt>    }
</#if>
}

void SYS_CACHE_EnableDCache (void)
{
<#if core.DATA_CACHE_ENABLE?? >
    <#lt>    if (DATA_CACHE_IS_ENABLED == 0) // If Data Cache is disabled
    <#lt>    {
    <#lt>        L1C_EnableDCache();
    <#lt>    }
</#if>
}

void SYS_CACHE_DisableDCache (void)
{
<#if core.DATA_CACHE_ENABLE?? >
    <#lt>    if (DATA_CACHE_IS_ENABLED) // If Data Cache is enabled
    <#lt>    {
    <#lt>        L1C_DisableDCache();
    <#lt>    }
</#if>
}

void SYS_CACHE_InvalidateDCache (void)
{
<#if core.DATA_CACHE_ENABLE?? >
    <#lt>    if (DATA_CACHE_IS_ENABLED)
    <#lt>    {
    <#lt>        L1C_InvalidateDCacheAll();
    <#lt>    }
</#if>

<#if core.L2CC_ENABLE?? && core.DATA_CACHE_ENABLE?? >
    <#lt>    if (L2_DATA_CACHE_IS_ENABLED && DATA_CACHE_IS_ENABLED)
    <#lt>    {
    <#lt>        PLIB_L2CC_InvalidateCache();
    <#lt>    }
</#if>
}

void SYS_CACHE_CleanDCache (void)
{
<#if core.DATA_CACHE_ENABLE?? >
    <#lt>    if (DATA_CACHE_IS_ENABLED)
    <#lt>    {
    <#lt>        L1C_CleanDCacheAll();
    <#lt>    }
</#if>

<#if core.L2CC_ENABLE?? && core.DATA_CACHE_ENABLE?? >
    <#lt>    if (L2_DATA_CACHE_IS_ENABLED && DATA_CACHE_IS_ENABLED)
    <#lt>    {
    <#lt>        PLIB_L2CC_CleanCache();
    <#lt>    }
</#if>
}

void SYS_CACHE_CleanInvalidateDCache (void)
{
<#if core.DATA_CACHE_ENABLE?? >
    <#lt>    if (DATA_CACHE_IS_ENABLED)
    <#lt>    {
    <#lt>        L1C_CleanInvalidateDCacheAll();
    <#lt>    }
</#if>

<#if core.L2CC_ENABLE?? && core.DATA_CACHE_ENABLE?? >
    <#lt>    if (L2_DATA_CACHE_IS_ENABLED && DATA_CACHE_IS_ENABLED)
    <#lt>    {
    <#lt>        PLIB_L2CC_CleanInvalidateCache();
    <#lt>    }
</#if>
}

void SYS_CACHE_InvalidateDCache_by_Addr (uint32_t *addr, int32_t size)
{
<#if core.L2CC_ENABLE?? && core.DATA_CACHE_ENABLE?? >
    <#lt>    if (L2_DATA_CACHE_IS_ENABLED && DATA_CACHE_IS_ENABLED)
    <#lt>    {
    <#lt>        PLIB_L2CC_InvalidateCacheByAddr(addr, size);
    <#lt>    }
</#if>

<#if core.DATA_CACHE_ENABLE?? >
    <#lt>    if (DATA_CACHE_IS_ENABLED)
    <#lt>    {
    <#lt>        L1C_InvalidateDCacheAll();
    <#lt>    }
</#if>
}

void SYS_CACHE_CleanDCache_by_Addr (uint32_t *addr, int32_t size)
{
<#if core.DATA_CACHE_ENABLE?? >
      <#lt>    if (DATA_CACHE_IS_ENABLED)
      <#lt>    {
      <#lt>        L1C_CleanDCacheAll();
      <#lt>    }
</#if>

<#if core.L2CC_ENABLE?? && core.DATA_CACHE_ENABLE?? >
      <#lt>    if (L2_DATA_CACHE_IS_ENABLED && DATA_CACHE_IS_ENABLED)
      <#lt>    {
      <#lt>        PLIB_L2CC_CleanCacheByAddr(addr, size);
      <#lt>    }
</#if>
}

void SYS_CACHE_CleanInvalidateDCache_by_Addr (uint32_t *addr, int32_t size)
{
<#if core.DATA_CACHE_ENABLE?? >
      <#lt>    if (L2_DATA_CACHE_IS_ENABLED || DATA_CACHE_IS_ENABLED)
      <#lt>    {
      <#lt>        L1C_CleanInvalidateDCacheAll();
      <#lt>    }
</#if>

<#if core.L2CC_ENABLE?? && core.DATA_CACHE_ENABLE?? >
      <#lt>    if (L2_DATA_CACHE_IS_ENABLED && DATA_CACHE_IS_ENABLED)
      <#lt>    {
      <#lt>        PLIB_L2CC_CleanInvalidateCacheByAddr(addr, size);
      <#lt>    }
</#if>
}
