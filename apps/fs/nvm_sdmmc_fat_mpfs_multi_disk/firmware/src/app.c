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
* Copyright (C) 2020 Microchip Technology Inc. and its subsidiaries.
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

#define SDCARD_MOUNT_NAME    SYS_FS_MEDIA_IDX0_MOUNT_NAME_VOLUME_IDX0
#define SDCARD_DEV_NAME      SYS_FS_MEDIA_IDX0_DEVICE_NAME_VOLUME_IDX0
#define SDCARD_FILE_NAME     "FILE.txt"

#define NVM_MOUNT_NAME       SYS_FS_MEDIA_IDX1_MOUNT_NAME_VOLUME_IDX0
#define NVM_DEV_NAME         SYS_FS_MEDIA_IDX1_DEVICE_NAME_VOLUME_IDX0
#define NVM_FILE_NAME        "abc.txt"

#define APP_DATA_LEN         13 // HELLO WORLD !
#define APP_TIMESTAMP_LEN    38 // File Modified on [dd/mm/yy hh:mm:ss]

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

/*******************************************************************************
  Function:
    void APP_SysFSEventHandler ( SYS_FS_EVENT event,void* eventData,uintptr_t context )

  Remarks:
    See prototype in app.h.
 */
void APP_SysFSEventHandler(SYS_FS_EVENT event,void* eventData,uintptr_t context)
{
    switch(event)
    {
        /* If the event is mount then check which media has been mounted */
        case SYS_FS_EVENT_MOUNT:
            if(strcmp((const char *)eventData, SDCARD_MOUNT_NAME) == 0)
            {
                appData.sdCardMountFlag = true;
            }
            else if(strcmp((const char *)eventData, NVM_MOUNT_NAME) == 0)
            {
                appData.nvmMountFlag = true;
            }
            break;
        /* If the event is unmount then check which media has been unmount */
        case SYS_FS_EVENT_UNMOUNT:
            if(strcmp((const char *)eventData, SDCARD_MOUNT_NAME) == 0)
            {
                appData.sdCardMountFlag = false;

                if (appData.state == APP_IDLE)
                {
                    appData.state = APP_MOUNT_WAIT;
                }
                else
                {
                    appData.state = APP_ERROR;
                }
                LED_OFF();
            }
            else if(strcmp((const char *)eventData, NVM_MOUNT_NAME) == 0)
            {
                appData.nvmMountFlag = false;
            }

            break;

        case SYS_FS_EVENT_ERROR:
            break;
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************

static void APP_SetRTCTime(void)
{
    struct tm sys_time = { 0 };

    sys_time.tm_hour    = BUILD_TIME_HOUR;
    sys_time.tm_min     = BUILD_TIME_MIN;
    sys_time.tm_sec     = BUILD_TIME_SEC;

    sys_time.tm_mday    = BUILD_DAY; 
    sys_time.tm_mon     = BUILD_MONTH;
    sys_time.tm_year    = BUILD_YEAR - APP_TM_STRUCT_REFERENCE_YEAR;

    /* Set RTC Time to current system time. */
    RTC_RTCCTimeSet(&sys_time);
}

/* This function overrides the default WEAK implementation
 * of get_fatttime() from diskio.c to use RTC.

 * This will be called from FAT FS code to update the timestamp
 * of modified files.
 */
uint32_t get_fattime(void)
{
    SYS_FS_TIME time    = { 0 };

    /* Get TimeStamp from RTC. */
    RTC_RTCCTimeGet(&appData.rtc_time);

    time.discreteTime.hour      = appData.rtc_time.tm_hour;
    time.discreteTime.minute    = appData.rtc_time.tm_min;
    time.discreteTime.second    = appData.rtc_time.tm_sec;

    time.discreteTime.day       = appData.rtc_time.tm_mday;
    time.discreteTime.month     = appData.rtc_time.tm_mon;

    /* For FAT FS, Years are calculated with offset from 1980 */
    time.discreteTime.year      = ((appData.rtc_time.tm_year + APP_TM_STRUCT_REFERENCE_YEAR) - APP_FAT_FS_REFERENCE_YEAR);

    return (time.packedTime);
}

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
    /* Intialize the app state to wait for media attach. */
    appData.state = APP_MOUNT_WAIT;

    appData.nvmMountFlag = false;
    appData.sdCardMountFlag = false;

    /* Set RTC to current system time */
    APP_SetRTCTime();

    /* register the event handler with media manager */
    SYS_FS_EventHandlerSet(APP_SysFSEventHandler,(uintptr_t)NULL);
}


/******************************************************************************
  Function:
    void APP_Tasks ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Tasks ( void )
{
    char timeStamp[APP_TIMESTAMP_LEN] = { 0 };

    /* Check the application's current state. */
    switch ( appData.state )
    {
        case APP_MOUNT_WAIT:
        {
            /* wait for the volume to get auto mounted */
            if(appData.sdCardMountFlag && appData.nvmMountFlag)
            {
                appData.state = APP_OPEN_FILE;
            }
            break;
        }

        case APP_OPEN_FILE:
        {
            appData.fileHandle1 = SYS_FS_FileOpen(NVM_MOUNT_NAME"/"NVM_FILE_NAME, (SYS_FS_FILE_OPEN_READ));

            if(appData.fileHandle1 == SYS_FS_HANDLE_INVALID)
            {
                /* Could not open the file. Error out*/
                appData.state = APP_ERROR;
                break;
            }

            appData.fileHandle2 = SYS_FS_FileOpen(SDCARD_MOUNT_NAME"/"SDCARD_FILE_NAME, (SYS_FS_FILE_OPEN_APPEND));

            if(appData.fileHandle2 == SYS_FS_HANDLE_INVALID)
            {
                /* Could not open the file. Error out*/
                appData.state = APP_ERROR;
                break;
            }

            /* Try reading from NVM file.*/
            appData.state = APP_READ_FILE_FROM_NVM;

            break;
        }

        case APP_READ_FILE_FROM_NVM:
        {
            if(SYS_FS_FileRead(appData.fileHandle1, (void *)appData.data, APP_DATA_LEN) == -1)
            {
                /* Read was not successful error out.*/
                appData.state = APP_ERROR;
            }
            else
            {
                /* Read was successful open SDCARD file for write. */
                appData.state = APP_WRITE_TO_FILE_ON_SDCARD;
            }

            SYS_FS_FileClose(appData.fileHandle1);

            break;
        }

        case APP_WRITE_TO_FILE_ON_SDCARD:
        {
            if(SYS_FS_FileWrite(appData.fileHandle2, (const void *)appData.data, APP_DATA_LEN) == -1)
            {
                /* There was an error while reading the file error out. */
                appData.state = APP_ERROR;
            }
            else
            {
                /* Flush the written Data to file. */
                appData.state = APP_FLUSH_FILE_FOR_TIMESTAMP;
            }

            break;
        }

        case APP_FLUSH_FILE_FOR_TIMESTAMP:
        {
            /* Force write data to file to get the latest timestamp from get_fattime()*/
            if (SYS_FS_FileSync(appData.fileHandle2) != 0)
            {
                /* Could not flush the contents of the file. Error out. */
                appData.state = APP_ERROR;
            }
            else
            {
                /* Write the Timestamp to file */
                appData.state = APP_WRITE_TIMESTAMP_TO_FILE_ON_SDCARD;
            }
            break;
        }

        case APP_WRITE_TIMESTAMP_TO_FILE_ON_SDCARD:
        {
            sprintf(&timeStamp[0], "File Modified On [%02d/%02d/%04d %02d:%02d:%02d]",
                    appData.rtc_time.tm_mday,
                    appData.rtc_time.tm_mon,
                    (appData.rtc_time.tm_year + APP_TM_STRUCT_REFERENCE_YEAR),
                    appData.rtc_time.tm_hour,
                    appData.rtc_time.tm_min,
                    appData.rtc_time.tm_sec
            );
            
            /* Log System time and temperature value to log file. */
            if(SYS_FS_FilePrintf(appData.fileHandle2, "\r\n%s\r\n", timeStamp) == SYS_FS_RES_FAILURE)
            {
                /* There was an error while reading the file error out. */
                appData.state = APP_ERROR;
            }
            else
            {
                /* The test was successful. Lets idle. */
                appData.state = APP_IDLE;
                SYS_FS_FileClose(appData.fileHandle2);
            }
            break;
        }
        case APP_IDLE:
        {
            /* The application comes here when the demo has completed
             * successfully.*/
            LED_ON();
            break;
        }

        case APP_ERROR:
        default:
        {
            break;
        }
    }
}



/*******************************************************************************
 End of File
 */
