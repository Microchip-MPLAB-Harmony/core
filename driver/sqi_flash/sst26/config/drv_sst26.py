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

ChipSelect      = ["Chip Select 0", "Chip Select 1"]
protocolUsed    = ["SQI", "SPI"]

global sort_alphanumeric

def sort_alphanumeric(l):
    import re
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ]
    return sorted(l, key = alphanum_key)

def sst26SetMemoryDependency(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def sst26HeaderFileGen(symbol, event):
    component = symbol.getComponent()

    protocolUsed = component.getSymbolByID("DRV_SST26_PROTOCOL").getValue()
    plib_used = event["value"]

    if (plib_used == ""):
        symbol.setEnabled(False)
    else:
        if (protocolUsed == "SQI"):
            if ("QSPI" in plib_used):
                symbol.setSourcePath("driver/sqi_flash/sst26/templates/drv_sst26_qspi_definitions.h.ftl")
            elif ("SQI" in plib_used):
                symbol.setSourcePath("driver/sqi_flash/sst26/templates/drv_sst26_sqi_definitions.h.ftl")
        elif (protocolUsed == "SPI"):
            symbol.setSourcePath("driver/sqi_flash/sst26/templates/drv_sst26_qspi_spi_definitions.h.ftl")

        symbol.setEnabled(True)

def sst26SourceFileGen(symbol, event):
    component = symbol.getComponent()

    protocolUsed = component.getSymbolByID("DRV_SST26_PROTOCOL").getValue()
    plib_used = event["value"]

    if (plib_used == ""):
        symbol.setEnabled(False)
    else:
        if (protocolUsed == "SQI"):
            if ("QSPI" in plib_used):
                symbol.setSourcePath("driver/sqi_flash/sst26/src/drv_sst26_qspi.c")
                symbol.setMarkup(False)
            elif ("SQI" in plib_used):
                symbol.setSourcePath("driver/sqi_flash/sst26/src/drv_sst26_sqi.c.ftl")
                symbol.setMarkup(True)
        elif (protocolUsed == "SPI"):
            symbol.setSourcePath("driver/sqi_flash/sst26/src/drv_sst26_qspi_spi.c")
            symbol.setMarkup(False)

        symbol.setEnabled(True)

def setBuffDescriptor(symbol, event):
    if ("SQI" in event["value"]):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def instantiateComponent(sst26Component):

    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
        Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True)

    # Enable "Generate Harmony System Service Common Files" option in MHC
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True)

    sst26PLIB = sst26Component.createStringSymbol("DRV_SST26_PLIB", None)
    sst26PLIB.setLabel("PLIB Used")
    sst26PLIB.setReadOnly(True)

    sst26Protocol = sst26Component.createComboSymbol("DRV_SST26_PROTOCOL", None, protocolUsed)
    sst26Protocol.setLabel("SST26 Protocol Used")
    sst26Protocol.setVisible(False)
    sst26Protocol.setDefaultValue("SQI")

    sst26NumClients = sst26Component.createIntegerSymbol("DRV_SST26_NUM_CLIENTS", None)
    sst26NumClients.setLabel("Number of Clients")
    sst26NumClients.setReadOnly(True)
    sst26NumClients.setMin(1)
    sst26NumClients.setMax(64)
    sst26NumClients.setDefaultValue(1)

    sst26NumBufDesc = sst26Component.createIntegerSymbol("DRV_SST26_NUM_BUFFER_DESC", None)
    sst26NumBufDesc.setLabel("Number of Buffer Descriptors")
    sst26NumBufDesc.setMin(1)
    sst26NumBufDesc.setDefaultValue(10)
    sst26NumBufDesc.setVisible(False)
    sst26NumBufDesc.setDependencies(setBuffDescriptor, ["DRV_SST26_PLIB"])

    sst26ChipSelect = sst26Component.createComboSymbol("CHIP_SELECT", None, ChipSelect)
    sst26ChipSelect.setLabel("SQI Chip Select")
    sst26ChipSelect.setVisible(False)
    sst26ChipSelect.setDefaultValue("Chip Select 1")

    sst26ChipSelectComment = sst26Component.createCommentSymbol("CHIP_SELECT_COMMENT", None)
    sst26ChipSelectComment.setVisible(False)
    sst26ChipSelectComment.setLabel("*** Configure Chip Select in SQI PLIB Configurations ***")

    sst26spiChipSelectPin = sst26Component.createKeyValueSetSymbol("SPI_CHIP_SELECT_PIN", None)
    sst26spiChipSelectPin.setLabel("Chip Select Pin")
    sst26spiChipSelectPin.setOutputMode("Key")
    sst26spiChipSelectPin.setDisplayMode("Description")
    sst26spiChipSelectPin.setVisible(False)

    availablePinDictionary = {}

    # Send message to core to get available pins
    availablePinDictionary = Database.sendMessage("core", "PIN_LIST", availablePinDictionary)

    for pad in sort_alphanumeric(availablePinDictionary.values()):
        key = "SYS_PORT_PIN_" + pad
        value = list(availablePinDictionary.keys())[list(availablePinDictionary.values()).index(pad)]
        description = pad
        sst26spiChipSelectPin.addKey(key, value, description)

    sst26spiChipSelectPinComment = sst26Component.createCommentSymbol("SPI_CHIP_SELECT_PIN_COMMENT", None)
    sst26spiChipSelectPinComment.setLabel("***Above selected pin must be configured as GPIO Output in Pin Manager***")
    sst26spiChipSelectPinComment.setVisible(False)

    ##### Do not modify below symbol names as they are used by Memory Driver #####
    sst26MemoryDriver = sst26Component.createBooleanSymbol("DRV_MEMORY_CONNECTED", None)
    sst26MemoryDriver.setLabel("Memory Driver Connected")
    sst26MemoryDriver.setVisible(False)
    sst26MemoryDriver.setDefaultValue(False)

    sst26MemoryStartAddr = sst26Component.createHexSymbol("START_ADDRESS", None)
    sst26MemoryStartAddr.setLabel("SST26 Start Address")
    sst26MemoryStartAddr.setVisible(True)
    sst26MemoryStartAddr.setDefaultValue(0x0000000)

    sst26MemoryInterruptEnable = sst26Component.createBooleanSymbol("INTERRUPT_ENABLE", None)
    sst26MemoryInterruptEnable.setLabel("SST26 Interrupt Enable")
    sst26MemoryInterruptEnable.setVisible(False)
    sst26MemoryInterruptEnable.setDefaultValue(False)
    sst26MemoryInterruptEnable.setReadOnly(True)

    sst26MemoryEraseEnable = sst26Component.createBooleanSymbol("ERASE_ENABLE", None)
    sst26MemoryEraseEnable.setLabel("SST26 Erase Enable")
    sst26MemoryEraseEnable.setVisible(False)
    sst26MemoryEraseEnable.setDefaultValue(True)
    sst26MemoryEraseEnable.setReadOnly(True)

    sst26MemoryEraseBufferSize = sst26Component.createIntegerSymbol("ERASE_BUFFER_SIZE", None)
    sst26MemoryEraseBufferSize.setLabel("SST26 Erase Buffer Size")
    sst26MemoryEraseBufferSize.setVisible(False)
    sst26MemoryEraseBufferSize.setDefaultValue(4096)
    sst26MemoryEraseBufferSize.setDependencies(sst26SetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    sst26MemoryEraseComment = sst26Component.createCommentSymbol("ERASE_COMMENT", None)
    sst26MemoryEraseComment.setVisible(False)
    sst26MemoryEraseComment.setLabel("*** Should be equal to Sector Erase Size ***")
    sst26MemoryEraseComment.setDependencies(sst26SetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    sst26HeaderFile = sst26Component.createFileSymbol("DRV_SST26_HEADER", None)
    sst26HeaderFile.setSourcePath("driver/sqi_flash/sst26/drv_sst26.h")
    sst26HeaderFile.setOutputName("drv_sst26.h")
    sst26HeaderFile.setDestPath("driver/sst26/")
    sst26HeaderFile.setProjectPath("config/" + configName + "/driver/sst26/")
    sst26HeaderFile.setType("HEADER")
    sst26HeaderFile.setOverwrite(True)

    sst26HeaderLocalFile = sst26Component.createFileSymbol("DRV_SST26_HEADER_LOCAL", None)
    sst26HeaderLocalFile.setSourcePath("driver/sqi_flash/sst26/src/drv_sst26_local.h.ftl")
    sst26HeaderLocalFile.setOutputName("drv_sst26_local.h")
    sst26HeaderLocalFile.setDestPath("driver/sst26/src")
    sst26HeaderLocalFile.setProjectPath("config/" + configName + "/driver/sst26/")
    sst26HeaderLocalFile.setType("HEADER")
    sst26HeaderLocalFile.setOverwrite(True)
    sst26HeaderLocalFile.setMarkup(True)
    sst26HeaderLocalFile.setOverwrite(True)

    sst26HeaderDefFile = sst26Component.createFileSymbol("DRV_SST26_HEADER_DEF", None)
    sst26HeaderDefFile.setOutputName("drv_sst26_definitions.h")
    sst26HeaderDefFile.setDestPath("driver/sst26/")
    sst26HeaderDefFile.setProjectPath("config/" + configName + "/driver/sst26/")
    sst26HeaderDefFile.setType("HEADER")
    sst26HeaderDefFile.setOverwrite(True)
    sst26HeaderDefFile.setMarkup(True)
    sst26HeaderDefFile.setDependencies(sst26HeaderFileGen, ["DRV_SST26_PLIB"])

    sst26SourceFile = sst26Component.createFileSymbol("DRV_SST26_SOURCE", None)
    sst26SourceFile.setOutputName("drv_sst26.c")
    sst26SourceFile.setDestPath("driver/sst26/src/")
    sst26SourceFile.setProjectPath("config/" + configName + "/driver/sst26/")
    sst26SourceFile.setType("SOURCE")
    sst26SourceFile.setOverwrite(True)
    sst26SourceFile.setDependencies(sst26SourceFileGen, ["DRV_SST26_PLIB"])

    # System Template Files
    sst26SystemDefFile = sst26Component.createFileSymbol("DRV_SST26_SYS_DEF", None)
    sst26SystemDefFile.setType("STRING")
    sst26SystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sst26SystemDefFile.setSourcePath("driver/sqi_flash/sst26/templates/system/definitions.h.ftl")
    sst26SystemDefFile.setMarkup(True)

    sst26SystemDefObjFile = sst26Component.createFileSymbol("DRV_SST26_SYS_DEF_OBJ", None)
    sst26SystemDefObjFile.setType("STRING")
    sst26SystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    sst26SystemDefObjFile.setSourcePath("driver/sqi_flash/sst26/templates/system/definitions_objects.h.ftl")
    sst26SystemDefObjFile.setMarkup(True)

    sst26SystemConfigFile = sst26Component.createFileSymbol("DRV_SST26_SYS_CFG", None)
    sst26SystemConfigFile.setType("STRING")
    sst26SystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    sst26SystemConfigFile.setSourcePath("driver/sqi_flash/sst26/templates/system/configuration.h.ftl")
    sst26SystemConfigFile.setMarkup(True)

    sst26SystemInitDataFile = sst26Component.createFileSymbol("DRV_SST26_SYS_INIT_DATA", None)
    sst26SystemInitDataFile.setType("STRING")
    sst26SystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    sst26SystemInitDataFile.setSourcePath("driver/sqi_flash/sst26/templates/system/initialize_data.c.ftl")
    sst26SystemInitDataFile.setMarkup(True)

    sst26SystemInitFile = sst26Component.createFileSymbol("DRV_SST26_SYS_INIT", None)
    sst26SystemInitFile.setType("STRING")
    sst26SystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    sst26SystemInitFile.setSourcePath("driver/sqi_flash/sst26/templates/system/initialize.c.ftl")
    sst26SystemInitFile.setMarkup(True)

def onAttachmentConnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    sqiCapabilityId = "drv_sst26_SQI_dependency"
    spiCapabilityId = "drv_sst26_SPI_dependency"

    sst26PlibID = remoteID.upper()

    if connectID == sqiCapabilityId :
        localComponent.getSymbolByID("DRV_SST26_PROTOCOL").setValue("SQI")

        localComponent.getSymbolByID("DRV_SST26_PLIB").setValue(sst26PlibID)

        if ("sqi" in remoteID):
            remoteComponent.getSymbolByID("SQI_FLASH_STATUS_CHECK").setReadOnly(True)
            localComponent.getSymbolByID("CHIP_SELECT").setVisible(True)
            localComponent.getSymbolByID("CHIP_SELECT_COMMENT").setVisible(True)

        localComponent.setCapabilityEnabled(spiCapabilityId, False)

    if connectID == spiCapabilityId :
        localComponent.getSymbolByID("DRV_SST26_PROTOCOL").setValue("SPI")

        localComponent.getSymbolByID("DRV_SST26_PLIB").setValue(sst26PlibID)

        Database.setSymbolValue(sst26PlibID, "SPI_DRIVER_CONTROLLED", True)

        localComponent.getSymbolByID("INTERRUPT_ENABLE").setValue(True)

        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN").setVisible(True)
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN_COMMENT").setVisible(True)

        localComponent.setCapabilityEnabled(sqiCapabilityId, False)

        # Enable "Enable System Ports" option in MHC
        if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS") == False):
            Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS", True)

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    sqiCapabilityId = "drv_sst26_SQI_dependency"
    spiCapabilityId = "drv_sst26_SPI_dependency"

    sst26PlibID = remoteID.upper()

    if connectID == "drv_sst26_SQI_dependency" :
        if ("sqi" in remoteID):
            remoteComponent.getSymbolByID("SQI_FLASH_STATUS_CHECK").setReadOnly(False)
            localComponent.getSymbolByID("CHIP_SELECT").setVisible(False)
            localComponent.getSymbolByID("CHIP_SELECT_COMMENT").setVisible(False)

        localComponent.getSymbolByID("DRV_SST26_PLIB").clearValue()

        localComponent.setCapabilityEnabled(spiCapabilityId, True)

    if connectID == "drv_sst26_SPI_dependency" :
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN").setVisible(False)
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN_COMMENT").setVisible(False)

        localComponent.getSymbolByID("DRV_SST26_PLIB").clearValue()

        Database.setSymbolValue(sst26PlibID, "SPI_DRIVER_CONTROLLED", False)

        localComponent.getSymbolByID("INTERRUPT_ENABLE").setValue(False)

        localComponent.setCapabilityEnabled(sqiCapabilityId, True)

