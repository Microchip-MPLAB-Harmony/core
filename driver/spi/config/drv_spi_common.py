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

def handleMessage(messageID, args):
    global spiMode
    global spiSymSYSDMACodeEnable
    global spiSymSYSDMAEnableCntr

    result_dict = {}

    if (messageID == "DRV_SDSPI_SET_COMMON_MODE_TO_ASYNC"):
        spiMode.setValue("Asynchronous")
        spiMode.setReadOnly(True)
    if (messageID == "DRV_SDSPI_SET_COMMON_MODE_TO_SYNC"):
        spiMode.setValue("Synchronous")
        spiMode.setReadOnly(True)
    if (messageID == "DRV_SDSPI_DISCONNECTED"):
        spiMode.setReadOnly(False)
    if (messageID == "DRV_SPI_DMA_ENABLED"):
        spiSymSYSDMAEnableCntr.setValue(spiSymSYSDMAEnableCntr.getValue() + 1)
        spiSymSYSDMACodeEnable.setValue(True)
    if (messageID == "DRV_SPI_DMA_DISABLED"):
        if spiSymSYSDMAEnableCntr.getValue() > 0:
            spiSymSYSDMAEnableCntr.setValue(spiSymSYSDMAEnableCntr.getValue() - 1)
        if spiSymSYSDMAEnableCntr.getValue() == 0:
            spiSymSYSDMACodeEnable.setValue(False)

    return result_dict

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
            symbol.setValue("Asynchronous")
        else:
            symbol.setValue("Synchronous")

def sysDMAEnabled(symbol, event):
    if symbol.getValue() != event["value"]:
        symbol.setValue(event["value"])
        if Database.getSymbolValue("core", "DMA_ENABLE") != None:
            Database.sendMessage("HarmonyCore", "ENABLE_SYS_DMA", {"isEnabled":event["value"]})

def instantiateComponent(spiComponentCommon):
    global spiMode
    global spiSymSYSDMACodeEnable
    global spiSymSYSDMAEnableCntr

    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Port Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_PORTS", {"isEnabled":True})

    rtos_mode = Database.getSymbolValue("HarmonyCore", "SELECT_RTOS")

    spi_default_mode = "Asynchronous"

    if ((rtos_mode != "BareMetal") and (rtos_mode != None)):
        spi_default_mode = "Synchronous"

    spiMode = spiComponentCommon.createComboSymbol("DRV_SPI_COMMON_MODE", None, ["Asynchronous", "Synchronous"])
    spiMode.setLabel("Driver Mode")
    spiMode.setDefaultValue(spi_default_mode)
    spiMode.setDependencies(setCommonMode, ["HarmonyCore.SELECT_RTOS"])

    spiSymSYSDMAEnableCntr = spiComponentCommon.createIntegerSymbol("DRV_SPI_SYS_DMA_ENABLE_CNTR", None)
    spiSymSYSDMAEnableCntr.setDefaultValue(0)
    spiSymSYSDMAEnableCntr.setVisible(False)

    spiSymSYSDMACodeEnable = spiComponentCommon.createBooleanSymbol("DRV_SPI_SYS_DMA_CODE_ENABLE", None)
    spiSymSYSDMACodeEnable.setDefaultValue(False)
    spiSymSYSDMACodeEnable.setVisible(False)

    spiSymSYSDMAEnable = spiComponentCommon.createBooleanSymbol("DRV_SPI_SYS_DMA_ENABLE", None)
    spiSymSYSDMAEnable.setDefaultValue(False)
    spiSymSYSDMAEnable.setVisible(False)
    spiSymSYSDMAEnable.setDependencies(sysDMAEnabled, ["DRV_SPI_SYS_DMA_CODE_ENABLE"])

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

    # Global Header Files
    spiSymHeaderFile = spiComponentCommon.createFileSymbol("DRV_SPI_HEADER", None)
    spiSymHeaderFile.setSourcePath("driver/spi/drv_spi.h")
    spiSymHeaderFile.setOutputName("drv_spi.h")
    spiSymHeaderFile.setDestPath("driver/spi/")
    spiSymHeaderFile.setProjectPath("config/" + configName + "/driver/spi/")
    spiSymHeaderFile.setType("HEADER")
    spiSymHeaderFile.setOverwrite(True)

    spiSymHeaderDefFile = spiComponentCommon.createFileSymbol("DRV_SPI_DEF", None)
    spiSymHeaderDefFile.setSourcePath("driver/spi/templates/drv_spi_definitions.h.ftl")
    spiSymHeaderDefFile.setOutputName("drv_spi_definitions.h")
    spiSymHeaderDefFile.setDestPath("driver/spi")
    spiSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/spi/")
    spiSymHeaderDefFile.setType("HEADER")
    spiSymHeaderDefFile.setMarkup(True)
    spiSymHeaderDefFile.setOverwrite(True)

def destroyComponent(spiComponentCommon):
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_PORTS", {"isEnabled":False})

    if Database.getSymbolValue("core", "DMA_ENABLE") != None:
        Database.sendMessage("HarmonyCore", "ENABLE_SYS_DMA", {"isEnabled":False})
