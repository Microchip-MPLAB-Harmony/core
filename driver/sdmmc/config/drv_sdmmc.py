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

global sdmmcFsEnable
global sdmmcWPCheckEnable
global sdmmcCardDetectionMethod
global sdmmcPLIBRemoteID

sdmmcPLIBRemoteID = None

cardDetectMethodComboValuesSDHC = ["Use Polling", "Use SDCD Pin"]
cardDetectMethodComboValuesHSMCI = ["Use Polling"]

def showRTOSMenu(symbol,event):
    if (event["value"] != "BareMetal"):
        # If not Bare Metal
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def genRtosTask(symbol, event):
    symbol.setEnabled((Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"))

def setVisible(symbol, event):
    symbol.setVisible(event["value"])

def setBufferSize(symbol, event):
    if (event["value"] == True):
        symbol.clearValue()
        symbol.setValue(1, 1)
        symbol.setReadOnly(True)
    else:
        symbol.setReadOnly(False)

def setVisibleCDMethodForSDHC(symbol, event):
    plibName = event["value"]
    symbol.clearValue()
    if (plibName[:4] == "SDHC"):
        symbol.setVisible(True)
        symbol.setValue("Use SDCD Pin", 1)
    else:
        symbol.setVisible(False)

def setVisibleCDMethodForHSMCI(symbol, event):
    plibName = event["value"]
    symbol.clearValue()
    if (plibName[:5] == "HSMCI"):
        symbol.setVisible(True)
        symbol.setValue("Use Polling", 1)
    else:
        symbol.setVisible(False)

def setWPCheckVisible(symbol, event):
    plibName = event["value"]
    if (plibName[:4] == "SDHC"):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def setCDMethod(symbol, event):
    symbol.setValue(event["value"], 2)

def setCDCommentVisible(symbol, event):
    symbol.setVisible(event["value"])

def setWPCommentVisible(symbol, event):
    symbol.setVisible(event["value"])

def setPLIBWPEN(symbol, event):
    global sdmmcWPCheckEnable
    global sdmmcPLIBRemoteID

    if (sdmmcPLIBRemoteID != None):
        plibSDWPEN = Database.getSymbolValue(sdmmcPLIBRemoteID, "SDHC_SDWPEN")
        if (plibSDWPEN != None):
            Database.setSymbolValue(sdmmcPLIBRemoteID, "SDHC_SDWPEN", sdmmcWPCheckEnable.getValue(), 2)
            symbol.setValue(sdmmcWPCheckEnable.getValue(), 2)

def setPLIBCDEN(symbol, event):
    global sdmmcCardDetectionMethod
    global sdmmcPLIBRemoteID

    if (sdmmcPLIBRemoteID != None):
        plibSDCDEN = Database.getSymbolValue(sdmmcPLIBRemoteID, "SDHC_SDCDEN")
        if (plibSDCDEN != None):
            Database.setSymbolValue(sdmmcPLIBRemoteID, "SDHC_SDCDEN", sdmmcCardDetectionMethod.getValue() == "Use SDCD Pin", 2)
            symbol.setValue(sdmmcCardDetectionMethod.getValue() == "Use SDCD Pin", 2)

def setVisiblePollingInterval(symbol, event):
    if (event["value"] == "Use Polling"):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def instantiateComponent(sdmmcComponent, index):
    global sdmmcFsEnable
    global sdmmcWPCheckEnable
    global sdmmcCardDetectionMethod

    # Enable dependent Harmony core components
    Database.clearSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
    Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True, 2)

    Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True, 2)

    Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA")
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA", True, 2)

    sdmmcIndex = sdmmcComponent.createIntegerSymbol("INDEX", None)
    sdmmcIndex.setVisible(False)
    sdmmcIndex.setDefaultValue(index)

    sdmmcPLIB = sdmmcComponent.createStringSymbol("DRV_SDMMC_PLIB", None)
    sdmmcPLIB.setLabel("PLIB Used")
    sdmmcPLIB.setReadOnly(True)
    sdmmcPLIB.setDefaultValue("None")

    sdmmcClients = sdmmcComponent.createIntegerSymbol("DRV_SDMMC_CLIENTS_NUMBER", None)
    sdmmcClients.setLabel("Number of Clients")
    sdmmcClients.setMin(1)
    sdmmcClients.setMax(10)
    sdmmcClients.setDefaultValue(1)

    sdmmcBufferObjects = sdmmcComponent.createIntegerSymbol("DRV_SDMMC_BUFFER_OBJECT_NUMBER", None)
    sdmmcBufferObjects.setLabel("Transfer Queue Size")
    sdmmcBufferObjects.setMin(1)
    sdmmcBufferObjects.setMax(64)
    sdmmcBufferObjects.setDefaultValue(2)

    sdmmcBusWidth= sdmmcComponent.createComboSymbol("DRV_SDMMC_TRANSFER_BUS_WIDTH", None,["1-bit", "4-bit"])
    sdmmcBusWidth.setLabel("Data Transfer Bus Width")
    sdmmcBusWidth.setDefaultValue("4-bit")

    sdmmcBusSpeed= sdmmcComponent.createComboSymbol("DRV_SDMMC_BUS_SPEED", None,["DEFAULT_SPEED", "HIGH_SPEED"])
    sdmmcBusSpeed.setLabel("Bus Speed")
    sdmmcBusSpeed.setDefaultValue("DEFAULT_SPEED")

    sdmmcProtocol= sdmmcComponent.createComboSymbol("DRV_SDMMC_PROTOCOL_SUPPORT", None,["SD", "eMMC"])
    sdmmcProtocol.setLabel("Protocol")
    sdmmcProtocol.setDefaultValue("SD")
    sdmmcProtocol.setReadOnly(True)

    sdmmcCardDetectionMethodForSDHC = sdmmcComponent.createComboSymbol("DRV_SDMMC_CARD_DETECTION_METHOD_SDHC", None, cardDetectMethodComboValuesSDHC)
    sdmmcCardDetectionMethodForSDHC.setLabel("Card Detection Method")
    sdmmcCardDetectionMethodForSDHC.setDefaultValue("Use SDCD Pin")
    sdmmcCardDetectionMethodForSDHC.setVisible(False)
    sdmmcCardDetectionMethodForSDHC.setDependencies(setVisibleCDMethodForSDHC, ["DRV_SDMMC_PLIB"])

    sdmmcCardDetectionMethodForHSMCI = sdmmcComponent.createComboSymbol("DRV_SDMMC_CARD_DETECTION_METHOD_HSMCI", None, cardDetectMethodComboValuesHSMCI)
    sdmmcCardDetectionMethodForHSMCI.setLabel("Card Detection Method")
    sdmmcCardDetectionMethodForHSMCI.setDefaultValue("Use Polling")
    sdmmcCardDetectionMethodForHSMCI.setVisible(False)
    sdmmcCardDetectionMethodForHSMCI.setDependencies(setVisibleCDMethodForHSMCI, ["DRV_SDMMC_PLIB"])

    sdmmcCardDetectionMethod = sdmmcComponent.createStringSymbol("DRV_SDMMC_CARD_DETECTION_METHOD", None)
    sdmmcCardDetectionMethod.setLabel("Selected Card Detection Method")
    sdmmcCardDetectionMethod.setVisible(False)
    sdmmcCardDetectionMethod.setDefaultValue("None")
    sdmmcCardDetectionMethod.setDependencies(setCDMethod, ["DRV_SDMMC_CARD_DETECTION_METHOD_SDHC" , "DRV_SDMMC_CARD_DETECTION_METHOD_HSMCI"])

    sdmmcPlibSdcdEnable = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_PLIB_SDCD_ENABLE", None)
    sdmmcPlibSdcdEnable.setLabel("Enable PLIB SDCD?")
    sdmmcPlibSdcdEnable.setVisible(False)
    sdmmcPlibSdcdEnable.setDefaultValue(sdmmcCardDetectionMethod.getValue() == "Use SDCD Pin")
    sdmmcPlibSdcdEnable.setDependencies(setPLIBCDEN, ["DRV_SDMMC_CARD_DETECTION_METHOD", "DRV_SDMMC_PLIB"])

    sdmmcPollingInterval = sdmmcComponent.createIntegerSymbol("DRV_SDMMC_POLLING_INTERVAL", None)
    sdmmcPollingInterval.setLabel("Polling Interval (ms)")
    sdmmcPollingInterval.setVisible(False)
    sdmmcPollingInterval.setMin(1)
    sdmmcPollingInterval.setDefaultValue(100)
    sdmmcPollingInterval.setDependencies(setVisiblePollingInterval, ["DRV_SDMMC_CARD_DETECTION_METHOD"])

    sdmmcCDComment = sdmmcComponent.createCommentSymbol("DRV_SDMMC_SDCDEN_COMMENT", None)
    sdmmcCDComment.setLabel("!!!Configure SDCD pin in Pin Configuration!!!")
    sdmmcCDComment.setVisible(sdmmcPlibSdcdEnable.getValue())
    sdmmcCDComment.setDependencies(setCDCommentVisible, ["DRV_SDMMC_PLIB_SDCD_ENABLE"])

    sdmmcWPCheckEnable = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_WP_CHECK_ENABLE", None)
    sdmmcWPCheckEnable.setLabel("Enable Write Protection Check?")
    sdmmcWPCheckEnable.setDefaultValue(False)
    sdmmcWPCheckEnable.setVisible(False)
    sdmmcWPCheckEnable.setDependencies(setWPCheckVisible, ["DRV_SDMMC_PLIB"])

    sdmmcPlibSdwpEnable = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_PLIB_SDWP_ENABLE", None)
    sdmmcPlibSdwpEnable.setLabel("Enable PLIB SDWP?")
    sdmmcPlibSdwpEnable.setVisible(False)
    sdmmcPlibSdwpEnable.setDefaultValue(sdmmcWPCheckEnable.getValue())
    sdmmcPlibSdwpEnable.setDependencies(setPLIBWPEN, ["DRV_SDMMC_WP_CHECK_ENABLE", "DRV_SDMMC_PLIB"])

    sdmmcWPComment = sdmmcComponent.createCommentSymbol("DRV_SDMMC_SDWPEN_COMMENT", None)
    sdmmcWPComment.setLabel("!!!Configure SDWP pin in Pin Configuration!!!")
    sdmmcWPComment.setVisible(sdmmcPlibSdwpEnable.getValue())
    sdmmcWPComment.setDependencies(setWPCommentVisible, ["DRV_SDMMC_PLIB_SDWP_ENABLE"])

    sdmmcFsEnable = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_FS_ENABLE", None)
    sdmmcFsEnable.setLabel("File system for SDMMC Driver Enabled")
    sdmmcFsEnable.setDefaultValue(False)
    sdmmcFsEnable.setReadOnly(True)

    sdmmcBufferObjects.setReadOnly((sdmmcFsEnable.getValue() == True))
    sdmmcBufferObjects.setDependencies(setBufferSize, ["DRV_SDMMC_FS_ENABLE"])

    sdmmcRTOSMenu = sdmmcComponent.createMenuSymbol("DRV_SDMMC_RTOS_MENU", None)
    sdmmcRTOSMenu.setLabel("RTOS Configuration")
    sdmmcRTOSMenu.setDescription("RTOS Configuration")
    sdmmcRTOSMenu.setVisible((Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"))
    sdmmcRTOSMenu.setDependencies(showRTOSMenu, ["HarmonyCore.SELECT_RTOS"])

    sdmmcRTOSTask = sdmmcComponent.createComboSymbol("DRV_SDMMC_RTOS", sdmmcRTOSMenu, ["Standalone"])
    sdmmcRTOSTask.setLabel("Run Library Tasks As")
    sdmmcRTOSTask.setDefaultValue("Standalone")
    sdmmcRTOSTask.setVisible(False)

    sdmmcRTOSTaskSize = sdmmcComponent.createIntegerSymbol("DRV_SDMMC_RTOS_STACK_SIZE", sdmmcRTOSMenu)
    sdmmcRTOSTaskSize.setLabel("Stack Size")
    sdmmcRTOSTaskSize.setDefaultValue(1024)

    sdmmcRTOSTaskPriority = sdmmcComponent.createIntegerSymbol("DRV_SDMMC_RTOS_TASK_PRIORITY", sdmmcRTOSMenu)
    sdmmcRTOSTaskPriority.setLabel("Task Priority")
    sdmmcRTOSTaskPriority.setDefaultValue(1)

    sdmmcRTOSTaskDelay = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_RTOS_USE_DELAY", sdmmcRTOSMenu)
    sdmmcRTOSTaskDelay.setLabel("Use Task Delay?")
    sdmmcRTOSTaskDelay.setDefaultValue(True)

    sdmmcRTOSTaskDelayVal = sdmmcComponent.createIntegerSymbol("DRV_SDMMC_RTOS_DELAY", sdmmcRTOSMenu)
    sdmmcRTOSTaskDelayVal.setLabel("Task Delay")
    sdmmcRTOSTaskDelayVal.setDefaultValue(10)
    sdmmcRTOSTaskDelayVal.setVisible(sdmmcRTOSTaskDelay.getValue())
    sdmmcRTOSTaskDelayVal.setDependencies(setVisible, ["DRV_SDMMC_RTOS_USE_DELAY"])

    configName = Variables.get("__CONFIGURATION_NAME")

    sdmmcSystemInitFile = sdmmcComponent.createFileSymbol("DRV_SDMMC_INITIALIZE_C", None)
    sdmmcSystemInitFile.setType("STRING")
    sdmmcSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    sdmmcSystemInitFile.setSourcePath("/driver/sdmmc/templates/system/system_initialize.c.ftl")
    sdmmcSystemInitFile.setMarkup(True)

    sdmmcSystemConfFile = sdmmcComponent.createFileSymbol("DRV_SDMMC_CONFIGURATION_H", None)
    sdmmcSystemConfFile.setType("STRING")
    sdmmcSystemConfFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    sdmmcSystemConfFile.setSourcePath("/driver/sdmmc/templates/system/system_config.h.ftl")
    sdmmcSystemConfFile.setMarkup(True)

    sdmmcSystemDataFile = sdmmcComponent.createFileSymbol("DRV_SDMMC_INITIALIZATION_DATA_C", None)
    sdmmcSystemDataFile.setType("STRING")
    sdmmcSystemDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    sdmmcSystemDataFile.setSourcePath("/driver/sdmmc/templates/system/system_initialize_data.c.ftl")
    sdmmcSystemDataFile.setMarkup(True)

    sdmmcSystemObjFile = sdmmcComponent.createFileSymbol("DRV_SDMMC_SYSTEM_OBJECTS_H", None)
    sdmmcSystemObjFile.setType("STRING")
    sdmmcSystemObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    sdmmcSystemObjFile.setSourcePath("/driver/sdmmc/templates/system/system_objects.h.ftl")
    sdmmcSystemObjFile.setMarkup(True)

    sdmmcSystemTaskFile = sdmmcComponent.createFileSymbol("DRV_SDMMC_SYSTEM_TASKS_C", None)
    sdmmcSystemTaskFile.setType("STRING")
    sdmmcSystemTaskFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS")
    sdmmcSystemTaskFile.setSourcePath("/driver/sdmmc/templates/system/system_tasks.c.ftl")
    sdmmcSystemTaskFile.setMarkup(True)

    sdmmcSystemRtosTasksFile = sdmmcComponent.createFileSymbol("DRV_SDMMC_SYS_RTOS_TASK", None)
    sdmmcSystemRtosTasksFile.setType("STRING")
    sdmmcSystemRtosTasksFile.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
    sdmmcSystemRtosTasksFile.setSourcePath("driver/sdmmc/templates/system/system_rtos_tasks.c.ftl")
    sdmmcSystemRtosTasksFile.setMarkup(True)
    sdmmcSystemRtosTasksFile.setEnabled((Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"))
    sdmmcSystemRtosTasksFile.setDependencies(genRtosTask, ["HarmonyCore.SELECT_RTOS"])

    sdmmcSourceFile = sdmmcComponent.createFileSymbol("DRV_SDMMC_C", None)
    sdmmcSourceFile.setSourcePath("driver/sdmmc/templates/drv_sdmmc.c.ftl")
    sdmmcSourceFile.setOutputName("drv_sdmmc.c")
    sdmmcSourceFile.setDestPath("/driver/sdmmc/src/")
    sdmmcSourceFile.setProjectPath("config/" + configName + "/driver/sdmmc/")
    sdmmcSourceFile.setType("SOURCE")
    sdmmcSourceFile.setMarkup(True)
    sdmmcSourceFile.setOverwrite(True)

def onCapabilityConnected(connectionInfo):
    global sdmmcFsEnable

    capability = connectionInfo["capabilityID"]
    localComponent = connectionInfo["localComponent"]
    remoteComponent = connectionInfo["remoteComponent"]

    if (remoteComponent.getID() == "sys_fs"):
        sdmmcFsEnable.setValue(True, 1)
        Database.setSymbolValue("drv_sdmmc", "DRV_SDMMC_COMMON_FS_COUNTER", True, 1)

def onCapabilityDisconnected(connectionInfo):
    global sdmmcFsEnable

    capability = connectionInfo["capabilityID"]
    localComponent = connectionInfo["localComponent"]
    remoteComponent = connectionInfo["remoteComponent"]

    if (remoteComponent.getID() == "sys_fs"):
        sdmmcFsEnable.setValue(False, 1)
        Database.setSymbolValue("drv_sdmmc", "DRV_SDMMC_COMMON_FS_COUNTER", False, 1)


def onAttachmentConnected(source, target):
    #global sdcardFsEnable
    global sdmmcPLIBRemoteID

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    # For Capability Connected (DRV_MEDIA)
    if (connectID == "drv_media"):
        if (remoteID == "sys_fs"):
            sdmmcFsEnable.setValue(True, 1)
            Database.setSymbolValue("drv_sdmmc", "DRV_SDMMC_COMMON_FS_COUNTER", True, 1)

    # For Dependency Connected (SDHC/HSMCI)
    if (connectID == "drv_sdmmc_SDHC_dependency"):
        sdmmcPLIBRemoteID = remoteID
        plibUsed = localComponent.getSymbolByID("DRV_SDMMC_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(remoteID.upper(), 2)

def onAttachmentDisconnected(source, target):
    #global sdcardFsEnable

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    # For Capability Disconnected (DRV_MEDIA)
    if (connectID == "drv_media"):
        if (remoteID == "sys_fs"):
            sdmmcFsEnable.setValue(False, 1)
            Database.setSymbolValue("drv_sdmmc", "DRV_SDMMC_COMMON_FS_COUNTER", False, 1)

    # For Dependency Disonnected (SDHC/HSMCI)
    if (connectID == "drv_sdmmc_SDHC_dependency"):

        plibUsed = localComponent.getSymbolByID("DRV_SDMMC_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue("None", 1)
