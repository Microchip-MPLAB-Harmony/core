def instantiateComponent(usartComponent):

    usartSymNumInst = usartComponent.createIntegerSymbol("DRV_USART_NUM_INSTANCES", None)
    usartSymNumInst.setLabel("Number of Instances")
    usartSymNumInst.setMin(1)
    usartSymNumInst.setMax(10)
    usartSymNumInst.setDefaultValue(1)
    usartSymNumInst.setVisible(False)

    usartSymBufPool = usartComponent.createIntegerSymbol("DRV_USART_BUFFER_POOL_SIZE", None)
    usartSymBufPool.setLabel("Buffer Pool Size")
    usartSymBufPool.setMin(1)
    usartSymBufPool.setDefaultValue(10)
    usartSymBufPool.setVisible(False)

    usartSymCommonSysCfgFile = usartComponent.createFileSymbol("USART_COMMON_CFG", None)
    usartSymCommonSysCfgFile.setType("STRING")
    usartSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    usartSymCommonSysCfgFile.setSourcePath("driver/usart/templates/system/system_config_common.h.ftl")
    usartSymCommonSysCfgFile.setMarkup(True)


