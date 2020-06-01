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
global osalSelectRTOS
global osalHeaderFile
global osalHeaderDefFile
global osalHeaderImpBasicFile
global osalHeaderFreeRtosFile
global osalSourceFreeRtosFile
global osalHeaderMicriumOSIIIFile
global osalSourceMicriumOSIIIFile
global osalHeaderThreadXOSIIIFile
global osalSourceThreadXOSIIIFile
global osalSystemDefFile
global osalHeaderMbedOSFile
global osalSourceMbedOSFile

def enableOSAL(symbol, event):
    drv_common = Database.getSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
    sys_common = Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")

    if ((drv_common == True) or (sys_common == True)):
        symbol.setValue(True)
    else:
        symbol.setValue(False)

def genOsalFiles(symbol, event):
    global osalSelectRTOS
    global osalHeaderFile
    global osalHeaderDefFile
    global osalHeaderImpBasicFile
    global osalHeaderFreeRtosFile
    global osalSourceFreeRtosFile
    global osalHeaderMicriumOSIIIFile
    global osalSourceMicriumOSIIIFile
    global osalSystemDefFile
    global osalHeaderMbedOSFile
    global osalSourceMbedOSFile

    genOsal = Database.getSymbolValue("HarmonyCore", "ENABLE_OSAL")

    if (genOsal == True):
        osalHeaderFile.setEnabled(True)
        osalHeaderDefFile.setEnabled(True)
        osalSystemDefFile.setEnabled(True)
        osalHeaderImpBasicFile.setEnabled(osalSelectRTOS.getValue() == "BareMetal")
        osalHeaderFreeRtosFile.setEnabled(osalSelectRTOS.getValue() == "FreeRTOS")
        osalSourceFreeRtosFile.setEnabled(osalSelectRTOS.getValue() == "FreeRTOS")
        osalHeaderMicriumOSIIIFile.setEnabled(osalSelectRTOS.getValue() == "MicriumOSIII")
        osalSourceMicriumOSIIIFile.setEnabled(osalSelectRTOS.getValue() == "MicriumOSIII")
        osalHeaderThreadXOSIIIFile.setEnabled(osalSelectRTOS.getValue() == "ThreadX")
        osalSourceThreadXOSIIIFile.setEnabled(osalSelectRTOS.getValue() == "ThreadX")
        osalHeaderMbedOSFile.setEnabled(osalSelectRTOS.getValue() == "MbedOS")
        osalSourceMbedOSFile.setEnabled(osalSelectRTOS.getValue() == "MbedOS")
    else:
        osalHeaderFile.setEnabled(False)
        osalHeaderDefFile.setEnabled(False)
        osalHeaderImpBasicFile.setEnabled(False)
        osalHeaderFreeRtosFile.setEnabled(False)
        osalSourceFreeRtosFile.setEnabled(False)
        osalHeaderMicriumOSIIIFile.setEnabled(False)
        osalSourceMicriumOSIIIFile.setEnabled(False)
        osalHeaderThreadXOSIIIFile.setEnabled(False)
        osalSourceThreadXOSIIIFile.setEnabled(False)
        osalSystemDefFile.setEnabled(False)
        osalHeaderMbedOSFile.setEnabled(False)
        osalSourceMbedOSFile.setEnabled(False)

############################################################################
#### Code Generation ####
############################################################################
osal = harmonyCoreComponent.createBooleanSymbol("ENABLE_OSAL", None)
osal.setLabel("Enable OSAL")
osal.setDefaultValue(False)
osal.setDependencies(enableOSAL, ["ENABLE_DRV_COMMON", "ENABLE_SYS_COMMON"])


osalSelectRTOS = harmonyCoreComponent.createComboSymbol("SELECT_RTOS", None, ["BareMetal", "FreeRTOS", "MicriumOSIII", "ThreadX", "MbedOS"])
osalSelectRTOS.setLabel("Select any RTOS or Bare-metal")
osalSelectRTOS.setDefaultValue("BareMetal")
osalSelectRTOS.setReadOnly(True)
osalSelectRTOS.setVisible(False)

# OSAL RTOS Configuration
osalHeaderFile = harmonyCoreComponent.createFileSymbol("OSAL_H", None)
osalHeaderFile.setSourcePath("osal/osal.h")
osalHeaderFile.setOutputName("osal.h")
osalHeaderFile.setDestPath("osal/")
osalHeaderFile.setProjectPath("config/" + configName + "/osal/")
osalHeaderFile.setType("HEADER")
osalHeaderFile.setOverwrite(True)
osalHeaderFile.setEnabled(False)

osalHeaderDefFile = harmonyCoreComponent.createFileSymbol("OSAL_DEFINITIONS_H", None)
osalHeaderDefFile.setSourcePath("osal/templates/osal_definitions.h.ftl")
osalHeaderDefFile.setOutputName("osal_definitions.h")
osalHeaderDefFile.setDestPath("osal/")
osalHeaderDefFile.setProjectPath("config/" + configName + "/osal/")
osalHeaderDefFile.setType("HEADER")
osalHeaderDefFile.setOverwrite(True)
osalHeaderDefFile.setMarkup(True)
osalHeaderDefFile.setEnabled(False)

osalHeaderImpBasicFile = harmonyCoreComponent.createFileSymbol("OSAL_IMPL_BASIC_H", None)
osalHeaderImpBasicFile.setSourcePath("osal/osal_impl_basic.h")
osalHeaderImpBasicFile.setOutputName("osal_impl_basic.h")
osalHeaderImpBasicFile.setDestPath("osal/")
osalHeaderImpBasicFile.setProjectPath("config/" + configName + "/osal/")
osalHeaderImpBasicFile.setType("HEADER")
osalHeaderImpBasicFile.setOverwrite(True)
osalHeaderImpBasicFile.setEnabled(False)
osalHeaderImpBasicFile.setDependencies(genOsalFiles, ["ENABLE_OSAL", "SELECT_RTOS"])

osalHeaderFreeRtosFile = harmonyCoreComponent.createFileSymbol("OSAL_FREERTOS_H", None)
osalHeaderFreeRtosFile.setSourcePath("osal/osal_freertos.h")
osalHeaderFreeRtosFile.setOutputName("osal_freertos.h")
osalHeaderFreeRtosFile.setDestPath("osal/")
osalHeaderFreeRtosFile.setProjectPath("config/" + configName + "/osal/")
osalHeaderFreeRtosFile.setType("HEADER")
osalHeaderFreeRtosFile.setOverwrite(True)
osalHeaderFreeRtosFile.setEnabled(False)

osalSourceFreeRtosFile = harmonyCoreComponent.createFileSymbol("OSAL_FREERTOS_C", None)
osalSourceFreeRtosFile.setSourcePath("osal/src/osal_freertos.c")
osalSourceFreeRtosFile.setOutputName("osal_freertos.c")
osalSourceFreeRtosFile.setDestPath("osal/")
osalSourceFreeRtosFile.setProjectPath("config/" + configName + "/osal/")
osalSourceFreeRtosFile.setType("SOURCE")
osalSourceFreeRtosFile.setOverwrite(True)
osalSourceFreeRtosFile.setEnabled(False)

osalHeaderMicriumOSIIIFile = harmonyCoreComponent.createFileSymbol("OSAL_MICRIUM_OS_III_H", None)
osalHeaderMicriumOSIIIFile.setSourcePath("osal/templates/osal_ucos3.h.ftl")
osalHeaderMicriumOSIIIFile.setOutputName("osal_ucos3.h")
osalHeaderMicriumOSIIIFile.setDestPath("osal/")
osalHeaderMicriumOSIIIFile.setProjectPath("config/" + configName + "/osal/")
osalHeaderMicriumOSIIIFile.setType("HEADER")
osalHeaderMicriumOSIIIFile.setOverwrite(True)
osalHeaderMicriumOSIIIFile.setEnabled(False)
osalHeaderMicriumOSIIIFile.setMarkup(True)

osalSourceMicriumOSIIIFile = harmonyCoreComponent.createFileSymbol("OSAL_MICRIUM_OS_III_C", None)
osalSourceMicriumOSIIIFile.setSourcePath("osal/templates/osal_ucos3.c.ftl")
osalSourceMicriumOSIIIFile.setOutputName("osal_ucos3.c")
osalSourceMicriumOSIIIFile.setDestPath("osal/")
osalSourceMicriumOSIIIFile.setProjectPath("config/" + configName + "/osal/")
osalSourceMicriumOSIIIFile.setType("SOURCE")
osalSourceMicriumOSIIIFile.setOverwrite(True)
osalSourceMicriumOSIIIFile.setEnabled(False)
osalSourceMicriumOSIIIFile.setMarkup(True)

osalHeaderThreadXOSIIIFile = harmonyCoreComponent.createFileSymbol("OSAL_THREADX_OS_III_H", None)
osalHeaderThreadXOSIIIFile.setSourcePath("osal/templates/osal_threadx.h.ftl")
osalHeaderThreadXOSIIIFile.setOutputName("osal_threadx.h")
osalHeaderThreadXOSIIIFile.setDestPath("osal/")
osalHeaderThreadXOSIIIFile.setProjectPath("config/" + configName + "/osal/")
osalHeaderThreadXOSIIIFile.setType("HEADER")
osalHeaderThreadXOSIIIFile.setOverwrite(True)
osalHeaderThreadXOSIIIFile.setEnabled(False)
osalHeaderThreadXOSIIIFile.setMarkup(True)

osalSourceThreadXOSIIIFile = harmonyCoreComponent.createFileSymbol("OSAL_THREADX_OS_III_C", None)
osalSourceThreadXOSIIIFile.setSourcePath("osal/templates/osal_threadx.c.ftl")
osalSourceThreadXOSIIIFile.setOutputName("osal_threadx.c")
osalSourceThreadXOSIIIFile.setDestPath("osal/")
osalSourceThreadXOSIIIFile.setProjectPath("config/" + configName + "/osal/")
osalSourceThreadXOSIIIFile.setType("SOURCE")
osalSourceThreadXOSIIIFile.setOverwrite(True)
osalSourceThreadXOSIIIFile.setEnabled(False)
osalSourceThreadXOSIIIFile.setMarkup(True)

osalHeaderMbedOSFile = harmonyCoreComponent.createFileSymbol("OSAL_MBEDOS_H", None)
osalHeaderMbedOSFile.setSourcePath("/osal/templates/osal_mbedos.h.ftl")
osalHeaderMbedOSFile.setOutputName("osal_mbedos.h")
osalHeaderMbedOSFile.setDestPath("osal/")
osalHeaderMbedOSFile.setProjectPath("config/" + configName + "/osal/")
osalHeaderMbedOSFile.setType("HEADER")
osalHeaderMbedOSFile.setOverwrite(True)
osalHeaderMbedOSFile.setEnabled(False)
osalHeaderMbedOSFile.setMarkup(True)

osalSourceMbedOSFile = harmonyCoreComponent.createFileSymbol("OSAL_MBEDOS_CPP", None)
osalSourceMbedOSFile.setSourcePath("/osal/templates/osal_mbedos.cpp.ftl")
osalSourceMbedOSFile.setOutputName("osal_mbedos.cpp")
osalSourceMbedOSFile.setDestPath("osal/")
osalSourceMbedOSFile.setProjectPath("config/" + configName + "/osal/")
osalSourceMbedOSFile.setType("SOURCE")
osalSourceMbedOSFile.setOverwrite(True)
osalSourceMbedOSFile.setEnabled(False)
osalSourceMbedOSFile.setMarkup(True)

osalSystemDefFile = harmonyCoreComponent.createFileSymbol("OSAL_SYSDEF_H", None)
osalSystemDefFile.setType("STRING")
osalSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
osalSystemDefFile.setSourcePath("osal/templates/system/system_definitions.h.ftl")
osalSystemDefFile.setMarkup(True)
osalSystemDefFile.setOverwrite(False)
osalSystemDefFile.setEnabled(False)
