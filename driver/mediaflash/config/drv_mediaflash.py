def instantiateComponent(mediaflashComponent, index):

	numInstances = 0
	
	try:
		numInstances = Database.getSymbolValue("drv_mediaflash", "DRV_MEDIAFLASH_NUM_INSTANCES")
	except:
		numInstances = 0
		
	if numInstances < (index+1):
		Database.clearSymbolValue("drv_mediaflash", "DRV_MEDIAFLASH_NUM_INSTANCES")
		Database.setSymbolValue("drv_mediaflash", "DRV_MEDIAFLASH_NUM_INSTANCES", (index+1), 2)
	
	mediaflashSymIndex = mediaflashComponent.createIntegerSymbol("INDEX", None)
	mediaflashSymIndex.setVisible(False)
	mediaflashSymIndex.setDefaultValue(index)
		
	mediaflashEnable = mediaflashComponent.createBooleanSymbol("USE_DRV_MEDIAFLASH", None)
	mediaflashEnable.setLabel("Use MediaFlash Driver?")
	mediaflashEnable.setDefaultValue(False)
	
	mediaflashMenu = mediaflashComponent.createMenuSymbol("DRV_MEDIAFLASH_MENU_0", None)
	mediaflashMenu.setLabel("Driver Settings")
	mediaflashMenu.setVisible(False)
	mediaflashMenu.setDependencies(showMenu, ["USE_DRV_MEDIAFLASH"])
	
	mediaflashClients = mediaflashComponent.createIntegerSymbol("DRV_MEDIAFLASH_CLIENTS_NUMBER", mediaflashMenu)
	mediaflashClients.setLabel("Number of MEDIAFLASH Driver Clients")
	mediaflashClients.setDefaultValue(1)
	
	mediaflashAddress = mediaflashComponent.createHexSymbol("DRV_MEDIAFLASH_MEDIA_START_ADDRESS", mediaflashMenu)
	mediaflashAddress.setLabel("MEDIAFLASH Media Start Address")
	mediaflashAddress.setDefaultValue(0x500000)
	mediaflashAddress.setMax(0x600000)
	
	mediaflashSize = mediaflashComponent.createIntegerSymbol("DRV_MEDIAFLASH_MEDIA_SIZE", mediaflashMenu)
	mediaflashSize.setLabel("MEDIAFLASH Media Size")
	mediaflashSize.setDefaultValue(1024)
	
	
	mediaflashBufferObjects = mediaflashComponent.createIntegerSymbol("DRV_MEDIAFLASH_BUFFER_OBJECT_NUMBER", mediaflashMenu)
	mediaflashBufferObjects.setLabel("Number of MEDIAFLASH Buffer Objects")
	mediaflashBufferObjects.setDefaultValue(8)
	mediaflashBufferObjects.setMax(10)
	
	mediaflashEraseWrite = mediaflashComponent.createBooleanSymbol("USE_DRV_MEDIAFLASH_ERASE_WRITE", mediaflashMenu)
	mediaflashEraseWrite.setLabel("Enable Erase Write Function?")
	mediaflashEraseWrite.setDefaultValue(False)
	
	mediaflashRegisterFS = mediaflashComponent.createBooleanSymbol("USE_DRV_MEDIAFLASH_SYS_FS_REGISTER", mediaflashMenu)
	mediaflashRegisterFS.setLabel("Register with File System?")
	mediaflashRegisterFS.setDefaultValue(False)
	
	mediaflashErrorCheck = mediaflashComponent.createBooleanSymbol("USE_DRV_MEDIAFLASH_DISABLE_ERROR_CHECK", mediaflashMenu)
	mediaflashErrorCheck.setLabel("Disable Error Checks?")
	mediaflashErrorCheck.setDefaultValue(False)
	
	
	configName = Variables.get("__CONFIGURATION_NAME")

	mediaflashHeaderFile = mediaflashComponent.createFileSymbol("MEDIAFLASH_FILE_0", None)
	mediaflashHeaderFile.setSourcePath("driver/mediaflash/drv_mediaflash.h")
	mediaflashHeaderFile.setOutputName("drv_mediaflash.h")
	mediaflashHeaderFile.setDestPath("/driver/mediaflash/")
	mediaflashHeaderFile.setProjectPath("/driver/mediaflash/")
	mediaflashHeaderFile.setType("HEADER")
	
	mediaflashSource1File = mediaflashComponent.createFileSymbol("MEDIAFLASH_FILE_1", None)
	mediaflashSource1File.setSourcePath("driver/mediaflash/src/drv_mediaflash.c")
	mediaflashSource1File.setOutputName("drv_mediaflash.c")
	mediaflashSource1File.setDestPath("/driver/mediaflash/src/")
	mediaflashSource1File.setProjectPath("/driver/mediaflash/src/")
	mediaflashSource1File.setType("SOURCE")
	
	mediaflashHeaderLocalFile = mediaflashComponent.createFileSymbol("MEDIAFLASH_FILE_2", None)
	mediaflashHeaderLocalFile.setSourcePath("driver/mediaflash/src/drv_mediaflash_local.h")
	mediaflashHeaderLocalFile.setOutputName("drv_mediaflash_local.h")
	mediaflashHeaderLocalFile.setDestPath("/driver/mediaflash/src/")
	mediaflashHeaderLocalFile.setProjectPath("/driver/mediaflash/src/")
	mediaflashHeaderLocalFile.setType("HEADER")
	
	mediaflashHeaderVmapFile = mediaflashComponent.createFileSymbol("MEDIAFLASH_FILE_3", None)
	mediaflashHeaderVmapFile.setSourcePath("driver/mediaflash/src/drv_mediaflash_variant_mapping.h")
	mediaflashHeaderVmapFile.setOutputName("drv_mediaflash_variant_mapping.h")
	mediaflashHeaderVmapFile.setDestPath("/driver/mediaflash/src/")
	mediaflashHeaderVmapFile.setProjectPath("/driver/mediaflash/src/")
	mediaflashHeaderVmapFile.setType("HEADER")
	
	mediaflashSourceEraseWriteFile = mediaflashComponent.createFileSymbol("MEDIAFLASH_FILE_4", None)
	mediaflashSourceEraseWriteFile.setSourcePath("driver/mediaflash/src/drv_mediaflash_erasewrite.c")
	mediaflashSourceEraseWriteFile.setOutputName("drv_mediaflash_erasewrite.c")
	mediaflashSourceEraseWriteFile.setDestPath("/driver/mediaflash/src/")
	mediaflashSourceEraseWriteFile.setProjectPath("/driver/mediaflash/src/")
	mediaflashSourceEraseWriteFile.setType("SOURCE")
	mediaflashSourceEraseWriteFile.setEnabled(False)
	mediaflashSourceEraseWriteFile.setDependencies(genSourceFile, ["USE_DRV_MEDIAFLASH_ERASE_WRITE"])
	
	mediaflashSystemDefFile = mediaflashComponent.createFileSymbol("MEDIAFLASH_FILE_5", None)
	mediaflashSystemDefFile.setType("STRING")
	mediaflashSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
	mediaflashSystemDefFile.setSourcePath("/driver/mediaflash/template/system_definitions.h.ftl")
	mediaflashSystemDefFile.setMarkup(True)
	
	mediaflashSystemInitFile = mediaflashComponent.createFileSymbol("MEDIAFLASH_FILE_6", None)
	mediaflashSystemInitFile.setType("STRING")
	mediaflashSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_CORE")
	mediaflashSystemInitFile.setSourcePath("/driver/mediaflash/template/system_initialize.c.ftl")
	mediaflashSystemInitFile.setMarkup(True)
	
	mediaflashSystemConfFile = mediaflashComponent.createFileSymbol("MEDIAFLASH_FILE_7", None)
	mediaflashSystemConfFile.setType("STRING")
	mediaflashSystemConfFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
	mediaflashSystemConfFile.setSourcePath("/driver/mediaflash/template/system_config.h.ftl")
	mediaflashSystemConfFile.setMarkup(True)
	
	mediaflashSystemDataFile = mediaflashComponent.createFileSymbol("MEDIAFLASH_FILE_8", None)
	mediaflashSystemDataFile.setType("STRING")
	mediaflashSystemDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
	mediaflashSystemDataFile.setSourcePath("/driver/mediaflash/template/system_data_initialize.c.ftl")
	mediaflashSystemDataFile.setMarkup(True)
	
	mediaflashSystemObjFile = mediaflashComponent.createFileSymbol("MEDIAFLASH_FILE_9", None)
	mediaflashSystemObjFile.setType("STRING")
	mediaflashSystemObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
	mediaflashSystemObjFile.setSourcePath("/driver/mediaflash/template/system_objects.h.ftl")
	mediaflashSystemObjFile.setMarkup(True)
	
	
def showMenu(mediaflashMenu, enable):
	mediaflashMenu.setVisible(enable["value"])
	
def genSourceFile (mediaflashSourceEraseWriteFile, genFile):
	mediaflashSourceEraseWriteFile.setEnabled(genFile["value"])
	
def deinstantiateComponent(mediaflashComponent):
    numInstances = numInstances - 1
    Database.setSymbolValue("drv_mediaflash", "DRV_MEDIAFLASH_NUM_INSTANCES", numInstances, 1)