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

drv_sst38_mcc_helpkeyword = "mcc_h3_drv_sst38_configurations"

global sst38MemoryStartAddr
global sst38MemoryAttachementID

sst38MemoryAttachementID = "None"

def sst38SetMemoryDependency(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)


def checkMpuConfig(symbol, event):
    global sst38MemoryStartAddr

    isMpuInSO = False

    if ( ( Database.getSymbolValue("core", "CoreUseMPU") != None ) and 
         ( Database.getSymbolValue("core", "CoreUseMPU") == True) ):

        index = 0
        while ( Database.getSymbolValue("core", "MPU_Region_"+str(index)+"_Enable") != None ):
            if (Database.getSymbolValue("core", "MPU_Region_"+str(index)+"_Enable") == True):
                regionAddr = Database.getSymbolValue("core", "MPU_Region_"+str(index)+"_Address")
                regionSizeSymbol = Database.getComponentByID("core").getSymbolByID("MPU_Region_"+str(index)+"_Size")
                regionSize = pow(2, int(regionSizeSymbol.getSelectedValue())+1)
                regionType = Database.getSymbolValue("core", "MPU_Region_"+str(index)+"_Type")
                if (regionType == 0 ): # 0 = "MPU_ATTR_STRONGLY_ORDERED"
                    if ( (int(sst38MemoryStartAddr.getValue(), 16) >= regionAddr) and 
                        ((int(sst38MemoryStartAddr.getValue(), 16)+0x00800000) <= (regionAddr+regionSize) ) ):
                        isMpuInSO = True
            index = index + 1

    symbol.setVisible(not isMpuInSO)

def instantiateComponent(sst38Component):
    global sst38MemoryStartAddr

    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":True})

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

    # retrieve MPU regions
    index = 0
    mpuRegionSymbolsDeps = []
    mpuRegionSymbolsDeps.append("core.CoreUseMPU")
    while Database.getSymbolValue("core", "MPU_Region_"+str(index)+"_Enable") != None:
        mpuRegionSymbolsDeps.append("core.MPU_Region_"+str(index)+"_Enable")
        mpuRegionSymbolsDeps.append("core.MPU_Region_"+str(index)+"_Address")
        mpuRegionSymbolsDeps.append("core.MPU_Region_"+str(index)+"_Size")
        index = index + 1

    sst38MpuConfigComment = sst38Component.createCommentSymbol("DRV_SST38_MPU_COMMENT", None)
    sst38MpuConfigComment.setLabel("Warning!!! MPU region for external memory should be configured in strongly order mode to write 16-bit commands. !!!")
    sst38MpuConfigComment.setVisible(True)
    checkMpuConfigDeps = mpuRegionSymbolsDeps.append("FLASH_START_ADDRESS")
    sst38MpuConfigComment.setDependencies(checkMpuConfig, mpuRegionSymbolsDeps)

    sst38InstanceName = sst38Component.createStringSymbol("SST38_INSTANCE_NAME", None)
    sst38InstanceName.setVisible(False)
    sst38InstanceName.setDefaultValue(sst38Component.getID().upper())

    sst38PLIB = sst38Component.createStringSymbol("DRV_SST38_PLIB", None)
    sst38PLIB.setLabel("PLIB Used")
    sst38PLIB.setHelp(drv_sst38_mcc_helpkeyword)
    sst38PLIB.setReadOnly(True)

    sst38NumClients = sst38Component.createIntegerSymbol("DRV_SST38_NUM_CLIENTS", None)
    sst38NumClients.setLabel("Number of Clients")
    sst38NumClients.setHelp(drv_sst38_mcc_helpkeyword)
    sst38NumClients.setReadOnly(True)
    sst38NumClients.setMin(1)
    sst38NumClients.setMax(1)
    sst38NumClients.setDefaultValue(1)

    sst38ChipSelect = sst38Component.createIntegerSymbol("CHIP_SELECT", None)
    sst38ChipSelect.setLabel("HEMC Chip Select")
    sst38ChipSelect.setVisible(False)
    sst38ChipSelect.setDefaultValue(0)

    ##### Do not modify below symbol names as they are used by Memory Driver #####
    sst38MemoryDriver = sst38Component.createBooleanSymbol("DRV_MEMORY_CONNECTED", None)
    sst38MemoryDriver.setLabel("Memory Driver Connected")
    sst38MemoryDriver.setVisible(False)
    sst38MemoryDriver.setDefaultValue(False)

    # Use FLASH_START_ADDRESS name for compatibility with Bootloader
    sst38MemoryStartAddr = sst38Component.createStringSymbol("FLASH_START_ADDRESS", None)
    sst38MemoryStartAddr.setLabel("SST38 Base Address")
    sst38MemoryStartAddr.setHelp(drv_sst38_mcc_helpkeyword)
    sst38MemoryStartAddr.setVisible(True)
    sst38MemoryStartAddr.setDefaultValue("0x00000000")
    sst38MemoryStartAddr.setReadOnly(True)

    sst38MemorySize = sst38Component.createStringSymbol("FLASH_SIZE", None)
    sst38MemorySize.setVisible(False)
    sst38MemorySize.setDefaultValue("0x00800000")
    sst38MemorySize.setReadOnly(True)

    # Program Page size for compatibility with BL
    sst38ProgramPageSize = sst38Component.createStringSymbol("FLASH_PROGRAM_SIZE", None)
    sst38ProgramPageSize.setVisible(False)
    sst38ProgramPageSize.setDefaultValue("0x00000100")

    sst38MemoryInterruptEnable = sst38Component.createBooleanSymbol("INTERRUPT_ENABLE", None)
    sst38MemoryInterruptEnable.setLabel("SST38 Interrupt Enable")
    sst38MemoryInterruptEnable.setVisible(False)
    sst38MemoryInterruptEnable.setDefaultValue(False)
    sst38MemoryInterruptEnable.setReadOnly(True)

    sst38MemoryEraseEnable = sst38Component.createBooleanSymbol("ERASE_ENABLE", None)
    sst38MemoryEraseEnable.setLabel("SST38 Erase Enable")
    sst38MemoryEraseEnable.setVisible(False)
    sst38MemoryEraseEnable.setDefaultValue(True)
    sst38MemoryEraseEnable.setReadOnly(True)

    # Use FLASH_ERASE_SIZE name for compatibility with Bootloader
    sst38MemoryEraseBufferSize = sst38Component.createIntegerSymbol("FLASH_ERASE_SIZE", None)
    sst38MemoryEraseBufferSize.setLabel("SST38 Erase Buffer Size")
    sst38MemoryEraseBufferSize.setHelp(drv_sst38_mcc_helpkeyword)
    sst38MemoryEraseBufferSize.setVisible(False)
    sst38MemoryEraseBufferSize.setDefaultValue(8192)
    sst38MemoryEraseBufferSize.setDependencies(sst38SetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    sst38MemoryEraseComment = sst38Component.createCommentSymbol("ERASE_COMMENT", None)
    sst38MemoryEraseComment.setVisible(False)
    sst38MemoryEraseComment.setLabel("*** Should be equal to Sector Erase Size ***")
    sst38MemoryEraseComment.setDependencies(sst38SetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    # Driver API for memory capability for Bootloader
    sst38DriverApiTypeBool = sst38Component.createBooleanSymbol("USES_DRV_API", None)
    sst38DriverApiTypeBool.setVisible(False)
    sst38DriverApiTypeBool.setDefaultValue(True)

    openApiName = sst38InstanceName.getValue() + "_Open"
    writeApiName = sst38InstanceName.getValue() + "_PageWrite"
    eraseApiName = sst38InstanceName.getValue() + "_SectorErase"

    sst38OpenApiName = sst38Component.createStringSymbol("OPEN_API_NAME", None)
    sst38OpenApiName.setVisible(False)
    sst38OpenApiName.setReadOnly(True)
    sst38OpenApiName.setDefaultValue(openApiName)

    sst38WriteApiName = sst38Component.createStringSymbol("WRITE_API_NAME", None)
    sst38WriteApiName.setVisible(False)
    sst38WriteApiName.setReadOnly(True)
    sst38WriteApiName.setDefaultValue(writeApiName)

    sst38EraseApiName = sst38Component.createStringSymbol("ERASE_API_NAME", None)
    sst38EraseApiName.setVisible(False)
    sst38EraseApiName.setReadOnly(True)
    sst38EraseApiName.setDefaultValue(eraseApiName)

    sst38EraseApiName = sst38Component.createStringSymbol("REGION_UNLOCK_API_NAME", None)
    sst38EraseApiName.setVisible(False)
    sst38EraseApiName.setReadOnly(True)
    sst38EraseApiName.setDefaultValue("None")

    sst38IsBusyApiName = sst38Component.createStringSymbol("IS_BUSY_API_NAME", None)
    sst38IsBusyApiName.setVisible(False)
    sst38IsBusyApiName.setReadOnly(True)
    sst38IsBusyApiName.setDefaultValue("None")

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    sst38HeaderFile = sst38Component.createFileSymbol("DRV_SST38_HEADER", None)
    sst38HeaderFile.setSourcePath("driver/parallel_prom/sst38/drv_sst38.h")
    sst38HeaderFile.setOutputName("drv_sst38.h")
    sst38HeaderFile.setDestPath("driver/sst38/")
    sst38HeaderFile.setProjectPath("config/" + configName + "/driver/sst38/")
    sst38HeaderFile.setType("HEADER")
    sst38HeaderFile.setOverwrite(True)

    sst38HeaderDefFile = sst38Component.createFileSymbol("DRV_SST38_HEADER_DEF", None)
    sst38HeaderDefFile.setSourcePath("driver/parallel_prom/sst38/templates/drv_sst38_definitions.h.ftl")
    sst38HeaderDefFile.setOutputName("drv_sst38_definitions.h")
    sst38HeaderDefFile.setDestPath("driver/sst38/")
    sst38HeaderDefFile.setProjectPath("config/" + configName + "/driver/sst38/")
    sst38HeaderDefFile.setType("HEADER")
    sst38HeaderDefFile.setOverwrite(True)
    sst38HeaderDefFile.setMarkup(True)

    sst38HeaderLocalFile = sst38Component.createFileSymbol("DRV_SST38_HEADER_LOCAL", None)
    sst38HeaderLocalFile.setSourcePath("driver/parallel_prom/sst38/src/drv_sst38_local.h.ftl")
    sst38HeaderLocalFile.setOutputName("drv_sst38_local.h")
    sst38HeaderLocalFile.setDestPath("driver/sst38/")
    sst38HeaderLocalFile.setProjectPath("config/" + configName + "/driver/sst38/")
    sst38HeaderLocalFile.setType("HEADER")
    sst38HeaderLocalFile.setOverwrite(True)
    sst38HeaderLocalFile.setMarkup(True)

    sst38SourceFile = sst38Component.createFileSymbol("DRV_SST38_SOURCE", None)
    sst38SourceFile.setSourcePath("driver/parallel_prom/sst38/src/drv_sst38.c.ftl")
    sst38SourceFile.setOutputName("drv_sst38.c")
    sst38SourceFile.setDestPath("driver/sst38/src/")
    sst38SourceFile.setProjectPath("config/" + configName + "/driver/sst38/")
    sst38SourceFile.setType("SOURCE")
    sst38SourceFile.setOverwrite(True)

    # System Template Files
    sst38SystemDefFile = sst38Component.createFileSymbol("DRV_SST38_SYS_DEF", None)
    sst38SystemDefFile.setType("STRING")
    sst38SystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sst38SystemDefFile.setSourcePath("driver/parallel_prom/sst38/templates/system/definitions.h.ftl")
    sst38SystemDefFile.setMarkup(True)

    sst38SystemDefObjFile = sst38Component.createFileSymbol("DRV_SST38_SYS_DEF_OBJ", None)
    sst38SystemDefObjFile.setType("STRING")
    sst38SystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    sst38SystemDefObjFile.setSourcePath("driver/parallel_prom/sst38/templates/system/definitions_objects.h.ftl")
    sst38SystemDefObjFile.setMarkup(True)

    sst38SystemConfigFile = sst38Component.createFileSymbol("DRV_SST38_SYS_CFG", None)
    sst38SystemConfigFile.setType("STRING")
    sst38SystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    sst38SystemConfigFile.setSourcePath("driver/parallel_prom/sst38/templates/system/configuration.h.ftl")
    sst38SystemConfigFile.setMarkup(True)

    sst38SystemInitDataFile = sst38Component.createFileSymbol("DRV_SST38_SYS_INIT_DATA", None)
    sst38SystemInitDataFile.setType("STRING")
    sst38SystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    sst38SystemInitDataFile.setSourcePath("driver/parallel_prom/sst38/templates/system/initialize_data.c.ftl")
    sst38SystemInitDataFile.setMarkup(True)

    sst38SystemInitFile = sst38Component.createFileSymbol("DRV_SST38_SYS_INIT", None)
    sst38SystemInitFile.setType("STRING")
    sst38SystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    sst38SystemInitFile.setSourcePath("driver/parallel_prom/sst38/templates/system/initialize.c.ftl")
    sst38SystemInitFile.setMarkup(True)

def handleMessage(messageID, args):
    global sst38MemoryStartAddr
    global sst38MemoryAttachementID
    resDict = {}

    if (messageID == "BASE_ADDRESS_UPDATE"):
        sst38MemoryStartAddr.setValue(args["address"])

        if (sst38MemoryAttachementID != "None"):
            argDict = {"address" : args["address"] }
            argDict = Database.sendMessage(sst38MemoryAttachementID, "FLASH_START_UPDATE", argDict)

    return resDict

def onAttachmentConnected(source, target):
    global sst38MemoryAttachementID
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    sst38PlibID = remoteID.upper()

    if connectID == "drv_sst38_HEMC_CS_dependency" :

        localComponent.getSymbolByID("DRV_SST38_PLIB").setValue(sst38PlibID)

        selectedCS = int(targetID.replace('hemc_cs', ''))

        localComponent.getSymbolByID("CHIP_SELECT").setValue(selectedCS)

        address = remoteComponent.getSymbolByID("CS_" + str(selectedCS) + "_START_ADDRESS").getValue()

        localComponent.getSymbolByID("FLASH_START_ADDRESS").setValue(address)

    elif (connectID == "memory"):
        sst38MemoryAttachementID = remoteID


def onAttachmentDisconnected(source, target):
    global sst38MemoryAttachementID
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "drv_sst38_HEMC_CS_dependency" :

        localComponent.getSymbolByID("DRV_SST38_PLIB").clearValue()
        localComponent.getSymbolByID("CHIP_SELECT").clearValue()
        localComponent.getSymbolByID("FLASH_START_ADDRESS").clearValue()

    elif (connectID == "memory"):
        sst38MemoryAttachementID = "None"

def destroyComponent(sst38Component):
    Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":False})
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})
    if Database.getSymbolValue("core", "DMA_ENABLE") != None:
        Database.sendMessage("HarmonyCore", "ENABLE_SYS_DMA", {"isEnabled":False})
