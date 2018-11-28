/******************************************************************************
  SDHC Driver File System Interface Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdhc_file_system.c

  Summary:
    SDHC Driver Interface Definition

  Description:
    The SDHC Driver provides a interface to access the SDHC on the PIC32
    microcontroller. This file implements the SDHC Driver file system interface.
    This file should be included in the project if SDHC driver functionality with
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

#include "driver/sdhc/drv_sdhc.h"
#include "system/fs/sys_fs_media_manager.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

/* FS Function registration table. */

<#if DRV_SDHC_COMMON_MODE == "Asynchronous" >
    <#lt>const SYS_FS_MEDIA_FUNCTIONS sdhcMediaFunctions =
    <#lt>{
    <#lt>    .mediaStatusGet     = DRV_SDHC_IsAttached,
    <#lt>    .mediaGeometryGet   = DRV_SDHC_GeometryGet,
    <#lt>    .sectorRead         = DRV_SDHC_AsyncRead,
    <#lt>    .sectorWrite        = DRV_SDHC_AsyncWrite,
    <#lt>    .eventHandlerset    = DRV_SDHC_EventHandlerSet,
    <#lt>    .commandStatusGet   = (void *)DRV_SDHC_CommandStatusGet,
    <#lt>    .Read               = DRV_SDHC_AsyncRead,
    <#lt>    .erase              = NULL,
    <#lt>    .addressGet         = NULL,
    <#lt>    .open               = DRV_SDHC_Open,
    <#lt>    .close              = DRV_SDHC_Close,
    <#lt>    .tasks              = DRV_SDHC_Tasks,
    <#lt>};
<#else>
    <#lt>const SYS_FS_MEDIA_FUNCTIONS sdhcMediaFunctions =
    <#lt>{
    <#lt>    .mediaStatusGet     = DRV_SDHC_IsAttached,
    <#lt>    .mediaGeometryGet   = DRV_SDHC_GeometryGet,
    <#lt>    .sectorRead         = DRV_SDHC_Read,
    <#lt>    .sectorWrite        = DRV_SDHC_Write,
    <#lt>    .eventHandlerset    = DRV_SDHC_EventHandlerSet,
    <#lt>    .commandStatusGet   = (void *)DRV_SDHC_CommandStatusGet,
    <#lt>    .Read               = DRV_SDHC_Read,
    <#lt>    .erase              = NULL,
    <#lt>    .addressGet         = NULL,
    <#lt>    .open               = DRV_SDHC_Open,
    <#lt>    .close              = DRV_SDHC_Close,
    <#lt>    .tasks              = NULL,
    <#lt>};
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: SDHC Driver File system interface Routines
// *****************************************************************************
// *****************************************************************************

void DRV_SDHC_RegisterWithSysFs( const SYS_MODULE_INDEX drvIndex)
{
    SYS_FS_MEDIA_MANAGER_Register
    (
        (SYS_MODULE_OBJ)drvIndex,
        (SYS_MODULE_INDEX)drvIndex,
        &sdhcMediaFunctions,
        SYS_FS_MEDIA_TYPE_SD_CARD
    );
}
