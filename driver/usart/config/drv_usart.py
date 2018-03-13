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

    usartTXQueueSize = usartComponent.createIntegerSymbol("DRV_USART_TX_QUEUE_SIZE", None)
    usartTXQueueSize.setLabel("Transmit Queue Size")
    usartTXQueueSize.setMax(50)
    usartTXQueueSize.setDefaultValue(5)
    currentTxBufSize = usartTXQueueSize.getValue()


    usartRXQueueSize = usartComponent.createIntegerSymbol("DRV_USART_RX_QUEUE_SIZE", None)
    usartRXQueueSize.setLabel("Receive Queue Size")
    usartRXQueueSize.setMax(50)
    usartRXQueueSize.setDefaultValue(5)
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

    usartHeaderFile = usartComponent.createFileSymbol("USART_HEADER", None)
    usartHeaderFile.setSourcePath("driver/usart/drv_usart.h")
    usartHeaderFile.setOutputName("drv_usart.h")
    usartHeaderFile.setDestPath("driver/usart/")
    usartHeaderFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartHeaderFile.setType("HEADER")
    usartHeaderFile.setOverwrite(True)

    usartHeaderDefFile = usartComponent.createFileSymbol("USART_DEF", None)
    usartHeaderDefFile.setSourcePath("driver/usart/drv_usart_definitions.h")
    usartHeaderDefFile.setOutputName("drv_usart_definitions.h")
    usartHeaderDefFile.setDestPath("driver/usart/")
    usartHeaderDefFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartHeaderDefFile.setType("HEADER")
    usartHeaderDefFile.setOverwrite(True)

    usartSourceFile = usartComponent.createFileSymbol("USART_SOURCE", None)
    usartSourceFile.setSourcePath("driver/usart/src/drv_usart.c")
    usartSourceFile.setOutputName("drv_usart.c")
    usartSourceFile.setDestPath("driver/usart/src")
    usartSourceFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartSourceFile.setType("SOURCE")
    usartSourceFile.setOverwrite(True)

    usartHeaderLocalFile = usartComponent.createFileSymbol("USART_LOCAL", None)
    usartHeaderLocalFile.setSourcePath("driver/usart/src/drv_usart_local.h")
    usartHeaderLocalFile.setOutputName("drv_usart_local.h")
    usartHeaderLocalFile.setDestPath("driver/usart/src")
    usartHeaderLocalFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartHeaderLocalFile.setType("SOURCE")
    usartHeaderLocalFile.setOverwrite(True)

    usartSystemDefFile = usartComponent.createFileSymbol("USART_DEF", None)
    usartSystemDefFile.setType("STRING")
    usartSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    usartSystemDefFile.setSourcePath("driver/usart/templates/system/system_definitions.h.ftl")
    usartSystemDefFile.setMarkup(True)

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
