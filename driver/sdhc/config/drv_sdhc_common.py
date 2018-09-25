global fsCounter

fsCounter = 0

def enableFileSystemIntegration(symbol, event):
    symbol.setEnabled(event["value"])

def setFileSystem(symbol, event):
    global fsCounter

    if (event["value"] == True):
        fsCounter = fsCounter + 1
        symbol.clearValue()
        symbol.setValue(True, 1)
    else:
        if (fsCounter != 0):
            fsCounter = fsCounter - 1

    if (fsCounter == 0):
        symbol.clearValue()
        symbol.setValue(False, 1)

def instantiateComponent(sdhcCommonComponent):
    
    res = Database.activateComponents(["HarmonyCore"])

    sdhcInstances = sdhcCommonComponent.createIntegerSymbol("DRV_SDHC_INSTANCES_NUMBER", None)
    sdhcInstances.setLabel("Number of SDHC Instances")
    sdhcInstances.setDefaultValue(1)
    sdhcInstances.setMax(1)
    sdhcInstances.setMin(0)

    sdhcCommonfsCounter = sdhcCommonComponent.createBooleanSymbol("DRV_SDHC_COMMON_FS_COUNTER", None)
    sdhcCommonfsCounter.setLabel("Number of Instances Using FS")
    sdhcCommonfsCounter.setDefaultValue(False)
    sdhcCommonfsCounter.setVisible(False)
    sdhcCommonfsCounter.setUseSingleDynamicValue(True)

    sdhcCommonFsEnable = sdhcCommonComponent.createBooleanSymbol("DRV_SDHC_COMMON_FS_ENABLE", None)
    sdhcCommonFsEnable.setLabel("Enable Common File system for SDHC Driver")
    sdhcCommonFsEnable.setDefaultValue(False)
    sdhcCommonFsEnable.setVisible(False)
    sdhcCommonFsEnable.setDependencies(setFileSystem, ["DRV_SDHC_COMMON_FS_COUNTER"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    sdhcCommonFsSourceFile = sdhcCommonComponent.createFileSymbol("DRV_SDHC_FS_SOURCE", None)
    sdhcCommonFsSourceFile.setSourcePath("driver/sdhc/templates/drv_sdhc_file_system.c.ftl")
    sdhcCommonFsSourceFile.setOutputName("drv_sdhc_file_system.c")
    sdhcCommonFsSourceFile.setDestPath("driver/sdhc/src")
    sdhcCommonFsSourceFile.setProjectPath("config/" + configName + "/driver/sdhc/")
    sdhcCommonFsSourceFile.setType("SOURCE")
    sdhcCommonFsSourceFile.setOverwrite(True)
    sdhcCommonFsSourceFile.setMarkup(True)
    sdhcCommonFsSourceFile.setEnabled((sdhcCommonFsEnable.getValue() == True))
    sdhcCommonFsSourceFile.setDependencies(enableFileSystemIntegration, ["DRV_SDHC_COMMON_FS_ENABLE"])

    sdhcCommonHeaderVariantFile = sdhcCommonComponent.createFileSymbol("DRV_SDHC_HEADER_VARIANT", None)
    sdhcCommonHeaderVariantFile.setSourcePath("driver/sdhc/templates/drv_sdhc_variant_mapping.h.ftl")
    sdhcCommonHeaderVariantFile.setOutputName("drv_sdhc_variant_mapping.h")
    sdhcCommonHeaderVariantFile.setDestPath("driver/sdhc/src")
    sdhcCommonHeaderVariantFile.setProjectPath("config/" + configName + "/driver/sdhc/")
    sdhcCommonHeaderVariantFile.setType("HEADER")
    sdhcCommonHeaderVariantFile.setOverwrite(True)
    sdhcCommonHeaderVariantFile.setMarkup(True)

    sdhcCommonSystemDefFile = sdhcCommonComponent.createFileSymbol("DRV_SDHC_SYS_DEF_COMMON", None)
    sdhcCommonSystemDefFile.setType("STRING")
    sdhcCommonSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sdhcCommonSystemDefFile.setSourcePath("driver/sdhc/templates/system/system_definitions_common.h.ftl")
    sdhcCommonSystemDefFile.setMarkup(True)

    sdhcCommonSymCommonSysCfgFile = sdhcCommonComponent.createFileSymbol("DRV_SDHC_SYS_CFG_COMMON", None)
    sdhcCommonSymCommonSysCfgFile.setType("STRING")
    sdhcCommonSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    sdhcCommonSymCommonSysCfgFile.setSourcePath("driver/sdhc/templates/system/system_config_common.h.ftl")
    sdhcCommonSymCommonSysCfgFile.setMarkup(True)