################################################################################
#### Global Variables ####
################################################################################

################################################################################
#### Business Logic ####
################################################################################
def selectDeviceSet(symbol, event):
    symbol.clearValue()
    if "USART" or "UART" in event["value"]:
        symbol.setValue("UART", 2)
    elif "USB" in event["value"]:
        symbol.setValue("USB_CDC", 2)
    elif "APP" in event["value"]:
        symbol.setValue("APPIO", 2)
    else:
        Log.WriteErrorMessage("Incorrect Component is attached to Console System Service")

def genDebugFiles(symbol, event):
    symbol.setEnabled(event["value"])

def genCommandFiles(symbol, event):
    symbol.setEnabled(event["value"])

################################################################################
#### Component ####
################################################################################
def instantiateComponent(consoleComponent):
    res = Database.activateComponents(["HarmonyCore"])

    Log.writeInfoMessage("Loading System Console Module...")

    # Enable dependent Harmony core components
    Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True, 2)

    Database.clearSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
    Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True, 2)

    consoleIndex = consoleComponent.createIntegerSymbol("INDEX", None)
    consoleIndex.setVisible(False)
    consoleIndex.setDefaultValue(0)

    consoleDevice = consoleComponent.createStringSymbol("SYS_CONSOLE_DEVICE", None)
    consoleDevice.setLabel("Device Used")
    consoleDevice.setReadOnly(True)
    consoleDevice.setDefaultValue("USART1")
    # Used onDependencyComponentAdd\Remove callbacks to get connected PLIB

    consoleDeviceSet = consoleComponent.createStringSymbol("SYS_CONSOLE_DEVICE_SET", None)
    consoleDeviceSet.setLabel("Device Set")
    consoleDeviceSet.setVisible(False)
    consoleDeviceSet.setDependencies(selectDeviceSet, ["SYS_CONSOLE_DEVICE"])
    consoleDeviceSet.setDefaultValue("UART")

    consoleSymTXQueueSize = consoleComponent.createIntegerSymbol("SYS_CONSOLE_TX_QUEUE_SIZE", None)
    consoleSymTXQueueSize.setLabel("Transmit Buffer Queue Size (1-128)")
    consoleSymTXQueueSize.setMin(1)
    consoleSymTXQueueSize.setMax(128)
    consoleSymTXQueueSize.setDefaultValue(64)

    consoleSymRXQueueSize = consoleComponent.createIntegerSymbol("SYS_CONSOLE_RX_QUEUE_SIZE", None)
    consoleSymRXQueueSize.setLabel("Receive Buffer Queue Size (1-128)")
    consoleSymRXQueueSize.setMin(1)
    consoleSymRXQueueSize.setMax(128)
    consoleSymRXQueueSize.setDefaultValue(10)

    debugEnable = consoleComponent.createBooleanSymbol("SYS_DEBUG_ENABLE", None)
    debugEnable.setLabel("Enable Debug?")
    debugEnable.setDefaultValue(True)

    debugLevel = consoleComponent.createComboSymbol("SYS_DEBUG_LEVEL", debugEnable, ["SYS_ERROR_FATAL", "SYS_ERROR_ERROR", "SYS_ERROR_WARNING", "SYS_ERROR_INFO", "SYS_ERROR_DEBUG"])
    debugLevel.setLabel("Enable Debug?")
    debugLevel.setDefaultValue("SYS_ERROR_DEBUG")

    debugPrintBufferSize = consoleComponent.createIntegerSymbol("SYS_DEBUG_PRINT_BUFFER_SIZE", debugEnable)
    debugPrintBufferSize.setLabel("Debug Print Buffer Size (128-8192)")
    debugPrintBufferSize.setMin(128)
    debugPrintBufferSize.setMax(8192)
    debugPrintBufferSize.setDefaultValue(200)

    commandEnable = consoleComponent.createBooleanSymbol("SYS_COMMAND_ENABLE", None)
    commandEnable.setLabel("Enable Command Processor?")
    commandEnable.setDefaultValue(True)

    commandPrintBufferSize = consoleComponent.createIntegerSymbol("SYS_COMMAND_PRINT_BUFFER_SIZE", commandEnable)
    commandPrintBufferSize.setLabel("Command Print Buffer Size (512-8192)")
    commandPrintBufferSize.setMin(512)
    commandPrintBufferSize.setMax(8192)
    commandPrintBufferSize.setDefaultValue(1024)

    commandConsoleEnable = consoleComponent.createBooleanSymbol("SYS_COMMAND_CONSOLE_ENABLE", commandEnable)
    commandConsoleEnable.setLabel("Re-route Console Message/Print through Command Service?")
    commandConsoleEnable.setDefaultValue(True)

    commandDebugEnable = consoleComponent.createBooleanSymbol("SYS_COMMAND_DEBUG_ENABLE", commandEnable)
    commandDebugEnable.setLabel("Re-route Debug Message/Print through Command Service?")
    commandDebugEnable.setDefaultValue(True)

    ############################################################################
    #### Dependency ####
    ############################################################################


    ############################################################################
    #### Code Generation ####
    ############################################################################
    configName = Variables.get("__CONFIGURATION_NAME")

    consoleHeaderFile = consoleComponent.createFileSymbol("SYS_CONSOLE_HEADER", None)
    consoleHeaderFile.setSourcePath("system/console/sys_console.h")
    consoleHeaderFile.setOutputName("sys_console.h")
    consoleHeaderFile.setDestPath("system/console/")
    consoleHeaderFile.setProjectPath("config/" + configName + "/system/console/")
    consoleHeaderFile.setType("HEADER")
    consoleHeaderFile.setOverwrite(True)

    consoleHeaderLocalFile = consoleComponent.createFileSymbol("SYS_CONSOLE_LOCAL", None)
    consoleHeaderLocalFile.setSourcePath("system/console/src/sys_console_local.h")
    consoleHeaderLocalFile.setOutputName("sys_console_local.h")
    consoleHeaderLocalFile.setDestPath("system/console/src")
    consoleHeaderLocalFile.setProjectPath("config/" + configName + "/system/console/")
    consoleHeaderLocalFile.setType("SOURCE")
    consoleHeaderLocalFile.setOverwrite(True)

    consoleSourceFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SOURCE", None)
    consoleSourceFile.setSourcePath("system/console/src/sys_console.c")
    consoleSourceFile.setOutputName("sys_console.c")
    consoleSourceFile.setDestPath("system/console/src")
    consoleSourceFile.setProjectPath("config/" + configName + "/system/console/")
    consoleSourceFile.setType("SOURCE")
    consoleSourceFile.setOverwrite(True)

    consoleUARTHeaderFile = consoleComponent.createFileSymbol("SYS_CONSOLE_UART_HEADER", None)
    consoleUARTHeaderFile.setSourcePath("system/console/src/sys_console_uart.h")
    consoleUARTHeaderFile.setOutputName("sys_console_uart.h")
    consoleUARTHeaderFile.setDestPath("system/console/src")
    consoleUARTHeaderFile.setProjectPath("config/" + configName + "/system/console/")
    consoleUARTHeaderFile.setType("SOURCE")
    consoleUARTHeaderFile.setOverwrite(True)

    consoleUARTSourceFile = consoleComponent.createFileSymbol("SYS_CONSOLE_UART_SOURCE", None)
    consoleUARTSourceFile.setSourcePath("system/console/templates/sys_console_uart.c.ftl")
    consoleUARTSourceFile.setOutputName("sys_console_uart.c")
    consoleUARTSourceFile.setDestPath("system/console/src")
    consoleUARTSourceFile.setProjectPath("config/" + configName + "/system/console/")
    consoleUARTSourceFile.setType("SOURCE")
    consoleUARTSourceFile.setMarkup(True)
    consoleUARTSourceFile.setOverwrite(True)

    debugHeaderFile = consoleComponent.createFileSymbol("SYS_DEBUG_HEADER", None)
    debugHeaderFile.setSourcePath("system/console/sys_debug.h")
    debugHeaderFile.setOutputName("sys_debug.h")
    debugHeaderFile.setDestPath("system/console/")
    debugHeaderFile.setProjectPath("config/" + configName + "/system/console/")
    debugHeaderFile.setType("HEADER")
    debugHeaderFile.setOverwrite(True)
    debugHeaderFile.setEnabled(True)
    debugHeaderFile.setDependencies(genDebugFiles, ["SYS_DEBUG_ENABLE"])

    debugHeaderLocalFile = consoleComponent.createFileSymbol("SYS_DEBUG_LOCAL", None)
    debugHeaderLocalFile.setSourcePath("system/console/src/sys_debug_local.h")
    debugHeaderLocalFile.setOutputName("sys_debug_local.h")
    debugHeaderLocalFile.setDestPath("system/console/src")
    debugHeaderLocalFile.setProjectPath("config/" + configName + "/system/console/")
    debugHeaderLocalFile.setType("SOURCE")
    debugHeaderLocalFile.setOverwrite(True)
    debugHeaderLocalFile.setEnabled(True)
    debugHeaderLocalFile.setDependencies(genDebugFiles, ["SYS_DEBUG_ENABLE"])

    debugSourceFile = consoleComponent.createFileSymbol("SYS_DEBUG_SOURCE", None)
    debugSourceFile.setSourcePath("system/console/src/sys_debug.c")
    debugSourceFile.setOutputName("sys_debug.c")
    debugSourceFile.setDestPath("system/console/src")
    debugSourceFile.setProjectPath("config/" + configName + "/system/console/")
    debugSourceFile.setType("SOURCE")
    debugSourceFile.setOverwrite(True)
    debugSourceFile.setEnabled(True)
    debugSourceFile.setDependencies(genDebugFiles, ["SYS_DEBUG_ENABLE"])

    commandHeaderFile = consoleComponent.createFileSymbol("SYS_COMMAND_HEADER", None)
    commandHeaderFile.setSourcePath("system/console/sys_command.h")
    commandHeaderFile.setOutputName("sys_command.h")
    commandHeaderFile.setDestPath("system/console/")
    commandHeaderFile.setProjectPath("config/" + configName + "/system/console/")
    commandHeaderFile.setType("HEADER")
    commandHeaderFile.setOverwrite(True)
    commandHeaderFile.setEnabled(True)
    commandHeaderFile.setDependencies(genCommandFiles, ["SYS_COMMAND_ENABLE"])

    commandSourceFile = consoleComponent.createFileSymbol("SYS_COMMAND_SOURCE", None)
    commandSourceFile.setSourcePath("system/console/src/sys_command.c")
    commandSourceFile.setOutputName("sys_command.c")
    commandSourceFile.setDestPath("system/console/src")
    commandSourceFile.setProjectPath("config/" + configName + "/system/console/")
    commandSourceFile.setType("SOURCE")
    commandSourceFile.setOverwrite(True)
    commandSourceFile.setEnabled(True)
    commandSourceFile.setDependencies(genCommandFiles, ["SYS_COMMAND_ENABLE"])

    consoleSystemDefFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_DEF", None)
    consoleSystemDefFile.setType("STRING")
    consoleSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    consoleSystemDefFile.setSourcePath("system/console/templates/system/system_definitions.h.ftl")
    consoleSystemDefFile.setMarkup(True)

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

    consoleSystemTasksFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_TASKS", None)
    consoleSystemTasksFile.setType("STRING")
    consoleSystemTasksFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS")
    consoleSystemTasksFile.setSourcePath("system/console/templates/system/system_tasks.c.ftl")
    consoleSystemTasksFile.setMarkup(True)

############################################################################
#### Dependency ####
############################################################################
def onDependentComponentAdded(sys_console, id, console):

    if id == "sys_console_UART_dependency" :
        deviceUsed = sys_console.getSymbolByID("SYS_CONSOLE_DEVICE")
        deviceUsed.clearValue()
        deviceUsed.setValue(console.getID().upper(), 2)
