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

at25dfMemoryInterruptEnable = None

global sort_alphanumeric

def sort_alphanumeric(l):
    import re
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ]
    return sorted(l, key = alphanum_key)

def at25dfSetMemoryDependency(symbol, event):

    symbol.setVisible(event["value"])

def instantiateComponent(at25dfComponent):
    global at25dfMemoryInterruptEnable

    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON") == False):
        Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True, 1)

    # Enable "Generate Harmony System Service Common Files" option in MHC
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON") == False):
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True, 1)

    # Enable "Enable System Ports" option in MHC
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS") == False):
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS", True, 1)

    at25dfSymNumInst = at25dfComponent.createIntegerSymbol("DRV_AT25DF_NUM_INSTANCES", None)
    at25dfSymNumInst.setLabel("Number of Instances")
    at25dfSymNumInst.setDefaultValue(1)
    at25dfSymNumInst.setVisible(False)

    at25dfPLIB = at25dfComponent.createStringSymbol("DRV_AT25DF_PLIB", None)
    at25dfPLIB.setLabel("PLIB Used")
    at25dfPLIB.setReadOnly(True)

    at25dfSymNumClients = at25dfComponent.createIntegerSymbol("DRV_AT25DF_NUM_CLIENTS", None)
    at25dfSymNumClients.setLabel("Number of Clients")
    at25dfSymNumClients.setReadOnly(True)
    at25dfSymNumClients.setDefaultValue(1)

    at25dfFLASHPageSize = at25dfComponent.createIntegerSymbol("PAGE_SIZE", None)
    at25dfFLASHPageSize.setLabel("Page Size")
    at25dfFLASHPageSize.setDefaultValue(256)

    at25dfFLASHFlashSize = at25dfComponent.createIntegerSymbol("FLASH_SIZE", None)
    at25dfFLASHFlashSize.setLabel("Flash Size")
    at25dfFLASHFlashSize.setDefaultValue(4194304)

    at25dfSymChipSelectPin = at25dfComponent.createKeyValueSetSymbol("DRV_AT25DF_CHIP_SELECT_PIN", None)
    at25dfSymChipSelectPin.setLabel("Chip Select Pin")
    at25dfSymChipSelectPin.setOutputMode("Key")
    at25dfSymChipSelectPin.setDisplayMode("Description")

    availablePinDictionary = {}

    # Send message to core to get available pins
    availablePinDictionary = Database.sendMessage("core", "PIN_LIST", availablePinDictionary)

    for pad in sort_alphanumeric(availablePinDictionary.values()):
        key = "SYS_PORT_PIN_" + pad
        value = list(availablePinDictionary.keys())[list(availablePinDictionary.values()).index(pad)]
        description = pad
        at25dfSymChipSelectPin.addKey(key, value, description)

    at25dfSymPinConfigComment = at25dfComponent.createCommentSymbol("DRV_AT25DF_PINS_CONFIG_COMMENT", None)
    at25dfSymPinConfigComment.setLabel("***Above selected pin must be configured as GPIO Output in Pin Manager***")

    ##### Do not modify below symbol names as they are used by Memory Driver #####

    at25dfMemoryDriver = at25dfComponent.createBooleanSymbol("DRV_MEMORY_CONNECTED", None)
    at25dfMemoryDriver.setLabel("Memory Driver Connected")
    at25dfMemoryDriver.setVisible(False)

    at25dfMemoryInterruptEnable = at25dfComponent.createBooleanSymbol("INTERRUPT_ENABLE", None)
    at25dfMemoryInterruptEnable.setLabel("Interrupt Enable")
    at25dfMemoryInterruptEnable.setVisible(False)
    at25dfMemoryInterruptEnable.setReadOnly(True)

    at25dfMemoryEraseEnable = at25dfComponent.createBooleanSymbol("ERASE_ENABLE", None)
    at25dfMemoryEraseEnable.setLabel("Erase Enable")
    at25dfMemoryEraseEnable.setVisible(False)
    at25dfMemoryEraseEnable.setDefaultValue(True)

    at25dfMemoryStartAddr = at25dfComponent.createHexSymbol("START_ADDRESS", None)
    at25dfMemoryStartAddr.setLabel("FLASH Start Address")
    at25dfMemoryStartAddr.setDefaultValue(0x0000000)

    at25dfMemoryEraseBufferSize = at25dfComponent.createIntegerSymbol("ERASE_BUFFER_SIZE", None)
    at25dfMemoryEraseBufferSize.setLabel("AT25DF Erase Buffer Size")
    at25dfMemoryEraseBufferSize.setVisible(False)
    at25dfMemoryEraseBufferSize.setDefaultValue(4096)
    at25dfMemoryEraseBufferSize.setDependencies(at25dfSetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    at25dfMemoryEraseComment = at25dfComponent.createCommentSymbol("ERASE_COMMENT", None)
    at25dfMemoryEraseComment.setVisible(False)
    at25dfMemoryEraseComment.setLabel("*** Should be equal to Sector Erase Size ***")
    at25dfMemoryEraseComment.setDependencies(at25dfSetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    at25dfHeaderFile = at25dfComponent.createFileSymbol("AT25DF_HEADER", None)
    at25dfHeaderFile.setSourcePath("driver/spi_flash/at25df/drv_at25df.h")
    at25dfHeaderFile.setOutputName("drv_at25df.h")
    at25dfHeaderFile.setDestPath("driver/spi_flash/at25df/")
    at25dfHeaderFile.setProjectPath("config/" + configName + "/driver/spi_flash/at25df/")
    at25dfHeaderFile.setType("HEADER")
    at25dfHeaderFile.setOverwrite(True)

    at25dfSymHeaderDefFile = at25dfComponent.createFileSymbol("DRV_AT25DF_DEF", None)
    at25dfSymHeaderDefFile.setSourcePath("driver/spi_flash/at25df/drv_at25df_definitions.h")
    at25dfSymHeaderDefFile.setOutputName("drv_at25df_definitions.h")
    at25dfSymHeaderDefFile.setDestPath("driver/spi_flash/at25df")
    at25dfSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/spi_flash/at25df/")
    at25dfSymHeaderDefFile.setType("HEADER")
    at25dfSymHeaderDefFile.setOverwrite(True)

    at25dfSourceFile = at25dfComponent.createFileSymbol("AT25DF_SOURCE", None)
    at25dfSourceFile.setSourcePath("driver/spi_flash/at25df/src/drv_at25df.c")
    at25dfSourceFile.setOutputName("drv_at25df.c")
    at25dfSourceFile.setDestPath("driver/spi_flash/at25df/src")
    at25dfSourceFile.setProjectPath("config/" + configName + "/driver/spi_flash/at25df/")
    at25dfSourceFile.setType("SOURCE")
    at25dfSourceFile.setOverwrite(True)
    at25dfSourceFile.setMarkup(False)

    at25dfAsyncSymHeaderLocalFile = at25dfComponent.createFileSymbol("DRV_AT25DF_HEADER_LOCAL", None)
    at25dfAsyncSymHeaderLocalFile.setSourcePath("driver/spi_flash/at25df/src/drv_at25df_local.h")
    at25dfAsyncSymHeaderLocalFile.setOutputName("drv_at25df_local.h")
    at25dfAsyncSymHeaderLocalFile.setDestPath("driver/spi_flash/at25df/src")
    at25dfAsyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/spi_flash/at25df/")
    at25dfAsyncSymHeaderLocalFile.setType("SOURCE")
    at25dfAsyncSymHeaderLocalFile.setOverwrite(True)

    at25dfSystemDefFile = at25dfComponent.createFileSymbol("AT25DF_DEF", None)
    at25dfSystemDefFile.setType("STRING")
    at25dfSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    at25dfSystemDefFile.setSourcePath("driver/spi_flash/at25df/templates/system/definitions.h.ftl")
    at25dfSystemDefFile.setMarkup(True)

    at25dfSymSystemDefObjFile = at25dfComponent.createFileSymbol("DRV_AT25DF_SYSTEM_DEF_OBJECT", None)
    at25dfSymSystemDefObjFile.setType("STRING")
    at25dfSymSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    at25dfSymSystemDefObjFile.setSourcePath("driver/spi_flash/at25df/templates/system/definitions_objects.h.ftl")
    at25dfSymSystemDefObjFile.setMarkup(True)

    at25dfSymSystemConfigFile = at25dfComponent.createFileSymbol("DRV_AT25DF_CONFIGIRUTION", None)
    at25dfSymSystemConfigFile.setType("STRING")
    at25dfSymSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    at25dfSymSystemConfigFile.setSourcePath("driver/spi_flash/at25df/templates/system/configuration.h.ftl")
    at25dfSymSystemConfigFile.setMarkup(True)

    at25dfSymSystemInitDataFile = at25dfComponent.createFileSymbol("DRV_AT25DF_INIT_DATA", None)
    at25dfSymSystemInitDataFile.setType("STRING")
    at25dfSymSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    at25dfSymSystemInitDataFile.setSourcePath("driver/spi_flash/at25df/templates/system/initialize_data.c.ftl")
    at25dfSymSystemInitDataFile.setMarkup(True)

    at25dfSystemInitFile = at25dfComponent.createFileSymbol("AT25DF_INIT", None)
    at25dfSystemInitFile.setType("STRING")
    at25dfSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    at25dfSystemInitFile.setSourcePath("driver/spi_flash/at25df/templates/system/initialize.c.ftl")
    at25dfSystemInitFile.setMarkup(True)

def onAttachmentConnected(source, target):

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_at25df_SPI_dependency" :
        plibUsed = localComponent.getSymbolByID("DRV_AT25DF_PLIB")
        at25dfPlibId = remoteID.upper()
        plibUsed.setValue(at25dfPlibId.upper(), 1)
        Database.setSymbolValue(at25dfPlibId, "SPI_DRIVER_CONTROLLED", True, 1)

def onAttachmentDisconnected(source, target):

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_at25df_SPI_dependency":
        plibUsed = localComponent.getSymbolByID("DRV_AT25DF_PLIB")
        plibUsed.clearValue()
        at25dfPlibId = remoteID.upper()
        Database.setSymbolValue(at25dfPlibId, "SPI_DRIVER_CONTROLLED", False, 1)
