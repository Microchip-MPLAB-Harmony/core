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

#Default Heap size
freeRtosSym_TotalHeapSize.setDefaultValue(4096)

#Set SysTick Priority and Lock the Priority
SysTickInterruptIndex        = Interrupt.getInterruptIndex("SysTick")
SysTickInterruptPriority     = "NVIC_"+ str(SysTickInterruptIndex) +"_0_PRIORITY"
SysTickInterruptPriorityLock = "NVIC_" + str(SysTickInterruptIndex) +"_0_PRIORITY_LOCK"

Database.clearSymbolValue("core", SysTickInterruptPriority)
Database.setSymbolValue("core", SysTickInterruptPriority, "0", 2)
Database.clearSymbolValue("core", SysTickInterruptPriorityLock)
Database.setSymbolValue("core", SysTickInterruptPriorityLock, True, 2)

#Set SVCall Priority and Lock the Priority
SVCallInterruptIndex        = Interrupt.getInterruptIndex("SVCall")
SVCallInterruptPriorityLock = "NVIC_" + str(SVCallInterruptIndex) +"_0_PRIORITY_LOCK"

Database.clearSymbolValue("core", SVCallInterruptPriorityLock)
Database.setSymbolValue("core", SVCallInterruptPriorityLock, True, 2)

############################################################################
#### Code Generation ####
############################################################################

configName  = Variables.get("__CONFIGURATION_NAME")

freeRtosdefSym = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_INCLUDE_DIRS", None)
freeRtosdefSym.setCategory("C32")
freeRtosdefSym.setKey("extra-include-directories")
freeRtosdefSym.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/GCC/ARM_CM0;../src/third_party/rtos/FreeRTOS/Source/include;")
freeRtosdefSym.setAppend(True, ";")

freeRtosPortSource = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_SAM_PORT_C", None)
freeRtosPortSource.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM0/port.c")
freeRtosPortSource.setOutputName("port.c")
freeRtosPortSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/ARM_CM0")
freeRtosPortSource.setProjectPath("FreeRTOS/Source/portable/GCC/ARM_CM0")
freeRtosPortSource.setType("SOURCE")
freeRtosPortSource.setMarkup(False)

freeRtosPortHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_SAM_PORTMACRO_H", None)
freeRtosPortHeader.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM0/portmacro.h")
freeRtosPortHeader.setOutputName("portmacro.h")
freeRtosPortHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/ARM_CM0")
freeRtosPortHeader.setProjectPath("FreeRTOS/Source/portable/GCC/ARM_CM0")
freeRtosPortHeader.setType("HEADER")
freeRtosPortHeader.setMarkup(False)
