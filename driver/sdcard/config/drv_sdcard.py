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
global fsCounter
global sdcardFsEnable

coreArchitecture = {"condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70"])'}

fsCounter = 0
sdcardFsEnable = None

def enableFileSystemIntegration(symbol, event):
    symbol.setEnabled(event["value"])

def setFileSystem(symbol, event):
    global fsCounter

    if event["value"] == True:
        fsCounter = fsCounter + 1
        symbol.clearValue()
        symbol.setValue(True, 1)
    else:
        if fsCounter > 0:
            fsCounter = fsCounter - 1

    if fsCounter == 0:
        symbol.clearValue()
        symbol.setValue(False, 1)

def setSdcardProtocolName(symbol, event):
    if (event["value"] == "SDHC"):
        symbol.setValue("DRV_SDHC", 1)
    elif (event["value"] == "SDSPI"):
        symbol.setValue("DRV_SDSPI", 1)

def setDependency(symbol, event):
    component = symbol.getComponent()
    component.setDependencyEnabled("drv_sdcard_SPI_dependency", False)

    symbol.setVisible(True)

    if (event["value"] == "SDHC"):
        if (eval(coreArchitecture['condition']) == False):
            symbol.setVisible(False)
        else:
            symbol.setValue("Asynchronous", 1)
    elif (event["value"] == "SDSPI"):
        symbol.setValue("Synchronous", 1)
        component.setDependencyEnabled("drv_sdcard_SPI_dependency", True)

def enableSdhcComment(symbol, event):
    symbol.setVisible(False)

    if (event["value"] == "SDHC"):
        if (eval(coreArchitecture['condition']) == False):
            symbol.setVisible(True)

def sdcardFileGen(symbol, event):
    if (event["value"] == "SDHC"):
        symbol.setEnabled(False)
    elif (event["value"] == "SDSPI"):
        symbol.setEnabled(True)

def showRTOSMenu(symbol, event):
    if (event["value"] != "BareMetal"):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def setSdcardConfigVisible(symbol, event):
    symbol.setVisible(event["value"])

def setSdcardUseTaskDelayReadOnly(symbol, event):
    if (event["value"] == "SDSPI"):
        symbol.setReadOnly(True)
    else:
        symbol.setReadOnly(False)

def instantiateComponent(sdcardComponent):
    global sdcardFsEnable

    res = Database.activateComponents(["HarmonyCore"])
    res = Database.activateComponents(["sys_time"])

    # Enable dependent Harmony core components
    Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True, 1)

    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True, 1)

    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA", True, 1)

    Database.setSymbolValue("HarmonyCore", "ENABLE_OSAL", True, 1)

    sdcardProtocol = sdcardComponent.createComboSymbol("DRV_SDCARD_SELECT_PROTOCOL", None, ["SDSPI", "SDHC"])
    sdcardProtocol.setLabel("Select Protocol")
    sdcardProtocol.setDescription("Select Protocol")
    sdcardProtocol.setDefaultValue("SDSPI")

    drvSdhcSym = sdcardComponent.createStringSymbol("DRV_SDCARD_PROTOCOL", None)
    drvSdhcSym.setLabel("SDHC Driver Name")
    drvSdhcSym.setReadOnly(True)
    drvSdhcSym.setVisible(False)
    drvSdhcSym.setDefaultValue("DRV_SDSPI")
    drvSdhcSym.setDependencies(setSdcardProtocolName, ["DRV_SDCARD_SELECT_PROTOCOL"])

    # SDCARD Common configurations
    sdcardSdspiMode = sdcardComponent.createComboSymbol("DRV_SDCARD_COMMON_MODE", None, ["Asynchronous", "Synchronous"])
    sdcardSdspiMode.setLabel("Driver Mode")
    sdcardSdspiMode.setDefaultValue("Synchronous")
    sdcardSdspiMode.setVisible(True)
    sdcardSdspiMode.setReadOnly(True)
    sdcardSdspiMode.setDependencies(setDependency, ["DRV_SDCARD_SELECT_PROTOCOL"])

    sdcardSdhcComment = sdcardComponent.createCommentSymbol("DRV_SDCARD_SDHC_SUPPORT_COMMENT", None)
    sdcardSdhcComment.setLabel("***** SDHC Protocol not supported in this device *****")
    sdcardSdhcComment.setVisible(False)
    sdcardSdhcComment.setDependencies(enableSdhcComment, ["DRV_SDCARD_SELECT_PROTOCOL"])

    sdcardFsEnable = sdcardComponent.createBooleanSymbol("DRV_SDCARD_FS_ENABLE", None)
    sdcardFsEnable.setLabel("File system for SDCARD Driver Enabled?")
    sdcardFsEnable.setDefaultValue(False)
    sdcardFsEnable.setVisible(True)
    sdcardFsEnable.setReadOnly(True)

    sdcardCommonfsCounter = sdcardComponent.createBooleanSymbol("DRV_SDCARD_COMMON_FS_COUNTER", None)
    sdcardCommonfsCounter.setLabel("Number of Instances Using FS")
    sdcardCommonfsCounter.setDefaultValue(False)
    sdcardCommonfsCounter.setVisible(False)
    sdcardCommonfsCounter.setUseSingleDynamicValue(True)

    sdcardCommonFsEnable = sdcardComponent.createBooleanSymbol("DRV_SDCARD_COMMON_FS_ENABLE", None)
    sdcardCommonFsEnable.setLabel("Enable Common File system for SD Card Driver")
    sdcardCommonFsEnable.setDefaultValue(False)
    sdcardCommonFsEnable.setVisible(False)
    sdcardCommonFsEnable.setDependencies(setFileSystem, ["DRV_SDCARD_COMMON_FS_COUNTER"])

    # SDHC specific configurations: SDHC suported for "SAMV70", "SAMV71", "SAME70", "SAMS70" devices
    if eval(coreArchitecture['condition']):
        execfile(Module.getPath() + "driver/sdcard/config/drv_sdhc.py")

    # SDSPI specific configurations:
    execfile(Module.getPath() + "driver/sdcard/config/drv_sdspi.py")

    # Common RTOS Configurations
    sdcardRTOSMenu = sdcardComponent.createMenuSymbol("SDCARD_RTOS_MENU", None)
    sdcardRTOSMenu.setLabel("RTOS Configuration")
    sdcardRTOSMenu.setDescription("RTOS Configuration")
    sdcardRTOSMenu.setVisible((Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"))
    sdcardRTOSMenu.setDependencies(showRTOSMenu, ["HarmonyCore.SELECT_RTOS"])

    sdcardRTOSTask = sdcardComponent.createComboSymbol("DRV_SDCARD_RTOS", sdcardRTOSMenu, ["Standalone"])
    sdcardRTOSTask.setLabel("Run Library Tasks As")
    sdcardRTOSTask.setDefaultValue("Standalone")
    sdcardRTOSTask.setVisible(False)

    sdcardRTOSTaskSize = sdcardComponent.createIntegerSymbol("DRV_SDCARD_RTOS_STACK_SIZE", sdcardRTOSMenu)
    sdcardRTOSTaskSize.setLabel("Stack Size")
    sdcardRTOSTaskSize.setDefaultValue(128)

    sdcardRTOSTaskPriority = sdcardComponent.createIntegerSymbol("DRV_SDCARD_RTOS_TASK_PRIORITY", sdcardRTOSMenu)
    sdcardRTOSTaskPriority.setLabel("Task Priority")
    sdcardRTOSTaskPriority.setDefaultValue(1)

    sdcardRTOSTaskDelay = sdcardComponent.createBooleanSymbol("DRV_SDCARD_RTOS_USE_DELAY", sdcardRTOSMenu)
    sdcardRTOSTaskDelay.setLabel("Use Task Delay?")
    sdcardRTOSTaskDelay.setDefaultValue(True)
    sdcardRTOSTaskDelay.setReadOnly(True)
    sdcardRTOSTaskDelay.setDependencies(setSdcardUseTaskDelayReadOnly, ["DRV_SDCARD_SELECT_PROTOCOL"])

    sdcardRTOSTaskDelayVal = sdcardComponent.createIntegerSymbol("DRV_SDCARD_RTOS_DELAY", sdcardRTOSMenu)
    sdcardRTOSTaskDelayVal.setLabel("Task Delay")
    sdcardRTOSTaskDelayVal.setDefaultValue(10)
    sdcardRTOSTaskDelayVal.setVisible(sdcardRTOSTaskDelay.getValue())
    sdcardRTOSTaskDelayVal.setDependencies(setSdcardConfigVisible, ["DRV_SDCARD_RTOS_USE_DELAY"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    sdcardSourceFile = sdcardComponent.createFileSymbol("DRV_SDCARD_C", None)
    sdcardSourceFile.setSourcePath("driver/sdcard/src/drv_sdcard.c")
    sdcardSourceFile.setOutputName("drv_sdcard.c")
    sdcardSourceFile.setDestPath("/driver/sdcard/")
    sdcardSourceFile.setProjectPath("config/" + configName + "/driver/sdcard/")
    sdcardSourceFile.setType("SOURCE")

    sdcardLocFile = sdcardComponent.createFileSymbol("DRV_SDCARD_LOCAL_H", None)
    sdcardLocFile.setSourcePath("driver/sdcard/src/drv_sdcard_local.h")
    sdcardLocFile.setOutputName("drv_sdcard_local.h")
    sdcardLocFile.setDestPath("/driver/sdcard/")
    sdcardLocFile.setProjectPath("config/" + configName + "/driver/sdcard/")
    sdcardLocFile.setType("HEADER")

    sdcardDefFile = sdcardComponent.createFileSymbol("DRV_SDCARD_DEF_H", None)
    sdcardDefFile.setSourcePath("driver/sdcard/drv_sdcard_definitions.h")
    sdcardDefFile.setOutputName("drv_sdcard_definitions.h")
    sdcardDefFile.setDestPath("/driver/sdcard/")
    sdcardDefFile.setProjectPath("config/" + configName + "/driver/sdcard/")
    sdcardDefFile.setType("HEADER")

    sdcardHeaderFile = sdcardComponent.createFileSymbol("DRV_SDCARD_HEADER_H", None)
    sdcardHeaderFile.setSourcePath("driver/sdcard/drv_sdcard.h")
    sdcardHeaderFile.setOutputName("drv_sdcard.h")
    sdcardHeaderFile.setDestPath("/driver/sdcard/")
    sdcardHeaderFile.setProjectPath("config/" + configName + "/driver/sdcard/")
    sdcardHeaderFile.setType("HEADER")

    sdcardCommonFsSourceFile = sdcardComponent.createFileSymbol("DRV_SDCARD_FS_SOURCE", None)
    sdcardCommonFsSourceFile.setSourcePath("driver/sdcard/src/drv_sdcard_file_system.c")
    sdcardCommonFsSourceFile.setOutputName("drv_sdcard_file_system.c")
    sdcardCommonFsSourceFile.setDestPath("driver/sdcard/src")
    sdcardCommonFsSourceFile.setProjectPath("config/" + configName + "/driver/sdcard/")
    sdcardCommonFsSourceFile.setType("SOURCE")
    sdcardCommonFsSourceFile.setOverwrite(True)
    sdcardCommonFsSourceFile.setEnabled((sdcardCommonFsEnable.getValue() == True))
    sdcardCommonFsSourceFile.setDependencies(enableFileSystemIntegration, ["DRV_SDCARD_COMMON_FS_ENABLE"])

    # System Template Files
    sdcardSymSystemDefIncFile = sdcardComponent.createFileSymbol("DRV_SDCARD_SYSTEM_DEF", None)
    sdcardSymSystemDefIncFile.setType("STRING")
    sdcardSymSystemDefIncFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sdcardSymSystemDefIncFile.setSourcePath("driver/sdcard/templates/system/system_definitions.h.ftl")
    sdcardSymSystemDefIncFile.setMarkup(True)

    sdcardSymSystemInitDataFile = sdcardComponent.createFileSymbol("DRV_SDCARD_INIT_DATA", None)
    sdcardSymSystemInitDataFile.setType("STRING")
    sdcardSymSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    sdcardSymSystemInitDataFile.setSourcePath("driver/sdcard/templates/system/system_initialize_data.c.ftl")
    sdcardSymSystemInitDataFile.setMarkup(True)

    sdcardSystemConfFile = sdcardComponent.createFileSymbol("DRV_SDCARD_CONFIGURATION_H", None)
    sdcardSystemConfFile.setType("STRING")
    sdcardSystemConfFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    sdcardSystemConfFile.setSourcePath("/driver/sdcard/templates/system/system_config.h.ftl")
    sdcardSystemConfFile.setMarkup(True)

    sdcardSystemInitFile = sdcardComponent.createFileSymbol("DRV_SDCARD_INITIALIZE_C", None)
    sdcardSystemInitFile.setType("STRING")
    sdcardSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    sdcardSystemInitFile.setSourcePath("/driver/sdcard/templates/system/system_initialize.c.ftl")
    sdcardSystemInitFile.setMarkup(True)

    sdcardSystemObjFile = sdcardComponent.createFileSymbol("DRV_SDCARD_SYSTEM_OBJECTS_H", None)
    sdcardSystemObjFile.setType("STRING")
    sdcardSystemObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    sdcardSystemObjFile.setSourcePath("/driver/sdcard/templates/system/system_objects.h.ftl")
    sdcardSystemObjFile.setMarkup(True)

    sdcardSystemTaskFile = sdcardComponent.createFileSymbol("DRV_SDCARD_SYSTEM_TASKS_C", None)
    sdcardSystemTaskFile.setType("STRING")
    sdcardSystemTaskFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS")
    sdcardSystemTaskFile.setSourcePath("/driver/sdcard/templates/system/system_tasks.c.ftl")
    sdcardSystemTaskFile.setMarkup(True)

    sdcardSystemRtosTasksFile = sdcardComponent.createFileSymbol("DRV_SDCARD_SYS_RTOS_TASK", None)
    sdcardSystemRtosTasksFile.setType("STRING")
    sdcardSystemRtosTasksFile.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
    sdcardSystemRtosTasksFile.setSourcePath("driver/sdcard/templates/system/system_rtos_tasks.c.ftl")
    sdcardSystemRtosTasksFile.setMarkup(True)

def destroyComponent(sdcardComponent):
    global drvSdspiInstanceSpace

    spiPeripheral = Database.getSymbolValue(drvSdspiInstanceSpace, "DRV_SPI_PLIB")

    dmaTxID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Transmit"
    dmaRxID = "DMA_CH_NEEDED_FOR_" + str(spiPeripheral) + "_Receive"

    Database.setSymbolValue("core", dmaTxID, False, 2)
    Database.setSymbolValue("core", dmaRxID, False, 2)

    # If device selected is anyone of "SAMV70", "SAMV71", "SAME70", "SAMS70"
    if eval(coreArchitecture['condition']):
        Database.setSymbolValue("core","DMA_CH_NEEDED_FOR_HSMCI", False, 2)

def onAttachmentConnected(connectionInfo):
    global sdcardFsEnable

    localComponent = connectionInfo["localComponent"]
    remoteComponent = connectionInfo["remoteComponent"]
    remoteID = remoteComponent.getID()
    connectID = connectionInfo["id"]
    targetID = connectionInfo["targetID"]

    # For Capability Connected (drv_sdcard)
    if (connectID == "drv_media"):
        if (remoteID == "sys_fs"):
            sdcardFsEnable.setValue(True, 1)
            localComponent.setSymbolValue("DRV_SDCARD_COMMON_FS_COUNTER", True, 1)

    # For Dependency Connected (SPI)
    if (connectID == "drv_sdcard_SPI_dependency"):
        dmaRxRequestID = "DMA_CH_NEEDED_FOR_" + remoteID.upper() + "_Receive"
        dmaTxRequestID = "DMA_CH_NEEDED_FOR_" + remoteID.upper() + "_Transmit"
        dmaTxChannelID = "DMA_CH_FOR_" + remoteID.upper() + "_Transmit"
        dmaRxChannelID = "DMA_CH_FOR_" + remoteID.upper() + "_Receive"

        localComponent.setSymbolValue("DRV_SDSPI_PLIB_CONNECTION", True, 2)
        plibUsed = localComponent.getSymbolByID("DRV_SDSPI_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(remoteID.upper(), 2)
        Database.setSymbolValue(remoteID.upper(), "SPI_DRIVER_CONTROLLED", True, 1)

        if localComponent.getSymbolValue("DRV_SDSPI_TX_RX_DMA") == True:
            Database.setSymbolValue("core", dmaRxRequestID, True, 2)
            Database.setSymbolValue("core", dmaTxRequestID, True, 2)

            # Get the allocated channel and assign it
            txChannel = Database.getSymbolValue("core", dmaTxChannelID)
            localComponent.setSymbolValue("DRV_SDSPI_TX_DMA_CHANNEL", txChannel, 2)
            rxChannel = Database.getSymbolValue("core", dmaRxChannelID)
            localComponent.setSymbolValue("DRV_SDSPI_RX_DMA_CHANNEL", rxChannel, 2)

def onAttachmentDisconnected(connectionInfo):
    global sdcardFsEnable

    localComponent = connectionInfo["localComponent"]
    remoteComponent = connectionInfo["remoteComponent"]
    remoteID = remoteComponent.getID()
    connectID = connectionInfo["id"]
    targetID = connectionInfo["targetID"]

    # For Capability Disconnected (drv_sdcard)
    if (connectID == "drv_media"):
        if (remoteID == "sys_fs"):
            sdcardFsEnable.setValue(False, 1)
            localComponent.setSymbolValue("DRV_SDCARD_COMMON_FS_COUNTER", False, 1)

    # For Dependency Disonnected (SPI)
    if (connectID == "drv_sdcard_SPI_dependency"):
        dmaRxRequestID = "DMA_CH_NEEDED_FOR_" + remoteID.upper() + "_Receive"
        dmaTxRequestID = "DMA_CH_NEEDED_FOR_" + remoteID.upper() + "_Transmit"
        dmaTxChannelID = "DMA_CH_FOR_" + remoteID.upper() + "_Transmit"
        dmaRxChannelID = "DMA_CH_FOR_" + remoteID.upper() + "_Receive"

        localComponent.setSymbolValue("DRV_SDSPI_PLIB_CONNECTION", False, 2)
        plibUsed = localComponent.getSymbolByID("DRV_SDSPI_PLIB")
        plibUsed.clearValue()
        Database.setSymbolValue(remoteID.upper(), "SPI_DRIVER_CONTROLLED", False, 1)

        if localComponent.getSymbolValue("DRV_SDSPI_TX_RX_DMA") == True:
            Database.setSymbolValue("core", dmaRxRequestID, False, 2)
            Database.setSymbolValue("core", dmaTxRequestID, False, 2)

            # Get the allocated channel and assign it
            txChannel = Database.getSymbolValue("core", dmaTxChannelID)
            localComponent.setSymbolValue("DRV_SDSPI_TX_DMA_CHANNEL", txChannel, 2)
            rxChannel = Database.getSymbolValue("core", dmaRxChannelID)
            localComponent.setSymbolValue("DRV_SDSPI_RX_DMA_CHANNEL", rxChannel, 2)
