################################################################################
#### Global Variables ####
################################################################################
# Maximum Application Tasks that can be created
global genAppTaskMaxCount

global genAppTaskConfMenu
global genAppRtosTaskConfMenu
global appHeaderFile
global appSourceFile

genAppTaskMaxCount          = 10
genAppRtosTaskConfMenu      = []
genAppTaskConfMenu          = []
genAppTaskName              = []
genAppTaskNameCodingGuide   = []
genAppRtosTaskSize          = []
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

def genAppRtosTaskDelayVisible(symbol, event):
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

    appCount    = Database.getSymbolValue("Harmony", "GEN_APP_TASK_COUNT")
    selectRTOS  = Database.getSymbolValue("Harmony", "SELECT_RTOS")

    for count in range(0, genAppTaskMaxCount):
        genAppRtosTaskConfMenu[count].setVisible(False)

    if (selectRTOS != "BareMetal"):
        for count in range(0, appCount):
            genAppRtosTaskConfMenu[count].setVisible(True)



def genRtosTask(symbol, event):
    selectRTOS = Database.getSymbolValue("Harmony", "SELECT_RTOS")

    if (selectRTOS != "BareMetal"):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)


def genAppSourceFile(symbol, event):
    global appSourceFile
    appName = None

    appFileEnableCount = Database.getSymbolValue("Harmony", "GEN_APP_TASK_COUNT")
    appGenFiles        = Database.getSymbolValue("Harmony", "ENABLE_APP_FILE")

    for count in range(0, genAppTaskMaxCount):
        appSourceFile[count].setEnabled(False)

    if (appGenFiles == True):
        for count in range(0, appFileEnableCount):
            appName = Database.getSymbolValue("Harmony", "GEN_APP_TASK_NAME_" + str(count))
            appSourceFile[count].setEnabled(True)
            appSourceFile[count].setOutputName(appName.lower() + ".c")

def genAppHeaderFile(symbol, event):
    global appHeaderFile
    appName = None

    appFileEnableCount = Database.getSymbolValue("Harmony", "GEN_APP_TASK_COUNT")
    appGenFiles        = Database.getSymbolValue("Harmony", "ENABLE_APP_FILE")

    for count in range(0, genAppTaskMaxCount):
        appHeaderFile[count].setEnabled(False)

    if (appGenFiles == True):
        for count in range(0, appFileEnableCount):
            appName = Database.getSymbolValue("Harmony", "GEN_APP_TASK_NAME_" + str(count))
            appHeaderFile[count].setEnabled(True)
            appHeaderFile[count].setOutputName(appName.lower() + ".h")

############################################################################

enableRTOS = Database.getSymbolValue("Harmony", "SELECT_RTOS")

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
    genAppRtosTaskSize[count].setDefaultValue(1024)

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
    genAppRtosTaskDelay[count].setDependencies(genAppRtosTaskDelayVisible, ["GEN_APP_RTOS_TASK_" + str(count) + "_USE_DELAY"])

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
genAppTasks.setDependencies(genRtosTask, ["Harmony.SELECT_RTOS"])

genAppRtosTasks = harmonyCoreComponent.createFileSymbol("GEN_RTOS_APP_TASKS", None)
genAppRtosTasks.setType("STRING")
genAppRtosTasks.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_GEN_APP")
genAppRtosTasks.setSourcePath("templates/gen_rtos_tasks_macros.ftl")
genAppRtosTasks.setMarkup(True)
genAppRtosTasks.setEnabled((Database.getSymbolValue("Harmony", "SELECT_RTOS") != 0))
genAppRtosTasks.setDependencies(genRtosTask, ["Harmony.SELECT_RTOS"])

genAppRtosTasksDef = harmonyCoreComponent.createFileSymbol("GEN_RTOS_APP_TASKS_DEF", None)
genAppRtosTasksDef.setType("STRING")
genAppRtosTasksDef.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
genAppRtosTasksDef.setSourcePath("/templates/gen_rtos_tasks.c.ftl")
genAppRtosTasksDef.setMarkup(True)
genAppRtosTasksDef.setEnabled((Database.getSymbolValue("Harmony", "SELECT_RTOS") != 0))
genAppRtosTasksDef.setDependencies(genRtosTask, ["Harmony.SELECT_RTOS"])

genappSystemInitFile = harmonyCoreComponent.createFileSymbol("APP_SYS_INIT", None)
genappSystemInitFile.setType("STRING")
genappSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_APP_INITIALIZE_DATA")
genappSystemInitFile.setSourcePath("/templates/system/system_initialize.c.ftl")
genappSystemInitFile.setMarkup(True)
genappSystemInitFile.setEnabled(True)
