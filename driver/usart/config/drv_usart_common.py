################################################################################
#### Component ####
################################################################################
def instantiateComponent(usartComponent):

    res = Database.activateComponents(["HarmonyCore"])

    usartMode = usartComponent.createKeyValueSetSymbol("DRV_USART_COMMON_MODE", None)
    usartMode.setLabel("Driver Mode")
    usartMode.addKey("ASYNC", "0", "Asynchronous")
    usartMode.addKey("SYNC", "1", "Synchronous")
    usartMode.setDisplayMode("Description")
    usartMode.setOutputMode("Key")
    usartMode.setVisible(True)
    usartMode.setDefaultValue(0)

    usartSymNumInst = usartComponent.createIntegerSymbol("DRV_USART_NUM_INSTANCES", None)
    usartSymNumInst.setLabel("Number of Instances")
    usartSymNumInst.setMin(1)
    usartSymNumInst.setMax(10)
    usartSymNumInst.setDefaultValue(0)
    usartSymNumInst.setUseSingleDynamicValue(True)
    usartSymNumInst.setVisible(False)

    usartSymBufPool = usartComponent.createIntegerSymbol("DRV_USART_BUFFER_POOL_SIZE", None)
    usartSymBufPool.setLabel("Buffer Pool Size")
    usartSymBufPool.setMin(1)
    usartSymBufPool.setDefaultValue(0)
    usartSymBufPool.setUseSingleDynamicValue(True)
    usartSymBufPool.setVisible(False)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    # Common system file content
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
