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

################################################################################
#### Component ####
################################################################################

def instantiateComponent(debugComponent):

    res = Database.activateComponents(["HarmonyCore"])

    # Enable dependent Harmony core components
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True)

    if (Database.getSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
        Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True)

    debugConsoleDevice = debugComponent.createStringSymbol("SYS_CONSOLE_DEVICE", None)
    debugConsoleDevice.setLabel("Device Used")
    debugConsoleDevice.setReadOnly(True)
    debugConsoleDevice.setDefaultValue("")

    debugConsoleIndex = debugComponent.createStringSymbol("SYS_CONSOLE_INDEX", None)
    debugConsoleIndex.setVisible(False)
    debugConsoleIndex.setDefaultValue("")

    debugLevel = debugComponent.createComboSymbol("SYS_DEBUG_LEVEL", None, ["SYS_ERROR_FATAL", "SYS_ERROR_ERROR", "SYS_ERROR_WARNING", "SYS_ERROR_INFO", "SYS_ERROR_DEBUG"])
    debugLevel.setLabel("Debug Level")
    debugLevel.setDefaultValue("SYS_ERROR_DEBUG")

    debugPrintBufferSize = debugComponent.createIntegerSymbol("SYS_DEBUG_PRINT_BUFFER_SIZE", None)
    debugPrintBufferSize.setLabel("Debug Print Buffer Size (128-8192)")
    debugPrintBufferSize.setMin(128)
    debugPrintBufferSize.setMax(8192)
    debugPrintBufferSize.setDefaultValue(200)

    debugUseConsole = debugComponent.createBooleanSymbol("SYS_DEBUG_USE_CONSOLE", None)
    debugUseConsole.setLabel("Use Console for Debug ?")
    debugUseConsole.setDefaultValue(True)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    debugHeaderFile = debugComponent.createFileSymbol("SYS_DEBUG_HEADER", None)
    debugHeaderFile.setSourcePath("system/debug/templates/sys_debug.h.ftl")
    debugHeaderFile.setOutputName("sys_debug.h")
    debugHeaderFile.setDestPath("system/debug/")
    debugHeaderFile.setProjectPath("config/" + configName + "/system/debug/")
    debugHeaderFile.setType("HEADER")
    debugHeaderFile.setOverwrite(True)
    debugHeaderFile.setMarkup(True)

    debugHeaderLocalFile = debugComponent.createFileSymbol("SYS_DEBUG_LOCAL", None)
    debugHeaderLocalFile.setSourcePath("system/debug/src/sys_debug_local.h")
    debugHeaderLocalFile.setOutputName("sys_debug_local.h")
    debugHeaderLocalFile.setDestPath("system/debug/src")
    debugHeaderLocalFile.setProjectPath("config/" + configName + "/system/debug/")
    debugHeaderLocalFile.setType("SOURCE")
    debugHeaderLocalFile.setOverwrite(True)

    debugSourceFile = debugComponent.createFileSymbol("SYS_DEBUG_SOURCE", None)
    debugSourceFile.setSourcePath("system/debug/src/sys_debug.c")
    debugSourceFile.setOutputName("sys_debug.c")
    debugSourceFile.setDestPath("system/debug/src")
    debugSourceFile.setProjectPath("config/" + configName + "/system/debug/")
    debugSourceFile.setType("SOURCE")
    debugSourceFile.setOverwrite(True)

    debugSystemDefFile = debugComponent.createFileSymbol("SYS_CONSOLE_SYS_DEF", None)
    debugSystemDefFile.setType("STRING")
    debugSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    debugSystemDefFile.setSourcePath("system/debug/templates/system/system_definitions.h.ftl")
    debugSystemDefFile.setMarkup(True)

    debugSystemDefObjFile = debugComponent.createFileSymbol("SYS_CONSOLE_SYS_DEF_OBJ", None)
    debugSystemDefObjFile.setType("STRING")
    debugSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    debugSystemDefObjFile.setSourcePath("system/debug/templates/system/system_definitions_objects.h.ftl")
    debugSystemDefObjFile.setMarkup(True)

    debugSystemConfigFile = debugComponent.createFileSymbol("SYS_CONSOLE_SYS_CONFIG", None)
    debugSystemConfigFile.setType("STRING")
    debugSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION")
    debugSystemConfigFile.setSourcePath("system/debug/templates/system/system_config.h.ftl")
    debugSystemConfigFile.setMarkup(True)

    debugSystemInitDataFile = debugComponent.createFileSymbol("SYS_CONSOLE_SYS_INIT_DATA", None)
    debugSystemInitDataFile.setType("STRING")
    debugSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYSTEM_INITIALIZATION")
    debugSystemInitDataFile.setSourcePath("system/debug/templates/system/system_initialize_data.c.ftl")
    debugSystemInitDataFile.setMarkup(True)

    debugSystemInitFile = debugComponent.createFileSymbol("SYS_CONSOLE_SYS_INIT", None)
    debugSystemInitFile.setType("STRING")
    debugSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_INITIALIZE_SYSTEM_SERVICES")
    debugSystemInitFile.setSourcePath("system/debug/templates/system/system_initialize.c.ftl")
    debugSystemInitFile.setMarkup(True)

############################################################################
#### Dependency ####
############################################################################

def onAttachmentConnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "sys_debug_SYS_CONSOLE_dependency" :
        deviceUsed = localComponent.getSymbolByID("SYS_CONSOLE_DEVICE")
        deviceConsoleIndex = localComponent.getSymbolByID("SYS_CONSOLE_INDEX")
        consoleIndex = ''.join(i for i in remoteID if i.isdigit())

        deviceUsed.setValue(remoteID.upper())
        deviceConsoleIndex.setValue(consoleIndex)

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "sys_debug_SYS_CONSOLE_dependency" :
        deviceUsed = localComponent.getSymbolByID("SYS_CONSOLE_DEVICE")
        deviceConsoleIndex = localComponent.getSymbolByID("SYS_CONSOLE_INDEX")

        deviceUsed.clearValue()
        deviceConsoleIndex.clearValue()
