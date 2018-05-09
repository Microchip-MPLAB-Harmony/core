################################################################################
#### Component ####
################################################################################

pioPinout = ATDF.getNode('/avr-tools-device-file/pinouts/pinout@[name= "LQFP144"]')

def at25mSetMemoryDependency(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def instantiateComponent(at25mComponent):

    # Enable "Generate Harmony Application Files" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_APP_FILE", True, 1)

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_DRV_COMMON", True, 1)

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_SYS_COMMON", True, 1)

    # Enable "Enable System Ports" option in MHC
    Database.setSymbolValue("Harmony", "ENABLE_SYS_PORTS", True, 1)

    at25mSymNumInst = at25mComponent.createIntegerSymbol("DRV_AT25M_NUM_INSTANCES", None)
    at25mSymNumInst.setLabel("Number of Instances")
    at25mSymNumInst.setDefaultValue(1)
    at25mSymNumInst.setVisible(False)
    
    at25mSymIndex = at25mComponent.createIntegerSymbol("DRV_AT25M_INDEX", None)
    at25mSymIndex.setLabel("Driver Index")
    at25mSymIndex.setVisible(True)
    at25mSymIndex.setDefaultValue(0)
    at25mSymIndex.setReadOnly(True)
    
    at25mPLIB = at25mComponent.createStringSymbol("DRV_AT25M_PLIB", None)
    at25mPLIB.setLabel("PLIB Used")
    at25mPLIB.setReadOnly(True)
    
    at25mSymNumClients = at25mComponent.createIntegerSymbol("DRV_AT25M_NUM_CLIENTS", None)
    at25mSymNumClients.setLabel("Number of Clients")
    at25mSymNumClients.setReadOnly(True)
    at25mSymNumClients.setDefaultValue(1)

    at25mMemoryDriver = at25mComponent.createBooleanSymbol("DRV_MEMORY_CONNECTED", None)
    at25mMemoryDriver.setLabel("Memory Driver Connected")
    at25mMemoryDriver.setVisible(False)
    at25mMemoryDriver.setDefaultValue(False)

    at25mMemoryEraseEnable = at25mComponent.createBooleanSymbol("ERASE_ENABLE", None)
    at25mMemoryEraseEnable.setLabel("at25m Erase Enable")
    at25mMemoryEraseEnable.setVisible(False)
    at25mMemoryEraseEnable.setDefaultValue(False)

    at25mSymChipSelectPin = at25mComponent.createKeyValueSetSymbol("DRV_AT25M_CHIP_SELECT_PIN", None)
    at25mSymChipSelectPin.setLabel("Chip Select Pin")
    at25mSymChipSelectPin.setDefaultValue(5) #PA5 
    at25mSymChipSelectPin.setOutputMode("Key")
    at25mSymChipSelectPin.setDisplayMode("Description")
    
    at25mSymHoldPin = at25mComponent.createKeyValueSetSymbol("DRV_AT25M_HOLD_PIN", None)
    at25mSymHoldPin.setLabel("Hold Pin")
    at25mSymHoldPin.setDefaultValue(0) #PA0
    at25mSymHoldPin.setOutputMode("Key")
    at25mSymHoldPin.setDisplayMode("Description")
    
    at25mSymWriteProtectPin = at25mComponent.createKeyValueSetSymbol("DRV_AT25M_WRITE_PROTECT_PIN", None)
    at25mSymWriteProtectPin.setLabel("Write Protect Pin")
    at25mSymWriteProtectPin.setDefaultValue(1) #PA1
    at25mSymWriteProtectPin.setOutputMode("Key")
    at25mSymWriteProtectPin.setDisplayMode("Description")
    
    count = Database.getSymbolValue("core", "PIO_PIN_TOTAL")
    for id in range(0,count):
        if (pioPinout.getChildren()[id].getAttribute("pad")[0] == "P") and (pioPinout.getChildren()[id].getAttribute("pad")[-1].isdigit()):
            key = "SYS_PORT_PIN_" + pioPinout.getChildren()[id].getAttribute("pad")        
            value = pioPinout.getChildren()[id].getAttribute("position")
            description = pioPinout.getChildren()[id].getAttribute("pad")
            at25mSymChipSelectPin.addKey(key, value, description)
            at25mSymHoldPin.addKey(key, value, description)
            at25mSymWriteProtectPin.addKey(key, value, description)

    at25mSymPinConfigComment = at25mComponent.createCommentSymbol("DRV_AT25M_PINS_CONFIG_COMMENT", None)
    at25mSymPinConfigComment.setVisible(True)
    at25mSymPinConfigComment.setLabel("Above selected pins must be configured as GPIO Output pin in Pin Manager")
    
    at25mMemoryStartAddr = at25mComponent.createHexSymbol("START_ADDRESS", None)
    at25mMemoryStartAddr.setLabel("AT25M EEPROM Start Address")
    at25mMemoryStartAddr.setVisible(True)
    at25mMemoryStartAddr.setDefaultValue(0x0000000)
    
    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    at25mHeaderFile = at25mComponent.createFileSymbol("AT25M_HEADER", None)
    at25mHeaderFile.setSourcePath("driver/at25m/drv_at25m.h")
    at25mHeaderFile.setOutputName("drv_at25m.h")
    at25mHeaderFile.setDestPath("driver/at25m/")
    at25mHeaderFile.setProjectPath("config/" + configName + "/driver/at25m/")
    at25mHeaderFile.setType("HEADER")
    at25mHeaderFile.setOverwrite(True)

    at25mSymHeaderDefFile = at25mComponent.createFileSymbol("DRV_AT25M_DEF", None)
    at25mSymHeaderDefFile.setSourcePath("driver/at25m/drv_at25m_definitions.h")
    at25mSymHeaderDefFile.setOutputName("drv_at25m_definitions.h")
    at25mSymHeaderDefFile.setDestPath("driver/at25m")
    at25mSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/at25m/")
    at25mSymHeaderDefFile.setType("HEADER")
    at25mSymHeaderDefFile.setMarkup(False)
    at25mSymHeaderDefFile.setOverwrite(True)
    
    at25mSourceFile = at25mComponent.createFileSymbol("AT25M_SOURCE", None)
    at25mSourceFile.setSourcePath("driver/at25m/src/drv_at25m.c")
    at25mSourceFile.setOutputName("drv_at25m.c")
    at25mSourceFile.setDestPath("driver/at25m/")
    at25mSourceFile.setProjectPath("config/" + configName + "/driver/at25m/")
    at25mSourceFile.setType("SOURCE")
    at25mSourceFile.setOverwrite(True)
    at25mSourceFile.setMarkup(False)

    at25mAsyncSymHeaderLocalFile = at25mComponent.createFileSymbol("DRV_AT25M_HEADER_LOCAL", None)
    at25mAsyncSymHeaderLocalFile.setSourcePath("driver/at25m/src/drv_at25m_local.h")
    at25mAsyncSymHeaderLocalFile.setOutputName("drv_at25m_local.h")
    at25mAsyncSymHeaderLocalFile.setDestPath("driver/at25m/src")
    at25mAsyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/at25m/")
    at25mAsyncSymHeaderLocalFile.setType("SOURCE")
    at25mAsyncSymHeaderLocalFile.setOverwrite(True)
    at25mAsyncSymHeaderLocalFile.setEnabled(True)

    
    at25mSystemDefFile = at25mComponent.createFileSymbol("AT25M_DEF", None)
    at25mSystemDefFile.setType("STRING")
    at25mSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    at25mSystemDefFile.setSourcePath("driver/at25m/templates/system/definitions.h.ftl")
    at25mSystemDefFile.setMarkup(True)

    at25mSymSystemDefObjFile = at25mComponent.createFileSymbol("DRV_AT25M_SYSTEM_DEF_OBJECT", None)
    at25mSymSystemDefObjFile.setType("STRING")
    at25mSymSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    at25mSymSystemDefObjFile.setSourcePath("driver/at25m/templates/system/definitions_objects.h.ftl")
    at25mSymSystemDefObjFile.setMarkup(True)
    
    at25mSymSystemConfigFile = at25mComponent.createFileSymbol("DRV_AT25M_CONFIGIRUTION", None)
    at25mSymSystemConfigFile.setType("STRING")
    at25mSymSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    at25mSymSystemConfigFile.setSourcePath("driver/at25m/templates/system/configuration.h.ftl")
    at25mSymSystemConfigFile.setMarkup(True)
    
    at25mSymSystemInitDataFile = at25mComponent.createFileSymbol("DRV_AT25M_INIT_DATA", None)
    at25mSymSystemInitDataFile.setType("STRING")
    at25mSymSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    at25mSymSystemInitDataFile.setSourcePath("driver/at25m/templates/system/initialize_data.c.ftl")
    at25mSymSystemInitDataFile.setMarkup(True)
    
    at25mSystemInitFile = at25mComponent.createFileSymbol("AT25M_INIT", None)
    at25mSystemInitFile.setType("STRING")
    at25mSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    at25mSystemInitFile.setSourcePath("driver/at25m/templates/system/initialize.c.ftl")
    at25mSystemInitFile.setMarkup(True)
    
def onDependentComponentAdded(at25mComponent, id, remoteComponent):
    if id == "drv_at25m_SPI_dependency" :
        plibUsed = at25mComponent.getSymbolByID("DRV_AT25M_PLIB")
        plibUsed.clearValue()
        plibUsed.setValue(remoteComponent.getID().upper(), 2)

