#include "system/fs/sys_fs.h"
#include "system/fs/sys_fs_media_manager.h"
<#if SYS_FS_FAT == true>
    <#lt>#include "system/fs/sys_fs_fat_interface.h"
    <#lt>#include "system/fs/fat_fs/file_system/ff.h"
    <#lt>#include "system/fs/fat_fs/file_system/ffconf.h"
    <#lt>#include "system/fs/fat_fs/hardware_access/diskio.h"
</#if>
<#if SYS_FS_MPFS == true>
    <#lt>#include "system/fs/mpfs/mpfs.h"
</#if>
<#if SYS_FS_LFS == true>
    <#lt>#include "system/fs/sys_fs_littlefs_interface.h"
</#if>
<#if SYS_FS_FILEX == true>
    <#lt>#include "system/fs/sys_fs_filex_interface.h"
</#if>