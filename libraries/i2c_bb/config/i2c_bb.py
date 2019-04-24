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


def onAttachmentConnected(source, target):
    global i2cbbTimerDep

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if localComponent.getID() == "i2c_bb" and connectID == "TMR":
        i2cbbTimerDep.setValue(remoteID.upper())



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

def instantiateComponent(i2cbbComponent):

    global i2cbbInstanceName
    global i2cbbTimerDep

    i2cbbInstanceName = i2cbbComponent.createStringSymbol("I2CBB_INSTANCE_NAME", None)
    i2cbbInstanceName.setVisible(False)
    i2cbbInstanceName.setDefaultValue(i2cbbComponent.getID().upper())

    availablePinDictionary = {}

    availablePinDictionary = Database.sendMessage("core", "I2C_BB", availablePinDictionary)

    print("Running " + i2cbbInstanceName.getValue())

    #operation mode
    opModeValues = ["MASTER"]

    i2cbbOpMode = i2cbbComponent.createComboSymbol("I2CBB_OPMODE", None, opModeValues)

    i2cbbOpMode.setLabel("I2CBB Operation Mode")
    i2cbbOpMode.setDefaultValue("MASTER")
    i2cbbOpMode.setReadOnly(True)
    
    res = Database.activateComponents(["HarmonyCore"])
    
    # Enable "Enable System Ports" option in MHC
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS") == False):
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS", True)

    # Clock speed
    i2cbbSymClockSpeed = i2cbbComponent.createIntegerSymbol("I2C_CLOCK_SPEED", None)
    i2cbbSymClockSpeed.setLabel("I2CBB_Clock Speed")
    i2cbbSymClockSpeed.setDefaultValue(1000)
    i2cbbSymClockSpeed.setMax(50000)

    i2cbbTimerDep = i2cbbComponent.createStringSymbol("I2CBB_CONNECTED_TIMER", None)
    i2cbbTimerDep.setVisible(False)
    i2cbbTimerDep.setDefaultValue("None")


    i2cbbSymDataPin = i2cbbComponent.createKeyValueSetSymbol("I2CBB_SDA_PIN", None)
    i2cbbSymDataPin.setLabel("I2CBB Data Pin")
    i2cbbSymDataPin.setDefaultValue(0)
    i2cbbSymDataPin.setOutputMode("Key")
    i2cbbSymDataPin.setDisplayMode("Description")

    i2cbbSymClockPin = i2cbbComponent.createKeyValueSetSymbol("I2CBB_SCL_PIN", None)
    i2cbbSymClockPin.setLabel("I2CBB Clock Pin")
    i2cbbSymClockPin.setDefaultValue(0)
    i2cbbSymClockPin.setOutputMode("Key")
    i2cbbSymClockPin.setDisplayMode("Description")

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
