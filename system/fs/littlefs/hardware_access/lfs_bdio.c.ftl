/*******************************************************************************
  Low Level Block Deivce Interface Implementation.

  Company:
    Microchip Technology Inc.

  File Name:
    lfs_bdio.c

  Summary:
    This file contains implementation of Low Level Block Deivce Interface functions 
    which hooking to LFS library.

  Description:
    This file contains implementation of Low Level Block Deivce Interface functions 
    which hooking to LFS library.
*******************************************************************************/

/*******************************************************************************
* Copyright (C) 2020 Microchip Technology Inc. and its subsidiaries.
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
 
#include "lfs_bdio.h"

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

static BDSTATUS disk_read_aligned
(
    uint8_t pdrv,   /* Physical drive nmuber (0..) */
    uint8_t *buff,  /* Data buffer to store read data */
    uint32_t sector,/* Sector address (LBA) */
    uint32_t sector_count   /* Number of sectors to read (1..128) */
)
{
    BDSTATUS result = RES_ERROR;

    gSysFsDiskData[pdrv].commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;

    gSysFsDiskData[pdrv].commandHandle = SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;

    /* Submit the read request to media */
    gSysFsDiskData[pdrv].commandHandle = SYS_FS_MEDIA_MANAGER_SectorRead(pdrv /* DISK Number */ ,
            buff /* Destination Buffer*/,
            sector /* Source Sector */,
            sector_count /* Number of Sectors */);

    result = bd_checkCommandStatus(pdrv);

    return result;
}

BDSTATUS lfs_bdio_initilize (
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
int lfs_bdio_read(const struct lfs_config *cfg, lfs_block_t block,
        lfs_off_t off, void *buffer, lfs_size_t size) {
    
    BDSTATUS result = RES_ERROR;
    BLOCK_DEV *bd = cfg->context;
    uint32_t sector = block * (cfg->block_size/ SYS_FS_LFS_MAX_SS);
    uint32_t count = size/ SYS_FS_LFS_MAX_SS;

<#if SYS_FS_ALIGNED_BUFFER_ENABLE?? && SYS_FS_ALIGNED_BUFFER_ENABLE == true>
    uint32_t i = 0;
    uint32_t sector_aligned_index = 0;
    uint8_t (*sector_ptr)[SYS_FS_LFS_MAX_SS] = (uint8_t (*)[])buffer;
    uint8_t *buff_prt = (uint8_t*) buffer;
	

    <#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
        <#lt>    /* Use Aligned Buffer if input buffer is in Cacheable address space and
        <#lt>     * is not aligned to cache line size */
        <#lt>    if ((IS_KVA0((uint8_t *)buffer) == true) && (((uint32_t)buffer & CACHE_ALIGN_CHECK) != 0))
    <#else>
        <#lt>    /* Use Aligned Buffer if input buffer is not aligned to cache line size */
        <#lt>    if (((uint32_t)buffer & CACHE_ALIGN_CHECK) != 0)
    </#if>
    {
        /* For unaligned buffers, if count is > 2, then always read the first sector into the internal aligned buffer since the starting address of app buffer is unaligned.
         * After this, find the first 512 byte aligned address in the app buffer and copy the remaining (count-1) sectors into the app buffer directly.
         * After this, move the count-1 sectors in app buffer to the end (i.e. start of 1st sector) in app buffer.
         * Finally, copy the first sector from internal aligned buffer to app buffer.
         * For unaligned buffers, if count is < 2, then directly use the internal aligned buffer and then copy it to app buffer as there is no gain in following the above logic.
        */
        if (count > 2)
        {
            /* Read first sector from media into internal aligned buffer */
            result = disk_read_aligned(bd->disk_num, gSysFsDiskData[bd->disk_num].alignedBuffer, sector, 1);

            if (result == RES_OK)
            {
                /* Find the first sector aligned address in the application buffer and read (count - 1) sectors into the aligned application buffer directly */

                sector_aligned_index = SYS_FS_LFS_MAX_SS - ((uint32_t)buffer & (SYS_FS_LFS_MAX_SS - 1));

                result = disk_read_aligned(bd->disk_num, &buff_prt[sector_aligned_index], (sector + 1), (count - 1));

                if (result == RES_OK)
                {
                    /* Move (count - 1) sectors to the end (i.e. start of 1st sector) in the application buffer */
                    memmove(&sector_ptr[1], &buff_prt[sector_aligned_index], (count - 1)*SYS_FS_LFS_MAX_SS);

                    /* Copy the first sector from the internal aligned buffer to the start of the application buffer */
                    memcpy(&sector_ptr[0], gSysFsDiskData[bd->disk_num].alignedBuffer, SYS_FS_LFS_MAX_SS);
                }
            }
        }
		else
        {
            for (i = 0; i < count; i++)
            {
                result = disk_read_aligned(bd->disk_num, gSysFsDiskData[bd->disk_num].alignedBuffer, (sector + i), 1);

                if (result == RES_OK)
                {
                    /* Copy the read data from the internal aligned buffer to the start of the application buffer */
                    memcpy(&sector_ptr[i], gSysFsDiskData[bd->disk_num].alignedBuffer, SYS_FS_LFS_MAX_SS);
                }
                else
                {
                    break;
                }
            }
        }		
    }
    else
</#if>
    {
        result = disk_read_aligned(bd->disk_num, buffer, sector, count);
		
        if (result != RES_OK)
        {
            return LFS_ERR_IO;
        }
    }
    
    return LFS_ERR_OK;
}

int lfs_bdio_prog(const struct lfs_config *cfg, lfs_block_t block,
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
            block           += currentXferLen/cfg->block_size;
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

int lfs_bdio_erase(const struct lfs_config *cfg, lfs_block_t block) {
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

int lfs_bdio_sync(const struct lfs_config *cfg) {
    
    LFS_TRACE("[%s] In\r\n", __func__);
    return 0;
}


