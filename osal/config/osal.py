

################################################################################
#### Business Logic ####
################################################################################

def genOsalFiles(osalHeaderFile, event):
    symObj=event["symbol"]
    
    osalHeaderImpBasicFile.setEnabled(symObj.getSelectedKey() == "BARE_METAL")
    osalHeaderFreeRtosFile.setEnabled(symObj.getSelectedKey() == "FREE_RTOS_V10")
    osalSourceFreeRtosFile.setEnabled(symObj.getSelectedKey() == "FREE_RTOS_V10")

############################################################################
#### Code Generation ####
############################################################################    

osalRTOS = harmonyCoreComponent.createKeyValueSetSymbol("SELECT_RTOS", coreMenu)
osalRTOS.setLabel("Select RTOS or Bare-metal")
osalRTOS.addKey("BARE_METAL", "0", "Bare-metal")
osalRTOS.addKey("FREE_RTOS_V10", "1", "FreeRTOS V10.x.x")
osalRTOS.setOutputMode("Key")
osalRTOS.setDisplayMode("Description")
osalRTOS.setSelectedKey("BARE_METAL",1)


osalHeaderFile = harmonyCoreComponent.createFileSymbol("OSAL_H", None)
osalHeaderFile.setSourcePath("/osal/osal.h")
osalHeaderFile.setOutputName("osal.h")
osalHeaderFile.setDestPath("/osal/")
osalHeaderFile.setProjectPath("/osal/")
osalHeaderFile.setType("HEADER")

osalHeaderDefFile = harmonyCoreComponent.createFileSymbol("OSAL_DEFINITIONS_H", None)
osalHeaderDefFile.setSourcePath("/osal/osal_definitions.h")
osalHeaderDefFile.setOutputName("osal_definitions.h")
osalHeaderDefFile.setDestPath("/osal/")
osalHeaderDefFile.setProjectPath("/osal/")
osalHeaderDefFile.setType("HEADER")

osalHeaderImpBasicFile = harmonyCoreComponent.createFileSymbol("OSAL_IMPL_BASIC_H", None)
osalHeaderImpBasicFile.setSourcePath("/osal/osal_impl_basic.h")
osalHeaderImpBasicFile.setOutputName("osal_impl_basic.h")
osalHeaderImpBasicFile.setDestPath("/osal/")
osalHeaderImpBasicFile.setProjectPath("/osal/")
osalHeaderImpBasicFile.setType("HEADER")
osalHeaderImpBasicFile.setEnabled(True)
osalHeaderImpBasicFile.setDependencies(genOsalFiles, ["OSAL_RTOS"])

osalHeaderFreeRtosFile = harmonyCoreComponent.createFileSymbol("OSAL_FREERTOS_H", None)
osalHeaderFreeRtosFile.setSourcePath("/osal/osal_freertos.h")
osalHeaderFreeRtosFile.setOutputName("osal_freertos.h")
osalHeaderFreeRtosFile.setDestPath("/osal/")
osalHeaderFreeRtosFile.setProjectPath("/osal/")
osalHeaderFreeRtosFile.setType("HEADER")
osalHeaderFreeRtosFile.setEnabled(False)

osalSourceFreeRtosFile = harmonyCoreComponent.createFileSymbol("OSAL_FREERTOS_C", None)
osalSourceFreeRtosFile.setSourcePath("/osal/src/osal_freertos.c")
osalSourceFreeRtosFile.setOutputName("osal_freertos.c")
osalSourceFreeRtosFile.setDestPath("/osal/")
osalSourceFreeRtosFile.setProjectPath("/osal/")
osalSourceFreeRtosFile.setType("SOURCE")
osalSourceFreeRtosFile.setEnabled(False)

osalSystemDefFile = harmonyCoreComponent.createFileSymbol("OSAL_SYSDEF_H", None)
osalSystemDefFile.setType("STRING")
osalSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
osalSystemDefFile.setSourcePath("/osal/templates/system/system_definitions.h.ftl")
osalSystemDefFile.setMarkup(True)

osalSystemConfFile = harmonyCoreComponent.createFileSymbol("OSAL_CONFIG_H", None)
osalSystemConfFile.setType("STRING")
osalSystemConfFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_MIDDLEWARE_CONFIGURATION")
osalSystemConfFile.setSourcePath("/osal/templates/system/system_config.h.ftl")
osalSystemConfFile.setMarkup(True)



