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
############### Cortex-M7 Architecture specific configuration ##############
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
freeRtosSym_TotalHeapSize.setDefaultValue(40960)

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

coreSymbolsCfgDict[SysTickInterruptPriority] = {"setValue":"7"}
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
freeRtosdefSymXc32.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/GCC/SAM/CM7;")
freeRtosdefSymXc32.setAppend(True, ";")
freeRtosdefSymXc32.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosdefSymXc32.setEnabled(selectedCompiler == "XC32" and freeRtosSymMenu_MPUPortOptions.getValue() == False)

freeRtosdefSymMPUPortXc32 = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_MPU_PORT_INCLUDE_DIRS", None)
freeRtosdefSymMPUPortXc32.setCategory("C32")
freeRtosdefSymMPUPortXc32.setKey("extra-include-directories")
freeRtosdefSymMPUPortXc32.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/GCC/SAM/ARM_CM4_MPU;")
freeRtosdefSymMPUPortXc32.setAppend(True, ";")
freeRtosdefSymMPUPortXc32.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE', "FreeRTOS.FREERTOS_MPU_PORT_ENABLE"])
freeRtosdefSymMPUPortXc32.setEnabled(selectedCompiler == "XC32" and freeRtosSymMenu_MPUPortOptions.getValue() == True)

freeRtosdefSymXc32cpp = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32CPP_INCLUDE_DIRS", None)
freeRtosdefSymXc32cpp.setCategory("C32CPP")
freeRtosdefSymXc32cpp.setKey("extra-include-directories")
freeRtosdefSymXc32cpp.setValue(freeRtosdefSymCommon.getValue() + freeRtosdefSymXc32.getValue())
freeRtosdefSymXc32cpp.setAppend(True, ";")
freeRtosdefSymXc32cpp.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosdefSymXc32cpp.setEnabled(selectedCompiler == "XC32")

freeRtosPortSourceXc32 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_XC32_SAM_PORT_C", None)
freeRtosPortSourceXc32.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM7/r0p1/port.c")
freeRtosPortSourceXc32.setOutputName("port.c")
freeRtosPortSourceXc32.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/SAM/CM7")
freeRtosPortSourceXc32.setProjectPath("FreeRTOS/Source/portable/GCC/SAM/CM7")
freeRtosPortSourceXc32.setType("SOURCE")
freeRtosPortSourceXc32.setMarkup(False)
freeRtosPortSourceXc32.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE', "FreeRTOS.FREERTOS_MPU_PORT_ENABLE"])
freeRtosPortSourceXc32.setEnabled(selectedCompiler == "XC32" and freeRtosSymMenu_MPUPortOptions.getValue() == False)

freeRtosPortSourceXc32MPU = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_XC32_SAM_MPU_PORT_C", None)
freeRtosPortSourceXc32MPU.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM4_MPU/port.c")
freeRtosPortSourceXc32MPU.setOutputName("port.c")
freeRtosPortSourceXc32MPU.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/SAM/ARM_CM4_MPU")
freeRtosPortSourceXc32MPU.setProjectPath("FreeRTOS/Source/portable/GCC/SAM/ARM_CM4_MPU")
freeRtosPortSourceXc32MPU.setType("SOURCE")
freeRtosPortSourceXc32MPU.setMarkup(False)
freeRtosPortSourceXc32MPU.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE', "FreeRTOS.FREERTOS_MPU_PORT_ENABLE"])
freeRtosPortSourceXc32MPU.setEnabled(selectedCompiler == "XC32" and freeRtosSymMenu_MPUPortOptions.getValue() == True)

freeRtosPortHeaderXc32 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_XC32_SAM_PORTMACRO_H", None)
freeRtosPortHeaderXc32.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM7/r0p1/portmacro.h")
freeRtosPortHeaderXc32.setOutputName("portmacro.h")
freeRtosPortHeaderXc32.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/SAM/CM7")
freeRtosPortHeaderXc32.setProjectPath("FreeRTOS/Source/portable/GCC/SAM/CM7")
freeRtosPortHeaderXc32.setType("HEADER")
freeRtosPortHeaderXc32.setMarkup(False)
freeRtosPortHeaderXc32.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE', "FreeRTOS.FREERTOS_MPU_PORT_ENABLE"])
freeRtosPortHeaderXc32.setEnabled(selectedCompiler == "XC32" and freeRtosSymMenu_MPUPortOptions.getValue() == False)

freeRtosPortHeaderXc32MPU = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_XC32_SAM_MPU_PORTMACRO_H", None)
freeRtosPortHeaderXc32MPU.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM4_MPU/portmacro.h")
freeRtosPortHeaderXc32MPU.setOutputName("portmacro.h")
freeRtosPortHeaderXc32MPU.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/SAM/ARM_CM4_MPU")
freeRtosPortHeaderXc32MPU.setProjectPath("FreeRTOS/Source/portable/GCC/SAM/ARM_CM4_MPU")
freeRtosPortHeaderXc32MPU.setType("HEADER")
freeRtosPortHeaderXc32MPU.setMarkup(False)
freeRtosPortHeaderXc32MPU.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE', "FreeRTOS.FREERTOS_MPU_PORT_ENABLE"])
freeRtosPortHeaderXc32MPU.setEnabled(selectedCompiler == "XC32" and freeRtosSymMenu_MPUPortOptions.getValue() == True)

freeRtosPortSourceXc32MPUWrappers = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_XC32_SAM_MPU_WRAPPERS_C", None)
freeRtosPortSourceXc32MPUWrappers.setSourcePath("../CMSIS-FreeRTOS/Source/portable/Common/mpu_wrappers.c")
freeRtosPortSourceXc32MPUWrappers.setOutputName("mpu_wrappers.c")
freeRtosPortSourceXc32MPUWrappers.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/Common")
freeRtosPortSourceXc32MPUWrappers.setProjectPath("FreeRTOS/Source/portable/GCC")
freeRtosPortSourceXc32MPUWrappers.setType("SOURCE")
freeRtosPortSourceXc32MPUWrappers.setMarkup(False)
freeRtosPortSourceXc32MPUWrappers.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE', "FreeRTOS.FREERTOS_MPU_PORT_ENABLE"])
freeRtosPortSourceXc32MPUWrappers.setEnabled(selectedCompiler == "XC32" and freeRtosSymMenu_MPUPortOptions.getValue() == True)

#IAR specific symbols
freeRtosdefSymIar = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_IAR_INCLUDE_DIRS", None)
freeRtosdefSymIar.setCategory("C32")
freeRtosdefSymIar.setKey("extra-include-directories")
freeRtosdefSymIar.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/CM7;")
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
freeRtosPortSourceIar.setSourcePath("../CMSIS-FreeRTOS/Source/portable/IAR/ARM_CM7/r0p1/port.c")
freeRtosPortSourceIar.setOutputName("port.c")
freeRtosPortSourceIar.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/CM7")
freeRtosPortSourceIar.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/CM7")
freeRtosPortSourceIar.setType("SOURCE")
freeRtosPortSourceIar.setMarkup(False)
freeRtosPortSourceIar.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosPortSourceIar.setEnabled(selectedCompiler == "IAR")

freeRtosPortAsmIar = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_IAR_SAM_PORTASM_S", None)
freeRtosPortAsmIar.setSourcePath("../CMSIS-FreeRTOS/Source/portable/IAR/ARM_CM7/r0p1/portasm.s")
freeRtosPortAsmIar.setOutputName("portasm.s")
freeRtosPortAsmIar.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/CM7")
freeRtosPortAsmIar.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/CM7")
freeRtosPortAsmIar.setType("SOURCE")
freeRtosPortAsmIar.setMarkup(False)
freeRtosPortAsmIar.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosPortAsmIar.setEnabled(selectedCompiler == "IAR")

freeRtosPortHeaderIar = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_IAR_SAM_PORTMACRO_H", None)
freeRtosPortHeaderIar.setSourcePath("../CMSIS-FreeRTOS/Source/portable/IAR/ARM_CM7/r0p1/portmacro.h")
freeRtosPortHeaderIar.setOutputName("portmacro.h")
freeRtosPortHeaderIar.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/CM7")
freeRtosPortHeaderIar.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/CM7")
freeRtosPortHeaderIar.setType("HEADER")
freeRtosPortHeaderIar.setMarkup(False)
freeRtosPortHeaderIar.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosPortHeaderIar.setEnabled(selectedCompiler == "IAR")

#KEIL specific symbols
freeRtosdefSymKeil = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_KEIL_INCLUDE_DIRS", None)
freeRtosdefSymKeil.setCategory("C32")
freeRtosdefSymKeil.setKey("extra-include-directories")
freeRtosdefSymKeil.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/KEIL/CM7;")
freeRtosdefSymKeil.setAppend(True, ";")
freeRtosdefSymKeil.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosdefSymKeil.setEnabled(selectedCompiler == "KEIL")

freeRtosPortSourceKeil = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_KEIL_PORT_C", None)
freeRtosPortSourceKeil.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM7/r0p1/port.c")
freeRtosPortSourceKeil.setOutputName("port.c")
freeRtosPortSourceKeil.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/KEIL/CM7")
freeRtosPortSourceKeil.setProjectPath("FreeRTOS/Source/portable/KEIL/CM7")
freeRtosPortSourceKeil.setType("SOURCE")
freeRtosPortSourceKeil.setMarkup(False)
freeRtosPortSourceKeil.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosPortSourceKeil.setEnabled(selectedCompiler == "KEIL")

freeRtosPortHeaderKeil = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_SAM_PORTMACRO_H", None)
freeRtosPortHeaderKeil.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM7/r0p1/portmacro.h")
freeRtosPortHeaderKeil.setOutputName("portmacro.h")
freeRtosPortHeaderKeil.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/KEIL/CM7")
freeRtosPortHeaderKeil.setProjectPath("FreeRTOS/Source/portable/KEIL/CM7")
freeRtosPortHeaderKeil.setType("HEADER")
freeRtosPortHeaderKeil.setMarkup(False)
freeRtosPortHeaderKeil.setDependencies(activateCompilerSymbol, ['core.COMPILER_CHOICE'])
freeRtosPortHeaderKeil.setEnabled(selectedCompiler == "KEIL")

execfile(Module.getPath() + "config/arch/arm/freertos_mpu_support/freertos_mpu_linker.py")