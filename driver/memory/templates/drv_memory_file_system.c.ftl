/******************************************************************************
  MEMORY Driver File System Interface Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_memory_file_system.c

  Summary:
    MEMORY Driver Interface Definition

  Description:
    The MEMORY Driver provides a interface to access the MEMORY on the PIC32
    microcontroller. This file implements the MEMORY Driver file system interface.
    This file should be included in the project if MEMORY driver functionality with
    File system is needed.
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

// *****************************************************************************
// *****************************************************************************
// Section: Include Files
// *****************************************************************************
// *****************************************************************************

#include "driver/memory/src/drv_memory_local.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

/* FS Function registration table. */

<#if DRV_MEMORY_COMMON_MODE == "ASYNC" >
    <#lt>const SYS_FS_MEDIA_FUNCTIONS memoryMediaFunctions =
    <#lt>{
    <#lt>    .mediaStatusGet     = DRV_MEMORY_IsAttached,
    <#lt>    .mediaGeometryGet   = DRV_MEMORY_GeometryGet,
    <#lt>    .sectorRead         = DRV_MEMORY_AsyncRead,
    <#lt>    .sectorWrite        = DRV_MEMORY_AsyncEraseWrite,
    <#lt>    .eventHandlerset    = DRV_MEMORY_TransferHandlerSet,
    <#lt>    .commandStatusGet   = (void *)DRV_MEMORY_CommandStatusGet,
    <#lt>    .Read               = DRV_MEMORY_AsyncRead,
    <#lt>    .erase              = DRV_MEMORY_AsyncErase,
    <#lt>    .addressGet         = DRV_MEMORY_AddressGet,
    <#lt>    .open               = DRV_MEMORY_Open,
    <#lt>    .close              = DRV_MEMORY_Close,
    <#lt>    .tasks              = DRV_MEMORY_Tasks,
    <#lt>};
<#else>
    <#lt>const SYS_FS_MEDIA_FUNCTIONS memoryMediaFunctions =
    <#lt>{
    <#lt>    .mediaStatusGet     = DRV_MEMORY_IsAttached,
    <#lt>    .mediaGeometryGet   = DRV_MEMORY_GeometryGet,
    <#lt>    .sectorRead         = DRV_MEMORY_FS_Read,
    <#lt>    .sectorWrite        = DRV_MEMORY_FS_EraseWrite,
    <#lt>    .eventHandlerset    = DRV_MEMORY_TransferHandlerSet,
    <#lt>    .commandStatusGet   = (void *)DRV_MEMORY_CommandStatusGet,
    <#lt>    .Read               = DRV_MEMORY_FS_Read,
    <#lt>    .erase              = DRV_MEMORY_FS_Erase,
    <#lt>    .addressGet         = DRV_MEMORY_AddressGet,
    <#lt>    .open               = DRV_MEMORY_Open,
    <#lt>    .close              = DRV_MEMORY_Close,
    <#lt>    .tasks              = NULL,
    <#lt>};
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: MEMORY Driver File system interface Routines
// *****************************************************************************
// *****************************************************************************

void DRV_MEMORY_RegisterWithSysFs( const SYS_MODULE_INDEX drvIndex, uint8_t mediaType)
{
    SYS_FS_MEDIA_MANAGER_Register
    (
        (SYS_MODULE_OBJ)drvIndex,
        (SYS_MODULE_INDEX)drvIndex,
        &memoryMediaFunctions,
        (SYS_FS_MEDIA_TYPE)mediaType
    );
}
