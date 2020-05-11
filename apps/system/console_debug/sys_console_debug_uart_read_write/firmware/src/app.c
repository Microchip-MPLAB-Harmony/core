/*******************************************************************************
* Copyright (C) 2020 Microchip Technology Inc. and its subsidiaries.
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

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "app.h"
#include "configuration.h"
#include "system/debug/sys_debug.h"
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

#define UART_CONSOLE_NUM_BYTES_READ              10
#define UART_CONSOLE_READ_BUFFER_SIZE            10
// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************
uint8_t uart_console_read_buffer[UART_CONSOLE_READ_BUFFER_SIZE];
/*******************************************************************************
  Function:
    void APP_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    appData.state = APP_STATE_WAIT_UART_CONSOLE_CONFIGURED;
}

static void APP_DebugAPIDemonstrate(void)
{
    SYS_DEBUG_MESSAGE(SYS_ERROR_INFO, "***This is UART Console Instance 0***\n\r");
    SYS_DEBUG_MESSAGE(SYS_ERROR_DEBUG, "\n\rTest Sys Debug Message!");
    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\n\rSys Debug Print test %d, %s", 1, "str1");
    SYS_DEBUG_PRINT(SYS_ERROR_INFO, "\n\rSys Debug Print test %d, %s", 2, "str2");
    /* Change the error level to only print the debug messages with error value set to SYS_ERROR_ERROR or lower */
    SYS_DEBUG_ErrorLevelSet(SYS_ERROR_ERROR);

    /* The below message should not get printed as "SYS_ERROR_DEBUG" is higher than "SYS_ERROR_ERROR" */
    SYS_DEBUG_MESSAGE(SYS_ERROR_DEBUG, "\n\rThis message should not be printed!");
    
    /* Set the error level back to SYS_ERROR_DEBUG */
    SYS_DEBUG_ErrorLevelSet(SYS_ERROR_DEBUG);
}
/******************************************************************************
  Function:
    void APP_Tasks ( void )

  Remarks:
    See prototype in app.h.
 */
void APP_Tasks ( void )
{
    switch ( appData.state )
    {
        case APP_STATE_WAIT_UART_CONSOLE_CONFIGURED:
            if (SYS_CONSOLE_Status(SYS_CONSOLE_INDEX_0) == SYS_STATUS_READY)
            {
                appData.state = APP_STATE_GET_CONSOLE_HANDLE;
            }
            break;

        case APP_STATE_GET_CONSOLE_HANDLE:
            /* Get handles to both the USB console instances */
            appData.consoleHandle = SYS_CONSOLE_HandleGet(SYS_CONSOLE_INDEX_0);

            if (appData.consoleHandle != SYS_CONSOLE_HANDLE_INVALID)
            {
                appData.state = APP_STATE_DEMONSTRATE_DEBUG_APIS;
            }
            else
            {
                appData.state = APP_STATE_ERROR;
            }
            break;

        case APP_STATE_DEMONSTRATE_DEBUG_APIS:
            APP_DebugAPIDemonstrate();
            appData.state = APP_STATE_READ_FROM_CONSOLE;
            break;

        case APP_STATE_READ_FROM_CONSOLE:
            SYS_CONSOLE_PRINT("\n\rFree Space in RX Buffer = %d bytes", SYS_CONSOLE_ReadFreeBufferCountGet(appData.consoleHandle));
            SYS_CONSOLE_Print(appData.consoleHandle, "\n\rEnter %d characters:", UART_CONSOLE_NUM_BYTES_READ);
            appData.state = APP_STATE_WAIT_READ_COMPLETE;
            break;

        case APP_STATE_WAIT_READ_COMPLETE:
            /* Demonstrate SYS_CONSOLE_ReadCountGet() and SYS_CONSOLE_Read() APIs */

            if (SYS_CONSOLE_ReadCountGet(appData.consoleHandle) >= UART_CONSOLE_NUM_BYTES_READ)
            {
                SYS_CONSOLE_PRINT("\n\rFree Space in RX Buffer = %d bytes", SYS_CONSOLE_ReadFreeBufferCountGet(appData.consoleHandle));

                /* UART_CONSOLE_NUM_BYTES_READ or more characters are available. Read the data in the application buffer. */
                if (SYS_CONSOLE_Read(appData.consoleHandle, uart_console_read_buffer, UART_CONSOLE_NUM_BYTES_READ) == UART_CONSOLE_NUM_BYTES_READ)
                {
                    appData.state = APP_STATE_WRITE_RECEIVED_DATA;
                }
                else
                {
                    appData.state = APP_STATE_ERROR;
                }
            }
            break;

        case APP_STATE_WRITE_RECEIVED_DATA:
            /* Demonstrate SYS_CONSOLE_WriteFreeBufferCountGet() and SYS_CONSOLE_Write() APIs */
            SYS_CONSOLE_MESSAGE("\n\rReceived Characters:");
            SYS_CONSOLE_Write(appData.consoleHandle, uart_console_read_buffer, UART_CONSOLE_NUM_BYTES_READ);
            appData.state = APP_STATE_WAIT_WRITE_BUFFER_EMPTY;
            break;

        case APP_STATE_WAIT_WRITE_BUFFER_EMPTY:
            if (SYS_CONSOLE_WriteCountGet(appData.consoleHandle) == 0)
            {
                SYS_CONSOLE_PRINT("\n\rFree Space in TX Buffer = %d", SYS_CONSOLE_WriteFreeBufferCountGet(appData.consoleHandle));
                appData.state = APP_STATE_ECHO_TEST;
            }
            break;

        case APP_STATE_ECHO_TEST:

            SYS_CONSOLE_Message(appData.consoleHandle, "\n\r\n\r***Echo Test*** \n\rEnter a character and it will be echoed back \n\r");
            appData.state = APP_STATE_CONSOLE_READ_WRITE;
            break;

        case APP_STATE_CONSOLE_READ_WRITE:
            if (SYS_CONSOLE_Read(appData.consoleHandle, uart_console_read_buffer, 1) >= 1)
            {
                LED_TOGGLE();
                SYS_CONSOLE_Write(appData.consoleHandle, uart_console_read_buffer, 1);
            }
            break;

        case APP_STATE_ERROR:
        default:
            break;

    }
}


/*******************************************************************************
 End of File
 */
