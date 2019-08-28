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
    This structure should be initialized by the APP2_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

static APP2_DATA app2Data;

const static char message2Buffer[] =
"*** Console 2 ***\r\n"
"*** USART Driver Echo Demo Application ***\r\n"
"*** Type a character and observe it echo back ***\r\n"
"*** LED toggles on each time the character is echoed ***\r\n";
// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

static void APP2_USARTBufferEventHandler(
    DRV_USART_BUFFER_EVENT bufferEvent,
    DRV_USART_BUFFER_HANDLE bufferHandle,
    uintptr_t context
)
{
    switch(bufferEvent)
    {
        case DRV_USART_BUFFER_EVENT_COMPLETE:
            app2Data.transferStatus = true;
            break;

        case DRV_USART_BUFFER_EVENT_ERROR:
            app2Data.state = APP2_STATE_ERROR;
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
    void APP2_Initialize ( void )

  Remarks:
    See prototype in app2.h.
 */

void APP2_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app2Data.state          = APP2_STATE_INIT;
    app2Data.transferStatus = false;
    app2Data.usartHandle    = DRV_HANDLE_INVALID;
    app2Data.bufferHandle   = DRV_USART_BUFFER_HANDLE_INVALID;
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

            app2Data.usartHandle = DRV_USART_Open(DRV_USART_INDEX_1, DRV_IO_INTENT_READWRITE);
            if (app2Data.usartHandle != DRV_HANDLE_INVALID)
            {
                DRV_USART_BufferEventHandlerSet(app2Data.usartHandle, APP2_USARTBufferEventHandler, 0);
                app2Data.state = APP2_STATE_TRANSMIT_MESSAGE;
            }
            else
            {
                app2Data.state = APP2_STATE_ERROR;
            }
            break;

        case APP2_STATE_TRANSMIT_MESSAGE:

            DRV_USART_WriteBufferAdd(app2Data.usartHandle, (void*)message2Buffer, strlen(message2Buffer), &app2Data.bufferHandle);
            if (app2Data.bufferHandle != DRV_USART_BUFFER_HANDLE_INVALID)
            {
                app2Data.state = APP2_STATE_WAIT_MESSAGE_TRANSFER_COMPLETE;
            }
            else
            {
                app2Data.state = APP2_STATE_ERROR;
            }
            break;

        case APP2_STATE_WAIT_MESSAGE_TRANSFER_COMPLETE:

            if(app2Data.transferStatus == true)
            {
                app2Data.transferStatus = false;
                app2Data.state = APP2_STATE_RECEIVE_DATA;
            }
            break;

        case APP2_STATE_RECEIVE_DATA:

            DRV_USART_ReadBufferAdd(app2Data.usartHandle, app2Data.readBuffer, APP2_DATA_SIZE, &app2Data.bufferHandle);
            if (app2Data.bufferHandle != DRV_USART_BUFFER_HANDLE_INVALID)
            {
                app2Data.state = APP2_STATE_WAIT_RECEIVE_COMPLETE;
            }
            else
            {
                app2Data.state = APP2_STATE_ERROR;
            }
            break;

        case APP2_STATE_WAIT_RECEIVE_COMPLETE:

            if(app2Data.transferStatus == true)
            {
                app2Data.transferStatus = false;
                app2Data.state = APP2_STATE_TRANSMIT_DATA;
            }
            break;

        case APP2_STATE_TRANSMIT_DATA:

            /* Echo the received data back on the terminal */
            DRV_USART_WriteBufferAdd(app2Data.usartHandle, app2Data.readBuffer, APP2_DATA_SIZE, &app2Data.bufferHandle);
            if (app2Data.bufferHandle != DRV_USART_BUFFER_HANDLE_INVALID)
            {
                app2Data.state = APP2_STATE_WAIT_TRANSMIT_COMPLETE;
            }
            else
            {
                app2Data.state = APP2_STATE_ERROR;
            }
            break;

        case APP2_STATE_WAIT_TRANSMIT_COMPLETE:

            if(app2Data.transferStatus == true)
            {
                app2Data.transferStatus = false;

                LED_TOGGLE();

                app2Data.state = APP2_STATE_RECEIVE_DATA;
            }
            break;

        case APP2_STATE_ERROR:
            break;

        default:
            break;
    }
}


/*******************************************************************************
 End of File
 */
