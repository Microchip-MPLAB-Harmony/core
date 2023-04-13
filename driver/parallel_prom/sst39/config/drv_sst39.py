# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2022 Microchip Technology Inc. and its subsidiaries.
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

drv_sst39_mcc_helpkeyword = "mcc_h3_drv_sst39_configurations"

global sst39MemoryStartAddr
global sst39MemoryAttachementID

sst39MemoryAttachementID = "None"

def sst39SetMemoryDependency(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)


def instantiateComponent(sst39Component):
    global sst39MemoryStartAddr

    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})


    sst39InstanceName = sst39Component.createStringSymbol("SST39_INSTANCE_NAME", None)
    sst39InstanceName.setVisible(False)
    sst39InstanceName.setDefaultValue(sst39Component.getID().upper())

    sst39PLIB = sst39Component.createStringSymbol("DRV_SST39_PLIB", None)
    sst39PLIB.setLabel("PLIB Used")
    sst39PLIB.setHelp(drv_sst39_mcc_helpkeyword)
    sst39PLIB.setReadOnly(True)

    sst39NumClients = sst39Component.createIntegerSymbol("DRV_SST39_NUM_CLIENTS", None)
    sst39NumClients.setLabel("Number of Clients")
    sst39NumClients.setHelp(drv_sst39_mcc_helpkeyword)
    sst39NumClients.setReadOnly(True)
    sst39NumClients.setMin(1)
    sst39NumClients.setMax(1)
    sst39NumClients.setDefaultValue(1)

    sst39ChipSelect = sst39Component.createIntegerSymbol("CHIP_SELECT", None)
    sst39ChipSelect.setLabel("HEMC Chip Select")
    sst39ChipSelect.setVisible(False)
    sst39ChipSelect.setDefaultValue(0)

    ##### Do not modify below symbol names as they are used by Memory Driver #####
    sst39MemoryDriver = sst39Component.createBooleanSymbol("DRV_MEMORY_CONNECTED", None)
    sst39MemoryDriver.setLabel("Memory Driver Connected")
    sst39MemoryDriver.setVisible(False)
    sst39MemoryDriver.setDefaultValue(False)

    # Use FLASH_START_ADDRESS name for compatibility with Bootloader
    sst39MemoryStartAddr = sst39Component.createStringSymbol("FLASH_START_ADDRESS", None)
    sst39MemoryStartAddr.setLabel("SST39 Base Address")
    sst39MemoryStartAddr.setHelp(drv_sst39_mcc_helpkeyword)
    sst39MemoryStartAddr.setVisible(True)
    sst39MemoryStartAddr.setDefaultValue("0x00000000")
    sst39MemoryStartAddr.setReadOnly(True)

    sst39MemorySize = sst39Component.createStringSymbol("FLASH_SIZE", None)
    sst39MemorySize.setVisible(False)
    sst39MemorySize.setDefaultValue("0x00080000")
    sst39MemorySize.setReadOnly(True)

    # Program Page size for compatibility with BL
    sst39ProgramPageSize = sst39Component.createStringSymbol("FLASH_PROGRAM_SIZE", None)
    sst39ProgramPageSize.setVisible(False)
    sst39ProgramPageSize.setDefaultValue("0x00000100")

    sst39MemoryInterruptEnable = sst39Component.createBooleanSymbol("INTERRUPT_ENABLE", None)
    sst39MemoryInterruptEnable.setLabel("SST39 Interrupt Enable")
    sst39MemoryInterruptEnable.setVisible(False)
    sst39MemoryInterruptEnable.setDefaultValue(False)
    sst39MemoryInterruptEnable.setReadOnly(True)

    sst39MemoryEraseEnable = sst39Component.createBooleanSymbol("ERASE_ENABLE", None)
    sst39MemoryEraseEnable.setLabel("SST39 Erase Enable")
    sst39MemoryEraseEnable.setVisible(False)
    sst39MemoryEraseEnable.setDefaultValue(True)
    sst39MemoryEraseEnable.setReadOnly(True)

    # Use FLASH_ERASE_SIZE name for compatibility with Bootloader
    sst39MemoryEraseBufferSize = sst39Component.createIntegerSymbol("FLASH_ERASE_SIZE", None)
    sst39MemoryEraseBufferSize.setLabel("SST39 Erase Buffer Size")
    sst39MemoryEraseBufferSize.setHelp(drv_sst39_mcc_helpkeyword)
    sst39MemoryEraseBufferSize.setVisible(False)
    sst39MemoryEraseBufferSize.setDefaultValue(4096)
    sst39MemoryEraseBufferSize.setDependencies(sst39SetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    sst39MemoryEraseComment = sst39Component.createCommentSymbol("ERASE_COMMENT", None)
    sst39MemoryEraseComment.setVisible(False)
    sst39MemoryEraseComment.setLabel("*** Should be equal to Sector Erase Size ***")
    sst39MemoryEraseComment.setDependencies(sst39SetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    # Driver API for memory capability for Bootloader
    sst39DriverApiTypeBool = sst39Component.createBooleanSymbol("USES_DRV_API", None)
    sst39DriverApiTypeBool.setVisible(False)
    sst39DriverApiTypeBool.setDefaultValue(True)

    openApiName = sst39InstanceName.getValue() + "_Open"
    writeApiName = sst39InstanceName.getValue() + "_PageWrite"
    eraseApiName = sst39InstanceName.getValue() + "_SectorErase"

    sst39OpenApiName = sst39Component.createStringSymbol("OPEN_API_NAME", None)
    sst39OpenApiName.setVisible(False)
    sst39OpenApiName.setReadOnly(True)
    sst39OpenApiName.setDefaultValue(openApiName)

    sst39WriteApiName = sst39Component.createStringSymbol("WRITE_API_NAME", None)
    sst39WriteApiName.setVisible(False)
    sst39WriteApiName.setReadOnly(True)
    sst39WriteApiName.setDefaultValue(writeApiName)

    sst39EraseApiName = sst39Component.createStringSymbol("ERASE_API_NAME", None)
    sst39EraseApiName.setVisible(False)
    sst39EraseApiName.setReadOnly(True)
    sst39EraseApiName.setDefaultValue(eraseApiName)

    sst39EraseApiName = sst39Component.createStringSymbol("REGION_UNLOCK_API_NAME", None)
    sst39EraseApiName.setVisible(False)
    sst39EraseApiName.setReadOnly(True)
    sst39EraseApiName.setDefaultValue("None")

    sst39IsBusyApiName = sst39Component.createStringSymbol("IS_BUSY_API_NAME", None)
    sst39IsBusyApiName.setVisible(False)
    sst39IsBusyApiName.setReadOnly(True)
    sst39IsBusyApiName.setDefaultValue("None")

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    sst39HeaderFile = sst39Component.createFileSymbol("DRV_SST39_HEADER", None)
    sst39HeaderFile.setSourcePath("driver/parallel_prom/sst39/drv_sst39.h")
    sst39HeaderFile.setOutputName("drv_sst39.h")
    sst39HeaderFile.setDestPath("driver/sst39/")
    sst39HeaderFile.setProjectPath("config/" + configName + "/driver/sst39/")
    sst39HeaderFile.setType("HEADER")
    sst39HeaderFile.setOverwrite(True)

    sst39HeaderDefFile = sst39Component.createFileSymbol("DRV_SST39_HEADER_DEF", None)
    sst39HeaderDefFile.setSourcePath("driver/parallel_prom/sst39/templates/drv_sst39_definitions.h.ftl")
    sst39HeaderDefFile.setOutputName("drv_sst39_definitions.h")
    sst39HeaderDefFile.setDestPath("driver/sst39/")
    sst39HeaderDefFile.setProjectPath("config/" + configName + "/driver/sst39/")
    sst39HeaderDefFile.setType("HEADER")
    sst39HeaderDefFile.setOverwrite(True)
    sst39HeaderDefFile.setMarkup(True)

    sst39HeaderLocalFile = sst39Component.createFileSymbol("DRV_SST39_HEADER_LOCAL", None)
    sst39HeaderLocalFile.setSourcePath("driver/parallel_prom/sst39/src/drv_sst39_local.h.ftl")
    sst39HeaderLocalFile.setOutputName("drv_sst39_local.h")
    sst39HeaderLocalFile.setDestPath("driver/sst39/")
    sst39HeaderLocalFile.setProjectPath("config/" + configName + "/driver/sst39/")
    sst39HeaderLocalFile.setType("HEADER")
    sst39HeaderLocalFile.setOverwrite(True)
    sst39HeaderLocalFile.setMarkup(True)

    sst39SourceFile = sst39Component.createFileSymbol("DRV_SST39_SOURCE", None)
    sst39SourceFile.setSourcePath("driver/parallel_prom/sst39/src/drv_sst39.c.ftl")
    sst39SourceFile.setOutputName("drv_sst39.c")
    sst39SourceFile.setDestPath("driver/sst39/src/")
    sst39SourceFile.setProjectPath("config/" + configName + "/driver/sst39/")
    sst39SourceFile.setType("SOURCE")
    sst39SourceFile.setMarkup(True)
    sst39SourceFile.setOverwrite(True)

    # System Template Files
    sst39SystemDefFile = sst39Component.createFileSymbol("DRV_SST39_SYS_DEF", None)
    sst39SystemDefFile.setType("STRING")
    sst39SystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sst39SystemDefFile.setSourcePath("driver/parallel_prom/sst39/templates/system/definitions.h.ftl")
    sst39SystemDefFile.setMarkup(True)

    sst39SystemDefObjFile = sst39Component.createFileSymbol("DRV_SST39_SYS_DEF_OBJ", None)
    sst39SystemDefObjFile.setType("STRING")
    sst39SystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    sst39SystemDefObjFile.setSourcePath("driver/parallel_prom/sst39/templates/system/definitions_objects.h.ftl")
    sst39SystemDefObjFile.setMarkup(True)

    sst39SystemConfigFile = sst39Component.createFileSymbol("DRV_SST39_SYS_CFG", None)
    sst39SystemConfigFile.setType("STRING")
    sst39SystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    sst39SystemConfigFile.setSourcePath("driver/parallel_prom/sst39/templates/system/configuration.h.ftl")
    sst39SystemConfigFile.setMarkup(True)

    sst39SystemInitDataFile = sst39Component.createFileSymbol("DRV_SST39_SYS_INIT_DATA", None)
    sst39SystemInitDataFile.setType("STRING")
    sst39SystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    sst39SystemInitDataFile.setSourcePath("driver/parallel_prom/sst39/templates/system/initialize_data.c.ftl")
    sst39SystemInitDataFile.setMarkup(True)

    sst39SystemInitFile = sst39Component.createFileSymbol("DRV_SST39_SYS_INIT", None)
    sst39SystemInitFile.setType("STRING")
    sst39SystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    sst39SystemInitFile.setSourcePath("driver/parallel_prom/sst39/templates/system/initialize.c.ftl")
    sst39SystemInitFile.setMarkup(True)

def handleMessage(messageID, args):
    global sst39MemoryStartAddr
    global sst39MemoryAttachementID
    resDict = {}

    if (messageID == "BASE_ADDRESS_UPDATE"):
        sst39MemoryStartAddr.setValue(args["address"])

        if (sst39MemoryAttachementID != "None"):
            argDict = {"address" : args["address"] }
            argDict = Database.sendMessage(sst39MemoryAttachementID, "FLASH_START_UPDATE", argDict)

    return resDict

def onAttachmentConnected(source, target):
    global sst39MemoryAttachementID
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    sst39PlibID = remoteID.upper()

    if connectID == "drv_sst39_HEMC_CS_dependency" :

        localComponent.getSymbolByID("DRV_SST39_PLIB").setValue(sst39PlibID)

        selectedCS = int(targetID.replace('hemc_cs', ''))

        localComponent.getSymbolByID("CHIP_SELECT").setValue(selectedCS)

        address = remoteComponent.getSymbolByID("CS_" + str(selectedCS) + "_START_ADDRESS").getValue()

        localComponent.getSymbolByID("FLASH_START_ADDRESS").setValue(address)

    elif (connectID == "memory"):
        sst39MemoryAttachementID = remoteID


def onAttachmentDisconnected(source, target):
    global sst39MemoryAttachementID
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_sst39_HEMC_CS_dependency" :

        localComponent.getSymbolByID("DRV_SST39_PLIB").clearValue()
        localComponent.getSymbolByID("CHIP_SELECT").clearValue()
        localComponent.getSymbolByID("FLASH_START_ADDRESS").clearValue()

    elif (connectID == "memory"):
        sst39MemoryAttachementID = "None"

def destroyComponent(sst39Component):
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})
    if Database.getSymbolValue("core", "DMA_ENABLE") != None:
        Database.sendMessage("HarmonyCore", "ENABLE_SYS_DMA", {"isEnabled":False})
