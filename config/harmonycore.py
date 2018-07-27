
################################################################################
#### Business Logic ####
################################################################################
global osalHeaderImpBasicFile
global osalHeaderFreeRtosFile
global osalSourceFreeRtosFile
global osalSelectRTOS

def onDependencyConnected(connectionInfo):
    global osalHeaderImpBasicFile
    global osalHeaderFreeRtosFile
    global osalSourceFreeRtosFile
    global osalSelectRTOS

    if (connectionInfo["capabilityID"] == "FreeRTOS"):
        print(connectionInfo["capabilityID"] + " selected")
        osalHeaderImpBasicFile.setEnabled(False)
        osalHeaderFreeRtosFile.setEnabled(True)
        osalSourceFreeRtosFile.setEnabled(True)
        osalSelectRTOS.setValue(1, 1)

def onDependencyDisconnected(connectionInfo):
    global osalHeaderImpBasicFile
    global osalHeaderFreeRtosFile
    global osalSourceFreeRtosFile
    global osalSelectRTOS

    print("Reverted back to Bare-metal")
    osalHeaderImpBasicFile.setEnabled(True)
    osalHeaderFreeRtosFile.setEnabled(False)
    osalSourceFreeRtosFile.setEnabled(False)
    osalSelectRTOS.setValue(0, 1)

def genUserHeaderFile(userHeaderFile, event):
    userHeaderFile.setEnabled(event["value"])

def genTaskSourceFile(taskSourceFile, event):
    taskSourceFile.setEnabled(event["value"])

def genConfHeaderFile(confHeaderFile, event):
    confHeaderFile.setEnabled(event["value"])

################################################################################
#### Component ####
################################################################################
def instantiateComponent(harmonyCoreComponent):
    global osalHeaderImpBasicFile
    global osalHeaderFreeRtosFile
    global osalSourceFreeRtosFile
    global osalSelectRTOS

    coreMenu = harmonyCoreComponent.createMenuSymbol("HARMONY_CORE_MENU", None)
    coreMenu.setLabel("Harmony Core Configuration")

    coreAppFiles = harmonyCoreComponent.createBooleanSymbol("ENABLE_APP_FILE", coreMenu)
    coreAppFiles.setLabel("Generate Harmony Application Files")
    coreAppFiles.setDefaultValue(False)

    configName = Variables.get("__CONFIGURATION_NAME")

    # Harmony Core Driver Common files
    execfile(Module.getPath() + "/driver/config/driver.py")

    # Harmony Core System Service Common files
    execfile(Module.getPath() + "/system/config/system.py")

    # Harmony Core System Interrupt files
    execfile(Module.getPath() + "/system/int/config/sys_int.py")

    # Harmony Core System Ports files
    execfile(Module.getPath() + "/system/ports/config/sys_ports.py")

    # Harmony Core System DMA files
    execfile(Module.getPath() + "/system/dma/config/sys_dma.py")

    # Harmony Core Operating System Abstraction Layer (OSAL) files
    execfile(Module.getPath() + "/osal/config/osal.py")

    # Harmony Core Create and Configure Application Tasks/Threads
    execfile(Module.getPath() + "/config/gen_app_tasks.py")

    #################### Configuration Files ####################
    # generate user.h file
    userHeaderFile = harmonyCoreComponent.createFileSymbol("USER_H", None)
    userHeaderFile.setSourcePath("templates/user.h.ftl")
    userHeaderFile.setOutputName("user.h")
    userHeaderFile.setMarkup(True)
    userHeaderFile.setOverwrite(False)
    userHeaderFile.setDestPath("")
    userHeaderFile.setProjectPath("config/" + configName + "/")
    userHeaderFile.setType("HEADER")
    userHeaderFile.setEnabled(False)
    userHeaderFile.setDependencies(genUserHeaderFile, ["ENABLE_APP_FILE"])
    appConfigIncludesList = harmonyCoreComponent.createListSymbol("LIST_APP_CONFIG_H_GLOBAL_INCLUDES", None)

    # generate configuration.h file
    confHeaderFile = harmonyCoreComponent.createFileSymbol("CONFIGURATION_H", None)
    confHeaderFile.setSourcePath("templates/configuration.h.ftl")
    confHeaderFile.setOutputName("configuration.h")
    confHeaderFile.setMarkup(True)
    confHeaderFile.setOverwrite(True)
    confHeaderFile.setDestPath("")
    confHeaderFile.setProjectPath("config/" + configName + "/")
    confHeaderFile.setType("HEADER")
    confHeaderFile.setEnabled(False)
    systemConfigIncludesList = harmonyCoreComponent.createListSymbol("LIST_SYSTEM_CONFIG_H_GLOBAL_INCLUDES", None)
    systemConfigSysList = harmonyCoreComponent.createListSymbol("LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION", None)
    systemConfigDrvList = harmonyCoreComponent.createListSymbol("LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION", None)
    systemConfigMWList = harmonyCoreComponent.createListSymbol("LIST_SYSTEM_CONFIG_H_MIDDLEWARE_CONFIGURATION", None)
    systemConfigAppList = harmonyCoreComponent.createListSymbol("LIST_SYSTEM_CONFIG_H_APPLICATION_CONFIGURATION", None)
    confHeaderFile.setDependencies(genConfHeaderFile, ["ENABLE_APP_FILE"])

    # generate tasks.c file
    taskSourceFile = harmonyCoreComponent.createFileSymbol("TASKS_C", None)
    taskSourceFile.setSourcePath("templates/tasks.c.ftl")
    taskSourceFile.setOutputName("tasks.c")
    taskSourceFile.setMarkup(True)
    taskSourceFile.setOverwrite(True)
    taskSourceFile.setDestPath("")
    taskSourceFile.setProjectPath("config/" + configName + "/")
    taskSourceFile.setType("SOURCE")
    taskSourceFile.setEnabled(False)
    taskSysList = harmonyCoreComponent.createListSymbol("LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS", None)
    taskDrvList = harmonyCoreComponent.createListSymbol("LIST_SYSTEM_TASKS_C_CALL_DRIVER_TASKS", None)
    taskLibList = harmonyCoreComponent.createListSymbol("LIST_SYSTEM_TASKS_C_CALL_LIB_TASKS", None)
    taskGenAppList = harmonyCoreComponent.createListSymbol("LIST_SYSTEM_TASKS_C_GEN_APP", None)
    taskGenRtosAppList = harmonyCoreComponent.createListSymbol("LIST_SYSTEM_RTOS_TASKS_C_GEN_APP", None)
    taskRtosDefList = harmonyCoreComponent.createListSymbol("LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS", None)
    taskRtosSchedList = harmonyCoreComponent.createListSymbol("LIST_SYSTEM_RTOS_TASKS_C_CALL_SCHEDULAR", None)
    taskSourceFile.setDependencies(genTaskSourceFile, ["ENABLE_APP_FILE"])