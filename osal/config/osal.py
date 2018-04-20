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
global osalRtosComment

def genOsalFiles(symbol, event):
    global selectRTOS
    global enableOSAL
    
    global osalHeaderFile
    global osalHeaderDefFile
    global osalHeaderImpBasicFile
    global osalHeaderFreeRtosFile
    global osalSourceFreeRtosFile
    global osalSystemDefFile
    global osalRtosComment

    if (enableOSAL.getValue() == True):
        osalHeaderFile.setEnabled(True)
        osalHeaderDefFile.setEnabled(True)
        osalHeaderImpBasicFile.setEnabled(selectRTOS.getSelectedKey() == "BareMetal")
        osalHeaderFreeRtosFile.setEnabled(selectRTOS.getSelectedKey() == "FreeRTOS")
        osalSourceFreeRtosFile.setEnabled(selectRTOS.getSelectedKey() == "FreeRTOS")
        osalSystemDefFile.setEnabled(True)
    else:
        osalHeaderFile.setEnabled(False)
        osalHeaderDefFile.setEnabled(False)
        osalHeaderImpBasicFile.setEnabled(False)
        osalHeaderFreeRtosFile.setEnabled(False)
        osalSourceFreeRtosFile.setEnabled(False)
        osalSystemDefFile.setEnabled(False)

    if (selectRTOS.getSelectedKey() != "BareMetal"):
        osalRtosComment.setLabel("**** Add " + selectRTOS.getSelectedKey() + " Third Party Repo and Instantiate " + selectRTOS.getSelectedKey() + " Component ****")
        osalRtosComment.setVisible(True)
    else:
        osalRtosComment.setVisible(False)

def osalRtosSelection(symbol, event):
    global osalRtosComment
    global selectRTOS

    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

############################################################################
#### Code Generation ####
############################################################################

enableOSAL = harmonyCoreComponent.createBooleanSymbol("ENABLE_OSAL", coreMenu)
enableOSAL.setLabel("Generate OSAL Files")
enableOSAL.setDefaultValue(False)

selectRTOS = harmonyCoreComponent.createKeyValueSetSymbol("SELECT_RTOS", enableOSAL)
selectRTOS.setLabel("Select RTOS or Bare-metal")
selectRTOS.addKey("BareMetal", "0", "Bare-metal")
selectRTOS.addKey("FreeRTOS", "1", "FreeRTOS")
selectRTOS.setOutputMode("Key")
selectRTOS.setDisplayMode("Description")
selectRTOS.setSelectedKey("BareMetal", 1)
selectRTOS.setDependencies(osalRtosSelection, ["ENABLE_OSAL"])
selectRTOS.setVisible(False)

osalRtosComment = harmonyCoreComponent.createCommentSymbol("OSAL_KEY_VALUE_COMMENT", selectRTOS)
osalRtosComment.setLabel("**** Add FreeRTOS Third Party Repo and Instantiate FreeRTOS Component ****")
osalRtosComment.setVisible(False)

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
osalHeaderDefFile.setEnabled(False)
osalHeaderDefFile.setMarkup(True)

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

