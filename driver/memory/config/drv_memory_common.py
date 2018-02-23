
def enableFileSystemIntegration(symbol, event):
    if (event["value"] == True):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def instantiateComponent(memoryCommonComponent):

    memoryCommonSymNumInst = memoryCommonComponent.createIntegerSymbol("DRV_MEMORY_NUM_INSTANCES", None)
    memoryCommonSymNumInst.setLabel("Number of Instances")
    memoryCommonSymNumInst.setMin(1)
    memoryCommonSymNumInst.setMax(10)
    memoryCommonSymNumInst.setDefaultValue(1)
    memoryCommonSymNumInst.setVisible(True)

    memoryCommonFsEnable = memoryCommonComponent.createBooleanSymbol("DRV_MEMORY_COMMON_FS_ENABLE", None)
    memoryCommonFsEnable.setLabel("Enable File system for Memory Driver")
    memoryCommonFsEnable.setDefaultValue(False)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    memoryCommonFsSourceFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_FS_SOURCE", None)
    memoryCommonFsSourceFile.setSourcePath("driver/memory/src/drv_memory_file_system.c")
    memoryCommonFsSourceFile.setOutputName("drv_memory_file_system.c")
    memoryCommonFsSourceFile.setDestPath("driver/memory/src")
    memoryCommonFsSourceFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryCommonFsSourceFile.setType("SOURCE")
    memoryCommonFsSourceFile.setOverwrite(True)
    memoryCommonFsSourceFile.setEnabled((memoryCommonFsEnable.getValue() == True))
    memoryCommonFsSourceFile.setDependencies(enableFileSystemIntegration, ["DRV_MEMORY_FS_ENABLE"])

    memoryCommonHeaderVariantFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_HEADER_VARIANT", None)
    memoryCommonHeaderVariantFile.setSourcePath("driver/memory/templates/drv_memory_variant_mapping.h.ftl")
    memoryCommonHeaderVariantFile.setOutputName("drv_memory_variant_mapping.h")
    memoryCommonHeaderVariantFile.setDestPath("driver/memory/src")
    memoryCommonHeaderVariantFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryCommonHeaderVariantFile.setType("HEADER")
    memoryCommonHeaderVariantFile.setOverwrite(True)
    memoryCommonHeaderVariantFile.setMarkup(True)

    memoryCommonSymCommonSysCfgFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_SYS_CFG_COMMON", None)
    memoryCommonSymCommonSysCfgFile.setType("STRING")
    memoryCommonSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    memoryCommonSymCommonSysCfgFile.setSourcePath("driver/memory/templates/system/system_config_common.h.ftl")
    memoryCommonSymCommonSysCfgFile.setMarkup(True)