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

def setCommonMode(symbol, event):
    rtos_mode = event["value"]

    if (rtos_mode != None):
        if (rtos_mode == "BareMetal"):
            symbol.setValue("Asynchronous", 1)
        else:
            symbol.setValue("Synchronous", 1)

def instantiateComponent(sdhcCommonComponent):

    res = Database.activateComponents(["HarmonyCore"])

    res = Database.activateComponents(["sys_time"])

    rtos_mode = Database.getSymbolValue("HarmonyCore", "SELECT_RTOS")

    sdhc_default_mode = "Asynchronous"

    # Below Lines to be enabled when we have Synchronous support
#    if ((rtos_mode != "BareMetal") and (rtos_mode != None)):
#        sdhc_default_mode = "Synchronous"

    sdhcCommonMode = sdhcCommonComponent.createComboSymbol("DRV_SDHC_COMMON_MODE", None, ["Asynchronous", "Synchronous"])
    sdhcCommonMode.setLabel("Driver Mode")
    sdhcCommonMode.setDefaultValue(sdhc_default_mode)
    sdhcCommonMode.setReadOnly(True)
#    sdhcCommonMode.setDependencies(setCommonMode, ["HarmonyCore.SELECT_RTOS"])

    sdhcInstances = sdhcCommonComponent.createIntegerSymbol("DRV_SDHC_INSTANCES_NUMBER", None)
    sdhcInstances.setLabel("Number of SDHC Instances")
    sdhcInstances.setDefaultValue(1)
    sdhcInstances.setMax(1)
    sdhcInstances.setMin(0)

    sdhcCommonfsCounter = sdhcCommonComponent.createBooleanSymbol("DRV_SDHC_COMMON_FS_COUNTER", None)
    sdhcCommonfsCounter.setLabel("Number of Instances Using FS")
    sdhcCommonfsCounter.setDefaultValue(False)
    sdhcCommonfsCounter.setVisible(False)
    sdhcCommonfsCounter.setUseSingleDynamicValue(True)

    sdhcCommonFsEnable = sdhcCommonComponent.createBooleanSymbol("DRV_SDHC_COMMON_FS_ENABLE", None)
    sdhcCommonFsEnable.setLabel("Enable Common File system for SDHC Driver")
    sdhcCommonFsEnable.setDefaultValue(False)
    sdhcCommonFsEnable.setVisible(False)
    sdhcCommonFsEnable.setDependencies(setFileSystem, ["DRV_SDHC_COMMON_FS_COUNTER"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    sdhcHeaderFile = sdhcCommonComponent.createFileSymbol("DRV_SDHC_H", None)
    sdhcHeaderFile.setSourcePath("driver/sdhc/drv_sdhc.h")
    sdhcHeaderFile.setOutputName("drv_sdhc.h")
    sdhcHeaderFile.setDestPath("/driver/sdhc/")
    sdhcHeaderFile.setProjectPath("config/" + configName + "/driver/sdhc/")
    sdhcHeaderFile.setType("HEADER")

    sdhcAsyncSourceFile = sdhcCommonComponent.createFileSymbol("DRV_SDHC_AYNC_SRC", None)
    sdhcAsyncSourceFile.setSourcePath("driver/sdhc/async/src/drv_sdhc.c")
    sdhcAsyncSourceFile.setOutputName("drv_sdhc.c")
    sdhcAsyncSourceFile.setDestPath("/driver/sdhc/src/")
    sdhcAsyncSourceFile.setProjectPath("config/" + configName + "/driver/sdhc/")
    sdhcAsyncSourceFile.setType("SOURCE")
    sdhcAsyncSourceFile.setEnabled((sdhcCommonMode.getValue() == "Asynchronous"))
    sdhcAsyncSourceFile.setDependencies(aSyncFileGen, ["DRV_SDHC_COMMON_MODE"])

    sdhcAsyncHeaderLocalFile = sdhcCommonComponent.createFileSymbol("DRV_SDHC_ASYNC_LOCAL_H", None)
    sdhcAsyncHeaderLocalFile.setSourcePath("driver/sdhc/async/src/drv_sdhc_local.h")
    sdhcAsyncHeaderLocalFile.setOutputName("drv_sdhc_local.h")
    sdhcAsyncHeaderLocalFile.setDestPath("/driver/sdhc/src/")
    sdhcAsyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/sdhc/")
    sdhcAsyncHeaderLocalFile.setType("HEADER")
    sdhcAsyncHeaderLocalFile.setEnabled((sdhcCommonMode.getValue() == "Asynchronous"))
    sdhcAsyncHeaderLocalFile.setDependencies(aSyncFileGen, ["DRV_SDHC_COMMON_MODE"])

    sdhcCommonFsSourceFile = sdhcCommonComponent.createFileSymbol("DRV_SDHC_FS_SOURCE", None)
    sdhcCommonFsSourceFile.setSourcePath("driver/sdhc/templates/drv_sdhc_file_system.c.ftl")
    sdhcCommonFsSourceFile.setOutputName("drv_sdhc_file_system.c")
    sdhcCommonFsSourceFile.setDestPath("driver/sdhc/src")
    sdhcCommonFsSourceFile.setProjectPath("config/" + configName + "/driver/sdhc/")
    sdhcCommonFsSourceFile.setType("SOURCE")
    sdhcCommonFsSourceFile.setOverwrite(True)
    sdhcCommonFsSourceFile.setMarkup(True)
    sdhcCommonFsSourceFile.setEnabled((sdhcCommonFsEnable.getValue() == True))
    sdhcCommonFsSourceFile.setDependencies(enableFileSystemIntegration, ["DRV_SDHC_COMMON_FS_ENABLE"])

    sdhcCommonSystemDefFile = sdhcCommonComponent.createFileSymbol("DRV_SDHC_SYS_DEF_COMMON", None)
    sdhcCommonSystemDefFile.setType("STRING")
    sdhcCommonSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    sdhcCommonSystemDefFile.setSourcePath("driver/sdhc/templates/system/system_definitions_common.h.ftl")
    sdhcCommonSystemDefFile.setMarkup(True)

    sdhcCommonSymCommonSysCfgFile = sdhcCommonComponent.createFileSymbol("DRV_SDHC_SYS_CFG_COMMON", None)
    sdhcCommonSymCommonSysCfgFile.setType("STRING")
    sdhcCommonSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    sdhcCommonSymCommonSysCfgFile.setSourcePath("driver/sdhc/templates/system/system_config_common.h.ftl")
    sdhcCommonSymCommonSysCfgFile.setMarkup(True)
