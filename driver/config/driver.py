def instantiateComponent(harmonyDriverComponent):

	# Driver layer level common content
	configName = Variables.get("__CONFIGURATION_NAME")

	driverHeaderRootFile = harmonyDriverComponent.createFileSymbol("DRIVER_ROOT", None)
	driverHeaderRootFile.setSourcePath("driver/driver.h")
	driverHeaderRootFile.setOutputName("driver.h")
	driverHeaderRootFile.setDestPath("driver/")
	driverHeaderRootFile.setProjectPath("config/" + configName + "/driver/")
	driverHeaderRootFile.setType("HEADER")
	driverHeaderRootFile.setOverwrite(True)
	driverHeaderRootFile.setEnabled(True)

	driverHeaderCommonFile = harmonyDriverComponent.createFileSymbol("DRIVER_COMMON", None)
	driverHeaderCommonFile.setSourcePath("driver/driver_common.h")
	driverHeaderCommonFile.setOutputName("driver_common.h")
	driverHeaderCommonFile.setDestPath("driver/")
	driverHeaderCommonFile.setProjectPath("config/" + configName + "/driver/")
	driverHeaderCommonFile.setType("HEADER")
	driverHeaderCommonFile.setOverwrite(True)
	driverHeaderCommonFile.setEnabled(True)


