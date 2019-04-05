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

global isDMAPresent

def instantiateComponent(spiComponent, index):
    global drvSpiInstanceSpace
    global isDMAPresent

    drvSpiInstanceSpace = "drv_spi_" + str(index)

    # Enable "Generate Harmony Driver Common Files" option in MHC
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON") == False):
        Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True)

    # Enable "Generate Harmony System Service Common Files" option in MHC
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON") == False):
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True)

    # Enable "Enable System Ports" option in MHC
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS") == False):
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS", True)

    # Enable "ENABLE_SYS_DMA" option in MHC
    if Database.getSymbolValue("core", "DMA_ENABLE") == None:
        isDMAPresent = False
    else:
        isDMAPresent = True

        # Enable "Enable System DMA" option in MHC
        if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_DMA") == False):
            Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_DMA", True)

    spiSymIndex = spiComponent.createIntegerSymbol("INDEX", None)
    spiSymIndex.setVisible(False)
    spiSymIndex.setDefaultValue(index)

    spiSymPLIB = spiComponent.createStringSymbol("DRV_SPI_PLIB", None)
    spiSymPLIB.setLabel("PLIB Used")
    spiSymPLIB.setReadOnly(True)
    spiSymPLIB.setDefaultValue("")

    spiGlobalMode = spiComponent.createStringSymbol("DRV_SPI_MODE", None)
    spiGlobalMode.setLabel("**** Driver Mode Update ****")
    spiGlobalMode.setValue(Database.getSymbolValue("drv_spi", "DRV_SPI_COMMON_MODE"))
    spiGlobalMode.setVisible(False)
    spiGlobalMode.setDependencies(spiDriverMode, ["drv_spi.DRV_SPI_COMMON_MODE"])

    spiSymNumClients = spiComponent.createIntegerSymbol("DRV_SPI_NUM_CLIENTS", None)
    spiSymNumClients.setLabel("Number of Clients")
    spiSymNumClients.setMin(1)
    spiSymNumClients.setMax(10)
    spiSymNumClients.setDefaultValue(1)

    spiSymQueueSize = spiComponent.createIntegerSymbol("DRV_SPI_QUEUE_SIZE", None)
    spiSymQueueSize.setLabel("Transfer Queue Size")
    spiSymQueueSize.setMin(1)
    spiSymQueueSize.setMax(64)
    spiSymQueueSize.setVisible((Database.getSymbolValue("drv_spi", "DRV_SPI_COMMON_MODE") == "Asynchronous"))
    spiSymQueueSize.setDefaultValue(4)
    spiSymQueueSize.setDependencies(asyncModeOptions, ["drv_spi.DRV_SPI_COMMON_MODE"])

    global spiTXRXDMA
    spiTXRXDMA = spiComponent.createBooleanSymbol("DRV_SPI_TX_RX_DMA", None)
    spiTXRXDMA.setLabel("Use DMA for Transmit and Receive?")
    spiTXRXDMA.setVisible(isDMAPresent)
    spiTXRXDMA.setReadOnly(True)

    global spiTXDMAChannel
    spiTXDMAChannel = spiComponent.createIntegerSymbol("DRV_SPI_TX_DMA_CHANNEL", None)
    spiTXDMAChannel.setLabel("DMA Channel For Transmit")
    spiTXDMAChannel.setDefaultValue(0)
    spiTXDMAChannel.setVisible(False)
    spiTXDMAChannel.setReadOnly(True)
    spiTXDMAChannel.setDependencies(requestAndAssignTxDMAChannel, ["DRV_SPI_TX_RX_DMA"])

    global spiTXDMAChannelComment
    spiTXDMAChannelComment = spiComponent.createCommentSymbol("DRV_SPI_TX_DMA_CH_COMMENT", None)
    spiTXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Transmit. Check DMA Manager. !!!")
    spiTXDMAChannelComment.setVisible(False)
    spiTXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_SPI_TX_DMA_CHANNEL"])

    global spiRXDMAChannel
    spiRXDMAChannel = spiComponent.createIntegerSymbol("DRV_SPI_RX_DMA_CHANNEL", None)
    spiRXDMAChannel.setLabel("DMA Channel For Receive")
    spiRXDMAChannel.setDefaultValue(1)
    spiRXDMAChannel.setVisible(False)
    spiRXDMAChannel.setReadOnly(True)
    spiRXDMAChannel.setDependencies(requestAndAssignRxDMAChannel, ["DRV_SPI_TX_RX_DMA"])

    global spiRXDMAChannelComment
    spiRXDMAChannelComment = spiComponent.createCommentSymbol("DRV_SPI_RX_DMA_CH_COMMENT", None)
    spiRXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Receive. Check DMA Manager. !!!")
    spiRXDMAChannelComment.setVisible(False)
    spiRXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_SPI_RX_DMA_CHANNEL"])

    spiDependencyDMAComment = spiComponent.createCommentSymbol("DRV_SPI_DEPENDENCY_DMA_COMMENT", None)
    spiDependencyDMAComment.setLabel("!!! Satisfy PLIB Dependency to Allocate DMA Channel !!!")
    spiDependencyDMAComment.setVisible(isDMAPresent)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    # Global Header Files
    spiSymHeaderFile = spiComponent.createFileSymbol("DRV_SPI_HEADER", None)
    spiSymHeaderFile.setSourcePath("driver/spi/drv_spi.h")
    spiSymHeaderFile.setOutputName("drv_spi.h")
    spiSymHeaderFile.setDestPath("driver/spi/")
    spiSymHeaderFile.setProjectPath("config/" + configName + "/driver/spi/")
    spiSymHeaderFile.setType("HEADER")
    spiSymHeaderFile.setOverwrite(True)

    spiSymHeaderDefFile = spiComponent.createFileSymbol("DRV_SPI_DEF", None)
    spiSymHeaderDefFile.setSourcePath("driver/spi/templates/drv_spi_definitions.h.ftl")
    spiSymHeaderDefFile.setOutputName("drv_spi_definitions.h")
    spiSymHeaderDefFile.setDestPath("driver/spi")
    spiSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/spi/")
    spiSymHeaderDefFile.setType("HEADER")
    spiSymHeaderDefFile.setMarkup(True)
    spiSymHeaderDefFile.setOverwrite(True)

    # System Template Files
    spiSymSystemDefObjFile = spiComponent.createFileSymbol("DRV_SPI_SYSTEM_DEF_OBJECT", None)
    spiSymSystemDefObjFile.setType("STRING")
    spiSymSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    spiSymSystemDefObjFile.setSourcePath("driver/spi/templates/system/system_definitions_objects.h.ftl")
    spiSymSystemDefObjFile.setMarkup(True)

    spiSymSystemConfigFile = spiComponent.createFileSymbol("DRV_SPI_SYSTEM_CONFIG", None)
    spiSymSystemConfigFile.setType("STRING")
    spiSymSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    spiSymSystemConfigFile.setSourcePath("driver/spi/templates/system/system_config.h.ftl")
    spiSymSystemConfigFile.setMarkup(True)

    spiSymSystemInitDataFile = spiComponent.createFileSymbol("DRV_SPI_INIT_DATA", None)
    spiSymSystemInitDataFile.setType("STRING")
    spiSymSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    spiSymSystemInitDataFile.setSourcePath("driver/spi/templates/system/system_initialize_data.c.ftl")
    spiSymSystemInitDataFile.setMarkup(True)

    spiSymSystemInitFile = spiComponent.createFileSymbol("DRV_SPI_SYS_INIT", None)
    spiSymSystemInitFile.setType("STRING")
    spiSymSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    spiSymSystemInitFile.setSourcePath("driver/spi/templates/system/system_initialize.c.ftl")
    spiSymSystemInitFile.setMarkup(True)

################################################################################
#### Business Logic ####
################################################################################

def spiDriverMode(symbol, event):
    symbol.setValue(event["value"])

def onAttachmentConnected(source, target):
    global isDMAPresent

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_spi_SPI_dependency":
        plibUsed = localComponent.getSymbolByID("DRV_SPI_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(remoteID.upper())

        Database.setSymbolValue(remoteID, "SPI_DRIVER_CONTROLLED", True)
        dmaChannelSym = Database.getSymbolValue("core", "DMA_CH_FOR_" + remoteID.upper() + "_Transmit")
        dmaRequestSym = Database.getSymbolValue("core", "DMA_CH_NEEDED_FOR_" + remoteID.upper() + "_Transmit")

        # Do not change the order as DMA Channels needs to be allocated
        # after setting the plibUsed symbol
        # Both device and connected plib should support DMA
        if isDMAPresent == True and dmaChannelSym != None and dmaRequestSym != None:
            localComponent.getSymbolByID("DRV_SPI_DEPENDENCY_DMA_COMMENT").setVisible(False)
            localComponent.getSymbolByID("DRV_SPI_TX_RX_DMA").setReadOnly(False)

def onAttachmentDisconnected(source, target):
    global isDMAPresent

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_spi_SPI_dependency":

        dmaChannelSym = Database.getSymbolValue("core", "DMA_CH_FOR_" + remoteID.upper() + "_Transmit")
        dmaRequestSym = Database.getSymbolValue("core", "DMA_CH_NEEDED_FOR_" + remoteID.upper() + "_Transmit")

        # Do not change the order as DMA Channels needs to be cleared
        # before clearing the plibUsed symbol
        # Both device and connected plib should support DMA
        if isDMAPresent == True and dmaChannelSym != None and dmaRequestSym != None:
            localComponent.getSymbolByID("DRV_SPI_TX_RX_DMA").clearValue()
            localComponent.getSymbolByID("DRV_SPI_TX_RX_DMA").setReadOnly(True)
            localComponent.getSymbolByID("DRV_SPI_DEPENDENCY_DMA_COMMENT").setVisible(True)

        plibUsed = localComponent.getSymbolByID("DRV_SPI_PLIB")
        plibUsed.clearValue()
        Database.setSymbolValue(remoteID, "SPI_DRIVER_CONTROLLED", False)

def requestAndAssignTxDMAChannel(symbol, event):
    global drvSpiInstanceSpace
    global spiTXDMAChannelComment

    spiPeripheral = Database.getSymbolValue(drvSpiInstanceSpace, "DRV_SPI_PLIB")

    dmaChannelID = "DMA_CH_FOR_" + str(spiPeripheral) + "_Transmit"
    dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Transmit"

    if event["value"] == False:
        Database.setSymbolValue("core", dmaRequestID, False)
        spiTXDMAChannelComment.setVisible(False)
        symbol.setVisible(False)
    else:
        symbol.setVisible(True)
        Database.setSymbolValue("core", dmaRequestID, True)

    # Get the allocated channel and assign it
    channel = Database.getSymbolValue("core", dmaChannelID)
    symbol.setValue(channel)

def requestAndAssignRxDMAChannel(symbol, event):
    global drvSpiInstanceSpace
    global spiRXDMAChannelComment

    spiPeripheral = Database.getSymbolValue(drvSpiInstanceSpace, "DRV_SPI_PLIB")

    dmaChannelID = "DMA_CH_FOR_" + str(spiPeripheral) + "_Receive"
    dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Receive"

    if event["value"] == False:
        Database.setSymbolValue("core", dmaRequestID, False)
        spiRXDMAChannelComment.setVisible(False)
        symbol.setVisible(False)
    else:
        symbol.setVisible(True)
        Database.setSymbolValue("core", dmaRequestID, True)

    # Get the allocated channel and assign it
    channel = Database.getSymbolValue("core", dmaChannelID)
    symbol.setValue(channel)

def requestDMAComment(symbol, event):
    global spiTXRXDMA

    if(event["value"] == -2) and (spiTXRXDMA.getValue() == True):
        symbol.setVisible(True)
        event["symbol"].setVisible(False)
    else:
        symbol.setVisible(False)

def destroyComponent(spiComponent):
    global drvSpiInstanceSpace

    if isDMAPresent:
        spiPeripheral = Database.getSymbolValue(drvSpiInstanceSpace, "DRV_SPI_PLIB")

        dmaTxID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Transmit"
        dmaRxID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Receive"

        Database.setSymbolValue("core", dmaTxID, False)
        Database.setSymbolValue("core", dmaRxID, False)

def asyncModeOptions(symbol, event):
    if (event["value"] == "Asynchronous"):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)
