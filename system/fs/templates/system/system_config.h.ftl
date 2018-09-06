<#--
/*******************************************************************************
  File System Service Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
    sys_devcon.h

  Summary:
   File System Service Freemarker Template File

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

/* File System Service Configuration */

#define SYS_FS_MEDIA_NUMBER               ${SYS_FS_INSTANCES_NUMBER}

<#if SYS_FS_AUTO_MOUNT != true>
    <#lt>#define SYS_FS_VOLUME_NUMBER              ${SYS_FS_VOLUME_NUMBER}
<#elseif SYS_FS_IDX0 == true && SYS_FS_IDX1 == true && SYS_FS_IDX2 == true && SYS_FS_IDX3 == true>
    <#lt>#define SYS_FS_VOLUME_NUMBER            (${SYS_FS_VOLUME_INSTANCES_NUMBER_IDX0} + ${SYS_FS_VOLUME_INSTANCES_NUMBER_IDX1} + ${SYS_FS_VOLUME_INSTANCES_NUMBER_IDX2} + ${SYS_FS_VOLUME_INSTANCES_NUMBER_IDX3})
<#elseif SYS_FS_IDX0 == true && SYS_FS_IDX1 == true && SYS_FS_IDX2 == true>
    <#lt>#define SYS_FS_VOLUME_NUMBER             (${SYS_FS_VOLUME_INSTANCES_NUMBER_IDX0} + ${SYS_FS_VOLUME_INSTANCES_NUMBER_IDX1} + ${SYS_FS_VOLUME_INSTANCES_NUMBER_IDX2})
<#elseif SYS_FS_IDX0 == true && SYS_FS_IDX1 == true>
    <#lt>#define SYS_FS_VOLUME_NUMBER              (${SYS_FS_VOLUME_INSTANCES_NUMBER_IDX0} + ${SYS_FS_VOLUME_INSTANCES_NUMBER_IDX1})
<#elseif SYS_FS_IDX0 == true>
    <#lt>#define SYS_FS_VOLUME_NUMBER              (${SYS_FS_VOLUME_INSTANCES_NUMBER_IDX0})
</#if>

<#if SYS_FS_AUTO_MOUNT == true>
    <#lt>#define SYS_FS_AUTOMOUNT_ENABLE           true
    <#lt>#define SYS_FS_CLIENT_NUMBER              ${SYS_FS_CLIENT_NUMBER}
<#else>
    <#lt>#define SYS_FS_AUTOMOUNT_ENABLE           false
</#if>
    <#lt>#define SYS_FS_MAX_FILES                  ${SYS_FS_MAX_FILES}
    <#lt>#define SYS_FS_MAX_FILE_SYSTEM_TYPE       ${SYS_FS_MAX_FILE_SYSTEM_TYPE}
<#if SYS_FS_MEDIA_MAX_BLOCK_SIZE?has_content>
    <#lt>#define SYS_FS_MEDIA_MAX_BLOCK_SIZE       ${SYS_FS_MEDIA_MAX_BLOCK_SIZE}
    <#lt>#define SYS_FS_MEDIA_MANAGER_BUFFER_SIZE  ${SYS_FS_MEDIA_MANAGER_BUFFER_SIZE}
    <#lt>#define SYS_FS_FILE_NAME_LEN              ${SYS_FS_FILE_NAME_LEN}
    <#lt>#define SYS_FS_CWD_STRING_LEN             ${SYS_FS_CWD_STRING_LEN}
</#if>

<#if HarmonyCore.SELECT_RTOS != "BareMetal">
    <#lt>/* File System RTOS Configurations*/
    <#lt>#define SYS_FS_STACK_SIZE                 ${SYS_FS_RTOS_STACK_SIZE}
    <#lt>#define SYS_FS_PRIORITY                   ${SYS_FS_RTOS_TASK_PRIORITY}
</#if>

<#--
/*******************************************************************************
 End of File
*/
-->

