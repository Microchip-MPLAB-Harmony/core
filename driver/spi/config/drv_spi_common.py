def instantiateComponent(spiComponentCommon):

    res = Database.activateComponents(["HarmonyCore"])

    spiMode = spiComponentCommon.createKeyValueSetSymbol("DRV_SPI_COMMON_MODE", None)
    spiMode.setLabel("Driver Mode")
    spiMode.addKey("ASYNC", "0", "Asynchronous")
    spiMode.addKey("SYNC", "1", "Synchronous")
    spiMode.setDisplayMode("Description")
    spiMode.setOutputMode("Key")
    spiMode.setVisible(True)
    spiMode.setDefaultValue(0)

    spiSymNumInst = spiComponentCommon.createIntegerSymbol("DRV_SPI_NUM_INSTANCES", None)
    spiSymNumInst.setLabel("Number of Instances")
    spiSymNumInst.setDefaultValue(0)
    spiSymNumInst.setVisible(False)
    spiSymNumInst.setUseSingleDynamicValue(True)

    spiSymCommonSysCfgFile = spiComponentCommon.createFileSymbol("DRV_SPI_COMMON_CFG", None)
    spiSymCommonSysCfgFile.setType("STRING")
    spiSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    spiSymCommonSysCfgFile.setSourcePath("driver/spi/templates/system/system_config_common.h.ftl")
    spiSymCommonSysCfgFile.setMarkup(True)

    spiSymSystemDefIncFile = spiComponentCommon.createFileSymbol("DRV_SPI_SYSTEM_DEF", None)
    spiSymSystemDefIncFile.setType("STRING")
    spiSymSystemDefIncFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    spiSymSystemDefIncFile.setSourcePath("driver/spi/templates/system/system_definitions.h.ftl")
    spiSymSystemDefIncFile.setMarkup(True)
