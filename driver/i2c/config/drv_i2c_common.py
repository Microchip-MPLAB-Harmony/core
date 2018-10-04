# coding: utf-8
"""*****************************************************************************
* © 2018 Microchip Technology Inc. and its subsidiaries.
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

def instantiateComponent(i2cComponentCommon):
    res = Database.activateComponents(["HarmonyCore"])

    # Enable "Generate Harmony Driver Common Files" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True, 1)

    # Enable "Generate Harmony System Service Common Files" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True, 1)

    # Enable "Enable System Ports" option in MHC
    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_PORTS", True, 1)

    i2cMode = i2cComponentCommon.createKeyValueSetSymbol("DRV_I2C_MODE", None)
    i2cMode.setLabel("Driver Mode")
    i2cMode.addKey("ASYNC", "0", "Asynchronous")
    i2cMode.addKey("SYNC", "1", "Synchronous")
    i2cMode.setDisplayMode("Description")
    i2cMode.setOutputMode("Key")
    i2cMode.setVisible(True)
    i2cMode.setDefaultValue(0)

    i2cSymCommonSysCfgFile = i2cComponentCommon.createFileSymbol(None, None)
    i2cSymCommonSysCfgFile.setType("STRING")
    i2cSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    i2cSymCommonSysCfgFile.setSourcePath("driver/i2c/templates/system/system_config_common.h.ftl")
    i2cSymCommonSysCfgFile.setMarkup(True)

    i2cSymSystemDefIncFile = i2cComponentCommon.createFileSymbol("DRV_I2C_SYSTEM_DEF", None)
    i2cSymSystemDefIncFile.setType("STRING")
    i2cSymSystemDefIncFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    i2cSymSystemDefIncFile.setSourcePath("driver/i2c/templates/system/system_definitions.h.ftl")
    i2cSymSystemDefIncFile.setMarkup(True)
    
    configName = Variables.get("__CONFIGURATION_NAME")

    # Global Header Files
    i2cSymHeaderFile = i2cComponentCommon.createFileSymbol("DRV_I2C_FILE_MAIN_HEADER", None)
    i2cSymHeaderFile.setSourcePath("driver/i2c/drv_i2c.h")
    i2cSymHeaderFile.setOutputName("drv_i2c.h")
    i2cSymHeaderFile.setDestPath("driver/i2c/")
    i2cSymHeaderFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cSymHeaderFile.setType("HEADER")
    i2cSymHeaderFile.setOverwrite(True)

    i2cSymHeaderDefFile = i2cComponentCommon.createFileSymbol("DRV_I2C_FILE_DEF_HEADER", None)
    i2cSymHeaderDefFile.setSourcePath("driver/i2c/templates/drv_i2c_definitions.h.ftl")
    i2cSymHeaderDefFile.setOutputName("drv_i2c_definitions.h")
    i2cSymHeaderDefFile.setDestPath("driver/i2c/")
    i2cSymHeaderDefFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cSymHeaderDefFile.setType("HEADER")
    i2cSymHeaderDefFile.setMarkup(True)
    i2cSymHeaderDefFile.setOverwrite(True)

    # Async Source Files
    i2cAsyncSymSourceFile = i2cComponentCommon.createFileSymbol("DRV_I2C_ASYNC_SRC", None)
    i2cAsyncSymSourceFile.setSourcePath("driver/i2c/src/async/drv_i2c.c")
    i2cAsyncSymSourceFile.setOutputName("drv_i2c.c")
    i2cAsyncSymSourceFile.setDestPath("driver/i2c/src")
    i2cAsyncSymSourceFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cAsyncSymSourceFile.setType("SOURCE")
    i2cAsyncSymSourceFile.setOverwrite(True)
    i2cAsyncSymSourceFile.setDependencies(asyncFileGen, ["DRV_I2C_MODE"])

    i2cAsyncSymHeaderLocalFile = i2cComponentCommon.createFileSymbol("DRV_I2C_ASYNC_HEADER", None)
    i2cAsyncSymHeaderLocalFile.setSourcePath("driver/i2c/src/async/drv_i2c_local.h")
    i2cAsyncSymHeaderLocalFile.setOutputName("drv_i2c_local.h")
    i2cAsyncSymHeaderLocalFile.setDestPath("driver/i2c/src")
    i2cAsyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cAsyncSymHeaderLocalFile.setType("SOURCE")
    i2cAsyncSymHeaderLocalFile.setOverwrite(True)
    i2cAsyncSymHeaderLocalFile.setDependencies(asyncFileGen, ["DRV_I2C_MODE"])

    # Sync Source Files
    i2cSyncSymSourceFile = i2cComponentCommon.createFileSymbol("DRV_I2C_SYNC_SRC", None)
    i2cSyncSymSourceFile.setSourcePath("driver/i2c/src/sync/drv_i2c.c")
    i2cSyncSymSourceFile.setOutputName("drv_i2c.c")
    i2cSyncSymSourceFile.setDestPath("driver/i2c/src")
    i2cSyncSymSourceFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cSyncSymSourceFile.setType("SOURCE")
    i2cSyncSymSourceFile.setOverwrite(True)
    i2cSyncSymSourceFile.setDependencies(syncFileGen, ["DRV_I2C_MODE"])

    i2cSyncSymHeaderLocalFile = i2cComponentCommon.createFileSymbol("DRV_I2C_SYNC_HEADER", None)
    i2cSyncSymHeaderLocalFile.setSourcePath("driver/i2c/src/sync/drv_i2c_local.h")
    i2cSyncSymHeaderLocalFile.setOutputName("drv_i2c_local.h")
    i2cSyncSymHeaderLocalFile.setDestPath("driver/i2c/src")
    i2cSyncSymHeaderLocalFile.setProjectPath("config/" + configName + "/driver/i2c/")
    i2cSyncSymHeaderLocalFile.setType("SOURCE")
    i2cSyncSymHeaderLocalFile.setOverwrite(True)
    i2cSyncSymHeaderLocalFile.setDependencies(syncFileGen, ["DRV_I2C_MODE"])

def syncFileGen(symbol, event):
    if(event["value"] == 1):
       symbol.setEnabled(True)
    else:
       symbol.setEnabled(False)

def asyncFileGen(symbol, event):
    if(event["value"] == 0):
       symbol.setEnabled(True)
    else:
       symbol.setEnabled(False)
