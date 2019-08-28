/*******************************************************************************
  MPLAB Harmony Application Source File
  NVM FAT Single Disk Demo Application
  Company:
    Microchip Technology Inc.

  File Name:
    app_nvm.c

  Summary:
    This file contains the source code for the MPLAB Harmony application.
    NVM FAT Single Disk Demo
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
#include "app_nvm.h"

/* This application showcases the File operations with NVM as the media. To
 * begin with the file system image contains a file called "FILE.TXT" with
 * 4-byte data "Data".
 * The application does the following:
 * 1. Mounts the file system present on the NVM media.
 * 2. Opens a file called "FILE.TXT" in READ PLUS mode.
 * 3. Retrieves the file stat information for the file.
 * 4. Gets the file size and compares it with the size information present in
 *    the file stat structure.
 * 5. Does a file seek to the end of the file.
 * 6. Checks if the EOF has reached.
 * 7. Sets the file pointer to the beginning of the file.
 * 8. Reads the 4 byte data and checks if the expected data is present in the
 *    file.
 * 9. Appends 13 bytes of data to the file. Performs a file seek to the
 *    beginning of the appended data.
 * 10. Reads 13 bytes and checks if the expected data is present in the file.
 * 11. If there is no error in any of the above steps then the application will
 *     go into Idle state.
 * 12. If there is an error then the application will go into Error state.
 * */

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

#define APP_NVM_MOUNT_NAME          "/mnt/myDrive2"
#define APP_NVM_DEVICE_NAME         "/dev/nvma1"
#define APP_NVM_FS_TYPE             FAT

#define APP_NVM_FILE_NAME           "FILE.TXT"

#define WRITE_DATA_SIZE             13
#define ORIG_DATA_SIZE              4

/* This is the string that will written to the file */
const uint8_t writeData[WRITE_DATA_SIZE] = "Hello World";

/* This string contains the original value of FILE.txt (before being written by
 * the demo */
const uint8_t originalData[ORIG_DATA_SIZE] = "Data";

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
    void APP_NVM_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_NVM_Initialize ( void )
{
    /* Initialize the app state to wait for
     * media attach. */
    appNvmData.state = APP_NVM_MOUNT_DISK;
}


/******************************************************************************
  Function:
    void APP_NVM_Tasks ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_NVM_Tasks ( void )
{

    /* Check the application's current state. */
    switch ( appNvmData.state )
    {
        case APP_NVM_MOUNT_DISK:
        {
            if(SYS_FS_Mount(APP_NVM_DEVICE_NAME, APP_NVM_MOUNT_NAME, APP_NVM_FS_TYPE, 0, NULL) != 0)
            {
                /* The disk could not be mounted. Try mounting again until
                 * mount is successful. */
                appNvmData.state = APP_NVM_MOUNT_DISK;
            }
            else
            {
                /* Mount was successful. Open a file. */
                appNvmData.state = APP_NVM_OPEN_FILE;
            }
            break;
        }

        case APP_NVM_OPEN_FILE:
        {
            appNvmData.fileHandle = SYS_FS_FileOpen(APP_NVM_MOUNT_NAME"/"APP_NVM_FILE_NAME, SYS_FS_FILE_OPEN_READ_PLUS);
            if(appNvmData.fileHandle == SYS_FS_HANDLE_INVALID)
            {
                /* Failed to open the file. */
                appNvmData.state = APP_NVM_ERROR;
            }
            else
            {
                /* Opened file successfully. Read the file stat. */
                appNvmData.state = APP_NVM_READ_FILE_STAT;
            }
            break;
        }

        case APP_NVM_READ_FILE_STAT:
        {
            if(SYS_FS_FileStat(APP_NVM_MOUNT_NAME"/"APP_NVM_FILE_NAME, &appNvmData.fileStatus) == SYS_FS_RES_FAILURE)
            {
                /* Failed to read the file stat. */
                appNvmData.state = APP_NVM_ERROR;
            }
            else
            {
                /* Now find the size of the file using FileSize API. */
                appNvmData.state = APP_NVM_READ_FILE_SIZE;
            }
            break;
        }

        case APP_NVM_READ_FILE_SIZE:
        {
            appNvmData.fileSize = SYS_FS_FileSize(appNvmData.fileHandle);
            if(appNvmData.fileSize == -1)
            {
                /* Failed to read the file size. */
                appNvmData.state = APP_NVM_ERROR;
            }
            else
            {
                if(appNvmData.fileSize == appNvmData.fileStatus.fsize)
                {
                    appNvmData.state = APP_NVM_DO_FILE_SEEK;
                }
                else
                {
                    appNvmData.state = APP_NVM_ERROR;
                }
            }
            break;
        }

        case APP_NVM_DO_FILE_SEEK:
        {
            if(SYS_FS_FileSeek(appNvmData.fileHandle, appNvmData.fileSize, SYS_FS_SEEK_SET) == -1)
            {
                /* File seek caused an error */
                appNvmData.state = APP_NVM_ERROR;
            }
            else
            {
                /* Check for End of file */
                appNvmData.state = APP_NVM_CHECK_EOF;
            }
            break;
        }

        case APP_NVM_CHECK_EOF:
        {
            if(SYS_FS_FileEOF(appNvmData.fileHandle) == false )
            {
                /* Either, EOF is not reached or there was an error. */
                appNvmData.state = APP_NVM_ERROR;
            }
            else
            {
                appNvmData.state = APP_NVM_DO_ANOTHER_FILE_SEEK;
            }
            break;
        }

        case APP_NVM_DO_ANOTHER_FILE_SEEK:
        {
            /* Move file pointer to beginning of the file. */
            if(SYS_FS_FileSeek(appNvmData.fileHandle, 0, SYS_FS_SEEK_SET) == -1)
            {
                /* File seek caused an error */
                appNvmData.state = APP_NVM_ERROR;
            }
            else
            {
                /* Check for original file content */
                appNvmData.state = APP_NVM_READ_ORIGINAL_FILE_CONTENT;
            }
            break;
        }

        case APP_NVM_READ_ORIGINAL_FILE_CONTENT:
        {
            if(SYS_FS_FileRead(appNvmData.fileHandle, (void *)appNvmData.data, ORIG_DATA_SIZE) == -1)
            {
                /* There was an error while reading the file. Close the
                 * file and error out. */
                SYS_FS_FileClose(appNvmData.fileHandle);
                appNvmData.state = APP_NVM_ERROR;
            }
            else
            {
                if(memcmp(appNvmData.data, originalData, ORIG_DATA_SIZE) != 0)
                {
                    /* The written and the read data don't match. */
                    appNvmData.state = APP_NVM_ERROR;
                }
                else
                {
                    /* The test was successful. Move the file pointer to
                     * the end of original data. */
                    appNvmData.state = APP_NVM_FILE_SEEK_ORIG_DATA;
                }
            }
            break;
        }

        case APP_NVM_FILE_SEEK_ORIG_DATA:
        {
            /* Move file pointer to end original Data */
            if (SYS_FS_FileSeek(appNvmData.fileHandle, ORIG_DATA_SIZE, SYS_FS_SEEK_SET) == -1)
            {
                /* File seek caused an error */
                appNvmData.state = APP_NVM_ERROR;
            }
            else
            {
                /* Do a file write now */
                appNvmData.state = APP_NVM_WRITE_TO_FILE;
            }
            break;
        }

        case APP_NVM_WRITE_TO_FILE:
        {
            if(SYS_FS_FileWrite(appNvmData.fileHandle, (const void *)writeData, WRITE_DATA_SIZE) == -1)
            {
                /* Write was not successful. Close the file and error
                 * out. */
                SYS_FS_FileClose(appNvmData.fileHandle);
                appNvmData.state = APP_NVM_ERROR;
            }
            else
            {
                /* Flush the data to NVM. */
                SYS_FS_FileSync(appNvmData.fileHandle);
                /* Write was successful. Read the file content. */
                appNvmData.state = APP_NVM_FILE_SEEK_WRITE_DATA;
            }
            break;
        }

        case APP_NVM_FILE_SEEK_WRITE_DATA:
        {
            if(SYS_FS_FileSeek(appNvmData.fileHandle, -WRITE_DATA_SIZE, SYS_FS_SEEK_END) == -1)
            {
                /* Could not seek the file. Error out*/
                appNvmData.state = APP_NVM_ERROR;
            }
            else
            {
                /* Read the file content */
                appNvmData.state = APP_NVM_READ_VERIFY_FILE;
            }
            break;
        }

        case APP_NVM_READ_VERIFY_FILE:
        {
            if(SYS_FS_FileRead(appNvmData.fileHandle, (void *)appNvmData.data, WRITE_DATA_SIZE) == -1)
            {
                /* There was an error while reading the file.
                 * Close the file and error out. */
                appNvmData.state = APP_NVM_ERROR;
            }
            else
            {
                if(strcmp((const char *)appNvmData.data, (const char *)writeData) != 0)
                {
                    appNvmData.state = APP_NVM_ERROR;
                }
                else
                {
                    if (SYS_FS_Unmount(APP_NVM_MOUNT_NAME) == 0)
                    {
                        appNvmData.state = APP_NVM_IDLE;
                    }
                    else
                    {
                        appNvmData.state = APP_NVM_ERROR;
                    }
                }
            }

            SYS_FS_FileClose(appNvmData.fileHandle);

            break;
        }

        case APP_NVM_IDLE:
        case APP_NVM_ERROR:
        default:
        {
            /* Suspend the Thread as the Task is complete.
             * If completed with Idle then LED1 will Toggle via Monitor Task */
            vTaskSuspend(NULL);
            break;
        }
    }

} //End of APP_NVM_Tasks
