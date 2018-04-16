

################################################################################
#### Business Logic ####
################################################################################

global selectRTOS
global enableOSAL

global osalHeaderFile
global osalHeaderDefFile
global osalHeaderImpBasicFile
global osalHeaderFreeRtosFile
global osalSourceFreeRtosFile
global osalSystemDefFile
global osalSystemConfFile

def genOsalFiles(symbol, event):
    global selectRTOS
    global enableOSAL
    
    global osalHeaderFile
    global osalHeaderDefFile
    global osalHeaderImpBasicFile
    global osalHeaderFreeRtosFile
    global osalSourceFreeRtosFile
    global osalSystemDefFile
    global osalSystemConfFile
    
    if (enableOSAL.getValue() == True):
        osalHeaderFile.setEnabled(True)
        osalHeaderDefFile.setEnabled(True)
        osalHeaderImpBasicFile.setEnabled(selectRTOS.getSelectedKey() == "BARE_METAL")
        osalHeaderFreeRtosFile.setEnabled(selectRTOS.getSelectedKey() == "FREE_RTOS_V10")
        osalSourceFreeRtosFile.setEnabled(selectRTOS.getSelectedKey() == "FREE_RTOS_V10")
        osalSystemDefFile.setEnabled(True)
        osalSystemConfFile.setEnabled(True)     
    else:
        osalHeaderFile.setEnabled(False)
        osalHeaderDefFile.setEnabled(False)
        osalHeaderImpBasicFile.setEnabled(False)
        osalHeaderFreeRtosFile.setEnabled(False)
        osalSourceFreeRtosFile.setEnabled(False)
        osalSystemDefFile.setEnabled(False)
        osalSystemConfFile.setEnabled(False)            
        
        
############################################################################
#### Code Generation ####
############################################################################    

enableOSAL = harmonyCoreComponent.createBooleanSymbol("ENABLE_OSAL", coreMenu)
enableOSAL.setLabel("Generate OSAL Files")
enableOSAL.setDefaultValue(False)
    
    
selectRTOS = harmonyCoreComponent.createKeyValueSetSymbol("SELECT_RTOS", enableOSAL)
selectRTOS.setLabel("Select RTOS or Bare-metal")
selectRTOS.addKey("BARE_METAL", "0", "Bare-metal")
selectRTOS.addKey("FREE_RTOS_V10", "1", "FreeRTOS V10.x.x")
selectRTOS.setOutputMode("Key")
selectRTOS.setDisplayMode("Description")
selectRTOS.setSelectedKey("BARE_METAL",1)


osalHeaderFile = harmonyCoreComponent.createFileSymbol("OSAL_H", None)
osalHeaderFile.setSourcePath("/osal/osal.h")
osalHeaderFile.setOutputName("osal.h")
osalHeaderFile.setDestPath("/osal/")
osalHeaderFile.setProjectPath("/osal/")
osalHeaderFile.setType("HEADER")
osalHeaderFile.setOverwrite(True)
osalHeaderFile.setEnabled(False)


osalHeaderDefFile = harmonyCoreComponent.createFileSymbol("OSAL_DEFINITIONS_H", None)
osalHeaderDefFile.setSourcePath("/osal/osal_definitions.h")
osalHeaderDefFile.setOutputName("osal_definitions.h")
osalHeaderDefFile.setDestPath("/osal/")
osalHeaderDefFile.setProjectPath("/osal/")
osalHeaderDefFile.setType("HEADER")
osalHeaderDefFile.setOverwrite(True)
osalHeaderDefFile.setEnabled(False)

osalHeaderImpBasicFile = harmonyCoreComponent.createFileSymbol("OSAL_IMPL_BASIC_H", None)
osalHeaderImpBasicFile.setSourcePath("/osal/osal_impl_basic.h")
osalHeaderImpBasicFile.setOutputName("osal_impl_basic.h")
osalHeaderImpBasicFile.setDestPath("/osal/")
osalHeaderImpBasicFile.setProjectPath("/osal/")
osalHeaderImpBasicFile.setType("HEADER")
osalHeaderImpBasicFile.setOverwrite(True)
osalHeaderImpBasicFile.setEnabled(False)
osalHeaderImpBasicFile.setDependencies(genOsalFiles, ["ENABLE_OSAL","SELECT_RTOS"])

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
osalSystemDefFile.setEnabled(False)

osalSystemConfFile = harmonyCoreComponent.createFileSymbol("OSAL_CONFIG_H", None)
osalSystemConfFile.setType("STRING")
osalSystemConfFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_MIDDLEWARE_CONFIGURATION")
osalSystemConfFile.setSourcePath("/osal/templates/system/system_config.h.ftl")
osalSystemConfFile.setMarkup(True)
osalSystemConfFile.setOverwrite(True)
osalSystemConfFile.setEnabled(False)



