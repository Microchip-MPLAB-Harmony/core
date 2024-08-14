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


#ifndef SYS_FS_FAT_INTERFACE_H
#define SYS_FS_FAT_INTERFACE_H

#include "system/fs/fat_fs/file_system/ff.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdarg.h>

int FATFS_mount (uint8_t vol);

int FATFS_unmount (uint8_t vol);

int FATFS_open (uintptr_t handle, const char* path, uint8_t mode);

int FATFS_read (uintptr_t handle, void* buff, uint32_t btr, uint32_t* br);

int FATFS_close (uintptr_t handle);

int FATFS_lseek (uintptr_t handle, FSIZE_t ofs);

int FATFS_stat (const char* path, uintptr_t fileInfo);

int FATFS_getlabel (const char* path, char* label, uint32_t* vsn);

int FATFS_getcwd (char* buff, uint32_t len);

char* FATFS_gets (char* buff, int len, uintptr_t handle);

int FATFS_opendir (uintptr_t handle, const char* path);

int FATFS_readdir (uintptr_t handle, uintptr_t fileInfo);

int FATFS_closedir (uintptr_t handle);

int FATFS_chdir (const char* path);

int FATFS_chdrive (uint8_t drv);

<#if SYS_FS_FAT_READONLY == false>
    <#lt>int FATFS_write (uintptr_t handle, const void* buff, uint32_t btw, uint32_t* bw);

    <#lt>int FATFS_getfree (const char* path, uint32_t* nclst, FATFS** fatfs);

    <#lt>FSIZE_t FATFS_tell(uintptr_t handle);

    <#lt>bool FATFS_eof(uintptr_t handle);

    <#lt>FSIZE_t FATFS_size(uintptr_t handle);

    <#lt>int FATFS_mkdir (const char* path);

    <#lt>int FATFS_unlink (const char* path);

    <#lt>int FATFS_setlabel (const char* label);

    <#lt>int FATFS_truncate (uintptr_t handle);

    <#lt>int FATFS_chmod (const char* path, uint8_t attr, uint8_t mask);

    <#lt>int FATFS_utime (const char* path, const uintptr_t ptr);

    <#lt>int FATFS_rename (const char* path_old, const char* path_new);

    <#lt>int FATFS_sync (uintptr_t handle);

    <#lt>int FATFS_putc (char c, uintptr_t handle);

    <#lt>int FATFS_puts (const char* str, uintptr_t handle);

    <#lt>int FATFS_printf (uintptr_t handle, const char* fmt, va_list argList);

    <#lt>bool FATFS_error(uintptr_t handle);

    <#lt>int FATFS_mkfs (uint8_t vol, const MKFS_PARM* opt, void* work, uint32_t len);

    <#lt>int FATFS_fdisk (uint8_t pdrv, const uint32_t ptbl[], void* work);

    <#lt>int FATFS_getclusters (const char *path, uint32_t *tot_sec, uint32_t *free_sec);

</#if>

#ifdef __cplusplus
}
#endif

#endif /* FF_DEFINED */
