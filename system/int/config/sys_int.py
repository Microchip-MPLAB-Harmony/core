
################################################################################
#### Business Logic ####
################################################################################

def genIntHeaderFile(symbol, event):
    symbol.setEnabled(event["value"])

def genIntHeaderMappingFile(symbol, event):
    symbol.setEnabled(event["value"])

def genIntSourceFile(symbol, event):
    symbol.setEnabled(event["value"])

def genIntSystemDefFile(symbol, event):
    symbol.setEnabled(event["value"])

############################################################################
#### Code Generation ####
############################################################################
genSysIntCommonFiles = harmonyCoreComponent.createBooleanSymbol("ENABLE_SYS_INT", coreMenu)
genSysIntCommonFiles.setLabel("Enable System Interrupt")
genSysIntCommonFiles.setDefaultValue(False)

intHeaderFile = harmonyCoreComponent.createFileSymbol("INT_HEADER", None)
intHeaderFile.setSourcePath("system/int/sys_int.h")
intHeaderFile.setOutputName("sys_int.h")
intHeaderFile.setDestPath("system/int/")
intHeaderFile.setProjectPath("config/" + configName + "/system/int/")
intHeaderFile.setType("HEADER")
intHeaderFile.setOverwrite(True)
intHeaderFile.setEnabled(False)
intHeaderFile.setDependencies(genIntHeaderFile, ["ENABLE_SYS_INT"])

intHeaderMappingFile = harmonyCoreComponent.createFileSymbol("INT_MAPPING", None)
intHeaderMappingFile.setSourcePath("system/int/sys_int_mapping.h")
intHeaderMappingFile.setOutputName("sys_int_mapping.h")
intHeaderMappingFile.setDestPath("system/int/")
intHeaderMappingFile.setProjectPath("config/" + configName + "/system/int/")
intHeaderMappingFile.setType("HEADER")
intHeaderMappingFile.setOverwrite(True)
intHeaderMappingFile.setEnabled(False)
intHeaderMappingFile.setDependencies(genIntHeaderMappingFile, ["ENABLE_SYS_INT"])

intSourceFile = harmonyCoreComponent.createFileSymbol("INT_SOURCE", None)
intSourceFile.setSourcePath("system/int/src/sys_int.c")
intSourceFile.setOutputName("sys_int.c")
intSourceFile.setDestPath("system/int/src/")
intSourceFile.setProjectPath("config/" + configName + "/system/int/")
intSourceFile.setType("SOURCE")
intSourceFile.setOverwrite(True)
intSourceFile.setEnabled(False)
intSourceFile.setDependencies(genIntSourceFile, ["ENABLE_SYS_INT"])

intSystemDefFile = harmonyCoreComponent.createFileSymbol("INT_DEF", None)
intSystemDefFile.setType("STRING")
intSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
intSystemDefFile.setSourcePath("system/int/templates/system/system_definitions.h.ftl")
intSystemDefFile.setMarkup(True)
intSystemDefFile.setOverwrite(True)
intSystemDefFile.setEnabled(False)
intSystemDefFile.setDependencies(genIntSystemDefFile, ["ENABLE_SYS_INT"])
