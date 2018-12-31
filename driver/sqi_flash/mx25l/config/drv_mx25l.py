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

def mx25lSetMemoryDependency(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def instantiateComponent(mx25lComponent):

    res = Database.activateComponents(["HarmonyCore"])

    # Enable dependent Harmony core components
    Database.clearSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
    Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True, 2)

    Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True, 2)

    mx25lPLIB = mx25lComponent.createStringSymbol("DRV_MX25L_PLIB", None)
    mx25lPLIB.setLabel("PLIB Used")
    mx25lPLIB.setReadOnly(True)

    ##### Do not modify below symbol names as they are used by Memory Driver #####
    mx25lMemoryDriver = mx25lComponent.createBooleanSymbol("DRV_MEMORY_CONNECTED", None)
    mx25lMemoryDriver.setLabel("Memory Driver Connected")
    mx25lMemoryDriver.setVisible(False)
    mx25lMemoryDriver.setDefaultValue(False)

    mx25lMemoryStartAddr = mx25lComponent.createHexSymbol("START_ADDRESS", None)
    mx25lMemoryStartAddr.setLabel("MX25L Start Address")
    mx25lMemoryStartAddr.setVisible(True)
    mx25lMemoryStartAddr.setDefaultValue(0x0000000)

    mx25lMemoryInterruptEnable = mx25lComponent.createBooleanSymbol("INTERRUPT_ENABLE", None)
    mx25lMemoryInterruptEnable.setLabel("MX25L Interrupt Enable")
    mx25lMemoryInterruptEnable.setVisible(False)
    mx25lMemoryInterruptEnable.setDefaultValue(False)
    mx25lMemoryInterruptEnable.setReadOnly(True)

    mx25lMemoryEraseEnable = mx25lComponent.createBooleanSymbol("ERASE_ENABLE", None)
    mx25lMemoryEraseEnable.setLabel("MX25L Erase Enable")
    mx25lMemoryEraseEnable.setVisible(False)
    mx25lMemoryEraseEnable.setDefaultValue(True)
    mx25lMemoryEraseEnable.setReadOnly(True)

    mx25lMemoryEraseBufferSize = mx25lComponent.createIntegerSymbol("ERASE_BUFFER_SIZE", None)
    mx25lMemoryEraseBufferSize.setLabel("MX25L Erase Buffer Size")
    mx25lMemoryEraseBufferSize.setVisible(False)
    mx25lMemoryEraseBufferSize.setDefaultValue(4096)
    mx25lMemoryEraseBufferSize.setDependencies(mx25lSetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    mx25lMemoryEraseComment = mx25lComponent.createCommentSymbol("ERASE_COMMENT", None)
    mx25lMemoryEraseComment.setVisible(False)
    mx25lMemoryEraseComment.setLabel("*** Should be equal to Sector Erase Size ***")
    mx25lMemoryEraseComment.setDependencies(mx25lSetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    mx25lHeaderFile = mx25lComponent.createFileSymbol("DRV_MX25L_HEADER", None)
    mx25lHeaderFile.setSourcePath("driver/sqi_flash/mx25l/drv_mx25l.h")
    mx25lHeaderFile.setOutputName("drv_mx25l.h")
    mx25lHeaderFile.setDestPath("driver/mx25l/")
    mx25lHeaderFile.setProjectPath("config/" + configName + "/driver/mx25l/")
    mx25lHeaderFile.setType("HEADER")
    mx25lHeaderFile.setOverwrite(True)

    mx25lAsyncHeaderLocalFile = mx25lComponent.createFileSymbol("DRV_MX25L_HEADER_LOCAL", None)
    mx25lAsyncHeaderLocalFile.setSourcePath("driver/sqi_flash/mx25l/src/drv_mx25l_local.h")
    mx25lAsyncHeaderLocalFile.setOutputName("drv_mx25l_local.h")
    mx25lAsyncHeaderLocalFile.setDestPath("driver/mx25l/src")
    mx25lAsyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/mx25l/")
    mx25lAsyncHeaderLocalFile.setType("HEADER")
    mx25lAsyncHeaderLocalFile.setOverwrite(True)

    mx25lHeaderDefFile = mx25lComponent.createFileSymbol("DRV_MX25L_HEADER_DEF", None)
    mx25lHeaderDefFile.setSourcePath("driver/sqi_flash/mx25l/templates/drv_mx25l_definitions.h.ftl")
    mx25lHeaderDefFile.setOutputName("drv_mx25l_definitions.h")
    mx25lHeaderDefFile.setDestPath("driver/mx25l/")
    mx25lHeaderDefFile.setProjectPath("config/" + configName + "/driver/mx25l/")
    mx25lHeaderDefFile.setType("HEADER")
    mx25lHeaderDefFile.setOverwrite(True)
    mx25lHeaderDefFile.setMarkup(True)

    mx25lSourceFile = mx25lComponent.createFileSymbol("DRV_MX25L_SOURCE", None)
    mx25lSourceFile.setSourcePath("driver/sqi_flash/mx25l/src/drv_mx25l.c")
    mx25lSourceFile.setOutputName("drv_mx25l.c")
    mx25lSourceFile.setDestPath("driver/mx25l/src/")
    mx25lSourceFile.setProjectPath("config/" + configName + "/driver/mx25l/")
    mx25lSourceFile.setType("SOURCE")
    mx25lSourceFile.setOverwrite(True)

    # System Template Files
    mx25lSystemDefFile = mx25lComponent.createFileSymbol("DRV_MX25L_SYS_DEF", None)
    mx25lSystemDefFile.setType("STRING")
    mx25lSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    mx25lSystemDefFile.setSourcePath("driver/sqi_flash/mx25l/templates/system/definitions.h.ftl")
    mx25lSystemDefFile.setMarkup(True)

    mx25lSystemDefObjFile = mx25lComponent.createFileSymbol("DRV_MX25L_SYS_DEF_OBJ", None)
    mx25lSystemDefObjFile.setType("STRING")
    mx25lSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    mx25lSystemDefObjFile.setSourcePath("driver/sqi_flash/mx25l/templates/system/definitions_objects.h.ftl")
    mx25lSystemDefObjFile.setMarkup(True)

    mx25lSystemConfigFile = mx25lComponent.createFileSymbol("DRV_MX25L_SYS_CFG", None)
    mx25lSystemConfigFile.setType("STRING")
    mx25lSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    mx25lSystemConfigFile.setSourcePath("driver/sqi_flash/mx25l/templates/system/configuration.h.ftl")
    mx25lSystemConfigFile.setMarkup(True)

    mx25lSystemInitDataFile = mx25lComponent.createFileSymbol("DRV_MX25L_SYS_INIT_DATA", None)
    mx25lSystemInitDataFile.setType("STRING")
    mx25lSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    mx25lSystemInitDataFile.setSourcePath("driver/sqi_flash/mx25l/templates/system/initialize_data.c.ftl")
    mx25lSystemInitDataFile.setMarkup(True)

    mx25lSystemInitFile = mx25lComponent.createFileSymbol("DRV_MX25L_SYS_INIT", None)
    mx25lSystemInitFile.setType("STRING")
    mx25lSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    mx25lSystemInitFile.setSourcePath("driver/sqi_flash/mx25l/templates/system/initialize.c.ftl")
    mx25lSystemInitFile.setMarkup(True)

def onAttachmentConnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_mx25l_SQI_dependency" :
        plibUsed = localComponent.getSymbolByID("DRV_MX25L_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(remoteID.upper(), 2)

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_mx25l_SQI_dependency" :
        plibUsed = localComponent.getSymbolByID("DRV_MX25L_PLIB")
        plibUsed.clearValue()
