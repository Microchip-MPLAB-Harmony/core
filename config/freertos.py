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
# Fetch Core Architecture and Family details
coreArch     = Database.getSymbolValue("core", "CoreArchitecture")
coreFamily   = ATDF.getNode( "/avr-tools-device-file/devices/device" ).getAttribute( "family" )

#Fetch the current compiler
compilerList = ["XC32", "IAR", "KEIL"]
selectedCompiler = compilerList[Database.getSymbolValue("core", "COMPILER_CHOICE")]

###############################################################################
########################## FreeRTOS Configurations ############################
###############################################################################
if (coreArch == "CORTEX-M0PLUS" or coreArch == "CORTEX-M23" or coreArch == "CORTEX-M33"):
    ComboVal_Task_Selection = ["Generic"]
else:
    ComboVal_Task_Selection = ["Port_Optimized", "Generic"]

ComboVal_Scheduler_Type     = ["Preemptive", "Co_Operative"]
ComboVal_Tick_Mode          = ["Tickless_Idle", "Tick_Interrupt"]
ComboVal_Mem_Mgmt_Type      = ["Heap_1", "Heap_2", "Heap_3", "Heap_4", "Heap_5"]
ComboVal_Stack_Overflow     = ["No_Check", "Method_1", "Method_2"]


def activateCompilerSymbol(symbol, event):
    global compilerList
    currentCompiler = compilerList[event["value"]]
    symbolCompiler = symbol.getID().split("_")[1].replace("CPP", "")
    symbol.setEnabled(currentCompiler == symbolCompiler)

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
        symbol.setValue(3)
    else:
        symbol.setVisible(False)
        symbol.setValue(0)

def freeRtosTimerQueueVisibility(symbol, event):
    id = symbol.getID()[-1]

    freeRtosTimerQueue = symbol.getComponent().getSymbolByID(event["id"])

    if(freeRtosTimerQueue.getValue() == True):
        symbol.setVisible(True)
        symbol.setValue(10)
    else:
        symbol.setVisible(False)
        symbol.setValue(0)

def freeRtosTimerTaskStackVisibility(symbol, event):
    id = symbol.getID()[-1]

    freeRtosTimerTaskStack = symbol.getComponent().getSymbolByID(event["id"])

    if(freeRtosTimerTaskStack.getValue() == True):
        symbol.setVisible(True)
        symbol.setValue(256)
    else:
        symbol.setVisible(False)
        symbol.setValue(0)

def freeRtosTimerDaemonVisibility(symbol, event):
    id = symbol.getID()[-1]

    freeRtosTimerDaemon = symbol.getComponent().getSymbolByID(event["id"])

    if(freeRtosTimerDaemon.getValue() == True):
        symbol.setVisible(True)
        symbol.setValue(True)
    else:
        symbol.setVisible(False)
        symbol.setValue(False)

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

def freeRtosCpuClockHz(symbol, event):
    clock = int(event["value"])
    symbol.setValue(clock)

def deactivateActiveRtos():
    activeComponents = Database.getActiveComponentIDs()

    for i in range(0, len(activeComponents)):
        if (activeComponents[i] == "MicriumOSIII"):
            res = Database.deactivateComponents(["MicriumOSIII"])
        if (activeComponents[i] == "ThreadX"):
            res = Database.deactivateComponents(["ThreadX"])
        if (activeComponents[i] == "MbedOS"):
            res = Database.deactivateComponents(["MbedOS"])

def freeRtosIntConfig():
    if (coreArch == "MIPS"):
        Timer1InterruptEnable   = "TIMER_1_INTERRUPT_ENABLE"
        SWI0InterruptEnable     = "CORE_SOFTWARE_0_INTERRUPT_ENABLE"

        if (Database.getSymbolValue("core", Timer1InterruptEnable) == False):
            Database.sendMessage("core", Timer1InterruptEnable, {"isEnabled":True})

        #Enable TMR1 Peripheral Clock for FreeRTOS Tick Interrupt Generation
        if (Database.getSymbolValue("core", "TMR1_CLOCK_ENABLE") == False):
            Database.sendMessage("core", "TMR1_CLOCK_ENABLE", {"isEnabled":True})

        if (Database.getSymbolValue("core", SWI0InterruptEnable) == False):
            Database.sendMessage("core", SWI0InterruptEnable, {"isEnabled":True})

    else:
        SysTickInterruptEnable      = "SysTick_INTERRUPT_ENABLE"
        SysTickInterruptHandler     = "SysTick_INTERRUPT_HANDLER"
        SysTickInterruptHandlerLock = "SysTick_INTERRUPT_HANDLER_LOCK"

        if (Database.getSymbolValue("core", SysTickInterruptEnable) == False):
            Database.sendMessage("core", SysTickInterruptEnable, {"isEnabled":True})

        if (Database.getSymbolValue("core", SysTickInterruptHandler) != "xPortSysTickHandler"):
            Database.sendMessage("core", SysTickInterruptHandler, {"intHandler":"xPortSysTickHandler"})

        if (Database.getSymbolValue("core", SysTickInterruptHandlerLock) == False):
            Database.sendMessage("core", SysTickInterruptHandlerLock, {"isEnabled":True})

        PendSVInterruptEnable       = "PendSV_INTERRUPT_ENABLE"
        PendSVInterruptHandler      = "PendSV_INTERRUPT_HANDLER"
        PendSVInterruptHandlerLock  = "PendSV_INTERRUPT_HANDLER_LOCK"

        if (Database.getSymbolValue("core", PendSVInterruptEnable) == False):
            Database.sendMessage("core", PendSVInterruptEnable, {"isEnabled":True})

        if (Database.getSymbolValue("core", PendSVInterruptHandler) != "xPortPendSVHandler"):
            Database.sendMessage("core", PendSVInterruptHandler, {"intHandler":"xPortPendSVHandler"})

        if (Database.getSymbolValue("core", PendSVInterruptHandlerLock) == False):
            Database.sendMessage("core", PendSVInterruptHandlerLock, {"isEnabled":True})

        SVCallInterruptEnable       = "SVCall_INTERRUPT_ENABLE"
        SVCallInterruptHandler      = "SVCall_INTERRUPT_HANDLER"
        SVCallInterruptHandlerLock  = "SVCall_INTERRUPT_HANDLER_LOCK"

        if (Database.getSymbolValue("core", SVCallInterruptEnable) == False):
            Database.sendMessage("core", SVCallInterruptEnable, {"isEnabled":True})

        if (Database.getSymbolValue("core", SVCallInterruptHandler) != "vPortSVCHandler"):
            Database.sendMessage("core", SVCallInterruptHandler, {"intHandler":"vPortSVCHandler"})

        if (Database.getSymbolValue("core", SVCallInterruptHandlerLock) == False):
            Database.sendMessage("core", SVCallInterruptHandlerLock, {"isEnabled":True})

def destroyComponent(thirdPartyFreeRTOS):
    global clearFreeRTOSSymbols
    
    if coreArch == "MIPS":
        Database.sendMessage("core", "TIMER_1_INTERRUPT_ENABLE", {"isEnabled":False})
        Database.sendMessage("core", "TMR1_CLOCK_ENABLE", {"isEnabled":False})
        Database.sendMessage("core", "CORE_SOFTWARE_0_INTERRUPT_ENABLE", {"isEnabled":False})
    else:
        Database.sendMessage("core", "SysTick_INTERRUPT_ENABLE", {"isEnabled":False})
        Database.sendMessage("core", "SysTick_INTERRUPT_HANDLER", {"intHandler":"SysTick_Handler"})
        Database.sendMessage("core", "SysTick_INTERRUPT_HANDLER_LOCK", {"isEnabled":False})
        Database.sendMessage("core", "PendSV_INTERRUPT_HANDLER", {"intHandler":"PendSV_Handler"})
        Database.sendMessage("core", "SVCall_INTERRUPT_HANDLER", {"intHandler":"SVCall_Handler"})
        if "ARM926" in coreArch:
            Database.sendMessage("core", "FREERTOS_CONFIG", {"USE_FREERTOS_VECTORS": {"clearValue":None}})
            Database.sendMessage("pit", "PIT_TIMER_CONFIG", {"isPitEn": False})
            Database.deactivateComponents(["pit"])
        elif "CORTEX-A5" in coreArch:
            Database.sendMessage("pit", "PIT_TIMER_CONFIG", {"isPitEn": False, "rtosInterruptHandler": ""})
            Database.sendMessage("core", "FREERTOS_CONFIG", {"USE_FREERTOS_VECTORS": {"clearValue":None}})
            Database.deactivateComponents(["pit"])
        else:
            clearFreeRTOSSymbols()

# Instatntiate FreeRTOS Component
def instantiateComponent(thirdPartyFreeRTOS):
    Log.writeInfoMessage("Running FreeRTOS")

    # Deactivate the active RTOS if any.
    deactivateActiveRtos()

    #FreeRTOS Interrupt Handlers configurations
    freeRtosIntConfig()

    if (coreArch == "MIPS"):
        rtosSet = thirdPartyFreeRTOS.createStringSymbol("SET_RTOS", None)
        rtosSet.setVisible(False)
        rtosSet.setValue("FreeRTOS")

    #FreeRTOS Configuration Menu
    freeRtosSymMenu = thirdPartyFreeRTOS.createMenuSymbol("FREERTOS_MENU", None)
    freeRtosSymMenu.setLabel("RTOS Configuration")
    freeRtosSymMenu.setDescription("Select either the preemptive RTOS scheduler, or the cooperative RTOS scheduler")

    freeRtosSym_SchedulerType = thirdPartyFreeRTOS.createComboSymbol("FREERTOS_SCHEDULER", freeRtosSymMenu, ComboVal_Scheduler_Type)
    freeRtosSym_SchedulerType.setLabel("Scheduler Type")
    freeRtosSym_SchedulerType.setDescription("Select either the preemptive RTOS scheduler, or the cooperative RTOS scheduler")
    freeRtosSym_SchedulerType.setDefaultValue("Preemptive")

    freeRtosSym_TaskSelection = thirdPartyFreeRTOS.createComboSymbol("FREERTOS_TASK_SELECTION", freeRtosSymMenu, ComboVal_Task_Selection)
    freeRtosSym_TaskSelection.setLabel("Task Selection")
    freeRtosSym_TaskSelection.setDescription("Select either the Port specific or the Generic method of selecting the next task to execute.")
    if (coreArch == "CORTEX-M0PLUS" or coreArch == "CORTEX-M23" or coreArch == "CORTEX-M33"):
        freeRtosSym_TaskSelection.setDefaultValue("Generic_Task_Selection")
    else:
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

    if (coreArch != "MIPS"):
        freeRtosSym_CpuClockHz = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_CPU_CLOCK_HZ", freeRtosSymMenu)
        freeRtosSym_CpuClockHz.setLabel("CPU Clock Speed (Hz)")
        freeRtosSym_CpuClockHz.setDescription("This is the CPU clock speed obtained from the Clock System Service configuration.")
        freeRtosSym_CpuClockHz.setReadOnly(True)
    else:
        freeRtosSym_PerClockHz = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_PERIPHERAL_CLOCK_HZ", freeRtosSymMenu)
        freeRtosSym_PerClockHz.setLabel("Peripheral Clock Speed (Hz)")
        freeRtosSym_PerClockHz.setDescription("This is the frequency in Hz at which the Timer peripherals are clocked (PBCLK), obtained from the Clock System Service configuration.")

    freeRtosSym_TickRate = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_TICK_RATE_HZ", freeRtosSymMenu)
    freeRtosSym_TickRate.setLabel("Tick Rate (Hz)")
    freeRtosSym_TickRate.setDescription("FreeRTOS - Tick rate (Hz)")
    freeRtosSym_TickRate.setMin(1)
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
    freeRtosSym_StackSize.setDescription("FreeRTOS - Minimal stack size. The size of the stack (in words) used by the idle task.")
    freeRtosSym_StackSize.setDefaultValue(128)

    if Variables.get("__TRUSTZONE_ENABLED") != None and Variables.get("__TRUSTZONE_ENABLED") == "true":
        freeRtosSym_SecureStackSize = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_MINIMAL_SECURE_STACK_SIZE", freeRtosSymMenu)
        freeRtosSym_SecureStackSize.setLabel("Minimal Secure Stack Size")
        freeRtosSym_SecureStackSize.setDescription("FreeRTOS - Minimal Secure stack size. The size of the stack in words")

        freeRtosSym_SecureTotalHeapSize = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_SECURE_TOTAL_HEAP_SIZE", freeRtosSymMenu)
        freeRtosSym_SecureTotalHeapSize.setLabel("Total secure heap size")
        freeRtosSym_SecureTotalHeapSize.setDescription("FreeRTOS - Total secure heap size")

    if (coreArch == "MIPS"):
        freeRtosSym_IsrStackSize = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_ISR_STACK_SIZE", freeRtosSymMenu)
        freeRtosSym_IsrStackSize.setLabel("ISR Stack Size")
        freeRtosSym_IsrStackSize.setDescription("FreeRTOS - ISR stack size. The size of the stack (in words) used by interrupt service routines that cause a context switch.")
        freeRtosSym_IsrStackSize.setDefaultValue(512)

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
    freeRtosSym_TotalHeapSize.setDependencies(freeRtosTotalHeapSizeVisibility, ["FREERTOS_MEMORY_MANAGEMENT_CHOICE"])

    freeRtosSym_MaxTaskNameLen = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_MAX_TASK_NAME_LEN", freeRtosSymMenu)
    freeRtosSym_MaxTaskNameLen.setLabel("Maximum task name length")
    freeRtosSym_MaxTaskNameLen.setDescription("FreeRTOS - Maximum task name length")
    freeRtosSym_MaxTaskNameLen.setMin(1)
    freeRtosSym_MaxTaskNameLen.setMax(32)
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
    freeRtosSym_TimeSlicing.setDefaultValue(True)

    freeRtosSym_NewlibReEntrant = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_NEWLIB_REENTRANT", freeRtosSymMenu)
    freeRtosSym_NewlibReEntrant.setLabel("Use newlib reentrant structure")
    freeRtosSym_NewlibReEntrant.setDescription("FreeRTOS - Use newlib reentrant structure")
    freeRtosSym_NewlibReEntrant.setDefaultValue(False)

    freeRtosSym_TaskFpuSupport = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_TASK_FPU_SUPPORT", freeRtosSymMenu)
    freeRtosSym_TaskFpuSupport.setLabel("Enable hardware FPU support for tasks")
    freeRtosSym_TaskFpuSupport.setDescription("FreeRTOS - Enable hardware FPU support for tasks")
    freeRtosSym_TaskFpuSupport.setDefaultValue(False)

    freeRtosSym_EnableFpu = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_ENABLE_FPU", freeRtosSymMenu)
    freeRtosSym_EnableFpu.setLabel("Enable FPU support")
    freeRtosSym_EnableFpu.setDescription("FreeRTOS - Enable hardware FPU")
    freeRtosSym_EnableFpu.setDefaultValue(False)
    freeRtosSym_EnableFpu.setVisible(False)

    freeRtosSym_EnableTrustZone = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_ENABLE_TRUSTZONE", freeRtosSymMenu)
    freeRtosSym_EnableTrustZone.setLabel("Enable TrustZone")
    freeRtosSym_EnableTrustZone.setDescription("FreeRTOS - Enable TrustZone")
    freeRtosSym_EnableTrustZone.setDefaultValue(False)
    freeRtosSym_EnableTrustZone.setVisible(False)

    freeRtosSym_EnableMpu = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_ENABLE_MPU", freeRtosSymMenu)
    freeRtosSym_EnableMpu.setLabel("Enable MPU")
    freeRtosSym_EnableMpu.setDescription("FreeRTOS - Enable Memory Protection Unit")
    freeRtosSym_EnableMpu.setDefaultValue(False)
    freeRtosSym_EnableMpu.setVisible(False)

    freeRtosSym_EnableMVE = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_ENABLE_MVE", freeRtosSymMenu)
    freeRtosSym_EnableMVE.setLabel("Enable MVE")
    freeRtosSym_EnableMVE.setDescription("FreeRTOS - Enable Cortex-M Vector Extensions")
    freeRtosSym_EnableMVE.setDefaultValue(False)
    freeRtosSym_EnableMVE.setVisible(False)

    freeRtosSym_RunFreeRtosSecure = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_RUN_FREERTOS_SECURE_ONLY", freeRtosSymMenu)
    freeRtosSym_RunFreeRtosSecure.setLabel("Run FreeRTOS on the Secure Side")
    freeRtosSym_RunFreeRtosSecure.setDescription("FreeRTOS - Run FreeRTOS on the Secure Side")
    freeRtosSym_RunFreeRtosSecure.setDefaultValue(False)
    freeRtosSym_RunFreeRtosSecure.setVisible(False)

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

    freeRtosSym_TraceMallocFnc = thirdPartyFreeRTOS.createStringSymbol("FREERTOS_TRACE_MALLOC_FNC", freeRtosSym_TraceFacility)
    freeRtosSym_TraceMallocFnc.setLabel("Use Malloc trace function")
    freeRtosSym_TraceMallocFnc.setDescription("Use memory allocation trace function")
    freeRtosSym_TraceMallocFnc.setDefaultValue("")
    freeRtosSym_TraceMallocFnc.setVisible(False)
    freeRtosSym_TraceMallocFnc.setDependencies(freeRtosStatsFormatFuncVisibility, ["FREERTOS_USE_TRACE_FACILITY"])

    freeRtosSym_TraceFreeFnc = thirdPartyFreeRTOS.createStringSymbol("FREERTOS_TRACE_FREE_FNC", freeRtosSym_TraceFacility)
    freeRtosSym_TraceFreeFnc.setLabel("Use Free trace function")
    freeRtosSym_TraceFreeFnc.setDescription("Use memory free trace function")
    freeRtosSym_TraceFreeFnc.setDefaultValue("")
    freeRtosSym_TraceFreeFnc.setVisible(False)
    freeRtosSym_TraceFreeFnc.setDependencies(freeRtosStatsFormatFuncVisibility, ["FREERTOS_USE_TRACE_FACILITY"])

    freeRtosSym_CoRoutines = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_USE_CO_ROUTINES", freeRtosSymMenu)
    freeRtosSym_CoRoutines.setLabel("Use Co-Routines")
    freeRtosSym_CoRoutines.setDescription("FreeRTOS - Use Co-Routines")
    freeRtosSym_CoRoutines.setDefaultValue(False)

    freeRtosSym_MaxCoRoutinePrio = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_MAX_CO_ROUTINE_PRIORITIES", freeRtosSymMenu)
    freeRtosSym_MaxCoRoutinePrio.setLabel("Maximum Co-Routines priorities")
    freeRtosSym_MaxCoRoutinePrio.setDescription("FreeRTOS - Maximum Co-Routines priorities")
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

    freeRtosSym_MaxSysCalIntrPrio = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_MAX_SYSCALL_INTERRUPT_PRIORITY", freeRtosSymMenu)
    freeRtosSym_MaxSysCalIntrPrio.setLabel("Maximum system call interrupt priority")
    freeRtosSym_MaxSysCalIntrPrio.setDescription("FreeRTOS - Kernel interrupt priority")
    freeRtosSym_MaxSysCalIntrPrio.setMin(0)
    freeRtosSym_MaxSysCalIntrPrio.setMax(7)

    if (coreArch != "MIPS") and (coreArch != "CORTEX-A5") and ("ARM926" not in coreArch) and (coreArch != "CORTEX-A7"):
        freeRtosSym_ConfigPriorityBits = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_CONFIG_PRIORITY_BITS", freeRtosSymMenu)
        freeRtosSym_ConfigPriorityBits.setLabel("Number of Bits used for Priority Levels")
        freeRtosSym_ConfigPriorityBits.setMin(2)
        freeRtosSym_ConfigPriorityBits.setMax(4)
        freeRtosSym_ConfigPriorityBits.setVisible(False)

    if (coreArch == "CORTEX-A7"):
        freeRtosSym_ConfigUniqueInterruptPriority = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_CONFIG_UNIQUE_INTERRUPT_PRIORITIES", freeRtosSymMenu)
        freeRtosSym_ConfigUniqueInterruptPriority.setLabel("Number of unique interrupt priorities")
        freeRtosSym_ConfigUniqueInterruptPriority.setDefaultValue(32)
        freeRtosSym_ConfigUniqueInterruptPriority.setMin(1)
        freeRtosSym_ConfigUniqueInterruptPriority.setMax(256)

        freeRtosSym_ConfigMaxApiCallInterruptPriority = thirdPartyFreeRTOS.createIntegerSymbol("FREERTOS_CONFIG_MAX_API_CALL_INTERRUPT_PRIORITY", freeRtosSymMenu)
        freeRtosSym_ConfigMaxApiCallInterruptPriority.setLabel("Number of maximum API call interrupt priorities")
        freeRtosSym_ConfigMaxApiCallInterruptPriority.setDefaultValue(((freeRtosSym_ConfigUniqueInterruptPriority.getValue() / 2) + 1))
        freeRtosSym_ConfigMaxApiCallInterruptPriority.setMin(1)
        freeRtosSym_ConfigMaxApiCallInterruptPriority.setMax((freeRtosSym_ConfigUniqueInterruptPriority.getMax() - 2))

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
    freeRtosSym_xTaskGetCurrentTaskHandle.setDefaultValue(True)

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

    freeRtosSym_xQueueGetMutexHolder = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_XQUEUEGETMUTEXHOLDER", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_xQueueGetMutexHolder.setLabel("Include xQueueGetMutexHolder")
    freeRtosSym_xQueueGetMutexHolder.setDescription("FreeRTOS - Include xQueueGetMutexHolder")
    freeRtosSym_xQueueGetMutexHolder.setDefaultValue(False)

    freeRtosSym_xSemaphoreGetMutexHolder = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_XSEMAPHOREGETMUTEXHOLDER", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_xSemaphoreGetMutexHolder.setLabel("Include xSemaphoreGetMutexHolder")
    freeRtosSym_xSemaphoreGetMutexHolder.setDescription("FreeRTOS - Include xSemaphoreGetMutexHolder")
    freeRtosSym_xSemaphoreGetMutexHolder.setDefaultValue(False)

    freeRtosSym_uxTaskGetStackHighWaterMark2 = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_UXTASKGETSTACKHIGHWATERMARK2", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_uxTaskGetStackHighWaterMark2.setLabel("Include uxTaskGetStackHighWaterMark2")
    freeRtosSym_uxTaskGetStackHighWaterMark2.setDescription("FreeRTOS - Include uxTaskGetStackHighWaterMark2")
    freeRtosSym_uxTaskGetStackHighWaterMark2.setDefaultValue(False)

    freeRtosSym_xTaskResumeFromISR = thirdPartyFreeRTOS.createBooleanSymbol("FREERTOS_INCLUDE_XTASKRESUMEFROMISR", freeRtosSymMenu_IncludeComponents)
    freeRtosSym_xTaskResumeFromISR.setLabel("Include xTaskResumeFromISR")
    freeRtosSym_xTaskResumeFromISR.setDescription("FreeRTOS - Include xTaskResumeFromISR")
    freeRtosSym_xTaskResumeFromISR.setDefaultValue(False)

############################################################################
#### Code Generation ####
############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")


    freeRtosConfHeaderFile = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_CONFIG_H", None)
    freeRtosConfHeaderFile.setSourcePath("templates/FreeRTOSConfig.h.ftl")
    freeRtosConfHeaderFile.setOutputName("FreeRTOSConfig.h")
    freeRtosConfHeaderFile.setProjectPath("config/" + configName + "")
    freeRtosConfHeaderFile.setType("HEADER")
    freeRtosConfHeaderFile.setMarkup(True)

    freeRtosHooksSourceFile = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_HOOKS_C", None)
    freeRtosHooksSourceFile.setSourcePath("templates/freertos_hooks.c.ftl")
    freeRtosHooksSourceFile.setOutputName("freertos_hooks.c")
    freeRtosHooksSourceFile.setProjectPath("config/" + configName + "")
    freeRtosHooksSourceFile.setType("SOURCE")
    freeRtosHooksSourceFile.setMarkup(True)

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
    freeRtosTask.setOutputName("FreeRTOS_tasks.c")
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
    freeRtosCoRoutineHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/croutine.h")
    freeRtosCoRoutineHeader.setOutputName("croutine.h")
    freeRtosCoRoutineHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosCoRoutineHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosCoRoutineHeader.setType("HEADER")

    freeRtosEventGrpHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_EVENT_GROUPS_H", None)
    freeRtosEventGrpHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/event_groups.h")
    freeRtosEventGrpHeader.setOutputName("event_groups.h")
    freeRtosEventGrpHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosEventGrpHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosEventGrpHeader.setType("HEADER")

    freeRtosFreeRtosHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_FREERTOS_H", None)
    freeRtosFreeRtosHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/FreeRTOS.h")
    freeRtosFreeRtosHeader.setOutputName("FreeRTOS.h")
    freeRtosFreeRtosHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosFreeRtosHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosFreeRtosHeader.setType("HEADER")

    freeRtosListHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_LIST_H", None)
    freeRtosListHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/list.h")
    freeRtosListHeader.setOutputName("list.h")
    freeRtosListHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosListHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosListHeader.setType("HEADER")

    freeRtosMpuWrappersHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MPU_WRAPPERS_H", None)
    freeRtosMpuWrappersHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/mpu_wrappers.h")
    freeRtosMpuWrappersHeader.setOutputName("mpu_wrappers.h")
    freeRtosMpuWrappersHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosMpuWrappersHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosMpuWrappersHeader.setType("HEADER")

    freeRtosPortableHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_PORTABLE_H", None)
    freeRtosPortableHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/portable.h")
    freeRtosPortableHeader.setOutputName("portable.h")
    freeRtosPortableHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosPortableHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosPortableHeader.setType("HEADER")

    freeRtosProjDefHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_PROJDEFS_H", None)
    freeRtosProjDefHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/projdefs.h")
    freeRtosProjDefHeader.setOutputName("projdefs.h")
    freeRtosProjDefHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosProjDefHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosProjDefHeader.setType("HEADER")

    freeRtosQueueHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_QUEUE_H", None)
    freeRtosQueueHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/queue.h")
    freeRtosQueueHeader.setOutputName("queue.h")
    freeRtosQueueHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosQueueHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosQueueHeader.setType("HEADER")

    freeRtosPortMacro = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_SEMPHR_H", None)
    freeRtosPortMacro.setSourcePath("../CMSIS-FreeRTOS/Source/include/semphr.h")
    freeRtosPortMacro.setOutputName("semphr.h")
    freeRtosPortMacro.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosPortMacro.setProjectPath("FreeRTOS/Source/include")
    freeRtosPortMacro.setType("HEADER")

    freeRtosStackMacroHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_STACK_MACROS_H", None)
    freeRtosStackMacroHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/stack_macros.h")
    freeRtosStackMacroHeader.setOutputName("stack_macros.h")
    freeRtosStackMacroHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosStackMacroHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosStackMacroHeader.setType("HEADER")

    freeRtosDepDefHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_DEPRECATED_DEFINITIONS_H", None)
    freeRtosDepDefHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/deprecated_definitions.h")
    freeRtosDepDefHeader.setOutputName("deprecated_definitions.h")
    freeRtosDepDefHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosDepDefHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosDepDefHeader.setType("HEADER")

    freeRtosTaskHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_TASK_H", None)
    freeRtosTaskHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/task.h")
    freeRtosTaskHeader.setOutputName("task.h")
    freeRtosTaskHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosTaskHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosTaskHeader.setType("HEADER")

    freeRtosTimerHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_TIMERS_H", None)
    freeRtosTimerHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/timers.h")
    freeRtosTimerHeader.setOutputName("timers.h")
    freeRtosTimerHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosTimerHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosTimerHeader.setType("HEADER")

    freeRtosMpuProtoHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MPU_PROTOTYPES_H", None)
    freeRtosMpuProtoHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/mpu_prototypes.h")
    freeRtosMpuProtoHeader.setOutputName("mpu_prototypes.h")
    freeRtosMpuProtoHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosMpuProtoHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosMpuProtoHeader.setType("HEADER")

    freeRtosStreamBufHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_STREAM_BUFFER_H", None)
    freeRtosStreamBufHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/stream_buffer.h")
    freeRtosStreamBufHeader.setOutputName("stream_buffer.h")
    freeRtosStreamBufHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosStreamBufHeader.setProjectPath("FreeRTOS/Source/include")
    freeRtosStreamBufHeader.setType("HEADER")
    freeRtosStreamBufHeader.setDependencies(buildStreamBuffer, ["FREERTOS_USE_TASK_NOTIFICATIONS"])

    freeRtosMesgBufHeader = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_MESSAGE_BUFFER_H", None)
    freeRtosMesgBufHeader.setSourcePath("../CMSIS-FreeRTOS/Source/include/message_buffer.h")
    freeRtosMesgBufHeader.setOutputName("message_buffer.h")
    freeRtosMesgBufHeader.setDestPath("../../third_party/rtos/FreeRTOS/Source/include")
    freeRtosMesgBufHeader.setProjectPath("FreeRTOS/Source/include")
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

    freertosInterruptInclude = thirdPartyFreeRTOS.createFileSymbol("FREERTOS_INTERRUPT_INCLUDE", None)
    freertosInterruptInclude.setType("STRING")
    freertosInterruptInclude.setOutputName("core.LIST_SYSTEM_INTERRUPT_C_INCLUDES")
    freertosInterruptInclude.setSourcePath("templates/freertos_interrupt_include.h.ftl")
    freertosInterruptInclude.setMarkup(True)
    freertosInterruptInclude.setEnabled(Database.getSymbolValue("core", "CoreArchitecture") in ["CORTEX-M23", "CORTEX-M33", "CORTEX-A5"])


    # load family specific configuration
    if (coreArch == "MIPS"):
        execfile(Module.getPath() + "config/arch/mips/devices_" + coreFamily[:7].lower() + "/freertos_config.py")
    elif ("ARM926" in coreArch):
        execfile(Module.getPath() + "config/arch/arm/devices_arm926/freertos_config.py")
    else:
        execfile(Module.getPath() + "config/arch/arm/devices_" + coreArch.replace("-", "_").replace("PLUS", "").lower() + "/freertos_config.py")
