/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_usart_usb_debug_port.c

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

#include "app_usart_usb_debug_port.h"
#include "toolchain_specifics.h"
#include "user.h"
#include <string.h>

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************
static CACHE_ALIGN char appUsartDebugPort_StartMessage[192] =
"*** USART Driver Multi-Instance Echo Demo Application ***\r\n"
"*** Type 10 characters and observe it echo back using DMA ***\r\n"
"*** LED toggles each time the data is echoed ***\r\n";

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_USART_USB_DEBUG_PORT_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

static APP_USART_USB_DEBUG_PORT_DATA appUsartDebugPortData;

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

/* TODO:  Add any necessary callback functions.
*/

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
    void APP_USART_USB_DEBUG_PORT_Initialize ( void )

  Remarks:
    See prototype in app_usart_usb_debug_port.h.
 */

void APP_USART_USB_DEBUG_PORT_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    appUsartDebugPortData.state = APP_USART_USB_DEBUG_PORT_STATE_INIT;
}


/******************************************************************************
  Function:
    void APP_USART_USB_DEBUG_PORT_Tasks ( void )

  Remarks:
    See prototype in app_usart_usb_debug_port.h.
 */

void APP_USART_USB_DEBUG_PORT_Tasks ( void )
{
    /* Check the application's current state. */
    switch ( appUsartDebugPortData.state )
    {
        case APP_USART_USB_DEBUG_PORT_STATE_INIT:
            /* Open USART Driver Instance 0 */
            appUsartDebugPortData.usartHandle = DRV_USART_Open(DRV_USART_INDEX_1, DRV_IO_INTENT_READWRITE);
            if (appUsartDebugPortData.usartHandle == DRV_HANDLE_INVALID)
            {
                appUsartDebugPortData.state = APP_USART_USB_DEBUG_PORT_STATE_ERROR;
            }
            else
            {
                appUsartDebugPortData.state = APP_USART_USB_DEBUG_PORT_STATE_SEND_MESSAGE;
            }
            break;

        case APP_USART_USB_DEBUG_PORT_STATE_SEND_MESSAGE:
            if (DRV_USART_WriteBuffer( appUsartDebugPortData.usartHandle, appUsartDebugPort_StartMessage, strlen(appUsartDebugPort_StartMessage)) == true)
            {
                appUsartDebugPortData.state = APP_USART_USB_DEBUG_PORT_STATE_LOOPBACK;
            }
            else
            {
                appUsartDebugPortData.state = APP_USART_USB_DEBUG_PORT_STATE_ERROR;
            }
            break;

        case APP_USART_USB_DEBUG_PORT_STATE_LOOPBACK:
            /* Submit a read request and block until read completes */
            if (DRV_USART_ReadBuffer( appUsartDebugPortData.usartHandle, appUsartDebugPortData.receiveBuffer, APP_DEBUG_PORT_LOOPBACK_DATA_SIZE) == true)
            {
                /* Copy receive buffer to transmit buffer */
                memcpy(appUsartDebugPortData.transmitBuffer, appUsartDebugPortData.receiveBuffer, APP_DEBUG_PORT_LOOPBACK_DATA_SIZE);
            }
            else
            {
                appUsartDebugPortData.state = APP_USART_USB_DEBUG_PORT_STATE_ERROR;
                break;
            }

            /* Write the received data back */
            if (DRV_USART_WriteBuffer( appUsartDebugPortData.usartHandle, appUsartDebugPortData.transmitBuffer, APP_DEBUG_PORT_LOOPBACK_DATA_SIZE) == true)
            {
                /* Toggle LED to indicate success */
                LED_TOGGLE();
            }
            else
            {
                appUsartDebugPortData.state = APP_USART_USB_DEBUG_PORT_STATE_ERROR;
                break;
            }
            break;

        case APP_USART_USB_DEBUG_PORT_STATE_ERROR:
        default:
            break;
    }
}


/*******************************************************************************
 End of File
 */
