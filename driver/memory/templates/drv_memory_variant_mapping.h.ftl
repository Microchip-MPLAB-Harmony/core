/*******************************************************************************
  MEMORY Driver Feature Variant Implementations

  Company:
    Microchip Technology Inc.

  File Name:
    drv_memory_variant_mapping.h

  Summary:
    MEMORY Driver Feature Variant Implementations

  Description:
    This file implements the functions which differ based on different parts
    and various implementations of the same feature.
*******************************************************************************/

//DOM-IGNORE-BEGIN
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
//DOM-IGNORE-END

#ifndef _DRV_MEMORY_VARIANT_MAPPING_H
#define _DRV_MEMORY_VARIANT_MAPPING_H

<#if DRV_MEMORY_COMMON_SYS_TIME_ENABLE >
    <#lt>#include "system/time/sys_time.h"
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: Feature Variant Mapping
// *****************************************************************************
// *****************************************************************************
/* Some variants are determined by hardware feature existence, some features
   are determined user configuration of the driver, and some variants are
   combination of the two.
*/

<#if DRV_MEMORY_COMMON_FS_ENABLE >
    <#lt>#include "system/fs/sys_fs_media_manager.h"
    <#lt>
    <#lt>// *****************************************************************************
    <#lt>

    <#lt>/* Registers the MEMORY driver services with the File System */

    <#lt>void DRV_MEMORY_RegisterWithSysFs( const SYS_MODULE_INDEX drvIndex, uint8_t mediaType);

    <#if DRV_MEMORY_COMMON_MODE == "SYNC" >
        <#lt>void DRV_MEMORY_FS_Erase
        <#lt>(
        <#lt>    const DRV_HANDLE handle,
        <#lt>    SYS_MEDIA_BLOCK_COMMAND_HANDLE *commandHandle,
        <#lt>    uint32_t blockStart,
        <#lt>    uint32_t nBlock
        <#lt>);

        <#lt>void DRV_MEMORY_FS_EraseWrite
        <#lt>(
        <#lt>    const DRV_HANDLE handle,    
        <#lt>    SYS_MEDIA_BLOCK_COMMAND_HANDLE *commandHandle,
        <#lt>    void *sourceBuffer,
        <#lt>    uint32_t blockStart,
        <#lt>    uint32_t nBlock
        <#lt>);

        <#lt>void DRV_MEMORY_FS_Write
        <#lt>(
        <#lt>    const DRV_HANDLE handle,        
        <#lt>    SYS_MEDIA_BLOCK_COMMAND_HANDLE *commandHandle,
        <#lt>    void *sourceBuffer,
        <#lt>    uint32_t blockStart,
        <#lt>    uint32_t nBlock
        <#lt>);

        <#lt>void DRV_MEMORY_FS_Read
        <#lt>(
        <#lt>    const DRV_HANDLE handle,
        <#lt>    SYS_MEDIA_BLOCK_COMMAND_HANDLE *commandHandle,
        <#lt>    void *targetBuffer,
        <#lt>    uint32_t blockStart,
        <#lt>    uint32_t nBlock
        <#lt>);
    </#if>
</#if>

#endif //_DRV_MEMORY_VARIANT_MAPPING_H

/*******************************************************************************
 End of File
*/

