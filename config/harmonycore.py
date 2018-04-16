
################################################################################
#### Business Logic ####
################################################################################
def generateAppFiles(symbol, event):
    Database.clearSymbolValue("core", "CoreGenAppFiles")
    Database.setSymbolValue("core", "CoreGenAppFiles", event["value"], 2)


################################################################################
#### Component ####
################################################################################
def instantiateComponent(harmonyCoreComponent):
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

    execfile(Module.getPath() + "/driver/config/driver.py")
 
    execfile(Module.getPath() + "/system/config/system.py")
        
    execfile(Module.getPath() + "/system/int/config/sys_int.py")

    execfile(Module.getPath() + "/system/dma/config/sys_dma.py")

    execfile(Module.getPath() + "/osal/config/osal.py")
