def instantiateComponent(i2cComponent):
    
    i2cSymNumInst = i2cComponent.createIntegerSymbol("DRV_I2C_NUM_INSTANCES", None)
    i2cSymNumInst.setMax(10)
    i2cSymNumInst.setDefaultValue(1)
    
    i2cSymCommonSysCfgFile = i2cComponent.createFileSymbol(None, None)
    i2cSymCommonSysCfgFile.setType("STRING")
    i2cSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    i2cSymCommonSysCfgFile.setSourcePath("driver/i2c/templates/system/system_config_common.h.ftl")
    i2cSymCommonSysCfgFile.setMarkup(True)

    
    
