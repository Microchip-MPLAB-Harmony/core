/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_usart_echo.c

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
//DOM-IGNORE-BEGIN
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
//DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "app_usart_echo.h"
#include "user.h"
#include <string.h>

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

static const char startMessage[] = "*** USART Driver Echo Demo Application ***\r\n"
"*** Type a character and observe it echo back ***\r\n"
"*** LED toggles on each time the character is echoed ***\r\n";
// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_USART_ECHO_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_USART_ECHO_DATA app_usart_echoData;

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

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
    void APP_USART_ECHO_Initialize ( void )

  Remarks:
    See prototype in app_usart_echo.h.
 */

void APP_USART_ECHO_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app_usart_echoData.state = APP_USART_ECHO_STATE_INIT;
}


/******************************************************************************
  Function:
    void APP_USART_ECHO_Tasks ( void )

  Remarks:
    See prototype in app_usart_echo.h.
 */

void APP_USART_ECHO_Tasks ( void )
{
    switch(app_usart_echoData.state)
    {
        case APP_USART_ECHO_STATE_INIT:

            /* Open USART Driver Instance 0 (USART 1)*/
            app_usart_echoData.usartHandle = DRV_USART_Open(DRV_USART_INDEX_0, DRV_IO_INTENT_READWRITE);
            if (app_usart_echoData.usartHandle != DRV_HANDLE_INVALID)
            {
                app_usart_echoData.state = APP_USART_ECHO_STATE_SEND_MESSGE;
            }
            else
            {
                app_usart_echoData.state = APP_USART_ECHO_STATE_ERROR;
            }
            break;

        case APP_USART_ECHO_STATE_SEND_MESSGE:

            if (DRV_USART_WriteBuffer( app_usart_echoData.usartHandle, (void*)startMessage, strlen(startMessage)) == true)
            {
                LED_TOGGLE();
                app_usart_echoData.state = APP_USART_ECHO_STATE_RECEIVE_BUFFER;
            }
            else
            {
                app_usart_echoData.state = APP_USART_ECHO_STATE_ERROR;
            }
            break;

        case APP_USART_ECHO_STATE_RECEIVE_BUFFER:

            /* Submit a read request and block until read completes */
            if (DRV_USART_ReadBuffer( app_usart_echoData.usartHandle, app_usart_echoData.receiveBuffer, APP_USART_ECHO_LOOPBACK_DATA_SIZE) == true)
            {
                app_usart_echoData.state = APP_USART_ECHO_STATE_SEND_BUFFER;
            }
            else
            {
                app_usart_echoData.state = APP_USART_ECHO_STATE_ERROR;
            }
            break;

        case APP_USART_ECHO_STATE_SEND_BUFFER:

            /* Echo the received character back */
            if (DRV_USART_WriteBuffer( app_usart_echoData.usartHandle, app_usart_echoData.receiveBuffer, APP_USART_ECHO_LOOPBACK_DATA_SIZE) == true)
            {
                LED_TOGGLE();
                app_usart_echoData.state = APP_USART_ECHO_STATE_RECEIVE_BUFFER;
            }
            else
            {
                app_usart_echoData.state = APP_USART_ECHO_STATE_ERROR;
            }
            break;

        case APP_USART_ECHO_STATE_ERROR:
        default:
            break;
    }
}


/*******************************************************************************
 End of File
 */
