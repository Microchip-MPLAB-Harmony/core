################################################################################
#### Global Variables ####
################################################################################

################################################################################
#### Business Logic ####
################################################################################

################################################################################
#### Component ####
################################################################################
def instantiateComponent(intComponent):
    Log.writeInfoMessage("Running Interrupt System Service ")

    useSysInt = intComponent.createBooleanSymbol("USE_SYS_INT", None)
    useSysInt.setLabel("Use Interrupt System Service?")
    useSysInt.setDescription("Enables Interrupt System Service")
    useSysInt.setDefaultValue(True)
    useSysInt.setVisible(False)

    useSysIntComment = intComponent.createCommentSymbol("USE_SYS_INT_COMMENT", None)
    useSysIntComment.setLabel("*** Configure Interrupts using Interrupt Manager ***")

    ############################################################################
    #### Code Generation ####
    ############################################################################
    configName = Variables.get("__CONFIGURATION_NAME")

    intHeaderFile = intComponent.createFileSymbol(None, None)
    intHeaderFile.setSourcePath("system/int/sys_int.h")
    intHeaderFile.setOutputName("sys_int.h")
    intHeaderFile.setDestPath("system/int/")
    intHeaderFile.setProjectPath("config/" + configName + "/system/int/")
    intHeaderFile.setType("HEADER")

    intHeaderMappingFile = intComponent.createFileSymbol(None, None)
    intHeaderMappingFile.setSourcePath("system/int/sys_int_mapping.h")
    intHeaderMappingFile.setOutputName("sys_int_mapping.h")
    intHeaderMappingFile.setDestPath("system/int/")
    intHeaderMappingFile.setProjectPath("config/" + configName + "/system/int/")
    intHeaderMappingFile.setType("HEADER")

    intSourceFile = intComponent.createFileSymbol(None, None)
    intSourceFile.setSourcePath("system/int/src/sys_int.c")
    intSourceFile.setOutputName("sys_int.c")
    intSourceFile.setDestPath("system/int/src/")
    intSourceFile.setProjectPath("config/" + configName + "/system/int/")
    intSourceFile.setType("SOURCE")

    intSystemDefFile = intComponent.createFileSymbol(None, None)
    intSystemDefFile.setType("STRING")
    intSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    intSystemDefFile.setSourcePath("system/int/templates/system/system_definitions.h.ftl")
    intSystemDefFile.setMarkup(True)

    # Adding System Service common files to the project
    Database.clearSymbolValue("harmonyCore", "SYSTEM_SERVICE_NEEDED")
    Database.setSymbolValue("harmonyCore", "SYSTEM_SERVICE_NEEDED", True, 2)