################################################################################
#### Business Logic ####
################################################################################
def syncFileGen(Sym, event):
    if(event["value"] == 1):
       Sym.setEnabled(True)
    elif(event["value"] == 0):
       Sym.setEnabled(False)

def asyncFileGen(Sym, event):
    if(event["value"] == 0):
       Sym.setEnabled(True)
    elif(event["value"] == 1):
       Sym.setEnabled(False)

################################################################################
#### Component ####
################################################################################
def instantiateComponent(usartComponent):

    res = Database.activateComponents(["HarmonyCore"])

    usartMode = usartComponent.createKeyValueSetSymbol("DRV_USART_MODE", None)
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
    configName = Variables.get("__CONFIGURATION_NAME")

    # Global Header Files
    usartHeaderFile = usartComponent.createFileSymbol("USART_HEADER", None)
    usartHeaderFile.setSourcePath("driver/usart/drv_usart.h")
    usartHeaderFile.setOutputName("drv_usart.h")
    usartHeaderFile.setDestPath("driver/usart/")
    usartHeaderFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartHeaderFile.setType("HEADER")
    usartHeaderFile.setOverwrite(True)

    usartHeaderDefFile = usartComponent.createFileSymbol("USART_HEADER_DEF", None)
    usartHeaderDefFile.setSourcePath("driver/usart/templates/drv_usart_definitions.h.ftl")
    usartHeaderDefFile.setOutputName("drv_usart_definitions.h")
    usartHeaderDefFile.setDestPath("driver/usart/")
    usartHeaderDefFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartHeaderDefFile.setType("HEADER")
    usartHeaderDefFile.setMarkup(True)
    usartHeaderDefFile.setOverwrite(True)

    # Async Source Files
    usartAsyncSourceFile = usartComponent.createFileSymbol("USART_ASYNC_SOURCE", None)
    usartAsyncSourceFile.setSourcePath("driver/usart/src/async/drv_usart.c")
    usartAsyncSourceFile.setOutputName("drv_usart.c")
    usartAsyncSourceFile.setDestPath("driver/usart/src")
    usartAsyncSourceFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartAsyncSourceFile.setType("SOURCE")
    usartAsyncSourceFile.setOverwrite(True)
    usartAsyncSourceFile.setEnabled(True)
    usartAsyncSourceFile.setDependencies(asyncFileGen, ["DRV_USART_MODE"])

    usartAsyncHeaderLocalFile = usartComponent.createFileSymbol("USART_ASYNC_LOCAL", None)
    usartAsyncHeaderLocalFile.setSourcePath("driver/usart/src/async/drv_usart_local.h")
    usartAsyncHeaderLocalFile.setOutputName("drv_usart_local.h")
    usartAsyncHeaderLocalFile.setDestPath("driver/usart/src")
    usartAsyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartAsyncHeaderLocalFile.setType("SOURCE")
    usartAsyncHeaderLocalFile.setOverwrite(True)
    usartAsyncHeaderLocalFile.setEnabled(True)
    usartAsyncHeaderLocalFile.setDependencies(asyncFileGen, ["DRV_USART_MODE"])

    # Sync Source Files
    usartSyncSourceFile = usartComponent.createFileSymbol("USART_SYNC_SOURCE", None)
    usartSyncSourceFile.setSourcePath("driver/usart/src/sync/drv_usart.c")
    usartSyncSourceFile.setOutputName("drv_usart.c")
    usartSyncSourceFile.setDestPath("driver/usart/src")
    usartSyncSourceFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartSyncSourceFile.setType("SOURCE")
    usartSyncSourceFile.setOverwrite(True)
    usartSyncSourceFile.setEnabled(False)
    usartSyncSourceFile.setDependencies(syncFileGen, ["DRV_USART_MODE"])

    usartSyncHeaderLocalFile = usartComponent.createFileSymbol("USART_SYNC_LOCAL", None)
    usartSyncHeaderLocalFile.setSourcePath("driver/usart/src/sync/drv_usart_local.h")
    usartSyncHeaderLocalFile.setOutputName("drv_usart_local.h")
    usartSyncHeaderLocalFile.setDestPath("driver/usart/src")
    usartSyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/usart/")
    usartSyncHeaderLocalFile.setType("SOURCE")
    usartSyncHeaderLocalFile.setOverwrite(True)
    usartSyncHeaderLocalFile.setEnabled(False)
    usartSyncHeaderLocalFile.setDependencies(syncFileGen, ["DRV_USART_MODE"])

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
