/*******************************************************************************
  MPLAB Harmony Application Header File

  Company:
    Microchip Technology Inc.

  File Name:
    app.h

  Summary:
    This header file provides prototypes and definitions for the application.

  Description:
    This header file provides function prototypes and data type definitions for
    the application.  Some of these are required by the system (such as the
    "APP_NVM_Initialize" and "APP_NVM_Tasks" prototypes) and some of them are only used
    internally by the application (such as the "APP_NVM_STATES" definition).  Both
    are defined here for convenience.
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

#ifndef APP_NVM_H
#define APP_NVM_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>
#include "configuration.h"
#include "system/fs/sys_fs.h"
#include "osal/osal.h"
#include "nvm_disk_images.h"

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

extern "C" {

#endif
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************
#define NVM_BUFFER_SIZE                (64)

// *****************************************************************************
/* Application states

  Summary:
    Application states enumeration

  Description:
    This enumeration defines the valid application states.  These states
    determine the behavior of the application at various times.
*/

typedef enum
{
    /* The app mounts the disk */
    APP_NVM_MOUNT_DISK = 0,

    /* The app opens the file */
    APP_NVM_OPEN_FILE,

    /* The app checks the file status */
    APP_NVM_READ_FILE_STAT,

    /* The app checks the file size */
    APP_NVM_READ_FILE_SIZE,

    /* The app does a file seek */
    APP_NVM_DO_FILE_SEEK,

    /* The app check for EOF */
    APP_NVM_CHECK_EOF,

    /* The app does another file seek, to mover file pointer to begin of file */
    APP_NVM_DO_ANOTHER_FILE_SEEK,

    /* The app checks for original file content */
    APP_NVM_READ_ORIGINAL_FILE_CONTENT,

    /* The app does another file seek to move file pointer to the end of original data */
    APP_NVM_FILE_SEEK_ORIG_DATA,

    /* The app writes to the file */
    APP_NVM_WRITE_TO_FILE,

    /* The app moves the file point to end of start of write Data */
    APP_NVM_FILE_SEEK_WRITE_DATA,

    /* The app reads and verifies the write */
    APP_NVM_READ_VERIFY_FILE,

    /* The app closes the file and idles */
    APP_NVM_IDLE,

    /* An app error has occurred */
    APP_NVM_ERROR

} APP_NVM_STATES;


// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    Application strings and buffers are be defined outside this structure.
 */

typedef struct
{
    /* SYS_FS File handle */
    SYS_FS_HANDLE fileHandle;

    /* Application's current state */
    APP_NVM_STATES state;

    /* Application data buffer */
    uint8_t data[NVM_BUFFER_SIZE];

    uint32_t nBytesWritten;

    uint32_t nBytesRead;

    SYS_FS_FSTAT fileStatus;

    long fileSize;

} APP_NVM_DATA;

extern APP_NVM_DATA appNvmData;

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Routines
// *****************************************************************************
// *****************************************************************************
/* These routines are called by drivers when certain events occur.
*/


// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_NVM_Initialize ( void )

  Summary:
     MPLAB Harmony application initialization routine.

  Description:
    This function initializes the Harmony application.  It places the
    application in its initial state and prepares it to run so that its
    APP_NVM_Tasks function can be called.

  Precondition:
    All other system initialization routines should be called before calling
    this routine (in "SYS_Initialize").

  Parameters:
    None.

  Returns:
    None.

  Example:
    <code>
    APP_NVM_Initialize();
    </code>

  Remarks:
    This routine must be called from the SYS_Initialize function.
*/

void APP_NVM_Initialize ( void );


/*******************************************************************************
  Function:
    void APP_NVM_Tasks ( void )

  Summary:
    MPLAB Harmony Demo application tasks function

  Description:
    This routine is the Harmony Demo application's tasks function.  It
    defines the application's state machine and core logic.

  Precondition:
    The system and application initialization ("SYS_Initialize") should be
    called before calling this.

  Parameters:
    None.

  Returns:
    None.

  Example:
    <code>
    APP_NVM_Tasks();
    </code>

  Remarks:
    This routine must be called from SYS_Tasks() routine.
 */

void APP_NVM_Tasks( void );


#endif /* APP_NVM_H */

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END
