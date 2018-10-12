/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app2.c

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

#include "app2.h"

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
    This structure should be initialized by the APP2_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP2_DATA app2Data;

#define APP_DATA_SIZE   1

static char messageStart[] = "**** Console 2 ****\r\n\
**** USART Driver Echo Demo Application ****\r\n\
**** Type a character and observe it echo back ***\r\n\
**** LED toggles on each time the character is echoed ***\r\n";
static char readBuffer[APP_DATA_SIZE] = {};
// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

void APP2_BufferEventHandler(DRV_USART_BUFFER_EVENT bufferEvent, DRV_USART_BUFFER_HANDLE bufferHandle, uintptr_t context )
{
    switch(bufferEvent)
    {
        case DRV_USART_BUFFER_EVENT_COMPLETE:
        {
            app2Data.completeStatus = true;
            break;
        }

        case DRV_USART_BUFFER_EVENT_ERROR:
        {
            app2Data.errorStatus = true;
            break;
        }

        default:
        {
            break;
        }
    }
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
    void APP2_Initialize ( void )

  Remarks:
    See prototype in app2.h.
 */

void APP2_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app2Data.state = APP2_STATE_INIT;
    app2Data.prevState = APP2_STATE_INIT;
    app2Data.usartHandle = DRV_HANDLE_INVALID;
    app2Data.messageBufHandler = DRV_USART_BUFFER_HANDLE_INVALID;
    app2Data.writeBufHandler = DRV_USART_BUFFER_HANDLE_INVALID;
    app2Data.readBufHandler = DRV_USART_BUFFER_HANDLE_INVALID;
}


/******************************************************************************
  Function:
    void APP2_Tasks ( void )

  Remarks:
    See prototype in app2.h.
 */

void APP2_Tasks ( void )
{

    /* Check the application's current state. */
    switch ( app2Data.state )
    {
        /* Application's initial state. */
        case APP2_STATE_INIT:
        {
            app2Data.usartHandle = DRV_USART_Open(DRV_USART_INDEX_1, DRV_IO_INTENT_READWRITE);

            if (app2Data.usartHandle != DRV_HANDLE_INVALID)
            {
                DRV_USART_BufferEventHandlerSet(app2Data.usartHandle, APP2_BufferEventHandler, 0);
                app2Data.state = APP2_STATE_SEND_MESSAGE;
            }
            break;
        }

        case APP2_STATE_SEND_MESSAGE:
        {
            DRV_USART_WriteBufferAdd(app2Data.usartHandle, messageStart, sizeof(messageStart), &app2Data.messageBufHandler);
            app2Data.prevState = APP2_STATE_SEND_MESSAGE;
            app2Data.state = APP2_STATE_WAIT;
            break;
        }

        case APP2_STATE_RECEIVE_BUFFER:
        {
            DRV_USART_ReadBufferAdd(app2Data.usartHandle, readBuffer, APP_DATA_SIZE, &app2Data.readBufHandler);
            app2Data.prevState = APP2_STATE_RECEIVE_BUFFER;
            app2Data.state = APP2_STATE_WAIT;
            break;
        }

        case APP2_STATE_SEND_BUFFER:
        {
            DRV_USART_WriteBufferAdd(app2Data.usartHandle, readBuffer, APP_DATA_SIZE, &app2Data.writeBufHandler);
            app2Data.prevState = APP2_STATE_SEND_BUFFER;
            app2Data.state = APP2_STATE_WAIT;
            break;
        }

        case APP2_STATE_WAIT:
        {
            if(app2Data.completeStatus == true)
            {
                app2Data.completeStatus = false;

                if(app2Data.prevState == APP2_STATE_SEND_MESSAGE || app2Data.prevState == APP2_STATE_SEND_BUFFER)
                {
                    LED_TOGGLE();
                    app2Data.state = APP2_STATE_RECEIVE_BUFFER;
                }
                else if(app2Data.prevState == APP2_STATE_RECEIVE_BUFFER)
                {
                    app2Data.state = APP2_STATE_SEND_BUFFER;
                }

                app2Data.prevState = APP2_STATE_WAIT;
            }
            else if(app2Data.errorStatus == true)
            {
                app2Data.errorStatus = false;
                app2Data.prevState = APP2_STATE_WAIT;
                app2Data.state = APP2_STATE_IDLE;
            }

            break;
        }

        case APP2_STATE_IDLE:
        {
            break;
        }

        /* The default state should never be executed. */
        default:
        {
            /* TODO: Handle error in application's state machine. */
            break;
        }
    }
}


/*******************************************************************************
 End of File
 */
