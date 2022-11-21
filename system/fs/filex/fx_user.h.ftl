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


/**************************************************************************/
/**************************************************************************/
/**                                                                       */
/** FileX Component                                                       */
/**                                                                       */
/**   User Specific                                                       */
/**                                                                       */
/**************************************************************************/
/**************************************************************************/


/**************************************************************************/
/*                                                                        */
/*  PORT SPECIFIC C INFORMATION                            RELEASE        */
/*                                                                        */
/*    fx_user.h                                           PORTABLE C      */
/*                                                           6.1.10       */
/*                                                                        */
/*  AUTHOR                                                                */
/*                                                                        */
/*    William E. Lamie, Microsoft Corporation                             */
/*                                                                        */
/*  DESCRIPTION                                                           */
/*                                                                        */
/*    This file contains user defines for configuring FileX in specific   */
/*    ways. This file will have an effect only if the application and     */
/*    FileX library are built with FX_INCLUDE_USER_DEFINE_FILE defined.   */
/*    Note that all the defines in this file may also be made on the      */
/*    command line when building FileX library and application objects.   */
/*                                                                        */
/*  RELEASE HISTORY                                                       */
/*                                                                        */
/*    DATE              NAME                      DESCRIPTION             */
/*                                                                        */
/*  05-19-2020     William E. Lamie         Initial Version 6.0           */
/*  09-30-2020     William E. Lamie         Modified comment(s), and      */
/*                                            added product constants     */
/*                                            to enable code              */
/*                                            size optimization,          */
/*                                            resulting in version 6.1    */
/*  03-02-2021     William E. Lamie         Modified comment(s), and      */
/*                                            added standalone support,   */
/*                                            resulting in version 6.1.5  */
/*  01-31-2022     Bhupendra Naphade        Modified comment(s), and      */
/*                                            added product constant to   */
/*                                            support variable sector     */
/*                                            size in exFAT,              */
/*                                            resulting in version 6.1.10 */
/*                                                                        */
/**************************************************************************/

#ifndef FX_USER_H
#define FX_USER_H


/* Define various build options for the FileX port.  The application should either make changes
   here by commenting or un-commenting the conditional compilation defined OR supply the defines
   though the compiler's equivalent of the -D option.  */


/* Override various options with default values already assigned in fx_api.h or fx_port.h. Please
   also refer to fx_port.h for descriptions on each of these options.  */


/* Defines the maximum size of long file names supported by FileX. */

#define FX_MAX_LONG_NAME_LEN            ${SYS_FS_FILEX_FX_MAX_LONG_NAME_LEN}
#define FX_MAX_LAST_NAME_LEN            ${SYS_FS_FILEX_FX_MAX_LONG_NAME_LEN}     /* Must be as large or larger than FX_MAX_LONG_NAME_LEN */


/* Defines the maximum number of logical sectors that can be cached by FileX. The cache memory
   supplied to FileX at fx_media_open determines how many sectors can actually be cached.  */

#define FX_MAX_SECTOR_CACHE             ${SYS_FS_FILEX_FX_MAX_SECTOR_CACHE}      /* Minimum value is 2, all other values must be power of 2.  */


/* Defines the size in bytes of the bit map used to update the secondary FAT sectors. The larger the value the
   less unnecessary secondary FAT sector writes.   */

#define FX_FAT_MAP_SIZE                 ${SYS_FS_FILEX_FX_FAT_MAP_SIZE}          /* Minimum value is 1, no maximum value.  */


/* Defines the number of entries in the FAT cache.  */

#define FX_MAX_FAT_CACHE                ${SYS_FS_FILEX_FX_MAX_FAT_CACHE}         /* Minimum value is 8, all values must be a power of 2.  */


/* Defines the number of seconds the time parameters are updated in FileX.  */

#define FX_UPDATE_RATE_IN_SECONDS       ${SYS_FS_FILEX_FX_UPDATE_RATE_IN_SECONDS}


/* Defines the number of ThreadX timer ticks required to achieve the update rate specified by
   FX_UPDATE_RATE_IN_SECONDS defined previously */

#define FX_UPDATE_RATE_IN_TICKS         ${SYS_FS_FILEX_FX_UPDATE_RATE_IN_TICKS}


/* Defined, FileX is built without update to the time parameters.  */

<#if SYS_FS_FILEX_FX_NO_TIMER>
#define FX_NO_TIMER
<#else>
/*#define FX_NO_TIMER  */
</#if>

/* Defined, FileX does not update already opened files.  */

<#if SYS_FS_FILEX_FX_DONT_UPDATE_OPEN_FILES>
#define FX_DONT_UPDATE_OPEN_FILES
<#else>
/*#define FX_DONT_UPDATE_OPEN_FILES   */
</#if>

/* Defined, the file search cache optimization is disabled.  */

<#if SYS_FS_FILEX_FX_MEDIA_DISABLE_SEARCH_CACHE>
#define FX_MEDIA_DISABLE_SEARCH_CACHE
<#else>
/*#define FX_MEDIA_DISABLE_SEARCH_CACHE  */
</#if>

/* Defined, the direct read sector update of cache is disabled.  */

<#if SYS_FS_FILEX_DISABLE_DIRECT_DATA_READ_CACHE>
#define FX_DISABLE_DIRECT_DATA_READ_CACHE_FILL
<#else>
/*#define FX_DISABLE_DIRECT_DATA_READ_CACHE_FILL  */
</#if>


/* Defined, gathering of media statistics is disabled.  */

<#if SYS_FS_FILEX_FX_MEDIA_STATISTICS_DISABLE>
#define FX_MEDIA_STATISTICS_DISABLE
<#else>
/*#define FX_MEDIA_STATISTICS_DISABLE  */
</#if>


/* Defined, legacy single open logic for the same file is enabled.  */

<#if SYS_FS_FILEX_FX_SINGLE_OPEN_LEGACY>
#define FX_SINGLE_OPEN_LEGACY
<#else>
/*#define FX_SINGLE_OPEN_LEGACY  */
</#if>


/* Defined, renaming inherits path information.  */

<#if SYS_FS_FILEX_FX_RENAME_PATH_INHERIT>
#define FX_RENAME_PATH_INHERIT
<#else>
/*#define FX_RENAME_PATH_INHERIT  */
</#if>


/* Defined, local path logic is disabled.  */

<#if SYS_FS_FILEX_FX_NO_LOCAL_PATH>
#define FX_NO_LOCAL_PATH
<#else>
/*#define FX_NO_LOCAL_PATH  */
</#if>


/* Defined, FileX is able to access exFAT file system.

   FileX supports the Microsoft exFAT file system format.
   Your use of exFAT technology in your products requires a separate
   license from Microsoft. Please see the following link for further
   details on exFAT licensing:

   https://www.microsoft.com/en-us/legal/intellectualproperty/mtl/exfat-licensing.aspx
*/

<#if SYS_FS_FILEX_FX_ENABLE_EXFAT>
#define FX_ENABLE_EXFAT
<#else>
/*#define FX_ENABLE_EXFAT  */
</#if>


/* Define bitmap cache size for exFAT. Size should be minimum one sector size and maximum 4096.
   For applications using muliple media devices with varing sector size, the value should be set to the
   size of largest sector size */

#define FX_EXFAT_MAX_CACHE_SIZE      ${SYS_FS_FILEX_FX_EXFAT_MAX_CACHE_SIZE}


/* Define FileX internal protection macros.  If FX_SINGLE_THREAD is defined,
   these protection macros are effectively disabled.  However, for multi-thread
   uses, the macros are setup to utilize a ThreadX mutex for multiple thread
   access control into an open media.  */

<#if SYS_FS_FILEX_FX_SINGLE_THREAD>
#define FX_SINGLE_THREAD
<#else>
/*#define FX_SINGLE_THREAD  */
</#if>


/* Defined, Filex will be used in standalone mode (without ThreadX) */

<#if SYS_FS_FILEX_FX_STANDALONE_ENABLE>
#define FX_STANDALONE_ENABLE
<#else>
/*#define FX_STANDALONE_ENABLE  */
</#if>


/* Defined, data sector write requests are flushed immediately to the driver.  */

<#if SYS_FS_FILEX_FX_FAULT_TOLERANT_DATA>
#define FX_FAULT_TOLERANT_DATA
<#else>
/*#define FX_FAULT_TOLERANT_DATA  */
</#if>


/* Defined, system sector write requests (including FAT and directory entry requests)
   are flushed immediately to the driver.  */

<#if SYS_FS_FILEX_FX_FAULT_TOLERANT>
#define FX_FAULT_TOLERANT
<#else>
/*#define FX_FAULT_TOLERANT  */
</#if>


/* Defined, enables 64-bits sector addresses used in I/O driver.  */

<#if SYS_FS_FILEX_FX_DRIVER_USE_64BIT_LBA>
#define FX_DRIVER_USE_64BIT_LBA
<#else>
/*#define FX_DRIVER_USE_64BIT_LBA  */
</#if>


/* Defined, enables FileX fault tolerant service.  */

<#if SYS_FS_FILEX_FX_ENABLE_FAULT_TOLERANT>
#define FX_ENABLE_FAULT_TOLERANT
<#else>
/*#define FX_ENABLE_FAULT_TOLERANT  */
</#if>


/* Define byte offset in boot sector where the cluster number of the Fault Tolerant Log file is.
   Note that this field (byte 116 to 119) is marked as reserved by FAT 12/16/32/exFAT specification. */

#define FX_FAULT_TOLERANT_BOOT_INDEX      ${SYS_FS_FILEX_FAULT_TOLERANT_BOOT_INDEX}

/* Below FX_DISABLE_XXX macros can be used for code size optimization required for memory
   critical aplications */

/* Defined, error checking is disabled.  */

<#if SYS_FS_FILEX_FX_DISABLE_ERROR_CHECKING>
#define FX_DISABLE_ERROR_CHECKING
<#else>
/*#define FX_DISABLE_ERROR_CHECKING  */
</#if>


/* Defined, cache is disabled.  */

<#if SYS_FS_FILEX_FX_DISABLE_CACHE>
#define FX_DISABLE_CACHE
<#else>
/*#define FX_DISABLE_CACHE  */
</#if>


/* Defined, file close is disabled.  */

<#if SYS_FS_FILEX_FX_DISABLE_FILE_CLOSE>
#define FX_DISABLE_FILE_CLOSE
<#else>
/*#define FX_DISABLE_FILE_CLOSE  */
</#if>


/* Defined, fast open is disabled.  */

<#if SYS_FS_FILEX_FX_DISABLE_FAST_OPEN>
#define FX_DISABLE_FAST_OPEN
<#else>
/*#define FX_DISABLE_FAST_OPEN  */
</#if>


/* Defined, force memory operations are disabled.  */

<#if SYS_FS_FILEX_FX_DISABLE_FORCE_MEMORY_OPERATION>
#define FX_DISABLE_FORCE_MEMORY_OPERATION
<#else>
/*#define FX_DISABLE_FORCE_MEMORY_OPERATION  */
</#if>


/* Defined, build options is disabled.  */

<#if SYS_FS_FILEX_FX_DISABLE_BUILD_OPTIONS>
#define FX_DISABLE_BUILD_OPTIONS
<#else>
/*#define FX_DISABLE_BUILD_OPTIONS  */
</#if>


/* Defined, one line function is disabled.  */

<#if SYS_FS_FILEX_FX_DISABLE_ONE_LINE_FUNCTION>
#define FX_DISABLE_ONE_LINE_FUNCTION
<#else>
/*#define FX_DISABLE_ONE_LINE_FUNCTION  */
</#if>


/* Defined, FAT entry refresh is disabled.  */

<#if SYS_FS_FILEX_FX_DIABLE_FAT_ENTRY_REFRESH>
#define FX_DIABLE_FAT_ENTRY_REFRESH
<#else>
/*#define FX_DIABLE_FAT_ENTRY_REFRESH  */
</#if>


/* Defined, consecutive detect is disabled.  */

<#if SYS_FS_FILEX_FX_DISABLE_CONSECUTIVE_DETECT>
#define FX_DISABLE_CONSECUTIVE_DETECT
<#else>
/*#define FX_DISABLE_CONSECUTIVE_DETECT  */
</#if>


#endif

