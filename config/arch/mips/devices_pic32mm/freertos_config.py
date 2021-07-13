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

#TMR1 Clock Frequency
perclk = Database.getSymbolValue("core", "TMR1_CLOCK_FREQUENCY")
perclk = int(perclk)

freeRtosSym_PerClockHz.setDefaultValue(perclk)
freeRtosSym_PerClockHz.setDependencies(freeRtosCpuClockHz, ["core.TMR1_CLOCK_FREQUENCY"])
freeRtosSym_PerClockHz.setReadOnly(True)

freeRtosSym_DynMemAloc.setReadOnly(True)

#Default Heap size
freeRtosSym_TotalHeapSize.setDefaultValue(28000)

#Setup Kernel Priority
freeRtosSym_KernelIntrPrio.setDefaultValue(1)
freeRtosSym_KernelIntrPrio.setReadOnly(True)

#Setup Sys Call Priority
freeRtosSym_MaxSysCalIntrPrio.setDefaultValue(3)

def getIRQnumber(string):
    interrupts = ATDF.getNode('/avr-tools-device-file/devices/device/interrupts')
    interruptsChildren = interrupts.getChildren()
    for param in interruptsChildren:
        modInst = param.getAttribute('name')
        if(string == modInst):
            irq_index = param.getAttribute('index')
    return irq_index

def _get_enblReg_parms(vectorNumber):
    # This takes in vector index for interrupt, and returns the IECx register name as well as
    # mask and bit location within it for given interrupt
    temp = float(vectorNumber) / 32.0
    index = int(temp)
    return index

def _get_ipcReg_parms(vectorNumber):    
    temp = float(vectorNumber) / 4.0
    index = int(temp)
    return index
############################################################################
#### Code Generation ####
############################################################################

configName  = Variables.get("__CONFIGURATION_NAME")

GPM_Variant = False

if "GPM" in Variables.get( "__PROCESSOR" ):
    GPM_Variant = True

irqString = "TIMER_1"
Irq_index = int(getIRQnumber(irqString))
enblRegIndex = _get_enblReg_parms(Irq_index)
ipcRegIndex = _get_ipcReg_parms(Irq_index)

# TIMER_1 IEC REG
freeRtosdefTimer1IEC = thirdPartyFreeRTOS.createStringSymbol("FREERTOS_TIM1_IEC_REG", None)
freeRtosdefTimer1IEC.setDefaultValue("IEC"+str(enblRegIndex))
freeRtosdefTimer1IEC.setVisible(False)

# TIMER_1 IFS REG
freeRtosdefTimer1IFS = thirdPartyFreeRTOS.createStringSymbol("FREERTOS_TIM1_IFS_REG", None)
freeRtosdefTimer1IFS.setDefaultValue("IFS"+str(enblRegIndex))
freeRtosdefTimer1IFS.setVisible(False)

# TIMER_1 IPC REG
freeRtosdefTimer1IPC = thirdPartyFreeRTOS.createStringSymbol("FREERTOS_TIM1_IPC_REG", None)
freeRtosdefTimer1IPC.setDefaultValue("IPC"+str(ipcRegIndex))
freeRtosdefTimer1IPC.setVisible(False)

irqString = "CORE_SOFTWARE_0"
Irq_index = int(getIRQnumber(irqString))
enblRegIndex = _get_enblReg_parms(Irq_index)
ipcRegIndex = _get_ipcReg_parms(Irq_index)

# CORE_SOFTWARE_0 IEC REG
freeRtosdefCoreSW0IEC = thirdPartyFreeRTOS.createStringSymbol("FREERTOS_CORE_SW_0_IEC_REG", None)
freeRtosdefCoreSW0IEC.setDefaultValue("IEC"+str(enblRegIndex))
freeRtosdefCoreSW0IEC.setVisible(False)

# CORE_SOFTWARE_0 IFS REG
freeRtosdefCoreSW0IFS = thirdPartyFreeRTOS.createStringSymbol("FREERTOS_CORE_SW_0_IFS_REG", None)
freeRtosdefCoreSW0IFS.setDefaultValue("IFS"+str(enblRegIndex))
freeRtosdefCoreSW0IFS.setVisible(False)

# CORE_SOFTWARE_0 IPC REG
freeRtosdefCoreSW0IPC = thirdPartyFreeRTOS.createStringSymbol("FREERTOS_CORE_SW_0_IPC_REG", None)
freeRtosdefCoreSW0IPC.setDefaultValue("IPC"+str(ipcRegIndex))
freeRtosdefCoreSW0IPC.setVisible(False)

freeRtosdefSym = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_INCLUDE_DIRS", None)
freeRtosdefSym.setCategory("C32")
freeRtosdefSym.setKey("extra-include-directories")
if GPM_Variant == True:
    freeRtosdefSym.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPM;../src/third_party/rtos/FreeRTOS/Source/include;")
else:
    freeRtosdefSym.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPL;../src/third_party/rtos/FreeRTOS/Source/include;")
freeRtosdefSym.setAppend(True, ";")

freeRtosdefXc32cppSym = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32CPP_INCLUDE_DIRS", None)
freeRtosdefXc32cppSym.setCategory("C32CPP")
freeRtosdefXc32cppSym.setKey("extra-include-directories")
freeRtosdefXc32cppSym.setValue(freeRtosdefSym.getValue())
freeRtosdefXc32cppSym.setAppend(True, ";")

freeRtosIncDirForAsm = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_AS_INCLUDE_DIRS", None)
freeRtosIncDirForAsm.setCategory("C32-AS")
freeRtosIncDirForAsm.setKey("extra-include-directories-for-assembler")
if GPM_Variant == True:
    freeRtosIncDirForAsm.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPM;../src/third_party/rtos/FreeRTOS/Source/include;../src/config/"+ configName +";")
else:
    freeRtosIncDirForAsm.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPL;../src/third_party/rtos/FreeRTOS/Source/include;../src/config/"+ configName +";")
freeRtosIncDirForAsm.setAppend(True, ";")

freeRtosIncDirForPre = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_AS_INCLUDE_PRE_PROC_DIRS", None)
freeRtosIncDirForPre.setCategory("C32-AS")
freeRtosIncDirForPre.setKey("extra-include-directories-for-preprocessor")
if GPM_Variant == True:
    freeRtosIncDirForPre.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPM;../src/third_party/rtos/FreeRTOS/Source/include;../src/config/"+ configName +";")
else:
    freeRtosIncDirForPre.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPL;../src/third_party/rtos/FreeRTOS/Source/include;../src/config/"+ configName +";")
freeRtosIncDirForPre.setAppend(True, ";")

freeRtosPortSource = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MIPS_PORT_C", None)
freeRtosPortSource.setSourcePath("config/arch/mips/devices_pic32mm/src/PIC32MM/port.c.ftl")
freeRtosPortSource.setOutputName("port.c")
if GPM_Variant == True:
    freeRtosPortSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPM")
    freeRtosPortSource.setProjectPath("FreeRTOS/Source/portable/MPLAB/PIC32MM_GPM")
else:
    freeRtosPortSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPL")
    freeRtosPortSource.setProjectPath("FreeRTOS/Source/portable/MPLAB/PIC32MM_GPL")
freeRtosPortSource.setType("SOURCE")
freeRtosPortSource.setMarkup(True)

freeRtosPortHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MIPS_PORTMACRO_H", None)
freeRtosPortHeader.setSourcePath("config/arch/mips/devices_pic32mm/src/PIC32MM/portmacro.h")
freeRtosPortHeader.setOutputName("portmacro.h")
if GPM_Variant == True:
    freeRtosPortHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPM")
    freeRtosPortHeader.setProjectPath("FreeRTOS/Source/portable/MPLAB/PIC32MM_GPM")
else:
    freeRtosPortHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPL")
    freeRtosPortHeader.setProjectPath("FreeRTOS/Source/portable/MPLAB/PIC32MM_GPL")
freeRtosPortHeader.setType("HEADER")
freeRtosPortHeader.setMarkup(False)

freeRtosPortAsmSource = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MIPS_PORT_ASM_S", None)
freeRtosPortAsmSource.setSourcePath("config/arch/mips/devices_pic32mm/src/PIC32MM/port_asm.S")
freeRtosPortAsmSource.setOutputName("port_asm.S")
if GPM_Variant == True:
    freeRtosPortAsmSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPM")
    freeRtosPortAsmSource.setProjectPath("FreeRTOS/Source/portable/MPLAB/PIC32MM_GPM")
else:
    freeRtosPortAsmSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPL")
    freeRtosPortAsmSource.setProjectPath("FreeRTOS/Source/portable/MPLAB/PIC32MM_GPL")
freeRtosPortAsmSource.setType("SOURCE")
freeRtosPortAsmSource.setMarkup(False)

freeRtosIsrSupportHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MIPS_ISR_SUPPORT_H", None)
freeRtosIsrSupportHeader.setSourcePath("config/arch/mips/devices_pic32mm/src/PIC32MM/ISR_Support.h")
freeRtosIsrSupportHeader.setOutputName("ISR_Support.h")
if GPM_Variant == True:
    freeRtosIsrSupportHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPM")
    freeRtosIsrSupportHeader.setProjectPath("FreeRTOS/Source/portable/MPLAB/PIC32MM_GPM")
else:
    freeRtosIsrSupportHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MPLAB/PIC32MM_GPL")
    freeRtosIsrSupportHeader.setProjectPath("FreeRTOS/Source/portable/MPLAB/PIC32MM_GPL")
freeRtosIsrSupportHeader.setType("HEADER")
freeRtosIsrSupportHeader.setMarkup(False)
