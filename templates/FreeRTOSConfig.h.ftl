/* MISRA C-2012 Rule 3.1, 5.4 deviated below. Deviation record ID -
   H3_MISRAC_2012_R_3_1_DR_1 & H3_MISRAC_2012_R_5_4_DR_1*/

#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:2 "MISRA C-2012 Rule 3.1" "H3_MISRAC_2012_R_3_1_DR_1" )\
(deviate:2 "MISRA C-2012 Rule 5.4" "H3_MISRAC_2012_R_5_4_DR_1" )
</#if>

/*
 * FreeRTOS Kernel V11.1.0
 * Copyright (C) 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * SPDX-License-Identifier: MIT
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * https://www.FreeRTOS.org
 * https://github.com/FreeRTOS
 *
 */

/*******************************************************************************
 * This file provides an example FreeRTOSConfig.h header file, inclusive of an
 * abbreviated explanation of each configuration item.  Online and reference
 * documentation provides more information.
 * https://www.freertos.org/a00110.html
 *
 * Constant values enclosed in square brackets ('[' and ']') must be completed
 * before this file will build.
 *
 * Use the FreeRTOSConfig.h supplied with the RTOS port in use rather than this
 * generic file, if one is available.
 ******************************************************************************/

<#if core.CoreArchitecture != "MIPS" && core.CoreArchitecture != "PIC32A" && core.CoreArchitecture != "dsPIC33A">
/******************************************************************************/
/* Hardware description related definitions. **********************************/
/******************************************************************************/

/* In most cases, configCPU_CLOCK_HZ must be set to the frequency of the clock
 * that drives the peripheral used to generate the kernels periodic tick interrupt.
 * The default value is set to 20MHz and matches the QEMU demo settings.  Your
 * application will certainly need a different value so set this correctly.
 * This is very often, but not always, equal to the main system clock frequency. */
#define configCPU_CLOCK_HZ                      ( ${FREERTOS_CPU_CLOCK_HZ?number?c}UL )
</#if>
/******************************************************************************/
/* Scheduling behaviour related definitions. **********************************/
/******************************************************************************/

/* configTICK_RATE_HZ sets frequency of the tick interrupt in Hz, normally
 * calculated from the configCPU_CLOCK_HZ value. */
#define configTICK_RATE_HZ                      ( ( TickType_t ) ${FREERTOS_TICK_RATE_HZ} )

/* Set configUSE_PREEMPTION to 1 to use pre-emptive scheduling.  Set
 * configUSE_PREEMPTION to 0 to use co-operative scheduling.
 * See https://www.freertos.org/single-core-amp-smp-rtos-scheduling.html. */
#define configUSE_PREEMPTION                    <#if FREERTOS_SCHEDULER == "Preemptive">1<#else>0</#if>

/* Set configUSE_TIME_SLICING to 1 to have the scheduler switch between Ready
 * state tasks of equal priority on every tick interrupt.  Set
 * configUSE_TIME_SLICING to 0 to prevent the scheduler switching between Ready
 * state tasks just because there was a tick interrupt.  See
 * https://freertos.org/single-core-amp-smp-rtos-scheduling.html. */
#define configUSE_TIME_SLICING                  <#if FREERTOS_USE_TIME_SLICING == true>1<#else>0</#if>

/* Set configUSE_PORT_OPTIMISED_TASK_SELECTION to 1 to select the next task to
 * run using an algorithm optimised to the instruction set of the target hardware -
 * normally using a count leading zeros assembly instruction.  Set to 0 to select
 * the next task to run using a generic C algorithm that works for all FreeRTOS
 * ports.  Not all FreeRTOS ports have this option.  Defaults to 0 if left
 * undefined. */
#define configUSE_PORT_OPTIMISED_TASK_SELECTION <#if FREERTOS_TASK_SELECTION == "Port_Optimized">1<#else>0</#if>

/* Set configUSE_TICKLESS_IDLE to 1 to use the low power tickless mode.  Set to
 * 0 to keep the tick interrupt running at all times.  Not all FreeRTOS ports
 * support tickless mode. See https://www.freertos.org/low-power-tickless-rtos.html
 * Defaults to 0 if left undefined. */
#define configUSE_TICKLESS_IDLE                 <#if FREERTOS_TICKLESS_IDLE_CHOICE == "Tickless_Idle">1<#else>0</#if>

/* configMAX_PRIORITIES Sets the number of available task priorities.  Tasks can
 * be assigned priorities of 0 to (configMAX_PRIORITIES - 1).  Zero is the lowest
 * priority. */
#define configMAX_PRIORITIES                    ( ${FREERTOS_MAX_PRIORITIES}UL )

/* configMINIMAL_STACK_SIZE defines the size of the stack used by the Idle task
 * (in words, not in bytes!).  The kernel does not use this constant for any other
 * purpose.  Demo applications use the constant to make the demos somewhat portable
 * across hardware architectures. */
#define configMINIMAL_STACK_SIZE                ( ${FREERTOS_MINIMAL_STACK_SIZE} )

/* configMAX_TASK_NAME_LEN sets the maximum length (in characters) of a task's
 * human readable name.  Includes the NULL terminator. */
#define configMAX_TASK_NAME_LEN                 ( ${FREERTOS_MAX_TASK_NAME_LEN} )

/* Time is measured in 'ticks' - which is the number of times the tick interrupt
 * has executed since the RTOS kernel was started.
 * The tick count is held in a variable of type TickType_t.
 *
 * configTICK_TYPE_WIDTH_IN_BITS controls the type (and therefore bit-width) of TickType_t:
 *
 * Defining configTICK_TYPE_WIDTH_IN_BITS as TICK_TYPE_WIDTH_16_BITS causes
 * TickType_t to be defined (typedef'ed) as an unsigned 16-bit type.
 *
 * Defining configTICK_TYPE_WIDTH_IN_BITS as TICK_TYPE_WIDTH_32_BITS causes
 * TickType_t to be defined (typedef'ed) as an unsigned 32-bit type.
 *
 * Defining configTICK_TYPE_WIDTH_IN_BITS as TICK_TYPE_WIDTH_64_BITS causes
 * TickType_t to be defined (typedef'ed) as an unsigned 64-bit type. */
#define configTICK_TYPE_WIDTH_IN_BITS              TICK_TYPE_WIDTH_${FREERTOS_TICK_TYPE_WIDTH_IN_BITS}

/* Set configIDLE_SHOULD_YIELD to 1 to have the Idle task yield to an
 * application task if there is an Idle priority (priority 0) application task that
 * can run.  Set to 0 to have the Idle task use all of its timeslice.  Default to 1
 * if left undefined. */
<#if FREERTOS_SCHEDULER == "Preemptive">
    <#lt>#define configIDLE_SHOULD_YIELD                 <#if FREERTOS_IDLE_SHOULD_YIELD == true>1<#else>0</#if>
</#if>

/* Each task has an array of task notifications.
 * configTASK_NOTIFICATION_ARRAY_ENTRIES sets the number of indexes in the array.
 * See https://www.freertos.org/RTOS-task-notifications.html  Defaults to 1 if
 * left undefined. */
#define configTASK_NOTIFICATION_ARRAY_ENTRIES      ${FREERTOS_TASK_NOTIFICATION_ARRAY_ENTRIES}

/* configQUEUE_REGISTRY_SIZE sets the maximum number of queues and semaphores
 * that can be referenced from the queue registry.  Only required when using a
 * kernel aware debugger.  Defaults to 0 if left undefined. */
#define configQUEUE_REGISTRY_SIZE               ${FREERTOS_QUEUE_REGISTRY_SIZE}

/* Set configENABLE_BACKWARD_COMPATIBILITY to 1 to map function names and
 * datatypes from old version of FreeRTOS to their latest equivalent.  Defaults to
 * 1 if left undefined. */
#define configENABLE_BACKWARD_COMPATIBILITY        <#if FREERTOS_ENABLE_BACKWARD_COMPATIBILITY == true>1<#else>0</#if>

/* Each task has its own array of pointers that can be used as thread local
 * storage.  configNUM_THREAD_LOCAL_STORAGE_POINTERS set the number of indexes in
 * the array.  See https://www.freertos.org/thread-local-storage-pointers.html
 * Defaults to 0 if left undefined. */
#define configNUM_THREAD_LOCAL_STORAGE_POINTERS    ${FREERTOS_NUM_THREAD_LOCAL_STORAGE_POINTERS}

/* When configUSE_MINI_LIST_ITEM is set to 0, MiniListItem_t and ListItem_t are
 * both the same. When configUSE_MINI_LIST_ITEM is set to 1, MiniListItem_t contains
 * 3 fewer fields than ListItem_t which saves some RAM at the cost of violating
 * strict aliasing rules which some compilers depend on for optimization. Defaults
 * to 1 if left undefined. */
#define configUSE_MINI_LIST_ITEM                   <#if FREERTOS_USE_MINI_LIST_ITEM == true>1<#else>0</#if>

/* Sets the type used by the parameter to xTaskCreate() that specifies the stack
 * size of the task being created.  The same type is used to return information
 * about stack usage in various other API calls.  Defaults to size_t if left
 * undefined. */
#define configSTACK_DEPTH_TYPE                     ${FREERTOS_STACK_DEPTH_TYPE}

/* configMESSAGE_BUFFER_LENGTH_TYPE sets the type used to store the length of
 * each message written to a FreeRTOS message buffer (the length is also written to
 * the message buffer.  Defaults to size_t if left undefined - but that may waste
 * space if messages never go above a length that could be held in a uint8_t. */
#define configMESSAGE_BUFFER_LENGTH_TYPE           size_t

/* If configHEAP_CLEAR_MEMORY_ON_FREE is set to 1, then blocks of memory allocated
 * using pvPortMalloc() will be cleared (i.e. set to zero) when freed using
 * vPortFree(). Defaults to 0 if left undefined. */
#define configHEAP_CLEAR_MEMORY_ON_FREE            <#if FREERTOS_HEAP_CLEAR_MEMORY_ON_FREE == true>1<#else>0</#if>

/* vTaskList and vTaskGetRunTimeStats APIs take a buffer as a parameter and assume
 * that the length of the buffer is configSTATS_BUFFER_MAX_LENGTH. Defaults to
 * 0xFFFF if left undefined.
 * New applications are recommended to use vTaskListTasks and
 * vTaskGetRunTimeStatistics APIs instead and supply the length of the buffer
 * explicitly to avoid memory corruption. */
#define configSTATS_BUFFER_MAX_LENGTH              0xFFFF

/* Set configUSE_NEWLIB_REENTRANT to 1 to have a newlib reent structure
 * allocated for each task.  Set to 0 to not support newlib reent structures.
 * Default to 0 if left undefined.
 *
 * Note Newlib support has been included by popular demand, but is not used or
 * tested by the FreeRTOS maintainers themselves. FreeRTOS is not responsible for
 * resulting newlib operation. User must be familiar with newlib and must provide
 * system-wide implementations of the necessary stubs. Note that (at the time of
 * writing) the current newlib design implements a system-wide malloc() that must
 * be provided with locks. */
#define configUSE_NEWLIB_REENTRANT              <#if FREERTOS_USE_NEWLIB_REENTRANT == true>1<#else>0</#if>

<#if FREERTOS_TICKLESS_IDLE_CHOICE == "Tickless_Idle">
    <#lt>#define configEXPECTED_IDLE_TIME_BEFORE_SLEEP   ${FREERTOS_EXPECTED_IDLE_TIME_BEFORE_SLEEP}
</#if>

/******************************************************************************/
/* Software timer related definitions. ****************************************/
/******************************************************************************/

/* Set configUSE_TIMERS to 1 to include software timer functionality in the
 * build.  Set to 0 to exclude software timer functionality from the build.  The
 * FreeRTOS/source/timers.c source file must be included in the build if
 * configUSE_TIMERS is set to 1.  Default to 0 if left undefined.  See
 * https://www.freertos.org/RTOS-software-timer.html. */
#define configUSE_TIMERS                        <#if FREERTOS_USE_TIMERS == true>1<#else>0</#if>

/* configTIMER_TASK_PRIORITY sets the priority used by the timer task.  Only
 * used if configUSE_TIMERS is set to 1.  The timer task is a standard FreeRTOS
 * task, so its priority is set like any other task.  See
 * https://www.freertos.org/RTOS-software-timer-service-daemon-task.html  Only used
 * if configUSE_TIMERS is set to 1. */
#define configTIMER_TASK_PRIORITY               ${FREERTOS_TIMER_TASK_PRIORITY}

/* configTIMER_TASK_STACK_DEPTH sets the size of the stack allocated to the
 * timer task (in words, not in bytes!).  The timer task is a standard FreeRTOS
 * task.  See https://www.freertos.org/RTOS-software-timer-service-daemon-task.html
 * Only used if configUSE_TIMERS is set to 1. */
#define configTIMER_TASK_STACK_DEPTH            ${FREERTOS_TIMER_TASK_STACK_DEPTH}

/* configTIMER_QUEUE_LENGTH sets the length of the queue (the number of discrete
 * items the queue can hold) used to send commands to the timer task.  See
 * https://www.freertos.org/RTOS-software-timer-service-daemon-task.html  Only used
 * if configUSE_TIMERS is set to 1. */
#define configTIMER_QUEUE_LENGTH                ${FREERTOS_TIMER_QUEUE_LENGTH}

/******************************************************************************/
/* Event Group related definitions. *******************************************/
/******************************************************************************/

/* Set configUSE_EVENT_GROUPS to 1 to include event group functionality in the
 * build. Set to 0 to exclude event group functionality from the build. The
 * FreeRTOS/source/event_groups.c source file must be included in the build if
 * configUSE_EVENT_GROUPS is set to 1. Defaults to 1 if left undefined. */

#define configUSE_EVENT_GROUPS    <#if FREERTOS_USE_EVENT_GROUPS == true>1<#else>0</#if>

/******************************************************************************/
/* Stream Buffer related definitions. *****************************************/
/******************************************************************************/

/* Set configUSE_STREAM_BUFFERS to 1 to include stream buffer functionality in
 * the build. Set to 0 to exclude stream buffer functionality from the build. The
 * FreeRTOS/source/stream_buffer.c source file must be included in the build if
 * configUSE_STREAM_BUFFERS is set to 1. Defaults to 1 if left undefined. */

#define configUSE_STREAM_BUFFERS    <#if FREERTOS_USE_STREAM_BUFFERS == true>1<#else>0</#if>

/******************************************************************************/
/* Memory allocation related definitions. *************************************/
/******************************************************************************/

/* Set configSUPPORT_STATIC_ALLOCATION to 1 to include FreeRTOS API functions
 * that create FreeRTOS objects (tasks, queues, etc.) using statically allocated
 * memory in the build.  Set to 0 to exclude the ability to create statically
 * allocated objects from the build.  Defaults to 0 if left undefined.  See
 * https://www.freertos.org/Static_Vs_Dynamic_Memory_Allocation.html. */
#define configSUPPORT_STATIC_ALLOCATION         <#if FREERTOS_STATIC_ALLOC == true>1<#else>0</#if>

/* Set configSUPPORT_DYNAMIC_ALLOCATION to 1 to include FreeRTOS API functions
 * that create FreeRTOS objects (tasks, queues, etc.) using dynamically allocated
 * memory in the build.  Set to 0 to exclude the ability to create dynamically
 * allocated objects from the build.  Defaults to 1 if left undefined.  See
 * https://www.freertos.org/Static_Vs_Dynamic_Memory_Allocation.html. */
#define configSUPPORT_DYNAMIC_ALLOCATION        <#if FREERTOS_DYNAMIC_ALLOC == true>1<#else>0</#if>

/* Sets the total size of the FreeRTOS heap, in bytes, when heap_1.c, heap_2.c
 * or heap_4.c are included in the build.  This value is defaulted to 4096 bytes but
 * it must be tailored to each application.  Note the heap will appear in the .bss
 * section.  See https://www.freertos.org/a00111.html. */
#define configTOTAL_HEAP_SIZE                   ( ( size_t ) ${FREERTOS_TOTAL_HEAP_SIZE} )

/* Set configAPPLICATION_ALLOCATED_HEAP to 1 to have the application allocate
 * the array used as the FreeRTOS heap.  Set to 0 to have the linker allocate the
 * array used as the FreeRTOS heap.  Defaults to 0 if left undefined. */
#define configAPPLICATION_ALLOCATED_HEAP             <#if FREERTOS_APPLICATION_ALLOCATED_HEAP == true>1<#else>0</#if>

/* Set configSTACK_ALLOCATION_FROM_SEPARATE_HEAP to 1 to have task stacks
 * allocated from somewhere other than the FreeRTOS heap.  This is useful if you
 * want to ensure stacks are held in fast memory.  Set to 0 to have task stacks
 * come from the standard FreeRTOS heap.  The application writer must provide
 * implementations for pvPortMallocStack() and vPortFreeStack() if set to 1.
 * Defaults to 0 if left undefined. */
#define configSTACK_ALLOCATION_FROM_SEPARATE_HEAP    <#if FREERTOS_STACK_ALLOCATION_FROM_SEPARATE_HEAP == true>1<#else>0</#if>

/* Set configENABLE_HEAP_PROTECTOR to 1 to enable bounds checking and obfuscation
 * to internal heap block pointers in heap_4.c and heap_5.c to help catch pointer
 * corruptions. Defaults to 0 if left undefined. */
#define configENABLE_HEAP_PROTECTOR                  <#if FREERTOS_ENABLE_HEAP_PROTECTOR == true>1<#else>0</#if>

/******************************************************************************/
/* Interrupt nesting behaviour configuration. *********************************/
/******************************************************************************/

<#if core.CoreArchitecture != "MIPS" && core.CoreArchitecture != "PIC32A" && core.CoreArchitecture != "dsPIC33A">
  <#if core.CoreArchitecture != "CORTEX-A5" && (core.CoreArchitecture?matches("ARM926.*") == false) && core.CoreArchitecture != "CORTEX-A7">
    <#lt>/* configKERNEL_INTERRUPT_PRIORITY sets the priority of the tick and context
    <#lt> * switch performing interrupts.  Not supported by all FreeRTOS ports.  See
    <#lt> * https://www.freertos.org/RTOS-Cortex-M3-M4.html for information specific to
    <#lt> * ARM Cortex-M devices. */
    <#lt>#define configKERNEL_INTERRUPT_PRIORITY         (${FREERTOS_KERNEL_INTERRUPT_PRIORITY} << (8 - ${FREERTOS_CONFIG_PRIORITY_BITS}))
    <#lt>
    <#lt>/* configMAX_SYSCALL_INTERRUPT_PRIORITY sets the interrupt priority above which
    <#lt> * FreeRTOS API calls must not be made.  Interrupts above this priority are never
    <#lt> * disabled, so never delayed by RTOS activity.  The default value is set to the
    <#lt> * highest interrupt priority (0).  Not supported by all FreeRTOS ports.
    <#lt> * See https://www.freertos.org/RTOS-Cortex-M3-M4.html for information specific to
    <#lt> * ARM Cortex-M devices. */
    <#lt>#define configMAX_SYSCALL_INTERRUPT_PRIORITY    (${FREERTOS_MAX_SYSCALL_INTERRUPT_PRIORITY} << (8 - ${FREERTOS_CONFIG_PRIORITY_BITS}))
  </#if>
<#else>
    <#lt>#define configPERIPHERAL_CLOCK_HZ               ( ${FREERTOS_PERIPHERAL_CLOCK_HZ?number?c}UL )
	<#if core.CoreArchitecture != "PIC32A" && core.CoreArchitecture != "dsPIC33A">
        <#lt>#define configISR_STACK_SIZE                    ( ${FREERTOS_ISR_STACK_SIZE} )
	</#if>
    <#lt>/* configKERNEL_INTERRUPT_PRIORITY sets the priority of the tick and context
    <#lt> * switch performing interrupts.  Not supported by all FreeRTOS ports.  See
    <#lt> * https://www.freertos.org/RTOS-Cortex-M3-M4.html for information specific to
    <#lt> * ARM Cortex-M devices. */
    <#lt>#define configKERNEL_INTERRUPT_PRIORITY         (${FREERTOS_KERNEL_INTERRUPT_PRIORITY})
    <#lt>
    <#lt>/* configMAX_SYSCALL_INTERRUPT_PRIORITY sets the interrupt priority above which
    <#lt> * FreeRTOS API calls must not be made.  Interrupts above this priority are never
    <#lt> * disabled, so never delayed by RTOS activity.  The default value is set to the
    <#lt> * highest interrupt priority (0).  Not supported by all FreeRTOS ports.
    <#lt> * See https://www.freertos.org/RTOS-Cortex-M3-M4.html for information specific to
    <#lt> * ARM Cortex-M devices. */
    <#lt>#define configMAX_SYSCALL_INTERRUPT_PRIORITY    (${FREERTOS_MAX_SYSCALL_INTERRUPT_PRIORITY})
</#if>

/* Another name for configMAX_SYSCALL_INTERRUPT_PRIORITY - the name used depends
 * on the FreeRTOS port. */
<#if FREERTOS_CONFIG_MAX_API_CALL_INTERRUPT_PRIORITY??>
    <#lt>#define configMAX_API_CALL_INTERRUPT_PRIORITY           ${FREERTOS_CONFIG_MAX_API_CALL_INTERRUPT_PRIORITY}
</#if>

/******************************************************************************/
/* Hook and callback function related definitions. ****************************/
/******************************************************************************/

/* Set the following configUSE_* constants to 1 to include the named hook
 * functionality in the build.  Set to 0 to exclude the hook functionality from the
 * build.  The application writer is responsible for providing the hook function
 * for any set to 1.  See https://www.freertos.org/a00016.html. */
#define configUSE_IDLE_HOOK                     <#if FREERTOS_IDLE_HOOK == true>1<#else>0</#if>
#define configUSE_TICK_HOOK                     <#if FREERTOS_TICK_HOOK == true>1<#else>0</#if>
#define configUSE_MALLOC_FAILED_HOOK            <#if FREERTOS_USE_MALLOC_FAILED_HOOK == true>1<#else>0</#if>
#define configUSE_DAEMON_TASK_STARTUP_HOOK      <#if FREERTOS_DAEMON_TASK_STARTUP_HOOK == true>1<#else>0</#if>

/* Set configUSE_SB_COMPLETED_CALLBACK to 1 to have send and receive completed
 * callbacks for each instance of a stream buffer or message buffer. When the
 * option is set to 1, APIs xStreamBufferCreateWithCallback() and
 * xStreamBufferCreateStaticWithCallback() (and likewise APIs for message
 * buffer) can be used to create a stream buffer or message buffer instance
 * with application provided callbacks. Defaults to 0 if left undefined. */
#define configUSE_SB_COMPLETED_CALLBACK       <#if FREERTOS_USE_SB_COMPLETED_CALLBACK == true>1<#else>0</#if>

/* Set configCHECK_FOR_STACK_OVERFLOW to 1 or 2 for FreeRTOS to check for a
 * stack overflow at the time of a context switch.  Set to 0 to not look for a
 * stack overflow.  If configCHECK_FOR_STACK_OVERFLOW is 1 then the check only
 * looks for the stack pointer being out of bounds when a task's context is saved
 * to its stack - this is fast but somewhat ineffective.  If
 * configCHECK_FOR_STACK_OVERFLOW is 2 then the check looks for a pattern written
 * to the end of a task's stack having been overwritten.  This is slower, but will
 * catch most (but not all) stack overflows.  The application writer must provide
 * the stack overflow callback when configCHECK_FOR_STACK_OVERFLOW is set to 1.
 * See https://www.freertos.org/Stacks-and-stack-overflow-checking.html  Defaults
 * to 0 if left undefined. */
#define configCHECK_FOR_STACK_OVERFLOW          <#if FREERTOS_CHECK_FOR_STACK_OVERFLOW == "No_Check">0<#else><#if FREERTOS_CHECK_FOR_STACK_OVERFLOW == "Method_1">1<#else>2</#if></#if>

/******************************************************************************/
/* Run time and task stats gathering related definitions. *********************/
/******************************************************************************/

/* Set configGENERATE_RUN_TIME_STATS to 1 to have FreeRTOS collect data on the
 * processing time used by each task.  Set to 0 to not collect the data.  The
 * application writer needs to provide a clock source if set to 1.  Defaults to 0
 * if left undefined.  See https://www.freertos.org/rtos-run-time-stats.html. */
#define configGENERATE_RUN_TIME_STATS           <#if FREERTOS_GENERATE_RUN_TIME_STATS == true>1<#else>0</#if>

/* Set configUSE_TRACE_FACILITY to include additional task structure members
 * are used by trace and visualisation functions and tools.  Set to 0 to exclude
 * the additional information from the structures. Defaults to 0 if left
 * undefined. */
#define configUSE_TRACE_FACILITY                <#if FREERTOS_USE_TRACE_FACILITY == true>1<#else>0</#if>

/* Set to 1 to include the vTaskList() and vTaskGetRunTimeStats() functions in
 * the build.  Set to 0 to exclude these functions from the build.  These two
 * functions introduce a dependency on string formatting functions that would
 * otherwise not exist - hence they are kept separate.  Defaults to 0 if left
 * undefined. */
#define configUSE_STATS_FORMATTING_FUNCTIONS    <#if FREERTOS_USE_STATS_FORMATTING_FUNCTIONS == true>1<#else>0</#if>

/******************************************************************************/
/* Co-routine related definitions. ********************************************/
/******************************************************************************/

/* Set configUSE_CO_ROUTINES to 1 to include co-routine functionality in the
 * build, or 0 to omit co-routine functionality from the build. To include
 * co-routines, croutine.c must be included in the project. Defaults to 0 if left
 * undefined. */
#define configUSE_CO_ROUTINES                   <#if FREERTOS_USE_CO_ROUTINES == true>1<#else>0</#if>

/* configMAX_CO_ROUTINE_PRIORITIES defines the number of priorities available
 * to the application co-routines. Any number of co-routines can share the same
 * priority. Defaults to 0 if left undefined. */
#define configMAX_CO_ROUTINE_PRIORITIES         ${FREERTOS_MAX_CO_ROUTINE_PRIORITIES}
<#if FREERTOS_USE_CONFIGASSERT == true>

/******************************************************************************/
/* Debugging assistance. ******************************************************/
/******************************************************************************/

/* configASSERT() has the same semantics as the standard C assert().  It can
 * either be defined to take an action when the assertion fails, or not defined
 * at all (i.e. comment out or delete the definitions) to completely remove
 * assertions.  configASSERT() can be defined to anything you want, for example
 * you can call a function if an assert fails that passes the filename and line
 * number of the failing assert (for example, "vAssertCalled( __FILE__, __LINE__ )"
 * or it can simple disable interrupts and sit in a loop to halt all execution
 * on the failing line for viewing in a debugger. */
    <#lt>/* Prevent C specific syntax being included in assembly files. */
    <#lt>#ifndef __LANGUAGE_ASSEMBLY
    <#lt>    void vAssertCalled( const char *pcFileName, unsigned long ulLine );
    <#lt>    #define configASSERT( x ) if( ( x ) == 0 ) vAssertCalled( __FILE__, __LINE__ )
    <#lt>#endif
</#if>

<#if core.CoreArchitecture == "CORTEX-M23" || core.CoreArchitecture == "CORTEX-M33">
<#if __TRUSTZONE_ENABLED?? && __TRUSTZONE_ENABLED == "true">
/******************************************************************************/
/* ARMv8-M secure side port related definitions. ******************************/
/******************************************************************************/

/* secureconfigMAX_SECURE_CONTEXTS define the maximum number of tasks that can
 *  call into the secure side of an ARMv8-M chip.  Not used by any other ports. */
#define secureconfigMAX_SECURE_CONTEXTS        ${FREERTOS_MAX_SECURE_CONTEXTS}

/* Defines the kernel provided implementation of
 * vApplicationGetIdleTaskMemory() and vApplicationGetTimerTaskMemory()
 * to provide the memory that is used by the Idle task and Timer task respectively.
 * The application can provide it's own implementation of
 * vApplicationGetIdleTaskMemory() and vApplicationGetTimerTaskMemory() by
 * setting configKERNEL_PROVIDED_STATIC_MEMORY to 0 or leaving it undefined. */
#define configKERNEL_PROVIDED_STATIC_MEMORY    <#if FREERTOS_KERNEL_PROVIDED_STATIC_MEMORY == true>1<#else>0</#if>

#define configMINIMAL_SECURE_STACK_SIZE        ((uint32_t) ${FREERTOS_MINIMAL_SECURE_STACK_SIZE})
  </#if>

/******************************************************************************/
/* ARMv8-M port Specific Configuration definitions. ***************************/
/******************************************************************************/

/* Set configENABLE_TRUSTZONE to 1 when running FreeRTOS on the non-secure side
 * to enable the TrustZone support in FreeRTOS ARMv8-M ports which allows the
 * non-secure FreeRTOS tasks to call the (non-secure callable) functions
 * exported from secure side. */
#define configENABLE_TRUSTZONE                  <#if FREERTOS_ENABLE_TRUSTZONE == true>1<#else>0</#if>

/* If the application writer does not want to use TrustZone, but the hardware does
 * not support disabling TrustZone then the entire application (including the FreeRTOS
 * scheduler) can run on the secure side without ever branching to the non-secure side.
 * To do that, in addition to setting configENABLE_TRUSTZONE to 0, also set
 * configRUN_FREERTOS_SECURE_ONLY to 1. */
#define configRUN_FREERTOS_SECURE_ONLY          <#if FREERTOS_RUN_FREERTOS_SECURE_ONLY == true>1<#else>0</#if>

/* Set configENABLE_MPU to 1 to enable the Memory Protection Unit (MPU), or 0
 * to leave the Memory Protection Unit disabled. */
#define configENABLE_MPU                        <#if FREERTOS_ENABLE_MPU == true>1<#else>0</#if>

/* Set configENABLE_FPU to 1 to enable the Floating Point Unit (FPU), or 0
 * to leave the Floating Point Unit disabled. */
#define configENABLE_FPU                        <#if FREERTOS_ENABLE_FPU == true>1<#else>0</#if>

/* Set configENABLE_MVE to 1 to enable the M-Profile Vector Extension (MVE) support,
 * or 0 to leave the MVE support disabled. This option is only applicable to Cortex-M55
 * and Cortex-M85 ports as M-Profile Vector Extension (MVE) is available only on
 * these architectures. configENABLE_MVE must be left undefined, or defined to 0
 * for the Cortex-M23,Cortex-M33 and Cortex-M35P ports. */
#define configENABLE_MVE                        <#if FREERTOS_ENABLE_MVE == true>1<#else>0</#if>
</#if>
<#if core.CoreArchitecture == "CORTEX-M0PLUS">
/* Set configENABLE_MPU to 1 to enable the Memory Protection Unit (MPU), or 0
 * to leave the Memory Protection Unit disabled. */
#define configENABLE_MPU                        <#if FREERTOS_ENABLE_MPU == true>1<#else>0</#if>
</#if>
<#if core.CoreArchitecture != "MIPS" && core.CoreArchitecture != "CORTEX-A5" && (core.CoreArchitecture?matches("ARM926.*") == false) && core.CoreArchitecture != "CORTEX-A7" && core.CoreArchitecture != "PIC32A" && core.CoreArchitecture != "dsPIC33A">

/******************************************************************************/
/* ARMv7-M and ARMv8-M port Specific Configuration definitions. ***************/
/******************************************************************************/

/* Set configCHECK_HANDLER_INSTALLATION to 1 to enable additional asserts to verify
 * that the application has correctly installed FreeRTOS interrupt handlers.
 *
 * An application can install FreeRTOS interrupt handlers in one of the following ways:
 *   1. Direct Routing  -  Install the functions vPortSVCHandler and xPortPendSVHandler
 *                         for SVC call and PendSV interrupts respectively.
 *   2. Indirect Routing - Install separate handlers for SVC call and PendSV
 *                         interrupts and route program control from those handlers
 *                         to vPortSVCHandler and xPortPendSVHandler functions.
 * The applications that use Indirect Routing must set configCHECK_HANDLER_INSTALLATION to 0.
 *
 * Defaults to 1 if left undefined. */
#define configCHECK_HANDLER_INSTALLATION    <#if FREERTOS_CHECK_HANDLER_INSTALLATION == true>1<#else>0</#if>
</#if>

/******************************************************************************/
/* Definitions that include or exclude functionality. *************************/
/******************************************************************************/

/* Set the following configUSE_* constants to 1 to include the named feature in
 * the build, or 0 to exclude the named feature from the build. */
#define configUSE_TASK_NOTIFICATIONS            <#if FREERTOS_USE_TASK_NOTIFICATIONS == true>1<#else>0</#if>
#define configUSE_MUTEXES                       <#if FREERTOS_USE_MUTEXES == true>1<#else>0</#if>
#define configUSE_RECURSIVE_MUTEXES             <#if FREERTOS_USE_RECURSIVE_MUTEXES == true>1<#else>0</#if>
#define configUSE_COUNTING_SEMAPHORES           <#if FREERTOS_USE_COUNTING_SEMAPHORES == true>1<#else>0</#if>
#define configUSE_QUEUE_SETS                    <#if FREERTOS_USE_QUEUE_SETS == true>1<#else>0</#if>
#define configUSE_APPLICATION_TASK_TAG          <#if FREERTOS_USE_APPLICATION_TASK_TAG == true>1<#else>0</#if>
<#if core.CoreArchitecture == "CORTEX-A7">
<#if FREERTOS_USE_TASK_FPU_SUPPORT == true>
#define configUSE_TASK_FPU_SUPPORT              1
</#if>
<#else>
#define configUSE_TASK_FPU_SUPPORT              <#if FREERTOS_USE_TASK_FPU_SUPPORT == true>1<#else>0</#if>
</#if>

<#if FREERTOS_MPU_PORT_ENABLE == true>
#define configUSE_MPU_WRAPPERS_V1                               <#if FREERTOS_USE_MPU_WRAPPERS_V1 == true>1<#else>0</#if>
/* FreeRTOS MPU specific definitions. */
#define configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS <#if FREERTOS_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS == true>1<#else>0</#if>
#define configTOTAL_MPU_REGIONS                                ${FREERTOS_TOTAL_MPU_REGIONS}
#define configTEX_S_C_B_FLASH                                  ${FREERTOS_TEX_S_C_B_FLASH}UL /* Default value. */
#define configTEX_S_C_B_SRAM                                   ${FREERTOS_TEX_S_C_B_SRAM}UL /* Default value. */
#define configENFORCE_SYSTEM_CALLS_FROM_KERNEL_ONLY            <#if FREERTOS_ENFORCE_SYSTEM_CALLS_FROM_KERNEL_ONLY == true>1<#else>0</#if>
#define configALLOW_UNPRIVILEGED_CRITICAL_SECTIONS             <#if FREERTOS_ALLOW_UNPRIVILEGED_CRITICAL_SECTIONS == true>1<#else>0</#if>
#define configENABLE_ERRATA_837070_WORKAROUND                  <#if FREERTOS_ERRATA_837070_WORKAROUND == true>1<#else>0</#if>
<#if FREERTOS_USE_MPU_WRAPPERS_V1 == false>
/* When using the v2 MPU wrapper, set configSYSTEM_CALL_STACK_SIZE to the size
 * of the system call stack in words. Each task has a statically allocated
 * memory buffer of this size which is used as the stack to execute system
 * calls. For example, if configSYSTEM_CALL_STACK_SIZE is defined as 128 and
 * there are 10 tasks in the application, the total amount of memory used for
 * system call stacks is 128 * 10 = 1280 words. */
#define configSYSTEM_CALL_STACK_SIZE                              ${FREERTOS_SYSTEM_CALL_STACK_SIZE}

/* When using the v2 MPU wrapper, set configPROTECTED_KERNEL_OBJECT_POOL_SIZE to
 * the total number of kernel objects, which includes tasks, queues, semaphores,
 * mutexes, event groups, timers, stream buffers and message buffers, in your
 * application. The application will not be able to have more than
 * configPROTECTED_KERNEL_OBJECT_POOL_SIZE kernel objects at any point of
 * time. */
#define configPROTECTED_KERNEL_OBJECT_POOL_SIZE                   ${FREERTOS_PROTECTED_KERNEL_OBJECT_POOL_SIZE}
</#if>
</#if>

/* Set the following INCLUDE_* constants to 1 to incldue the named API function,
 * or 0 to exclude the named API function.  Most linkers will remove unused
 * functions even when the constant is 1. */

/* Optional functions - most linkers will remove unused functions anyway. */
#define INCLUDE_vTaskPrioritySet                <#if FREERTOS_INCLUDE_VTASKPRIORITYSET == true>1<#else>0</#if>
#define INCLUDE_uxTaskPriorityGet               <#if FREERTOS_INCLUDE_UXTASKPRIORITYGET == true>1<#else>0</#if>
#define INCLUDE_vTaskDelete                     <#if FREERTOS_INCLUDE_VTASKDELETE == true>1<#else>0</#if>
#define INCLUDE_vTaskSuspend                    <#if FREERTOS_INCLUDE_VTASKSUSPEND == true>1<#else>0</#if>
#define INCLUDE_xResumeFromISR                  <#if FREERTOS_INCLUDE_XRESUMEFROMISR == true>1<#else>0</#if>
#define INCLUDE_vTaskDelayUntil                 <#if FREERTOS_INCLUDE_VTASKDELAYUNTIL == true>1<#else>0</#if>
#define INCLUDE_vTaskDelay                      <#if FREERTOS_INCLUDE_VTASKDELAY == true>1<#else>0</#if>
#define INCLUDE_xTaskGetSchedulerState          <#if FREERTOS_INCLUDE_XTASKGETSCHEDULERSTATE == true>1<#else>0</#if>
#define INCLUDE_xTaskGetCurrentTaskHandle       <#if FREERTOS_INCLUDE_XTASKGETCURRENTTASKHANDLE == true>1<#else>0</#if>
#define INCLUDE_uxTaskGetStackHighWaterMark     <#if FREERTOS_INCLUDE_UXTASKGETSTACKHIGHWATERMARK == true>1<#else>0</#if>
#define INCLUDE_xTaskGetIdleTaskHandle          <#if FREERTOS_INCLUDE_XTASKGETIDLETASKHANDLE == true>1<#else>0</#if>
#define INCLUDE_eTaskGetState                   <#if FREERTOS_INCLUDE_ETASKGETSTATE == true>1<#else>0</#if>
#define INCLUDE_xEventGroupSetBitFromISR        <#if FREERTOS_INCLUDE_XEVENTGROUPSETBITFROMISR == true>1<#else>0</#if>
#define INCLUDE_xTimerPendFunctionCall          <#if FREERTOS_INCLUDE_XTIMERPENDFUNCTIONCALL == true>1<#else>0</#if>
#define INCLUDE_xTaskAbortDelay                 <#if FREERTOS_INCLUDE_XTASKABORTDELAY == true>1<#else>0</#if>
#define INCLUDE_xTaskGetHandle                  <#if FREERTOS_INCLUDE_XTASKGETHANDLE == true>1<#else>0</#if>
#define INCLUDE_xQueueGetMutexHolder            <#if FREERTOS_INCLUDE_XQUEUEGETMUTEXHOLDER == true>1<#else>0</#if>
#define INCLUDE_xSemaphoreGetMutexHolder        <#if FREERTOS_INCLUDE_XSEMAPHOREGETMUTEXHOLDER == true>1<#else>0</#if>
#define INCLUDE_uxTaskGetStackHighWaterMark2    <#if FREERTOS_INCLUDE_UXTASKGETSTACKHIGHWATERMARK2 == true>1<#else>0</#if>
#define INCLUDE_xTaskResumeFromISR              <#if FREERTOS_INCLUDE_XTASKRESUMEFROMISR == true>1<#else>0</#if>

<#if core.CoreArchitecture == "PIC32A" || core.CoreArchitecture == "dsPIC33A">
#define taskYIELD()    portYIELD_WITHIN_API()
</#if>
<#if FREERTOS_CONFIG_INTERRUPT_CONTROLLER_BASE_ADDRESS??>
    <#lt>#define configINTERRUPT_CONTROLLER_BASE_ADDRESS         ${FREERTOS_CONFIG_INTERRUPT_CONTROLLER_BASE_ADDRESS}
</#if>
<#if FREERTOS_CONFIG_INTERRUPT_CONTROLLER_CPU_INTERFACE_OFFSET??>
    <#lt>#define configINTERRUPT_CONTROLLER_CPU_INTERFACE_OFFSET ${FREERTOS_CONFIG_INTERRUPT_CONTROLLER_CPU_INTERFACE_OFFSET}
</#if>
<#if FREERTOS_CONFIG_UNIQUE_INTERRUPT_PRIORITIES??>
    <#lt>#define configUNIQUE_INTERRUPT_PRIORITIES               ${FREERTOS_CONFIG_UNIQUE_INTERRUPT_PRIORITIES}
</#if>

<#if FREERTOS_SETUP_TICK_INTERRUPT??>
    <#if core.COMPILER_CHOICE == "IAR">
        <#lt>#ifdef __ICCARM__
        <#lt>void ${FREERTOS_SETUP_TICK_INTERRUPT}(void);
        <#lt>#endif //__ICCARM__
    <#elseif core.COMPILER_CHOICE == "XC32">
        <#lt>void ${FREERTOS_SETUP_TICK_INTERRUPT}(void);
    </#if>
    <#lt>#define configSETUP_TICK_INTERRUPT ${FREERTOS_SETUP_TICK_INTERRUPT}
</#if>
<#if FREERTOS_EOI_ADDRESS??>
    <#lt>#define configEOI_ADDRESS ${FREERTOS_EOI_ADDRESS}
</#if>
<#if FREERTOS_CONFIG_TICK_INTERRUPT??>
    <#if core.COMPILER_CHOICE == "IAR">
        <#lt>#ifdef __ICCARM__
        <#lt>void ${FREERTOS_CONFIG_TICK_INTERRUPT}(void);
        <#lt>#endif //__ICCARM__
    <#elseif core.COMPILER_CHOICE == "XC32">
        <#lt>void ${FREERTOS_CONFIG_TICK_INTERRUPT}(void);
    </#if>
    <#lt>#define configCLEAR_TICK_INTERRUPT ${FREERTOS_CONFIG_TICK_INTERRUPT}
</#if>

<#if FREERTOS_USE_TRACE_FACILITY == true && FREERTOS_TRACE_MALLOC_FNC?has_content>
#define traceMALLOC( pvAddress, uiSize )      ${FREERTOS_TRACE_MALLOC_FNC}( pvAddress, uiSize )
<#if core.COMPILER_CHOICE == "XC32">
#ifndef __LANGUAGE_ASSEMBLY__
<#elseif core.COMPILER_CHOICE == "IAR">
#ifdef __ICCARM__
</#if>
void ${FREERTOS_TRACE_MALLOC_FNC}(void *pAddr, size_t size);
#endif
</#if>
<#if FREERTOS_USE_TRACE_FACILITY == true && FREERTOS_TRACE_FREE_FNC?has_content>
#define traceFREE( pvAddress, uiSize )        ${FREERTOS_TRACE_FREE_FNC}( pvAddress, uiSize )
<#if core.COMPILER_CHOICE == "XC32">
#ifndef __LANGUAGE_ASSEMBLY__
<#elseif core.COMPILER_CHOICE == "IAR">
#ifdef __ICCARM__
</#if>
void ${FREERTOS_TRACE_FREE_FNC}(void *pAddr, size_t size);
#endif
</#if>
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 3.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 5.4"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */
#endif /* FREERTOS_CONFIG_H */
