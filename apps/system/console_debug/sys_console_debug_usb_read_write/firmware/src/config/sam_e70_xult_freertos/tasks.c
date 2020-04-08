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

#include "configuration.h"
#include "definitions.h"


// *****************************************************************************
// *****************************************************************************
// Section: RTOS "Tasks" Routine
// *****************************************************************************
// *****************************************************************************
void _SYS_CONSOLE_1_Tasks(  void *pvParameters  )
{
    while(1)
    {
        SYS_CONSOLE_Tasks(SYS_CONSOLE_INDEX_1);
        vTaskDelay(10 / portTICK_PERIOD_MS);
    }
}


void _USB_DEVICE_Tasks(  void *pvParameters  )
{
    while(1)
    {
				 /* USB Device layer tasks routine */
        USB_DEVICE_Tasks(sysObj.usbDevObject0);
        vTaskDelay(10 / portTICK_PERIOD_MS);
    }
}

void _DRV_USBHSV1_Tasks(  void *pvParameters  )
{
    while(1)
    {
				 /* USB HS Driver Task Routine */
        DRV_USBHSV1_Tasks(sysObj.drvUSBHSV1Object);
        vTaskDelay(10 / portTICK_PERIOD_MS);
    }
}

void _SYS_CONSOLE_0_Tasks(  void *pvParameters  )
{
    while(1)
    {
        SYS_CONSOLE_Tasks(SYS_CONSOLE_INDEX_0);
        vTaskDelay(10 / portTICK_PERIOD_MS);
    }
}


/* Handle for the APP_Tasks. */
TaskHandle_t xAPP_Tasks;

void _APP_Tasks(  void *pvParameters  )
{
    while(1)
    {
        APP_Tasks();
    }
}




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
void SYS_Tasks ( void )
{
    /* Maintain system services */
        xTaskCreate( _SYS_CONSOLE_1_Tasks,
        "SYS_CONSOLE_1_TASKS",
        SYS_CONSOLE_RTOS_STACK_SIZE_IDX1,
        (void*)NULL,
        SYS_CONSOLE_RTOS_TASK_PRIORITY_IDX1,
        (TaskHandle_t*)NULL
    );

    xTaskCreate( _SYS_CONSOLE_0_Tasks,
        "SYS_CONSOLE_0_TASKS",
        SYS_CONSOLE_RTOS_STACK_SIZE_IDX0,
        (void*)NULL,
        SYS_CONSOLE_RTOS_TASK_PRIORITY_IDX0,
        (TaskHandle_t*)NULL
    );



    /* Maintain Device Drivers */
    

    /* Maintain Middleware & Other Libraries */
        /* Create OS Thread for USB_DEVICE_Tasks. */
    xTaskCreate( _USB_DEVICE_Tasks,
        "USB_DEVICE_TASKS",
        1024,
        (void*)NULL,
        1,
        (TaskHandle_t*)NULL
    );

	/* Create OS Thread for USB Driver Tasks. */
    xTaskCreate( _DRV_USBHSV1_Tasks,
        "DRV_USBHSV1_TASKS",
        1024,
        (void*)NULL,
        1,
        (TaskHandle_t*)NULL
    );



    /* Maintain the application's state machine. */
        /* Create OS Thread for APP_Tasks. */
    xTaskCreate((TaskFunction_t) _APP_Tasks,
                "APP_Tasks",
                1024,
                NULL,
                1,
                &xAPP_Tasks);




    /* Start RTOS Scheduler. */
    
     /**********************************************************************
     * Create all Threads for APP Tasks before starting FreeRTOS Scheduler *
     ***********************************************************************/
    vTaskStartScheduler(); /* This function never returns. */

}

/*******************************************************************************
 End of File
 */

