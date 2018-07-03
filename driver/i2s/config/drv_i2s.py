def requestDMAChannel(Sym, event):
    global drvSpiInstanceSpace
    sscPeripheral = Database.getSymbolValue(drvSpiInstanceSpace, "DRV_SSC_PLIB")
    
    # Control visibility
    if event["id"] == "DRV_SSC_TX_RX_DMA":
        Sym.setVisible(event["value"])
        
    # Request from Driver
    elif event["id"] == "DRV_SSC_TX_DMA" or event["id"] == "DRV_SSC_RX_DMA":
        if event["id"] == "DRV_SSC_TX_DMA":
            dmaRequestID = "DMA_CH_NEEDED_FOR_" + "SSC" + "_Transmit"
        elif event["id"] == "DRV_SSC_RX_DMA":
            dmaRequestID = "DMA_CH_NEEDED_FOR_" + "SSC" + "_Receive"

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

def destroyComponent(i2sComponent):
    i2sNumInstances = Database.getSymbolValue("drv_i2s", "DRV_I2S_NUM_INSTANCES")   
    i2sNumInstances = i2sNumInstances - 1   
    Database.setSymbolValue("drv_i2s", "DRV_I2S_NUM_INSTANCES", i2sNumInstances, 1)

def instantiateComponent(i2sComponent, index):
    global drvSpiInstanceSpace
    drvSpiInstanceSpace = "drv_i2s_" + str(index)
    
    i2sNumInstances = Database.getSymbolValue("drv_i2s", "DRV_I2S_NUM_INSTANCES")
  
    if i2sNumInstances is None:
        i2sNumInstances = 1
    else:
        i2sNumInstances = i2sNumInstances + 1
    
    Database.clearSymbolValue("drv_i2s", "DRV_I2S_NUM_INSTANCES")
    Database.setSymbolValue("drv_i2s", "DRV_I2S_NUM_INSTANCES", i2sNumInstances, 1)
    
    i2sSymIndex = i2sComponent.createIntegerSymbol("INDEX", None)
    i2sSymIndex.setVisible(False)
    i2sSymIndex.setDefaultValue(index)
    
    i2sSymPLIB = i2sComponent.createStringSymbol("DRV_I2S_PLIB", None)
    i2sSymPLIB.setVisible(True)
    i2sSymPLIB.setLabel("PLIB Used")
    i2sSymPLIB.setReadOnly(True)
    i2sSymPLIB.setDefaultValue("SSC")
    
    i2sSymNumClients = i2sComponent.createIntegerSymbol("DRV_I2S_NUM_CLIENTS", None)
    i2sSymNumClients.setVisible(True)
    i2sSymNumClients.setLabel("Number of clients")
    i2sSymNumClients.setMin(1)
    i2sSymNumClients.setMax(10)
    i2sSymNumClients.setDefaultValue(1)
    
    i2sSymQueueSize = i2sComponent.createIntegerSymbol("DRV_I2S_QUEUE_SIZE", None)
    i2sSymQueueSize.setVisible(True)
    i2sSymQueueSize.setLabel("Transfer Queue Size")
    i2sSymQueueSize.setMin(1)
    i2sSymQueueSize.setMax(250)
    i2sSymQueueSize.setDefaultValue(8)

    i2sDataWidth = i2sComponent.createIntegerSymbol("I2S_DATA_LENGTH", None)
    i2sDataWidth.setVisible(False)
    i2sDataWidth.setDefaultValue(0)  

    # FUTURE -- need to create either SSC or I2SC symbols for DMA based on peripheral chosen (DRV_I2S_PLIB)
    i2sTXRXDMA = i2sComponent.createBooleanSymbol("DRV_SSC_TX_RX_DMA", None)
    i2sTXRXDMA.setVisible(True)
    i2sTXRXDMA.setLabel("Use DMA for Transmit and Receive?")
    i2sTXRXDMA.setDefaultValue(False)

    i2sTXDMA = i2sComponent.createBooleanSymbol("DRV_SSC_TX_DMA", None)
    i2sTXDMA.setLabel("Use DMA for Transmit?")
    i2sTXDMA.setDefaultValue(True)
    i2sTXDMA.setVisible(True)
    i2sTXDMA.setDependencies(commonTxRxOption, ["DRV_SSC_TX_RX_DMA"])
    
    i2sTXDMAChannel = i2sComponent.createIntegerSymbol("DRV_SSC_TX_DMA_CHANNEL", None)
    i2sTXDMAChannel.setLabel("DMA Channel For Transmit")
    i2sTXDMAChannel.setDefaultValue(0)
    i2sTXDMAChannel.setVisible(True)
    i2sTXDMAChannel.setReadOnly(True)
    i2sTXDMAChannel.setDependencies(requestDMAChannel, ["DRV_SSC_TX_RX_DMA","DRV_SSC_TX_DMA", "core.DMA_CH_FOR_" + "SSC" + "_Transmit"])

    i2sTXDMAChannelComment = i2sComponent.createCommentSymbol("DRV_SSC_TX_DMA_CH_COMMENT", None)
    i2sTXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate any DMA Channel. Check DMA manager.")
    i2sTXDMAChannelComment.setDependencies(requestDMAComment, ["core.DMA_CH_FOR_" + "SSC" + "_Transmit"])
    i2sTXDMAChannelComment.setVisible(False)

    i2sRXDMA = i2sComponent.createBooleanSymbol("DRV_SSC_RX_DMA", None)
    i2sRXDMA.setLabel("Use DMA for Receive?")
    i2sRXDMA.setDefaultValue(True)
    i2sRXDMA.setVisible(True)
    i2sRXDMA.setDependencies(commonTxRxOption, ["DRV_SSC_TX_RX_DMA"])
    
    i2sRXDMAChannel = i2sComponent.createIntegerSymbol("DRV_SSC_RX_DMA_CHANNEL", None)
    i2sRXDMAChannel.setLabel("DMA Channel For Receive")
    i2sRXDMAChannel.setDefaultValue(1)
    i2sRXDMAChannel.setVisible(True)
    i2sRXDMAChannel.setReadOnly(True)
    i2sRXDMAChannel.setDependencies(requestDMAChannel, ["DRV_SSC_TX_RX_DMA","DRV_SSC_RX_DMA", "core.DMA_CH_FOR_" + "SSC" + "_Receive"])

    i2sRXDMAChannelComment = i2sComponent.createCommentSymbol("DRV_SSC_RX_DMA_CH_COMMENT", None)
    i2sRXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate any DMA Channel. Check DMA manager.")
    i2sRXDMAChannelComment.setDependencies(requestDMAComment, ["core.DMA_CH_FOR_" + "SSC" + "_Receive"])
    i2sRXDMAChannelComment.setVisible(False)
    
    ############################################################################
    #### Code Generation ####
    ############################################################################
    
    configName = Variables.get("__CONFIGURATION_NAME")
    
    i2sSymHeaderFile = i2sComponent.createFileSymbol("DRV_I2S_HEADER", None)
    i2sSymHeaderFile.setSourcePath("driver/i2s/drv_i2s.h")
    i2sSymHeaderFile.setOutputName("drv_i2s.h")
    i2sSymHeaderFile.setDestPath("driver/i2s/")
    i2sSymHeaderFile.setProjectPath("config/" + configName + "/driver/i2s/")
    i2sSymHeaderFile.setType("HEADER")
    i2sSymHeaderFile.setOverwrite(True)
    
    i2sSymHeaderDefFile = i2sComponent.createFileSymbol("DRV_I2S_DEF", None)
    i2sSymHeaderDefFile.setSourcePath("driver/i2s/drv_i2s_definitions.h")
    i2sSymHeaderDefFile.setOutputName("drv_i2s_definitions.h")
    i2sSymHeaderDefFile.setDestPath("driver/i2s/")
    i2sSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/i2s/")
    i2sSymHeaderDefFile.setType("HEADER")
    i2sSymHeaderDefFile.setOverwrite(True)

    i2sSymSourceFile = i2sComponent.createFileSymbol("DRV_I2S_SOURCE", None)
    i2sSymSourceFile.setSourcePath("driver/i2s/src/drv_i2s.c")
    i2sSymSourceFile.setOutputName("drv_i2s.c")
    i2sSymSourceFile.setDestPath("driver/i2s/src")
    i2sSymSourceFile.setProjectPath("config/" + configName + "/driver/i2s/")
    i2sSymSourceFile.setType("SOURCE")
    i2sSymSourceFile.setOverwrite(True)

    i2sSymHeaderLocalFile = i2sComponent.createFileSymbol("DRV_I2S_HEADER_LOCAL", None)
    i2sSymHeaderLocalFile.setSourcePath("driver/i2s/src/drv_i2s_local.h")
    i2sSymHeaderLocalFile.setOutputName("drv_i2s_local.h")
    i2sSymHeaderLocalFile.setDestPath("driver/i2s/src")
    i2sSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/i2s/")
    i2sSymHeaderLocalFile.setType("SOURCE")
    i2sSymHeaderLocalFile.setOverwrite(True)
    
    i2sSymSystemDefIncFile = i2sComponent.createFileSymbol("DRV_I2S_SYSTEM_DEF", None)
    i2sSymSystemDefIncFile.setType("STRING")
    i2sSymSystemDefIncFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    i2sSymSystemDefIncFile.setSourcePath("driver/i2s/templates/system/system_definitions.h.ftl")
    i2sSymSystemDefIncFile.setMarkup(True)
    
    i2sSymSystemDefObjFile = i2sComponent.createFileSymbol("DRV_I2S_SYSTEM_DEF_OBJECT", None)
    i2sSymSystemDefObjFile.setType("STRING")
    i2sSymSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    i2sSymSystemDefObjFile.setSourcePath("driver/i2s/templates/system/system_definitions_objects.h.ftl")
    i2sSymSystemDefObjFile.setMarkup(True)

    i2sSymSystemConfigFile = i2sComponent.createFileSymbol("DRV_I2S_SYSTEM_CONFIG", None)
    i2sSymSystemConfigFile.setType("STRING")
    i2sSymSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    i2sSymSystemConfigFile.setSourcePath("driver/i2s/templates/system/system_config.h.ftl")
    i2sSymSystemConfigFile.setMarkup(True)

    i2sSymSystemInitDataFile = i2sComponent.createFileSymbol("DRV_I2S_INIT_DATA", None)
    i2sSymSystemInitDataFile.setType("STRING")
    i2sSymSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    i2sSymSystemInitDataFile.setSourcePath("driver/i2s/templates/system/system_initialize_data.c.ftl")
    i2sSymSystemInitDataFile.setMarkup(True)

    i2sSymSystemInitFile = i2sComponent.createFileSymbol("DRV_I2S_SYS_INIT", None)
    i2sSymSystemInitFile.setType("STRING")
    i2sSymSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")  
    i2sSymSystemInitFile.setSourcePath("driver/i2s/templates/system/system_initialize.c.ftl")
    i2sSymSystemInitFile.setMarkup(True)
    
def onDependentComponentAdded(i2sComponent, id, i2sPlib):
    if id == "drv_i2s_I2S_dependency":
        plibUsed = i2sComponent.getSymbolByID("DRV_I2S_PLIB")
        plibUsed.clearValue()
        # i2sPlib.getID() returns ssc0 for example
        i2sPlibId = i2sPlib.getID()
        plibUsed.setValue(i2sPlibId.upper(), 1)
        if i2sPlibId[:3] == "ssc":        
            dataLength = i2sPlib.getSymbolValue("SSC_DATA_LENGTH")
            i2sDataWidth = i2sComponent.getSymbolByID("I2S_DATA_LENGTH")
            i2sDataWidth.setValue(dataLength, 1)
            i2sTXRXDMA = i2sComponent.getSymbolByID("DRV_SSC_TX_RX_DMA")
            i2sTXRXDMA.setValue(True, 1)



