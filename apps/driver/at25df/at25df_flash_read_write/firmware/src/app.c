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

#include <string.h>
#include "app.h"

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

static uint32_t write_index = 0;

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************
void APP_FLASH_EventHandler(DRV_AT25DF_TRANSFER_STATUS event, uintptr_t context)
{
    switch(event)
    {
        case DRV_AT25DF_TRANSFER_STATUS_COMPLETED:
            appData.isTransferDone = true;
            break;
        case DRV_AT25DF_TRANSFER_STATUS_ERROR:
        default:
            appData.isTransferDone = false;
            break;
    }
}
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
    void APP_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Initialize ( void )
{
    uint32_t i = 0;

    /* Place the App state machine in its initial state. */
    appData.state = APP_STATE_INIT;
    appData.isTransferDone = false;

    for (i = 0; i < BUFFER_SIZE; i++)
        appData.writeBuffer[i] = i;

    PIT_TimerStart();
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
        {
            if (DRV_AT25DF_Status(DRV_AT25DF_INDEX) == SYS_STATUS_READY)
            {
                appData.state = APP_STATE_OPEN_DRIVER;
            }
            break;
        }

        case APP_STATE_OPEN_DRIVER:
        {
            appData.handle = DRV_AT25DF_Open(DRV_AT25DF_INDEX, DRV_IO_INTENT_READWRITE);

            if (appData.handle != DRV_HANDLE_INVALID)
            {
                DRV_AT25DF_EventHandlerSet(appData.handle, APP_FLASH_EventHandler, 0);
                appData.state = APP_STATE_GEOMETRY_GET;
            }

            break;
        }
        case APP_STATE_GEOMETRY_GET:
        {
            if (DRV_AT25DF_GeometryGet(appData.handle, &appData.geometry) != true)
            {
                appData.state = APP_STATE_ERROR;
                break;
            }

            appData.state = APP_STATE_GEOMETRY_WAIT;

            break;
        }

        case APP_STATE_GEOMETRY_WAIT:
        {
            if (appData.isTransferDone == true)            
            {
                appData.state = APP_STATE_ERASE_FLASH;
                appData.isTransferDone = false;
            }
            else if (DRV_AT25DF_TransferStatusGet(appData.handle) == DRV_AT25DF_TRANSFER_STATUS_ERROR)
            {
                appData.state = APP_STATE_ERROR;
            }
            break;
        }

        case APP_STATE_ERASE_FLASH:
        {
            if (DRV_AT25DF_SectorErase(appData.handle, MEM_ADDRESS) != true)
            {
                appData.state = APP_STATE_ERROR;
            }

            appData.state = APP_STATE_ERASE_WAIT;

            break;
        }

        case APP_STATE_ERASE_WAIT:
        {
            if (appData.isTransferDone == true)            
            {
                appData.state = APP_STATE_WRITE_MEMORY;
                appData.isTransferDone = false;
            }
            else if (DRV_AT25DF_TransferStatusGet(appData.handle) == DRV_AT25DF_TRANSFER_STATUS_ERROR)
            {
                appData.state = APP_STATE_ERROR;
            }
            break;
        }

        case APP_STATE_WRITE_MEMORY:
        {
            if (DRV_AT25DF_PageWrite(appData.handle, (uint32_t *)&appData.writeBuffer[write_index], (MEM_ADDRESS + write_index)) != true)
            {
                appData.state = APP_STATE_ERROR;
                break;
            }

            appData.state = APP_STATE_WRITE_WAIT;

            break;
        }

        case APP_STATE_WRITE_WAIT:
        {
            if (appData.isTransferDone == true)            
            {
                appData.isTransferDone = false;
                write_index += appData.geometry.writeBlockSize;

                if (write_index < BUFFER_SIZE)
                {
                    appData.state = APP_STATE_WRITE_MEMORY;
                }
                else
                {
                    appData.state = APP_STATE_READ_MEMORY;
                }
            }
            else if (DRV_AT25DF_TransferStatusGet(appData.handle) == DRV_AT25DF_TRANSFER_STATUS_ERROR)
            {
                appData.state = APP_STATE_ERROR;
            }

            break;
        }

        case APP_STATE_READ_MEMORY:
        {
            if (DRV_AT25DF_Read(appData.handle, (uint32_t *)&appData.readBuffer, BUFFER_SIZE, MEM_ADDRESS) != true)
            {
                appData.state = APP_STATE_ERROR;
            }
            else
            {
                appData.state = APP_STATE_READ_WAIT;
            }

            break;
        }

        case APP_STATE_READ_WAIT:
            
            if (appData.isTransferDone == true)
            {
                appData.isTransferDone = false;
                appData.state = APP_STATE_VERIFY_DATA;
            }
            else if (DRV_AT25DF_TransferStatusGet(appData.handle) == DRV_AT25DF_TRANSFER_STATUS_ERROR)
            {
                appData.state = APP_STATE_ERROR;
            }
            break;

        case APP_STATE_VERIFY_DATA:
        {
            if (!memcmp(appData.writeBuffer, appData.readBuffer, BUFFER_SIZE))
            {
                appData.state = APP_STATE_SUCCESS;
            }
            else
            {
                appData.state = APP_STATE_ERROR;
            }

            break;
        }

        case APP_STATE_SUCCESS:
        {
            PIT_DelayMs(1000);

            LED_TOGGLE();

            break;
        }

        case APP_STATE_ERROR:
        default:
            LED_ON();
    }
}



/*******************************************************************************
 End of File
 */
