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
global rwwEEPROMStartAddr
global EEPROMEmulatorAddrSpaces

NvmMemoryNames      = ["NVMCTRL"]
SupportedAddrSpaces = ["Main Array (EEPROM Emulator)", "RWWEE"]
EEPROMEmulatorAddrSpaces = []

periphNode          = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
peripherals         = periphNode.getChildren()

rwwEEPROMStartAddr = 0

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

def getSelectedEEPROMSize():
    selectedKeyIndex = 0
    coreComponent = Database.getComponentByID("core")
    eepromSizeSym = coreComponent.getSymbolByID("DEVICE_NVMCTRL_EEPROM_SIZE")
    selectedKey = eepromSizeSym.getSelectedKey()

    for index in range(eepromSizeSym.getKeyCount()):
        if eepromSizeSym.getKey(index) == selectedKey:
            selectedKeyIndex = index
            break

    return int(eepromSizeSym.getKeyDescription(selectedKeyIndex).split()[0])

def updateEEPROMSize(symbol, event):
    localComponent = symbol.getComponent()

    is_dependency_satisfied = localComponent.getSymbolValue("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED")
    is_main_array_enabled = localComponent.getSymbolValue("EEPROM_EMULATOR_MAIN_ARRAY_ENABLED")

    if event["id"] == "EEPROM_EMULATOR_MAIN_ARRAY_ENABLED" or event["id"] == "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED":
        symbol.setVisible(is_dependency_satisfied == True and is_main_array_enabled == True)
    else:
        symbol.setValue(getSelectedEEPROMSize())

def updateLogicalEEPROMSize (symbol, event):
    localComponent = symbol.getComponent()

    is_dependency_satisfied = localComponent.getSymbolValue("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED")

    if event["id"] == "EEPROM_EMULATOR_NUM_LOGICAL_PAGES":
        num_logical_pages = event["value"]
        if num_logical_pages > 0:
            page_size = localComponent.getSymbolValue("EEPROM_EMULATOR_PAGE_SIZE")
            logical_size = num_logical_pages * (page_size-4)    # 4 Bytes in each page are used for storing logical page number and other meta-data and hence not available for use by application
            symbol.setValue(logical_size)
        else:
            symbol.setValue(0)
    else:
        is_main_array_enabled = localComponent.getSymbolValue("EEPROM_EMULATOR_MAIN_ARRAY_ENABLED")
        is_rww_enabled = localComponent.getSymbolValue("EEPROM_EMULATOR_RWWEE_ENABLED")
        symbol.setVisible(is_dependency_satisfied == True and (is_rww_enabled == True or is_main_array_enabled == True))

def updateEEPROMStartAddr(symbol, event):
    localComponent = symbol.getComponent()

    is_dependency_satisfied = localComponent.getSymbolValue("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED")
    is_main_array_enabled = localComponent.getSymbolValue("EEPROM_EMULATOR_MAIN_ARRAY_ENABLED")

    if event["id"] == "EEPROM_EMULATOR_MAIN_ARRAY_ENABLED" or event["id"] == "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED":
        symbol.setVisible(is_dependency_satisfied == True and is_main_array_enabled == True)
    else:
        total_eeprom_size = localComponent.getSymbolValue("EEPROM_EMULATOR_EEPROM_SIZE")
        flash_start_addr = localComponent.getSymbolValue("EEPROM_EMULATOR_MAIN_ARRAY_START_ADDR")
        flash_size = localComponent.getSymbolValue("EEPROM_EMULATOR_MAIN_ARRAY_SIZE")

        eeprom_start_addr = (flash_start_addr + flash_size) - total_eeprom_size
        symbol.setValue(int(eeprom_start_addr))

def updateMainArrayPhysicalPages(symbol, event):
    localComponent = symbol.getComponent()

    total_eeprom_size = event["value"]
    page_size = localComponent.getSymbolValue("EEPROM_EMULATOR_PAGE_SIZE")

    symbol.setValue(total_eeprom_size/page_size)

def updateNumPhysicalPages(symbol, event):
    localComponent = symbol.getComponent()
    num_physical_pages = 0

    is_dependency_satisfied = localComponent.getSymbolValue("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED")

    main_array_phy_pages = localComponent.getSymbolValue("EEPROM_EMULATOR_MAIN_ARRAY_NUM_PHYSICAL_PAGES")
    rwwee_phy_pages = localComponent.getSymbolValue("EEPROM_EMULATOR_RWWEE_NUM_PHYSICAL_PAGES")

    is_main_array_enabled = localComponent.getSymbolValue("EEPROM_EMULATOR_MAIN_ARRAY_ENABLED")
    is_rww_enabled = localComponent.getSymbolValue("EEPROM_EMULATOR_RWWEE_ENABLED")

    if is_main_array_enabled == True:
        num_physical_pages += main_array_phy_pages
    if is_rww_enabled == True:
        num_physical_pages += rwwee_phy_pages

    symbol.setValue(num_physical_pages)
    symbol.setVisible(is_dependency_satisfied == True and (is_rww_enabled == True or is_main_array_enabled == True))

def updateNumLogicalPages(symbol, event):
    localComponent = symbol.getComponent()

    is_dependency_satisfied = localComponent.getSymbolValue("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED")

    if event["id"] == "EEPROM_EMULATOR_NUM_PHYSICAL_PAGES":
        num_physical_pages = event["value"]
        if num_physical_pages > 0:
            row_size = localComponent.getSymbolValue("EEPROM_EMULATOR_ROW_SIZE")
            page_size = localComponent.getSymbolValue("EEPROM_EMULATOR_PAGE_SIZE")
            pages_pr_row = row_size/page_size
            logical_pages = (num_physical_pages - (1 * pages_pr_row))/(pages_pr_row/2)
            symbol.setValue(logical_pages)
        else:
            symbol.setValue(0)
    else:
        is_main_array_enabled = localComponent.getSymbolValue("EEPROM_EMULATOR_MAIN_ARRAY_ENABLED")
        is_rww_enabled = localComponent.getSymbolValue("EEPROM_EMULATOR_RWWEE_ENABLED")
        symbol.setVisible(is_dependency_satisfied == True and (is_rww_enabled == True or is_main_array_enabled == True))

def updateRWWEEStartAddr(symbol, event):
    global rwwEEPROMStartAddr

    localComponent = symbol.getComponent()

    is_dependency_satisfied = localComponent.getSymbolValue("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED")
    is_rww_enabled = localComponent.getSymbolValue("EEPROM_EMULATOR_RWWEE_ENABLED")

    symbol.setValue(rwwEEPROMStartAddr)
    symbol.setVisible(is_dependency_satisfied == True and is_rww_enabled == True)

def updateMainArrayEnable(symbol, event):
    global EEPROMEmulatorAddrSpaces

    localComponent = symbol.getComponent()

    is_dependency_satisfied = localComponent.getSymbolValue("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED")
    selected_address_space = localComponent.getSymbolValue("EEPROM_EMULATOR_ADDRESS_SPACE")

    symbol.setValue(selected_address_space == EEPROMEmulatorAddrSpaces[0])
    symbol.setVisible(is_dependency_satisfied == True and selected_address_space == EEPROMEmulatorAddrSpaces[0])

def updateRWWEEEnable(symbol, event):
    localComponent = symbol.getComponent()

    is_dependency_satisfied = localComponent.getSymbolValue("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED")
    selected_address_space = localComponent.getSymbolValue("EEPROM_EMULATOR_ADDRESS_SPACE")

    symbol.setVisible(is_dependency_satisfied == True and selected_address_space == "RWWEE")
    symbol.setValue(selected_address_space == "RWWEE")

def updateEEPROMAddressSpace(symbol, event):
    symbol.setVisible(event["value"])

def enableCommentVisibility(symbol, event):
    localComponent = symbol.getComponent()

    is_dependency_satisfied = localComponent.getSymbolValue("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED")
    is_main_array_enabled = localComponent.getSymbolValue("EEPROM_EMULATOR_MAIN_ARRAY_ENABLED")

    symbol.setVisible(is_dependency_satisfied == True and is_main_array_enabled == True)

def enableVisibility(symbol, event):
    localComponent = symbol.getComponent()

    is_dependency_satisfied = localComponent.getSymbolValue("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED")
    is_rww_enabled = localComponent.getSymbolValue("EEPROM_EMULATOR_RWWEE_ENABLED")

    symbol.setVisible(is_dependency_satisfied == True and is_rww_enabled == True)



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

    EEPROMEmulatorAddrSpaces.append(SupportedAddrSpaces[0])

    nvmctrlRWWEEPROMNode = ATDF.getNode("/avr-tools-device-file/devices/device/address-spaces/address-space/memory-segment@[name=\"RWW\"]")
    if nvmctrlRWWEEPROMNode != None:
        EEPROMEmulatorAddrSpaces.append(SupportedAddrSpaces[1])

    # As various flash symbols are read from the underlying NVMCTRL PLIB, the EEPROM Emulator configuration options are made visible only if the NVM PLIB dependency is satisfied
    eep_emu_IsDependencySatisfied = emulated_eeprom.createBooleanSymbol("EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED", None)
    eep_emu_IsDependencySatisfied.setValue(False)
    eep_emu_IsDependencySatisfied.setVisible(False)

    eep_emu_RemoteComponentID = emulated_eeprom.createStringSymbol("EEPROM_EMULATOR_NVM_PLIB", None)
    eep_emu_RemoteComponentID.setValue("")
    eep_emu_RemoteComponentID.setVisible(False)

    #--<UI>--EEPROM Emulator Address Space
    eep_emu_EEPROMAddressSpace = emulated_eeprom.createComboSymbol("EEPROM_EMULATOR_ADDRESS_SPACE", None, EEPROMEmulatorAddrSpaces)
    eep_emu_EEPROMAddressSpace.setLabel("EEPROM Emulation Address Space")
    eep_emu_EEPROMAddressSpace.setDefaultValue(EEPROMEmulatorAddrSpaces[0])
    eep_emu_EEPROMAddressSpace.setVisible(False)
    eep_emu_EEPROMAddressSpace.setDependencies(updateEEPROMAddressSpace, ["EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    #--<UI>--Use main array for EEPROM Emulator ?
    eep_emu_MainArrayEnable = emulated_eeprom.createBooleanSymbol("EEPROM_EMULATOR_MAIN_ARRAY_ENABLED", None)
    eep_emu_MainArrayEnable.setLabel("Use Main Array for EEPROM Emulator ?")
    eep_emu_MainArrayEnable.setDefaultValue(True)
    eep_emu_MainArrayEnable.setReadOnly(True)
    eep_emu_MainArrayEnable.setVisible(False)
    eep_emu_MainArrayEnable.setDependencies(updateMainArrayEnable, ["EEPROM_EMULATOR_ADDRESS_SPACE", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    eep_emu_EEPROMSizeConfigComment1 = emulated_eeprom.createCommentSymbol("EEPROM_EMULATOR_EEPROM_SIZE_CONFIG_COMMENT1", eep_emu_MainArrayEnable)
    eep_emu_EEPROMSizeConfigComment1.setLabel("*** Configure EEPROM Size under NVMCTRL Fuse Configuration in System component ***")
    eep_emu_EEPROMSizeConfigComment1.setVisible(False)
    eep_emu_EEPROMSizeConfigComment1.setDependencies(enableCommentVisibility, ["EEPROM_EMULATOR_MAIN_ARRAY_ENABLED"])

    eep_emu_EEPROMSizeConfigComment2 = emulated_eeprom.createCommentSymbol("EEPROM_EMULATOR_EEPROM_SIZE_CONFIG_COMMENT_2", eep_emu_MainArrayEnable)
    eep_emu_EEPROMSizeConfigComment2.setLabel("*** Make sure EEPROM size is greater than or equal to 512 Bytes (2 Rows) ***")
    eep_emu_EEPROMSizeConfigComment2.setVisible(False)
    eep_emu_EEPROMSizeConfigComment2.setDependencies(enableCommentVisibility, ["EEPROM_EMULATOR_MAIN_ARRAY_ENABLED"])

    eep_emu_FlashRowSize = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_ROW_SIZE", eep_emu_MainArrayEnable)
    eep_emu_FlashRowSize.setLabel("Flash Row Size")
    eep_emu_FlashRowSize.setDefaultValue(256)
    eep_emu_FlashRowSize.setReadOnly(True)
    eep_emu_FlashRowSize.setVisible(False)

    eep_emu_FlashPageSize = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_PAGE_SIZE", eep_emu_MainArrayEnable)
    eep_emu_FlashPageSize.setLabel("Flash Page Size")
    eep_emu_FlashPageSize.setDefaultValue(64)
    eep_emu_FlashPageSize.setReadOnly(True)
    eep_emu_FlashPageSize.setVisible(False)

    eep_emu_NumPagesPerRow = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_PAGES_PER_ROW", eep_emu_MainArrayEnable)
    eep_emu_NumPagesPerRow.setLabel("Pages Per Row")
    eep_emu_NumPagesPerRow.setDefaultValue(eep_emu_FlashRowSize.getValue()/eep_emu_FlashPageSize.getValue())
    eep_emu_NumPagesPerRow.setReadOnly(True)
    eep_emu_NumPagesPerRow.setVisible(False)

    #Main Array Start Address
    eep_emu_FlashStartAddr = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_MAIN_ARRAY_START_ADDR", eep_emu_MainArrayEnable)
    eep_emu_FlashStartAddr.setLabel("Main Array Flash Start Addr")
    eep_emu_FlashStartAddr.setDefaultValue(0)
    eep_emu_FlashStartAddr.setReadOnly(True)
    eep_emu_FlashStartAddr.setVisible(False)

    #Main Array Flash Size
    eep_emu_FlashSize = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_MAIN_ARRAY_SIZE", eep_emu_MainArrayEnable)
    eep_emu_FlashSize.setLabel("Main Array Flash Size")
    eep_emu_FlashSize.setDefaultValue(0)
    eep_emu_FlashSize.setReadOnly(True)
    eep_emu_FlashSize.setVisible(False)

    #--<UI>--Main Array EEPROM Emulator Start Address
    eep_emu_EEPROMStartAddr = emulated_eeprom.createHexSymbol("EEPROM_EMULATOR_EEPROM_START_ADDRESS", eep_emu_MainArrayEnable)
    eep_emu_EEPROMStartAddr.setLabel("EEPROM Start Address")
    eep_emu_EEPROMStartAddr.setDefaultValue(0)
    eep_emu_EEPROMStartAddr.setReadOnly(True)
    eep_emu_EEPROMStartAddr.setVisible(False)
    eep_emu_EEPROMStartAddr.setDependencies(updateEEPROMStartAddr, ["EEPROM_EMULATOR_EEPROM_SIZE", "EEPROM_EMULATOR_MAIN_ARRAY_SIZE", "EEPROM_EMULATOR_MAIN_ARRAY_ENABLED", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    #--<UI>--Size of EEPROM Emulator memory in Main Array (configured through fuse setting)
    eep_emu_EEPROMSize = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_EEPROM_SIZE", eep_emu_MainArrayEnable)
    eep_emu_EEPROMSize.setLabel("EEPROM Size")
    eep_emu_EEPROMSize.setDefaultValue(getSelectedEEPROMSize())
    eep_emu_EEPROMSize.setReadOnly(True)
    eep_emu_EEPROMSize.setVisible(False)
    eep_emu_EEPROMSize.setDependencies(updateEEPROMSize, ["core.DEVICE_NVMCTRL_EEPROM_SIZE", "EEPROM_EMULATOR_MAIN_ARRAY_ENABLED", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    #Main Array physical pages
    eep_emu_NumPhysicalPages = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_MAIN_ARRAY_NUM_PHYSICAL_PAGES", eep_emu_MainArrayEnable)
    eep_emu_NumPhysicalPages.setLabel("Num Physical Pages")
    eep_emu_NumPhysicalPages.setDefaultValue(0)
    eep_emu_NumPhysicalPages.setVisible(False)
    eep_emu_NumPhysicalPages.setDependencies(updateMainArrayPhysicalPages, ["EEPROM_EMULATOR_EEPROM_SIZE"])

    #------RWWEE Configuration Options----------------------------------------------------------------------------------------------#

    #RWWEE Is Available?
    eep_emu_RWWEEMemAvailable = emulated_eeprom.createBooleanSymbol("EEPROM_EMULATOR_RWWEE_AVAILABLE", None)
    eep_emu_RWWEEMemAvailable.setLabel("RWWEE Available?")
    eep_emu_RWWEEMemAvailable.setDefaultValue(nvmctrlRWWEEPROMNode != None)
    eep_emu_RWWEEMemAvailable.setVisible(False)

    #--<UI>--RWWEE Is Enabled?
    eep_emu_RWWEEMemEnable = emulated_eeprom.createBooleanSymbol("EEPROM_EMULATOR_RWWEE_ENABLED", None)
    eep_emu_RWWEEMemEnable.setLabel("Use RWWEE memory for EEPROM Emulator ?")
    eep_emu_RWWEEMemEnable.setDefaultValue(False)
    eep_emu_RWWEEMemEnable.setReadOnly(True)
    eep_emu_RWWEEMemEnable.setVisible(False)
    eep_emu_RWWEEMemEnable.setDependencies(updateRWWEEEnable, ["EEPROM_EMULATOR_ADDRESS_SPACE", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    #--<UI>--RWWEE Start Address
    eep_emu_RWWEEStartAddr = emulated_eeprom.createHexSymbol("EEPROM_EMULATOR_RWWEE_START_ADDRESS", eep_emu_RWWEEMemEnable)
    eep_emu_RWWEEStartAddr.setLabel("RWWEE Start Address")
    eep_emu_RWWEEStartAddr.setDefaultValue(0)
    eep_emu_RWWEEStartAddr.setReadOnly(True)
    eep_emu_RWWEEStartAddr.setVisible(False)
    eep_emu_RWWEEStartAddr.setDependencies(updateRWWEEStartAddr, ["EEPROM_EMULATOR_RWWEE_ENABLED", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    #--<UI>--RWWEE Size
    eep_emu_RWWEESize = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_RWWEE_SIZE", eep_emu_RWWEEMemEnable)
    eep_emu_RWWEESize.setLabel("RWWEE Size")
    eep_emu_RWWEESize.setDefaultValue(0)
    eep_emu_RWWEESize.setReadOnly(True)
    eep_emu_RWWEESize.setVisible(False)
    eep_emu_RWWEESize.setDependencies(enableVisibility, ["EEPROM_EMULATOR_RWWEE_ENABLED", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    #RWWEE Physical Pages
    eep_emu_RWWEENumPhyPages = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_RWWEE_NUM_PHYSICAL_PAGES", eep_emu_RWWEEMemEnable)
    eep_emu_RWWEENumPhyPages.setLabel("RWWEE Physical Pages")
    eep_emu_RWWEENumPhyPages.setDefaultValue(0)
    eep_emu_RWWEENumPhyPages.setReadOnly(True)
    eep_emu_RWWEENumPhyPages.setVisible(False)

    #-------Final Configuration Snapshot-------------------------------------------------------------------------------------------#

    #--<UI>--Total Physical Pages (Main Array or RWWEE or Main Array + RWWEE)
    eep_emu_NumPhysicalPages = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_NUM_PHYSICAL_PAGES", None)
    eep_emu_NumPhysicalPages.setLabel("Number of Physical Pages")
    eep_emu_NumPhysicalPages.setDefaultValue(0)
    eep_emu_NumPhysicalPages.setReadOnly(True)
    eep_emu_NumPhysicalPages.setVisible(False)
    eep_emu_NumPhysicalPages.setDependencies(updateNumPhysicalPages, ["EEPROM_EMULATOR_MAIN_ARRAY_NUM_PHYSICAL_PAGES", "EEPROM_EMULATOR_RWWEE_NUM_PHYSICAL_PAGES", "EEPROM_EMULATOR_RWWEE_ENABLED", "EEPROM_EMULATOR_MAIN_ARRAY_ENABLED", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    #--<UI>--Total Logical Pages (Main Array or RWWEE or Main Array + RWWEE)
    eep_emu_NumLogicalPages = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_NUM_LOGICAL_PAGES", None)
    eep_emu_NumLogicalPages.setLabel("Number of Logical Pages")
    eep_emu_NumLogicalPages.setDefaultValue(0)
    eep_emu_NumLogicalPages.setReadOnly(True)
    eep_emu_NumLogicalPages.setVisible(False)
    eep_emu_NumLogicalPages.setDependencies(updateNumLogicalPages, ["EEPROM_EMULATOR_NUM_PHYSICAL_PAGES", "EEPROM_EMULATOR_RWWEE_ENABLED", "EEPROM_EMULATOR_MAIN_ARRAY_ENABLED", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    #--<UI>--Total Logical Size (Main Array or RWWEE or Main Array + RWWEE)
    eep_emu_UsableEEPROMSpace = emulated_eeprom.createIntegerSymbol("EEPROM_EMULATOR_EEPROM_LOGICAL_SIZE", None)
    eep_emu_UsableEEPROMSpace.setLabel("Logical EEPROM Size")
    eep_emu_UsableEEPROMSpace.setDefaultValue(0)
    eep_emu_UsableEEPROMSpace.setReadOnly(True)
    eep_emu_UsableEEPROMSpace.setVisible(False)
    eep_emu_UsableEEPROMSpace.setDependencies(updateLogicalEEPROMSize, ["EEPROM_EMULATOR_NUM_LOGICAL_PAGES", "EEPROM_EMULATOR_RWWEE_ENABLED", "EEPROM_EMULATOR_MAIN_ARRAY_ENABLED", "EEPROM_EMULATOR_IS_DEPENDENCY_SATISFIED"])

    fileGeneration(emulated_eeprom)

def onAttachmentConnected(source, target):
    global rwwEEPROMStartAddr

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    localComponentID = source["id"]

    if localComponentID == "lib_emulated_eeprom_MEMORY_dependency":

        row_size = int(Database.getSymbolValue(remoteID, "FLASH_ERASE_SIZE"))
        page_size = int(Database.getSymbolValue(remoteID, "FLASH_PROGRAM_SIZE"))
        main_array_start_addr = int(Database.getSymbolValue(remoteID, "FLASH_START_ADDRESS")[2:], 16)
        main_array_size = int(Database.getSymbolValue(remoteID, "FLASH_SIZE")[2:], 16)

        if Database.getSymbolValue(remoteID, "FLASH_RWWEEPROM_START_ADDRESS") != None:
            rwwEEPROMStartAddr = int(Database.getSymbolValue(remoteID, "FLASH_RWWEEPROM_START_ADDRESS")[2:], 16)
            rwwEEPROMSize = int(Database.getSymbolValue(remoteID, "FLASH_RWWEEPROM_SIZE")[2:], 16)
            localComponent.setSymbolValue("EEPROM_EMULATOR_RWWEE_AVAILABLE", True)
            localComponent.setSymbolValue("EEPROM_EMULATOR_RWWEE_SIZE", rwwEEPROMSize)
            localComponent.setSymbolValue("EEPROM_EMULATOR_RWWEE_NUM_PHYSICAL_PAGES", (rwwEEPROMSize/page_size))


        total_eeprom_size = localComponent.getSymbolValue("EEPROM_EMULATOR_EEPROM_SIZE")
        localComponent.setSymbolValue("EEPROM_EMULATOR_NVM_PLIB", remoteID.upper())
        localComponent.setSymbolValue("EEPROM_EMULATOR_ROW_SIZE", row_size)
        localComponent.setSymbolValue("EEPROM_EMULATOR_PAGE_SIZE", page_size)
        localComponent.setSymbolValue("EEPROM_EMULATOR_PAGES_PER_ROW", (row_size/page_size))
        localComponent.setSymbolValue("EEPROM_EMULATOR_MAIN_ARRAY_START_ADDR", main_array_start_addr)
        localComponent.setSymbolValue("EEPROM_EMULATOR_MAIN_ARRAY_SIZE", main_array_size)
        localComponent.setSymbolValue("EEPROM_EMULATOR_MAIN_ARRAY_NUM_PHYSICAL_PAGES", (total_eeprom_size/page_size))
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