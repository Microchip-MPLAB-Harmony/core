
def	instantiateComponent(osalComponent):

	osalMenu = osalComponent.createMenuSymbol(None, None)
	osalMenu.setLabel("OSAL Settings")
	osalMenu.setDescription("Configuration for OSAL layer")
	# osalRTOS = osalComponent.createKeyValueSetSymbol("OSAL_RTOS", osalMenu)
	# osalRTOS.setLabel("RTOS to be used")
	# osalRTOS.setDescription("Selects the RTOS to be used")

	# osalRTOS.addKey("NO_RTOS", "0", "OSAL is configured for no RTOS (bare metal) environment")
	# osalRTOS.addKey("FreeRTOS_V8.x.x", "1", "OSAL is configured for FreeRTOS_V8.x.x")
	# osalRTOS.addKey("FreeRTOS_V7.x.x", "2", "OSAL is configured for FreeRTOS_V7.x.x")
	# osalRTOS.addKey("OpenRTOS_V8.x.x", "3", "OSAL is configured for OpenRTOS_V8.x.x")
	# osalRTOS.addKey("OpenRTOS_V7.x.x", "4", "OSAL is configured for OpenRTOS_V7.x.x")
	# osalRTOS.addKey("uC/OS-III", "5", "OSAL is configured for uC/OS-III")
	# osalRTOS.addKey("uC/OS-II", "6", "OSAL is configured for uC/OS-II")
	# osalRTOS.addKey("ThreadX", "7", "OSAL is configured for ThreadX")
	# osalRTOS.addKey("embOS", "8", "OSAL is configured for embOS")
	# osalRTOS.addKey("FreeRTOS", "9", "OSAL is configured for latest version FreeRTOS (now v9.x.x)")
	# osalRTOS.setOutputMode("Value")
	osalRTOS = osalComponent.createComboSymbol("OSAL_RTOS", osalMenu, osalDIC.keys())
	osalRTOS.setLabel("RTOS to be used")
	osalRTOS.setDefaultValue("NO_RTOS")
	
	configName = Variables.get("__CONFIGURATION_NAME")
	
	osalHeaderFile = osalComponent.createFileSymbol(None, None)
	osalHeaderFile.setSourcePath("/osal/osal.h")
	osalHeaderFile.setOutputName("osal.h")
	osalHeaderFile.setDestPath("/osal/")
	osalHeaderFile.setProjectPath("/osal/")
	osalHeaderFile.setType("HEADER")
	
	osalHeaderDefFile = osalComponent.createFileSymbol(None, None)
	osalHeaderDefFile.setSourcePath("/osal/osal_definitions.h")
	osalHeaderDefFile.setOutputName("osal_definitions.h")
	osalHeaderDefFile.setDestPath("/osal/")
	osalHeaderDefFile.setProjectPath("/osal/")
	osalHeaderDefFile.setType("HEADER")
	
	osalHeaderImpBasicFile = osalComponent.createFileSymbol(None, None)
	osalHeaderImpBasicFile.setSourcePath("/osal/osal_impl_basic.h")
	osalHeaderImpBasicFile.setOutputName("osal_impl_basic.h")
	osalHeaderImpBasicFile.setDestPath("/osal/")
	osalHeaderImpBasicFile.setProjectPath("/osal/")
	osalHeaderImpBasicFile.setType("HEADER")
	osalHeaderImpBasicFile.setEnabled(True)
	osalHeaderImpBasicFile.setDependencies(genImpBasicHeaderFile, ["OSAL_RTOS"])	
	
	osalHeaderFreeRtos7File = osalComponent.createFileSymbol(None, None)
	osalHeaderFreeRtos7File.setSourcePath("/osal/osal_freertos_v7xx.h")
	osalHeaderFreeRtos7File.setOutputName("osal_freertos_v7xx.h")
	osalHeaderFreeRtos7File.setDestPath("/osal/")
	osalHeaderFreeRtos7File.setProjectPath("/osal/")
	osalHeaderFreeRtos7File.setType("HEADER")
	osalHeaderFreeRtos7File.setEnabled(False)
	osalHeaderFreeRtos7File.setDependencies(genFreeRtosv7HeaderFile, ["OSAL_RTOS"])
		
	osalSourceFreeRtos7File = osalComponent.createFileSymbol(None, None)
	osalSourceFreeRtos7File.setSourcePath("/osal/src/osal_freertos_v7xx.c")
	osalSourceFreeRtos7File.setOutputName("osal_freertos_v7xx.c")
	osalSourceFreeRtos7File.setDestPath("/osal/")
	osalSourceFreeRtos7File.setProjectPath("/osal/")
	osalSourceFreeRtos7File.setType("SOURCE")
	osalSourceFreeRtos7File.setEnabled(False)
	osalSourceFreeRtos7File.setDependencies(genFreeRtosv7SourceFile, ["OSAL_RTOS"])

	osalHeaderOpenRTOSFile = osalComponent.createFileSymbol(None, None)
	osalHeaderOpenRTOSFile.setSourcePath("/osal/osal_openrtos.h")
	osalHeaderOpenRTOSFile.setOutputName("osal_openrtos.h")
	osalHeaderOpenRTOSFile.setDestPath("/osal/")
	osalHeaderOpenRTOSFile.setProjectPath("/osal/")
	osalHeaderOpenRTOSFile.setType("HEADER")
	osalHeaderOpenRTOSFile.setEnabled(False)
	osalHeaderOpenRTOSFile.setDependencies(genOpenRTOSHeaderFile, ["OSAL_RTOS"])
		
	osalSourceOpenRTOSFile = osalComponent.createFileSymbol(None, None)
	osalSourceOpenRTOSFile.setSourcePath("/osal/src/osal_openrtos.c")
	osalSourceOpenRTOSFile.setOutputName("osal_openrtos.c")
	osalSourceOpenRTOSFile.setDestPath("/osal/")
	osalSourceOpenRTOSFile.setProjectPath("/osal/")
	osalSourceOpenRTOSFile.setType("SOURCE")
	osalSourceOpenRTOSFile.setEnabled(False)
	osalSourceOpenRTOSFile.setDependencies(genOpenRTOSSourceFile, ["OSAL_RTOS"])

	osalHeaderOpenRTOSV7File = osalComponent.createFileSymbol(None, None)
	osalHeaderOpenRTOSV7File.setSourcePath("/osal/osal_openrtos_v7xx.h")
	osalHeaderOpenRTOSV7File.setOutputName("osal_openrtos_v7xx.h")
	osalHeaderOpenRTOSV7File.setDestPath("/osal/")
	osalHeaderOpenRTOSV7File.setProjectPath("/osal/")
	osalHeaderOpenRTOSV7File.setType("HEADER")
	osalHeaderOpenRTOSV7File.setEnabled(False)
	osalHeaderOpenRTOSV7File.setDependencies(genOpenRTOSV7HeaderFile, ["OSAL_RTOS"])
		
	osalSourceOpenRTOSV7File = osalComponent.createFileSymbol(None, None)
	osalSourceOpenRTOSV7File.setSourcePath("/osal/src/osal_openrtos_v7xx.c")
	osalSourceOpenRTOSV7File.setOutputName("osal_openrtos_v7xx.c")
	osalSourceOpenRTOSV7File.setDestPath("/osal/")
	osalSourceOpenRTOSV7File.setProjectPath("/osal/")
	osalSourceOpenRTOSV7File.setType("SOURCE")
	osalSourceOpenRTOSV7File.setEnabled(False)
	osalSourceOpenRTOSV7File.setDependencies(genOpenRTOSV7SourceFile, ["OSAL_RTOS"])	

	osalHeaderUcos3File = osalComponent.createFileSymbol(None, None)
	osalHeaderUcos3File.setSourcePath("/osal/osal_ucos3.h")
	osalHeaderUcos3File.setOutputName("osal_ucos3.h")
	osalHeaderUcos3File.setDestPath("/osal/")
	osalHeaderUcos3File.setProjectPath("/osal/")
	osalHeaderUcos3File.setType("HEADER")
	osalHeaderUcos3File.setEnabled(False)
	osalHeaderUcos3File.setDependencies(genUcos3HeaderFile, ["OSAL_RTOS"])	
		
	osalSourceUcos3File = osalComponent.createFileSymbol(None, None)
	osalSourceUcos3File.setSourcePath("/osal/src/osal_ucos3.c")
	osalSourceUcos3File.setOutputName("osal_ucos3.c")
	osalSourceUcos3File.setDestPath("/osal/")
	osalSourceUcos3File.setProjectPath("/osal/")
	osalSourceUcos3File.setType("SOURCE")
	osalSourceUcos3File.setEnabled(False)
	osalSourceUcos3File.setDependencies(genUcos3SourceFile, ["OSAL_RTOS"])		

	osalHeaderUcos2File = osalComponent.createFileSymbol(None, None)
	osalHeaderUcos2File.setSourcePath("/osal/osal_ucos2.h")
	osalHeaderUcos2File.setOutputName("osal_ucos2.h")
	osalHeaderUcos2File.setDestPath("/osal/")
	osalHeaderUcos2File.setProjectPath("/osal/")
	osalHeaderUcos2File.setType("HEADER")
	osalHeaderUcos2File.setEnabled(False)
	osalHeaderUcos2File.setDependencies(genUcos2HeaderFile, ["OSAL_RTOS"])
		
	osalSourceUcos2File = osalComponent.createFileSymbol(None, None)
	osalSourceUcos2File.setSourcePath("/osal/src/osal_ucos2.c")
	osalSourceUcos2File.setOutputName("osal_ucos2.c")
	osalSourceUcos2File.setDestPath("/osal/")
	osalSourceUcos2File.setProjectPath("/osal/")
	osalSourceUcos2File.setType("SOURCE")
	osalSourceUcos2File.setEnabled(False)
	osalSourceUcos2File.setDependencies(genUcos2SourceFile, ["OSAL_RTOS"])
	

	osalHeaderThreadxFile = osalComponent.createFileSymbol(None, None)
	osalHeaderThreadxFile.setSourcePath("/osal/osal_threadx.h")
	osalHeaderThreadxFile.setOutputName("osal_threadx.h")
	osalHeaderThreadxFile.setDestPath("/osal/")
	osalHeaderThreadxFile.setProjectPath("/osal/")
	osalHeaderThreadxFile.setType("HEADER")
	osalHeaderThreadxFile.setEnabled(False)
	osalHeaderThreadxFile.setDependencies(genThreadxHeaderFile, ["OSAL_RTOS"])	
		
	osalSourceThreadxFile = osalComponent.createFileSymbol(None, None)
	osalSourceThreadxFile.setSourcePath("/osal/src/osal_threadx.c")
	osalSourceThreadxFile.setOutputName("osal_threadx.c")
	osalSourceThreadxFile.setDestPath("/osal/")
	osalSourceThreadxFile.setProjectPath("/osal/")
	osalSourceThreadxFile.setType("SOURCE")
	osalSourceThreadxFile.setEnabled(False)
	osalSourceThreadxFile.setDependencies(genThreadxSourceFile, ["OSAL_RTOS"])	
	

	osalHeaderEmbosFile = osalComponent.createFileSymbol(None, None)
	osalHeaderEmbosFile.setSourcePath("/osal/osal_embos.h")
	osalHeaderEmbosFile.setOutputName("osal_embos.h")
	osalHeaderEmbosFile.setDestPath("/osal/")
	osalHeaderEmbosFile.setProjectPath("/osal/")
	osalHeaderEmbosFile.setType("HEADER")
	osalHeaderEmbosFile.setEnabled(False)
	osalHeaderEmbosFile.setDependencies(genEmbosHeaderFile, ["OSAL_RTOS"])	
		
	osalSourceEmbosFile = osalComponent.createFileSymbol(None, None)
	osalSourceEmbosFile.setSourcePath("/osal/src/osal_embos.c")
	osalSourceEmbosFile.setOutputName("osal_embos.c")
	osalSourceEmbosFile.setDestPath("/osal/")
	osalSourceEmbosFile.setProjectPath("/osal/")
	osalSourceEmbosFile.setType("SOURCE")
	osalSourceEmbosFile.setEnabled(False)
	osalSourceEmbosFile.setDependencies(genEmbosSourceFile, ["OSAL_RTOS"])	

	osalHeaderFreeRtosFile = osalComponent.createFileSymbol(None, None)
	osalHeaderFreeRtosFile.setSourcePath("/osal/osal_freertos.h")
	osalHeaderFreeRtosFile.setOutputName("osal_freertos.h")
	osalHeaderFreeRtosFile.setDestPath("/osal/")
	osalHeaderFreeRtosFile.setProjectPath("/osal/")
	osalHeaderFreeRtosFile.setType("HEADER")
	osalHeaderFreeRtosFile.setEnabled(False)
	osalHeaderFreeRtosFile.setDependencies(genFreeRtosHeaderFile, ["OSAL_RTOS"])			
		
	osalSourceFreeRtosFile = osalComponent.createFileSymbol(None, None)
	osalSourceFreeRtosFile.setSourcePath("/osal/src/osal_freertos.c")
	osalSourceFreeRtosFile.setOutputName("osal_freertos.c")
	osalSourceFreeRtosFile.setDestPath("/osal/")
	osalSourceFreeRtosFile.setProjectPath("/osal/")
	osalSourceFreeRtosFile.setType("SOURCE")
	osalSourceFreeRtosFile.setEnabled(False)
	osalSourceFreeRtosFile.setDependencies(genFreeRtosSourceFile, ["OSAL_RTOS"])			


	osalSystemDefFile = osalComponent.createFileSymbol(None, None)
	osalSystemDefFile.setType("STRING")
	osalSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
	osalSystemDefFile.setSourcePath("/osal/templates/system/system_definitions.h.ftl")
	osalSystemDefFile.setMarkup(True)
	
	osalSystemConfFile = osalComponent.createFileSymbol(None, None)
	osalSystemConfFile.setType("STRING")
	osalSystemConfFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_MIDDLEWARE_CONFIGURATION")
	osalSystemConfFile.setSourcePath("/osal/templates/system/system_config.h.ftl")
	osalSystemConfFile.setMarkup(True)


def genImpBasicHeaderFile(osalHeaderImpBasicFile, genFiles):
	if genFiles["value"] == "NO_RTOS":
		osalHeaderImpBasicFile.setEnabled(True)
	else :
		osalHeaderImpBasicFile.setEnabled(False)
		
def genFreeRtosv7HeaderFile(osalHeaderFreeRtos7File, genFiles):
	if genFiles["value"] == "FreeRTOS_V7":
		osalHeaderFreeRtos7File.setEnabled(True)
	else :
		osalHeaderFreeRtos7File.setEnabled(False)
		
def genFreeRtosv7SourceFile(osalSourceFreeRtos7File, genFiles):
	if genFiles["value"] == "FreeRTOS_V7":
		osalSourceFreeRtos7File.setEnabled(True)
	else :
		osalSourceFreeRtos7File.setEnabled(False)
		
def genOpenRTOSHeaderFile(osalHeaderOpenRTOSFile, genFiles):
	if genFiles["value"] == "OpenRTOS_V8":
		osalHeaderOpenRTOSFile.setEnabled(True)
	else :
		osalHeaderOpenRTOSFile.setEnabled(False)
		
def genOpenRTOSSourceFile(osalSourceOpenRTOSFile, genFiles):
	if genFiles["value"] == "OpenRTOS_V8":
		osalSourceOpenRTOSFile.setEnabled(True)
	else :
		osalSourceOpenRTOSFile.setEnabled(False)
		
def genOpenRTOSV7HeaderFile(osalHeaderOpenRTOSV7File, genFiles):
	if genFiles["value"] == "OpenRTOS_V7":
		osalHeaderOpenRTOSV7File.setEnabled(True)
	else :
		osalHeaderOpenRTOSV7File.setEnabled(False)
		
def genOpenRTOSV7SourceFile(osalSourceOpenRTOSV7File, genFiles):	
	if genFiles["value"] == "OpenRTOS_V7":
		osalSourceOpenRTOSV7File.setEnabled(True)
	else :
		osalSourceOpenRTOSV7File.setEnabled(False)
		
def genUcos2HeaderFile(osalHeaderUcos2File, genFiles):
	if genFiles["value"] == "uC/OS-II":
		osalHeaderUcos2File.setEnabled(True)
	else :
		osalHeaderUcos2File.setEnabled(False)
		
def genUcos2SourceFile(osalSourceUcos2File, genFiles):
	if genFiles["value"] == "uC/OS-II":
		osalSourceUcos2File.setEnabled(True)
	else :
		osalSourceUcos2File.setEnabled(False)
		
def genUcos3HeaderFile(osalHeaderUcos3File, genFiles):	
	if genFiles["value"] == "uC/OS-III":
		osalHeaderUcos3File.setEnabled(True)
	else :
		osalHeaderUcos3File.setEnabled(False)
		
def genUcos3SourceFile(osalSourceUcos3File, genFiles):
	if genFiles["value"] == "uC/OS-III":
		osalSourceUcos3File.setEnabled(True)
	else :
		osalSourceUcos3File.setEnabled(False)
		
def genThreadxHeaderFile(osalHeaderThreadxFile, genFiles):
	if genFiles["value"] == "ThreadX":
		osalHeaderThreadxFile.setEnabled(True)
	else :
		osalHeaderThreadxFile.setEnabled(False)
		
def genThreadxSourceFile(osalSourceThreadxFile, genFiles):
	if genFiles["value"] == "ThreadX":
		osalSourceThreadxFile.setEnabled(True)
	else :
		osalSourceThreadxFile.setEnabled(False)
		
def genEmbosHeaderFile(osalHeaderEmbosFile, genFiles):
	if genFiles["value"] == "embOS":
		osalHeaderEmbosFile.setEnabled(True)
	else :
		osalHeaderEmbosFile.setEnabled(False)
		
def genEmbosSourceFile(osalSourceEmbosFile, genFiles):
	if genFiles["value"] == "embOS":
		osalSourceEmbosFile.setEnabled(True)
	else :
		osalSourceEmbosFile.setEnabled(False)
		
def genFreeRtosHeaderFile(osalHeaderFreeRtosFile, genFiles):
	if genFiles["value"] == "FreeRTOS":
		osalHeaderFreeRtosFile.setEnabled(True)
	else :
		osalHeaderFreeRtosFile.setEnabled(False)
		
def genFreeRtosSourceFile(osalSourceFreeRtosFile, genFiles):
	if genFiles["value"] == "FreeRTOS":
		osalSourceFreeRtosFile.setEnabled(True)
	else :
		osalSourceFreeRtosFile.setEnabled(False)
		


osalDIC = { 'NO_RTOS' : 0,
				'FreeRTOS_V8.x.x' : 1,
				'FreeRTOS_V7.x.x' : 2,
				'OpenRTOS_V8.x.x' : 3,
				'OpenRTOS_V7.x.x' : 4,
				'uC/OS-III' : 5,
				'uC/OS-II' : 6,
				'ThreadX' : 7,
				'embOS' : 8,
				'FreeRTOS' : 9
				}