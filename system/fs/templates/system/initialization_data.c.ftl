<#--
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
-->
// <editor-fold defaultstate="collapsed" desc="File System Initialization Data">

<#if SYS_FS_AUTO_MOUNT == true>
    <#lt>const SYS_FS_MEDIA_MOUNT_DATA sysfsMountTable[SYS_FS_VOLUME_NUMBER] =
    <#lt>{
            <#list 0..4 as i>
                <#assign FS_ENABLE = "SYS_FS_IDX" + i>
                    <#if .vars[FS_ENABLE]?has_content>
                        <#if (.vars[FS_ENABLE] != false)>
                            <#list 1..5 as j>
                                <#assign VOL_ENABLE = "SYS_FS_VOL_" + j + "_IDX" + i>
                                <#if .vars[VOL_ENABLE]?has_content>
                                    <#if (.vars[VOL_ENABLE] != false)>
                                        <#lt>    {
                                        <#lt>        .mountName = SYS_FS_MEDIA_IDX${i}_MOUNT_NAME_VOLUME_IDX${j-1},
                                        <#lt>        .devName   = SYS_FS_MEDIA_IDX${i}_DEVICE_NAME_VOLUME_IDX${j-1},
                                        <#lt>        .mediaType = SYS_FS_MEDIA_TYPE_IDX${i},
                                        <#lt>        .fsType   = SYS_FS_TYPE_IDX${i}
                                        <#lt>    },
                                    </#if>
                                </#if>
                            </#list>
                        </#if>
                    </#if>
            </#list>
    <#lt>};
</#if>

<#if SYS_FS_AUTO_MOUNT != true>
    <#lt>const SYS_FS_MEDIA_MOUNT_DATA sysfsMountTable[SYS_FS_VOLUME_NUMBER] =
    <#lt>{
    <#lt>    {NULL}
    <#lt>};
</#if>

<#if SYS_FS_FAT == true>
    <#lt>const SYS_FS_FUNCTIONS FatFsFunctions =
    <#lt>{
    <#lt>    .mount             = FATFS_mount,
    <#lt>    .unmount           = FATFS_unmount,
    <#lt>    .open              = FATFS_open,
    <#lt>    .read_t              = FATFS_read,
    <#lt>    .close             = FATFS_close,
    <#lt>    .seek              = FATFS_lseek,
    <#lt>    .fstat             = FATFS_stat,
    <#lt>    .getlabel          = FATFS_getlabel,
    <#lt>    .currWD            = FATFS_getcwd,
    <#lt>    .getstrn           = FATFS_gets,
    <#lt>    .openDir           = FATFS_opendir,
    <#lt>    .readDir           = FATFS_readdir,
    <#lt>    .closeDir          = FATFS_closedir,
    <#lt>    .chdir             = FATFS_chdir,
    <#lt>    .chdrive           = FATFS_chdrive,
    <#if SYS_FS_FAT_READONLY == false>
        <#lt>    .write_t             = FATFS_write,
        <#lt>    .tell              = FATFS_tell,
        <#lt>    .eof               = FATFS_eof,
        <#lt>    .size              = FATFS_size,
        <#lt>    .mkdir             = FATFS_mkdir,
        <#lt>    .remove_t            = FATFS_unlink,
        <#lt>    .setlabel          = FATFS_setlabel,
        <#lt>    .truncate          = FATFS_truncate,
        <#lt>    .chmode            = FATFS_chmod,
        <#lt>    .chtime            = FATFS_utime,
        <#lt>    .rename_t            = FATFS_rename,
        <#lt>    .sync              = FATFS_sync,
        <#lt>    .putchr            = FATFS_putc,
        <#lt>    .putstrn           = FATFS_puts,
        <#lt>    .formattedprint    = FATFS_printf,
        <#lt>    .testerror         = FATFS_error,
        <#lt>    .formatDisk        = (FORMAT_DISK)FATFS_mkfs,
        <#lt>    .partitionDisk     = FATFS_fdisk,
        <#lt>    .getCluster        = FATFS_getclusters
    <#else>
        <#lt>    .write_t             = NULL,
        <#lt>    .tell              = NULL,
        <#lt>    .eof               = NULL,
        <#lt>    .size              = NULL,
        <#lt>    .mkdir             = NULL,
        <#lt>    .remove_t            = NULL,
        <#lt>    .setlabel          = NULL,
        <#lt>    .truncate          = NULL,
        <#lt>    .chmode            = NULL,
        <#lt>    .chtime            = NULL,
        <#lt>    .rename_t            = NULL,
        <#lt>    .sync              = NULL,
        <#lt>    .putchr            = NULL,
        <#lt>    .putstrn           = NULL,
        <#lt>    .formattedprint    = NULL,
        <#lt>    .testerror         = NULL,
        <#lt>    .formatDisk        = NULL,
        <#lt>    .partitionDisk     = NULL,
        <#lt>    .getCluster        = NULL
    </#if>
    <#lt>};
</#if>

<#if SYS_FS_MPFS == true>
    <#lt>const SYS_FS_FUNCTIONS MPFSFunctions =
    <#lt>{
    <#lt>    .mount             = MPFS_Mount,
    <#lt>    .unmount           = MPFS_Unmount,
    <#lt>    .open              = MPFS_Open,
    <#lt>    .read_t            = MPFS_Read,
    <#lt>    .close             = MPFS_Close,
    <#lt>    .seek              = MPFS_Seek,
    <#lt>    .fstat             = MPFS_Stat,
    <#lt>    .tell              = MPFS_GetPosition,
    <#lt>    .eof               = MPFS_EOF,
    <#lt>    .size              = MPFS_GetSize,
    <#lt>    .openDir           = MPFS_DirOpen,
    <#lt>    .readDir           = MPFS_DirRead,
    <#lt>    .closeDir          = MPFS_DirClose,
    <#lt>    .getlabel          = NULL,
    <#lt>    .currWD            = NULL,
    <#lt>    .getstrn           = NULL,
    <#lt>    .write_t           = NULL,
    <#lt>    .mkdir             = NULL,
    <#lt>    .chdir             = NULL,
    <#lt>    .remove_t          = NULL,
    <#lt>    .setlabel          = NULL,
    <#lt>    .truncate          = NULL,
    <#lt>    .chdrive           = NULL,
    <#lt>    .chmode            = NULL,
    <#lt>    .chtime            = NULL,
    <#lt>    .rename_t           = NULL,
    <#lt>    .sync              = NULL,
    <#lt>    .putchr            = NULL,
    <#lt>    .putstrn           = NULL,
    <#lt>    .formattedprint    = NULL,
    <#lt>    .testerror         = NULL,
    <#lt>    .formatDisk        = NULL,
    <#lt>    .partitionDisk     = NULL,
    <#lt>    .getCluster        = NULL
    <#lt>};
</#if>

<#if SYS_FS_LFS == true>
    <#lt>const SYS_FS_FUNCTIONS LittleFSFunctions =
    <#lt>{
    <#lt>    .mount             = LITTLEFS_mount,
    <#lt>    .unmount           = LITTLEFS_unmount,
    <#lt>    .open              = LITTLEFS_open,
    <#lt>    .read_t              = LITTLEFS_read,
    <#lt>    .close             = LITTLEFS_close,
    <#lt>    .seek              = LITTLEFS_lseek,
    <#lt>    .fstat             = LITTLEFS_stat,
    <#lt>    .getlabel          = NULL,
    <#lt>    .currWD            = NULL,
    <#lt>    .getstrn           = NULL,
    <#lt>    .openDir           = LITTLEFS_opendir,
    <#lt>    .readDir           = LITTLEFS_readdir,
    <#lt>    .closeDir          = LITTLEFS_closedir,
    <#lt>    .chdir             = NULL,
    <#lt>    .chdrive           = NULL,
    <#lt>    .tell              = LITTLEFS_tell,
    <#lt>    .eof               = LITTLEFS_eof,
    <#lt>    .size              = LITTLEFS_size,
    <#if SYS_FS_LFS_READONLY == false>
        <#lt>    .write_t             = LITTLEFS_write,
        <#lt>    .mkdir             = LITTLEFS_mkdir,
        <#lt>    .remove_t            = LITTLEFS_remove,
        <#lt>    .rename_t            = LITTLEFS_rename,
        <#lt>    .truncate          = LITTLEFS_truncate,
        <#lt>    .formatDisk        = (FORMAT_DISK)LITTLEFS_mkfs,
        <#lt>    .sync              = LITTLEFS_sync,
    <#else>
        <#lt>    .write_t             = NULL,
        <#lt>    .mkdir             = NULL,
        <#lt>    .remove_t            = NULL,
        <#lt>    .rename_t            = NULL,
        <#lt>    .truncate          = NULL,
        <#lt>    .formatDisk        = NULL,
        <#lt>    .sync              = NULL,
    </#if>
    <#lt>    .setlabel          = NULL,
    <#lt>    .chmode            = NULL,
    <#lt>    .chtime            = NULL,
    <#lt>    .putchr            = NULL,
    <#lt>    .putstrn           = NULL,
    <#lt>    .formattedprint    = NULL,
    <#lt>    .testerror         = NULL,
    <#lt>    .partitionDisk     = NULL,
    <#lt>    .getCluster        = NULL
    <#lt>};
</#if>

<#if SYS_FS_FILEX == true>
    <#lt>const SYS_FS_FUNCTIONS FileXFunctions =
    <#lt>{
    <#lt>    .mount             = FILEX_mount,
    <#lt>    .unmount           = FILEX_unmount,
    <#lt>    .open              = FILEX_open,
    <#lt>    .read_t              = FILEX_read,
    <#lt>    .close             = FILEX_close,
    <#lt>    .seek              = FILEX_lseek,
    <#lt>    .fstat             = FILEX_stat,
    <#lt>    .getlabel          = FILEX_getlabel,
    <#lt>    .currWD            = FILEX_getcwd,
    <#lt>    .getstrn           = NULL,
    <#lt>    .openDir           = FILEX_opendir,
    <#lt>    .readDir           = FILEX_readdir,
    <#lt>    .closeDir          = FILEX_closedir,
    <#lt>    .chdir             = FILEX_chdir,
    <#lt>    .chdrive           = FILEX_chdrive,
    <#if SYS_FS_FILEX_READONLY == false>
        <#lt>    .write_t           = FILEX_write,
        <#lt>    .tell              = FILEX_tell,
        <#lt>    .eof               = FILEX_eof,
        <#lt>    .size              = FILEX_size,
        <#lt>    .mkdir             = FILEX_mkdir,
        <#lt>    .remove_t          = FILEX_unlink,
        <#lt>    .setlabel          = FILEX_setlabel,
        <#lt>    .truncate          = FILEX_truncate,
        <#lt>    .chmode            = FILEX_chmod,
        <#lt>    .chtime            = FILEX_utime,
        <#lt>    .rename_t          = FILEX_rename,
        <#lt>    .sync              = FILEX_sync,
        <#lt>    .putchr            = NULL,
        <#lt>    .putstrn           = NULL,
        <#lt>    .formattedprint    = NULL,
        <#lt>    .testerror         = NULL,
        <#lt>    .formatDisk        = (FORMAT_DISK)FILEX_mkfs,
        <#lt>    .partitionDisk     = NULL,
        <#lt>    .getCluster        = FILEX_getclusters
    <#else>
        <#lt>    .write_t           = NULL,
        <#lt>    .tell              = NULL,
        <#lt>    .eof               = NULL,
        <#lt>    .size              = NULL,
        <#lt>    .mkdir             = NULL,
        <#lt>    .remove_t          = NULL,
        <#lt>    .setlabel          = NULL,
        <#lt>    .truncate          = NULL,
        <#lt>    .chmode            = NULL,
        <#lt>    .chtime            = NULL,
        <#lt>    .rename_t          = NULL,
        <#lt>    .sync              = NULL,
        <#lt>    .putchr            = NULL,
        <#lt>    .putstrn           = NULL,
        <#lt>    .formattedprint    = NULL,
        <#lt>    .testerror         = NULL,
        <#lt>    .formatDisk        = NULL,
        <#lt>    .partitionDisk     = NULL,
        <#lt>    .getCluster        = NULL
    </#if>
    <#lt>};
</#if>

<#if SYS_FS_FAT == true && SYS_FS_MPFS == true && SYS_FS_LFS == true && SYS_FS_FILEX == true>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = FAT,
    <#lt>        .nativeFileSystemFunctions = &FatFsFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = MPFS2,
    <#lt>        .nativeFileSystemFunctions = &MPFSFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = LITTLEFS,
    <#lt>        .nativeFileSystemFunctions = &LittleFSFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = FILEX,
    <#lt>        .nativeFileSystemFunctions = &FileXFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == true && SYS_FS_MPFS == true && SYS_FS_LFS == true && SYS_FS_FILEX == false>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = FAT,
    <#lt>        .nativeFileSystemFunctions = &FatFsFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = MPFS2,
    <#lt>        .nativeFileSystemFunctions = &MPFSFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = LITTLEFS,
    <#lt>        .nativeFileSystemFunctions = &LittleFSFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == true && SYS_FS_MPFS == true && SYS_FS_LFS == false && SYS_FS_FILEX == true>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = FAT,
    <#lt>        .nativeFileSystemFunctions = &FatFsFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = MPFS2,
    <#lt>        .nativeFileSystemFunctions = &MPFSFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = FILEX,
    <#lt>        .nativeFileSystemFunctions = &FileXFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == true && SYS_FS_MPFS == true && SYS_FS_LFS == false && SYS_FS_FILEX == false>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = FAT,
    <#lt>        .nativeFileSystemFunctions = &FatFsFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = MPFS2,
    <#lt>        .nativeFileSystemFunctions = &MPFSFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == true && SYS_FS_MPFS == false && SYS_FS_LFS == true && SYS_FS_FILEX == true>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = FAT,
    <#lt>        .nativeFileSystemFunctions = &FatFsFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = LITTLEFS,
    <#lt>        .nativeFileSystemFunctions = &LittleFSFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = FILEX,
    <#lt>        .nativeFileSystemFunctions = &FileXFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == true && SYS_FS_MPFS == false && SYS_FS_LFS == true && SYS_FS_FILEX == false>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = FAT,
    <#lt>        .nativeFileSystemFunctions = &FatFsFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = LITTLEFS,
    <#lt>        .nativeFileSystemFunctions = &LittleFSFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == true && SYS_FS_MPFS == false && SYS_FS_LFS == false && SYS_FS_FILEX == true>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = FAT,
    <#lt>        .nativeFileSystemFunctions = &FatFsFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = FILEX,
    <#lt>        .nativeFileSystemFunctions = &FileXFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == true && SYS_FS_MPFS == false && SYS_FS_LFS == false && SYS_FS_FILEX == false>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = FAT,
    <#lt>        .nativeFileSystemFunctions = &FatFsFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == false && SYS_FS_MPFS == true && SYS_FS_LFS == true && SYS_FS_FILEX == true>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = MPFS2,
    <#lt>        .nativeFileSystemFunctions = &MPFSFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = LITTLEFS,
    <#lt>        .nativeFileSystemFunctions = &LittleFSFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = FILEX,
    <#lt>        .nativeFileSystemFunctions = &FileXFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == false && SYS_FS_MPFS == true && SYS_FS_LFS == true && SYS_FS_FILEX == false>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = MPFS2,
    <#lt>        .nativeFileSystemFunctions = &MPFSFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = LITTLEFS,
    <#lt>        .nativeFileSystemFunctions = &LittleFSFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == false && SYS_FS_MPFS == true && SYS_FS_LFS == false && SYS_FS_FILEX == true>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = MPFS2,
    <#lt>        .nativeFileSystemFunctions = &MPFSFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = FILEX,
    <#lt>        .nativeFileSystemFunctions = &FileXFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == false && SYS_FS_MPFS == true && SYS_FS_LFS == false && SYS_FS_FILEX == false>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = MPFS2,
    <#lt>        .nativeFileSystemFunctions = &MPFSFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == false && SYS_FS_MPFS == false && SYS_FS_LFS == true && SYS_FS_FILEX == true>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = LITTLEFS,
    <#lt>        .nativeFileSystemFunctions = &LittleFSFunctions
    <#lt>    },
    <#lt>    {
    <#lt>        .nativeFileSystemType = FILEX,
    <#lt>        .nativeFileSystemFunctions = &FileXFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == false && SYS_FS_MPFS == false && SYS_FS_LFS == true && SYS_FS_FILEX == false>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = LITTLEFS,
    <#lt>        .nativeFileSystemFunctions = &LittleFSFunctions
    <#lt>    }
    <#lt>};
<#elseif SYS_FS_FAT == false && SYS_FS_MPFS == false && SYS_FS_LFS == false && SYS_FS_FILEX == true>
    <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
    <#lt>{
    <#lt>    {
    <#lt>        .nativeFileSystemType = FILEX,
    <#lt>        .nativeFileSystemFunctions = &FileXFunctions
    <#lt>    }
    <#lt>};
</#if>


// </editor-fold>
<#--
/*******************************************************************************
 End of File
*/
-->
