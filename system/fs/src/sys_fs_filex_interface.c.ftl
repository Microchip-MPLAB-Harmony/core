/*******************************************************************************
* Copyright (C) 2022 Microchip Technology Inc. and its subsidiaries.
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

#include "system/fs/sys_fs_filex_interface.h"

/* MISRA C-2012 Rule 11.3, 11.8 deviated below. Deviation record ID -  H3_MISRAC_2012_R_11_3_DR_1 & H3_MISRAC_2012_R_11_8_DR_1*/
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:23 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1" )
</#if>

typedef struct
{
    bool inUse;
    uint8_t vol_num;
    FX_MEDIA mediaObj;
} FILEX_MEDIA_OBJECT;

typedef struct
{
    bool inUse;
    FX_FILE fileObj;
} FILEX_FILE_OBJECT;

typedef struct
{
    bool inUse;
    FX_MEDIA dirObj;
} FILEX_DIR_OBJECT;

static FILEX_MEDIA_OBJECT CACHE_ALIGN FILEXMediaObject[SYS_FS_VOLUME_NUMBER];
static FILEX_FILE_OBJECT CACHE_ALIGN FILEXFileObject[SYS_FS_MAX_FILES];
static FILEX_DIR_OBJECT CACHE_ALIGN FILEXDirObject[SYS_FS_MAX_FILES];
static uint8_t CACHE_ALIGN mediaBuffer[SYS_FS_MEDIA_MAX_BLOCK_SIZE];
static uint8_t startupflag = 0;
static char mediaName[] = {'F','I','L','E','X','_','M','E','D','I','A','\0'};
static char diskName[] = {'F', 'X', '_', 'D', 'I', 'S', 'K', '\0'};

int FILEX_mount ( uint8_t vol )
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    uint8_t index = 0;


    FILEXMediaObject[vol].vol_num = vol;

    if(0U == startupflag)
    {
        startupflag = 1;
        for(index = 0; index != SYS_FS_VOLUME_NUMBER ; index++ )
        {
            FILEXMediaObject[index].inUse = false;
        }
        for(index = 0; index != SYS_FS_MAX_FILES ; index++ )
        {
            FILEXFileObject[index].inUse = false;
            FILEXDirObject[index].inUse = false;
        }
    }

    /* Check if the drive number is valid */
    if (vol >= SYS_FS_VOLUME_NUMBER)
    {
        return FX_MEDIA_INVALID;
    }

    /* If the volume specified is already in use, then return failure, as we cannot mount it again */
    if(FILEXMediaObject[vol].inUse == true)
    {
        return FX_MEDIA_INVALID;
    }
    else
    {
        media_ptr = &FILEXMediaObject[vol].mediaObj;
    }

    res = (int)fx_media_open(media_ptr, mediaName, filex_io_drv_entry, &FILEXMediaObject[vol].vol_num, mediaBuffer, SYS_FS_MEDIA_MAX_BLOCK_SIZE);

    if (res == FX_SUCCESS)
    {
        FILEXMediaObject[vol].inUse = true;
    }

    return res;
}

int FILEX_unmount ( uint8_t vol )
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    uint32_t cnt =0;

    if (vol >= SYS_FS_VOLUME_NUMBER)
    {
        return res;
    }

    /* If the volume specified not in use, then return failure, as we cannot unmount mount a free volume */
    if(FILEXMediaObject[vol].inUse == false)
    {
        return res;
    }

    media_ptr = &FILEXMediaObject[vol].mediaObj;

    res = (int)fx_media_close(media_ptr);

    if (res == FX_SUCCESS)
    {
        // free the volume
        FILEXMediaObject[vol].inUse = false;

        for(cnt = 0; cnt < SYS_FS_MAX_FILES; cnt++)
        {
            if(FILEXFileObject[cnt].inUse)
            {
                (void)memset(&FILEXFileObject[cnt].fileObj, 0, sizeof(FILEXFileObject[cnt].fileObj));
                FILEXFileObject[cnt].inUse = false;
            }
            if(FILEXDirObject[cnt].inUse)
            {
                (void)memset(&FILEXDirObject[cnt].dirObj, 0, sizeof(FILEXDirObject[cnt].dirObj));
                FILEXDirObject[cnt].inUse = false;
            }
        }
    }

    return (res);
}

int FILEX_open (
    uintptr_t handle,   /* Pointer to the blank file object */
    const char * path,  /* Pointer to the file name */
    uint8_t mode        /* Access mode and file open mode flags */
)
{
    FX_MEDIA *media_ptr = NULL;
    FX_FILE *fp = NULL;
    int res = FX_ACCESS_ERROR;
    uint32_t index;
    int32_t volumeNum = (int32_t)path[0] - (int32_t)'0';
    int32_t filex_mode;
    SYS_FS_FILE_OPEN_ATTRIBUTES sysfs_mode = (SYS_FS_FILE_OPEN_ATTRIBUTES)mode;

    media_ptr = &FILEXMediaObject[volumeNum].mediaObj;

    /* Convert the SYS_FS file open attributes to FILEX attributes */
    switch (sysfs_mode)
    {
        case SYS_FS_FILE_OPEN_READ:
            filex_mode = FX_OPEN_FOR_READ;
            break;
<#if SYS_FS_FAT_READONLY == false>
        case SYS_FS_FILE_OPEN_WRITE:
        case SYS_FS_FILE_OPEN_WRITE_PLUS:
        case SYS_FS_FILE_OPEN_READ_PLUS:
        case SYS_FS_FILE_OPEN_APPEND:
        case SYS_FS_FILE_OPEN_APPEND_PLUS:
            filex_mode = FX_OPEN_FOR_WRITE;
            break;
</#if>
        default:
            filex_mode = FX_INVALID_STATE;
            break;
    }

    if(filex_mode == FX_INVALID_STATE)
    {
        return FX_ACCESS_ERROR;
    }

    for (index = 0; index < SYS_FS_MAX_FILES; index++)
    {
        if(FILEXFileObject[index].inUse == false)
        {
            FILEXFileObject[index].inUse = true;
            fp = &FILEXFileObject[index].fileObj;
            *(uintptr_t *)handle = (uintptr_t)&FILEXFileObject[index];
            break;
        }
    }

    if (filex_mode == FX_OPEN_FOR_READ)
    {
        res = (int)fx_file_open(media_ptr, fp, (char *)(path + 2), FX_OPEN_FOR_READ);
    }
<#if SYS_FS_FAT_READONLY == false>
    else
    {
        res = (int)fx_file_create(media_ptr, (char *)(path + 2));

        if ((res == FX_SUCCESS) || (res == FX_ALREADY_CREATED))
        {
            res = (int)fx_file_open(media_ptr, fp, (char *)(path + 2), FX_OPEN_FOR_WRITE);

            if ((res == FX_SUCCESS) && ((sysfs_mode == SYS_FS_FILE_OPEN_APPEND) || (sysfs_mode == SYS_FS_FILE_OPEN_APPEND_PLUS)))
            {
                res = (int)fx_file_seek(fp, (uint32_t)fp->fx_file_current_file_size);
            }
        }
    }
</#if>

    if ((index < SYS_FS_MAX_FILES) && (res != FX_SUCCESS))
    {
        FILEXFileObject[index].inUse = false;
    }

    return res;
}

int FILEX_read (
    uintptr_t handle, /* Pointer to the file object */
    void* buff,       /* Pointer to data buffer */
    uint32_t btr,     /* Number of bytes to read */
    uint32_t* br      /* Pointer to number of bytes read */
)
{
    int res = FX_PTR_ERROR;
    FILEX_FILE_OBJECT *ptr = (FILEX_FILE_OBJECT *)handle;
    FX_FILE *fp = &ptr->fileObj;

    res = (int)fx_file_read(fp, buff, btr, (ULONG *)br);

    return res;
}

int FILEX_close (
    uintptr_t handle /* Pointer to the file object to be closed */
)
{
    int res = FX_PTR_ERROR;
    FILEX_FILE_OBJECT *ptr = (FILEX_FILE_OBJECT *)handle;
    FX_FILE *fp = &ptr->fileObj;

    if(ptr->inUse == false)
    {
        return res;
    }

    res = (int)fx_file_close(fp);

    if (res == FX_SUCCESS)
    {
        ptr->inUse = false;
    }
    return res;
}

int FILEX_lseek (
    uintptr_t handle,   /* Pointer to the file object */
    uint32_t ofs        /* File pointer from top of file */
)
{
    int res = FX_PTR_ERROR;
    FILEX_FILE_OBJECT *ptr = (FILEX_FILE_OBJECT *)handle;
    FX_FILE *fp = &ptr->fileObj;

    res = (int)fx_file_relative_seek(fp, ofs, FX_SEEK_BEGIN);

    return res;
}

int FILEX_stat (
    const char* path,   /* Pointer to the file path */
    uintptr_t fileInfo  /* Pointer to file information to return */
)
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    UINT attributes, year, month, day;
    UINT hour, minute, second;
    ULONG size;
    CHAR fileName[FX_MAX_LONG_NAME_LEN];
    FILEX_STATUS *fileStat = (FILEX_STATUS *)fileInfo;
    int32_t volumeNum = (int32_t)path[0] - (int32_t)'0';

    media_ptr = &FILEXMediaObject[volumeNum].mediaObj;

    res = (int)fx_directory_information_get(media_ptr, (char *)(path + 2), &attributes, &size,
                                       &year, &month, &day,
                                       &hour, &minute, &second);

    if (res != FX_SUCCESS)
    {
        return res;
    }

    if ((INT)attributes == FX_DIRECTORY)
    {
        fileStat->fattrib = (uint8_t)SYS_FS_ATTR_DIR;
    }
    else if ((INT)attributes != FX_VOLUME)
    {
        fileStat->fattrib = (uint8_t)SYS_FS_ATTR_FILE;
    }
    else
    {
        /* Nothing to do */
    }

    fileStat->fsize = size;

    fileStat->fdate = (uint16_t)((((year - (UINT)FX_BASE_YEAR) & (UINT)FX_YEAR_MASK) << FX_YEAR_SHIFT)
                    | ((month & (UINT)FX_MONTH_MASK) << FX_MONTH_SHIFT)
                    | (day & (UINT)FX_DAY_MASK));

    fileStat->ftime = (uint16_t)(((hour & (UINT)FX_HOUR_MASK) << FX_HOUR_SHIFT)
                    | ((minute & (UINT)FX_MINUTE_MASK) << FX_MINUTE_SHIFT)
                    | ((second / 2U) & (UINT)FX_SECOND_MASK));

    res = (int)fx_directory_long_name_get(media_ptr, (char *)(path + 2), fileName);

    if (res != FX_SUCCESS)
    {
        return res;
    }

    if (strlen(fileName) < sizeof(fileStat->fname))
    {
        /* Populate the file details. */
        (void)strcpy(fileStat->fname, fileName);
    }
    else
    {
        /* Populate the file details. */
        (void)strncpy(fileStat->fname, fileName, (sizeof(fileStat->fname) - 2U));
        fileStat->fname[(sizeof(fileStat->fname) - 1U)] = '\0';
    }

<#if SYS_FS_LFN_ENABLE == true>
    if (fileStat->lfname != NULL)
    {
        fileStat->lfname[0] = '\0';
    }

    res = (int)fx_directory_short_name_get(media_ptr, (char *)(path + 2), fileName);

    if (res != FX_SUCCESS)
    {
        return res;
    }

    if (strlen(fileName) < sizeof(fileStat->altname))
    {
        /* Populate the file details. */
        (void)strcpy(fileStat->altname, fileName);
    }
    else
    {
        /* Populate the file details. */
        (void)strncpy(fileStat->altname, fileName, (sizeof(fileStat->altname) - 2U));
        fileStat->altname[(sizeof(fileStat->altname) - 1U)] = '\0';
    }
</#if>

    return res;
}

int FILEX_getlabel (
    const char* path,  /* Path name of the logical drive number */
    char* label,       /* Pointer to a buffer to return the volume label */
    uint32_t* vsn           /* Pointer to a variable to return the volume serial number */
)
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    int32_t volumeNum = (int32_t)path[0] - (int32_t)'0';

    media_ptr = &FILEXMediaObject[volumeNum].mediaObj;

    res = (int)fx_media_volume_get(media_ptr, label, FX_DIRECTORY_SECTOR);

    return res;
}

int FILEX_getcwd (
    char* buff,     /* Pointer to the directory path */
    uint32_t len    /* Size of path */
)
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    uint8_t index = 0;
    char* path = NULL;

    for (index = 0; index != SYS_FS_VOLUME_NUMBER; index++)
    {
        if(FILEXMediaObject[index].inUse == true)
        {
            media_ptr = &FILEXMediaObject[index].mediaObj;
            break;
        }
    }

    if (media_ptr != NULL)
    {
        res = (int)fx_directory_default_get(media_ptr, &path);

        if (res == FX_SUCCESS)
        {
            if (len < strlen(path))
            {
                (void)strncpy(buff, path, len);
            }
            else
            {
                (void)strcpy(buff, path);
            }
        }
    }

    return res;
}

int FILEX_opendir (
    uintptr_t handle,           /* Pointer to directory object to create */
    const char* path   /* Pointer to the directory path */
)
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    int32_t volumeNum = (int32_t)path[0] - (int32_t)'0';
    uint32_t index = 0;
    FX_MEDIA *dp = NULL;

    media_ptr = &FILEXMediaObject[volumeNum].mediaObj;

    for(index = 0; index < SYS_FS_MAX_FILES; index++)
    {
        if(FILEXDirObject[index].inUse == false)
        {
            FILEXDirObject[index].inUse = true;
            dp = &FILEXDirObject[index].dirObj;
            *(uintptr_t *)handle = (uintptr_t)&FILEXDirObject[index];
            break;
        }
    }

    if(index >= SYS_FS_MAX_FILES)
    {
        return res;
    }

    res = (int)fx_directory_default_set(media_ptr, (char *)(path + 2));

    if (res != FX_SUCCESS)
    {
        FILEXDirObject[index].inUse = false;
    }
    else
    {
        *dp = *media_ptr;
    }

    return res;
}

int FILEX_readdir (
    uintptr_t handle,   /* Pointer to the open directory object */
    uintptr_t fileInfo  /* Pointer to file information to return */
)
{
    int res = FX_PTR_ERROR;
    FILEX_DIR_OBJECT *ptr = (FILEX_DIR_OBJECT *)handle;
    FX_MEDIA *dp = &ptr->dirObj;
    SYS_FS_FSTAT *fileStat = (SYS_FS_FSTAT *)fileInfo;
    UINT attributes, year, month, day;
    CHAR fileName[FX_MAX_LONG_NAME_LEN];
    ULONG size;
    UINT hour, minute, second;

    res = (int)fx_directory_next_full_entry_find(dp, fileName, &attributes, &size,
                                           &year, &month, &day,
                                           &hour, &minute, &second);

    if (res != FX_SUCCESS)
    {
        return res;
    }

    if ((INT)attributes == FX_DIRECTORY)
    {
        fileStat->fattrib = (uint8_t)SYS_FS_ATTR_DIR;
    }
    else if ((INT)attributes != FX_VOLUME)
    {
        fileStat->fattrib = (uint8_t)SYS_FS_ATTR_FILE;
    }
    else
    {
        /* Nothing to do */
    }

    fileStat->fsize = size;

    fileStat->fdate = (uint16_t)((((year - (UINT)FX_BASE_YEAR) & (UINT)FX_YEAR_MASK) << FX_YEAR_SHIFT)
                    | ((month & (UINT)FX_MONTH_MASK) << FX_MONTH_SHIFT)
                    | (day & (UINT)FX_DAY_MASK));

    fileStat->ftime = (uint16_t)(((hour & (UINT)FX_HOUR_MASK) << FX_HOUR_SHIFT)
                    | ((minute & (UINT)FX_MINUTE_MASK) << FX_MINUTE_SHIFT)
                    | ((second / 2U) & (UINT)FX_SECOND_MASK));

    if (strlen(fileName) < sizeof(fileStat->fname))
    {
        /* Populate the file details. */
        (void)strcpy(fileStat->fname, fileName);
    }
    else
    {
        /* Populate the file details. */
        (void)strncpy(fileStat->fname, fileName, (sizeof(fileStat->fname) - 2U));
        fileStat->fname[(sizeof(fileStat->fname) - 1U)] = '\0';
    }

<#if SYS_FS_LFN_ENABLE == true>
    if (fileStat->lfname != NULL)
    {
        fileStat->lfname[0] = '\0';
    }

    res = (int)fx_directory_short_name_get(dp, fileStat->fname, fileName);

    if (res != FX_SUCCESS)
    {
        return res;
    }

    if (strlen(fileName) < sizeof(fileStat->altname))
    {
        /* Populate the file details. */
        (void)strcpy(fileStat->altname, fileName);
    }
    else
    {
        /* Populate the file details. */
        (void)strncpy(fileStat->altname, fileName, (sizeof(fileStat->altname) - 2U));
        fileStat->altname[(sizeof(fileStat->altname) - 1U)] = '\0';
    }
</#if>

    return res;
}

int FILEX_closedir (
    uintptr_t handle /* Pointer to the directory object to be closed */
)
{
    int res = FX_PTR_ERROR;
    FILEX_DIR_OBJECT *ptr = (FILEX_DIR_OBJECT *)handle;
    FX_MEDIA *dp = &ptr->dirObj;

    if (ptr->inUse == false)
    {
        return res;
    }

    res = (int)fx_directory_default_set(dp, NULL);

    if (res == FX_SUCCESS)
    {
        ptr->inUse = false;
    }

    return res;
}

int FILEX_chdir (
    const char* path   /* Pointer to the directory path */
)
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    int32_t volumeNum = (int32_t)path[0] - (int32_t)'0';

    media_ptr = &FILEXMediaObject[volumeNum].mediaObj;

    res = (int)fx_directory_default_set(media_ptr, (char *)(path + 2));

    return res;
}

int FILEX_chdrive (
    uint8_t drv     /* Drive number */
)
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    media_ptr = &FILEXMediaObject[drv].mediaObj;

    res = (int)fx_directory_default_set(media_ptr, NULL);

    return res;
}

<#if SYS_FS_FAT_READONLY == false>

int FILEX_write (
    uintptr_t handle,   /* Pointer to the file object */
    const void *buff,   /* Pointer to the data to be written */
    uint32_t btw,       /* Number of bytes to write */
    uint32_t* bw        /* Pointer to number of bytes written */
)
{
    int res = FX_PTR_ERROR;
    FILEX_FILE_OBJECT *ptr = (FILEX_FILE_OBJECT *)handle;
    FX_FILE *fp = &ptr->fileObj;

    res = (int)fx_file_write(fp, (void *)buff, btw);

    if (res == FX_SUCCESS)
    {
        *bw = btw;
    }
    else
    {
        *bw = 0;
    }

    return res;
}

uint32_t FILEX_tell(uintptr_t handle)
{
    FILEX_FILE_OBJECT *ptr = (FILEX_FILE_OBJECT *)handle;
    FX_FILE *fp = &ptr->fileObj;

    return ((uint32_t)fp->fx_file_current_file_offset);
}

bool FILEX_eof(uintptr_t handle)
{
    FILEX_FILE_OBJECT *ptr = (FILEX_FILE_OBJECT *)handle;
    FX_FILE *fp = &ptr->fileObj;

    return ((bool)(fp->fx_file_current_file_offset >= fp->fx_file_current_file_size));
}

uint32_t FILEX_size(uintptr_t handle)
{
    FILEX_FILE_OBJECT *ptr = (FILEX_FILE_OBJECT *)handle;
    FX_FILE *fp = &ptr->fileObj;

    return ((uint32_t)fp->fx_file_current_file_size);
}

int FILEX_mkdir (
    const char* path       /* Pointer to the directory path */
)
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    int32_t volumeNum = (int32_t)path[0] - (int32_t)'0';

    media_ptr = &FILEXMediaObject[volumeNum].mediaObj;

    res = (int)fx_directory_create(media_ptr, (char *)(path + 2));

    if (res == FX_ALREADY_CREATED)
    {
        res = FX_SUCCESS;
    }

    return res;
}

int FILEX_unlink (
    const char* path       /* Pointer to the file or directory path */
)
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    int32_t volumeNum = (int32_t)path[0] - (int32_t)'0';

    media_ptr = &FILEXMediaObject[volumeNum].mediaObj;

    if ((int)fx_directory_name_test(media_ptr, (char *)(path + 2)) == FX_SUCCESS)
    {
        res = (int)fx_directory_delete(media_ptr, (char *)(path + 2));
    }
    else
    {
        res = (int)fx_file_delete(media_ptr, (char *)(path + 2));
    }

   return res;
}

int FILEX_setlabel (
    const char* label  /* Volume label to set with heading logical drive number */
)
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    int32_t volumeNum = (int32_t)label[0] - (int32_t)'0';

    media_ptr = &FILEXMediaObject[volumeNum].mediaObj;

    res = (int)fx_media_volume_set(media_ptr, (char *)(label + 2));

    return res;
}

int FILEX_truncate (
    uintptr_t handle /* Pointer to the file object */
)
{
    int res = FX_PTR_ERROR;
    FILEX_FILE_OBJECT *ptr = (FILEX_FILE_OBJECT *)handle;
    FX_FILE *fp = &ptr->fileObj;

    res = (int)fx_file_truncate_release(fp, (uint32_t)fp->fx_file_current_file_offset);

    return res;
}

int FILEX_chmod (
    const char* path,  /* Pointer to the file path */
    uint8_t attr,       /* Attribute bits */
    uint8_t mask        /* Attribute mask to change */
)
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    int32_t volumeNum = (int32_t)path[0] - (int32_t)'0';
    UINT attribs = (UINT)attr;
    attribs &= (UINT)mask;

    media_ptr = &FILEXMediaObject[volumeNum].mediaObj;

    if (attribs != 0U)
    {
        if ((int)fx_directory_name_test(media_ptr, (char *)(path + 2)) == FX_SUCCESS)
        {
            res = (int)fx_directory_attributes_set(media_ptr, (char *)(path + 2), attribs);
        }
        else
        {
            res = (int)fx_file_attributes_set(media_ptr, (char *)(path + 2), attribs);
        }
    }

    return res;
}

int FILEX_utime (
    const char* path,  /* Pointer to the file/directory name */
    uintptr_t ptr /* Pointer to the time stamp to be set */
)
{
    SYS_FS_FSTAT *fileStat = (SYS_FS_FSTAT *)ptr;
    SYS_FS_TIME sys_time;
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    int32_t volumeNum = (int32_t)path[0] - (int32_t)'0';

    media_ptr = &FILEXMediaObject[volumeNum].mediaObj;
    sys_time.timeDate.date = fileStat->fdate;
    sys_time.timeDate.time = fileStat->ftime;

    res = (int)fx_file_date_time_set(media_ptr, (char *)(path + 2),
                                (sys_time.discreteTime.year + (UINT)FX_BASE_YEAR), sys_time.discreteTime.month, sys_time.discreteTime.day,
                                sys_time.discreteTime.hour, sys_time.discreteTime.minute, sys_time.discreteTime.second);

    return res;
}

int FILEX_rename (
    const char* path_old,  /* Pointer to the object to be renamed */
    const char* path_new   /* Pointer to the new name */
)
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    uint8_t index = 0;

    for (index = 0; index != SYS_FS_VOLUME_NUMBER; index++)
    {
        if(FILEXMediaObject[index].inUse == true)
        {
            media_ptr = &FILEXMediaObject[index].mediaObj;
            break;
        }
    }

    if (media_ptr != NULL)
    {
        if ((int)fx_directory_name_test(media_ptr, (char *)path_old) == FX_SUCCESS)
        {
            res = (int)fx_directory_rename(media_ptr, (char *)path_old, (char *)path_new);
        }
        else
        {
            res = (int)fx_file_rename(media_ptr, (char *)path_old, (char *)path_new);
        }
    }

    return res;
}

int FILEX_sync (
    uintptr_t handle /* Pointer to the file object */
)
{
    int res = FX_PTR_ERROR;
    FILEX_FILE_OBJECT *ptr = (FILEX_FILE_OBJECT *)handle;
    FX_FILE *fp = &ptr->fileObj;

    res = (int)fx_media_flush(fp->fx_file_media_ptr);

    return res;
}

int FILEX_mkfs (
    uint8_t vol,            /* Logical drive number */
    const SYS_FS_FORMAT_PARAM*  f_opt, /* Format options */
    void* work,             /* Not used */
    uint32_t len            /* Not used */
)
{
    int res = FX_PTR_ERROR;
    FX_MEDIA *media_ptr = NULL;
    uint32_t numSectors = 64;
    uint32_t sectors_per_cluster = 8;
    uint32_t number_of_fats = 1;
    uint32_t number_of_dir_entries = 32;


    FILEXMediaObject[vol].vol_num = vol;

    /* Check if the drive number is valid */
    if (vol >= SYS_FS_VOLUME_NUMBER)
    {
        return res;
    }

    if (f_opt->n_fat != 0U)
    {
        number_of_fats = f_opt->n_fat;
    }
    if (f_opt->n_root != 0U)
    {
        number_of_dir_entries = f_opt->n_root;
    }
    if (f_opt->au_size != 0U)
    {
        sectors_per_cluster = f_opt->au_size / SYS_FS_MEDIA_MAX_BLOCK_SIZE;
        if (sectors_per_cluster == 0U)
        {
            sectors_per_cluster = 1;
        }
    }

    media_ptr = &FILEXMediaObject[vol].mediaObj;

    numSectors = filex_io_disk_get_sector_count(VolToPart[vol].pd);

    res = (int)fx_media_format(media_ptr, filex_io_drv_entry, &FILEXMediaObject[vol].vol_num, mediaBuffer, SYS_FS_MEDIA_MAX_BLOCK_SIZE, diskName,
                          number_of_fats, number_of_dir_entries, 0, numSectors, SYS_FS_MEDIA_MAX_BLOCK_SIZE, sectors_per_cluster, 1, 1);

    return res;
}

int FILEX_getclusters (
    const char *path,
    uint32_t *tot_sec,
    uint32_t *free_sec
)
{
    FX_MEDIA *media_ptr = NULL;
    int res = FX_PTR_ERROR;
    int32_t volumeNum = (int32_t)path[0] - (int32_t)'0';
    ULONG64 available_space = 0;

    media_ptr = &FILEXMediaObject[volumeNum].mediaObj;

    res = (int)fx_media_extended_space_available(media_ptr, &available_space);

    if (res != FX_SUCCESS)
    {
        *tot_sec = 0;
        *free_sec = 0;
    }
    else
    {
        /* Get total sectors and free sectors */
        *tot_sec = (uint32_t)media_ptr->fx_media_total_sectors;
        *free_sec = (uint32_t)(available_space / SYS_FS_FILEX_MAX_SS);
    }

    return res;
}

</#if>

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */