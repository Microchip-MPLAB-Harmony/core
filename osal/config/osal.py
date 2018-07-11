################################################################################
#### Business Logic ####
################################################################################
global osalHeaderImpBasicFile
global osalHeaderFreeRtosFile
global osalSourceFreeRtosFile
global osalSelectRTOS

############################################################################
#### Code Generation ####
############################################################################
enableOSAL = harmonyCoreComponent.createBooleanSymbol("ENABLE_OSAL", None)
enableOSAL.setLabel("Generate OSAL Files")
enableOSAL.setDefaultValue(True)
enableOSAL.setReadOnly(True)

osalSelectRTOS = harmonyCoreComponent.createKeyValueSetSymbol("SELECT_RTOS", None)
osalSelectRTOS.setLabel("Select any RTOS or Bare-metal")
osalSelectRTOS.addKey("BareMetal", "0", "Bare-metal")
osalSelectRTOS.addKey("FreeRTOS", "1", "FreeRTOS")
osalSelectRTOS.setOutputMode("Key")
osalSelectRTOS.setDisplayMode("Description")
osalSelectRTOS.setSelectedKey("BareMetal", 1)
osalSelectRTOS.setReadOnly(True)

# OSAL RTOS Configuration
osalHeaderFile = harmonyCoreComponent.createFileSymbol("OSAL_H", None)
osalHeaderFile.setSourcePath("/osal/osal.h")
osalHeaderFile.setOutputName("osal.h")
osalHeaderFile.setDestPath("/osal/")
osalHeaderFile.setProjectPath("/osal/")
osalHeaderFile.setType("HEADER")
osalHeaderFile.setOverwrite(True)

osalHeaderDefFile = harmonyCoreComponent.createFileSymbol("OSAL_DEFINITIONS_H", None)
osalHeaderDefFile.setSourcePath("osal/templates/osal_definitions.h.ftl")
osalHeaderDefFile.setOutputName("osal_definitions.h")
osalHeaderDefFile.setDestPath("/osal/")
osalHeaderDefFile.setProjectPath("/osal/")
osalHeaderDefFile.setType("HEADER")
osalHeaderDefFile.setOverwrite(True)
osalHeaderDefFile.setMarkup(True)

osalHeaderImpBasicFile = harmonyCoreComponent.createFileSymbol("OSAL_IMPL_BASIC_H", None)
osalHeaderImpBasicFile.setSourcePath("/osal/osal_impl_basic.h")
osalHeaderImpBasicFile.setOutputName("osal_impl_basic.h")
osalHeaderImpBasicFile.setDestPath("/osal/")
osalHeaderImpBasicFile.setProjectPath("/osal/")
osalHeaderImpBasicFile.setType("HEADER")
osalHeaderImpBasicFile.setOverwrite(True)
osalHeaderImpBasicFile.setEnabled(True)

osalHeaderFreeRtosFile = harmonyCoreComponent.createFileSymbol("OSAL_FREERTOS_H", None)
osalHeaderFreeRtosFile.setSourcePath("/osal/osal_freertos.h")
osalHeaderFreeRtosFile.setOutputName("osal_freertos.h")
osalHeaderFreeRtosFile.setDestPath("/osal/")
osalHeaderFreeRtosFile.setProjectPath("/osal/")
osalHeaderFreeRtosFile.setType("HEADER")
osalHeaderFreeRtosFile.setOverwrite(True)
osalHeaderFreeRtosFile.setEnabled(False)

osalSourceFreeRtosFile = harmonyCoreComponent.createFileSymbol("OSAL_FREERTOS_C", None)
osalSourceFreeRtosFile.setSourcePath("/osal/src/osal_freertos.c")
osalSourceFreeRtosFile.setOutputName("osal_freertos.c")
osalSourceFreeRtosFile.setDestPath("/osal/")
osalSourceFreeRtosFile.setProjectPath("/osal/")
osalSourceFreeRtosFile.setType("SOURCE")
osalSourceFreeRtosFile.setOverwrite(True)
osalSourceFreeRtosFile.setEnabled(False)

osalSystemDefFile = harmonyCoreComponent.createFileSymbol("OSAL_SYSDEF_H", None)
osalSystemDefFile.setType("STRING")
osalSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
osalSystemDefFile.setSourcePath("/osal/templates/system/system_definitions.h.ftl")
osalSystemDefFile.setMarkup(True)
osalSystemDefFile.setOverwrite(True)
