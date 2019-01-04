/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_mx25l.c

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

#include "app_mx25l.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

SYS_MEDIA_GEOMETRY *mx25lGeometry = NULL;

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_MX25L_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_MX25L_DATA appMx25lData;

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

void appMx25lTransferHandler
(
    DRV_MEMORY_EVENT event,
    DRV_MEMORY_COMMAND_HANDLE commandHandle,
    uintptr_t context
)
{
    switch(event)
    {
        case DRV_MEMORY_EVENT_COMMAND_COMPLETE:
            appMx25lData.xfer_done = true;
            break;

        case DRV_MEMORY_EVENT_COMMAND_ERROR:
            appMx25lData.state = APP_MX25L_STATE_ERROR;
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
    void APP_MX25L_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_MX25L_Initialize ( void )
{
    uint32_t i = 0;

    /* Place the App state machine in its initial state. */
    appMx25lData.state = APP_MX25L_STATE_OPEN_DRIVER;

    for (i = 0; i < MX25L_BUFFER_SIZE; i++)
        appMx25lData.writeBuffer[i] = i;
}


/******************************************************************************
  Function:
    void APP_MX25L_Tasks ( void )

 Description:
    Demonstrates Erase, Write and Read operation of DRV_MEMORY in Buffer Model.
    Each case is a fall through when the request is queued up successfully.

  Remarks:
    See prototype in app.h.
 */

void APP_MX25L_Tasks ( void )
{
    /* Check the application's current state. */
    switch ( appMx25lData.state )
    {
        case APP_MX25L_STATE_OPEN_DRIVER:
        {
            appMx25lData.memoryHandle = DRV_MEMORY_Open(DRV_MEMORY_INDEX_0, DRV_IO_INTENT_READWRITE);

            if (DRV_HANDLE_INVALID != appMx25lData.memoryHandle)
            {
                DRV_MEMORY_TransferHandlerSet(appMx25lData.memoryHandle, (const void *)appMx25lTransferHandler, (uintptr_t)&appMx25lData);
                appMx25lData.state = APP_MX25L_STATE_GEOMETRY_GET;
            }
            break;
        }

        case APP_MX25L_STATE_GEOMETRY_GET:
        {
            mx25lGeometry = DRV_MEMORY_GeometryGet(appMx25lData.memoryHandle);

            if (mx25lGeometry == NULL)
            {
                appMx25lData.state = APP_MX25L_STATE_ERROR;
            }
            else
            {
                appMx25lData.numReadBlocks  = (MX25L_BUFFER_SIZE / mx25lGeometry->geometryTable[GEOMETRY_TABLE_READ_ENTRY].blockSize);
                appMx25lData.numWriteBlocks = (MX25L_BUFFER_SIZE / mx25lGeometry->geometryTable[GEOMETRY_TABLE_WRITE_ENTRY].blockSize);
                appMx25lData.numEraseBlocks = (MX25L_BUFFER_SIZE / mx25lGeometry->geometryTable[GEOMETRY_TABLE_ERASE_ENTRY].blockSize);
                appMx25lData.state = APP_MX25L_STATE_ERASE_FLASH;
            }
            break;
        }

        case APP_MX25L_STATE_ERASE_FLASH:
        {
            DRV_MEMORY_AsyncErase(appMx25lData.memoryHandle, &appMx25lData.eraseHandle, BLOCK_START, appMx25lData.numEraseBlocks);

            if (DRV_MEMORY_COMMAND_HANDLE_INVALID == appMx25lData.eraseHandle)
            {
                appMx25lData.state = APP_MX25L_STATE_ERROR;
            }
            else
            {
                appMx25lData.state = APP_MX25L_STATE_ERASE_WAIT;
            }
            break;
        }

        case APP_MX25L_STATE_WRITE_MEMORY:
        {
            DRV_MEMORY_AsyncWrite(appMx25lData.memoryHandle, &appMx25lData.writeHandle, (void *)&appMx25lData.writeBuffer, BLOCK_START, appMx25lData.numWriteBlocks);

            if (DRV_MEMORY_COMMAND_HANDLE_INVALID == appMx25lData.writeHandle)
            {
                appMx25lData.state = APP_MX25L_STATE_ERROR;
            }
            else
            {
                appMx25lData.state = APP_MX25L_STATE_WRITE_WAIT;
            }
            break;
        }

        case APP_MX25L_STATE_READ_MEMORY:
        {
            memset((void *)&appMx25lData.readBuffer, 0, MX25L_BUFFER_SIZE);

            DRV_MEMORY_AsyncRead(appMx25lData.memoryHandle, &appMx25lData.readHandle, (void *)&appMx25lData.readBuffer, BLOCK_START, appMx25lData.numReadBlocks);

            if (DRV_MEMORY_COMMAND_HANDLE_INVALID == appMx25lData.readHandle)
            {
                appMx25lData.state = APP_MX25L_STATE_ERROR;
            }
            else
            {
                appMx25lData.state = APP_MX25L_STATE_READ_WAIT;
            }
            break;
        }

        case APP_MX25L_STATE_ERASE_WAIT:
        case APP_MX25L_STATE_WRITE_WAIT:
        case APP_MX25L_STATE_READ_WAIT:
        {
            /* Wait until transfer request is done */
            if(appMx25lData.xfer_done)
            {
                appMx25lData.xfer_done = false;
                if (appMx25lData.state == APP_MX25L_STATE_ERASE_WAIT)
                {
                    appMx25lData.state = APP_MX25L_STATE_WRITE_MEMORY;
                }
                else if (appMx25lData.state == APP_MX25L_STATE_WRITE_WAIT)
                {
                    appMx25lData.state = APP_MX25L_STATE_READ_MEMORY;
                }
                else if (appMx25lData.state == APP_MX25L_STATE_READ_WAIT)
                {
                    appMx25lData.state = APP_MX25L_STATE_VERIFY_DATA;
                }
            }
            break;
        }

        case APP_MX25L_STATE_VERIFY_DATA:
        {
            if (!memcmp(appMx25lData.writeBuffer, appMx25lData.readBuffer, MX25L_BUFFER_SIZE))
            {
                appMx25lData.state = APP_MX25L_STATE_SUCCESS;
            }
            else
            {
                appMx25lData.state = APP_MX25L_STATE_ERROR;
            }
            DRV_MEMORY_Close(appMx25lData.memoryHandle);
            break;
        }

        case APP_MX25L_STATE_SUCCESS:
        case APP_MX25L_STATE_ERROR:
        default:
        {
            break;
        }
    }
}

/*******************************************************************************
 End of File
 */
