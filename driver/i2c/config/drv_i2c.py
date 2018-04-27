def instantiateComponent(i2cComponent, index):

    i2cNumInstances = Database.getSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES")
    i2cNumInstances = i2cNumInstances + 1

    Database.clearSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES")
    Database.setSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES", i2cNumInstances, 1)

    # Enable "Generate Harmony Application Files" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_APP_FILE", True, 1)

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_DRV_COMMON", True, 1)

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_SYS_COMMON", True, 1)

    # Enable "Enable System Interrupt" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_SYS_INT", True, 1)

    # Enable "Enable System Ports" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_SYS_PORTS", True, 1)

    # Enable "Enable OSAL" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_OSAL", True, 1)

    i2cSymIndex = i2cComponent.createIntegerSymbol("INDEX", None)
    i2cSymIndex.setVisible(False)
    i2cSymIndex.setDefaultValue(index)

    i2cSymPLIB = i2cComponent.createStringSymbol("DRV_I2C_PLIB", None)
    i2cSymPLIB.setLabel("PLIB Used")
    i2cSymPLIB.setReadOnly(True)
    i2cSymPLIB.setDefaultValue("TWIHS0")

    i2cGlobalMode = i2cComponent.createBooleanSymbol("DRV_I2C_MODE", None)
    i2cGlobalMode.setLabel("**** Driver Mode Update ****")
    i2cGlobalMode.setValue(Database.getSymbolValue("drv_i2c", "DRV_I2C_COMMON_MODE"), 1)
    i2cGlobalMode.setVisible(False)
    i2cGlobalMode.setDependencies(i2cDriverMode, ["drv_i2c.DRV_I2C_COMMON_MODE"])

    i2cSymNumClients = i2cComponent.createIntegerSymbol("DRV_I2C_NUM_CLIENTS", None)
    i2cSymNumClients.setLabel("Number of clients")
    i2cSymNumClients.setMax(10)
    i2cSymNumClients.setDefaultValue(1)

    i2cSymQueueSize = i2cComponent.createIntegerSymbol("DRV_I2C_QUEUE_SIZE", None)
    i2cSymQueueSize.setLabel("Transfer Queue Size")
    i2cSymQueueSize.setMax(64)
    i2cSymQueueSize.setDefaultValue(2)
    i2cSymQueueSize.setDependencies(asyncModeOptions, ["DRV_I2C_MODE"])

    configName = Variables.get("__CONFIGURATION_NAME")

    # Global Header Files
    i2cSymHeaderFile = i2cComponent.createFileSymbol("DRV_I2C_FILE_MAIN_HEADER", None)
    i2cSymHeaderFile.setSourcePath("driver/i2c/drv_i2c.h")
    i2cSymHeaderFile.setOutputName("drv_i2c.h")
    i2cSymHeaderFile.setDestPath("driver/i2c/")
    i2cSymHeaderFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cSymHeaderFile.setType("HEADER")
    i2cSymHeaderFile.setOverwrite(True)

    i2cSymHeaderDefFile = i2cComponent.createFileSymbol("DRV_I2C_FILE_DEF_HEADER", None)
    i2cSymHeaderDefFile.setSourcePath("driver/i2c/templates/drv_i2c_definitions.h.ftl")
    i2cSymHeaderDefFile.setOutputName("drv_i2c_definitions.h")
    i2cSymHeaderDefFile.setDestPath("driver/i2c/")
    i2cSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cSymHeaderDefFile.setType("HEADER")
    i2cSymHeaderDefFile.setMarkup(True)
    i2cSymHeaderDefFile.setOverwrite(True)

    # Async Source Files
    i2cAsyncSymSourceFile = i2cComponent.createFileSymbol("DRV_I2C_ASYNC_SRC", None)
    i2cAsyncSymSourceFile.setSourcePath("driver/i2c/src/async/drv_i2c.c")
    i2cAsyncSymSourceFile.setOutputName("drv_i2c.c")
    i2cAsyncSymSourceFile.setDestPath("driver/i2c/src")
    i2cAsyncSymSourceFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cAsyncSymSourceFile.setType("SOURCE")
    i2cAsyncSymSourceFile.setOverwrite(True)
    i2cAsyncSymSourceFile.setDependencies(asyncFileGen, ["DRV_I2C_MODE"])

    i2cAsyncSymHeaderLocalFile = i2cComponent.createFileSymbol("DRV_I2C_ASYNC_HEADER", None)
    i2cAsyncSymHeaderLocalFile.setSourcePath("driver/i2c/src/async/drv_i2c_local.h")
    i2cAsyncSymHeaderLocalFile.setOutputName("drv_i2c_local.h")
    i2cAsyncSymHeaderLocalFile.setDestPath("driver/i2c/src")
    i2cAsyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cAsyncSymHeaderLocalFile.setType("SOURCE")
    i2cAsyncSymHeaderLocalFile.setOverwrite(True)
    i2cAsyncSymHeaderLocalFile.setDependencies(asyncFileGen, ["DRV_I2C_MODE"])

    # Sync Source Files
    i2cSyncSymSourceFile = i2cComponent.createFileSymbol("DRV_I2C_SYNC_SRC", None)
    i2cSyncSymSourceFile.setSourcePath("driver/i2c/src/sync/drv_i2c.c")
    i2cSyncSymSourceFile.setOutputName("drv_i2c.c")
    i2cSyncSymSourceFile.setDestPath("driver/i2c/src")
    i2cSyncSymSourceFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cSyncSymSourceFile.setType("SOURCE")
    i2cSyncSymSourceFile.setOverwrite(True)
    i2cSyncSymSourceFile.setDependencies(syncFileGen, ["DRV_I2C_MODE"])

    i2cSyncSymHeaderLocalFile = i2cComponent.createFileSymbol("DRV_I2C_SYNC_HEADER", None)
    i2cSyncSymHeaderLocalFile.setSourcePath("driver/i2c/src/sync/drv_i2c_local.h")
    i2cSyncSymHeaderLocalFile.setOutputName("drv_i2c_local.h")
    i2cSyncSymHeaderLocalFile.setDestPath("driver/i2c/src")
    i2cSyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cSyncSymHeaderLocalFile.setType("SOURCE")
    i2cSyncSymHeaderLocalFile.setOverwrite(True)
    i2cSyncSymHeaderLocalFile.setDependencies(syncFileGen, ["DRV_I2C_MODE"])

    # System Template Files
    i2cSymSystemDefIncFile = i2cComponent.createFileSymbol("DRV_I2C_FILE_SYS_DEF", None)
    i2cSymSystemDefIncFile.setType("STRING")
    i2cSymSystemDefIncFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    i2cSymSystemDefIncFile.setSourcePath("driver/i2c/templates/system/system_definitions.h.ftl")
    i2cSymSystemDefIncFile.setMarkup(True)
    
    i2cSymSystemDefObjFile = i2cComponent.createFileSymbol("DRV_I2C_FILE_SYS_DEF_OBJ", None)
    i2cSymSystemDefObjFile.setType("STRING")
    i2cSymSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    i2cSymSystemDefObjFile.setSourcePath("driver/i2c/templates/system/system_definitions_objects.h.ftl")
    i2cSymSystemDefObjFile.setMarkup(True)

    i2cSymSystemConfigFile = i2cComponent.createFileSymbol("DRV_I2C_FILE_SYS_CONFIG", None)
    i2cSymSystemConfigFile.setType("STRING")
    i2cSymSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    i2cSymSystemConfigFile.setSourcePath("driver/i2c/templates/system/system_config.h.ftl")
    i2cSymSystemConfigFile.setMarkup(True)

    i2cSymSystemInitDataFile = i2cComponent.createFileSymbol("DRV_I2C_FILE_SYS_INIT_DATA", None)
    i2cSymSystemInitDataFile.setType("STRING")
    i2cSymSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    i2cSymSystemInitDataFile.setSourcePath("driver/i2c/templates/system/system_initialize_data.c.ftl")
    i2cSymSystemInitDataFile.setMarkup(True)

    i2cSymSystemInitFile = i2cComponent.createFileSymbol("DRV_I2C_FILE_SYS_INIT", None)
    i2cSymSystemInitFile.setType("STRING")
    i2cSymSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    i2cSymSystemInitFile.setSourcePath("driver/i2c/templates/system/system_initialize.c.ftl")
    i2cSymSystemInitFile.setMarkup(True)

def i2cDriverMode(symbol, event):
    symbol.setValue(Database.getSymbolValue("drv_i2c", "DRV_I2C_COMMON_MODE"), 1)

def asyncModeOptions(symbol, event):
    if(event["value"] == False):
       symbol.setVisible(True)
    elif(event["value"] == True):
       symbol.setVisible(False)

def syncFileGen(symbol, event):
    if(event["value"] == True):
       symbol.setEnabled(True)
    elif(event["value"] == False):
       symbol.setEnabled(False)

def asyncFileGen(symbol, event):
    if(event["value"] == False):
       symbol.setEnabled(True)
    elif(event["value"] == True):
       symbol.setEnabled(False)

def destroyComponent(i2cComponent):

    i2cNumInstances = Database.getSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES")
    i2cNumInstances = i2cNumInstances - 1
    Database.setSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES", i2cNumInstances, 1)

    # Disable "Generate Harmony Application Files" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_APP_FILE", False, 3)

    # Disable "Generate Harmony Driver Common Files" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_DRV_COMMON", False, 3)

    # Disable "Generate Harmony System Service Common Files" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_SYS_COMMON", False, 3)

    # Disable "Enable System Interrupt" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_SYS_INT", False, 3)

    # Disable "Enable System Ports" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_SYS_PORTS", False, 3)

    # Enable "Enable OSAL" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_OSAL", False, 1)

def onDependentComponentAdded(drv_i2c, id, i2c):
    if id == "drv_i2c_TWIHS_dependency" :
        plibUsed = drv_i2c.getSymbolByID("DRV_I2C_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(i2c.getID().upper(), 2)
    
    
