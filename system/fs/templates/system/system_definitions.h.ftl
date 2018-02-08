<#if USE_SYS_FS == true>
	<#lt>#include "system/fs/sys_fs.h"
	<#lt>#include "system/fs/sys_fs_media_manager.h"
	<#if SYS_FS_FAT == true>
		<#lt>#include "system/fs/fat_fs/src/file_system/ff.h"
		<#lt>#include "system/fs/fat_fs/src/file_system/ffconf.h"
		<#lt>#include "system/fs/fat_fs/src/hardware_access/diskio.h"
	</#if>
	<#if SYS_FS_MPFS == true>
		<#lt>#include "system/fs/mpfs/mpfs.h"
	</#if>
</#if>