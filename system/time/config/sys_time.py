################################################################################
#### Global Variables ####
################################################################################

################################################################################
#### Business Logic ####
################################################################################

################################################################################
#### Component ####
################################################################################
def instantiateComponent(sysTimeComponent):
    Log.writeInfoMessage("Loading System Time Module...")

    sysTimePLIB = sysTimeComponent.createStringSymbol("SYS_TIME_PLIB", None)
    sysTimePLIB.setLabel("PLIB Used")
    sysTimePLIB.setReadOnly(True)
    sysTimePLIB.setDefaultValue("TC0_CH0")
    # Used onDependencyComponentAdd\Remove callbacks to get connected PLIB

    sysTimeObjects = sysTimeComponent.createIntegerSymbol("SYS_TIME_MAX_TIMERS", None)
    sysTimeObjects.setLabel("Number of Clients")
    sysTimeObjects.setMax(50)
    sysTimeObjects.setMin(1)
    sysTimeObjects.setDefaultValue(10)

    sysTimeUnitResolution = sysTimeComponent.createIntegerSymbol("SYS_TIME_RESOLUTION", None)
    sysTimeUnitResolution.setLabel("Time Unit or Resolution in Micro Seconds")
    sysTimeUnitResolution.setMin(1)
    sysTimeUnitResolution.setDefaultValue(100)

    sysTimeUnitResolutionComment = sysTimeComponent.createCommentSymbol("SYS_TIME_RESOLUTION_COMMENT", None)
    sysTimeUnitResolutionComment.setLabel("**** Check The H/W Timer Connected For The Possible Timer Resolution ****")

    ############################################################################
    #### Code Generation ####
    ############################################################################
    configName = Variables.get("__CONFIGURATION_NAME")

    sysTimeHeaderFile = sysTimeComponent.createFileSymbol("SYS_TIME_HEADER", None)
    sysTimeHeaderFile.setSourcePath("system/time/sys_time.h")
    sysTimeHeaderFile.setOutputName("sys_time.h")
    sysTimeHeaderFile.setDestPath("system/time/")
    sysTimeHeaderFile.setProjectPath("config/" + configName + "/system/time/")
    sysTimeHeaderFile.setType("HEADER")
    sysTimeHeaderFile.setOverwrite(True)

    sysTimeHeaderDefFile = sysTimeComponent.createFileSymbol("SYS_TIME_HEADER_DEF", None)
    sysTimeHeaderDefFile.setSourcePath("system/time/sys_time_definitions.h")
    sysTimeHeaderDefFile.setOutputName("sys_time_definitions.h")
    sysTimeHeaderDefFile.setDestPath("system/time/")
    sysTimeHeaderDefFile.setProjectPath("config/" + configName + "/system/time/")
    sysTimeHeaderDefFile.setType("HEADER")
    sysTimeHeaderDefFile.setOverwrite(True)

    sysTimeSourceFile = sysTimeComponent.createFileSymbol("SYS_TIME_SOURCE", None)
    sysTimeSourceFile.setSourcePath("system/time/src/sys_time.c")
    sysTimeSourceFile.setOutputName("sys_time.c")
    sysTimeSourceFile.setDestPath("system/time/src")
    sysTimeSourceFile.setProjectPath("config/" + configName + "/system/time/")
    sysTimeSourceFile.setType("SOURCE")
    sysTimeSourceFile.setOverwrite(True)

    sysTimeHeaderLocalFile = sysTimeComponent.createFileSymbol("SYS_TIME_LOCAL", None)
    sysTimeHeaderLocalFile.setSourcePath("system/time/src/sys_time_local.h")
    sysTimeHeaderLocalFile.setOutputName("sys_time_local.h")
    sysTimeHeaderLocalFile.setDestPath("system/time/src")
    sysTimeHeaderLocalFile.setProjectPath("config/" + configName + "/system/time/")
    sysTimeHeaderLocalFile.setType("SOURCE")
    sysTimeHeaderLocalFile.setOverwrite(True)

    sysTimeSystemDefFile = sysTimeComponent.createFileSymbol("SYS_TIME_DEF", None)
    sysTimeSystemDefFile.setType("STRING")
    sysTimeSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sysTimeSystemDefFile.setSourcePath("system/time/templates/system/system_definitions.h.ftl")
    sysTimeSystemDefFile.setMarkup(True)

    sysTimeSystemDefObjFile = sysTimeComponent.createFileSymbol("SYS_TIME_DEF_OBJ", None)
    sysTimeSystemDefObjFile.setType("STRING")
    sysTimeSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    sysTimeSystemDefObjFile.setSourcePath("system/time/templates/system/system_definitions_objects.h.ftl")
    sysTimeSystemDefObjFile.setMarkup(True)

    sysTimeSystemConfigFile = sysTimeComponent.createFileSymbol("SYS_TIME_CONFIG", None)
    sysTimeSystemConfigFile.setType("STRING")
    sysTimeSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION")
    sysTimeSystemConfigFile.setSourcePath("system/time/templates/system/system_config.h.ftl")
    sysTimeSystemConfigFile.setMarkup(True)

    sysTimeSystemInitDataFile = sysTimeComponent.createFileSymbol("SYS_TIME_INIT_DATA", None)
    sysTimeSystemInitDataFile.setType("STRING")
    sysTimeSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYSTEM_INITIALIZATION")
    sysTimeSystemInitDataFile.setSourcePath("system/time/templates/system/system_initialize_data.c.ftl")
    sysTimeSystemInitDataFile.setMarkup(True)

    sysTimeSystemInitFile = sysTimeComponent.createFileSymbol("SYS_TIME_INIT", None)
    sysTimeSystemInitFile.setType("STRING")
    sysTimeSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_INITIALIZE_SYSTEM_SERVICES")
    sysTimeSystemInitFile.setSourcePath("system/time/templates/system/system_initialize.c.ftl")
    sysTimeSystemInitFile.setMarkup(True)

############################################################################
#### Dependency ####
############################################################################
def onDependentComponentAdded(sys_time, id, time):

    if id == "sys_time_TC_dependency" :
        plibUsed = sys_time.getSymbolByID("SYS_TIME_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(time.getID().upper() + "_CH0", 2)

        time.clearSymbolValue("TC0_ENABLE")
        time.setSymbolValue("TC0_ENABLE", True, 2)
        time.clearSymbolValue("TC0_OPERATING_MODE")
        time.setSymbolValue("TC0_OPERATING_MODE", "Timer", 2)