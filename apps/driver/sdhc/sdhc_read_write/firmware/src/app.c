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
#include "string.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

SYS_MEDIA_GEOMETRY *geometry = NULL;

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

void appTransferHandler
(
    DRV_SDHC_EVENT event,
    DRV_SDHC_COMMAND_HANDLE commandHandle,
    uintptr_t context
)
{
    APP_DATA *app_data = (APP_DATA *)context;

    switch(event)
    {
        case DRV_SDHC_EVENT_COMMAND_COMPLETE:
            if (commandHandle == app_data->readHandle)
            {
                appData.xfer_done = true;
            }
            break;

        case DRV_SDHC_EVENT_COMMAND_ERROR:
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
    uint32_t i = 0;

    /* Place the App state machine in its initial state. */
    appData.state = APP_STATE_OPEN_DRIVER;

    for (i = 0; i < SDHC_BUFFER_SIZE; i++)
        appData.writeBuffer[i] = i;
}


/******************************************************************************
  Function:
    void APP_Tasks ( void )

 Description:
    Demonstrates Erase, Write and Read operation of DRV_SDHC in Buffer Model.
    Each case is a fall through when the request is queued up successfully.

  Remarks:
    See prototype in app.h.
 */

void APP_Tasks ( void )
{

    /* Check the application's current state. */
    switch ( appData.state )
    {
        case APP_STATE_OPEN_DRIVER:
        {
            appData.sdhcHandle = DRV_SDHC_Open(DRV_SDHC_INDEX_0, DRV_IO_INTENT_READWRITE);

            if (DRV_HANDLE_INVALID != appData.sdhcHandle)
            {
                DRV_SDHC_EventHandlerSet(appData.sdhcHandle, appTransferHandler, (uintptr_t)&appData);
                appData.state = APP_STATE_SDCARD_ATTACHED;
            }
            else
            {
                break;
            }
        }

        case APP_STATE_SDCARD_ATTACHED:
        {
            if (DRV_SDHC_IsAttached(appData.sdhcHandle) == true)
            {
                appData.state = APP_STATE_GEOMETRY_GET;
            }
            else
            {
                break;
            }
        }

        case APP_STATE_GEOMETRY_GET:
        {
            geometry = DRV_SDHC_GeometryGet(appData.sdhcHandle);

            if (geometry == NULL)
            {
                appData.state = APP_STATE_ERROR;
                break;
            }

            appData.numReadBlocks  = (SDHC_DATA_SIZE / geometry->geometryTable[GEOMETRY_TABLE_READ_ENTRY].blockSize);
            appData.numWriteBlocks = (SDHC_DATA_SIZE / geometry->geometryTable[GEOMETRY_TABLE_WRITE_ENTRY].blockSize);
            appData.numEraseBlocks = (SDHC_DATA_SIZE / geometry->geometryTable[GEOMETRY_TABLE_ERASE_ENTRY].blockSize);
        }

        case APP_STATE_WRITE_MEMORY:
        {
            DRV_SDHC_Write(appData.sdhcHandle, &appData.writeHandle, (void *)&appData.writeBuffer, BLOCK_START, appData.numWriteBlocks);

            if (DRV_SDHC_COMMAND_HANDLE_INVALID == appData.writeHandle)
            {
                appData.state = APP_STATE_ERROR;
                break;
            }
            else
            {
                appData.state = APP_STATE_READ_MEMORY;
            }
        }

        case APP_STATE_READ_MEMORY:
        {
            memset((void *)&appData.readBuffer, 0, SDHC_DATA_SIZE);

            DRV_SDHC_Read(appData.sdhcHandle, &appData.readHandle, (void *)&appData.readBuffer, BLOCK_START, appData.numReadBlocks);

            if (DRV_SDHC_COMMAND_HANDLE_INVALID == appData.readHandle)
            {
                appData.state = APP_STATE_ERROR;
                break;
            }
            else
            {
                appData.state = APP_STATE_XFER_WAIT;
            }
        }

        case APP_STATE_XFER_WAIT:
        {
            /* Wait until all the above queued transfer requests are done */
            if(appData.xfer_done)
            {
                appData.xfer_done = false;
                appData.state = APP_STATE_VERIFY_DATA;
            }

            break;
        }

        case APP_STATE_VERIFY_DATA:
        {
            if (!memcmp(appData.writeBuffer, appData.readBuffer, SDHC_DATA_SIZE))
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
            DRV_SDHC_Close(appData.sdhcHandle);
            LED_ON();
            break;
        }
        case APP_STATE_ERROR:
        {
            DRV_SDHC_Close(appData.sdhcHandle);
        }
        default:
        {
            break;
        }
    }
}

/*******************************************************************************
 End of File
 */
