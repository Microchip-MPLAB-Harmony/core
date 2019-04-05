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

################################################################################
#### Business Logic ####
################################################################################

def enableSysInt(symbol, event):

    drv_common = Database.getSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
    sys_common = Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")

    if ((drv_common == True) or (sys_common == True)):
        symbol.setValue(True)
    else:
        symbol.setValue(False)

def genSysIntFiles(symbol, event):

    symbol.setEnabled(event["value"])

############################################################################
#### Code Generation ####
############################################################################

sysInt = harmonyCoreComponent.createBooleanSymbol("ENABLE_SYS_INT", None)
sysInt.setLabel("Enable System Interrupt")
sysInt.setDefaultValue(False)
sysInt.setDependencies(enableSysInt, ["ENABLE_DRV_COMMON", "ENABLE_SYS_COMMON"])

processor = Variables.get("__PROCESSOR")

sysIntHeaderFile = "sys_int"
sysIntCFileStem = "sys_int_nvic"

if "SAMA5" in processor or "SAM9X6" in processor:
    sysIntCFileStem = "sys_int_aic"
elif "PIC32M" in processor:
	sysIntCFileStem = "sys_int_pic32"
	sysIntHeaderFile = "sys_int_pic32"

intHeaderFile = harmonyCoreComponent.createFileSymbol("INT_HEADER", None)
intHeaderFile.setSourcePath("system/int/" + sysIntHeaderFile + ".h")
intHeaderFile.setOutputName("sys_int.h")
intHeaderFile.setDestPath("system/int/")
intHeaderFile.setProjectPath("config/" + configName + "/system/int/")
intHeaderFile.setType("HEADER")
intHeaderFile.setOverwrite(True)
intHeaderFile.setEnabled(False)
intHeaderFile.setDependencies(genSysIntFiles, ["ENABLE_SYS_INT"])

intHeaderMappingFile = harmonyCoreComponent.createFileSymbol("INT_MAPPING", None)
intHeaderMappingFile.setSourcePath("system/int/templates/sys_int_mapping.h.ftl")
intHeaderMappingFile.setOutputName("sys_int_mapping.h")
intHeaderMappingFile.setDestPath("system/int/")
intHeaderMappingFile.setProjectPath("config/" + configName + "/system/int/")
intHeaderMappingFile.setType("HEADER")
intHeaderMappingFile.setMarkup(True)
intHeaderMappingFile.setOverwrite(True)
intHeaderMappingFile.setEnabled(False)
intHeaderMappingFile.setDependencies(genSysIntFiles, ["ENABLE_SYS_INT"])

intSourceFile = harmonyCoreComponent.createFileSymbol("INT_SOURCE", None)
intSourceFile.setSourcePath("system/int/src/" + sysIntCFileStem + ".c")
intSourceFile.setOutputName("sys_int.c")
intSourceFile.setDestPath("system/int/src/")
intSourceFile.setProjectPath("config/" + configName + "/system/int/")
intSourceFile.setType("SOURCE")
intSourceFile.setMarkup(False)
intSourceFile.setOverwrite(True)
intSourceFile.setEnabled(False)
intSourceFile.setDependencies(genSysIntFiles, ["ENABLE_SYS_INT"])

intSystemDefFile = harmonyCoreComponent.createFileSymbol("INT_DEF", None)
intSystemDefFile.setType("STRING")
intSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
intSystemDefFile.setSourcePath("system/int/templates/system/system_definitions.h.ftl")
intSystemDefFile.setMarkup(True)
intSystemDefFile.setOverwrite(True)
intSystemDefFile.setEnabled(False)
intSystemDefFile.setDependencies(genSysIntFiles, ["ENABLE_SYS_INT"])
