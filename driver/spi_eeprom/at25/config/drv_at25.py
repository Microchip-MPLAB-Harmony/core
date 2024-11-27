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
#### Component ####
################################################################################

at25MemoryInterruptEnable = None

global sort_alphanumeric

drv_at25_mcc_helpkeyword = "mcc_h3_drv_at25_configurations"

global at25SymChipSelectPin
global at25SymHoldPin
global at25SymWriteProtectPin

def handleMessage(messageID, args):

    result_dict = {}

    if (messageID == "REQUEST_CONFIG_PARAMS"):
        if args.get("localComponentID") != None:
            result_dict = Database.sendMessage(args["localComponentID"], "SPI_MASTER_MODE", {"isReadOnly":True, "isEnabled":True})
            result_dict = Database.sendMessage(args["localComponentID"], "SPI_MASTER_INTERRUPT_MODE", {"isReadOnly":True, "isEnabled":True})
            result_dict = Database.sendMessage(args["localComponentID"], "SPI_MASTER_HARDWARE_CS", {"isReadOnly":True, "isEnabled":False})

    elif (messageID == "AT25_CONFIG_HW_IO"):
        global at25SymChipSelectPin
        global at25SymHoldPin
        global at25SymWriteProtectPin
        
        pinFn, pinId, enable = args['config']
        component = "drv_at25"

        configurePin = False
        if pinFn == "WP":
            symbolInstance = at25SymWriteProtectPin
            symbolId = "DRV_AT25_WRITE_PROTECT_PIN"
            configurePin = True
        elif pinFn == "HOLD":
            symbolInstance = at25SymHoldPin
            symbolId = "DRV_AT25_HOLD_PIN"
            configurePin = True
        elif pinFn == "CS":
            symbolInstance = at25SymChipSelectPin
            symbolId = "DRV_AT25_CHIP_SELECT_PIN"
            configurePin = True
        else:
            result_dict = {"Result": "Fail - AT25 pin is not detected {}".format(pinFn)}

        if configurePin == True:
            res = False
            if enable == True:
                keyCount = symbolInstance.getKeyCount()
                for index in range(0, keyCount):
                    symbolKey = symbolInstance.getKey(index)
                    if pinId.upper() == symbolKey.split("_")[-1].upper():
                        res = symbolInstance.setValue(index)
                        break
            else:
                res = Database.clearSymbolValue(component, symbolId)
            
            if res == True:
                result_dict = {"Result": "Success"}
            else:
                result_dict = {"Result": "Fail"}
            
    return result_dict

def sort_alphanumeric(l):
    import re
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ]
    return sorted(l, key = alphanum_key)

def at25SetMemoryDependency(symbol, event):

    symbol.setVisible(event["value"])

def instantiateComponent(at25Component):
    global at25MemoryInterruptEnable

    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Port Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_PORTS", {"isEnabled":True})

    at25SymNumInst = at25Component.createIntegerSymbol("DRV_AT25_NUM_INSTANCES", None)
    at25SymNumInst.setLabel("Number of Instances")
    at25SymNumInst.setDefaultValue(1)
    at25SymNumInst.setVisible(False)

    #at25SymIndex = at25Component.createIntegerSymbol("DRV_AT25_INDEX", None)
    #at25SymIndex.setLabel("Driver Index")
    #at25SymIndex.setVisible(True)
    #at25SymIndex.setDefaultValue(0)
    #at25SymIndex.setReadOnly(True)

    at25PLIB = at25Component.createStringSymbol("DRV_AT25_PLIB", None)
    at25PLIB.setLabel("PLIB Used")
    at25PLIB.setHelp(drv_at25_mcc_helpkeyword)
    at25PLIB.setReadOnly(True)

    at25SymNumClients = at25Component.createIntegerSymbol("DRV_AT25_NUM_CLIENTS", None)
    at25SymNumClients.setLabel("Number of Clients")
    at25SymNumClients.setHelp(drv_at25_mcc_helpkeyword)
    at25SymNumClients.setReadOnly(True)
    at25SymNumClients.setDefaultValue(1)

    at25EEPROMPageSize = at25Component.createIntegerSymbol("EEPROM_PAGE_SIZE", None)
    at25EEPROMPageSize.setLabel("EEPROM Page Size")
    at25EEPROMPageSize.setHelp(drv_at25_mcc_helpkeyword)
    at25EEPROMPageSize.setDefaultValue(256)

    at25EEPROMFlashSize = at25Component.createIntegerSymbol("EEPROM_FLASH_SIZE", None)
    at25EEPROMFlashSize.setLabel("EEPROM Flash Size")
    at25EEPROMFlashSize.setHelp(drv_at25_mcc_helpkeyword)
    at25EEPROMFlashSize.setDefaultValue(262144)

    global at25SymChipSelectPin
    at25SymChipSelectPin = at25Component.createKeyValueSetSymbol("DRV_AT25_CHIP_SELECT_PIN", None)
    at25SymChipSelectPin.setLabel("Chip Select Pin")
    at25SymChipSelectPin.setHelp(drv_at25_mcc_helpkeyword)
    at25SymChipSelectPin.setOutputMode("Key")
    at25SymChipSelectPin.setDisplayMode("Description")

    global at25SymHoldPin
    at25SymHoldPin = at25Component.createKeyValueSetSymbol("DRV_AT25_HOLD_PIN", None)
    at25SymHoldPin.setLabel("Hold Pin")
    at25SymHoldPin.setHelp(drv_at25_mcc_helpkeyword)
    at25SymHoldPin.setOutputMode("Key")
    at25SymHoldPin.setDisplayMode("Description")

    global at25SymWriteProtectPin
    at25SymWriteProtectPin = at25Component.createKeyValueSetSymbol("DRV_AT25_WRITE_PROTECT_PIN", None)
    at25SymWriteProtectPin.setLabel("Write Protect Pin")
    at25SymWriteProtectPin.setHelp(drv_at25_mcc_helpkeyword)
    at25SymWriteProtectPin.setOutputMode("Key")
    at25SymWriteProtectPin.setDisplayMode("Description")

    availablePinDictionary = {}

    # Send message to core to get available pins
    availablePinDictionary = Database.sendMessage("core", "PIN_LIST", availablePinDictionary)

    for pad in sort_alphanumeric(availablePinDictionary.values()):
        key = "SYS_PORT_PIN_" + pad
        value = list(availablePinDictionary.keys())[list(availablePinDictionary.values()).index(pad)]
        description = pad
        at25SymChipSelectPin.addKey(key, value, description)
        at25SymHoldPin.addKey(key, value, description)
        at25SymWriteProtectPin.addKey(key, value, description)

    at25SymHoldPin.addKey("SYS_PORT_PIN_NONE", "-1", "None")
    at25SymWriteProtectPin.addKey("SYS_PORT_PIN_NONE", "-1", "None")

    at25SymPinConfigComment = at25Component.createCommentSymbol("DRV_AT25_PINS_CONFIG_COMMENT", None)
    at25SymPinConfigComment.setLabel("***Above selected pins must be configured as GPIO Output in Pin Manager***")

    ##### Do not modify below symbol names as they are used by Memory Driver #####

    at25MemoryDriver = at25Component.createBooleanSymbol("DRV_MEMORY_CONNECTED", None)
    at25MemoryDriver.setLabel("Memory Driver Connected")
    at25MemoryDriver.setVisible(False)

    at25MemoryInterruptEnable = at25Component.createBooleanSymbol("INTERRUPT_ENABLE", None)
    at25MemoryInterruptEnable.setLabel("at25 Interrupt Enable")
    at25MemoryInterruptEnable.setVisible(False)
    at25MemoryInterruptEnable.setReadOnly(True)

    at25MemoryEraseEnable = at25Component.createBooleanSymbol("ERASE_ENABLE", None)
    at25MemoryEraseEnable.setLabel("at25 Erase Enable")
    at25MemoryEraseEnable.setVisible(False)

    at25MemoryStartAddr = at25Component.createHexSymbol("START_ADDRESS", None)
    at25MemoryStartAddr.setLabel("AT25 EEPROM Start Address")
    at25MemoryStartAddr.setHelp(drv_at25_mcc_helpkeyword)
    at25MemoryStartAddr.setDefaultValue(0x0000000)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    at25HeaderFile = at25Component.createFileSymbol("AT25_HEADER", None)
    at25HeaderFile.setSourcePath("driver/spi_eeprom/at25/drv_at25.h")
    at25HeaderFile.setOutputName("drv_at25.h")
    at25HeaderFile.setDestPath("driver/at25/")
    at25HeaderFile.setProjectPath("config/" + configName + "/driver/at25/")
    at25HeaderFile.setType("HEADER")
    at25HeaderFile.setOverwrite(True)

    at25SymHeaderDefFile = at25Component.createFileSymbol("DRV_AT25_DEF", None)
    at25SymHeaderDefFile.setSourcePath("driver/spi_eeprom/at25/drv_at25_definitions.h")
    at25SymHeaderDefFile.setOutputName("drv_at25_definitions.h")
    at25SymHeaderDefFile.setDestPath("driver/at25")
    at25SymHeaderDefFile.setProjectPath("config/" + configName + "/driver/at25/")
    at25SymHeaderDefFile.setType("HEADER")
    at25SymHeaderDefFile.setOverwrite(True)

    at25SourceFile = at25Component.createFileSymbol("AT25_SOURCE", None)
    at25SourceFile.setSourcePath("driver/spi_eeprom/at25/src/drv_at25.c.ftl")
    at25SourceFile.setOutputName("drv_at25.c")
    at25SourceFile.setDestPath("driver/at25/src")
    at25SourceFile.setProjectPath("config/" + configName + "/driver/at25/")
    at25SourceFile.setType("SOURCE")
    at25SourceFile.setOverwrite(True)
    at25SourceFile.setMarkup(True)

    at25AsyncSymHeaderLocalFile = at25Component.createFileSymbol("DRV_AT25_HEADER_LOCAL", None)
    at25AsyncSymHeaderLocalFile.setSourcePath("driver/spi_eeprom/at25/src/drv_at25_local.h")
    at25AsyncSymHeaderLocalFile.setOutputName("drv_at25_local.h")
    at25AsyncSymHeaderLocalFile.setDestPath("driver/at25/src")
    at25AsyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/at25/")
    at25AsyncSymHeaderLocalFile.setType("SOURCE")
    at25AsyncSymHeaderLocalFile.setOverwrite(True)

    at25SystemDefFile = at25Component.createFileSymbol("AT25_DEF", None)
    at25SystemDefFile.setType("STRING")
    at25SystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    at25SystemDefFile.setSourcePath("driver/spi_eeprom/at25/templates/system/definitions.h.ftl")
    at25SystemDefFile.setMarkup(True)

    at25SymSystemDefObjFile = at25Component.createFileSymbol("DRV_AT25_SYSTEM_DEF_OBJECT", None)
    at25SymSystemDefObjFile.setType("STRING")
    at25SymSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    at25SymSystemDefObjFile.setSourcePath("driver/spi_eeprom/at25/templates/system/definitions_objects.h.ftl")
    at25SymSystemDefObjFile.setMarkup(True)

    at25SymSystemConfigFile = at25Component.createFileSymbol("DRV_AT25_CONFIGIRUTION", None)
    at25SymSystemConfigFile.setType("STRING")
    at25SymSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    at25SymSystemConfigFile.setSourcePath("driver/spi_eeprom/at25/templates/system/configuration.h.ftl")
    at25SymSystemConfigFile.setMarkup(True)

    at25SymSystemInitDataFile = at25Component.createFileSymbol("DRV_AT25_INIT_DATA", None)
    at25SymSystemInitDataFile.setType("STRING")
    at25SymSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    at25SymSystemInitDataFile.setSourcePath("driver/spi_eeprom/at25/templates/system/initialize_data.c.ftl")
    at25SymSystemInitDataFile.setMarkup(True)

    at25SystemInitFile = at25Component.createFileSymbol("AT25_INIT", None)
    at25SystemInitFile.setType("STRING")
    at25SystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    at25SystemInitFile.setSourcePath("driver/spi_eeprom/at25/templates/system/initialize.c.ftl")
    at25SystemInitFile.setMarkup(True)

def onAttachmentConnected(source, target):

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_at25_SPI_dependency" :
        plibUsed = localComponent.getSymbolByID("DRV_AT25_PLIB")
        plibUsed.clearValue()
        at25PlibId = remoteID.upper()
        plibUsed.setValue(at25PlibId.upper())

def onAttachmentDisconnected(source, target):

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_at25_SPI_dependency":
        plibUsed = localComponent.getSymbolByID("DRV_AT25_PLIB")
        plibUsed.clearValue()
        at25PlibId = remoteID.upper()

        dummyDict = {}
        dummyDict = Database.sendMessage(remoteID, "SPI_MASTER_MODE", {"isReadOnly":False})
        dummyDict = Database.sendMessage(remoteID, "SPI_MASTER_INTERRUPT_MODE", {"isReadOnly":False})
        dummyDict = Database.sendMessage(remoteID, "SPI_MASTER_HARDWARE_CS", {"isReadOnly":False})

def destroyComponent(at25Component):
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_PORTS", {"isEnabled":False})