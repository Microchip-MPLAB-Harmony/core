
################################################################################
#### Business Logic ####
################################################################################
global osalHeaderImpBasicFile
global osalHeaderFreeRtosFile
global osalSourceFreeRtosFile
global osalSelectRTOS

def enableAppFile(symbol, event):
    drv_common = Database.getSymbolValue("Harmony", "ENABLE_DRV_COMMON")
    sys_common = Database.getSymbolValue("Harmony", "ENABLE_SYS_COMMON")

    if ((drv_common == True) or (sys_common == True)):
        symbol.setValue(True,1)
    else:
        symbol.setValue(False,1)


def genHarmonyFiles(symbol, event):
    drv_common = Database.getSymbolValue("Harmony", "ENABLE_DRV_COMMON")
    sys_common = Database.getSymbolValue("Harmony", "ENABLE_SYS_COMMON")
    appfile = Database.getSymbolValue("Harmony", "ENABLE_APP_FILE")

    if ((drv_common == True) or (sys_common == True) or (appfile == True)):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

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

    harmonyAppFile = harmonyCoreComponent.createBooleanSymbol("ENABLE_APP_FILE", coreMenu)
    harmonyAppFile.setLabel("Generate Harmony Application Files")
    harmonyAppFile.setDefaultValue(False)
    harmonyAppFile.setDependencies(enableAppFile, ["ENABLE_DRV_COMMON", "ENABLE_SYS_COMMON"])


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
    userHeaderFile.setDependencies(genHarmonyFiles, ["ENABLE_DRV_COMMON", "ENABLE_SYS_COMMON", "ENABLE_APP_FILE"])
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
    confHeaderFile.setDependencies(genHarmonyFiles, ["ENABLE_DRV_COMMON", "ENABLE_SYS_COMMON", "ENABLE_APP_FILE"])

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
    taskSourceFile.setDependencies(genHarmonyFiles, ["ENABLE_DRV_COMMON", "ENABLE_SYS_COMMON", "ENABLE_APP_FILE"])

def onGenericDependencySatisfied(dependencyID, satisfierID):
    print("satisfied: " + dependencyID + ", " + satisfierID)

    if satisfierID == "FreeRTOS":
        Database.clearSymbolValue("Harmony", "SELECT_RTOS")
        Database.setSymbolValue("Harmony", "SELECT_RTOS", "FreeRTOS", 2)

def onGenericDependencyUnsatisfied(dependencyID, satisfierID):
    print("unsatisfied: " + dependencyID + ", " + satisfierID)

    if satisfierID == "FreeRTOS":
        Database.clearSymbolValue("Harmony", "SELECT_RTOS")
        Database.setSymbolValue("Harmony", "SELECT_RTOS", "BareMetal", 2)

