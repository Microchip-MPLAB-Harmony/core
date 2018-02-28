def instantiateComponent(spiComponentCommon):
    
    spiSymNumInst = spiComponentCommon.createIntegerSymbol("DRV_SPI_NUM_INSTANCES", None)
    spiSymNumInst.setLabel("Number of Instances")
 #   spiSymNumInst.setMin(1)
 #   spiSymNumInst.setMax(10)
    spiSymNumInst.setDefaultValue(1)
    spiSymNumInst.setVisible(False)
    
    spiSymCommonSysCfgFile = spiComponentCommon.createFileSymbol("DRV_SPI_COMMON_CFG", None)
    spiSymCommonSysCfgFile.setType("STRING")
    spiSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    spiSymCommonSysCfgFile.setSourcePath("driver/spi/templates/system/system_config_common.h.ftl")
    spiSymCommonSysCfgFile.setMarkup(True)