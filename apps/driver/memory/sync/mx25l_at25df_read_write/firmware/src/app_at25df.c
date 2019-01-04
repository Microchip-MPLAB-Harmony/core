/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_at25df.c

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

#include "app_at25df.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

SYS_MEDIA_GEOMETRY *at25dfGeometry = NULL;

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_AT25DF_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_AT25DF_DATA appAt25dfData;

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


/* TODO:  Add any necessary local functions.
*/


// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_AT25DF_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_AT25DF_Initialize ( void )
{
    uint32_t i = 0;

    /* Place the App state machine in its initial state. */
    appAt25dfData.state = APP_AT25DF_STATE_OPEN_DRIVER;

    for (i = 0; i < AT25DF_BUFFER_SIZE; i++)
        appAt25dfData.writeBuffer[i] = i;
}


/******************************************************************************
  Function:
    void APP_AT25DF_Tasks ( void )

 Description:
    Demonstrates Erase, Write and Read operation of DRV_MEMORY in Buffer Model.
    Each case is a fall through when the request is queued up successfully.

  Remarks:
    See prototype in app.h.
 */

void APP_AT25DF_Tasks ( void )
{
    bool xferDone = false;

    /* Check the application's current state. */
    switch ( appAt25dfData.state )
    {
        case APP_AT25DF_STATE_OPEN_DRIVER:
        {
            appAt25dfData.memoryHandle = DRV_MEMORY_Open(DRV_MEMORY_INDEX_1, DRV_IO_INTENT_READWRITE);

            if (DRV_HANDLE_INVALID != appAt25dfData.memoryHandle)
            {
                appAt25dfData.state = APP_AT25DF_STATE_GEOMETRY_GET;
            }
            break;
        }

        case APP_AT25DF_STATE_GEOMETRY_GET:
        {
            at25dfGeometry = DRV_MEMORY_GeometryGet(appAt25dfData.memoryHandle);

            if (at25dfGeometry == NULL)
            {
                appAt25dfData.state = APP_AT25DF_STATE_ERROR;
            }
            else
            {
                appAt25dfData.numReadBlocks  = (AT25DF_BUFFER_SIZE / at25dfGeometry->geometryTable[AT25DF_GEOMETRY_TABLE_READ_ENTRY].blockSize);
                appAt25dfData.numWriteBlocks = (AT25DF_BUFFER_SIZE / at25dfGeometry->geometryTable[AT25DF_GEOMETRY_TABLE_WRITE_ENTRY].blockSize);
                appAt25dfData.numEraseBlocks = (AT25DF_BUFFER_SIZE / at25dfGeometry->geometryTable[AT25DF_GEOMETRY_TABLE_ERASE_ENTRY].blockSize);
                appAt25dfData.state = APP_AT25DF_STATE_ERASE_FLASH;
            }
            break;
        }

        case APP_AT25DF_STATE_ERASE_FLASH:
        {
            xferDone = DRV_MEMORY_SyncErase(appAt25dfData.memoryHandle, BLOCK_START, appAt25dfData.numEraseBlocks);

            if (xferDone == false)
            {
                appAt25dfData.state = APP_AT25DF_STATE_ERROR;
            }
            else
            {
                appAt25dfData.state = APP_AT25DF_STATE_WRITE_MEMORY;
            }
            break;
        }

        case APP_AT25DF_STATE_WRITE_MEMORY:
        {
            xferDone = DRV_MEMORY_SyncWrite(appAt25dfData.memoryHandle, (void *)&appAt25dfData.writeBuffer, BLOCK_START, appAt25dfData.numWriteBlocks);

            if (xferDone == false)
            {
                appAt25dfData.state = APP_AT25DF_STATE_ERROR;
            }
            else
            {
                appAt25dfData.state = APP_AT25DF_STATE_READ_MEMORY;
            }
            break;
        }

        case APP_AT25DF_STATE_READ_MEMORY:
        {
            memset((void *)&appAt25dfData.readBuffer, 0, AT25DF_BUFFER_SIZE);

            xferDone = DRV_MEMORY_SyncRead(appAt25dfData.memoryHandle, (void *)&appAt25dfData.readBuffer, BLOCK_START, appAt25dfData.numReadBlocks);

            if (xferDone == false)
            {
                appAt25dfData.state = APP_AT25DF_STATE_ERROR;
            }
            else
            {
                appAt25dfData.state = APP_AT25DF_STATE_VERIFY_DATA;
            }
            break;
        }

        case APP_AT25DF_STATE_VERIFY_DATA:
        {
            if (!memcmp(appAt25dfData.writeBuffer, appAt25dfData.readBuffer, AT25DF_BUFFER_SIZE))
            {
                appAt25dfData.state = APP_AT25DF_STATE_SUCCESS;
            }
            else
            {
                appAt25dfData.state = APP_AT25DF_STATE_ERROR;
            }
            DRV_MEMORY_Close(appAt25dfData.memoryHandle);
            break;
        }

        case APP_AT25DF_STATE_SUCCESS:
        case APP_AT25DF_STATE_ERROR:
        default:
        {
            break;
        }
    }
}

/*******************************************************************************
 End of File
 */
