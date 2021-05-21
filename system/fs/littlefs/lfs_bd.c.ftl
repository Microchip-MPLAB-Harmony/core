/*
 * Testing block device, wraps filebd and rambd while providing a bunch
 * of hooks for testing littlefs in various conditions.
 *
 * Copyright (c) 2017, Arm Limited. All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 */
#include "lfs_bd.h"

#include <stdlib.h>
#include "system/fs/sys_fs_media_manager.h"

<#if SYS_FS_ALIGNED_BUFFER_ENABLE?? && SYS_FS_ALIGNED_BUFFER_ENABLE == true>
    <#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
        <#lt>#include "sys/kmem.h"
    </#if>

    <#lt>#define CACHE_ALIGN_CHECK  (CACHE_LINE_SIZE - 1)

    <#lt>typedef struct
    <#lt>{
    <#lt>    uint8_t alignedBuffer[SYS_FS_ALIGNED_BUFFER_LEN] __ALIGNED(CACHE_LINE_SIZE);
    <#lt>    SYS_FS_MEDIA_COMMAND_STATUS commandStatus;
    <#lt>    SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE commandHandle;
    <#lt>} SYS_FS_BD_DATA;
<#else>
    <#lt>typedef struct
    <#lt>{
    <#lt>    SYS_FS_MEDIA_COMMAND_STATUS commandStatus;
    <#lt>    SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE commandHandle;
    <#lt>} SYS_FS_BD_DATA;
</#if>

static SYS_FS_BD_DATA CACHE_ALIGN gSysFsDiskData[SYS_FS_MEDIA_NUMBER];

void bdEventHandler
(
    SYS_FS_MEDIA_BLOCK_EVENT event,
    SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE commandHandle,
    uintptr_t context
)
{
    switch(event)
    {
        case SYS_FS_MEDIA_EVENT_BLOCK_COMMAND_COMPLETE:
            gSysFsDiskData[context].commandStatus = SYS_FS_MEDIA_COMMAND_COMPLETED;
            break;
        case SYS_FS_MEDIA_EVENT_BLOCK_COMMAND_ERROR:
            gSysFsDiskData[context].commandStatus= SYS_FS_MEDIA_COMMAND_UNKNOWN;
            break;
        default:
            break;
    }
}

static BDSTATUS bd_checkCommandStatus(uint8_t pdrv)
{
    BDSTATUS result = RES_ERROR;

    /* Buffer is invalid report error */
    if (gSysFsDiskData[pdrv].commandHandle == SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID)
    {
        result = RES_PARERR;
    }
    else
    {
        /* process the read request by blocking on the task routine that process the
         I/O request */
        while (gSysFsDiskData[pdrv].commandStatus == SYS_FS_MEDIA_COMMAND_IN_PROGRESS)
        {
            SYS_FS_MEDIA_MANAGER_TransferTask (pdrv);
        }


        if (gSysFsDiskData[pdrv].commandStatus == SYS_FS_MEDIA_COMMAND_COMPLETED)
        {
            /* Buffer processed successfully */
            result = RES_OK;
        }
    }
    
    return result;
}

BDSTATUS lfs_bd_initilize (
    uint8_t pdrv                /* Physical drive nmuber to identify the drive */
)
{
    switch( pdrv ) {
    case 0:
    default:
        break;
    }

    SYS_FS_MEDIA_MANAGER_RegisterTransferHandler( (void *) bdEventHandler );
    return 0;
}

/// block device API ///
int lfs_bd_read(const struct lfs_config *cfg, lfs_block_t block,
        lfs_off_t off, void *buffer, lfs_size_t size) {
    
    BDSTATUS result = RES_ERROR;
    BLOCK_DEV *bd = cfg->context;

<#if SYS_FS_ALIGNED_BUFFER_ENABLE?? && SYS_FS_ALIGNED_BUFFER_ENABLE == true>
    uint8_t* data;    
    uint32_t bytesToTransfer    = 0;
    uint32_t currentXferLen     = 0;
    uint32_t sectorXferCntr     = 0;
    
    data = (uint8_t*) buffer;

    <#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
        <#lt>    /* Use Aligned Buffer if input buffer is in Cacheable address space and
        <#lt>     * is not aligned to cache line size */
        <#lt>    if ((IS_KVA0((uint8_t *)buffer) == true) && (((uint32_t)buffer & CACHE_ALIGN_CHECK) != 0))
    <#else>
        <#lt>    /* Use Aligned Buffer if input buffer is not aligned to cache line size */
        <#lt>    if (((uint32_t)buffer & CACHE_ALIGN_CHECK) != 0)
    </#if>
    {
        bytesToTransfer = size;

        while (bytesToTransfer > 0)
        {
            /* Calculate the number of sectors to be transferred with current request */
            if (bytesToTransfer > SYS_FS_ALIGNED_BUFFER_LEN)
            {
                sectorXferCntr  = (SYS_FS_ALIGNED_BUFFER_LEN / SYS_FS_LFS_MAX_SS);
                currentXferLen  = SYS_FS_ALIGNED_BUFFER_LEN;
            }
            else
            {
                sectorXferCntr  = (bytesToTransfer / SYS_FS_LFS_MAX_SS);
                currentXferLen  = bytesToTransfer;
            }

            gSysFsDiskData[bd->disk_num].commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;

            gSysFsDiskData[bd->disk_num].commandHandle = SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;

            /* Submit the read request to media */
            gSysFsDiskData[bd->disk_num].commandHandle = SYS_FS_MEDIA_MANAGER_SectorRead(bd->disk_num /* DISK Number */ ,
                    gSysFsDiskData[bd->disk_num].alignedBuffer /* Destination Buffer*/,
                    block* (cfg->block_size/ cfg->read_size) /* Source Sector */,
                    sectorXferCntr /* Number of Sectors */);

            result = bd_checkCommandStatus(bd->disk_num);

            if (result != RES_OK)
            {
                break;
            }

            /* Copy the received data from aligned buffer to actual buffer */
            memcpy(data, gSysFsDiskData[bd->disk_num].alignedBuffer, currentXferLen);

            bytesToTransfer -= currentXferLen;
            data            += currentXferLen;
            block          += sectorXferCntr;
        }
    }
    else
</#if>
    {
        gSysFsDiskData[bd->disk_num].commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;
        gSysFsDiskData[bd->disk_num].commandHandle = SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;

        LFS_TRACE("[%s] block = %d, size = %d, off = %d\r\n", __func__, (int) block, (int) size, (int) off );
        gSysFsDiskData[bd->disk_num].commandHandle =  SYS_FS_MEDIA_MANAGER_SectorRead(bd->disk_num, (uint8_t*) buffer, block* (cfg->block_size/ cfg->read_size),  (size/cfg->read_size) );

       result = bd_checkCommandStatus(bd->disk_num);

        if (result != RES_OK)
        {
            return LFS_ERR_IO;
        }
    }
    
    return LFS_ERR_OK;
}

int lfs_bd_prog(const struct lfs_config *cfg, lfs_block_t block,
        lfs_off_t off, const void *buffer, lfs_size_t size) {
    
    BDSTATUS result = RES_ERROR;
    BLOCK_DEV *bd = cfg->context;
    
<#if SYS_FS_ALIGNED_BUFFER_ENABLE?? && SYS_FS_ALIGNED_BUFFER_ENABLE == true>
    uint8_t* data;
    uint32_t bytesToTransfer    = 0;
    uint32_t currentXferLen     = 0;
    uint32_t sectorXferCntr     = 0;

    data = (uint8_t*) buffer;

    <#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
        <#lt>    /* Use Aligned Buffer if input buffer is in Cacheable address space and
        <#lt>     * is not aligned to cache line size */
        <#lt>    if ((IS_KVA0((uint8_t *)buffer) == true) && (((uint32_t)buffer & CACHE_ALIGN_CHECK) != 0))
    <#else>
        <#lt>    /* Use Aligned Buffer if input buffer is not aligned to cache line size */
        <#lt>    if (((uint32_t)buffer & CACHE_ALIGN_CHECK) != 0)
    </#if>
    {
        bytesToTransfer = size;

        while (bytesToTransfer > 0)
        {
            /* Calculate the number of sectors to be transferred with current request */
            if (bytesToTransfer > SYS_FS_ALIGNED_BUFFER_LEN)
            {
                sectorXferCntr  = (SYS_FS_ALIGNED_BUFFER_LEN / SYS_FS_LFS_MAX_SS);
                currentXferLen  = SYS_FS_ALIGNED_BUFFER_LEN;
            }
            else
            {
                sectorXferCntr  = (bytesToTransfer / SYS_FS_LFS_MAX_SS);
                currentXferLen  = bytesToTransfer;
            }

            gSysFsDiskData[bd->disk_num].commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;

            gSysFsDiskData[bd->disk_num].commandHandle = SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;

            /* Copy the actual buffer data into aligned buffer */
            memcpy(gSysFsDiskData[bd->disk_num].alignedBuffer, data, currentXferLen);

            /* Submit the write request to media */
            gSysFsDiskData[bd->disk_num].commandHandle = SYS_FS_MEDIA_MANAGER_SectorWrite(bd->disk_num /* DISK Number */ ,
                    block * cfg->block_size/SYS_FS_LFS_MAX_SS /* Destination Sector*/,
                    gSysFsDiskData[bd->disk_num].alignedBuffer /* Source Buffer */,
                    sectorXferCntr /* Number of Sectors */);

            result = bd_checkCommandStatus(bd->disk_num);

            if (result != RES_OK)
            {
                break;
            }

            bytesToTransfer -= currentXferLen;
            data            += currentXferLen;
            block          += sectorXferCntr;
        }
    }
    else
</#if>
    {
        gSysFsDiskData[bd->disk_num].commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;
        gSysFsDiskData[bd->disk_num].commandHandle = SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;

       gSysFsDiskData[bd->disk_num].commandHandle =  SYS_FS_MEDIA_MANAGER_SectorWrite(bd->disk_num, block * cfg->block_size/SYS_FS_LFS_MAX_SS, (uint8_t*) buffer,  size/ SYS_FS_LFS_MAX_SS);      

       result = bd_checkCommandStatus(bd->disk_num);
        if (result != RES_OK)
        {
            return RES_ERROR;
        }
    }
    return 0;
}

int lfs_bd_erase(const struct lfs_config *cfg, lfs_block_t block) {
    BDSTATUS result = RES_ERROR;
    BLOCK_DEV *bd = cfg->context;
    uint8_t buffer[SYS_FS_LFS_MAX_SS];
    memset(buffer, 0xff, sizeof(buffer));

    gSysFsDiskData[bd->disk_num].commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;
    gSysFsDiskData[bd->disk_num].commandHandle = SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;
    
    gSysFsDiskData[bd->disk_num].commandHandle =  SYS_FS_MEDIA_MANAGER_SectorWrite(bd->disk_num, block * cfg->block_size/SYS_FS_LFS_MAX_SS, (uint8_t*) buffer,  1);
   
    result = bd_checkCommandStatus(bd->disk_num);

    if (result != RES_OK)
    {
        return RES_ERROR;
    }
    return result;
}

int lfs_bd_sync(const struct lfs_config *cfg) {
    
    LFS_TRACE("[%s] In\r\n", __func__);
    return 0;
}


