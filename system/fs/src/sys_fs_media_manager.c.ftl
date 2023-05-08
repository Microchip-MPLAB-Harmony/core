/*******************************************************************************
  File System System-Library Interface Implementation.

  Company:
    Microchip Technology Inc.

  File Name:
    sys_fs_media_manager.c

  Summary:
    This file contains implementation of SYS FS Media Manager functions.

  Description:
    This file contains implementation of SYS FS Media Manager functions.
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
#include <string.h>
#include "system/fs/src/sys_fs_media_manager_local.h"
#include "system/fs/src/sys_fs_local.h"
<#if SYS_FS_FAT == true>
    <#lt>#include "system/fs/fat_fs/file_system/ff.h"
</#if>
<#if SYS_FS_MPFS == true>
    <#lt>#include "system/fs/mpfs/mpfs.h"
</#if>
<#if SYS_FS_FILEX == true>
    <#lt>#include "system/fs/filex/filex_io_drv.h"
</#if>
<#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
    <#lt>#include "system/cache/sys_cache.h"
    <#lt>#include "sys/kmem.h"
</#if>

static const char *gSYSFSVolumeName [] = {
    "nvm",
    "sd",
    "mmcblk",
    "ram",
    "mtd",
};
<#if (SYS_FS_FAT == true) || (SYS_FS_FILEX == true)>
/**/
static const uint16_t gPartitionTypeOffset [4] =
{
    450,
    466,
    482,
    498
};
</#if>
// *****************************************************************************
/* Media object

  Summary:
    Defines the media object for each media that should be controlled by media manager

  Description:
    This data type defines the media objects that are available on
    the part.
  Remarks:
    None
*/

static SYS_FS_MEDIA gSYSFSMediaObject[SYS_FS_MEDIA_NUMBER];

// *****************************************************************************
/* Volume object

  Summary:
    Defines the volume object for each media that should be controlled by media manager

  Description:
     Each partition of the media is assigned as a volume using the volume object.

  Remarks:
    None
*/
static SYS_FS_VOLUME gSYSFSVolumeObject[SYS_FS_VOLUME_NUMBER];

<#if SYS_FS_AUTO_MOUNT == true>
    <#lt>// *****************************************************************************
    <#lt>/* Media Event Handler

    <#lt>  Summary:
    <#lt>    Defines the media Event handler that stores the application event handler.

    <#lt>  Description:
    <#lt>    This data type defines the media event handler
    <#lt>    the part.
    <#lt>  Remarks:
    <#lt>    None
    <#lt>*/
    <#lt>typedef struct
    <#lt>{
    <#lt>    SYS_FS_EVENT_HANDLER eventHandler;
    <#lt>    uintptr_t context;
    <#lt>} S_SYS_FS_EVENT_HANDLER;

    <#lt>static S_SYS_FS_EVENT_HANDLER gSYSFSEventHandler[SYS_FS_CLIENT_NUMBER];
    <#lt>static uint8_t gNumOfFSClients = 0;
</#if>

// *****************************************************************************
/* Media Page Buffer

  Summary:
    Defines the media page buffer to store the data on media.

  Description:
    This data type defines the media page buffer.
  Remarks:
    None
*/
static uint8_t CACHE_ALIGN gSYSFSMediaBlockBuffer[SYS_FS_MEDIA_MANAGER_BUFFER_SIZE] = {0};

// *****************************************************************************
/* Media Mount Table

  Summary:
    Defines the mount table specified by application.

  Description:
    This data type defines the mount table that maps device and mount name.
  Remarks:
    None
*/
static uint8_t CACHE_ALIGN gSYSFSMediaBuffer[SYS_FS_MEDIA_MAX_BLOCK_SIZE];

/* Following structure holds the variables for media manager, including the task states */
static SYS_FS_MEDIA_MANAGER_OBJ gSYSFSMediaManagerObj =
{
    gSYSFSMediaObject,
    gSYSFSVolumeObject,
    sysfsMountTable,
    NULL,
    gSYSFSMediaBuffer,
    0,
    0,
    false
};

<#if SYS_FS_MPFS == true>
    <#lt>/* Defines the volume to partition translation table, used by MPFS */
    <#lt>MPFS_PARTITION MPFS_VolToPart[SYS_FS_VOLUME_NUMBER];
</#if>

<#if SYS_FS_FAT == true || SYS_FS_FILEX == true>
    <#lt>// *****************************************************************************
    <#lt>/* Volume to Partition translation

    <#lt>Summary:
    <#lt>    Defines the volume to partition translation table, used by FAT FS.

    <#lt>Description:
    <#lt>    The following structure was added to enable the "multipartition"
    <#lt>    feature of FAT FS. This strucre is already declared in ff.h and
    <#lt>    the intention was to make as little change on ff.h
    <#lt>    To use multipartition on FAT FS, we need to enable "_MULTI_PARTITION".
    <#lt>    And, when we do that, the FAT FS code expects an array named "VolToPart".
    <#lt>    The explanation for each element of the array is given below, and
    <#lt>    this function places the elements of this array.

    <#lt>    Lets consider a case where 2 media are attached = SD card with 4 partitions
    <#lt>    and NVM with 1 partition.

    <#lt>    PARTITION VolToPart[SYS_FS_VOLUME_NUMBER] = {
    <#lt>        {0, 1},
    <#lt>        {0, 2},
    <#lt>        {0, 3},
    <#lt>        {0, 4},
    <#lt>        {1, 1}
    <#lt>    };

    <#lt>Remarks:
    <#lt>    None
    <#lt>*/
    <#lt>PARTITION VolToPart[SYS_FS_VOLUME_NUMBER];

    <#lt>//*****************************************************************************
    <#lt>/* Function:
    <#lt>    static void SYS_FS_MEDIA_T_MANAGER_UpdateVolToPart
    <#lt>    (
    <#lt>        uint8_t volNumber,
    <#lt>        uint8_t pd,
    <#lt>        uint8_t pt
    <#lt>    );

    <#lt>Summary:
    <#lt>    Update the volume to partition number information.

    <#lt>Description:
    <#lt>    This function is present to enable the multipartition operation of FAT FS.
    <#lt>    FAT FS uses the structure VolToPart to know the physical drive media number
    <#lt>    and partition number of that media, using this structure. This function is
    <#lt>    used to populate the structure.

    <#lt>Remarks:
    <#lt>    None
    <#lt>*/
    <#lt>static void SYS_FS_MEDIA_T_MANAGER_UpdateVolToPart
    <#lt>(
    <#lt>    uint8_t volNumber,
    <#lt>    uint8_t pd,
    <#lt>    uint8_t pt
    <#lt>)
    <#lt>{
    <#lt>    /* Update the "VolToPart" table for multipartition support on FAT FS */
    <#lt>    /* pd = Physical drive, starting from "zero". This is to be compatible with FAT FS code */
    <#lt>    VolToPart[volNumber].pd = pd;
    <#lt>    /* pt = partition, starting from "one". This is to be compatible with FAT FS code */
    <#lt>    VolToPart[volNumber].pt = pt;
    <#lt>}
</#if>

//*****************************************************************************
/* MISRA C-2012 Rule 11.1, 11.8 deviated below. Deviation record ID -
   H3_MISRAC_2012_R_11_1_DR_1 & H3_MISRAC_2012_R_11_8_DR_1*/
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:1 "MISRA C-2012 Rule 11.1" "H3_MISRAC_2012_R_11_1_DR_1" )\
(deviate:3 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1" )
</#if>
/* Function:
    static void SYS_FS_MEDIA_T_MANAGER_HandleMediaDetach
    (
        SYS_FS_MEDIA *mediaObj
    );

  Summary:
    Handles the media detach condition.

  Description:
    This function updates the structure members tracking the media attach
    status and also invokes the registered callback function to propagate the
    media detach event.

  Remarks:
    None
*/
static void SYS_FS_MEDIA_T_MANAGER_HandleMediaDetach
(
    SYS_FS_MEDIA *mediaObj
)
{
    uint8_t volIndex = 0;
    SYS_FS_VOLUME *volumeObj = NULL;

    for (volIndex = 0; volIndex < SYS_FS_VOLUME_NUMBER; volIndex++)
    {
        volumeObj = &gSYSFSMediaManagerObj.volumeObj[volIndex];
        if ((volumeObj->inUse == false) || (volumeObj->obj != mediaObj))
        {
            continue;
        }

        volumeObj->inUse = false;

<#if SYS_FS_AUTO_MOUNT == true>
        uint8_t index = 0;
        uint8_t handlerIndex = 0;
        const SYS_FS_MEDIA_MOUNT_DATA *fsMount = (const SYS_FS_MEDIA_MOUNT_DATA *)&gSYSFSMediaManagerObj.fsMountTable[0];

        /* Unmount the media */
        for (index = 0; index < SYS_FS_VOLUME_NUMBER; index++)
        {
            /* Find out the mount name from the media mount table */
            if (mediaObj->mediaType != fsMount[index].mediaType)
            {
                continue;
            }

            if(0 != strcmp((const char *)(volumeObj->volumeName), (const char *)(fsMount[index].devName+5)))
            {
                continue;
            }

            /* If the device is present in the mount table then fetch the mount name
               which is the input for the unmount function */
            if (SYS_FS_RES_SUCCESS != SYS_FS_Unmount(fsMount[index].mountName))
            {
                continue;
            }

            for (handlerIndex = 0; handlerIndex < SYS_FS_CLIENT_NUMBER; handlerIndex++)
            {
                if (gSYSFSEventHandler[handlerIndex].eventHandler != NULL)
                {
                    gSYSFSEventHandler[handlerIndex].eventHandler(SYS_FS_EVENT_UNMOUNT,
                            (void*)fsMount[index].mountName,
                            gSYSFSEventHandler[handlerIndex].context);
                }
            }

            break;
        }
</#if>
    }
}

<#if SYS_FS_AUTO_MOUNT == true>
    <#lt>// *****************************************************************************
    <#lt>/* Function:
    <#lt>    static void lSYS_FS_MountVolume
    <#lt>    (
    <#lt>        SYS_FS_MEDIA_TYPE mediaType,
    <#lt>        const uint8_t *volumeName
    <#lt>    );

    <#lt>  Summary:
    <#lt>    Mount the volume when AUTOMOUNT feature is enabled.

    <#lt>  Description:
    <#lt>    Mount the volume when AUTOMOUNT feature is enabled.

    <#lt>  Remarks:
    <#lt>    None.
    <#lt>***************************************************************************/
    <#lt>static void lSYS_FS_MountVolume
    <#lt>(
    <#lt>    SYS_FS_MEDIA_TYPE mediaType,
    <#lt>    const uint8_t *volumeName
    <#lt>)
    <#lt>{
    <#lt>    uint8_t volumeIndex    = 0;
    <#lt>    uint8_t handlerIndex   = 0;
    <#lt>    SYS_FS_EVENT fsEvent   = SYS_FS_EVENT_ERROR;

    <#lt>    const SYS_FS_MEDIA_MOUNT_DATA *fsMount = (const SYS_FS_MEDIA_MOUNT_DATA *)&gSYSFSMediaManagerObj.fsMountTable[0];

    <#lt>    for (volumeIndex = 0; volumeIndex < SYS_FS_VOLUME_NUMBER; volumeIndex++)
    <#lt>    {
    <#lt>        if (mediaType != fsMount[volumeIndex].mediaType)
    <#lt>        {
    <#lt>            continue;
    <#lt>        }

    <#lt>        if (strcmp((const char *)volumeName, (const char *)(fsMount[volumeIndex].devName + 5)) != 0)
    <#lt>        {
    <#lt>            continue;
    <#lt>        }

    <#lt>        if (SYS_FS_Mount(fsMount[volumeIndex].devName, fsMount[volumeIndex].mountName, fsMount[volumeIndex].fsType, 0, NULL) == SYS_FS_RES_SUCCESS)
    <#lt>        {
    <#lt>            fsEvent = SYS_FS_EVENT_MOUNT;

    <#lt>            // Check If mount has passed with no file system on Media
    <#lt>            if (SYS_FS_Error() == SYS_FS_ERROR_NO_FILESYSTEM)
    <#lt>            {
    <#lt>                fsEvent = SYS_FS_EVENT_MOUNT_WITH_NO_FILESYSTEM;
    <#lt>            }
    <#lt>        }

    <#lt>        // Call all the registered event handlers with updated fsEvent
    <#lt>        for (handlerIndex = 0; handlerIndex < SYS_FS_CLIENT_NUMBER; handlerIndex++)
    <#lt>        {
    <#lt>            if (gSYSFSEventHandler[handlerIndex].eventHandler != NULL)
    <#lt>            {
    <#lt>                gSYSFSEventHandler[handlerIndex].eventHandler(fsEvent,
    <#lt>                        (void*)fsMount[volumeIndex].mountName,
    <#lt>                        gSYSFSEventHandler[handlerIndex].context);
    <#lt>            }
    <#lt>        }

    <#lt>        break;
    <#lt>    }
    <#lt>}
</#if>

// *****************************************************************************
/* Function:
    static void SYS_FS_MEDIA_T_MANAGER_PopulateVolume
    (
        SYS_FS_MEDIA *mediaObj,
        uint8_t isMBR,
        uint8_t partitionMap,
        uint8_t fsType
    );

  Summary:
    Allocate a volume and populate with the FS details.

  Description:
    After finding a valid file system, a volume is allocated and populated with
    the details of the file system.

  Remarks:
    None.
***************************************************************************/
static void SYS_FS_MEDIA_T_MANAGER_PopulateVolume
(
    SYS_FS_MEDIA *mediaObj,
    uint8_t isMBR,
    uint8_t partitionMap,
    uint8_t fsType
)
{
    uint8_t volumeIndex = 0;
    uint8_t volumeNameLen = 0;
    SYS_FS_VOLUME *volumeObj = &gSYSFSMediaManagerObj.volumeObj[0];

<#if SYS_FS_FAT == true || SYS_FS_FILEX == true>
    uint8_t  partitionNum = 0;
    uint16_t offset = 0;
    uint8_t  *readBuffer = gSYSFSMediaManagerObj.mediaBuffer;
</#if>

    for (volumeIndex = 0; volumeIndex < SYS_FS_VOLUME_NUMBER; volumeIndex++)
    {
        if (volumeObj->inUse == true)
        {
            volumeObj++;
            continue;
        }

        /* Found a free volume */
        mediaObj->numVolumes++;

        volumeNameLen = (uint8_t)strlen(gSYSFSVolumeName[mediaObj->mediaType]);
        (void) memcpy (volumeObj->volumeName, gSYSFSVolumeName[mediaObj->mediaType], volumeNameLen);

        /* Store the volume name */
        volumeObj->volumeName[volumeNameLen] = (char)mediaObj->mediaId;
        volumeNameLen++;
        volumeObj->volumeName[volumeNameLen] = mediaObj->numVolumes + '0';
        volumeNameLen++;
        volumeObj->volumeName[volumeNameLen] = '\0';

        volumeObj->obj = mediaObj;
        volumeObj->fsType = fsType;

<#if SYS_FS_MPFS == true>
        if ((uint8_t)'M' == volumeObj->fsType)
        {
            /* MPFS File System */
            volumeObj->numSectors = 0;
            volumeObj->startSector = 0;

            MPFS_VolToPart[volumeIndex].pd = mediaObj->mediaIndex;
            MPFS_VolToPart[volumeIndex].pt = 0;
        }
</#if>
<#if (SYS_FS_MPFS == true && SYS_FS_FAT == true) || (SYS_FS_MPFS == true && SYS_FS_FILEX == true)>
        else
</#if>
<#if SYS_FS_FAT == true || SYS_FS_FILEX == true>
        {
            /* Register Media and Volume mapping with FAT File System */
            /* Register the volumes to partition table only if this device has
             * partition table entry or MBR. Skip if media contains VBR */
            if (partitionMap != 0U)
            {
                if ((partitionMap & 0x01U) != 0U)
                {
                    partitionNum = 0;
                    partitionMap &= ~(uint8_t)0x01U;
                }
                else if ((partitionMap & 0x02U) != 0U)
                {
                    partitionNum = 1;
                    partitionMap &= ~(uint8_t)0x02U;
                }
                else if ((partitionMap & 0x04U) != 0U)
                {
                    partitionNum = 2;
                    partitionMap &= ~(uint8_t)0x04U;
                }
                else if ((partitionMap & 0x08U) != 0U)
                {
                    partitionNum = 3;
                    partitionMap &= ~(uint8_t)0x08U;
                }
                else
                {
                    /* Nothing to do */
                }

                if (fsType != 0xFFU)
                {
                    /* File system type offset */
                    offset = gPartitionTypeOffset[partitionNum];
                    volumeObj->fsType = readBuffer[offset];

                    /* Number of sectors */
                    volumeObj->numSectors = (((uint32_t)readBuffer[offset + 11UL] << 24) + ((uint32_t)readBuffer[offset + 10UL] << 16) + ((uint32_t)readBuffer[offset + 9UL] << 8) + (uint32_t)readBuffer[offset + 8U]);

                    /* Start address of the volume */
                    volumeObj->startSector = (((uint32_t)readBuffer[offset + 7UL] << 24) + ((uint32_t)readBuffer[offset + 6UL] << 16) + ((uint32_t)readBuffer[offset + 5UL] << 8) + (uint32_t)readBuffer[offset + 4U]);
                }
            }

            if (isMBR != 0U)
            {
                SYS_FS_MEDIA_T_MANAGER_UpdateVolToPart (volumeIndex, mediaObj->mediaIndex, partitionNum + 1U);
            }
            else
            {
                SYS_FS_MEDIA_T_MANAGER_UpdateVolToPart (volumeIndex, mediaObj->mediaIndex, 0);
            }
        }
</#if>
        /* Update the inUse flag to indicate that the volume is now in use.*/
        volumeObj->inUse = true;

<#if SYS_FS_AUTO_MOUNT == true>
        /* Mount the Media */
        lSYS_FS_MountVolume (mediaObj->mediaType, (const uint8_t *)(volumeObj->volumeName));
</#if>

        /* Continue if there is more than one partition on media */
        if (partitionMap == 0U)
        {
            break;
        }

        /* Go to the next volume object */
        volumeObj++;
    }
}

// *****************************************************************************
/* Function:
    static uint8_t SYS_FS_MEDIA_T_MANAGER_FindNextMedia
    (
        SYS_FS_MEDIA *mediaObj,
        uint8_t *index
    );

  Summary:
    Returns the index of the media that needs to be processed.

  Description:
    This function returns the index of the media that will be processed next by
    the media manager task routine.

  Remarks:
    None.
***************************************************************************/
static uint8_t SYS_FS_MEDIA_T_MANAGER_FindNextMedia
(
    SYS_FS_MEDIA *mediaObj,
    uint8_t *index
)
{
    uint8_t indexLow = 0;

    indexLow = *index;
    while (*index < SYS_FS_MEDIA_NUMBER)
    {
        if (mediaObj[*index].inUse == true)
        {
            /* Media found. Return the index. */
            indexLow = *index;
            SYS_FS_MEDIA_MANAGER_UPDATE_MEDIA_INDEX_T(*index);
            return indexLow;
        }

        (*index)++;
    }

    if (indexLow == 0U)
    {
        /* No media. Reset the media index. */
        *index = 0;
        return 0xFF;
    }

    /* No media found in the upper range. Start searching from 0 till *index.
     * */
    indexLow = 0;
    while (indexLow < *index)
    {
        if (mediaObj[indexLow].inUse == true)
        {
            /* Media found. Return the media index. */
            *index = indexLow;
            SYS_FS_MEDIA_MANAGER_UPDATE_MEDIA_INDEX_T(*index);
            return indexLow;
        }

        indexLow++;
    }

    /* No media. */
    return 0xFF;
}

<#if SYS_FS_FAT == true || SYS_FS_FILEX == true>
     /* MISRA C-2012 Rule 16.1 deviate: 1, 16.3 deviate:2 and 16.6 deviate:1.
      Deviation record ID - H3_MISRAC_2012_R_16_1_DR_1, H3_MISRAC_2012_R_16_3_DR_1
      & H3_MISRAC_2012_R_16_6_DR_1 */
      <#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
      #pragma coverity compliance block \
      (deviate:1 "MISRA C-2012 Rule 16.1" "H3_MISRAC_2012_R_16_1_DR_1" )\
      (deviate:2 "MISRA C-2012 Rule 16.3" "H3_MISRAC_2012_R_16_3_DR_1" )\
      (deviate:1 "MISRA C-2012 Rule 16.6" "H3_MISRAC_2012_R_16_6_DR_1" )
      </#if>
    <#lt>// *****************************************************************************
    <#lt>/* Function:
    <#lt>    static bool SYS_FS_MEDIA_MANAGER_IsFSFat
    <#lt>    (
    <#lt>        uint8_t fsType
    <#lt>    );

    <#lt>Summary:
    <#lt>    Function to identify if file system type is FAT FS.

    <#lt>Description:
    <#lt>    This function identifies if the file system located on the media/partition
    <#lt>    is FAT FS.

    <#lt>Remarks:
    <#lt>    None.
    <#lt>***************************************************************************/
    <#lt>static bool SYS_FS_MEDIA_MANAGER_IsFSFat
    <#lt>(
    <#lt>    uint8_t fsType
    <#lt>)
    <#lt>{
    <#lt>    switch (fsType)
    <#lt>    {
    <#lt>        case 0x01: // FAT12
    <#lt>        case 0x04: // FAT16
    <#lt>        case 0x05: // Extended partition
    <#lt>        case 0x06: // FAT16
    <#lt>        case 0x07: // exFAT for future enhancement
    <#lt>        case 0x0B: // FAT32
    <#lt>        case 0x0C: // FAT32
    <#lt>        case 0x0E: // FAT16
    <#lt>        case 0x0F: // FAT16
    <#lt>            {
    <#lt>                return true;
    <#lt>            }
    <#lt>        default:
    <#lt>            {
    <#lt>                return false;
    <#lt>            }
    <#lt>    }
    <#lt>}
</#if>
    <#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
    #pragma coverity compliance end_block "MISRA C-2012 Rule 16.1"
    #pragma coverity compliance end_block "MISRA C-2012 Rule 16.3"
    #pragma coverity compliance end_block "MISRA C-2012 Rule 16.6"
    </#if>
    /* MISRAC 2012 deviation block end */
// *****************************************************************************
/* Function:
    static uint8_t SYS_FS_MEDIA_T_MANAGER_AnalyzeFileSystem
    (
        uint8_t *firstSector,
        uint8_t *numPartition,
        uint8_t *isMBR,
        uint8_t *partitionMap
    );

  Summary:
    Analyzes the MBR/VBR and identifies the type of filesystem present.

  Description:
    This function analyzes the contents of the MBR or the VBR to find the type
    of file system present on the media/partition.

  Remarks:
    None.
***************************************************************************/
static uint8_t SYS_FS_MEDIA_T_MANAGER_AnalyzeFileSystem
(
    uint8_t *firstSector,
    uint8_t *numPartition,
    uint8_t *isMBR,
    uint8_t *partitionMap
)
{
    uint8_t fsType = 0xFF;

    *partitionMap = 0;
    *numPartition = 0;

    /* Check for the Boot Signature */
<#if SYS_FS_FAT == true || SYS_FS_FILEX == true>
    if((firstSector[510] == 0x55U) && (firstSector[511] == 0xAAU))
    {
        /* Check if the first sector of the media is Volume Boot Record or the
           Master Boot Record */
        if((0xEBU == firstSector[0]) &&
                ((0x3CU == firstSector[1]) || (0x58U == firstSector[1]) || (0xFEU == firstSector[1])) &&
                (0x90U == firstSector[2]))
        {
            /* Volume Boot Record */
            *numPartition = 1;
            *isMBR = 0;

            /* The extended BPB contains FAT32 in this field */
            if ((0x46U == firstSector[82]) || (0x41U == firstSector[83]) ||
                    (0x54U == firstSector[84]))
            {
                fsType = 0x0B;
            }
            /* The extended BPB contains FAT, FAT12 or FAT16 in these fields */
            else if ((0x46U == firstSector[54]) || (0x41U == firstSector[55]) ||
                    (0x54U == firstSector[56]))
            {
                fsType = 0x06;
            }
            else
            {
                /* Nothing to do */
            }
        }
        else
        {
            /* The partition table in the MBR sector has room for four 16-byte
             * entries that each specify the sectors that belong to a
             * partition. The table is in bytes 446 through 509. An entry can
             * begin at byte 446, 462, 478, or 494. */

            /* Determine total partitions in the media */
            *isMBR = 1;
            if(SYS_FS_MEDIA_MANAGER_IsFSFat(firstSector[450]))
            {
                *partitionMap |= (uint8_t)(1UL << 0);
                (*numPartition)++;
            }
            if(SYS_FS_MEDIA_MANAGER_IsFSFat(firstSector[466]))
            {
                *partitionMap |= (uint8_t)(1UL << 1);
                (*numPartition)++;
            }
            if(SYS_FS_MEDIA_MANAGER_IsFSFat(firstSector[482]))
            {
                *partitionMap |= (uint8_t)(1UL << 2);
                (*numPartition)++;
            }
            if(SYS_FS_MEDIA_MANAGER_IsFSFat(firstSector[498]))
            {
                *partitionMap |= (uint8_t)(1UL << 3);
                (*numPartition)++;
            }

            /* Found at least one valid partition. Assign a non 0xFF value to
             * indicate that atleast one of the partitions has a valid file
             * system. */
            if (*partitionMap != 0U)
            {
                fsType = 1;
            }
        }
    }
</#if>
<#if (SYS_FS_FAT == true || SYS_FS_FILEX == true) && SYS_FS_MPFS == true>
    else if (0 == strncmp((char*)firstSector, "MPFS", 4))
</#if>
<#if SYS_FS_FAT == false && SYS_FS_FILEX == false && SYS_FS_MPFS == true>
    if (0 == strncmp((char*)firstSector, "MPFS", 4))
</#if>
<#if SYS_FS_MPFS == true>
    {
        /* No partitions in MPFS, hence, go to other state */
        /* allocate a new volume to each partition */
        (*numPartition) = 1;
        /* This is 0x4D which also mean file system Primary QNX POSIX volume on disk */
        /* Need to find an unused value from the partition type*/
        fsType = (uint8_t)'M';
    }
</#if>
<#if (SYS_FS_FAT == true || SYS_FS_MPFS == true || SYS_FS_FILEX == true) && SYS_FS_LFS == true>
    else if (0 == strncmp((char*)&firstSector[8], "littlefs", 8))
<#elseif SYS_FS_MPFS == true && SYS_FS_LFS == true>
    else if (0 == strncmp((char*)&firstSector[8], "littlefs", 8))
<#elseif SYS_FS_LFS == true>
    if (0 == strncmp((char*)&firstSector[8], "littlefs", 8))
</#if>
<#if SYS_FS_LFS == true>
    {
        /* No partitions in littlefs, hence, go to other state */
        /* allocate a new volume to each partition */
        (*numPartition) = 1;
        /* This is 0x4C which also mean file system Primary QNX POSIX volume on disk */
        /* Need to find an unused value from the partition type*/
        fsType = (uint8_t)'L';
    }
</#if>
    else /* If MBR is not detected, make media as unsupported */
    {
        /* File system either not present or not supported */
        fsType = 0xFF;
    }

    return fsType;
}

// *****************************************************************************
/* Function:
    SYS_FS_MEDIA_HANDLE SYS_FS_MEDIA_MANAGER_Register
    (
        SYS_MODULE_OBJ obj,
        SYS_MODULE_INDEX index,
        const SYS_FS_MEDIA_FUNCTIONS *mediaFunctions,
        SYS_FS_MEDIA_TYPE mediaType
    );

  Summary:
    Function to register media drivers with the media manager.

  Description:
    This function is called by the media driver to register the functionalities
    with the media manager. For static media, such as NVM or a SD card, the
    media drivers register with this function at the time of initialization.
    For dynamic media, such as MSD, this register function is called
    dynamically, once the MSD media is connected.

  Remarks:
    See sys_fs_media_manager.h for usage information.
***************************************************************************/
SYS_FS_MEDIA_HANDLE SYS_FS_MEDIA_MANAGER_Register
(
    SYS_MODULE_OBJ obj,
    SYS_MODULE_INDEX index,
    const SYS_FS_MEDIA_FUNCTIONS *mediaFunctions,
    SYS_FS_MEDIA_TYPE mediaType
)
{
    uint8_t mediaIndex = 0;
    uint8_t mediaId = (uint8_t)'a';

    SYS_FS_MEDIA *mediaObj = NULL;

    mediaObj = &gSYSFSMediaManagerObj.mediaObj[0];
    for (mediaIndex = 0; mediaIndex < SYS_FS_MEDIA_NUMBER; mediaIndex++)
    {
         if ((mediaObj->inUse) && (mediaType == mediaObj->mediaType))
         {
             /* For every type of media, increment the mediaID as a, b, c... */
             mediaId++;
         }
         mediaObj++;
    }

    mediaObj = &gSYSFSMediaManagerObj.mediaObj[0];
    /* Start with 0th disk and find a disk which is free */
    for (mediaIndex = 0; mediaIndex < SYS_FS_MEDIA_NUMBER; mediaIndex++)
    {
        if (mediaObj->inUse == false)
        {
            mediaObj->inUse = true;

            mediaObj->driverFunctions = mediaFunctions;
            mediaObj->driverObj = obj;
            mediaObj->driverIndex = index;
            mediaObj->driverHandle = DRV_HANDLE_INVALID;

            mediaObj->mediaState = SYS_FS_MEDIA_STATE_REGISTERED;
            mediaObj->mediaType = mediaType;

            mediaObj->numPartitions = 0;
            mediaObj->numVolumes = 0;

            mediaObj->mediaIndex = mediaIndex;
            mediaObj->mediaId = mediaId;
            mediaObj->attachStatus = SYS_FS_MEDIA_DETACHED;

            return (SYS_FS_MEDIA_HANDLE)mediaObj;
        }

        mediaObj++;
    }

    return SYS_FS_MEDIA_HANDLE_INVALID;
}

//*****************************************************************************
/*Function:
    void SYS_FS_MEDIA_MANAGER_DeRegister
    (
        SYS_FS_MEDIA_HANDLE    handle
    )

  Description:
    Function called by a media to deregister itself to the media manager. For
    static media, (like NVM or SD card), this "deregister function" is never
    called, since static media never gets deregistered once they are
    initialized.  For dynamic media (like MSD), this register function is
    called dynamically, once the MSD media is connected.

  Remarks:
    See sys_fs_media_manager.h for usage information.
***************************************************************************/
void SYS_FS_MEDIA_MANAGER_DeRegister
(
    SYS_FS_MEDIA_HANDLE handle
)
{
    SYS_FS_MEDIA *mediaObj = (SYS_FS_MEDIA *)handle;

    if (handle == SYS_FS_MEDIA_HANDLE_INVALID)
    {
        return;
    }

    mediaObj->isMediaDisconnected = 1U;
}

//*****************************************************************************
/* Function:
    SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE SYS_FS_MEDIA_MANAGER_SectorRead
    (
        uint16_t diskNo,
        uint8_t * dataBuffer,
        uint32_t sector,
        uint32_t noSectors
    );

  Summary:
    Reads a specified media sector.

  Description:
    This function reads a specified media (disk) sector. This is the function
    in the media manager layer. This function in turn calls the specific sector
    read function from the list of function pointers of the media driver.

  Remarks:
    See sys_fs_media_manager.h for usage information.
***************************************************************************/
SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE SYS_FS_MEDIA_MANAGER_SectorRead
(
    uint16_t diskNum,
    uint8_t *dataBuffer,
    uint32_t sector,
    uint32_t numSectors
)
{
    SYS_FS_MEDIA *mediaObj = NULL;
    uint32_t blocksPerSector = 0;
    uint32_t mediaReadBlockSize = 0;

    if (diskNum >= SYS_FS_MEDIA_NUMBER)
    {
        SYS_ASSERT(false, "Invalid Disk");
        return SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;
    }

    mediaObj = &gSYSFSMediaManagerObj.mediaObj[diskNum];

    if (mediaObj->driverHandle == DRV_HANDLE_INVALID)
    {
        return SYS_FS_MEDIA_HANDLE_INVALID;
    }

    mediaReadBlockSize = mediaObj->mediaGeometry->geometryTable[0].blockSize;

    if (mediaReadBlockSize < 512U)
    {
        /* Find the number of blocks per sector */
        blocksPerSector = 512U / mediaReadBlockSize;
        /* Perform sector to block translation */
        sector *= blocksPerSector;
        numSectors *= blocksPerSector;
    }
    else
    {
        /* TODO: Handle cases where the block size is greater than 512 bytes.
         * */
    }

<#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
    /* Perform Cache Invalidate on the client buffer if it is in cacheable address space */
    if (IS_KVA0(dataBuffer) == true)
    {
        SYS_CACHE_InvalidateDCache_by_Addr((uint32_t *)dataBuffer, (numSectors * mediaReadBlockSize));
    }
</#if>

    mediaObj->commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;
    mediaObj->driverFunctions->sectorRead (mediaObj->driverHandle, &(mediaObj->commandHandle), dataBuffer, sector, numSectors);

    return (mediaObj->commandHandle);
}

//*****************************************************************************
/* Function:
    SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE SYS_FS_MEDIA_MANAGER_Read
    (
        uint16_t diskNo,
        uint8_t* destination,
        uint8_t * source,
        const unsigned int nBytes
    );

   Summary:
     Gets data from a specific media address.

   Description:
     This function gets data from a specific address of media. This function is
     intended to work with NVM media only, which can have byte level
     addressing.  For other media, such as a SD card, byte addressing is not
     possible and this function will not work. Also, this function is intended
     to work with the MPFS2 file system only, which uses byte addressing.

  Remarks:
    See sys_fs_media_manager.h for usage information.
***************************************************************************/
SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE SYS_FS_MEDIA_MANAGER_Read
(
    uint16_t diskNum,
    uint8_t *destination,
    uint8_t *source,
    const uint32_t nBytes
)
{
    SYS_FS_MEDIA *mediaObj = NULL;
    uint32_t startAddress = 0;
    uint32_t address = 0;

    if (diskNum >= SYS_FS_MEDIA_NUMBER)
    {
        SYS_ASSERT(false, "Invalid Disk");
        return SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;
    }

    mediaObj = &gSYSFSMediaManagerObj.mediaObj[diskNum];

    if (mediaObj->driverHandle == DRV_HANDLE_INVALID)
    {
        return SYS_FS_MEDIA_HANDLE_INVALID;
    }

    startAddress = mediaObj->driverFunctions->addressGet(mediaObj->driverHandle);
    address = (uint32_t)source - (uint32_t)startAddress;

<#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
    /* Perform Cache Invalidate on the client buffer if it is in cacheable address space */
    if (IS_KVA0(destination) == true)
    {
        SYS_CACHE_InvalidateDCache_by_Addr((uint32_t *)destination, nBytes);
    }
</#if>

    mediaObj->commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;
    mediaObj->driverFunctions->Read(mediaObj->driverHandle, &(mediaObj->commandHandle), destination, address, nBytes);

    return (mediaObj->commandHandle);
}

//*****************************************************************************
/* Function:
    SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE SYS_FS_MEDIA_MANAGER_SectorWrite
    (
        uint16_t diskNo,
        uint32_t sector,
        uint8_t * dataBuffer,
        uint32_t noSectors
    );

    Summary:
      Writes a sector to the specified media.

    Description:
      This function writes to a sector of the specified media (disk). This is
      the function in the media manager layer. This function in turn calls the
      specific sector write function from the list of function pointers of the
      media driver.

  Remarks:
    See sys_fs_media_manager.h for usage information.
***************************************************************************/
SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE SYS_FS_MEDIA_MANAGER_SectorWrite
(
    uint16_t diskNum,
    uint32_t sector,
    uint8_t *dataBuffer,
    uint32_t numSectors
)
{
    SYS_FS_MEDIA *mediaObj = NULL;
    uint8_t *data = dataBuffer;
    uint32_t sectorOffsetInBlock = 0;
    uint32_t memoryBlock = 0;
    uint32_t sectorsPerBlock = 0;
    uint32_t numSectorsToWrite = 0;
    uint32_t mediaWriteBlockSize = 0;
    uint32_t blocksPerSector = 0;
    uint32_t readSize = SYS_FS_MEDIA_MANAGER_BUFFER_SIZE;

    if(diskNum >= SYS_FS_MEDIA_NUMBER)
    {
        SYS_ASSERT(false, "Invalid Disk");
        return SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;
    }

    mediaObj = &gSYSFSMediaManagerObj.mediaObj[diskNum];

    if (mediaObj->driverHandle == DRV_HANDLE_INVALID)
    {
        return SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;
    }

    mediaWriteBlockSize = mediaObj->mediaGeometry->geometryTable[1].blockSize;

    if (mediaWriteBlockSize > 512U)
    {
        sectorsPerBlock = mediaWriteBlockSize / 512U;
    }
    else if (mediaWriteBlockSize == 512U)
    {
        sectorsPerBlock = 1;
        blocksPerSector = 1;
    }
    else
    {
        blocksPerSector = 512U / mediaWriteBlockSize;
        sector *= blocksPerSector;
        numSectors *= blocksPerSector;
    }

    if ((sectorsPerBlock == 1U) || (blocksPerSector > 0U))
    {
<#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
        /* Perform Cache Clean on the client buffer if it is in cacheable address space */
        if (IS_KVA0(dataBuffer) == true)
        {
            SYS_CACHE_CleanDCache_by_Addr((uint32_t *)dataBuffer, (numSectors * mediaWriteBlockSize));
        }
</#if>
        mediaObj->commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;
        mediaObj->driverFunctions->sectorWrite (mediaObj->driverHandle, &(mediaObj->commandHandle), dataBuffer, sector, numSectors);
        return (mediaObj->commandHandle);
    }
    else
    {
        /* Mute the event notification */
        gSYSFSMediaManagerObj.muteEventNotification = true;

        while (numSectors > 0U)
        {
            /* Find the memory block for the starting sector */
            memoryBlock = sector / sectorsPerBlock;

            /* Find the number of sectors to be updated in this block. */
            sectorOffsetInBlock = (sector % sectorsPerBlock);
            numSectorsToWrite = (sectorsPerBlock - sectorOffsetInBlock);

            if (numSectors < numSectorsToWrite)
            {
                numSectorsToWrite = numSectors;
            }

            if (numSectorsToWrite != sectorsPerBlock)
            {
                /* Read the memory block from the media. Update the media data. */
                mediaObj->commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;

                if (mediaWriteBlockSize < SYS_FS_MEDIA_MANAGER_BUFFER_SIZE)
                {
                    readSize = mediaWriteBlockSize;
                }

                mediaObj->driverFunctions->sectorRead(mediaObj->driverHandle, &(mediaObj->commandHandle), gSYSFSMediaBlockBuffer, memoryBlock * mediaWriteBlockSize, readSize);

                while (mediaObj->commandStatus == SYS_FS_MEDIA_COMMAND_IN_PROGRESS)
                {
                    if(mediaObj->driverFunctions->tasks != NULL)
                    {
                        mediaObj->driverFunctions->tasks(mediaObj->driverObj);
                    }
                }

                if (mediaObj->commandStatus != SYS_FS_MEDIA_COMMAND_COMPLETED)
                {
                    /* Unmute the event notification */
                    gSYSFSMediaManagerObj.muteEventNotification = false;

                    /* Media read operation failed. */
                    return SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;
                }

                /* Multiply by the sector size */
                sectorOffsetInBlock <<= 9;
                (void) memcpy ((void *)&gSYSFSMediaBlockBuffer[sectorOffsetInBlock], (const void *)dataBuffer, numSectorsToWrite << 9);

                data = gSYSFSMediaBlockBuffer;
            }
            else
            {
                /* Since the whole block is being updated, there is no need to
                 * perform a read-modify-write operation of the block. */
                data = dataBuffer;
<#if core.PRODUCT_FAMILY?matches("PIC32MZ.*") == true>
                /* Perform Cache Clean on the client buffer if it is in cacheable address space */
                if (IS_KVA0(dataBuffer) == true)
                {
                    SYS_CACHE_CleanDCache_by_Addr((uint32_t *)dataBuffer, mediaWriteBlockSize);
                }
</#if>
            }

            if ((numSectors - numSectorsToWrite) == 0U)
            {
                /* This is the last write operation. */
                break;
            }

            /* Write the block to the media */
            mediaObj->commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;
            mediaObj->driverFunctions->sectorWrite (mediaObj->driverHandle, &(mediaObj->commandHandle), data, memoryBlock, 1);
            while (mediaObj->commandStatus == SYS_FS_MEDIA_COMMAND_IN_PROGRESS)
            {
                if(mediaObj->driverFunctions->tasks != NULL)
                {
                    mediaObj->driverFunctions->tasks(mediaObj->driverObj);
                }
            }

            if (mediaObj->commandStatus != SYS_FS_MEDIA_COMMAND_COMPLETED)
            {
                /* Unmute the event notification */
                gSYSFSMediaManagerObj.muteEventNotification = false;

                /* Media write operation failed. */
                return SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID;
            }

            /* Update the number of block still to be written, sector address
             * and the buffer pointer */
            numSectors -= numSectorsToWrite;
            sector += numSectorsToWrite;
            dataBuffer += (numSectorsToWrite << 9);
        }
    }

    /* Unmute the event notification */
    gSYSFSMediaManagerObj.muteEventNotification = false;

    mediaObj->commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;
    mediaObj->driverFunctions->sectorWrite (mediaObj->driverHandle, &(mediaObj->commandHandle), data, memoryBlock, 1);

    return (mediaObj->commandHandle);
}

//*****************************************************************************
/* Function:
    uintptr_t SYS_FS_MEDIA_MANAGER_AddressGet
    (
        uint16_t diskNo
    );

  Summary:
    Gets the starting media address based on a disk number.

  Description:
    This function gets the starting address of a media. This function is
    intended to work only with MPFS2, which does byte addressing and needs a
    memory address (not disk number).

  Remarks:
    See sys_fs_media_manager.h for usage information.
***************************************************************************/
uintptr_t SYS_FS_MEDIA_MANAGER_AddressGet
(
    uint16_t diskNum
)
{
    SYS_FS_MEDIA *mediaObj = NULL;

    if (diskNum >= SYS_FS_MEDIA_NUMBER)
    {
        SYS_ASSERT(false, "Invalid Disk");
        return 0;
    }

    mediaObj = &gSYSFSMediaManagerObj.mediaObj[diskNum];
    return (mediaObj->driverFunctions->addressGet(mediaObj->driverHandle));
}

//*****************************************************************************
/* Function:
    SYS_FS_MEDIA_COMMAND_STATUS SYS_FS_MEDIA_MANAGER_CommandStatusGet
    (
        uint16_t diskNo,
        SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE bufferHandle
    );

  Summary:
    Gets the command status.

  Description:
    This function gets the command status. The sector read and sector write are
    non-blocking functions. Therefore, this interface is provided where the
    code should periodically poll for the buffer status. If status is
    completed, the read/write operation is considered to be complete.

  Remarks:
    See sys_fs_media_manager.h for usage information.
***************************************************************************/
SYS_FS_MEDIA_COMMAND_STATUS SYS_FS_MEDIA_MANAGER_CommandStatusGet
(
    uint16_t diskNum,
    SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE commandHandle
)
{
    SYS_FS_MEDIA *mediaObj = NULL;

    if (diskNum >= SYS_FS_MEDIA_NUMBER)
    {
        SYS_ASSERT(false, "Invalid Disk");
        return SYS_FS_MEDIA_COMMAND_UNKNOWN;
    }

    mediaObj = &gSYSFSMediaManagerObj.mediaObj[diskNum];

    if (mediaObj->driverHandle == DRV_HANDLE_INVALID)
    {
        return SYS_FS_MEDIA_COMMAND_UNKNOWN;
    }

    return (mediaObj->driverFunctions->commandStatusGet(mediaObj->driverHandle, commandHandle));
}

//*****************************************************************************
/* Function:
    bool SYS_FS_MEDIA_MANAGER_MediaStatusGet
    (
        const char *devName
    );

  Summary:
    Gets the media status.

  Description:
    This function gets the media status. This function is used by higher layers
    (sys_fs layer) to know the status of the media(whether the media is attached
    or detached).

  Remarks:
    See sys_fs_media_manager.h for usage information.
***************************************************************************/
bool SYS_FS_MEDIA_MANAGER_MediaStatusGet
(
    const char *volumeName
)
{
    SYS_FS_VOLUME * volumeObj =  NULL;
    uint8_t volumeIndex = 0;

    for (volumeIndex = 0; volumeIndex < SYS_FS_VOLUME_NUMBER; volumeIndex++)
    {
        volumeObj = &gSYSFSMediaManagerObj.volumeObj[volumeIndex];
        if (volumeObj->inUse == true)
        {
            if (strncmp("/dev/", volumeName, 5) != 0)
            {
                if (strcmp((const char*)(volumeName), (const char *)volumeObj->volumeName) == 0)
                {
                    return (volumeObj->obj->driverFunctions->mediaStatusGet(volumeObj->obj->driverHandle));
                }
            }
            else
            {
                if (strcmp((const char*)(volumeName + 5), (const char *)volumeObj->volumeName) == 0)
                {
                    return (volumeObj->obj->driverFunctions->mediaStatusGet(volumeObj->obj->driverHandle));
                }
            }
        }
    }

    return (bool)SYS_FS_MEDIA_DETACHED;
}

// *****************************************************************************
/* Function:
    bool SYS_FS_MEDIA_MANAGER_VolumePropertyGet
    (
        const char *volumeName,
        SYS_FS_VOLUME_PROPERTY *property
    );

  Summary:
    Gets the volume property.

  Description:
    This function gets the property of the volume. This function is used by
    higher layers (sys_fs layer) to know the property of the volume as
    specified in the SYS_FS_VOLUME_PROPERTY structure.

  Remarks:
    See sys_fs_media_manager.h for usage information.
***************************************************************************/
bool SYS_FS_MEDIA_MANAGER_VolumePropertyGet
(
    const char *volumeName,
    SYS_FS_VOLUME_PROPERTY *property
)
{
    SYS_FS_VOLUME *volumeObj = NULL;
    uint8_t volumeIndex = 0;

    for (volumeIndex = 0; volumeIndex < SYS_FS_VOLUME_NUMBER; volumeIndex++)
    {
        volumeObj = &gSYSFSMediaManagerObj.volumeObj[volumeIndex];

        if (volumeObj->inUse == true)
        {
            if (strcmp((const char*)(volumeName + 5), (const char *)volumeObj->volumeName) == 0)
            {
<#if SYS_FS_FAT == true || SYS_FS_FILEX == true>
                if (SYS_FS_MEDIA_MANAGER_IsFSFat (volumeObj->fsType))
                {
<#if SYS_FS_FILEX == true>
                    /* FS type is already set */
<#else>
                    /* FAT File System */
                    property->fsType = FAT;
</#if>
                }
</#if>
<#if (SYS_FS_FAT == true || SYS_FS_FILEX == true) && SYS_FS_MPFS == true>
                else if (volumeObj->fsType == (uint8_t)'M')
</#if>
<#if SYS_FS_FAT == false && SYS_FS_FILEX == false && SYS_FS_MPFS == true>
                if (volumeObj->fsType == (uint8_t)'M')
</#if>
<#if SYS_FS_MPFS == true>
                {
                    /* MPFS File System */
                    property->fsType = MPFS2;
                }
</#if>
<#if (SYS_FS_FAT == true || SYS_FS_MPFS == true || SYS_FS_FILEX == true) && SYS_FS_LFS == true>
                else if (volumeObj->fsType == 'L')
<#elseif SYS_FS_LFS == true>
                if (volumeObj->fsType == (uint8_t)'L')
</#if>
<#if SYS_FS_LFS == true>
                {
                    /* LFS File System */
                    property->fsType = LITTLEFS;
                }
</#if>
                else
                {
                    /* Unsupported file system or no file system */
                    property->fsType = UNSUPPORTED_FS;
                }

                property->volNumber = volumeIndex;
                return true;
            }
        }
    }

    return false;
}
/* MISRA C-2012 Rule 5.1, 5.2 deviated below. Deviation record ID -
   H3_MISRAC_2012_R_5_1_DR_1 & H3_MISRAC_2012_R_5_2_DR_1*/
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:2 "MISRA C-2012 Rule 5.1" "H3_MISRAC_2012_R_5_1_DR_1" )\
(deviate:1 "MISRA C-2012 Rule 5.2" "H3_MISRAC_2012_R_5_2_DR_1" )
</#if>
<#if SYS_FS_AUTO_MOUNT == true>
    <#lt>//*****************************************************************************
    <#lt>/* Function:
    <#lt>    void SYS_FS_MEDIA_MANAGER_EventHandlerSet
    <#lt>    (
    <#lt>        const void * eventHandler,
    <#lt>        const uintptr_t context
    <#lt>    );

    <#lt>  Summary:
    <#lt>    Register the event handler for Mount/Un-Mount events .

    <#lt>  Description:
    <#lt>    This function is used to register a FS client event handler for notifying the
    <#lt>    Mount/Un-Mount events when AutoMount feature is enabled for File system.

    <#lt>***************************************************************************/
    <#lt>void SYS_FS_MEDIA_MANAGER_EventHandlerSet
    <#lt>(
    <#lt>    const void * eventHandler,
    <#lt>    const uintptr_t context
    <#lt>)
    <#lt>{
    <#lt>    if (gNumOfFSClients == SYS_FS_CLIENT_NUMBER)
    <#lt>    {
    <#lt>        return;
    <#lt>    }
    <#lt>    gSYSFSEventHandler[gNumOfFSClients].eventHandler = (SYS_FS_EVENT_HANDLER)eventHandler;
    <#lt>    gSYSFSEventHandler[gNumOfFSClients].context = context;
    <#lt>    gNumOfFSClients++;
    <#lt>}
</#if>

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"
</#if>
/* MISRAC 2012 deviation block end */
//*****************************************************************************
/* Function:
    void SYS_FS_MEDIA_MANAGER_RegisterTransferHandler
    (
        const void *eventHandler
    );

  Summary:
    Register the event handler for data transfer events.

  Description:
    This function is used to send the command status for the disk operation.

***************************************************************************/

/* MISRA C-2012 Rule 11.1, 11.6 & 11.8 deviated below. Deviation record ID -
   H3_MISRAC_2012_R_11_1_DR_1, H3_MISRAC_2012_R_11_6_DR_1 & H3_MISRAC_2012_R_11_8_DR_1*/
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance block \
(deviate:1 "MISRA C-2012 Rule 11.1" "H3_MISRAC_2012_R_11_1_DR_1" )\
(deviate:1 "MISRA C-2012 Rule 11.6" "H3_MISRAC_2012_R_11_6_DR_1" )\
(deviate:1 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1" )
</#if>

void SYS_FS_MEDIA_MANAGER_RegisterTransferHandler
(
    const void *eventHandler
)
{
    gSYSFSMediaManagerObj.eventHandler = (SYS_FS_EVENT_HANDLER) eventHandler;
}
//*****************************************************************************
/* Function:
    static void SYS_FS_MEDIA_MANAGER_EventHandler
    (
        SYS_FS_MEDIA_BLOCK_EVENT event,
        SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE commandHandle,
        uintptr_t context
    );

  Summary:
    Registers the event handler with media drivers.

  Description:
    This function registers the event handler with media drivers. The event
    handler will be called by media drivers whenever a media command has
    executed successfully or if it resulted in an error.

  Remarks:
    None.
*/
static void SYS_FS_MEDIA_MANAGER_EventHandler
(
    SYS_FS_MEDIA_BLOCK_EVENT event,
    SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE commandHandle,
    uintptr_t context
)
{
    switch(event)
    {
        case SYS_FS_MEDIA_EVENT_BLOCK_COMMAND_COMPLETE:
            ((SYS_FS_MEDIA*)context)->commandStatus = SYS_FS_MEDIA_COMMAND_COMPLETED;
            break;
        case SYS_FS_MEDIA_EVENT_BLOCK_COMMAND_ERROR:
            ((SYS_FS_MEDIA*)context)->commandStatus = SYS_FS_MEDIA_COMMAND_UNKNOWN;
            break;
        default:
                 /* Nothing to do */
            break;
    }

    if ((gSYSFSMediaManagerObj.eventHandler != NULL) && (gSYSFSMediaManagerObj.muteEventNotification == false))
    {
        gSYSFSMediaManagerObj.eventHandler ((SYS_FS_EVENT)event, (void *)commandHandle, ((SYS_FS_MEDIA*)context)->mediaIndex);
    }
}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 5.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 5.2"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.6"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */

//*****************************************************************************
/* Function:
    SYS_FS_MEDIA_GEOMETRY * SYS_FS_MEDIA_MANAGER_GetMediaGeometry
    (
        uint16_t diskNum
    );

  Summary:
    Gets the media geometry information.

  Description:
    This function gets the media geometry information.

  Remarks:
    See sys_fs_media_manager.h for usage information.
***************************************************************************/
SYS_FS_MEDIA_GEOMETRY * SYS_FS_MEDIA_MANAGER_GetMediaGeometry
(
    uint16_t diskNum
)
{
    SYS_FS_MEDIA *mediaObj = NULL;

    if (diskNum >= SYS_FS_MEDIA_NUMBER)
    {
        SYS_ASSERT(false, "Invalid Disk");
        return NULL;
    }

    mediaObj = &gSYSFSMediaManagerObj.mediaObj[diskNum];

    if (mediaObj->attachStatus == SYS_FS_MEDIA_DETACHED)
    {
        return NULL;
    }

    return mediaObj->mediaGeometry;
}

//*****************************************************************************
/* Function:
    void SYS_FS_MEDIA_MANAGER_TransferTask
    (
        uint8_t mediaIndex
    );

  Summary:
    Media manager transfer task function.

  Description:
    This is the media manager transfer task function. This task is repeatedly
    called by the disk io layer of the native file system for driving the
    current disk read/write operation to completion.

  Remarks:
    See sys_fs_media_manager.h for usage information.
***************************************************************************/
void SYS_FS_MEDIA_MANAGER_TransferTask
(
    uint8_t mediaIndex
)
{
    SYS_FS_MEDIA *mediaObj;

    if (mediaIndex >= SYS_FS_MEDIA_NUMBER)
    {
        return;
    }

    mediaObj = &gSYSFSMediaManagerObj.mediaObj[mediaIndex];

    if (mediaObj->inUse == false)
    {
        return;
    }

    if (mediaObj->driverFunctions->tasks != NULL)
    {
        mediaObj->driverFunctions->tasks(mediaObj->driverObj);
    }
}

//*****************************************************************************
/* Function:
    void SYS_FS_MEDIA_MANAGER_Tasks(void)

  Summary:
    Media manager task function.

  Description:
    This is the media manager task function. This task must be called
    repeatedly from the main loop.

  Remarks:
    See sys_fs_media_manager.h for usage information.
***************************************************************************/
void SYS_FS_MEDIA_MANAGER_Tasks
(
    void
)
{
    uint8_t mediaIndex = 0;
    uint8_t fsType = 0xFF;
    uint8_t partitionMap = 0;
    uint8_t isMBR = 0;
    uint32_t numSectors = 0;
    uint32_t mediaReadBlockSize = 0;

    SYS_FS_MEDIA *mediaObj = NULL;

    /* Find the next media to be processed */
    mediaIndex = SYS_FS_MEDIA_T_MANAGER_FindNextMedia (&gSYSFSMediaManagerObj.mediaObj[0], &gSYSFSMediaManagerObj.mediaIndex);
    if (mediaIndex == 0xFFU)
    {
        /* No media attached. Do nothing. */
        return;
    }

    mediaObj = &gSYSFSMediaManagerObj.mediaObj[mediaIndex];

    if (mediaObj->isMediaDisconnected == 1U)
    {
        /* If the media driver was de-registered in this state, then the media
         * had use of the media buffer and no longer needs it. */
         if(SYS_FS_MEDIA_ANALYZE_FS == mediaObj->mediaState)
         {
            gSYSFSMediaManagerObj.bufferInUse = false;
         }

        /* If media driver has de-registered then switch to the DEREGISTERED
         * state and handle the media detach. */
        mediaObj->mediaState = SYS_FS_MEDIA_STATE_DEREGISTERED;
    }

    switch (mediaObj->mediaState)
    {
        case SYS_FS_MEDIA_STATE_REGISTERED:
            {
                /* Initial state. Open the media driver. */
                mediaObj->driverHandle = mediaObj->driverFunctions->open(mediaObj->driverIndex, DRV_IO_INTENT_READWRITE);
                if (mediaObj->driverHandle != DRV_HANDLE_INVALID)
                {
                    /* Media driver open successful. Register an event handler for
                     * the media driver events. */
                    mediaObj->driverFunctions->eventHandlerset(
                                                mediaObj->driverHandle,
                                                (const void *) SYS_FS_MEDIA_MANAGER_EventHandler,
                                                (uintptr_t) mediaObj
                                                );

                    /* Transition to the next state. */
                    mediaObj->mediaState = SYS_FS_MEDIA_CHECK_ATTACH_STATUS;
                }
                else
                {
                    /* Media driver open failed. Stay in the same state and
                     * retry. */
                }

                break;
            }

        case SYS_FS_MEDIA_CHECK_ATTACH_STATUS:
            {
                /* Check if the Media is attached. */
                if (mediaObj->driverFunctions->mediaStatusGet(mediaObj->driverHandle) == true)
                {
                    if (mediaObj->attachStatus == SYS_FS_MEDIA_DETACHED)
                    {
                        /* The media was earlier detached. But now it is
                         * attached. Read the media geometry. */
                        mediaObj->mediaGeometry = mediaObj->driverFunctions->mediaGeometryGet(mediaObj->driverHandle);

                        /* Transition to the next state to kick start the
                         * analysis of the FS on the media. */
                        mediaObj->mediaState = SYS_FS_MEDIA_READ_FIRST_SECTOR;
                    }

                    /* Update the media status */
                    mediaObj->attachStatus = SYS_FS_MEDIA_ATTACHED;
                }
                else
                {
                    if (mediaObj->attachStatus == SYS_FS_MEDIA_ATTACHED)
                    {
                        /* The media was earlier attached. But now it is
                         * detached. Handle the media detach. */
                        SYS_FS_MEDIA_T_MANAGER_HandleMediaDetach (mediaObj);

                        /* Reset the media's number of volumes field */
                        mediaObj->numVolumes = 0;
                    }

                    /* Update the media status */
                    mediaObj->attachStatus = SYS_FS_MEDIA_DETACHED;

                    /* Stay in the same state */
                }

                break;
            }

        case SYS_FS_MEDIA_READ_FIRST_SECTOR:
            {
                if (gSYSFSMediaManagerObj.bufferInUse == true)
                {
                    /* Stay in the same state till the buffer becomes free. */
                    break;
                }

                gSYSFSMediaManagerObj.bufferInUse = true;

                numSectors = 1;

                mediaReadBlockSize = mediaObj->mediaGeometry->geometryTable[0].blockSize;

                if (mediaReadBlockSize < 512U)
                {
                    /* Perform sector to block translation */
                    numSectors *= (512U / mediaReadBlockSize);
                }

                (void) memset (gSYSFSMediaManagerObj.mediaBuffer, 0, SYS_FS_MEDIA_MAX_BLOCK_SIZE);

                /* Update the command status */
                mediaObj->commandStatus = SYS_FS_MEDIA_COMMAND_IN_PROGRESS;

                /* Read the first sector of the media */
                mediaObj->driverFunctions->sectorRead(mediaObj->driverHandle, &(mediaObj->commandHandle), gSYSFSMediaManagerObj.mediaBuffer, 0, numSectors);

                if (mediaObj->commandHandle != SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID)
                {
                    mediaObj->mediaState = SYS_FS_MEDIA_ANALYZE_FS;
                }
                else
                {
                    /* Failed to queue the Media read operation. Retry the
                     * operation. Clear the buffer in use flag. */
                    gSYSFSMediaManagerObj.bufferInUse = false;
                }

                break;
            }

        case SYS_FS_MEDIA_ANALYZE_FS:
            {
                if (SYS_FS_MEDIA_COMMAND_IN_PROGRESS == mediaObj->commandStatus)
                {
                    /* The request is not complete yet. Stay in the same state.
                     * */
                    if(mediaObj->driverFunctions->tasks != NULL)
                    {
                        mediaObj->driverFunctions->tasks(mediaObj->driverObj);
                    }
                    break;
                }

                if (mediaObj->commandStatus != SYS_FS_MEDIA_COMMAND_COMPLETED)
                {
                    /* Clear the buffer in use flag. */
                    gSYSFSMediaManagerObj.bufferInUse = false;

                    /* Media read operation has failed. Retry the read
                     * operation. */
                    mediaObj->mediaState = SYS_FS_MEDIA_READ_FIRST_SECTOR;

                    break;
                }

                fsType = SYS_FS_MEDIA_T_MANAGER_AnalyzeFileSystem(gSYSFSMediaManagerObj.mediaBuffer, &mediaObj->numPartitions, &isMBR, &partitionMap);

                if (fsType == 0xFFU)
                {
                    /* File system not found or found an unsupported file
                     * system. Allocate a volume so as to allow for formatting
                     * of the disk. */
                    if (isMBR != 0U)
                    {
                        partitionMap = 0x01;
                    }
                    else
                    {
                        partitionMap = 0x00;
                    }
                }

                SYS_FS_MEDIA_T_MANAGER_PopulateVolume (mediaObj, isMBR, partitionMap, fsType);

                /* Clear the buffer in use flag. */
                gSYSFSMediaManagerObj.bufferInUse = false;

                /* Transition state to check for media attach/detach */
                mediaObj->mediaState = SYS_FS_MEDIA_CHECK_ATTACH_STATUS;

                break;
            }

        case SYS_FS_MEDIA_STATE_DEREGISTERED:
            {
                if (mediaObj->attachStatus == SYS_FS_MEDIA_ATTACHED)
                {
                    /* The media was earlier attached. But now it is
                     * detached. Handle the media detach. */
                    SYS_FS_MEDIA_T_MANAGER_HandleMediaDetach (mediaObj);
                }

                mediaObj->inUse = false;
                mediaObj->attachStatus = SYS_FS_MEDIA_DETACHED;
                mediaObj->isMediaDisconnected = 0U;
                mediaObj->mediaId = 0;
                mediaObj->mediaIndex = 0;
                mediaObj->numPartitions = 0;
                mediaObj->numVolumes = 0;
                break;
            }

        default:
                  /* Nothing to do */

            break;
    }
}

/*************************************************************************
* END OF sys_fs_media_manager.c
***************************************************************************/
