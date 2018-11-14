/******************************************************************************
  SD Card Library Interface Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdcard.c

  Summary:
    SD Card Driver Library Interface implementation

  Description:
    The SD Card Library provides a common interface to read/write to SD Card
    running differnt protocols.
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

// *****************************************************************************
// *****************************************************************************
// Section: Include Files
// *****************************************************************************
// *****************************************************************************
#include "configuration.h"
#include "drv_sdcard.h"
#include "drv_sdcard_local.h"

static DRV_SDCARD_OBJ gDrvSDCARDObj[DRV_SDCARD_INSTANCES_NUMBER];

void __attribute__ ((weak)) DRV_SDCARD_RegisterWithSysFs
(
    const SYS_MODULE_INDEX drvIndex
)
{
    /* Weak function to avoid compiler warning when registration with FS is
     * not enabled. */
}

SYS_MODULE_OBJ DRV_SDCARD_Initialize(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT * const init
)
{
    const DRV_SDCARD_INIT* sdCardInit = (const DRV_SDCARD_INIT *)init;
    DRV_SDCARD_OBJ* dObj = NULL;
    SYS_MODULE_OBJ sysObj = SYS_MODULE_OBJ_INVALID;

    /* Validate the request */
    if(drvIndex >= DRV_SDCARD_INSTANCES_NUMBER)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    dObj = &gDrvSDCARDObj[drvIndex];

    dObj->sdCardIntf = sdCardInit;

    sysObj = dObj->sdCardIntf->initialize(drvIndex, dObj->sdCardIntf->sdDriverInitData);
    
    /* Register with file system*/
    if (sysObj != SYS_MODULE_OBJ_INVALID)
    {
        if (sdCardInit->isFsEnabled == true)
        {
            DRV_SDCARD_RegisterWithSysFs(drvIndex);
        }
    }

    return sysObj;
}

DRV_HANDLE DRV_SDCARD_Open(const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent)
{
    return gDrvSDCARDObj[0].sdCardIntf->open(drvIndex, ioIntent);
}
SYS_STATUS DRV_SDCARD_Status( SYS_MODULE_OBJ object )
{
    return gDrvSDCARDObj[0].sdCardIntf->status(object);
}
void DRV_SDCARD_Tasks ( SYS_MODULE_OBJ object )
{
    gDrvSDCARDObj[0].sdCardIntf->tasks(object);
}
void DRV_SDCARD_Close(const DRV_HANDLE handle)
{
    gDrvSDCARDObj[0].sdCardIntf->close(handle);
}
bool DRV_SDCARD_IsAttached(const DRV_HANDLE handle)
{
    return gDrvSDCARDObj[0].sdCardIntf->isAttached(handle);
}
bool DRV_SDCARD_IsWriteProtected( const DRV_HANDLE handle )
{
    return gDrvSDCARDObj[0].sdCardIntf->isWriteProtected(handle);
}
DRV_SDCARD_COMMAND_STATUS DRV_SDCARD_CommandStatus( const DRV_HANDLE handle, const DRV_SDCARD_COMMAND_HANDLE commandHandle )
{
    return gDrvSDCARDObj[0].sdCardIntf->commandStatus(handle, commandHandle);
}
void DRV_SDCARD_EventHandlerSet( const DRV_HANDLE handle, const void * eventHandler, const uintptr_t context )
{
    gDrvSDCARDObj[0].sdCardIntf->eventHandlerSet(handle, eventHandler, context);
}
SYS_MEDIA_GEOMETRY * DRV_SDCARD_GeometryGet ( const DRV_HANDLE handle )
{
    return gDrvSDCARDObj[0].sdCardIntf->geometryGet(handle);
}

bool DRV_SDCARD_SyncRead (
    const DRV_HANDLE handle,
    void* targetBuffer,
    uint32_t blockStart,
    uint32_t nBlock
)
{
    if (gDrvSDCARDObj[0].sdCardIntf->readSync != NULL)
    {
        return gDrvSDCARDObj[0].sdCardIntf->readSync(handle, targetBuffer, blockStart, nBlock);
    }
    return false;
}

bool DRV_SDCARD_SyncWrite(
    const DRV_HANDLE handle,
    void* sourceBuffer,
    uint32_t blockStart,
    uint32_t nBlock
)
{
    if (gDrvSDCARDObj[0].sdCardIntf->writeSync != NULL)
    {
        return gDrvSDCARDObj[0].sdCardIntf->writeSync(handle, sourceBuffer, blockStart, nBlock);
    }
    return false;
}

void DRV_SDCARD_AsyncRead (
    const DRV_HANDLE handle,
    DRV_SDCARD_COMMAND_HANDLE* commandHandle,
    void* targetBuffer,
    uint32_t blockStart,
    uint32_t nBlock
)
{
    if (gDrvSDCARDObj[0].sdCardIntf->readAsync != NULL)
    {
        gDrvSDCARDObj[0].sdCardIntf->readAsync(handle, commandHandle, targetBuffer, blockStart, nBlock);
    }
}

void DRV_SDCARD_AsyncWrite(
    const DRV_HANDLE handle,
    DRV_SDCARD_COMMAND_HANDLE* commandHandle,
    void* sourceBuffer,
    uint32_t blockStart,
    uint32_t nBlock
)
{
    if (gDrvSDCARDObj[0].sdCardIntf->writeAsync != NULL)
    {
        gDrvSDCARDObj[0].sdCardIntf->writeAsync(handle, commandHandle, sourceBuffer, blockStart, nBlock);
    }
}

void DRV_SDCARD_FS_Read(
    const DRV_HANDLE handle,
    DRV_SDCARD_COMMAND_HANDLE* commandHandle,
    void* targetBuffer,
    uint32_t blockStart,
    uint32_t nBlock
)
{
    if (gDrvSDCARDObj[0].sdCardIntf->fsRead != NULL)
    {
        gDrvSDCARDObj[0].sdCardIntf->fsRead(handle, commandHandle, targetBuffer, blockStart, nBlock);
    }
}

void DRV_SDCARD_FS_Write(
    const DRV_HANDLE handle,
    DRV_SDCARD_COMMAND_HANDLE* commandHandle,
    void* sourceBuffer,
    uint32_t blockStart,
    uint32_t nBlock
)
{
    if (gDrvSDCARDObj[0].sdCardIntf->fsWrite != NULL)
    {
        gDrvSDCARDObj[0].sdCardIntf->fsWrite(handle, commandHandle, sourceBuffer, blockStart, nBlock);
    }
}
