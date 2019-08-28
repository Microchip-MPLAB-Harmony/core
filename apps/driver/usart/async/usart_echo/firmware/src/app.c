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

#include <string.h>
#include "app.h"
#include "user.h"
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

static const char messageBuffer[] =
"*** USART Driver Echo Demo Application ***\r\n"
"*** Type a character and observe it echo back ***\r\n"
"*** LED toggles on each time the character is echoed ***\r\n";

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

static void APP_USARTBufferEventHandler(
    DRV_USART_BUFFER_EVENT bufferEvent,
    DRV_USART_BUFFER_HANDLE bufferHandle,
    uintptr_t context
)
{
    switch(bufferEvent)
    {
        case DRV_USART_BUFFER_EVENT_COMPLETE:
            appData.transferStatus = true;
            break;

        case DRV_USART_BUFFER_EVENT_ERROR:
            appData.state = APP_STATE_ERROR;
            break;

        default:
            break;
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
    void APP_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    appData.state           = APP_STATE_INIT;
    appData.transferStatus  = false;
    appData.usartHandle     = DRV_HANDLE_INVALID;
    appData.bufferHandle    = DRV_USART_BUFFER_HANDLE_INVALID;

    LED_OFF();
}


/******************************************************************************
  Function:
    void APP_Tasks ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Tasks ( void )
{
    /* Check the application's current state. */
    switch ( appData.state )
    {
        /* Application's initial state. */
        case APP_STATE_INIT:

            appData.usartHandle = DRV_USART_Open(DRV_USART_INDEX_0, DRV_IO_INTENT_READWRITE);
            if (appData.usartHandle != DRV_HANDLE_INVALID)
            {
                DRV_USART_BufferEventHandlerSet(appData.usartHandle, APP_USARTBufferEventHandler, 0);
                appData.state = APP_STATE_TRANSMIT_MESSAGE;
            }
            else
            {
                appData.state = APP_STATE_ERROR;
            }
            break;

        case APP_STATE_TRANSMIT_MESSAGE:

            DRV_USART_WriteBufferAdd(appData.usartHandle, (void*)messageBuffer, strlen(messageBuffer), &appData.bufferHandle);
            if (appData.bufferHandle != DRV_USART_BUFFER_HANDLE_INVALID)
            {
                appData.state = APP_STATE_WAIT_MESSAGE_TRANSFER_COMPLETE;
            }
            else
            {
                appData.state = APP_STATE_ERROR;
            }
            break;

        case APP_STATE_WAIT_MESSAGE_TRANSFER_COMPLETE:
            if(appData.transferStatus == true)
            {
                appData.transferStatus = false;
                appData.state = APP_STATE_RECEIVE_DATA;
            }
            break;

        case APP_STATE_RECEIVE_DATA:

            DRV_USART_ReadBufferAdd(appData.usartHandle, appData.readBuffer, APP_DATA_SIZE, &appData.bufferHandle);
            if (appData.bufferHandle != DRV_USART_BUFFER_HANDLE_INVALID)
            {
                appData.state = APP_STATE_WAIT_RECEIVE_COMPLETE;
            }
            else
            {
                appData.state = APP_STATE_ERROR;
            }
            break;

        case APP_STATE_WAIT_RECEIVE_COMPLETE:

            if(appData.transferStatus == true)
            {
                appData.transferStatus = false;
                appData.state = APP_STATE_TRANSMIT_DATA;
            }
            break;

        case APP_STATE_TRANSMIT_DATA:

            /* Echo the received data back on the terminal */
            DRV_USART_WriteBufferAdd(appData.usartHandle, appData.readBuffer, APP_DATA_SIZE, &appData.bufferHandle);
            if (appData.bufferHandle != DRV_USART_BUFFER_HANDLE_INVALID)
            {
                appData.state = APP_STATE_WAIT_TRANSMIT_COMPLETE;
            }
            else
            {
                appData.state = APP_STATE_ERROR;
            }
            break;

        case APP_STATE_WAIT_TRANSMIT_COMPLETE:

            if(appData.transferStatus == true)
            {
                appData.transferStatus = false;

                LED_TOGGLE();

                appData.state = APP_STATE_RECEIVE_DATA;
            }
            break;

        case APP_STATE_ERROR:

            LED_OFF();
            appData.state = APP_STATE_IDLE;
            break;

        case APP_STATE_IDLE:
        default:
            break;
    }
}


/*******************************************************************************
 End of File
 */
