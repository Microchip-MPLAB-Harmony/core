################################################################################
#### Business Logic ####
################################################################################
global osalSelectRTOS
global osalHeaderFile
global osalHeaderDefFile
global osalHeaderImpBasicFile
global osalHeaderFreeRtosFile
global osalSourceFreeRtosFile
global osalSystemDefFile

def enableOSAL(symbol, event):
    drv_common = Database.getSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
    sys_common = Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")

    if ((drv_common == True) or (sys_common == True)):
        symbol.setValue(True,1)
    else:
        symbol.setValue(False,1)

def genOsalFiles(symbol, event):
    global osalSelectRTOS
    global osalHeaderFile
    global osalHeaderDefFile
    global osalHeaderImpBasicFile
    global osalHeaderFreeRtosFile
    global osalSourceFreeRtosFile
    global osalSystemDefFile

    genOsal = Database.getSymbolValue("HarmonyCore", "ENABLE_OSAL")

    if (genOsal == True):
        osalHeaderFile.setEnabled(True)
        osalHeaderDefFile.setEnabled(True)
        osalSystemDefFile.setEnabled(True)
        osalHeaderImpBasicFile.setEnabled(osalSelectRTOS.getValue() == "BareMetal")
        osalHeaderFreeRtosFile.setEnabled(osalSelectRTOS.getValue() == "FreeRTOS")
        osalSourceFreeRtosFile.setEnabled(osalSelectRTOS.getValue() == "FreeRTOS")
    else:
        osalHeaderFile.setEnabled(False)
        osalHeaderDefFile.setEnabled(False)
        osalHeaderImpBasicFile.setEnabled(False)
        osalHeaderFreeRtosFile.setEnabled(False)
        osalSourceFreeRtosFile.setEnabled(False)
        osalSystemDefFile.setEnabled(False)

############################################################################
#### Code Generation ####
############################################################################
osal = harmonyCoreComponent.createBooleanSymbol("ENABLE_OSAL", coreMenu)
osal.setLabel("Enable OSAL")
osal.setDefaultValue(False)
osal.setDependencies(enableOSAL, ["ENABLE_DRV_COMMON", "ENABLE_SYS_COMMON"])


osalSelectRTOS = harmonyCoreComponent.createComboSymbol("SELECT_RTOS", None, ["BareMetal", "FreeRTOS"])
osalSelectRTOS.setLabel("Select any RTOS or Bare-metal")
osalSelectRTOS.setDefaultValue("BareMetal")
osalSelectRTOS.setVisible(False)

# OSAL RTOS Configuration
osalHeaderFile = harmonyCoreComponent.createFileSymbol("OSAL_H", None)
osalHeaderFile.setSourcePath("/osal/osal.h")
osalHeaderFile.setOutputName("osal.h")
osalHeaderFile.setDestPath("/osal/")
osalHeaderFile.setProjectPath("/osal/")
osalHeaderFile.setType("HEADER")
osalHeaderFile.setOverwrite(True)
osalHeaderFile.setEnabled(False)

osalHeaderDefFile = harmonyCoreComponent.createFileSymbol("OSAL_DEFINITIONS_H", None)
osalHeaderDefFile.setSourcePath("osal/templates/osal_definitions.h.ftl")
osalHeaderDefFile.setOutputName("osal_definitions.h")
osalHeaderDefFile.setDestPath("/osal/")
osalHeaderDefFile.setProjectPath("/osal/")
osalHeaderDefFile.setType("HEADER")
osalHeaderDefFile.setOverwrite(True)
osalHeaderDefFile.setMarkup(True)
osalHeaderDefFile.setEnabled(False)

osalHeaderImpBasicFile = harmonyCoreComponent.createFileSymbol("OSAL_IMPL_BASIC_H", None)
osalHeaderImpBasicFile.setSourcePath("/osal/osal_impl_basic.h")
osalHeaderImpBasicFile.setOutputName("osal_impl_basic.h")
osalHeaderImpBasicFile.setDestPath("/osal/")
osalHeaderImpBasicFile.setProjectPath("/osal/")
osalHeaderImpBasicFile.setType("HEADER")
osalHeaderImpBasicFile.setOverwrite(True)
osalHeaderImpBasicFile.setEnabled(False)
osalHeaderImpBasicFile.setDependencies(genOsalFiles, ["ENABLE_OSAL", "SELECT_RTOS"])

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
osalSystemDefFile.setOverwrite(False)
osalSystemDefFile.setEnabled(False)
