def instantiateComponent(i2sComponentCommon):
    
    i2sSymNumInst = i2sComponentCommon.createIntegerSymbol("DRV_I2S_NUM_INSTANCES", None)
    i2sSymNumInst.setLabel("Number of Instances")
    i2sSymNumInst.setMin(1)
    i2sSymNumInst.setMax(2)
    i2sSymNumInst.setDefaultValue(1)
    i2sSymNumInst.setVisible(False)
    
    i2sSymCommonSysCfgFile = i2sComponentCommon.createFileSymbol("DRV_I2S_COMMON_CFG", None)
    i2sSymCommonSysCfgFile.setType("STRING")
    i2sSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    i2sSymCommonSysCfgFile.setSourcePath("driver/i2s/templates/system/system_config_common.h.ftl")
    i2sSymCommonSysCfgFile.setMarkup(True)