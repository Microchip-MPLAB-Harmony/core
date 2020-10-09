# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2020 Microchip Technology Inc. and its subsidiaries.
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

def nandFlashFileSymbolEnable(symbol, event):
    symbol.setEnabled(event["value"])

def UpdateDependentPmeccSym(symbol, event):
    global nandFlashPLIB
    Database.sendMessage(nandFlashPLIB.getValue().lower(), "PMECC_CTRL_ENABLE", {"isEnabled":event["value"], "isReadOnly":True})

def enableSysDMA(symbol, event):
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_DMA", {"isEnabled":event["value"]})

def requestAndAssignDMAChannel(symbol, event):
    dmaRequest = "Software Trigger"
    dmaChannelID = "DMA_CH_FOR_" + dmaRequest
    dmaRequestID = "DMA_CH_NEEDED_FOR_" + dmaRequest

    # Symbol visibility control
    symbol.setVisible(event["value"])

    if event["value"] == False:
        Database.sendMessage("core", "DMA_CHANNEL_DISABLE", {"dma_channel":dmaRequestID})
    else:
        Database.sendMessage("core", "DMA_CHANNEL_ENABLE", {"dma_channel":dmaRequestID})

    # Get the allocated channel and assign it
    channel = Database.getSymbolValue("core", dmaChannelID)
    if channel != None:
        symbol.setValue(channel)

def requestDMAComment(symbol, event):
    global nandTXRXDMA

    if ((event["value"] == -2) and (nandTXRXDMA.getValue() == True)):
        symbol.setVisible(True)
        event["symbol"].setVisible(False)
    else:
        symbol.setVisible(False)

def instantiateComponent(nandFlashComponent):
    global nandFlashPLIB
    global nandTXRXDMA

    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

    nandFlashPLIB = nandFlashComponent.createStringSymbol("DRV_NAND_FLASH_PLIB", None)
    nandFlashPLIB.setLabel("PLIB Used")
    nandFlashPLIB.setReadOnly(True)

    nandFlashNumClients = nandFlashComponent.createIntegerSymbol("DRV_NAND_FLASH_NUM_CLIENTS", None)
    nandFlashNumClients.setLabel("Number of Clients")
    nandFlashNumClients.setReadOnly(True)
    nandFlashNumClients.setMin(1)
    nandFlashNumClients.setMax(64)
    nandFlashNumClients.setDefaultValue(1)

    nandFlashChipSelect = nandFlashComponent.createIntegerSymbol("DRV_NAND_FLASH_CHIP_SELECT", None)
    nandFlashChipSelect.setLabel("Chip Select")
    nandFlashChipSelect.setReadOnly(True)
    nandFlashChipSelect.setMin(0)
    nandFlashChipSelect.setDefaultValue(3)

    nandEnablePMECC = nandFlashComponent.createBooleanSymbol("DRV_NAND_FLASH_PMECC_ENABLE", None)
    nandEnablePMECC.setLabel("Enable Error Correction Code (PMECC)")
    nandEnablePMECC.setDefaultValue(True)
    nandEnablePMECC.setDependencies(UpdateDependentPmeccSym, ["DRV_NAND_FLASH_PMECC_ENABLE"])

    if Database.getSymbolValue("core", "DMA_ENABLE") != None:
        nandTXRXDMA = nandFlashComponent.createBooleanSymbol("DRV_NAND_FLASH_TX_RX_DMA", None)
        nandTXRXDMA.setLabel("Use DMA for Transmit and Receive ?")
        nandTXRXDMA.setDefaultValue(False)
        nandTXRXDMA.setDependencies(enableSysDMA, ["DRV_NAND_FLASH_TX_RX_DMA"])

        nandTXRXDMAChannel = nandFlashComponent.createIntegerSymbol("DRV_NAND_FLASH_TX_RX_DMA_CHANNEL", nandTXRXDMA)
        nandTXRXDMAChannel.setLabel("DMA Channel For Transmit and Receive")
        nandTXRXDMAChannel.setDefaultValue(0)
        nandTXRXDMAChannel.setVisible(False)
        nandTXRXDMAChannel.setReadOnly(True)
        nandTXRXDMAChannel.setDependencies(requestAndAssignDMAChannel, ["DRV_NAND_FLASH_TX_RX_DMA"])

        nandTXRXDMAChannelComment = nandFlashComponent.createCommentSymbol("DRV_NAND_FLASH_TX_RX_DMA_CH_COMMENT", nandTXRXDMA)
        nandTXRXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Transmit and Receive. Check DMA manager. !!!")
        nandTXRXDMAChannelComment.setVisible(False)
        nandTXRXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_NAND_FLASH_TX_RX_DMA_CHANNEL"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    nandFlashHeaderFile = nandFlashComponent.createFileSymbol("DRV_NAND_FLASH_HEADER", None)
    nandFlashHeaderFile.setSourcePath("driver/smc_flash/nand_flash/drv_nand_flash.h")
    nandFlashHeaderFile.setOutputName("drv_nand_flash.h")
    nandFlashHeaderFile.setDestPath("driver/smc_flash/nand_flash/")
    nandFlashHeaderFile.setProjectPath("config/" + configName + "/driver/smc_flash/nand_flash/")
    nandFlashHeaderFile.setType("HEADER")
    nandFlashHeaderFile.setOverwrite(True)

    nandFlashAsyncHeaderLocalFile = nandFlashComponent.createFileSymbol("DRV_NAND_FLASH_HEADER_LOCAL", None)
    nandFlashAsyncHeaderLocalFile.setSourcePath("driver/smc_flash/nand_flash/src/drv_nand_flash_local.h.ftl")
    nandFlashAsyncHeaderLocalFile.setOutputName("drv_nand_flash_local.h")
    nandFlashAsyncHeaderLocalFile.setDestPath("driver/smc_flash/nand_flash/src")
    nandFlashAsyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/smc_flash/nand_flash/")
    nandFlashAsyncHeaderLocalFile.setType("HEADER")
    nandFlashAsyncHeaderLocalFile.setOverwrite(True)
    nandFlashAsyncHeaderLocalFile.setMarkup(True)

    nandFlashSourceFile = nandFlashComponent.createFileSymbol("DRV_NAND_FLASH_SOURCE", None)
    nandFlashSourceFile.setSourcePath("driver/smc_flash/nand_flash/src/drv_nand_flash.c.ftl")
    nandFlashSourceFile.setOutputName("drv_nand_flash.c")
    nandFlashSourceFile.setDestPath("driver/smc_flash/nand_flash/src/")
    nandFlashSourceFile.setProjectPath("config/" + configName + "/driver/smc_flash/nand_flash/")
    nandFlashSourceFile.setType("SOURCE")
    nandFlashSourceFile.setOverwrite(True)
    nandFlashSourceFile.setMarkup(True)

    nandFlashPmeccSourceFile = nandFlashComponent.createFileSymbol("DRV_NAND_FLASH_PMECC_SOURCE", None)
    nandFlashPmeccSourceFile.setSourcePath("driver/smc_flash/nand_flash/src/drv_nand_flash_pmecc.c")
    nandFlashPmeccSourceFile.setOutputName("drv_nand_flash_pmecc.c")
    nandFlashPmeccSourceFile.setDestPath("driver/smc_flash/nand_flash/src/")
    nandFlashPmeccSourceFile.setProjectPath("config/" + configName + "/driver/smc_flash/nand_flash/")
    nandFlashPmeccSourceFile.setType("SOURCE")
    nandFlashPmeccSourceFile.setOverwrite(True)
    nandFlashPmeccSourceFile.setEnabled(nandEnablePMECC.getValue())
    nandFlashPmeccSourceFile.setDependencies(nandFlashFileSymbolEnable, ["DRV_NAND_FLASH_PMECC_ENABLE"])

    nandFlashPmeccHeaderFile = nandFlashComponent.createFileSymbol("DRV_NAND_FLASH_PMECC_HEADER", None)
    nandFlashPmeccHeaderFile.setSourcePath("driver/smc_flash/nand_flash/src/drv_nand_flash_pmecc.h")
    nandFlashPmeccHeaderFile.setOutputName("drv_nand_flash_pmecc.h")
    nandFlashPmeccHeaderFile.setDestPath("driver/smc_flash/nand_flash/src/")
    nandFlashPmeccHeaderFile.setProjectPath("config/" + configName + "/driver/smc_flash/nand_flash/")
    nandFlashPmeccHeaderFile.setType("HEADER")
    nandFlashPmeccHeaderFile.setOverwrite(True)
    nandFlashPmeccHeaderFile.setEnabled(nandEnablePMECC.getValue())
    nandFlashPmeccHeaderFile.setDependencies(nandFlashFileSymbolEnable, ["DRV_NAND_FLASH_PMECC_ENABLE"])

    nandFlashHeaderDefFile = nandFlashComponent.createFileSymbol("DRV_NAND_FLASH_HEADER_DEF", None)
    nandFlashHeaderDefFile.setSourcePath("driver/smc_flash/nand_flash/templates/drv_nand_flash_definitions.h.ftl")
    nandFlashHeaderDefFile.setOutputName("drv_nand_flash_definitions.h")
    nandFlashHeaderDefFile.setDestPath("driver/smc_flash/nand_flash/")
    nandFlashHeaderDefFile.setProjectPath("config/" + configName + "/driver/smc_flash/nand_flash/")
    nandFlashHeaderDefFile.setType("HEADER")
    nandFlashHeaderDefFile.setOverwrite(True)
    nandFlashHeaderDefFile.setMarkup(True)

    # System Template Files
    nandFlashSystemDefFile = nandFlashComponent.createFileSymbol("DRV_NAND_FLASH_SYS_DEF", None)
    nandFlashSystemDefFile.setType("STRING")
    nandFlashSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    nandFlashSystemDefFile.setSourcePath("driver/smc_flash/nand_flash/templates/system/definitions.h.ftl")
    nandFlashSystemDefFile.setMarkup(True)

    nandFlashSystemDefObjFile = nandFlashComponent.createFileSymbol("DRV_NAND_FLASH_SYS_DEF_OBJ", None)
    nandFlashSystemDefObjFile.setType("STRING")
    nandFlashSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    nandFlashSystemDefObjFile.setSourcePath("driver/smc_flash/nand_flash/templates/system/definitions_objects.h.ftl")
    nandFlashSystemDefObjFile.setMarkup(True)

    nandFlashSystemConfigFile = nandFlashComponent.createFileSymbol("DRV_NAND_FLASH_SYS_CFG", None)
    nandFlashSystemConfigFile.setType("STRING")
    nandFlashSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    nandFlashSystemConfigFile.setSourcePath("driver/smc_flash/nand_flash/templates/system/configuration.h.ftl")
    nandFlashSystemConfigFile.setMarkup(True)

    nandFlashSystemInitDataFile = nandFlashComponent.createFileSymbol("DRV_NAND_FLASH_SYS_INIT_DATA", None)
    nandFlashSystemInitDataFile.setType("STRING")
    nandFlashSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    nandFlashSystemInitDataFile.setSourcePath("driver/smc_flash/nand_flash/templates/system/initialize_data.c.ftl")
    nandFlashSystemInitDataFile.setMarkup(True)

    nandFlashSystemInitFile = nandFlashComponent.createFileSymbol("DRV_NAND_FLASH_SYS_INIT", None)
    nandFlashSystemInitFile.setType("STRING")
    nandFlashSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    nandFlashSystemInitFile.setSourcePath("driver/smc_flash/nand_flash/templates/system/initialize.c.ftl")
    nandFlashSystemInitFile.setMarkup(True)

def onAttachmentConnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_nand_flash_NAND_CS_dependency" :
        localComponent.getSymbolByID("DRV_NAND_FLASH_PLIB").setValue(remoteID.upper())
        localComponent.getSymbolByID("DRV_NAND_FLASH_CHIP_SELECT").setValue(int(targetID.replace("smc_cs","")))
        # Enable chip select of dependent plib
        Database.sendMessage(remoteID, "SMC_CS_ENABLE_" + str(localComponent.getSymbolByID("DRV_NAND_FLASH_CHIP_SELECT").getValue()), {"isEnabled":True, "isReadOnly":True})
        # PMECC control enable value
        Database.sendMessage(remoteID, "PMECC_CTRL_ENABLE", {"isEnabled":localComponent.getSymbolByID("DRV_NAND_FLASH_PMECC_ENABLE").getValue(), "isReadOnly":True})
        # Disable PMECC interrupt
        Database.sendMessage(remoteID, "PMECC_IER_ERRIE", {"isEnabled":False, "isReadOnly":True})
        # Disable PMERR interrupt
        Database.sendMessage(remoteID, "PMERRLOC_ELIER_DONE", {"isEnabled":False, "isReadOnly":True})

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_nand_flash_NAND_CS_dependency" :
        plibUsed = localComponent.getSymbolByID("DRV_NAND_FLASH_PLIB")
        plibUsed.clearValue()
        localComponent.getSymbolByID("DRV_NAND_FLASH_CHIP_SELECT").clearValue()
        # Chip select of dependent plib
        Database.sendMessage(remoteID, "SMC_CS_ENABLE_" + str(localComponent.getSymbolByID("DRV_NAND_FLASH_CHIP_SELECT").getValue()), {"isReadOnly":False})
        # PMECC control enable value
        Database.sendMessage(remoteID, "PMECC_CTRL_ENABLE", {"isReadOnly":False})
        # PMECC interrupt
        Database.sendMessage(remoteID, "PMECC_IER_ERRIE", {"isReadOnly":False})
        # PMERR interrupt
        Database.sendMessage(remoteID, "PMERRLOC_ELIER_DONE", {"isReadOnly":False})

def destroyComponent(nandFlashComponent):
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})
    if Database.getSymbolValue("core", "DMA_ENABLE") != None:
        Database.sendMessage("HarmonyCore", "ENABLE_SYS_DMA", {"isEnabled":False})
