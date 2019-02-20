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
#include "device_cache.h"
#include "system/cache/sys_cache.h"

<#if !__PROCESSOR?matches("ATSAME5.*") >
#define DATA_CACHE_IS_ENABLED()            (SCB->CCR & (uint32_t)SCB_CCR_DC_Msk)
#define INSTRUCTION_CACHE_IS_ENABLED()     (SCB->CCR & (uint32_t)SCB_CCR_IC_Msk)
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: System Cache Interface Functions
// *****************************************************************************
// *****************************************************************************
void SYS_CACHE_EnableCaches (void)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if ((INSTRUCTION_CACHE_IS_ENABLED() == 0) && (DATA_CACHE_IS_ENABLED() == 0)) // If Data and Instruction Caches are disabled
    <#lt>    {
    <#lt>        ICACHE_ENABLE();
    <#lt>        DCACHE_ENABLE();
    <#lt>    }
</#if>
}

void SYS_CACHE_DisableCaches (void)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if (INSTRUCTION_CACHE_IS_ENABLED() && DATA_CACHE_IS_ENABLED()) // If Data and Instruction Caches are enabled
    <#lt>    {
    <#lt>        DCACHE_DISABLE();
    <#lt>        ICACHE_DISABLE();
    <#lt>    }
</#if>
}
void SYS_CACHE_EnableICache (void)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if (INSTRUCTION_CACHE_IS_ENABLED() == 0) // If Instruction Cache is disabled
    <#lt>    {
    <#lt>        ICACHE_ENABLE();
    <#lt>    }
</#if>
}

void SYS_CACHE_DisableICache (void)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if (INSTRUCTION_CACHE_IS_ENABLED()) // If Instruction Cache is enabled
    <#lt>    {
    <#lt>        ICACHE_DISABLE();
    <#lt>    }
</#if>
}

void SYS_CACHE_InvalidateICache (void)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if (INSTRUCTION_CACHE_IS_ENABLED()) // If Instruction Cache is enabled
    <#lt>    {
    <#lt>        ICACHE_INVALIDATE();
    <#lt>    }
</#if>
}

void SYS_CACHE_EnableDCache (void)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if (DATA_CACHE_IS_ENABLED() == 0) // If Data Cache is disabled
    <#lt>    {
    <#lt>        DCACHE_ENABLE();
    <#lt>    }
</#if>
}

void SYS_CACHE_DisableDCache (void)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if (DATA_CACHE_IS_ENABLED()) // If Data Cache is enabled
    <#lt>    {
    <#lt>        DCACHE_DISABLE();
    <#lt>    }
</#if>
}

void SYS_CACHE_InvalidateDCache (void)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if (DATA_CACHE_IS_ENABLED()) // If Data Cache is enabled
    <#lt>    {
    <#lt>        DCACHE_INVALIDATE();
    <#lt>    }
</#if>
}

void SYS_CACHE_CleanDCache (void)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if (DATA_CACHE_IS_ENABLED()) // If Data Cache is enabled
    <#lt>    {
    <#lt>        DCACHE_CLEAN();
    <#lt>    }
</#if>
}

void SYS_CACHE_CleanInvalidateDCache (void)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if (DATA_CACHE_IS_ENABLED()) // If Data Cache is enabled
    <#lt>    {
    <#lt>        DCACHE_CLEAN_INVALIDATE();
    <#lt>    }
</#if>
}

void SYS_CACHE_InvalidateDCache_by_Addr (uint32_t *addr, int32_t size)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if (DATA_CACHE_IS_ENABLED()) // If Data Cache is enabled
    <#lt>    {
    <#lt>        DCACHE_INVALIDATE_BY_ADDR(addr, size);
    <#lt>    }
</#if>
}

void SYS_CACHE_CleanDCache_by_Addr (uint32_t *addr, int32_t size)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if (DATA_CACHE_IS_ENABLED()) // If Data Cache is enabled
    <#lt>    {
    <#lt>        DCACHE_CLEAN_BY_ADDR(addr, size);
    <#lt>    }
</#if>
}

void SYS_CACHE_CleanInvalidateDCache_by_Addr (uint32_t *addr, int32_t size)
{
<#if !__PROCESSOR?matches("ATSAME5.*") >
    <#lt>    if (DATA_CACHE_IS_ENABLED()) // If Data Cache is enabled
    <#lt>    {
    <#lt>        DCACHE_CLEAN_INVALIDATE_BY_ADDR(addr, size);
    <#lt>    }
</#if>
}
