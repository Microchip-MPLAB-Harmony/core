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

drv_sfdp_mcc_helpkeyword = "mcc_h3_drv_sfdp_configurations"

ChipSelect      = ["Chip Select 0", "Chip Select 1"]
protocolUsed    = ["SQI", "SPI"]

global sort_alphanumeric

def handleMessage(messageID, args):
    global sfdpspiChipSelectPin
    result_dict = {}
    component = 'drv_sfdp'
    # print("DRV_SFDP handleMessage: {} args: {}".format(messageID, args))
    result_dict= {"Result": "DRV_SFDP UnImplemented Command"}

    if (messageID == "SFDP_CONFIG_HW_IO"):
        pinId, protocol, cs, enable = args['config']
        if protocol == 'SQI':
            if cs >= len(ChipSelect):
                result_dict = {"Result": "Fail - SQI_CS{} out of range".format(cs)}
            else:
                symbolId = "CHIP_SELECT"
                if enable == True:
                    res = Database.setSymbolValue(component, symbolId, ChipSelect[cs])
                else:
                    res = Database.clearSymbolValue(component, symbolId)

                if res == True:
                    result_dict = {"Result": "Success"}
                else:
                    result_dict = {"Result": "Fail"}

        elif protocol == 'SPI':
            key = "SYS_PORT_PIN_{}".format(pinId)
            sfdpspiChipSelectPin.setSelectedKey(key)

    return result_dict

def sort_alphanumeric(l):
    import re
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ]
    return sorted(l, key = alphanum_key)

def sfdpSetMemoryDependency(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def sfdpHeaderFileGen(symbol, event):
    component = symbol.getComponent()

    protocolUsed = component.getSymbolByID("DRV_SFDP_PROTOCOL").getValue()
    plib_used = component.getSymbolByID("DRV_SFDP_PLIB").getValue()

    if (protocolUsed == "SQI"):
        if ("QSPI" in plib_used):
            symbol.setSourcePath("driver/sfdp/templates/drv_sfdp_qspi_definitions.h.ftl")
        elif ("SQI" in plib_used):
            symbol.setSourcePath("driver/sfdp/templates/drv_sfdp_sqi_definitions.h.ftl")
    elif (protocolUsed == "SPI"):
        symbol.setSourcePath("driver/sfdp/templates/drv_sfdp_qspi_spi_definitions.h.ftl")

    symbol.setEnabled(True)

def sfdpSourceFileGen(symbol, event):
    component = symbol.getComponent()

    coreArch = Database.getSymbolValue("core", "CoreArchitecture")
    protocolUsed = component.getSymbolByID("DRV_SFDP_PROTOCOL").getValue()
    plib_used = component.getSymbolByID("DRV_SFDP_PLIB").getValue()

    if (protocolUsed == "SQI"):
        if ("QSPI" in plib_used):
            symbol.setSourcePath("driver/sfdp/src/drv_sfdp_qspi.c.ftl")
            symbol.setMarkup(True)
        elif ("SQI" in plib_used):
            if "CORTEX" in coreArch:
                symbol.setSourcePath("driver/sfdp/src/drv_sfdp_sqi_arm.c.ftl")
                symbol.setMarkup(True)
    elif (protocolUsed == "SPI"):
        symbol.setSourcePath("driver/sfdp/src/drv_sfdp_qspi_spi.c.ftl")
        symbol.setMarkup(True)

    symbol.setEnabled(True)

def sfdpInterfaceFileGen(symbol, event):
    if symbol.getID() == "DRV_SFDP_SPI_INTERFACE_SOURCE":
        symbol.setEnabled(event["value"] == "SPI")
    if symbol.getID() == "DRV_SFDP_SPI_INTERFACE_HEADER":
        symbol.setEnabled(event["value"] == "SPI")

def setBuffDescriptor(symbol, event):
    if ("SQI" in event["value"]):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def setLaneMode(symbol, event):
    component = symbol.getComponent()

    if (event["id"] == "DRV_SFDP_PLIB"):
        if ("SQI" in event["value"]):
            symbol.setVisible(True)
        else:
            symbol.setVisible(False)
    elif (event["id"] == "LANE_MODE"):
        plibID = component.getSymbolByID("DRV_SFDP_PLIB").getValue().lower()

        Database.sendMessage(plibID, "SET_SQI_LANE_MODE", {"laneMode":event["value"], "isReadOnly":True})

def requestAndAssignDMAChannel(symbol, event):

    component = symbol.getComponent()

    spiPeripheral = component.getSymbolByID("DRV_SFDP_PLIB").getValue()

    if symbol.getID() == "DRV_SFDP_TX_DMA_CHANNEL":
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
    global sfdpTXRXDMA

    if ((event["value"] == -2) and (sfdpTXRXDMA.getValue() == True)):
        symbol.setVisible(True)
        event["symbol"].setVisible(False)
    else:
        symbol.setVisible(False)

def setPLIBOptionsVisibility(symbol, event):
    global isDMAPresent

    if (symbol.getID() == "DRV_SFDP_TX_RX_DMA"):
        if (isDMAPresent == True):
            symbol.setVisible(event["value"] == "SPI_PLIB")
    else:
        symbol.setVisible(event["value"] != "SPI_DRV")

def setDriverOptionsVisibility(symbol, event):
    symbol.setVisible(event["value"] == "SPI_DRV")

def instantiateComponent(sfdpComponent):
    global isDMAPresent
    global sfdpTXRXDMA
    global sfdpInterfaceType

    res = Database.activateComponents(["HarmonyCore"])

    if Database.getSymbolValue("core", "DMA_ENABLE") == None:
        isDMAPresent = False
    else:
        isDMAPresent = True

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

    sfdpPLIB = sfdpComponent.createStringSymbol("DRV_SFDP_PLIB", None)
    sfdpPLIB.setLabel("PLIB Used")
    sfdpPLIB.setHelp(drv_sfdp_mcc_helpkeyword)
    sfdpPLIB.setReadOnly(True)
    sfdpPLIB.setDependencies(setPLIBOptionsVisibility, ["DRV_SFDP_INTERFACE_TYPE"])

    sfdpProtocol = sfdpComponent.createComboSymbol("DRV_SFDP_PROTOCOL", None, protocolUsed)
    sfdpProtocol.setLabel("SFDP Protocol Used")
    sfdpProtocol.setHelp(drv_sfdp_mcc_helpkeyword)
    sfdpProtocol.setDefaultValue("SQI")
    sfdpProtocol.setDescription("SFDP driver protocol selection (SQI for QSPI or SPI for standard SPI)")

    sfdpNumClients = sfdpComponent.createIntegerSymbol("DRV_SFDP_NUM_CLIENTS", None)
    sfdpNumClients.setLabel("Number of Clients")
    sfdpNumClients.setHelp(drv_sfdp_mcc_helpkeyword)
    sfdpNumClients.setReadOnly(True)
    sfdpNumClients.setMin(1)
    sfdpNumClients.setMax(64)
    sfdpNumClients.setDefaultValue(1)

    sfdpNumBufDesc = sfdpComponent.createIntegerSymbol("DRV_SFDP_NUM_BUFFER_DESC", None)
    sfdpNumBufDesc.setLabel("Number of Buffer Descriptors")
    sfdpNumBufDesc.setHelp(drv_sfdp_mcc_helpkeyword)
    sfdpNumBufDesc.setMin(1)
    sfdpNumBufDesc.setDefaultValue(10)
    sfdpNumBufDesc.setVisible(False)
    sfdpNumBufDesc.setDependencies(setBuffDescriptor, ["DRV_SFDP_PLIB"])

    sfdpSqiLaneMode = sfdpComponent.createComboSymbol("LANE_MODE", None, ["SINGLE", "QUAD"])
    sfdpSqiLaneMode.setLabel("SQI Lane Mode")
    sfdpSqiLaneMode.setHelp(drv_sfdp_mcc_helpkeyword)
    sfdpSqiLaneMode.setDefaultValue("QUAD")
    sfdpSqiLaneMode.setVisible(False)
    sfdpSqiLaneMode.setDependencies(setLaneMode, ["DRV_SFDP_PLIB", "LANE_MODE"])
    sfdpSqiLaneMode.setDescription("SFDP driver will auto-detect optimal mode via SFDP discovery")

    sfdpChipSelect = sfdpComponent.createComboSymbol("CHIP_SELECT", None, ChipSelect)
    sfdpChipSelect.setLabel("SQI Chip Select")
    sfdpChipSelect.setHelp(drv_sfdp_mcc_helpkeyword)
    sfdpChipSelect.setVisible(False)
    sfdpChipSelect.setDefaultValue("Chip Select 1")

    sfdpChipSelectComment = sfdpComponent.createCommentSymbol("CHIP_SELECT_COMMENT", None)
    sfdpChipSelectComment.setVisible(False)
    sfdpChipSelectComment.setLabel("*** Configure Chip Select in SQI PLIB Configurations ***")

    global sfdpspiChipSelectPin
    sfdpspiChipSelectPin = sfdpComponent.createKeyValueSetSymbol("SPI_CHIP_SELECT_PIN", None)
    sfdpspiChipSelectPin.setLabel("Chip Select Pin")
    sfdpspiChipSelectPin.setHelp(drv_sfdp_mcc_helpkeyword)
    sfdpspiChipSelectPin.setOutputMode("Key")
    sfdpspiChipSelectPin.setDisplayMode("Description")
    sfdpspiChipSelectPin.setVisible(False)

    availablePinDictionary = {}

    # Send message to core to get available pins
    availablePinDictionary = Database.sendMessage("core", "PIN_LIST", availablePinDictionary)

    for pad in sort_alphanumeric(availablePinDictionary.values()):
        key = "SYS_PORT_PIN_" + pad
        value = list(availablePinDictionary.keys())[list(availablePinDictionary.values()).index(pad)]
        description = pad
        sfdpspiChipSelectPin.addKey(key, value, description)

    sfdpspiChipSelectPinComment = sfdpComponent.createCommentSymbol("SPI_CHIP_SELECT_PIN_COMMENT", None)
    sfdpspiChipSelectPinComment.setLabel("***Above selected pin must be configured as GPIO Output in Pin Manager***")
    sfdpspiChipSelectPinComment.setVisible(False)

    ##### Do not modify below symbol names as they are used by Memory Driver #####
    sfdpMemoryDriver = sfdpComponent.createBooleanSymbol("DRV_MEMORY_CONNECTED", None)
    sfdpMemoryDriver.setLabel("Memory Driver Connected")
    sfdpMemoryDriver.setVisible(False)
    sfdpMemoryDriver.setDefaultValue(False)

    sfdpMemoryStartAddr = sfdpComponent.createHexSymbol("START_ADDRESS", None)
    sfdpMemoryStartAddr.setLabel("SFDP Start Address")
    sfdpMemoryStartAddr.setHelp(drv_sfdp_mcc_helpkeyword)
    sfdpMemoryStartAddr.setVisible(True)
    sfdpMemoryStartAddr.setDefaultValue(0x0000000)
    sfdpMemoryStartAddr.setDescription("Starting address offset in flash memory")

    sfdpMemoryInterruptEnable = sfdpComponent.createBooleanSymbol("INTERRUPT_ENABLE", None)
    sfdpMemoryInterruptEnable.setLabel("SFDP Interrupt Enable")
    sfdpMemoryInterruptEnable.setVisible(False)
    sfdpMemoryInterruptEnable.setDefaultValue(False)
    sfdpMemoryInterruptEnable.setReadOnly(True)

    sfdpMemoryEraseEnable = sfdpComponent.createBooleanSymbol("ERASE_ENABLE", None)
    sfdpMemoryEraseEnable.setLabel("SFDP Erase Enable")
    sfdpMemoryEraseEnable.setVisible(False)
    sfdpMemoryEraseEnable.setDefaultValue(True)
    sfdpMemoryEraseEnable.setReadOnly(True)

    sfdpMemoryEraseBufferSize = sfdpComponent.createIntegerSymbol("ERASE_BUFFER_SIZE", None)
    sfdpMemoryEraseBufferSize.setLabel("SFDP Erase Buffer Size")
    sfdpMemoryEraseBufferSize.setHelp(drv_sfdp_mcc_helpkeyword)
    sfdpMemoryEraseBufferSize.setVisible(False)
    sfdpMemoryEraseBufferSize.setDefaultValue(4096)
    sfdpMemoryEraseBufferSize.setDependencies(sfdpSetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])
    sfdpMemoryEraseBufferSize.setDescription("Erase buffer size (discovered from SFDP at runtime)")

    sfdpMemoryEraseComment = sfdpComponent.createCommentSymbol("ERASE_COMMENT", None)
    sfdpMemoryEraseComment.setVisible(False)
    sfdpMemoryEraseComment.setLabel("*** Erase size is discovered at runtime from SFDP ***")
    sfdpMemoryEraseComment.setDependencies(sfdpSetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    sfdpInterfaceType = sfdpComponent.createStringSymbol("DRV_SFDP_INTERFACE_TYPE", None)
    sfdpInterfaceType.setLabel("SFDP Interface Type")
    sfdpInterfaceType.setVisible(False)
    sfdpInterfaceType.setDefaultValue("")

    sfdpTXRXDMA = sfdpComponent.createBooleanSymbol("DRV_SFDP_TX_RX_DMA", None)
    sfdpTXRXDMA.setLabel("Use DMA for Transmit and Receive ?")
    sfdpTXRXDMA.setVisible(isDMAPresent and sfdpInterfaceType.getValue() == "SPI_PLIB")
    sfdpTXRXDMA.setDependencies(setPLIBOptionsVisibility, ["DRV_SFDP_INTERFACE_TYPE"])

    sfdpSymDrvInstance = sfdpComponent.createStringSymbol("DRV_SFDP_SPI_DRIVER_INSTANCE", None)
    sfdpSymDrvInstance.setLabel("SPI Driver Instance Used")
    sfdpSymDrvInstance.setReadOnly(True)
    sfdpSymDrvInstance.setDefaultValue("")
    sfdpSymDrvInstance.setVisible(False)
    sfdpSymDrvInstance.setDependencies(setDriverOptionsVisibility, ["DRV_SFDP_INTERFACE_TYPE"])

    sfdpTXDMAChannel = sfdpComponent.createIntegerSymbol("DRV_SFDP_TX_DMA_CHANNEL", None)
    sfdpTXDMAChannel.setLabel("DMA Channel For Transmit")
    sfdpTXDMAChannel.setDefaultValue(0)
    sfdpTXDMAChannel.setVisible(False)
    sfdpTXDMAChannel.setReadOnly(True)
    sfdpTXDMAChannel.setDependencies(requestAndAssignDMAChannel, ["DRV_SFDP_TX_RX_DMA"])

    sfdpTXDMAChannelComment = sfdpComponent.createCommentSymbol("DRV_SFDP_TX_DMA_CH_COMMENT", None)
    sfdpTXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Transmit. Check DMA manager. !!!")
    sfdpTXDMAChannelComment.setVisible(False)
    sfdpTXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_SFDP_TX_DMA_CHANNEL"])

    sfdpRXDMAChannel = sfdpComponent.createIntegerSymbol("DRV_SFDP_RX_DMA_CHANNEL", None)
    sfdpRXDMAChannel.setLabel("DMA Channel For Receive")
    sfdpRXDMAChannel.setDefaultValue(1)
    sfdpRXDMAChannel.setVisible(False)
    sfdpRXDMAChannel.setReadOnly(True)
    sfdpRXDMAChannel.setDependencies(requestAndAssignDMAChannel, ["DRV_SFDP_TX_RX_DMA"])

    sfdpRXDMAChannelComment = sfdpComponent.createCommentSymbol("DRV_SFDP_RX_DMA_CH_COMMENT", None)
    sfdpRXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Receive. Check DMA manager. !!!")
    sfdpRXDMAChannelComment.setVisible(False)
    sfdpRXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_SFDP_RX_DMA_CHANNEL"])

    sfdpDependencyDMAComment = sfdpComponent.createCommentSymbol("DRV_SFDP_DEPENDENCY_DMA_COMMENT", None)
    sfdpDependencyDMAComment.setLabel("!!! Satisfy PLIB Dependency to Allocate DMA Channel !!!")
    sfdpDependencyDMAComment.setVisible(False)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    sfdpHeaderFile = sfdpComponent.createFileSymbol("DRV_SFDP_HEADER", None)
    sfdpHeaderFile.setSourcePath("driver/sfdp/drv_sfdp.h.ftl")
    sfdpHeaderFile.setOutputName("drv_sfdp.h")
    sfdpHeaderFile.setDestPath("driver/sfdp/")
    sfdpHeaderFile.setProjectPath("config/" + configName + "/driver/sfdp/")
    sfdpHeaderFile.setType("HEADER")
    sfdpHeaderFile.setMarkup(True)
    sfdpHeaderFile.setOverwrite(True)

    sfdpHeaderLocalFile = sfdpComponent.createFileSymbol("DRV_SFDP_HEADER_LOCAL", None)
    sfdpHeaderLocalFile.setSourcePath("driver/sfdp/src/drv_sfdp_local.h.ftl")
    sfdpHeaderLocalFile.setOutputName("drv_sfdp_local.h")
    sfdpHeaderLocalFile.setDestPath("driver/sfdp/src")
    sfdpHeaderLocalFile.setProjectPath("config/" + configName + "/driver/sfdp/")
    sfdpHeaderLocalFile.setType("HEADER")
    sfdpHeaderLocalFile.setOverwrite(True)
    sfdpHeaderLocalFile.setMarkup(True)
    sfdpHeaderLocalFile.setOverwrite(True)

    sfdpHeaderDefFile = sfdpComponent.createFileSymbol("DRV_SFDP_HEADER_DEF", None)
    sfdpHeaderDefFile.setOutputName("drv_sfdp_definitions.h")
    sfdpHeaderDefFile.setDestPath("driver/sfdp/")
    sfdpHeaderDefFile.setProjectPath("config/" + configName + "/driver/sfdp/")
    sfdpHeaderDefFile.setType("HEADER")
    sfdpHeaderDefFile.setOverwrite(True)
    sfdpHeaderDefFile.setMarkup(True)
    sfdpHeaderDefFile.setDependencies(sfdpHeaderFileGen, ["DRV_SFDP_PROTOCOL"])

    sfdpSourceFile = sfdpComponent.createFileSymbol("DRV_SFDP_SOURCE", None)
    sfdpSourceFile.setOutputName("drv_sfdp.c")
    sfdpSourceFile.setDestPath("driver/sfdp/src/")
    sfdpSourceFile.setProjectPath("config/" + configName + "/driver/sfdp/")
    sfdpSourceFile.setType("SOURCE")
    sfdpSourceFile.setOverwrite(True)
    sfdpSourceFile.setDependencies(sfdpSourceFileGen, ["DRV_SFDP_PROTOCOL"])

    # SPI Interface Files
    sfdpSpiInterfaceHeader = sfdpComponent.createFileSymbol("DRV_SFDP_SPI_INTERFACE_HEADER", None)
    sfdpSpiInterfaceHeader.setSourcePath("driver/sfdp/src/drv_sfdp_spi_interface.h.ftl")
    sfdpSpiInterfaceHeader.setOutputName("drv_sfdp_spi_interface.h")
    sfdpSpiInterfaceHeader.setDestPath("driver/sfdp/src")
    sfdpSpiInterfaceHeader.setProjectPath("config/" + configName + "/driver/sfdp/")
    sfdpSpiInterfaceHeader.setType("HEADER")
    sfdpSpiInterfaceHeader.setOverwrite(True)
    sfdpSpiInterfaceHeader.setMarkup(True)
    sfdpSpiInterfaceHeader.setEnabled(False)
    sfdpSpiInterfaceHeader.setDependencies(sfdpInterfaceFileGen, ["DRV_SFDP_PROTOCOL"])

    sfdpSpiInterfaceSource = sfdpComponent.createFileSymbol("DRV_SFDP_SPI_INTERFACE_SOURCE", None)
    sfdpSpiInterfaceSource.setSourcePath("driver/sfdp/src/drv_sfdp_spi_interface.c.ftl")
    sfdpSpiInterfaceSource.setOutputName("drv_sfdp_spi_interface.c")
    sfdpSpiInterfaceSource.setDestPath("driver/sfdp/src/")
    sfdpSpiInterfaceSource.setProjectPath("config/" + configName + "/driver/sfdp/")
    sfdpSpiInterfaceSource.setType("SOURCE")
    sfdpSpiInterfaceSource.setOverwrite(True)
    sfdpSpiInterfaceSource.setMarkup(True)
    sfdpSpiInterfaceSource.setEnabled(False)
    sfdpSpiInterfaceSource.setDependencies(sfdpInterfaceFileGen, ["DRV_SFDP_PROTOCOL"])

    # System Template Files
    sfdpSystemDefFile = sfdpComponent.createFileSymbol("DRV_SFDP_SYS_DEF", None)
    sfdpSystemDefFile.setType("STRING")
    sfdpSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sfdpSystemDefFile.setSourcePath("driver/sfdp/templates/system/definitions.h.ftl")
    sfdpSystemDefFile.setMarkup(True)

    sfdpSystemDefObjFile = sfdpComponent.createFileSymbol("DRV_SFDP_SYS_DEF_OBJ", None)
    sfdpSystemDefObjFile.setType("STRING")
    sfdpSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    sfdpSystemDefObjFile.setSourcePath("driver/sfdp/templates/system/definitions_objects.h.ftl")
    sfdpSystemDefObjFile.setMarkup(True)

    sfdpSystemConfigFile = sfdpComponent.createFileSymbol("DRV_SFDP_SYS_CFG", None)
    sfdpSystemConfigFile.setType("STRING")
    sfdpSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    sfdpSystemConfigFile.setSourcePath("driver/sfdp/templates/system/configuration.h.ftl")
    sfdpSystemConfigFile.setMarkup(True)

    sfdpSystemInitDataFile = sfdpComponent.createFileSymbol("DRV_SFDP_SYS_INIT_DATA", None)
    sfdpSystemInitDataFile.setType("STRING")
    sfdpSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    sfdpSystemInitDataFile.setSourcePath("driver/sfdp/templates/system/initialize_data.c.ftl")
    sfdpSystemInitDataFile.setMarkup(True)

    sfdpSystemInitFile = sfdpComponent.createFileSymbol("DRV_SFDP_SYS_INIT", None)
    sfdpSystemInitFile.setType("STRING")
    sfdpSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    sfdpSystemInitFile.setSourcePath("driver/sfdp/templates/system/initialize.c.ftl")
    sfdpSystemInitFile.setMarkup(True)

def onAttachmentConnected(source, target):
    global isDMAPresent
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    sqiCapabilityId = "drv_sfdp_SQI_dependency"
    spiCapabilityId = "drv_sfdp_SPI_dependency"
    spiDrvCapabilityId = "drv_sfdp_DRV_SPI_dependency"

    sfdpPlibID = remoteID.upper()

    if connectID == sqiCapabilityId :
        localComponent.getSymbolByID("DRV_SFDP_PLIB").setValue(sfdpPlibID)
        localComponent.getSymbolByID("DRV_SFDP_PROTOCOL").setValue("SQI")
        localComponent.getSymbolByID("DRV_SFDP_INTERFACE_TYPE").setValue("SQI_PLIB")

        if ("sqi" in remoteID):
            localComponent.getSymbolByID("CHIP_SELECT").setVisible(True)
            localComponent.getSymbolByID("CHIP_SELECT_COMMENT").setVisible(True)

            laneMode = localComponent.getSymbolByID("LANE_MODE").getValue()

            Database.sendMessage(sfdpPlibID.lower(), "SET_SQI_FLASH_STATUS_CHECK", {"isReadOnly":True})
            Database.sendMessage(sfdpPlibID.lower(), "SET_SQI_LANE_MODE", {"laneMode":laneMode, "isReadOnly":True})

        localComponent.setCapabilityEnabled(spiCapabilityId, False)
        localComponent.setCapabilityEnabled(spiDrvCapabilityId, False)


    if connectID == spiCapabilityId :

        localComponent.getSymbolByID("DRV_SFDP_PLIB").setValue(sfdpPlibID)
        localComponent.getSymbolByID("DRV_SFDP_PROTOCOL").setValue("SPI")

        Database.setSymbolValue(sfdpPlibID, "SPI_DRIVER_CONTROLLED", True)

        localComponent.getSymbolByID("INTERRUPT_ENABLE").setValue(True)

        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN").setVisible(True)
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN_COMMENT").setVisible(True)

        localComponent.setCapabilityEnabled(sqiCapabilityId, False)
        localComponent.setCapabilityEnabled(spiDrvCapabilityId, False)

        # Enable "Enable System Ports" option in MHC
        Database.sendMessage("HarmonyCore", "ENABLE_SYS_PORTS", {"isEnabled":True})

        localComponent.getSymbolByID("DRV_SFDP_INTERFACE_TYPE").setValue("SPI_PLIB")
        localComponent.getSymbolByID("DRV_SFDP_TX_RX_DMA").setReadOnly(False)

    if connectID == "drv_sfdp_DRV_SPI_dependency":
        localComponent.getSymbolByID("DRV_SFDP_PLIB").setValue("")
        localComponent.getSymbolByID("DRV_SFDP_PROTOCOL").setValue("SPI")
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN").setVisible(True)
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN_COMMENT").setVisible(True)
        localComponent.setCapabilityEnabled(spiCapabilityId, False)
        localComponent.setCapabilityEnabled(sqiCapabilityId, False)
        localComponent.getSymbolByID("DRV_SFDP_INTERFACE_TYPE").setValue("SPI_DRV")
        drvInstance = localComponent.getSymbolByID("DRV_SFDP_SPI_DRIVER_INSTANCE")
        drvInstance.clearValue()
        index = Database.getSymbolValue(remoteID, "INDEX")
        drvInstance.setValue(str(index))

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    sqiCapabilityId = "drv_sfdp_SQI_dependency"
    spiCapabilityId = "drv_sfdp_SPI_dependency"
    spiDrvCapabilityId = "drv_sfdp_DRV_SPI_dependency"

    sfdpPlibID = remoteID.upper()

    if connectID == "drv_sfdp_SQI_dependency" :
        if ("sqi" in remoteID):
            localComponent.getSymbolByID("CHIP_SELECT").setVisible(False)
            localComponent.getSymbolByID("CHIP_SELECT_COMMENT").setVisible(False)

            Database.sendMessage(sfdpPlibID.lower(), "SET_SQI_FLASH_STATUS_CHECK", {"isReadOnly":False})
            Database.sendMessage(sfdpPlibID.lower(), "SET_SQI_LANE_MODE", {"isReadOnly":False})

        localComponent.getSymbolByID("DRV_SFDP_PLIB").clearValue()

        localComponent.setCapabilityEnabled(spiCapabilityId, True)
        localComponent.setCapabilityEnabled(spiDrvCapabilityId, True)
        localComponent.getSymbolByID("DRV_SFDP_INTERFACE_TYPE").setValue("")

    if connectID == "drv_sfdp_SPI_dependency" :
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN").setVisible(False)
        localComponent.getSymbolByID("SPI_CHIP_SELECT_PIN_COMMENT").setVisible(False)

        Database.setSymbolValue(sfdpPlibID, "SPI_DRIVER_CONTROLLED", False)

        localComponent.getSymbolByID("INTERRUPT_ENABLE").setValue(False)

        localComponent.setCapabilityEnabled(sqiCapabilityId, True)
        localComponent.setCapabilityEnabled(spiDrvCapabilityId, True)

        Database.sendMessage("HarmonyCore", "ENABLE_SYS_PORTS", {"isEnabled":False})
        localComponent.getSymbolByID("DRV_SFDP_TX_RX_DMA").setReadOnly(True)
        localComponent.getSymbolByID("DRV_SFDP_TX_RX_DMA").setValue(False)
        localComponent.getSymbolByID("DRV_SFDP_PLIB").clearValue()
        localComponent.getSymbolByID("DRV_SFDP_INTERFACE_TYPE").setValue("")

    if (connectID == "drv_sfdp_DRV_SPI_dependency"):
        localComponent.setCapabilityEnabled(sqiCapabilityId, True)
        localComponent.setCapabilityEnabled(spiCapabilityId, True)
        drvInstance = localComponent.getSymbolByID("DRV_SFDP_SPI_DRIVER_INSTANCE")
        drvInstance.clearValue()
        localComponent.getSymbolByID("DRV_SFDP_INTERFACE_TYPE").setValue("")

def destroyComponent(sfdpComponent):
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})
    if Database.getSymbolValue("core", "DMA_ENABLE") != None:
        Database.sendMessage("HarmonyCore", "ENABLE_SYS_DMA", {"isEnabled":False})
