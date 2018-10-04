<#--
/*******************************************************************************
  File system Media Driver Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
    sys_fs_idx.h.ftl

  Summary:
     File system Media Driver Freemarker Template File

  Description:

*******************************************************************************/

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

<#if SYS_FS_AUTO_MOUNT == true>
	<#list 0..4 as i>
		<#assign FS_ENABLE = "SYS_FS_IDX" + i>
			<#if .vars[FS_ENABLE]?has_content>
				<#if (.vars[FS_ENABLE] != false)>
					<#lt>#define SYS_FS_MEDIA_TYPE_IDX${i} 				${.vars["SYS_FS_MEDIA_TYPE_DEFINE_IDX" + i]}
					<#lt>#define SYS_FS_TYPE_IDX${i} 					${.vars["SYS_FS_TYPE_DEFINE_IDX" + i]}
					
					<#list 1..5 as j>
						<#assign VOL_ENABLE = "SYS_FS_VOL_" + j + "_IDX" + i>
						<#if .vars[VOL_ENABLE]?has_content>
							<#if (.vars[VOL_ENABLE] != false)>
								<#lt>#define SYS_FS_MEDIA_IDX${i}_MOUNT_NAME_VOLUME_IDX${j - 1} 			"${.vars["SYS_FS_MEDIA_MOUNT_" + j + "_NAME_IDX" + i]}"
								<#lt>#define SYS_FS_MEDIA_IDX${i}_DEVICE_NAME_VOLUME_IDX${j - 1}			"${.vars["SYS_FS_MEDIA_DEVICE_" + j + "_NAME_IDX" + i]}"
								
							</#if>
						</#if>
					</#list>
				</#if>
			</#if>			
	</#list>
</#if>