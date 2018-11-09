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

global fsCounter

fsCounter = 0

def enableFileSystemIntegration(symbol, event):
    if (event["value"] == True):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def setFileSystem(symbol, event):
    global fsCounter

    if (event["value"] == True):
        fsCounter = fsCounter + 1
        symbol.clearValue()
        symbol.setValue(True, 1)
    else:
        if (fsCounter != 0):
            fsCounter = fsCounter - 1

    if (fsCounter == 0):
        symbol.clearValue()
        symbol.setValue(False, 1)

def setSysTimeEnable(symbol, event):
    if (event["value"] == "Synchronous"):
        symbol.setValue(True, 1)
        res = Database.activateComponents(["sys_time"])
    else:
        symbol.setValue(False, 1)

def instantiateComponent(memoryCommonComponent):
    global memoryCommonFsEnable

    res = Database.activateComponents(["HarmonyCore"])

    memory_default_mode = "Synchronous"

    if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") == "BareMetal"):
        memory_default_mode = "Asynchronous"

    memoryCommonMode = memoryCommonComponent.createComboSymbol("DRV_MEMORY_COMMON_MODE", None, ["Asynchronous", "Synchronous"])
    memoryCommonMode.setLabel("Driver Mode")
    memoryCommonMode.setDefaultValue(memory_default_mode)

    memorySysTimeEnable = memoryCommonComponent.createBooleanSymbol("DRV_MEMORY_COMMON_SYS_TIME_ENABLE", None)
    memorySysTimeEnable.setLabel("Enable Timer System Service")
    memorySysTimeEnable.setVisible(False)
    memorySysTimeEnable.setDefaultValue((memoryCommonMode.getValue() == "Synchronous"))
    memorySysTimeEnable.setDependencies(setSysTimeEnable, ["DRV_MEMORY_COMMON_MODE"])

    if (memorySysTimeEnable.getValue() == True):
        res = Database.activateComponents(["sys_time"])

    memoryCommonfsCounter = memoryCommonComponent.createBooleanSymbol("DRV_MEMORY_COMMON_FS_COUNTER", None)
    memoryCommonfsCounter.setLabel("Number of Instances Using FS")
    memoryCommonfsCounter.setDefaultValue(False)
    memoryCommonfsCounter.setVisible(False)
    memoryCommonfsCounter.setUseSingleDynamicValue(True)

    memoryCommonFsEnable = memoryCommonComponent.createBooleanSymbol("DRV_MEMORY_COMMON_FS_ENABLE", None)
    memoryCommonFsEnable.setLabel("Enable Common File system for Memory Driver")
    memoryCommonFsEnable.setDefaultValue(False)
    memoryCommonFsEnable.setVisible(False)
    memoryCommonFsEnable.setDependencies(setFileSystem, ["DRV_MEMORY_COMMON_FS_COUNTER"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    memoryCommonFsSourceFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_FS_SOURCE", None)
    memoryCommonFsSourceFile.setSourcePath("driver/memory/templates/drv_memory_file_system.c.ftl")
    memoryCommonFsSourceFile.setOutputName("drv_memory_file_system.c")
    memoryCommonFsSourceFile.setDestPath("driver/memory/src")
    memoryCommonFsSourceFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryCommonFsSourceFile.setType("SOURCE")
    memoryCommonFsSourceFile.setOverwrite(True)
    memoryCommonFsSourceFile.setMarkup(True)
    memoryCommonFsSourceFile.setEnabled((memoryCommonFsEnable.getValue() == True))
    memoryCommonFsSourceFile.setDependencies(enableFileSystemIntegration, ["DRV_MEMORY_COMMON_FS_ENABLE"])

    memoryCommonHeaderVariantFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_HEADER_VARIANT", None)
    memoryCommonHeaderVariantFile.setSourcePath("driver/memory/templates/drv_memory_variant_mapping.h.ftl")
    memoryCommonHeaderVariantFile.setOutputName("drv_memory_variant_mapping.h")
    memoryCommonHeaderVariantFile.setDestPath("driver/memory/src")
    memoryCommonHeaderVariantFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryCommonHeaderVariantFile.setType("HEADER")
    memoryCommonHeaderVariantFile.setOverwrite(True)
    memoryCommonHeaderVariantFile.setMarkup(True)

    memoryCommonSystemDefFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_SYS_DEF_COMMON", None)
    memoryCommonSystemDefFile.setType("STRING")
    memoryCommonSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    memoryCommonSystemDefFile.setSourcePath("driver/memory/templates/system/system_definitions_common.h.ftl")
    memoryCommonSystemDefFile.setMarkup(True)

    memoryCommonSymCommonSysCfgFile = memoryCommonComponent.createFileSymbol("DRV_MEMORY_SYS_CFG_COMMON", None)
    memoryCommonSymCommonSysCfgFile.setType("STRING")
    memoryCommonSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    memoryCommonSymCommonSysCfgFile.setSourcePath("driver/memory/templates/system/system_config_common.h.ftl")
    memoryCommonSymCommonSysCfgFile.setMarkup(True)
