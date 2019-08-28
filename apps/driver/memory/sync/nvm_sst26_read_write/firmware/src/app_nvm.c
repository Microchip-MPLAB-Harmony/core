/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_nvm.c

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

#include "app_nvm.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

SYS_MEDIA_GEOMETRY *nvmGeometry = NULL;

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_NVM_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_NVM_DATA CACHE_ALIGN appNvmData;

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
    void APP_NVM_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_NVM_Initialize ( void )
{
    uint32_t i = 0;

    /* Place the App state machine in its initial state. */
    appNvmData.state = APP_NVM_STATE_OPEN_DRIVER;

    for (i = 0; i < NVM_BUFFER_SIZE; i++)
        appNvmData.writeBuffer[i] = i;
}


/******************************************************************************
  Function:
    void APP_NVM_Tasks ( void )

 Description:
    Demonstrates Erase, Write and Read operation of DRV_MEMORY in Buffer Model.
    Each case is a fall through when the request is queued up successfully.

  Remarks:
    See prototype in app.h.
 */

void APP_NVM_Tasks ( void )
{
    bool xferDone = false;

    /* Check the application's current state. */
    switch ( appNvmData.state )
    {
        case APP_NVM_STATE_OPEN_DRIVER:
        {
            appNvmData.memoryHandle = DRV_MEMORY_Open(DRV_MEMORY_INDEX_0, DRV_IO_INTENT_READWRITE);

            if (DRV_HANDLE_INVALID != appNvmData.memoryHandle)
            {
                appNvmData.state = APP_NVM_STATE_ERASE_FLASH;
            }
            else
            {
                break;
            }
        }

        case APP_NVM_STATE_GEOMETRY_GET:
        {
            nvmGeometry = DRV_MEMORY_GeometryGet(appNvmData.memoryHandle);

            if (nvmGeometry == NULL)
            {
                appNvmData.state = APP_NVM_STATE_ERROR;
                break;
            }

            appNvmData.numReadBlocks  = (NVM_BUFFER_SIZE / nvmGeometry->geometryTable[NVM_GEOMETRY_TABLE_READ_ENTRY].blockSize);
            appNvmData.numWriteBlocks = (NVM_BUFFER_SIZE / nvmGeometry->geometryTable[NVM_GEOMETRY_TABLE_WRITE_ENTRY].blockSize);
            appNvmData.numEraseBlocks = (NVM_BUFFER_SIZE / nvmGeometry->geometryTable[NVM_GEOMETRY_TABLE_ERASE_ENTRY].blockSize);
        }

        case APP_NVM_STATE_ERASE_FLASH:
        {
            xferDone = DRV_MEMORY_SyncErase(appNvmData.memoryHandle, BLOCK_START, appNvmData.numEraseBlocks);

            if (xferDone == false)
            {
                appNvmData.state = APP_NVM_STATE_ERROR;
                break;
            }
            else
            {
                appNvmData.state = APP_NVM_STATE_WRITE_MEMORY;
            }
        }

        case APP_NVM_STATE_WRITE_MEMORY:
        {
            xferDone = DRV_MEMORY_SyncWrite(appNvmData.memoryHandle, (void *)&appNvmData.writeBuffer, BLOCK_START, appNvmData.numWriteBlocks);

            if (xferDone == false)
            {
                appNvmData.state = APP_NVM_STATE_ERROR;
                break;
            }
            else
            {
                appNvmData.state = APP_NVM_STATE_READ_MEMORY;
            }
        }

        case APP_NVM_STATE_READ_MEMORY:
        {
            memset((void *)&appNvmData.readBuffer, 0, NVM_BUFFER_SIZE);

            xferDone = DRV_MEMORY_SyncRead(appNvmData.memoryHandle, (void *)&appNvmData.readBuffer, BLOCK_START, appNvmData.numReadBlocks);

            if (xferDone == false)
            {
                appNvmData.state = APP_NVM_STATE_ERROR;
                break;
            }
            else
            {
                appNvmData.state = APP_NVM_STATE_VERIFY_DATA;
            }
        }

        case APP_NVM_STATE_VERIFY_DATA:
        {
            if (!memcmp(appNvmData.writeBuffer, appNvmData.readBuffer, NVM_BUFFER_SIZE))
            {
                appNvmData.state = APP_NVM_STATE_SUCCESS;
            }
            else
            {
                appNvmData.state = APP_NVM_STATE_ERROR;
            }

            DRV_MEMORY_Close(appNvmData.memoryHandle);

            break;
        }

        case APP_NVM_STATE_SUCCESS:
        case APP_NVM_STATE_ERROR:
        default:
        {
            vTaskSuspend(NULL);
            break;
        }
    }
}
