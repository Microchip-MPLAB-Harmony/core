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
Copyright (c) 2016 - 2017 released Microchip Technology Inc. All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED AS IS WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR
CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF
SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
*******************************************************************************/
//DOM-IGNORE-END

#ifndef _DRV_MEMORY_VARIANT_MAPPING_H
#define _DRV_MEMORY_VARIANT_MAPPING_H

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

