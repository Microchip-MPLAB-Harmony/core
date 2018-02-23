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

def setMemoryDeviceValue(symbol, event):
    symbol.clearValue()
    symbol.setValue(event["value"], 1)

def setmemoryDevice(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def setMemoryBuffer(symbol, event):
    if (event["value"] == True):
        symbol.clearValue()
        symbol.setValue(1, 1)
        symbol.setReadOnly(True)
    else:
        symbol.setReadOnly(False)

def instantiateComponent(memoryComponent, index):
    global memoryDeviceUsed
    global memoryDeviceStartAddr
    global memoryDeviceComment
    global memoryDeviceEraseBufferSize
    global memoryDeviceInterruptEnable
    global memoryDeviceInterruptSource
    global memoryDeviceEraseComment

    numInstances = Database.getSymbolValue("drv_memory", "DRV_MEMORY_NUM_INSTANCES")

    if numInstances is None:
        numInstances = 1
    else:
        numInstances = numInstances + 1

    Database.setSymbolValue("drv_memory", "DRV_MEMORY_NUM_INSTANCES", numInstances, 1)

    memoryIndex = memoryComponent.createIntegerSymbol("INDEX", None)
    memoryIndex.setVisible(False)
    memoryIndex.setDefaultValue(index)

    memoryDeviceFsEnable = memoryComponent.createBooleanSymbol("DRV_MEMORY_FS_ENABLE", None)
    memoryDeviceFsEnable.setLabel("Enable File system for Memory Driver")
    memoryDeviceFsEnable.setVisible(False)
    memoryDeviceFsEnable.setReadOnly(True)
    memoryDeviceFsEnable.setDefaultValue((Database.getSymbolValue("drv_memory", "DRV_MEMORY_COMMON_FS_ENABLE") == True))
    memoryDeviceFsEnable.setDependencies(setMemoryDeviceValue, ["drv_memory.DRV_MEMORY_COMMON_FS_ENABLE"])

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
    memorySymBufPool.setReadOnly((memoryDeviceFsEnable.getValue() == True))
    memorySymBufPool.setDependencies(setMemoryBuffer, ["DRV_MEMORY_FS_ENABLE"])

    memoryDeviceUsed = memoryComponent.createStringSymbol("DRV_MEMORY_DEVICE", None)
    memoryDeviceUsed.setLabel("Memory Device Used")
    memoryDeviceUsed.setReadOnly(True)

    memoryDeviceComment = memoryComponent.createCommentSymbol("DRV_MEMORY_DEVICE_COMMENT", None)
    memoryDeviceComment.setVisible(False)
    memoryDeviceComment.setLabel("*** Configure Memory Device in Memory Device Configurations ***")

    memoryDeviceStartAddr = memoryComponent.createHexSymbol("DRV_MEMORY_DEVICE_START_ADDRESS", None)
    memoryDeviceStartAddr.setLabel("Memory Device Start Address")
    memoryDeviceStartAddr.setReadOnly(True)
    memoryDeviceStartAddr.setVisible(False)

    memoryDeviceEraseBufferSize = memoryComponent.createIntegerSymbol("DRV_MEMORY_ERASE_BUFF_SIZE", None)
    memoryDeviceEraseBufferSize.setLabel("Memory Device Erase Buffer Size")
    memoryDeviceEraseBufferSize.setVisible(False)

    memoryDeviceMediaType = memoryComponent.createComboSymbol("DRV_MEMORY_DEVICE_TYPE", None, mediaTypes)
    memoryDeviceMediaType.setLabel("Memory Device Type")
    memoryDeviceMediaType.setDefaultValue("SYS_FS_MEDIA_TYPE_SPIFLASH")
    memoryDeviceMediaType.setVisible((memoryDeviceFsEnable.getValue()))
    memoryDeviceMediaType.setDependencies(setmemoryDevice, ["DRV_MEMORY_FS_ENABLE"])

    memoryDeviceInterruptEnable = memoryComponent.createBooleanSymbol("DRV_MEMORY_INTERRUPT_ENABLE", None)
    memoryDeviceInterruptEnable.setLabel("Enable Interrupt Mode for Memory Driver")
    memoryDeviceInterruptEnable.setVisible(False)
    memoryDeviceInterruptEnable.setDefaultValue(False)

    memoryDeviceInterruptSource = memoryComponent.createStringSymbol("DRV_MEMORY_INTERRUPT_SOURCE", None)
    memoryDeviceInterruptSource.setLabel("Memory Device Interrupt Source")
    memoryDeviceInterruptSource.setVisible(False)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    memorySourceFile = memoryComponent.createFileSymbol("DRV_MEMORY_SOURCE", None)
    memorySourceFile.setSourcePath("driver/memory/src/drv_memory.c")
    memorySourceFile.setOutputName("drv_memory.c")
    memorySourceFile.setDestPath("driver/memory/src")
    memorySourceFile.setProjectPath("config/" + configName + "/driver/memory/")
    memorySourceFile.setType("SOURCE")
    memorySourceFile.setOverwrite(True)

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

    memoryHeaderLocalFile = memoryComponent.createFileSymbol("DRV_MEMORY_HEADER_LOCAL", None)
    memoryHeaderLocalFile.setSourcePath("driver/memory/src/drv_memory_local.h")
    memoryHeaderLocalFile.setOutputName("drv_memory_local.h")
    memoryHeaderLocalFile.setDestPath("driver/memory/src")
    memoryHeaderLocalFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryHeaderLocalFile.setType("HEADER")
    memoryHeaderLocalFile.setOverwrite(True)

    memorySystemDefFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_DEF", None)
    memorySystemDefFile.setType("STRING")
    memorySystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    memorySystemDefFile.setSourcePath("driver/memory/templates/system/system_definitions.h.ftl")
    memorySystemDefFile.setMarkup(True)

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

def destroyComponent(i2cComponent):
    
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

    if (id == "drv_memory_memory_dev_dependency") :
        remoteId = remoteComponent.getID()

        memoryDeviceUsed.clearValue()
        memoryDeviceUsed.setValue(remoteId.upper(), 2)

        memoryDeviceComment.setVisible(True)

#        memoryDeviceInterruptEnable.setDependencies(setMemoryDeviceValue, [remoteId + ".INTERRUPT_ENABLE"])
        memoryDeviceInterruptEnable.setValue(remoteComponent.getSymbolValue("INTERRUPT_ENABLE"), 1)

#        memoryDeviceInterruptSource.setDependencies(setMemoryDeviceValue, [remoteId + ".INTERRUPT_SOURCE"])
        memoryDeviceInterruptSource.setValue(remoteComponent.getSymbolValue("INTERRUPT_SOURCE"), 1)

#        memoryDeviceStartAddr.setDependencies(setMemoryDeviceValue, [remoteId + ".START_ADDRESS"])
        memoryDeviceStartAddr.setValue(remoteComponent.getSymbolValue("START_ADDRESS"), 1)

#        memoryDeviceEraseBufferSize.setDependencies(setMemoryDeviceValue, [remoteId + ".ERASE_BUFFER_SIZE"])
        memoryDeviceEraseBufferSize.setValue(remoteComponent.getSymbolValue("ERASE_BUFFER_SIZE"), 1)

        remoteComponent.setSymbolValue("DRV_MEMORY_CONNECTED", True, 1)
