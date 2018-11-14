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
global sdcardFsEnable

def sdhcAsyncFileGen(symbol, event):
    component = symbol.getComponent()
    sdcardProtocol = component.getSymbolValue("DRV_SDCARD_SELECT_PROTOCOL")
    sdcardMode = component.getSymbolValue("DRV_SDCARD_COMMON_MODE")

    if (sdcardProtocol == "SDHC" and sdcardMode == "Asynchronous"):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def sdhcCommonFileGen(symbol, event):
    if event["value"] == "SDHC":
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def setSdhcConfigVisible(symbol, event):
    symbol.setVisible(event["value"])

def setMasterClockValue(symbol, event):
    symbol.setValue(int(event["value"]), 2)

def setBufferSize(symbol, event):
    if (event["value"] == True):
        symbol.clearValue()
        symbol.setValue(1, 1)
        symbol.setReadOnly(True)
    else:
        symbol.setReadOnly(False)

def setupSDHCConfig(symbol, event):
    interruptVector = "HSMCI_INTERRUPT_ENABLE"
    interruptHandler = "HSMCI_INTERRUPT_HANDLER"
    interruptHandlerLock = "HSMCI_INTERRUPT_HANDLER_LOCK"
    interruptVectorUpdate = "HSMCI_INTERRUPT_ENABLE_UPDATE"

    component = symbol.getComponent()

    if (event["value"] == "SDHC"):
        # Enable SDHC Menu
        symbol.setVisible(True)

        Database.clearSymbolValue("core", interruptVector)
        Database.setSymbolValue("core", interruptVector, True, 2)

        Database.clearSymbolValue("core", interruptHandler)
        Database.setSymbolValue("core", interruptHandler, "SDHC_InterruptHandler", 2)

        Database.clearSymbolValue("core", interruptHandlerLock)
        Database.setSymbolValue("core", interruptHandlerLock, True, 2)

        # Enable clock for HSMCI
        Database.setSymbolValue("core", "HSMCI_CLOCK_ENABLE", True, 1)

        # Enable DMA for HSMCI
        Database.setSymbolValue("core","DMA_CH_NEEDED_FOR_HSMCI", True, 2)

        component.setSymbolValue("DRV_SDHC_DMA", str(Database.getSymbolValue("core", "DMA_CH_FOR_HSMCI")), 1)

        if(int(Database.getSymbolValue("core", "DMA_CH_FOR_HSMCI")) == -2):
            component.getSymbolByID("DRV_SDHC_DMA_CH_COMMENT").setVisible(True)
        else:
            component.getSymbolByID("DRV_SDHC_DMA_CH_COMMENT").setVisible(False)
    else:
        # Disable SDHC Menu
        symbol.setVisible(False)

        Database.clearSymbolValue("core", interruptVector)

        Database.clearSymbolValue("core", interruptHandler)

        Database.clearSymbolValue("core", interruptHandlerLock)

        # Disable clock for HSMCI
        Database.setSymbolValue("core", "HSMCI_CLOCK_ENABLE", False, 1)

        # Enable DMA for HSMCI
        Database.setSymbolValue("core","DMA_CH_NEEDED_FOR_HSMCI", False, 2)

        component.setSymbolValue("DRV_SDHC_DMA", "", 1)

# SDHC Common Symbols
sdhcInstances = sdcardComponent.createIntegerSymbol("DRV_SDHC_INSTANCES_NUMBER", None)
sdhcInstances.setLabel("Number of SDHC Instances")
sdhcInstances.setDefaultValue(1)
sdhcInstances.setMax(1)
sdhcInstances.setMin(0)
sdhcInstances.setVisible(False)

# SDHC Symbols
sdhcDrvMenu = sdcardComponent.createMenuSymbol("DRV_SDCARD_SDHC_MENU", None)
sdhcDrvMenu.setLabel("Configure SDHC")
sdhcDrvMenu.setVisible(False)
sdhcDrvMenu.setDependencies(setupSDHCConfig, ["DRV_SDCARD_SELECT_PROTOCOL"])

sdhcCLK = sdcardComponent.createIntegerSymbol("SDHC_CLK", sdhcDrvMenu)
sdhcCLK.setVisible(False)
sdhcCLK.setDefaultValue(int(Database.getSymbolValue("core", "MASTER_CLOCK_FREQUENCY")))
sdhcCLK.setDependencies(setMasterClockValue, ["core.MASTER_CLOCK_FREQUENCY"])

sdhcClients = sdcardComponent.createIntegerSymbol("DRV_SDHC_CLIENTS_NUMBER", sdhcDrvMenu)
sdhcClients.setLabel("Number of SDHC Driver Clients")
sdhcClients.setDefaultValue(1)

sdhcBufferObjects = sdcardComponent.createIntegerSymbol("DRV_SDHC_BUFFER_OBJECT_NUMBER", sdhcDrvMenu)
sdhcBufferObjects.setLabel("Number of SDHC Buffer Objects")
sdhcBufferObjects.setDefaultValue(1)
sdhcBufferObjects.setMax(10)
sdhcBufferObjects.setReadOnly((sdcardFsEnable.getValue() == True))
sdhcBufferObjects.setDependencies(setBufferSize, ["DRV_SDCARD_FS_ENABLE"])

sdhcBusWidth= sdcardComponent.createComboSymbol("DRV_SDHC_TRANSFER_BUS_WIDTH", sdhcDrvMenu, ["1-bit", "4-bit"])
sdhcBusWidth.setLabel("Data Transfer Bus Width")
sdhcBusWidth.setDefaultValue("4-bit")

sdhcBusWidth= sdcardComponent.createComboSymbol("DRV_SDHC_SDHC_BUS_SPEED", sdhcDrvMenu,["DEFAULT_SPEED", "HIGH_SPEED"])
sdhcBusWidth.setLabel("Maximum Bus Speed")
sdhcBusWidth.setDefaultValue("DEFAULT_SPEED")

sdhcWP = sdcardComponent.createBooleanSymbol("DRV_SDHC_SDWPEN", sdhcDrvMenu)
sdhcWP.setLabel("Use Write Protect (SDWP#) Pin")
sdhcWP.setDefaultValue(False)

sdhcWPComment = sdcardComponent.createCommentSymbol("DRV_SDHC_SDWPEN_COMMENT", sdhcDrvMenu)
sdhcWPComment.setLabel("*****Use pin manager to rename the Pin as SDWP*********")
sdhcWPComment.setVisible(sdhcWP.getValue())
sdhcWPComment.setDependencies(setSdhcConfigVisible, ["DRV_SDHC_SDWPEN"])

sdhcCD = sdcardComponent.createBooleanSymbol("DRV_SDHC_SDCDEN", sdhcDrvMenu)
sdhcCD.setLabel("Use Card Detect (SDCD#) Pin")
sdhcCD.setDefaultValue(False)

sdhcCDComment = sdcardComponent.createCommentSymbol("DRV_SDHC_SDCDEN_COMMENT", sdhcDrvMenu)
sdhcCDComment.setLabel("*****Use pin manager to rename the Pin as SDCD*********")
sdhcCDComment.setVisible(sdhcCD.getValue())
sdhcCDComment.setDependencies(setSdhcConfigVisible, ["DRV_SDHC_SDCDEN"])

sdhcDMA = sdcardComponent.createStringSymbol("DRV_SDHC_DMA", sdhcDrvMenu)
sdhcDMA.setLabel("DMA Channel For Transmit and Receive")
sdhcDMA.setReadOnly(True)
sdhcDMA.setDefaultValue("")

sdhcDMAChannelComment = sdcardComponent.createCommentSymbol("DRV_SDHC_DMA_CH_COMMENT", sdhcDrvMenu)
sdhcDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel. Check DMA Manager.")
sdhcDMAChannelComment.setVisible(False)

############################################################################
#### Code Generation ####
############################################################################

configName = Variables.get("__CONFIGURATION_NAME")

# Async Files
sdhcAsyncSourceFile = sdcardComponent.createFileSymbol("DRV_SDHC_ASYNC_C", None)
sdhcAsyncSourceFile.setSourcePath("driver/sdcard/src/sdhc/async/drv_sdhc.c")
sdhcAsyncSourceFile.setOutputName("drv_sdhc.c")
sdhcAsyncSourceFile.setDestPath("/driver/sdcard/sdhc/")
sdhcAsyncSourceFile.setProjectPath("config/" + configName + "/driver/sdcard/sdhc/")
sdhcAsyncSourceFile.setType("SOURCE")
sdhcAsyncSourceFile.setEnabled(False)
sdhcAsyncSourceFile.setDependencies(sdhcAsyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

sdhcAsyncHeaderLocalFile = sdcardComponent.createFileSymbol("DRV_SDHC_ASYNC_LOCAL_H", None)
sdhcAsyncHeaderLocalFile.setSourcePath("driver/sdcard/src/sdhc/async/drv_sdhc_local.h")
sdhcAsyncHeaderLocalFile.setOutputName("drv_sdhc_local.h")
sdhcAsyncHeaderLocalFile.setDestPath("/driver/sdcard/sdhc/")
sdhcAsyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/sdcard/sdhc/")
sdhcAsyncHeaderLocalFile.setType("HEADER")
sdhcAsyncHeaderLocalFile.setEnabled(False)
sdhcAsyncHeaderLocalFile.setDependencies(sdhcAsyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

sdhcAsyncHeaderHostLocFile = sdcardComponent.createFileSymbol("DRV_SDHC_ASYNC_HOST_LOCAL_H", None)
sdhcAsyncHeaderHostLocFile.setSourcePath("driver/sdcard/src/sdhc/async/drv_sdhc_host_local.h")
sdhcAsyncHeaderHostLocFile.setOutputName("drv_sdhc_host_local.h")
sdhcAsyncHeaderHostLocFile.setDestPath("/driver/sdcard/sdhc/")
sdhcAsyncHeaderHostLocFile.setProjectPath("config/" + configName + "/driver/sdcard/sdhc/")
sdhcAsyncHeaderHostLocFile.setType("HEADER")
sdhcAsyncHeaderHostLocFile.setEnabled(False)
sdhcAsyncHeaderHostLocFile.setDependencies(sdhcAsyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

sdhcAsyncHeaderHostFile = sdcardComponent.createFileSymbol("DRV_SDHC_ASYNC_HOST_H", None)
sdhcAsyncHeaderHostFile.setSourcePath("driver/sdcard/src/sdhc/async/drv_sdhc_host.h")
sdhcAsyncHeaderHostFile.setOutputName("drv_sdhc_host.h")
sdhcAsyncHeaderHostFile.setDestPath("/driver/sdcard/sdhc/")
sdhcAsyncHeaderHostFile.setProjectPath("config/" + configName + "/driver/sdcard/sdhc/")
sdhcAsyncHeaderHostFile.setType("HEADER")
sdhcAsyncHeaderHostFile.setEnabled(False)
sdhcAsyncHeaderHostFile.setDependencies(sdhcAsyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

# Sync is not supported for now.
"""
# Sync File
sdhcSyncSourceFile = sdcardComponent.createFileSymbol("DRV_SDHC_SYNC_C", None)
sdhcSyncSourceFile.setSourcePath("driver/sdcard/src/sdhc/sync/drv_sdhc.c")
sdhcSyncSourceFile.setOutputName("drv_sdhc.c")
sdhcSyncSourceFile.setDestPath("/driver/sdcard/sdhc/")
sdhcSyncSourceFile.setProjectPath("config/" + configName + "/driver/sdcard/sdhc/")
sdhcSyncSourceFile.setType("SOURCE")
sdhcSyncSourceFile.setEnabled(False)
sdhcSyncSourceFile.setDependencies(sdcardSyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

sdhcSyncHeaderLocalFile = sdcardComponent.createFileSymbol("DRV_SDHC_SYNC_LOCAL_H", None)
sdhcSyncHeaderLocalFile.setSourcePath("driver/sdcard/src/sdhc/sync/drv_sdhc_local.h")
sdhcSyncHeaderLocalFile.setOutputName("drv_sdhc_local.h")
sdhcSyncHeaderLocalFile.setDestPath("/driver/sdcard/sdhc/")
sdhcSyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/sdcard/sdhc/")
sdhcSyncHeaderLocalFile.setType("HEADER")
sdhcSyncHeaderLocalFile.setEnabled(False)
sdhcSyncHeaderLocalFile.setDependencies(sdcardSyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

sdhcSyncHeaderHostLocFile = sdcardComponent.createFileSymbol("DRV_SDHC_SYNC_HOST_LOCAL_H", None)
sdhcSyncHeaderHostLocFile.setSourcePath("driver/sdcard/src/sdhc/sync/drv_sdhc_host_local.h")
sdhcSyncHeaderHostLocFile.setOutputName("drv_sdhc_host_local.h")
sdhcSyncHeaderHostLocFile.setDestPath("/driver/sdcard/sdhc/")
sdhcSyncHeaderHostLocFile.setProjectPath("config/" + configName + "/driver/sdcard/sdhc/")
sdhcSyncHeaderHostLocFile.setType("HEADER")
sdhcSyncHeaderHostLocFile.setEnabled(False)
sdhcSyncHeaderHostLocFile.setDependencies(sdcardSyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

sdhcSyncHeaderHostFile = sdcardComponent.createFileSymbol("DRV_SDHC_SYNC_HOST_H", None)
sdhcSyncHeaderHostFile.setSourcePath("driver/sdcard/src/sdhc/sync/drv_sdhc_host.h")
sdhcSyncHeaderHostFile.setOutputName("drv_sdhc_host.h")
sdhcSyncHeaderHostFile.setDestPath("/driver/sdcard/sdhc/")
sdhcSyncHeaderHostFile.setProjectPath("config/" + configName + "/driver/sdcard/sdhc/")
sdhcSyncHeaderHostFile.setType("HEADER")
sdhcSyncHeaderHostFile.setEnabled(False)
sdhcSyncHeaderHostFile.setDependencies(sdcardSyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])
"""

# Common Header
sdhcHeaderFile = sdcardComponent.createFileSymbol("DRV_SDHC_H", None)
sdhcHeaderFile.setSourcePath("driver/sdcard/src/sdhc/drv_sdhc.h")
sdhcHeaderFile.setOutputName("drv_sdhc.h")
sdhcHeaderFile.setDestPath("/driver/sdcard/sdhc/")
sdhcHeaderFile.setProjectPath("config/" + configName + "/driver/sdcard/sdhc/")
sdhcHeaderFile.setType("HEADER")
sdhcHeaderFile.setEnabled(False)
sdhcHeaderFile.setDependencies(sdhcCommonFileGen, ["DRV_SDCARD_SELECT_PROTOCOL"])

# System files
sdhcSourceHostFile = sdcardComponent.createFileSymbol("DRV_SDHC_HOST_C", None)
sdhcSourceHostFile.setType("SOURCE")
sdhcSourceHostFile.setOutputName("drv_sdhc_host.c")
sdhcSourceHostFile.setSourcePath("/driver/sdcard/src/sdhc/templates/drv_sdhc_host.c.ftl")
sdhcSourceHostFile.setDestPath("/driver/sdcard/sdhc/")
sdhcSourceHostFile.setProjectPath("config/" + configName + "/driver/sdcard/sdhc/")
sdhcSourceHostFile.setMarkup(True)
sdhcSourceHostFile.setEnabled(False)
sdhcSourceHostFile.setDependencies(sdhcCommonFileGen, ["DRV_SDCARD_SELECT_PROTOCOL"])

sdhcSystemDataFile = sdcardComponent.createFileSymbol("DRV_SDHC_INITIALIZATION_DATA_C", None)
sdhcSystemDataFile.setType("STRING")
sdhcSystemDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
sdhcSystemDataFile.setSourcePath("/driver/sdcard/src/sdhc/templates/system/system_data_initialize.c.ftl")
sdhcSystemDataFile.setMarkup(True)
sdhcSystemDataFile.setEnabled(False)
sdhcSystemDataFile.setDependencies(sdhcCommonFileGen, ["DRV_SDCARD_SELECT_PROTOCOL"])
