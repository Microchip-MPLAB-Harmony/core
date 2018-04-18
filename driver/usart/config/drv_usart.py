################################################################################
#### Global Variables ####
################################################################################
global currentTxBufSize
global currentRxBufSize
global drvUsartInstanceSpace

################################################################################
#### Business Logic ####
################################################################################
def bufferPoolSize(Sym, event):
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

def requestDMAChannel(Sym, event):
    global drvUsartInstanceSpace
    usartPeripheral = Database.getSymbolValue(drvUsartInstanceSpace, "DRV_USART_PLIB")

    # Request from Driver
    if event["id"] == "DRV_USART_TX_DMA" or event["id"] == "DRV_USART_RX_DMA":
        if event["id"] == "DRV_USART_TX_DMA":
            dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(usartPeripheral) + "_Transmit"
        elif event["id"] == "DRV_USART_RX_DMA":
            dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(usartPeripheral) + "_Receive"

        Database.clearSymbolValue("core", dmaRequestID)
        Database.setSymbolValue("core", dmaRequestID, event["value"], 2)

    # Response from DMA Manager
    else:
        Sym.clearValue()
        Sym.setValue(event["value"], 2)

def requestDMAComment(Sym, event):
    if(event["value"] == -2):
        Sym.setVisible(True)
    else:
        Sym.setVisible(False)

def syncModeOptions(Sym, event):
    if(event["value"] == 1):
       Sym.setVisible(True)
    elif(event["value"] == 0):
       Sym.setVisible(False)

def asyncModeOptions(Sym, event):
    if(event["value"] == 0):
       Sym.setVisible(True)
    elif(event["value"] == 1):
       Sym.setVisible(False)

def syncFileGen(Sym, event):
    if(event["value"] == 1):
       Sym.setEnabled(True)
    elif(event["value"] == 0):
       Sym.setEnabled(False)

def asyncFileGen(Sym, event):
    if(event["value"] == 0):
       Sym.setEnabled(True)
    elif(event["value"] == 1):
       Sym.setEnabled(False)

def driverModeUpdate(Sym, event):
    global drvUsartInstanceSpace
    bufPoolSize = Database.getSymbolValue("drv_usart", "DRV_USART_COMMON_MODE")
    Database.clearSymbolValue("drv_usart", "DRV_USART_COMMON_MODE")

    if(event["value"] == 0):
        Database.setSymbolValue("drv_usart", "DRV_USART_COMMON_MODE", event["value"], 2)
    elif(event["value"] == 1):
        Database.setSymbolValue("drv_usart", "DRV_USART_COMMON_MODE", event["value"], 2)

################################################################################
#### Component ####
################################################################################
def instantiateComponent(usartComponent, index):
    global currentTxBufSize
    global currentRxBufSize
    global drvUsartInstanceSpace
    drvUsartInstanceSpace = "drv_usart_" + str(index)

    usartIndex = usartComponent.createIntegerSymbol("INDEX", None)
    usartIndex.setVisible(False)
    usartIndex.setDefaultValue(index)

    usartPLIB = usartComponent.createStringSymbol("DRV_USART_PLIB", None)
    usartPLIB.setLabel("PLIB Used")
    usartPLIB.setReadOnly(True)
    usartPLIB.setDefaultValue("USART1")
    # Used onDependencyComponentAdd\Remove callbacks to get connected PLIB

    usartMode = usartComponent.createKeyValueSetSymbol("DRV_USART_MODE", None)
    usartMode.setLabel("Driver Mode")
    usartMode.addKey("ASYNC", "0", "Asynchronous")
    usartMode.addKey("SYNC", "1", "Synchronous")
    usartMode.setDisplayMode("Description")
    usartMode.setOutputMode("Key")
    usartMode.setDefaultValue(0)

    usartGlobalMode = usartComponent.createBooleanSymbol("DRV_USART_MODE_UPDATE", None)
    usartGlobalMode.setLabel("**** Driver Mode Update ****")
    usartGlobalMode.setDependencies(driverModeUpdate, ["DRV_USART_MODE"])
    usartGlobalMode.setVisible(False)

    usartNumClients = usartComponent.createIntegerSymbol("DRV_USART_CLIENTS_NUM", None)
    usartNumClients.setLabel("Number of Clients")
    usartNumClients.setMax(50)
    usartNumClients.setVisible(False)
    usartNumClients.setDefaultValue(1)
    usartNumClients.setDependencies(syncModeOptions, ["DRV_USART_MODE"])

    usartTXQueueSize = usartComponent.createIntegerSymbol("DRV_USART_TX_QUEUE_SIZE", None)
    usartTXQueueSize.setLabel("Transmit Queue Size")
    usartTXQueueSize.setMax(50)
    usartTXQueueSize.setDefaultValue(5)
    usartTXQueueSize.setDependencies(asyncModeOptions, ["DRV_USART_MODE"])
    currentTxBufSize = usartTXQueueSize.getValue()

    usartRXQueueSize = usartComponent.createIntegerSymbol("DRV_USART_RX_QUEUE_SIZE", None)
    usartRXQueueSize.setLabel("Receive Queue Size")
    usartRXQueueSize.setMax(50)
    usartRXQueueSize.setDefaultValue(5)
    usartRXQueueSize.setDependencies(asyncModeOptions, ["DRV_USART_MODE"])
    currentRxBufSize = usartRXQueueSize.getValue()

    usartBufPool = usartComponent.createBooleanSymbol("DRV_USART_BUFFER_POOL", None)
    usartBufPool.setLabel("**** Buffer Pool Update ****")
    usartBufPool.setDependencies(bufferPoolSize, ["DRV_USART_TX_QUEUE_SIZE","DRV_USART_RX_QUEUE_SIZE"])
    usartBufPool.setVisible(False)

    usartTXDMA = usartComponent.createBooleanSymbol("DRV_USART_TX_DMA", None)
    usartTXDMA.setLabel("Use DMA for Transmit?")
    usartTXDMA.setDefaultValue(False)

    usartTXDMAChannel = usartComponent.createIntegerSymbol("DRV_USART_TX_DMA_CHANNEL", None)
    usartTXDMAChannel.setLabel("DMA Channel To Use")
    usartTXDMAChannel.setDependencies(requestDMAChannel, ["DRV_USART_TX_DMA", "core.DMA_CH_FOR_" + str(usartPLIB.getValue()) + "_Transmit"])
    usartTXDMAChannel.setDefaultValue(0)
    usartTXDMAChannel.setVisible(False)

    usartTXDMAChannelComment = usartComponent.createCommentSymbol("DRV_USART_TX_DMA_CH_COMMENT", None)
    usartTXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate any DMA Channel. Check DMA manager.")
    usartTXDMAChannelComment.setDependencies(requestDMAComment, ["core.DMA_CH_FOR_" + str(usartPLIB.getValue()) + "_Transmit"])
    usartTXDMAChannelComment.setVisible(False)

    usartRXDMA = usartComponent.createBooleanSymbol("DRV_USART_RX_DMA", None)
    usartRXDMA.setLabel("Use DMA for Receive?")
    usartRXDMA.setDefaultValue(False)

    usartRXDMAChannel = usartComponent.createIntegerSymbol("DRV_USART_RX_DMA_CHANNEL", None)
    usartRXDMAChannel.setLabel("DMA Channel To Use")
    usartRXDMAChannel.setDependencies(requestDMAChannel, ["DRV_USART_RX_DMA", "core.DMA_CH_FOR_" + str(usartPLIB.getValue()) + "_Receive"])
    usartRXDMAChannel.setDefaultValue(1)
    usartRXDMAChannel.setVisible(False)

    usartRXDMAChannelComment = usartComponent.createCommentSymbol("DRV_USART_RX_DMA_CH_COMMENT", None)
    usartRXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate any DMA Channel. Check DMA manager.")
    usartRXDMAChannelComment.setDependencies(requestDMAComment, ["core.DMA_CH_FOR_" + str(usartPLIB.getValue()) + "_Receive"])
    usartRXDMAChannelComment.setVisible(False)

    ############################################################################
    #### Dependency ####
    ############################################################################
    # DRV_USART Common Dependency
    try:
        numInstances  = Database.getSymbolValue("drv_usart", "DRV_USART_NUM_INSTANCES")
        bufPoolSize = Database.getSymbolValue("drv_usart", "DRV_USART_BUFFER_POOL_SIZE")

        Database.clearSymbolValue("drv_usart", "DRV_USART_BUFFER_POOL_SIZE")
        Database.setSymbolValue("drv_usart", "DRV_USART_BUFFER_POOL_SIZE", (bufPoolSize + currentTxBufSize + currentRxBufSize), 2)

        if numInstances < (index+1):
            Database.clearSymbolValue("drv_usart", "DRV_USART_NUM_INSTANCES")
            Database.setSymbolValue("drv_usart", "DRV_USART_NUM_INSTANCES", (index+1), 2)
    except:
        Log.writeDebugMessage("USART driver common file error")

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

    usartHeaderDefFile = usartComponent.createFileSymbol("USART_HEADER_DEF", None)
    usartHeaderDefFile.setSourcePath("driver/usart/templates/drv_usart_definitions.h.ftl")
    usartHeaderDefFile.setOutputName("drv_usart_definitions.h")
    usartHeaderDefFile.setDestPath("driver/usart/")
    usartHeaderDefFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartHeaderDefFile.setType("HEADER")
    usartHeaderDefFile.setMarkup(True)
    usartHeaderDefFile.setOverwrite(True)

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

def onDependentComponentAdded(drv_usart, id, usart):
    if id == "drv_usart_USART_dependency" :
        plibUsed = drv_usart.getSymbolByID("DRV_USART_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(usart.getID().upper(), 2)
