# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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

global isCachePresent

isCachePresent = True

if ((Database.getSymbolValue("core", "DATA_CACHE_ENABLE") == None) or
    (Database.getSymbolValue("core", "INSTRUCTION_CACHE_ENABLE") == None)):
    isCachePresent = False

################################################################################
#### Business Logic ####
################################################################################

def genSysCacheFiles(symbol, event):
    symbol.setEnabled(event["value"])

def enableSysCache(symbol, event):
    component = symbol.getComponent()

    symbol.setValue(False, 1)

    # Enable Sys Cache only if Cache is present on device and enabled
    isDataCacheEnabled          = Database.getSymbolValue("core", "DATA_CACHE_ENABLE")
    isInstructionCacheEnabled   = Database.getSymbolValue("core", "INSTRUCTION_CACHE_ENABLE")

    if ((isDataCacheEnabled == True) or (isInstructionCacheEnabled == True)):
        symbol.setValue(True, 1)

############################################################################
#### Code Generation ####
############################################################################

coreArch  = Database.getSymbolValue("core", "CoreArchitecture");

genSysCacheCommonFiles = harmonyCoreComponent.createBooleanSymbol("ENABLE_SYS_CACHE", None)
genSysCacheCommonFiles.setLabel("Enable System Cache")
if (("PIC32MZ" in Variables.get("__PROCESSOR")) or ("CORTEX-M4" in coreArch)):
    genSysCacheCommonFiles.setDefaultValue(False)
elif (coreArch == "CORTEX-M0PLUS" or coreArch == "CORTEX-M23"):
    genSysCacheCommonFiles.setDefaultValue(False)
    genSysCacheCommonFiles.setVisible(False)
else:
    genSysCacheCommonFiles.setDefaultValue(isCachePresent)
genSysCacheCommonFiles.setDependencies(enableSysCache, ["ENABLE_SYS_COMMON", "core.DATA_CACHE_ENABLE", "core.INSTRUCTION_CACHE_ENABLE"])

cacheHeaderFile = harmonyCoreComponent.createFileSymbol("SYS_CACHE_HEADER", None)
cacheHeaderFile.setSourcePath("system/cache/sys_cache.h")
cacheHeaderFile.setOutputName("sys_cache.h")
cacheHeaderFile.setDestPath("system/cache/")
cacheHeaderFile.setProjectPath("config/" + configName + "/system/cache/")
cacheHeaderFile.setType("HEADER")
cacheHeaderFile.setOverwrite(True)
cacheHeaderFile.setEnabled(genSysCacheCommonFiles.getValue())
cacheHeaderFile.setDependencies(genSysCacheFiles, ["ENABLE_SYS_CACHE"])

cacheSourceFile = harmonyCoreComponent.createFileSymbol("SYS_CACHE_SOURCE", None)
if "CORTEX-A" in coreArch:
    cacheSourceFile.setSourcePath("system/cache/templates/sys_cache_cortex_a.c.ftl")
elif "CORTEX-M" in coreArch:
    cacheSourceFile.setSourcePath("system/cache/templates/sys_cache_cortex_m.c.ftl")
else:
    cacheSourceFile.setSourcePath("system/cache/templates/sys_cache_pic32mz.c.ftl")
cacheSourceFile.setOutputName("sys_cache.c")
cacheSourceFile.setDestPath("system/cache/")
cacheSourceFile.setProjectPath("config/" + configName + "/system/cache/")
cacheSourceFile.setType("SOURCE")
cacheSourceFile.setMarkup(True)
cacheSourceFile.setOverwrite(True)
cacheSourceFile.setEnabled(genSysCacheCommonFiles.getValue())
cacheSourceFile.setDependencies(genSysCacheFiles, ["ENABLE_SYS_CACHE"])

cacheSystemDefFile = harmonyCoreComponent.createFileSymbol("SYS_CACHE_DEF", None)
cacheSystemDefFile.setType("STRING")
cacheSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
cacheSystemDefFile.setSourcePath("system/cache/templates/system/definitions.h.ftl")
cacheSystemDefFile.setMarkup(True)
cacheSystemDefFile.setOverwrite(True)
cacheSystemDefFile.setEnabled(genSysCacheCommonFiles.getValue())
cacheSystemDefFile.setDependencies(genSysCacheFiles, ["ENABLE_SYS_CACHE"])
