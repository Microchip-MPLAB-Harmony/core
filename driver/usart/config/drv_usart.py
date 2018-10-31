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

def instantiateComponent(usartComponent, index):
    global currentTxBufSize
    global currentRxBufSize
    global drvUsartInstanceSpace
    drvUsartInstanceSpace = "drv_usart_" + str(index)

    # Enable dependent Harmony core components
    Database.clearSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
    Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True, 2)

    Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_DMA")
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_DMA", True, 2)

    # Menu
    usartIndex = usartComponent.createIntegerSymbol("INDEX", None)
    usartIndex.setVisible(False)
    usartIndex.setDefaultValue(index)

    usartPLIB = usartComponent.createStringSymbol("DRV_USART_PLIB", None)
    usartPLIB.setLabel("PLIB Used")
    usartPLIB.setReadOnly(True)
    usartPLIB.setDefaultValue("USART1")
    # Used onDependencyComponentAdd\Remove callbacks to get connected PLIB

    global usartSymPLIBConnection
    usartSymPLIBConnection = usartComponent.createBooleanSymbol("DRV_USART_PLIB_CONNECTION", None)
    usartSymPLIBConnection.setDefaultValue(False)
    usartSymPLIBConnection.setVisible(False)

    usartGlobalMode = usartComponent.createBooleanSymbol("DRV_USART_MODE", None)
    usartGlobalMode.setLabel("**** Driver Mode Update ****")
    usartGlobalMode.setValue(Database.getSymbolValue("drv_usart", "DRV_USART_COMMON_MODE"), 1)
    usartGlobalMode.setVisible(False)
    usartGlobalMode.setDependencies(usartDriverMode, ["drv_usart.DRV_USART_COMMON_MODE"])

    usartNumClients = usartComponent.createIntegerSymbol("DRV_USART_CLIENTS_NUM", None)
    usartNumClients.setLabel("Number of Clients")
    usartNumClients.setMax(50)
    usartNumClients.setVisible((Database.getSymbolValue("drv_usart", "DRV_USART_COMMON_MODE") == 1))
    usartNumClients.setDefaultValue(1)
    usartNumClients.setDependencies(syncModeOptions, ["DRV_USART_MODE"])

    usartTXQueueSize = usartComponent.createIntegerSymbol("DRV_USART_TX_QUEUE_SIZE", None)
    usartTXQueueSize.setLabel("Transmit Queue Size")
    usartTXQueueSize.setMax(50)
    usartTXQueueSize.setDefaultValue(5)
    usartTXQueueSize.setVisible((Database.getSymbolValue("drv_usart", "DRV_USART_COMMON_MODE") == 0))
    usartTXQueueSize.setDependencies(asyncModeOptions, ["DRV_USART_MODE"])
    currentTxBufSize = usartTXQueueSize.getValue()

    usartRXQueueSize = usartComponent.createIntegerSymbol("DRV_USART_RX_QUEUE_SIZE", None)
    usartRXQueueSize.setLabel("Receive Queue Size")
    usartRXQueueSize.setMax(50)
    usartRXQueueSize.setDefaultValue(5)
    usartRXQueueSize.setVisible((Database.getSymbolValue("drv_usart", "DRV_USART_COMMON_MODE") == 0))
    usartRXQueueSize.setDependencies(asyncModeOptions, ["DRV_USART_MODE"])
    currentRxBufSize = usartRXQueueSize.getValue()

    usartBufPool = usartComponent.createBooleanSymbol("DRV_USART_BUFFER_POOL", None)
    usartBufPool.setLabel("**** Buffer Pool Update ****")
    usartBufPool.setDependencies(bufferPoolSize, ["DRV_USART_TX_QUEUE_SIZE","DRV_USART_RX_QUEUE_SIZE"])
    usartBufPool.setVisible(False)

    global usartTXDMA
    usartTXDMA = usartComponent.createBooleanSymbol("DRV_USART_TX_DMA", None)
    usartTXDMA.setLabel("Use DMA for Transmit?")
    usartTXDMA.setDefaultValue(False)

    global usartTXDMAChannel
    usartTXDMAChannel = usartComponent.createIntegerSymbol("DRV_USART_TX_DMA_CHANNEL", None)
    usartTXDMAChannel.setLabel("DMA Channel For Transmit")
    usartTXDMAChannel.setDependencies(requestAndAssignTxDMAChannel, ["DRV_USART_TX_DMA"])
    usartTXDMAChannel.setDefaultValue(0)
    usartTXDMAChannel.setVisible(False)
    usartTXDMAChannel.setReadOnly(True)

    global usartTXDMAChannelComment
    usartTXDMAChannelComment = usartComponent.createCommentSymbol("DRV_USART_TX_DMA_CH_COMMENT", None)
    usartTXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Transmit. Check DMA Manager.")
    usartTXDMAChannelComment.setVisible(False)
    usartTXDMAChannelComment.setDependencies(requestTxDMAComment, ["DRV_USART_TX_DMA_CHANNEL"])

    global usartRXDMA
    usartRXDMA = usartComponent.createBooleanSymbol("DRV_USART_RX_DMA", None)
    usartRXDMA.setLabel("Use DMA for Receive?")
    usartRXDMA.setDefaultValue(False)

    global usartRXDMAChannel
    usartRXDMAChannel = usartComponent.createIntegerSymbol("DRV_USART_RX_DMA_CHANNEL", None)
    usartRXDMAChannel.setLabel("DMA Channel For Receive")
    usartRXDMAChannel.setDependencies(requestAndAssignRxDMAChannel, ["DRV_USART_RX_DMA"])
    usartRXDMAChannel.setDefaultValue(1)
    usartRXDMAChannel.setVisible(False)
    usartRXDMAChannel.setReadOnly(True)

    global usartRXDMAChannelComment
    usartRXDMAChannelComment = usartComponent.createCommentSymbol("DRV_USART_RX_DMA_CH_COMMENT", None)
    usartRXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Receive. Check DMA Manager.")
    usartRXDMAChannelComment.setVisible(False)
    usartRXDMAChannelComment.setDependencies(requestRxDMAComment, ["DRV_USART_RX_DMA_CHANNEL"])

    global usartDependencyDMAComment
    usartDependencyDMAComment = usartComponent.createCommentSymbol("DRV_USART_DEPENDENCY_DMA_COMMENT", None)
    usartDependencyDMAComment.setLabel("Satisfy PLIB Dependency to Allocate DMA Channel")
    usartDependencyDMAComment.setVisible(False)

    # DRV_USART Common Dependency
    bufPoolSize = Database.getSymbolValue("drv_usart", "DRV_USART_BUFFER_POOL_SIZE")
    Database.setSymbolValue("drv_usart", "DRV_USART_BUFFER_POOL_SIZE", (bufPoolSize + currentTxBufSize + currentRxBufSize), 1)

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

    # Async Source Files
    usartAsyncSourceFile = usartComponent.createFileSymbol("USART_ASYNC_SOURCE", None)
    usartAsyncSourceFile.setSourcePath("driver/usart/src/async/drv_usart.c")
    usartAsyncSourceFile.setOutputName("drv_usart.c")
    usartAsyncSourceFile.setDestPath("driver/usart/src")
    usartAsyncSourceFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartAsyncSourceFile.setType("SOURCE")
    usartAsyncSourceFile.setOverwrite(True)
    usartAsyncSourceFile.setEnabled(True)
    usartAsyncSourceFile.setDependencies(asyncFileGen, ["DRV_USART_MODE"])

    usartAsyncHeaderLocalFile = usartComponent.createFileSymbol("USART_ASYNC_LOCAL", None)
    usartAsyncHeaderLocalFile.setSourcePath("driver/usart/src/async/drv_usart_local.h")
    usartAsyncHeaderLocalFile.setOutputName("drv_usart_local.h")
    usartAsyncHeaderLocalFile.setDestPath("driver/usart/src")
    usartAsyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartAsyncHeaderLocalFile.setType("SOURCE")
    usartAsyncHeaderLocalFile.setOverwrite(True)
    usartAsyncHeaderLocalFile.setEnabled(True)
    usartAsyncHeaderLocalFile.setDependencies(asyncFileGen, ["DRV_USART_MODE"])

    # Sync Source Files
    usartSyncSourceFile = usartComponent.createFileSymbol("USART_SYNC_SOURCE", None)
    usartSyncSourceFile.setSourcePath("driver/usart/src/sync/drv_usart.c")
    usartSyncSourceFile.setOutputName("drv_usart.c")
    usartSyncSourceFile.setDestPath("driver/usart/src")
    usartSyncSourceFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartSyncSourceFile.setType("SOURCE")
    usartSyncSourceFile.setOverwrite(True)
    usartSyncSourceFile.setEnabled(False)
    usartSyncSourceFile.setDependencies(syncFileGen, ["DRV_USART_MODE"])

    usartSyncHeaderLocalFile = usartComponent.createFileSymbol("USART_SYNC_LOCAL", None)
    usartSyncHeaderLocalFile.setSourcePath("driver/usart/src/sync/drv_usart_local.h")
    usartSyncHeaderLocalFile.setOutputName("drv_usart_local.h")
    usartSyncHeaderLocalFile.setDestPath("driver/usart/src")
    usartSyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartSyncHeaderLocalFile.setType("SOURCE")
    usartSyncHeaderLocalFile.setOverwrite(True)
    usartSyncHeaderLocalFile.setEnabled(False)
    usartSyncHeaderLocalFile.setDependencies(syncFileGen, ["DRV_USART_MODE"])

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

def usartDriverMode(sym, event):
    sym.setValue(Database.getSymbolValue("drv_usart", "DRV_USART_COMMON_MODE"), 1)

def onDependencyConnected(info):
    global usartDependencyDMAComment
    global usartRXDMAChannel
    global usartTXDMAChannel

    dmaRxRequestID = "DMA_CH_NEEDED_FOR_" + info["remoteComponent"].getID().upper() + "_Receive"
    dmaTxRequestID = "DMA_CH_NEEDED_FOR_" + info["remoteComponent"].getID().upper() + "_Transmit"
    dmaTxChannelID = "DMA_CH_FOR_" + info["remoteComponent"].getID().upper() + "_Transmit"
    dmaRxChannelID = "DMA_CH_FOR_" + info["remoteComponent"].getID().upper() + "_Receive"

    localComponent = info["localComponent"]
    if info["dependencyID"] == "drv_usart_UART_dependency" :
        localComponent.setSymbolValue("DRV_USART_PLIB_CONNECTION", True, 2)
        plibUsed = localComponent.getSymbolByID("DRV_USART_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(info["remoteComponent"].getID().upper(), 1)
        usartDependencyDMAComment.setVisible(False)
        if localComponent.getSymbolValue("DRV_USART_TX_DMA") == True:
            usartTXDMAChannel.setVisible(True)
            Database.setSymbolValue("core", dmaTxRequestID, True, 2)
            # Get the allocated channel and assign it
            txChannel = Database.getSymbolValue("core", dmaTxChannelID)
            localComponent.setSymbolValue("DRV_USART_TX_DMA_CHANNEL", txChannel, 2)

        if localComponent.getSymbolValue("DRV_USART_RX_DMA") == True:
            usartRXDMAChannel.setVisible(True)
            Database.setSymbolValue("core", dmaRxRequestID, True, 2)
            # Get the allocated channel and assign it
            rxChannel = Database.getSymbolValue("core", dmaRxChannelID)
            localComponent.setSymbolValue("DRV_USART_RX_DMA_CHANNEL", rxChannel, 2)


def onDependencyDisconnected(info):
    global usartDependencyDMAComment
    global usartRXDMAChannel
    global usartTXDMAChannel
    global usartTXDMAChannelComment
    global usartRXDMAChannelComment

    dmaRxRequestID = "DMA_CH_NEEDED_FOR_" + info["remoteComponent"].getID().upper() + "_Receive"
    dmaTxRequestID = "DMA_CH_NEEDED_FOR_" + info["remoteComponent"].getID().upper() + "_Transmit"
    dmaTxChannelID = "DMA_CH_FOR_" + info["remoteComponent"].getID().upper() + "_Transmit"
    dmaRxChannelID = "DMA_CH_FOR_" + info["remoteComponent"].getID().upper() + "_Receive"

    localComponent = info["localComponent"]

    if info["dependencyID"] == "drv_usart_UART_dependency" :
        localComponent.setSymbolValue("DRV_USART_PLIB_CONNECTION", False, 2)

        if localComponent.getSymbolValue("DRV_USART_TX_DMA") == True:
            usartDependencyDMAComment.setVisible(True)
            usartTXDMAChannel.setVisible(False)
            usartTXDMAChannelComment.setVisible(False)
            Database.setSymbolValue("core", dmaTxRequestID, False, 2)

        if localComponent.getSymbolValue("DRV_USART_RX_DMA") == True:
            usartDependencyDMAComment.setVisible(True)
            usartRXDMAChannel.setVisible(False)
            usartRXDMAChannelComment.setVisible(False)
            Database.setSymbolValue("core", dmaRxRequestID, False, 2)

def requestAndAssignTxDMAChannel(sym, event):
    global drvUsartInstanceSpace
    global usartSymPLIBConnection
    global usartTXDMAChannelComment
    global usartDependencyDMAComment
    global usartRXDMA

    usartPeripheral = Database.getSymbolValue(drvUsartInstanceSpace, "DRV_USART_PLIB")

    dmaChannelID = "DMA_CH_FOR_" + str(usartPeripheral) + "_Transmit"
    dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(usartPeripheral) + "_Transmit"

    if event["value"] == False:
        Database.setSymbolValue("core", dmaRequestID, False, 2)
        usartTXDMAChannelComment.setVisible(False)
        sym.setVisible(False)
        if usartRXDMA.getValue()==False:
            usartDependencyDMAComment.setVisible(False)

    else:
        if (usartSymPLIBConnection.getValue() == True):
            usartDependencyDMAComment.setVisible(False)
            sym.setVisible(True)
            Database.setSymbolValue("core", dmaRequestID, True, 2)
        else:
            usartTXDMAChannelComment.setVisible(False)
            usartDependencyDMAComment.setVisible(True)
            sym.setVisible(False)

    # Get the allocated channel and assign it
    channel = Database.getSymbolValue("core", dmaChannelID)
    sym.setValue(channel, 2)

def requestAndAssignRxDMAChannel(sym, event):
    global drvUsartInstanceSpace
    global usartSymPLIBConnection
    global usartRXDMAChannelComment
    global usartDependencyDMAComment
    global usartTXDMA

    usartPeripheral = Database.getSymbolValue(drvUsartInstanceSpace, "DRV_USART_PLIB")

    dmaChannelID = "DMA_CH_FOR_" + str(usartPeripheral) + "_Receive"
    dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(usartPeripheral) + "_Receive"

    if event["value"] == False:
        Database.setSymbolValue("core", dmaRequestID, False, 2)
        usartRXDMAChannelComment.setVisible(False)
        sym.setVisible(False)
        if usartTXDMA.getValue()==False:
            usartDependencyDMAComment.setVisible(False)
    else:
        if (usartSymPLIBConnection.getValue() == True):
            usartDependencyDMAComment.setVisible(False)
            sym.setVisible(True)
            Database.setSymbolValue("core", dmaRequestID, True, 2)
        else:
            usartRXDMAChannelComment.setVisible(False)
            usartDependencyDMAComment.setVisible(True)
            sym.setVisible(False)

    # Get the allocated channel and assign it
    channel = Database.getSymbolValue("core", dmaChannelID)
    sym.setValue(channel, 2)

def requestTxDMAComment(sym, event):
    global usartSymPLIBConnection
    global usartTXDMA
    if(event["value"] == -2) and (usartTXDMA.getValue()== True) and (usartSymPLIBConnection.getValue() == True):
        sym.setVisible(True)
        event["symbol"].setVisible(False)
    else:
        sym.setVisible(False)

def requestRxDMAComment(sym, event):
    global usartSymPLIBConnection
    global usartRXDMA
    if(event["value"] == -2) and (usartRXDMA.getValue()== True) and (usartSymPLIBConnection.getValue() == True):
        sym.setVisible(True)
        event["symbol"].setVisible(False)
    else:
        sym.setVisible(False)

def destroyComponent(usartComponent):
    global drvUsartInstanceSpace
    usartPeripheral = Database.getSymbolValue(drvUsartInstanceSpace, "DRV_USART_PLIB")

    dmaTxID = "DMA_CH_NEEDED_FOR_" + str(usartPeripheral) + "_Transmit"
    dmaRxID = "DMA_CH_NEEDED_FOR_" + str(usartPeripheral) + "_Receive"

    Database.setSymbolValue("core", dmaTxID, False, 2)
    Database.setSymbolValue("core", dmaRxID, False, 2)

def syncModeOptions(sym, event):
    sym.setVisible(event["value"])

def asyncModeOptions(sym, event):
    if(event["value"] == False):
        sym.setVisible(True)
    else:
        sym.setVisible(False)

def syncFileGen(sym, event):
    sym.setEnabled(event["value"])

def asyncFileGen(sym, event):
    if(event["value"] == False):
        sym.setEnabled(True)
    else:
        sym.setEnabled(False)

def bufferPoolSize(sym, event):
    global currentTxBufSize
    global currentRxBufSize

    bufPoolSize = Database.getSymbolValue("drv_usart", "DRV_USART_BUFFER_POOL_SIZE")

    if (event["id"] == "DRV_USART_TX_QUEUE_SIZE"):
        bufPoolSize = bufPoolSize - currentTxBufSize + event["value"]
        currentTxBufSize = event["value"]
    if (event["id"] == "DRV_USART_RX_QUEUE_SIZE"):
        bufPoolSize = bufPoolSize - currentRxBufSize + event["value"]
        currentRxBufSize = event["value"]

    Database.clearSymbolValue("drv_usart", "DRV_USART_BUFFER_POOL_SIZE")
    Database.setSymbolValue("drv_usart", "DRV_USART_BUFFER_POOL_SIZE", bufPoolSize, 2)