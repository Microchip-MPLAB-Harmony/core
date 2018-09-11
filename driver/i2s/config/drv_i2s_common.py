def instantiateComponent(i2sComponentCommon):
    i2sSymCommonSysCfgFile = i2sComponentCommon.createFileSymbol("DRV_I2S_COMMON_CFG", None)
    i2sSymCommonSysCfgFile.setType("STRING")
    i2sSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    i2sSymCommonSysCfgFile.setSourcePath("driver/i2s/templates/system/system_config_common.h.ftl")
    i2sSymCommonSysCfgFile.setMarkup(True)