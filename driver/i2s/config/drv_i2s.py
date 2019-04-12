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

def customUpdate(linkedList, event):
    global customVisible 
    global i2sLinkedListComment

    if event["value"]==1:
        customVisible = True    
    else:
        customVisible = False

    i2sLinkedListComment.setVisible(customVisible)

def requestDMAChannel(Sym, event):
    global i2sPlibId
    global dmaChannelRequests

    # Control visibility
    if event["id"] == "DRV_I2S_TX_RX_DMA":
        Sym.setVisible(event["value"])
        
    # Request from Driver
    elif event["id"] == "DRV_I2S_TX_DMA" or event["id"] == "DRV_I2S_RX_DMA":
        dmaRequestID = ""
        if event["id"] == "DRV_I2S_TX_DMA":
            if i2sPlibId[:3] == "SSC":
                dmaRequestID = "DMA_CH_NEEDED_FOR_SSC_Transmit"
            elif (i2sPlibId[:4] == "I2SC"):
                dmaRequestID = "DMA_CH_NEEDED_FOR_" + i2sPlibId + "_Transmit_Left"
            elif (i2sPlibId[:3] == "I2S"):
                dmaRequestID = "DMA_CH_NEEDED_FOR_" + i2sPlibId + "_Transmit_0"
        elif event["id"] == "DRV_I2S_RX_DMA":
            if i2sPlibId[:3] == "SSC":
                dmaRequestID = "DMA_CH_NEEDED_FOR_SSC_Receive"
            elif (i2sPlibId[:4] == "I2SC"):
                dmaRequestID = "DMA_CH_NEEDED_FOR_" + i2sPlibId + "_Receive_Left"
            elif (i2sPlibId[:3] == "I2S"):
                dmaRequestID = "DMA_CH_NEEDED_FOR_" + i2sPlibId + "_Receive_0"
        if dmaRequestID!="":
            Database.clearSymbolValue("core", dmaRequestID)
            Database.setSymbolValue("core", dmaRequestID, event["value"])
            dmaChannelRequests.append(dmaRequestID)

    # Response from DMA Manager
    else:
        Sym.clearValue()
        Sym.setValue(event["value"])

def requestDMAComment(Sym, event):
    if(event["value"] == -2):
        Sym.setVisible(True)
    else:
        Sym.setVisible(False)        
        
def commonTxRxOption(Sym, event):
    Sym.setValue(event["value"])

def instantiateComponent(i2sComponent, index):
    global i2sPlibId
    global customVisible 
    global i2sLinkedListComment
    global dmaChannelRequests

    customVisible = False
    customVisible2 = False
    dmaChannelRequests = []

    # Enable "Generate Harmony Driver Common Files" option in MHC
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON") == False):
        Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True)

    # Enable "Generate Harmony System Service Common Files" option in MHC
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON") == False):
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")

    i2sSymIndex = i2sComponent.createIntegerSymbol("INDEX", None)
    i2sSymIndex.setVisible(False)
    i2sSymIndex.setDefaultValue(index)
    
    i2sSymPLIB = i2sComponent.createStringSymbol("DRV_I2S_PLIB", None)
    i2sSymPLIB.setVisible(True)
    i2sSymPLIB.setLabel("PLIB Used")
    i2sSymPLIB.setReadOnly(True)
    i2sSymPLIB.setDefaultValue("")
    i2sPlibId = "" 
    
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
    i2sDataWidth.setVisible(True)
    i2sDataWidth.setLabel("I2S Data Length")
    i2sDataWidth.setDefaultValue(0)

    i2sDataLengthComment = i2sComponent.createCommentSymbol("I2S_DATA_LENGTH_COMMENT", None)
    i2sDataLengthComment.setVisible(True)
    i2sDataLengthComment.setLabel("Must match Data Length field in I2SC/SSC PLIB")") 

    i2sTXRXDMA = i2sComponent.createBooleanSymbol("DRV_I2S_TX_RX_DMA", None)
    i2sTXRXDMA.setVisible(True)
    i2sTXRXDMA.setLabel("Use DMA for Transmit and Receive?")
    i2sTXRXDMA.setDefaultValue(False)

    i2sTXDMA = i2sComponent.createBooleanSymbol("DRV_I2S_TX_DMA", None)
    i2sTXDMA.setLabel("Use DMA for Transmit?")
    i2sTXDMA.setDefaultValue(True)
    i2sTXDMA.setVisible(True)
    i2sTXDMA.setDependencies(commonTxRxOption, ["DRV_I2S_TX_RX_DMA"])
    
    i2sTXDMAChannel = i2sComponent.createIntegerSymbol("DRV_I2S_TX_DMA_CHANNEL", None)
    i2sTXDMAChannel.setLabel("DMA Channel for Transmit")
    i2sTXDMAChannel.setDefaultValue(0)
    i2sTXDMAChannel.setVisible(True)
    i2sTXDMAChannel.setReadOnly(False)
    i2sTXDMAChannel.setDependencies(requestDMAChannel, ["DRV_I2S_TX_RX_DMA","DRV_I2S_TX_DMA", "core.DMA_CH_FOR_SSC_Transmit", "core.DMA_CH_FOR_I2SC0_Transmit_Left", "core.DMA_CH_FOR_I2SC1_Transmit_Left", "core.DMA_CH_FOR_I2S_Transmit_0"])

    i2sTXDMAChannelComment = i2sComponent.createCommentSymbol("DRV_I2S_TX_DMA_CH_COMMENT", None)
    i2sTXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate any DMA Channel. Check DMA manager.")
    i2sTXDMAChannelComment.setDependencies(requestDMAComment, ["core.DMA_CH_FOR_" + "I2SC0" + "_Transmit_Left", "core.DMA_CH_FOR_" + "I2SC1" + "_Transmit_Left","core.DMA_CH_FOR_" + "I2S_Transmit_0"])
    i2sTXDMAChannelComment.setVisible(False)

    i2sRXDMA = i2sComponent.createBooleanSymbol("DRV_I2S_RX_DMA", None)
    i2sRXDMA.setLabel("Use DMA for Receive?")
    i2sRXDMA.setDefaultValue(True)
    i2sRXDMA.setVisible(True)
    i2sRXDMA.setDependencies(commonTxRxOption, ["DRV_I2S_TX_RX_DMA"])
    
    i2sRXDMAChannel = i2sComponent.createIntegerSymbol("DRV_I2S_RX_DMA_CHANNEL", None)
    i2sRXDMAChannel.setLabel("DMA Channel For Receive")
    i2sRXDMAChannel.setDefaultValue(1)
    i2sRXDMAChannel.setVisible(True)
    i2sRXDMAChannel.setReadOnly(False)
    i2sRXDMAChannel.setDependencies(requestDMAChannel, ["DRV_I2S_TX_RX_DMA","DRV_I2S_RX_DMA", "core.DMA_CH_FOR_SSC_Receive", "core.DMA_CH_FOR_I2SC0_Receive_Left", "core.DMA_CH_FOR_I2SC1_Receive_Left", "core.DMA_CH_FOR_I2S_Receive_0"])

    i2sRXDMAChannelComment = i2sComponent.createCommentSymbol("DRV_I2S_RX_DMA_CH_COMMENT", None)
    i2sRXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate any DMA Channel. Check DMA manager.")
    i2sRXDMAChannelComment.setDependencies(requestDMAComment, ["core.DMA_CH_FOR_SSC_Receive", "core.DMA_CH_FOR_I2SC0_Receive_Left", "core.DMA_CH_FOR_I2SC1_Receive_Left", "core.DMA_CH_FOR_I2S_Receive_0"])
    i2sRXDMAChannelComment.setVisible(False)

    i2sDMALinkedList = i2sComponent.createBooleanSymbol("DRV_I2S_DMA_LL_ENABLE", None)
    i2sDMALinkedList.setLabel("Include Linked List DMA Functions?")
    i2sDMALinkedList.setDefaultValue(False)
    i2sDMALinkedList.setDependencies(customUpdate, ["DRV_I2S_DMA_LL_ENABLE"])
    
    # create comment to be shown first time user clicks on Linked List option
    i2sLinkedListComment = i2sComponent.createCommentSymbol("DRV_I2S_DMA_LL_COMMENT", None)
    i2sLinkedListComment.setVisible(customVisible)
    i2sLinkedListComment.setLabel('"Use Linked List Mode" must also be checked under System -> DMA (XDMAC)')

    ############################################################################
    #### Code Generation ####
    ############################################################################
    
    configName = Variables.get("__CONFIGURATION_NAME")
    
    i2sSymHeaderFile = i2sComponent.createFileSymbol("DRV_I2S_HEADER", None)
    i2sSymHeaderFile.setMarkup(True)
    i2sSymHeaderFile.setSourcePath("driver/i2s/templates/drv_i2s.h.ftl")
    i2sSymHeaderFile.setOutputName("drv_i2s.h")
    i2sSymHeaderFile.setDestPath("driver/i2s/")
    i2sSymHeaderFile.setProjectPath("config/" + configName + "/driver/i2s/")
    i2sSymHeaderFile.setType("HEADER")
    i2sSymHeaderFile.setOverwrite(True)
    
    i2sSymSourceFile = i2sComponent.createFileSymbol("DRV_I2S_SOURCE", None)
    i2sSymSourceFile.setMarkup(True) 
    i2sSymSourceFile.setSourcePath("driver/i2s/templates/drv_i2s.c.ftl")
    i2sSymSourceFile.setOutputName("drv_i2s.c")
    i2sSymSourceFile.setDestPath("driver/i2s/src")
    i2sSymSourceFile.setProjectPath("config/" + configName + "/driver/i2s/")
    i2sSymSourceFile.setType("SOURCE")
    i2sSymSourceFile.setOverwrite(True)

    i2sSymHeaderDefFile = i2sComponent.createFileSymbol("DRV_I2S_DEF", None)
    i2sSymHeaderDefFile.setSourcePath("driver/i2s/drv_i2s_definitions.h")
    i2sSymHeaderDefFile.setOutputName("drv_i2s_definitions.h")
    i2sSymHeaderDefFile.setDestPath("driver/i2s/")
    i2sSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/i2s/")
    i2sSymHeaderDefFile.setType("HEADER")
    i2sSymHeaderDefFile.setOverwrite(True)

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

# this callback occurs when user connects SSC or I2SCx block to I2S driver block in Project Graph    
def onDependencyConnected(info):
    global i2sPlibId
    if info["dependencyID"] == "drv_i2s_I2S_dependency":
        plibUsed = info["localComponent"].getSymbolByID("DRV_I2S_PLIB")
        # info["remoteComponent"].getID() returns ssc or 12sc1 for example
        i2sPlibId = info["remoteComponent"].getID().upper()
        plibUsed.setValue(i2sPlibId)
        if i2sPlibId[:3] == "SSC":
            dataLength = info["remoteComponent"].getSymbolValue("SSC_DATA_LENGTH")
            i2sDataWidth = info["localComponent"].getSymbolByID("I2S_DATA_LENGTH")
            i2sDataWidth.setValue(dataLength)
            # force DMA channels to be allocated
            i2sTXRXDMA = info["localComponent"].getSymbolByID("DRV_I2S_TX_RX_DMA")
            i2sTXRXDMA.setValue(True)
        elif i2sPlibId[:4] == "I2SC":
            dataLengthIdx = info["remoteComponent"].getSymbolValue("I2SC_MR_DATALENGTH")
            i2sDataWidth = info["localComponent"].getSymbolByID("I2S_DATA_LENGTH")
            if dataLengthIdx==0:
                i2sDataWidth.setValue(32)
            elif dataLengthIdx==4:
                i2sDataWidth.setValue(16)
            # force DMA channels to be allocated
            i2sTXRXDMA = info["localComponent"].getSymbolByID("DRV_I2S_TX_RX_DMA")
            i2sTXRXDMA.setValue(True)
        elif i2sPlibId[:3] == "I2S":
            dataLengthIdx = info["remoteComponent"].getSymbolValue("I2SC_MR_DATALENGTH")
            i2sDataWidth = info["localComponent"].getSymbolByID("I2S_DATA_LENGTH")
            if dataLengthIdx==0:
                i2sDataWidth.setValue(32)
            elif dataLengthIdx==4:
                i2sDataWidth.setValue(16)
            # force DMA channels to be allocated
            i2sTXRXDMA = info["localComponent"].getSymbolByID("DRV_I2S_TX_RX_DMA")
            i2sTXRXDMA.setValue(True)

# this callback occurs when user disconnects SSC or I2SCx block from I2S driver block in Project Graph (or I2S driver is destroyed)    
def onDependencyDisconnected(info):
    global dmaChannelRequests
    for dmaChannelRequest in dmaChannelRequests:
        Database.setSymbolValue("core", dmaChannelRequest , False)
