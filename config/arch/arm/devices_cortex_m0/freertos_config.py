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

############################################################################
############## Cortex-M0+ Architecture specific configuration ##############
############################################################################

global clearFreeRTOSSymbols

global coreSymbolsCfgDict
coreSymbolsCfgDict = {}

def clearFreeRTOSSymbols():
    global coreSymbolsCfgDict

    for key in coreSymbolsCfgDict.keys():
        coreSymbolsCfgDict[key] = {"clearValue":None}

    Database.sendMessage("core", "FREERTOS_CONFIG", coreSymbolsCfgDict)


#CPU Clock Frequency
cpuclk = Database.getSymbolValue("core", "CPU_CLOCK_FREQUENCY")
cpuclk = int(cpuclk)

freeRtosSym_CpuClockHz.setDependencies(freeRtosCpuClockHz, ["core.CPU_CLOCK_FREQUENCY"])
freeRtosSym_CpuClockHz.setDefaultValue(cpuclk)

#Default Heap size
freeRtosSym_TotalHeapSize.setDefaultValue(4096)

#Number of Bits used for Priority Levels
priorityBits = int(ATDF.getNode("/avr-tools-device-file/devices/device/parameters/param@[name=\"__NVIC_PRIO_BITS\"]").getAttribute("value"))

#Setup Kernel Priority
freeRtosSym_KernelIntrPrio.setDefaultValue((2**priorityBits)-1)
freeRtosSym_KernelIntrPrio.setReadOnly(True)

#Setup Sys Call Priority
freeRtosSym_MaxSysCalIntrPrio.setDefaultValue(1)


freeRtosSym_ConfigPriorityBits.setDefaultValue(priorityBits)

#Set SysTick Priority and Lock the Priority
SysTickInterruptIndex        = Interrupt.getInterruptIndex("SysTick")
SysTickInterruptPriority     = "NVIC_"+ str(SysTickInterruptIndex) +"_0_PRIORITY"
SysTickInterruptPriorityLock = "NVIC_" + str(SysTickInterruptIndex) +"_0_PRIORITY_LOCK"

Database.clearSymbolValue("core", SysTickInterruptPriority)
Database.clearSymbolValue("core", SysTickInterruptPriorityLock)

#Set SVCall Priority and Lock the Priority
SVCallInterruptIndex        = Interrupt.getInterruptIndex("SVCall")
SVCallInterruptPriorityLock = "NVIC_" + str(SVCallInterruptIndex) +"_0_PRIORITY_LOCK"

Database.clearSymbolValue("core", SVCallInterruptPriorityLock)


coreSymbolsCfgDict[SysTickInterruptPriority] = {"setValue":"0"}
coreSymbolsCfgDict[SysTickInterruptPriorityLock] = {"setValue":True}
coreSymbolsCfgDict[SVCallInterruptPriorityLock] = {"setValue":True}

Database.sendMessage("core", "FREERTOS_CONFIG", coreSymbolsCfgDict)

############################################################################
#### Code Generation ####
############################################################################

configName  = Variables.get("__CONFIGURATION_NAME")

freeRtosdefSymCommon = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_COMMON_INCLUDE_DIRS", None)
freeRtosdefSymCommon.setCategory("C32")
freeRtosdefSymCommon.setKey("extra-include-directories")
freeRtosdefSymCommon.setValue("../src/third_party/rtos/FreeRTOS/Source/include;")
freeRtosdefSymCommon.setAppend(True, ";")

#XC32 specific symbols
freeRtosdefSymXc32 = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_INCLUDE_DIRS", None)
freeRtosdefSymXc32.setCategory("C32")
freeRtosdefSymXc32.setKey("extra-include-directories")
freeRtosdefSymXc32.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/GCC/ARM_CM0;")
freeRtosdefSymXc32.setAppend(True, ";")
freeRtosdefSymXc32.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosdefSymXc32.setEnabled(selectedCompiler == "XC32")

freeRtosdefSymXc32cpp = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32CPP_INCLUDE_DIRS", None)
freeRtosdefSymXc32cpp.setCategory("C32CPP")
freeRtosdefSymXc32cpp.setKey("extra-include-directories")
freeRtosdefSymXc32cpp.setValue(freeRtosdefSymCommon.getValue() + freeRtosdefSymXc32.getValue())
freeRtosdefSymXc32cpp.setAppend(True, ";")
freeRtosdefSymXc32cpp.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosdefSymXc32cpp.setEnabled(selectedCompiler == "XC32")

freeRtosPortSourceXc32 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_XC32_SAM_PORT_C", None)
freeRtosPortSourceXc32.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM0/port.c")
freeRtosPortSourceXc32.setOutputName("port.c")
freeRtosPortSourceXc32.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/ARM_CM0")
freeRtosPortSourceXc32.setProjectPath("FreeRTOS/Source/portable/GCC/ARM_CM0")
freeRtosPortSourceXc32.setType("SOURCE")
freeRtosPortSourceXc32.setMarkup(False)
freeRtosPortSourceXc32.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosPortSourceXc32.setEnabled(selectedCompiler == "XC32")

freeRtosPortHeaderXc32 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_XC32_SAM_PORTMACRO_H", None)
freeRtosPortHeaderXc32.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM0/portmacro.h")
freeRtosPortHeaderXc32.setOutputName("portmacro.h")
freeRtosPortHeaderXc32.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/ARM_CM0")
freeRtosPortHeaderXc32.setProjectPath("FreeRTOS/Source/portable/GCC/ARM_CM0")
freeRtosPortHeaderXc32.setType("HEADER")
freeRtosPortHeaderXc32.setMarkup(False)
freeRtosPortHeaderXc32.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosPortHeaderXc32.setEnabled(selectedCompiler == "XC32")

#IAR specific symbols
freeRtosdefSymIar = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_IAR_INCLUDE_DIRS", None)
freeRtosdefSymIar.setCategory("C32")
freeRtosdefSymIar.setKey("extra-include-directories")
freeRtosdefSymIar.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/ARM_CM0;")
freeRtosdefSymIar.setAppend(True, ";")
freeRtosdefSymIar.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosdefSymIar.setEnabled(selectedCompiler == "IAR")

freeRtosAsmdefSymIar = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_IAR_ASM_INCLUDE_DIRS", None)
freeRtosAsmdefSymIar.setCategory("C32-AS")
freeRtosAsmdefSymIar.setKey("extra-include-directories-for-assembler")
freeRtosAsmdefSymIar.setValue("../src/config/" + configName +";")
freeRtosAsmdefSymIar.setAppend(True, ";")
freeRtosAsmdefSymIar.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosAsmdefSymIar.setEnabled(selectedCompiler == "IAR")

freeRtosPortSourceIar = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_IAR_SAM_PORT_C", None)
freeRtosPortSourceIar.setSourcePath("../CMSIS-FreeRTOS/Source/portable/IAR/ARM_CM0/port.c")
freeRtosPortSourceIar.setOutputName("port.c")
freeRtosPortSourceIar.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/ARM_CM0")
freeRtosPortSourceIar.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/ARM_CM0")
freeRtosPortSourceIar.setType("SOURCE")
freeRtosPortSourceIar.setMarkup(False)
freeRtosPortSourceIar.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosPortSourceIar.setEnabled(selectedCompiler == "IAR")

freeRtosPortAsmIar = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_IAR_SAM_PORTASM_S", None)
freeRtosPortAsmIar.setSourcePath("../CMSIS-FreeRTOS/Source/portable/IAR/ARM_CM0/portasm.s")
freeRtosPortAsmIar.setOutputName("portasm.s")
freeRtosPortAsmIar.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/ARM_CM0")
freeRtosPortAsmIar.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/ARM_CM0")
freeRtosPortAsmIar.setType("SOURCE")
freeRtosPortAsmIar.setMarkup(False)
freeRtosPortAsmIar.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosPortAsmIar.setEnabled(selectedCompiler == "IAR")

freeRtosPortHeaderIar = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_IAR_SAM_PORTMACRO_H", None)
freeRtosPortHeaderIar.setSourcePath("../CMSIS-FreeRTOS/Source/portable/IAR/ARM_CM0/portmacro.h")
freeRtosPortHeaderIar.setOutputName("portmacro.h")
freeRtosPortHeaderIar.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/ARM_CM0")
freeRtosPortHeaderIar.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/ARM_CM0")
freeRtosPortHeaderIar.setType("HEADER")
freeRtosPortHeaderIar.setMarkup(False)
freeRtosPortHeaderIar.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosPortHeaderIar.setEnabled(selectedCompiler == "IAR")

#KEIL specific symbols
freeRtosdefSymKeil = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_KEIL_INCLUDE_DIRS", None)
freeRtosdefSymKeil.setCategory("C32")
freeRtosdefSymKeil.setKey("extra-include-directories")
freeRtosdefSymKeil.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/KEIL/ARM_CM0;")
freeRtosdefSymKeil.setAppend(True, ";")
freeRtosdefSymKeil.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosdefSymKeil.setEnabled(selectedCompiler == "KEIL")

freeRtosPortSourceKeil = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_KEIL_PORT_C", None)
freeRtosPortSourceKeil.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM0/port.c")
freeRtosPortSourceKeil.setOutputName("port.c")
freeRtosPortSourceKeil.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/KEIL/ARM_CM0")
freeRtosPortSourceKeil.setProjectPath("FreeRTOS/Source/portable/KEIL/ARM_CM0")
freeRtosPortSourceKeil.setType("SOURCE")
freeRtosPortSourceKeil.setMarkup(False)
freeRtosPortSourceKeil.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosPortSourceKeil.setEnabled(selectedCompiler == "KEIL")

freeRtosPortHeaderKeil = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_KEIL_PORTMACRO_H", None)
freeRtosPortHeaderKeil.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM0/portmacro.h")
freeRtosPortHeaderKeil.setOutputName("portmacro.h")
freeRtosPortHeaderKeil.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/KEIL/ARM_CM0")
freeRtosPortHeaderKeil.setProjectPath("FreeRTOS/Source/portable/KEIL/ARM_CM0")
freeRtosPortHeaderKeil.setType("HEADER")
freeRtosPortHeaderKeil.setMarkup(False)
freeRtosPortHeaderKeil.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosPortHeaderKeil.setEnabled(selectedCompiler == "KEIL")