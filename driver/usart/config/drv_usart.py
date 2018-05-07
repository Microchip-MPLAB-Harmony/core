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

    if event["id"] == "DRV_USART_TX_DMA":
        dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(usartPeripheral) + "_Transmit"
        dmaChannelID = "DMA_CH_FOR_" + str(usartPeripheral) + "_Transmit"
    elif event["id"] == "DRV_USART_RX_DMA":
        dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(usartPeripheral) + "_Receive"
        dmaChannelID = "DMA_CH_FOR_" + str(usartPeripheral) + "_Receive"

    # Request/Release a channel
    Database.setSymbolValue("core", dmaRequestID, event["value"], 2)

    # Get the allocated channel
    channel = Database.getSymbolValue("core", dmaChannelID)
    if channel >= 0:
        Sym.clearValue()
        Sym.setValue(Database.getSymbolValue("core", dmaChannelID), 2)

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

################################################################################
#### Component ####
################################################################################
def instantiateComponent(usartComponent, index):
    global currentTxBufSize
    global currentRxBufSize
    global drvUsartInstanceSpace
    drvUsartInstanceSpace = "drv_usart_" + str(index)

    # Enable dependent Harmony core components
    Database.clearSymbolValue("Harmony", "ENABLE_DRV_COMMON")
    Database.setSymbolValue("Harmony", "ENABLE_DRV_COMMON", True, 2)

    Database.clearSymbolValue("Harmony", "ENABLE_SYS_INT")
    Database.setSymbolValue("Harmony", "ENABLE_SYS_INT", True, 2)

    Database.clearSymbolValue("Harmony", "ENABLE_SYS_DMA")
    Database.setSymbolValue("Harmony", "ENABLE_SYS_DMA", True, 2)

    Database.clearSymbolValue("Harmony", "ENABLE_OSAL")
    Database.setSymbolValue("Harmony", "ENABLE_OSAL", True, 2)

    Database.clearSymbolValue("Harmony", "ENABLE_APP_FILE")
    Database.setSymbolValue("Harmony", "ENABLE_APP_FILE", True, 2)

    # Menu
    usartIndex = usartComponent.createIntegerSymbol("INDEX", None)
    usartIndex.setVisible(False)
    usartIndex.setDefaultValue(index)

    usartPLIB = usartComponent.createStringSymbol("DRV_USART_PLIB", None)
    usartPLIB.setLabel("PLIB Used")
    usartPLIB.setReadOnly(True)
    usartPLIB.setDefaultValue("USART1")
    # Used onDependencyComponentAdd\Remove callbacks to get connected PLIB

    usartNumClients = usartComponent.createIntegerSymbol("DRV_USART_CLIENTS_NUM", None)
    usartNumClients.setLabel("Number of Clients")
    usartNumClients.setMax(50)
    usartNumClients.setVisible(False)
    usartNumClients.setDefaultValue(1)
    usartNumClients.setDependencies(syncModeOptions, ["drv_usart.DRV_USART_MODE"])

    usartTXQueueSize = usartComponent.createIntegerSymbol("DRV_USART_TX_QUEUE_SIZE", None)
    usartTXQueueSize.setLabel("Transmit Queue Size")
    usartTXQueueSize.setMax(50)
    usartTXQueueSize.setDefaultValue(5)
    usartTXQueueSize.setDependencies(asyncModeOptions, ["drv_usart.DRV_USART_MODE"])
    currentTxBufSize = usartTXQueueSize.getValue()

    usartRXQueueSize = usartComponent.createIntegerSymbol("DRV_USART_RX_QUEUE_SIZE", None)
    usartRXQueueSize.setLabel("Receive Queue Size")
    usartRXQueueSize.setMax(50)
    usartRXQueueSize.setDefaultValue(5)
    usartRXQueueSize.setDependencies(asyncModeOptions, ["drv_usart.DRV_USART_MODE"])
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
    usartTXDMAChannel.setDependencies(requestDMAChannel, ["DRV_USART_TX_DMA"])
    usartTXDMAChannel.setDefaultValue(0)
    usartTXDMAChannel.setVisible(False)

    usartRXDMA = usartComponent.createBooleanSymbol("DRV_USART_RX_DMA", None)
    usartRXDMA.setLabel("Use DMA for Receive?")
    usartRXDMA.setDefaultValue(False)

    usartRXDMAChannel = usartComponent.createIntegerSymbol("DRV_USART_RX_DMA_CHANNEL", None)
    usartRXDMAChannel.setLabel("DMA Channel To Use")
    usartRXDMAChannel.setDependencies(requestDMAChannel, ["DRV_USART_RX_DMA"])
    usartRXDMAChannel.setDefaultValue(1)
    usartRXDMAChannel.setVisible(False)

    ############################################################################
    #### Dependency ####
    ############################################################################
    # DRV_USART Common Dependency

    numInstances  = Database.getSymbolValue("drv_usart", "DRV_USART_NUM_INSTANCES")
    numInstances = numInstances + 1
    Database.setSymbolValue("drv_usart", "DRV_USART_NUM_INSTANCES", numInstances, 1)

    bufPoolSize = Database.getSymbolValue("drv_usart", "DRV_USART_BUFFER_POOL_SIZE")
    Database.setSymbolValue("drv_usart", "DRV_USART_BUFFER_POOL_SIZE", (bufPoolSize + currentTxBufSize + currentRxBufSize), 1)

    ############################################################################
    #### Code Generation ####
    ############################################################################

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
    if id == "drv_usart_USART_dependency" or id == "drv_usart_UART_dependency":
        plibUsed = drv_usart.getSymbolByID("DRV_USART_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(usart.getID().upper(), 2)
