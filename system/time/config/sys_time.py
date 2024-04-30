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
global sysTimeRemoteComponentId
global sysTimeOperatingMode
global sysTimePLIB

sys_time_mcc_helpkeyword = "mcc_h3_sys_time_configurations"

sysTimeOperatingModeList = ["TICKLESS", "TICK BASED"]

def handleMessage(messageID, args):
    global sysTimePlibCapability
    global sysTimeAchievableTickRateHz
    global sysTimeOperatingMode
    global sysTimeTickRateMs
    global sysTimeRemoteComponentId
    global sysTimeAchievableTickRateMsComment
    global sysTimePLIBErrorComment
    global sysTimeUseSystick

    sysTickRate = {"sys_time_tick_ms" : 0.0}
    sysTimePLIBConfig = dict()
    dummy_dict = dict()

    if sysTimeUseSystick.getValue() == True:
        sysTimeRemoteComponentId.setValue("core")
        
    if messageID == "SYS_TIME_PLIB_CAPABILITY":
        if args["plib_mode"] == "PERIOD_MODE":
            sysTimeOperatingMode.setValue("TICK BASED")
            sysTimeOperatingMode.setReadOnly(True)
        elif args["plib_mode"] == "COMPARE_MODE":
            sysTimeOperatingMode.setValue("TICKLESS")
            sysTimeOperatingMode.setReadOnly(True)
        else:
            sysTimeOperatingMode.setReadOnly(False)

        sysTimeOperatingMode.setVisible(True)

        if sysTimeOperatingMode.getValue() == "TICKLESS":
            sysTimePLIBConfig["plib_mode"] = "SYS_TIME_PLIB_MODE_COMPARE"
            return sysTimePLIBConfig
        else:
            sysTimeTickRateMs.setVisible(True)
            sysTimeAchievableTickRateMsComment.setVisible(True)
            sysTimePLIBConfig["plib_mode"] = "SYS_TIME_PLIB_MODE_PERIOD"
            sysTimePLIBConfig["sys_time_tick_ms"] = float(sysTimeTickRateMs.getValue())
            return sysTimePLIBConfig

    elif messageID == "SYS_TIME_ACHIEVABLE_TICK_RATE_HZ":
        sysTimeAchievableTickRateHz.setValue(args["tick_rate_hz"])

    elif messageID == "SYS_TIME_NOT_SUPPORTED":
        if args["isVisible"] == "True":
            sysTimePLIBErrorComment.setLabel(args["message"])
            sysTimePLIBErrorComment.setVisible(True)
        else:
            sysTimePLIBErrorComment.setVisible(False)

    return dummy_dict

def tickbasedFileGen(symbol, event):
    if event["value"] == "TICK BASED":
       symbol.setEnabled(True)
    else:
       symbol.setEnabled(False)

def ticklessFileGen(symbol, event):
    if event["value"] == "TICKLESS":
       symbol.setEnabled(True)
    else:
       symbol.setEnabled(False)

def sysTimeFrequencyCalculate(symbol, event):
    timeFreq = 1000000/event["value"]
    symbol.setLabel("**** Timer Frequency is " + str(timeFreq) + " Hz ****")

def sysTimeOperatingModeCallback(symbol, event):
    global sysTimeTickRateMs
    dummyDict = {}
    sysTickRate = {"sys_time_tick_ms" : 0.0}

    if sysTimeRemoteComponentId.getValue() != "":
        if event["value"] == "TICKLESS":
            dummyDict = Database.sendMessage(sysTimeRemoteComponentId.getValue(), "SYS_TIME_PLIB_MODE_COMPARE", dummyDict)
        else:
            dummyDict = Database.sendMessage(sysTimeRemoteComponentId.getValue(), "SYS_TIME_PLIB_MODE_PERIOD", dummyDict)
            sysTickRate["sys_time_tick_ms"] = float(sysTimeTickRateMs.getValue())
            dummyDict = Database.sendMessage(sysTimeRemoteComponentId.getValue(), "SYS_TIME_TICK_RATE_CHANGED", sysTickRate)

def sysTimeTickRateCallback(symbol, event):
    global sysTimeRemoteComponentId

    dummyDict = {}
    sysTickRate = {"sys_time_tick_ms" : 0.0}

    if (event["id"] == "SYS_TIME_OPERATING_MODE"):
        if event["value"] == "TICK BASED":
            symbol.setVisible(True)
        else:
            symbol.setVisible(False)

    elif (event["id"] == "SYS_TIME_TICK_RATE_MS"):
        if sysTimeRemoteComponentId.getValue() != "" :
            sysTickRate["sys_time_tick_ms"] = float(symbol.getValue())
            dummyDict = Database.sendMessage(sysTimeRemoteComponentId.getValue(), "SYS_TIME_TICK_RATE_CHANGED", sysTickRate)

def sysTimeAchievableTickRateMsCallback(symbol, event):
    global sysTimeOperatingMode
    global sysTimePLIB

    if (event["id"] == "SYS_TIME_ACHIEVABLE_TICK_RATE_HZ"):
        if event["value"] != 0:
            achievableRateMs =  100000.0 / event["value"]
        else:
            achievableRateMs = 0
        achievableRateMs = achievableRateMs * 1000.0
        symbol.setLabel("Achievable Tick Rate Resolution (ms):" + str(achievableRateMs) + "ms")

    elif (event["id"] == "SYS_TIME_OPERATING_MODE"):
        if event["value"]  == "TICK BASED":
            symbol.setVisible(True)
        else:
            symbol.setVisible(False)

def setVisibility(symbol, event):
    if event["value"]  == "TICK BASED":
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def onSysTimeUseSystickChange(symbol, event):
    global sysTimePLIB

    localComponent = symbol.getComponent()

    if event["id"] == "SYS_TIME_USE_SYSTICK":
        if event["value"] == True:
            localComponent.getSymbolByID("SYS_TIME_REMOTE_COMPONENT_ID").setValue("core")
            localComponent.setDependencyEnabled("sys_time_TMR_dependency", False)
            #Request PLIB to publish it's capabilities
            Database.sendMessage("core", "SYS_TIME_PUBLISH_CAPABILITIES", {"ID":"sys_time"})
            sysTimePLIB.setValue("core")
            sysTimePLIB.setVisible(False)
        else:
            localComponent.getSymbolByID("SYS_TIME_REMOTE_COMPONENT_ID").setValue("")
            localComponent.setDependencyEnabled("sys_time_TMR_dependency", True)
            #Let sys_tick PLIB know that SYS Time no longer uses sys_tick PLIB
            Database.sendMessage("core", "SYS_TIME_PUBLISH_CAPABILITIES", {"ID":"None"})
            if sysTimePLIB.getValue() == "core":
                sysTimePLIB.setValue("")
            sysTimePLIB.setVisible(True)
            sysTimeOperatingMode.setVisible(False)
            sysTimeTickRateMs.setVisible(False)
            sysTimeAchievableTickRateMsComment.setVisible(False)
            sysTimePLIBErrorComment.setVisible(False)
    elif event["id"] == "SYSTICK_BUSY":
        if event["value"] == False:
            localComponent.getSymbolByID("SYS_TIME_USE_SYSTICK").setVisible(True)
        if event["value"] == True:
            if (localComponent.getSymbolByID("SYS_TIME_USE_SYSTICK").getValue() == True):
                localComponent.getSymbolByID("SYS_TIME_USE_SYSTICK").setVisible(True)
            elif (localComponent.getSymbolByID("SYS_TIME_USE_SYSTICK").getValue() == False):
                localComponent.getSymbolByID("SYS_TIME_USE_SYSTICK").setVisible(False)
    else:
        if event["value"] == "BareMetal":
            symbol.setVisible(True)
        else:
            #Let sys_tick PLIB know that SYS Time no longer uses sys_tick PLIB
            if symbol.getValue() == True:
                symbol.setReadOnly(True)
                symbol.setValue(False)
                symbol.setReadOnly(False)
            symbol.setVisible(False)


################################################################################
#### Component ####
################################################################################
def instantiateComponent(sysTimeComponent):
    global sysTimeRemoteComponentId
    global sysTimeOperatingMode
    global sysTimePLIB
    global sysTimeAchievableTickRateHz
    global sysTimePlibCapability
    global sysTimeTickRateMs
    global sysTimeAchievableTickRateMsComment
    global sysTimePLIBErrorComment
    global sysTimeUseSystick

    res = Database.activateComponents(["HarmonyCore"])

    Log.writeInfoMessage("Loading System Time Module...")

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

    systickNode = ATDF.getNode('/avr-tools-device-file/modules/module@[name="SysTick"]')

    sysTimeUseSystick = sysTimeComponent.createBooleanSymbol("SYS_TIME_USE_SYSTICK", None)
    sysTimeUseSystick.setLabel("Use Systick?")
    sysTimeUseSystick.setHelp(sys_time_mcc_helpkeyword)
    sysTimeUseSystick.setDefaultValue(False)
    sysTimeUseSystick.setVisible(systickNode != None and Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") == "BareMetal")
    sysTimeUseSystick.setDependencies(onSysTimeUseSystickChange, ["SYS_TIME_USE_SYSTICK", "HarmonyCore.SELECT_RTOS", "core.SYSTICK_BUSY"])

    sysTimePLIB = sysTimeComponent.createStringSymbol("SYS_TIME_PLIB", None)
    sysTimePLIB.setLabel("PLIB Used")
    sysTimePLIB.setHelp(sys_time_mcc_helpkeyword)
    sysTimePLIB.setReadOnly(True)
    sysTimePLIB.setDefaultValue("")
    # Used onDependencyComponentAdd\Remove callbacks to get connected PLIB

    sysTimeObjects = sysTimeComponent.createIntegerSymbol("SYS_TIME_MAX_TIMERS", None)
    sysTimeObjects.setLabel("Number of Clients")
    sysTimeObjects.setHelp(sys_time_mcc_helpkeyword)
    sysTimeObjects.setMax(50)
    sysTimeObjects.setMin(1)
    sysTimeObjects.setDefaultValue(5)

    sysTimeRemoteComponentId = sysTimeComponent.createStringSymbol("SYS_TIME_REMOTE_COMPONENT_ID", None)
    sysTimeRemoteComponentId.setLabel("Remote component id")
    sysTimeRemoteComponentId.setVisible(False)
    sysTimeRemoteComponentId.setDefaultValue("")

    sysTimeOperatingMode = sysTimeComponent.createComboSymbol("SYS_TIME_OPERATING_MODE", None, sysTimeOperatingModeList)
    sysTimeOperatingMode.setLabel("Operating Mode")
    sysTimeOperatingMode.setHelp(sys_time_mcc_helpkeyword)
    sysTimeOperatingMode.setDefaultValue(sysTimeOperatingModeList[0])
    sysTimeOperatingMode.setVisible(False)
    sysTimeOperatingMode.setDependencies(sysTimeOperatingModeCallback, ["SYS_TIME_OPERATING_MODE"])

    sysTimeTickRateMs = sysTimeComponent.createFloatSymbol("SYS_TIME_TICK_RATE_MS", None)
    sysTimeTickRateMs.setLabel("Tick Rate (ms)")
    sysTimeTickRateMs.setHelp(sys_time_mcc_helpkeyword)
    sysTimeTickRateMs.setMax(5000)          #5 seconds
    sysTimeTickRateMs.setMin(0.1)           #100 usec
    sysTimeTickRateMs.setDefaultValue(1)
    sysTimeTickRateMs.setVisible(False)
    sysTimeTickRateMs.setDependencies(sysTimeTickRateCallback, ["SYS_TIME_OPERATING_MODE", "SYS_TIME_TICK_RATE_MS"])

    sysTimeAchievableTickRateHz = sysTimeComponent.createLongSymbol("SYS_TIME_ACHIEVABLE_TICK_RATE_HZ", None)
    sysTimeAchievableTickRateHz.setDefaultValue(1)
    sysTimeAchievableTickRateHz.setVisible(False)

    sysTimeUseFloatingPtCalculations = sysTimeComponent.createBooleanSymbol("SYS_TIME_USE_FLOATING_POINT_CALCULATIONS", None)
    sysTimeUseFloatingPtCalculations.setLabel("Use Floating Point Calculations?")
    sysTimeUseFloatingPtCalculations.setHelp(sys_time_mcc_helpkeyword)
    sysTimeUseFloatingPtCalculations.setDefaultValue(False)
    sysTimeUseFloatingPtCalculations.setVisible(False)
    sysTimeUseFloatingPtCalculations.setDependencies(setVisibility, ["SYS_TIME_OPERATING_MODE"])

    sysTimeAchievableTickRateMsComment = sysTimeComponent.createCommentSymbol("SYS_TIME_ACHIEVABLEE_TICK_RATE_COMMENT", None)
    sysTimeAchievableTickRateMsComment.setLabel("Achievable Tick Rate Resolution (ms):" + str(sysTimeAchievableTickRateHz.getValue()) + "ms")
    sysTimeAchievableTickRateMsComment.setVisible(False)
    sysTimeAchievableTickRateMsComment.setDependencies(sysTimeAchievableTickRateMsCallback, ["SYS_TIME_OPERATING_MODE" ,"SYS_TIME_ACHIEVABLE_TICK_RATE_HZ"])

    sysTimePLIBErrorComment = sysTimeComponent.createCommentSymbol("SYS_TIME_PLIB_ERROR", None)
    sysTimePLIBErrorComment.setLabel("")
    sysTimePLIBErrorComment.setVisible(False)

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
    sysTimeHeaderDefFile.setSourcePath("system/time/templates/sys_time_definitions.h.ftl")
    sysTimeHeaderDefFile.setOutputName("sys_time_definitions.h")
    sysTimeHeaderDefFile.setDestPath("system/time/")
    sysTimeHeaderDefFile.setProjectPath("config/" + configName + "/system/time/")
    sysTimeHeaderDefFile.setType("HEADER")
    sysTimeHeaderDefFile.setMarkup(True)
    sysTimeHeaderDefFile.setOverwrite(True)

    sysTimeTickbasedSourceFile = sysTimeComponent.createFileSymbol("SYS_TIME_TICK_BASED_SOURCE", None)
    sysTimeTickbasedSourceFile.setSourcePath("system/time/src/tickbased/sys_time.c.ftl")
    sysTimeTickbasedSourceFile.setOutputName("sys_time.c")
    sysTimeTickbasedSourceFile.setDestPath("system/time/src")
    sysTimeTickbasedSourceFile.setProjectPath("config/" + configName + "/system/time/")
    sysTimeTickbasedSourceFile.setType("SOURCE")
    sysTimeTickbasedSourceFile.setOverwrite(True)
    sysTimeTickbasedSourceFile.setMarkup(True)
    sysTimeTickbasedSourceFile.setEnabled((sysTimeOperatingMode.getValue() == "TICK BASED"))
    sysTimeTickbasedSourceFile.setDependencies(tickbasedFileGen, ["SYS_TIME_OPERATING_MODE"])

    sysTimeTicklessSourceFile = sysTimeComponent.createFileSymbol("SYS_TIME_TICKLESS_SOURCE", None)
    sysTimeTicklessSourceFile.setSourcePath("system/time/src/tickless/sys_time.c.ftl")
    sysTimeTicklessSourceFile.setOutputName("sys_time.c")
    sysTimeTicklessSourceFile.setDestPath("system/time/src")
    sysTimeTicklessSourceFile.setProjectPath("config/" + configName + "/system/time/")
    sysTimeTicklessSourceFile.setType("SOURCE")
    sysTimeTicklessSourceFile.setMarkup(True)
    sysTimeTicklessSourceFile.setOverwrite(True)
    sysTimeTicklessSourceFile.setEnabled((sysTimeOperatingMode.getValue() == "TICKLESS"))
    sysTimeTicklessSourceFile.setDependencies(ticklessFileGen, ["SYS_TIME_OPERATING_MODE"])

    sysTimeTickbasedHeaderLocalFile = sysTimeComponent.createFileSymbol("SYS_TIME_TICK_BASED_LOCAL", None)
    sysTimeTickbasedHeaderLocalFile.setSourcePath("system/time/src/tickbased/sys_time_local.h.ftl")
    sysTimeTickbasedHeaderLocalFile.setOutputName("sys_time_local.h")
    sysTimeTickbasedHeaderLocalFile.setDestPath("system/time/src")
    sysTimeTickbasedHeaderLocalFile.setProjectPath("config/" + configName + "/system/time/")
    sysTimeTickbasedHeaderLocalFile.setType("HEADER")
    sysTimeTickbasedHeaderLocalFile.setOverwrite(True)
    sysTimeTickbasedHeaderLocalFile.setMarkup(True)
    sysTimeTickbasedHeaderLocalFile.setEnabled((sysTimeOperatingMode.getValue() == "TICK BASED"))
    sysTimeTickbasedHeaderLocalFile.setDependencies(tickbasedFileGen, ["SYS_TIME_OPERATING_MODE"])

    sysTimeTicklessHeaderLocalFile = sysTimeComponent.createFileSymbol("SYS_TIME_TICKLESS_LOCAL", None)
    sysTimeTicklessHeaderLocalFile.setSourcePath("system/time/src/tickless/sys_time_local.h")
    sysTimeTicklessHeaderLocalFile.setOutputName("sys_time_local.h")
    sysTimeTicklessHeaderLocalFile.setDestPath("system/time/src")
    sysTimeTicklessHeaderLocalFile.setProjectPath("config/" + configName + "/system/time/")
    sysTimeTicklessHeaderLocalFile.setType("HEADER")
    sysTimeTicklessHeaderLocalFile.setOverwrite(True)
    sysTimeTicklessHeaderLocalFile.setEnabled((sysTimeOperatingMode.getValue() == "TICKLESS"))
    sysTimeTicklessHeaderLocalFile.setDependencies(ticklessFileGen, ["SYS_TIME_OPERATING_MODE"])

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
    sysTimeDict = {"ID":"sys_time"}

    if (connectID == "sys_time_TMR_dependency"):
        localComponent.getSymbolByID("SYS_TIME_REMOTE_COMPONENT_ID").setValue(remoteID)
        plibUsed = localComponent.getSymbolByID("SYS_TIME_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(remoteID.upper())
        #Request PLIB to publish it's capabilities
        sysTimeDict = Database.sendMessage(remoteID, "SYS_TIME_PUBLISH_CAPABILITIES", sysTimeDict)

def onAttachmentDisconnected(source, target):
    global sysTimeAchievableTickRateMsComment
    global sysTimeOperatingMode
    global sysTimeTickRateMs
    global sysTimePLIBErrorComment

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if (connectID == "sys_time_TMR_dependency"):
        localComponent.getSymbolByID("SYS_TIME_REMOTE_COMPONENT_ID").setValue("")
        plibUsed = localComponent.getSymbolByID("SYS_TIME_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue("")
        sysTimeOperatingMode.setVisible(False)
        sysTimeTickRateMs.setVisible(False)
        sysTimeAchievableTickRateMsComment.setVisible(False)
        sysTimePLIBErrorComment.setVisible(False)

def destroyComponent(sysTimeComponent):
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})
    if sysTimeComponent.getSymbolByID("SYS_TIME_USE_SYSTICK").getValue() == True:
        # Let the core.systick know that SYS Time is no longer using the systick module
        sysTimeDict = {"ID":"None"}
        sysTimeDict = Database.sendMessage("core", "SYS_TIME_PUBLISH_CAPABILITIES", sysTimeDict)
