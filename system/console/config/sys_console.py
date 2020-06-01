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
#### Business Logic ####
################################################################################
def handleMessage(messageID, args):

    result_dict = {}

    if (messageID == "REQUEST_CONFIG_PARAMS"):
        if args.get("localComponentID") != None:

            result_dict = Database.sendMessage(args["localComponentID"], "UART_INTERRUPT_MODE", {"isEnabled":True, "isReadOnly":True})

            result_dict = Database.sendMessage(args["localComponentID"], "UART_RING_BUFFER_MODE", {"isEnabled":True, "isReadOnly":True})

    return result_dict

def selectDeviceSet(symbol, event):
    symbol.clearValue()
    if ("USART" in event["value"]) or ("UART" in event["value"]) or ("SERCOM" in event["value"]) or ("FLEXCOM" in event["value"]) or ("DBGU" in event["value"]):
        symbol.setValue("UART")
    elif "USB" in event["value"]:
        symbol.setValue("USB_CDC")
    elif "APP" in event["value"]:
        symbol.setValue("APPIO")
    else:
        symbol.setValue("")

def uartConsoleFileGen(symbol, event):
    if (event["value"] == "UART"):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def usbCDCConsoleFileGen(symbol, event):
    if (event["value"] == "USB_CDC"):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def setVisibility(symbol, event):
    global consoleBufferConfigComment

    # Show the comment if UART is connected. Hide other-wise.
    # Show the TX/RX size option if USB is connected. Hide other-wise
    if (event["value"] == "USB_CDC"):
        symbol.setVisible(True)
        consoleBufferConfigComment.setVisible(False)
    elif (event["value"] == "UART"):
        symbol.setVisible(False)
        consoleBufferConfigComment.setVisible(True)
    else:
        symbol.setVisible(False)
        consoleBufferConfigComment.setVisible(False)

# RTOS related callbacks
def getActiveRtos():
    activeComponents = Database.getActiveComponentIDs()

    for i in range(0, len(activeComponents)):
        if (activeComponents[i] == "FreeRTOS"):
            return "FreeRTOS"
        elif (activeComponents[i] == "ThreadX"):
            return "ThreadX"
        elif (activeComponents[i] == "MicriumOSIII"):
            return "MicriumOSIII"
        elif (activeComponents[i] == "MbedOS"):
            return "MbedOS"

def updateTaskDelayVisiblity(symbol, event):
    symbol.setVisible(event["value"])

def showRTOSMenu(symbol, event):
    show_rtos_menu = False
    component = symbol.getComponent().getID()
    deviceSet = Database.getSymbolValue(component, "SYS_CONSOLE_DEVICE_SET")

    if (deviceSet == "USB_CDC"):
        if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
            show_rtos_menu = True

    symbol.setVisible(show_rtos_menu)

def genRtosTask(symbol, event):
    gen_rtos_task = False
    component = symbol.getComponent().getID()
    deviceSet = Database.getSymbolValue(component, "SYS_CONSOLE_DEVICE_SET")

    if (deviceSet == "USB_CDC"):
        if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
            gen_rtos_task = True

    symbol.setEnabled(gen_rtos_task)

def consoleRtosMicriumOSIIIAppTaskVisibility(symbol, event):
    isVisible = False
    component = symbol.getComponent().getID()
    deviceSet = Database.getSymbolValue(component, "SYS_CONSOLE_DEVICE_SET")
    selectedRTOS = Database.getSymbolValue("HarmonyCore", "SELECT_RTOS")

    if (deviceSet == "USB_CDC"):
        if (selectedRTOS == "MicriumOSIII"):
            isVisible = True

    symbol.setVisible(isVisible)

def consoleRtosMicriumOSIIITaskOptVisibility(symbol, event):
    symbol.setVisible(event["value"])

################################################################################
#### Component ####
################################################################################

def instantiateComponent(consoleComponent, index):
    global consoleBufferConfigComment

    consoleIndex = consoleComponent.createIntegerSymbol("INDEX", None)
    consoleIndex.setVisible(False)
    consoleIndex.setDefaultValue(index)

    consoleDevice = consoleComponent.createStringSymbol("SYS_CONSOLE_DEVICE", None)
    consoleDevice.setLabel("Device Used")
    consoleDevice.setReadOnly(True)
    consoleDevice.setDefaultValue("")

    consoleUARTIndex = consoleComponent.createIntegerSymbol("SYS_CONSOLE_DEVICE_UART_INDEX", None)
    consoleUARTIndex.setVisible(False)
    consoleUARTIndex.setDefaultValue(0)
    consoleUARTIndex.setUseSingleDynamicValue(True)

    consoleUSBIndex = consoleComponent.createIntegerSymbol("SYS_CONSOLE_DEVICE_USB_INDEX", None)
    consoleUSBIndex.setVisible(False)
    consoleUSBIndex.setDefaultValue(0)
    consoleUSBIndex.setUseSingleDynamicValue(True)

    consoleDeviceSet = consoleComponent.createStringSymbol("SYS_CONSOLE_DEVICE_SET", None)
    consoleDeviceSet.setLabel("Device Set")
    consoleDeviceSet.setVisible(False)
    consoleDeviceSet.setDependencies(selectDeviceSet, ["SYS_CONSOLE_DEVICE"])
    consoleDeviceSet.setDefaultValue("")

    consoleSymTXQueueSize = consoleComponent.createIntegerSymbol("SYS_CONSOLE_TX_BUFFER_SIZE", None)
    consoleSymTXQueueSize.setLabel("Transmit Buffer Size (1-4096)")
    consoleSymTXQueueSize.setMin(1)
    consoleSymTXQueueSize.setMax(4096)
    consoleSymTXQueueSize.setDefaultValue(128)
    consoleSymTXQueueSize.setVisible(False)
    consoleSymTXQueueSize.setDependencies(setVisibility, ["SYS_CONSOLE_DEVICE_SET"])

    consoleSymRXQueueSize = consoleComponent.createIntegerSymbol("SYS_CONSOLE_RX_BUFFER_SIZE", None)
    consoleSymRXQueueSize.setLabel("Receive Buffer Size (1-4096)")
    consoleSymRXQueueSize.setMin(1)
    consoleSymRXQueueSize.setMax(4096)
    consoleSymRXQueueSize.setDefaultValue(128)
    consoleSymRXQueueSize.setVisible(False)
    consoleSymRXQueueSize.setDependencies(setVisibility, ["SYS_CONSOLE_DEVICE_SET"])

    consoleBufferConfigComment = consoleComponent.createCommentSymbol("SYS_CONSOLE_BUFFER_CONFIG_COMMENT", None)
    consoleBufferConfigComment.setLabel("TX/RX Ring Buffers must be configured in the attached PLIB")
    consoleBufferConfigComment.setVisible(False)

    consoleSymDeviceIndex = consoleComponent.createIntegerSymbol("SYS_CONSOLE_DEVICE_INDEX", None)
    consoleSymDeviceIndex.setLabel("Device Index")
    consoleSymDeviceIndex.setVisible(False)
    consoleSymDeviceIndex.setDefaultValue(0)

    consoleSymUSBDeviceSpeed = consoleComponent.createStringSymbol("SYS_CONSOLE_USB_DEVICE_SPEED", None)
    consoleSymUSBDeviceSpeed.setLabel("USB Device Speed")
    consoleSymUSBDeviceSpeed.setVisible(False)
    consoleSymUSBDeviceSpeed.setDefaultValue("")

    enable_rtos_settings = False

    if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
        if (consoleDeviceSet.getValue() == "USB_CDC"):
            enable_rtos_settings = True

    # RTOS Settings
    consoleRTOSMenu = consoleComponent.createMenuSymbol("SYS_CONSOLE_RTOS_MENU", None)
    consoleRTOSMenu.setLabel("RTOS settings")
    consoleRTOSMenu.setDescription("RTOS settings")
    consoleRTOSMenu.setVisible(enable_rtos_settings)
    consoleRTOSMenu.setDependencies(showRTOSMenu, ["HarmonyCore.SELECT_RTOS", "SYS_CONSOLE_DEVICE_SET" ])

    consoleRTOSStackSize = consoleComponent.createIntegerSymbol("SYS_CONSOLE_RTOS_STACK_SIZE", consoleRTOSMenu)
    consoleRTOSStackSize.setLabel("Stack Size (in bytes)")
    consoleRTOSStackSize.setDefaultValue(1024)

    consoleRTOSMsgQSize = consoleComponent.createIntegerSymbol("SYS_CONSOLE_RTOS_TASK_MSG_QTY", consoleRTOSMenu)
    consoleRTOSMsgQSize.setLabel("Maximum Message Queue Size")
    consoleRTOSMsgQSize.setDescription("A µC/OS-III task contains an optional internal message queue (if OS_CFG_TASK_Q_EN is set to DEF_ENABLED in os_cfg.h). This argument specifies the maximum number of messages that the task can receive through this message queue. The user may specify that the task is unable to receive messages by setting this argument to 0")
    consoleRTOSMsgQSize.setDefaultValue(0)
    consoleRTOSMsgQSize.setVisible(getActiveRtos() == "MicriumOSIII")
    consoleRTOSMsgQSize.setDependencies(consoleRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS", "SYS_CONSOLE_DEVICE_SET"])

    consoleRTOSTaskTimeQuanta = consoleComponent.createIntegerSymbol("SYS_CONSOLE_RTOS_TASK_TIME_QUANTA", consoleRTOSMenu)
    consoleRTOSTaskTimeQuanta.setLabel("Task Time Quanta")
    consoleRTOSTaskTimeQuanta.setDescription("The amount of time (in clock ticks) for the time quanta when Round Robin is enabled. If you specify 0, then the default time quanta will be used which is the tick rate divided by 10.")
    consoleRTOSTaskTimeQuanta.setDefaultValue(0)
    consoleRTOSTaskTimeQuanta.setVisible(getActiveRtos() == "MicriumOSIII")
    consoleRTOSTaskTimeQuanta.setDependencies(consoleRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS", "SYS_CONSOLE_DEVICE_SET"])

    consoleRTOSTaskPriority = consoleComponent.createIntegerSymbol("SYS_CONSOLE_RTOS_TASK_PRIORITY", consoleRTOSMenu)
    consoleRTOSTaskPriority.setLabel("Task Priority")
    consoleRTOSTaskPriority.setDefaultValue(1)

    consoleRTOSTaskDelay = consoleComponent.createBooleanSymbol("SYS_CONSOLE_RTOS_USE_DELAY", consoleRTOSMenu)
    consoleRTOSTaskDelay.setLabel("Use Task Delay ?")
    consoleRTOSTaskDelay.setDefaultValue(True)

    consoleRTOSTaskDelayVal = consoleComponent.createIntegerSymbol("SYS_CONSOLE_RTOS_DELAY", consoleRTOSMenu)
    consoleRTOSTaskDelayVal.setLabel("Task Delay")
    consoleRTOSTaskDelayVal.setDefaultValue(10)
    consoleRTOSTaskDelayVal.setVisible((consoleRTOSTaskDelay.getValue() == True))
    consoleRTOSTaskDelayVal.setDependencies(updateTaskDelayVisiblity, ["SYS_CONSOLE_RTOS_USE_DELAY"])

    consoleRTOSTaskSpecificOpt = consoleComponent.createBooleanSymbol("SYS_CONSOLE_RTOS_TASK_OPT_NONE", consoleRTOSMenu)
    consoleRTOSTaskSpecificOpt.setLabel("Task Specific Options")
    consoleRTOSTaskSpecificOpt.setDescription("Contains task-specific options. Each option consists of one bit. The option is selected when the bit is set. The current version of µC/OS-III supports the following options:")
    consoleRTOSTaskSpecificOpt.setDefaultValue(True)
    consoleRTOSTaskSpecificOpt.setVisible(getActiveRtos() == "MicriumOSIII")
    consoleRTOSTaskSpecificOpt.setDependencies(consoleRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS", "SYS_CONSOLE_DEVICE_SET"])

    consoleRTOSTaskStkChk = consoleComponent.createBooleanSymbol("SYS_CONSOLE_RTOS_TASK_OPT_STK_CHK", consoleRTOSTaskSpecificOpt)
    consoleRTOSTaskStkChk.setLabel("Stack checking is allowed for the task")
    consoleRTOSTaskStkChk.setDescription("Specifies whether stack checking is allowed for the task")
    consoleRTOSTaskStkChk.setDefaultValue(True)
    consoleRTOSTaskStkChk.setDependencies(consoleRtosMicriumOSIIITaskOptVisibility, ["SYS_CONSOLE_RTOS_TASK_OPT_NONE"])

    consoleRTOSTaskStkClr = consoleComponent.createBooleanSymbol("SYS_CONSOLE_RTOS_TASK_OPT_STK_CLR", consoleRTOSTaskSpecificOpt)
    consoleRTOSTaskStkClr.setLabel("Stack needs to be cleared")
    consoleRTOSTaskStkClr.setDescription("Specifies whether the stack needs to be cleared")
    consoleRTOSTaskStkClr.setDefaultValue(True)
    consoleRTOSTaskStkClr.setDependencies(consoleRtosMicriumOSIIITaskOptVisibility, ["SYS_CONSOLE_RTOS_TASK_OPT_NONE"])

    consoleRTOSTaskSaveFp = consoleComponent.createBooleanSymbol("SYS_CONSOLE_RTOS_TASK_OPT_SAVE_FP", consoleRTOSTaskSpecificOpt)
    consoleRTOSTaskSaveFp.setLabel("Floating-point registers needs to be saved")
    consoleRTOSTaskSaveFp.setDescription("Specifies whether floating-point registers are saved. This option is only valid if the processor has floating-point hardware and the processor-specific code saves the floating-point registers")
    consoleRTOSTaskSaveFp.setDefaultValue(False)
    consoleRTOSTaskSaveFp.setDependencies(consoleRtosMicriumOSIIITaskOptVisibility, ["SYS_CONSOLE_RTOS_TASK_OPT_NONE"])

    consoleRTOSTaskNoTls = consoleComponent.createBooleanSymbol("SYS_CONSOLE_RTOS_TASK_OPT_NO_TLS", consoleRTOSTaskSpecificOpt)
    consoleRTOSTaskNoTls.setLabel("TLS (Thread Local Storage) support needed for the task")
    consoleRTOSTaskNoTls.setDescription("If the caller doesn’t want or need TLS (Thread Local Storage) support for the task being created. If you do not include this option, TLS will be supported by default. TLS support was added in V3.03.00")
    consoleRTOSTaskNoTls.setDefaultValue(False)
    consoleRTOSTaskNoTls.setDependencies(consoleRtosMicriumOSIIITaskOptVisibility, ["SYS_CONSOLE_RTOS_TASK_OPT_NONE"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    consoleSystemDefObjFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_DEF_OBJ", None)
    consoleSystemDefObjFile.setType("STRING")
    consoleSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    consoleSystemDefObjFile.setSourcePath("system/console/templates/system/system_definitions_objects.h.ftl")
    consoleSystemDefObjFile.setMarkup(True)

    consoleSystemConfigFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_CONFIG", None)
    consoleSystemConfigFile.setType("STRING")
    consoleSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION")
    consoleSystemConfigFile.setSourcePath("system/console/templates/system/system_config.h.ftl")
    consoleSystemConfigFile.setMarkup(True)

    consoleSystemInitDataFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_INIT_DATA", None)
    consoleSystemInitDataFile.setType("STRING")
    consoleSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYSTEM_INITIALIZATION")
    consoleSystemInitDataFile.setSourcePath("system/console/templates/system/system_initialize_data.c.ftl")
    consoleSystemInitDataFile.setMarkup(True)

    consoleSystemInitFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_INIT", None)
    consoleSystemInitFile.setType("STRING")
    consoleSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_INITIALIZE_SYSTEM_SERVICES")
    consoleSystemInitFile.setSourcePath("system/console/templates/system/system_initialize.c.ftl")
    consoleSystemInitFile.setMarkup(True)




    ###UART File Generation

    consoleUARTHeaderFile = consoleComponent.createFileSymbol("SYS_CONSOLE_UART_HEADER", None)
    consoleUARTHeaderFile.setSourcePath("system/console/src/console_uart/sys_console_uart.h")
    consoleUARTHeaderFile.setOutputName("sys_console_uart.h")
    consoleUARTHeaderFile.setDestPath("system/console/src")
    consoleUARTHeaderFile.setProjectPath("config/" + configName + "/system/console/")
    consoleUARTHeaderFile.setType("SOURCE")
    consoleUARTHeaderFile.setOverwrite(True)
    consoleUARTHeaderFile.setDependencies(uartConsoleFileGen, ["SYS_CONSOLE_DEVICE_SET"])

    consoleUARTDefinitionsHeaderFile = consoleComponent.createFileSymbol("SYS_CONSOLE_UART_DEFINITIONS_HEADER", None)
    consoleUARTDefinitionsHeaderFile.setSourcePath("system/console/src/console_uart/sys_console_uart_definitions.h")
    consoleUARTDefinitionsHeaderFile.setOutputName("sys_console_uart_definitions.h")
    consoleUARTDefinitionsHeaderFile.setDestPath("system/console/src")
    consoleUARTDefinitionsHeaderFile.setProjectPath("config/" + configName + "/system/console/")
    consoleUARTDefinitionsHeaderFile.setType("SOURCE")
    consoleUARTDefinitionsHeaderFile.setOverwrite(True)
    consoleUARTDefinitionsHeaderFile.setDependencies(uartConsoleFileGen, ["SYS_CONSOLE_DEVICE_SET"])

    consoleUARTSourceFile = consoleComponent.createFileSymbol("SYS_CONSOLE_UART_SOURCE", None)
    consoleUARTSourceFile.setSourcePath("system/console/src/console_uart/sys_console_uart.c")
    consoleUARTSourceFile.setOutputName("sys_console_uart.c")
    consoleUARTSourceFile.setDestPath("system/console/src")
    consoleUARTSourceFile.setProjectPath("config/" + configName + "/system/console/")
    consoleUARTSourceFile.setType("SOURCE")
    consoleUARTSourceFile.setOverwrite(True)
    consoleUARTSourceFile.setDependencies(uartConsoleFileGen, ["SYS_CONSOLE_DEVICE_SET"])

    ###USB CDC File Generation

    consoleUSBHeaderFile = consoleComponent.createFileSymbol("SYS_CONSOLE_USB_HEADER", None)
    consoleUSBHeaderFile.setSourcePath("system/console/src/console_usb/sys_console_usb_cdc.h")
    consoleUSBHeaderFile.setOutputName("sys_console_usb_cdc.h")
    consoleUSBHeaderFile.setDestPath("system/console/src")
    consoleUSBHeaderFile.setProjectPath("config/" + configName + "/system/console/")
    consoleUSBHeaderFile.setType("SOURCE")
    consoleUSBHeaderFile.setOverwrite(True)
    consoleUSBHeaderFile.setDependencies(usbCDCConsoleFileGen, ["SYS_CONSOLE_DEVICE_SET"])

    consoleUSBDefinitionsHeaderFile = consoleComponent.createFileSymbol("SYS_CONSOLE_USB_DEFINITIONS_HEADER", None)
    consoleUSBDefinitionsHeaderFile.setSourcePath("system/console/src/console_usb/sys_console_usb_cdc_definitions.h")
    consoleUSBDefinitionsHeaderFile.setOutputName("sys_console_usb_cdc_definitions.h")
    consoleUSBDefinitionsHeaderFile.setDestPath("system/console/src")
    consoleUSBDefinitionsHeaderFile.setProjectPath("config/" + configName + "/system/console/")
    consoleUSBDefinitionsHeaderFile.setType("SOURCE")
    consoleUSBDefinitionsHeaderFile.setOverwrite(True)
    consoleUSBDefinitionsHeaderFile.setDependencies(usbCDCConsoleFileGen, ["SYS_CONSOLE_DEVICE_SET"])

    consoleUSBSourceFile = consoleComponent.createFileSymbol("SYS_CONSOLE_USB_CDC_SOURCE", None)
    consoleUSBSourceFile.setSourcePath("system/console/src/console_usb/sys_console_usb_cdc.c")
    consoleUSBSourceFile.setOutputName("sys_console_usb_cdc.c")
    consoleUSBSourceFile.setDestPath("system/console/src")
    consoleUSBSourceFile.setProjectPath("config/" + configName + "/system/console/")
    consoleUSBSourceFile.setType("SOURCE")
    consoleUSBSourceFile.setOverwrite(True)
    consoleUSBSourceFile.setDependencies(usbCDCConsoleFileGen, ["SYS_CONSOLE_DEVICE_SET"])

    ### RTOS File Generation
    consoleSystemTasksFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_TASKS", None)
    consoleSystemTasksFile.setType("STRING")
    consoleSystemTasksFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS")
    consoleSystemTasksFile.setSourcePath("system/console/templates/system/system_tasks.c.ftl")
    consoleSystemTasksFile.setMarkup(True)

    commandSystemRtosTasksFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_RTOS_TASK", None)
    commandSystemRtosTasksFile.setType("STRING")
    commandSystemRtosTasksFile.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
    commandSystemRtosTasksFile.setSourcePath("system/console/templates/system/system_console_rtos_tasks.c.ftl")
    commandSystemRtosTasksFile.setMarkup(True)
    commandSystemRtosTasksFile.setEnabled(enable_rtos_settings)
    commandSystemRtosTasksFile.setDependencies(genRtosTask, ["HarmonyCore.SELECT_RTOS", "SYS_CONSOLE_DEVICE_SET"])

############################################################################
#### Dependency ####
############################################################################

def onAttachmentConnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    deviceUsed = localComponent.getSymbolByID("SYS_CONSOLE_DEVICE")

    if connectID == "sys_console_UART_dependency" :
        if "USART" or "UART" or "SERCOM" or "FLEXCOM" or "DBGU" in remoteID:
            deviceUsed.setValue(remoteID.upper())
            console_uart_connection_counter_dict = {}
            ring_buffer_enable_dict = {}

            console_uart_connection_counter_dict = Database.sendMessage("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER_INC", console_uart_connection_counter_dict)

    elif connectID == "sys_console_USB_DEVICE_CDC_dependency" :
        deviceUsed.setValue(remoteID.upper())
        consoleSymDeviceIndex = localComponent.getSymbolByID("SYS_CONSOLE_DEVICE_INDEX")
        consoleSymDeviceIndex.setValue(Database.getSymbolValue(remoteID, "CONFIG_USB_DEVICE_FUNCTION_INDEX"))
        consoleSymDeviceSpeed = localComponent.getSymbolByID("SYS_CONSOLE_USB_DEVICE_SPEED")
        consoleSymDeviceSpeed.setValue(Database.getSymbolValue("usb_device", "CONFIG_USB_DEVICE_SPEED"))
        console_usb_connection_counter_dict = {}
        console_usb_connection_counter_dict = Database.sendMessage("sys_console", "SYS_CONSOLE_USB_CONNECTION_COUNTER_INC", console_usb_connection_counter_dict)

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    deviceUsed = localComponent.getSymbolByID("SYS_CONSOLE_DEVICE")

    if connectID == "sys_console_UART_dependency" :
        if "USART" or "UART" or "SERCOM" or "FLEXCOM" or "DBGU" in remoteID:
            deviceUsed.clearValue()
            console_uart_connection_counter_dict = {}

            console_uart_connection_counter_dict = Database.sendMessage("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER_DEC", console_uart_connection_counter_dict)

            console_uart_connection_counter_dict = Database.sendMessage(remoteID, "UART_INTERRUPT_MODE", {"isReadOnly":False})

            console_uart_connection_counter_dict = Database.sendMessage(remoteID, "UART_RING_BUFFER_MODE", {"isReadOnly":False})

    elif connectID == "sys_console_USB_DEVICE_CDC_dependency" :
        deviceUsed.clearValue()
        console_usb_connection_counter_dict = {}
        console_usb_connection_counter_dict = Database.sendMessage("sys_console", "SYS_CONSOLE_USB_CONNECTION_COUNTER_DEC", console_usb_connection_counter_dict)