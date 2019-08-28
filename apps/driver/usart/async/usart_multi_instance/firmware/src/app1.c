/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app1.c

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

#include "app1.h"
#include "user.h"
#include <string.h>

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
    This structure should be initialized by the APP1_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

static APP1_DATA app1Data;

const static char message1Buffer[] =
"*** Console 1 ****\r\n"
"*** USART Driver Echo Demo Application ****\r\n"
"*** Type a character and observe it echo back ***\r\n"
"*** LED toggles on each time the character is echoed ***\r\n";
// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

static void APP1_USARTBufferEventHandler(
    DRV_USART_BUFFER_EVENT bufferEvent,
    DRV_USART_BUFFER_HANDLE bufferHandle,
    uintptr_t context
)
{
    switch(bufferEvent)
    {
        case DRV_USART_BUFFER_EVENT_COMPLETE:
            app1Data.transferStatus = true;
            break;

        case DRV_USART_BUFFER_EVENT_ERROR:
            app1Data.state = APP1_STATE_ERROR;
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

// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP1_Initialize ( void )

  Remarks:
    See prototype in app1.h.
 */

void APP1_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app1Data.state          = APP1_STATE_INIT;
    app1Data.transferStatus = false;
    app1Data.usartHandle    = DRV_HANDLE_INVALID;
    app1Data.bufferHandle   = DRV_USART_BUFFER_HANDLE_INVALID;
}


/******************************************************************************
  Function:
    void APP1_Tasks ( void )

  Remarks:
    See prototype in app1.h.
 */

void APP1_Tasks ( void )
{
    /* Check the application's current state. */
    switch ( app1Data.state )
    {
        /* Application's initial state. */
        case APP1_STATE_INIT:

            app1Data.usartHandle = DRV_USART_Open(DRV_USART_INDEX_0, DRV_IO_INTENT_READWRITE);
            if (app1Data.usartHandle != DRV_HANDLE_INVALID)
            {
                DRV_USART_BufferEventHandlerSet(app1Data.usartHandle, APP1_USARTBufferEventHandler, 0);
                app1Data.state = APP1_STATE_TRANSMIT_MESSAGE;
            }
            else
            {
                app1Data.state = APP1_STATE_ERROR;
            }
            break;

        case APP1_STATE_TRANSMIT_MESSAGE:

            DRV_USART_WriteBufferAdd(app1Data.usartHandle, (void*)message1Buffer, strlen(message1Buffer), &app1Data.bufferHandle);
            if (app1Data.bufferHandle != DRV_USART_BUFFER_HANDLE_INVALID)
            {
                app1Data.state = APP1_STATE_WAIT_MESSAGE_TRANSFER_COMPLETE;
            }
            else
            {
                app1Data.state = APP1_STATE_ERROR;
            }
            break;

        case APP1_STATE_WAIT_MESSAGE_TRANSFER_COMPLETE:

            if(app1Data.transferStatus == true)
            {
                app1Data.transferStatus = false;
                app1Data.state = APP1_STATE_RECEIVE_DATA;
            }
            break;
        case APP1_STATE_RECEIVE_DATA:

            DRV_USART_ReadBufferAdd(app1Data.usartHandle, app1Data.readBuffer, APP1_DATA_SIZE, &app1Data.bufferHandle);
            if (app1Data.bufferHandle != DRV_USART_BUFFER_HANDLE_INVALID)
            {
                app1Data.state = APP1_STATE_WAIT_RECEIVE_COMPLETE;
            }
            else
            {
                app1Data.state = APP1_STATE_ERROR;
            }
            break;

        case APP1_STATE_WAIT_RECEIVE_COMPLETE:

            if(app1Data.transferStatus == true)
            {
                app1Data.transferStatus = false;
                app1Data.state = APP1_STATE_TRANSMIT_DATA;
            }
            break;

        case APP1_STATE_TRANSMIT_DATA:

            /* Echo the received data back on the terminal */
            DRV_USART_WriteBufferAdd(app1Data.usartHandle, app1Data.readBuffer, APP1_DATA_SIZE, &app1Data.bufferHandle);
            if (app1Data.bufferHandle != DRV_USART_BUFFER_HANDLE_INVALID)
            {
                app1Data.state = APP1_STATE_WAIT_TRANSMIT_COMPLETE;
            }
            else
            {
                app1Data.state = APP1_STATE_ERROR;
            }
            break;

        case APP1_STATE_WAIT_TRANSMIT_COMPLETE:

            if(app1Data.transferStatus == true)
            {
                app1Data.transferStatus = false;

                LED_TOGGLE();

                app1Data.state = APP1_STATE_RECEIVE_DATA;
            }
            break;

        case APP1_STATE_ERROR:
            break;

        default:
            break;
    }
}


/*******************************************************************************
 End of File
 */
