def instantiateComponent(sdhcComponent, index):
	numInstances = 0

	try:
		numInstances = Database.getSymbolValue("drv_sdhc", "DRV_SDHC_NUM_INSTANCES")
	except:
		numInstances = 0

	#numInstances = numInstances + 1

	if numInstances < (index+1):
		Database.clearSymbolValue("drv_sdhc", "DRV_SDHC_NUM_INSTANCES")
		Database.setSymbolValue("drv_sdhc", "DRV_SDHC_NUM_INSTANCES", (index+1), 2)
		
	peripId = Interrupt.getInterruptIndex("HSMCI")
	NVICVector = "NVIC_" + str(peripId) + "_ENABLE"
	NVICHandler = "NVIC_" + str(peripId) + "_HANDLER"
	NVICHandlerLock = "NVIC_" + str(peripId) + "_HANDLER_LOCK"
	
	sdhcDMA = sdhcComponent.createIntegerSymbol("SDHC_DMA", None)
	sdhcDMA.setVisible(False)
	sdhcDMA.setDependencies(dmaChannel, ["core.DMA_CH_FOR_HSMCI"])
	
	sdhcCLK = sdhcComponent.createIntegerSymbol("SDHC_CLK", None)
	sdhcCLK.setVisible(False)
	sdhcCLK.setDependencies(sdhcClock, ["core.CLK_MASTER"])
	sdhcCLK.setDefaultValue(150000000)
	
	Database.clearSymbolValue("core", NVICVector)
	Database.setSymbolValue("core", NVICVector, True, 2)
	Database.clearSymbolValue("core", NVICHandler)
	Database.setSymbolValue("core", NVICHandler, "SDHC_InterruptHandler", 2)
	Database.clearSymbolValue("core", NVICHandlerLock)
	Database.setSymbolValue("core", NVICHandlerLock, True, 2)
	Database.clearSymbolValue("core", "PMC_ID_HSMCI")
	Database.setSymbolValue("core", "PMC_ID_HSMCI", True, 2)
	Database.setSymbolValue("core","DMA_CH_NEEDED_FOR_HSMCI", True, 2)
	
	sdhcEnable = sdhcComponent.createBooleanSymbol("USE_DRV_SDHC", None)
	sdhcEnable.setLabel("Use SDHC Driver?")
	sdhcEnable.setDefaultValue(False)

	sdhcMenu = sdhcComponent.createMenuSymbol("SDHC_MENU", None)
	sdhcMenu.setLabel("SD Host Controller settings")
	sdhcMenu.setDescription("SD Host Controller settings")
	sdhcMenu.setVisible(False)
	sdhcMenu.setDependencies(showMenu, ["USE_DRV_SDHC"])

	sdhcRTOSMenu = sdhcComponent.createMenuSymbol("SDHC_SUBMENU", sdhcMenu)
	sdhcRTOSMenu.setLabel("RTOS Configuration")
	sdhcRTOSMenu.setDescription("RTOS Configuration")
	sdhcRTOSMenu.setVisible(False)
	sdhcRTOSMenu.setDependencies(showRTOSMenu, ["USE_DRV_SDHC","HarmonyCore.SELECT_RTOS"])

	sdhcRTOSTask = sdhcComponent.createComboSymbol("DRV_SDHC_RTOS", sdhcRTOSMenu, ["Standalone"])
	sdhcRTOSTask.setLabel("Run Library Tasks As")
	sdhcRTOSTask.setDefaultValue("Standalone")

	sdhcRTOSTaskSize = sdhcComponent.createIntegerSymbol("DRV_SDHC_RTOS_TASK_SIZE", sdhcRTOSMenu)
	sdhcRTOSTaskSize.setLabel("Task Size")
	sdhcRTOSTaskSize.setDefaultValue(1024)

	sdhcRTOSTaskPriority = sdhcComponent.createIntegerSymbol("DRV_SDHC_RTOS_TASK_PRIORITY", sdhcRTOSMenu)
	sdhcRTOSTaskPriority.setLabel("Task Priority")
	sdhcRTOSTaskPriority.setDefaultValue(1)

	sdhcRTOSTaskDelay = sdhcComponent.createBooleanSymbol("DRV_SDHC_RTOS_USE_DELAY", sdhcRTOSMenu)
	sdhcRTOSTaskDelay.setLabel("Use Task Delay?")
	sdhcRTOSTaskDelay.setDefaultValue(True)

	sdhcRTOSTaskDelayVal = sdhcComponent.createIntegerSymbol("DRV_SDHC_RTOS_DELAY", sdhcRTOSMenu)
	sdhcRTOSTaskDelayVal.setLabel("Task Delay")
	sdhcRTOSTaskDelayVal.setDefaultValue(1000)
	sdhcRTOSTaskDelayVal.setDependencies(showRTOSTaskDel, ["DRV_SDHC_RTOS_USE_DELAY"])

	sdhcClients = sdhcComponent.createIntegerSymbol("DRV_SDHC_CLIENTS_NUMBER", sdhcMenu)
	sdhcClients.setLabel("Number of SDHC Driver Clients")
	sdhcClients.setDefaultValue(1)

	sdhcBufferObjects = sdhcComponent.createIntegerSymbol("DRV_SDHC_BUFFER_OBJECT_NUMBER", sdhcMenu)
	sdhcBufferObjects.setLabel("Number of SDHC Buffer Objects")
	sdhcBufferObjects.setDefaultValue(8)
	sdhcBufferObjects.setMax(10)

	sdhcBusWidth= sdhcComponent.createComboSymbol("DRV_SDHC_TRANSFER_BUS_WIDTH", sdhcMenu,["1-bit", "4-bit"])
	sdhcBusWidth.setLabel("Data Transfer Bus Width")
	sdhcBusWidth.setDefaultValue("4-bit")

	sdhcBusWidth= sdhcComponent.createComboSymbol("DRV_SDHC_SDHC_BUS_SPEED", sdhcMenu,["DEFAULT_SPEED", "HIGH_SPEED"])
	sdhcBusWidth.setLabel("Maximum Bus Speed")
	sdhcBusWidth.setDefaultValue("DEFAULT_SPEED")

	sdhcWP = sdhcComponent.createBooleanSymbol("DRV_SDHC_SDWPEN", sdhcMenu)
	sdhcWP.setLabel("Use Write Protect (SDWP#) Pin")
	sdhcWP.setDefaultValue(False)

	sdhcWPComment = sdhcComponent.createCommentSymbol("DRV_SDHC_SDWPEN_COMMENT", sdhcMenu)
	sdhcWPComment.setLabel("*****Use pin manager to rename the Pin as SDWP*********")
	sdhcWPComment.setVisible(False)
	sdhcWPComment.setDependencies(showWPComment, ["DRV_SDHC_SDWPEN"])

	sdhcCD = sdhcComponent.createBooleanSymbol("DRV_SDHC_SDCDEN", sdhcMenu)
	sdhcCD.setLabel("Use Card Detect (SDCD#) Pin")
	sdhcCD.setDefaultValue(False)

	sdhcCDComment = sdhcComponent.createCommentSymbol("DRV_SDHC_SDCDEN_COMMENT", sdhcMenu)
	sdhcCDComment.setLabel("*****Use pin manager to rename the Pin as SDCD*********")
	sdhcCDComment.setVisible(False)
	sdhcCDComment.setDependencies(showCDComment, ["DRV_SDHC_SDCDEN"])


	sdhcInstances = sdhcComponent.createIntegerSymbol("DRV_SDHC_INSTANCES_NUMBER", sdhcMenu)
	sdhcInstances.setLabel("Number of SDHC Instances")
	sdhcInstances.setDefaultValue(1)
	sdhcInstances.setMax(1)
	sdhcInstances.setMin(0)
	
	sdhcRegisterFS = sdhcComponent.createBooleanSymbol("DRV_SDHC_SYS_FS_REGISTER", sdhcMenu)
	sdhcRegisterFS.setLabel("Register with File System?")
	sdhcRegisterFS.setDefaultValue(False)

	configName = Variables.get("__CONFIGURATION_NAME")

	sdhcHeaderFile = sdhcComponent.createFileSymbol("DRV_SDHC_H", None)
	sdhcHeaderFile.setSourcePath("driver/sdhc/drv_sdhc.h")
	sdhcHeaderFile.setOutputName("drv_sdhc.h")
	sdhcHeaderFile.setDestPath("/driver/sdhc/")
	sdhcHeaderFile.setProjectPath("config/" + configName + "/driver/sdhc/")
	sdhcHeaderFile.setType("HEADER")

	sdhcSource1File = sdhcComponent.createFileSymbol("DRV_SDHC_C", None)
	sdhcSource1File.setSourcePath("driver/sdhc/src/drv_sdhc.c")
	sdhcSource1File.setOutputName("drv_sdhc.c")
	sdhcSource1File.setDestPath("/driver/sdhc/src/")
	sdhcSource1File.setProjectPath("config/" + configName + "/driver/sdhc/")
	sdhcSource1File.setType("SOURCE")
	
	
	sdhcHeaderLocalFile = sdhcComponent.createFileSymbol("DRV_SDHC_LOCAL_H", None)
	sdhcHeaderLocalFile.setSourcePath("driver/sdhc/src/drv_sdhc_local.h")
	sdhcHeaderLocalFile.setOutputName("drv_sdhc_local.h")
	sdhcHeaderLocalFile.setDestPath("/driver/sdhc/src/")
	sdhcHeaderLocalFile.setProjectPath("config/" + configName + "/driver/sdhc/")
	sdhcHeaderLocalFile.setType("HEADER")

	sdhcHeaderVmapFile = sdhcComponent.createFileSymbol("DRV_SDHC_VARIANT_MAPPING_H", None)
	sdhcHeaderVmapFile.setSourcePath("driver/sdhc/src/drv_sdhc_variant_mapping.h")
	sdhcHeaderVmapFile.setOutputName("drv_sdhc_variant_mapping.h")
	sdhcHeaderVmapFile.setDestPath("/driver/sdhc/src/")
	sdhcHeaderVmapFile.setProjectPath("config/" + configName + "/driver/sdhc/")
	sdhcHeaderVmapFile.setType("HEADER")

	sdhcHeaderHostLocFile = sdhcComponent.createFileSymbol("DRV_SDHC_HOST_LOCAL_H", None)
	sdhcHeaderHostLocFile.setSourcePath("driver/sdhc/src/drv_sdhc_host_local.h")
	sdhcHeaderHostLocFile.setOutputName("drv_sdhc_host_local.h")
	sdhcHeaderHostLocFile.setDestPath("/driver/sdhc/src/")
	sdhcHeaderHostLocFile.setProjectPath("config/" + configName + "/driver/sdhc/")
	sdhcHeaderHostLocFile.setType("HEADER")

	sdhcHeaderHostFile = sdhcComponent.createFileSymbol("DRV_SDHC_HOST_H", None)
	sdhcHeaderHostFile.setSourcePath("driver/sdhc/src/drv_sdhc_host.h")
	sdhcHeaderHostFile.setOutputName("drv_sdhc_host.h")
	sdhcHeaderHostFile.setDestPath("/driver/sdhc/src/")
	sdhcHeaderHostFile.setProjectPath("config/" + configName + "/driver/sdhc/")
	sdhcHeaderHostFile.setType("HEADER")

	sdhcSourceHostFile = sdhcComponent.createFileSymbol("DRV_SDHC_HOST_C", None)
	sdhcSourceHostFile.setType("SOURCE")
	sdhcSourceHostFile.setOutputName("drv_sdhc_host.c")
	sdhcSourceHostFile.setSourcePath("/driver/sdhc/templates/drv_sdhc_host.c.ftl")
	sdhcSourceHostFile.setDestPath("/driver/sdhc/src/")
	sdhcSourceHostFile.setProjectPath("config/" + configName + "/driver/sdhc/")
	sdhcSourceHostFile.setMarkup(True)

	sdhcSystemDefFile = sdhcComponent.createFileSymbol("DRV_SDHC_DEFINITIONS_H", None)
	sdhcSystemDefFile.setType("STRING")
	sdhcSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
	sdhcSystemDefFile.setSourcePath("/driver/sdhc/templates/system/system_definitions.h.ftl")
	sdhcSystemDefFile.setMarkup(True)

	sdhcSystemInitFile = sdhcComponent.createFileSymbol("DRV_SDHC_INITIALIZE_C", None)
	sdhcSystemInitFile.setType("STRING")
	sdhcSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
	sdhcSystemInitFile.setSourcePath("/driver/sdhc/templates/system/system_initialize.c.ftl")
	sdhcSystemInitFile.setMarkup(True)

	sdhcSystemConfFile = sdhcComponent.createFileSymbol("DRV_SDHC_CONFIGURATION_H", None)
	sdhcSystemConfFile.setType("STRING")
	sdhcSystemConfFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
	sdhcSystemConfFile.setSourcePath("/driver/sdhc/templates/system/system_config.h.ftl")
	sdhcSystemConfFile.setMarkup(True)

	sdhcSystemDataFile = sdhcComponent.createFileSymbol("DRV_SDHC_INITIALIZATION_DATA_C", None)
	sdhcSystemDataFile.setType("STRING")
	sdhcSystemDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
	sdhcSystemDataFile.setSourcePath("/driver/sdhc/templates/system/system_data_initialize.c.ftl")
	sdhcSystemDataFile.setMarkup(True)

	sdhcSystemObjFile = sdhcComponent.createFileSymbol("DRV_SDHC_SYSTEM_OBJECTS_H", None)
	sdhcSystemObjFile.setType("STRING")
	sdhcSystemObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
	sdhcSystemObjFile.setSourcePath("/driver/sdhc/templates/system/system_objects.h.ftl")
	sdhcSystemObjFile.setMarkup(True)

	sdhcSystemTaskFile = sdhcComponent.createFileSymbol("DRV_SDHC_SYSTEM_TASKS_C", None)
	sdhcSystemTaskFile.setType("STRING")
	sdhcSystemTaskFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS")
	sdhcSystemTaskFile.setSourcePath("/driver/sdhc/templates/system/system_tasks.c.ftl")
	sdhcSystemTaskFile.setMarkup(True)

	sdhcSystemInterruptFile = sdhcComponent.createFileSymbol("DRV_SDHC_SYSTEM_INTERRUPT_C", None)
	sdhcSystemInterruptFile.setType("STRING")
	sdhcSystemInterruptFile.setOutputName("core.LIST_SYSTEM_INTERRUPT_C_VECTORS")
	sdhcSystemInterruptFile.setSourcePath("/driver/sdhc/templates/system/system_interrupt.c.ftl")
	sdhcSystemInterruptFile.setMarkup(True)

def showRTOSMenu(symbol,event):
    if (event["value"] != "BareMetal"):
        # If not Bare Metal
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def showRTOSTaskDel(sdhcRTOSTaskDelayVal, enable):
	sdhcRTOSTaskDelayVal.setVisible(enable["value"])

def showMenu(sdhcMenu,enable):
	sdhcMenu.setVisible(enable["value"])

def showCDComment(sdhcCDComment,enable):
	sdhcCDComment.setVisible(enable["value"])

def showWPComment(sdhcWPComment,enable):
	sdhcWPComment.setVisible(enable["value"])

def deinstantiateComponent(i2cComponent):

    numInstances = Database.getSymbolValue("drv_sdhc", "DRV_SDHC_NUM_INSTANCES")
    print("#####destroyComponent Component: instances = ", numInstances)
    numInstances = numInstances - 1
    Database.setSymbolValue("drv_sdhc", "DRV_SDHC_NUM_INSTANCES", numInstances, 1)

def dmaChannel(sym, channel):
	sym.setValue(channel[value], 2)

def sdhcClock(sym, clock):
	sym.setValue(channel[value], 2)