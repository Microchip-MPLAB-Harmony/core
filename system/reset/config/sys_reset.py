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

def genResetFiles(symbol, event):
    symbol.setEnabled(event["value"])

############################################################################
#### Code Generation ####
############################################################################
genSysResetCommonFiles = harmonyCoreComponent.createBooleanSymbol("ENABLE_SYS_RESET", None)
genSysResetCommonFiles.setLabel("Enable System Reset")
genSysResetCommonFiles.setHelp(harmony_core_mcc_helpkeyword)
genSysResetCommonFiles.setDefaultValue(False)

resetHeaderFile = harmonyCoreComponent.createFileSymbol("RESET_HEADER", None)
resetHeaderFile.setSourcePath("system/reset/templates/sys_reset.h.ftl")
resetHeaderFile.setOutputName("sys_reset.h")
resetHeaderFile.setDestPath("system/reset/")
resetHeaderFile.setProjectPath("config/" + configName + "/system/reset/")
resetHeaderFile.setType("HEADER")
resetHeaderFile.setOverwrite(True)
resetHeaderFile.setEnabled(False)
resetHeaderFile.setDependencies(genResetFiles, ["ENABLE_SYS_RESET"])
resetHeaderFile.setMarkup(True)


resetHeaderMappingFile = harmonyCoreComponent.createFileSymbol("RESET_MAPPING", None)
resetHeaderMappingFile.setSourcePath("system/reset/templates/sys_reset.c.ftl")
resetHeaderMappingFile.setOutputName("sys_reset.c")
resetHeaderMappingFile.setDestPath("system/reset/")
resetHeaderMappingFile.setProjectPath("config/" + configName + "/system/reset/")
resetHeaderMappingFile.setType("SOURCE")
resetHeaderMappingFile.setOverwrite(True)
resetHeaderMappingFile.setEnabled(False)
resetHeaderMappingFile.setDependencies(genResetFiles, ["ENABLE_SYS_RESET"])
resetHeaderMappingFile.setMarkup(True)


resetSystemDefFile = harmonyCoreComponent.createFileSymbol("RESET_DEF", None)
resetSystemDefFile.setType("STRING")
resetSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
resetSystemDefFile.setSourcePath("system/reset/templates/system/definitions.h.ftl")
resetSystemDefFile.setMarkup(True)
resetSystemDefFile.setOverwrite(False)
resetSystemDefFile.setEnabled(False)
resetSystemDefFile.setDependencies(genResetFiles, ["ENABLE_SYS_RESET"])
