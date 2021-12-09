# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2021 Microchip Technology Inc. and its subsidiaries.
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




NvmMemoryNames      = ["NVMCTRL", "EFC"]

periphNode          = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
peripherals         = periphNode.getChildren()

def activateAndConnectDependencies(componentID):
    nvmMemoryName = ""

    for module in range (0, len(peripherals)):
        periphName = str(peripherals[module].getAttribute("name"))

        if ((any(x == periphName for x in NvmMemoryNames) == True)):
            nvmMemoryName = periphName.lower()
            break

    nvmMemoryCapabilityId = nvmMemoryName.upper() + "_MEMORY"

    eep_emu_ActivateTable = [nvmMemoryName]
    eep_emu_ConnectTable  = [
        [componentID, "lib_emulated_eeprom_MEMORY_dependency", nvmMemoryName, nvmMemoryCapabilityId]
    ]

    res = Database.activateComponents(["HarmonyCore"])
    res = Database.activateComponents(eep_emu_ActivateTable)
    res = Database.connectDependencies(eep_emu_ConnectTable)

def symbolVisibility(symbol, event):
    symbol.setVisible(event["value"])

def updateLogicalEEPROMSize (symbol, event):
    localComponent = symbol.getComponent()

    if event["id"] == "EEPROM_EMULATOR_NUM_LOGICAL_PAGES":
        num_logical_pages = event["value"]
        if num_logical_pages > 0:
            page_size = localComponent.getSymbolValue("EEPROM_EMULATOR_PAGE_SIZE")
            logical_size = num_logical_pages * (page_size-4)    # 4 Bytes in each page are used for storing logical page number and other meta-data and hence not available for use by application
            symbol.setValue(logical_size)
        else:
            symbol.setValue(0)
    else:
        symbol.setVisible(event["value"])

def updateEEPROMStartAddr(symbol, event):
    localComponent = symbol.getComponent()

    if event["id"] == "EEPROM_EMULATOR_EEPROM_SIZE":
        total_eeprom_size = event["value"]
        flash_start_addr = localComponent.getSymbolValue("EEPROM_EMULATOR_FLASH_START_ADDR")
        flash_size = localComponent.getSymbolValue("EEPROM_EMULATOR_FLASH_SIZE")

        eeprom_start_addr = (flash_start_addr + flash_size) - total_eeprom_size
        symbol.setValue(int(eeprom_start_addr))
    else:
        symbol.setVisible(event["value"])

def updateNumPhysicalPages(symbol, event):
    localComponent = symbol.getComponent()

    if event["id"] == "EEPROM_EMULATOR_EEPROM_SIZE":
        total_eeprom_size = event["value"]
        page_size = localComponent.getSymbolValue("EEPROM_EMULATOR_PAGE_SIZE")
        symbol.setValue(total_eeprom_size/page_size)
    else:
        symbol.setVisible(event["value"])

def updateNumLogicalPages(symbol, event):
    localComponent = symbol.getComponent()

    if event["id"] == "EEPROM_EMULATOR_NUM_PHYSICAL_PAGES":
        num_physical_pages = event["value"]
        if num_physical_pages > 0:
            row_size = localComponent.getSymbolValue("EEPROM_EMULATOR_ROW_SIZE")
            page_size = localComponent.getSymbolValue("EEPROM_EMULATOR_PAGE_SIZE")
            pages_pr_row = row_size/page_size
            logical_pages = (num_physical_pages - (1 * pages_pr_row))/(2)
            symbol.setValue(logical_pages)
        else:
            symbol.setValue(0)
    else:
        symbol.setVisible(event["value"])

def updateEEPROMSizeBlocks(symbol, event):
    localComponent = symbol.getComponent()

    row_size = localComponent.getSymbolValue("EEPROM_EMULATOR_ROW_SIZE")
    flash_size = localComponent.getSymbolValue("EEPROM_EMULATOR_FLASH_SIZE")
    max_num_rows = flash_size/row_size

    symbol.setMax(max_num_rows)
    symbol.setVisible(event["value"])

def updateEEPROMSizeBytes(symbol, event):
    localComponent = symbol.getComponent()

    if event["id"] == "EEPROM_EMULATOR_EEPROM_SIZE_IN_BLOCKS":
        row_size = localComponent.getSymbolValue("EEPROM_EMULATOR_ROW_SIZE")
        num_eeprom_rows = event["value"]
        num_eeprom_bytes = num_eeprom_rows * row_size
        symbol.setValue(num_eeprom_bytes)
    else:
        symbol.setVisible(event["value"])

def calculateROMLength (symbol, event):
    localComponent = symbol.getComponent()

    total_eeprom_size = localComponent.getSymbolValue("EEPROM_EMULATOR_EEPROM_SIZE")
    flash_size = localComponent.getSymbolValue("EEPROM_EMULATOR_FLASH_SIZE")
    
    rom_length = flash_size - total_eeprom_size
    
    symbol.setValue("ROM_LENGTH=" + str(hex(rom_length)))  

def fileGeneration(emulated_eeprom):
    configName = Variables.get("__CONFIGURATION_NAME")

    eep_emu_sourceFile = emulated_eeprom.createFileSymbol("EEPROM_EMULATOR_SRC", None)
    eep_emu_sourceFile.setSourcePath("libraries/emulated_eeprom/templates/cortex_m0_m4_m7/emulated_eeprom.c.ftl")
    eep_emu_sourceFile.setOutputName("emulated_eeprom.c")
    eep_emu_sourceFile.setMarkup(True)
    eep_emu_sourceFile.setOverwrite(True)
    eep_emu_sourceFile.setDestPath("library/emulated_eeprom/")
    eep_emu_sourceFile.setProjectPath("config/" + configName + "/library/emulated_eeprom/")
    eep_emu_sourceFile.setType("SOURCE")

    eep_emu_headerFile = emulated_eeprom.createFileSymbol("EEPROM_EMULATOR_HEADER", None)
    eep_emu_headerFile.setSourcePath("libraries/emulated_eeprom/templates/emulated_eeprom.h")
    eep_emu_headerFile.setOutputName("emulated_eeprom.h")
    eep_emu_headerFile.setMarkup(False)
    eep_emu_headerFile.setOverwrite(True)
    eep_emu_headerFile.setDestPath("library/emulated_eeprom/")
    eep_emu_headerFile.setProjectPath("config/" + configName + "/library/emulated_eeprom/")
    eep_emu_headerFile.setType("HEADER")

    eep_emu_LocalHeaderFile = emulated_eeprom.createFileSymbol("EEPROM_EMULATOR_LOCAL_HEADER", None)
    eep_emu_LocalHeaderFile.setSourcePath("libraries/emulated_eeprom/templates/cortex_m0_m4_m7/emulated_eeprom_local.h.ftl")
    eep_emu_LocalHeaderFile.setOutputName("emulated_eeprom_local.h")
    eep_emu_LocalHeaderFile.setMarkup(True)
    eep_emu_LocalHeaderFile.setOverwrite(True)
    eep_emu_LocalHeaderFile.setDestPath("library/emulated_eeprom/")
    eep_emu_LocalHeaderFile.setProjectPath("config/" + configName + "/library/emulated_eeprom/")
    eep_emu_LocalHeaderFile.setType("HEADER")

    eep_emu_DefinitionsHeaderFile = emulated_eeprom.createFileSymbol("EEPROM_EMULATOR_DEFINITIONS_HEADER", None)
    eep_emu_DefinitionsHeaderFile.setSourcePath("libraries/emulated_eeprom/templates/emulated_eeprom_definitions.h")
    eep_emu_DefinitionsHeaderFile.setOutputName("emulated_eeprom_definitions.h")
    eep_emu_DefinitionsHeaderFile.setMarkup(False)
    eep_emu_DefinitionsHeaderFile.setOverwrite(True)
    eep_emu_DefinitionsHeaderFile.setDestPath("library/emulated_eeprom/")
    eep_emu_DefinitionsHeaderFile.setProjectPath("config/" + configName + "/library/emulated_eeprom/")
    eep_emu_DefinitionsHeaderFile.setType("HEADER")

    # System Template Files
    eep_emu_SystemConfigFile = emulated_eeprom.createFileSymbol("EEPROM_EMULATOR_SYS_CONFIG", None)
    eep_emu_SystemConfigFile.setType("STRING")
    eep_emu_SystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    eep_emu_SystemConfigFile.setSourcePath("libraries/emulated_eeprom/templates/system/system_config.h.ftl")
    eep_emu_SystemConfigFile.setMarkup(True)

    eep_emu_SystemDefObjFile = emulated_eeprom.createFileSymbol("EEPROM_EMULATOR_SYS_DEF_OBJ", None)
    eep_emu_SystemDefObjFile.setType("STRING")
    eep_emu_SystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    eep_emu_SystemDefObjFile.setSourcePath("libraries/emulated_eeprom/templates/system/system_definitions_objects.h.ftl")
    eep_emu_SystemDefObjFile.setMarkup(True)

    eep_emu_SystemInitFile = emulated_eeprom.createFileSymbol("EEPROM_EMULATOR_SYS_INIT", None)
    eep_emu_SystemInitFile.setType("STRING")
    eep_emu_SystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    eep_emu_SystemInitFile.setSourcePath("libraries/emulated_eeprom/templates/system/system_initialize.c.ftl")
    eep_emu_SystemInitFile.setMarkup(True)

    eep_emu_SystemDefIncFile = emulated_eeprom.createFileSymbol("EEPROM_EMULATOR_SYSTEM_DEF", None)
    eep_emu_SystemDefIncFile.setType("STRING")
    eep_emu_SystemDefIncFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    eep_emu_SystemDefIncFile.setSourcePath("libraries/emulated_eeprom/templates/system/system_definitions.h.ftl")
    eep_emu_SystemDefIncFile.setMarkup(True)


def instantiateComponent(emulated_eeprom):

    # As various flash symbols are read from the underlying EFC PLIB, the EEPROM Emulator configuration options are made visible only if the NVM PLIB dependency is satisfied
    eep_emu_IsDependencySatisfied = emulated_eeprom.createBooleanSymbol("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED", None)
    eep_emu_IsDependencySatisfied.setValue(False)
    eep_emu_IsDependencySatisfied.setVisible(False)

    eep_emu_RemoteComponentID = emulated_eeprom.createStringSymbol("EEPROM_EMULATOR_NVM_PLIB", None)
    eep_emu_RemoteComponentID.setValue("")
    eep_emu_RemoteComponentID.setVisible(False)

    eep_emu_FlashRowSize = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_ROW_SIZE", None)
    eep_emu_FlashRowSize.setLabel("Flash Row Size")
    eep_emu_FlashRowSize.setDefaultValue(8192)
    eep_emu_FlashRowSize.setReadOnly(True)
    eep_emu_FlashRowSize.setVisible(False)

    eep_emu_FlashPageSize = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_PAGE_SIZE", None)
    eep_emu_FlashPageSize.setLabel("Flash Page Size")
    eep_emu_FlashPageSize.setDefaultValue(512)
    eep_emu_FlashPageSize.setReadOnly(True)
    eep_emu_FlashPageSize.setVisible(False)

    eep_emu_NumPagesPerRow = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_PAGES_PER_ROW", None)
    eep_emu_NumPagesPerRow.setLabel("Pages Per Row")
    eep_emu_NumPagesPerRow.setDefaultValue(eep_emu_FlashRowSize.getValue()/eep_emu_FlashPageSize.getValue())
    eep_emu_NumPagesPerRow.setReadOnly(True)
    eep_emu_NumPagesPerRow.setVisible(False)

    #Flash Start Address
    eep_emu_FlashStartAddr = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_FLASH_START_ADDR", None)
    eep_emu_FlashStartAddr.setLabel("Flash Start Addr")
    eep_emu_FlashStartAddr.setDefaultValue(0)
    eep_emu_FlashStartAddr.setReadOnly(True)
    eep_emu_FlashStartAddr.setVisible(False)

    #Flash Size
    eep_emu_FlashSize = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_FLASH_SIZE", None)
    eep_emu_FlashSize.setLabel("Flash Size")
    eep_emu_FlashSize.setDefaultValue(0)
    eep_emu_FlashSize.setReadOnly(True)
    eep_emu_FlashSize.setVisible(False)

    #--<UI>--Size of EEPROM Emulator memory in units of erase blocks (must be atleast 2 erase blocks)
    eep_emu_EEPROMSize = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_EEPROM_SIZE_IN_BLOCKS", None)
    eep_emu_EEPROMSize.setLabel("EEPROM Size (in Erase Sectors)")
    eep_emu_EEPROMSize.setMin(2)
    eep_emu_EEPROMSize.setDefaultValue(2)
    eep_emu_EEPROMSize.setVisible(False)
    eep_emu_EEPROMSize.setDependencies(updateEEPROMSizeBlocks, ["EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    #--<UI>--Size of EEPROM Emulator memory in bytes
    default_eeprom_size = eep_emu_EEPROMSize.getValue() * eep_emu_FlashRowSize.getValue()
    eep_emu_EEPROMSize = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_EEPROM_SIZE", None)
    eep_emu_EEPROMSize.setLabel("EEPROM Size (Bytes)")
    eep_emu_EEPROMSize.setDefaultValue(default_eeprom_size)
    eep_emu_EEPROMSize.setVisible(False)
    eep_emu_EEPROMSize.setReadOnly(True)
    eep_emu_EEPROMSize.setDependencies(updateEEPROMSizeBytes, ["EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED", "EEPROM_EMULATOR_EEPROM_SIZE_IN_BLOCKS"])

    #--<UI>--EEPROM Emulator Start Address
    eep_emu_EEPROMStartAddr = emulated_eeprom.createHexSymbol("EEPROM_EMULATOR_EEPROM_START_ADDRESS", None)
    eep_emu_EEPROMStartAddr.setLabel("EEPROM Emulation Start Address")
    eep_emu_EEPROMStartAddr.setDefaultValue(0)
    eep_emu_EEPROMStartAddr.setVisible(False)
    eep_emu_EEPROMStartAddr.setDependencies(updateEEPROMStartAddr, ["EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED", "EEPROM_EMULATOR_EEPROM_SIZE"])
    
    #XC32 Linker macor - ROM Length 
    xc32LinkerMacroROMLength = emulated_eeprom.createSettingSymbol("XC32_LINKER_MACRO_ROM_LENGTH", None)
    xc32LinkerMacroROMLength.setCategory("C32-LD")
    xc32LinkerMacroROMLength.setKey("preprocessor-macros")
    xc32LinkerMacroROMLength.setAppend(True, ";=")
    xc32LinkerMacroROMLength.setDependencies(calculateROMLength, ["EEPROM_EMULATOR_EEPROM_SIZE", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    #-------Final Configuration Snapshot-------------------------------------------------------------------------------------------#

    #--<UI>--Total Physical Pages
    eep_emu_NumPhysicalPages = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_NUM_PHYSICAL_PAGES", None)
    eep_emu_NumPhysicalPages.setLabel("Number of Physical Pages")
    eep_emu_NumPhysicalPages.setDefaultValue(0)
    eep_emu_NumPhysicalPages.setReadOnly(True)
    eep_emu_NumPhysicalPages.setVisible(False)
    eep_emu_NumPhysicalPages.setDependencies(updateNumPhysicalPages, ["EEPROM_EMULATOR_EEPROM_SIZE", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    #--<UI>--Total Logical Pages
    eep_emu_NumLogicalPages = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_NUM_LOGICAL_PAGES", None)
    eep_emu_NumLogicalPages.setLabel("Number of Logical Pages")
    eep_emu_NumLogicalPages.setDefaultValue(0)
    eep_emu_NumLogicalPages.setReadOnly(True)
    eep_emu_NumLogicalPages.setVisible(False)
    eep_emu_NumLogicalPages.setDependencies(updateNumLogicalPages, ["EEPROM_EMULATOR_NUM_PHYSICAL_PAGES", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    #--<UI>--Total Logical Size
    eep_emu_UsableEEPROMSpace = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_EEPROM_LOGICAL_SIZE", None)
    eep_emu_UsableEEPROMSpace.setLabel("Logical EEPROM Size (Bytes)")
    eep_emu_UsableEEPROMSpace.setDefaultValue(0)
    eep_emu_UsableEEPROMSpace.setReadOnly(True)
    eep_emu_UsableEEPROMSpace.setVisible(False)
    eep_emu_UsableEEPROMSpace.setDependencies(updateLogicalEEPROMSize, ["EEPROM_EMULATOR_NUM_LOGICAL_PAGES", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    fileGeneration(emulated_eeprom)

def onAttachmentConnected(source, target):

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    localComponentID = source["id"]

    if localComponentID == "lib_emulated_eeprom_MEMORY_dependency":

        if remoteID.upper() == "NVMCTRL":
            row_size = Database.getSymbolValue(remoteID, "FLASH_ERASE_SIZE")
            page_size = Database.getSymbolValue(remoteID, "FLASH_PROGRAM_SIZE")
            main_array_start_addr = Database.getSymbolValue(remoteID, "FLASH_START_ADDRESS")
            main_array_size = Database.getSymbolValue(remoteID, "FLASH_SIZE")
        else:
            row_size = int(Database.getSymbolValue(remoteID, "FLASH_ERASE_SIZE"))
            page_size = int(Database.getSymbolValue(remoteID, "FLASH_PROGRAM_SIZE"))
            main_array_start_addr = int(Database.getSymbolValue(remoteID, "FLASH_START_ADDRESS")[2:], 16)
            main_array_size = int(Database.getSymbolValue(remoteID, "FLASH_SIZE")[2:], 16)

        total_eeprom_size = localComponent.getSymbolValue("EEPROM_EMULATOR_EEPROM_SIZE")
        localComponent.setSymbolValue("EEPROM_EMULATOR_NVM_PLIB", remoteID.upper())
        localComponent.setSymbolValue("EEPROM_EMULATOR_ROW_SIZE", row_size)
        localComponent.setSymbolValue("EEPROM_EMULATOR_PAGE_SIZE", page_size)
        localComponent.setSymbolValue("EEPROM_EMULATOR_PAGES_PER_ROW", (row_size/page_size))
        localComponent.setSymbolValue("EEPROM_EMULATOR_FLASH_START_ADDR", main_array_start_addr)
        localComponent.setSymbolValue("EEPROM_EMULATOR_FLASH_SIZE", main_array_size)
        localComponent.setSymbolValue("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED", True)

    if localComponentID == "lib_emulated_eeprom_HarmonyCoreDependency":
        Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    localComponentID = source["id"]

    if localComponentID == "lib_emulated_eeprom_MEMORY_dependency":
        localComponent.setSymbolValue("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED", False)

    if localComponentID == "lib_emulated_eeprom_HarmonyCoreDependency":
        Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})

def destroyComponent(emulated_eeprom):
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})

def finalizeComponent(emulated_eeprom):
    activateAndConnectDependencies(emulated_eeprom.getID())