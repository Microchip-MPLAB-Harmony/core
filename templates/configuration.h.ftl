/*******************************************************************************
  System Configuration Header

  File Name:
    configuration.h

  Summary:
    Build-time configuration header for the system defined by this project.

  Description:
    An MPLAB Project may have multiple configurations.  This file defines the
    build-time options for a single configuration.

  Remarks:
    This configuration header must not define any prototypes or data
    definitions (or include any files that do).  It only provides macro
    definitions for build-time configuration options

*******************************************************************************/

// DOM-IGNORE-BEGIN
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
// DOM-IGNORE-END

#ifndef CONFIGURATION_H
#define CONFIGURATION_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
/*  This section Includes other configuration headers necessary to completely
    define this configuration.
*/
${core.LIST_SYSTEM_CONFIG_H_GLOBAL_INCLUDES}
#include "user.h"
#include "toolchain_specifics.h"
<#if __PROCESSOR?matches("ATSAMA5.*")>
<#if core.L2CC_ENABLE == true >
#include <stdint.h>
#include "peripheral/l2cc/plib_l2cc.h"
</#if>
</#if>

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

extern "C" {

#endif
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: System Configuration
// *****************************************************************************
// *****************************************************************************
<#if core.DATA_CACHE_ENABLE?? >
<#if __PROCESSOR?matches("ATSAMA5.*")>
    <#lt>#define DCACHE_CLEAN_BY_ADDR(data, size)       <#if core.L2CC_ENABLE == true >PLIB_L2CC_CleanCacheByAddr((uint32_t*)data, size);</#if><#if core.L2CC_ENABLE == true || core.DATA_CACHE_ENABLE == true> \
    <#lt>                                               L1C_CleanDCacheAll()</#if>
    <#lt>#define DCACHE_INVALIDATE_BY_ADDR(data, size)  <#if core.L2CC_ENABLE == true || core.DATA_CACHE_ENABLE == true >L1C_InvalidateDCacheAll()</#if><#if core.L2CC_ENABLE == true >; \
    <#lt>                                               PLIB_L2CC_InvalidateCacheByAddr((uint32_t*)data, size)</#if>
<#else>
    <#lt>#define DCACHE_CLEAN_BY_ADDR(data, size)       SCB_CleanDCache_by_Addr((uint32_t *)data, size)
    <#lt>#define DCACHE_INVALIDATE_BY_ADDR(data, size)  SCB_InvalidateDCache_by_Addr((uint32_t *)data, size)
</#if>
    <#if core.DATA_CACHE_ENABLE == true >
        <#lt>#define DATA_CACHE_ENABLED                     true
    <#else>
        <#lt>#define DATA_CACHE_ENABLED                     false
    </#if>
<#else>
    <#lt>#define DCACHE_CLEAN_BY_ADDR(data, size)
    <#lt>#define DCACHE_INVALIDATE_BY_ADDR(data, size)

    <#lt>#define DATA_CACHE_ENABLED                         false
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: System Service Configuration
// *****************************************************************************
// *****************************************************************************
${core.LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION}

// *****************************************************************************
// *****************************************************************************
// Section: Driver Configuration
// *****************************************************************************
// *****************************************************************************
${core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION}

// *****************************************************************************
// *****************************************************************************
// Section: Middleware & Other Library Configuration
// *****************************************************************************
// *****************************************************************************
${core.LIST_SYSTEM_CONFIG_H_MIDDLEWARE_CONFIGURATION}

// *****************************************************************************
// *****************************************************************************
// Section: Application Configuration
// *****************************************************************************
// *****************************************************************************
${core.LIST_SYSTEM_CONFIG_H_APPLICATION_CONFIGURATION}

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

#endif // CONFIGURATION_H
/*******************************************************************************
 End of File
*/
