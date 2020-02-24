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
    <#lt>    .mount             = f_mount,
    <#lt>    .unmount           = f_unmount,
    <#lt>    .open              = f_open,
    <#lt>    .read              = f_read,
    <#lt>    .write             = f_write,
    <#lt>    .close             = f_close,
    <#lt>    .seek              = f_lseek,
    <#lt>    .tell              = f_tell,
    <#lt>    .eof               = f_eof,
    <#lt>    .size              = f_size,
    <#lt>    .fstat             = f_stat,
    <#lt>    .mkdir             = f_mkdir,
    <#lt>    .chdir             = f_chdir,
    <#lt>    .remove            = f_unlink,
    <#lt>    .getlabel          = f_getlabel,
    <#lt>    .setlabel          = f_setlabel,
    <#lt>    .truncate          = f_truncate,
    <#lt>    .currWD            = f_getcwd,
    <#lt>    .chdrive           = f_chdrive,
    <#lt>    .chmode            = f_chmod,
    <#lt>    .chtime            = f_utime,
    <#lt>    .rename            = f_rename,
    <#lt>    .sync              = f_sync,
    <#lt>    .getstrn           = f_gets,
    <#lt>    .putchr            = f_putc,
    <#lt>    .putstrn           = f_puts,
    <#lt>    .formattedprint    = f_printf,
    <#lt>    .testerror         = f_error,
    <#lt>    .formatDisk        = f_mkfs,
    <#lt>    .openDir           = f_opendir,
    <#lt>    .readDir           = f_readdir,
    <#lt>    .closeDir          = f_closedir,
    <#lt>    .partitionDisk     = f_fdisk,
    <#lt>    .getCluster        = f_getclusters
    <#lt>};
</#if>

<#if SYS_FS_MPFS == true>
    <#lt>const SYS_FS_FUNCTIONS MPFSFunctions =
    <#lt>{
    <#lt>    .mount             = MPFS_Mount,
    <#lt>    .unmount           = MPFS_Unmount,
    <#lt>    .open              = MPFS_Open,
    <#lt>    .read              = MPFS_Read,
    <#lt>    .write             = NULL,
    <#lt>    .close             = MPFS_Close,
    <#lt>    .seek              = MPFS_Seek,
    <#lt>    .tell              = MPFS_GetPosition,
    <#lt>    .eof               = MPFS_EOF,
    <#lt>    .size              = MPFS_GetSize,
    <#lt>    .fstat             = MPFS_Stat,
    <#lt>    .mkdir             = NULL,
    <#lt>    .chdir             = NULL,
    <#lt>    .remove            = NULL,
    <#lt>    .getlabel          = NULL,
    <#lt>    .setlabel          = NULL,
    <#lt>    .truncate          = NULL,
    <#lt>    .currWD            = NULL,
    <#lt>    .chdrive           = NULL,
    <#lt>    .chmode            = NULL,
    <#lt>    .chtime            = NULL,
    <#lt>    .rename            = NULL,
    <#lt>    .sync              = NULL,
    <#lt>    .getstrn           = NULL,
    <#lt>    .putchr            = NULL,
    <#lt>    .putstrn           = NULL,
    <#lt>    .formattedprint    = NULL,
    <#lt>    .testerror         = NULL,
    <#lt>    .formatDisk        = NULL,
    <#lt>    .openDir           = MPFS_DirOpen,
    <#lt>    .readDir           = MPFS_DirRead,
    <#lt>    .closeDir          = MPFS_DirClose,
    <#lt>    .partitionDisk     = NULL,
    <#lt>    .getCluster        = NULL
    <#lt>};
</#if>

<#if SYS_FS_FAT == true>
    <#if SYS_FS_MPFS == true>
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
    <#else>
        <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
        <#lt>{
        <#lt>    {
        <#lt>        .nativeFileSystemType = FAT,
        <#lt>        .nativeFileSystemFunctions = &FatFsFunctions
        <#lt>    }
        <#lt>};
    </#if>
<#else>
    <#if SYS_FS_MPFS == true>
        <#lt>const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
        <#lt>{
        <#lt>    {
        <#lt>        .nativeFileSystemType = MPFS2,
        <#lt>        .nativeFileSystemFunctions = &MPFSFunctions
        <#lt>    }
        <#lt>};
    </#if>
</#if>

// </editor-fold>
<#--
/*******************************************************************************
 End of File
*/
-->
