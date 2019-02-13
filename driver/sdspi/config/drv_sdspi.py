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

sdspiFsEnable              = None

global isDMAPresent

def setVisible(symbol, event):
    symbol.setVisible(event["value"])

def genRtosTask(symbol, event):
    if event["value"] != "BareMetal":
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def showRTOSMenu(symbol, event):
    if event["value"] != "BareMetal":
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def showWriteProtectComment(symbol, event):
    symbol.setVisible(event["value"])

def requestDMAComment(symbol, event):
    global sdspiTXRXDMA

    if ((event["value"] == -2) and (sdspiTXRXDMA.getValue() == True)):
        symbol.setVisible(True)
        event["symbol"].setVisible(False)
    else:
        symbol.setVisible(False)

def requestAndAssignDMAChannel(symbol, event):
    global drvSdspiInstanceSpace

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
        Database.setSymbolValue("core", dmaRequestID, True, 2)

    # Get the allocated channel and assign it
    channel = Database.getSymbolValue("core", dmaChannelID)
    symbol.setValue(channel, 2)

def instantiateComponent(sdspiComponent, index):
    global drvSdspiInstanceSpace
    global sdspiFsEnable
    global sdspiTXRXDMA
    global isDMAPresent

    drvSdspiInstanceSpace = "drv_sdspi_" + str(index)

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True, 1)

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True, 1)

    # Enable "Enable System Interrupt" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_INT", True, 1)

    # Enable "Enable System Ports" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS", True, 1)

    # Enable "Enable OSAL" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_OSAL", True, 1)

    # Enable "ENABLE_SYS_MEDIA" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA", True, 1)

    if Database.getSymbolValue("core", "DMA_ENABLE") == None:
        isDMAPresent = False
    else:
        isDMAPresent = True

        # Enable "Enable System DMA" option in MHC
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_DMA", True, 1)

    availablePinDictionary = {}

    availablePinDictionary = Database.sendMessage("core", "DRV_SDSPI", availablePinDictionary)

    sdspiSymIndex = sdspiComponent.createIntegerSymbol("INDEX", None)
    sdspiSymIndex.setVisible(False)
    sdspiSymIndex.setDefaultValue(index)

    sdspiSymPLIB = sdspiComponent.createStringSymbol("DRV_SDSPI_PLIB", None)
    sdspiSymPLIB.setLabel("PLIB Used")
    sdspiSymPLIB.setReadOnly(True)
    sdspiSymPLIB.setDefaultValue("")

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

    sdspiFsEnable = sdspiComponent.createBooleanSymbol("DRV_SDSPI_FS_ENABLE", None)
    sdspiFsEnable.setLabel("File system for SDSPI Driver Enabled")
    sdspiFsEnable.setReadOnly(True)

    sdspiSymChipSelectPin = sdspiComponent.createKeyValueSetSymbol("DRV_SDSPI_CHIP_SELECT_PIN", None)
    sdspiSymChipSelectPin.setLabel("Chip Select Pin")
    sdspiSymChipSelectPin.setDefaultValue(0)
    sdspiSymChipSelectPin.setOutputMode("Key")
    sdspiSymChipSelectPin.setDisplayMode("Description")

    sdspiChipSelectPinComment = sdspiComponent.createCommentSymbol("DRV_SDSPI_CHIP_SELECT_PIN_COMMENT", None)
    sdspiChipSelectPinComment.setLabel("!!! Configure the Chip Select pin as GPIO output under Pin Settings.!!! ")

    sdspiSymWriteProtect = sdspiComponent.createBooleanSymbol("DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING", None)
    sdspiSymWriteProtect.setLabel("Use Write Protect Pin (Active High)?")

    sdspiSymWriteProtectPin = sdspiComponent.createKeyValueSetSymbol("DRV_SDSPI_WRITE_PROTECT_PIN", sdspiSymWriteProtect)
    sdspiSymWriteProtectPin.setLabel("Write Protect Pin (Active High)")
    sdspiSymWriteProtectPin.setDefaultValue(0)
    sdspiSymWriteProtectPin.setOutputMode("Key")
    sdspiSymWriteProtectPin.setDisplayMode("Description")
    sdspiSymWriteProtectPin.setVisible(sdspiSymWriteProtect.getValue())
    sdspiSymWriteProtectPin.setDependencies(showWriteProtectComment, ["DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING"])

    sdspiWriteProtectPinComment = sdspiComponent.createCommentSymbol("DRV_SDSPI_WRITE_PROTECT_PIN_COMMENT", sdspiSymWriteProtect)
    sdspiWriteProtectPinComment.setLabel("!!! Configure the Write Protect pin as GPIO input under Pin Settings. !!!")
    sdspiWriteProtectPinComment.setVisible(sdspiSymWriteProtect.getValue())
    sdspiWriteProtectPinComment.setDependencies(showWriteProtectComment, ["DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING"])

    sdspiTXRXDMA = sdspiComponent.createBooleanSymbol("DRV_SDSPI_TX_RX_DMA", None)
    sdspiTXRXDMA.setLabel("Use DMA for Transmit and Receive ?")
    sdspiTXRXDMA.setVisible(isDMAPresent)
    sdspiTXRXDMA.setReadOnly(True)

    sdspiTXDMAChannel = sdspiComponent.createIntegerSymbol("DRV_SDSPI_TX_DMA_CHANNEL", None)
    sdspiTXDMAChannel.setLabel("DMA Channel For Transmit")
    sdspiTXDMAChannel.setDefaultValue(0)
    sdspiTXDMAChannel.setVisible(False)
    sdspiTXDMAChannel.setReadOnly(True)
    sdspiTXDMAChannel.setDependencies(requestAndAssignDMAChannel, ["DRV_SDSPI_TX_RX_DMA"])

    sdspiTXDMAChannelComment = sdspiComponent.createCommentSymbol("DRV_SDSPI_TX_DMA_CH_COMMENT", None)
    sdspiTXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Transmit. Check DMA manager. !!!")
    sdspiTXDMAChannelComment.setVisible(False)
    sdspiTXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_SDSPI_TX_DMA_CHANNEL"])

    sdspiRXDMAChannel = sdspiComponent.createIntegerSymbol("DRV_SDSPI_RX_DMA_CHANNEL", None)
    sdspiRXDMAChannel.setLabel("DMA Channel For Receive")
    sdspiRXDMAChannel.setDefaultValue(1)
    sdspiRXDMAChannel.setVisible(False)
    sdspiRXDMAChannel.setReadOnly(True)
    sdspiRXDMAChannel.setDependencies(requestAndAssignDMAChannel, ["DRV_SDSPI_TX_RX_DMA"])

    sdspiRXDMAChannelComment = sdspiComponent.createCommentSymbol("DRV_SDSPI_RX_DMA_CH_COMMENT", None)
    sdspiRXDMAChannelComment.setLabel("Warning!!! Couldn't Allocate DMA Channel for Receive. Check DMA manager. !!!")
    sdspiRXDMAChannelComment.setVisible(False)
    sdspiRXDMAChannelComment.setDependencies(requestDMAComment, ["DRV_SDSPI_RX_DMA_CHANNEL"])

    sdspiDependencyDMAComment = sdspiComponent.createCommentSymbol("DRV_SDSPI_DEPENDENCY_DMA_COMMENT", None)
    sdspiDependencyDMAComment.setLabel("!!! Satisfy PLIB Dependency to Allocate DMA Channel !!!")
    sdspiDependencyDMAComment.setVisible(isDMAPresent)

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
    sdspiRTOSStackSize.setDefaultValue(256)

    sdspiRTOSTaskPriority = sdspiComponent.createIntegerSymbol("DRV_SDSPI_RTOS_TASK_PRIORITY", sdspiRTOSMenu)
    sdspiRTOSTaskPriority.setLabel("Task Priority")
    sdspiRTOSTaskPriority.setDefaultValue(1)

    sdspiRTOSTaskDelay = sdspiComponent.createBooleanSymbol("DRV_SDSPI_RTOS_USE_DELAY", sdspiRTOSMenu)
    sdspiRTOSTaskDelay.setLabel("Use Task Delay?")
    sdspiRTOSTaskDelay.setDefaultValue(True)
    sdspiRTOSTaskDelay.setVisible(True)
    sdspiRTOSTaskDelay.setReadOnly(True)

    sdspiRTOSTaskDelayVal = sdspiComponent.createIntegerSymbol("DRV_SDSPI_RTOS_DELAY", sdspiRTOSMenu)
    sdspiRTOSTaskDelayVal.setLabel("Task Delay (ms)")
    sdspiRTOSTaskDelayVal.setMin(1)
    sdspiRTOSTaskDelayVal.setMax(10000)
    sdspiRTOSTaskDelayVal.setDefaultValue(10)
    sdspiRTOSTaskDelayVal.setVisible((sdspiRTOSTaskDelay.getValue() == True))
    sdspiRTOSTaskDelayVal.setDependencies(setVisible, ["DRV_SDSPI_RTOS_USE_DELAY"])

    availablePinDictionary = {}

    # Send message to core to get available pins
    availablePinDictionary = Database.sendMessage("core", "PIN_LIST", availablePinDictionary)

    for pin in availablePinDictionary:
        key = "SYS_PORT_PIN_" + availablePinDictionary.get(pin)
        value = pin
        description = availablePinDictionary.get(pin)
        sdspiSymChipSelectPin.addKey(key, value, description)
        sdspiSymWriteProtectPin.addKey(key, value, description)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

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

def destroyComponent(sdspiComponent):
    global drvSdspiInstanceSpace
    spiPeripheral = Database.getSymbolValue(drvSdspiInstanceSpace, "DRV_SPI_PLIB")

    if (spiPeripheral != ""):
        dmaTxID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Transmit"
        dmaRxID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Receive"

        Database.setSymbolValue("core", dmaTxID, False, 2)
        Database.setSymbolValue("core", dmaRxID, False, 2)

def onAttachmentConnected(source, target):
    global sdcardFsEnable
    global isDMAPresent

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    # For Capability Connected (drv_sdcard)
    if (connectID == "drv_media"):
        if (remoteID == "sys_fs"):
            sdspiFsEnable.setValue(True, 1)
            Database.setSymbolValue("drv_sdspi", "DRV_SDSPI_COMMON_FS_COUNTER", True, 1)

    # For Dependency Connected (SPI)
    if (connectID == "drv_sdspi_SPI_dependency"):
        plibUsed = localComponent.getSymbolByID("DRV_SDSPI_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(remoteID.upper(), 2)

        Database.setSymbolValue(remoteID.upper(), "SPI_DRIVER_CONTROLLED", True, 1)

        # Do not change the order as DMA Channels needs to be allocated
        # after setting the plibUsed symbol
        if isDMAPresent == True:
            localComponent.getSymbolByID("DRV_SDSPI_TX_RX_DMA").setReadOnly(False)
            localComponent.getSymbolByID("DRV_SDSPI_DEPENDENCY_DMA_COMMENT").setVisible(False)

def onAttachmentDisconnected(source, target):
    global sdcardFsEnable
    global isDMAPresent

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    # For Capability Disconnected (drv_sdcard)
    if (connectID == "drv_media"):
        if (remoteID == "sys_fs"):
            sdspiFsEnable.setValue(False, 1)
            Database.setSymbolValue("drv_sdspi", "DRV_SDSPI_COMMON_FS_COUNTER", False, 1)

    # For Dependency Disonnected (SPI)
    if (connectID == "drv_sdspi_SPI_dependency"):
        # Do not change the order as DMA Channels needs to be cleared
        # before clearing the plibUsed symbol
        if isDMAPresent == True:
            localComponent.getSymbolByID("DRV_SDSPI_TX_RX_DMA").clearValue()
            localComponent.getSymbolByID("DRV_SDSPI_TX_RX_DMA").setReadOnly(True)
            localComponent.getSymbolByID("DRV_SDSPI_DEPENDENCY_DMA_COMMENT").setVisible(True)

        plibUsed = localComponent.getSymbolByID("DRV_SDSPI_PLIB")
        plibUsed.clearValue()
        Database.setSymbolValue(remoteID.upper(), "SPI_DRIVER_CONTROLLED", False, 1)
