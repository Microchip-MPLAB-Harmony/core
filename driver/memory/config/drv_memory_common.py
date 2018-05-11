global fsCounter

fsCounter = 0

def enableFileSystemIntegration(symbol, event):
    if (event["value"] == True):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def setFileSystem(symbol, event):
    global fsCounter

    if (event["value"] == True):
        fsCounter = fsCounter + 1
        symbol.clearValue()
        symbol.setValue(True, 1)
    else:
        fsCounter = fsCounter - 1

    if (fsCounter == 0):
        symbol.clearValue()
        symbol.setValue(False, 1)

def instantiateComponent(memoryCommonComponent):
    global memoryCommonFsEnable

    memoryCommonSymNumInst = memoryCommonComponent.createIntegerSymbol("DRV_MEMORY_NUM_INSTANCES", None)
    memoryCommonSymNumInst.setLabel("Number of Instances")
    memoryCommonSymNumInst.setMin(1)
    memoryCommonSymNumInst.setMax(10)
    memoryCommonSymNumInst.setVisible(False)
    memoryCommonSymNumInst.setUseSingleDynamicValue(True)

    memoryCommonMode = memoryCommonComponent.createKeyValueSetSymbol("DRV_MEMORY_COMMON_MODE", None)
    memoryCommonMode.setLabel("Driver Mode")
    memoryCommonMode.addKey("ASYNC", "0", "Asynchronous")
    memoryCommonMode.addKey("SYNC", "1", "Synchronous")
    memoryCommonMode.setDisplayMode("Description")
    memoryCommonMode.setOutputMode("Key")
    memoryCommonMode.setVisible(True)
    memoryCommonMode.setDefaultValue(0)

    memoryCommonfsCounter = memoryCommonComponent.createBooleanSymbol("DRV_MEMORY_COMMON_FS_COUNTER", None)
    memoryCommonfsCounter.setLabel("Number of Instances Using FS")
    memoryCommonfsCounter.setDefaultValue(False)
    memoryCommonfsCounter.setVisible(False)
    memoryCommonfsCounter.setUseSingleDynamicValue(True)

    memoryCommonFsEnable = memoryCommonComponent.createBooleanSymbol("DRV_MEMORY_COMMON_FS_ENABLE", None)
    memoryCommonFsEnable.setLabel("Enable Common File system for Memory Driver")
    memoryCommonFsEnable.setDefaultValue(False)
    memoryCommonFsEnable.setVisible(False)
    memoryCommonFsEnable.setDependencies(setFileSystem, ["DRV_MEMORY_COMMON_FS_COUNTER"])


    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    memoryCommonFsSourceFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_FS_SOURCE", None)
    memoryCommonFsSourceFile.setSourcePath("driver/memory/templates/drv_memory_file_system.c.ftl")
    memoryCommonFsSourceFile.setOutputName("drv_memory_file_system.c")
    memoryCommonFsSourceFile.setDestPath("driver/memory/src")
    memoryCommonFsSourceFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryCommonFsSourceFile.setType("SOURCE")
    memoryCommonFsSourceFile.setOverwrite(True)
    memoryCommonFsSourceFile.setMarkup(True)
    memoryCommonFsSourceFile.setEnabled((memoryCommonFsEnable.getValue() == True))
    memoryCommonFsSourceFile.setDependencies(enableFileSystemIntegration, ["DRV_MEMORY_COMMON_FS_ENABLE"])

    memoryCommonHeaderVariantFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_HEADER_VARIANT", None)
    memoryCommonHeaderVariantFile.setSourcePath("driver/memory/templates/drv_memory_variant_mapping.h.ftl")
    memoryCommonHeaderVariantFile.setOutputName("drv_memory_variant_mapping.h")
    memoryCommonHeaderVariantFile.setDestPath("driver/memory/src")
    memoryCommonHeaderVariantFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryCommonHeaderVariantFile.setType("HEADER")
    memoryCommonHeaderVariantFile.setOverwrite(True)
    memoryCommonHeaderVariantFile.setMarkup(True)

    memoryCommonSystemDefFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_SYS_DEF_COMMON", None)
    memoryCommonSystemDefFile.setType("STRING")
    memoryCommonSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    memoryCommonSystemDefFile.setSourcePath("driver/memory/templates/system/system_definitions_common.h.ftl")
    memoryCommonSystemDefFile.setMarkup(True)

    memoryCommonSymCommonSysCfgFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_SYS_CFG_COMMON", None)
    memoryCommonSymCommonSysCfgFile.setType("STRING")
    memoryCommonSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    memoryCommonSymCommonSysCfgFile.setSourcePath("driver/memory/templates/system/system_config_common.h.ftl")
    memoryCommonSymCommonSysCfgFile.setMarkup(True)