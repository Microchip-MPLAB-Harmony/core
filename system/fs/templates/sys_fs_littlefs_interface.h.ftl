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


#ifndef _SYS_FS_LFS_INTERFACE_H
#define _SYS_FS_LFS_INTERFACE_H

#include "system/fs/littlefs/lfs.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdarg.h>
    
#define FILE_NAME_LEN   255
    
    /* File status structure (FILINFO) */
typedef struct {
    unsigned long	fsize;			/* File size */
    unsigned short	fdate;			/* Last modified date */
    unsigned short	ftime;			/* Last modified time */
    unsigned char	fattrib;		/* Attribute */
    /* Short file name (8.3 format) */
    char        fname[13];
<#if SYS_FS_LFN_ENABLE == true>
    /* Pointer to the LFN buffer */
    char       *lfname;
    /* Size of LFN buffer in TCHAR */
    uint32_t    lfsize;
</#if>
} LITTLEFS_STATUS;

typedef enum lfs_error LITTLEFS_ERR;

int LITTLEFS_mount (uint8_t vol);

int LITTLEFS_unmount (uint8_t vol);

int LITTLEFS_open (uintptr_t handle, const char* path, uint8_t mode);

int LITTLEFS_read (uintptr_t handle, void* buff, uint32_t btr, uint32_t* br);

int LITTLEFS_close (uintptr_t handle);

int LITTLEFS_lseek (uintptr_t handle, uint32_t ofs);

int LITTLEFS_stat (const char* path, uintptr_t ptr);

int LITTLEFS_getlabel (const char* path, char* label, uint32_t* vsn);

int LITTLEFS_getcwd (char* buff, uint32_t len);

char* LITTLEFS_gets (char* buff, int len, uintptr_t handle);

int LITTLEFS_opendir (uintptr_t handle, const char* path);

int LITTLEFS_readdir (uintptr_t handle, uintptr_t fno);

int LITTLEFS_closedir (uintptr_t handle);

int LITTLEFS_chdir (const char* path);

int LITTLEFS_chdrive (uint8_t drv);

int LITTLEFS_write (uintptr_t handle, const void* buff, uint32_t btw, uint32_t* bw);

//int LITTLEFS_getfree (const char* path, uint32_t* nclst, FATFS** fatfs);

uint32_t LITTLEFS_tell(uintptr_t handle);

bool LITTLEFS_eof(uintptr_t handle);

uint32_t LITTLEFS_size(uintptr_t handle);

int LITTLEFS_mkdir (const char* path);

int LITTLEFS_remove (const char* path);

int LITTLEFS_setlabel (const char* label);

int LITTLEFS_truncate (uintptr_t handle);

int LITTLEFS_chmod (const char* path, uint8_t attr, uint8_t mask);

int LITTLEFS_utime (const char* path, const uintptr_t fno);

int LITTLEFS_rename (const char* path_old, const char* path_new);

int LITTLEFS_sync (uintptr_t handle);

int LITTLEFS_putc (char c, uintptr_t handle);

int LITTLEFS_puts (const char* str, uintptr_t handle);

int LITTLEFS_printf (uintptr_t handle, const char* str, va_list argList);

bool LITTLEFS_error(uintptr_t handle);

int LITTLEFS_mkfs (uint8_t vol, void* opt, void* work, uint32_t len);

//int LITTLEFS_expand (FIL* fp, uint32_t fsz, uint8_t opt);

int LITTLEFS_fdisk (uint8_t pdrv, const uint32_t szt[], void* work);

int LITTLEFS_getclusters (const char *path, uint32_t *tot_sec, uint32_t *free_sec);


#ifdef __cplusplus
}
#endif

#endif /* FF_DEFINED */
