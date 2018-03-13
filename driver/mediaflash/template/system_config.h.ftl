<#--
/*******************************************************************************
  MEDIAFLASH Driver Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
    system_config.h.ftl

  Summary:
    MEDIAFLASH Driver Freemarker Template File

  Description:

*******************************************************************************/

/*******************************************************************************
Copyright (c) 2014 released Microchip Technology Inc.  All rights reserved.

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

/*** MEDIAFLASH Driver Configuration ***/
<#if USE_DRV_MEDIAFLASH == true>
	<#lt><#-- MEDIAFLASH Media Driver Defines -->
	<#lt>#define DRV_MEDIAFLASH_INSTANCES_NUMBER     	${DRV_MEDIAFLASH_NUM_INSTANCES}
	<#lt>#define DRV_MEDIAFLASH_CLIENTS_NUMBER        	${DRV_MEDIAFLASH_CLIENTS_NUMBER}
	<#lt>#define DRV_MEDIAFLASH_BUFFER_OBJECT_NUMBER  	${DRV_MEDIAFLASH_BUFFER_OBJECT_NUMBER}
	<#lt>#define DRV_MEDIAFLASH_MEDIA_START_ADDRESS     0x${DRV_MEDIAFLASH_MEDIA_START_ADDRESS}
	<#lt>#define DRV_MEDIAFLASH_MEDIA_SIZE              ${DRV_MEDIAFLASH_MEDIA_SIZE}
	<#lt>#define DRV_MEDIAFLASH_INTERRUPT_MODE        	true

	<#lt><#if USE_DRV_MEDIAFLASH_ERASE_WRITE == true>
		<#lt>#define DRV_MEDIAFLASH_ERASE_WRITE_ENABLE
	<#lt></#if>
	<#lt><#if USE_DRV_MEDIAFLASH_SYS_FS_REGISTER == true>
		<#lt>#define DRV_MEDIAFLASH_SYS_FS_REGISTER
	<#lt></#if>

	<#lt><#if USE_DRV_MEDIAFLASH_DISABLE_ERROR_CHECK == true>
		<#lt>#define DRV_MEDIAFLASH_DISABLE_ERROR_CHECK
	<#lt></#if>
	
    <#lt>#define  DRV_MEDIAFLASH_HW_CallbackRegister(callback,context)  EEFC0_CallbackRegister(callback,context)
    <#lt>#define  DRV_MEDIAFLASH_HW_Erase(address)                      EEFC0_EraseRow(address)
    <#lt>#define  DRV_MEDIAFLASH_HW_Write(address,data)                 EEFC0_WritePage(address,data)
    <#lt>#define  DRV_MEDIAFLASH_HW_WRITE_SIZE                          EEFC0_PAGESIZE
    <#lt>#define  DRV_MEDIAFLASH_HW_ERASE_SIZE                          EEFC0_ROWSIZE
    <#lt>#define  DRV_MEDIAFLASH_HW_ID                                  0
	<#lt>#define  DRV_MEDIAFLASH_HW_HEADER								peripheral/eefc/plib_eefc0.h
</#if>
<#--
/*******************************************************************************
 End of File
*/
-->

