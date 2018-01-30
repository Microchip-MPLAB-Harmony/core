<#--
/*******************************************************************************
Copyright (c) 2013-2014 released Microchip Technology Inc.  All rights reserved.

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
// <editor-fold defaultstate="collapsed" desc="DRV_MEDIAFLASH Initialization Data">
/*** FLASH Driver Initialization Data ***/
<#if USE_DRV_MEDIAFLASH == true>
	<#lt>SYS_FS_MEDIA_REGION_GEOMETRY MEDIAFLASHGeometryTable[3] =
	<#lt>{
	<#lt>	{
	<#lt>		.blockSize = 1,
	<#lt>		.numBlocks = (DRV_MEDIAFLASH_MEDIA_SIZE * 1024),
	<#lt>	},
	<#lt>	{
	<#lt>		.blockSize = DRV_MEDIAFLASH_ROW_SIZE,
	<#lt>		.numBlocks = ((DRV_MEDIAFLASH_MEDIA_SIZE * 1024)/DRV_MEDIAFLASH_ROW_SIZE)
	<#lt>	},
	<#lt>	{
	<#lt>		.blockSize = DRV_MEDIAFLASH_PAGE_SIZE,
	<#lt>		.numBlocks = ((DRV_MEDIAFLASH_MEDIA_SIZE * 1024)/DRV_MEDIAFLASH_PAGE_SIZE)
	<#lt>	}
	<#lt>	};


	<#lt>const SYS_FS_MEDIA_GEOMETRY MEDIAFLASHGeometry =
	<#lt>{
	<#lt>	.mediaProperty = SYS_FS_MEDIA_WRITE_IS_BLOCKING,
	<#lt>	.numReadRegions = 1,
	<#lt>	.numWriteRegions = 1,
	<#lt>	.numEraseRegions = 1,
	<#lt>	.geometryTable = (SYS_FS_MEDIA_REGION_GEOMETRY *)&MEDIAFLASHGeometryTable
	<#lt>};

	<#lt>const DRV_MEDIAFLASH_INIT drvMediaflashInit =
	<#lt>{
	<#lt>		.moduleInit.sys.powerState = SYS_MODULE_POWER_RUN_FULL,
	<#lt>		.mediaflashID = DRV_MEDIAFLASH_HW_ID ,
	<#lt>	<#if DRV_MEDIAFLASH_MEDIA_START_ADDRESS?has_content>
	<#lt>		.mediaStartAddress = ${DRV_MEDIAFLASH_MEDIA_START_ADDRESS},
	<#lt>		.mediaflashMediaGeometry = (SYS_FS_MEDIA_GEOMETRY *)&MEDIAFLASHGeometry
	<#lt>	</#if>

	<#lt>};

</#if>
