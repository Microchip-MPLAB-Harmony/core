# Driver layer level common content

global enabledDriversCount
enabledDriversCount = 0

def genDriverFiles(driverFile, event):
    global enabledDriversCount
    Log.writeInfoMessage("Called...")

    if event["value"] == True:
        enabledDriversCount += 1
    if event["value"] == False:
        enabledDriversCount -= 1

    driverFile.clearValue()
    if enabledDriversCount > 0:
        Log.writeInfoMessage("Generates...")
        driverFile.setValue(True, 2)
    else:
        driverFile.setValue(False, 2)
        Log.writeInfoMessage("Doesn't Generate...")

def genDrvFile(driverFile, event):
    driverFile.setEnabled(event["value"])

def genDrvCommonFile(driverFile, event):
    driverFile.setEnabled(event["value"])

driverNeeded = harmonyCoreComponent.createBooleanSymbol("DRIVER_NEEDED", None)
driverNeeded.setLabel("Use Harmony Driver Layer Common Files?")
driverNeeded.setDefaultValue(False)
driverNeeded.setReadOnly(True)

genDriverLayerFiles = harmonyCoreComponent.createBooleanSymbol("genDriverCommonFiles", None)
genDriverLayerFiles.setLabel("Generate Harmony Driver Layer Common Files")
genDriverLayerFiles.setDependencies(genDriverFiles, ["DRIVER_NEEDED"])
genDriverLayerFiles.setDefaultValue(False)
genDriverLayerFiles.setVisible(False)

configName = Variables.get("__CONFIGURATION_NAME")

driverHeaderRootFile = harmonyCoreComponent.createFileSymbol(None, None)
driverHeaderRootFile.setSourcePath("driver/driver.h")
driverHeaderRootFile.setOutputName("driver.h")
driverHeaderRootFile.setDestPath("driver/")
driverHeaderRootFile.setProjectPath("config/" + configName + "/driver/")
driverHeaderRootFile.setType("HEADER")
driverHeaderRootFile.setOverwrite(True)
driverHeaderRootFile.setEnabled(False)
driverHeaderRootFile.setDependencies(genDrvFile, ["genDriverCommonFiles"])

driverHeaderCommonFile = harmonyCoreComponent.createFileSymbol(None, None)
driverHeaderCommonFile.setSourcePath("driver/driver_common.h")
driverHeaderCommonFile.setOutputName("driver_common.h")
driverHeaderCommonFile.setDestPath("driver/")
driverHeaderCommonFile.setProjectPath("config/" + configName + "/driver/")
driverHeaderCommonFile.setType("HEADER")
driverHeaderCommonFile.setOverwrite(True)
driverHeaderCommonFile.setEnabled(False)
driverHeaderCommonFile.setDependencies(genDrvCommonFile, ["genDriverCommonFiles"])


