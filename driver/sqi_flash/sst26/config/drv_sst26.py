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

drv_sst26_mcc_helpkeyword = "mcc_h3_drv_sst26_configurations"

ChipSelect      = ["Chip Select 0", "Chip Select 1"]
protocolUsed    = ["SQI", "SPI"]

global sort_alphanumeric

def handleMessage(messageID, args):
    result_dict = {}

    return result_dict

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
    plib_used = component.getSymbolByID("DRV_SST26_PLIB").getValue()

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

    coreArch = Database.getSymbolValue("core", "CoreArchitecture")
    protocolUsed = component.getSymbolByID("DRV_SST26_PROTOCOL").getValue()
    plib_used = component.getSymbolByID("DRV_SST26_PLIB").getValue()

    if (protocolUsed == "SQI"):
        if ("QSPI" in plib_used):
            symbol.setSourcePath("driver/sqi_flash/sst26/src/drv_sst26_qspi.c.ftl")
            symbol.setMarkup(True)
        elif ("SQI" in plib_used):
            if "CORTEX" in coreArch:
                symbol.setSourcePath("driver/sqi_flash/sst26/src/drv_sst26_sqi_arm.c.ftl")
            else:
                symbol.setSourcePath("driver/sqi_flash/sst26/src/drv_sst26_sqi_pic.c.ftl")
            symbol.setMarkup(True)
    elif (protocolUsed == "SPI"):
        symbol.setSourcePath("driver/sqi_flash/sst26/src/drv_sst26_qspi_spi.c.ftl")
        symbol.setMarkup(True)

    symbol.setEnabled(True)

def sst26InterfaceFileGen(symbol, event):
    global sst26InterfaceType

    if symbol.getID() == "DRV_SST26_SPI_INTERFACE_SOURCE":
        symbol.setEnabled(event["value"] == "SPI")
    if symbol.getID() == "DRV_SST26_SPI_INTERFACE_HEADER":
        symbol.setEnabled(event["value"] == "SPI")

def setBuffDescriptor(symbol, event):
    if ("SQI" in event["value"]):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def setLaneMode(symbol, event):
    component = symbol.getComponent()

    if (event["id"] == "DRV_SST26_PLIB"):
        if ("SQI" in event["value"]):
            symbol.setVisible(True)
        else:
            symbol.setVisible(False)
    elif (event["id"] == "LANE_MODE"):
        plibID = component.getSymbolByID("DRV_SST26_PLIB").getValue().lower()

        Database.sendMessage(plibID, "SET_SQI_LANE_MODE", {"laneMode":event["value"], "isReadOnly":True})

def requestAndAssignDMAChannel(symbol, event):

    component = symbol.getComponent()

    spiPeripheral = component.getSymbolByID("DRV_SST26_PLIB").getValue()

    if symbol.getID() == "DRV_SST26_TX_DMA_CHANNEL":
        dmaChannelID = "DMA_CH_FOR_" + str(spiPeripheral) + "_Transmit"
        dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Transmit"
    else:
        dmaChannelID = "DMA_CH_FOR_" + str(spiPeripheral) + "_Receive"
        dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Receive"

    # Control visibility
    symbol.setVisible(event["value"])

    dummyDict = {}

    if event["value"] == False:
        dummyDict = Database.sendMessage("core", "DMA_CHANNEL_DISABLE", {"dma_channel":dmaRequestID})
    else:
        dummyDict = Database.sendMessage("core", "DMA_CHANNEL_ENABLE", {"dma_channel":dmaRequestID})

    # Get the allocated channel and assign it
    channel = Database.getSymbolValue("core", dmaChannelID)
    if channel != None:
        symbol.setValue(channel)

    # Enable "System DMA" option in MHC
    if Database.getSymbolValue("core", "DMA_ENABLE") != None:
        Database.sendMessage("HarmonyCore", "ENABLE_SYS_DMA", {"isEnabled":event["value"]})

def requestDMAComment(symbol, event):
    global sst26TXRXDMA

    if ((event["value"] == -2) and (sst26TXRXDMA.getValue() == True)):
        symbol.setVisible(True)
        event["symbol"].setVisible(False)
    else:
        symbol.setVisible(False)

def setPLIBOptionsVisibility(symbol, event):
    global isDMAPresent

    if (symbol.getID() == "DRV_SST26_TX_RX_DMA"):
        if (isDMAPresent == True):
            symbol.setVisible(event["value"] == "SPI_PLIB")
    else:
        symbol.setVisible(event["value"] != "SPI_DRV")

def setDriverOptionsVisibility(symbol, event):
    symbol.setVisible(event["value"] == "SPI_DRV")

def instantiateComponent(sst26Component):
    global isDMAPresent
    global sst26TXRXDMA
    global sst26InterfaceType

    res = Database.activateComponents(["HarmonyCore"])

    if Database.getSymbolValue("core", "DMA_ENABLE") == None:
        isDMAPresent = False
    else:
        isDMAPresent = True

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

    sst26PLIB = sst26Component.createStringSymbol("DRV_SST26_PLIB", None)
    sst26PLIB.setLabel("PLIB Used")
    sst26PLIB.setHelp(drv_sst26_mcc_helpkeyword)
    sst26PLIB.setReadOnly(True)
    sst26PLIB.setDependencies(setPLIBOptionsVisibility, ["DRV_SST26_INTERFACE_TYPE"])

    sst26Protocol = sst26Component.createComboSymbol("DRV_SST26_PROTOCOL", None, protocolUsed)
    sst26Protocol.setLabel("SST26 Protocol Used")
    #sst26Protocol.setVisible(False)
    sst26Protocol.setDefaultValue("SQI")

    sst26NumClients = sst26Component.createIntegerSymbol("DRV_SST26_NUM_CLIENTS", None)
    sst26NumClients.setLabel("Number of Clients")
    sst26NumClients.setHelp(drv_sst26_mcc_helpkeyword)
    sst26NumClients.setReadOnly(True)
    sst26NumClients.setMin(1)
    sst26NumClients.setMax(64)
    sst26NumClients.setDefaultValue(1)

    sst26NumBufDesc = sst26Component.createIntegerSymbol("DRV_SST26_NUM_BUFFER_DESC", None)
    sst26NumBufDesc.setLabel("Number of Buffer Descriptors")
    sst26NumBufDesc.setHelp(drv_sst26_mcc_helpkeyword)
    sst26NumBufDesc.setMin(1)
    sst26NumBufDesc.setDefaultValue(10)
    sst26NumBufDesc.setVisible(False)
    sst26NumBufDesc.setDependencies(setBuffDescriptor, ["DRV_SST26_PLIB"])

    sst26SqiLaneMode = sst26Component.createComboSymbol("LANE_MODE", None, ["SINGLE", "QUAD"])
    sst26SqiLaneMode.setLabel("SQI Lane Mode")
    sst26SqiLaneMode.setHelp(drv_sst26_mcc_helpkeyword)
    sst26SqiLaneMode.setDefaultValue("QUAD")
    sst26SqiLaneMode.setVisible(False)
    sst26SqiLaneMode.setDependencies(setLaneMode, ["DRV_SST26_PLIB", "LANE_MODE"])

    sst26ChipSelect = sst26Component.createComboSymbol("CHIP_SELECT", None, ChipSelect)
    sst26ChipSelect.setLabel("SQI Chip Select")
    sst26ChipSelect.setHelp(drv_sst26_mcc_helpkeyword)
    sst26ChipSelect.setVisible(False)
    sst26ChipSelect.setDefaultValue("Chip Select 1")

    sst26ChipSelectComment = sst26Component.createCommentSymbol("CHIP_SELECT_COMMENT", None)
    sst26ChipSelectComment.setVisible(False)
    sst26ChipSelectComment.setLabel("*** Configure Chip Select in SQI PLIB Configurations ***")

    sst26spiChipSelectPin = sst26Component.createKeyValueSetSymbol("SPI_CHIP_SELECT_PIN", None)
    sst26spiChipSelectPin.setLabel("Chip Select Pin")
    sst26spiChipSelectPin.setHelp(drv_sst26_mcc_helpkeyword)
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
    sst26MemoryStartAddr.setHelp(drv_sst26_mcc_helpkeyword)
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
    sst26MemoryEraseBufferSize.setHelp(drv_sst26_mcc_helpkeyword)
    sst26MemoryEraseBufferSize.setVisible(False)
    sst26MemoryEraseBufferSize.setDefaultValue(4096)
    sst26MemoryEraseBufferSize.setDependencies(sst26SetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    sst26MemoryEraseComment = sst26Component.createCommentSymbol("ERASE_COMMENT", None)
    sst26MemoryEraseComment.setVisible(False)
    sst26MemoryEraseComment.setLabel("*** Should be equal to Sector Erase Size ***")
    sst26MemoryEraseComment.setDependencies(sst26SetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    sst26InterfaceType = sst26Component.createStringSymbol("DRV_SST26_INTERFACE_TYPE", None)
    sst26InterfaceType.setLabel("SST26 Interface Type")
    sst26InterfaceType.setVisible(False)
    sst26InterfaceType.setDefaultValue("")

    sst26TXRXDMA = sst26Component.createBooleanSymbol("DRV_SST26_TX_RX_DMA", None)
    sst26TXRXDMA.setLabel("Use DMA for Transmit and Receive ?")
    sst26TXRXDMA.setVisible(isDMAPresent and sst26InterfaceType.getValue() == "SPI_PLIB")
    sst26TXRXDMA.setDependencies(setPLIBOptionsVisibility, ["DRV_SST26_INTERFACE_TYPE"])

    sst26SymDrvInstance = sst26Component.createStringSymbol("DRV_SST26_SPI_DRIVER_INSTANCE", None)
    sst26SymDrvInstance.setLabel("SPI Driver Instance Used")
    sst26SymDrvInstance.setReadOnly(True)
    sst26SymDrvInstance.setDefaultValue("")
    sst26SymDrvInstance.setVisible(False)
    sst26SymDrvInstance.setDependencies(setDriverOptionsVisibility, ["DRV_SST26_INTERFACE_TYPE"])

    sst26TXDMAChannel = sst26Component.createIntegerSymbol("DRV_SST26_TX_DMA_CHANNEL", None)
    sst26TXDMAChannel.setLabel("DMA Channel For Transmit")
    sst26TXDMAChannel.setDefaultValue(0)
    sst26TXDMAChannel.setVisible(False)
    sst26TXDMAChannel.setReadOnly(True)
    sst26TXDMAChannel.setDependencies(requestAndAssignDMAChannel, ["DRV_SST26_TX_RX_DMA"])

    sst26TXDMAChannelComment = sst26Component.createCommentSymbol("DRV_SST26_TX_DMA_CH_COMMENT", None)
    sst26TXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Transmit. Check DMA manager. !!!")
    sst26TXDMAChannelComment.setVisible(False)
    sst26TXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_SST26_TX_DMA_CHANNEL"])

    sst26RXDMAChannel = sst26Component.createIntegerSymbol("DRV_SST26_RX_DMA_CHANNEL", None)
    sst26RXDMAChannel.setLabel("DMA Channel For Receive")
    sst26RXDMAChannel.setDefaultValue(1)
    sst26RXDMAChannel.setVisible(False)
    sst26RXDMAChannel.setReadOnly(True)
    sst26RXDMAChannel.setDependencies(requestAndAssignDMAChannel, ["DRV_SST26_TX_RX_DMA"])

    sst26RXDMAChannelComment = sst26Component.createCommentSymbol("DRV_SST26_RX_DMA_CH_COMMENT", None)
    sst26RXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Receive. Check DMA manager. !!!")
    sst26RXDMAChannelComment.setVisible(False)
    sst26RXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_SST26_RX_DMA_CHANNEL"])

    sst26DependencyDMAComment = sst26Component.createCommentSymbol("DRV_SST26_DEPENDENCY_DMA_COMMENT", None)
    sst26DependencyDMAComment.setLabel("!!! Satisfy PLIB Dependency to Allocate DMA Channel !!!")
    sst26DependencyDMAComment.setVisible(False)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    sst26HeaderFile = sst26Component.createFileSymbol("DRV_SST26_HEADER", None)
    sst26HeaderFile.setSourcePath("driver/sqi_flash/sst26/drv_sst26.h.ftl")
    sst26HeaderFile.setOutputName("drv_sst26.h")
    sst26HeaderFile.setDestPath("driver/sst26/")
    sst26HeaderFile.setProjectPath("config/" + configName + "/driver/sst26/")
    sst26HeaderFile.setType("HEADER")
    sst26HeaderFile.setMarkup(True)
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
    sst26HeaderDefFile.setDependencies(sst26HeaderFileGen, ["DRV_SST26_PROTOCOL"])

    sst26SourceFile = sst26Component.createFileSymbol("DRV_SST26_SOURCE", None)
    sst26SourceFile.setOutputName("drv_sst26.c")
    sst26SourceFile.setDestPath("driver/sst26/src/")
    sst26SourceFile.setProjectPath("config/" + configName + "/driver/sst26/")
    sst26SourceFile.setType("SOURCE")
    sst26SourceFile.setOverwrite(True)
    sst26SourceFile.setDependencies(sst26SourceFileGen, ["DRV_SST26_PROTOCOL"])

    sst26PlibIntfSourceFile = sst26Component.createFileSymbol("DRV_SST26_SPI_INTERFACE_SOURCE", None)
    sst26PlibIntfSourceFile.setSourcePath("driver/sqi_flash/sst26/src/drv_sst26_spi_interface.c.ftl")
    sst26PlibIntfSourceFile.setOutputName("drv_sst26_spi_interface.c")
    sst26PlibIntfSourceFile.setDestPath("driver/sst26/src/")
    sst26PlibIntfSourceFile.setProjectPath("config/" + configName + "/driver/sst26/")
    sst26PlibIntfSourceFile.setType("SOURCE")
    sst26PlibIntfSourceFile.setOverwrite(True)
    sst26PlibIntfSourceFile.setMarkup(True)
    sst26PlibIntfSourceFile.setDependencies(sst26InterfaceFileGen, ["DRV_SST26_PROTOCOL"])

    sst26PlibIntfHeaderFile = sst26Component.createFileSymbol("DRV_SST26_SPI_INTERFACE_HEADER", None)
    sst26PlibIntfHeaderFile.setSourcePath("driver/sqi_flash/sst26/src/drv_sst26_spi_interface.h.ftl")
    sst26PlibIntfHeaderFile.setOutputName("drv_sst26_spi_interface.h")
    sst26PlibIntfHeaderFile.setDestPath("driver/sst26/src/")
    sst26PlibIntfHeaderFile.setProjectPath("config/" + configName + "/driver/sst26/")
    sst26PlibIntfHeaderFile.setType("HEADER")
    sst26PlibIntfHeaderFile.setOverwrite(True)
    sst26PlibIntfHeaderFile.setMarkup(True)
    sst26PlibIntfHeaderFile.setDependencies(sst26InterfaceFileGen, ["DRV_SST26_PROTOCOL"])

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
    global isDMAPresent
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    sqiCapabilityId = "drv_sst26_SQI_dependency"
    spiCapabilityId = "drv_sst26_SPI_dependency"
    spiDrvCapabilityId = "drv_sst26_DRV_SPI_dependency"

    sst26PlibID = remoteID.upper()

    if connectID == sqiCapabilityId :
        localComponent.getSymbolByID("DRV_SST26_PLIB").setValue(sst26PlibID)
        localComponent.getSymbolByID("DRV_SST26_PROTOCOL").setValue("SQI")
        localComponent.getSymbolByID("DRV_SST26_INTERFACE_TYPE").setValue("SQI_PLIB")

        if ("sqi" in remoteID):
            localComponent.getSymbolByID("CHIP_SELECT").setVisible(True)
            localComponent.getSymbolByID("CHIP_SELECT_COMMENT").setVisible(True)

            laneMode = localComponent.getSymbolByID("LANE_MODE").getValue()

            Database.sendMessage(sst26PlibID.lower(), "SET_SQI_FLASH_STATUS_CHECK", {"isReadOnly":True})
            Database.sendMessage(sst26PlibID.lower(), "SET_SQI_LANE_MODE", {"laneMode":laneMode, "isReadOnly":True})

        localComponent.setCapabilityEnabled(spiCapabilityId, False)
        localComponent.setCapabilityEnabled(spiDrvCapabilityId, False)


    if connectID == spiCapabilityId :

        localComponent.getSymbolByID("DRV_SST26_PLIB").setValue(sst26PlibID)
        localComponent.getSymbolByID("DRV_SST26_PROTOCOL").setValue("SPI")

        Database.setSymbolValue(sst26PlibID, "SPI_DRIVER_CONTROLLED", True)

        localComponent.getSymbolByID("INTERRUPT_ENABLE").setValue(True)

        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN").setVisible(True)
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN_COMMENT").setVisible(True)

        localComponent.setCapabilityEnabled(sqiCapabilityId, False)
        localComponent.setCapabilityEnabled(spiDrvCapabilityId, False)

        # Enable "Enable System Ports" option in MHC
        Database.sendMessage("HarmonyCore", "ENABLE_SYS_PORTS", {"isEnabled":True})

        localComponent.getSymbolByID("DRV_SST26_INTERFACE_TYPE").setValue("SPI_PLIB")
        localComponent.getSymbolByID("DRV_SST26_TX_RX_DMA").setReadOnly(False)

    if connectID == "drv_sst26_DRV_SPI_dependency":
        localComponent.getSymbolByID("DRV_SST26_PLIB").setValue("")
        localComponent.getSymbolByID("DRV_SST26_PROTOCOL").setValue("SPI")
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN").setVisible(True)
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN_COMMENT").setVisible(True)
        localComponent.setCapabilityEnabled(spiCapabilityId, False)
        localComponent.setCapabilityEnabled(sqiCapabilityId, False)
        localComponent.getSymbolByID("DRV_SST26_INTERFACE_TYPE").setValue("SPI_DRV")
        drvInstance = localComponent.getSymbolByID("DRV_SST26_SPI_DRIVER_INSTANCE")
        drvInstance.clearValue()
        index = Database.getSymbolValue(remoteID, "INDEX")
        drvInstance.setValue(str(index))

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    sqiCapabilityId = "drv_sst26_SQI_dependency"
    spiCapabilityId = "drv_sst26_SPI_dependency"
    spiDrvCapabilityId = "drv_sst26_DRV_SPI_dependency"

    sst26PlibID = remoteID.upper()

    if connectID == "drv_sst26_SQI_dependency" :
        if ("sqi" in remoteID):
            localComponent.getSymbolByID("CHIP_SELECT").setVisible(False)
            localComponent.getSymbolByID("CHIP_SELECT_COMMENT").setVisible(False)

            Database.sendMessage(sst26PlibID.lower(), "SET_SQI_FLASH_STATUS_CHECK", {"isReadOnly":False})
            Database.sendMessage(sst26PlibID.lower(), "SET_SQI_LANE_MODE", {"isReadOnly":False})

        localComponent.getSymbolByID("DRV_SST26_PLIB").clearValue()

        localComponent.setCapabilityEnabled(spiCapabilityId, True)
        localComponent.setCapabilityEnabled(spiDrvCapabilityId, True)
        localComponent.getSymbolByID("DRV_SST26_INTERFACE_TYPE").setValue("")

    if connectID == "drv_sst26_SPI_dependency" :
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN").setVisible(False)
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN_COMMENT").setVisible(False)

        Database.setSymbolValue(sst26PlibID, "SPI_DRIVER_CONTROLLED", False)

        localComponent.getSymbolByID("INTERRUPT_ENABLE").setValue(False)

        localComponent.setCapabilityEnabled(sqiCapabilityId, True)
        localComponent.setCapabilityEnabled(spiDrvCapabilityId, True)

        Database.sendMessage("HarmonyCore", "ENABLE_SYS_PORTS", {"isEnabled":False})
        localComponent.getSymbolByID("DRV_SST26_TX_RX_DMA").setReadOnly(True)
        localComponent.getSymbolByID("DRV_SST26_TX_RX_DMA").setValue(False)
        localComponent.getSymbolByID("DRV_SST26_PLIB").clearValue()
        localComponent.getSymbolByID("DRV_SST26_INTERFACE_TYPE").setValue("")

    if (connectID == "drv_sst26_DRV_SPI_dependency"):
        localComponent.setCapabilityEnabled(sqiCapabilityId, True)
        localComponent.setCapabilityEnabled(spiCapabilityId, True)
        drvInstance = localComponent.getSymbolByID("DRV_SST26_SPI_DRIVER_INSTANCE")
        drvInstance.clearValue()
        localComponent.getSymbolByID("DRV_SST26_INTERFACE_TYPE").setValue("")

def destroyComponent(sst26Component):
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})
    if Database.getSymbolValue("core", "DMA_ENABLE") != None:
        Database.sendMessage("HarmonyCore", "ENABLE_SYS_DMA", {"isEnabled":False})
