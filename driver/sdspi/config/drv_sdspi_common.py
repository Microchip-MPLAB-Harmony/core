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

    if event["value"] == True:
        fsCounter = fsCounter + 1
        symbol.clearValue()
        symbol.setValue(True, 1)
        #print fsCounter
    else:
        if fsCounter > 0:
            fsCounter = fsCounter - 1
        #print fsCounter

    if fsCounter == 0:
        symbol.clearValue()
        symbol.setValue(False, 1)

def instantiateComponent(sdspiComponentCommon):
    global sdspiCommonFsEnable

    res = Database.activateComponents(["HarmonyCore"])
    res = Database.activateComponents(["sys_time"])

    sdspiMode = sdspiComponentCommon.createKeyValueSetSymbol("DRV_SDSPI_COMMON_MODE", None)
    sdspiMode.setLabel("Driver Mode")
    sdspiMode.addKey("ASYNC", "0", "Asynchronous")
    sdspiMode.addKey("SYNC", "1", "Synchronous")
    sdspiMode.setDisplayMode("Description")
    sdspiMode.setOutputMode("Value")
    sdspiMode.setVisible(True)
    sdspiMode.setReadOnly(True)
    sdspiMode.setDefaultValue(1)

    sdspiSymCommonSysCfgFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_COMMON_CFG", None)
    sdspiSymCommonSysCfgFile.setType("STRING")
    sdspiSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    sdspiSymCommonSysCfgFile.setSourcePath("driver/sdspi/templates/system/system_config_common.h.ftl")
    sdspiSymCommonSysCfgFile.setMarkup(True)

    sdspiSymSystemDefIncFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_SYSTEM_DEF", None)
    sdspiSymSystemDefIncFile.setType("STRING")
    sdspiSymSystemDefIncFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sdspiSymSystemDefIncFile.setSourcePath("driver/sdspi/templates/system/system_definitions.h.ftl")
    sdspiSymSystemDefIncFile.setMarkup(True)

    sdspiCommonfsCounter = sdspiComponentCommon.createBooleanSymbol("DRV_SDSPI_COMMON_FS_COUNTER", None)
    sdspiCommonfsCounter.setLabel("Number of Instances Using FS")
    sdspiCommonfsCounter.setDefaultValue(False)
    sdspiCommonfsCounter.setVisible(False)
    sdspiCommonfsCounter.setUseSingleDynamicValue(True)

    sdspiCommonFsEnable = sdspiComponentCommon.createBooleanSymbol("DRV_SDSPI_COMMON_FS_ENABLE", None)
    sdspiCommonFsEnable.setLabel("Enable Common File system for SD Card Driver")
    sdspiCommonFsEnable.setDefaultValue(False)
    sdspiCommonFsEnable.setVisible(False)
    sdspiCommonFsEnable.setDependencies(setFileSystem, ["DRV_SDSPI_COMMON_FS_COUNTER"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    sdspiCommonFsSourceFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_FS_SOURCE", None)
    sdspiCommonFsSourceFile.setSourcePath("driver/sdspi/src/sync/drv_sdspi_file_system.c")
    sdspiCommonFsSourceFile.setOutputName("drv_sdspi_file_system.c")
    sdspiCommonFsSourceFile.setDestPath("driver/sdspi/src")
    sdspiCommonFsSourceFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiCommonFsSourceFile.setType("SOURCE")
    sdspiCommonFsSourceFile.setOverwrite(True)
    sdspiCommonFsSourceFile.setEnabled((sdspiCommonFsEnable.getValue() == True))
    sdspiCommonFsSourceFile.setDependencies(enableFileSystemIntegration, ["DRV_SDSPI_COMMON_FS_ENABLE"])
