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

def genPortsHeaderFile(symbol, event):
    symbol.setEnabled(event["value"])

def genPortsHeaderMappingFile(symbol, event):
    symbol.setEnabled(event["value"])

def genPortsSystemDefFile(symbol, event):
    symbol.setEnabled(event["value"])

############################################################################
#### Code Generation ####
############################################################################
genSysPortsCommonFiles = harmonyCoreComponent.createBooleanSymbol("ENABLE_SYS_PORTS", coreMenu)
genSysPortsCommonFiles.setLabel("Enable System Ports")
genSysPortsCommonFiles.setDefaultValue(False)

portsHeaderFile = harmonyCoreComponent.createFileSymbol("PORTS_HEADER", None)
portsHeaderFile.setSourcePath("system/ports/templates/sys_ports.h.ftl")
portsHeaderFile.setOutputName("sys_ports.h")
portsHeaderFile.setDestPath("system/ports/")
portsHeaderFile.setProjectPath("config/" + configName + "/system/ports/")
portsHeaderFile.setType("HEADER")
portsHeaderFile.setOverwrite(True)
portsHeaderFile.setEnabled(False)
portsHeaderFile.setDependencies(genPortsHeaderFile, ["ENABLE_SYS_PORTS"])
portsHeaderFile.setMarkup(True)


portsHeaderMappingFile = harmonyCoreComponent.createFileSymbol("PORTS_MAPPING", None)
portsHeaderMappingFile.setSourcePath("system/ports/templates/sys_ports_mapping.h.ftl")
portsHeaderMappingFile.setOutputName("sys_ports_mapping.h")
portsHeaderMappingFile.setDestPath("system/ports/")
portsHeaderMappingFile.setProjectPath("config/" + configName + "/system/ports/")
portsHeaderMappingFile.setType("HEADER")
portsHeaderMappingFile.setOverwrite(True)
portsHeaderMappingFile.setEnabled(False)
portsHeaderMappingFile.setDependencies(genPortsHeaderMappingFile, ["ENABLE_SYS_PORTS"])
portsHeaderMappingFile.setMarkup(True)


portsSystemDefFile = harmonyCoreComponent.createFileSymbol("PORTS_DEF", None)
portsSystemDefFile.setType("STRING")
portsSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
portsSystemDefFile.setSourcePath("system/ports/templates/system/definitions.h.ftl")
portsSystemDefFile.setMarkup(True)
portsSystemDefFile.setOverwrite(True)
portsSystemDefFile.setEnabled(False)
portsSystemDefFile.setDependencies(genPortsSystemDefFile, ["ENABLE_SYS_PORTS"])
