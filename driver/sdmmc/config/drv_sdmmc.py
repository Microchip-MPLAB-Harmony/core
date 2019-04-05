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
global sdmmcPLIB

cardDetectMethodList1ComboValues = ["Use Polling", "Use SDCD Pin"]
cardDetectMethodList2ComboValues = ["Use Polling"]

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
        symbol.setValue(1)
        symbol.setReadOnly(True)
    else:
        symbol.setReadOnly(False)

def setPLIBSDCDSupport(symbol, event):
    plibName = event["value"]
    if (plibName == "None"):
        symbol.setValue(False)
    else:
        if (Database.getSymbolValue(plibName.lower(), "SDCARD_SDCD_SUPPORT") == True):
            symbol.setValue(True)
        else:
            symbol.setValue(False)

def setPLIBSDWPSupport(symbol, event):
    plibName = event["value"]
    if (plibName == "None"):
        symbol.setValue(False)
    else:
        if (Database.getSymbolValue(plibName.lower(), "SDCARD_SDWP_SUPPORT") == True):
            symbol.setValue(True)
        else:
            symbol.setValue(False)

def setVisibleCDList1(symbol, event):
    symbol.clearValue()
    plibName = event["value"]
    if (plibName == "None"):
        symbol.setVisible(False)
    else:
        if (Database.getSymbolValue(plibName.lower(), "SDCARD_SDCD_SUPPORT") == True):
            symbol.setVisible(True)
            symbol.setValue(cardDetectMethodList1ComboValues[1])
        else:
            symbol.setVisible(False)

def setVisibleCDList2(symbol, event):
    symbol.clearValue()
    plibName = event["value"]
    if (plibName == "None"):
        symbol.setVisible(False)
    else:
        if (Database.getSymbolValue(plibName.lower(), "SDCARD_SDCD_SUPPORT") == False):
            symbol.setVisible(True)
            symbol.setValue(cardDetectMethodList2ComboValues[0])
        else:
            symbol.setVisible(False)

def setWPCheckVisible(symbol, event):
    plibName = event["value"]
    if (plibName == "None"):
        symbol.setVisible(False)
    else:
        if (Database.getSymbolValue(plibName.lower(), "SDCARD_SDWP_SUPPORT") == True):
            symbol.setVisible(True)
        else:
            symbol.setVisible(False)

def setCDMethod(symbol, event):
    symbol.setValue(event["value"])

def setCDCommentVisible(symbol, event):
    symbol.setVisible(event["value"])

def setWPCommentVisible(symbol, event):
    symbol.setVisible(event["value"])

def setPLIBWPEN(symbol, event):
    global sdmmcWPCheckEnable
    global sdmmcPLIB
    plibName = sdmmcPLIB.getValue()
    if (plibName != "None"):
        plibSDWPEN = Database.getSymbolValue(plibName.lower(), "SDCARD_SDWPEN")
        if (plibSDWPEN != None):
            Database.setSymbolValue(plibName.lower(), "SDCARD_SDWPEN", sdmmcWPCheckEnable.getValue())
            symbol.setValue(sdmmcWPCheckEnable.getValue())
        else:
            symbol.setValue(False)
    else:
        symbol.setValue(False)

def setPLIBCDEN(symbol, event):
    global sdmmcCardDetectionMethod
    global sdmmcPLIB
    plibName = sdmmcPLIB.getValue()
    if (plibName != "None"):
        plibSDCDEN = Database.getSymbolValue(plibName.lower(), "SDCARD_SDCDEN")
        if (plibSDCDEN != None):
            Database.setSymbolValue(plibName.lower(), "SDCARD_SDCDEN", sdmmcCardDetectionMethod.getValue() == "Use SDCD Pin")
            symbol.setValue(sdmmcCardDetectionMethod.getValue() == "Use SDCD Pin")
        else:
            symbol.setValue(False)
    else:
        symbol.setValue(False)

def setVisiblePollingInterval(symbol, event):
    global sdmmcCardDetectionMethod
    global sdmmcPLIB
    plibName = sdmmcPLIB.getValue()
    if (plibName == "None"):
        symbol.setVisible(False)
    else:
        if (sdmmcCardDetectionMethod.getValue() == "Use Polling"):
            symbol.setVisible(True)
        else:
            symbol.setVisible(False)

def instantiateComponent(sdmmcComponent, index):
    global sdmmcFsEnable
    global sdmmcWPCheckEnable
    global sdmmcCardDetectionMethod
    global sdmmcPLIB

    # Enable dependent Harmony core components
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
        Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True)

    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True)

    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA")
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA", True)

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

    sdmmcCardDetectionMethodsList1 = sdmmcComponent.createComboSymbol("DRV_SDMMC_CARD_DETECTION_METHODS_LIST1", None, cardDetectMethodList1ComboValues)
    sdmmcCardDetectionMethodsList1.setLabel("Card Detection Method")
    sdmmcCardDetectionMethodsList1.setDefaultValue(cardDetectMethodList1ComboValues[1])
    sdmmcCardDetectionMethodsList1.setVisible(False)
    sdmmcCardDetectionMethodsList1.setDependencies(setVisibleCDList1, ["DRV_SDMMC_PLIB"])

    sdmmcCardDetectionMethodsList2 = sdmmcComponent.createComboSymbol("DRV_SDMMC_CARD_DETECTION_METHODS_LIST2", None, cardDetectMethodList2ComboValues)
    sdmmcCardDetectionMethodsList2.setLabel("Card Detection Method")
    sdmmcCardDetectionMethodsList2.setDefaultValue(cardDetectMethodList2ComboValues[0])
    sdmmcCardDetectionMethodsList2.setVisible(False)
    sdmmcCardDetectionMethodsList2.setDependencies(setVisibleCDList2, ["DRV_SDMMC_PLIB"])

    sdmmcCardDetectionMethod = sdmmcComponent.createStringSymbol("DRV_SDMMC_CARD_DETECTION_METHOD", None)
    sdmmcCardDetectionMethod.setLabel("Selected Card Detection Method")
    sdmmcCardDetectionMethod.setVisible(False)
    sdmmcCardDetectionMethod.setDefaultValue("None")
    sdmmcCardDetectionMethod.setDependencies(setCDMethod, ["DRV_SDMMC_CARD_DETECTION_METHODS_LIST1" , "DRV_SDMMC_CARD_DETECTION_METHODS_LIST2"])

    sdmmcPlibSdcdEnable = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_PLIB_SDCD_ENABLE", None)
    sdmmcPlibSdcdEnable.setLabel("Enable PLIB SDCD?")
    sdmmcPlibSdcdEnable.setVisible(False)
    sdmmcPlibSdcdEnable.setDefaultValue(sdmmcCardDetectionMethod.getValue() == "Use SDCD Pin")
    sdmmcPlibSdcdEnable.setDependencies(setPLIBCDEN, ["DRV_SDMMC_CARD_DETECTION_METHOD", "DRV_SDMMC_PLIB"])

    sdmmcPLIBSDCDSupport = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_PLIB_SDCD_SUPPORT", None)
    sdmmcPLIBSDCDSupport.setLabel("PLIB_SDCD_SUPPORT")
    sdmmcPLIBSDCDSupport.setVisible(False)
    sdmmcPLIBSDCDSupport.setDefaultValue(False)
    sdmmcPLIBSDCDSupport.setDependencies(setPLIBSDCDSupport, ["DRV_SDMMC_PLIB"])

    sdmmcPLIBSDWPSupport = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_PLIB_SDWP_SUPPORT", None)
    sdmmcPLIBSDWPSupport.setLabel("PLIB_SDWP_SUPPORT")
    sdmmcPLIBSDWPSupport.setVisible(False)
    sdmmcPLIBSDWPSupport.setDefaultValue(False)
    sdmmcPLIBSDWPSupport.setDependencies(setPLIBSDWPSupport, ["DRV_SDMMC_PLIB"])

    sdmmcPollingInterval = sdmmcComponent.createIntegerSymbol("DRV_SDMMC_POLLING_INTERVAL", None)
    sdmmcPollingInterval.setLabel("Polling Interval (ms)")
    sdmmcPollingInterval.setVisible(False)
    sdmmcPollingInterval.setMin(1)
    sdmmcPollingInterval.setDefaultValue(100)
    sdmmcPollingInterval.setDependencies(setVisiblePollingInterval, ["DRV_SDMMC_CARD_DETECTION_METHOD", "DRV_SDMMC_PLIB"])

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
        sdmmcFsEnable.setValue(True)
        Database.setSymbolValue("drv_sdmmc", "DRV_SDMMC_COMMON_FS_COUNTER", True)

def onCapabilityDisconnected(connectionInfo):
    global sdmmcFsEnable

    capability = connectionInfo["capabilityID"]
    localComponent = connectionInfo["localComponent"]
    remoteComponent = connectionInfo["remoteComponent"]

    if (remoteComponent.getID() == "sys_fs"):
        sdmmcFsEnable.setValue(False)
        Database.setSymbolValue("drv_sdmmc", "DRV_SDMMC_COMMON_FS_COUNTER", False)


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
            sdmmcFsEnable.setValue(True)
            Database.setSymbolValue("drv_sdmmc", "DRV_SDMMC_COMMON_FS_COUNTER", True)

    # For Dependency Connected (SDHC/HSMCI)
    if (connectID == "drv_sdmmc_SDHC_dependency"):
        sdmmcPLIBRemoteID = remoteID
        plibUsed = localComponent.getSymbolByID("DRV_SDMMC_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(remoteID.upper())

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
            sdmmcFsEnable.setValue(False)
            Database.setSymbolValue("drv_sdmmc", "DRV_SDMMC_COMMON_FS_COUNTER", False)

    # For Dependency Disonnected (SDHC/HSMCI)
    if (connectID == "drv_sdmmc_SDHC_dependency"):

        plibUsed = localComponent.getSymbolByID("DRV_SDMMC_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue("None")
