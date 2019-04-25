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
global fsCounter

fsCounter = 0

def enableFileSystemIntegration(symbol, event):
    print(event["value"])
    symbol.setEnabled(event["value"])

def handleMessage(messageID, args):
    global fsCounter

    result_dict = {}

    if (messageID == "DRV_SDSPI_FS_CONNECTION_COUNTER_INC"):
        fsCounter = fsCounter + 1
        Database.setSymbolValue("drv_sdspi", "DRV_SDSPI_COMMON_FS_ENABLE", True)
    if (messageID == "DRV_SDSPI_FS_CONNECTION_COUNTER_DEC"):
        if (fsCounter != 0):
            fsCounter = fsCounter - 1

    if (fsCounter == 0):
        Database.setSymbolValue("drv_sdspi", "DRV_SDSPI_COMMON_FS_ENABLE", False)

    return result_dict

def aSyncFileGen(symbol, event):
    if(event["value"] == "Asynchronous"):
       symbol.setEnabled(True)
    else:
       symbol.setEnabled(False)

def syncFileGen(symbol, event):
    if(event["value"] == "Synchronous"):
       symbol.setEnabled(True)
    else:
       symbol.setEnabled(False)

def setCommonMode(symbol, event):
    rtos_mode = event["value"]

    if (rtos_mode != None):
        if (rtos_mode == "BareMetal"):
            symbol.setValue("Asynchronous")
        else:
            symbol.setValue("Synchronous")

def instantiateComponent(sdspiComponentCommon):
    global sdspiCommonFsEnable

    res = Database.activateComponents(["HarmonyCore"])
    res = Database.activateComponents(["sys_time"])

    rtos_mode = Database.getSymbolValue("HarmonyCore", "SELECT_RTOS")

    sdspi_default_mode = "Asynchronous"

    # Below Lines to be enabled when we have Synchronous support
    if ((rtos_mode != "BareMetal") and (rtos_mode != None)):
        sdspi_default_mode = "Synchronous"

    sdspiCommonMode = sdspiComponentCommon.createComboSymbol("DRV_SDSPI_COMMON_MODE", None, ["Asynchronous", "Synchronous"])
    sdspiCommonMode.setLabel("Driver Mode")
    sdspiCommonMode.setDefaultValue(sdspi_default_mode)
    sdspiCommonMode.setDependencies(setCommonMode, ["HarmonyCore.SELECT_RTOS"])

    sdspiCommonFsEnable = sdspiComponentCommon.createBooleanSymbol("DRV_SDSPI_COMMON_FS_ENABLE", None)
    sdspiCommonFsEnable.setLabel("Enable Common File system for SD Card Driver")
    sdspiCommonFsEnable.setVisible(False)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    # Global Header Files
    sdspiSymHeaderFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_HEADER", None)
    sdspiSymHeaderFile.setSourcePath("driver/sdspi/drv_sdspi.h")
    sdspiSymHeaderFile.setOutputName("drv_sdspi.h")
    sdspiSymHeaderFile.setDestPath("driver/sdspi/")
    sdspiSymHeaderFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSymHeaderFile.setType("HEADER")
    sdspiSymHeaderFile.setOverwrite(True)

    sdspiSymHeaderDefFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_DEF", None)
    sdspiSymHeaderDefFile.setSourcePath("driver/sdspi/templates/drv_sdspi_definitions.h.ftl")
    sdspiSymHeaderDefFile.setOutputName("drv_sdspi_definitions.h")
    sdspiSymHeaderDefFile.setDestPath("driver/sdspi")
    sdspiSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSymHeaderDefFile.setType("HEADER")
    sdspiSymHeaderDefFile.setMarkup(True)
    sdspiSymHeaderDefFile.setOverwrite(True)

    # Async Source Files
    sdspiAsyncSymSourceFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_ASYNC_SOURCE", None)
    sdspiAsyncSymSourceFile.setSourcePath("driver/sdspi/async/src/drv_sdspi.c.ftl")
    sdspiAsyncSymSourceFile.setOutputName("drv_sdspi.c")
    sdspiAsyncSymSourceFile.setDestPath("driver/sdspi/src")
    sdspiAsyncSymSourceFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiAsyncSymSourceFile.setType("SOURCE")
    sdspiAsyncSymSourceFile.setOverwrite(True)
    sdspiAsyncSymSourceFile.setMarkup(True)
    sdspiAsyncSymSourceFile.setEnabled((sdspiCommonMode.getValue() == "Asynchronous"))
    sdspiAsyncSymSourceFile.setDependencies(aSyncFileGen, ["DRV_SDSPI_COMMON_MODE"])

    sdspiAsyncSymHeaderLocalFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_ASYNC_HEADER_LOCAL", None)
    sdspiAsyncSymHeaderLocalFile.setSourcePath("driver/sdspi/async/src/drv_sdspi_local.h.ftl")
    sdspiAsyncSymHeaderLocalFile.setOutputName("drv_sdspi_local.h")
    sdspiAsyncSymHeaderLocalFile.setDestPath("driver/sdspi/src")
    sdspiAsyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiAsyncSymHeaderLocalFile.setType("HEADER")
    sdspiAsyncSymHeaderLocalFile.setOverwrite(True)
    sdspiAsyncSymHeaderLocalFile.setMarkup(True)
    sdspiAsyncSymHeaderLocalFile.setEnabled((sdspiCommonMode.getValue() == "Asynchronous"))
    sdspiAsyncSymHeaderLocalFile.setDependencies(aSyncFileGen, ["DRV_SDSPI_COMMON_MODE"])

    sdspiAsyncSymInterfaceSourceFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_ASYNC_INTERFACE_SOURCE", None)
    sdspiAsyncSymInterfaceSourceFile.setSourcePath("driver/sdspi/async/src/drv_sdspi_plib_interface.c.ftl")
    sdspiAsyncSymInterfaceSourceFile.setOutputName("drv_sdspi_plib_interface.c")
    sdspiAsyncSymInterfaceSourceFile.setDestPath("driver/sdspi/src")
    sdspiAsyncSymInterfaceSourceFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiAsyncSymInterfaceSourceFile.setType("SOURCE")
    sdspiAsyncSymInterfaceSourceFile.setOverwrite(True)
    sdspiAsyncSymInterfaceSourceFile.setMarkup(True)
    sdspiAsyncSymInterfaceSourceFile.setEnabled((sdspiCommonMode.getValue() == "Asynchronous"))
    sdspiAsyncSymInterfaceSourceFile.setDependencies(aSyncFileGen, ["DRV_SDSPI_COMMON_MODE"])

    sdspiAsyncSymInterfaceHeaderFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_ASYNC_INTERFACE_HEADER", None)
    sdspiAsyncSymInterfaceHeaderFile.setSourcePath("driver/sdspi/async/src/drv_sdspi_plib_interface.h.ftl")
    sdspiAsyncSymInterfaceHeaderFile.setOutputName("drv_sdspi_plib_interface.h")
    sdspiAsyncSymInterfaceHeaderFile.setDestPath("driver/sdspi/src")
    sdspiAsyncSymInterfaceHeaderFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiAsyncSymInterfaceHeaderFile.setType("HEADER")
    sdspiAsyncSymInterfaceHeaderFile.setOverwrite(True)
    sdspiAsyncSymInterfaceHeaderFile.setMarkup(True)
    sdspiAsyncSymInterfaceHeaderFile.setEnabled((sdspiCommonMode.getValue() == "Asynchronous"))
    sdspiAsyncSymInterfaceHeaderFile.setDependencies(aSyncFileGen, ["DRV_SDSPI_COMMON_MODE"])

    # Sync Source Files
    sdspiSyncSymSourceFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_SYNC_SOURCE", None)
    sdspiSyncSymSourceFile.setSourcePath("driver/sdspi/sync/src/drv_sdspi.c.ftl")
    sdspiSyncSymSourceFile.setOutputName("drv_sdspi.c")
    sdspiSyncSymSourceFile.setDestPath("driver/sdspi/src")
    sdspiSyncSymSourceFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSyncSymSourceFile.setType("SOURCE")
    sdspiSyncSymSourceFile.setOverwrite(True)
    sdspiSyncSymSourceFile.setMarkup(True)
    sdspiSyncSymSourceFile.setEnabled((sdspiCommonMode.getValue() == "Synchronous"))
    sdspiSyncSymSourceFile.setDependencies(syncFileGen, ["DRV_SDSPI_COMMON_MODE"])

    sdspiSyncSymHeaderLocalFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_SYNC_HEADER_LOCAL", None)
    sdspiSyncSymHeaderLocalFile.setSourcePath("driver/sdspi/sync/src/drv_sdspi_local.h.ftl")
    sdspiSyncSymHeaderLocalFile.setOutputName("drv_sdspi_local.h")
    sdspiSyncSymHeaderLocalFile.setDestPath("driver/sdspi/src")
    sdspiSyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSyncSymHeaderLocalFile.setType("HEADER")
    sdspiSyncSymHeaderLocalFile.setOverwrite(True)
    sdspiSyncSymHeaderLocalFile.setMarkup(True)
    sdspiSyncSymHeaderLocalFile.setEnabled((sdspiCommonMode.getValue() == "Synchronous"))
    sdspiSyncSymHeaderLocalFile.setDependencies(syncFileGen, ["DRV_SDSPI_COMMON_MODE"])

    sdspiSyncSymPlibInterfaceSourceFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_SYNC_PLIB_INTERFACE_SOURCE", None)
    sdspiSyncSymPlibInterfaceSourceFile.setSourcePath("driver/sdspi/sync/src/drv_sdspi_plib_interface.c.ftl")
    sdspiSyncSymPlibInterfaceSourceFile.setOutputName("drv_sdspi_plib_interface.c")
    sdspiSyncSymPlibInterfaceSourceFile.setDestPath("driver/sdspi/src")
    sdspiSyncSymPlibInterfaceSourceFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSyncSymPlibInterfaceSourceFile.setType("SOURCE")
    sdspiSyncSymPlibInterfaceSourceFile.setOverwrite(True)
    sdspiSyncSymPlibInterfaceSourceFile.setMarkup(True)
    sdspiSyncSymPlibInterfaceSourceFile.setEnabled((sdspiCommonMode.getValue() == "Synchronous"))
    sdspiSyncSymPlibInterfaceSourceFile.setDependencies(syncFileGen, ["DRV_SDSPI_COMMON_MODE"])

    sdspiSyncSymPlibInterfaceHeaderFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_SYNC_PLIB_INTERFACE_HEADER", None)
    sdspiSyncSymPlibInterfaceHeaderFile.setSourcePath("driver/sdspi/sync/src/drv_sdspi_plib_interface.h.ftl")
    sdspiSyncSymPlibInterfaceHeaderFile.setOutputName("drv_sdspi_plib_interface.h")
    sdspiSyncSymPlibInterfaceHeaderFile.setDestPath("driver/sdspi/src")
    sdspiSyncSymPlibInterfaceHeaderFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSyncSymPlibInterfaceHeaderFile.setType("HEADER")
    sdspiSyncSymPlibInterfaceHeaderFile.setOverwrite(True)
    sdspiSyncSymPlibInterfaceHeaderFile.setMarkup(True)
    sdspiSyncSymPlibInterfaceHeaderFile.setEnabled((sdspiCommonMode.getValue() == "Synchronous"))
    sdspiSyncSymPlibInterfaceHeaderFile.setDependencies(syncFileGen, ["DRV_SDSPI_COMMON_MODE"])

    sdspiCommonFsSourceFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_FS_SOURCE", None)
    sdspiCommonFsSourceFile.setSourcePath("driver/sdspi/templates/drv_sdspi_file_system.c.ftl")
    sdspiCommonFsSourceFile.setOutputName("drv_sdspi_file_system.c")
    sdspiCommonFsSourceFile.setDestPath("driver/sdspi/src")
    sdspiCommonFsSourceFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiCommonFsSourceFile.setType("SOURCE")
    sdspiCommonFsSourceFile.setOverwrite(True)
    sdspiCommonFsSourceFile.setMarkup(True)
    sdspiCommonFsSourceFile.setEnabled((sdspiCommonFsEnable.getValue() == True))
    sdspiCommonFsSourceFile.setDependencies(enableFileSystemIntegration, ["DRV_SDSPI_COMMON_FS_ENABLE"])

    sdspiSymCommonSysCfgFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_COMMON_CFG", None)
    sdspiSymCommonSysCfgFile.setType("STRING")
    sdspiSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    sdspiSymCommonSysCfgFile.setSourcePath("driver/sdspi/templates/system/system_config_common.h.ftl")
    sdspiSymCommonSysCfgFile.setMarkup(True)

    sdspiSymSystemDefIncFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_SYSTEM_DEF", None)
    sdspiSymSystemDefIncFile.setType("STRING")
    sdspiSymSystemDefIncFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sdspiSymSystemDefIncFile.setSourcePath("driver/sdspi/templates/system/system_definitions.h.ftl")
    sdspiSymSystemDefIncFile.setMarkup(True)
