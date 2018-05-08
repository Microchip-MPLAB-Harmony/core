def instantiateComponent(i2cComponent, index):

    i2cNumInstances = Database.getSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES")
    i2cNumInstances = i2cNumInstances + 1

    Database.clearSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES")
    Database.setSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES", i2cNumInstances, 1)

    i2cSymIndex = i2cComponent.createIntegerSymbol("INDEX", None)
    i2cSymIndex.setVisible(False)
    i2cSymIndex.setDefaultValue(index)

    i2cSymPLIB = i2cComponent.createStringSymbol("DRV_I2C_PLIB", None)
    i2cSymPLIB.setLabel("PLIB Used")
    i2cSymPLIB.setReadOnly(True)
    i2cSymPLIB.setDefaultValue("TWIHS0")

    i2cSymNumClients = i2cComponent.createIntegerSymbol("DRV_I2C_NUM_CLIENTS", None)
    i2cSymNumClients.setLabel("Number of clients")
    i2cSymNumClients.setMax(10)
    i2cSymNumClients.setDefaultValue(1)

    i2cSymQueueSize = i2cComponent.createIntegerSymbol("DRV_I2C_QUEUE_SIZE", None)
    i2cSymQueueSize.setLabel("Transfer Queue Size")
    i2cSymQueueSize.setMax(64)
    i2cSymQueueSize.setDefaultValue(2)
    i2cSymQueueSize.setDependencies(asyncModeOptions, ["drv_i2c.DRV_I2C_MODE"])

    configName = Variables.get("__CONFIGURATION_NAME")

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

def asyncModeOptions(symbol, event):
    if(event["value"] == False):
       symbol.setVisible(True)
    elif(event["value"] == True):
       symbol.setVisible(False)

def destroyComponent(i2cComponent):

    i2cNumInstances = Database.getSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES")
    i2cNumInstances = i2cNumInstances - 1
    Database.setSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES", i2cNumInstances, 1)

def onDependentComponentAdded(drv_i2c, id, i2c):
    if id == "drv_i2c_I2C_dependency" :
        plibUsed = drv_i2c.getSymbolByID("DRV_I2C_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(i2c.getID().upper(), 2)


