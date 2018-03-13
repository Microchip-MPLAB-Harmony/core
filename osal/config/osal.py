#####global variables#############
global osalHeaderImpBasicFile
global osalHeaderFreeRtos7File
global osalSourceFreeRtos7File
global osalHeaderOpenRTOSFile
global osalSourceOpenRTOSFile
global osalHeaderOpenRTOSV7File
global osalSourceOpenRTOSV7File
global osalHeaderUcos2File
global osalSourceUcos2File
global osalHeaderUcos3File
global osalSourceUcos3File
global osalHeaderThreadxFile
global osalSourceThreadxFile
global osalHeaderEmbosFile
global osalSourceEmbosFile
global osalHeaderFreeRtosFile
global osalSourceFreeRtosFile
#############################################################

def	instantiateComponent(osalComponent):

	global osalHeaderImpBasicFile
	global osalHeaderFreeRtos7File
	global osalSourceFreeRtos7File
	global osalHeaderOpenRTOSFile
	global osalSourceOpenRTOSFile
	global osalHeaderOpenRTOSV7File
	global osalSourceOpenRTOSV7File
	global osalHeaderUcos2File
	global osalSourceUcos2File
	global osalHeaderUcos3File
	global osalSourceUcos3File
	global osalHeaderThreadxFile
	global osalSourceThreadxFile
	global osalHeaderEmbosFile
	global osalSourceEmbosFile
	global osalHeaderFreeRtosFile
	global osalSourceFreeRtosFile
	osalMenu = osalComponent.createMenuSymbol("OSAL_MENU", None)
	osalMenu.setLabel("OSAL Settings")
	osalMenu.setDescription("Configuration for OSAL layer")
	osalRTOS = osalComponent.createKeyValueSetSymbol("OSAL_RTOS", osalMenu)
	osalRTOS.setLabel("RTOS to be used")
	osalRTOS.setDescription("Selects the RTOS to be used")

	osalRTOS.addKey("NO_RTOS", "0", "OSAL is configured for no RTOS (bare metal) environment")
	osalRTOS.addKey("FreeRTOS_V8.x.x", "1", "OSAL is configured for FreeRTOS_V8.x.x")
	osalRTOS.addKey("FreeRTOS_V7.x.x", "2", "OSAL is configured for FreeRTOS_V7.x.x")
	osalRTOS.addKey("OpenRTOS_V8.x.x", "3", "OSAL is configured for OpenRTOS_V8.x.x")
	osalRTOS.addKey("OpenRTOS_V7.x.x", "4", "OSAL is configured for OpenRTOS_V7.x.x")
	osalRTOS.addKey("uC/OS-III", "5", "OSAL is configured for uC/OS-III")
	osalRTOS.addKey("uC/OS-II", "6", "OSAL is configured for uC/OS-II")
	osalRTOS.addKey("ThreadX", "7", "OSAL is configured for ThreadX")
	osalRTOS.addKey("embOS", "8", "OSAL is configured for embOS")
	osalRTOS.addKey("FreeRTOS", "9", "OSAL is configured for latest version FreeRTOS (now v9.x.x)")
	osalRTOS.setOutputMode("Value")
	# osalRTOS = osalComponent.createComboSymbol("OSAL_RTOS", osalMenu, osalDIC.keys())
	# osalRTOS.setLabel("RTOS to be used")
	# osalRTOS.setDefaultValue("NO_RTOS")

	configName = Variables.get("__CONFIGURATION_NAME")

	osalHeaderFile = osalComponent.createFileSymbol("OSAL_H", None)
	osalHeaderFile.setSourcePath("/osal/osal.h")
	osalHeaderFile.setOutputName("osal.h")
	osalHeaderFile.setDestPath("/osal/")
	osalHeaderFile.setProjectPath("/osal/")
	osalHeaderFile.setType("HEADER")

	osalHeaderDefFile = osalComponent.createFileSymbol("OSAL_DEFINITIONS_H", None)
	osalHeaderDefFile.setSourcePath("/osal/osal_definitions.h")
	osalHeaderDefFile.setOutputName("osal_definitions.h")
	osalHeaderDefFile.setDestPath("/osal/")
	osalHeaderDefFile.setProjectPath("/osal/")
	osalHeaderDefFile.setType("HEADER")

	osalHeaderImpBasicFile = osalComponent.createFileSymbol("OSAL_IMPL_BASIC_H", None)
	osalHeaderImpBasicFile.setSourcePath("/osal/osal_impl_basic.h")
	osalHeaderImpBasicFile.setOutputName("osal_impl_basic.h")
	osalHeaderImpBasicFile.setDestPath("/osal/")
	osalHeaderImpBasicFile.setProjectPath("/osal/")
	osalHeaderImpBasicFile.setType("HEADER")
	osalHeaderImpBasicFile.setEnabled(True)
	osalHeaderImpBasicFile.setDependencies(osalFile, ["OSAL_RTOS"])

	osalHeaderFreeRtos7File = osalComponent.createFileSymbol("OSAL_FREERTOS_V7XX_H", None)
	osalHeaderFreeRtos7File.setSourcePath("/osal/osal_freertos_v7xx.h")
	osalHeaderFreeRtos7File.setOutputName("osal_freertos_v7xx.h")
	osalHeaderFreeRtos7File.setDestPath("/osal/")
	osalHeaderFreeRtos7File.setProjectPath("/osal/")
	osalHeaderFreeRtos7File.setType("HEADER")
	osalHeaderFreeRtos7File.setEnabled(False)

	osalSourceFreeRtos7File = osalComponent.createFileSymbol("OSAL_FREERTOS_V7XX_C", None)
	osalSourceFreeRtos7File.setSourcePath("/osal/src/osal_freertos_v7xx.c")
	osalSourceFreeRtos7File.setOutputName("osal_freertos_v7xx.c")
	osalSourceFreeRtos7File.setDestPath("/osal/")
	osalSourceFreeRtos7File.setProjectPath("/osal/")
	osalSourceFreeRtos7File.setType("SOURCE")
	osalSourceFreeRtos7File.setEnabled(False)


	osalHeaderOpenRTOSFile = osalComponent.createFileSymbol("OSAL_OPENRTOS_H", None)
	osalHeaderOpenRTOSFile.setSourcePath("/osal/osal_openrtos.h")
	osalHeaderOpenRTOSFile.setOutputName("osal_openrtos.h")
	osalHeaderOpenRTOSFile.setDestPath("/osal/")
	osalHeaderOpenRTOSFile.setProjectPath("/osal/")
	osalHeaderOpenRTOSFile.setType("HEADER")
	osalHeaderOpenRTOSFile.setEnabled(False)


	osalSourceOpenRTOSFile = osalComponent.createFileSymbol("OSAL_OPENRTOS_C", None)
	osalSourceOpenRTOSFile.setSourcePath("/osal/src/osal_openrtos.c")
	osalSourceOpenRTOSFile.setOutputName("osal_openrtos.c")
	osalSourceOpenRTOSFile.setDestPath("/osal/")
	osalSourceOpenRTOSFile.setProjectPath("/osal/")
	osalSourceOpenRTOSFile.setType("SOURCE")
	osalSourceOpenRTOSFile.setEnabled(False)


	osalHeaderOpenRTOSV7File = osalComponent.createFileSymbol("OSAL_OPENRTOS_V7XX_H", None)
	osalHeaderOpenRTOSV7File.setSourcePath("/osal/osal_openrtos_v7xx.h")
	osalHeaderOpenRTOSV7File.setOutputName("osal_openrtos_v7xx.h")
	osalHeaderOpenRTOSV7File.setDestPath("/osal/")
	osalHeaderOpenRTOSV7File.setProjectPath("/osal/")
	osalHeaderOpenRTOSV7File.setType("HEADER")
	osalHeaderOpenRTOSV7File.setEnabled(False)


	osalSourceOpenRTOSV7File = osalComponent.createFileSymbol("OSAL_OPENRTOS_V7XX_C", None)
	osalSourceOpenRTOSV7File.setSourcePath("/osal/src/osal_openrtos_v7xx.c")
	osalSourceOpenRTOSV7File.setOutputName("osal_openrtos_v7xx.c")
	osalSourceOpenRTOSV7File.setDestPath("/osal/")
	osalSourceOpenRTOSV7File.setProjectPath("/osal/")
	osalSourceOpenRTOSV7File.setType("SOURCE")
	osalSourceOpenRTOSV7File.setEnabled(False)


	osalHeaderUcos3File = osalComponent.createFileSymbol("OSAL_UCOS3_H", None)
	osalHeaderUcos3File.setSourcePath("/osal/osal_ucos3.h")
	osalHeaderUcos3File.setOutputName("osal_ucos3.h")
	osalHeaderUcos3File.setDestPath("/osal/")
	osalHeaderUcos3File.setProjectPath("/osal/")
	osalHeaderUcos3File.setType("HEADER")
	osalHeaderUcos3File.setEnabled(False)


	osalSourceUcos3File = osalComponent.createFileSymbol("OSAL_UCOS3_C", None)
	osalSourceUcos3File.setSourcePath("/osal/src/osal_ucos3.c")
	osalSourceUcos3File.setOutputName("osal_ucos3.c")
	osalSourceUcos3File.setDestPath("/osal/")
	osalSourceUcos3File.setProjectPath("/osal/")
	osalSourceUcos3File.setType("SOURCE")
	osalSourceUcos3File.setEnabled(False)


	osalHeaderUcos2File = osalComponent.createFileSymbol("osal_ucos2_h", None)
	osalHeaderUcos2File.setSourcePath("/osal/osal_ucos2.h")
	osalHeaderUcos2File.setOutputName("osal_ucos2.h")
	osalHeaderUcos2File.setDestPath("/osal/")
	osalHeaderUcos2File.setProjectPath("/osal/")
	osalHeaderUcos2File.setType("HEADER")
	osalHeaderUcos2File.setEnabled(False)


	osalSourceUcos2File = osalComponent.createFileSymbol("OSAL_UCOS2_C", None)
	osalSourceUcos2File.setSourcePath("/osal/src/osal_ucos2.c")
	osalSourceUcos2File.setOutputName("osal_ucos2.c")
	osalSourceUcos2File.setDestPath("/osal/")
	osalSourceUcos2File.setProjectPath("/osal/")
	osalSourceUcos2File.setType("SOURCE")
	osalSourceUcos2File.setEnabled(False)



	osalHeaderThreadxFile = osalComponent.createFileSymbol("OSAL_THREADX_H", None)
	osalHeaderThreadxFile.setSourcePath("/osal/osal_threadx.h")
	osalHeaderThreadxFile.setOutputName("osal_threadx.h")
	osalHeaderThreadxFile.setDestPath("/osal/")
	osalHeaderThreadxFile.setProjectPath("/osal/")
	osalHeaderThreadxFile.setType("HEADER")
	osalHeaderThreadxFile.setEnabled(False)


	osalSourceThreadxFile = osalComponent.createFileSymbol("OSAL_THREADX_C", None)
	osalSourceThreadxFile.setSourcePath("/osal/src/osal_threadx.c")
	osalSourceThreadxFile.setOutputName("osal_threadx.c")
	osalSourceThreadxFile.setDestPath("/osal/")
	osalSourceThreadxFile.setProjectPath("/osal/")
	osalSourceThreadxFile.setType("SOURCE")
	osalSourceThreadxFile.setEnabled(False)



	osalHeaderEmbosFile = osalComponent.createFileSymbol("OSAL_EMBOS_H", None)
	osalHeaderEmbosFile.setSourcePath("/osal/osal_embos.h")
	osalHeaderEmbosFile.setOutputName("osal_embos.h")
	osalHeaderEmbosFile.setDestPath("/osal/")
	osalHeaderEmbosFile.setProjectPath("/osal/")
	osalHeaderEmbosFile.setType("HEADER")
	osalHeaderEmbosFile.setEnabled(False)


	osalSourceEmbosFile = osalComponent.createFileSymbol("OSAL_EMBOS_C", None)
	osalSourceEmbosFile.setSourcePath("/osal/src/osal_embos.c")
	osalSourceEmbosFile.setOutputName("osal_embos.c")
	osalSourceEmbosFile.setDestPath("/osal/")
	osalSourceEmbosFile.setProjectPath("/osal/")
	osalSourceEmbosFile.setType("SOURCE")
	osalSourceEmbosFile.setEnabled(False)


	osalHeaderFreeRtosFile = osalComponent.createFileSymbol("OSAL_FREERTOS_H", None)
	osalHeaderFreeRtosFile.setSourcePath("/osal/osal_freertos.h")
	osalHeaderFreeRtosFile.setOutputName("osal_freertos.h")
	osalHeaderFreeRtosFile.setDestPath("/osal/")
	osalHeaderFreeRtosFile.setProjectPath("/osal/")
	osalHeaderFreeRtosFile.setType("HEADER")
	osalHeaderFreeRtosFile.setEnabled(False)


	osalSourceFreeRtosFile = osalComponent.createFileSymbol("OSAL_FREERTOS_C", None)
	osalSourceFreeRtosFile.setSourcePath("/osal/src/osal_freertos.c")
	osalSourceFreeRtosFile.setOutputName("osal_freertos.c")
	osalSourceFreeRtosFile.setDestPath("/osal/")
	osalSourceFreeRtosFile.setProjectPath("/osal/")
	osalSourceFreeRtosFile.setType("SOURCE")
	osalSourceFreeRtosFile.setEnabled(False)



	osalSystemDefFile = osalComponent.createFileSymbol("OSAL_DEFINITIONS_H", None)
	osalSystemDefFile.setType("STRING")
	osalSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
	osalSystemDefFile.setSourcePath("/osal/templates/system/system_definitions.h.ftl")
	osalSystemDefFile.setMarkup(True)

	osalSystemConfFile = osalComponent.createFileSymbol("OSAL_CONFIG_H", None)
	osalSystemConfFile.setType("STRING")
	osalSystemConfFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_MIDDLEWARE_CONFIGURATION")
	osalSystemConfFile.setSourcePath("/osal/templates/system/system_config.h.ftl")
	osalSystemConfFile.setMarkup(True)


def osalFile(osalHeaderFile, genFiles):
	osalHeaderImpBasicFile.setEnabled(genFiles["value"] == 0)
	osalHeaderFreeRtos7File.setEnabled(genFiles["value"] == 2)
	osalSourceFreeRtos7File.setEnabled(genFiles["value"] == 2)
	osalHeaderOpenRTOSFile.setEnabled(genFiles["value"] == 3)
	osalSourceOpenRTOSFile.setEnabled(genFiles["value"] == 3)
	osalHeaderOpenRTOSV7File.setEnabled(genFiles["value"] == 4)
	osalSourceOpenRTOSV7File.setEnabled(genFiles["value"] == 4)
	osalHeaderUcos2File.setEnabled(genFiles["value"] == 6)
	osalSourceUcos2File.setEnabled(genFiles["value"] == 6)
	osalHeaderUcos3File.setEnabled(genFiles["value"] == 5)
	osalSourceUcos3File.setEnabled(genFiles["value"] == 5)
	osalHeaderThreadxFile.setEnabled(genFiles["value"] == 7)
	osalSourceThreadxFile.setEnabled(genFiles["value"] == 7)
	osalHeaderEmbosFile.setEnabled(genFiles["value"] == 8)
	osalSourceEmbosFile.setEnabled(genFiles["value"] == 8)
	osalHeaderFreeRtosFile.setEnabled(genFiles["value"] == 9)
	osalSourceFreeRtosFile.setEnabled(genFiles["value"] == 9)
