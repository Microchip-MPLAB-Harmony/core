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

################################################################################
#### Component ####
################################################################################

#myVariableValue = Database.getSymbolValue("core", "COMPONENT_PACKAGE")
#pioPinout = ATDF.getNode('/avr-tools-device-file/pinouts/pinout@[name= "' + str(myVariableValue) + '"]')
global drvSdspiInstanceSpace
global sdspiSymPLIBConnection

def sdspiSyncFileGen(symbol, event):
    component = symbol.getComponent()
    sdcardProtocol = component.getSymbolValue("DRV_SDCARD_SELECT_PROTOCOL")
    sdcardMode = component.getSymbolValue("DRV_SDCARD_COMMON_MODE")

    if (sdcardProtocol == "SDSPI" and sdcardMode == "Synchronous"):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def sdspiCommonFileGen(symbol, event):
    if event["value"] == "SDSPI":
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def showSDSPIMenu(symbol, event):
    if (event["value"] == "SDSPI"):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def showWriteProtectComment(symbol, event):
    symbol.setVisible(event["value"])

def updatePinPosition(symbol, event):
    if event["id"] == "DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING":
        symbol.setVisible(event["value"])
    else:
        # "value" of at25mSymChipSelectPin and other pin symbols should be updated
        # here based on the package selected in Pin manager.
        pioPinout = ATDF.getNode('/avr-tools-device-file/pinouts/pinout@[name= "' + event["value"] + '"]')
        count = Database.getSymbolValue("core", "PIO_PIN_TOTAL")
        for id in range(0,count):
            if (pioPinout.getChildren()[id].getAttribute("pad")[0] == "P") and (pioPinout.getChildren()[id].getAttribute("pad")[-1].isdigit()):
                key = "SYS_PORT_PIN_" + pioPinout.getChildren()[id].getAttribute("pad")
                value = pioPinout.getChildren()[id].getAttribute("position")
                symbol.setKeyValue(key, value)

def requestDMAComment(symbol, event):
    if event["value"] == -2:
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def requestAndAssignDMAChannel(symbol, event):
    global drvSdspiInstanceSpace
    global sdspiSymPLIBConnection

    spiPeripheral = Database.getSymbolValue(drvSdspiInstanceSpace, "DRV_SDSPI_PLIB")

    if symbol.getID() == "DRV_SDSPI_TX_DMA_CHANNEL":
        dmaChannelID = "DMA_CH_FOR_" + str(spiPeripheral) + "_Transmit"
        dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Transmit"
    else:
        dmaChannelID = "DMA_CH_FOR_" + str(spiPeripheral) + "_Receive"
        dmaRequestID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Receive"

    # Control visibility
    symbol.setVisible(event["value"])

    if event["value"] == False:
        Database.setSymbolValue("core", dmaRequestID, False, 2)
    else:
        if (sdspiSymPLIBConnection.getValue() == True) and (Database.getSymbolValue("core", dmaChannelID) == -1):
            Database.setSymbolValue("core", dmaRequestID, True, 2)

    # Get the allocated channel and assign it
    channel = Database.getSymbolValue("core", dmaChannelID)
    # print("Value of dmaChannelID ", dmaChannelID)
    # print("Value of channel ", channel)
    symbol.setValue(channel, 2)

drvSdspiInstanceSpace = "drv_sdcard"

# Enable "Enable System Interrupt" option in MHC
Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_INT", True, 1)

# Enable "Enable System Ports" option in MHC
Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS", True, 1)

# Enable "Enable System DMA" option in MHC
Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_DMA", True, 1)

# SDSPI Symbols
sdspiDrvMenu = sdcardComponent.createMenuSymbol("DRV_SDCARD_SDSPI_MENU", None)
sdspiDrvMenu.setLabel("Configure SDSPI")
sdspiDrvMenu.setVisible(True)
sdspiDrvMenu.setDependencies(showSDSPIMenu, ["DRV_SDCARD_SELECT_PROTOCOL"])

sdspiSymIndex = sdcardComponent.createIntegerSymbol("INDEX", sdspiDrvMenu)
sdspiSymIndex.setVisible(False)
sdspiSymIndex.setDefaultValue(0)

sdspiSymPLIB = sdcardComponent.createStringSymbol("DRV_SDSPI_PLIB", sdspiDrvMenu)
sdspiSymPLIB.setLabel("PLIB Used")
sdspiSymPLIB.setReadOnly(True)
sdspiSymPLIB.setDefaultValue("")

sdspiSymPLIBConnection = sdcardComponent.createBooleanSymbol("DRV_SDSPI_PLIB_CONNECTION", sdspiDrvMenu)
sdspiSymPLIBConnection.setDefaultValue(False)
sdspiSymPLIBConnection.setVisible(False)

sdspiSymNumClients = sdcardComponent.createIntegerSymbol("DRV_SDSPI_NUM_CLIENTS", sdspiDrvMenu)
sdspiSymNumClients.setLabel("Number of Clients")
sdspiSymNumClients.setMin(1)
sdspiSymNumClients.setMax(10)
sdspiSymNumClients.setDefaultValue(1)

sdspiSymNumClients = sdcardComponent.createIntegerSymbol("DRV_SDSPI_SPEED_HZ", sdspiDrvMenu)
sdspiSymNumClients.setLabel("SD Card Speed (Hz)")
sdspiSymNumClients.setMin(1)
sdspiSymNumClients.setMax(25000000)
sdspiSymNumClients.setDefaultValue(5000000)

sdspiSymChipSelectPin = sdcardComponent.createKeyValueSetSymbol("DRV_SDSPI_CHIP_SELECT_PIN", sdspiDrvMenu)
sdspiSymChipSelectPin.setLabel("Chip Select Pin")
sdspiSymChipSelectPin.setDefaultValue(0)
sdspiSymChipSelectPin.setOutputMode("Key")
sdspiSymChipSelectPin.setDisplayMode("Description")
sdspiSymChipSelectPin.setDependencies(updatePinPosition, ["core.COMPONENT_PACKAGE"])

sdspiChipSelectPinComment = sdcardComponent.createCommentSymbol("DRV_SDSPI_CHIP_SELECT_PIN_COMMENT", sdspiDrvMenu)
sdspiChipSelectPinComment.setLabel("Configure the Chip Select pin as GPIO output under Pin Settings.")
sdspiChipSelectPinComment.setVisible(True)

sdspiSymWriteProtect = sdcardComponent.createBooleanSymbol("DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING", sdspiDrvMenu)
sdspiSymWriteProtect.setLabel("Use Write Protect Pin (Active High)?")
sdspiSymWriteProtect.setDefaultValue(False)
sdspiSymWriteProtect.setVisible(True)

sdspiSymWriteProtectPin = sdcardComponent.createKeyValueSetSymbol("DRV_SDSPI_WRITE_PROTECT_PIN", sdspiSymWriteProtect)
sdspiSymWriteProtectPin.setLabel("Write Protect Pin (Active High)")
sdspiSymWriteProtectPin.setDefaultValue(0)
sdspiSymWriteProtectPin.setOutputMode("Key")
sdspiSymWriteProtectPin.setDisplayMode("Description")
sdspiSymWriteProtectPin.setVisible(sdspiSymWriteProtect.getValue())
sdspiSymWriteProtectPin.setDependencies(updatePinPosition, ["core.COMPONENT_PACKAGE", "DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING"])

sdspiWriteProtectPinComment = sdcardComponent.createCommentSymbol("DRV_SDSPI_WRITE_PROTECT_PIN_COMMENT", sdspiSymWriteProtect)
sdspiWriteProtectPinComment.setLabel("Configure the Write Protect pin as GPIO input under Pin Settings.")
sdspiWriteProtectPinComment.setVisible(sdspiSymWriteProtect.getValue())
sdspiWriteProtectPinComment.setDependencies(showWriteProtectComment, ["DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING"])

sdspiTXRXDMA = sdcardComponent.createBooleanSymbol("DRV_SDSPI_TX_RX_DMA", sdspiDrvMenu)
sdspiTXRXDMA.setLabel("Use DMA for Transmit and Receive?")
sdspiTXRXDMA.setDefaultValue(False)

sdspiTXDMAChannel = sdcardComponent.createIntegerSymbol("DRV_SDSPI_TX_DMA_CHANNEL", sdspiDrvMenu)
sdspiTXDMAChannel.setLabel("DMA Channel For Transmit")
sdspiTXDMAChannel.setDefaultValue(0)
sdspiTXDMAChannel.setVisible(False)
sdspiTXDMAChannel.setReadOnly(True)
sdspiTXDMAChannel.setDependencies(requestAndAssignDMAChannel, ["DRV_SDSPI_TX_RX_DMA"])

sdspiTXDMAChannelComment = sdcardComponent.createCommentSymbol("DRV_SDSPI_TX_DMA_CH_COMMENT", sdspiDrvMenu)
sdspiTXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Transmit. Check DMA manager.")
sdspiTXDMAChannelComment.setVisible(False)
sdspiTXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_SDSPI_TX_DMA_CHANNEL"])

sdspiRXDMAChannel = sdcardComponent.createIntegerSymbol("DRV_SDSPI_RX_DMA_CHANNEL", sdspiDrvMenu)
sdspiRXDMAChannel.setLabel("DMA Channel For Receive")
sdspiRXDMAChannel.setDefaultValue(1)
sdspiRXDMAChannel.setVisible(False)
sdspiRXDMAChannel.setReadOnly(True)
sdspiRXDMAChannel.setDependencies(requestAndAssignDMAChannel, ["DRV_SDSPI_TX_RX_DMA"])

sdspiRXDMAChannelComment = sdcardComponent.createCommentSymbol("DRV_SDSPI_RX_DMA_CH_COMMENT", sdspiDrvMenu)
sdspiRXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Receive. Check DMA manager.")
sdspiRXDMAChannelComment.setVisible(False)
sdspiRXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_SDSPI_RX_DMA_CHANNEL"])

pinOutNode = ATDF.getNode("/avr-tools-device-file/pinouts/pinout")
pinOut = pinOutNode.getChildren()

for pad in range(0, len(pinOut)):
    pin = pinOut[pad].getAttribute("pad")
    if (pin[0] == "P") and (pin[-1].isdigit()):
        key = "SYS_PORT_PIN_" + pin
        value = pinOut[pad].getAttribute("position")
        description = pinOut[pad].getAttribute("pad")
        sdspiSymChipSelectPin.addKey(key, value, description)
        sdspiSymWriteProtectPin.addKey(key, value, description)

############################################################################
#### Code Generation ####
############################################################################

configName = Variables.get("__CONFIGURATION_NAME")

# Global Header Files
sdspiSymHeaderFile = sdcardComponent.createFileSymbol("DRV_SDSPI_HEADER", None)
sdspiSymHeaderFile.setSourcePath("driver/sdcard/src/sdspi/drv_sdspi.h")
sdspiSymHeaderFile.setOutputName("drv_sdspi.h")
sdspiSymHeaderFile.setDestPath("driver/sdcard/sdspi/")
sdspiSymHeaderFile.setProjectPath("config/" + configName + "/driver/sdcard/sdspi/")
sdspiSymHeaderFile.setType("HEADER")
sdspiSymHeaderFile.setOverwrite(True)
sdspiSymHeaderFile.setDependencies(sdspiCommonFileGen, ["DRV_SDCARD_SELECT_PROTOCOL"])

sdspiSymHeaderDefFile = sdcardComponent.createFileSymbol("DRV_SDSPI_DEF", None)
sdspiSymHeaderDefFile.setSourcePath("driver/sdcard/src/sdspi/drv_sdspi_definitions.h")
sdspiSymHeaderDefFile.setOutputName("drv_sdspi_definitions.h")
sdspiSymHeaderDefFile.setDestPath("driver/sdcard/sdspi")
sdspiSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/sdcard/sdspi/")
sdspiSymHeaderDefFile.setType("HEADER")
sdspiSymHeaderDefFile.setOverwrite(True)
sdspiSymHeaderDefFile.setDependencies(sdspiCommonFileGen, ["DRV_SDCARD_SELECT_PROTOCOL"])

# Async is not supported for now.
"""
# Async Source Files
sdspiAsyncSymSourceFile = sdcardComponent.createFileSymbol("DRV_SDSPI_ASYNC_SOURCE", None)
sdspiAsyncSymSourceFile.setSourcePath("driver/sdcard/src/sdspi/async/drv_sdspi.c")
sdspiAsyncSymSourceFile.setOutputName("drv_sdspi.c")
sdspiAsyncSymSourceFile.setDestPath("driver/sdcard/sdspi/src")
sdspiAsyncSymSourceFile.setProjectPath("config/" + configName + "/driver/sdcard/sdspi/")
sdspiAsyncSymSourceFile.setType("SOURCE")
sdspiAsyncSymSourceFile.setOverwrite(True)
sdspiAsyncSymSourceFile.setEnabled(False)
sdspiAsyncSymSourceFile.setDependencies(asyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

sdspiAsyncSymHeaderLocalFile = sdcardComponent.createFileSymbol("DRV_SDSPI_ASYNC_HEADER_LOCAL", None)
sdspiAsyncSymHeaderLocalFile.setSourcePath("driver/sdcard/src/sdspi/async/drv_sdspi_local.h")
sdspiAsyncSymHeaderLocalFile.setOutputName("drv_sdspi_local.h")
sdspiAsyncSymHeaderLocalFile.setDestPath("driver/sdcard/sdspi/src")
sdspiAsyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/sdcard/sdspi/")
sdspiAsyncSymHeaderLocalFile.setType("HEADER")
sdspiAsyncSymHeaderLocalFile.setOverwrite(True)
sdspiAsyncSymHeaderLocalFile.setEnabled(False)
sdspiAsyncSymHeaderLocalFile.setDependencies(asyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

sdspiAsyncSymInterfaceSourceFile = sdcardComponent.createFileSymbol("DRV_SDSPI_ASYNC_INTERFACE_SOURCE", None)
sdspiAsyncSymInterfaceSourceFile.setSourcePath("driver/sdcard/src/sdspi/async/drv_sdspi_interface.c")
sdspiAsyncSymInterfaceSourceFile.setOutputName("drv_sdspi_interface.c")
sdspiAsyncSymInterfaceSourceFile.setDestPath("driver/sdcard/sdspi/src")
sdspiAsyncSymInterfaceSourceFile.setProjectPath("config/" + configName + "/driver/sdcard/sdspi/")
sdspiAsyncSymInterfaceSourceFile.setType("SOURCE")
sdspiAsyncSymInterfaceSourceFile.setOverwrite(True)
sdspiAsyncSymInterfaceSourceFile.setEnabled(False)
sdspiAsyncSymInterfaceSourceFile.setDependencies(asyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

sdspiAsyncSymInterfaceHeaderFile = sdcardComponent.createFileSymbol("DRV_SDSPI_ASYNC_INTERFACE_HEADER", None)
sdspiAsyncSymInterfaceHeaderFile.setSourcePath("driver/sdcard/src/sdspi/async/drv_sdspi_interface.h")
sdspiAsyncSymInterfaceHeaderFile.setOutputName("drv_sdspi_interface.h")
sdspiAsyncSymInterfaceHeaderFile.setDestPath("driver/sdcard/sdspi/src")
sdspiAsyncSymInterfaceHeaderFile.setProjectPath("config/" + configName + "/driver/sdcard/sdspi/")
sdspiAsyncSymInterfaceHeaderFile.setType("HEADER")
sdspiAsyncSymInterfaceHeaderFile.setOverwrite(True)
sdspiAsyncSymInterfaceHeaderFile.setEnabled(False)
sdspiAsyncSymInterfaceHeaderFile.setDependencies(asyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])
"""

# Sync Source Files
sdspiSyncSymSourceFile = sdcardComponent.createFileSymbol("DRV_SDSPI_SYNC_SOURCE", None)
sdspiSyncSymSourceFile.setSourcePath("driver/sdcard/src/sdspi/sync/drv_sdspi.c")
sdspiSyncSymSourceFile.setOutputName("drv_sdspi.c")
sdspiSyncSymSourceFile.setDestPath("driver/sdcard/sdspi/src")
sdspiSyncSymSourceFile.setProjectPath("config/" + configName + "/driver/sdcard/sdspi/")
sdspiSyncSymSourceFile.setType("SOURCE")
sdspiSyncSymSourceFile.setOverwrite(True)
sdspiSyncSymSourceFile.setEnabled(True)
sdspiSyncSymSourceFile.setDependencies(sdspiSyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

sdspiSyncSymHeaderLocalFile = sdcardComponent.createFileSymbol("DRV_SDSPI_SYNC_HEADER_LOCAL", None)
sdspiSyncSymHeaderLocalFile.setSourcePath("driver/sdcard/src/sdspi/sync/drv_sdspi_local.h")
sdspiSyncSymHeaderLocalFile.setOutputName("drv_sdspi_local.h")
sdspiSyncSymHeaderLocalFile.setDestPath("driver/sdcard/sdspi/src")
sdspiSyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/sdcard/sdspi/")
sdspiSyncSymHeaderLocalFile.setType("HEADER")
sdspiSyncSymHeaderLocalFile.setOverwrite(True)
sdspiSyncSymHeaderLocalFile.setEnabled(True)
sdspiSyncSymHeaderLocalFile.setDependencies(sdspiSyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

sdspiSyncSymPlibInterfaceSourceFile = sdcardComponent.createFileSymbol("DRV_SDSPI_SYNC_PLIB_INTERFACE_SOURCE", None)
sdspiSyncSymPlibInterfaceSourceFile.setSourcePath("driver/sdcard/src/sdspi/sync/drv_sdspi_plib_interface.c")
sdspiSyncSymPlibInterfaceSourceFile.setOutputName("drv_sdspi_plib_interface.c")
sdspiSyncSymPlibInterfaceSourceFile.setDestPath("driver/sdcard/sdspi/src")
sdspiSyncSymPlibInterfaceSourceFile.setProjectPath("config/" + configName + "/driver/sdcard/sdspi/")
sdspiSyncSymPlibInterfaceSourceFile.setType("SOURCE")
sdspiSyncSymPlibInterfaceSourceFile.setOverwrite(True)
sdspiSyncSymPlibInterfaceSourceFile.setEnabled(True)
sdspiSyncSymPlibInterfaceSourceFile.setDependencies(sdspiSyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

sdspiSyncSymPlibInterfaceHeaderFile = sdcardComponent.createFileSymbol("DRV_SDSPI_SYNC_PLIB_INTERFACE_HEADER", None)
sdspiSyncSymPlibInterfaceHeaderFile.setSourcePath("driver/sdcard/src/sdspi/sync/drv_sdspi_plib_interface.h")
sdspiSyncSymPlibInterfaceHeaderFile.setOutputName("drv_sdspi_plib_interface.h")
sdspiSyncSymPlibInterfaceHeaderFile.setDestPath("driver/sdcard/sdspi/src")
sdspiSyncSymPlibInterfaceHeaderFile.setProjectPath("config/" + configName + "/driver/sdcard/sdspi/")
sdspiSyncSymPlibInterfaceHeaderFile.setType("HEADER")
sdspiSyncSymPlibInterfaceHeaderFile.setOverwrite(True)
sdspiSyncSymPlibInterfaceHeaderFile.setEnabled(True)
sdspiSyncSymPlibInterfaceHeaderFile.setDependencies(sdspiSyncFileGen, ["DRV_SDCARD_COMMON_MODE", "DRV_SDCARD_SELECT_PROTOCOL"])

# System Template Files
sdspiSymSystemInitDataFile = sdcardComponent.createFileSymbol("DRV_SDSPI_INIT_DATA", None)
sdspiSymSystemInitDataFile.setType("STRING")
sdspiSymSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
sdspiSymSystemInitDataFile.setSourcePath("driver/sdcard/src/sdspi/templates/system/system_initialize_data.c.ftl")
sdspiSymSystemInitDataFile.setMarkup(True)
sdspiSymSystemInitDataFile.setDependencies(sdspiCommonFileGen, ["DRV_SDCARD_SELECT_PROTOCOL"])


