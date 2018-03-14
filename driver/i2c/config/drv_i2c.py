def instantiateComponent(i2cComponent, index):
    
    numInstances = Database.getSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES")
  
    if numInstances is None:
        numInstances = 1
    else:
        numInstances = numInstances + 1
        
    Database.setSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES", numInstances, 1)
    
    i2cSymIndex = i2cComponent.createIntegerSymbol("INDEX", None)
    i2cSymIndex.setVisible(False)
    i2cSymIndex.setDefaultValue(index)
    
    i2cSymPLIB = i2cComponent.createStringSymbol("DRV_I2C_PLIB", None)
    i2cSymPLIB.setLabel("PLIB Used")
    i2cSymPLIB.setReadOnly(True)
    i2cSymPLIB.setDefaultValue("TWI0")
    
    i2cSymNumClients = i2cComponent.createIntegerSymbol("DRV_I2C_NUM_CLIENTS", None)
    i2cSymNumClients.setLabel("Number of clients")
    i2cSymNumClients.setMax(10)
    i2cSymNumClients.setDefaultValue(1)
    
    i2cSymQueueSize = i2cComponent.createIntegerSymbol("DRV_I2C_QUEUE_SIZE", None)
    i2cSymQueueSize.setLabel("Transfer Queue Size")
    i2cSymQueueSize.setMax(64)
    i2cSymQueueSize.setDefaultValue(2)
    
    configName = Variables.get("__CONFIGURATION_NAME")
    
    i2cSymHeaderFile = i2cComponent.createFileSymbol("DRV_I2C_FILE_MAIN_HEADER", None)
    i2cSymHeaderFile.setSourcePath("driver/i2c/drv_i2c.h")
    i2cSymHeaderFile.setOutputName("drv_i2c.h")
    i2cSymHeaderFile.setDestPath("driver/i2c/")
    i2cSymHeaderFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cSymHeaderFile.setType("HEADER")
    i2cSymHeaderFile.setOverwrite(True)
    
    i2cSymHeaderDefFile = i2cComponent.createFileSymbol("DRV_I2C_FILE_DEF_HEADER", None)
    i2cSymHeaderDefFile.setSourcePath("driver/i2c/drv_i2c_definitions.h")
    i2cSymHeaderDefFile.setOutputName("drv_i2c_definitions.h")
    i2cSymHeaderDefFile.setDestPath("driver/i2c/")
    i2cSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cSymHeaderDefFile.setType("HEADER")
    i2cSymHeaderDefFile.setOverwrite(True)

    i2cSymSourceFile = i2cComponent.createFileSymbol("DRV_I2C_FILE_MAIN_SRC", None)
    i2cSymSourceFile.setSourcePath("driver/i2c/src/drv_i2c.c")
    i2cSymSourceFile.setOutputName("drv_i2c.c")
    i2cSymSourceFile.setDestPath("driver/i2c/src")
    i2cSymSourceFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cSymSourceFile.setType("SOURCE")
    i2cSymSourceFile.setOverwrite(True)

    i2cSymHeaderLocalFile = i2cComponent.createFileSymbol("DRV_I2C_FILE_LOCAL_HEADER", None)
    i2cSymHeaderLocalFile.setSourcePath("driver/i2c/src/drv_i2c_local.h")
    i2cSymHeaderLocalFile.setOutputName("drv_i2c_local.h")
    i2cSymHeaderLocalFile.setDestPath("driver/i2c/src")
    i2cSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cSymHeaderLocalFile.setType("SOURCE")
    i2cSymHeaderLocalFile.setOverwrite(True)
    
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
    
def destroyComponent(i2cComponent):
    
    numInstances = Database.getSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES")   
    numInstances = numInstances - 1   
    Database.setSymbolValue("drv_i2c", "DRV_I2C_NUM_INSTANCES", numInstances, 1)
    
def onDependentComponentAdded(drv_i2c, id, i2c):
    if id == "drv_i2c_TWI_dependency" :
        plibUsed = drv_i2c.getSymbolByID("DRV_I2C_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(i2c.getID().upper(), 2)
    
    
