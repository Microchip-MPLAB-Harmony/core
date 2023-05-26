/*******************************************************************************
 System Tasks File

  File Name:
    freertos_hooks.c

  Summary:
    This file contains source code necessary for FreeRTOS hooks

  Description:

  Remarks:
 *******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
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
 *******************************************************************************/
// DOM-IGNORE-END
#include "FreeRTOS.h"
#include "task.h"

void vApplicationIdleHook( void );
void vApplicationTickHook( void );
void vAssertCalled( const char * pcFile, unsigned long ulLine );

<#if core.CoreArchitecture == "MIPS">
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:1 "MISRA C-2012 Rule 12.2" "H3_MISRAC_2012_R_12_2_DR_1"
</#if>
</#if>
/*
*********************************************************************************************************
*                                          vApplicationStackOverflowHook()
*
* Description : Hook function called by FreeRTOS if a stack overflow happens.
*
* Argument(s) : none
*
* Return(s)   : none
*
* Caller(s)   : APP_StateReset()
*
* Note(s)     : none.
*********************************************************************************************************
*/
void vApplicationStackOverflowHook( TaskHandle_t xTask, char *pcTaskName )
{
   ( void ) pcTaskName;
   ( void ) xTask;

   /* Run time task stack overflow checking is performed if
   configCHECK_FOR_STACK_OVERFLOW is defined to 1 or 2.  This hook  function is
   called if a task stack overflow is detected.  Note the system/interrupt
   stack is not checked. */
   ${(core.CoreArchitecture?matches("CORTEX-(M33|A7)"))?string("(void)", "")}taskDISABLE_INTERRUPTS();
   for( ;; )
   {
       /* Do Nothing */
   }
}

/*
*********************************************************************************************************
*                                     vApplicationMallocFailedHook()
*
* Description : vApplicationMallocFailedHook() will only be called if
*               configUSE_MALLOC_FAILED_HOOK is set to 1 in FreeRTOSConfig.h.
*               It is a hook function that will get called if a call to
*               pvPortMalloc() fails.  pvPortMalloc() is called internally by
*               the kernel whenever a task, queue, timer or semaphore is
*               created.  It is also called by various parts of the demo
*               application.  If heap_1.c or heap_2.c are used, then the size of
*               the heap available to pvPortMalloc() is defined by
*               configTOTAL_HEAP_SIZE in FreeRTOSConfig.h, and the
*               xPortGetFreeHeapSize() API function can be used to query the
*               size of free heap space that remains (although it does not
*               provide information on how the remaining heap might be
*               fragmented).
*
* Argument(s) : none
*
* Return(s)   : none
*
* Caller(s)   : APP_StateReset()
*
* Note(s)     : none.
*********************************************************************************************************
*/
void vApplicationMallocFailedHook( void )
{
   /* vApplicationMallocFailedHook() will only be called if
      configUSE_MALLOC_FAILED_HOOK is set to 1 in FreeRTOSConfig.h.  It is a hook
      function that will get called if a call to pvPortMalloc() fails.
      pvPortMalloc() is called internally by the kernel whenever a task, queue,
      timer or semaphore is created.  It is also called by various parts of the
      demo application.  If heap_1.c or heap_2.c are used, then the size of the
      heap available to pvPortMalloc() is defined by configTOTAL_HEAP_SIZE in
      FreeRTOSConfig.h, and the xPortGetFreeHeapSize() API function can be used
      to query the size of free heap space that remains (although it does not
      provide information on how the remaining heap might be fragmented). */

   ${(core.CoreArchitecture?matches("CORTEX-(M33|A7)"))?string("(void)", "")}taskDISABLE_INTERRUPTS();
   for( ;; )
   {
       /* Do Nothing */
   }
}
<#if core.CoreArchitecture == "MIPS">
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 12.2"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
</#if>
/*-----------------------------------------------------------*/

void vApplicationIdleHook( void )
{
    /* vApplicationIdleHook() will only be called if configUSE_IDLE_HOOK is set
    to 1 in FreeRTOSConfig.h.  It will be called on each iteration of the idle
    task.  It is essential that code added to this hook function never attempts
    to block in any way (for example, call xQueueReceive() with a block time
    specified, or call vTaskDelay()).  If the application makes use of the
    vTaskDelete() API function  then it is also
    important that vApplicationIdleHook() is permitted to return to its calling
    function, because it is the responsibility of the idle task to clean up
    memory allocated by the kernel to any task that has since been deleted. */
}

/*-----------------------------------------------------------*/

/*-----------------------------------------------------------*/

void vApplicationTickHook( void )
{
    /* This function will be called by each tick interrupt if
    configUSE_TICK_HOOK is set to 1 in FreeRTOSConfig.h.  User code can be
    added here, but the tick hook is called from an interrupt context, so
    code must not attempt to block, and only the interrupt safe FreeRTOS API
    functions can be used (those that end in FromISR()). */
}

/*-----------------------------------------------------------*/

/*-----------------------------------------------------------*/

/* Error Handler */
void vAssertCalled( const char * pcFile, unsigned long ulLine )
{
   volatile unsigned long ul = 0;

   ( void ) pcFile;
   ( void ) ulLine;

   taskENTER_CRITICAL();
   {
      /* Set ul to a non-zero value using the debugger to step out of this
         function. */
      while( ul == 0U )
      {
         portNOP();
      }
   }
   taskEXIT_CRITICAL();
}
/*-----------------------------------------------------------*/

<#if FREERTOS_USE_TRACE_FACILITY == true && FREERTOS_TRACE_MALLOC_FNC?has_content>
/*-----------------------------------------------------------*/
/* Malloc trace function */
void ${FREERTOS_TRACE_MALLOC_FNC}(void *pAddr, size_t size)
{
    ( void ) pAddr;
    ( void ) size;
}
/*-----------------------------------------------------------*/
</#if>

<#if FREERTOS_USE_TRACE_FACILITY == true && FREERTOS_TRACE_FREE_FNC?has_content>
/*-----------------------------------------------------------*/
/* Free trace function */
void ${FREERTOS_TRACE_FREE_FNC}(void *pAddr, size_t size)
{
    ( void ) pAddr;
    ( void ) size;
}
/*-----------------------------------------------------------*/
</#if>
/*******************************************************************************
 End of File
 */
