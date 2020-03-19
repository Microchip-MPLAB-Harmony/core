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
global drv_spi_counter

fsCounter = 0

def enableFileSystemIntegration(symbol, event):
    print(event["value"])
    symbol.setEnabled(event["value"])

def handleSPIDrvInstanceChange(symbol, event):

    result_dict = {}
    sdspiCommonMode = Database.getSymbolValue("drv_sdspi", "DRV_SDSPI_COMMON_MODE")

    if (symbol.getValue() == 0):
        msg = "DRV_SDSPI_DISCONNECTED"
    else:
        if (sdspiCommonMode == "Asynchronous"):
            msg = "DRV_SDSPI_SET_COMMON_MODE_TO_ASYNC"
        else:
            msg = "DRV_SDSPI_SET_COMMON_MODE_TO_SYNC"

    Database.sendMessage("drv_spi", msg, result_dict)

    return result_dict

def handleMessage(messageID, args):
    global fsCounter
    global sdspiCommonSPIDrvInstancesCnt

    result_dict = {}

    if (messageID == "DRV_SDSPI_FS_CONNECTION_COUNTER_INC"):
        fsCounter = fsCounter + 1
        Database.setSymbolValue("drv_sdspi", "DRV_SDSPI_COMMON_FS_ENABLE", True)
    if (messageID == "DRV_SDSPI_FS_CONNECTION_COUNTER_DEC"):
        if (fsCounter != 0):
            fsCounter = fsCounter - 1
        if (fsCounter == 0):
            Database.setSymbolValue("drv_sdspi", "DRV_SDSPI_COMMON_FS_ENABLE", False)
    if (messageID == "DRV_SDSPI_SPI_DRIVER_CONNECTION_COUNTER_INC"):
        sdspiCommonSPIDrvInstancesCnt.setValue(sdspiCommonSPIDrvInstancesCnt.getValue() + 1)
    if (messageID == "DRV_SDSPI_SPI_DRIVER_CONNECTION_COUNTER_DEC"):
        if (sdspiCommonSPIDrvInstancesCnt.getValue() != 0):
            sdspiCommonSPIDrvInstancesCnt.setValue(sdspiCommonSPIDrvInstancesCnt.getValue() - 1)

    return result_dict

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
            symbol.setValue("Asynchronous")
        else:
            symbol.setValue("Synchronous")


def instantiateComponent(sdspiComponentCommon):
    global sdspiCommonFsEnable
    global sdspiCommonSPIDrvInstancesCnt

    res = Database.activateComponents(["HarmonyCore"])
    res = Database.activateComponents(["sys_time"])

    rtos_mode = Database.getSymbolValue("HarmonyCore", "SELECT_RTOS")

    sdspi_default_mode = "Asynchronous"

    # Below Lines to be enabled when we have Synchronous support
    if ((rtos_mode != "BareMetal") and (rtos_mode != None)):
        sdspi_default_mode = "Synchronous"

    sdspiCommonMode = sdspiComponentCommon.createComboSymbol("DRV_SDSPI_COMMON_MODE", None, ["Asynchronous", "Synchronous"])
    sdspiCommonMode.setLabel("Driver Mode")
    sdspiCommonMode.setDefaultValue(sdspi_default_mode)
    sdspiCommonMode.setDependencies(setCommonMode, ["HarmonyCore.SELECT_RTOS"])

    sdspiCommonFsEnable = sdspiComponentCommon.createBooleanSymbol("DRV_SDSPI_COMMON_FS_ENABLE", None)
    sdspiCommonFsEnable.setLabel("Enable Common File system for SD Card Driver")
    sdspiCommonFsEnable.setVisible(False)

    sdspiCommonSPIDrvInstancesCnt = sdspiComponentCommon.createIntegerSymbol("DRV_SDSPI_COMMON_SPI_DRV_INSTANCE_CNT", None)
    sdspiCommonSPIDrvInstancesCnt.setLabel("SPI Driver Instances Counter")
    sdspiCommonSPIDrvInstancesCnt.setDefaultValue(0)
    sdspiCommonSPIDrvInstancesCnt.setVisible(False)
    sdspiCommonSPIDrvInstancesCnt.setDependencies(handleSPIDrvInstanceChange, ["DRV_SDSPI_COMMON_SPI_DRV_INSTANCE_CNT", "DRV_SDSPI_COMMON_MODE"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    # Global Header Files
    sdspiSymHeaderFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_HEADER", None)
    sdspiSymHeaderFile.setSourcePath("driver/sdspi/drv_sdspi.h")
    sdspiSymHeaderFile.setOutputName("drv_sdspi.h")
    sdspiSymHeaderFile.setDestPath("driver/sdspi/")
    sdspiSymHeaderFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiSymHeaderFile.setType("HEADER")
    sdspiSymHeaderFile.setOverwrite(True)

    # Common System Files

    sdspiCommonFsSourceFile = sdspiComponentCommon.createFileSymbol("DRV_SDSPI_FS_SOURCE", None)
    sdspiCommonFsSourceFile.setSourcePath("driver/sdspi/templates/drv_sdspi_file_system.c.ftl")
    sdspiCommonFsSourceFile.setOutputName("drv_sdspi_file_system.c")
    sdspiCommonFsSourceFile.setDestPath("driver/sdspi/src")
    sdspiCommonFsSourceFile.setProjectPath("config/" + configName + "/driver/sdspi/")
    sdspiCommonFsSourceFile.setType("SOURCE")
    sdspiCommonFsSourceFile.setOverwrite(True)
    sdspiCommonFsSourceFile.setMarkup(True)
    sdspiCommonFsSourceFile.setEnabled((sdspiCommonFsEnable.getValue() == True))
    sdspiCommonFsSourceFile.setDependencies(enableFileSystemIntegration, ["DRV_SDSPI_COMMON_FS_ENABLE"])

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
