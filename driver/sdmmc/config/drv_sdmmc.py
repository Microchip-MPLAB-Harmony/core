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

def setCDMethod(symbol, event):
    plibName = event["source"].getSymbolValue("DRV_SDMMC_PLIB")
    protocol = event["source"].getSymbolValue("DRV_SDMMC_PROTOCOL_SUPPORT")
    cdList1 = event["source"].getSymbolByID("DRV_SDMMC_CARD_DETECTION_METHODS_LIST1")
    cdList2 = event["source"].getSymbolByID("DRV_SDMMC_CARD_DETECTION_METHODS_LIST2")
    value = "None"
    if plibName != "None" and protocol == "SD":
        cdSupport = Database.getSymbolValue(plibName.lower(), "SDCARD_SDCD_SUPPORT")
        value = cdList1.getValue() if cdSupport else cdList2.getValue()
        symbol.setValue(value)
    else:
        symbol.clearValue()


def setCDCommentVisible(symbol, event):
    symbol.setVisible(event["value"])

def setWPCommentVisible(symbol, event):
    symbol.setVisible(event["value"])

def setPLIBWPEN(symbol, event):
    plibName = event["source"].getSymbolValue("DRV_SDMMC_PLIB")
    if (plibName != "None"):
        plibComp = Database.getComponentByID(plibName.lower())
        if (plibComp.getSymbolValue("SDCARD_SDWP_SUPPORT")):
            plibComp.setSymbolValue("SDCARD_SDWPEN", event["value"])
        symbol.setValue(event["value"])


def setPLIBCDEN(symbol, event):
    plibName = event["source"].getSymbolValue("DRV_SDMMC_PLIB")
    useCD = event["value"] == "Use SDCD Pin"
    if (plibName != "None"):
        plibComp = Database.getComponentByID(plibName.lower())
        if (plibComp.getSymbolValue("SDCARD_SDCD_SUPPORT")):
            plibComp.setSymbolValue("SDCARD_SDCDEN", useCD)
        symbol.setValue(useCD)

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

def UpdateProtocol(symbol, event):
    drvComp  = event["source"]
    plibName = drvComp.getSymbolValue("DRV_SDMMC_PLIB")
    if plibName != "None":
        updateUI(drvComp)

        #Enable the plib emmc feature
        plibComp = Database.getComponentByID(plibName.lower())
        if(plibComp.getSymbolValue("SDCARD_EMMC_SUPPORT")):
            plibComp.setSymbolValue("SDCARD_EMMCEN", event["value"] == "eMMC" )

        # Remove write protection if enabled
        event["source"].getSymbolByID("DRV_SDMMC_WP_CHECK_ENABLE").setReadOnly(event["value"] == "eMMC")

def UpdateBusWidth(symbol, event):
    plibName = event["source"].getSymbolValue("DRV_SDMMC_PLIB")
    symbolName = "DRV_SDMMC_TRANSFER_BUS_WIDTH_4BIT"
    if plibName != "None":
        protocol = event["source"].getSymbolValue("DRV_SDMMC_PROTOCOL_SUPPORT")
        support8Bit = Database.getSymbolValue(plibName.lower(), "SDCARD_8BIT_SUPPORT")
        if protocol == "eMMC" and support8Bit:
            symbolName = "DRV_SDMMC_TRANSFER_BUS_WIDTH_8BIT"
    symbol.setValue(event["source"].getSymbolValue(symbolName))


global updateUI
def updateUI(drvComp):
    # If plib is connected
    plibName = drvComp.getSymbolValue("DRV_SDMMC_PLIB")
    plibComp = None if plibName == "None" else Database.getComponentByID(plibName.lower())
    cdSupport = False if plibComp is None else plibComp.getSymbolValue("SDCARD_SDCD_SUPPORT")
    wpSupport = False if plibComp is None else plibComp.getSymbolValue("SDCARD_SDWP_SUPPORT")
    bus8Support = False if plibComp is None else plibComp.getSymbolValue("SDCARD_8BIT_SUPPORT")
    sdProtocol =  drvComp.getSymbolValue("DRV_SDMMC_PROTOCOL_SUPPORT") == "SD"
    show8Bitbus = bus8Support and not sdProtocol

    # If the plib supports card detect line, show the appropriate combo
    drvComp.getSymbolByID("DRV_SDMMC_CARD_DETECTION_METHODS_LIST1").setVisible(sdProtocol and cdSupport)
    drvComp.getSymbolByID("DRV_SDMMC_CARD_DETECTION_METHODS_LIST2").setVisible(sdProtocol and not cdSupport)

    # If the plib supports write protect, show the option to enable it
    drvComp.getSymbolByID("DRV_SDMMC_WP_CHECK_ENABLE").setVisible(wpSupport)

    # Show the 4/8 bus width selection
    drvComp.getSymbolByID("DRV_SDMMC_TRANSFER_BUS_WIDTH_4BIT").setVisible(not show8Bitbus)
    drvComp.getSymbolByID("DRV_SDMMC_TRANSFER_BUS_WIDTH_8BIT").setVisible(show8Bitbus)

    drvComp.getSymbolByID("DRV_SDMMC_WP_CHECK_ENABLE").setVisible(sdProtocol and wpSupport)

def sdmmcRtosMicriumOSIIIAppTaskVisibility(symbol, event):
    if (event["value"] == "MicriumOSIII"):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def sdmmcRtosMicriumOSIIITaskOptVisibility(symbol, event):
    symbol.setVisible(event["value"])

def UpdateSleepModeVisibility(symbol, event):
    symbol.setVisible(event["value"] == "eMMC")

def getActiveRtos():
    activeComponents = Database.getActiveComponentIDs()

    for i in range(0, len(activeComponents)):
        if (activeComponents[i] == "FreeRTOS"):
            return "FreeRTOS"
        elif (activeComponents[i] == "ThreadX"):
            return "ThreadX"
        elif (activeComponents[i] == "MicriumOSIII"):
            return "MicriumOSIII"

def instantiateComponent(sdmmcComponent, index):
    global sdmmcFsEnable
    global sdmmcWPCheckEnable
    global sdmmcCardDetectionMethod
    global sdmmcPLIB

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

    sdmmcBusWidth8Bit = sdmmcComponent.createComboSymbol("DRV_SDMMC_TRANSFER_BUS_WIDTH_8BIT", None,["1-bit", "4-bit", "8-bit"])
    sdmmcBusWidth8Bit.setLabel("Data Transfer Bus Width")
    sdmmcBusWidth8Bit.setVisible(False)
    sdmmcBusWidth8Bit.setDefaultValue("8-bit")

    sdmmcBusWidth4Bit = sdmmcComponent.createComboSymbol("DRV_SDMMC_TRANSFER_BUS_WIDTH_4BIT", None, ["1-bit", "4-bit"])
    sdmmcBusWidth4Bit.setLabel("Data Transfer Bus Width")
    sdmmcBusWidth4Bit.setVisible(True)
    sdmmcBusWidth4Bit.setDefaultValue("4-bit")
    sdmmcBusWidth4Bit.setReadOnly(False)

    sdmmcBusWidth = sdmmcComponent.createComboSymbol("DRV_SDMMC_TRANSFER_BUS_WIDTH", None,["1-bit", "4-bit", "8-bit"])
    sdmmcBusWidth.setDefaultValue("4-bit")
    sdmmcBusWidth.setDependencies(UpdateBusWidth, ["DRV_SDMMC_TRANSFER_BUS_WIDTH_4BIT", "DRV_SDMMC_TRANSFER_BUS_WIDTH_8BIT", "DRV_SDMMC_PROTOCOL_SUPPORT"])
    sdmmcBusWidth.setReadOnly(True)
    sdmmcBusWidth.setVisible(False)

    sdmmcBusSpeed= sdmmcComponent.createComboSymbol("DRV_SDMMC_BUS_SPEED", None,["DEFAULT_SPEED", "HIGH_SPEED"])
    sdmmcBusSpeed.setLabel("Bus Speed")
    sdmmcBusSpeed.setDefaultValue("DEFAULT_SPEED")

    sdmmcProtocol= sdmmcComponent.createComboSymbol("DRV_SDMMC_PROTOCOL_SUPPORT", None,["SD", "eMMC"])
    sdmmcProtocol.setLabel("Protocol")
    sdmmcProtocol.setDefaultValue("SD")
    sdmmcProtocol.setReadOnly(True)
    sdmmcProtocol.setDependencies(UpdateProtocol, ["DRV_SDMMC_PROTOCOL_SUPPORT"])

    sdmmcSleepWhenIdle= sdmmcComponent.createBooleanSymbol("DRV_SDMMC_SLEEP_WHEN_IDLE", None)
    sdmmcSleepWhenIdle.setLabel("Sleep when idle?")
    sdmmcSleepWhenIdle.setDescription("eMMC is put to sleep mode when no read/write request is pending")
    sdmmcSleepWhenIdle.setVisible(sdmmcProtocol.getValue() == "eMMC")
    sdmmcSleepWhenIdle.setDefaultValue(False)
    sdmmcSleepWhenIdle.setDependencies(UpdateSleepModeVisibility, ["DRV_SDMMC_PROTOCOL_SUPPORT"])

    sdmmcCardDetectionMethodsList1 = sdmmcComponent.createComboSymbol("DRV_SDMMC_CARD_DETECTION_METHODS_LIST1", None, cardDetectMethodList1ComboValues)
    sdmmcCardDetectionMethodsList1.setLabel("Card Detection Method")
    sdmmcCardDetectionMethodsList1.setDefaultValue(cardDetectMethodList1ComboValues[1])
    sdmmcCardDetectionMethodsList1.setReadOnly(True)
    sdmmcCardDetectionMethodsList1.setVisible(False)

    sdmmcCardDetectionMethodsList2 = sdmmcComponent.createComboSymbol("DRV_SDMMC_CARD_DETECTION_METHODS_LIST2", None, cardDetectMethodList2ComboValues)
    sdmmcCardDetectionMethodsList2.setLabel("Card Detection Method")
    sdmmcCardDetectionMethodsList2.setDefaultValue(cardDetectMethodList2ComboValues[0])
    sdmmcCardDetectionMethodsList2.setReadOnly(True)
    sdmmcCardDetectionMethodsList2.setVisible(False)

    sdmmcCardDetectionMethod = sdmmcComponent.createStringSymbol("DRV_SDMMC_CARD_DETECTION_METHOD", None)
    sdmmcCardDetectionMethod.setLabel("Selected Card Detection Method")
    sdmmcCardDetectionMethod.setVisible(False)
    sdmmcCardDetectionMethod.setDefaultValue("None")
    sdmmcCardDetectionMethod.setDependencies(setCDMethod, ["DRV_SDMMC_CARD_DETECTION_METHODS_LIST1" , "DRV_SDMMC_CARD_DETECTION_METHODS_LIST2", "DRV_SDMMC_PROTOCOL_SUPPORT"])

    sdmmcPlibSdcdEnable = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_PLIB_SDCD_ENABLE", None)
    sdmmcPlibSdcdEnable.setLabel("Enable PLIB SDCD?")
    sdmmcPlibSdcdEnable.setVisible(False)
    sdmmcPlibSdcdEnable.setDefaultValue(sdmmcCardDetectionMethod.getValue() == "Use SDCD Pin")
    sdmmcPlibSdcdEnable.setDependencies(setPLIBCDEN, ["DRV_SDMMC_CARD_DETECTION_METHOD"])

    sdmmcPLIBSDCDSupport = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_PLIB_SDCD_SUPPORT", None)
    sdmmcPLIBSDCDSupport.setVisible(False)
    sdmmcPLIBSDCDSupport.setDefaultValue(False)

    sdmmcPLIBSDWPSupport = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_PLIB_SDWP_SUPPORT", None)
    sdmmcPLIBSDWPSupport.setVisible(False)
    sdmmcPLIBSDWPSupport.setDefaultValue(False)

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
    sdmmcWPCheckEnable.setReadOnly(True)
    sdmmcWPCheckEnable.setVisible(False)

    sdmmcPlibSdwpEnable = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_PLIB_SDWP_ENABLE", None)
    sdmmcPlibSdwpEnable.setLabel("Enable PLIB SDWP?")
    sdmmcPlibSdwpEnable.setVisible(False)
    sdmmcPlibSdwpEnable.setDefaultValue(sdmmcWPCheckEnable.getValue())
    sdmmcPlibSdwpEnable.setDependencies(setPLIBWPEN, ["DRV_SDMMC_WP_CHECK_ENABLE"])

    sdmmcWPComment = sdmmcComponent.createCommentSymbol("DRV_SDMMC_SDWPEN_COMMENT", None)
    sdmmcWPComment.setLabel("!!!Configure SDWP pin in Pin Configuration!!!")
    sdmmcWPComment.setVisible(sdmmcPlibSdwpEnable.getValue())
    sdmmcWPComment.setDependencies(setWPCommentVisible, ["DRV_SDMMC_PLIB_SDWP_ENABLE"])

    sdmmcFsEnable = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_FS_ENABLE", None)
    sdmmcFsEnable.setLabel("File system for SDMMC Driver Enabled")
    sdmmcFsEnable.setReadOnly(True)

    # RTOS Settings
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
    sdmmcRTOSTaskSize.setLabel("Stack Size (in bytes)")
    sdmmcRTOSTaskSize.setDefaultValue(4096)

    sdmmcRTOSMsgQSize = sdmmcComponent.createIntegerSymbol("DRV_SDMMC_RTOS_TASK_MSG_QTY", sdmmcRTOSMenu)
    sdmmcRTOSMsgQSize.setLabel("Maximum Message Queue Size")
    sdmmcRTOSMsgQSize.setDescription("A µC/OS-III task contains an optional internal message queue (if OS_CFG_TASK_Q_EN is set to DEF_ENABLED in os_cfg.h). This argument specifies the maximum number of messages that the task can receive through this message queue. The user may specify that the task is unable to receive messages by setting this argument to 0")
    sdmmcRTOSMsgQSize.setDefaultValue(0)
    sdmmcRTOSMsgQSize.setVisible(getActiveRtos() == "MicriumOSIII")
    sdmmcRTOSMsgQSize.setDependencies(sdmmcRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS"])

    sdmmcRTOSTaskTimeQuanta = sdmmcComponent.createIntegerSymbol("DRV_SDMMC_RTOS_TASK_TIME_QUANTA", sdmmcRTOSMenu)
    sdmmcRTOSTaskTimeQuanta.setLabel("Task Time Quanta")
    sdmmcRTOSTaskTimeQuanta.setDescription("The amount of time (in clock ticks) for the time quanta when Round Robin is enabled. If you specify 0, then the default time quanta will be used which is the tick rate divided by 10.")
    sdmmcRTOSTaskTimeQuanta.setDefaultValue(0)
    sdmmcRTOSTaskTimeQuanta.setVisible(getActiveRtos() == "MicriumOSIII")
    sdmmcRTOSTaskTimeQuanta.setDependencies(sdmmcRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS"])

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

    sdmmcRTOSTaskSpecificOpt = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_RTOS_TASK_OPT_NONE", sdmmcRTOSMenu)
    sdmmcRTOSTaskSpecificOpt.setLabel("Task Specific Options")
    sdmmcRTOSTaskSpecificOpt.setDescription("Contains task-specific options. Each option consists of one bit. The option is selected when the bit is set. The current version of µC/OS-III supports the following options:")
    sdmmcRTOSTaskSpecificOpt.setDefaultValue(True)
    sdmmcRTOSTaskSpecificOpt.setVisible(getActiveRtos() == "MicriumOSIII")
    sdmmcRTOSTaskSpecificOpt.setDependencies(sdmmcRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS"])

    sdmmcRTOSTaskStkChk = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_RTOS_TASK_OPT_STK_CHK", sdmmcRTOSTaskSpecificOpt)
    sdmmcRTOSTaskStkChk.setLabel("Stack checking is allowed for the task")
    sdmmcRTOSTaskStkChk.setDescription("Specifies whether stack checking is allowed for the task")
    sdmmcRTOSTaskStkChk.setDefaultValue(True)
    sdmmcRTOSTaskStkChk.setDependencies(sdmmcRtosMicriumOSIIITaskOptVisibility, ["DRV_SDMMC_RTOS_TASK_OPT_NONE"])

    sdmmcRTOSTaskStkClr = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_RTOS_TASK_OPT_STK_CLR", sdmmcRTOSTaskSpecificOpt)
    sdmmcRTOSTaskStkClr.setLabel("Stack needs to be cleared")
    sdmmcRTOSTaskStkClr.setDescription("Specifies whether the stack needs to be cleared")
    sdmmcRTOSTaskStkClr.setDefaultValue(True)
    sdmmcRTOSTaskStkClr.setDependencies(sdmmcRtosMicriumOSIIITaskOptVisibility, ["DRV_SDMMC_RTOS_TASK_OPT_NONE"])

    sdmmcRTOSTaskSaveFp = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_RTOS_TASK_OPT_SAVE_FP", sdmmcRTOSTaskSpecificOpt)
    sdmmcRTOSTaskSaveFp.setLabel("Floating-point registers needs to be saved")
    sdmmcRTOSTaskSaveFp.setDescription("Specifies whether floating-point registers are saved. This option is only valid if the processor has floating-point hardware and the processor-specific code saves the floating-point registers")
    sdmmcRTOSTaskSaveFp.setDefaultValue(False)
    sdmmcRTOSTaskSaveFp.setDependencies(sdmmcRtosMicriumOSIIITaskOptVisibility, ["DRV_SDMMC_RTOS_TASK_OPT_NONE"])

    sdmmcRTOSTaskNoTls = sdmmcComponent.createBooleanSymbol("DRV_SDMMC_RTOS_TASK_OPT_NO_TLS", sdmmcRTOSTaskSpecificOpt)
    sdmmcRTOSTaskNoTls.setLabel("TLS (Thread Local Storage) support needed for the task")
    sdmmcRTOSTaskNoTls.setDescription("If the caller doesn’t want or need TLS (Thread Local Storage) support for the task being created. If you do not include this option, TLS will be supported by default. TLS support was added in V3.03.00")
    sdmmcRTOSTaskNoTls.setDefaultValue(False)
    sdmmcRTOSTaskNoTls.setDependencies(sdmmcRtosMicriumOSIIITaskOptVisibility, ["DRV_SDMMC_RTOS_TASK_OPT_NONE"])

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
            sdmmcFsConnectionCounterDict = {}
            sdmmcFsConnectionCounterDict = Database.sendMessage("drv_sdmmc", "DRV_SDMMC_FS_CONNECTION_COUNTER_INC", sdmmcFsConnectionCounterDict)

    # For Dependency Connected (SDHC/HSMCI)
    if (connectID == "drv_sdmmc_SDHC_dependency"):
        sdmmcPLIBRemoteID = remoteID

        #Update Plib
        plibUsed = localComponent.setSymbolValue("DRV_SDMMC_PLIB", remoteID.upper())

        # Unlock driver symbols based on plib capabilities
        #Protocol selection
        if remoteComponent.getSymbolValue("SDCARD_EMMC_SUPPORT"):
            localComponent.getSymbolByID("DRV_SDMMC_PROTOCOL_SUPPORT").setReadOnly(False)

        # Card detection selection
        if remoteComponent.getSymbolValue("SDCARD_SDCD_SUPPORT"):
            localComponent.getSymbolByID("DRV_SDMMC_CARD_DETECTION_METHODS_LIST1").setReadOnly(False)
            localComponent.setSymbolValue("DRV_SDMMC_CARD_DETECTION_METHOD", "Use SDCD Pin")


        # Write protection selection
        if remoteComponent.getSymbolValue("SDCARD_SDWP_SUPPORT"):
            localComponent.getSymbolByID("DRV_SDMMC_WP_CHECK_ENABLE").setReadOnly(False)

        # Bus width selection
        localComponent.getSymbolByID("DRV_SDMMC_TRANSFER_BUS_WIDTH_4BIT").setReadOnly(False)
        if remoteComponent.getSymbolValue("SDCARD_8BIT_SUPPORT"):
            localComponent.getSymbolByID("DRV_SDMMC_TRANSFER_BUS_WIDTH_8BIT").setReadOnly(False)

        # Update UI
        updateUI(localComponent)


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
            sdmmcFsConnectionCounterDict = {}
            sdmmcFsConnectionCounterDict = Database.sendMessage("drv_sdmmc", "DRV_SDMMC_FS_CONNECTION_COUNTER_DEC", sdmmcFsConnectionCounterDict)

    # For Dependency Disonnected (SDHC/HSMCI)
    if (connectID == "drv_sdmmc_SDHC_dependency"):

        plibUsed = localComponent.getSymbolByID("DRV_SDMMC_PLIB")
        plibUsed.clearValue()

        #Lock out all capability symbols
        localComponent.getSymbolByID("DRV_SDMMC_PROTOCOL_SUPPORT").setReadOnly(True)
        localComponent.getSymbolByID("DRV_SDMMC_CARD_DETECTION_METHODS_LIST1").setReadOnly(True)
        localComponent.getSymbolByID("DRV_SDMMC_WP_CHECK_ENABLE").setReadOnly(True)
        localComponent.getSymbolByID("DRV_SDMMC_TRANSFER_BUS_WIDTH_8BIT").setReadOnly(True)

        #clear out all state symbols
        localComponent.clearSymbolValue("DRV_SDMMC_CARD_DETECTION_METHOD")
        localComponent.clearSymbolValue("DRV_SDMMC_PLIB_SDCD_ENABLE")
        localComponent.clearSymbolValue("DRV_SDMMC_PLIB_SDWP_ENABLE")

        #Clear all the remote symbol set by driver
        remoteComponent.clearSymbolValue("SDCARD_SDCDEN")
        remoteComponent.clearSymbolValue("SDCARD_SDWPEN")
        remoteComponent.clearSymbolValue("SDCARD_EMMCEN")

        #Update UI
        updateUI(localComponent)




