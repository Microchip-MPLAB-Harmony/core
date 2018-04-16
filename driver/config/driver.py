

################################################################################
#### Business Logic ####
################################################################################
def genDriverHeaderRootFile(symbol, event):
    symbol.setEnabled(event["value"])

def genDriverHeaderCommonFile(symbol, event):
    symbol.setEnabled(event["value"])

############################################################################
#### Code Generation ####
############################################################################
genDriverCommonFiles = harmonyCoreComponent.createBooleanSymbol("ENABLE_DRV_COMMON", coreMenu)
genDriverCommonFiles.setLabel("Generate Harmony Driver Common Files")
genDriverCommonFiles.setDefaultValue(False)
	
driverHeaderRootFile = harmonyCoreComponent.createFileSymbol("DRIVER_ROOT", None)
driverHeaderRootFile.setSourcePath("driver/driver.h")
driverHeaderRootFile.setOutputName("driver.h")
driverHeaderRootFile.setDestPath("driver/")
driverHeaderRootFile.setProjectPath("config/" + configName + "/driver/")
driverHeaderRootFile.setType("HEADER")
driverHeaderRootFile.setOverwrite(True)
driverHeaderRootFile.setEnabled(False)
driverHeaderRootFile.setDependencies(genDriverHeaderRootFile, ["ENABLE_DRV_COMMON"])

    
driverHeaderCommonFile = harmonyCoreComponent.createFileSymbol("DRIVER_COMMON", None)
driverHeaderCommonFile.setSourcePath("driver/driver_common.h")
driverHeaderCommonFile.setOutputName("driver_common.h")
driverHeaderCommonFile.setDestPath("driver/")
driverHeaderCommonFile.setProjectPath("config/" + configName + "/driver/")
driverHeaderCommonFile.setType("HEADER")
driverHeaderCommonFile.setOverwrite(True)
driverHeaderCommonFile.setEnabled(False)
driverHeaderCommonFile.setDependencies(genDriverHeaderCommonFile, ["ENABLE_DRV_COMMON"])




