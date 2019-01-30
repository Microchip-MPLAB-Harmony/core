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
Database.setSymbolValue("core", "PIT_INTERRUPT_HANDLER", "FreeRTOS_Tick_Handler", 1);
Database.setSymbolValue("core", "USE_FREERTOS_VECTORS", True, 1)
Database.setSymbolValue("pit", "ENABLE_COUNTER", False, 1)

############################################################################
#### Code Generation ####
############################################################################

configName  = Variables.get("__CONFIGURATION_NAME")

freeRtosdefSym = thirdPartyFreeRTOS.createSettingSymbol(None, None)
freeRtosdefSym.setCategory("C32")
freeRtosdefSym.setKey("extra-include-directories")
freeRtosdefSym.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/CA5;../src/third_party/rtos/FreeRTOS/Source/Include;")
freeRtosdefSym.setAppend(True, ";")

freeRtosPortSource = thirdPartyFreeRTOS.createFileSymbol(None, None)
freeRtosPortSource.setSourcePath("../CMSIS-FreeRTOS/Source/portable/IAR/ARM_CA5_No_GIC/port.c")
freeRtosPortSource.setOutputName("port.c")
freeRtosPortSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/CA5")
freeRtosPortSource.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/CA5")
freeRtosPortSource.setType("SOURCE")
freeRtosPortSource.setMarkup(False)

freeRtosPortASMHeader = thirdPartyFreeRTOS.createFileSymbol(None, None)
freeRtosPortASMHeader.setSourcePath("../CMSIS-FreeRTOS/Source/portable/IAR/ARM_CA5_No_GIC/portASM.h")
freeRtosPortASMHeader.setOutputName("portASM.h")
freeRtosPortASMHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/CA5")
freeRtosPortASMHeader.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/CA5")
freeRtosPortASMHeader.setType("HEADER")
freeRtosPortASMHeader.setMarkup(False)

freeRtosPortASMSource = thirdPartyFreeRTOS.createFileSymbol(None, None)
freeRtosPortASMSource.setSourcePath("../CMSIS-FreeRTOS/Source/portable/IAR/ARM_CA5_No_GIC/portASM.s")
freeRtosPortASMSource.setOutputName("portASM.s")
freeRtosPortASMSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/CA5")
freeRtosPortASMSource.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/CA5")
freeRtosPortASMSource.setType("SOURCE")
freeRtosPortASMSource.setMarkup(False)

freeRtosPortHeader = thirdPartyFreeRTOS.createFileSymbol(None, None)
freeRtosPortHeader.setSourcePath("../CMSIS-FreeRTOS/Source/portable/IAR/ARM_CA5_No_GIC/portmacro.h")
freeRtosPortHeader.setOutputName("portmacro.h")
freeRtosPortHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/CA5")
freeRtosPortHeader.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/CA5")
freeRtosPortHeader.setType("HEADER")
freeRtosPortHeader.setMarkup(False)

freeRtosPortTickSource = thirdPartyFreeRTOS.createFileSymbol(None, None)
freeRtosPortTickSource.setSourcePath("config/arch/arm/devices_cortex_a5/src/FreeRTOS_tick_config.c")
freeRtosPortTickSource.setOutputName("FreeRTOS_tick_config.c")
freeRtosPortTickSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/IAR/SAM/CA5")
freeRtosPortTickSource.setProjectPath("FreeRTOS/Source/portable/IAR/SAM/CA5")
freeRtosPortTickSource.setType("SOURCE")
freeRtosPortTickSource.setMarkup(False)
