################################################################################
#### Component ####
################################################################################

memoryDeviceUsed            = None
memoryDeviceStartAddr       = None
memoryDeviceEraseBufferSize = None
memoryDeviceEraseComment    = None
memoryDeviceInterruptEnable = None
memoryDeviceInterruptSource = None
memoryDeviceComment         = None

mediaTypes =  ["SYS_FS_MEDIA_TYPE_NVM",
                "SYS_FS_MEDIA_TYPE_MSD",
                "SYS_FS_MEDIA_TYPE_SD_CARD",
                "SYS_FS_MEDIA_TYPE_RAM",
                "SYS_FS_MEDIA_TYPE_SPIFLASH"]

def setVisible(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def genRtosTask(symbol, event):
    if (event["value"] != 0):
        # If not Bare Metal
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def showRTOSMenu(symbol, event):
    if (event["value"] != 0):
        # If not Bare Metal
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def setMemoryDeviceValue(symbol, event):
    symbol.clearValue()
    symbol.setValue(event["value"], 1)

def syncFileGen(symbol, event):
    if(event["value"] == 1):
       symbol.setEnabled(True)
    elif(event["value"] == 0):
       symbol.setEnabled(False)

def aSyncFileGen(symbol, event):
    if(event["value"] == 0):
       symbol.setEnabled(True)
    elif(event["value"] == 1):
       symbol.setEnabled(False)

def setRtosUseDelay(symbol, event):
    if (event["value"] == 0):
        symbol.setVisible(True)
        symbol.clearValue()
        symbol.setValue(True, 1)
    elif(event["value"] == 1):
        symbol.setVisible(False)
        symbol.clearValue()
        symbol.setValue(False, 1)

def setMemoryBuffer(symbol, event):
    if (event["id"] == "DRV_MEMORY_COMMON_MODE"):
        if (event["value"] == 0):
            symbol.setVisible(True)
        elif(event["value"] == 1):
            symbol.setVisible(False)
    else:
        if (event["value"] == True):
            symbol.clearValue()
            symbol.setValue(1, 1)
            symbol.setReadOnly(True)
        else:
            symbol.setReadOnly(False)

def setFileSystemCounter(symbol, event):
    if (event["value"] == True):
        Database.setSymbolValue("drv_memory", "DRV_MEMORY_COMMON_FS_COUNTER", True, 1)
    else:
        Database.setSymbolValue("drv_memory", "DRV_MEMORY_COMMON_FS_COUNTER", False, 1)

def instantiateComponent(memoryComponent, index):
    global memoryDeviceUsed
    global memoryDeviceStartAddr
    global memoryDeviceComment
    global memoryDeviceEraseBufferSize
    global memoryDeviceInterruptEnable
    global memoryDeviceInterruptSource
    global memoryDeviceEraseComment

    # Enable dependent Harmony core components
    Database.clearSymbolValue("Harmony", "ENABLE_DRV_COMMON")
    Database.setSymbolValue("Harmony", "ENABLE_DRV_COMMON", True, 2)
    
    Database.clearSymbolValue("Harmony", "ENABLE_SYS_COMMON")
    Database.setSymbolValue("Harmony", "ENABLE_SYS_COMMON", True, 2)

    Database.clearSymbolValue("Harmony", "ENABLE_SYS_MEDIA")
    Database.setSymbolValue("Harmony", "ENABLE_SYS_MEDIA", True, 2)

    Database.clearSymbolValue("Harmony", "ENABLE_SYS_INT")
    Database.setSymbolValue("Harmony", "ENABLE_SYS_INT", True, 2)

    Database.clearSymbolValue("Harmony", "ENABLE_OSAL")
    Database.setSymbolValue("Harmony", "ENABLE_OSAL", True, 2)

    Database.clearSymbolValue("Harmony", "ENABLE_APP_FILE")
    Database.setSymbolValue("Harmony", "ENABLE_APP_FILE", True, 2)

    numInstances = Database.getSymbolValue("drv_memory", "DRV_MEMORY_NUM_INSTANCES")

    if numInstances is None:
        numInstances = 1
    else:
        numInstances = numInstances + 1
        Database.setSymbolValue("drv_memory", "DRV_MEMORY_NUM_INSTANCES", numInstances, 1)

    memoryIndex = memoryComponent.createIntegerSymbol("INDEX", None)
    memoryIndex.setVisible(False)
    memoryIndex.setDefaultValue(index)

    memoryFsEnable = memoryComponent.createBooleanSymbol("DRV_MEMORY_FS_ENABLE", None)
    memoryFsEnable.setLabel("Enable File system for Memory Driver")
    memoryFsEnable.setDefaultValue(False)

    memoryfsCounter = memoryComponent.createBooleanSymbol("DRV_MEMORY_FS_COUNTER", None)
    memoryfsCounter.setLabel("FS Counter")
    memoryfsCounter.setVisible(False)
    memoryfsCounter.setDependencies(setFileSystemCounter, ["DRV_MEMORY_FS_ENABLE"])

    memorySymNumClients = memoryComponent.createIntegerSymbol("DRV_MEMORY_NUM_CLIENTS", None)
    memorySymNumClients.setLabel("Number of Clients")
    memorySymNumClients.setMin(1)
    memorySymNumClients.setMax(10)
    memorySymNumClients.setDefaultValue(1)
    memorySymNumClients.setVisible(True)

    memorySymBufPool = memoryComponent.createIntegerSymbol("DRV_MEMORY_BUFFER_QUEUE_SIZE", None)
    memorySymBufPool.setLabel("Buffer Queue Size")
    memorySymBufPool.setMin(1)
    memorySymBufPool.setDefaultValue(1)
    memorySymBufPool.setVisible(True)
    memorySymBufPool.setReadOnly((memoryFsEnable.getValue() == True))
    memorySymBufPool.setDependencies(setMemoryBuffer, ["DRV_MEMORY_FS_ENABLE", "drv_memory.DRV_MEMORY_COMMON_MODE"])

    memoryDeviceUsed = memoryComponent.createStringSymbol("DRV_MEMORY_DEVICE", None)
    memoryDeviceUsed.setLabel("Memory Device Used")
    memoryDeviceUsed.setReadOnly(True)

    memoryDeviceComment = memoryComponent.createCommentSymbol("DRV_MEMORY_DEVICE_COMMENT", None)
    memoryDeviceComment.setVisible(False)
    memoryDeviceComment.setLabel("*** Configure Memory Device in Memory Device Configurations ***")

    memoryDeviceStartAddr = memoryComponent.createHexSymbol("DRV_MEMORY_DEVICE_START_ADDRESS", None)
    memoryDeviceStartAddr.setLabel("Memory Device Start Address")
    memoryDeviceStartAddr.setVisible(False)
    memoryDeviceStartAddr.setReadOnly(True)
    memoryDeviceStartAddr.setDependencies(setMemoryDeviceValue, ["drv_memory_memory_dev_dependency:START_ADDRESS"])

    memoryDeviceEraseBufferSize = memoryComponent.createIntegerSymbol("DRV_MEMORY_ERASE_BUFF_SIZE", None)
    memoryDeviceEraseBufferSize.setLabel("Memory Device Erase Buffer Size")
    memoryDeviceEraseBufferSize.setVisible(False)
    memoryDeviceEraseBufferSize.setReadOnly(True)
    memoryDeviceEraseBufferSize.setDependencies(setMemoryDeviceValue, ["drv_memory_memory_dev_dependency:ERASE_BUFFER_SIZE"])

    memoryDeviceInterruptEnable = memoryComponent.createBooleanSymbol("DRV_MEMORY_INTERRUPT_ENABLE", None)
    memoryDeviceInterruptEnable.setLabel("Enable Interrupt Mode for Memory Driver")
    memoryDeviceInterruptEnable.setVisible(False)
    memoryDeviceInterruptEnable.setDefaultValue(False)
    memoryDeviceInterruptEnable.setReadOnly(True)
    memoryDeviceInterruptEnable.setDependencies(setMemoryDeviceValue, ["drv_memory_memory_dev_dependency:INTERRUPT_ENABLE"])

    memoryDeviceInterruptSource = memoryComponent.createStringSymbol("DRV_MEMORY_INTERRUPT_SOURCE", None)
    memoryDeviceInterruptSource.setLabel("Memory Device Interrupt Source")
    memoryDeviceInterruptSource.setVisible(False)
    memoryDeviceInterruptSource.setReadOnly(True)
    memoryDeviceInterruptSource.setDependencies(setMemoryDeviceValue, ["drv_memory_memory_dev_dependency:INTERRUPT_SOURCE"])

    memoryDeviceMediaType = memoryComponent.createComboSymbol("DRV_MEMORY_DEVICE_TYPE", None, mediaTypes)
    memoryDeviceMediaType.setLabel("Memory Device Type")
    memoryDeviceMediaType.setDefaultValue("SYS_FS_MEDIA_TYPE_SPIFLASH")
    memoryDeviceMediaType.setVisible((memoryFsEnable.getValue() == True))
    memoryDeviceMediaType.setDependencies(setVisible, ["DRV_MEMORY_FS_ENABLE"])

    memoryRTOSMenu = memoryComponent.createMenuSymbol(None, None)
    memoryRTOSMenu.setLabel("RTOS settings")
    memoryRTOSMenu.setDescription("RTOS settings")
    memoryRTOSMenu.setVisible((Database.getSymbolValue("Harmony", "SELECT_RTOS") != 0))
    memoryRTOSMenu.setDependencies(showRTOSMenu, ["Harmony.SELECT_RTOS"])

    memoryRTOSTask = memoryComponent.createComboSymbol("DRV_MEMORY_RTOS", memoryRTOSMenu, ["Standalone"])
    memoryRTOSTask.setLabel("Run Library Tasks As")
    memoryRTOSTask.setDefaultValue("Standalone")
    memoryRTOSTask.setVisible(False)

    memoryRTOSStackSize = memoryComponent.createIntegerSymbol("DRV_MEMORY_RTOS_STACK_SIZE", memoryRTOSMenu)
    memoryRTOSStackSize.setLabel("Stack Size")
    memoryRTOSStackSize.setDefaultValue(1024)
    memoryRTOSStackSize.setReadOnly(True)

    memoryRTOSTaskPriority = memoryComponent.createIntegerSymbol("DRV_MEMORY_RTOS_TASK_PRIORITY", memoryRTOSMenu)
    memoryRTOSTaskPriority.setLabel("Task Priority")
    memoryRTOSTaskPriority.setDefaultValue(1)

    memoryRTOSTaskDelay = memoryComponent.createBooleanSymbol("DRV_MEMORY_RTOS_USE_DELAY", memoryRTOSMenu)
    memoryRTOSTaskDelay.setLabel("Use Task Delay?")
    memoryRTOSTaskDelay.setDefaultValue((Database.getSymbolValue("drv_memory", "DRV_MEMORY_COMMON_MODE") == 0))
    memoryRTOSTaskDelay.setVisible((Database.getSymbolValue("drv_memory", "DRV_MEMORY_COMMON_MODE") == 0))
    memoryRTOSTaskDelay.setDependencies(setRtosUseDelay, ["drv_memory.DRV_MEMORY_COMMON_MODE"])

    memoryRTOSTaskDelayVal = memoryComponent.createIntegerSymbol("DRV_MEMORY_RTOS_DELAY", memoryRTOSMenu)
    memoryRTOSTaskDelayVal.setLabel("Task Delay")
    memoryRTOSTaskDelayVal.setDefaultValue(1000) 
    memoryRTOSTaskDelayVal.setVisible((memoryRTOSTaskDelay.getValue() == True))
    memoryRTOSTaskDelayVal.setDependencies(setVisible, ["DRV_MEMORY_RTOS_USE_DELAY"])


    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    memoryHeaderFile = memoryComponent.createFileSymbol("DRV_MEMORY_HEADER", None)
    memoryHeaderFile.setSourcePath("driver/memory/drv_memory.h")
    memoryHeaderFile.setOutputName("drv_memory.h")
    memoryHeaderFile.setDestPath("driver/memory/")
    memoryHeaderFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryHeaderFile.setType("HEADER")
    memoryHeaderFile.setOverwrite(True)

    memoryHeaderDefFile = memoryComponent.createFileSymbol("DRV_MEMORY_HEADER_DEF", None)
    memoryHeaderDefFile.setSourcePath("driver/memory/drv_memory_definitions.h")
    memoryHeaderDefFile.setOutputName("drv_memory_definitions.h")
    memoryHeaderDefFile.setDestPath("driver/memory/")
    memoryHeaderDefFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryHeaderDefFile.setType("HEADER")
    memoryHeaderDefFile.setOverwrite(True)

    # Async Source Files
    memoryAsyncSourceFile = memoryComponent.createFileSymbol("DRV_MEMORY_ASYNC_SOURCE", None)
    memoryAsyncSourceFile.setSourcePath("driver/memory/async/src/drv_memory.c")
    memoryAsyncSourceFile.setOutputName("drv_memory.c")
    memoryAsyncSourceFile.setDestPath("driver/memory/src")
    memoryAsyncSourceFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryAsyncSourceFile.setType("SOURCE")
    memoryAsyncSourceFile.setOverwrite(True)
    memoryAsyncSourceFile.setDependencies(aSyncFileGen, ["drv_memory.DRV_MEMORY_COMMON_MODE"])

    memoryAsyncHeaderLocalFile = memoryComponent.createFileSymbol("DRV_MEMORY_ASYNC_HEADER_LOCAL", None)
    memoryAsyncHeaderLocalFile.setSourcePath("driver/memory/async/src/drv_memory_local.h")
    memoryAsyncHeaderLocalFile.setOutputName("drv_memory_local.h")
    memoryAsyncHeaderLocalFile.setDestPath("driver/memory/src")
    memoryAsyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryAsyncHeaderLocalFile.setType("HEADER")
    memoryAsyncHeaderLocalFile.setOverwrite(True)
    memoryAsyncHeaderLocalFile.setDependencies(aSyncFileGen, ["drv_memory.DRV_MEMORY_COMMON_MODE"])

    # Sync Source Files
    memorySyncSourceFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYNC_SOURCE", None)
    memorySyncSourceFile.setSourcePath("driver/memory/sync/src/drv_memory.c")
    memorySyncSourceFile.setOutputName("drv_memory.c")
    memorySyncSourceFile.setDestPath("driver/memory/src")
    memorySyncSourceFile.setProjectPath("config/" + configName + "/driver/memory/")
    memorySyncSourceFile.setType("SOURCE")
    memorySyncSourceFile.setOverwrite(True)
    memorySyncSourceFile.setDependencies(syncFileGen, ["drv_memory.DRV_MEMORY_COMMON_MODE"])

    memorySyncHeaderLocalFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYNC_HEADER_LOCAL", None)
    memorySyncHeaderLocalFile.setSourcePath("driver/memory/sync/src/drv_memory_local.h")
    memorySyncHeaderLocalFile.setOutputName("drv_memory_local.h")
    memorySyncHeaderLocalFile.setDestPath("driver/memory/src")
    memorySyncHeaderLocalFile.setProjectPath("config/" + configName + "/driver/memory/")
    memorySyncHeaderLocalFile.setType("HEADER")
    memorySyncHeaderLocalFile.setOverwrite(True)
    memorySyncHeaderLocalFile.setDependencies(syncFileGen, ["drv_memory.DRV_MEMORY_COMMON_MODE"])

    # System Template Files
    memorySystemDefObjFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_DEF_OBJ", None)
    memorySystemDefObjFile.setType("STRING")
    memorySystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    memorySystemDefObjFile.setSourcePath("driver/memory/templates/system/system_definitions_objects.h.ftl")
    memorySystemDefObjFile.setMarkup(True)

    memorySystemConfigFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_CFG", None)
    memorySystemConfigFile.setType("STRING")
    memorySystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    memorySystemConfigFile.setSourcePath("driver/memory/templates/system/system_config.h.ftl")
    memorySystemConfigFile.setMarkup(True)

    memorySystemInitDataFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_INIT_DATA", None)
    memorySystemInitDataFile.setType("STRING")
    memorySystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    memorySystemInitDataFile.setSourcePath("driver/memory/templates/system/system_initialize_data.c.ftl")
    memorySystemInitDataFile.setMarkup(True)

    memorySystemInitFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_INIT", None)
    memorySystemInitFile.setType("STRING")
    memorySystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    memorySystemInitFile.setSourcePath("driver/memory/templates/system/system_initialize.c.ftl")
    memorySystemInitFile.setMarkup(True)

    memorySystemTasksFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_TASK", None)
    memorySystemTasksFile.setType("STRING")
    memorySystemTasksFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_DRIVER_TASKS")
    memorySystemTasksFile.setSourcePath("driver/memory/templates/system/system_tasks.c.ftl")
    memorySystemTasksFile.setMarkup(True)

    memorySystemRtosTasksFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_RTOS_TASK", None)
    memorySystemRtosTasksFile.setType("STRING")
    memorySystemRtosTasksFile.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
    memorySystemRtosTasksFile.setSourcePath("driver/memory/templates/system/system_rtos_tasks.c.ftl")
    memorySystemRtosTasksFile.setMarkup(True)
    memorySystemRtosTasksFile.setEnabled((Database.getSymbolValue("Harmony", "SELECT_RTOS") != 0))
    memorySystemRtosTasksFile.setDependencies(genRtosTask, ["Harmony.SELECT_RTOS"])

def destroyComponent(memoryComponent):
    numInstances = Database.getSymbolValue("drv_memory", "DRV_MEMORY_NUM_INSTANCES")   
    numInstances = numInstances - 1   
    Database.setSymbolValue("drv_memory", "DRV_MEMORY_NUM_INSTANCES", numInstances, 1)

def onDependentComponentAdded(memoryComponent, id, remoteComponent):
    global memoryDeviceUsed
    global memoryDeviceStartAddr
    global memoryDeviceComment
    global memoryDeviceEraseBufferSize
    global memoryDeviceInterruptEnable
    global memoryDeviceInterruptSource

    if (id == "drv_memory_MEMORY_dependency") :
        remoteId = remoteComponent.getID()

        memoryDeviceUsed.clearValue()
        memoryDeviceUsed.setValue(remoteId.upper(), 2)

        memoryDeviceComment.setVisible(True)

        memoryDeviceInterruptEnable.setValue(remoteComponent.getSymbolValue("INTERRUPT_ENABLE"), 1)

        memoryDeviceInterruptSource.setValue(remoteComponent.getSymbolValue("INTERRUPT_SOURCE"), 1)

        memoryDeviceStartAddr.setValue(remoteComponent.getSymbolValue("START_ADDRESS"), 1)

        memoryDeviceEraseBufferSize.setValue(remoteComponent.getSymbolValue("ERASE_BUFFER_SIZE"), 1)

        remoteComponent.setSymbolValue("DRV_MEMORY_CONNECTED", True, 1)
