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


#ifndef SYS_FS_FILEX_INTERFACE_H
#define SYS_FS_FILEX_INTERFACE_H

#include "filex_io_drv.h"
#include "fx_api.h"
#include "system/fs/sys_fs.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdarg.h>

/* File status structure */
typedef struct {
<#if SYS_FS_FAT == true && SYS_FS_FAT_EXFAT_ENABLE == true>
    uint64_t    fsize;      /* File size */
<#else>
    uint32_t    fsize;      /* File size */
</#if>
    uint16_t    fdate;      /* Last modified date */
    uint16_t    ftime;      /* Last modified time */
    uint8_t     fattrib;    /* Attribute */
<#if SYS_FS_LFN_ENABLE == true>
    /* Alternate/Short file name (8.3 format) */
    char        altname[13];
    /* Primary/Long file name */
    char        fname[FX_MAX_LONG_NAME_LEN];
    /* Pointer to the LFN buffer */
    char       *lfname;
    /* Size of LFN buffer */
    uint32_t    lfsize;
<#else>
    /* Short file name (8.3 format) */
    char        fname[13];
</#if>
} FILEX_STATUS;

int FILEX_mount (uint8_t vol);

int FILEX_unmount (uint8_t vol);

int FILEX_open (uintptr_t handle, const char* path, uint8_t mode);

int FILEX_read (uintptr_t handle, void* buff, uint32_t btr, uint32_t* br);

int FILEX_close (uintptr_t handle);

int FILEX_lseek (uintptr_t handle, uint32_t ofs);

int FILEX_stat (const char* path, uintptr_t fileInfo);

int FILEX_getlabel (const char* path, char* label, uint32_t* vsn);

int FILEX_getcwd (char* buff, uint32_t len);

int FILEX_opendir (uintptr_t handle, const char* path);

int FILEX_readdir (uintptr_t handle, uintptr_t fileInfo);

int FILEX_closedir (uintptr_t handle);

int FILEX_chdir (const char* path);

int FILEX_chdrive (uint8_t drv);

<#if SYS_FS_FILEX_READONLY == false>
    <#lt>int FILEX_write (uintptr_t handle, const void* buff, uint32_t btw, uint32_t* bw);

    <#lt>uint32_t FILEX_tell(uintptr_t handle);

    <#lt>bool FILEX_eof(uintptr_t handle);

    <#lt>uint32_t FILEX_size(uintptr_t handle);

    <#lt>int FILEX_mkdir (const char* path);

    <#lt>int FILEX_unlink (const char* path);

    <#lt>int FILEX_setlabel (const char* label);

    <#lt>int FILEX_truncate (uintptr_t handle);

    <#lt>int FILEX_chmod (const char* path, uint8_t attr, uint8_t mask);

    <#lt>int FILEX_utime (const char* path, uintptr_t ptr);

    <#lt>int FILEX_rename (const char* path_old, const char* path_new);

    <#lt>int FILEX_sync (uintptr_t handle);

    <#lt>int FILEX_mkfs (uint8_t vol, const SYS_FS_FORMAT_PARAM*  f_opt, void* work, uint32_t len);

    <#lt>int FILEX_getclusters (const char *path, uint32_t *tot_sec, uint32_t *free_sec);

</#if>

#ifdef __cplusplus
}
#endif

#endif /* SYS_FS_FILEX_INTERFACE_H */
