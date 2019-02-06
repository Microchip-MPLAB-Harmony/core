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

def genDmaHeaderFile(symbol, event):

    symbol.setEnabled(event["value"])

def genDmaHeaderMappingFile(symbol, event):

    symbol.setEnabled(event["value"])

def genDmaSystemDefFile(symbol, event):

    symbol.setEnabled(event["value"])

def enableDependencySymbols(symbol, event):

    Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", event["value"], 1)

############################################################################
#### Code Generation ####
############################################################################

deviceFile = ""

if("PIC32M" in Variables.get("__PROCESSOR")):
    deviceFile = "_pic32m"

genSysDMACommonFiles = harmonyCoreComponent.createBooleanSymbol("ENABLE_SYS_DMA", None)
genSysDMACommonFiles.setLabel("Enable System DMA")

enableDependency = harmonyCoreComponent.createBooleanSymbol("ENABLE_SYS_DMA_DEPENDENCY", None)
enableDependency.setLabel("Enable System DMA Dependencies")
enableDependency.setVisible(False)
enableDependency.setDependencies(enableDependencySymbols, ["ENABLE_SYS_DMA"])

dmaHeaderFile = harmonyCoreComponent.createFileSymbol("DMA_HEADER", None)
dmaHeaderFile.setSourcePath("system/dma/templates/sys_dma" + deviceFile + ".h.ftl")
dmaHeaderFile.setOutputName("sys_dma.h")
dmaHeaderFile.setDestPath("system/dma/")
dmaHeaderFile.setProjectPath("config/" + configName + "/system/dma/")
dmaHeaderFile.setType("HEADER")
dmaHeaderFile.setMarkup(True)
dmaHeaderFile.setOverwrite(True)
dmaHeaderFile.setEnabled(False)
dmaHeaderFile.setDependencies(genDmaHeaderFile, ["ENABLE_SYS_DMA"])

dmaSourceFile = harmonyCoreComponent.createFileSymbol("DMA_SOURCE", None)
dmaSourceFile.setSourcePath("system/dma/templates/sys_dma" + deviceFile + ".c.ftl")
dmaSourceFile.setOutputName("sys_dma.c")
dmaSourceFile.setDestPath("system/dma/")
dmaSourceFile.setProjectPath("config/" + configName + "/system/dma/")
dmaSourceFile.setType("SOURCE")
dmaSourceFile.setMarkup(True)
dmaSourceFile.setOverwrite(True)
dmaSourceFile.setEnabled(False)
dmaSourceFile.setDependencies(genDmaHeaderFile, ["ENABLE_SYS_DMA"])

dmaHeaderMappingFile = harmonyCoreComponent.createFileSymbol("DMA_MAPPING", None)
dmaHeaderMappingFile.setSourcePath("system/dma/templates/sys_dma_mapping" + deviceFile + ".h.ftl")
dmaHeaderMappingFile.setOutputName("sys_dma_mapping.h")
dmaHeaderMappingFile.setDestPath("system/dma/")
dmaHeaderMappingFile.setProjectPath("config/" + configName + "/system/dma/")
dmaHeaderMappingFile.setType("HEADER")
dmaHeaderMappingFile.setMarkup(True)
dmaHeaderMappingFile.setOverwrite(True)
dmaHeaderMappingFile.setEnabled(False)
dmaHeaderMappingFile.setDependencies(genDmaHeaderMappingFile, ["ENABLE_SYS_DMA"])

dmaSystemDefFile = harmonyCoreComponent.createFileSymbol("DMA_DEF", None)
dmaSystemDefFile.setType("STRING")
dmaSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
dmaSystemDefFile.setSourcePath("system/dma/templates/system/system_definitions.h.ftl")
dmaSystemDefFile.setMarkup(True)
dmaSystemDefFile.setOverwrite(True)
dmaSystemDefFile.setEnabled(False)
dmaSystemDefFile.setDependencies(genDmaSystemDefFile, ["ENABLE_SYS_DMA"])


