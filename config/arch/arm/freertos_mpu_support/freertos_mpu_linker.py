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

############################################################################
############### Custom linker file generation ##############
############################################################################

global device_name

def generateFreeRTOSMPULinker(symbol, event):
    currentCompiler = Database.getComponentByID("core").getSymbolByID("COMPILER_CHOICE").getSelectedKey()
    mpu_port_enable = Database.getComponentByID("FreeRTOS").getSymbolByID("FREERTOS_MPU_PORT_ENABLE").getValue()

    if currentCompiler == "XC32" and mpu_port_enable == True:
        # Disable Default linker script generation
        Database.setSymbolValue("core", "ADD_LINKER_FILE", False)
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)
        Database.setSymbolValue("core", "ADD_LINKER_FILE", True)

MPULinkerSymbolMap = {
    "ATSAM_E5X_D5X" : {"filter": ["ATSAMD5", "ATSAME5"],"ROM": "FLASH",  "RAM": "HSRAM", "BACKUPRAM": "BKUPRAM"},
    "ATSAM_G5X"     : {"filter": ["ATSAMG5"],           "ROM": "IFLASH", "RAM": "IRAM"},
    "CEC17X"        : {"filter": ["CEC17"],             "ROM": "CODE_SRAM", "RAM": "DATA_SRAM"},
    "PIC32CX_BZ2"   : {"filter": ["BZ24", "BZ25", "WBZ45"],      "ROM": "FLASH", "RAM": "HSRAM", "BACKUPRAM": "BKUPRAM", "BOOTROM": "BOOT_FLASH"},
    "PIC32WM_BW1"   : {"filter": ["PIC32WM_BW1"],       "ROM": "FLASH", "RAM": "HSRAM", "BACKUPRAM": "BKUPRAM", "BOOTROM": "BOOT_FLASH"},
    "PIC32CX_BZ3"   : {"filter": ["BZ3", "WBZ35"],      "ROM": "FCR_PFM", "RAM": "RAM_SYSTEM_RAM"},
    "PIC32CX_BZ6"   : {"filter": ["BZ6", "WBZ65"],      "ROM": "FCR_PFM", "RAM": "RAM_SYSTEM_RAM"},
    "PIC32CX_MT"    : {"filter": ["MTC", "MTG", "MTSH"],"ROM": "IFLASH0",  "RAM": "IRAM0", "ITCM": "ITCM", "DTCM": "DTCM"},
    "PIC32CX_SG"    : {"filter": ["SG41", "SG60", "SG61"],"ROM": "FLASH",  "RAM": "HSRAM", "BACKUPRAM": "BKUPRAM"},
    "LAN9255"       : {"filter": ["LAN9255"],   "ROM": "FLASH",  "RAM": "HSRAM", "BACKUPRAM": "BKUPRAM"},
    "ATSAM_E7X_S7X_V7X" : {"filter": ["ATSAME7", "ATSAMS7", "ATSAMV7", "CA70", "MC70"],   "ROM": "IFLASH",  "RAM": "IRAM", "ITCM": "ITCM", "DTCM": "DTCM"},
    "PIC32CZ_CA80_CA90" : {"filter": ["CA80", "CA90"],   "ROM": "FCR_PFM",  "BOOTROM" : "FCR_BFM", "RAM": "FLEXRAM", "ITCM": "ITCM", "DTCM": "DTCM"},
    "ATSAMRH70"     : {"filter": ["ATSAMRH70"],   "ROM": "IFLASH",  "RAM": "FlexRAM", "ITCM": "ITCM", "DTCM": "DTCM"},
    "ATSAMRH71"     : {"filter": ["ATSAMRH71"],   "ROM": "IFLASH",  "RAM": "FlexRAM", "ITCM": "ITCM", "DTCM": "DTCM"},
}

template_linker = None
device_name         = ATDF.getNode("/avr-tools-device-file/devices/device").getAttribute("name")

rom_start = 0
rom_size = 0
ram_start = 0
ram_size = 0
backupram_start = 0
backupram_size = 0
bootrom_start = 0
bootrom_size = 0

for key, val in MPULinkerSymbolMap.items():
    dev_filter_list = MPULinkerSymbolMap[key]["filter"]
    for device in dev_filter_list:
        if device in device_name:
            template_linker = key
            break

atdf_node_str_format = '/avr-tools-device-file/devices/device/address-spaces/address-space/memory-segment@[name="{0}"]'
linker_symbols_map = MPULinkerSymbolMap[template_linker]
for key, val in linker_symbols_map.items():
    if key != "filter":
        atdf_node_str = atdf_node_str_format.format(val)

        if key == "ROM":
            rom_start = ATDF.getNode(atdf_node_str).getAttribute("start")
            rom_size = ATDF.getNode(atdf_node_str).getAttribute("size")
        if key == "RAM":
            ram_start = ATDF.getNode(atdf_node_str).getAttribute("start")
            ram_size = ATDF.getNode(atdf_node_str).getAttribute("size")
        if key == "BACKUPRAM":
            backupram_start = ATDF.getNode(atdf_node_str).getAttribute("start")
            backupram_size = ATDF.getNode(atdf_node_str).getAttribute("size")
        if key == "BOOTROM":
            bootrom_start = ATDF.getNode(atdf_node_str).getAttribute("start")
            bootrom_size = ATDF.getNode(atdf_node_str).getAttribute("size")
        if key == "ITCM":
            itcm_start = ATDF.getNode(atdf_node_str).getAttribute("start")
            itcm_size = ATDF.getNode(atdf_node_str).getAttribute("size")
        if key == "DTCM":
            dtcm_start = ATDF.getNode(atdf_node_str).getAttribute("start")
            dtcm_size = ATDF.getNode(atdf_node_str).getAttribute("size")


linker_device_name = thirdPartyFreeRTOS.createStringSymbol("LINKER_DEVICE_NAME", None)
linker_device_name.setDefaultValue(device_name)
linker_device_name.setVisible(False)

if "ROM" in MPULinkerSymbolMap[template_linker]:
    if any(x in device_name for x in ["BZ3", "WBZ35", "BZ6", "WBZ65"]):
        rom_start = int (rom_start, 0) + 0x200
        rom_start = str(hex(rom_start))
        rom_size  = int (rom_size, 0) - 0x200
        rom_size  = str(hex(rom_size))

    linker_rom_origin = thirdPartyFreeRTOS.createStringSymbol("LINKER_ROM_ORIGIN", None)
    linker_rom_origin.setDefaultValue(rom_start)
    linker_rom_origin.setVisible(False)

    linker_rom_len = thirdPartyFreeRTOS.createStringSymbol("LINKER_ROM_LENGTH", None)
    linker_rom_len.setDefaultValue(rom_size)
    linker_rom_len.setVisible(False)

if "RAM" in MPULinkerSymbolMap[template_linker]:
    linker_ram_origin = thirdPartyFreeRTOS.createStringSymbol("LINKER_RAM_ORIGIN", None)
    linker_ram_origin.setDefaultValue(ram_start)
    linker_ram_origin.setVisible(False)

    linker_ram_len = thirdPartyFreeRTOS.createStringSymbol("LINKER_RAM_LENGTH", None)
    linker_ram_len.setDefaultValue(ram_size)
    linker_ram_len.setVisible(False)

if "BACKUPRAM" in MPULinkerSymbolMap[template_linker]:
    linker_bkupram_origin = thirdPartyFreeRTOS.createStringSymbol("LINKER_BACKUPRAM_ORIGIN", None)
    linker_bkupram_origin.setDefaultValue(backupram_start)
    linker_bkupram_origin.setVisible(False)

    linker_bkupram_len = thirdPartyFreeRTOS.createStringSymbol("LINKER_BACKUPRAM_LENGTH", None)
    linker_bkupram_len.setDefaultValue(backupram_size)
    linker_bkupram_len.setVisible(False)

if "BOOTROM" in MPULinkerSymbolMap[template_linker]:
    linker_bootrom_origin = thirdPartyFreeRTOS.createStringSymbol("LINKER_BOOTROM_ORIGIN", None)
    linker_bootrom_origin.setDefaultValue(bootrom_start)
    linker_bootrom_origin.setVisible(False)

    linker_bootrom_len = thirdPartyFreeRTOS.createStringSymbol("LINKER_BOOTROM_LENGTH", None)
    linker_bootrom_len.setDefaultValue(bootrom_size)
    linker_bootrom_len.setVisible(False)

if "ITCM" in MPULinkerSymbolMap[template_linker]:
    linker_itcm_origin = thirdPartyFreeRTOS.createStringSymbol("LINKER_ITCM_ORIGIN", None)
    linker_itcm_origin.setDefaultValue(itcm_start)
    linker_itcm_origin.setVisible(False)

    linker_itcm_len = thirdPartyFreeRTOS.createStringSymbol("LINKER_ITCM_LENGTH", None)
    linker_itcm_len.setDefaultValue(itcm_size)
    linker_itcm_len.setVisible(False)

if "DTCM" in MPULinkerSymbolMap[template_linker]:
    linker_dtcm_origin = thirdPartyFreeRTOS.createStringSymbol("LINKER_DTCM_ORIGIN", None)
    linker_dtcm_origin.setDefaultValue(dtcm_start)
    linker_dtcm_origin.setVisible(False)

    linker_dtcm_len = thirdPartyFreeRTOS.createStringSymbol("LINKER_DTCM_LENGTH", None)
    linker_dtcm_len.setDefaultValue(dtcm_size)
    linker_dtcm_len.setVisible(False)

freertosMPULinker = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MPU_LINKER_FILE", None)
freertosMPULinker.setSourcePath("config/arch/arm/freertos_mpu_support/mpu_linkers/" + template_linker + ".ld.ftl")
freertosMPULinker.setOutputName(linker_device_name.getValue() + ".ld")
freertosMPULinker.setMarkup(True)
freertosMPULinker.setOverwrite(True)
freertosMPULinker.setType("LINKER")
freertosMPULinker.setEnabled(False)
freertosMPULinker.setDependencies(generateFreeRTOSMPULinker, ['core.COMPILER_CHOICE', "FreeRTOS.FREERTOS_MPU_PORT_ENABLE"])



############################################################################
#### Code Generation ####
############################################################################
