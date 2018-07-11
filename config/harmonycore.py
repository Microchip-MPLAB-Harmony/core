
################################################################################
#### Business Logic ####
################################################################################
global osalHeaderImpBasicFile
global osalHeaderFreeRtosFile
global osalSourceFreeRtosFile
global osalSelectRTOS

def generateAppFiles(symbol, event):
    Database.clearSymbolValue("core", "CoreGenAppFiles")
    Database.setSymbolValue("core", "CoreGenAppFiles", event["value"], 2)

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

    genAppFiles = harmonyCoreComponent.createBooleanSymbol("GEN_APP_FILE", coreMenu)
    genAppFiles.setLabel("Generate Harmony Application Files")
    genAppFiles.setVisible(False)       
    genAppFiles.setDependencies(generateAppFiles, ["ENABLE_APP_FILE"])

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
