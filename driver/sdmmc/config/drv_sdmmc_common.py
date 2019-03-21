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
    symbol.setEnabled(event["value"])

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

def aSyncFileGen(symbol, event):
    if(event["value"] == "Asynchronous"):
       symbol.setEnabled(True)
    else:
       symbol.setEnabled(False)

def syncFileGen(symbol, event):
    if(event["value"] == "Synchronous"):
       symbol.setEnabled(True)
    else:
       symbol.setEnabled(False)

def setCommonMode(symbol, event):
    rtos_mode = event["value"]

    if (rtos_mode != None):
        if (rtos_mode == "BareMetal"):
            symbol.setValue("Asynchronous", 1)
        else:
            symbol.setValue("Synchronous", 1)

def instantiateComponent(sdmmcCommonComponent):
    res = Database.activateComponents(["HarmonyCore"])
    res = Database.activateComponents(["sys_time"])

    rtos_mode = Database.getSymbolValue("HarmonyCore", "SELECT_RTOS")

    sdmmc_default_mode = "Asynchronous"

    sdmmcCommonMode = sdmmcCommonComponent.createComboSymbol("DRV_SDMMC_COMMON_MODE", None, ["Asynchronous", "Synchronous"])
    sdmmcCommonMode.setLabel("Driver Mode")
    sdmmcCommonMode.setDefaultValue(sdmmc_default_mode)
    sdmmcCommonMode.setReadOnly(True)
#    sdmmcCommonMode.setDependencies(setCommonMode, ["HarmonyCore.SELECT_RTOS"])

    sdmmcCommonfsCounter = sdmmcCommonComponent.createBooleanSymbol("DRV_SDMMC_COMMON_FS_COUNTER", None)
    sdmmcCommonfsCounter.setLabel("Number of Instances Using FS")
    sdmmcCommonfsCounter.setDefaultValue(False)
    sdmmcCommonfsCounter.setVisible(False)
    sdmmcCommonfsCounter.setUseSingleDynamicValue(True)

    sdmmcCommonFsEnable = sdmmcCommonComponent.createBooleanSymbol("DRV_SDMMC_COMMON_FS_ENABLE", None)
    sdmmcCommonFsEnable.setLabel("Enable Common File system for SDMMC Driver")
    sdmmcCommonFsEnable.setDefaultValue(False)
    sdmmcCommonFsEnable.setVisible(False)
    sdmmcCommonFsEnable.setDependencies(setFileSystem, ["DRV_SDMMC_COMMON_FS_COUNTER"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    sdmmcCommonHeaderFile = sdmmcCommonComponent.createFileSymbol("DRV_SDMMC_H", None)
    sdmmcCommonHeaderFile.setSourcePath("driver/sdmmc/drv_sdmmc.h")
    sdmmcCommonHeaderFile.setOutputName("drv_sdmmc.h")
    sdmmcCommonHeaderFile.setDestPath("/driver/sdmmc/")
    sdmmcCommonHeaderFile.setProjectPath("config/" + configName + "/driver/sdmmc/")
    sdmmcCommonHeaderFile.setType("HEADER")

    sdmmcCommonLocalHeaderFile = sdmmcCommonComponent.createFileSymbol("DRV_SDMMC_LOCAL_H", None)
    sdmmcCommonLocalHeaderFile.setSourcePath("driver/sdmmc/templates/drv_sdmmc_local.h.ftl")
    sdmmcCommonLocalHeaderFile.setOutputName("drv_sdmmc_local.h")
    sdmmcCommonLocalHeaderFile.setDestPath("/driver/sdmmc/src/")
    sdmmcCommonLocalHeaderFile.setProjectPath("config/" + configName + "/driver/sdmmc/")
    sdmmcCommonLocalHeaderFile.setType("HEADER")
    sdmmcCommonLocalHeaderFile.setMarkup(True)

    sdmmcCommonDefHeaderFile = sdmmcCommonComponent.createFileSymbol("DRV_SDMMC_DEFINITIONS_H", None)
    sdmmcCommonDefHeaderFile.setSourcePath("driver/sdmmc/src/drv_sdmmc_definitions.h")
    sdmmcCommonDefHeaderFile.setOutputName("drv_sdmmc_definitions.h")
    sdmmcCommonDefHeaderFile.setDestPath("/driver/sdmmc/")
    sdmmcCommonDefHeaderFile.setProjectPath("config/" + configName + "/driver/sdmmc/")
    sdmmcCommonDefHeaderFile.setType("HEADER")

    sdmmcCommonFsSourceFile = sdmmcCommonComponent.createFileSymbol("DRV_SDMMC_FS_SOURCE", None)
    sdmmcCommonFsSourceFile.setSourcePath("driver/sdmmc/templates/drv_sdmmc_file_system.c.ftl")
    sdmmcCommonFsSourceFile.setOutputName("drv_sdmmc_file_system.c")
    sdmmcCommonFsSourceFile.setDestPath("driver/sdmmc/src")
    sdmmcCommonFsSourceFile.setProjectPath("config/" + configName + "/driver/sdmmc/")
    sdmmcCommonFsSourceFile.setType("SOURCE")
    sdmmcCommonFsSourceFile.setOverwrite(True)
    sdmmcCommonFsSourceFile.setMarkup(True)
    sdmmcCommonFsSourceFile.setEnabled((sdmmcCommonFsEnable.getValue() == True))
    sdmmcCommonFsSourceFile.setDependencies(enableFileSystemIntegration, ["DRV_SDMMC_COMMON_FS_ENABLE"])

    sdmmcCommonSystemDefFile = sdmmcCommonComponent.createFileSymbol("DRV_SDMMC_SYS_DEF_COMMON", None)
    sdmmcCommonSystemDefFile.setType("STRING")
    sdmmcCommonSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sdmmcCommonSystemDefFile.setSourcePath("driver/sdmmc/templates/system/system_definitions_common.h.ftl")
    sdmmcCommonSystemDefFile.setMarkup(True)

    sdmmcCommonSymCommonSysCfgFile = sdmmcCommonComponent.createFileSymbol("DRV_SDMMC_SYS_CFG_COMMON", None)
    sdmmcCommonSymCommonSysCfgFile.setType("STRING")
    sdmmcCommonSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    sdmmcCommonSymCommonSysCfgFile.setSourcePath("driver/sdmmc/templates/system/system_config_common.h.ftl")
    sdmmcCommonSymCommonSysCfgFile.setMarkup(True)