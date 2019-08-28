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

#include "app.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

#define SDCARD_MOUNT_NAME    "/mnt/mydrive2"
#define SDCARD_DEV_NAME      "/dev/mmcblka1"
#define SDCARD_FILE_NAME     "FILE.txt"

#define NVM_MOUNT_NAME       "/mnt/mydrive1"
#define NVM_DEV_NAME         "/dev/nvma1"
#define NVM_FILE_NAME        "FILE.txt"

/* This data from NVM Disk    */
#define APP_DATA_LEN         23

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
    /* Intialize the app state to wait for
     * media attach. */
    appData.state = APP_MOUNT_DISK_MEDIA_NVM;
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
         case APP_MOUNT_DISK_MEDIA_NVM:
            if(SYS_FS_Mount(NVM_DEV_NAME, NVM_MOUNT_NAME, FAT, 0, NULL) != SYS_FS_RES_SUCCESS)
            {
                /* The disk could not be mounted. Try
                 * until success. */
                appData.state = APP_MOUNT_DISK_MEDIA_NVM;
                break;
            }

            appData.state = APP_MOUNT_DISK_MEDIA_SD;

            break;

         case APP_MOUNT_DISK_MEDIA_SD:
            if(SYS_FS_Mount(SDCARD_DEV_NAME, SDCARD_MOUNT_NAME, FAT, 0, NULL) != SYS_FS_RES_SUCCESS)
            {
                /* The disk could not be mounted. Try
                 * until success. */
                appData.state = APP_MOUNT_DISK_MEDIA_SD;
                break;
            }

            /* Mount was successful. Search for file form NVM */
            appData.state = APP_OPEN_DIRECTORY;

            break;

        case APP_OPEN_DIRECTORY:
            /* Open the root directory of NVM media and search for the file "FILE.TXT*/
            appData.dirHandle = SYS_FS_DirOpen(NVM_MOUNT_NAME"/");

            if(appData.dirHandle == SYS_FS_HANDLE_INVALID)
            {
                /* Could not open the directory. Error out*/
                appData.state = APP_ERROR;
            }
            else
            {
                /* Search Directory for the file */
                appData.state = APP_SEARCH_DIRECTORY;
            }
            break;

        case APP_SEARCH_DIRECTORY:
            /* Search for the file "FILE.TXT" with wild characters */
            /* Since, we are using LFN, initialize the structure accordingly */
            appData.dirStatus.lfname = (char *) appData.data;
            appData.dirStatus.lfsize = 64;

            if(SYS_FS_DirSearch(appData.dirHandle, "FIL*.*", SYS_FS_ATTR_ARC, &appData.dirStatus) == SYS_FS_RES_FAILURE)
            {
                /* Could not search the directory. Error out*/
                appData.state = APP_ERROR;
            }
            else
            {
                if(SYS_FS_DirClose(appData.dirHandle) == SYS_FS_RES_SUCCESS)
                {
                    /* Though, LFN is enabled, the file name "FILE.TXT" that we are searching, it fits in 8.3 format.
                     * Hence, the file name would be stored in "appData.dirStatus.fname" and not inside
                     * "appData.dirStatus.lfname" (or appData.data). In a real world case, the decision can be made
                     * by checking the contents of both the buffer. If any one of the buffer is NULL, the data will
                     * be in the other one. That check is not done here, since, this is a demo and we know the file
                     * name, that we are searching for.  */
                    /* Verify the searched file. Since there is only 1 file in the NVM, it should be the one,
                       we are looking for */
                    if((appData.dirStatus.fname[0] == 'F') && (appData.dirStatus.fname[1] == 'I') && (appData.dirStatus.fname[2] == 'L') &&
                            (appData.dirStatus.fname[3] == 'E') && (appData.dirStatus.fname[4] == '.') && (appData.dirStatus.fname[5] == 'T') &&
                            (appData.dirStatus.fname[6] == 'X') && (appData.dirStatus.fname[7] == 'T'))
                    {
                        /* Open the file */
                        appData.state = APP_OPEN_FILE;
                    }
                    else
                    {
                        /* File name does not match. Error out*/
                        appData.state = APP_ERROR;
                    }
                }
                else
                {
                    /* Directory close did not work. Error out*/
                    appData.state = APP_ERROR;
                }
            }
            break;

        case APP_OPEN_FILE:

            appData.fileHandle1 = SYS_FS_FileOpen(NVM_MOUNT_NAME"/"NVM_FILE_NAME, (SYS_FS_FILE_OPEN_READ));

            if(appData.fileHandle1 == SYS_FS_HANDLE_INVALID)
            {
                /* Could not open the file. Error out*/
                appData.state = APP_ERROR;
                break;
            }

            appData.fileHandle2 = SYS_FS_FileOpen(SDCARD_MOUNT_NAME"/"SDCARD_FILE_NAME, (SYS_FS_FILE_OPEN_WRITE));

            if(appData.fileHandle2 == SYS_FS_HANDLE_INVALID)
            {
                /* Could not open the file. Error out*/
                appData.state = APP_ERROR;
                break;
            }

            /* Try reading from NVM file.*/
            appData.state = APP_READ_FILE_FROM_NVM;

            break;

        case APP_READ_FILE_FROM_NVM:
            if(SYS_FS_FileRead(appData.fileHandle1, (void *)appData.data, APP_DATA_LEN) == -1)
            {
                /* Read was not successful. Close the file
                 * and error out.*/
                SYS_FS_FileClose(appData.fileHandle1);
                appData.state = APP_ERROR;
            }
            else
            {
                /* Read was successful. Close the file and
                 * open SDCARD file for write. */
                SYS_FS_FileClose(appData.fileHandle1);
                appData.state = APP_WRITE_TO_FILE_ON_SDCARD;
            }
            break;

        case APP_WRITE_TO_FILE_ON_SDCARD:

            if(SYS_FS_FileWrite(appData.fileHandle2, (const void *)appData.data, APP_DATA_LEN) == -1)
            {
                /* There was an error while writing the file.
                 * Close the file and error out. */
                SYS_FS_FileClose(appData.fileHandle2);
                appData.state = APP_ERROR;
            }
            else
            {
                /* The test was successful. Write a character to file. */
                appData.state = APP_WRITE_CHAR_TO_FILE_ON_SDCARD;
            }
            break;

        case APP_WRITE_CHAR_TO_FILE_ON_SDCARD:
            if(SYS_FS_FileCharacterPut(appData.fileHandle2, '\n') == SYS_FS_RES_FAILURE)
            {
                /* There was an error while writing the file.
                 * Close the file and error out. */
                SYS_FS_FileClose(appData.fileHandle2);
                appData.state = APP_ERROR;
            }
            else
            {
                /* The test was successful. Write a string to file. */
                appData.state = APP_WRITE_STRING_TO_FILE_ON_SDCARD;
            }
            break;

        case APP_WRITE_STRING_TO_FILE_ON_SDCARD:
            if(SYS_FS_FileStringPut(appData.fileHandle2, "Test is successful.") == SYS_FS_RES_FAILURE)
            {
                /* There was an error while writing the file.
                 * Close the file and error out. */
                SYS_FS_FileClose(appData.fileHandle2);
                appData.state = APP_ERROR;
            }
            else
            {
                /* The test was successful. Go to idle loop. */
                SYS_FS_FileClose(appData.fileHandle2);
                appData.state = APP_IDLE;
            }
            break;

        case APP_IDLE:
            /* The application comes here when the demo has completed
             * successfully. Glow LED. */
            LED_ON();
            break;

        case APP_ERROR:
            /* The application comes here when the demo has failed. */
            break;

        default:
            break;
    }

} //End of APP_Tasks


/*******************************************************************************
 End of File
 */
