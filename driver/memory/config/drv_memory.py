# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*****************************************************************************"""

################################################################################
#### Component ####
################################################################################

memoryDeviceUsed            = None
memoryPlibUsed              = None
memoryDeviceInterruptEnable = None
memoryDeviceEraseEnable     = None
memoryDeviceComment         = None
memoryPlibSourceFile        = None
memoryPlibHeaderFile        = None
memoryPlibSystemDefFile     = None
memoryFsEnable              = None

mediaTypes =  ["SYS_FS_MEDIA_TYPE_NVM",
                "SYS_FS_MEDIA_TYPE_RAM",
                "SYS_FS_MEDIA_TYPE_SPIFLASH"]

def setVisible(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def setMemoryDevicePoll(symbol, event):
    global memoryDeviceUsed
    global memoryDeviceInterruptEnable


    enable_poll = False

    if (memoryDeviceInterruptEnable.getValue() == False):
        if (Database.getSymbolValue("drv_memory", "DRV_MEMORY_COMMON_SYS_TIME_ENABLE") == True):
            if (memoryDeviceUsed.getValue() != ""):
                enable_poll = True

    symbol.setVisible(enable_poll)

def genRtosTask(symbol, event):
    gen_rtos_task = False

    if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
        if (Database.getSymbolValue("drv_memory", "DRV_MEMORY_COMMON_MODE") == "Asynchronous"):
            gen_rtos_task = True

    symbol.setEnabled(gen_rtos_task)

def showRTOSMenu(symbol, event):
    show_rtos_menu = False

    if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
        if (Database.getSymbolValue("drv_memory", "DRV_MEMORY_COMMON_MODE") == "Asynchronous"):
            show_rtos_menu = True

    symbol.setVisible(show_rtos_menu)

def setMemoryDeviceValue(symbol, event):
    symbol.clearValue()
    symbol.setValue(event["value"])

def setMemoryBuffer(symbol, event):
    if (event["id"] == "DRV_MEMORY_COMMON_MODE"):
        if (event["value"] == "Asynchronous"):
            symbol.setVisible(True)
        elif(event["value"] == "Synchronous"):
            symbol.setVisible(False)
    else:
        if (event["value"] == True):
            symbol.clearValue()
            symbol.setValue(1)
            symbol.setReadOnly(True)
        else:
            symbol.setReadOnly(False)

def instantiateComponent(memoryComponent, index):
    global memoryDeviceUsed
    global memoryDeviceComment
    global memoryDeviceInterruptEnable
    global memoryDeviceEraseEnable
    global memoryPlibSourceFile
    global memoryPlibHeaderFile
    global memoryPlibSystemDefFile
    global memoryPlibUsed
    global memoryFsEnable

    # Enable dependent Harmony core components
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
        Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True)

    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True)

    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA")
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_MEDIA", True)

    memoryIndex = memoryComponent.createIntegerSymbol("INDEX", None)
    memoryIndex.setVisible(False)
    memoryIndex.setDefaultValue(index)

    memorySymNumClients = memoryComponent.createIntegerSymbol("DRV_MEMORY_NUM_CLIENTS", None)
    memorySymNumClients.setLabel("Number of Clients")
    memorySymNumClients.setMin(1)
    memorySymNumClients.setMax(10)
    memorySymNumClients.setDefaultValue(1)
    memorySymNumClients.setVisible(True)

    memoryFsEnable = memoryComponent.createBooleanSymbol("DRV_MEMORY_FS_ENABLE", None)
    memoryFsEnable.setLabel("File system Enabled for Memory Driver")
    memoryFsEnable.setReadOnly(True)

    memorySymBufPool = memoryComponent.createIntegerSymbol("DRV_MEMORY_BUFFER_QUEUE_SIZE", None)
    memorySymBufPool.setLabel("Buffer Queue Size")
    memorySymBufPool.setMin(1)
    memorySymBufPool.setMax(64)
    memorySymBufPool.setDefaultValue(1)
    memorySymBufPool.setVisible((Database.getSymbolValue("drv_memory", "DRV_MEMORY_COMMON_MODE") == "Asynchronous"))
    memorySymBufPool.setReadOnly((memoryFsEnable.getValue() == True))
    memorySymBufPool.setDependencies(setMemoryBuffer, ["DRV_MEMORY_FS_ENABLE", "drv_memory.DRV_MEMORY_COMMON_MODE"])

    memoryDeviceMediaType = memoryComponent.createComboSymbol("DRV_MEMORY_DEVICE_TYPE", None, mediaTypes)
    memoryDeviceMediaType.setLabel("Memory Device Type")
    memoryDeviceMediaType.setDefaultValue("SYS_FS_MEDIA_TYPE_SPIFLASH")
    memoryDeviceMediaType.setVisible((memoryFsEnable.getValue() == True))
    memoryDeviceMediaType.setDependencies(setVisible, ["DRV_MEMORY_FS_ENABLE"])

    memoryDeviceUsed = memoryComponent.createStringSymbol("DRV_MEMORY_DEVICE", None)
    memoryDeviceUsed.setLabel("Memory Device Used")
    memoryDeviceUsed.setReadOnly(True)

    memoryDeviceComment = memoryComponent.createCommentSymbol("DRV_MEMORY_DEVICE_COMMENT", None)
    memoryDeviceComment.setVisible(False)
    memoryDeviceComment.setLabel("*** Configure Memory Device in "+ memoryDeviceUsed.getValue() + " Configurations ***")

    memoryDeviceInterruptEnable = memoryComponent.createBooleanSymbol("DRV_MEMORY_INTERRUPT_ENABLE", None)
    memoryDeviceInterruptEnable.setLabel("Enable Interrupt for Memory Device")
    memoryDeviceInterruptEnable.setVisible(False)
    memoryDeviceInterruptEnable.setDefaultValue(False)
    memoryDeviceInterruptEnable.setReadOnly(True)
    memoryDeviceInterruptEnable.setDependencies(setMemoryDeviceValue, ["drv_memory_MEMORY_dependency:INTERRUPT_ENABLE"])

    enable_poll = False

    if (memoryDeviceInterruptEnable.getValue() == False):
        if (Database.getSymbolValue("drv_memory", "DRV_MEMORY_COMMON_SYS_TIME_ENABLE") == True):
            if (memoryDeviceUsed.getValue() != ""):
                enable_poll = True

    memoryDevicePollUs = memoryComponent.createIntegerSymbol("DRV_MEMORY_DEVICE_POLL_US", None)
    memoryDevicePollUs.setLabel("Memory Device Status Polling Rate MicroSeconds")
    memoryDevicePollUs.setMin(0)
    memoryDevicePollUs.setDefaultValue(500)
    memoryDevicePollUs.setVisible(enable_poll)
    memoryDevicePollUs.setDependencies(setMemoryDevicePoll, ["DRV_MEMORY_INTERRUPT_ENABLE", "drv_memory.DRV_MEMORY_COMMON_SYS_TIME_ENABLE", "DRV_MEMORY_DEVICE"])

    memoryPlibUsed = memoryComponent.createStringSymbol("DRV_MEMORY_PLIB", None)
    memoryPlibUsed.setLabel("Plib Used")
    memoryPlibUsed.setVisible(False)
    memoryPlibUsed.setReadOnly(True)

    memoryDeviceEraseEnable = memoryComponent.createBooleanSymbol("DRV_MEMORY_ERASE_ENABLE", None)
    memoryDeviceEraseEnable.setLabel("Enable Erase for Memory Device")
    memoryDeviceEraseEnable.setVisible(False)
    memoryDeviceEraseEnable.setDefaultValue(False)
    memoryDeviceEraseEnable.setReadOnly(True)
    memoryDeviceEraseEnable.setDependencies(setMemoryDeviceValue, ["drv_memory_MEMORY_dependency:ERASE_ENABLE"])

    enable_rtos_settings = False

    if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
        if (Database.getSymbolValue("drv_memory", "DRV_MEMORY_COMMON_MODE") == "Asynchronous"):
            enable_rtos_settings = True

    # RTOS Settings
    memoryRTOSMenu = memoryComponent.createMenuSymbol("DRV_MEMORY_RTOS_MENU", None)
    memoryRTOSMenu.setLabel("RTOS settings")
    memoryRTOSMenu.setDescription("RTOS settings")
    memoryRTOSMenu.setVisible(enable_rtos_settings)
    memoryRTOSMenu.setDependencies(showRTOSMenu, ["HarmonyCore.SELECT_RTOS", "drv_memory.DRV_MEMORY_COMMON_MODE"])

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
    memoryRTOSTaskDelay.setDefaultValue(True)

    memoryRTOSTaskDelayVal = memoryComponent.createIntegerSymbol("DRV_MEMORY_RTOS_DELAY", memoryRTOSMenu)
    memoryRTOSTaskDelayVal.setLabel("Task Delay")
    memoryRTOSTaskDelayVal.setDefaultValue(10)
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

    memoryPlibSourceFile = memoryComponent.createFileSymbol("DRV_MEMORY_PLIB_SOURCE", None)
    memoryPlibSourceFile.setSourcePath("driver/memory/templates/drv_memory_plib.c.ftl")
    memoryPlibSourceFile.setDestPath("driver/memory/src")
    memoryPlibSourceFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryPlibSourceFile.setType("SOURCE")
    memoryPlibSourceFile.setOverwrite(True)
    memoryPlibSourceFile.setMarkup(True)
    memoryPlibSourceFile.setEnabled(False)

    memoryPlibHeaderFile = memoryComponent.createFileSymbol("DRV_MEMORY_PLIB_HEADER", None)
    memoryPlibHeaderFile.setSourcePath("driver/memory/templates/drv_memory_plib.h.ftl")
    memoryPlibHeaderFile.setDestPath("driver/memory/")
    memoryPlibHeaderFile.setProjectPath("config/" + configName + "/driver/memory/")
    memoryPlibHeaderFile.setType("HEADER")
    memoryPlibHeaderFile.setOverwrite(True)
    memoryPlibHeaderFile.setMarkup(True)
    memoryPlibHeaderFile.setEnabled(False)

    memoryPlibSystemDefFile = memoryComponent.createFileSymbol("DRV_MEMORY_PLIB_SYS_DEF", None)
    memoryPlibSystemDefFile.setType("STRING")
    memoryPlibSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    memoryPlibSystemDefFile.setSourcePath("driver/memory/templates/system/definitions_plib.h.ftl")
    memoryPlibSystemDefFile.setMarkup(True)
    memoryPlibSystemDefFile.setEnabled(False)

    # System Template Files
    memorySystemDefObjFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_DEF_OBJ", None)
    memorySystemDefObjFile.setType("STRING")
    memorySystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    memorySystemDefObjFile.setSourcePath("driver/memory/templates/system/definitions_objects.h.ftl")
    memorySystemDefObjFile.setMarkup(True)

    memorySystemConfigFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_CFG", None)
    memorySystemConfigFile.setType("STRING")
    memorySystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    memorySystemConfigFile.setSourcePath("driver/memory/templates/system/configuration.h.ftl")
    memorySystemConfigFile.setMarkup(True)

    memorySystemInitDataFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_INIT_DATA", None)
    memorySystemInitDataFile.setType("STRING")
    memorySystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA")
    memorySystemInitDataFile.setSourcePath("driver/memory/templates/system/initialization_data.c.ftl")
    memorySystemInitDataFile.setMarkup(True)

    memorySystemInitFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_INIT", None)
    memorySystemInitFile.setType("STRING")
    memorySystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    memorySystemInitFile.setSourcePath("driver/memory/templates/system/initialization.c.ftl")
    memorySystemInitFile.setMarkup(True)

    memorySystemTasksFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_TASK", None)
    memorySystemTasksFile.setType("STRING")
    memorySystemTasksFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_DRIVER_TASKS")
    memorySystemTasksFile.setSourcePath("driver/memory/templates/system/tasks.c.ftl")
    memorySystemTasksFile.setMarkup(True)

    memorySystemRtosTasksFile = memoryComponent.createFileSymbol("DRV_MEMORY_SYS_RTOS_TASK", None)
    memorySystemRtosTasksFile.setType("STRING")
    memorySystemRtosTasksFile.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
    memorySystemRtosTasksFile.setSourcePath("driver/memory/templates/system/rtos_tasks.c.ftl")
    memorySystemRtosTasksFile.setMarkup(True)
    memorySystemRtosTasksFile.setEnabled(enable_rtos_settings)
    memorySystemRtosTasksFile.setDependencies(genRtosTask, ["HarmonyCore.SELECT_RTOS", "drv_memory.DRV_MEMORY_COMMON_MODE"])

def onAttachmentConnected(source, target):
    global memoryDeviceUsed
    global memoryDeviceComment
    global memoryDeviceInterruptEnable
    global memoryDeviceEraseEnable
    global memoryPlibSourceFile
    global memoryPlibHeaderFile
    global memoryPlibSystemDefFile
    global memoryPlibUsed
    global memoryFsEnable

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    # For Capability Connected (drv_media)
    if (connectID == "drv_media"):
        if (remoteID == "sys_fs"):
            memoryFsEnable.setValue(True)
            memoryFsConnectionCounterDict = {}
            memoryFsConnectionCounterDict = Database.sendMessage("drv_memory", "DRV_MEMORY_FS_CONNECTION_COUNTER_INC", memoryFsConnectionCounterDict)

    # For Dependency Connected (memory)
    if (connectID == "drv_memory_MEMORY_dependency"):
        memoryDeviceUsed.setValue(remoteID.upper())

        memoryPlibUsed.clearValue()

        memoryDeviceComment.setLabel("*** Configure Memory Device in "+ memoryDeviceUsed.getValue() + " Configurations ***")
        memoryDeviceComment.setVisible(True)

        memoryDeviceInterruptEnable.setValue(remoteComponent.getSymbolValue("INTERRUPT_ENABLE"))

        memoryDeviceEraseEnable.setValue(remoteComponent.getSymbolValue("ERASE_ENABLE"))

        remoteComponent.setSymbolValue("DRV_MEMORY_CONNECTED", True)

        # If a PLIB is directly connected create plib wrappers
        if ("drv_" not in remoteID):
            memoryPlibUsed.setValue("DRV_" + remoteID.upper())
            memoryPlibSourceFile.setOutputName("drv_memory_" + remoteID +".c")
            memoryPlibHeaderFile.setOutputName("drv_memory_" + remoteID +".h")
            memoryPlibSourceFile.setEnabled(True)
            memoryPlibHeaderFile.setEnabled(True)
            memoryPlibSystemDefFile.setEnabled(True)

def onAttachmentDisconnected(source, target):
    global memoryDeviceUsed
    global memoryDeviceComment
    global memoryDeviceInterruptEnable
    global memoryDeviceEraseEnable
    global memoryPlibSourceFile
    global memoryPlibHeaderFile
    global memoryPlibSystemDefFile
    global memoryPlibUsed
    global memoryFsEnable

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    # For Capability Disconnected (drv_media)
    if (connectID == "drv_media"):
        if (remoteID == "sys_fs"):
            memoryFsEnable.setValue(False, 1)
            memoryFsConnectionCounterDict = {}
            memoryFsConnectionCounterDict = Database.sendMessage("drv_memory", "DRV_MEMORY_FS_CONNECTION_COUNTER_DEC", memoryFsConnectionCounterDict)

    # For Dependency Disconnected (memory)
    if (connectID == "drv_memory_MEMORY_dependency"):
        memoryDeviceUsed.clearValue()

        memoryPlibUsed.clearValue()

        memoryDeviceComment.setVisible(False)

        memoryDeviceInterruptEnable.clearValue()

        memoryDeviceEraseEnable.clearValue()

        remoteComponent.setSymbolValue("DRV_MEMORY_CONNECTED", False)

        # If PLIB was connected
        if ("drv_" not in remoteID):
            memoryPlibSourceFile.setEnabled(False)
            memoryPlibHeaderFile.setEnabled(False)
            memoryPlibSystemDefFile.setEnabled(False)
