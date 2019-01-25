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

at24MemoryInterruptEnable = None

def updateEEPROMAddressLen(symbol, event):
    symObj=event["symbol"]
    if (symObj.getValue() > 256):
        symbol.setValue(2, 2)
    else:
        symbol.setValue(1, 2)


def at24SetMemoryDependency(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def instantiateComponent(at24Component):
    global at24MemoryInterruptEnable

    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True, 1)

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True, 1)

    # Enable "Enable System Ports" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS", True, 1)

    at24SymNumInst = at24Component.createIntegerSymbol("DRV_AT24_NUM_INSTANCES", None)
    at24SymNumInst.setLabel("Number of Instances")
    at24SymNumInst.setDefaultValue(1)
    at24SymNumInst.setVisible(False)

    #at24SymIndex = at24Component.createIntegerSymbol("DRV_AT24_INDEX", None)
    #at24SymIndex.setLabel("Driver Index")
    #at24SymIndex.setVisible(True)
    #at24SymIndex.setDefaultValue(0)
    #at24SymIndex.setReadOnly(True)

    at24PLIB = at24Component.createStringSymbol("DRV_AT24_PLIB", None)
    at24PLIB.setLabel("PLIB Used")
    at24PLIB.setReadOnly(True)

    at24SymNumClients = at24Component.createIntegerSymbol("DRV_AT24_NUM_CLIENTS", None)
    at24SymNumClients.setLabel("Number of Clients")
    at24SymNumClients.setReadOnly(True)
    at24SymNumClients.setDefaultValue(1)

    at24EEPROMPageSize = at24Component.createIntegerSymbol("EEPROM_PAGE_SIZE", None)
    at24EEPROMPageSize.setLabel("EEPROM Page Size")
    at24EEPROMPageSize.setVisible(True)
    at24EEPROMPageSize.setDefaultValue(16)

    at24EEPROMFlashSize = at24Component.createIntegerSymbol("EEPROM_FLASH_SIZE", None)
    at24EEPROMFlashSize.setLabel("EEPROM Flash Size")
    at24EEPROMFlashSize.setVisible(True)
    at24EEPROMFlashSize.setDefaultValue(256)

    at24EEPROMAddressLen = at24Component.createIntegerSymbol("EEPROM_ADDR_LEN", None)
    at24EEPROMAddressLen.setLabel("EEPROM Address Len")
    at24EEPROMAddressLen.setVisible(False)
    at24EEPROMAddressLen.setDefaultValue(2)
    at24EEPROMAddressLen.setDependencies(updateEEPROMAddressLen, ["EEPROM_FLASH_SIZE"])

    at24EEPROMAddress = at24Component.createHexSymbol("I2C_EEPROM_ADDDRESS", None)
    at24EEPROMAddress.setLabel("EEPROM Address")
    at24EEPROMAddress.setVisible(True)
    at24EEPROMAddress.setDefaultValue(0x57)

    ##### Do not modify below symbol names as they are used by Memory Driver #####

    at24MemoryDriver = at24Component.createBooleanSymbol("DRV_MEMORY_CONNECTED", None)
    at24MemoryDriver.setLabel("Memory Driver Connected")
    at24MemoryDriver.setVisible(False)
    at24MemoryDriver.setDefaultValue(False)

    at24MemoryInterruptEnable = at24Component.createBooleanSymbol("INTERRUPT_ENABLE", None)
    at24MemoryInterruptEnable.setLabel("at24 Interrupt Enable")
    at24MemoryInterruptEnable.setVisible(False)
    at24MemoryInterruptEnable.setDefaultValue(False)
    at24MemoryInterruptEnable.setReadOnly(True)

    at24MemoryEraseEnable = at24Component.createBooleanSymbol("ERASE_ENABLE", None)
    at24MemoryEraseEnable.setLabel("at24 Erase Enable")
    at24MemoryEraseEnable.setVisible(False)
    at24MemoryEraseEnable.setDefaultValue(False)

    at24MemoryStartAddr = at24Component.createHexSymbol("START_ADDRESS", None)
    at24MemoryStartAddr.setLabel("AT24 EEPROM Start Address")
    at24MemoryStartAddr.setVisible(True)
    at24MemoryStartAddr.setDefaultValue(0x0000000)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    at24HeaderFile = at24Component.createFileSymbol("AT24_HEADER", None)
    at24HeaderFile.setSourcePath("driver/i2c_eeprom/at24/drv_at24.h")
    at24HeaderFile.setOutputName("drv_at24.h")
    at24HeaderFile.setDestPath("driver/at24/")
    at24HeaderFile.setProjectPath("config/" + configName + "/driver/at24/")
    at24HeaderFile.setType("HEADER")
    at24HeaderFile.setOverwrite(True)

    at24SymHeaderDefFile = at24Component.createFileSymbol("DRV_AT24_DEF", None)
    at24SymHeaderDefFile.setSourcePath("driver/i2c_eeprom/at24/drv_at24_definitions.h")
    at24SymHeaderDefFile.setOutputName("drv_at24_definitions.h")
    at24SymHeaderDefFile.setDestPath("driver/at24")
    at24SymHeaderDefFile.setProjectPath("config/" + configName + "/driver/at24/")
    at24SymHeaderDefFile.setType("HEADER")
    at24SymHeaderDefFile.setMarkup(False)
    at24SymHeaderDefFile.setOverwrite(True)

    at24SourceFile = at24Component.createFileSymbol("AT24_SOURCE", None)
    at24SourceFile.setSourcePath("driver/i2c_eeprom/at24/src/drv_at24.c")
    at24SourceFile.setOutputName("drv_at24.c")
    at24SourceFile.setDestPath("driver/at24/src")
    at24SourceFile.setProjectPath("config/" + configName + "/driver/at24/")
    at24SourceFile.setType("SOURCE")
    at24SourceFile.setOverwrite(True)
    at24SourceFile.setMarkup(False)

    at24AsyncSymHeaderLocalFile = at24Component.createFileSymbol("DRV_AT24_HEADER_LOCAL", None)
    at24AsyncSymHeaderLocalFile.setSourcePath("driver/i2c_eeprom/at24/src/drv_at24_local.h")
    at24AsyncSymHeaderLocalFile.setOutputName("drv_at24_local.h")
    at24AsyncSymHeaderLocalFile.setDestPath("driver/at24/src")
    at24AsyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/at24/")
    at24AsyncSymHeaderLocalFile.setType("SOURCE")
    at24AsyncSymHeaderLocalFile.setOverwrite(True)
    at24AsyncSymHeaderLocalFile.setEnabled(True)

    # at24AsyncSymHeaderLocalFile = at24Component.createFileSymbol("DRV_AT24_HEADER_LOCAL", None)
    # at24AsyncSymHeaderLocalFile.setOutputName("drv_at24_local.h")
    # at24AsyncSymHeaderLocalFile.setSourcePath("driver/i2c_eeprom/at24/templates/system/drv_at24_local.h.ftl")
    # at24AsyncSymHeaderLocalFile.setDestPath("driver/at24/src")
    # at24AsyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/at24/")
    # at24AsyncSymHeaderLocalFile.setType("HEADER")
    # at24AsyncSymHeaderLocalFile.setMarkup(True)
    # at24AsyncSymHeaderLocalFile.setOverwrite(True)
    # at24AsyncSymHeaderLocalFile.setEnabled(True)


    at24SystemDefFile = at24Component.createFileSymbol("AT24_DEF", None)
    at24SystemDefFile.setType("STRING")
    at24SystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    at24SystemDefFile.setSourcePath("driver/i2c_eeprom/at24/templates/system/definitions.h.ftl")
    at24SystemDefFile.setMarkup(True)

    at24SymSystemDefObjFile = at24Component.createFileSymbol("DRV_AT24_SYSTEM_DEF_OBJECT", None)
    at24SymSystemDefObjFile.setType("STRING")
    at24SymSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    at24SymSystemDefObjFile.setSourcePath("driver/i2c_eeprom/at24/templates/system/definitions_objects.h.ftl")
    at24SymSystemDefObjFile.setMarkup(True)

    at24SymSystemConfigFile = at24Component.createFileSymbol("DRV_AT24_CONFIGIRUTION", None)
    at24SymSystemConfigFile.setType("STRING")
    at24SymSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    at24SymSystemConfigFile.setSourcePath("driver/i2c_eeprom/at24/templates/system/configuration.h.ftl")
    at24SymSystemConfigFile.setMarkup(True)

    at24SymSystemInitDataFile = at24Component.createFileSymbol("DRV_AT24_INIT_DATA", None)
    at24SymSystemInitDataFile.setType("STRING")
    at24SymSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    at24SymSystemInitDataFile.setSourcePath("driver/i2c_eeprom/at24/templates/system/initialize_data.c.ftl")
    at24SymSystemInitDataFile.setMarkup(True)

    at24SystemInitFile = at24Component.createFileSymbol("AT24_INIT", None)
    at24SystemInitFile.setType("STRING")
    at24SystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    at24SystemInitFile.setSourcePath("driver/i2c_eeprom/at24/templates/system/initialize.c.ftl")
    at24SystemInitFile.setMarkup(True)

def onAttachmentConnected(source, target):

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_at24_I2C_dependency":
        plibUsed = localComponent.getSymbolByID("DRV_AT24_PLIB")
        plibUsed.clearValue()
        at24PlibId = remoteID.upper()
        plibUsed.setValue(at24PlibId, 1)
        Database.setSymbolValue(at24PlibId, "I2C_DRIVER_CONTROLLED", True, 1)


def onAttachmentDisconnected(source, target):

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_at24_I2C_dependency":
        plibUsed = localComponent.getSymbolByID("DRV_AT24_PLIB")
        plibUsed.clearValue()
        at24PlibId = remoteID.upper()
        Database.setSymbolValue(at24PlibId, "I2C_DRIVER_CONTROLLED", False, 1)

