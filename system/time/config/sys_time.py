# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*****************************************************************************"""

################################################################################
#### Global Variables ####
################################################################################

################################################################################
#### Business Logic ####
################################################################################
def sysTimeFrequencyCalculate(symbol, event):
    timeFreq = 1000000/event["value"]
    symbol.setLabel("**** Timer Frequency is " + str(timeFreq) + " Hz ****")

################################################################################
#### Component ####
################################################################################
def instantiateComponent(sysTimeComponent):

    res = Database.activateComponents(["HarmonyCore"])

    Log.writeInfoMessage("Loading System Time Module...")

    # Enable dependent Harmony core components
    Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True, 2)

    sysTimePLIB = sysTimeComponent.createStringSymbol("SYS_TIME_PLIB", None)
    sysTimePLIB.setLabel("PLIB Used")
    sysTimePLIB.setReadOnly(True)
    sysTimePLIB.setDefaultValue("")
    # Used onDependencyComponentAdd\Remove callbacks to get connected PLIB

    sysTimeObjects = sysTimeComponent.createIntegerSymbol("SYS_TIME_MAX_TIMERS", None)
    sysTimeObjects.setLabel("Number of Clients")
    sysTimeObjects.setMax(50)
    sysTimeObjects.setMin(1)
    sysTimeObjects.setDefaultValue(5)

    #sysTimeUnitResolutionComment = sysTimeComponent.createCommentSymbol("SYS_TIME_RESOLUTION_COMMENT", None)
    #sysTimeUnitResolutionComment.setLabel("**** Check The H/W Timer Connected For The Possible Timer Resolution ****")

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
    sysTimeHeaderLocalFile.setType("HEADER")
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

def onAttachmentConnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if (connectID == "sys_time_TMR_dependency"):
        plibUsed = localComponent.getSymbolByID("SYS_TIME_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(remoteID.upper(), 2)

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if (connectID == "sys_time_TMR_dependency"):
        plibUsed = localComponent.getSymbolByID("SYS_TIME_PLIB")
        plibUsed.clearValue()
