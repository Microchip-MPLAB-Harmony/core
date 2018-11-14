/******************************************************************************
  SDCARD Driver File System Interface Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdcard_file_system.c

  Summary:
    SDCARD Driver Interface Definition

  Description:
    The SDCARD Driver provides a interface to access the SDCARD on the PIC32
    microcontroller. This file implements the SDCARD Driver file system interface.
    This file should be included in the project if SDCARD driver functionality with
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

#include "driver/sdcard/drv_sdcard_local.h"
#include "system/fs/sys_fs_media_manager.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

/* FS Function registration table. */

const SYS_FS_MEDIA_FUNCTIONS sdcardMediaFunctions =
{
    .mediaStatusGet     = DRV_SDCARD_IsAttached,
    .mediaGeometryGet   = DRV_SDCARD_GeometryGet,
    .sectorRead         = DRV_SDCARD_FS_Read,
    .sectorWrite        = DRV_SDCARD_FS_Write,
    .eventHandlerset    = DRV_SDCARD_EventHandlerSet,
    .commandStatusGet   = (void *)DRV_SDCARD_CommandStatus,
    .Read               = DRV_SDCARD_FS_Read,
    .erase              = NULL,
    .addressGet         = NULL,
    .open               = DRV_SDCARD_Open,
    .close              = DRV_SDCARD_Close,
    .tasks              = DRV_SDCARD_Tasks,
};

// *****************************************************************************
// *****************************************************************************
// Section: SDCARD Driver File system interface Routines
// *****************************************************************************
// *****************************************************************************

/* Registers the SDCARD driver services with the File System */
void DRV_SDCARD_RegisterWithSysFs( const SYS_MODULE_INDEX drvIndex);

void DRV_SDCARD_RegisterWithSysFs( const SYS_MODULE_INDEX drvIndex)
{
    SYS_FS_MEDIA_MANAGER_Register
    (
        (SYS_MODULE_OBJ)drvIndex,
        (SYS_MODULE_INDEX)drvIndex,
        &sdcardMediaFunctions,
        (SYS_FS_MEDIA_TYPE)SYS_FS_MEDIA_TYPE_SD_CARD
    );
}
