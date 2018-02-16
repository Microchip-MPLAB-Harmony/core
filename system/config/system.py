# System service layer level common content

global enabledSysServicesCount
enabledSysServicesCount = 0

def genSysServiceFiles(systemFile, event):
    global enabledSysServicesCount

    if event["value"] == True:
        enabledSysServicesCount += 1
    if event["value"] == False:
        enabledSysServicesCount -= 1

    systemFile.clearValue()
    if enabledSysServicesCount > 0:
        systemFile.setValue(True, 2)
    else:
        systemFile.setValue(False, 2)

def genSysFile(systemFile, event):
    systemFile.setEnabled(event["value"])

def genSysCommonFile(systemFile, event):
    systemFile.setEnabled(event["value"])

def genSysModuleFile(systemFile, event):
    systemFile.setEnabled(event["value"])

sysServiceNeeded = harmonyCoreComponent.createBooleanSymbol("SYSTEM_SERVICE_NEEDED", None)
sysServiceNeeded.setLabel("Use Harmony System Service Layer Common Files?")
sysServiceNeeded.setDefaultValue(False)
sysServiceNeeded.setReadOnly(True)

genSysServiceLayerFiles = harmonyCoreComponent.createBooleanSymbol("genSysServiceCommonFiles", None)
genSysServiceLayerFiles.setLabel("Generate Harmony System Service Layer Common Files")
genSysServiceLayerFiles.setDependencies(genSysServiceFiles, ["SYSTEM_SERVICE_NEEDED"])
genSysServiceLayerFiles.setDefaultValue(False)
genSysServiceLayerFiles.setVisible(False)

configName = Variables.get("__CONFIGURATION_NAME")

systemHeaderRootFile = harmonyCoreComponent.createFileSymbol(None, None)
systemHeaderRootFile.setSourcePath("system/system.h")
systemHeaderRootFile.setOutputName("system.h")
systemHeaderRootFile.setDestPath("system/")
systemHeaderRootFile.setProjectPath("config/" + configName + "/system/")
systemHeaderRootFile.setType("HEADER")
systemHeaderRootFile.setOverwrite(True)
systemHeaderRootFile.setEnabled(False)
systemHeaderRootFile.setDependencies(genSysFile, ["genSysServiceCommonFiles"])

systemHeaderCommonFile = harmonyCoreComponent.createFileSymbol(None, None)
systemHeaderCommonFile.setSourcePath("system/system_common.h")
systemHeaderCommonFile.setOutputName("system_common.h")
systemHeaderCommonFile.setDestPath("system/")
systemHeaderCommonFile.setProjectPath("config/" + configName + "/system/")
systemHeaderCommonFile.setType("HEADER")
systemHeaderCommonFile.setOverwrite(True)
systemHeaderCommonFile.setEnabled(False)
systemHeaderCommonFile.setDependencies(genSysCommonFile, ["genSysServiceCommonFiles"])

systemHeaderModuleFile = harmonyCoreComponent.createFileSymbol(None, None)
systemHeaderModuleFile.setSourcePath("system/system_module.h")
systemHeaderModuleFile.setOutputName("system_module.h")
systemHeaderModuleFile.setDestPath("system/")
systemHeaderModuleFile.setProjectPath("config/" + configName + "/system/")
systemHeaderModuleFile.setType("HEADER")
systemHeaderModuleFile.setOverwrite(True)
systemHeaderModuleFile.setEnabled(False)
systemHeaderModuleFile.setDependencies(genSysModuleFile, ["genSysServiceCommonFiles"])


