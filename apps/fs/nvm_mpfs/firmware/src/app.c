/*******************************************************************************
  MPLAB Harmony Application
  NVM MPFS Single Disk Demo Application
  Company:
    Microchip Technology Inc.

  File Name:
    app.c

  Summary:
   NVM MPFS Single Disk Demo

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

/* This demonstration shows an example of implementing a MPFS disk in device
 * Flash memory. The demonstration contains a MPFS disk image in the internal
 * Flash memory. The disk image contains two files named:
 * FILE.txt, Size = 11 bytes. The content of the file is: "Hello World".
 * TEST.txt, Size = 10 bytes. The content of the file is: "1234567890".
 *
 * The demonstration application logic is implemented as a state machine in the
 * APP_Tasks function in the file app.c.
 *
 * The application does the following:
 * 1. Mount the file system image present on the internal flash. The volume is
 *    mounted against a MPFS2 type file system and mounted at /mnt/myDrive/.
 * 2. After the mount is successful open a file named "FILE.txt" in read mode.
 * 3. Open a second file named "TEST.txt" also in read mode.
 * 4. Find the size of the file "FILE.txt" and check that size matches the
 *    known value of 11 bytes.
 * 5. Move the file pointer of the file "TEST.txt" 10 bytes from the end of the
 *    file.
 * 6. Read 10 bytes of data from the file and compare it against the known
 *    string 1234567890 using the strncmp function.
 * 7. If the string comparison is successful, then check for the EOF of the
 *    file.
 * 8. If there is no error in any of the above steps then the application will
 *    go into Idle state.
 * 9. If there is an error then the application will go into Error state.
 * */

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

#define FILE_TXT_SIZE  11 // "HELLO WORLD"
#define TEST_TXT_SIZE  10 // "1234567890"

/* This string is already present in a file in the disk image */
const uint8_t compareString[] = "1234567890";

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
    /* Initialize the app state to wait for media attach. */
    appData.state = APP_MOUNT_DISK;
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
        case APP_MOUNT_DISK:
        {
            if(SYS_FS_Mount("/dev/nvma1", "/mnt/myDrive", MPFS2, 0, NULL) != 0)
            {
                /* The disk could not be mounted. Keep trying until the
                 * mount operation is successful. */
                appData.state = APP_MOUNT_DISK;
            }
            else
            {
                /* Mount was successful. Open file. */
                appData.state = APP_OPEN_FILE_1;
            }
            break;
        }

        case APP_OPEN_FILE_1:
        {
            appData.fileHandle_1 = SYS_FS_FileOpen("/mnt/myDrive/FILE.txt", SYS_FS_FILE_OPEN_READ);
            if(appData.fileHandle_1 == SYS_FS_HANDLE_INVALID)
            {
                /* Could not open the file. Error out. */
                appData.state = APP_ERROR;
            }
            else
            {
                /* First file open was successful. Now open the second
                 * file. */
                appData.state = APP_OPEN_FILE_2;
            }
            break;
        }

        case APP_OPEN_FILE_2:
        {
            appData.fileHandle_2 = SYS_FS_FileOpen("/mnt/myDrive/TEST.txt", SYS_FS_FILE_OPEN_READ);
            if(appData.fileHandle_2 == SYS_FS_HANDLE_INVALID)
            {
                /* Could not open the file. Error out. */
                appData.state = APP_ERROR;
            }
            else
            {
                /* Second file open was successful. */
                appData.state = APP_DO_FILE_SIZE_CHECK;
            }
            break;
        }

        case APP_DO_FILE_SIZE_CHECK:
        {
            if(SYS_FS_FileSize(appData.fileHandle_1) != FILE_TXT_SIZE)
            {
                /* Incorrect file size. */
                appData.state = APP_ERROR;
            }
            else
            {
                appData.state = APP_DO_FILE_SEEK;
            }

            /* We are done with this file, hence close it */
            SYS_FS_FileClose(appData.fileHandle_1);
            break;
        }

        case APP_DO_FILE_SEEK:
        {
            if(SYS_FS_FileSeek(appData.fileHandle_2, -TEST_TXT_SIZE, SYS_FS_SEEK_END) != -TEST_TXT_SIZE)
            {
                /* File seek went wrong somewhere  */
                appData.state = APP_ERROR;
            }
            else
            {
                /* Compare the remaining file content with a known string */
                appData.state = APP_READ_VERIFY_CONTENT;
            }
            break;
        }

        case APP_READ_VERIFY_CONTENT:
        {
            if(SYS_FS_FileRead(appData.fileHandle_2, (void *)appData.data, TEST_TXT_SIZE) == -1)
            {
                /* There was an error while reading the file. Close the
                 * file and error out. */
                SYS_FS_FileClose(appData.fileHandle_2);
                appData.state = APP_ERROR;
            }
            else
            {
                if(strncmp((const char *)appData.data, (const char *)compareString, TEST_TXT_SIZE) != 0)
                {
                    /* The written and the read data don't match. */
                    appData.state = APP_ERROR;
                }
                else
                {
                    /* The test was successful. Lets idle. */
                    appData.state = APP_CHECK_EOF;
                }
            }
            break;
        }

        case APP_CHECK_EOF:
        {
            /* By now, we should have reached end of file */
            if(SYS_FS_FileEOF(appData.fileHandle_2) != true)
            {
                /* Error */
                appData.state = APP_ERROR;
            }
            else
            {
                /* We have completed all tests. Hence go to idle state */
                appData.state = APP_IDLE;
            }

            SYS_FS_FileClose(appData.fileHandle_2);

            break;
        }

        case APP_IDLE:
        {
            /* The application comes here when the demo has completed
             * successfully. Glow LED. */
            LED_ON();
            break;
        }

        case APP_ERROR:
        {
            /* The application comes here when the demo has failed. */
            break;
        }
        default:
        {
            break;
        }
    }

} //End of APP_Tasks
