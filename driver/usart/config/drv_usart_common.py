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

drv_usart_mcc_helpkeyword = "mcc_h3_drv_usart_configurations"

def handleMessage(messageID, args):
    global usartSymSYSDMACodeEnable
    global usartSymSYSDMAEnableCntr
    global usartMode
    global usartModeLock

    result_dict = {}

    if (messageID == "DRV_USART_DMA_ENABLED"):
        usartSymSYSDMAEnableCntr.setValue(usartSymSYSDMAEnableCntr.getValue() + 1)
        usartSymSYSDMACodeEnable.setValue(True)
    elif (messageID == "DRV_USART_DMA_DISABLED"):
        if usartSymSYSDMAEnableCntr.getValue() > 0:
            usartSymSYSDMAEnableCntr.setValue(usartSymSYSDMAEnableCntr.getValue() - 1)
        if usartSymSYSDMAEnableCntr.getValue() == 0:
            usartSymSYSDMACodeEnable.setValue(False)

    elif (messageID == "DRV_USART_OPERATING_MODE_CONFIG"):
        if args.get("mode") != None:
            usartMode.setValue(args["mode"])
        if args.get("isReadOnly") != None:
            usartMode.setReadOnly(args["isReadOnly"])
        if args.get("isLocked") != None:
            usartModeLock.setValue(args["isLocked"])

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
    global usartModeLock

    rtos_mode = event["value"]

    if rtos_mode != None and usartModeLock.getValue() == False:
        if rtos_mode == "BareMetal":
            symbol.setValue("Asynchronous")
        else:
            symbol.setValue("Synchronous")

def sysDMAEnabled(symbol, event):
    if symbol.getValue() != event["value"]:
        symbol.setValue(event["value"])
        if Database.getSymbolValue("core", "DMA_ENABLE") != None:
            Database.sendMessage("HarmonyCore", "ENABLE_SYS_DMA", {"isEnabled":event["value"]})
################################################################################
#### Component ####
################################################################################

def instantiateComponent(usartComponentCommon):
    global usartSymSYSDMACodeEnable
    global usartSymSYSDMAEnableCntr
    global usartMode
    global usartModeLock

    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

    rtos_mode = Database.getSymbolValue("HarmonyCore", "SELECT_RTOS")

    usart_default_mode = "Asynchronous"

    if ((rtos_mode != "BareMetal") and (rtos_mode != None)):
        usart_default_mode = "Synchronous"

    usartMode = usartComponentCommon.createComboSymbol("DRV_USART_COMMON_MODE", None, ["Asynchronous", "Synchronous"])
    usartMode.setLabel("Driver Mode")
    usartMode.setHelp(drv_usart_mcc_helpkeyword)
    usartMode.setDefaultValue(usart_default_mode)
    usartMode.setDependencies(setCommonMode, ["HarmonyCore.SELECT_RTOS"])

    usartSymBufPool = usartComponentCommon.createIntegerSymbol("DRV_USART_BUFFER_POOL_SIZE", None)
    usartSymBufPool.setLabel("Buffer Pool Size")
    usartSymBufPool.setMin(1)
    usartSymBufPool.setDefaultValue(1)
    usartSymBufPool.setUseSingleDynamicValue(True)
    usartSymBufPool.setVisible(False)

    usartSymSYSDMAEnableCntr = usartComponentCommon.createIntegerSymbol("DRV_USART_SYS_DMA_ENABLE_CNTR", None)
    usartSymSYSDMAEnableCntr.setDefaultValue(0)
    usartSymSYSDMAEnableCntr.setVisible(False)

    usartSymSYSDMACodeEnable = usartComponentCommon.createBooleanSymbol("DRV_USART_SYS_DMA_CODE_ENABLE", None)
    usartSymSYSDMACodeEnable.setDefaultValue(False)
    usartSymSYSDMACodeEnable.setVisible(False)

    usartSymSYSDMAEnable = usartComponentCommon.createBooleanSymbol("DRV_USART_SYS_DMA_ENABLE", None)
    usartSymSYSDMAEnable.setDefaultValue(False)
    usartSymSYSDMAEnable.setVisible(False)
    usartSymSYSDMAEnable.setDependencies(sysDMAEnabled, ["DRV_USART_SYS_DMA_CODE_ENABLE"])

    usartModeLock = usartComponentCommon.createBooleanSymbol("DRV_USART_COMMON_MODE_LOCK", None)
    usartModeLock.setDefaultValue(False)
    usartModeLock.setVisible(False)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    # Common system file content
    usartCommonSysCfgFile = usartComponentCommon.createFileSymbol("USART_COMMON_CFG", None)
    usartCommonSysCfgFile.setType("STRING")
    usartCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    usartCommonSysCfgFile.setSourcePath("driver/usart/templates/system/system_config_common.h.ftl")
    usartCommonSysCfgFile.setMarkup(True)

    usartSystemDefFile = usartComponentCommon.createFileSymbol("USART_DEF", None)
    usartSystemDefFile.setType("STRING")
    usartSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    usartSystemDefFile.setSourcePath("driver/usart/templates/system/system_definitions.h.ftl")
    usartSystemDefFile.setMarkup(True)

    usartSymHeaderDefFile = usartComponentCommon.createFileSymbol("DRV_USART_DEF", None)
    usartSymHeaderDefFile.setSourcePath("driver/usart/templates/drv_usart_definitions.h.ftl")
    usartSymHeaderDefFile.setOutputName("drv_usart_definitions.h")
    usartSymHeaderDefFile.setDestPath("driver/usart")
    usartSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartSymHeaderDefFile.setType("HEADER")
    usartSymHeaderDefFile.setMarkup(True)
    usartSymHeaderDefFile.setOverwrite(True)

    # Async Source Files
    usartAsyncSourceFile = usartComponentCommon.createFileSymbol("USART_ASYNC_SOURCE", None)
    usartAsyncSourceFile.setSourcePath("driver/usart/src/async/drv_usart.c.ftl")
    usartAsyncSourceFile.setOutputName("drv_usart.c")
    usartAsyncSourceFile.setDestPath("driver/usart/src")
    usartAsyncSourceFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartAsyncSourceFile.setType("SOURCE")
    usartAsyncSourceFile.setMarkup(True)
    usartAsyncSourceFile.setOverwrite(True)
    usartAsyncSourceFile.setEnabled(usartMode.getValue() == "Asynchronous")
    usartAsyncSourceFile.setDependencies(asyncFileGen, ["DRV_USART_COMMON_MODE"])

    usartAsyncHeaderLocalFile = usartComponentCommon.createFileSymbol("USART_ASYNC_LOCAL", None)
    usartAsyncHeaderLocalFile.setSourcePath("driver/usart/src/async/drv_usart_local.h.ftl")
    usartAsyncHeaderLocalFile.setOutputName("drv_usart_local.h")
    usartAsyncHeaderLocalFile.setDestPath("driver/usart/src")
    usartAsyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartAsyncHeaderLocalFile.setType("SOURCE")
    usartAsyncHeaderLocalFile.setMarkup(True)
    usartAsyncHeaderLocalFile.setOverwrite(True)
    usartAsyncHeaderLocalFile.setEnabled(usartMode.getValue() == "Asynchronous")
    usartAsyncHeaderLocalFile.setDependencies(asyncFileGen, ["DRV_USART_COMMON_MODE"])

    # Sync Source Files
    usartSyncSourceFile = usartComponentCommon.createFileSymbol("USART_SYNC_SOURCE", None)
    usartSyncSourceFile.setSourcePath("driver/usart/src/sync/drv_usart.c.ftl")
    usartSyncSourceFile.setOutputName("drv_usart.c")
    usartSyncSourceFile.setDestPath("driver/usart/src")
    usartSyncSourceFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartSyncSourceFile.setType("SOURCE")
    usartSyncSourceFile.setMarkup(True)
    usartSyncSourceFile.setOverwrite(True)
    usartSyncSourceFile.setEnabled(usartMode.getValue() == "Synchronous")
    usartSyncSourceFile.setDependencies(syncFileGen, ["DRV_USART_COMMON_MODE"])

    usartSyncHeaderLocalFile = usartComponentCommon.createFileSymbol("USART_SYNC_LOCAL", None)
    usartSyncHeaderLocalFile.setSourcePath("driver/usart/src/sync/drv_usart_local.h.ftl")
    usartSyncHeaderLocalFile.setOutputName("drv_usart_local.h")
    usartSyncHeaderLocalFile.setDestPath("driver/usart/src")
    usartSyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartSyncHeaderLocalFile.setType("SOURCE")
    usartSyncHeaderLocalFile.setMarkup(True)
    usartSyncHeaderLocalFile.setOverwrite(True)
    usartSyncHeaderLocalFile.setEnabled(usartMode.getValue() == "Synchronous")
    usartSyncHeaderLocalFile.setDependencies(syncFileGen, ["DRV_USART_COMMON_MODE"])

def destroyComponent(usartComponentCommon):
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})

    if Database.getSymbolValue("core", "DMA_ENABLE") != None:
        Database.sendMessage("HarmonyCore", "ENABLE_SYS_DMA", {"isEnabled":False})
