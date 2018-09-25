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

// *****************************************************************************
// *****************************************************************************
// Section: Include Files
// *****************************************************************************
// *****************************************************************************

#include "driver/sdhc/src/drv_sdhc_local.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

/* FS Function registration table. */

const SYS_FS_MEDIA_FUNCTIONS sdhcMediaFunctions =
{
    .mediaStatusGet     = DRV_SDHC_IsAttached,
    .mediaGeometryGet   = DRV_SDHC_GeometryGet,
    .sectorRead         = DRV_SDHC_Read,
    .sectorWrite        = DRV_SDHC_Write,
    .eventHandlerset    = DRV_SDHC_EventHandlerSet,
    .commandStatusGet   = (void *)DRV_SDHC_CommandStatus,
    .open               = DRV_SDHC_Open,
    .close              = DRV_SDHC_Close,
    .tasks              = DRV_SDHC_Tasks
};

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
