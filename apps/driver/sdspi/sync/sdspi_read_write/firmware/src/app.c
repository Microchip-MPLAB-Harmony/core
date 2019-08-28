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
#include "user.h"
#include <string.h>

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

static SYS_MEDIA_GEOMETRY* geometry = NULL;

/* Read Buffer */
static CACHE_ALIGN uint32_t readBuffer[SDSPI_BUFFER_SIZE];

/* Write Buffer*/
static CACHE_ALIGN uint32_t writeBuffer[SDSPI_BUFFER_SIZE];

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

    for (i = 0; i < SDSPI_BUFFER_SIZE; i++)
    {
        writeBuffer[i] = i;
    }
}


/******************************************************************************
  Function:
    void APP_Tasks ( void )

 Description:
    Demonstrates Erase, Write and Read operation of DRV_SDSPI driver.

  Remarks:
    See prototype in app.h.
 */

void APP_Tasks ( void )
{
    /* Check the application's current state. */
    switch ( appData.state )
    {
        case APP_STATE_OPEN_DRIVER:

            appData.sdspiHandle = DRV_SDSPI_Open(DRV_SDSPI_INDEX_0, DRV_IO_INTENT_READWRITE);

            if (appData.sdspiHandle != DRV_HANDLE_INVALID)
            {
                appData.state = APP_STATE_WAIT_FOR_SDCARD_ATTACH;
            }
            break;

        case APP_STATE_WAIT_FOR_SDCARD_ATTACH:

            if (DRV_SDSPI_IsAttached(appData.sdspiHandle) == true)
            {
                appData.state = APP_STATE_GEOMETRY_GET;
            }
            break;

        case APP_STATE_GEOMETRY_GET:

            geometry = DRV_SDSPI_GeometryGet(appData.sdspiHandle);

            if (geometry != NULL)
            {
                appData.numReadBlocks  = (SDSPI_DATA_SIZE / geometry->geometryTable[GEOMETRY_TABLE_READ_ENTRY].blockSize);
                appData.numWriteBlocks = (SDSPI_DATA_SIZE / geometry->geometryTable[GEOMETRY_TABLE_WRITE_ENTRY].blockSize);
                appData.numEraseBlocks = (SDSPI_DATA_SIZE / geometry->geometryTable[GEOMETRY_TABLE_ERASE_ENTRY].blockSize);
                appData.state = APP_STATE_WRITE_MEMORY;
            }
            else
            {
                appData.state = APP_STATE_ERROR;
            }
            break;

        case APP_STATE_WRITE_MEMORY:

            if (DRV_SDSPI_SyncWrite(appData.sdspiHandle, (void *)writeBuffer, BLOCK_START, appData.numWriteBlocks) == true)
            {
                appData.state = APP_STATE_READ_MEMORY;
            }
            else
            {
                appData.state = APP_STATE_ERROR;
            }

            break;

        case APP_STATE_READ_MEMORY:

            memset((void *)readBuffer, 0, SDSPI_DATA_SIZE);

            if (DRV_SDSPI_SyncRead(appData.sdspiHandle, (void *)readBuffer, BLOCK_START, appData.numReadBlocks) == true)
            {
                appData.state = APP_STATE_VERIFY_DATA;
            }
            else
            {
                appData.state = APP_STATE_ERROR;
            }

            break;

        case APP_STATE_VERIFY_DATA:

            if (!memcmp(writeBuffer, readBuffer, SDSPI_DATA_SIZE))
            {
                appData.state = APP_STATE_SUCCESS;
            }
            else
            {
                appData.state = APP_STATE_ERROR;
            }
            DRV_SDSPI_Close(appData.sdspiHandle);
            break;

        case APP_STATE_SUCCESS:
            LED_ON();
            break;

        case APP_STATE_ERROR:            
        default:
            LED_OFF();
            break;

    }
}

/*******************************************************************************
 End of File
 */
