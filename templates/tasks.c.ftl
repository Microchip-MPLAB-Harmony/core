/*******************************************************************************
 System Tasks File

  File Name:
    tasks.c

  Summary:
    This file contains source code necessary to maintain system's polled tasks.

  Description:
    This file contains source code necessary to maintain system's polled tasks.
    It implements the "SYS_Tasks" function that calls the individual "Tasks"
    functions for all polled MPLAB Harmony modules in the system.

  Remarks:
    This file requires access to the systemObjects global data structure that
    contains the object handles to all MPLAB Harmony module objects executing
    polled in the system.  These handles are passed into the individual module
    "Tasks" functions to identify the instance of the module to maintain.
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

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

<#if ENABLE_DRV_COMMON == true ||
     ENABLE_SYS_COMMON == true ||
     ENABLE_APP_FILE == true >
    <#lt>#include "configuration.h"
</#if>
#include "definitions.h"
#include "sys_tasks.h"
<#if SELECT_RTOS == "MbedOS">
#include "mbed.h"
#include "platform/mbed_thread.h"
</#if>

<#if SELECT_RTOS == "ThreadX">
    <#lt>/* ThreadX byte memory pool from which to allocate the thread stacks. */
    <#lt>#define TX_BYTE_POOL_SIZE   (${ThreadX.THREADX_TX_BYTE_POOL_SIZE} + 512)

    <#lt>TX_BYTE_POOL   byte_pool_0;
</#if>

<#if SELECT_RTOS != "BareMetal">
    <#lt>// *****************************************************************************
    <#lt>// *****************************************************************************
    <#lt>// Section: RTOS "Tasks" Routine
    <#lt>// *****************************************************************************
    <#lt>// *****************************************************************************
    <#lt>${core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS}
</#if>

<#if SELECT_RTOS == "ThreadX">
    <#lt>void tx_application_define(void* first_unused_memory)
    <#lt>{
    <#lt>    /* Create a byte memory pool from which to allocate the thread stacks. */
    <#lt>    tx_byte_pool_create(&byte_pool_0, "byte pool 0", first_unused_memory, TX_BYTE_POOL_SIZE);

    <#lt>    /* Maintain system services */
    <#lt>    ${core.LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS}

    <#lt>    /* Maintain Device Drivers */
    <#lt>    ${core.LIST_SYSTEM_TASKS_C_CALL_DRIVER_TASKS}

    <#lt>    /* Maintain Middleware & Other Libraries */
    <#lt>    ${core.LIST_SYSTEM_TASKS_C_CALL_LIB_TASKS}

    <#if ENABLE_APP_FILE == true >
        <#lt>    /* Maintain the application's state machine. */
        <#lt>    ${core.LIST_SYSTEM_RTOS_TASKS_C_GEN_APP}
    </#if>
    <#if sys_fs.SYS_FS_FILEX && sys_fs.SYS_FS_FILEX_FX_STANDALONE_ENABLE == false>

    <#lt>    /* Initialize the FileX File System. */
    <#lt>    fx_system_initialize();
    </#if>
    <#lt>}
<#elseif SELECT_RTOS == "MbedOS">
    <#lt>void mbed_start(void)
    <#lt>{
    <#lt>    /* Create and Initialize a Singleton Mutex object */
    <#lt>    mbed_rtos_init_singleton_mutex();

    <#lt>    /* Maintain system services */
    <#lt>    ${core.LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS}

    <#lt>    /* Maintain Device Drivers */
    <#lt>    ${core.LIST_SYSTEM_TASKS_C_CALL_DRIVER_TASKS}

    <#lt>    /* Maintain Middleware & Other Libraries */
    <#lt>    ${core.LIST_SYSTEM_TASKS_C_CALL_LIB_TASKS}

    <#if ENABLE_APP_FILE == true >
        <#lt>    /* Maintain the application's state machine. */
        <#lt>    ${core.LIST_SYSTEM_RTOS_TASKS_C_GEN_APP}
    </#if>
    <#lt>    while(true)
    <#lt>    {
    <#lt>    }
    <#lt>}
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: System "Tasks" Routine
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void SYS_Tasks ( void )

  Remarks:
    See prototype in system/common/sys_module.h.
*/
<#if SELECT_RTOS == "ThreadX" || SELECT_RTOS == "MbedOS">
    <#lt>void SYS_Tasks ( void )
    <#lt>{
    <#lt>    ${core.LIST_SYSTEM_RTOS_TASKS_C_CALL_SCHEDULAR}
    <#lt>}
<#else>
    <#lt>void SYS_Tasks ( void )
    <#lt>{
    <#if SELECT_RTOS == "MicriumOSIII">
        <#lt>    OS_ERR os_err;
    </#if>
    <#lt>    /* Maintain system services */
    <#lt>    ${core.LIST_SYSTEM_TASKS_C_CALL_SYSTEM_TASKS}

    <#lt>    /* Maintain Device Drivers */
    <#lt>    ${core.LIST_SYSTEM_TASKS_C_CALL_DRIVER_TASKS}

    <#lt>    /* Maintain Middleware & Other Libraries */
    <#lt>    ${core.LIST_SYSTEM_TASKS_C_CALL_LIB_TASKS}

    <#if ENABLE_APP_FILE == true >
        <#lt>    /* Maintain the application's state machine. */
        <#if SELECT_RTOS == "BareMetal">
            <#lt>    ${core.LIST_SYSTEM_TASKS_C_GEN_APP}
        <#else>
            <#lt>    ${core.LIST_SYSTEM_RTOS_TASKS_C_GEN_APP}
        </#if>
    </#if>

    <#if SELECT_RTOS != "BareMetal">
        <#lt>    /* Start RTOS Scheduler. */
        <#lt>    ${core.LIST_SYSTEM_RTOS_TASKS_C_CALL_SCHEDULAR}
    </#if>
    <#lt>}
</#if>

/*******************************************************************************
 End of File
 */

