def instantiateComponent(harmonySystemComponent):

	configName = Variables.get("__CONFIGURATION_NAME")

	systemHeaderRootFile = harmonySystemComponent.createFileSymbol(None, None)
	systemHeaderRootFile.setSourcePath("system/system.h")
	systemHeaderRootFile.setOutputName("system.h")
	systemHeaderRootFile.setDestPath("system/")
	systemHeaderRootFile.setProjectPath("config/" + configName + "/system/")
	systemHeaderRootFile.setType("HEADER")
	systemHeaderRootFile.setOverwrite(True)
	systemHeaderRootFile.setEnabled(True)

	systemHeaderCommonFile = harmonySystemComponent.createFileSymbol(None, None)
	systemHeaderCommonFile.setSourcePath("system/system_common.h")
	systemHeaderCommonFile.setOutputName("system_common.h")
	systemHeaderCommonFile.setDestPath("system/")
	systemHeaderCommonFile.setProjectPath("config/" + configName + "/system/")
	systemHeaderCommonFile.setType("HEADER")
	systemHeaderCommonFile.setOverwrite(True)
	systemHeaderCommonFile.setEnabled(True)

	systemHeaderModuleFile = harmonySystemComponent.createFileSymbol(None, None)
	systemHeaderModuleFile.setSourcePath("system/system_module.h")
	systemHeaderModuleFile.setOutputName("system_module.h")
	systemHeaderModuleFile.setDestPath("system/")
	systemHeaderModuleFile.setProjectPath("config/" + configName + "/system/")
	systemHeaderModuleFile.setType("HEADER")
	systemHeaderModuleFile.setOverwrite(True)
	systemHeaderModuleFile.setEnabled(True)


