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
#### Business Logic ####
################################################################################
global osalHeaderImpBasicFile
global osalHeaderFreeRtosFile
global osalSourceFreeRtosFile
global osalSelectRTOS

rtosIdTable = ["FreeRTOS", "ThreadX", "MicriumOSIII"]

def enableAppFile(symbol, event):
    component = symbol.getComponent()

    drv_common = component.getSymbolValue("ENABLE_DRV_COMMON")
    sys_common = component.getSymbolValue("ENABLE_SYS_COMMON")

    if ((drv_common == True) or (sys_common == True)):
        symbol.setValue(True)
    else:
        symbol.setValue(False)

def genSysDebugHeader(symbol, event):
    symbol.setEnabled(event["value"])

def genHarmonyFiles(symbol, event):
    component = symbol.getComponent()

    drv_common = component.getSymbolValue("ENABLE_DRV_COMMON")
    sys_common = component.getSymbolValue("ENABLE_SYS_COMMON")
    appfile = component.getSymbolValue("ENABLE_APP_FILE")

    if ((drv_common == True) or (sys_common == True) or (appfile == True)):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def checkActiveRtos():
    activeComponents = Database.getActiveComponentIDs()

    for i in range(0, len(activeComponents)):
        for j in range(0, len(rtosIdTable)):
            if (activeComponents[i] == rtosIdTable[j]):
                return True
    return False

################################################################################
#### Component ####
################################################################################
def instantiateComponent(harmonyCoreComponent):
    global osalHeaderImpBasicFile
    global osalHeaderFreeRtosFile
    global osalSourceFreeRtosFile
    global osalSelectRTOS

    if (checkActiveRtos() == False):
        autoComponentIDTable = ["FreeRTOS"]
        res = Database.activateComponents(autoComponentIDTable)

    harmonyAppFile = harmonyCoreComponent.createBooleanSymbol("ENABLE_APP_FILE", None)
    harmonyAppFile.setLabel("Generate Harmony Application Files")
    harmonyAppFile.setDefaultValue(False)
    harmonyAppFile.setDependencies(enableAppFile, ["ENABLE_DRV_COMMON", "ENABLE_SYS_COMMON"])


    configName = Variables.get("__CONFIGURATION_NAME")

    # Harmony Core Driver Common files
    execfile(Module.getPath() + "/driver/config/driver.py")

    # Harmony Core System Service Common files
    execfile(Module.getPath() + "/system/config/system.py")

    # Harmony Core System Service Interrupt files
    execfile(Module.getPath() + "/system/int/config/sys_int.py")

    # Harmony Core System Service Ports files
    execfile(Module.getPath() + "/system/ports/config/sys_ports.py")

    # Harmony Core System Service Cache files
    execfile(Module.getPath() + "/system/cache/config/sys_cache.py")

    # Harmony Core System Service DMA files
    execfile(Module.getPath() + "/system/dma/config/sys_dma.py")

    # Harmony Core System Service Reset files
    execfile(Module.getPath() + "/system/reset/config/sys_reset.py")

    # Harmony Core Operating System Abstraction Layer (OSAL) files
    execfile(Module.getPath() + "/osal/config/osal.py")

    # Harmony Core Create and Configure Application Tasks/Threads
    execfile(Module.getPath() + "/config/gen_app_tasks.py")

    #################### Configuration Files ####################
    # generate user.h file
    userHeaderFile = harmonyCoreComponent.createFileSymbol("USER_H", None)
    userHeaderFile.setSourcePath("templates/user.h.ftl")
    userHeaderFile.setOutputName("user.h")
    userHeaderFile.setMarkup(True)
    userHeaderFile.setOverwrite(False)
    userHeaderFile.setDestPath("")
    userHeaderFile.setProjectPath("config/" + configName + "/")
    userHeaderFile.setType("HEADER")
    userHeaderFile.setEnabled(False)
    userHeaderFile.setDependencies(genHarmonyFiles, ["ENABLE_DRV_COMMON", "ENABLE_SYS_COMMON", "ENABLE_APP_FILE"])
    appConfigIncludesList = harmonyCoreComponent.createListSymbol("LIST_APP_CONFIG_H_GLOBAL_INCLUDES", None)

    # generate configuration.h file
    confHeaderFile = harmonyCoreComponent.createFileSymbol("CONFIGURATION_H", None)
    confHeaderFile.setSourcePath("templates/configuration.h.ftl")
    confHeaderFile.setOutputName("configuration.h")
    confHeaderFile.setMarkup(True)
    confHeaderFile.setOverwrite(True)
    confHeaderFile.setDestPath("")
    confHeaderFile.setProjectPath("config/" + configName + "/")
    confHeaderFile.setType("HEADER")
    confHeaderFile.setEnabled(False)
    confHeaderFile.setDependencies(genHarmonyFiles, ["ENABLE_DRV_COMMON", "ENABLE_SYS_COMMON", "ENABLE_APP_FILE"])

    # generate tasks.c file
    taskSourceFile = harmonyCoreComponent.createFileSymbol("TASKS_C", None)
    taskSourceFile.setSourcePath("templates/tasks.c.ftl")
    taskSourceFile.setOutputName("tasks.c")
    taskSourceFile.setMarkup(True)
    taskSourceFile.setOverwrite(True)
    taskSourceFile.setDestPath("")
    taskSourceFile.setProjectPath("config/" + configName + "/")
    taskSourceFile.setType("SOURCE")
    taskSourceFile.setEnabled(False)
    taskSourceFile.setDependencies(genHarmonyFiles, ["ENABLE_DRV_COMMON", "ENABLE_SYS_COMMON", "ENABLE_APP_FILE"])

    # generate sys_debug.h file
    debugHeaderFile = harmonyCoreComponent.createFileSymbol("SYS_DEBUG_HEADER", None)
    debugHeaderFile.setSourcePath("system/debug/templates/sys_debug.h.ftl")
    debugHeaderFile.setOutputName("sys_debug.h")
    debugHeaderFile.setDestPath("system/debug/")
    debugHeaderFile.setProjectPath("config/" + configName + "/system/debug/")
    debugHeaderFile.setType("HEADER")
    debugHeaderFile.setEnabled(False)
    debugHeaderFile.setOverwrite(True)
    debugHeaderFile.setMarkup(True)
    debugHeaderFile.setDependencies(genSysDebugHeader, ["ENABLE_SYS_COMMON"])

    debugSystemDefFile = harmonyCoreComponent.createFileSymbol("SYS_DEBUG_DEF_HEADER", None)
    debugSystemDefFile.setType("STRING")
    debugSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    debugSystemDefFile.setSourcePath("system/debug/templates/system/system_definitions.h.ftl")
    debugSystemDefFile.setMarkup(True)
    debugSystemDefFile.setEnabled(False)
    debugSystemDefFile.setDependencies(genSysDebugHeader, ["ENABLE_SYS_COMMON"])

def onAttachmentConnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    print("satisfied: " + connectID + ", " + targetID)

    if targetID == "FreeRTOS":
        localComponent.clearSymbolValue("SELECT_RTOS")
        localComponent.setSymbolValue("SELECT_RTOS", "FreeRTOS")
    elif targetID == "MicriumOSIII":
        localComponent.clearSymbolValue("SELECT_RTOS")
        localComponent.setSymbolValue("SELECT_RTOS", "MicriumOSIII")
    elif targetID == "ThreadX":
        localComponent.clearSymbolValue("SELECT_RTOS")
        localComponent.setSymbolValue("SELECT_RTOS", "ThreadX")

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    print("unsatisfied: " + connectID + ", " + targetID)

    if targetID == "FreeRTOS" or targetID == "MicriumOSIII" or targetID == "ThreadX":
        localComponent.clearSymbolValue("SELECT_RTOS")
        localComponent.setSymbolValue("SELECT_RTOS", "BareMetal")
