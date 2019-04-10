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

################################################################################
#### Component ####
################################################################################

def instantiateComponent(commandComponent):

    res = Database.activateComponents(["HarmonyCore"])

    # Enable dependent Harmony core components
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True)

    if (Database.getSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
        Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True)

    commandConsoleDevice = commandComponent.createStringSymbol("SYS_CONSOLE_DEVICE", None)
    commandConsoleDevice.setLabel("Device Used")
    commandConsoleDevice.setReadOnly(True)
    commandConsoleDevice.setDefaultValue("")

    commandConsoleIndex = commandComponent.createStringSymbol("SYS_CONSOLE_INDEX", None)
    commandConsoleIndex.setVisible(False)
    commandConsoleIndex.setDefaultValue("")

    commandPrintBufferSize = commandComponent.createIntegerSymbol("SYS_COMMAND_PRINT_BUFFER_SIZE", None)
    commandPrintBufferSize.setLabel("Command Print Buffer Size (512-8192)")
    commandPrintBufferSize.setMin(512)
    commandPrintBufferSize.setMax(8192)
    commandPrintBufferSize.setDefaultValue(1024)

    commandConsoleEnable = commandComponent.createBooleanSymbol("SYS_COMMAND_CONSOLE_ENABLE", None)
    commandConsoleEnable.setLabel("Re-route Console Message/Print through Command Service ?")
    commandConsoleEnable.setDefaultValue(True)

    commandDebugEnable = commandComponent.createBooleanSymbol("SYS_COMMAND_DEBUG_ENABLE", None)
    commandDebugEnable.setLabel("Re-route Debug Message/Print through Command Service ?")

    enable_rtos_settings = False

    if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
        if (commandEnable.getValue() == True):
            enable_rtos_settings = True

    # RTOS Settings
    commandRTOSMenu = commandComponent.createMenuSymbol("SYS_COMMAND_RTOS_MENU", None)
    commandRTOSMenu.setLabel("RTOS settings")
    commandRTOSMenu.setDescription("RTOS settings")
    commandRTOSMenu.setVisible(enable_rtos_settings)
    commandRTOSMenu.setDependencies(showRTOSMenu, ["HarmonyCore.SELECT_RTOS"])

    commandRTOSStackSize = commandComponent.createIntegerSymbol("SYS_COMMAND_RTOS_STACK_SIZE", commandRTOSMenu)
    commandRTOSStackSize.setLabel("Stack Size")
    commandRTOSStackSize.setDefaultValue(256)

    commandRTOSTaskPriority = commandComponent.createIntegerSymbol("SYS_COMMAND_RTOS_TASK_PRIORITY", commandRTOSMenu)
    commandRTOSTaskPriority.setLabel("Task Priority")
    commandRTOSTaskPriority.setDefaultValue(1)

    commandRTOSTaskDelay = commandComponent.createBooleanSymbol("SYS_COMMAND_RTOS_USE_DELAY", commandRTOSMenu)
    commandRTOSTaskDelay.setLabel("Use Task Delay ?")
    commandRTOSTaskDelay.setDefaultValue(True)

    commandRTOSTaskDelayVal = commandComponent.createIntegerSymbol("SYS_COMMAND_RTOS_DELAY", commandRTOSMenu)
    commandRTOSTaskDelayVal.setLabel("Task Delay")
    commandRTOSTaskDelayVal.setDefaultValue(10)
    commandRTOSTaskDelayVal.setVisible((commandRTOSTaskDelay.getValue() == True))
    commandRTOSTaskDelayVal.setDependencies(updateTaskDelayVisiblity, ["SYS_COMMAND_RTOS_USE_DELAY"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    commandHeaderFile = commandComponent.createFileSymbol("SYS_COMMAND_HEADER", None)
    commandHeaderFile.setSourcePath("system/command/sys_command.h")
    commandHeaderFile.setOutputName("sys_command.h")
    commandHeaderFile.setDestPath("system/command/")
    commandHeaderFile.setProjectPath("config/" + configName + "/system/command/")
    commandHeaderFile.setType("HEADER")
    commandHeaderFile.setOverwrite(True)

    commandSourceFile = commandComponent.createFileSymbol("SYS_COMMAND_SOURCE", None)
    commandSourceFile.setSourcePath("system/command/src/sys_command.c")
    commandSourceFile.setOutputName("sys_command.c")
    commandSourceFile.setDestPath("system/command/src")
    commandSourceFile.setProjectPath("config/" + configName + "/system/command/")
    commandSourceFile.setType("SOURCE")
    commandSourceFile.setOverwrite(True)

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
