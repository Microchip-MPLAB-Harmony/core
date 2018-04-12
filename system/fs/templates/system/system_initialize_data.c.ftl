<#--
/*******************************************************************************
Copyright (c) 2017 released Microchip Technology Inc.  All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED AS IS WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR
CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF
SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *******************************************************************************/
-->
/*** File System Initialization Data ***/
<#if USE_SYS_FS == true> 

<#if SYS_FS_AUTO_MOUNT == true>    
const SYS_FS_MEDIA_MOUNT_DATA sysfsMountTable[SYS_FS_VOLUME_NUMBER] = 
{
	<#list 0..4 as i>
		<#assign FS_ENABLE = "SYS_FS_IDX" + i>
			<#if .vars[FS_ENABLE]?has_content>
				<#if (.vars[FS_ENABLE] != false)>
					<#list 1..5 as j>
						<#assign VOL_ENABLE = "SYS_FS_VOL_" + j + "_IDX" + i>
						<#if .vars[VOL_ENABLE]?has_content>	
							<#if (.vars[VOL_ENABLE] != false)>
								<#lt>	{
								<#lt>		.mountName = SYS_FS_MEDIA_IDX${i}_MOUNT_NAME_VOLUME_IDX${j-1},
								<#lt>		.devName   = SYS_FS_MEDIA_IDX${i}_DEVICE_NAME_VOLUME_IDX${j-1}, 
								<#lt>		.mediaType = SYS_FS_MEDIA_TYPE_IDX${i},
								<#lt>		.fsType   = SYS_FS_TYPE_IDX${i}   
								<#lt>	},
							</#if>
						</#if>
					</#list>
				</#if>
			</#if>			
	</#list>									
};
</#if>

<#if SYS_FS_AUTO_MOUNT != true>
const SYS_FS_MEDIA_MOUNT_DATA sysfsMountTable[SYS_FS_VOLUME_NUMBER] = 
{
	{NULL}
};
</#if>


<#if SYS_FS_FAT == true> 
<#if SYS_FS_MPFS == true> 
const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
{
    {
        .nativeFileSystemType = FAT,
        .nativeFileSystemFunctions = &FatFsFunctions
    },
    {
        .nativeFileSystemType = MPFS2,
        .nativeFileSystemFunctions = &MPFSFunctions
    }

};

</#if>
</#if>
</#if>

<#if USE_SYS_FS == true> 
<#if SYS_FS_MPFS == true> 
<#if SYS_FS_FAT == false> 
const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
{
    {
        .nativeFileSystemType = MPFS2,
        .nativeFileSystemFunctions = &MPFSFunctions
    }
};
</#if>
</#if>
</#if>

<#if USE_SYS_FS == true> 
<#if SYS_FS_FAT == true> 
<#if SYS_FS_MPFS == false> 
const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
{
    {
        .nativeFileSystemType = FAT,
        .nativeFileSystemFunctions = &FatFsFunctions
    }
};
</#if>
</#if>
</#if>

<#--
/*******************************************************************************
 End of File
*/
-->
