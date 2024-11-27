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

sys_command_mcc_helpkeyword = "mcc_h3_sys_command_configurations"

def updateTaskDelayVisiblity(symbol, event):
    symbol.setVisible(event["value"])

def showRTOSMenu(symbol, event):
    show_rtos_menu = False
    component = symbol.getComponent()

    if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
        show_rtos_menu = True

    symbol.setVisible(show_rtos_menu)

def genRtosTask(symbol, event):
    gen_rtos_task = False
    component = symbol.getComponent()

    if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
        gen_rtos_task = True

    symbol.setEnabled(gen_rtos_task)

def commandRtosMicriumOSIIIAppTaskVisibility(symbol, event):
    if (event["value"] == "MicriumOSIII"):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def commandRtosMicriumOSIIITaskOptVisibility(symbol, event):
    symbol.setVisible(event["value"])

def commandSendMessageHeapSize(symbol, event):
    dummyDict = {}
    dummyDict = Database.sendMessage("core", "HEAP_SIZE", {"heap_size" : 1024})

################################################################################
#### Component ####
################################################################################

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

def instantiateComponent(commandComponent):

    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Reset File" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_RESET", {"isEnabled":True})

    dummyDict = {}
    dummyDict = Database.sendMessage("core", "HEAP_SIZE", {"heap_size" : 1024})

    commandConsoleDevice = commandComponent.createStringSymbol("SYS_CONSOLE_DEVICE", None)
    commandConsoleDevice.setLabel("Device Used")
    commandConsoleDevice.setHelp(sys_command_mcc_helpkeyword)
    commandConsoleDevice.setReadOnly(True)
    commandConsoleDevice.setDefaultValue("")
    commandConsoleDevice.setDependencies(commandSendMessageHeapSize, ["core.COMPILER_CHOICE"])

    commandConsoleIndex = commandComponent.createStringSymbol("SYS_CONSOLE_INDEX", None)
    commandConsoleIndex.setVisible(False)
    commandConsoleIndex.setDefaultValue("")

    commandPrintBufferSize = commandComponent.createIntegerSymbol("SYS_COMMAND_PRINT_BUFFER_SIZE", None)
    commandPrintBufferSize.setLabel("Command Print Buffer Size (512-8192)")
    commandPrintBufferSize.setHelp(sys_command_mcc_helpkeyword)
    commandPrintBufferSize.setMin(512)
    commandPrintBufferSize.setMax(8192)
    commandPrintBufferSize.setDefaultValue(1024)

    commandMaxGroups = commandComponent.createIntegerSymbol("SYS_COMMAND_MAX_CMD_GROUPS", None)
    commandMaxGroups.setLabel("Maximum Command Groups")
    commandMaxGroups.setHelp(sys_command_mcc_helpkeyword)
    commandMaxGroups.setMin(1)
    commandMaxGroups.setMax(65535)
    commandMaxGroups.setDefaultValue(8)

    commandMaxArgsPerCmd = commandComponent.createIntegerSymbol("SYS_COMMAND_MAX_CMD_ARGS", None)
    commandMaxArgsPerCmd.setLabel("Maximum Arguments Per Command")
    commandMaxArgsPerCmd.setHelp(sys_command_mcc_helpkeyword)
    commandMaxArgsPerCmd.setMin(1)
    commandMaxArgsPerCmd.setMax(65535)
    commandMaxArgsPerCmd.setDefaultValue(8)

    commandMaxCmdLengthPerCmd = commandComponent.createIntegerSymbol("SYS_COMMAND_MAX_CMD_LENGTH", None)
    commandMaxCmdLengthPerCmd.setLabel("Maximum Length Per Command")
    commandMaxCmdLengthPerCmd.setHelp(sys_command_mcc_helpkeyword)
    commandMaxCmdLengthPerCmd.setMin(1)
    commandMaxCmdLengthPerCmd.setMax(65535)
    commandMaxCmdLengthPerCmd.setDefaultValue(80)

    enable_rtos_settings = False

    if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
        enable_rtos_settings = True

    # RTOS Settings
    commandRTOSMenu = commandComponent.createMenuSymbol("SYS_COMMAND_RTOS_MENU", None)
    commandRTOSMenu.setLabel("RTOS settings")
    commandRTOSMenu.setHelp(sys_command_mcc_helpkeyword)
    commandRTOSMenu.setDescription("RTOS settings")
    commandRTOSMenu.setVisible(enable_rtos_settings)
    commandRTOSMenu.setDependencies(showRTOSMenu, ["HarmonyCore.SELECT_RTOS"])

    commandRTOSStackSize = commandComponent.createIntegerSymbol("SYS_COMMAND_RTOS_STACK_SIZE", commandRTOSMenu)
    commandRTOSStackSize.setLabel("Stack Size (in bytes)")
    commandRTOSStackSize.setHelp(sys_command_mcc_helpkeyword)
    commandRTOSStackSize.setDefaultValue(1024)

    commandRTOSMsgQSize = commandComponent.createIntegerSymbol("SYS_COMMAND_RTOS_TASK_MSG_QTY", commandRTOSMenu)
    commandRTOSMsgQSize.setLabel("Maximum Message Queue Size")
    commandRTOSMsgQSize.setHelp(sys_command_mcc_helpkeyword)
    commandRTOSMsgQSize.setDescription("A µC/OS-III task contains an optional internal message queue (if OS_CFG_TASK_Q_EN is set to DEF_ENABLED in os_cfg.h). This argument specifies the maximum number of messages that the task can receive through this message queue. The user may specify that the task is unable to receive messages by setting this argument to 0")
    commandRTOSMsgQSize.setDefaultValue(0)
    commandRTOSMsgQSize.setVisible(getActiveRtos() == "MicriumOSIII")
    commandRTOSMsgQSize.setDependencies(commandRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS"])

    commandRTOSTaskTimeQuanta = commandComponent.createIntegerSymbol("SYS_COMMAND_RTOS_TASK_TIME_QUANTA", commandRTOSMenu)
    commandRTOSTaskTimeQuanta.setLabel("Task Time Quanta")
    commandRTOSTaskTimeQuanta.setHelp(sys_command_mcc_helpkeyword)
    commandRTOSTaskTimeQuanta.setDescription("The amount of time (in clock ticks) for the time quanta when Round Robin is enabled. If you specify 0, then the default time quanta will be used which is the tick rate divided by 10.")
    commandRTOSTaskTimeQuanta.setDefaultValue(0)
    commandRTOSTaskTimeQuanta.setVisible(getActiveRtos() == "MicriumOSIII")
    commandRTOSTaskTimeQuanta.setDependencies(commandRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS"])

    commandRTOSTaskPriority = commandComponent.createIntegerSymbol("SYS_COMMAND_RTOS_TASK_PRIORITY", commandRTOSMenu)
    commandRTOSTaskPriority.setLabel("Task Priority")
    commandRTOSTaskPriority.setHelp(sys_command_mcc_helpkeyword)
    commandRTOSTaskPriority.setDefaultValue(1)

    commandRTOSTaskDelay = commandComponent.createBooleanSymbol("SYS_COMMAND_RTOS_USE_DELAY", commandRTOSMenu)
    commandRTOSTaskDelay.setLabel("Use Task Delay ?")
    commandRTOSTaskDelay.setHelp(sys_command_mcc_helpkeyword)
    commandRTOSTaskDelay.setDefaultValue(True)

    commandRTOSTaskDelayVal = commandComponent.createIntegerSymbol("SYS_COMMAND_RTOS_DELAY", commandRTOSMenu)
    commandRTOSTaskDelayVal.setLabel("Task Delay")
    commandRTOSTaskDelayVal.setHelp(sys_command_mcc_helpkeyword)
    commandRTOSTaskDelayVal.setDefaultValue(10)
    commandRTOSTaskDelayVal.setVisible((commandRTOSTaskDelay.getValue() == True))
    commandRTOSTaskDelayVal.setDependencies(updateTaskDelayVisiblity, ["SYS_COMMAND_RTOS_USE_DELAY"])

    commandRTOSTaskSpecificOpt = commandComponent.createBooleanSymbol("SYS_COMMAND_RTOS_TASK_OPT_NONE", commandRTOSMenu)
    commandRTOSTaskSpecificOpt.setLabel("Task Specific Options")
    commandRTOSTaskSpecificOpt.setHelp(sys_command_mcc_helpkeyword)
    commandRTOSTaskSpecificOpt.setDescription("Contains task-specific options. Each option consists of one bit. The option is selected when the bit is set. The current version of µC/OS-III supports the following options:")
    commandRTOSTaskSpecificOpt.setDefaultValue(True)
    commandRTOSTaskSpecificOpt.setVisible(getActiveRtos() == "MicriumOSIII")
    commandRTOSTaskSpecificOpt.setDependencies(commandRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS"])

    commandRTOSTaskStkChk = commandComponent.createBooleanSymbol("SYS_COMMAND_RTOS_TASK_OPT_STK_CHK", commandRTOSTaskSpecificOpt)
    commandRTOSTaskStkChk.setLabel("Stack checking is allowed for the task")
    commandRTOSTaskStkChk.setHelp(sys_command_mcc_helpkeyword)
    commandRTOSTaskStkChk.setDescription("Specifies whether stack checking is allowed for the task")
    commandRTOSTaskStkChk.setDefaultValue(True)
    commandRTOSTaskStkChk.setDependencies(commandRtosMicriumOSIIITaskOptVisibility, ["SYS_COMMAND_RTOS_TASK_OPT_NONE"])

    commandRTOSTaskStkClr = commandComponent.createBooleanSymbol("SYS_COMMAND_RTOS_TASK_OPT_STK_CLR", commandRTOSTaskSpecificOpt)
    commandRTOSTaskStkClr.setLabel("Stack needs to be cleared")
    commandRTOSTaskStkClr.setHelp(sys_command_mcc_helpkeyword)
    commandRTOSTaskStkClr.setDescription("Specifies whether the stack needs to be cleared")
    commandRTOSTaskStkClr.setDefaultValue(True)
    commandRTOSTaskStkClr.setDependencies(commandRtosMicriumOSIIITaskOptVisibility, ["SYS_COMMAND_RTOS_TASK_OPT_NONE"])

    commandRTOSTaskSaveFp = commandComponent.createBooleanSymbol("SYS_COMMAND_RTOS_TASK_OPT_SAVE_FP", commandRTOSTaskSpecificOpt)
    commandRTOSTaskSaveFp.setLabel("Floating-point registers needs to be saved")
    commandRTOSTaskSaveFp.setHelp(sys_command_mcc_helpkeyword)
    commandRTOSTaskSaveFp.setDescription("Specifies whether floating-point registers are saved. This option is only valid if the processor has floating-point hardware and the processor-specific code saves the floating-point registers")
    commandRTOSTaskSaveFp.setDefaultValue(False)
    commandRTOSTaskSaveFp.setDependencies(commandRtosMicriumOSIIITaskOptVisibility, ["SYS_COMMAND_RTOS_TASK_OPT_NONE"])

    commandRTOSTaskNoTls = commandComponent.createBooleanSymbol("SYS_COMMAND_RTOS_TASK_OPT_NO_TLS", commandRTOSTaskSpecificOpt)
    commandRTOSTaskNoTls.setLabel("TLS (Thread Local Storage) support needed for the task")
    commandRTOSTaskNoTls.setHelp(sys_command_mcc_helpkeyword)
    commandRTOSTaskNoTls.setDescription("If the caller doesn’t want or need TLS (Thread Local Storage) support for the task being created. If you do not include this option, TLS will be supported by default. TLS support was added in V3.03.00")
    commandRTOSTaskNoTls.setDefaultValue(False)
    commandRTOSTaskNoTls.setDependencies(commandRtosMicriumOSIIITaskOptVisibility, ["SYS_COMMAND_RTOS_TASK_OPT_NONE"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    commandHeaderFile = commandComponent.createFileSymbol("SYS_COMMAND_HEADER", None)
    commandHeaderFile.setSourcePath("system/command/templates/system/sys_command.h.ftl")
    commandHeaderFile.setOutputName("sys_command.h")
    commandHeaderFile.setDestPath("system/command/")
    commandHeaderFile.setProjectPath("config/" + configName + "/system/command/")
    commandHeaderFile.setType("HEADER")
    commandHeaderFile.setOverwrite(True)
    commandHeaderFile.setMarkup(True)

    commandSourceFile = commandComponent.createFileSymbol("SYS_COMMAND_SOURCE", None)
    commandSourceFile.setSourcePath("system/command/src/sys_command.c.ftl")
    commandSourceFile.setOutputName("sys_command.c")
    commandSourceFile.setDestPath("system/command/src")
    commandSourceFile.setProjectPath("config/" + configName + "/system/command/")
    commandSourceFile.setType("SOURCE")
    commandSourceFile.setMarkup(True)
    commandSourceFile.setOverwrite(True)

    commandSystemDefObjFile = commandComponent.createFileSymbol("SYS_CONSOLE_SYS_DEF_OBJ", None)
    commandSystemDefObjFile.setType("STRING")
    commandSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    commandSystemDefObjFile.setSourcePath("system/command/templates/system/system_definitions_objects.h.ftl")
    commandSystemDefObjFile.setMarkup(True)
    
    commandSystemDefFile = commandComponent.createFileSymbol("SYS_CONSOLE_SYS_DEF", None)
    commandSystemDefFile.setType("STRING")
    commandSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    commandSystemDefFile.setSourcePath("system/command/templates/system/system_definitions.h.ftl")
    commandSystemDefFile.setMarkup(True)
    
    commandSystemConfigFile = commandComponent.createFileSymbol("SYS_CONSOLE_SYS_CONFIG", None)
    commandSystemConfigFile.setType("STRING")
    commandSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION")
    commandSystemConfigFile.setSourcePath("system/command/templates/system/system_config.h.ftl")
    commandSystemConfigFile.setMarkup(True)

    commandSystemInitDataFile = commandComponent.createFileSymbol("SYS_CONSOLE_SYS_INIT_DATA", None)
    commandSystemInitDataFile.setType("STRING")
    commandSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYSTEM_INITIALIZATION")
    commandSystemInitDataFile.setSourcePath("system/command/templates/system/system_initialize_data.c.ftl")
    commandSystemInitDataFile.setMarkup(True)

    commandSystemInitFile = commandComponent.createFileSymbol("SYS_CONSOLE_SYS_INIT", None)
    commandSystemInitFile.setType("STRING")
    commandSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_INITIALIZE_SYSTEM_SERVICES")
    commandSystemInitFile.setSourcePath("system/command/templates/system/system_initialize.c.ftl")
    commandSystemInitFile.setMarkup(True)

    commandSystemTasksFile = commandComponent.createFileSymbol("SYS_CONSOLE_SYS_TASKS", None)
    commandSystemTasksFile.setType("STRING")
    commandSystemTasksFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS")
    commandSystemTasksFile.setSourcePath("system/command/templates/system/system_tasks.c.ftl")
    commandSystemTasksFile.setMarkup(True)

    commandSystemRtosTasksFile = commandComponent.createFileSymbol("SYS_COMMAND_SYS_RTOS_TASK", None)
    commandSystemRtosTasksFile.setType("STRING")
    commandSystemRtosTasksFile.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
    commandSystemRtosTasksFile.setSourcePath("system/command/templates/system/system_cmd_rtos_tasks.c.ftl")
    commandSystemRtosTasksFile.setMarkup(True)
    commandSystemRtosTasksFile.setEnabled(enable_rtos_settings)
    commandSystemRtosTasksFile.setDependencies(genRtosTask, ["HarmonyCore.SELECT_RTOS"])

    commandSystemRtosTaskHandleFile = commandComponent.createFileSymbol("SYS_COMMAND_SYS_RTOS_TASK_HANDLE", None)
    commandSystemRtosTaskHandleFile.setType("STRING")
    commandSystemRtosTaskHandleFile.setOutputName("core.LIST_SYSTEM_TASKS_HANDLE_DECLARATION")
    commandSystemRtosTaskHandleFile.setSourcePath("system/command/templates/system/system_cmd_rtos_tasks_handle_decl.h.ftl")
    commandSystemRtosTaskHandleFile.setMarkup(True)
    commandSystemRtosTaskHandleFile.setEnabled(enable_rtos_settings)
    commandSystemRtosTaskHandleFile.setDependencies(genRtosTask, ["HarmonyCore.SELECT_RTOS"])

############################################################################
#### Dependency ####
############################################################################

def onAttachmentConnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "sys_command_SYS_CONSOLE_dependency" :
        deviceUsed = localComponent.getSymbolByID("SYS_CONSOLE_DEVICE")
        deviceConsoleIndex = localComponent.getSymbolByID("SYS_CONSOLE_INDEX")

        consoleIndex = ''.join(i for i in remoteID if i.isdigit())

        deviceUsed.setValue(remoteID.upper())
        deviceConsoleIndex.setValue(consoleIndex)

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "sys_command_SYS_CONSOLE_dependency" :
        deviceUsed = localComponent.getSymbolByID("SYS_CONSOLE_DEVICE")
        deviceConsoleIndex = localComponent.getSymbolByID("SYS_CONSOLE_INDEX")

        deviceUsed.clearValue()
        deviceConsoleIndex.clearValue()

def destroyComponent(commandComponent):
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_RESET", {"isEnabled":False})
