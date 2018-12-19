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

global currentTxBufSize
global currentRxBufSize
global drvUsartInstanceSpace
global isDMAPresent

def instantiateComponent(usartComponent, index):
    global currentTxBufSize
    global currentRxBufSize
    global drvUsartInstanceSpace
    global isDMAPresent

    drvUsartInstanceSpace = "drv_usart_" + str(index)

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True, 1)

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True, 1)

    if Database.getSymbolValue("core", "DMA_ENABLE") == None:
        isDMAPresent = False
    else:
        isDMAPresent = True

        # Enable "Enable System DMA" option in MHC
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_DMA", True, 1)

    # Menu
    usartIndex = usartComponent.createIntegerSymbol("INDEX", None)
    usartIndex.setVisible(False)
    usartIndex.setDefaultValue(index)

    usartPLIB = usartComponent.createStringSymbol("DRV_USART_PLIB", None)
    usartPLIB.setLabel("PLIB Used")
    usartPLIB.setReadOnly(True)
    usartPLIB.setDefaultValue("")

    usartNumClients = usartComponent.createIntegerSymbol("DRV_USART_CLIENTS_NUM", None)
    usartNumClients.setLabel("Number of Clients")
    usartNumClients.setMax(10)
    usartNumClients.setVisible(True)
    usartNumClients.setDefaultValue(1)

    usartTXQueueSize = usartComponent.createIntegerSymbol("DRV_USART_QUEUE_SIZE", None)
    usartTXQueueSize.setLabel("Transfer Queue Size")
    usartTXQueueSize.setMax(64)
    usartTXQueueSize.setDefaultValue(5)
    usartTXQueueSize.setVisible((Database.getSymbolValue("drv_usart", "DRV_USART_COMMON_MODE") == "Asynchronous"))
    usartTXQueueSize.setDependencies(asyncModeOptions, ["drv_usart.DRV_USART_COMMON_MODE"])

    global usartTXDMA
    usartTXDMA = usartComponent.createBooleanSymbol("DRV_USART_TX_DMA", None)
    usartTXDMA.setLabel("Use DMA for Transmit ?")
    usartTXDMA.setVisible(isDMAPresent)
    usartTXDMA.setReadOnly(True)

    global usartTXDMAChannel
    usartTXDMAChannel = usartComponent.createIntegerSymbol("DRV_USART_TX_DMA_CHANNEL", None)
    usartTXDMAChannel.setLabel("DMA Channel For Transmit")
    usartTXDMAChannel.setDefaultValue(0)
    usartTXDMAChannel.setVisible(False)
    usartTXDMAChannel.setReadOnly(True)
    usartTXDMAChannel.setDependencies(requestAndAssignTxDMAChannel, ["DRV_USART_TX_DMA"])

    global usartTXDMAChannelComment
    usartTXDMAChannelComment = usartComponent.createCommentSymbol("DRV_USART_TX_DMA_CH_COMMENT", None)
    usartTXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Transmit. Check DMA Manager. !!!")
    usartTXDMAChannelComment.setVisible(False)
    usartTXDMAChannelComment.setDependencies(requestTxDMAComment, ["DRV_USART_TX_DMA_CHANNEL"])

    global usartRXDMA
    usartRXDMA = usartComponent.createBooleanSymbol("DRV_USART_RX_DMA", None)
    usartRXDMA.setLabel("Use DMA for Receive ?")
    usartRXDMA.setVisible(isDMAPresent)
    usartRXDMA.setReadOnly(True)

    global usartRXDMAChannel
    usartRXDMAChannel = usartComponent.createIntegerSymbol("DRV_USART_RX_DMA_CHANNEL", None)
    usartRXDMAChannel.setLabel("DMA Channel For Receive")
    usartRXDMAChannel.setDefaultValue(1)
    usartRXDMAChannel.setVisible(False)
    usartRXDMAChannel.setReadOnly(True)
    usartRXDMAChannel.setDependencies(requestAndAssignRxDMAChannel, ["DRV_USART_RX_DMA"])

    global usartRXDMAChannelComment
    usartRXDMAChannelComment = usartComponent.createCommentSymbol("DRV_USART_RX_DMA_CH_COMMENT", None)
    usartRXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Receive. Check DMA Manager. !!!")
    usartRXDMAChannelComment.setVisible(False)
    usartRXDMAChannelComment.setDependencies(requestRxDMAComment, ["DRV_USART_RX_DMA_CHANNEL"])

    usartDependencyDMAComment = usartComponent.createCommentSymbol("DRV_USART_DEPENDENCY_DMA_COMMENT", None)
    usartDependencyDMAComment.setLabel("!!! Satisfy PLIB Dependency to Allocate DMA Channel !!!")
    usartDependencyDMAComment.setVisible(isDMAPresent)

############################################################################
#### Code Generation ####
############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    # Global Header Files
    usartHeaderFile = usartComponent.createFileSymbol("USART_HEADER", None)
    usartHeaderFile.setSourcePath("driver/usart/drv_usart.h")
    usartHeaderFile.setOutputName("drv_usart.h")
    usartHeaderFile.setDestPath("driver/usart/")
    usartHeaderFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartHeaderFile.setType("HEADER")
    usartHeaderFile.setOverwrite(True)

    usartSymHeaderDefFile = usartComponent.createFileSymbol("DRV_USART_DEF", None)
    usartSymHeaderDefFile.setSourcePath("driver/usart/templates/drv_usart_definitions.h.ftl")
    usartSymHeaderDefFile.setOutputName("drv_usart_definitions.h")
    usartSymHeaderDefFile.setDestPath("driver/usart")
    usartSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartSymHeaderDefFile.setType("HEADER")
    usartSymHeaderDefFile.setMarkup(True)
    usartSymHeaderDefFile.setOverwrite(True)

    # System Template Files
    usartSystemDefObjFile = usartComponent.createFileSymbol("USART_DEF_OBJ", None)
    usartSystemDefObjFile.setType("STRING")
    usartSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    usartSystemDefObjFile.setSourcePath("driver/usart/templates/system/system_definitions_objects.h.ftl")
    usartSystemDefObjFile.setMarkup(True)

    usartSystemConfigFile = usartComponent.createFileSymbol("USART_CONFIG", None)
    usartSystemConfigFile.setType("STRING")
    usartSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    usartSystemConfigFile.setSourcePath("driver/usart/templates/system/system_config.h.ftl")
    usartSystemConfigFile.setMarkup(True)

    usartSystemInitDataFile = usartComponent.createFileSymbol("USART_INIT_DATA", None)
    usartSystemInitDataFile.setType("STRING")
    usartSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    usartSystemInitDataFile.setSourcePath("driver/usart/templates/system/system_initialize_data.c.ftl")
    usartSystemInitDataFile.setMarkup(True)

    usartSystemInitFile = usartComponent.createFileSymbol("USART_INIT", None)
    usartSystemInitFile.setType("STRING")
    usartSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    usartSystemInitFile.setSourcePath("driver/usart/templates/system/system_initialize.c.ftl")
    usartSystemInitFile.setMarkup(True)

################################################################################
#### Business Logic ####
################################################################################

def onAttachmentConnected(source, target):
    global isDMAPresent

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_usart_UART_dependency" :
        plibUsed = localComponent.getSymbolByID("DRV_USART_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(remoteID.upper(), 1)

        # Do not change the order as DMA Channels needs to be allocated
        # after setting the plibUsed symbol
        if isDMAPresent == True:
            localComponent.getSymbolByID("DRV_USART_DEPENDENCY_DMA_COMMENT").setVisible(False)
            localComponent.getSymbolByID("DRV_USART_TX_DMA").setReadOnly(False)
            localComponent.getSymbolByID("DRV_USART_RX_DMA").setReadOnly(False)

def onAttachmentDisconnected(source, target):
    global isDMAPresent

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_usart_UART_dependency" :
        # Do not change the order as DMA Channels needs to be cleared
        # before clearing the plibUsed symbol
        if isDMAPresent == True:
            localComponent.getSymbolByID("DRV_USART_TX_DMA").clearValue()
            localComponent.getSymbolByID("DRV_USART_TX_DMA").setReadOnly(True)
            localComponent.getSymbolByID("DRV_USART_RX_DMA").clearValue()
            localComponent.getSymbolByID("DRV_USART_RX_DMA").setReadOnly(True)
            localComponent.getSymbolByID("DRV_USART_DEPENDENCY_DMA_COMMENT").setVisible(True)

        plibUsed = localComponent.getSymbolByID("DRV_USART_PLIB")
        plibUsed.clearValue()

def requestAndAssignTxDMAChannel(symbol, event):
    global drvUsartInstanceSpace
    global usartTXDMAChannelComment

    usartPeripheral = Database.getSymbolValue(drvUsartInstanceSpace, "DRV_USART_PLIB")

    dmaChannelID = "DMA_CH_FOR_" + str(usartPeripheral) + "_Transmit"
    dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(usartPeripheral) + "_Transmit"

    if event["value"] == False:
        Database.setSymbolValue("core", dmaRequestID, False, 2)
        usartTXDMAChannelComment.setVisible(False)
        symbol.setVisible(False)
    else:
        symbol.setVisible(True)
        Database.setSymbolValue("core", dmaRequestID, True, 2)

    # Get the allocated channel and assign it
    channel = Database.getSymbolValue("core", dmaChannelID)
    symbol.setValue(channel, 2)

def requestAndAssignRxDMAChannel(symbol, event):
    global drvUsartInstanceSpace
    global usartRXDMAChannelComment

    usartPeripheral = Database.getSymbolValue(drvUsartInstanceSpace, "DRV_USART_PLIB")

    dmaChannelID = "DMA_CH_FOR_" + str(usartPeripheral) + "_Receive"
    dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(usartPeripheral) + "_Receive"

    if event["value"] == False:
        Database.setSymbolValue("core", dmaRequestID, False, 2)
        usartRXDMAChannelComment.setVisible(False)
        symbol.setVisible(False)
    else:
        symbol.setVisible(True)
        Database.setSymbolValue("core", dmaRequestID, True, 2)

    # Get the allocated channel and assign it
    channel = Database.getSymbolValue("core", dmaChannelID)
    symbol.setValue(channel, 2)

def requestTxDMAComment(symbol, event):
    global usartTXDMA

    if(event["value"] == -2) and (usartTXDMA.getValue() == True):
        symbol.setVisible(True)
        event["symbol"].setVisible(False)
    else:
        symbol.setVisible(False)

def requestRxDMAComment(symbol, event):
    global usartRXDMA

    if(event["value"] == -2) and (usartRXDMA.getValue() == True):
        symbol.setVisible(True)
        event["symbol"].setVisible(False)
    else:
        symbol.setVisible(False)

def destroyComponent(usartComponent):
    global drvUsartInstanceSpace

    if isDMAPresent:
        usartPeripheral = Database.getSymbolValue(drvUsartInstanceSpace, "DRV_USART_PLIB")

        dmaTxID = "DMA_CH_NEEDED_FOR_" + str(usartPeripheral) + "_Transmit"
        dmaRxID = "DMA_CH_NEEDED_FOR_" + str(usartPeripheral) + "_Receive"

        Database.setSymbolValue("core", dmaTxID, False, 2)
        Database.setSymbolValue("core", dmaRxID, False, 2)

def asyncModeOptions(symbol, event):
    if event["value"] == "Asynchronous":
       symbol.setVisible(True)
    else:
       symbol.setVisible(False)