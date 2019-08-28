/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app.c

  Summary:
    This file contains the source code for the MPLAB Harmony application.

  Description:
    This file contains the source code for the MPLAB Harmony application.  It
    implements the logic of the application's state machine and it may call
    API routines of other MPLAB Harmony modules in the system, such as drivers,
    system services, and middleware.  However, it does not call any of the
    system interfaces (such as the "Initialize" and "Tasks" functions) of any of
    the modules in the system or make any assumptions about when those functions
    are called.  That is the responsibility of the configuration-specific system
    files.
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

#include "app.h"
#include "user.h"
#include <stdio.h>

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_DATA appData;

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

void Timer1_Callback ( uintptr_t context )
{
    appData.tmr1Expired = true;
}

void Timer2_Callback ( uintptr_t context )
{
    appData.tmr2Expired = true;
}

void Timer3_Callback ( uintptr_t context )
{
    appData.tmr3Expired = true;
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************


/* TODO:  Add any necessary local functions.
*/


// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    appData.state = APP_STATE_INIT;
    appData.state = APP_STATE_INIT;
    appData.tmr1Handle = SYS_TIME_HANDLE_INVALID;
    appData.tmr2Handle = SYS_TIME_HANDLE_INVALID;
    appData.tmr3Handle = SYS_TIME_HANDLE_INVALID;
    appData.tmr4Handle = SYS_TIME_HANDLE_INVALID;
    appData.tmr1Expired = false;
    appData.tmr2Expired = false;
    appData.tmr3Expired = false;
}


/******************************************************************************
  Function:
    void APP_Tasks ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Tasks ( void )
{
    uint64_t diffCount = 0;

    /* Check the application's current state. */
    switch ( appData.state )
    {
        /* Application's initial state. */
        case APP_STATE_INIT:
            
            appData.tmr1Handle = SYS_TIME_CallbackRegisterMS(Timer1_Callback, 0, LED_BLINK_RATE_MS, SYS_TIME_PERIODIC);
            appData.tmr2Handle = SYS_TIME_CallbackRegisterMS(Timer2_Callback, 0, CONSOLE_PRINT_RATE_MS, SYS_TIME_PERIODIC);

            if ((appData.tmr1Handle != SYS_TIME_HANDLE_INVALID) && (appData.tmr2Handle != SYS_TIME_HANDLE_INVALID))
            {

                appData.state = APP_STATE_SERVICE_TASKS;
            }
            break;

        case APP_STATE_SERVICE_TASKS:

            if(appData.tmr1Expired == true)
            {
                /* Toggle LED periodically */
                appData.tmr1Expired = false;
                LED_TOGGLE();
            }
            if(appData.tmr2Expired == true)
            {
                printf("Message printed every %d ms \r\n", CONSOLE_PRINT_RATE_MS);
                appData.tmr2Expired = false;
            }
            if(appData.tmr3Expired == true)
            {
                printf("Single shot timer of %d ms expired \r\n", SINGLE_SHOT_TIMER_MS);
                appData.tmr3Expired = false;
            }
            if(SWITCH_GET() == SWITCH_STATUS_PRESSED)
            {
                /* Wait on delay */
                appData.prevCounterVal = SYS_TIME_Counter64Get();

                SYS_TIME_DelayMS(SWITCH_DELAY_MS, &appData.tmr4Handle);
                while(SYS_TIME_DelayIsComplete(appData.tmr4Handle) == false);

                diffCount = (SYS_TIME_Counter64Get() - appData.prevCounterVal);
                printf("Delay time = %d ms\r\n", (int)SYS_TIME_CountToMS(diffCount));

                appData.tmr3Handle = SYS_TIME_CallbackRegisterMS(Timer3_Callback, 0, SINGLE_SHOT_TIMER_MS, SYS_TIME_SINGLE);
            }
            break;

        /* The default state should never be executed. */
        default:
            break;

    }
}


/*******************************************************************************
 End of File
 */
