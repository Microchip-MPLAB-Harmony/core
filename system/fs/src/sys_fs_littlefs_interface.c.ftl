/*******************************************************************************
* Copyright (C) 2021 Microchip Technology Inc. and its subsidiaries.
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

#include "system/fs/sys_fs_littlefs_interface.h"
#include "system/fs/littlefs/lfs_bdio.h"
#include "system/fs/sys_fs.h"


// include littlefs license in the binary
<#if core.COMPILER_CHOICE == "IAR">
__root const char* szLicense =\
<#elseif core.COMPILER_CHOICE == "KEIL">
 const char* szLicense __attribute__ ((used)) =\
<#else>
 const char* szLicense __attribute__ ((keep)) =\
</#if>
"Copyright (c) 2017, Arm Limited. All rights reserved.\
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\
\
* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the\
documentation and/or other materials provided with the distribution.\
* Neither the name of ARM nor the names of its contributors may be used to endorse or promote products derived from this software\
without specific prior written permission.\
\
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES,\
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE\
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,\
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS\
OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,\
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF\
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.";

typedef struct
{
    bool inUse;
    lfs_t volObj;
} LITTLEFS_VOLUME_OBJECT;

typedef struct
{
    bool inUse;
    lfs_file_t fileObj;
} LITTLEFS_FILE_OBJECT;

typedef struct
{
    bool inUse;
    lfs_dir_t dirObj;
} LITTLEFS_DIR_OBJECT;

static LITTLEFS_VOLUME_OBJECT CACHE_ALIGN LITTLEFSVolume[SYS_FS_VOLUME_NUMBER];
static LITTLEFS_FILE_OBJECT CACHE_ALIGN LFSFileObject[SYS_FS_MAX_FILES];
static LITTLEFS_DIR_OBJECT CACHE_ALIGN LFSDirObject[SYS_FS_MAX_FILES];
static uint8_t startupflag = 0;

#define LFS_READ_SIZE      SYS_FS_LFS_ALIGNED_BUFFER_LEN
#define LFS_PROG_SIZE      SYS_FS_LFS_ALIGNED_BUFFER_LEN
#define LFS_BLOCK_SIZE     SYS_FS_LFS_ALIGNED_BUFFER_LEN
#define LFS_BLOCK_COUNT    ((${SYS_FS_LFS_SIZE}U * 1024U) / SYS_FS_LFS_ALIGNED_BUFFER_LEN)
#define LFS_BLOCK_CYCLES   16
#define LFS_CACHE_SIZE     SYS_FS_LFS_ALIGNED_BUFFER_LEN
#define LFS_LOOKAHEAD_SIZE 64

static uint8_t ReadBuf[LFS_CACHE_SIZE] = {0};
static uint8_t ProgBuf[LFS_CACHE_SIZE] = {0};
static uint8_t LookaheadBuf[LFS_LOOKAHEAD_SIZE] = {0};

static BLOCK_DEV bd;
static const struct lfs_config cfg = {
        .context        = &bd,
        .read           = lfs_bdio_read,
        .prog           = lfs_bdio_prog,
        .erase          = lfs_bdio_erase,
        .sync           = lfs_bdio_sync,
        .read_size      = LFS_READ_SIZE,
        .prog_size      = LFS_PROG_SIZE,
        .block_size     = LFS_BLOCK_SIZE,
        .block_count    = LFS_BLOCK_COUNT,
        .block_cycles   = LFS_BLOCK_CYCLES,
        .cache_size     = LFS_CACHE_SIZE,
        .lookahead_size = LFS_LOOKAHEAD_SIZE,
        .read_buffer    = ReadBuf,
        .prog_buffer    = ProgBuf,
        .lookahead_buffer = LookaheadBuf,
    };

static SYS_FS_ERROR LFS_Err_To_SYSFS_Err(enum lfs_error err)
{

    if ( err == LFS_ERR_OK)
    {
        return SYS_FS_ERROR_OK;
    }
    else if ( err == LFS_ERR_IO)
    {
        return SYS_FS_ERROR_IO;
    }
    else if ( err == LFS_ERR_CORRUPT)
    {
        return SYS_FS_ERROR_CORRUPT;
    }
    else if ( err == LFS_ERR_NOENT)
    {
        return SYS_FS_ERROR_NOENT;
    }
    else if ( err == LFS_ERR_EXIST)
    {
        return SYS_FS_ERROR_EXIST;
    }
    else if ( err == LFS_ERR_NOTDIR)
    {
        return SYS_FS_ERROR_NOTDIR;
    }
    else if ( err == LFS_ERR_ISDIR)
    {
        return SYS_FS_ERROR_ISDIR;
    }
    else if ( err == LFS_ERR_NOTEMPTY)
    {
        return SYS_FS_ERROR_NOTEMPTY;
    }
    else if ( err == LFS_ERR_BADF)
    {
        return SYS_FS_ERROR_BADF;
    }
    else if ( err == LFS_ERR_FBIG)
    {
        return SYS_FS_ERROR_FBIG;
    }
    else if ( err == LFS_ERR_INVAL)
    {
        return SYS_FS_ERROR_INVAL;
    }
    else if ( err == LFS_ERR_NOSPC)
    {
        return SYS_FS_ERROR_NOSPC;
    }
    else if ( err == LFS_ERR_NOMEM)
    {
        return SYS_FS_ERROR_NOMEM;
    }
    else if ( err == LFS_ERR_NOATTR)
    {
        return SYS_FS_ERROR_NOATTR;
    }
    else if ( err == LFS_ERR_NAMETOOLONG)
    {
        return SYS_FS_ERROR_NAMETOOLONG;
    }
    else
    {
        return SYS_FS_ERROR_INVAL;
    }

}

int LITTLEFS_mount ( uint8_t vol )
{
    lfs_t *fs = NULL;
    enum lfs_error res = LFS_ERR_INVAL;
    uint8_t index = 0;

    if(0U == startupflag)
    {
        startupflag = 1;
        for(index = 0; index != SYS_FS_VOLUME_NUMBER ; index++ )
        {
            LITTLEFSVolume[index].inUse = false;
        }
        for(index = 0; index != SYS_FS_MAX_FILES ; index++ )
        {
            LFSFileObject[index].inUse = false;
            LFSDirObject[index].inUse = false;
        }
    }

    /* Check if the drive number is valid */
    if (vol >= SYS_FS_VOLUME_NUMBER)
    {
        return (int)LFS_ERR_INVAL;
    }

    /* If the volume specified is already in use, then return failure, as we cannot mount it again */
    if(LITTLEFSVolume[vol].inUse == true)
    {
        return (int)LFS_ERR_EXIST;
    }
    else
    {
        fs = &LITTLEFSVolume[vol].volObj;
    }

    bd.disk_num = vol;

    (void) lfs_bdio_initilize(0);   /* Initialize the physical drive */

    res = (enum lfs_error)lfs_mount(fs, &cfg);


    if (res == LFS_ERR_OK)
    {
        LITTLEFSVolume[vol].inUse = true;
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));
}

int LITTLEFS_unmount ( uint8_t vol )
{
    lfs_t *fs = NULL;
    enum lfs_error res = LFS_ERR_IO;
    uint32_t cnt =0;

    fs = &LITTLEFSVolume[vol].volObj;


    if (vol >= SYS_FS_VOLUME_NUMBER)
    {
        return (int)LFS_ERR_INVAL;
    }

    /* If the volume specified not in use, then return failure, as we cannot unmount mount a free volume */
    if(LITTLEFSVolume[vol].inUse == false)
    {
        return (int)LFS_ERR_INVAL;
    }

    // free the volume
    LITTLEFSVolume[vol].inUse = false;

    for(cnt = 0; cnt < SYS_FS_MAX_FILES; cnt++)
    {
        if(LFSFileObject[cnt].inUse != false)
        {
            (void) memset(&LFSFileObject[cnt].fileObj, 0, sizeof(LFSFileObject[cnt].fileObj));
            LFSFileObject[cnt].inUse = false;
        }
        if(LFSDirObject[cnt].inUse != false)
        {
            (void) memset(&LFSDirObject[cnt].dirObj, 0, sizeof(LFSDirObject[cnt].dirObj));
            LFSDirObject[cnt].inUse = false;
        }
    }

    res = (enum lfs_error)lfs_unmount(fs);

    /* For MISRA C satisfy used this condition */
    if ( (uint8_t)res == 0U)
    {
       /* Do nothing */
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));
}

/* MISRA C-2012 Rule 2.1 deviated:1 Deviation record ID -  H3_MISRAC_2012_R_2_1_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:1 "MISRA C-2012 Rule 2.1" "H3_MISRAC_2012_R_2_1_DR_1"
</#if>
int LITTLEFS_open (
    uintptr_t handle,   /* Pointer to the blank file object */
    const char * path,  /* Pointer to the file name */
    uint8_t mode        /* Access mode and file open mode flags */
)
{
    uint8_t volumeNum = 0;
    uint32_t temp;
    int flags;
    lfs_t *fs = NULL;
    lfs_file_t* fp = NULL;
    SYS_FS_FILE_OPEN_ATTRIBUTES mode_Check = (SYS_FS_FILE_OPEN_ATTRIBUTES)mode;

    volumeNum = ((uint8_t)path[0] - (uint8_t)'0');

    fs = &LITTLEFSVolume[volumeNum].volObj;

    enum lfs_error res = LFS_ERR_NOATTR;
    uint32_t index = 0;


    /* Convert the SYS_FS file open attributes to FAT FS attributes */
    switch(mode_Check)
    {
        case SYS_FS_FILE_OPEN_READ:
            flags = (int)LFS_O_RDONLY;
            break;
<#if SYS_FS_LFS_READONLY == false>
        case SYS_FS_FILE_OPEN_WRITE:
            temp  = (uint32_t)LFS_O_WRONLY | (uint32_t)LFS_O_CREAT | (uint32_t)LFS_O_TRUNC;
            flags = (int)temp;
            break;
        case SYS_FS_FILE_OPEN_APPEND:
            temp  = (uint32_t)LFS_O_WRONLY | (uint32_t)LFS_O_CREAT | (uint32_t)LFS_O_APPEND;
            flags = (int)temp;
            break;
        case SYS_FS_FILE_OPEN_READ_PLUS:
            flags = (int)LFS_O_RDWR;
            break;
        case SYS_FS_FILE_OPEN_WRITE_PLUS:
            temp  = (uint32_t)LFS_O_RDWR | (uint32_t)LFS_O_CREAT | (uint32_t)LFS_O_TRUNC;
            flags = (int)temp;
            break;
        case SYS_FS_FILE_OPEN_APPEND_PLUS:
            temp  = (uint32_t)LFS_O_RDWR | (uint32_t)LFS_O_CREAT | (uint32_t)LFS_O_APPEND;
            flags = (int)temp;
            break;
</#if>
        default:
            return ((int)LFS_Err_To_SYSFS_Err(res));
            break;
    }

    for (index = 0; index < SYS_FS_MAX_FILES; index++)
    {
        if(LFSFileObject[index].inUse == false)
        {
            LFSFileObject[index].inUse = true;
            fp = &LFSFileObject[index].fileObj;
            *(uintptr_t *)handle = (uintptr_t)&LFSFileObject[index];
            break;
        }
    }

    if (index < SYS_FS_MAX_FILES)
    {
        res = (enum lfs_error)lfs_file_open(fs, fp, (const char *)path + 2, flags);

       if ((int)res != 0)
        {
            LFSFileObject[index].inUse = false;
        }

        return ((int)LFS_Err_To_SYSFS_Err(res));
    }
    else
    {
        return (int)SYS_FS_ERROR_NOSPC;
    }
}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 2.1"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */

int LITTLEFS_read (
    uintptr_t handle, /* Pointer to the file object */
    void* buff,       /* Pointer to data buffer */
    uint32_t btr,     /* Number of bytes to read */
    uint32_t* br      /* Pointer to number of bytes read */
)
{
    lfs_t *fs = NULL;
    enum lfs_error res = LFS_ERR_OK;
    LITTLEFS_FILE_OBJECT *ptr = (LITTLEFS_FILE_OBJECT *)handle;
    lfs_file_t *fp = &ptr->fileObj;
    int32_t lfs_ret = 0;

    fs = &LITTLEFSVolume[0].volObj;


    lfs_ret = lfs_file_read(fs, fp, buff, btr);

    if (lfs_ret < 0)
    {
        res = (enum lfs_error)lfs_ret;
        *br = 0;
    }
    else
    {
        *br = (uint32_t)lfs_ret;
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));

}

int LITTLEFS_close (
    uintptr_t handle /* Pointer to the file object to be closed */
)
{
    lfs_t *fs = NULL;
    enum lfs_error res = LFS_ERR_OK;
    LITTLEFS_FILE_OBJECT *ptr = (LITTLEFS_FILE_OBJECT *)handle;
    lfs_file_t *fp = &ptr->fileObj;

    fs = &LITTLEFSVolume[0].volObj;

    if(ptr->inUse == false)
    {
        return (int)LFS_ERR_IO;
    }

    res = (enum lfs_error)lfs_file_close(fs, fp);

    if (res == LFS_ERR_OK)
    {
        ptr->inUse = false;
    }
    return ((int)LFS_Err_To_SYSFS_Err(res));

}

int LITTLEFS_lseek (
    uintptr_t handle,   /* Pointer to the file object */
    uint32_t ofs        /* File pointer from top of file */
)
{
    enum lfs_error res = LFS_ERR_OK;
    lfs_soff_t offset;
    LITTLEFS_FILE_OBJECT *ptr = (LITTLEFS_FILE_OBJECT *)handle;
    lfs_file_t *fp = &ptr->fileObj;
    lfs_t *fs = NULL;

    fs = &LITTLEFSVolume[0].volObj;

    offset = (lfs_soff_t)lfs_file_seek(fs, fp, (lfs_soff_t)ofs, (int)LFS_SEEK_SET);

    if (offset >= 0)
    {
        res = LFS_ERR_OK;
    }
    else
    {
        res = LFS_ERR_IO;
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));
}

int LITTLEFS_stat (
    const char* path,   /* Pointer to the file path */
    uintptr_t fileInfo  /* Pointer to file information to return */
)
{

    enum lfs_error res = LFS_ERR_OK;
    LITTLEFS_STATUS *stat = (LITTLEFS_STATUS *)fileInfo;
    struct lfs_info info = {0};
    uint8_t volumeNum = 0;
    lfs_t *fs = NULL;
    uint16_t fileLen = 0;

    volumeNum = ((uint8_t)path[0] - (uint8_t)'0');
    fs = &LITTLEFSVolume[volumeNum].volObj;

    res = (enum lfs_error)lfs_stat(fs, (const char *)path + 3, &info);

    /* For MISRA C satisfy used this condition */
    if ( (uint8_t)res == 0U)
    {
       /* Do nothing */
    }

    fileLen = (uint16_t)strlen (info.name);

<#if SYS_FS_LFN_ENABLE == true>
    if (((stat->lfname) != NULL) && ((stat->lfsize) != 0U))
    {
        if (fileLen > stat->lfsize)
        {
            stat->lfname[0] = '\0';
        }
        else
        {
            /* Populate the file details. */
            (void) strncpy (stat->lfname, info.name, fileLen);
            stat->lfname[fileLen] = '\0';
        }
    }
</#if>

    /* Check if the name of the file is longer than the SFN 8.3 format. */
    if (fileLen > 12U)
    {
        fileLen = 12;
    }

    /* Populate the file details. */
    (void) strncpy (stat->fname, info.name, fileLen);
    stat->fname[fileLen] = '\0';
    stat->fsize = info.size;


    return ((int)LFS_Err_To_SYSFS_Err(res));

}

int LITTLEFS_opendir (
    uintptr_t handle,           /* Pointer to directory object to create */
    const char* path   /* Pointer to the directory path */
)
{
    lfs_t *fs = NULL;
    enum lfs_error res = LFS_ERR_INVAL;
    uint32_t index = 0;
    lfs_dir_t *dp = NULL;

    fs = &LITTLEFSVolume[0].volObj;

    for(index = 0; index < SYS_FS_MAX_FILES; index++)
    {
        if(LFSDirObject[index].inUse == false)
        {
            LFSDirObject[index].inUse = true;
            dp = &LFSDirObject[index].dirObj;
            *(uintptr_t *)handle = (uintptr_t)&LFSDirObject[index];
            break;
        }
    }

    if(index >= SYS_FS_MAX_FILES)
    {
        return (int)LFS_ERR_INVAL;
    }

    res = (enum lfs_error)lfs_dir_open(fs, dp, path+2);

    if (res != LFS_ERR_OK)
    {
        LFSDirObject[index].inUse = false;
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));

}

int LITTLEFS_readdir (
    uintptr_t handle,   /* Pointer to the open directory object */
    uintptr_t fileInfo  /* Pointer to file information to return */
)
{
    lfs_t *fs = NULL;
    int res = -1;
    LITTLEFS_DIR_OBJECT *ptr = (LITTLEFS_DIR_OBJECT *)handle;
    lfs_dir_t *dp = &ptr->dirObj;
    struct lfs_info    info;
    SYS_FS_FSTAT *fileStat = (SYS_FS_FSTAT *)fileInfo;
    uint16_t fileLen = 0;

    fs = &LITTLEFSVolume[0].volObj;

    if (fileStat == NULL)
    {
        res = lfs_dir_rewind(fs, dp);
        return (res == 0) ? 0 : 1;
    }
    else
    {
        res = lfs_dir_read(fs, dp, &info);      // return 1 if success
    }

    if ( info.type == (uint8_t)LFS_TYPE_DIR)
    {
        fileStat->fattrib = (uint8_t)SYS_FS_ATTR_DIR;
    }
    else if ( info.type == (uint8_t)LFS_TYPE_REG)
    {
        fileStat->fattrib = (uint8_t)SYS_FS_ATTR_FILE;
    }
    else
    {
        /* Nothing to do */
    }

    fileStat->fsize = info.size;

<#if SYS_FS_LFN_ENABLE == true>

    if (fileStat->lfsize < strlen(info.name))
    {
        fileLen = (uint16_t)fileStat->lfsize;
    }
    else
    {
        fileLen = (uint16_t)strlen(info.name);
    }
    if ((res ==  1) && (fileStat->lfname != NULL))
    {
        (void) memcpy(fileStat->lfname, info.name, fileLen);
        fileStat->lfname[fileLen] = '\0';
    }
    else if (fileStat->lfname != NULL)
    {
        /* Use fileStat->fname instead */
        fileStat->lfname[0] = '\0';
    }
    else
    {
        /* nothing to do */
    }
</#if>

    if (strlen(info.name) > 12U)
    {
        fileLen = 12;
    }
    else
    {
        fileLen = (uint16_t)strlen(info.name);
    }

    (void) memcpy(fileStat->fname, info.name, fileLen);
    fileStat->fname[fileLen] = '\0';

    return (res == 1) ? 0 : 1;
}

int LITTLEFS_closedir (
    uintptr_t handle /* Pointer to the directory object to be closed */
)
{
    lfs_t *fs = NULL;
    enum lfs_error res = LFS_ERR_INVAL;
    LITTLEFS_DIR_OBJECT *ptr = (LITTLEFS_DIR_OBJECT *)handle;
    lfs_dir_t *dp = &ptr->dirObj;

    fs = &LITTLEFSVolume[0].volObj;

    if(ptr->inUse == false)
    {
        return (int)LFS_ERR_INVAL;
    }

    res = (enum lfs_error)lfs_dir_close(fs, dp);

    if (res == LFS_ERR_OK)
    {
        ptr->inUse = false;
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));
}

<#if SYS_FS_LFS_READONLY == false>
int LITTLEFS_write (
    uintptr_t handle,   /* Pointer to the file object */
    const void *buff,   /* Pointer to the data to be written */
    uint32_t btw,       /* Number of bytes to write */
    uint32_t* bw        /* Pointer to number of bytes written */
)
{
    lfs_t *fs = NULL;
    enum lfs_error res = LFS_ERR_OK;
    LITTLEFS_FILE_OBJECT *ptr = (LITTLEFS_FILE_OBJECT *)handle;
    lfs_file_t *fp = &ptr->fileObj;
    int32_t lfs_ret = 0;

    fs = &LITTLEFSVolume[0].volObj;

    lfs_ret = lfs_file_write(fs, fp, buff, btw);

    if (lfs_ret < 0)
    {
        res = (enum lfs_error)lfs_ret;
        *bw = 0;
    }
    else
    {
        *bw = (uint32_t)lfs_ret;
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));
}
</#if>

uint32_t LITTLEFS_tell(uintptr_t handle)
{
    LITTLEFS_FILE_OBJECT *ptr = (LITTLEFS_FILE_OBJECT *)handle;
    lfs_file_t *fp = &ptr->fileObj;
    lfs_t *fs = NULL;
    int32_t temp_errcheck;

    fs = &LITTLEFSVolume[0].volObj;

    /* For MISRA C satisfy used this code */
    temp_errcheck = lfs_file_tell(fs, fp);

    /* For MISRA C satisfy used this condition */
    if( temp_errcheck == 0)
    {
        /* Do nothing */
    }

    return((uint32_t)temp_errcheck);
}

bool LITTLEFS_eof(uintptr_t handle)
{
    LITTLEFS_FILE_OBJECT *ptr = (LITTLEFS_FILE_OBJECT *)handle;
    lfs_file_t *fp = &ptr->fileObj;
    lfs_t *fs = NULL;
    bool result;

    fs = &LITTLEFSVolume[0].volObj;

     if (lfs_file_tell(fs, fp) ==  lfs_file_size(fs, fp))
     {
         result = true;
     }
     else
     {
         result = false;
     }

    return (result);
}

uint32_t LITTLEFS_size(uintptr_t handle)
{
    LITTLEFS_FILE_OBJECT *ptr = (LITTLEFS_FILE_OBJECT *)handle;
    lfs_file_t *fp = &ptr->fileObj;
    lfs_t *fs = NULL;
    int32_t temp_errcheck;

    fs = &LITTLEFSVolume[0].volObj;

    /* For MISRA C satisfy used this code */
    temp_errcheck = lfs_file_size(fs, fp);

    /* For MISRA C satisfy used this condition */
    if( temp_errcheck == 0)
    {
        /* Do nothing */
    }

    return (uint32_t)temp_errcheck;
}

<#if SYS_FS_LFS_READONLY == false>
int LITTLEFS_mkdir (
    const char* path       /* Pointer to the directory path */
)
{
    lfs_t *fs = NULL;
    enum lfs_error res = LFS_ERR_INVAL;

    fs = &LITTLEFSVolume[0].volObj;
    res = (enum lfs_error)lfs_mkdir(fs, path+2);

    /* For MISRA C satisfy used this condition */
    if ( (uint8_t)res == 0U)
    {
       /* Do nothing */
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));
}

int LITTLEFS_remove (
    const char* path       /* Pointer to the file or directory path */
)
{
    enum lfs_error res = LFS_ERR_INVAL;
    lfs_t *fs = NULL;

    fs = &LITTLEFSVolume[0].volObj;

    res = (enum lfs_error)lfs_remove(fs, path+2);

    /* For MISRA C satisfy used this condition */
    if ( (uint8_t)res == 0U)
    {
       /* Do nothing */
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));
}

int LITTLEFS_truncate (
    uintptr_t handle /* Pointer to the file object */
)
{
    enum lfs_error res = LFS_ERR_INVAL;
    lfs_t *fs = NULL;
    lfs_soff_t fpos= 0;
    LITTLEFS_FILE_OBJECT *ptr = (LITTLEFS_FILE_OBJECT *)handle;
    lfs_file_t *fp = &ptr->fileObj;

    fs = &LITTLEFSVolume[0].volObj;

    fpos = lfs_file_tell(fs, fp);

    if (fpos >=0)
    {
        res = (enum lfs_error)lfs_file_truncate(fs, fp, (uint32_t)fpos);

        /* For MISRA C satisfy used this condition */
        if ( (uint8_t)res == 0U)
        {
           /* Do nothing */
        }
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));
}

int LITTLEFS_rename (
    const char* path_old,  /* Pointer to the object to be renamed */
    const char* path_new   /* Pointer to the new name */
)
{
    lfs_t *fs = NULL;
    enum lfs_error res = LFS_ERR_OK;

    fs = &LITTLEFSVolume[0].volObj;

    res = (enum lfs_error)lfs_rename(fs, path_old, path_new);

    /* For MISRA C satisfy used this condition */
    if ( (uint8_t)res == 0U)
    {
       /* Do nothing */
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));
}

int LITTLEFS_sync (
    uintptr_t handle /* Pointer to the file object */
)
{
    lfs_t *fs = NULL;
    LITTLEFS_ERR res = LFS_ERR_OK;
    LITTLEFS_FILE_OBJECT *ptr = (LITTLEFS_FILE_OBJECT *)handle;
    lfs_file_t *fp = &ptr->fileObj;

    fs = &LITTLEFSVolume[0].volObj;

    res = (LITTLEFS_ERR)lfs_file_sync(fs, fp);

    /* For MISRA C satisfy used this condition */
    if ( (uint8_t)res == 0U)
    {
       /* Do nothing */
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));
}

int LITTLEFS_mkfs (
    uint8_t vol,            /* Logical drive number */
    void* opt,   /* this value is not used */
    void* work,             /* this value is not used  */
    uint32_t len            /* this value is not used  */
)
{
    lfs_t *fs = NULL;
    LITTLEFS_ERR res = LFS_ERR_INVAL;

    /* Check if the drive number is valid */
    if (vol >= SYS_FS_VOLUME_NUMBER)
    {
        return (int)LFS_ERR_INVAL;
    }

    fs = &LITTLEFSVolume[vol].volObj;

    res = (LITTLEFS_ERR)lfs_format(fs, &cfg );

    /* For MISRA C satisfy used this condition */
    if ( (uint8_t)res == 0U)
    {
       /* Do nothing */
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));

}
</#if>

int LITTLEFS_getclusters (
    const char *path,
    uint32_t *totalSectors,
    uint32_t *freeSectors
)
{
    lfs_t *fs = NULL;

    fs = &LITTLEFSVolume[0].volObj;

    int32_t used = lfs_fs_size(fs);
    if (used < 0)
    {
        return ((int)LFS_Err_To_SYSFS_Err((enum lfs_error)used));
    }

    *freeSectors = LFS_BLOCK_COUNT - (uint32_t)used;
    *totalSectors = LFS_BLOCK_COUNT;

    return ((int)LFS_Err_To_SYSFS_Err(LFS_ERR_OK));
}

char *LITTLEFS_gets (char *buff, int len, uintptr_t handle)
{
    lfs_t *fs = NULL;
    int32_t res = 0;
    LITTLEFS_FILE_OBJECT *ptr = (LITTLEFS_FILE_OBJECT *)handle;
    lfs_file_t *fp = &ptr->fileObj;
    char c;
    int chars_read = 0;
    char *pBuff = buff;

    if (len < 1)
    {
        return NULL;
    }

    fs = &LITTLEFSVolume[0].volObj;

    len -= 1;  // Make a room for the termination
    while (chars_read < len)
    {
        res = lfs_file_read( fs, fp, &c, 1 );
        if (res != 1)
        {
            break;      // eof?
        }
        if (c == '\r')
        {
            continue;    // skip over cr
        }

        *pBuff++ = c;
        chars_read++;
        if (c == '\n')
        {
            break;       // end read at lf
        }
    }

    *pBuff = '\0';     // terminate string

    if ((res < 0) || (chars_read == 0))
    {
        return NULL;
    }

    return buff;
}

int LITTLEFS_puts (
    const char *buff,   /* Pointer to the data to be written */
    uintptr_t handle    /* Pointer to the file object */
)
{
    lfs_t *fs = NULL;
    enum lfs_error res = LFS_ERR_OK;
    LITTLEFS_FILE_OBJECT *ptr = (LITTLEFS_FILE_OBJECT *)handle;
    lfs_file_t *fp = &ptr->fileObj;
    int32_t lfs_ret = 0;
    const char strNewLine[2] = "\n";

    fs = &LITTLEFSVolume[0].volObj;

    lfs_size_t btw = strlen(buff);
    lfs_ret = lfs_file_write(fs, fp, buff, btw);

    if (lfs_ret < 0)
    {
        res = (enum lfs_error)lfs_ret;
    }
    else
    {
        lfs_ret = lfs_file_write(fs, fp, strNewLine, 1);

        if (lfs_ret < 0)
        {
            res = (enum lfs_error)lfs_ret;
        }
    }

    return ((int)LFS_Err_To_SYSFS_Err(res));
}
