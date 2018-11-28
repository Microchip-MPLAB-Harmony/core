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

sdspiRegisterWithFS              = None

def setVisible(symbol, event):
    symbol.setVisible(event["value"])

def genRtosTask(symbol, event):
    if event["value"] != 0:
        # If not Bare Metal
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def showRTOSMenu(symbol, event):
    if event["value"] != 0:
        # If not Bare Metal
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def setRtosUseDelay(symbol, event):
    if event["value"] == 0:
        symbol.setVisible(True)
        symbol.clearValue()
        symbol.setValue(True, 1)
    elif event["value"] == 1:
        symbol.setVisible(False)
        symbol.clearValue()
        symbol.setValue(False, 1)

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

def instantiateComponent(sdspiComponent, index):
    global drvSdspiInstanceSpace
    global sdspiRegisterWithFS
    drvSdspiInstanceSpace = "drv_sdspi_" + str(index)

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True, 1)

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True, 1)

    # Enable "Enable System Interrupt" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_INT", True, 1)

    # Enable "Enable System Ports" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS", True, 1)

    # Enable "Enable System DMA" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_DMA", True, 1)

    # Enable "Enable OSAL" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_OSAL", True, 1)

    # Enable "ENABLE_SYS_MEDIA" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA", True, 1)

    sdspiSymIndex = sdspiComponent.createIntegerSymbol("INDEX", None)
    sdspiSymIndex.setVisible(False)
    sdspiSymIndex.setDefaultValue(index)

    sdspiSymPLIB = sdspiComponent.createStringSymbol("DRV_SDSPI_PLIB", None)
    sdspiSymPLIB.setLabel("PLIB Used")
    sdspiSymPLIB.setReadOnly(True)
    sdspiSymPLIB.setDefaultValue("SPI0")

    global sdspiSymPLIBConnection
    sdspiSymPLIBConnection = sdspiComponent.createBooleanSymbol("DRV_SDSPI_PLIB_CONNECTION", None)
    sdspiSymPLIBConnection.setDefaultValue(False)
    sdspiSymPLIBConnection.setVisible(False)

    sdspiGlobalMode = sdspiComponent.createBooleanSymbol("DRV_SDSPI_MODE", None)
    sdspiGlobalMode.setLabel("**** Driver Mode Update ****")
    sdspiGlobalMode.setValue(Database.getSymbolValue("drv_sdspi", "DRV_SDSPI_COMMON_MODE"), 1)
    sdspiGlobalMode.setVisible(False)
    sdspiGlobalMode.setDependencies(sdspiDriverMode, ["drv_sdspi.DRV_SDSPI_COMMON_MODE"])

    sdspiSymNumClients = sdspiComponent.createIntegerSymbol("DRV_SDSPI_NUM_CLIENTS", None)
    sdspiSymNumClients.setLabel("Number of Clients")
    sdspiSymNumClients.setMin(1)
    sdspiSymNumClients.setMax(10)
    sdspiSymNumClients.setDefaultValue(1)

    sdspiSymNumClients = sdspiComponent.createIntegerSymbol("DRV_SDSPI_SPEED_HZ", None)
    sdspiSymNumClients.setLabel("SD Card Speed (Hz)")
    sdspiSymNumClients.setMin(1)
    sdspiSymNumClients.setMax(25000000)
    sdspiSymNumClients.setDefaultValue(5000000)

    sdspiSymChipSelectPin = sdspiComponent.createKeyValueSetSymbol("DRV_SDSPI_CHIP_SELECT_PIN", None)
    sdspiSymChipSelectPin.setLabel("Chip Select Pin")
    sdspiSymChipSelectPin.setDefaultValue(0)
    sdspiSymChipSelectPin.setOutputMode("Key")
    sdspiSymChipSelectPin.setDisplayMode("Description")
    sdspiSymChipSelectPin.setDependencies(updatePinPosition, ["core.COMPONENT_PACKAGE"])

    sdspiChipSelectPinComment = sdspiComponent.createCommentSymbol("DRV_SDSPI_CHIP_SELECT_PIN_COMMENT", None)
    sdspiChipSelectPinComment.setLabel("Configure the Chip Select pin as GPIO output under Pin Settings.")
    sdspiChipSelectPinComment.setVisible(True)

    sdspiSymWriteProtect = sdspiComponent.createBooleanSymbol("DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING", None)
    sdspiSymWriteProtect.setLabel("Use Write Protect Pin (Active High)?")
    sdspiSymWriteProtect.setDefaultValue(False)
    sdspiSymWriteProtect.setVisible(True)

    sdspiSymWriteProtectPin = sdspiComponent.createKeyValueSetSymbol("DRV_SDSPI_WRITE_PROTECT_PIN", sdspiSymWriteProtect)
    sdspiSymWriteProtectPin.setLabel("Write Protect Pin (Active High)")
    sdspiSymWriteProtectPin.setDefaultValue(0)
    sdspiSymWriteProtectPin.setOutputMode("Key")
    sdspiSymWriteProtectPin.setDisplayMode("Description")
    sdspiSymWriteProtectPin.setVisible(sdspiSymWriteProtect.getValue())
    sdspiSymWriteProtectPin.setDependencies(updatePinPosition, ["core.COMPONENT_PACKAGE", "DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING"])

    sdspiWriteProtectPinComment = sdspiComponent.createCommentSymbol("DRV_SDSPI_WRITE_PROTECT_PIN_COMMENT", sdspiSymWriteProtect)
    sdspiWriteProtectPinComment.setLabel("Configure the Write Protect pin as GPIO input under Pin Settings.")
    sdspiWriteProtectPinComment.setVisible(sdspiSymWriteProtect.getValue())
    sdspiWriteProtectPinComment.setDependencies(showWriteProtectComment, ["DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING"])

    sdspiTXRXDMA = sdspiComponent.createBooleanSymbol("DRV_SDSPI_TX_RX_DMA", None)
    sdspiTXRXDMA.setLabel("Use DMA for Transmit and Receive?")
    sdspiTXRXDMA.setDefaultValue(False)

    sdspiTXDMAChannel = sdspiComponent.createIntegerSymbol("DRV_SDSPI_TX_DMA_CHANNEL", None)
    sdspiTXDMAChannel.setLabel("DMA Channel For Transmit")
    sdspiTXDMAChannel.setDefaultValue(0)
    sdspiTXDMAChannel.setVisible(False)
    sdspiTXDMAChannel.setReadOnly(True)
    sdspiTXDMAChannel.setDependencies(requestAndAssignDMAChannel, ["DRV_SDSPI_TX_RX_DMA"])

    sdspiTXDMAChannelComment = sdspiComponent.createCommentSymbol("DRV_SDSPI_TX_DMA_CH_COMMENT", None)
    sdspiTXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Transmit. Check DMA manager.")
    sdspiTXDMAChannelComment.setVisible(False)
    sdspiTXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_SDSPI_TX_DMA_CHANNEL"])

    sdspiRXDMAChannel = sdspiComponent.createIntegerSymbol("DRV_SDSPI_RX_DMA_CHANNEL", None)
    sdspiRXDMAChannel.setLabel("DMA Channel For Receive")
    sdspiRXDMAChannel.setDefaultValue(1)
    sdspiRXDMAChannel.setVisible(False)
    sdspiRXDMAChannel.setReadOnly(True)
    sdspiRXDMAChannel.setDependencies(requestAndAssignDMAChannel, ["DRV_SDSPI_TX_RX_DMA"])

    sdspiRXDMAChannelComment = sdspiComponent.createCommentSymbol("DRV_SDSPI_RX_DMA_CH_COMMENT", None)
    sdspiRXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Receive. Check DMA manager.")
    sdspiRXDMAChannelComment.setVisible(False)
    sdspiRXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_SDSPI_RX_DMA_CHANNEL"])

    sdspiRegisterWithFS = sdspiComponent.createBooleanSymbol("DRV_SDSPI_REGISTER_WITH_FS", None)
    sdspiRegisterWithFS.setLabel("Registerd with File System?")
    sdspiRegisterWithFS.setDefaultValue(False)
    sdspiRegisterWithFS.setVisible(True)
    sdspiRegisterWithFS.setReadOnly(True)

    # RTOS Settings
    sdspiRTOSMenu = sdspiComponent.createMenuSymbol("DRV_SDSPI_RTOS_MENU", None)
    sdspiRTOSMenu.setLabel("RTOS settings")
    sdspiRTOSMenu.setDescription("RTOS settings")
    sdspiRTOSMenu.setVisible((Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != 0))
    sdspiRTOSMenu.setDependencies(showRTOSMenu, ["HarmonyCore.SELECT_RTOS"])

    sdspiRTOSTask = sdspiComponent.createComboSymbol("DRV_SDSPI_RTOS", sdspiRTOSMenu, ["Standalone"])
    sdspiRTOSTask.setLabel("Run Library Tasks As")
    sdspiRTOSTask.setDefaultValue("Standalone")
    sdspiRTOSTask.setVisible(False)

    sdspiRTOSStackSize = sdspiComponent.createIntegerSymbol("DRV_SDSPI_RTOS_STACK_SIZE", sdspiRTOSMenu)
    sdspiRTOSStackSize.setLabel("Stack Size")
    sdspiRTOSStackSize.setDefaultValue(128)
    sdspiRTOSStackSize.setReadOnly(True)

    sdspiRTOSTaskPriority = sdspiComponent.createIntegerSymbol("DRV_SDSPI_RTOS_TASK_PRIORITY", sdspiRTOSMenu)
    sdspiRTOSTaskPriority.setLabel("Task Priority")
    sdspiRTOSTaskPriority.setDefaultValue(1)

    sdspiRTOSTaskDelay = sdspiComponent.createBooleanSymbol("DRV_SDSPI_RTOS_USE_DELAY", sdspiRTOSMenu)
    sdspiRTOSTaskDelay.setLabel("Use Task Delay?")
    sdspiRTOSTaskDelay.setDefaultValue(True)
    sdspiRTOSTaskDelay.setVisible(True)
    sdspiRTOSTaskDelay.setReadOnly(True)
    #sdspiRTOSTaskDelay.setDependencies(setRtosUseDelay, ["drv_sdspi.DRV_SDSPI_COMMON_MODE"])

    sdspiRTOSTaskDelayVal = sdspiComponent.createIntegerSymbol("DRV_SDSPI_RTOS_DELAY", sdspiRTOSMenu)
    sdspiRTOSTaskDelayVal.setLabel("Task Delay (ms)")
    sdspiRTOSTaskDelayVal.setMin(1)
    sdspiRTOSTaskDelayVal.setMax(10000)
    sdspiRTOSTaskDelayVal.setDefaultValue(100)
    sdspiRTOSTaskDelayVal.setVisible((sdspiRTOSTaskDelay.getValue() == True))
    sdspiRTOSTaskDelayVal.setDependencies(setVisible, ["DRV_SDSPI_RTOS_USE_DELAY"])

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
    sdspiSymHeaderFile = sdspiComponent.createFileSymbol("DRV_SDSPI_HEADER", None)
    sdspiSymHeaderFile.setSourcePath("driver/sdspi/drv_sdspi.h")
    sdspiSymHeaderFile.setOutputName("drv_sdspi.h")
    sdspiSymHeaderFile.setDestPath("driver/sdspi/")
    sdspiSymHeaderFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSymHeaderFile.setType("HEADER")
    sdspiSymHeaderFile.setOverwrite(True)

    sdspiSymHeaderDefFile = sdspiComponent.createFileSymbol("DRV_SDSPI_DEF", None)
    sdspiSymHeaderDefFile.setSourcePath("driver/sdspi/templates/drv_sdspi_definitions.h.ftl")
    sdspiSymHeaderDefFile.setOutputName("drv_sdspi_definitions.h")
    sdspiSymHeaderDefFile.setDestPath("driver/sdspi")
    sdspiSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSymHeaderDefFile.setType("HEADER")
    sdspiSymHeaderDefFile.setMarkup(True)
    sdspiSymHeaderDefFile.setOverwrite(True)

    sdspiSymVariantMappingFile = sdspiComponent.createFileSymbol("DRV_SDSPI_VARIANT_MAPPING", None)
    sdspiSymVariantMappingFile.setSourcePath("driver/sdspi/src/drv_sdspi_variant_mapping.h")
    sdspiSymVariantMappingFile.setOutputName("drv_sdspi_variant_mapping.h")
    sdspiSymVariantMappingFile.setDestPath("driver/sdspi/src")
    sdspiSymVariantMappingFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSymVariantMappingFile.setType("SOURCE")
    sdspiSymVariantMappingFile.setMarkup(False)
    sdspiSymVariantMappingFile.setOverwrite(True)

    # Async Source Files
    sdspiAsyncSymSourceFile = sdspiComponent.createFileSymbol("DRV_SDSPI_ASYNC_SOURCE", None)
    sdspiAsyncSymSourceFile.setSourcePath("driver/sdspi/src/async/drv_sdspi.c")
    sdspiAsyncSymSourceFile.setOutputName("drv_sdspi.c")
    sdspiAsyncSymSourceFile.setDestPath("driver/sdspi/src")
    sdspiAsyncSymSourceFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiAsyncSymSourceFile.setType("SOURCE")
    sdspiAsyncSymSourceFile.setOverwrite(True)
    sdspiAsyncSymSourceFile.setEnabled(False)
    sdspiAsyncSymSourceFile.setDependencies(asyncFileGen, ["DRV_SDSPI_MODE"])

    sdspiAsyncSymHeaderLocalFile = sdspiComponent.createFileSymbol("DRV_SDSPI_ASYNC_HEADER_LOCAL", None)
    sdspiAsyncSymHeaderLocalFile.setSourcePath("driver/sdspi/src/async/drv_sdspi_local.h")
    sdspiAsyncSymHeaderLocalFile.setOutputName("drv_sdspi_local.h")
    sdspiAsyncSymHeaderLocalFile.setDestPath("driver/sdspi/src")
    sdspiAsyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiAsyncSymHeaderLocalFile.setType("SOURCE")
    sdspiAsyncSymHeaderLocalFile.setOverwrite(True)
    sdspiAsyncSymHeaderLocalFile.setEnabled(False)
    sdspiAsyncSymHeaderLocalFile.setDependencies(asyncFileGen, ["DRV_SDSPI_MODE"])

    sdspiAsyncSymInterfaceSourceFile = sdspiComponent.createFileSymbol("DRV_SDSPI_ASYNC_INTERFACE_SOURCE", None)
    sdspiAsyncSymInterfaceSourceFile.setSourcePath("driver/sdspi/src/async/drv_sdspi_interface.c")
    sdspiAsyncSymInterfaceSourceFile.setOutputName("drv_sdspi_interface.c")
    sdspiAsyncSymInterfaceSourceFile.setDestPath("driver/sdspi/src")
    sdspiAsyncSymInterfaceSourceFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiAsyncSymInterfaceSourceFile.setType("SOURCE")
    sdspiAsyncSymInterfaceSourceFile.setOverwrite(True)
    sdspiAsyncSymInterfaceSourceFile.setEnabled(False)
    sdspiAsyncSymInterfaceSourceFile.setDependencies(asyncFileGen, ["DRV_SDSPI_MODE"])

    sdspiAsyncSymInterfaceHeaderFile = sdspiComponent.createFileSymbol("DRV_SDSPI_ASYNC_INTERFACE_HEADER", None)
    sdspiAsyncSymInterfaceHeaderFile.setSourcePath("driver/sdspi/src/async/drv_sdspi_interface.h")
    sdspiAsyncSymInterfaceHeaderFile.setOutputName("drv_sdspi_interface.h")
    sdspiAsyncSymInterfaceHeaderFile.setDestPath("driver/sdspi/src")
    sdspiAsyncSymInterfaceHeaderFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiAsyncSymInterfaceHeaderFile.setType("SOURCE")
    sdspiAsyncSymInterfaceHeaderFile.setOverwrite(True)
    sdspiAsyncSymInterfaceHeaderFile.setEnabled(False)
    sdspiAsyncSymInterfaceHeaderFile.setDependencies(asyncFileGen, ["DRV_SDSPI_MODE"])

    # Sync Source Files
    sdspiSyncSymSourceFile = sdspiComponent.createFileSymbol("DRV_SDSPI_SYNC_SOURCE", None)
    sdspiSyncSymSourceFile.setSourcePath("driver/sdspi/src/sync/drv_sdspi.c")
    sdspiSyncSymSourceFile.setOutputName("drv_sdspi.c")
    sdspiSyncSymSourceFile.setDestPath("driver/sdspi/src")
    sdspiSyncSymSourceFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSyncSymSourceFile.setType("SOURCE")
    sdspiSyncSymSourceFile.setOverwrite(True)
    sdspiSyncSymSourceFile.setEnabled(True)
    sdspiSyncSymSourceFile.setDependencies(syncFileGen, ["DRV_SDSPI_MODE"])

    sdspiSyncSymHeaderLocalFile = sdspiComponent.createFileSymbol("DRV_SDSPI_SYNC_HEADER_LOCAL", None)
    sdspiSyncSymHeaderLocalFile.setSourcePath("driver/sdspi/src/sync/drv_sdspi_local.h")
    sdspiSyncSymHeaderLocalFile.setOutputName("drv_sdspi_local.h")
    sdspiSyncSymHeaderLocalFile.setDestPath("driver/sdspi/src")
    sdspiSyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSyncSymHeaderLocalFile.setType("SOURCE")
    sdspiSyncSymHeaderLocalFile.setOverwrite(True)
    sdspiSyncSymHeaderLocalFile.setEnabled(True)
    sdspiSyncSymHeaderLocalFile.setDependencies(syncFileGen, ["DRV_SDSPI_MODE"])

    sdspiSyncSymPlibInterfaceSourceFile = sdspiComponent.createFileSymbol("DRV_SDSPI_SYNC_PLIB_INTERFACE_SOURCE", None)
    sdspiSyncSymPlibInterfaceSourceFile.setSourcePath("driver/sdspi/src/sync/drv_sdspi_plib_interface.c")
    sdspiSyncSymPlibInterfaceSourceFile.setOutputName("drv_sdspi_plib_interface.c")
    sdspiSyncSymPlibInterfaceSourceFile.setDestPath("driver/sdspi/src")
    sdspiSyncSymPlibInterfaceSourceFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSyncSymPlibInterfaceSourceFile.setType("SOURCE")
    sdspiSyncSymPlibInterfaceSourceFile.setOverwrite(True)
    sdspiSyncSymPlibInterfaceSourceFile.setEnabled(True)
    sdspiSyncSymPlibInterfaceSourceFile.setDependencies(syncFileGen, ["DRV_SDSPI_MODE"])

    sdspiSyncSymPlibInterfaceHeaderFile = sdspiComponent.createFileSymbol("DRV_SDSPI_SYNC_PLIB_INTERFACE_HEADER", None)
    sdspiSyncSymPlibInterfaceHeaderFile.setSourcePath("driver/sdspi/src/sync/drv_sdspi_plib_interface.h")
    sdspiSyncSymPlibInterfaceHeaderFile.setOutputName("drv_sdspi_plib_interface.h")
    sdspiSyncSymPlibInterfaceHeaderFile.setDestPath("driver/sdspi/src")
    sdspiSyncSymPlibInterfaceHeaderFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSyncSymPlibInterfaceHeaderFile.setType("SOURCE")
    sdspiSyncSymPlibInterfaceHeaderFile.setOverwrite(True)
    sdspiSyncSymPlibInterfaceHeaderFile.setEnabled(True)
    sdspiSyncSymPlibInterfaceHeaderFile.setDependencies(syncFileGen, ["DRV_SDSPI_MODE"])

    # System Template Files

    sdspiSymSystemDefObjFile = sdspiComponent.createFileSymbol("DRV_SDSPI_SYSTEM_DEF_OBJECT", None)
    sdspiSymSystemDefObjFile.setType("STRING")
    sdspiSymSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    sdspiSymSystemDefObjFile.setSourcePath("driver/sdspi/templates/system/system_definitions_objects.h.ftl")
    sdspiSymSystemDefObjFile.setMarkup(True)

    sdspiSymSystemConfigFile = sdspiComponent.createFileSymbol("DRV_SDSPI_SYSTEM_CONFIG", None)
    sdspiSymSystemConfigFile.setType("STRING")
    sdspiSymSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    sdspiSymSystemConfigFile.setSourcePath("driver/sdspi/templates/system/system_config.h.ftl")
    sdspiSymSystemConfigFile.setMarkup(True)

    sdspiSymSystemInitDataFile = sdspiComponent.createFileSymbol("DRV_SDSPI_INIT_DATA", None)
    sdspiSymSystemInitDataFile.setType("STRING")
    sdspiSymSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    sdspiSymSystemInitDataFile.setSourcePath("driver/sdspi/templates/system/system_initialize_data.c.ftl")
    sdspiSymSystemInitDataFile.setMarkup(True)

    sdspiSymSystemInitFile = sdspiComponent.createFileSymbol("DRV_SDSPI_SYS_INIT", None)
    sdspiSymSystemInitFile.setType("STRING")
    sdspiSymSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    sdspiSymSystemInitFile.setSourcePath("driver/sdspi/templates/system/system_initialize.c.ftl")
    sdspiSymSystemInitFile.setMarkup(True)

    sdspiSystemTasksFile = sdspiComponent.createFileSymbol("DRV_SDSPI_SYS_TASK", None)
    sdspiSystemTasksFile.setType("STRING")
    sdspiSystemTasksFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_DRIVER_TASKS")
    sdspiSystemTasksFile.setSourcePath("driver/sdspi/templates/system/system_tasks.c.ftl")
    sdspiSystemTasksFile.setMarkup(True)

    sdspiSystemRtosTasksFile = sdspiComponent.createFileSymbol("DRV_SDSPI_SYS_RTOS_TASK", None)
    sdspiSystemRtosTasksFile.setType("STRING")
    sdspiSystemRtosTasksFile.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
    sdspiSystemRtosTasksFile.setSourcePath("driver/sdspi/templates/system/system_rtos_tasks.c.ftl")
    sdspiSystemRtosTasksFile.setMarkup(True)
    sdspiSystemRtosTasksFile.setEnabled((Database.getSymbolValue("Harmony", "SELECT_RTOS") != 0))
    sdspiSystemRtosTasksFile.setDependencies(genRtosTask, ["Harmony.SELECT_RTOS"])

def sdspiDriverMode(symbol, event):
    symbol.setValue(Database.getSymbolValue("drv_sdspi", "DRV_SDSPI_COMMON_MODE"), 1)

def onDependencyConnected(info):
    dmaRxRequestID = "DMA_CH_NEEDED_FOR_" + info["remoteComponent"].getID().upper() + "_Receive"
    dmaTxRequestID = "DMA_CH_NEEDED_FOR_" + info["remoteComponent"].getID().upper() + "_Transmit"
    dmaTxChannelID = "DMA_CH_FOR_" + info["remoteComponent"].getID().upper() + "_Transmit"
    dmaRxChannelID = "DMA_CH_FOR_" + info["remoteComponent"].getID().upper() + "_Receive"

    if info["dependencyID"] == "drv_sdspi_SPI_dependency":
        info["localComponent"].setSymbolValue("DRV_SDSPI_PLIB_CONNECTION", True, 2)
        plibUsed = info["localComponent"].getSymbolByID("DRV_SDSPI_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(info["remoteComponent"].getID().upper(), 2)
        Database.setSymbolValue(info["remoteComponent"].getID().upper(), "SPI_DRIVER_CONTROLLED", True, 1)

        if info["localComponent"].getSymbolValue("DRV_SDSPI_TX_RX_DMA") == True:
            Database.setSymbolValue("core", dmaRxRequestID, True, 2)
            Database.setSymbolValue("core", dmaTxRequestID, True, 2)

            # Get the allocated channel and assign it
            txChannel = Database.getSymbolValue("core", dmaTxChannelID)
            info["localComponent"].setSymbolValue("DRV_SDSPI_TX_DMA_CHANNEL", txChannel, 2)
            rxChannel = Database.getSymbolValue("core", dmaRxChannelID)
            info["localComponent"].setSymbolValue("DRV_SDSPI_RX_DMA_CHANNEL", rxChannel, 2)

def onDependencyDisconnected(info):
    dmaRxRequestID = "DMA_CH_NEEDED_FOR_" + info["remoteComponent"].getID().upper() + "_Receive"
    dmaTxRequestID = "DMA_CH_NEEDED_FOR_" + info["remoteComponent"].getID().upper() + "_Transmit"
    dmaTxChannelID = "DMA_CH_FOR_" + info["remoteComponent"].getID().upper() + "_Transmit"
    dmaRxChannelID = "DMA_CH_FOR_" + info["remoteComponent"].getID().upper() + "_Receive"

    if info["dependencyID"] == "drv_sdspi_SPI_dependency" :
        info["localComponent"].setSymbolValue("DRV_SDSPI_PLIB_CONNECTION", False, 2)
        Database.setSymbolValue(info["remoteComponent"].getID().upper(), "SPI_DRIVER_CONTROLLED", False, 1)

        if info["localComponent"].getSymbolValue("DRV_SDSPI_TX_RX_DMA") == True:
            Database.setSymbolValue("core", dmaRxRequestID, False, 2)
            Database.setSymbolValue("core", dmaTxRequestID, False, 2)

            # Get the allocated channel and assign it
            txChannel = Database.getSymbolValue("core", dmaTxChannelID)
            info["localComponent"].setSymbolValue("DRV_SDSPI_TX_DMA_CHANNEL", txChannel, 2)
            rxChannel = Database.getSymbolValue("core", dmaRxChannelID)
            info["localComponent"].setSymbolValue("DRV_SDSPI_RX_DMA_CHANNEL", rxChannel, 2)

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
    symbol.setValue(channel, 2)

def requestDMAComment(symbol, event):
    if event["value"] == -2:
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def destroyComponent(sdspiComponent):
    global drvSdspiInstanceSpace
    spiPeripheral = Database.getSymbolValue(drvSdspiInstanceSpace, "DRV_SPI_PLIB")

    dmaTxID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Transmit"
    dmaRxID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Receive"

    Database.setSymbolValue("core", dmaTxID, False, 2)
    Database.setSymbolValue("core", dmaRxID, False, 2)

def asyncModeOptions(symbol, event):
    if event["value"] == False:
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def syncFileGen(symbol, event):
    if event["value"] == True:
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def asyncFileGen(symbol, event):
    if event["value"] == False:
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def onCapabilityConnected(connectionInfo):
    global sdspiRegisterWithFS

    capability = connectionInfo["capabilityID"]
    localComponent = connectionInfo["localComponent"]
    remoteComponent = connectionInfo["remoteComponent"]

    if (remoteComponent.getID() == "sys_fs"):
        sdspiRegisterWithFS.setValue(True, 1)
        print "onCapabilityConnected",  str(sdspiRegisterWithFS.getValue())
        Database.setSymbolValue("drv_sdspi", "DRV_SDSPI_COMMON_FS_COUNTER", True, 1)

def onCapabilityDisconnected(connectionInfo):
    global sdspiRegisterWithFS

    capability = connectionInfo["capabilityID"]
    localComponent = connectionInfo["localComponent"]
    remoteComponent = connectionInfo["remoteComponent"]

    if (remoteComponent.getID() == "sys_fs"):
        sdspiRegisterWithFS.setValue(False, 1)
        print "onCapabilityDisconnected",  str(sdspiRegisterWithFS.getValue())
        Database.setSymbolValue("drv_sdspi", "DRV_SDSPI_COMMON_FS_COUNTER", False, 1)