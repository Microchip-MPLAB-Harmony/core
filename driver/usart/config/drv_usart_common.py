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

    usartCommonSysCfgFile = usartComponent.createFileSymbol("USART_COMMON_CFG", None)
    usartCommonSysCfgFile.setType("STRING")
    usartCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    usartCommonSysCfgFile.setSourcePath("driver/usart/templates/system/system_config_common.h.ftl")
    usartCommonSysCfgFile.setMarkup(True)

    usartSystemDefFile = usartComponent.createFileSymbol("USART_DEF", None)
    usartSystemDefFile.setType("STRING")
    usartSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    usartSystemDefFile.setSourcePath("driver/usart/templates/system/system_definitions.h.ftl")
    usartSystemDefFile.setMarkup(True)


