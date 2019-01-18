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
#### Global Variables ####
################################################################################
# Maximum Application Tasks that can be created
global genAppTaskMaxCount

global genAppTaskConfMenu
global genAppRtosTaskConfMenu
global appHeaderFile
global appSourceFile

# Get the default selected OSAL
global osalSelectRTOS

genAppTaskMaxCount          = 10
genAppRtosTaskConfMenu      = []
genAppTaskConfMenu          = []
genAppTaskName              = []
genAppTaskNameCodingGuide   = []
genAppRtosTaskSize          = []
genAppRtosMsgQSize          = []
genAppRtosTaskTimeQuanta    = []
genAppRtosTaskSpecificOpt   = []
genAppRtosTaskStkChk        = []
genAppRtosTaskStkClr        = []
genAppRtosTaskSaveFp        = []
genAppRtosTaskNoTls         = []
genAppRtosTaskPrio          = []
genAppRtosTaskUseDelay      = []
genAppRtosTaskDelay         = []
appSourceFile               = []
appHeaderFile               = []

################################################################################
#### Business Logic ####
################################################################################
def genAppTaskMenuVisible(symbol, event):
    symbol.setVisible(event["value"])

def genAppRtosTaskOptionsVisible(symbol, event):
    symbol.setVisible(event["value"])

def genAppTaskConfMenuVisible(symbol, event):
    global genAppTaskConfMenu
    global genAppTaskMaxCount

    appCount = event["value"]

    for count in range(0, genAppTaskMaxCount):
        genAppTaskConfMenu[count].setVisible(False)

    for count in range(0, appCount):
        genAppTaskConfMenu[count].setVisible(True)

def genAppRtosTaskConfMenuVisible(symbol, event):
    global genAppRtosTaskConfMenu
    global genAppTaskMaxCount

    component = symbol.getComponent()

    appCount    = component.getSymbolValue("GEN_APP_TASK_COUNT")
    selectRTOS  = component.getSymbolValue("SELECT_RTOS")

    for count in range(0, genAppTaskMaxCount):
        genAppRtosTaskConfMenu[count].setVisible(False)

    if (selectRTOS != "BareMetal"):
        for count in range(0, appCount):
            genAppRtosTaskConfMenu[count].setVisible(True)

def genBareMetalAppTask(symbol, event):
    if (event["value"] == "BareMetal"):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def genRtosAppTask(symbol, event):
    if (event["value"] != "BareMetal"):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def genAppSourceFile(symbol, event):
    global appSourceFile
    appName = None

    component = symbol.getComponent()

    appFileEnableCount = component.getSymbolValue("GEN_APP_TASK_COUNT")
    appGenFiles        = component.getSymbolValue("ENABLE_APP_FILE")

    for count in range(0, genAppTaskMaxCount):
        appSourceFile[count].setEnabled(False)

    if (appGenFiles == True):
        for count in range(0, appFileEnableCount):
            appName = component.getSymbolValue("GEN_APP_TASK_NAME_" + str(count))
            appSourceFile[count].setEnabled(True)
            appSourceFile[count].setOutputName(appName.lower() + ".c")

def genAppHeaderFile(symbol, event):
    global appHeaderFile
    appName = None

    component = symbol.getComponent()

    appFileEnableCount = component.getSymbolValue("GEN_APP_TASK_COUNT")
    appGenFiles        = component.getSymbolValue("ENABLE_APP_FILE")

    for count in range(0, genAppTaskMaxCount):
        appHeaderFile[count].setEnabled(False)

    if (appGenFiles == True):
        for count in range(0, appFileEnableCount):
            appName = component.getSymbolValue("GEN_APP_TASK_NAME_" + str(count))
            appHeaderFile[count].setEnabled(True)
            appHeaderFile[count].setOutputName(appName.lower() + ".h")

def genRtosMicriumOSIIIAppTaskVisible(symbol, event):
    if (event["value"] == "MicriumOSIII"):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

############################################################################
enableRTOS  = osalSelectRTOS.getValue()
coreArch  = Database.getSymbolValue("core", "CoreArchitecture");

genAppTaskMenu = harmonyCoreComponent.createMenuSymbol("GEN_APP_TASK_MENU", harmonyAppFile)
genAppTaskMenu.setLabel("Application Configuration")
genAppTaskMenu.setVisible(False)
genAppTaskMenu.setDependencies(genAppTaskMenuVisible, ["ENABLE_APP_FILE"])

genAppNumTask = harmonyCoreComponent.createIntegerSymbol("GEN_APP_TASK_COUNT", genAppTaskMenu)
genAppNumTask.setLabel("Number of Applications")
genAppNumTask.setDescription("Number of Applications")
genAppNumTask.setMin(1)
genAppNumTask.setMax(genAppTaskMaxCount)
genAppNumTask.setDefaultValue(1)


for count in range(0, genAppTaskMaxCount):
    global genAppTaskConfMenu
    global genAppRtosTaskConfMenu

    genAppTaskConfMenu.append(count)
    genAppTaskConfMenu[count] = harmonyCoreComponent.createMenuSymbol("GEN_APP_TASK_CONF_MENU" + str(count), genAppTaskMenu)
    genAppTaskConfMenu[count].setLabel("Application " + str(count) + " Configuration")
    genAppTaskConfMenu[count].setDescription("Application " + str(count) + " Configuration")
    # Only 1 callback is sufficient
    genAppTaskConfMenu[0].setDependencies(genAppTaskConfMenuVisible, ["GEN_APP_TASK_COUNT"])
    if (count == 0):
        genAppTaskConfMenu[count].setVisible(True)
    else:
        genAppTaskConfMenu[count].setVisible(False)

    genAppTaskName.append(count)
    genAppTaskName[count] = harmonyCoreComponent.createStringSymbol("GEN_APP_TASK_NAME_" + str(count), genAppTaskConfMenu[count])
    genAppTaskName[count].setLabel("Application Name")
    genAppTaskName[count].setDescription("Application Name")
    if (count == 0):
        genAppTaskName[count].setDefaultValue("app")
    else:
        genAppTaskName[count].setDefaultValue("app" + str(count))

    genAppTaskNameCodingGuide.append(count)
    genAppTaskNameCodingGuide[count] = harmonyCoreComponent.createCommentSymbol("GEN_APP_TASK_NAME_CODING_GUIDE_" + str(count), genAppTaskConfMenu[count])
    genAppTaskNameCodingGuide[count].setLabel("**** Application name must be valid C-Language identifier and should be short and lowercase. ****")

    # generate app.c
    appSourceFile.append(count)
    appSourceFile[count] = harmonyCoreComponent.createFileSymbol("APP" + str(count) + "_C", None)
    appSourceFile[count].setSourcePath("templates/app.c.ftl")
    if (count == 0):
        appSourceFile[count].setOutputName("app.c")
    else:
        appSourceFile[count].setOutputName("app" + str(count) + ".c")

    appSourceFile[count].setMarkup(True)
    appSourceFile[count].setOverwrite(False)
    appSourceFile[count].setDestPath("../../")
    appSourceFile[count].setProjectPath("")
    appSourceFile[count].setType("SOURCE")
    appSourceFile[count].setEnabled(False)
    appSourceFile[count].setDependencies(genAppSourceFile, ["ENABLE_APP_FILE", "GEN_APP_TASK_COUNT", "GEN_APP_TASK_NAME_" + str(count)])
    appSourceFile[count].addMarkupVariable("APP_NAME", "GEN_APP_TASK_NAME_" + str(count))

    # generate app.h
    appHeaderFile.append(count)
    appHeaderFile[count] = harmonyCoreComponent.createFileSymbol("APP" + str(count) + "_H", None)
    appHeaderFile[count].setSourcePath("templates/app.h.ftl")
    if (count == 0):
        appHeaderFile[count].setOutputName("app.h")
    else:
        appHeaderFile[count].setOutputName("app" + str(count) + ".h")
    appHeaderFile[count].setMarkup(True)
    appHeaderFile[count].setOverwrite(False)
    appHeaderFile[count].setDestPath("../../")
    appHeaderFile[count].setProjectPath("")
    appHeaderFile[count].setType("HEADER")
    appHeaderFile[count].setEnabled(False)
    appHeaderFile[count].setDependencies(genAppHeaderFile, ["ENABLE_APP_FILE", "GEN_APP_TASK_COUNT", "GEN_APP_TASK_NAME_" + str(count)])
    appHeaderFile[count].addMarkupVariable("APP_NAME", "GEN_APP_TASK_NAME_" + str(count))

    # RTOS configurations
    genAppRtosTaskConfMenu.append(count)
    genAppRtosTaskConfMenu[count] = harmonyCoreComponent.createMenuSymbol("GEN_APP_RTOS_TASK_CONF_MENU" + str(count), genAppTaskConfMenu[count])
    genAppRtosTaskConfMenu[count].setLabel("RTOS Configuration")
    genAppRtosTaskConfMenu[count].setDescription("RTOS Configuration")
    # Only 1 callback is sufficient
    genAppRtosTaskConfMenu[0].setDependencies(genAppRtosTaskConfMenuVisible, ["GEN_APP_TASK_COUNT", "SELECT_RTOS"])
    if (count == 0 and enableRTOS != "BareMetal"):
        genAppRtosTaskConfMenu[count].setVisible(True)
    else:
        genAppRtosTaskConfMenu[count].setVisible(False)

    genAppRtosTaskSize.append(count)
    genAppRtosTaskSize[count] = harmonyCoreComponent.createIntegerSymbol("GEN_APP_RTOS_TASK_" + str(count) + "_SIZE", genAppRtosTaskConfMenu[count])
    genAppRtosTaskSize[count].setLabel("Stack Size")
    genAppRtosTaskSize[count].setDescription("Stack Size")
    if (coreArch == "CORTEX-M0PLUS" or coreArch == "CORTEX-M23"):
        genAppRtosTaskSize[count].setDefaultValue(128)
    else:
        genAppRtosTaskSize[count].setDefaultValue(1024)

    genAppRtosMsgQSize.append(count)
    genAppRtosMsgQSize[count] = harmonyCoreComponent.createIntegerSymbol("GEN_APP_RTOS_TASK_" + str(count) + "_MSG_QTY", genAppRtosTaskConfMenu[count])
    genAppRtosMsgQSize[count].setLabel("Maximum Message Queue Size")
    genAppRtosMsgQSize[count].setDescription("A µC/OS-III task contains an optional internal message queue (if OS_CFG_TASK_Q_EN is set to DEF_ENABLED in os_cfg.h). This argument specifies the maximum number of messages that the task can receive through this message queue. The user may specify that the task is unable to receive messages by setting this argument to 0")
    genAppRtosMsgQSize[count].setDefaultValue(0)
    genAppRtosMsgQSize[count].setVisible(False)
    genAppRtosMsgQSize[count].setDependencies(genRtosMicriumOSIIIAppTaskVisible, ["SELECT_RTOS"])

    genAppRtosTaskTimeQuanta.append(count)
    genAppRtosTaskTimeQuanta[count] = harmonyCoreComponent.createIntegerSymbol("GEN_APP_RTOS_TASK_" + str(count) + "_TIME_QUANTA", genAppRtosTaskConfMenu[count])
    genAppRtosTaskTimeQuanta[count].setLabel("Task Time Quanta")
    genAppRtosTaskTimeQuanta[count].setDescription("The amount of time (in clock ticks) for the time quanta when Round Robin is enabled. If you specify 0, then the default time quanta will be used which is the tick rate divided by 10.")
    genAppRtosTaskTimeQuanta[count].setDefaultValue(0)
    genAppRtosTaskTimeQuanta[count].setVisible(False)
    genAppRtosTaskTimeQuanta[count].setDependencies(genRtosMicriumOSIIIAppTaskVisible, ["SELECT_RTOS"])

    genAppRtosTaskPrio.append(count)
    genAppRtosTaskPrio[count] = harmonyCoreComponent.createIntegerSymbol("GEN_APP_RTOS_TASK_" + str(count) + "_PRIO", genAppRtosTaskConfMenu[count])
    genAppRtosTaskPrio[count].setLabel("Task Priority")
    genAppRtosTaskPrio[count].setDescription("Task Priority")
    genAppRtosTaskPrio[count].setDefaultValue(1)

    genAppRtosTaskUseDelay.append(count)
    genAppRtosTaskUseDelay[count] = harmonyCoreComponent.createBooleanSymbol("GEN_APP_RTOS_TASK_" + str(count) + "_USE_DELAY", genAppRtosTaskConfMenu[count])
    genAppRtosTaskUseDelay[count].setLabel("Use Task Delay")
    genAppRtosTaskUseDelay[count].setDescription("Use Task Delay")

    genAppRtosTaskDelay.append(count)
    genAppRtosTaskDelay[count] = harmonyCoreComponent.createIntegerSymbol("GEN_APP_RTOS_TASK_" + str(count) + "_DELAY", genAppRtosTaskUseDelay[count])
    genAppRtosTaskDelay[count].setLabel("Task Delay in ms")
    genAppRtosTaskDelay[count].setDescription("Task Delay in ms")
    genAppRtosTaskDelay[count].setDefaultValue(50)
    genAppRtosTaskDelay[count].setVisible(False)
    genAppRtosTaskDelay[count].setDependencies(genAppRtosTaskOptionsVisible, ["GEN_APP_RTOS_TASK_" + str(count) + "_USE_DELAY"])

    genAppRtosTaskSpecificOpt.append(count)
    genAppRtosTaskSpecificOpt[count] = harmonyCoreComponent.createBooleanSymbol("GEN_APP_RTOS_TASK_" + str(count) + "_OPT_NONE", genAppRtosTaskConfMenu[count])
    genAppRtosTaskSpecificOpt[count].setLabel("Task Specific Options")
    genAppRtosTaskSpecificOpt[count].setDescription("Contains task-specific options. Each option consists of one bit. The option is selected when the bit is set. The current version of µC/OS-III supports the following options:")
    genAppRtosTaskSpecificOpt[count].setDefaultValue(True)
    genAppRtosTaskSpecificOpt[count].setVisible(False)
    genAppRtosTaskSpecificOpt[count].setDependencies(genRtosMicriumOSIIIAppTaskVisible, ["SELECT_RTOS"])

    genAppRtosTaskStkChk.append(count)
    genAppRtosTaskStkChk[count] = harmonyCoreComponent.createBooleanSymbol("GEN_APP_RTOS_TASK_" + str(count) + "_OPT_STK_CHK", genAppRtosTaskSpecificOpt[count])
    genAppRtosTaskStkChk[count].setLabel("Stack checking is allowed for the task")
    genAppRtosTaskStkChk[count].setDescription("Specifies whether stack checking is allowed for the task")
    genAppRtosTaskStkChk[count].setDefaultValue(True)
    genAppRtosTaskStkChk[count].setDependencies(genAppRtosTaskOptionsVisible, ["GEN_APP_RTOS_TASK_" + str(count) + "_OPT_NONE"])

    genAppRtosTaskStkClr.append(count)
    genAppRtosTaskStkClr[count] = harmonyCoreComponent.createBooleanSymbol("GEN_APP_RTOS_TASK_" + str(count) + "_OPT_STK_CLR", genAppRtosTaskSpecificOpt[count])
    genAppRtosTaskStkClr[count].setLabel("Stack needs to be cleared")
    genAppRtosTaskStkClr[count].setDescription("Specifies whether the stack needs to be cleared")
    genAppRtosTaskStkClr[count].setDefaultValue(True)
    genAppRtosTaskStkClr[count].setDependencies(genAppRtosTaskOptionsVisible, ["GEN_APP_RTOS_TASK_" + str(count) + "_OPT_NONE"])

    genAppRtosTaskSaveFp.append(count)
    genAppRtosTaskSaveFp[count] = harmonyCoreComponent.createBooleanSymbol("GEN_APP_RTOS_TASK_" + str(count) + "_OPT_SAVE_FP", genAppRtosTaskSpecificOpt[count])
    genAppRtosTaskSaveFp[count].setLabel("Floating-point registers needs to be saved")
    genAppRtosTaskSaveFp[count].setDescription("Specifies whether floating-point registers are saved. This option is only valid if the processor has floating-point hardware and the processor-specific code saves the floating-point registers")
    genAppRtosTaskSaveFp[count].setDefaultValue(False)
    genAppRtosTaskSaveFp[count].setDependencies(genAppRtosTaskOptionsVisible, ["GEN_APP_RTOS_TASK_" + str(count) + "_OPT_NONE"])

    genAppRtosTaskNoTls.append(count)
    genAppRtosTaskNoTls[count] = harmonyCoreComponent.createBooleanSymbol("GEN_APP_RTOS_TASK_" + str(count) + "_OPT_NO_TLS", genAppRtosTaskSpecificOpt[count])
    genAppRtosTaskNoTls[count].setLabel("TLS (Thread Local Storage) support needed for the task")
    genAppRtosTaskNoTls[count].setDescription("If the caller doesn’t want or need TLS (Thread Local Storage) support for the task being created. If you do not include this option, TLS will be supported by default. TLS support was added in V3.03.00")
    genAppRtosTaskNoTls[count].setDefaultValue(False)
    genAppRtosTaskNoTls[count].setDependencies(genAppRtosTaskOptionsVisible, ["GEN_APP_RTOS_TASK_" + str(count) + "_OPT_NONE"])

############################################################################
#### Code Generation ####
############################################################################
genAppTasksHeader = harmonyCoreComponent.createFileSymbol("GEN_APP_DEF", None)
genAppTasksHeader.setType("STRING")
genAppTasksHeader.setOutputName("core.LIST_SYSTEM_APP_DEFINITIONS_H_INCLUDES")
genAppTasksHeader.setSourcePath("templates/gen_app_definitions_common.h.ftl")
genAppTasksHeader.setMarkup(True)

genAppTasks = harmonyCoreComponent.createFileSymbol("GEN_APP_TASKS", None)
genAppTasks.setType("STRING")
genAppTasks.setOutputName("core.LIST_SYSTEM_TASKS_C_GEN_APP")
genAppTasks.setSourcePath("templates/gen_app_tasks_macros.ftl")
genAppTasks.setMarkup(True)
genAppTasks.setEnabled(True)
genAppTasks.setDependencies(genBareMetalAppTask, ["SELECT_RTOS"])

genAppRtosTasks = harmonyCoreComponent.createFileSymbol("GEN_RTOS_APP_TASKS", None)
genAppRtosTasks.setType("STRING")
genAppRtosTasks.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_GEN_APP")
genAppRtosTasks.setSourcePath("templates/gen_rtos_tasks_macros.ftl")
genAppRtosTasks.setMarkup(True)
genAppRtosTasks.setEnabled(False)
genAppRtosTasks.setDependencies(genRtosAppTask, ["SELECT_RTOS"])

genAppRtosTasksDef = harmonyCoreComponent.createFileSymbol("GEN_RTOS_APP_TASKS_DEF", None)
genAppRtosTasksDef.setType("STRING")
genAppRtosTasksDef.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
genAppRtosTasksDef.setSourcePath("/templates/gen_rtos_tasks.c.ftl")
genAppRtosTasksDef.setMarkup(True)
genAppRtosTasksDef.setEnabled(False)
genAppRtosTasksDef.setDependencies(genRtosAppTask, ["SELECT_RTOS"])

genappSystemInitFile = harmonyCoreComponent.createFileSymbol("APP_SYS_INIT", None)
genappSystemInitFile.setType("STRING")
genappSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_APP_INITIALIZE_DATA")
genappSystemInitFile.setSourcePath("/templates/system/system_initialize.c.ftl")
genappSystemInitFile.setMarkup(True)
genappSystemInitFile.setEnabled(True)
