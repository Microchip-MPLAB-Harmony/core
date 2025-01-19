# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2025 Microchip Technology Inc. and its subsidiaries.
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
############ PIC32A/dsPIC33A Architecture specific configuration ###########
############################################################################

#TIMER1 Clock Frequency
perclk = Database.getSymbolValue("core", "stdSpeedClkFreq")
perclk = int(perclk)

freeRtosSym_PerClockHz.setDefaultValue(perclk)
freeRtosSym_PerClockHz.setDependencies(freeRtosCpuClockHz, ["core.stdSpeedClkFreq"])
freeRtosSym_PerClockHz.setReadOnly(True)

freeRtosSym_DynMemAloc.setReadOnly(True)

#Default Heap size
freeRtosSym_TotalHeapSize.setDefaultValue(8192)

#Setup Kernel Priority
freeRtosSym_KernelIntrPrio.setDefaultValue(1)
freeRtosSym_KernelIntrPrio.setReadOnly(True)

#Setup Sys Call Priority
freeRtosSym_MaxSysCalIntrPrio.setDefaultValue(3)

############################################################################
#### Code Generation ####
############################################################################

configName  = Variables.get("__CONFIGURATION_NAME")

freeRtosTaskHeader.setSourcePath("config/arch/pic32a/devices_pic32a/src/task.h")

freeRtosdefSym = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_INCLUDE_DIRS", None)
if (coreArch == "dsPIC33A"):
    freeRtosdefSym.setCategory("C30")
else:
    freeRtosdefSym.setCategory("C32")
freeRtosdefSym.setKey("extra-include-directories")
freeRtosdefSym.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/MPLAB/" + coreArch + ";../src/third_party/rtos/FreeRTOS/Source/include;")
freeRtosdefSym.setAppend(True, ";")

if (coreArch == "PIC32A"):
    freeRtosdefXc32cppSym = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32CPP_INCLUDE_DIRS", None)
    freeRtosdefXc32cppSym.setCategory("C32CPP")
    freeRtosdefXc32cppSym.setKey("extra-include-directories")
    freeRtosdefXc32cppSym.setValue(freeRtosdefSym.getValue())
    freeRtosdefXc32cppSym.setAppend(True, ";")

freeRtosIncDirForAsm = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_AS_INCLUDE_DIRS", None)
if (coreArch == "dsPIC33A"):
    freeRtosIncDirForAsm.setCategory("C30-AS")
else:
    freeRtosIncDirForAsm.setCategory("C32-AS")
freeRtosIncDirForAsm.setKey("extra-include-directories-for-assembler")
freeRtosIncDirForAsm.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/MPLAB/" + coreArch + ";../src/third_party/rtos/FreeRTOS/Source/include;../src/config/"+ configName +";")
freeRtosIncDirForAsm.setAppend(True, ";")

freeRtosIncDirForPre = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_AS_INCLUDE_PRE_PROC_DIRS", None)
if (coreArch == "dsPIC33A"):
    freeRtosIncDirForPre.setCategory("C30-AS")
else:
    freeRtosIncDirForPre.setCategory("C32-AS")
freeRtosIncDirForPre.setKey("extra-include-directories-for-preprocessor")
freeRtosIncDirForPre.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/MPLAB/" + coreArch + ";../src/third_party/rtos/FreeRTOS/Source/include;../src/config/"+ configName +";")
freeRtosIncDirForPre.setAppend(True, ";")

freeRtosPortSource = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_PIC32A_PORT_C", None)
freeRtosPortSource.setSourcePath("config/arch/pic32a/devices_pic32a/src/PIC32A/port.c")
freeRtosPortSource.setOutputName("port.c")
freeRtosPortSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/" + coreArch)
freeRtosPortSource.setProjectPath("FreeRTOS/Source/portable/MPLAB/" + coreArch)
freeRtosPortSource.setType("SOURCE")
freeRtosPortSource.setMarkup(False)

freeRtosPortHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_PIC32A_PORTMACRO_H", None)
freeRtosPortHeader.setSourcePath("config/arch/pic32a/devices_pic32a/src/PIC32A/portmacro.h")
freeRtosPortHeader.setOutputName("portmacro.h")
freeRtosPortHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/" + coreArch)
freeRtosPortHeader.setProjectPath("FreeRTOS/Source/portable/MPLAB/" + coreArch)
freeRtosPortHeader.setType("HEADER")
freeRtosPortHeader.setMarkup(False)
