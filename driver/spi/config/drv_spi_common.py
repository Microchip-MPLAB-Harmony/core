# coding: utf-8
"""*****************************************************************************
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
*****************************************************************************"""

def syncFileGen(symbol, event):
    if event["value"] == "Synchronous":
       symbol.setEnabled(True)
    else:
       symbol.setEnabled(False)

def asyncFileGen(symbol, event):
    if event["value"] == "Asynchronous":
       symbol.setEnabled(True)
    else:
       symbol.setEnabled(False)

def setCommonMode(symbol, event):
    rtos_mode = event["value"]

    if rtos_mode != None:
        if rtos_mode == "BareMetal":
            symbol.setValue("Asynchronous", 1)
        else:
            symbol.setValue("Synchronous", 1)

def instantiateComponent(spiComponentCommon):

    res = Database.activateComponents(["HarmonyCore"])

    rtos_mode = Database.getSymbolValue("HarmonyCore", "SELECT_RTOS")

    spi_default_mode = "Asynchronous"

    if ((rtos_mode != "BareMetal") and (rtos_mode != None)):
        spi_default_mode = "Synchronous"

    spiMode = spiComponentCommon.createComboSymbol("DRV_SPI_COMMON_MODE", None, ["Asynchronous", "Synchronous"])
    spiMode.setLabel("Driver Mode")
    spiMode.setDefaultValue(spi_default_mode)
    spiMode.setDependencies(setCommonMode, ["HarmonyCore.SELECT_RTOS"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    spiSymCommonSysCfgFile = spiComponentCommon.createFileSymbol("DRV_SPI_COMMON_CFG", None)
    spiSymCommonSysCfgFile.setType("STRING")
    spiSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    spiSymCommonSysCfgFile.setSourcePath("driver/spi/templates/system/system_config_common.h.ftl")
    spiSymCommonSysCfgFile.setMarkup(True)

    spiSymSystemDefIncFile = spiComponentCommon.createFileSymbol("DRV_SPI_SYSTEM_DEF", None)
    spiSymSystemDefIncFile.setType("STRING")
    spiSymSystemDefIncFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    spiSymSystemDefIncFile.setSourcePath("driver/spi/templates/system/system_definitions.h.ftl")
    spiSymSystemDefIncFile.setMarkup(True)

    # Async Source Files
    spiAsyncSymSourceFile = spiComponentCommon.createFileSymbol("DRV_SPI_ASYNC_SOURCE", None)
    spiAsyncSymSourceFile.setSourcePath("driver/spi/src/async/drv_spi.c.ftl")
    spiAsyncSymSourceFile.setOutputName("drv_spi.c")
    spiAsyncSymSourceFile.setDestPath("driver/spi/src")
    spiAsyncSymSourceFile.setProjectPath("config/" + configName + "/driver/spi/")
    spiAsyncSymSourceFile.setType("SOURCE")
    spiAsyncSymSourceFile.setMarkup(True)
    spiAsyncSymSourceFile.setOverwrite(True)
    spiAsyncSymSourceFile.setEnabled(spiMode.getValue() == "Asynchronous")
    spiAsyncSymSourceFile.setDependencies(asyncFileGen, ["DRV_SPI_COMMON_MODE"])

    spiAsyncSymHeaderLocalFile = spiComponentCommon.createFileSymbol("DRV_SPI_ASYNC_HEADER_LOCAL", None)
    spiAsyncSymHeaderLocalFile.setSourcePath("driver/spi/src/async/drv_spi_local.h.ftl")
    spiAsyncSymHeaderLocalFile.setOutputName("drv_spi_local.h")
    spiAsyncSymHeaderLocalFile.setDestPath("driver/spi/src")
    spiAsyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/spi/")
    spiAsyncSymHeaderLocalFile.setType("SOURCE")
    spiAsyncSymHeaderLocalFile.setMarkup(True)
    spiAsyncSymHeaderLocalFile.setOverwrite(True)
    spiAsyncSymHeaderLocalFile.setEnabled(spiMode.getValue() == "Asynchronous")
    spiAsyncSymHeaderLocalFile.setDependencies(asyncFileGen, ["DRV_SPI_COMMON_MODE"])

    # Sync Source Files
    spiSyncSymSourceFile = spiComponentCommon.createFileSymbol("DRV_SPI_SYNC_SOURCE", None)
    spiSyncSymSourceFile.setSourcePath("driver/spi/src/sync/drv_spi.c.ftl")
    spiSyncSymSourceFile.setOutputName("drv_spi.c")
    spiSyncSymSourceFile.setDestPath("driver/spi/src")
    spiSyncSymSourceFile.setProjectPath("config/" + configName + "/driver/spi/")
    spiSyncSymSourceFile.setType("SOURCE")
    spiSyncSymSourceFile.setMarkup(True)
    spiSyncSymSourceFile.setOverwrite(True)
    spiSyncSymSourceFile.setEnabled(spiMode.getValue() == "Synchronous")
    spiSyncSymSourceFile.setDependencies(syncFileGen, ["DRV_SPI_COMMON_MODE"])

    spiSyncSymHeaderLocalFile = spiComponentCommon.createFileSymbol("DRV_SPI_SYNC_HEADER_LOCAL", None)
    spiSyncSymHeaderLocalFile.setSourcePath("driver/spi/src/sync/drv_spi_local.h.ftl")
    spiSyncSymHeaderLocalFile.setOutputName("drv_spi_local.h")
    spiSyncSymHeaderLocalFile.setDestPath("driver/spi/src")
    spiSyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/spi/")
    spiSyncSymHeaderLocalFile.setType("SOURCE")
    spiSyncSymHeaderLocalFile.setMarkup(True)
    spiSyncSymHeaderLocalFile.setOverwrite(True)
    spiSyncSymHeaderLocalFile.setEnabled(spiMode.getValue() == "Synchronous")
    spiSyncSymHeaderLocalFile.setDependencies(syncFileGen, ["DRV_SPI_COMMON_MODE"])
