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
// <editor-fold defaultstate="collapsed" desc="DRV_SDMMC Instance ${INDEX?string} Initialization Data">

/* SDMMC Client Objects Pool */
static DRV_SDMMC_CLIENT_OBJ drvSDMMC${INDEX?string}ClientObjPool[DRV_SDMMC_CLIENTS_NUMBER_IDX${INDEX?string}];

/* SDMMC Transfer Objects Pool */
static DRV_SDMMC_BUFFER_OBJ drvSDMMC${INDEX?string}BufferObjPool[DRV_SDMMC_QUEUE_SIZE_IDX${INDEX?string}];


const DRV_SDMMC_PLIB_API drvSDMMC${INDEX?string}PlibAPI = {
    .sdhostCallbackRegister = (DRV_SDMMC_PLIB_CALLBACK_REGISTER)${DRV_SDMMC_PLIB}_CallbackRegister,
    .sdhostInitModule = (DRV_SDMMC_PLIB_INIT_MODULE)${DRV_SDMMC_PLIB}_ModuleInit,
    .sdhostSetClock  = (DRV_SDMMC_PLIB_SET_CLOCK)${DRV_SDMMC_PLIB}_ClockSet,
    .sdhostIsCmdLineBusy = (DRV_SDMMC_PLIB_IS_CMD_LINE_BUSY)${DRV_SDMMC_PLIB}_IsCmdLineBusy,
    .sdhostIsDatLineBusy = (DRV_SDMMC_PLIB_IS_DATA_LINE_BUSY)${DRV_SDMMC_PLIB}_IsDatLineBusy,
    .sdhostSendCommand = (DRV_SDMMC_PLIB_SEND_COMMAND)${DRV_SDMMC_PLIB}_CommandSend,
    .sdhostReadResponse = (DRV_SDMMC_PLIB_READ_RESPONSE)${DRV_SDMMC_PLIB}_ResponseRead,
    .sdhostSetBlockCount = (DRV_SDMMC_PLIB_SET_BLOCK_COUNT)${DRV_SDMMC_PLIB}_BlockCountSet,
    .sdhostSetBlockSize = (DRV_SDMMC_PLIB_SET_BLOCK_SIZE)${DRV_SDMMC_PLIB}_BlockSizeSet,
    .sdhostSetBusWidth = (DRV_SDMMC_PLIB_SET_BUS_WIDTH)${DRV_SDMMC_PLIB}_BusWidthSet,
    .sdhostSetSpeedMode = (DRV_SDMMC_PLIB_SET_SPEED_MODE)${DRV_SDMMC_PLIB}_SpeedModeSet,
    .sdhostSetupDma = (DRV_SDMMC_PLIB_SETUP_DMA)${DRV_SDMMC_PLIB}_DmaSetup,
    .sdhostGetCommandError = (DRV_SDMMC_PLIB_GET_COMMAND_ERROR)${DRV_SDMMC_PLIB}_CommandErrorGet,
    .sdhostGetDataError = (DRV_SDMMC_PLIB_GET_DATA_ERROR)${DRV_SDMMC_PLIB}_DataErrorGet,
<#if DRV_SDMMC_PLIB == "HSMCI">
    .sdhostClockEnable = (DRV_SDMMC_PLIB_CLOCK_ENABLE)NULL,
    .sdhostResetError = (DRV_SDMMC_PLIB_RESET_ERROR)NULL,
<#else>
    .sdhostClockEnable = (DRV_SDMMC_PLIB_CLOCK_ENABLE)${DRV_SDMMC_PLIB}_ClockEnable,
    .sdhostResetError = (DRV_SDMMC_PLIB_RESET_ERROR)${DRV_SDMMC_PLIB}_ErrorReset,
</#if>
<#if DRV_SDMMC_PLIB_SDCD_SUPPORT == true>
    .sdhostIsCardAttached = (DRV_SDMMC_PLIB_IS_CARD_ATTACHED)${DRV_SDMMC_PLIB}_IsCardAttached,
<#else>
    .sdhostIsCardAttached = (DRV_SDMMC_PLIB_IS_CARD_ATTACHED)NULL,
</#if>
<#if DRV_SDMMC_PLIB_SDWP_SUPPORT == true>
    .sdhostIsWriteProtected = (DRV_SDMMC_PLIB_IS_WRITE_PROTECTED)${DRV_SDMMC_PLIB}_IsWriteProtected,
<#else>
    .sdhostIsWriteProtected = (DRV_SDMMC_PLIB_IS_WRITE_PROTECTED)NULL,
</#if>
};

/*** SDMMC Driver Initialization Data ***/
const DRV_SDMMC_INIT drvSDMMC${INDEX?string}InitData =
{
    .sdmmcPlib                      = &drvSDMMC${INDEX?string}PlibAPI,
    .bufferObjPool                  = (uintptr_t)&drvSDMMC${INDEX?string}BufferObjPool[0],
    .bufferObjPoolSize              = DRV_SDMMC_QUEUE_SIZE_IDX${INDEX?string},
    .clientObjPool                  = (uintptr_t)&drvSDMMC${INDEX?string}ClientObjPool[0],
    .numClients                     = DRV_SDMMC_CLIENTS_NUMBER_IDX${INDEX?string},
    .cardDetectionMethod            = DRV_SDMMC_CARD_DETECTION_METHOD_IDX${INDEX?string},
<#if DRV_SDMMC_CARD_DETECTION_METHOD == "Use Polling">
    .cardDetectionPollingIntervalMs = ${DRV_SDMMC_POLLING_INTERVAL},
<#else>
    .cardDetectionPollingIntervalMs = 0,
</#if>
    .isWriteProtectCheckEnabled     = ${DRV_SDMMC_WP_CHECK_ENABLE?c},
    .speedMode                      = (DRV_SDMMC_SPEED_MODE)DRV_SDMMC_CONFIG_SPEED_MODE_IDX${INDEX?string},
    .busWidth                       = (DRV_SDMMC_BUS_WIDTH)DRV_SDMMC_CONFIG_BUS_WIDTH_IDX${INDEX?string},
<#if DRV_SDMMC_FS_ENABLE == true>
    <#lt>    .isFsEnabled                    = true,
<#else>
    <#lt>    .isFsEnabled                    = false,
</#if>
};

// </editor-fold>
