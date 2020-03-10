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

#include "app_sst26.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

#define APP_SST26_MOUNT_NAME          "/mnt/myDrive1"
#define APP_SST26_DEVICE_NAME         "/dev/mtda1"
#define APP_SST26_FS_TYPE             FAT

#define APP_SST26_FILE_NAME           "newfile.txt"

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

/* Work buffer used by FAT FS during Format */
uint8_t CACHE_ALIGN work[SYS_FS_FAT_MAX_SS];

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
    void APP_SST26_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_SST26_Initialize ( void )
{
    uint32_t i;

    /* Initialize the app state to wait for media attach. */
    appSST26Data.state = APP_SST26_MOUNT_DISK;

    for (i = 0; i < BUFFER_SIZE; i++)
    {
        appSST26Data.writeBuffer[i] = i;
    }
}

/******************************************************************************
  Function:
    void APP_SST26_Tasks ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_SST26_Tasks ( void )
{
    SYS_FS_FORMAT_PARAM opt = { 0 };

    /* Check the application's current state. */
    switch ( appSST26Data.state )
    {
        case APP_SST26_MOUNT_DISK:
        {
            /* Mount the disk */
            if(SYS_FS_Mount(APP_SST26_DEVICE_NAME, APP_SST26_MOUNT_NAME, APP_SST26_FS_TYPE, 0, NULL) != 0)
            {
                /* The disk could not be mounted. Try mounting again until
                 * the operation succeeds. */
                appSST26Data.state = APP_SST26_MOUNT_DISK;
            }
            else
            {
                /* Mount was successful. Format the disk. */
                appSST26Data.state = APP_SST26_FORMAT_DISK;
            }
            break;
        }

        case APP_SST26_FORMAT_DISK:
        {
            opt.fmt = SYS_FS_FORMAT_FAT;
            opt.au_size = 0;

            if (SYS_FS_DriveFormat (APP_SST26_MOUNT_NAME, &opt, (void *)work, SYS_FS_FAT_MAX_SS) != SYS_FS_RES_SUCCESS)
            {
                /* Format of the disk failed. */
                appSST26Data.state = APP_SST26_ERROR;
            }
            else
            {
                /* Format succeeded. Open a file. */
                appSST26Data.state = APP_SST26_OPEN_FILE;
            }
            break;
        }

        case APP_SST26_OPEN_FILE:
        {
            appSST26Data.fileHandle = SYS_FS_FileOpen(APP_SST26_MOUNT_NAME"/"APP_SST26_FILE_NAME, (SYS_FS_FILE_OPEN_WRITE_PLUS));

            if(appSST26Data.fileHandle == SYS_FS_HANDLE_INVALID)
            {
                /* File open unsuccessful */
                appSST26Data.state = APP_SST26_ERROR;
            }
            else
            {
                /* File open was successful. Write to the file. */
                appSST26Data.state = APP_SST26_WRITE_TO_FILE;
            }
            break;
        }

        case APP_SST26_WRITE_TO_FILE:
        {
            if(SYS_FS_FileWrite (appSST26Data.fileHandle, (void *)appSST26Data.writeBuffer, BUFFER_SIZE) == -1)
            {
                /* Failed to write to the file. */
                appSST26Data.state = APP_SST26_ERROR;
            }
            else
            {
                /* File write was successful. */
                appSST26Data.state = APP_SST26_FLUSH_FILE;
            }
            break;
        }

        case APP_SST26_FLUSH_FILE:
        {
            if (SYS_FS_FileSync(appSST26Data.fileHandle) != 0)
            {
                /* Could not flush the contents of the file. Error out. */
                appSST26Data.state = APP_SST26_ERROR;
            }
            else
            {
                /* Check the file status */
                appSST26Data.state = APP_SST26_READ_FILE_STAT;
            }
            break;
        }

        case APP_SST26_READ_FILE_STAT:
        {
            if(SYS_FS_FileStat(APP_SST26_MOUNT_NAME"/"APP_SST26_FILE_NAME, &appSST26Data.fileStatus) == SYS_FS_RES_FAILURE)
            {
                /* Reading file status was a failure */
                appSST26Data.state = APP_SST26_ERROR;
            }
            else
            {
                /* Read file size */
                appSST26Data.state = APP_SST26_READ_FILE_SIZE;
            }
            break;
        }

        case APP_SST26_READ_FILE_SIZE:
        {
            appSST26Data.fileSize = SYS_FS_FileSize(appSST26Data.fileHandle);
            if(appSST26Data.fileSize == -1)
            {
                /* Reading file size was a failure */
                appSST26Data.state = APP_SST26_ERROR;
            }
            else
            {
                if(appSST26Data.fileSize == appSST26Data.fileStatus.fsize)
                {
                    appSST26Data.state = APP_SST26_DO_FILE_SEEK;
                }
                else
                {
                    appSST26Data.state = APP_SST26_ERROR;
                }
            }
            break;
        }

        case APP_SST26_DO_FILE_SEEK:
        {
            if(SYS_FS_FileSeek( appSST26Data.fileHandle, appSST26Data.fileSize, SYS_FS_SEEK_SET ) == -1)
            {
                /* File seek caused an error */
                appSST26Data.state = APP_SST26_ERROR;
            }
            else
            {
                /* Check for End of file */
                appSST26Data.state = APP_SST26_CHECK_EOF;
            }
            break;
        }

        case APP_SST26_CHECK_EOF:
        {
            if(SYS_FS_FileEOF( appSST26Data.fileHandle ) == false )
            {
                /* Either, EOF is not reached or there was an error
                   In any case, for the application, its an error condition */
                appSST26Data.state = APP_SST26_ERROR;
            }
            else
            {
                appSST26Data.state = APP_SST26_DO_ANOTHER_FILE_SEEK;
            }
            break;
        }

        case APP_SST26_DO_ANOTHER_FILE_SEEK:
        {
            /* Move file pointer to begining of file */
            if(SYS_FS_FileSeek( appSST26Data.fileHandle, 0, SYS_FS_SEEK_SET ) == -1)
            {
                /* File seek caused an error */
                appSST26Data.state = APP_SST26_ERROR;
            }
            else
            {
                /* Check for original file content */
                appSST26Data.state = APP_SST26_READ_FILE_CONTENT;
            }
            break;
        }

        case APP_SST26_READ_FILE_CONTENT:
        {
            if(SYS_FS_FileRead(appSST26Data.fileHandle, (void *)appSST26Data.readBuffer, appSST26Data.fileSize) == -1)
            {
                /* There was an error while reading the file. Close the file
                 * and error out. */
                SYS_FS_FileClose(appSST26Data.fileHandle);
                appSST26Data.state = APP_SST26_ERROR;
            }
            else
            {
                if ((appSST26Data.fileSize != BUFFER_SIZE) || (memcmp(appSST26Data.readBuffer, appSST26Data.writeBuffer, BUFFER_SIZE) != 0))
                {
                    /* The written and the read data don't match. */
                    appSST26Data.state = APP_SST26_ERROR;
                }
                else
                {
                    /* The test was successful. */
                    appSST26Data.state = APP_SST26_CLOSE_FILE;
                }
            }
            break;
        }

        case APP_SST26_CLOSE_FILE:
        {
            /* Close the file */
            if (SYS_FS_FileClose(appSST26Data.fileHandle) != 0)
            {
                appSST26Data.state = APP_SST26_ERROR;
            }
            else
            {
                appSST26Data.state = APP_SST26_UNMOUNT_DISK;
            }
            break;
        }

        case APP_SST26_UNMOUNT_DISK:
        {
            /* Unmount the disk */
            if (SYS_FS_Unmount(APP_SST26_MOUNT_NAME) != 0)
            {
                appSST26Data.state = APP_SST26_ERROR;
            }
            else
            {
                appSST26Data.state = APP_SST26_IDLE;
            }
            break;
        }

        case APP_SST26_IDLE:
        case APP_SST26_ERROR:
        default:
        {
            /* Suspend the Thread as the Task is complete.
             * If completed with Idle then LED1 will Toggle via Monitor Task */
            vTaskSuspend(NULL);
            break;
        }

    }
}
