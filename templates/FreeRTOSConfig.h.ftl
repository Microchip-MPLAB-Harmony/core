
#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

/* MISRA C-2012 Rule 3.1, 5.4 deviated below. Deviation record ID -
   H3_MISRAC_2012_R_3_1_DR_1 & H3_MISRAC_2012_R_5_4_DR_1*/
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
 * FreeRTOS Kernel V10.4.0
 * Copyright (C) 2019 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
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
 * http://www.FreeRTOS.org
 * http://aws.amazon.com/freertos
 *
 * 1 tab == 4 spaces!
 */

/*-----------------------------------------------------------
 * Application specific definitions.
 *
 * These definitions should be adjusted for your particular hardware and
 * application requirements.
 *
 * THESE PARAMETERS ARE DESCRIBED WITHIN THE 'CONFIGURATION' SECTION OF THE
 * FreeRTOS API DOCUMENTATION AVAILABLE ON THE FreeRTOS.org WEB SITE.
 *
 * See http://www.freertos.org/a00110.html
 *----------------------------------------------------------*/
#define configUSE_PREEMPTION                    <#if FREERTOS_SCHEDULER == "Preemptive">1<#else>0</#if>
#define configUSE_PORT_OPTIMISED_TASK_SELECTION <#if FREERTOS_TASK_SELECTION == "Port_Optimized">1<#else>0</#if>
#define configUSE_TICKLESS_IDLE                 <#if FREERTOS_TICKLESS_IDLE_CHOICE == "Tickless_Idle">1<#else>0</#if>
<#if FREERTOS_TICKLESS_IDLE_CHOICE == "Tickless_Idle">
    <#lt>#define configEXPECTED_IDLE_TIME_BEFORE_SLEEP   ${FREERTOS_EXPECTED_IDLE_TIME_BEFORE_SLEEP}
</#if>
<#if core.CoreArchitecture != "MIPS">
#define configCPU_CLOCK_HZ                      ( ${FREERTOS_CPU_CLOCK_HZ?number?c}UL )
</#if>
#define configTICK_RATE_HZ                      ( ( TickType_t ) ${FREERTOS_TICK_RATE_HZ} )
#define configMAX_PRIORITIES                    ( ${FREERTOS_MAX_PRIORITIES}UL )
#define configMINIMAL_STACK_SIZE                ( ${FREERTOS_MINIMAL_STACK_SIZE} )
#define configSUPPORT_DYNAMIC_ALLOCATION        <#if FREERTOS_DYNAMIC_ALLOC == true>1<#else>0</#if>
#define configSUPPORT_STATIC_ALLOCATION         <#if FREERTOS_STATIC_ALLOC == true>1<#else>0</#if>
#define configTOTAL_HEAP_SIZE                   ( ( size_t ) ${FREERTOS_TOTAL_HEAP_SIZE} )
#define configMAX_TASK_NAME_LEN                 ( ${FREERTOS_MAX_TASK_NAME_LEN} )
#define configUSE_16_BIT_TICKS                  <#if FREERTOS_USE_16_BIT_TICKS == true>1<#else>0</#if>
<#if FREERTOS_SCHEDULER == "Preemptive">
    <#lt>#define configIDLE_SHOULD_YIELD                 <#if FREERTOS_IDLE_SHOULD_YIELD == true>1<#else>0</#if>
</#if>
#define configUSE_MUTEXES                       <#if FREERTOS_USE_MUTEXES == true>1<#else>0</#if>
#define configUSE_RECURSIVE_MUTEXES             <#if FREERTOS_USE_RECURSIVE_MUTEXES == true>1<#else>0</#if>
#define configUSE_COUNTING_SEMAPHORES           <#if FREERTOS_USE_COUNTING_SEMAPHORES == true>1<#else>0</#if>
#define configUSE_TASK_NOTIFICATIONS            <#if FREERTOS_USE_TASK_NOTIFICATIONS == true>1<#else>0</#if>
#define configQUEUE_REGISTRY_SIZE               ${FREERTOS_QUEUE_REGISTRY_SIZE}
#define configUSE_QUEUE_SETS                    <#if FREERTOS_USE_QUEUE_SETS == true>1<#else>0</#if>
#define configUSE_TIME_SLICING                  <#if FREERTOS_USE_TIME_SLICING == true>1<#else>0</#if>
#define configUSE_NEWLIB_REENTRANT              <#if FREERTOS_USE_NEWLIB_REENTRANT == true>1<#else>0</#if>
<#if core.CoreArchitecture == "CORTEX-A7">
<#if FREERTOS_USE_TASK_FPU_SUPPORT == true>
#define configUSE_TASK_FPU_SUPPORT              1
</#if>
<#else>
#define configUSE_TASK_FPU_SUPPORT              <#if FREERTOS_USE_TASK_FPU_SUPPORT == true>1<#else>0</#if>
</#if>

<#if core.CoreArchitecture == "CORTEX-M23" || core.CoreArchitecture == "CORTEX-M33">
#define configENABLE_FPU                        <#if FREERTOS_ENABLE_FPU == true>1<#else>0</#if>
#define configENABLE_TRUSTZONE                  <#if FREERTOS_ENABLE_TRUSTZONE == true>1<#else>0</#if>
#define configENABLE_MPU                        <#if FREERTOS_ENABLE_MPU == true>1<#else>0</#if>
#define configENABLE_MVE                        <#if FREERTOS_ENABLE_MVE == true>1<#else>0</#if>
#define configRUN_FREERTOS_SECURE_ONLY          <#if FREERTOS_RUN_FREERTOS_SECURE_ONLY == true>1<#else>0</#if>
<#if __TRUSTZONE_ENABLED?? && __TRUSTZONE_ENABLED == "true">
#define configMINIMAL_SECURE_STACK_SIZE         ( (uint32_t) ${FREERTOS_MINIMAL_SECURE_STACK_SIZE} )
</#if>
</#if>

/* Hook function related definitions. */
#define configUSE_IDLE_HOOK                     <#if FREERTOS_IDLE_HOOK == true>1<#else>0</#if>
#define configUSE_TICK_HOOK                     <#if FREERTOS_TICK_HOOK == true>1<#else>0</#if>
#define configCHECK_FOR_STACK_OVERFLOW          <#if FREERTOS_CHECK_FOR_STACK_OVERFLOW == "No_Check">0<#else><#if FREERTOS_CHECK_FOR_STACK_OVERFLOW == "Method_1">1<#else>2</#if></#if>
#define configUSE_MALLOC_FAILED_HOOK            <#if FREERTOS_USE_MALLOC_FAILED_HOOK == true>1<#else>0</#if>

/* Run time and task stats gathering related definitions. */
#define configGENERATE_RUN_TIME_STATS           <#if FREERTOS_GENERATE_RUN_TIME_STATS == true>1<#else>0</#if>
#define configUSE_TRACE_FACILITY                <#if FREERTOS_USE_TRACE_FACILITY == true>1<#else>0</#if>
#define configUSE_STATS_FORMATTING_FUNCTIONS    <#if FREERTOS_USE_STATS_FORMATTING_FUNCTIONS == true>1<#else>0</#if>

/* Co-routine related definitions. */
#define configUSE_CO_ROUTINES                   <#if FREERTOS_USE_CO_ROUTINES == true>1<#else>0</#if>
#define configMAX_CO_ROUTINE_PRIORITIES         ${FREERTOS_MAX_CO_ROUTINE_PRIORITIES}

/* Software timer related definitions. */
#define configUSE_TIMERS                        <#if FREERTOS_USE_TIMERS == true>1<#else>0</#if>
#define configTIMER_TASK_PRIORITY               ${FREERTOS_TIMER_TASK_PRIORITY}
#define configTIMER_QUEUE_LENGTH                ${FREERTOS_TIMER_QUEUE_LENGTH}
#define configTIMER_TASK_STACK_DEPTH            ${FREERTOS_TIMER_TASK_STACK_DEPTH}
#define configUSE_DAEMON_TASK_STARTUP_HOOK      <#if FREERTOS_DAEMON_TASK_STARTUP_HOOK == true>1<#else>0</#if>

/* Misc */
#define configUSE_APPLICATION_TASK_TAG          <#if FREERTOS_USE_APPLICATION_TASK_TAG == true>1<#else>0</#if>

<#if FREERTOS_USE_CONFIGASSERT == true>
    <#lt>/* Prevent C specific syntax being included in assembly files. */
    <#lt>#ifndef __LANGUAGE_ASSEMBLY
    <#lt>    void vAssertCalled( const char *pcFileName, unsigned long ulLine );
    <#lt>    #define configASSERT( x ) if( ( x ) == 0 ) vAssertCalled( __FILE__, __LINE__ )
    <#lt>#endif
</#if>

/* Interrupt nesting behaviour configuration. */
<#if core.CoreArchitecture != "MIPS">
  <#if core.CoreArchitecture != "CORTEX-A5" && (core.CoreArchitecture?matches("ARM926.*") == false) && core.CoreArchitecture != "CORTEX-A7">
    <#lt>/* The priority at which the tick interrupt runs.  This should probably be kept at lowest priority. */
    <#lt>#define configKERNEL_INTERRUPT_PRIORITY         (${FREERTOS_KERNEL_INTERRUPT_PRIORITY} << (8 - ${FREERTOS_CONFIG_PRIORITY_BITS}))
    <#lt>
    <#lt>/* The maximum interrupt priority from which FreeRTOS.org API functions can be called.
    <#lt> * Only API functions that end in ...FromISR() can be used within interrupts. */
    <#lt>#define configMAX_SYSCALL_INTERRUPT_PRIORITY    (${FREERTOS_MAX_SYSCALL_INTERRUPT_PRIORITY} << (8 - ${FREERTOS_CONFIG_PRIORITY_BITS}))
  </#if>
<#else>
    <#lt>#define configPERIPHERAL_CLOCK_HZ               ( ${FREERTOS_PERIPHERAL_CLOCK_HZ?number?c}UL )
    <#lt>#define configISR_STACK_SIZE                    ( ${FREERTOS_ISR_STACK_SIZE} )
    <#lt>/* The priority at which the tick interrupt runs.  This should probably be kept at lowest priority. */
    <#lt>#define configKERNEL_INTERRUPT_PRIORITY         (${FREERTOS_KERNEL_INTERRUPT_PRIORITY})
    <#lt>
    <#lt>/* The maximum interrupt priority from which FreeRTOS.org API functions can be called.
    <#lt> *Only API functions that end in ...FromISR() can be used within interrupts. */
    <#lt>#define configMAX_SYSCALL_INTERRUPT_PRIORITY    (${FREERTOS_MAX_SYSCALL_INTERRUPT_PRIORITY})
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
<#if FREERTOS_CONFIG_MAX_API_CALL_INTERRUPT_PRIORITY??>
    <#lt>#define configMAX_API_CALL_INTERRUPT_PRIORITY           ${FREERTOS_CONFIG_MAX_API_CALL_INTERRUPT_PRIORITY}
</#if>


<#if FREERTOS_MPU_PORT_ENABLE == true>
/* FreeRTOS MPU specific definitions. */
#define configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS <#if FREERTOS_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS == true>1<#else>0</#if>
#define configTOTAL_MPU_REGIONS                                ${FREERTOS_TOTAL_MPU_REGIONS}
#define configTEX_S_C_B_FLASH                                  ${FREERTOS_TEX_S_C_B_FLASH}UL /* Default value. */
#define configTEX_S_C_B_SRAM                                   ${FREERTOS_TEX_S_C_B_SRAM}UL /* Default value. */
#define configENFORCE_SYSTEM_CALLS_FROM_KERNEL_ONLY            <#if FREERTOS_ENFORCE_SYSTEM_CALLS_FROM_KERNEL_ONLY == true>1<#else>0</#if>
#define configALLOW_UNPRIVILEGED_CRITICAL_SECTIONS             <#if FREERTOS_ALLOW_UNPRIVILEGED_CRITICAL_SECTIONS == true>1<#else>0</#if>
#define configENABLE_ERRATA_837070_WORKAROUND                  <#if FREERTOS_ERRATA_837070_WORKAROUND == true>1<#else>0</#if>
</#if>

/* Optional functions - most linkers will remove unused functions anyway. */
#define INCLUDE_vTaskPrioritySet                <#if FREERTOS_INCLUDE_VTASKPRIORITYSET == true>1<#else>0</#if>
#define INCLUDE_uxTaskPriorityGet               <#if FREERTOS_INCLUDE_UXTASKPRIORITYGET == true>1<#else>0</#if>
#define INCLUDE_vTaskDelete                     <#if FREERTOS_INCLUDE_VTASKDELETE == true>1<#else>0</#if>
#define INCLUDE_vTaskSuspend                    <#if FREERTOS_INCLUDE_VTASKSUSPEND == true>1<#else>0</#if>
#define INCLUDE_vTaskDelayUntil                 <#if FREERTOS_INCLUDE_VTASKDELAYUNTIL == true>1<#else>0</#if>
#define INCLUDE_vTaskDelay                      <#if FREERTOS_INCLUDE_VTASKDELAY == true>1<#else>0</#if>
#define INCLUDE_xTaskGetSchedulerState          <#if FREERTOS_INCLUDE_XTASKGETSCHEDULERSTATE == true>1<#else>0</#if>
#define INCLUDE_xTaskGetCurrentTaskHandle       <#if FREERTOS_INCLUDE_XTASKGETCURRENTTASKHANDLE == true>1<#else>0</#if>
#define INCLUDE_uxTaskGetStackHighWaterMark     <#if FREERTOS_INCLUDE_UXTASKGETSTACKHIGHWATERMARK == true>1<#else>0</#if>
#define INCLUDE_xTaskGetIdleTaskHandle          <#if FREERTOS_INCLUDE_XTASKGETIDLETASKHANDLE == true>1<#else>0</#if>
#define INCLUDE_eTaskGetState                   <#if FREERTOS_INCLUDE_ETASKGETSTATE == true>1<#else>0</#if>
#define INCLUDE_xTimerPendFunctionCall          <#if FREERTOS_INCLUDE_XTIMERPENDFUNCTIONCALL == true>1<#else>0</#if>
#define INCLUDE_xTaskAbortDelay                 <#if FREERTOS_INCLUDE_XTASKABORTDELAY == true>1<#else>0</#if>
#define INCLUDE_xTaskGetHandle                  <#if FREERTOS_INCLUDE_XTASKGETHANDLE == true>1<#else>0</#if>
#define INCLUDE_xQueueGetMutexHolder            <#if FREERTOS_INCLUDE_XQUEUEGETMUTEXHOLDER == true>1<#else>0</#if>
#define INCLUDE_xSemaphoreGetMutexHolder        <#if FREERTOS_INCLUDE_XSEMAPHOREGETMUTEXHOLDER == true>1<#else>0</#if>
#define INCLUDE_uxTaskGetStackHighWaterMark2    <#if FREERTOS_INCLUDE_UXTASKGETSTACKHIGHWATERMARK2 == true>1<#else>0</#if>
#define INCLUDE_xTaskResumeFromISR              <#if FREERTOS_INCLUDE_XTASKRESUMEFROMISR == true>1<#else>0</#if>

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
