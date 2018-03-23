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
Copyright (c) 2017 released Microchip Technology Inc.  All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED AS IS  WITHOUT  WARRANTY  OF  ANY  KIND,
EITHER EXPRESS  OR  IMPLIED,  INCLUDING  WITHOUT  LIMITATION,  ANY  WARRANTY  OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A  PARTICULAR  PURPOSE.
IN NO EVENT SHALL MICROCHIP OR  ITS  LICENSORS  BE  LIABLE  OR  OBLIGATED  UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION,  BREACH  OF  WARRANTY,  OR
OTHER LEGAL  EQUITABLE  THEORY  ANY  DIRECT  OR  INDIRECT  DAMAGES  OR  EXPENSES
INCLUDING BUT NOT LIMITED TO ANY  INCIDENTAL,  SPECIAL,  INDIRECT,  PUNITIVE  OR
CONSEQUENTIAL DAMAGES, LOST  PROFITS  OR  LOST  DATA,  COST  OF  PROCUREMENT  OF
SUBSTITUTE  GOODS,  TECHNOLOGY,  SERVICES,  OR  ANY  CLAIMS  BY  THIRD   PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE  THEREOF),  OR  OTHER  SIMILAR  COSTS.
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