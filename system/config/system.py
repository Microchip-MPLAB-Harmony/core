

################################################################################
#### Business Logic ####
################################################################################
def genSystemHeaderRootFile(symbol, event):
    symbol.setEnabled(event["value"])

def genSystemHeaderCommonFile(symbol, event):
    symbol.setEnabled(event["value"])

def genSystemHeaderModuleFile(symbol, event):
    symbol.setEnabled(event["value"])


############################################################################
#### Code Generation ####
############################################################################

genSystemCommonFiles = harmonyCoreComponent.createBooleanSymbol("ENABLE_SYS_COMMON", coreMenu)
genSystemCommonFiles.setLabel("Generate Harmony System Service Common Files")  
genSystemCommonFiles.setDefaultValue(False)

	
systemHeaderRootFile = harmonyCoreComponent.createFileSymbol("SYSTEM_ROOT", None)
systemHeaderRootFile.setSourcePath("system/system.h")
systemHeaderRootFile.setOutputName("system.h")
systemHeaderRootFile.setDestPath("system/")
systemHeaderRootFile.setProjectPath("config/" + configName + "/system/")
systemHeaderRootFile.setType("HEADER")
systemHeaderRootFile.setOverwrite(True)
systemHeaderRootFile.setEnabled(False)
systemHeaderRootFile.setDependencies(genSystemHeaderRootFile, ["ENABLE_SYS_COMMON"])

systemHeaderCommonFile = harmonyCoreComponent.createFileSymbol("SYSTEM_COMMON", None)
systemHeaderCommonFile.setSourcePath("system/system_common.h")
systemHeaderCommonFile.setOutputName("system_common.h")
systemHeaderCommonFile.setDestPath("system/")
systemHeaderCommonFile.setProjectPath("config/" + configName + "/system/")
systemHeaderCommonFile.setType("HEADER")
systemHeaderCommonFile.setOverwrite(True)
systemHeaderCommonFile.setEnabled(False)
systemHeaderCommonFile.setDependencies(genSystemHeaderCommonFile, ["ENABLE_SYS_COMMON"])

systemHeaderModuleFile = harmonyCoreComponent.createFileSymbol("SYSTEM_MODULE", None)
systemHeaderModuleFile.setSourcePath("system/system_module.h")
systemHeaderModuleFile.setOutputName("system_module.h")
systemHeaderModuleFile.setDestPath("system/")
systemHeaderModuleFile.setProjectPath("config/" + configName + "/system/")
systemHeaderModuleFile.setType("HEADER")
systemHeaderModuleFile.setOverwrite(True)
systemHeaderModuleFile.setEnabled(True)
systemHeaderModuleFile.setDependencies(genSystemHeaderModuleFile, ["ENABLE_SYS_COMMON"])


    