

################################################################################
#### Business Logic ####
################################################################################
def genSystemFiles(symbol, event):
    symbol.setEnabled(event["value"])


############################################################################
#### Code Generation ####
############################################################################

genSystemCommonFiles = harmonyCoreComponent.createBooleanSymbol("ENABLE_SYS_COMMON", coreMenu)
genSystemCommonFiles.setLabel("Generate Harmony System Service Common Files")
genSystemCommonFiles.setDefaultValue(False)

genSystemMediaFiles = harmonyCoreComponent.createBooleanSymbol("ENABLE_SYS_MEDIA", coreMenu)
genSystemMediaFiles.setLabel("Generate Harmony System Media Files")
genSystemMediaFiles.setDefaultValue(False)
genSystemMediaFiles.setVisible(False)

systemHeaderRootFile = harmonyCoreComponent.createFileSymbol("SYSTEM_ROOT", None)
systemHeaderRootFile.setSourcePath("system/system.h")
systemHeaderRootFile.setOutputName("system.h")
systemHeaderRootFile.setDestPath("system/")
systemHeaderRootFile.setProjectPath("config/" + configName + "/system/")
systemHeaderRootFile.setType("HEADER")
systemHeaderRootFile.setOverwrite(True)
systemHeaderRootFile.setEnabled(False)
systemHeaderRootFile.setDependencies(genSystemFiles, ["ENABLE_SYS_COMMON"])

systemHeaderCommonFile = harmonyCoreComponent.createFileSymbol("SYSTEM_COMMON", None)
systemHeaderCommonFile.setSourcePath("system/system_common.h")
systemHeaderCommonFile.setOutputName("system_common.h")
systemHeaderCommonFile.setDestPath("system/")
systemHeaderCommonFile.setProjectPath("config/" + configName + "/system/")
systemHeaderCommonFile.setType("HEADER")
systemHeaderCommonFile.setOverwrite(True)
systemHeaderCommonFile.setEnabled(False)
systemHeaderCommonFile.setDependencies(genSystemFiles, ["ENABLE_SYS_COMMON"])

systemHeaderModuleFile = harmonyCoreComponent.createFileSymbol("SYSTEM_MODULE", None)
systemHeaderModuleFile.setSourcePath("system/system_module.h")
systemHeaderModuleFile.setOutputName("system_module.h")
systemHeaderModuleFile.setDestPath("system/")
systemHeaderModuleFile.setProjectPath("config/" + configName + "/system/")
systemHeaderModuleFile.setType("HEADER")
systemHeaderModuleFile.setOverwrite(True)
systemHeaderModuleFile.setEnabled(False)
systemHeaderModuleFile.setDependencies(genSystemFiles, ["ENABLE_SYS_COMMON"])

systemHeaderMediaFile = harmonyCoreComponent.createFileSymbol("SYSTEM_MEDIA", None)
systemHeaderMediaFile.setSourcePath("system/system_media.h")
systemHeaderMediaFile.setOutputName("system_media.h")
systemHeaderMediaFile.setDestPath("system/")
systemHeaderMediaFile.setProjectPath("config/" + configName + "/system/")
systemHeaderMediaFile.setType("HEADER")
systemHeaderMediaFile.setOverwrite(True)
systemHeaderMediaFile.setEnabled(False)
systemHeaderMediaFile.setDependencies(genSystemFiles, ["ENABLE_SYS_MEDIA"])


