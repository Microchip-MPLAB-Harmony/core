# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2023 Microchip Technology Inc. and its subsidiaries.
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

drv_w25_mcc_helpkeyword = "mcc_h3_drv_w25_configurations"

protocolUsed    = ["SQI"]

def w25SetMemoryDependency(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def w25HeaderFileGen(symbol, event):
    component = symbol.getComponent()

    protocolUsed = component.getSymbolByID("DRV_W25_PROTOCOL").getValue()
    plib_used = component.getSymbolByID("DRV_W25_PLIB").getValue()

    if (protocolUsed == "SQI"):
        if ("QMSPI" in plib_used):
            symbol.setSourcePath("driver/sqi_flash/w25/templates/drv_w25_qmspi_definitions.h.ftl")

    symbol.setEnabled(True)

def w25SourceFileGen(symbol, event):
    component = symbol.getComponent()

    coreArch = Database.getSymbolValue("core", "CoreArchitecture")
    protocolUsed = component.getSymbolByID("DRV_W25_PROTOCOL").getValue()
    plib_used = component.getSymbolByID("DRV_W25_PLIB").getValue()

    if (protocolUsed == "SQI"):
        if ("QMSPI" in plib_used):
            symbol.setSourcePath("driver/sqi_flash/w25/src/drv_w25_qmspi.c.ftl")
            symbol.setMarkup(True)

    symbol.setEnabled(True)

def instantiateComponent(w25Component):
    Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

    w25PLIB = w25Component.createStringSymbol("DRV_W25_PLIB", None)
    w25PLIB.setLabel("PLIB Used")
    w25PLIB.setHelp(drv_w25_mcc_helpkeyword)
    w25PLIB.setReadOnly(True)

    w25Protocol = w25Component.createComboSymbol("DRV_W25_PROTOCOL", None, protocolUsed)
    w25Protocol.setLabel("W25 Protocol Used")
    w25Protocol.setDefaultValue("SQI")

    w25NumClients = w25Component.createIntegerSymbol("DRV_W25_NUM_CLIENTS", None)
    w25NumClients.setLabel("Number of Clients")
    w25NumClients.setHelp(drv_w25_mcc_helpkeyword)
    w25NumClients.setReadOnly(True)
    w25NumClients.setMin(1)
    w25NumClients.setMax(64)
    w25NumClients.setDefaultValue(1)

    ##### Do not modify below symbol names as they are used by Memory Driver #####
    w25MemoryDriver = w25Component.createBooleanSymbol("DRV_MEMORY_CONNECTED", None)
    w25MemoryDriver.setLabel("Memory Driver Connected")
    w25MemoryDriver.setVisible(False)
    w25MemoryDriver.setDefaultValue(False)

    w25MemoryStartAddr = w25Component.createHexSymbol("START_ADDRESS", None)
    w25MemoryStartAddr.setLabel("W25 Start Address")
    w25MemoryStartAddr.setHelp(drv_w25_mcc_helpkeyword)
    w25MemoryStartAddr.setVisible(True)
    w25MemoryStartAddr.setDefaultValue(0x0000000)

    w25MemoryInterruptEnable = w25Component.createBooleanSymbol("INTERRUPT_ENABLE", None)
    w25MemoryInterruptEnable.setLabel("W25 Interrupt Enable")
    w25MemoryInterruptEnable.setVisible(False)
    w25MemoryInterruptEnable.setDefaultValue(False)
    w25MemoryInterruptEnable.setReadOnly(True)

    w25MemoryEraseEnable = w25Component.createBooleanSymbol("ERASE_ENABLE", None)
    w25MemoryEraseEnable.setLabel("W25 Erase Enable")
    w25MemoryEraseEnable.setVisible(False)
    w25MemoryEraseEnable.setDefaultValue(True)
    w25MemoryEraseEnable.setReadOnly(True)

    w25MemoryEraseBufferSize = w25Component.createIntegerSymbol("ERASE_BUFFER_SIZE", None)
    w25MemoryEraseBufferSize.setLabel("W25 Erase Buffer Size")
    w25MemoryEraseBufferSize.setHelp(drv_w25_mcc_helpkeyword)
    w25MemoryEraseBufferSize.setVisible(False)
    w25MemoryEraseBufferSize.setDefaultValue(4096)
    w25MemoryEraseBufferSize.setDependencies(w25SetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    w25MemoryEraseComment = w25Component.createCommentSymbol("ERASE_COMMENT", None)
    w25MemoryEraseComment.setVisible(False)
    w25MemoryEraseComment.setLabel("*** Should be equal to Sector Erase Size ***")
    w25MemoryEraseComment.setDependencies(w25SetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    w25HeaderFile = w25Component.createFileSymbol("DRV_W25_HEADER", None)
    w25HeaderFile.setSourcePath("driver/sqi_flash/w25/drv_w25.h")
    w25HeaderFile.setOutputName("drv_w25.h")
    w25HeaderFile.setDestPath("driver/w25/")
    w25HeaderFile.setProjectPath("config/" + configName + "/driver/w25/")
    w25HeaderFile.setType("HEADER")
    w25HeaderFile.setOverwrite(True)

    w25HeaderLocalFile = w25Component.createFileSymbol("DRV_W25_HEADER_LOCAL", None)
    w25HeaderLocalFile.setSourcePath("driver/sqi_flash/w25/src/drv_w25_local.h.ftl")
    w25HeaderLocalFile.setOutputName("drv_w25_local.h")
    w25HeaderLocalFile.setDestPath("driver/w25/src")
    w25HeaderLocalFile.setProjectPath("config/" + configName + "/driver/w25/")
    w25HeaderLocalFile.setType("HEADER")
    w25HeaderLocalFile.setOverwrite(True)
    w25HeaderLocalFile.setMarkup(True)
    w25HeaderLocalFile.setOverwrite(True)

    w25HeaderDefFile = w25Component.createFileSymbol("DRV_W25_HEADER_DEF", None)
    w25HeaderDefFile.setOutputName("drv_w25_definitions.h")
    w25HeaderDefFile.setDestPath("driver/w25/")
    w25HeaderDefFile.setProjectPath("config/" + configName + "/driver/w25/")
    w25HeaderDefFile.setType("HEADER")
    w25HeaderDefFile.setOverwrite(True)
    w25HeaderDefFile.setMarkup(True)
    w25HeaderDefFile.setDependencies(w25HeaderFileGen, ["DRV_W25_PROTOCOL"])

    w25SourceFile = w25Component.createFileSymbol("DRV_W25_SOURCE", None)
    w25SourceFile.setOutputName("drv_w25.c")
    w25SourceFile.setDestPath("driver/w25/src/")
    w25SourceFile.setProjectPath("config/" + configName + "/driver/w25/")
    w25SourceFile.setType("SOURCE")
    w25SourceFile.setOverwrite(True)
    w25SourceFile.setDependencies(w25SourceFileGen, ["DRV_W25_PROTOCOL"])

    # System Template Files
    w25SystemDefFile = w25Component.createFileSymbol("DRV_W25_SYS_DEF", None)
    w25SystemDefFile.setType("STRING")
    w25SystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    w25SystemDefFile.setSourcePath("driver/sqi_flash/w25/templates/system/definitions.h.ftl")
    w25SystemDefFile.setMarkup(True)

    w25SystemDefObjFile = w25Component.createFileSymbol("DRV_W25_SYS_DEF_OBJ", None)
    w25SystemDefObjFile.setType("STRING")
    w25SystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    w25SystemDefObjFile.setSourcePath("driver/sqi_flash/w25/templates/system/definitions_objects.h.ftl")
    w25SystemDefObjFile.setMarkup(True)

    w25SystemConfigFile = w25Component.createFileSymbol("DRV_W25_SYS_CFG", None)
    w25SystemConfigFile.setType("STRING")
    w25SystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    w25SystemConfigFile.setSourcePath("driver/sqi_flash/w25/templates/system/configuration.h.ftl")
    w25SystemConfigFile.setMarkup(True)

    w25SystemInitDataFile = w25Component.createFileSymbol("DRV_W25_SYS_INIT_DATA", None)
    w25SystemInitDataFile.setType("STRING")
    w25SystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    w25SystemInitDataFile.setSourcePath("driver/sqi_flash/w25/templates/system/initialize_data.c.ftl")
    w25SystemInitDataFile.setMarkup(True)

    w25SystemInitFile = w25Component.createFileSymbol("DRV_W25_SYS_INIT", None)
    w25SystemInitFile.setType("STRING")
    w25SystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    w25SystemInitFile.setSourcePath("driver/sqi_flash/w25/templates/system/initialize.c.ftl")
    w25SystemInitFile.setMarkup(True)

def onAttachmentConnected(source, target):
    global isDMAPresent
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    sqiCapabilityId = "drv_w25_SQI_dependency"
    w25PlibID = remoteID.upper()

    if connectID == sqiCapabilityId:
        localComponent.getSymbolByID("DRV_W25_PLIB").setValue(w25PlibID)
        localComponent.getSymbolByID("DRV_W25_PROTOCOL").setValue("SQI")
        remoteComponent.getSymbolByID("QMSPI_INTERRUPT_MODE").setReadOnly(True)
        remoteComponent.getSymbolByID("QMSPI_INTERRUPT_MODE").setValue(False)

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    sqiCapabilityId = "drv_w25_SQI_dependency"

    if connectID == sqiCapabilityId:
        localComponent.getSymbolByID("DRV_W25_PLIB").clearValue()
        localComponent.getSymbolByID("DRV_W25_PROTOCOL").clearValue()
        remoteComponent.getSymbolByID("QMSPI_INTERRUPT_MODE").setReadOnly(False)

def destroyComponent(w25Component):
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})
