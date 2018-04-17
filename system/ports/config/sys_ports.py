
################################################################################
#### Business Logic ####
################################################################################

def genPortsHeaderFile(symbol, event):
    symbol.setEnabled(event["value"])

def genPortsHeaderMappingFile(symbol, event):
    symbol.setEnabled(event["value"])

def genPortsSystemDefFile(symbol, event):
    symbol.setEnabled(event["value"])

############################################################################
#### Code Generation ####
############################################################################
genSysPortsCommonFiles = harmonyCoreComponent.createBooleanSymbol("ENABLE_SYS_PORTS", coreMenu)
genSysPortsCommonFiles.setLabel("Enable System Ports")
genSysPortsCommonFiles.setDefaultValue(False)

portsHeaderFile = harmonyCoreComponent.createFileSymbol("PORTS_HEADER", None)
portsHeaderFile.setSourcePath("system/ports/sys_ports.h")
portsHeaderFile.setOutputName("sys_ports.h")
portsHeaderFile.setDestPath("system/ports/")
portsHeaderFile.setProjectPath("config/" + configName + "/system/ports/")
portsHeaderFile.setType("HEADER")
portsHeaderFile.setOverwrite(True)
portsHeaderFile.setEnabled(False)
portsHeaderFile.setDependencies(genPortsHeaderFile, ["ENABLE_SYS_PORTS"])

portsHeaderMappingFile = harmonyCoreComponent.createFileSymbol("PORTS_MAPPING", None)
portsHeaderMappingFile.setSourcePath("system/ports/sys_ports_mapping.h")
portsHeaderMappingFile.setOutputName("sys_ports_mapping.h")
portsHeaderMappingFile.setDestPath("system/ports/")
portsHeaderMappingFile.setProjectPath("config/" + configName + "/system/ports/")
portsHeaderMappingFile.setType("HEADER")
portsHeaderMappingFile.setOverwrite(True)
portsHeaderMappingFile.setEnabled(False)
portsHeaderMappingFile.setDependencies(genPortsHeaderMappingFile, ["ENABLE_SYS_PORTS"])

portsSystemDefFile = harmonyCoreComponent.createFileSymbol("PORTS_DEF", None)
portsSystemDefFile.setType("STRING")
portsSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
portsSystemDefFile.setSourcePath("system/ports/templates/system/definitions.h.ftl")
portsSystemDefFile.setMarkup(True)
portsSystemDefFile.setOverwrite(True)
portsSystemDefFile.setEnabled(False)
portsSystemDefFile.setDependencies(genPortsSystemDefFile, ["ENABLE_SYS_PORTS"])
