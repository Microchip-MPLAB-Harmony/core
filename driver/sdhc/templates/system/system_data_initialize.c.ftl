<#--
/*******************************************************************************
Copyright (c) 2013-2015 released Microchip Technology Inc.  All rights reserved.

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
<#if USE_DRV_SDHC == true>
/*** SDHC Driver Initialization Data ***/
<#lt>	const DRV_SDHC_INIT drvSDHCInit =
<#lt>	{
		<#if DRV_SDHC_SDCDEN == true>
	<#lt>		.sdCardDetectEnable = true,
		<#else>
	<#lt>		.sdCardDetectEnable = false,
		</#if>
		<#if DRV_SDHC_SDWPEN == true>
	<#lt>		.sdWriteProtectEnable = true,
		<#else>
	<#lt>		.sdWriteProtectEnable = false,
		</#if>
		<#if DRV_SDHC_SDHC_BUS_SPEED == "HIGH_SPEED">
	<#lt>		.speedMode = DRV_SDHC_SPEED_MODE_HIGH,
		<#else>
	<#lt>		.speedMode = DRV_SDHC_SPEED_MODE_DEFAULT,
		</#if> 
		<#if DRV_SDHC_TRANSFER_BUS_WIDTH == "1-bit">
	<#lt>		.busWidth = DRV_SDHC_BUS_WIDTH_1_BIT,
		<#else>
	<#lt>		.busWidth = DRV_SDHC_BUS_WIDTH_4_BIT,
		</#if> 
		<#if DRV_SDHC_SYS_FS_REGISTER == true>
	<#lt>		.registerWithFs = true,
		<#else>
	<#lt>		.registerWithFs = false,
		</#if> 
	};
</#if>
// </editor-fold>
<#--
/*******************************************************************************
 End of File
*/
-->
