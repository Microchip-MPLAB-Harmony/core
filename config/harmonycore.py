
def instantiateComponent(harmonyCoreComponent):
    coreMenu = harmonyCoreComponent.createMenuSymbol("HARMONY_CORE_MENU", None)
    coreMenu.setLabel("Harmony Core Configuration")
	
    configName = Variables.get("__CONFIGURATION_NAME")

    execfile(Module.getPath() + "/driver/config/driver.py")
 
    execfile(Module.getPath() + "/system/config/system.py")
        
    execfile(Module.getPath() + "/system/int/config/sys_int.py")

    execfile(Module.getPath() + "/system/dma/config/sys_dma.py")

    execfile(Module.getPath() + "/osal/config/osal.py")
