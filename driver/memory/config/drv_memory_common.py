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
    symbol.setEnabled(event["value"])

def handleMessage(messageID, args):
    global fsCounter

    result_dict = {}

    if (messageID == "DRV_MEMORY_FS_CONNECTION_COUNTER_INC"):
        fsCounter = fsCounter + 1
        Database.setSymbolValue("drv_memory", "DRV_MEMORY_COMMON_FS_ENABLE", True)
    if (messageID == "DRV_MEMORY_FS_CONNECTION_COUNTER_DEC"):
        if (fsCounter != 0):
            fsCounter = fsCounter - 1

    if (fsCounter == 0):
        Database.setSymbolValue("drv_memory", "DRV_MEMORY_COMMON_FS_ENABLE", False)

    return result_dict

def setSysTimeEnable(symbol, event):
    if (event["value"] == "Synchronous"):
        symbol.setValue(True)
        res = Database.activateComponents(["sys_time"])
    else:
        symbol.setValue(False)

def setCommonMode(symbol, event):
    rtos_mode = event["value"]

    if (rtos_mode != None):
        if (rtos_mode == "BareMetal"):
            symbol.setValue("Asynchronous")
        else:
            symbol.setValue("Synchronous")

def syncFileGen(symbol, event):
    if(event["value"] == "Synchronous"):
       symbol.setEnabled(True)
    else:
       symbol.setEnabled(False)

def aSyncFileGen(symbol, event):
    if(event["value"] == "Asynchronous"):
       symbol.setEnabled(True)
    else:
       symbol.setEnabled(False)

def instantiateComponent(memoryCommonComponent):
    global memoryCommonFsEnable

    res = Database.activateComponents(["HarmonyCore"])

    rtos_mode = Database.getSymbolValue("HarmonyCore", "SELECT_RTOS")

    memory_default_mode = "Asynchronous"

    if ((rtos_mode != "BareMetal") and (rtos_mode != None)):
        memory_default_mode = "Synchronous"

    memoryCommonMode = memoryCommonComponent.createComboSymbol("DRV_MEMORY_COMMON_MODE", None, ["Asynchronous", "Synchronous"])
    memoryCommonMode.setLabel("Driver Mode")
    memoryCommonMode.setDefaultValue(memory_default_mode)
    memoryCommonMode.setDependencies(setCommonMode, ["HarmonyCore.SELECT_RTOS"])

    memorySysTimeEnable = memoryCommonComponent.createBooleanSymbol("DRV_MEMORY_COMMON_SYS_TIME_ENABLE", None)
    memorySysTimeEnable.setLabel("Enable Timer System Service")
    memorySysTimeEnable.setVisible(False)
    memorySysTimeEnable.setDefaultValue((memoryCommonMode.getValue() == "Synchronous"))
    memorySysTimeEnable.setDependencies(setSysTimeEnable, ["DRV_MEMORY_COMMON_MODE"])

    if (memorySysTimeEnable.getValue() == True):
        res = Database.activateComponents(["sys_time"])

    memoryCommonFsEnable = memoryCommonComponent.createBooleanSymbol("DRV_MEMORY_COMMON_FS_ENABLE", None)
    memoryCommonFsEnable.setLabel("Enable Common File system for Memory Driver")
    memoryCommonFsEnable.setVisible(False)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    # Async Source Files
    memoryAsyncSourceFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_ASYNC_SOURCE", None)
    memoryAsyncSourceFile.setSourcePath("driver/memory/async/src/drv_memory.c")
    memoryAsyncSourceFile.setOutputName("drv_memory.c")
    memoryAsyncSourceFile.setDestPath("driver/memory/src")
    memoryAsyncSourceFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryAsyncSourceFile.setType("SOURCE")
    memoryAsyncSourceFile.setOverwrite(True)
    memoryAsyncSourceFile.setEnabled((memoryCommonMode.getValue() == "Asynchronous"))
    memoryAsyncSourceFile.setDependencies(aSyncFileGen, ["DRV_MEMORY_COMMON_MODE"])

    memoryAsyncHeaderLocalFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_ASYNC_HEADER_LOCAL", None)
    memoryAsyncHeaderLocalFile.setSourcePath("driver/memory/async/src/drv_memory_local.h")
    memoryAsyncHeaderLocalFile.setOutputName("drv_memory_local.h")
    memoryAsyncHeaderLocalFile.setDestPath("driver/memory/src")
    memoryAsyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryAsyncHeaderLocalFile.setType("HEADER")
    memoryAsyncHeaderLocalFile.setOverwrite(True)
    memoryAsyncHeaderLocalFile.setEnabled((memoryCommonMode.getValue() == "Asynchronous"))
    memoryAsyncHeaderLocalFile.setDependencies(aSyncFileGen, ["DRV_MEMORY_COMMON_MODE"])

    # Sync Source Files
    memorySyncSourceFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_SYNC_SOURCE", None)
    memorySyncSourceFile.setSourcePath("driver/memory/sync/src/drv_memory.c")
    memorySyncSourceFile.setOutputName("drv_memory.c")
    memorySyncSourceFile.setDestPath("driver/memory/src")
    memorySyncSourceFile.setProjectPath("config/" + configName + "/driver/memory/")
    memorySyncSourceFile.setType("SOURCE")
    memorySyncSourceFile.setOverwrite(True)
    memorySyncSourceFile.setEnabled((memoryCommonMode.getValue() == "Synchronous"))
    memorySyncSourceFile.setDependencies(syncFileGen, ["DRV_MEMORY_COMMON_MODE"])

    memorySyncHeaderLocalFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_SYNC_HEADER_LOCAL", None)
    memorySyncHeaderLocalFile.setSourcePath("driver/memory/sync/src/drv_memory_local.h")
    memorySyncHeaderLocalFile.setOutputName("drv_memory_local.h")
    memorySyncHeaderLocalFile.setDestPath("driver/memory/src")
    memorySyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/memory/")
    memorySyncHeaderLocalFile.setType("HEADER")
    memorySyncHeaderLocalFile.setOverwrite(True)
    memorySyncHeaderLocalFile.setEnabled((memoryCommonMode.getValue() == "Synchronous"))
    memorySyncHeaderLocalFile.setDependencies(syncFileGen, ["DRV_MEMORY_COMMON_MODE"])

    memoryCommonFsSourceFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_FS_SOURCE", None)
    memoryCommonFsSourceFile.setSourcePath("driver/memory/templates/drv_memory_file_system.c.ftl")
    memoryCommonFsSourceFile.setOutputName("drv_memory_file_system.c")
    memoryCommonFsSourceFile.setDestPath("driver/memory/src")
    memoryCommonFsSourceFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryCommonFsSourceFile.setType("SOURCE")
    memoryCommonFsSourceFile.setOverwrite(True)
    memoryCommonFsSourceFile.setMarkup(True)
    memoryCommonFsSourceFile.setEnabled((memoryCommonFsEnable.getValue() == True))
    memoryCommonFsSourceFile.setDependencies(enableFileSystemIntegration, ["DRV_MEMORY_COMMON_FS_ENABLE"])

    memoryCommonSystemDefFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_SYS_DEF_COMMON", None)
    memoryCommonSystemDefFile.setType("STRING")
    memoryCommonSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    memoryCommonSystemDefFile.setSourcePath("driver/memory/templates/system/definitions_common.h.ftl")
    memoryCommonSystemDefFile.setMarkup(True)

    memoryCommonSymCommonSysCfgFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_SYS_CFG_COMMON", None)
    memoryCommonSymCommonSysCfgFile.setType("STRING")
    memoryCommonSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    memoryCommonSymCommonSysCfgFile.setSourcePath("driver/memory/templates/system/configuration_common.h.ftl")
    memoryCommonSymCommonSysCfgFile.setMarkup(True)
