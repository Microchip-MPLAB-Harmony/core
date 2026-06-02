# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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
global sort_alphanumeric

i2c_bb_mcc_helpkeyword = "mcc_h3_i2c_bb_configurations"

def onAttachmentConnected(source, target):
    global i2cbbTimerDep
    global i2cbbTimerClockFreq
    
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]
        
    if localComponent.getID() == "i2c_bb" and connectID == "TMR":
        i2cbbTimerDep.setValue(remoteID.upper())
        return_dict = dict()
        return_dict = Database.sendMessage(remoteID, "TIMER_FREQ_GET", {"ID": "i2c_bb","timer_ch": "0"})
        timer_freq = return_dict["TIMER_FREQ"]
        i2cbbTimerClockFreq.setValue(timer_freq)

def onAttachmentDisconnected(source, target):
    global i2cbbTimerDep

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if localComponent.getID() == "i2c_bb" and connectID == "TMR":
        i2cbbTimerDep.clearValue(remoteID.upper())


def sort_alphanumeric(l):
    import re
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ]
    return sorted(l, key = alphanum_key)

global i2cbbInstanceName
global i2cbbSymDataPin
global i2cbbSymClockPin

def handleMessage(messageID, args):
    global i2cbbTimerClockFreq
    global i2cbbInstanceName
    global i2cbbSymDataPin
    global i2cbbSymClockPin

    retDict = {}
    # print("I2C_BB handleMessage: {} args: {}".format(messageID, args))
    
    if (messageID == "TIMER_FREQUENCY"):
        if 'CHANNEL_ID' in args:
            if((args["CHANNEL_ID"] == 0)):
                i2cbbTimerClockFreq.setValue(args["frequency"])
        else:
            i2cbbTimerClockFreq.setValue(args["frequency"])

    elif (messageID == "I2CBB_CONFIG_HW_IO"):
        component = i2cbbInstanceName.getValue().lower()
        signalId, pinId, enable = args['config']

        configurePin = False
        if signalId.lower() == "sda":
            symbolInstance = i2cbbSymDataPin
            symbolId = "I2CBB_SDA_PIN"
            configurePin = True
        elif signalId.lower() == "scl":
            symbolInstance = i2cbbSymClockPin
            symbolId = "I2CBB_SCL_PIN"
            configurePin = True
        else:
            retDict = {"Result": "Fail"}

        if configurePin == True:
            res = False
            if enable == True:
                keyCount = symbolInstance.getKeyCount()
                for index in range(0, keyCount):
                    symbolKey = symbolInstance.getKey(index)
                    if pinId.upper() == symbolKey.upper():
                        res = symbolInstance.setValue(index)
                        break
            else:
                res = Database.clearSymbolValue(component, symbolId)
            
            if res == True:
                retDict = {"Result": "Success"}
            else:
                retDict = {"Result": "Fail"}

    return retDict

def instantiateComponent(i2cbbComponent):

    global i2cbbInstanceName
    global i2cbbTimerDep
    global i2cbbTimerClockFreq

    i2cbbInstanceName = i2cbbComponent.createStringSymbol("I2CBB_INSTANCE_NAME", None)
    i2cbbInstanceName.setVisible(False)
    i2cbbInstanceName.setDefaultValue(i2cbbComponent.getID().upper())


    print("Running " + i2cbbInstanceName.getValue())

    #operation mode
    opModeValues = ["MASTER"]

    i2cbbOpMode = i2cbbComponent.createComboSymbol("I2CBB_OPMODE", None, opModeValues)
    i2cbbOpMode.setLabel("I2CBB Operation Mode")
    i2cbbOpMode.setHelp(i2c_bb_mcc_helpkeyword)
    i2cbbOpMode.setDefaultValue("MASTER")
    i2cbbOpMode.setReadOnly(True)

    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony System Port Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_PORTS", {"isEnabled":True})

    # Clock speed
    i2cbbSymClockSpeed = i2cbbComponent.createIntegerSymbol("I2C_CLOCK_SPEED", None)
    i2cbbSymClockSpeed.setLabel("I2CBB_Clock Speed")
    i2cbbSymClockSpeed.setHelp(i2c_bb_mcc_helpkeyword)
    i2cbbSymClockSpeed.setDefaultValue(1000)
    i2cbbSymClockSpeed.setMax(50000)

    i2cbbTimerDep = i2cbbComponent.createStringSymbol("I2CBB_CONNECTED_TIMER", None)
    i2cbbTimerDep.setVisible(False)
    i2cbbTimerDep.setDefaultValue("None")

    i2cbbTimerClockFreq = i2cbbComponent.createIntegerSymbol("I2CBB_CONNECTED_TIMER_FRQUENCY", None)
    i2cbbTimerClockFreq.setVisible(False)
    i2cbbTimerClockFreq.setDefaultValue(0)

    global i2cbbSymDataPin
    i2cbbSymDataPin = i2cbbComponent.createKeyValueSetSymbol("I2CBB_SDA_PIN", None)
    i2cbbSymDataPin.setLabel("I2CBB Data Pin")
    i2cbbSymDataPin.setHelp(i2c_bb_mcc_helpkeyword)
    i2cbbSymDataPin.setDefaultValue(0)
    i2cbbSymDataPin.setOutputMode("Key")
    i2cbbSymDataPin.setDisplayMode("Description")

    global i2cbbSymClockPin
    i2cbbSymClockPin = i2cbbComponent.createKeyValueSetSymbol("I2CBB_SCL_PIN", None)
    i2cbbSymClockPin.setLabel("I2CBB Clock Pin")
    i2cbbSymClockPin.setHelp(i2c_bb_mcc_helpkeyword)
    i2cbbSymClockPin.setDefaultValue(0)
    i2cbbSymClockPin.setOutputMode("Key")
    i2cbbSymClockPin.setDisplayMode("Description")

    #I2C Forced Write API Inclusion
    i2cbbSymForcedWriteAPIGen = i2cbbComponent.createBooleanSymbol("I2C_INCLUDE_FORCED_WRITE_API", None)
    i2cbbSymForcedWriteAPIGen.setLabel("Include Force Write I2C Function (Master Mode Only - Ignore NACK from Slave)")
    i2cbbSymForcedWriteAPIGen.setHelp(i2c_bb_mcc_helpkeyword)
    i2cbbSymForcedWriteAPIGen.setDefaultValue(False)
    i2cbbSymForcedWriteAPIGen.setVisible(True)

    availablePinDictionary = {}

    # Send message to core to get available pins
    availablePinDictionary = Database.sendMessage("core", "PIN_LIST", availablePinDictionary)

    for pad in sort_alphanumeric(availablePinDictionary.values()):
        key = pad
        value = list(availablePinDictionary.keys())[list(availablePinDictionary.values()).index(pad)]
        description = pad
        i2cbbSymDataPin.addKey(key, value, description)
        i2cbbSymClockPin.addKey(key, value, description)

    #I2C API Prefix
    i2cbb_API_Prefix = i2cbbComponent.createStringSymbol("I2C_PLIB_API_PREFIX", None)
    i2cbb_API_Prefix.setDefaultValue(i2cbbInstanceName.getValue())
    i2cbb_API_Prefix.setVisible(False)

    i2cbbPinComment = i2cbbComponent.createCommentSymbol("I2C_BB_PINS", None)
    i2cbbPinComment.setLabel("!!! Configure the DATA and CLOCK pin as GPIO INPUT and enable Open Drain under Pin Settings.!!! ")


    REG_MODULE_I2CBB = Register.getRegisterModule("I2CBB")

    configName = Variables.get("__CONFIGURATION_NAME")

    #Master Header
    i2cbbHeaderFile = i2cbbComponent.createFileSymbol("I2CBB_FILE_MASTER_HEADER", None)

    i2cbbHeaderFile.setSourcePath("/libraries/i2c_bb/templates/i2c_bb_local.h.ftl")
    i2cbbHeaderFile.setOutputName("i2c_bb_local.h")
    i2cbbHeaderFile.setDestPath("library/i2cbb/")
    i2cbbHeaderFile.setProjectPath("config/" + configName + "/library/i2cbb/")
    i2cbbHeaderFile.setType("HEADER")
    i2cbbHeaderFile.setMarkup(True)

    #Source File
    i2cbbMainSourceFile = i2cbbComponent.createFileSymbol("I2CBB_FILE_SRC_MAIN", None)

    i2cbbMainSourceFile.setSourcePath("/libraries/i2c_bb/templates/i2c_bb.c.ftl")
    i2cbbMainSourceFile.setOutputName(i2cbbInstanceName.getValue().lower()+".c")
    i2cbbMainSourceFile.setDestPath("library/i2cbb/")
    i2cbbMainSourceFile.setProjectPath("config/" + configName + "/library/i2cbb/")
    i2cbbMainSourceFile.setType("SOURCE")
    i2cbbMainSourceFile.setMarkup(True)

    #Instance Header File
    i2cbbInstHeaderFile = i2cbbComponent.createFileSymbol("I2CBB_FILE_MAIN_HEADER", None)

    i2cbbInstHeaderFile.setSourcePath("/libraries/i2c_bb/templates/i2c_bb.h.ftl")
    i2cbbInstHeaderFile.setOutputName(i2cbbInstanceName.getValue().lower()+".h")
    i2cbbInstHeaderFile.setDestPath("library/i2cbb/")
    i2cbbInstHeaderFile.setProjectPath("config/" + configName + "/library/i2cbb/")
    i2cbbInstHeaderFile.setType("HEADER")
    i2cbbInstHeaderFile.setMarkup(True)

    #I2CBB Initialize
    i2cbbSystemInitFile = i2cbbComponent.createFileSymbol("I2CBB_FILE_SYS_INIT", None)
    i2cbbSystemInitFile.setType("STRING")
    i2cbbSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    i2cbbSystemInitFile.setSourcePath("/libraries/i2c_bb/templates/system/initialization.c.ftl")
    i2cbbSystemInitFile.setMarkup(True)

    #I2CBB definitions header
    i2cbbSystemDefFile = i2cbbComponent.createFileSymbol("I2CBB_FILE_SYS_DEF", None)

    i2cbbSystemDefFile.setType("STRING")
    i2cbbSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    i2cbbSystemDefFile.setSourcePath("/libraries/i2c_bb/templates/system/definitions.h.ftl")
    i2cbbSystemDefFile.setMarkup(True)

def destroyComponent(memoryComponent):
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_PORTS", {"isEnabled":False})