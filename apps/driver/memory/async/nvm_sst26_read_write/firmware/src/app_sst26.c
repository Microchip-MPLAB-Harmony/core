/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_sst26.c

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

#include "app_sst26.h"

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
    This structure should be initialized by the APP_SST26_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_SST26_DATA CACHE_ALIGN appSST26Data;

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

void appTransferHandler
(
    DRV_MEMORY_EVENT event,
    DRV_MEMORY_COMMAND_HANDLE commandHandle,
    uintptr_t context
)
{
    APP_SST26_DATA *app_data = (APP_SST26_DATA *)context;

    switch(event)
    {
        case DRV_MEMORY_EVENT_COMMAND_COMPLETE:
            if (commandHandle == app_data->readHandle)
            {
                appSST26Data.xfer_done = true;
            }
            break;

        case DRV_MEMORY_EVENT_COMMAND_ERROR:
            appSST26Data.state = APP_SST26_STATE_ERROR;
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
    void APP_SST26_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_SST26_Initialize ( void )
{
    uint32_t i = 0;

    /* Place the App state machine in its initial state. */
    appSST26Data.state = APP_SST26_STATE_OPEN_DRIVER;

    for (i = 0; i < SST26_BUFFER_SIZE; i++)
        appSST26Data.writeBuffer[i] = i;
}


/******************************************************************************
  Function:
    void APP_SST26_Tasks ( void )

 Description:
    Demonstrates Erase, Write and Read operation of DRV_MEMORY in Buffer Model.
    Each case is a fall through when the request is queued up successfully.

  Remarks:
    See prototype in app.h.
 */

void APP_SST26_Tasks ( void )
{

    /* Check the application's current state. */
    switch ( appSST26Data.state )
    {
        case APP_SST26_STATE_OPEN_DRIVER:
        {
            appSST26Data.memoryHandle = DRV_MEMORY_Open(DRV_MEMORY_INDEX_0, DRV_IO_INTENT_READWRITE);

            if (DRV_HANDLE_INVALID != appSST26Data.memoryHandle)
            {
                DRV_MEMORY_TransferHandlerSet(appSST26Data.memoryHandle, appTransferHandler, (uintptr_t)&appSST26Data);
                appSST26Data.state = APP_SST26_STATE_ERASE_FLASH;
            }
            else
            {
                break;
            }
        }

        case APP_SST26_STATE_GEOMETRY_GET:
        {
            geometry = DRV_MEMORY_GeometryGet(appSST26Data.memoryHandle);

            if (geometry == NULL)
            {
                appSST26Data.state = APP_SST26_STATE_ERROR;
                break;
            }

            appSST26Data.numReadBlocks  = (SST26_BUFFER_SIZE / geometry->geometryTable[GEOMETRY_TABLE_READ_ENTRY].blockSize);
            appSST26Data.numWriteBlocks = (SST26_BUFFER_SIZE / geometry->geometryTable[GEOMETRY_TABLE_WRITE_ENTRY].blockSize);
            appSST26Data.numEraseBlocks = (SST26_BUFFER_SIZE / geometry->geometryTable[GEOMETRY_TABLE_ERASE_ENTRY].blockSize);
        }

        case APP_SST26_STATE_ERASE_FLASH:
        {
            DRV_MEMORY_AsyncErase(appSST26Data.memoryHandle, &appSST26Data.eraseHandle, BLOCK_START, appSST26Data.numEraseBlocks);

            if (DRV_MEMORY_COMMAND_HANDLE_INVALID == appSST26Data.eraseHandle)
            {
                appSST26Data.state = APP_SST26_STATE_ERROR;
                break;
            }
            else
            {
                appSST26Data.state = APP_SST26_STATE_WRITE_MEMORY;
            }
        }

        case APP_SST26_STATE_WRITE_MEMORY:
        {
            DRV_MEMORY_AsyncWrite(appSST26Data.memoryHandle, &appSST26Data.writeHandle, (void *)&appSST26Data.writeBuffer, BLOCK_START, appSST26Data.numWriteBlocks);

            if (DRV_MEMORY_COMMAND_HANDLE_INVALID == appSST26Data.writeHandle)
            {
                appSST26Data.state = APP_SST26_STATE_ERROR;
                break;
            }
            else
            {
                appSST26Data.state = APP_SST26_STATE_READ_MEMORY;
            }
        }

        case APP_SST26_STATE_READ_MEMORY:
        {
            DRV_MEMORY_AsyncRead(appSST26Data.memoryHandle, &appSST26Data.readHandle, (void *)appSST26Data.readBuffer, BLOCK_START, appSST26Data.numReadBlocks);

            if (DRV_MEMORY_COMMAND_HANDLE_INVALID == appSST26Data.readHandle)
            {
                appSST26Data.state = APP_SST26_STATE_ERROR;
                break;
            }
            else
            {
                appSST26Data.state = APP_SST26_STATE_XFER_WAIT;
            }
        }

        case APP_SST26_STATE_XFER_WAIT:
        {
            /* Wait until all the above queued transfer requests are done */
            if(appSST26Data.xfer_done)
            {
                appSST26Data.xfer_done = false;
                appSST26Data.state = APP_SST26_STATE_VERIFY_DATA;
            }

            break;
        }

        case APP_SST26_STATE_VERIFY_DATA:
        {
            if (!memcmp(appSST26Data.writeBuffer, appSST26Data.readBuffer, SST26_BUFFER_SIZE))
            {
                appSST26Data.state = APP_SST26_STATE_SUCCESS;
            }
            else
            {
                appSST26Data.state = APP_SST26_STATE_ERROR;
            }

            DRV_MEMORY_Close(appSST26Data.memoryHandle);

            break;
        }

        case APP_SST26_STATE_SUCCESS:
        case APP_SST26_STATE_ERROR:
        default:
        {
            break;
        }
    }
}
