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
############### ARM926EJS Architecture specific configuration ##############
############################################################################

#CPU Clock Frequency
cpuclk = Database.getSymbolValue("core", "CPU_CLOCK_FREQUENCY")
cpuclk = int(cpuclk)

freeRtosSym_CpuClockHz.setDependencies(freeRtosCpuClockHz, ["core.CPU_CLOCK_FREQUENCY"])
freeRtosSym_CpuClockHz.setDefaultValue(cpuclk)

#Default Heap size
freeRtosSym_TotalHeapSize.setDefaultValue(40960)

#Setup Kernel Priority
freeRtosSym_KernelIntrPrio.setDefaultValue(7)
freeRtosSym_KernelIntrPrio.setReadOnly(True)

#Setup Sys Call Priority
freeRtosSym_MaxSysCalIntrPrio.setDefaultValue(1)

freeRtosSym_tickConfig = thirdPartyFreeRTOS.createStringSymbol("FREERTOS_SETUP_TICK_INTERRUPT", None)
freeRtosSym_tickConfig.setVisible(False)
freeRtosSym_tickConfig.setDefaultValue("vConfigureTickInterrupt")

clearTick = thirdPartyFreeRTOS.createStringSymbol("FREERTOS_CONFIG_TICK_INTERRUPT", None);
clearTick.setVisible(False)
clearTick.setReadOnly(True)
clearTick.setDefaultValue("vClear_Tick_Interrupt")

eoiAddress = thirdPartyFreeRTOS.createStringSymbol("FREERTOS_EOI_ADDRESS", None)
eoiAddress.setVisible(False)
eoiAddress.setReadOnly(True)
node        = ATDF.getNode('/avr-tools-device-file/devices/device/peripherals/module@[name="AIC"]/instance@[name="AIC"]/register-group@[name="AIC"]')
baseAddr    = int(node.getAttribute("offset"),16);
node        = ATDF.getNode('/avr-tools-device-file/modules/module@[name="AIC"]/register-group@[name="AIC"]/register@[name="AIC_EOICR"]')
offset      = int(node.getAttribute("offset"),16)
address     = baseAddr + offset
eoiAddress.setDefaultValue(str(hex(address)))

Database.activateComponents(["pit"]);
Database.setSymbolValue("core", "USE_FREERTOS_VECTORS", True)
Database.setSymbolValue("pit", "ENABLE_COUNTER", False)

############################################################################
#### Code Generation ####
############################################################################

configName  = Variables.get("__CONFIGURATION_NAME")

compiler_choice = Database.getComponentByID("core").getSymbolByID("COMPILER_CHOICE")

#IAR port files
freeRtosdefSym_iar = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_IAR_INCLUDE_DIRS", None)
freeRtosdefSym_iar.setCategory("C32")
freeRtosdefSym_iar.setKey("extra-include-directories")
freeRtosdefSym_iar.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/ARM926;../src/third_party/rtos/FreeRTOS/Source/include;")
freeRtosdefSym_iar.setAppend(True, ";")
freeRtosdefSym_iar.setEnabled(compiler_choice.getSelectedKey() == "IAR")
freeRtosdefSym_iar.setDependencies(lambda symbol, event: symbol.setEnabled(event["symbol"].getSelectedKey() == "IAR"), ['core.COMPILER_CHOICE'])

freeRtosPortSource_iar = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_IAR_SAM_PORT_C", None)
freeRtosPortSource_iar.setSourcePath("config/arch/arm/devices_arm926/src/port.c")
freeRtosPortSource_iar.setOutputName("port.c")
freeRtosPortSource_iar.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/ARM926")
freeRtosPortSource_iar.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/ARM926")
freeRtosPortSource_iar.setType("SOURCE")
freeRtosPortSource_iar.setMarkup(False)
freeRtosPortSource_iar.setEnabled(compiler_choice.getSelectedKey() == "IAR")
freeRtosPortSource_iar.setDependencies(lambda symbol, event: symbol.setEnabled(event["symbol"].getSelectedKey() == "IAR"), ['core.COMPILER_CHOICE'])

freeRtosPortASMSource_iar = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_IAR_SAM_PORT_ASM", None)
freeRtosPortASMSource_iar.setSourcePath("config/arch/arm/devices_arm926/src/IAR/portASM.s")
freeRtosPortASMSource_iar.setOutputName("portASM.s")
freeRtosPortASMSource_iar.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/ARM926")
freeRtosPortASMSource_iar.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/ARM926")
freeRtosPortASMSource_iar.setType("SOURCE")
freeRtosPortASMSource_iar.setMarkup(False)
freeRtosPortASMSource_iar.setEnabled(compiler_choice.getSelectedKey() == "IAR")
freeRtosPortASMSource_iar.setDependencies(lambda symbol, event: symbol.setEnabled(event["symbol"].getSelectedKey() == "IAR"), ["core.COMPILER_CHOICE"])

freeRtosPortHeader_iar = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_IAR_SAM_PORT_MACRO_H", None)
freeRtosPortHeader_iar.setSourcePath("config/arch/arm/devices_arm926/src/portmacro.h")
freeRtosPortHeader_iar.setOutputName("portmacro.h")
freeRtosPortHeader_iar.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/ARM926")
freeRtosPortHeader_iar.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/ARM926")
freeRtosPortHeader_iar.setType("HEADER")
freeRtosPortHeader_iar.setMarkup(False)
freeRtosPortHeader_iar.setEnabled(compiler_choice.getSelectedKey() == "IAR")
freeRtosPortHeader_iar.setDependencies(lambda symbol, event: symbol.setEnabled(event["symbol"].getSelectedKey() == "IAR"), ["core.COMPILER_CHOICE"])

freeRtosPortTickSource_iar = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_IAR_SAM_PORT_TICK_CONFIG_C", None)
freeRtosPortTickSource_iar.setSourcePath("config/arch/arm/devices_arm926/src/FreeRTOS_tick_config.c")
freeRtosPortTickSource_iar.setOutputName("FreeRTOS_tick_config.c")
freeRtosPortTickSource_iar.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/ARM926")
freeRtosPortTickSource_iar.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/ARM926")
freeRtosPortTickSource_iar.setType("SOURCE")
freeRtosPortTickSource_iar.setMarkup(False)
freeRtosPortTickSource_iar.setEnabled(compiler_choice.getSelectedKey() == "IAR")
freeRtosPortTickSource_iar.setDependencies(lambda symbol, event: symbol.setEnabled(event["symbol"].getSelectedKey() == "IAR"), ["core.COMPILER_CHOICE"])

#XC32 port files
freeRtosdefSym_xc32 = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_INCLUDE_DIRS", None)
freeRtosdefSym_xc32.setCategory("C32")
freeRtosdefSym_xc32.setKey("extra-include-directories")
freeRtosdefSym_xc32.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/XC32/SAM/ARM926;../src/third_party/rtos/FreeRTOS/Source/include;")
freeRtosdefSym_xc32.setAppend(True, ";")
freeRtosdefSym_xc32.setEnabled(compiler_choice.getSelectedKey() == "XC32")
freeRtosdefSym_xc32.setDependencies(lambda symbol, event: symbol.setEnabled(event["symbol"].getSelectedKey() == "XC32"), ['core.COMPILER_CHOICE'])

freeRtosdefSym_xc32cpp = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32CPP_INCLUDE_DIRS", None)
freeRtosdefSym_xc32cpp.setCategory("C32CPP")
freeRtosdefSym_xc32cpp.setKey("extra-include-directories")
freeRtosdefSym_xc32cpp.setValue(freeRtosdefSym_xc32.getValue())
freeRtosdefSym_xc32cpp.setAppend(True, ";")
freeRtosdefSym_xc32cpp.setEnabled(compiler_choice.getSelectedKey() == "XC32")
freeRtosdefSym_xc32cpp.setDependencies(lambda symbol, event: symbol.setEnabled(event["symbol"].getSelectedKey() == "XC32"), ['core.COMPILER_CHOICE'])

freeRtosPortSource_xc32 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_XC32_SAM_PORT_C", None)
freeRtosPortSource_xc32.setSourcePath("config/arch/arm/devices_arm926/src/port.c")
freeRtosPortSource_xc32.setOutputName("port.c")
freeRtosPortSource_xc32.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/XC32/SAM/ARM926")
freeRtosPortSource_xc32.setProjectPath("FreeRTOS/Source/portable/XC32/SAM/ARM926")
freeRtosPortSource_xc32.setType("SOURCE")
freeRtosPortSource_xc32.setMarkup(False)
freeRtosPortSource_xc32.setEnabled(compiler_choice.getSelectedKey() == "XC32")
freeRtosPortSource_xc32.setDependencies(lambda symbol, event: symbol.setEnabled(event["symbol"].getSelectedKey() == "XC32"), ['core.COMPILER_CHOICE'])

freeRtosPortASMSource_xc32 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_XC32_SAM_PORT_ASM", None)
freeRtosPortASMSource_xc32.setSourcePath("config/arch/arm/devices_arm926/src/GCC/portASM.S")
freeRtosPortASMSource_xc32.setOutputName("portASM.S")
freeRtosPortASMSource_xc32.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/XC32/SAM/ARM926")
freeRtosPortASMSource_xc32.setProjectPath("FreeRTOS/Source/portable/XC32/SAM/ARM926")
freeRtosPortASMSource_xc32.setType("SOURCE")
freeRtosPortASMSource_xc32.setMarkup(False)
freeRtosPortASMSource_xc32.setEnabled(compiler_choice.getSelectedKey() == "XC32")
freeRtosPortASMSource_xc32.setDependencies(lambda symbol, event: symbol.setEnabled(event["symbol"].getSelectedKey() == "XC32"), ["core.COMPILER_CHOICE"])

freeRtosPortHeader_xc32 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_XC32_SAM_PORT_MACRO_H", None)
freeRtosPortHeader_xc32.setSourcePath("config/arch/arm/devices_arm926/src/portmacro.h")
freeRtosPortHeader_xc32.setOutputName("portmacro.h")
freeRtosPortHeader_xc32.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/XC32/SAM/ARM926")
freeRtosPortHeader_xc32.setProjectPath("FreeRTOS/Source/portable/XC32/SAM/ARM926")
freeRtosPortHeader_xc32.setType("HEADER")
freeRtosPortHeader_xc32.setMarkup(False)
freeRtosPortHeader_xc32.setEnabled(compiler_choice.getSelectedKey() == "XC32")
freeRtosPortHeader_xc32.setDependencies(lambda symbol, event: symbol.setEnabled(event["symbol"].getSelectedKey() == "XC32"), ["core.COMPILER_CHOICE"])

freeRtosPortTickSource_xc32 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_XC32_SAM_PORT_TICK_CONFIG_C", None)
freeRtosPortTickSource_xc32.setSourcePath("config/arch/arm/devices_arm926/src/FreeRTOS_tick_config.c")
freeRtosPortTickSource_xc32.setOutputName("FreeRTOS_tick_config.c")
freeRtosPortTickSource_xc32.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/XC32/SAM/ARM926")
freeRtosPortTickSource_xc32.setProjectPath("FreeRTOS/Source/portable/XC32/SAM/ARM926")
freeRtosPortTickSource_xc32.setType("SOURCE")
freeRtosPortTickSource_xc32.setMarkup(False)
freeRtosPortTickSource_xc32.setEnabled(compiler_choice.getSelectedKey() == "XC32")
freeRtosPortTickSource_xc32.setDependencies(lambda symbol, event: symbol.setEnabled(event["symbol"].getSelectedKey() == "XC32"), ["core.COMPILER_CHOICE"])
