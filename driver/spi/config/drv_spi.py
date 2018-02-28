def instantiateComponent(spiComponent, index):
    global drvSpiInstanceSpace
    drvSpiInstanceSpace = "drv_spi_" + str(index)
    
    spiNumInstances = Database.getSymbolValue("drv_spi", "DRV_SPI_NUM_INSTANCES")
  
    if spiNumInstances is None:
        spiNumInstances = 1
    else:
        spiNumInstances = spiNumInstances + 1
    
    Database.clearSymbolValue("drv_spi", "DRV_SPI_NUM_INSTANCES")
    Database.setSymbolValue("drv_spi", "DRV_SPI_NUM_INSTANCES", spiNumInstances, 1)
    
    spiSymIndex = spiComponent.createIntegerSymbol("INDEX", None)
    spiSymIndex.setVisible(False)
    spiSymIndex.setDefaultValue(index)
    
    spiSymPLIB = spiComponent.createStringSymbol("DRV_SPI_PLIB", None)
    spiSymPLIB.setLabel("PLIB Used")
    spiSymPLIB.setReadOnly(True)
    spiSymPLIB.setDefaultValue("SPI0")
    
    spiSymNumClients = spiComponent.createIntegerSymbol("DRV_SPI_NUM_CLIENTS", None)
    spiSymNumClients.setLabel("Number of clients")
    spiSymNumClients.setMin(1)
    spiSymNumClients.setMax(10)
    spiSymNumClients.setDefaultValue(1)
    
    spiSymQueueSize = spiComponent.createIntegerSymbol("DRV_SPI_QUEUE_SIZE", None)
    spiSymQueueSize.setLabel("Transfer Queue Size")
    spiSymQueueSize.setMin(1)
    spiSymQueueSize.setMax(250)
    spiSymQueueSize.setDefaultValue(2)

    spiTXRXDMA = spiComponent.createBooleanSymbol("DRV_SPI_TX_RX_DMA", None)
    spiTXRXDMA.setLabel("Use DMA for Transmit and Receive?")
    spiTXRXDMA.setDefaultValue(False)

    spiTXDMA = spiComponent.createBooleanSymbol("DRV_SPI_TX_DMA", None)
    spiTXDMA.setLabel("Use DMA for Transmit?")
    spiTXDMA.setDefaultValue(False)
    spiTXDMA.setVisible(False)
    spiTXDMA.setDependencies(commonTxRxOption, ["DRV_SPI_TX_RX_DMA"])
    
    spiTXDMAChannel = spiComponent.createIntegerSymbol("DRV_SPI_TX_DMA_CHANNEL", None)
    spiTXDMAChannel.setLabel("DMA Channel For Transmit")
    spiTXDMAChannel.setDefaultValue(0)
    spiTXDMAChannel.setVisible(False)
    spiTXDMAChannel.setReadOnly(True)
    spiTXDMAChannel.setDependencies(requestDMAChannel, ["DRV_SPI_TX_RX_DMA","DRV_SPI_TX_DMA", "core.DMA_CH_FOR_" + str(spiSymPLIB.getValue()) + "_Transmit"])

    spiTXDMAChannelComment = spiComponent.createCommentSymbol("DRV_SPI_TX_DMA_CH_COMMENT", None)
    spiTXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate any DMA Channel. Check DMA manager.")
    spiTXDMAChannelComment.setDependencies(requestDMAComment, ["core.DMA_CH_FOR_" + str(spiSymPLIB.getValue()) + "_Transmit"])
    spiTXDMAChannelComment.setVisible(False)

    spiRXDMA = spiComponent.createBooleanSymbol("DRV_SPI_RX_DMA", None)
    spiRXDMA.setLabel("Use DMA for Receive?")
    spiRXDMA.setDefaultValue(False)
    spiRXDMA.setVisible(False)
    spiRXDMA.setDependencies(commonTxRxOption, ["DRV_SPI_TX_RX_DMA"])
    
    spiRXDMAChannel = spiComponent.createIntegerSymbol("DRV_SPI_RX_DMA_CHANNEL", None)
    spiRXDMAChannel.setLabel("DMA Channel For Receive")
    spiRXDMAChannel.setDefaultValue(1)
    spiRXDMAChannel.setVisible(False)
    spiRXDMAChannel.setReadOnly(True)
    spiRXDMAChannel.setDependencies(requestDMAChannel, ["DRV_SPI_TX_RX_DMA","DRV_SPI_RX_DMA", "core.DMA_CH_FOR_" + str(spiSymPLIB.getValue()) + "_Receive"])

    spiRXDMAChannelComment = spiComponent.createCommentSymbol("DRV_SPI_RX_DMA_CH_COMMENT", None)
    spiRXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate any DMA Channel. Check DMA manager.")
    spiRXDMAChannelComment.setDependencies(requestDMAComment, ["core.DMA_CH_FOR_" + str(spiSymPLIB.getValue()) + "_Receive"])
    spiRXDMAChannelComment.setVisible(False)
    
    ############################################################################
    #### Code Generation ####
    ############################################################################
    
    configName = Variables.get("__CONFIGURATION_NAME")
    
    spiSymHeaderFile = spiComponent.createFileSymbol("DRV_SPI_HEADER", None)
    spiSymHeaderFile.setSourcePath("driver/spi/drv_spi.h")
    spiSymHeaderFile.setOutputName("drv_spi.h")
    spiSymHeaderFile.setDestPath("driver/spi/")
    spiSymHeaderFile.setProjectPath("config/" + configName + "/driver/spi/")
    spiSymHeaderFile.setType("HEADER")
    spiSymHeaderFile.setOverwrite(True)
    
    spiSymHeaderDefFile = spiComponent.createFileSymbol("DRV_SPI_DEF", None)
    spiSymHeaderDefFile.setSourcePath("driver/spi/drv_spi_definitions.h")
    spiSymHeaderDefFile.setOutputName("drv_spi_definitions.h")
    spiSymHeaderDefFile.setDestPath("driver/spi/")
    spiSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/spi/")
    spiSymHeaderDefFile.setType("HEADER")
    spiSymHeaderDefFile.setOverwrite(True)

    spiSymSourceFile = spiComponent.createFileSymbol("DRV_SPI_SOURCE", None)
    spiSymSourceFile.setSourcePath("driver/spi/src/drv_spi.c")
    spiSymSourceFile.setOutputName("drv_spi.c")
    spiSymSourceFile.setDestPath("driver/spi/src")
    spiSymSourceFile.setProjectPath("config/" + configName + "/driver/spi/")
    spiSymSourceFile.setType("SOURCE")
    spiSymSourceFile.setOverwrite(True)

    spiSymHeaderLocalFile = spiComponent.createFileSymbol("DRV_SPI_HEADER_LOCAL", None)
    spiSymHeaderLocalFile.setSourcePath("driver/spi/src/drv_spi_local.h")
    spiSymHeaderLocalFile.setOutputName("drv_spi_local.h")
    spiSymHeaderLocalFile.setDestPath("driver/spi/src")
    spiSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/spi/")
    spiSymHeaderLocalFile.setType("SOURCE")
    spiSymHeaderLocalFile.setOverwrite(True)
    
    spiSymSystemDefIncFile = spiComponent.createFileSymbol("DRV_SPI_SYSTEM_DEF", None)
    spiSymSystemDefIncFile.setType("STRING")
    spiSymSystemDefIncFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    spiSymSystemDefIncFile.setSourcePath("driver/spi/templates/system/system_definitions.h.ftl")
    spiSymSystemDefIncFile.setMarkup(True)
    
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
    
def onDependentComponentAdded(drv_spi, id, spi):
    if id == "drv_spi_SPI_dependency" :
        plibUsed = drv_spi.getSymbolByID("DRV_SPI_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(spi.getID().upper(), 1)
        spi.setSymbolValue("SPI_INTERRUPT_MODE", True, 1)
        #spiIntSymPLIB = spi.getSymbolByID("SPI_INTERRUPT_MODE")
        #spiIntSymPLIB.setReadOnly(True)

def requestDMAChannel(Sym, event):
    global drvSpiInstanceSpace
    spiPeripheral = Database.getSymbolValue(drvSpiInstanceSpace, "DRV_SPI_PLIB")
    
    # Control visibility
    if event["id"] == "DRV_SPI_TX_RX_DMA":
        Sym.setVisible(event["value"])
        
    # Request from Driver
    elif event["id"] == "DRV_SPI_TX_DMA" or event["id"] == "DRV_SPI_RX_DMA":
        if event["id"] == "DRV_SPI_TX_DMA":
            dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Transmit"
        elif event["id"] == "DRV_SPI_RX_DMA":
            dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Receive"

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
        
def commonTxRxOption(Sym, event):
    Sym.setValue(event["value"], 1)

def destroyComponent(spiComponent):
    print("bug_arpan")
    spiNumInstances = Database.getSymbolValue("drv_spi", "DRV_SPI_NUM_INSTANCES")   
    spiNumInstances = spiNumInstances - 1   
    Database.setSymbolValue("drv_spi", "DRV_SPI_NUM_INSTANCES", spiNumInstances, 1)
