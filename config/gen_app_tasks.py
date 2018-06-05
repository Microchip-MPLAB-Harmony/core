################################################################################
#### Global Variables ####
################################################################################
# Maximum Application Tasks that can be created
global genAppRtosTaskMaxCount

global genAppTaskConfMenu
global genAppRtosTaskConfMenu

genAppRtosTaskMaxCount      = 10
genAppRtosTaskConfMenu      = []
genAppTaskConfMenu          = []
genAppTaskName              = []
genAppTaskNameCodingGuide   = []
genAppRtosTaskSize          = []
genAppRtosTaskPrio          = []
genAppRtosTaskUseDelay      = []
genAppRtosTaskDelay         = []


################################################################################
#### Business Logic ####
################################################################################
def genAppTaskMenuVisible(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def genAppRtosTaskDelayVisible(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def genAppTaskConfMenuVisible(symbol, event):
    global genAppTaskConfMenu
    global genAppRtosTaskMaxCount

    appCount = event["value"]

    for count in range(0, genAppRtosTaskMaxCount):
        genAppTaskConfMenu[count].setVisible(False)

    for count in range(0, appCount):
        genAppTaskConfMenu[count].setVisible(True)
        
def genAppRtosTaskConfMenuVisible(symbol, event):
    global genAppRtosTaskConfMenu
    global genAppRtosTaskMaxCount

    appCount    = Database.getSymbolValue("Harmony", "GEN_APP_TASK_COUNT")
    selectRTOS  = Database.getSymbolValue("Harmony", "SELECT_RTOS")

    if (selectRTOS == True):
        for count in range(0, genAppRtosTaskMaxCount):
            genAppRtosTaskConfMenu[count].setVisible(False)

        for count in range(0, appCount):
            genAppRtosTaskConfMenu[count].setVisible(True)
    else:
        for count in range(0, genAppRtosTaskMaxCount):
            genAppRtosTaskConfMenu[count].setVisible(False)

def genAppTask(symbol, event):
    if (event["value"] == 0):
        # If not Bare Metal
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def genRtosTask(symbol, event):
    if (event["value"] != 0):
        # If not Bare Metal
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def genRtosTaskDef(symbol, event):
    if (event["value"] != 0):
        # If not Bare Metal
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def genAppSysInit(symbol, event):
    if (event["value"] == True):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

############################################################################

enableRTOS = Database.getSymbolValue("Harmony", "SELECT_RTOS")

genAppTaskMenu = harmonyCoreComponent.createMenuSymbol("GEN_APP_TASK_MENU", coreAppFiles)
genAppTaskMenu.setLabel("Application Configuration")
genAppTaskMenu.setVisible(False)
genAppTaskMenu.setDependencies(genAppTaskMenuVisible, ["ENABLE_APP_FILE"])

genAppNumTask = harmonyCoreComponent.createIntegerSymbol("GEN_APP_TASK_COUNT", genAppTaskMenu)
genAppNumTask.setLabel("Number of Applications")
genAppNumTask.setDescription("Number of Applications")
genAppNumTask.setMin(1)
genAppNumTask.setMax(genAppRtosTaskMaxCount)
genAppNumTask.setDefaultValue(1)

for count in range(0, genAppRtosTaskMaxCount):
    global genAppTaskConfMenu
    global genAppRtosTaskConfMenu

    genAppTaskConfMenu.append(count)
    genAppTaskConfMenu[count] = harmonyCoreComponent.createMenuSymbol("GEN_APP_TASK_CONF_MENU" + str(count), genAppTaskMenu)
    genAppTaskConfMenu[count].setLabel("Application " + str(count) + " Configuration")
    genAppTaskConfMenu[count].setDescription("Application " + str(count) + " Configuration")
    genAppTaskConfMenu[count].setDependencies(genAppTaskConfMenuVisible, ["GEN_APP_TASK_COUNT"])
    if (count == 0):
        genAppTaskConfMenu[count].setVisible(True)
    else:
        genAppTaskConfMenu[count].setVisible(False)

    genAppTaskName.append(count)
    genAppTaskName[count] = harmonyCoreComponent.createStringSymbol("GEN_APP_TASK_NAME_" + str(count), genAppTaskConfMenu[count])
    genAppTaskName[count].setLabel("Application Name")
    genAppTaskName[count].setDescription("Application Name")
    genAppTaskName[count].setDefaultValue("app" + str(count))

    genAppTaskNameCodingGuide.append(count)
    genAppTaskNameCodingGuide[count] = harmonyCoreComponent.createCommentSymbol("GEN_APP_TASK_NAME_CODING_GUIDE_" + str(count), genAppTaskConfMenu[count])
    genAppTaskNameCodingGuide[count].setLabel("**** Application name must be valid C-Language identifier and should be short and lowercase. ****")

    genAppRtosTaskConfMenu.append(count)
    genAppRtosTaskConfMenu[count] = harmonyCoreComponent.createMenuSymbol("GEN_APP_RTOS_TASK_CONF_MENU" + str(count), genAppTaskMenu)
    genAppRtosTaskConfMenu[count].setLabel("RTOS Configuration")
    genAppRtosTaskConfMenu[count].setDescription("RTOS Configuration")
    genAppRtosTaskConfMenu[count].setDependencies(genAppRtosTaskConfMenuVisible, ["GEN_APP_TASK_COUNT", "Harmony.SELECT_RTOS"])
    if (count == 0 and enableRTOS == True):
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
genAppTasks.setDependencies(genAppTask, ["Harmony.SELECT_RTOS"])

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
genAppRtosTasksDef.setDependencies(genRtosTaskDef, ["Harmony.SELECT_RTOS"])

genappSystemInitFile = harmonyCoreComponent.createFileSymbol("APP_SYS_INIT", None)
genappSystemInitFile.setType("STRING")
genappSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_APP_INITIALIZE_DATA")
genappSystemInitFile.setSourcePath("/templates/system/system_initialize.c.ftl")
genappSystemInitFile.setMarkup(True)
genappSystemInitFile.setEnabled(True)
