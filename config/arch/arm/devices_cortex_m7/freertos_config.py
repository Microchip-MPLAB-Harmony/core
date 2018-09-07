#Default Heap size for Cortex-M7 architecture
freeRtosSym_TotalHeapSize.setDefaultValue(40960)

############################################################################
#### Code Generation ####
############################################################################

configName  = Variables.get("__CONFIGURATION_NAME")

freeRtosdefSym = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_INCLUDE_DIRS", None)
freeRtosdefSym.setCategory("C32")
freeRtosdefSym.setKey("extra-include-directories")
freeRtosdefSym.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/GCC/SAM/CM7;../src/third_party/rtos/FreeRTOS/Source/Include;")
freeRtosdefSym.setAppend(True, ";")

freeRtosPortSource = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_SAM_PORT_C", None)
freeRtosPortSource.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM7/r0p1/port.c")
freeRtosPortSource.setOutputName("port.c")
freeRtosPortSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/SAM/CM7")
freeRtosPortSource.setProjectPath("FreeRTOS/Source/portable/GCC/SAM/CM7")
freeRtosPortSource.setType("SOURCE")
freeRtosPortSource.setMarkup(False)

freeRtosPortHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_SAM_PORTMACRO_H", None)
freeRtosPortHeader.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM7/r0p1/portmacro.h")
freeRtosPortHeader.setOutputName("portmacro.h")
freeRtosPortHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/SAM/CM7")
freeRtosPortHeader.setProjectPath("FreeRTOS/Source/portable/GCC/SAM/CM7")
freeRtosPortHeader.setType("HEADER")
freeRtosPortHeader.setMarkup(False)
