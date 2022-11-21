/**************************************************************************/
/*                                                                        */
/*       Copyright (c) Microsoft Corporation. All rights reserved.        */
/*                                                                        */
/*       This software is licensed under the Microsoft Software License   */
/*       Terms for Microsoft Azure RTOS. Full text of the license can be  */
/*       found in the LICENSE file at https://aka.ms/AzureRTOS_EULA       */
/*       and in the root directory of this software.                      */
/*                                                                        */
/**************************************************************************/

#include <string.h>
#include "filex_io_drv.h"        /* FileX low level media I/O header */
#include "system/fs/sys_fs_media_manager.h"

<#if SYS_FS_ALIGNED_BUFFER_ENABLE?? && SYS_FS_ALIGNED_BUFFER_ENABLE == true>
    <#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
        <#lt>#include "sys/kmem.h"
    </#if>

    <#lt>#define CACHE_ALIGN_CHECK  (CACHE_LINE_SIZE - 1)

    <#lt>typedef struct
    <#lt>{
    <#lt>    uint8_t alignedBuffer[SYS_FS_FILEX_ALIGNED_BUFFER_LEN] __ALIGNED(CACHE_LINE_SIZE);
    <#lt>    SYS_FS_MEDIA_COMMAND_STATUS commandStatus;
    <#lt>    SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE commandHandle;
    <#lt>} SYS_FS_FILEX_IO_DATA;
<#else>
    <#lt>typedef struct
    <#lt>{
    <#lt>    SYS_FS_MEDIA_COMMAND_STATUS commandStatus;
    <#lt>    SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE commandHandle;
    <#lt>} SYS_FS_FILEX_IO_DATA;
</#if>

static SYS_FS_FILEX_IO_DATA CACHE_ALIGN gSysFsDiskData[SYS_FS_MEDIA_NUMBER];

void filexIoEventHandler
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

static FILEX_IO_RESULT filexIoCheckCommandStatus(uint8_t pdrv)
{
    FILEX_IO_RESULT result = RES_ERROR;

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

static FILEX_IO_RESULT disk_read_aligned
(
    uint8_t pdrv,   /* Physical drive nmuber (0..) */
    uint8_t *buff,  /* Data buffer to store read data */
    uint32_t sector,/* Sector address (LBA) */
    uint32_t sector_count   /* Number of sectors to read (1..128) */
)
{
    FILEX_IO_RESULT result = RES_ERROR;

    gSysFsDiskData[pdrv].commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;

    gSysFsDiskData[pdrv].commandHandle = SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;

    /* Submit the read request to media */
    gSysFsDiskData[pdrv].commandHandle = SYS_FS_MEDIA_MANAGER_SectorRead(pdrv /* DISK Number */ ,
            buff /* Destination Buffer*/,
            sector /* Source Sector */,
            sector_count /* Number of Sectors */);

    result = filexIoCheckCommandStatus(pdrv);

    return result;
}

void filex_io_drv_entry(FX_MEDIA *media_ptr)
{
<#if SYS_FS_ALIGNED_BUFFER_ENABLE?? && SYS_FS_ALIGNED_BUFFER_ENABLE == true>
    uint8_t *source_buffer;
    uint8_t *destination_buffer;
</#if>
    FILEX_IO_RESULT result = RES_ERROR;
    uint8_t *ptrdrv = (uint8_t *)media_ptr->fx_media_driver_info;
    uint8_t pdrv = *ptrdrv;

    /* Process the driver request specified in the media control block.  */
    switch (media_ptr -> fx_media_driver_request)
    {
        case FX_DRIVER_INIT:
        {
            SYS_FS_MEDIA_MANAGER_RegisterTransferHandler((void *)filexIoEventHandler);

            media_ptr->fx_media_driver_free_sector_update = FX_TRUE;
            if (SYS_FS_FILEX_READONLY)
            {
                media_ptr -> fx_media_driver_write_protect = FX_TRUE;
            }
            /* Success */
            media_ptr -> fx_media_driver_status =  FX_SUCCESS;
            break;
        }

        case FX_DRIVER_READ:
        {
            <#if SYS_FS_ALIGNED_BUFFER_ENABLE?? && SYS_FS_ALIGNED_BUFFER_ENABLE == true>
            uint32_t i = 0;
            uint32_t sector_aligned_index = 0;
            uint32_t sector = (uint32_t)(media_ptr -> fx_media_driver_logical_sector + media_ptr -> fx_media_hidden_sectors);
            uint32_t count = (uint32_t)media_ptr->fx_media_driver_sectors;
            uint8_t (*sector_ptr)[SYS_FS_FILEX_MAX_SS] = (uint8_t (*)[])media_ptr->fx_media_driver_buffer;
            destination_buffer = (uint8_t *)media_ptr->fx_media_driver_buffer;

            <#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
            /* Use Aligned Buffer if input buffer is in Cacheable address space and is not aligned to cache line size */
            if ((IS_KVA0((uint8_t *)destination_buffer) == true) && (((uint32_t)destination_buffer & CACHE_ALIGN_CHECK) != 0))
            <#else>
            /* Use Aligned Buffer if input buffer is not aligned to cache line size */
            if (((uint32_t)destination_buffer & CACHE_ALIGN_CHECK) != 0)
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
                    result = disk_read_aligned(pdrv, gSysFsDiskData[pdrv].alignedBuffer, sector, 1);

                    if (result == RES_OK)
                    {
                        /* Find the first sector aligned address in the application buffer and read (count - 1) sectors into the aligned application buffer directly */

                        sector_aligned_index = SYS_FS_FILEX_MAX_SS - ((uint32_t)destination_buffer & (SYS_FS_FILEX_MAX_SS - 1));

                        result = disk_read_aligned(pdrv, &destination_buffer[sector_aligned_index], (sector + 1), (count - 1));

                        if (result == RES_OK)
                        {
                            /* Move (count - 1) sectors to the end (i.e. start of 1st sector) in the application buffer */
                            memmove(&sector_ptr[1], &destination_buffer[sector_aligned_index], (count - 1)*SYS_FS_FILEX_MAX_SS);

                            /* Copy the first sector from the internal aligned buffer to the start of the application buffer */
                            memcpy(&sector_ptr[0], gSysFsDiskData[pdrv].alignedBuffer, SYS_FS_FILEX_MAX_SS);
                        }
                    }
                }
                else
                {
                    for (i = 0; i < count; i++)
                    {
                        result = disk_read_aligned(pdrv, gSysFsDiskData[pdrv].alignedBuffer, (sector + i), 1);

                        if (result == RES_OK)
                        {
                            /* Copy the read data from the internal aligned buffer to the start of the application buffer */
                            memcpy(&sector_ptr[i], gSysFsDiskData[pdrv].alignedBuffer, SYS_FS_FILEX_MAX_SS);
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
                result = disk_read_aligned(pdrv, (uint8_t *)media_ptr->fx_media_driver_buffer, (uint32_t)(media_ptr -> fx_media_driver_logical_sector + media_ptr -> fx_media_hidden_sectors), (uint32_t)media_ptr->fx_media_driver_sectors);
            }

            if (result == RES_OK)
            {
                /* Success  */
                media_ptr -> fx_media_driver_status =  FX_SUCCESS;
            }
            else
            {
                /* Error */
                media_ptr -> fx_media_driver_status =  FX_IO_ERROR;
            }
            break;
        }

        case FX_DRIVER_WRITE:
        {
            <#if SYS_FS_ALIGNED_BUFFER_ENABLE?? && SYS_FS_ALIGNED_BUFFER_ENABLE == true>
            uint32_t bytesToTransfer    = 0;
            uint32_t currentXferLen     = 0;
            uint32_t sectorXferCntr     = 0;
            uint32_t sector = (uint32_t)(media_ptr -> fx_media_driver_logical_sector + media_ptr -> fx_media_hidden_sectors);
            uint32_t count = (uint32_t)media_ptr->fx_media_driver_sectors;
            source_buffer = (uint8_t *)media_ptr->fx_media_driver_buffer;

            <#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
            /* Use Aligned Buffer if input buffer is in Cacheable address space and is not aligned to cache line size */
            if ((IS_KVA0((uint8_t *)source_buffer) == true) && (((uint32_t)source_buffer & CACHE_ALIGN_CHECK) != 0))
            <#else>
            /* Use Aligned Buffer if input buffer is not aligned to cache line size */
            if (((uint32_t)source_buffer & CACHE_ALIGN_CHECK) != 0)
            </#if>
            {
                /* When aligned buffer is used the total number of sectors will be divided by the aligned
                 * buffer size and will be sent to drivers in iterations.
                 * As the total sectors are now divided into chunks it may effect the overall throughput.
                 * Increasing the length of the buffer will increase the throughput but consume more RAM memory.
                */

                bytesToTransfer = (count * SYS_FS_FILEX_MAX_SS);

                while (bytesToTransfer > 0)
                {
                    /* Calculate the number of sectors to be transferred with current request */
                    if (bytesToTransfer > SYS_FS_FILEX_ALIGNED_BUFFER_LEN)
                    {
                        sectorXferCntr  = (SYS_FS_FILEX_ALIGNED_BUFFER_LEN / SYS_FS_FILEX_MAX_SS);
                        currentXferLen  = SYS_FS_FILEX_ALIGNED_BUFFER_LEN;
                    }
                    else
                    {
                        sectorXferCntr  = (bytesToTransfer / SYS_FS_FILEX_MAX_SS);
                        currentXferLen  = bytesToTransfer;
                    }

                    gSysFsDiskData[pdrv].commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;

                    gSysFsDiskData[pdrv].commandHandle = SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;

                    /* Copy the actual buffer data into aligned buffer */
                    memcpy(gSysFsDiskData[pdrv].alignedBuffer, source_buffer, currentXferLen);

                    /* Submit the write request to media */
                    gSysFsDiskData[pdrv].commandHandle = SYS_FS_MEDIA_MANAGER_SectorWrite(pdrv /* DISK Number */ ,
                            sector /* Destination Sector*/,
                            gSysFsDiskData[pdrv].alignedBuffer /* Source Buffer */,
                            sectorXferCntr /* Number of Sectors */);

                    result = filexIoCheckCommandStatus(pdrv);

                    if (result != RES_OK)
                    {
                        break;
                    }

                    bytesToTransfer -= currentXferLen;
                    source_buffer   += currentXferLen;
                    sector          += sectorXferCntr;
                }
            }
            else
            </#if>
            {
                gSysFsDiskData[pdrv].commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;

                gSysFsDiskData[pdrv].commandHandle = SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;

                /* Submit the write request to media */
                gSysFsDiskData[pdrv].commandHandle = SYS_FS_MEDIA_MANAGER_SectorWrite(pdrv /* DISK Number */ ,
                        (uint32_t)(media_ptr -> fx_media_driver_logical_sector + media_ptr -> fx_media_hidden_sectors) /* Destination Sector*/,
                        (uint8_t *)media_ptr->fx_media_driver_buffer /* Source Buffer */,
                        (uint32_t)media_ptr->fx_media_driver_sectors /* Number of Sectors */);

                result = filexIoCheckCommandStatus(pdrv);
            }

            if (result == RES_OK)
            {
                /* Success  */
                media_ptr -> fx_media_driver_status =  FX_SUCCESS;
            }
            else
            {
                /* Error */
                media_ptr -> fx_media_driver_status =  FX_IO_ERROR;
            }
            break;
        }

        case FX_DRIVER_BOOT_READ:
        {
            <#if SYS_FS_ALIGNED_BUFFER_ENABLE?? && SYS_FS_ALIGNED_BUFFER_ENABLE == true>
            destination_buffer = (uint8_t *)media_ptr->fx_media_driver_buffer;

            <#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
            /* Use Aligned Buffer if input buffer is in Cacheable address space and is not aligned to cache line size */
            if ((IS_KVA0((uint8_t *)destination_buffer) == true) && (((uint32_t)destination_buffer & CACHE_ALIGN_CHECK) != 0))
            <#else>
            /* Use Aligned Buffer if input buffer is not aligned to cache line size */
            if (((uint32_t)destination_buffer & CACHE_ALIGN_CHECK) != 0)
            </#if>
            {
                /* Read boot sector from media into internal aligned buffer */
                result = disk_read_aligned(pdrv, gSysFsDiskData[pdrv].alignedBuffer, 0, 1);
                if (result == RES_OK)
                {
                    /* Copy the aligned buffer into actual buffer data */
                    memcpy(destination_buffer, gSysFsDiskData[pdrv].alignedBuffer, SYS_FS_FILEX_MAX_SS);
                }
            }
            else
            </#if>
            {
                result = disk_read_aligned(pdrv, (uint8_t *)media_ptr->fx_media_driver_buffer, 0, 1);
            }

            if (result == RES_OK)
            {
                /* Success  */
                media_ptr -> fx_media_driver_status =  FX_SUCCESS;
            }
            else
            {
                /* Error */
                media_ptr -> fx_media_driver_status =  FX_IO_ERROR;
            }
            break;
        }

        case FX_DRIVER_BOOT_WRITE:
        {
            <#if SYS_FS_ALIGNED_BUFFER_ENABLE?? && SYS_FS_ALIGNED_BUFFER_ENABLE == true>
            uint32_t currentXferLen     = 0;
            source_buffer = (uint8_t *)media_ptr->fx_media_driver_buffer;

            <#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
            /* Use Aligned Buffer if input buffer is in Cacheable address space and is not aligned to cache line size */
            if ((IS_KVA0((uint8_t *)source_buffer) == true) && (((uint32_t)source_buffer & CACHE_ALIGN_CHECK) != 0))
            <#else>
            /* Use Aligned Buffer if input buffer is not aligned to cache line size */
            if (((uint32_t)source_buffer & CACHE_ALIGN_CHECK) != 0)
            </#if>
            {
                /* Calculate the number of sectors to be transferred with current request */
                if (SYS_FS_FILEX_MAX_SS > SYS_FS_FILEX_ALIGNED_BUFFER_LEN)
                {
                    currentXferLen  = SYS_FS_FILEX_ALIGNED_BUFFER_LEN;
                }
                else
                {
                    currentXferLen  = SYS_FS_FILEX_MAX_SS;
                }

                gSysFsDiskData[pdrv].commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;

                gSysFsDiskData[pdrv].commandHandle = SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;

                /* Copy the actual buffer data into aligned buffer */
                memcpy(gSysFsDiskData[pdrv].alignedBuffer, source_buffer, currentXferLen);

                /* Submit the write request to media */
                gSysFsDiskData[pdrv].commandHandle = SYS_FS_MEDIA_MANAGER_SectorWrite(pdrv /* DISK Number */ ,
                        0 /* Boot Sector*/,
                        gSysFsDiskData[pdrv].alignedBuffer /* Source Buffer */,
                        1 /* Number of Sectors */);

                result = filexIoCheckCommandStatus(pdrv);
            }
            else
            </#if>
            {
                gSysFsDiskData[pdrv].commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;

                gSysFsDiskData[pdrv].commandHandle = SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;

                /* Submit the write request to media */
                gSysFsDiskData[pdrv].commandHandle = SYS_FS_MEDIA_MANAGER_SectorWrite(pdrv /* DISK Number */ ,
                        0 /* Boot Sector*/,
                        (uint8_t *)media_ptr->fx_media_driver_buffer /* Source Buffer */,
                        1 /* Number of Sectors */);

                result = filexIoCheckCommandStatus(pdrv);
            }

            if (result == RES_OK)
            {
                /* Success  */
                media_ptr -> fx_media_driver_status =  FX_SUCCESS;
            }
            else
            {
                /* Error */
                media_ptr -> fx_media_driver_status =  FX_IO_ERROR;
            }
            break;
        }

        case FX_DRIVER_FLUSH:
        {

            /* Success */
            media_ptr -> fx_media_driver_status =  FX_SUCCESS;
            break;
        }

        case FX_DRIVER_ABORT:
        {

            /* Success */
            media_ptr -> fx_media_driver_status =  FX_SUCCESS;
            break;
        }

        case FX_DRIVER_UNINIT:
        {
            /* Success */
            media_ptr -> fx_media_driver_status =  FX_SUCCESS;
            break;
        }

        default:
        {
            /* Invalid request */
            media_ptr -> fx_media_driver_status =  FX_IO_ERROR;
            break;
        }
    }
}

uint32_t filex_io_disk_get_sector_count(uint8_t pdrv)
{
    uint32_t mediaBlockSize = 0;
    uint32_t numBlocksPerSector = 1;
    SYS_FS_MEDIA_GEOMETRY *mediaGeometry = NULL;
    uint32_t sector_count = 64;

    mediaGeometry = SYS_FS_MEDIA_MANAGER_GetMediaGeometry (pdrv);
    if (mediaGeometry != NULL)
    {
        mediaBlockSize = mediaGeometry->geometryTable[0].blockSize;

        if (mediaBlockSize < SYS_FS_FILEX_MAX_SS)
        {
            /* Perform block to sector translation */
            numBlocksPerSector = (SYS_FS_FILEX_MAX_SS / mediaBlockSize);
        }
        sector_count = mediaGeometry->geometryTable[0].numBlocks / numBlocksPerSector;
    }

    return sector_count;
}
