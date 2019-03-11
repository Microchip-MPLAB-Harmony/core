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

############################################################################
############### MIPS Architecture specific configuration ##############
############################################################################

#CPU Clock Frequency
cpuclk = Database.getSymbolValue("core", "SYS_CLK_FREQ")
cpuclk = int(cpuclk)

freeRtosSym_CpuClockHz.setDefaultValue(cpuclk)
freeRtosSym_CpuClockHz.setDependencies(freeRtosCpuClockHz, ["core.SYS_CLK_FREQ"])

perclk = Database.getSymbolValue("core", "CONFIG_SYS_CLK_PBCLK2_FREQ")
perclk = int(perclk)

freeRtosSym_PerClockHz.setDefaultValue(perclk)
freeRtosSym_PerClockHz.setDependencies(freeRtosCpuClockHz, ["core.CONFIG_SYS_CLK_PBCLK2_FREQ"])
freeRtosSym_PerClockHz.setReadOnly(True)

freeRtosSym_DynMemAloc.setReadOnly(True)

#Default Heap size
freeRtosSym_TotalHeapSize.setDefaultValue(28000)

#Setup Kernel Priority
freeRtosSym_KernelIntrPrio.setDefaultValue(1)
freeRtosSym_KernelIntrPrio.setReadOnly(True)

#Setup Sys Call Priority
freeRtosSym_MaxSysCalIntrPrio.setDefaultValue(3)

############################################################################
#### Code Generation ####
############################################################################

configName  = Variables.get("__CONFIGURATION_NAME")

freeRtosdefSym = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_INCLUDE_DIRS", None)
freeRtosdefSym.setCategory("C32")
freeRtosdefSym.setKey("extra-include-directories")
freeRtosdefSym.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MK;../src/third_party/rtos/FreeRTOS/Source/include;")
freeRtosdefSym.setAppend(True, ";")

freeRtosIncDirForAsm = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_AS_INCLUDE_DIRS", None)
freeRtosIncDirForAsm.setCategory("C32-AS")
freeRtosIncDirForAsm.setKey("extra-include-directories-for-assembler")
freeRtosIncDirForAsm.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MK;../src/third_party/rtos/FreeRTOS/Source/include;../src/config/"+ configName +";")
freeRtosIncDirForAsm.setAppend(True, ";")

freeRtosIncDirForPre = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_AS_INCLUDE_PRE_PROC_DIRS", None)
freeRtosIncDirForPre.setCategory("C32-AS")
freeRtosIncDirForPre.setKey("extra-include-directories-for-preprocessor")
freeRtosIncDirForPre.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MK;../src/third_party/rtos/FreeRTOS/Source/include;../src/config/"+ configName +";")
freeRtosIncDirForPre.setAppend(True, ";")

freeRtosPortSource = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MIPS_PORT_C", None)
freeRtosPortSource.setSourcePath("config/arch/mips/devices_pic32mk/src/PIC32MK/port.c")
freeRtosPortSource.setOutputName("port.c")
freeRtosPortSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MK")
freeRtosPortSource.setProjectPath("FreeRTOS/Source/portable/MPLAB/PIC32MK")
freeRtosPortSource.setType("SOURCE")
freeRtosPortSource.setMarkup(False)

freeRtosPortHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MIPS_PORTMACRO_H", None)
freeRtosPortHeader.setSourcePath("../CMSIS-FreeRTOS/Source/portable/MPLAB/PIC32MZ/portmacro.h")
freeRtosPortHeader.setOutputName("portmacro.h")
freeRtosPortHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MK")
freeRtosPortHeader.setProjectPath("FreeRTOS/Source/portable/MPLAB/PIC32MK")
freeRtosPortHeader.setType("HEADER")
freeRtosPortHeader.setMarkup(False)

freeRtosPortAsmSource = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MIPS_PORT_ASM_S", None)
freeRtosPortAsmSource.setSourcePath("../CMSIS-FreeRTOS/Source/portable/MPLAB/PIC32MZ/port_asm.S")
freeRtosPortAsmSource.setOutputName("port_asm.S")
freeRtosPortAsmSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MK")
freeRtosPortAsmSource.setProjectPath("FreeRTOS/Source/portable/MPLAB/PIC32MK")
freeRtosPortAsmSource.setType("SOURCE")
freeRtosPortAsmSource.setMarkup(False)

freeRtosIsrSupportHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MIPS_ISR_SUPPORT_H", None)
freeRtosIsrSupportHeader.setSourcePath("../CMSIS-FreeRTOS/Source/portable/MPLAB/PIC32MZ/ISR_Support.h")
freeRtosIsrSupportHeader.setOutputName("ISR_Support.h")
freeRtosIsrSupportHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MK")
freeRtosIsrSupportHeader.setProjectPath("FreeRTOS/Source/portable/MPLAB/PIC32MK")
freeRtosIsrSupportHeader.setType("HEADER")
freeRtosIsrSupportHeader.setMarkup(False)
