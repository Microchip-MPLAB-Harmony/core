###############################################################################
########################## FreeRTOS Configurations ############################ 
###############################################################################
ComboVal_Scheduler_Type = ["Preemptive", "Co_Operative"]
ComboVal_Task_Selection = ["Port_Optimized", "Generic_Task_Selection"]
ComboVal_Tick_Mode        = ["Tickless_Idle", "Tick_Interrupt"]
ComboVal_Mem_Mgmt_Type    = ["Heap_1", "Heap_2", "Heap_3", "Heap_4", "Heap_5"]
ComboVal_Stack_Overflow    = ["No_Check", "Method_1", "Method_2"]

def freeRtosExpIdleTimeVisibility(symbol, event):
    id = symbol.getID()[-1]

    freeRtosIdleTimeVis = symbol.getComponent().getSymbolByID(event["id"])

    if(freeRtosIdleTimeVis.getValue() == "Tickless_Idle"):
        symbol.setVisible(True)
    else :
        symbol.setVisible(False)

def freeRtosTotalHeapSizeVisibility(symbol, event):
    id = symbol.getID()[-1]

    freeRtosTotalHeapSize = symbol.getComponent().getSymbolByID(event["id"])

    if(freeRtosTotalHeapSize.getValue() == "Heap_3"):
        symbol.setVisible(False)
    else :
        symbol.setVisible(True)

def freeRtosTotalIdleTaskYieldVisibility(symbol, event):
    id = symbol.getID()[-1]

    freeRtosIdleTaskYield = symbol.getComponent().getSymbolByID(event["id"])

    if(freeRtosIdleTaskYield.getValue() == True):
        symbol.setVisible(True)
    else :
        symbol.setVisible(False)
         
def freeRtosStatsFormatFuncVisibility(symbol, event):
    id = symbol.getID()[-1]

    freeRtosStatsFormatFunc = symbol.getComponent().getSymbolByID(event["id"])

    if(freeRtosStatsFormatFunc.getValue() == True):
        symbol.setVisible(True)
    else :
        symbol.setVisible(False)

def freeRtosTimerTaskVisibility(symbol, event):
    id = symbol.getID()[-1]

    freeRtosTimerTask = symbol.getComponent().getSymbolByID(event["id"])

    if(freeRtosTimerTask.getValue() == True):
        symbol.setVisible(True)
        symbol.setValue(3, 1)
    else:
        symbol.setVisible(False)
        symbol.setValue(0, 1)

def freeRtosTimerQueueVisibility(symbol, event):
    id = symbol.getID()[-1]

    freeRtosTimerQueue = symbol.getComponent().getSymbolByID(event["id"])

    if(freeRtosTimerQueue.getValue() == True):
        symbol.setVisible(True)
        symbol.setValue(10, 1)
    else:
        symbol.setVisible(False)
        symbol.setValue(0, 1)

def freeRtosTimerTaskStackVisibility(symbol, event):
    id = symbol.getID()[-1]

    freeRtosTimerTaskStack = symbol.getComponent().getSymbolByID(event["id"])

    if(freeRtosTimerTaskStack.getValue() == True):
        symbol.setVisible(True)
        symbol.setValue(256, 1)
    else:
        symbol.setVisible(False)
        symbol.setValue(0, 1)

def freeRtosTimerDaemonVisibility(symbol, event):
    id = symbol.getID()[-1]

    freeRtosTimerDaemon = symbol.getComponent().getSymbolByID(event["id"])

    if(freeRtosTimerDaemon.getValue() == True):
        symbol.setVisible(True)
        symbol.setValue(True, 1)
    else:
        symbol.setVisible(False)
        symbol.setValue(False, 1)

def buildStreamBuffer (symbol, event):
    id = symbol.getID()[-1]

    freeRtosStreamBuf = symbol.getComponent().getSymbolByID(event["id"])

    if(freeRtosStreamBuf.getValue() == True):
        symbol.setEnabled(True)
    else:
        symbol.setEnabled(False)

def freeRtosMemMangEnableHeap1(freeRtosMemMangHeap1, event):
    if(event["value"] == "Heap_1"):
        freeRtosMemMangHeap1.setEnabled(True)
    else :
        freeRtosMemMangHeap1.setEnabled(False)

def freeRtosMemMangEnableHeap2(freeRtosMemMangHeap2, event):
    if(event["value"] == "Heap_2"):
        freeRtosMemMangHeap2.setEnabled(True)
    else :
        freeRtosMemMangHeap2.setEnabled(False)

def freeRtosMemMangEnableHeap3(freeRtosMemMangHeap3, event):
    if(event["value"] == "Heap_3"):
        freeRtosMemMangHeap3.setEnabled(True)
    else :
        freeRtosMemMangHeap3.setEnabled(False)

def freeRtosMemMangEnableHeap4(freeRtosMemMangHeap4, event):
    if(event["value"] == "Heap_4"):
        freeRtosMemMangHeap4.setEnabled(True)
    else :
        freeRtosMemMangHeap4.setEnabled(False)

def freeRtosMemMangEnableHeap5(freeRtosMemMangHeap5, event):
    if(event["value"] == "Heap_5"):
        freeRtosMemMangHeap5.setEnabled(True)
    else :
        freeRtosMemMangHeap5.setEnabled(False)

def destroyComponent(thirdPartyFreeRTOS):
    # Restore OSAL to Bare-metal
    Database.clearSymbolValue("Harmony", "SELECT_RTOS")
    Database.setSymbolValue("Harmony", "SELECT_RTOS", 0, 1)

# Instatntiate FreeRTOS Component
def    instantiateComponent(thirdPartyFreeRTOS):
    Log.writeInfoMessage("Running FreeRTOS")

    # Set Generate Harmony Application Files to True
    Database.clearSymbolValue("Harmony", "ENABLE_APP_FILE")
    Database.setSymbolValue("Harmony", "ENABLE_APP_FILE", True, 3)

    NVICSysTickHandlerId = Interrupt.getInterruptIndex("SysTick")
    NVICSysTicVector = "NVIC_" + str(NVICSysTickHandlerId) + "_ENABLE"
    NVICSysTicHandler = "NVIC_" + str(NVICSysTickHandlerId) + "_HANDLER"
    NVICSysTicHandlerLock = "NVIC_" + str(NVICSysTickHandlerId) + "_HANDLER_LOCK"
    NVICSysTickPriorityLock = "NVIC_" + str(NVICSysTickHandlerId) + "_PRIORITY_LOCK"

    Database.clearSymbolValue("core", NVICSysTicVector)
    Database.setSymbolValue("core", NVICSysTicVector, False, 2)
    Database.clearSymbolValue("core", NVICSysTicHandler)
    Database.setSymbolValue("core", NVICSysTicHandler, "xPortSysTickHandler", 2)
    Database.clearSymbolValue("core", NVICSysTicHandlerLock)
    Database.setSymbolValue("core", NVICSysTicHandlerLock, True, 2)
    Database.clearSymbolValue("core", NVICSysTickPriorityLock)
    Database.setSymbolValue("core", NVICSysTickPriorityLock, True, 2)

    NVICPendSVHandlerId = Interrupt.getInterruptIndex("PendSV")
    NVICPendSVVector = "NVIC_" + str(NVICPendSVHandlerId) + "_ENABLE"
    NVICPendSVHandler = "NVIC_" + str(NVICPendSVHandlerId) + "_HANDLER"
    NVICPendSVHandlerLock = "NVIC_" + str(NVICPendSVHandlerId) + "_HANDLER_LOCK"

    Database.clearSymbolValue("core", NVICPendSVVector)
    Database.setSymbolValue("core", NVICPendSVVector, False, 2)
    Database.clearSymbolValue("core", NVICPendSVHandler)
    Database.setSymbolValue("core", NVICPendSVHandler, "PendSV_Handler", 2)
    Database.clearSymbolValue("core", NVICPendSVHandlerLock)
    Database.setSymbolValue("core", NVICPendSVHandlerLock, True, 2)

    NVICSVCallHandlerId = Interrupt.getInterruptIndex("SVCall")
    NVICSVCallVector = "NVIC_" + str(NVICSVCallHandlerId) + "_ENABLE"
    NVICSVCallHandler = "NVIC_" + str(NVICSVCallHandlerId) + "_HANDLER"
    NVICSVCallHandlerLock = "NVIC_" + str(NVICSVCallHandlerId) + "_HANDLER_LOCK"
    NVICSVCallPriorityLock = "NVIC_" + str(NVICSVCallHandlerId) + "_PRIORITY_LOCK"

    Database.clearSymbolValue("core", NVICSVCallVector)
    Database.setSymbolValue("core", NVICSVCallVector, False, 2)
    Database.clearSymbolValue("core", NVICSVCallHandler)
    Database.setSymbolValue("core", NVICSVCallHandler, "SVCall_Handler", 2)
    Database.clearSymbolValue("core", NVICSVCallHandlerLock)
    Database.setSymbolValue("core", NVICSVCallHandlerLock, True, 2)
    Database.clearSymbolValue("core", NVICSVCallPriorityLock)
    Database.setSymbolValue("core", NVICSVCallPriorityLock, True, 2)

    freeRtosSymMenu = thirdPartyFreeRTOS.createMenuSymbol("FREERTOS_MENU", None)
    freeRtosSymMenu.setLabel("RTOS Configuration")
    freeRtosSymMenu.setDescription("Select either the preemptive RTOS scheduler, or the cooperative RTOS scheduler")

    # NVIC Dynamic settings
    freeRtosInterrupts = thirdPartyFreeRTOS.createBooleanSymbol("sysTickEnableInterrupt", freeRtosSymMenu)
    freeRtosInterrupts.setLabel("Enable xPortSysTickHandler Interrupt")
    freeRtosInterrupts.setVisible(False)

    freeRtosSym_SchedulerType = thirdPartyFreeRTOS.createComboSymbol("FREERTOS_SCHEDULER", freeRtosSymMenu, ComboVal_Scheduler_Type)
    freeRtosSym_SchedulerType.setLabel("Scheduler Type")
    freeRtosSym_SchedulerType.setDescription("Select either the preemptive RTOS scheduler, or the cooperative RTOS scheduler")
    freeRtosSym_SchedulerType.setDefaultValue("Preemptive")

    freeRtosSym_TaskSelection = thirdPartyFreeRTOS.createComboSymbol("FREERTOS_TASK_SELECTION", freeRtosSymMenu, ComboVal_Task_Selection)
    freeRtosSym_TaskSelection.setLabel("Task Selection")
    freeRtosSym_TaskSelection.setDescription("Select either the Port specific or the Generic method of selecting the next task to execute.")
    freeRtosSym_TaskSelection.setDefaultValue("Port_Optimized")

    freeRtosSym_TickMode = thirdPartyFreeRTOS.createComboSymbol("FREERTOS_TICKLESS_IDLE_CHOICE", freeRtosSymMenu, ComboVal_Tick_Mode)
    freeRtosSym_TickMode.setLabel("Tick Mode")
    freeRtosSym_TickMode.setDescription("Selects either the low power tickless mode, or keeps the tick interrupt running at all times.")
    freeRtosSym_TickMode.setDefaultValue("Tick_Interrupt")

    freeRtosSym_ExpectedIdleTime = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_EXPECTED_IDLE_TIME_BEFORE_SLEEP", freeRtosSymMenu)
    freeRtosSym_ExpectedIdleTime.setLabel("Expected idle time before sleep")
    freeRtosSym_ExpectedIdleTime.setMin(2)
    freeRtosSym_ExpectedIdleTime.setMax(99999999)
    freeRtosSym_ExpectedIdleTime.setDefaultValue(2)
    freeRtosSym_ExpectedIdleTime.setVisible(False)
    freeRtosSym_ExpectedIdleTime.setDependencies(freeRtosExpIdleTimeVisibility, ["FREERTOS_TICKLESS_IDLE_CHOICE"])

    cpuclk = Database.getSymbolValue("core", "PROCESSORCLK_FREQ")
    cpuclk = int(cpuclk)

    freeRtosSym_CpuClockHz = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_CPU_CLOCK_HZ", freeRtosSymMenu)
    freeRtosSym_CpuClockHz.setLabel("CPU Clock Speed (Hz)")
    freeRtosSym_CpuClockHz.setVisible(False)
    freeRtosSym_CpuClockHz.setDefaultValue(cpuclk)

    freeRtosSym_TickRate = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_TICK_RATE_HZ", freeRtosSymMenu)
    freeRtosSym_TickRate.setLabel("Tick Rate (Hz)")
    freeRtosSym_TickRate.setDescription("FreeRTOS - Tick rate (Hz)")
    freeRtosSym_TickRate.setMin(250)
    freeRtosSym_TickRate.setMax(1000)
    freeRtosSym_TickRate.setDefaultValue(1000)

    freeRtosSym_MaxPrio = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_MAX_PRIORITIES", freeRtosSymMenu)
    freeRtosSym_MaxPrio.setLabel("Maximum number of priorities")
    freeRtosSym_MaxPrio.setDescription("FreeRTOS - Maximum number of priorities")
    freeRtosSym_MaxPrio.setMin(1)
    freeRtosSym_MaxPrio.setMax(999999999)
    freeRtosSym_MaxPrio.setDefaultValue(5)

    freeRtosSym_StackSize = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_MINIMAL_STACK_SIZE", freeRtosSymMenu)
    freeRtosSym_StackSize.setLabel("Minimal Stack Size")
    freeRtosSym_StackSize.setDescription("FreeRTOS - Maximum number of priorities")
    freeRtosSym_StackSize.setDefaultValue(128)

    freeRtosSym_DynMemAloc = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_DYNAMIC_ALLOC", freeRtosSymMenu)
    freeRtosSym_DynMemAloc.setLabel("Enable Dynamic Memory Allocation")
    freeRtosSym_DynMemAloc.setDescription("FreeRTOS - Dynamic memory allocation")
    freeRtosSym_DynMemAloc.setDefaultValue(True)

    freeRtosSym_StaMemAloc = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_STATIC_ALLOC", freeRtosSymMenu)
    freeRtosSym_StaMemAloc.setLabel("Enable Static memory allocation")
    freeRtosSym_StaMemAloc.setDescription("FreeRTOS - Static memory allocation")
    freeRtosSym_StaMemAloc.setDefaultValue(False)

    freeRtosSym_MemMgmtType = thirdPartyFreeRTOS.createComboSymbol("FREERTOS_MEMORY_MANAGEMENT_CHOICE", freeRtosSymMenu, ComboVal_Mem_Mgmt_Type)
    freeRtosSym_MemMgmtType.setLabel("Memory Management Type")
    freeRtosSym_MemMgmtType.setDescription("FreeRTOS - Memory management type")
    freeRtosSym_MemMgmtType.setDefaultValue("Heap_1")

    freeRtosSym_TotalHeapSize = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_TOTAL_HEAP_SIZE", freeRtosSymMenu)
    freeRtosSym_TotalHeapSize.setLabel("Total heap size")
    freeRtosSym_TotalHeapSize.setDescription("FreeRTOS - Total heap size")
    freeRtosSym_TotalHeapSize.setDefaultValue(40960)
    freeRtosSym_TotalHeapSize.setDependencies(freeRtosTotalHeapSizeVisibility, ["FREERTOS_MEMORY_MANAGEMENT_CHOICE"])

    freeRtosSym_MaxTaskNameLen = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_MAX_TASK_NAME_LEN", freeRtosSymMenu)
    freeRtosSym_MaxTaskNameLen.setLabel("Maximum task name length")
    freeRtosSym_MaxTaskNameLen.setDescription("FreeRTOS - Maximum task name length")
    freeRtosSym_MaxTaskNameLen.setMin(1)
    freeRtosSym_MaxTaskNameLen.setMax(1024)
    freeRtosSym_MaxTaskNameLen.setDefaultValue(16)

    freeRtosSym_16BitTicks = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_16_BIT_TICKS", freeRtosSymMenu)
    freeRtosSym_16BitTicks.setLabel("Use 16-bit ticks")
    freeRtosSym_16BitTicks.setDescription("FreeRTOS - Use 16-bit ticks")
    freeRtosSym_16BitTicks.setDefaultValue(False)

    freeRtosSym_IdleTaskYield = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_IDLE_SHOULD_YIELD", freeRtosSymMenu)
    freeRtosSym_IdleTaskYield.setLabel("Idle task should yield")
    freeRtosSym_IdleTaskYield.setDescription("FreeRTOS - Idle task should yield")
    freeRtosSym_IdleTaskYield.setDefaultValue(True)
    freeRtosSym_IdleTaskYield.setDependencies(freeRtosTotalIdleTaskYieldVisibility, ["FREERTOS_PREEMPTIVE_SCHEDULER"])

    freeRtosSym_Mutex = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_MUTEXES", freeRtosSymMenu)
    freeRtosSym_Mutex.setLabel("Use Mutexes")
    freeRtosSym_Mutex.setDescription("FreeRTOS - Use Mutexes")
    freeRtosSym_Mutex.setDefaultValue(True)

    freeRtosSym_RecursiveMutex = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_RECURSIVE_MUTEXES", freeRtosSymMenu)
    freeRtosSym_RecursiveMutex.setLabel("Use Recursive Mutexes")
    freeRtosSym_RecursiveMutex.setDescription("FreeRTOS - Use Recursive Mutexes")
    freeRtosSym_RecursiveMutex.setDefaultValue(False)

    freeRtosSym_CountingSem = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_COUNTING_SEMAPHORES", freeRtosSymMenu)
    freeRtosSym_CountingSem.setLabel("Use Counting Semaphores")
    freeRtosSym_CountingSem.setDescription("FreeRTOS - Use Counting Semaphores")
    freeRtosSym_CountingSem.setDefaultValue(True)

    freeRtosSym_TaskNotification = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_TASK_NOTIFICATIONS", freeRtosSymMenu)
    freeRtosSym_TaskNotification.setLabel("Use Task Notifications")
    freeRtosSym_TaskNotification.setDescription("FreeRTOS - Use Task Notifications")
    freeRtosSym_TaskNotification.setDefaultValue(True)

    freeRtosSym_QueueRegSize = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_QUEUE_REGISTRY_SIZE", freeRtosSymMenu)
    freeRtosSym_QueueRegSize.setLabel("Queue Registry Size")
    freeRtosSym_QueueRegSize.setDescription("FreeRTOS - Queue Registry Size")
    freeRtosSym_QueueRegSize.setDefaultValue(0)

    freeRtosSym_QueueSets = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_QUEUE_SETS", freeRtosSymMenu)
    freeRtosSym_QueueSets.setLabel("Use Queue Sets")
    freeRtosSym_QueueSets.setDescription("FreeRTOS - Use Queue Sets")
    freeRtosSym_QueueSets.setDefaultValue(False)

    freeRtosSym_TimeSlicing = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_TIME_SLICING", freeRtosSymMenu)
    freeRtosSym_TimeSlicing.setLabel("Use Time Slicing")
    freeRtosSym_TimeSlicing.setDescription("FreeRTOS - Use Time Slicing")
    freeRtosSym_TimeSlicing.setDefaultValue(False)

    freeRtosSym_NewlibReEntrant = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_NEWLIB_REENTRANT", freeRtosSymMenu)
    freeRtosSym_NewlibReEntrant.setLabel("Use newlib reentrant structure")
    freeRtosSym_NewlibReEntrant.setDescription("FreeRTOS - Use newlib reentrant structure")
    freeRtosSym_NewlibReEntrant.setDefaultValue(False)

    freeRtosSym_TaskFpuSupport = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_TASK_FPU_SUPPORT", freeRtosSymMenu)
    freeRtosSym_TaskFpuSupport.setLabel("Enable hardware FPU support for tasks")
    freeRtosSym_TaskFpuSupport.setDescription("FreeRTOS - Enable hardware FPU support for tasks")
    freeRtosSym_TaskFpuSupport.setDefaultValue(False)

    freeRtosSym_IdleHook = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_IDLE_HOOK", freeRtosSymMenu)
    freeRtosSym_IdleHook.setLabel("Use Idle Hook")
    freeRtosSym_IdleHook.setDescription("FreeRTOS - Use Idle Hook")
    freeRtosSym_IdleHook.setDefaultValue(False)

    freeRtosSym_TickHook = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_TICK_HOOK", freeRtosSymMenu)
    freeRtosSym_TickHook.setLabel("Use Tick Hook")
    freeRtosSym_TickHook.setDescription("FreeRTOS - Use Tick Hook")
    freeRtosSym_TickHook.setDefaultValue(False)

    freeRtosSym_StackOverFlow = thirdPartyFreeRTOS.createComboSymbol("FREERTOS_CHECK_FOR_STACK_OVERFLOW", freeRtosSymMenu, ComboVal_Stack_Overflow)
    freeRtosSym_StackOverFlow.setLabel("Stack Overflow Checking")
    freeRtosSym_StackOverFlow.setDescription("FreeRTOS - Stack overflow checking")
    freeRtosSym_StackOverFlow.setDefaultValue("Method_2")

    freeRtosSym_FailedMallocHook = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_MALLOC_FAILED_HOOK", freeRtosSymMenu)
    freeRtosSym_FailedMallocHook.setLabel("Use malloc failed hook")
    freeRtosSym_FailedMallocHook.setDescription("FreeRTOS - Use malloc failed hook")
    freeRtosSym_FailedMallocHook.setDefaultValue(True)

    freeRtosSym_GenRunTimeStat = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_GENERATE_RUN_TIME_STATS", freeRtosSymMenu)
    freeRtosSym_GenRunTimeStat.setLabel("Generate runtime statistics")
    freeRtosSym_GenRunTimeStat.setDescription("FreeRTOS - Generate runtime statistics")
    freeRtosSym_GenRunTimeStat.setDefaultValue(False)

    freeRtosSym_TraceFacility = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_TRACE_FACILITY", freeRtosSymMenu)
    freeRtosSym_TraceFacility.setLabel("Use trace facility")
    freeRtosSym_TraceFacility.setDescription("FreeRTOS - Use trace facility")
    freeRtosSym_TraceFacility.setDefaultValue(False)

    freeRtosSym_StatsFormatFunc = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_STATS_FORMATTING_FUNCTIONS", freeRtosSym_TraceFacility)
    freeRtosSym_StatsFormatFunc.setLabel("Use stats formatting functions")
    freeRtosSym_StatsFormatFunc.setDescription("FreeRTOS - Use stats formatting functions")
    freeRtosSym_StatsFormatFunc.setDefaultValue(False)
    freeRtosSym_StatsFormatFunc.setVisible(False)
    freeRtosSym_StatsFormatFunc.setDependencies(freeRtosStatsFormatFuncVisibility, ["FREERTOS_USE_TRACE_FACILITY"])

    freeRtosSym_CoRoutines = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_CO_ROUTINES", freeRtosSymMenu)
    freeRtosSym_CoRoutines.setLabel("Use Co-Routines")
    freeRtosSym_CoRoutines.setDescription("FreeRTOS - Use Co-Routines")
    freeRtosSym_CoRoutines.setDefaultValue(False)

    freeRtosSym_MaxCoRoutinePrio = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_MAX_CO_ROUTINE_PRIORITIES", freeRtosSymMenu)
    freeRtosSym_MaxCoRoutinePrio.setLabel("Maximum task name length")
    freeRtosSym_MaxCoRoutinePrio.setDescription("FreeRTOS - Maximum task name length")
    freeRtosSym_MaxCoRoutinePrio.setMin(1)
    freeRtosSym_MaxCoRoutinePrio.setMax(999999999)
    freeRtosSym_MaxCoRoutinePrio.setDefaultValue(2)

    freeRtosSym_Timers = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_TIMERS", freeRtosSymMenu)
    freeRtosSym_Timers.setLabel("Use Timers")
    freeRtosSym_Timers.setDescription("FreeRTOS - Use Timers")
    freeRtosSym_Timers.setDefaultValue(False)

    freeRtosSym_TimerTaskPrio = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_TIMER_TASK_PRIORITY", freeRtosSym_Timers)
    freeRtosSym_TimerTaskPrio.setLabel("Timer task priority")
    freeRtosSym_TimerTaskPrio.setDescription("FreeRTOS - Timer task priority")
    #freeRtosSym_TimerTaskPrio.setMin(1)
    #freeRtosSym_TimerTaskPrio.setMax(999999999)
    freeRtosSym_TimerTaskPrio.setDefaultValue(0)
    freeRtosSym_TimerTaskPrio.setVisible(False)
    freeRtosSym_TimerTaskPrio.setDependencies(freeRtosTimerTaskVisibility, ["FREERTOS_USE_TIMERS"])

    freeRtosSym_TimerQueueLen = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_TIMER_QUEUE_LENGTH", freeRtosSym_Timers)
    freeRtosSym_TimerQueueLen.setLabel("Timer queue length")
    freeRtosSym_TimerQueueLen.setDescription("FreeRTOS - Timer queue length")
    #freeRtosSym_TimerQueueLen.setMin(1)
    #freeRtosSym_TimerQueueLen.setMax(999999999)
    freeRtosSym_TimerQueueLen.setDefaultValue(0)
    freeRtosSym_TimerQueueLen.setVisible(False)
    freeRtosSym_TimerQueueLen.setDependencies(freeRtosTimerQueueVisibility, ["FREERTOS_USE_TIMERS"])

    freeRtosSym_TimerTaskStackDepth = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_TIMER_TASK_STACK_DEPTH", freeRtosSym_Timers)
    freeRtosSym_TimerTaskStackDepth.setLabel("Timer task stack depth")
    freeRtosSym_TimerTaskStackDepth.setDescription("FreeRTOS - Timer task stack depth")
    #freeRtosSym_TimerTaskStackDepth.setMin(1)
    #freeRtosSym_TimerTaskStackDepth.setMax(999999999)
    freeRtosSym_TimerTaskStackDepth.setDefaultValue(0)
    freeRtosSym_TimerTaskStackDepth.setVisible(False)
    freeRtosSym_TimerTaskStackDepth.setDependencies(freeRtosTimerTaskStackVisibility, ["FREERTOS_USE_TIMERS"])

    freeRtosSym_TimerDaemonTask = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_DAEMON_TASK_STARTUP_HOOK", freeRtosSym_Timers)
    freeRtosSym_TimerDaemonTask.setLabel("Use Application Daemon Task Startup Hook")
    freeRtosSym_TimerDaemonTask.setDescription("FreeRTOS - Use Application Daemon Task Startup Hook")
    freeRtosSym_TimerDaemonTask.setDefaultValue(False)
    freeRtosSym_TimerDaemonTask.setVisible(False)
    freeRtosSym_TimerDaemonTask.setDependencies(freeRtosTimerDaemonVisibility, ["FREERTOS_USE_TIMERS"])

    freeRtosSym_AppTaskTag = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_APPLICATION_TASK_TAG", freeRtosSymMenu)
    freeRtosSym_AppTaskTag.setLabel("Use application task tags")
    freeRtosSym_AppTaskTag.setDescription("FreeRTOS - Use application task tags")
    freeRtosSym_AppTaskTag.setDefaultValue(False)

    freeRtosSym_ConfAssertMacro = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_CONFIGASSERT", freeRtosSymMenu)
    freeRtosSym_ConfAssertMacro.setLabel("Use the configAssert macro")
    freeRtosSym_ConfAssertMacro.setDescription("FreeRTOS - Use the configAssert macro")
    freeRtosSym_ConfAssertMacro.setDefaultValue(False)

    freeRtosSym_KernelIntrPrio = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_KERNEL_INTERRUPT_PRIORITY", freeRtosSymMenu)
    freeRtosSym_KernelIntrPrio.setLabel("Kernel interrupt priority")
    freeRtosSym_KernelIntrPrio.setDescription("FreeRTOS - Kernel interrupt priority")
    #freeRtosSym_KernelIntrPrio.setMin(1)
    #freeRtosSym_KernelIntrPrio.setMax(999999999)
    freeRtosSym_KernelIntrPrio.setDefaultValue(7)
    freeRtosSym_KernelIntrPrio.setReadOnly(True)

    freeRtosSym_MaxSysCalIntrPrio = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_MAX_SYSCALL_INTERRUPT_PRIORITY", freeRtosSymMenu)
    freeRtosSym_MaxSysCalIntrPrio.setLabel("Maximum system call interrupt priority")
    freeRtosSym_MaxSysCalIntrPrio.setDescription("FreeRTOS - Kernel interrupt priority")
    freeRtosSym_MaxSysCalIntrPrio.setMin(1)
    freeRtosSym_MaxSysCalIntrPrio.setMax(7)
    freeRtosSym_MaxSysCalIntrPrio.setDefaultValue(0)

    freeRtosSymMenu_IncludeComponents = thirdPartyFreeRTOS.createMenuSymbol("FREERTOS_INCLUDE_COMPONENTS", freeRtosSymMenu)
    freeRtosSymMenu_IncludeComponents.setLabel("Include components")
    freeRtosSymMenu_IncludeComponents.setDescription("Explicitly include or exclude FreeRTOS components from the build.")

    freeRtosSym_vTaskPrioritySet = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_VTASKPRIORITYSET", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_vTaskPrioritySet.setLabel("Include vTaskPrioritySet")
    freeRtosSym_vTaskPrioritySet.setDescription("FreeRTOS - Include vTaskPrioritySet")
    freeRtosSym_vTaskPrioritySet.setDefaultValue(True)

    freeRtosSym_uxTaskPriorityGet = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_UXTASKPRIORITYGET", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_uxTaskPriorityGet.setLabel("Include uxTaskPriorityGet")
    freeRtosSym_uxTaskPriorityGet.setDescription("FreeRTOS - Include uxTaskPriorityGet")
    freeRtosSym_uxTaskPriorityGet.setDefaultValue(True)

    freeRtosSym_vTaskDelete = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_VTASKDELETE", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_vTaskDelete.setLabel("Include vTaskDelete")
    freeRtosSym_vTaskDelete.setDescription("FreeRTOS - Include vTaskDelete")
    freeRtosSym_vTaskDelete.setDefaultValue(True)

    freeRtosSym_vTaskSuspend = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_VTASKSUSPEND", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_vTaskSuspend.setLabel("Include vTaskSuspend")
    freeRtosSym_vTaskSuspend.setDescription("FreeRTOS - Include vTaskSuspend")
    freeRtosSym_vTaskSuspend.setDefaultValue(True)

    freeRtosSym_vTaskDelayUntil = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_VTASKDELAYUNTIL", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_vTaskDelayUntil.setLabel("Include vTaskDelayUntil")
    freeRtosSym_vTaskDelayUntil.setDescription("FreeRTOS - Include vTaskDelayUntil")
    freeRtosSym_vTaskDelayUntil.setDefaultValue(True)

    freeRtosSym_vTaskDelay = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_VTASKDELAY", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_vTaskDelay.setLabel("Include vTaskDelay")
    freeRtosSym_vTaskDelay.setDescription("FreeRTOS - Include vTaskDelay")
    freeRtosSym_vTaskDelay.setDefaultValue(True)
    
    freeRtosSym_uxTaskGetStackHighWaterMark = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_UXTASKGETSTACKHIGHWATERMARK", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_uxTaskGetStackHighWaterMark.setLabel("Include uxTaskGetStackHighWaterMark")
    freeRtosSym_uxTaskGetStackHighWaterMark.setDescription("FreeRTOS - Include uxTaskGetStackHighWaterMark")
    freeRtosSym_uxTaskGetStackHighWaterMark.setDefaultValue(False)

    freeRtosSym_xTaskGetSchedulerState = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_XTASKGETSCHEDULERSTATE", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_xTaskGetSchedulerState.setLabel("Include xTaskGetSchedulerState")
    freeRtosSym_xTaskGetSchedulerState.setDescription("FreeRTOS - Include xTaskGetSchedulerState")
    freeRtosSym_xTaskGetSchedulerState.setDefaultValue(False)

    freeRtosSym_xTaskGetCurrentTaskHandle = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_XTASKGETCURRENTTASKHANDLE", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_xTaskGetCurrentTaskHandle.setLabel("Include xTaskGetCurrentTaskHandle")
    freeRtosSym_xTaskGetCurrentTaskHandle.setDescription("FreeRTOS - Include xTaskGetCurrentTaskHandle")
    freeRtosSym_xTaskGetCurrentTaskHandle.setDefaultValue(False)

    freeRtosSym_xTaskGetIdleTaskHandle = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_XTASKGETIDLETASKHANDLE", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_xTaskGetIdleTaskHandle.setLabel("Include xTaskGetIdleTaskHandle")
    freeRtosSym_xTaskGetIdleTaskHandle.setDescription("FreeRTOS - Include xTaskGetIdleTaskHandle")
    freeRtosSym_xTaskGetIdleTaskHandle.setDefaultValue(False)

    freeRtosSym_eTaskGetState = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_ETASKGETSTATE", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_eTaskGetState.setLabel("Include eTaskGetState")
    freeRtosSym_eTaskGetState.setDescription("FreeRTOS - Include eTaskGetState")
    freeRtosSym_eTaskGetState.setDefaultValue(False)

    freeRtosSym_xTimerPendFunctionCall = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_XTIMERPENDFUNCTIONCALL", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_xTimerPendFunctionCall.setLabel("Include xTimerPendFunctionCall")
    freeRtosSym_xTimerPendFunctionCall.setDescription("FreeRTOS - Include xTimerPendFunctionCall")
    freeRtosSym_xTimerPendFunctionCall.setDefaultValue(False)

    freeRtosSym_xTaskAbortDelay = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_XTASKABORTDELAY", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_xTaskAbortDelay.setLabel("Include xTaskAbortDelay")
    freeRtosSym_xTaskAbortDelay.setDescription("FreeRTOS - Include xTaskAbortDelay")
    freeRtosSym_xTaskAbortDelay.setDefaultValue(False)

    freeRtosSym_xTaskGetHandle = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_XTASKGETHANDLE", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_xTaskGetHandle.setLabel("Include xTaskGetHandle")
    freeRtosSym_xTaskGetHandle.setDescription("FreeRTOS - Include xTaskGetHandle")
    freeRtosSym_xTaskGetHandle.setDefaultValue(False)

############################################################################
#### Code Generation ####
############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    freeRtosdefSym = thirdPartyFreeRTOS.createSettingSymbol("FREERTOS_XC32_INCLUDE_DIRS", None)
    freeRtosdefSym.setCategory("C32")
    freeRtosdefSym.setKey("extra-include-directories")
    freeRtosdefSym.setValue("../src/third_party/rtos/FreeRTOS/Source/portable/GCC/SAM/CM7;../src/third_party/rtos/FreeRTOS/Source/Include;")
    freeRtosdefSym.setAppend(True, ";")

    freeRtosConfHeaderFile = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_CONFIG_H", None)
    freeRtosConfHeaderFile.setSourcePath("templates/FreeRTOSConfig.h.ftl")
    freeRtosConfHeaderFile.setOutputName("FreeRTOSConfig.h")
    freeRtosConfHeaderFile.setProjectPath("config/" + configName + "")
    freeRtosConfHeaderFile.setType("HEADER")
    freeRtosConfHeaderFile.setMarkup(True)

    freeRtosHooksSourceFile = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_HOOKS_C", None)
    freeRtosHooksSourceFile.setSourcePath("templates/freertos_hooks.c")
    freeRtosHooksSourceFile.setOutputName("freertos_hooks.c")
    freeRtosHooksSourceFile.setProjectPath("config/" + configName + "")
    freeRtosHooksSourceFile.setType("SOURCE")
    freeRtosHooksSourceFile.setMarkup(False)

    freeRtosCoRoutine = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_CROUTINE_C", None)
    freeRtosCoRoutine.setSourcePath("../CMSIS-FreeRTOS/Source/croutine.c")
    freeRtosCoRoutine.setOutputName("croutine.c")
    freeRtosCoRoutine.setDestPath("../../third_party/rtos/FreeRTOS/Source")
    freeRtosCoRoutine.setProjectPath("FreeRTOS/Source")
    freeRtosCoRoutine.setType("SOURCE")
    freeRtosCoRoutine.setMarkup(False)

    freeRtosList = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_LIST_C", None)
    freeRtosList.setSourcePath("../CMSIS-FreeRTOS/Source/list.c")
    freeRtosList.setOutputName("list.c")
    freeRtosList.setDestPath("../../third_party/rtos/FreeRTOS/Source")
    freeRtosList.setProjectPath("FreeRTOS/Source")
    freeRtosList.setType("SOURCE")
    freeRtosList.setMarkup(False)

    freeRtosQueue = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_QUEUE_C", None)
    freeRtosQueue.setSourcePath("../CMSIS-FreeRTOS/Source/queue.c")
    freeRtosQueue.setOutputName("queue.c")
    freeRtosQueue.setDestPath("../../third_party/rtos/FreeRTOS/Source")
    freeRtosQueue.setProjectPath("FreeRTOS/Source")
    freeRtosQueue.setType("SOURCE")
    freeRtosQueue.setMarkup(False)    

    freeRtosTask = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_TASKS_C", None)
    freeRtosTask.setSourcePath("../CMSIS-FreeRTOS/Source/tasks.c")
    freeRtosTask.setOutputName("tasks.c")
    freeRtosTask.setDestPath("../../third_party/rtos/FreeRTOS/Source")
    freeRtosTask.setProjectPath("FreeRTOS/Source")
    freeRtosTask.setType("SOURCE")
    freeRtosTask.setMarkup(False)

    freeRtosTimers = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_TIMERS_C", None)
    freeRtosTimers.setSourcePath("../CMSIS-FreeRTOS/Source/timers.c")
    freeRtosTimers.setOutputName("timers.c")
    freeRtosTimers.setDestPath("../../third_party/rtos/FreeRTOS/Source")
    freeRtosTimers.setProjectPath("FreeRTOS/Source")
    freeRtosTimers.setType("SOURCE")
    freeRtosTimers.setMarkup(False)    

    freeRtosEventGroups = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_EVENT_GROUPS_C", None)
    freeRtosEventGroups.setSourcePath("../CMSIS-FreeRTOS/Source/event_groups.c")
    freeRtosEventGroups.setOutputName("event_groups.c")
    freeRtosEventGroups.setDestPath("../../third_party/rtos/FreeRTOS/Source")
    freeRtosEventGroups.setProjectPath("FreeRTOS/Source")
    freeRtosEventGroups.setType("SOURCE")
    freeRtosEventGroups.setMarkup(False)

    freeRtosStreamBuffer = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_STREAM_BUFFER_C", None)
    freeRtosStreamBuffer.setSourcePath("../CMSIS-FreeRTOS/Source/stream_buffer.c")
    freeRtosStreamBuffer.setOutputName("stream_buffer.c")
    freeRtosStreamBuffer.setDestPath("../../third_party/rtos/FreeRTOS/Source")
    freeRtosStreamBuffer.setProjectPath("FreeRTOS/Source")
    freeRtosStreamBuffer.setType("SOURCE")
    freeRtosStreamBuffer.setMarkup(False)
    freeRtosStreamBuffer.setDependencies(buildStreamBuffer, ["FREERTOS_USE_TASK_NOTIFICATIONS"])

    freeRtosPortSource = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_SAM_PORT_C", None)
    freeRtosPortSource.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM7/r0p1/port.c")
    freeRtosPortSource.setOutputName("port.c")
    freeRtosPortSource.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/SAM/CM7")
    freeRtosPortSource.setProjectPath("FreeRTOS/Source/portable/GCC/SAM/CM7")
    freeRtosPortSource.setType("SOURCE")
    freeRtosPortSource.setMarkup(False)

    freeRtosPortHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_SAM_PORTMACRO_H", None)
    freeRtosPortHeader.setSourcePath("../CMSIS-FreeRTOS/Source/portable/GCC/ARM_CM7/r0p1/portmacro.h")
    freeRtosPortHeader.setOutputName("portmacro.h")
    freeRtosPortHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/GCC/SAM/CM7")
    freeRtosPortHeader.setProjectPath("FreeRTOS/Source/portable/GCC/SAM/CM7")
    freeRtosPortHeader.setType("HEADER")
    freeRtosPortHeader.setMarkup(False)

    freeRtosMemMangHeap1 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_HEAP_1_C", None)
    freeRtosMemMangHeap1.setSourcePath("../CMSIS-FreeRTOS/Source/portable/MemMang/heap_1.c")
    freeRtosMemMangHeap1.setOutputName("heap_1.c")
    freeRtosMemMangHeap1.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MemMang/")
    freeRtosMemMangHeap1.setProjectPath("FreeRTOS/Source/portable/MemMang/")
    freeRtosMemMangHeap1.setType("SOURCE")
    freeRtosMemMangHeap1.setEnabled(True)
    freeRtosMemMangHeap1.setDependencies(freeRtosMemMangEnableHeap1, ["FREERTOS_MEMORY_MANAGEMENT_CHOICE"])

    freeRtosMemMangHeap2 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_HEAP_2_C", None)
    freeRtosMemMangHeap2.setSourcePath("../CMSIS-FreeRTOS/Source/portable/MemMang/heap_2.c")
    freeRtosMemMangHeap2.setOutputName("heap_2.c")
    freeRtosMemMangHeap2.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MemMang/")
    freeRtosMemMangHeap2.setProjectPath("FreeRTOS/Source/portable/MemMang/")
    freeRtosMemMangHeap2.setType("SOURCE")
    freeRtosMemMangHeap2.setEnabled(False)
    freeRtosMemMangHeap2.setDependencies(freeRtosMemMangEnableHeap2, ["FREERTOS_MEMORY_MANAGEMENT_CHOICE"])

    freeRtosMemMangHeap3 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_HEAP_3_C", None)
    freeRtosMemMangHeap3.setSourcePath("../CMSIS-FreeRTOS/Source/portable/MemMang/heap_3.c")
    freeRtosMemMangHeap3.setOutputName("heap_3.c")
    freeRtosMemMangHeap3.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MemMang/")
    freeRtosMemMangHeap3.setProjectPath("FreeRTOS/Source/portable/MemMang/")
    freeRtosMemMangHeap3.setType("SOURCE")
    freeRtosMemMangHeap3.setEnabled(False)
    freeRtosMemMangHeap3.setDependencies(freeRtosMemMangEnableHeap3, ["FREERTOS_MEMORY_MANAGEMENT_CHOICE"])

    freeRtosMemMangHeap4 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_HEAP_4_C", None)
    freeRtosMemMangHeap4.setSourcePath("../CMSIS-FreeRTOS/Source/portable/MemMang/heap_4.c")
    freeRtosMemMangHeap4.setOutputName("heap_4.c")
    freeRtosMemMangHeap4.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MemMang/")
    freeRtosMemMangHeap4.setProjectPath("FreeRTOS/Source/portable/MemMang/")
    freeRtosMemMangHeap4.setType("SOURCE")
    freeRtosMemMangHeap4.setEnabled(False)
    freeRtosMemMangHeap4.setDependencies(freeRtosMemMangEnableHeap4, ["FREERTOS_MEMORY_MANAGEMENT_CHOICE"])

    freeRtosMemMangHeap5 = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_HEAP_5_C", None)
    freeRtosMemMangHeap5.setSourcePath("../CMSIS-FreeRTOS/Source/portable/MemMang/heap_5.c")
    freeRtosMemMangHeap5.setOutputName("heap_5.c")
    freeRtosMemMangHeap5.setDestPath("../../third_party/rtos/FreeRTOS/Source/portable/MemMang/")
    freeRtosMemMangHeap5.setProjectPath("FreeRTOS/Source/portable/MemMang/")
    freeRtosMemMangHeap5.setType("SOURCE")
    freeRtosMemMangHeap5.setEnabled(False)
    freeRtosMemMangHeap5.setDependencies(freeRtosMemMangEnableHeap5, ["FREERTOS_MEMORY_MANAGEMENT_CHOICE"])

    freeRtosCoRoutineHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_CROUTINE_H", None)
    freeRtosCoRoutineHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/croutine.h")
    freeRtosCoRoutineHeader.setOutputName("croutine.h")
    freeRtosCoRoutineHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosCoRoutineHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosCoRoutineHeader.setType("HEADER")

    freeRtosEventGrpHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_EVENT_GROUPS_H", None)
    freeRtosEventGrpHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/event_groups.h")
    freeRtosEventGrpHeader.setOutputName("event_groups.h")
    freeRtosEventGrpHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosEventGrpHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosEventGrpHeader.setType("HEADER")

    freeRtosFreeRtosHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_FREERTOS_H", None)
    freeRtosFreeRtosHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/FreeRTOS.h")
    freeRtosFreeRtosHeader.setOutputName("FreeRTOS.h")
    freeRtosFreeRtosHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosFreeRtosHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosFreeRtosHeader.setType("HEADER")

    freeRtosListHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_LIST_H", None)
    freeRtosListHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/list.h")
    freeRtosListHeader.setOutputName("list.h")
    freeRtosListHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosListHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosListHeader.setType("HEADER")

    freeRtosMpuWrappersHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MPU_WRAPPERS_H", None)
    freeRtosMpuWrappersHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/mpu_wrappers.h")
    freeRtosMpuWrappersHeader.setOutputName("mpu_wrappers.h")
    freeRtosMpuWrappersHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosMpuWrappersHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosMpuWrappersHeader.setType("HEADER")

    freeRtosPortableHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_PORTABLE_H", None)
    freeRtosPortableHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/portable.h")
    freeRtosPortableHeader.setOutputName("portable.h")
    freeRtosPortableHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosPortableHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosPortableHeader.setType("HEADER")

    freeRtosProjDefHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_PROJDEFS_H", None)
    freeRtosProjDefHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/projdefs.h")
    freeRtosProjDefHeader.setOutputName("projdefs.h")
    freeRtosProjDefHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosProjDefHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosProjDefHeader.setType("HEADER")

    freeRtosQueueHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_QUEUE_H", None)
    freeRtosQueueHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/queue.h")
    freeRtosQueueHeader.setOutputName("queue.h")
    freeRtosQueueHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosQueueHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosQueueHeader.setType("HEADER")

    freeRtosPortMacro = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_SEMPHR_H", None)
    freeRtosPortMacro.setSourcePath("../CMSIS-FreeRTOS/Source/Include/semphr.h")
    freeRtosPortMacro.setOutputName("semphr.h")
    freeRtosPortMacro.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosPortMacro.setProjectPath("FreeRTOS/Source/Include")
    freeRtosPortMacro.setType("HEADER")

    freeRtosStackMacroHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_STACK_MACROS_H", None)
    freeRtosStackMacroHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/stack_macros.h")
    freeRtosStackMacroHeader.setOutputName("stack_macros.h")
    freeRtosStackMacroHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosStackMacroHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosStackMacroHeader.setType("HEADER")

    freeRtosDepDefHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_DEPRECATED_DEFINITIONS_H", None)
    freeRtosDepDefHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/deprecated_definitions.h")
    freeRtosDepDefHeader.setOutputName("deprecated_definitions.h")
    freeRtosDepDefHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosDepDefHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosDepDefHeader.setType("HEADER")

    freeRtosTaskHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_TASK_H", None)
    freeRtosTaskHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/task.h")
    freeRtosTaskHeader.setOutputName("task.h")
    freeRtosTaskHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosTaskHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosTaskHeader.setType("HEADER")

    freeRtosTimerHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_TIMERS_H", None)
    freeRtosTimerHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/timers.h")
    freeRtosTimerHeader.setOutputName("timers.h")
    freeRtosTimerHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosTimerHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosTimerHeader.setType("HEADER")

    freeRtosMpuProtoHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MPU_PROTOTYPES_H", None)
    freeRtosMpuProtoHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/mpu_prototypes.h")
    freeRtosMpuProtoHeader.setOutputName("mpu_prototypes.h")
    freeRtosMpuProtoHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosMpuProtoHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosMpuProtoHeader.setType("HEADER")

    freeRtosStreamBufHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_STREAM_BUFFER_H", None)
    freeRtosStreamBufHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/stream_buffer.h")
    freeRtosStreamBufHeader.setOutputName("stream_buffer.h")
    freeRtosStreamBufHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosStreamBufHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosStreamBufHeader.setType("HEADER")
    freeRtosStreamBufHeader.setDependencies(buildStreamBuffer, ["FREERTOS_USE_TASK_NOTIFICATIONS"])

    freeRtosMesgBufHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MESSAGE_BUFFER_H", None)
    freeRtosMesgBufHeader.setSourcePath("../CMSIS-FreeRTOS/Source/Include/message_buffer.h")
    freeRtosMesgBufHeader.setOutputName("message_buffer.h")
    freeRtosMesgBufHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/Include")
    freeRtosMesgBufHeader.setProjectPath("FreeRTOS/Source/Include")
    freeRtosMesgBufHeader.setType("HEADER")
    freeRtosMesgBufHeader.setDependencies(buildStreamBuffer, ["FREERTOS_USE_TASK_NOTIFICATIONS"])

    freeRtosSystemDefFile = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_SYS_DEF", None)
    freeRtosSystemDefFile.setType("STRING")
    freeRtosSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    freeRtosSystemDefFile.setSourcePath("templates/system/system_rtos_definitions.h.ftl")
    freeRtosSystemDefFile.setMarkup(True)

    freeRtosSystemTasksFile = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_SYS_TASK", None)
    freeRtosSystemTasksFile.setType("STRING")
    freeRtosSystemTasksFile.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_CALL_SCHEDULAR")
    freeRtosSystemTasksFile.setSourcePath("templates/system/system_rtos_tasks.c.ftl")
    freeRtosSystemTasksFile.setMarkup(True) 
