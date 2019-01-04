/*******************************************************************************
  MPLAB Harmony Application Header File

  Company:
    Microchip Technology Inc.

  File Name:
    app_at25df.h

  Summary:
    This header file provides prototypes and definitions for the application.

  Description:
    This header file provides function prototypes and data type definitions for
    the application.  Some of these are required by the system (such as the
    "APP_AT25DF_Initialize" and "APP_AT25DF_Tasks" prototypes) and some of them are only used
    internally by the application (such as the "APP_AT25DF_STATES" definition).  Both
    are defined here for convenience.
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

#ifndef APP_AT25DF_H
#define APP_AT25DF_H

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
#include "driver/memory/drv_memory.h"
#include "driver/spi_flash/at25df/drv_at25df.h"

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

/* Will Erase, Write and Read into 20 Sectors of 4KB each */
#define AT25DF_BUFFER_SIZE                 (81920U)

#define AT25DF_GEOMETRY_TABLE_READ_ENTRY   (0)
#define AT25DF_GEOMETRY_TABLE_WRITE_ENTRY  (1)
#define AT25DF_GEOMETRY_TABLE_ERASE_ENTRY  (2)

#define BLOCK_START                         0x0

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
    /* Open the flash driver */
    APP_AT25DF_STATE_OPEN_DRIVER,

    /* Wait for Open driver to complete */
    APP_AT25DF_STATE_OPEN_WAIT,

    /* Get the geometry details */
    APP_AT25DF_STATE_GEOMETRY_GET,

    /* Erase Flash */
    APP_AT25DF_STATE_ERASE_FLASH,

    /* Wait for Erase to complete */
    APP_AT25DF_STATE_ERASE_WAIT,

    /* Write to Memory */
    APP_AT25DF_STATE_WRITE_MEMORY,

    /* Wait for Write to complete */
    APP_AT25DF_STATE_WRITE_WAIT,

    /* Read From Memory */
    APP_AT25DF_STATE_READ_MEMORY,

    /* Wait for Read to complete */
    APP_AT25DF_STATE_READ_WAIT,

    /* Verify Data Read */
    APP_AT25DF_STATE_VERIFY_DATA,

    /* Transfer success */
    APP_AT25DF_STATE_SUCCESS,

    /* An app error has occurred */
    APP_AT25DF_STATE_ERROR

} APP_AT25DF_STATES;

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
    /* Application's current state */
    APP_AT25DF_STATES state;

    /* Driver Handle */
    DRV_HANDLE memoryHandle;

    /* Application transfer status */
    volatile bool xfer_done;

    /* Erase/Write/Read Command Handles*/
    DRV_MEMORY_COMMAND_HANDLE eraseHandle;
    DRV_MEMORY_COMMAND_HANDLE writeHandle;
    DRV_MEMORY_COMMAND_HANDLE readHandle;

    /* Number of read blocks*/
    uint32_t numReadBlocks;

    /* Number of read blocks*/
    uint32_t numWriteBlocks;

    /* Number of read blocks*/
    uint32_t numEraseBlocks;

    /* Read Buffer */
    uint8_t readBuffer[AT25DF_BUFFER_SIZE];

    /* Write Buffer*/
    uint8_t writeBuffer[AT25DF_BUFFER_SIZE];
} APP_AT25DF_DATA;

extern APP_AT25DF_DATA appAt25dfData;

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
    void APP_AT25DF_Initialize ( void )

  Summary:
     MPLAB Harmony application initialization routine.

  Description:
    This function initializes the Harmony application.  It places the
    application in its initial state and prepares it to run so that its
    APP_AT25DF_Tasks function can be called.

  Precondition:
    All other system initialization routines should be called before calling
    this routine (in "SYS_Initialize").

  Parameters:
    None.

  Returns:
    None.

  Example:
    <code>
    APP_AT25DF_Initialize();
    </code>

  Remarks:
    This routine must be called from the SYS_Initialize function.
*/

void APP_AT25DF_Initialize ( void );


/*******************************************************************************
  Function:
    void APP_AT25DF_Tasks ( void )

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
    APP_AT25DF_Tasks();
    </code>

  Remarks:
    This routine must be called from SYS_Tasks() routine.
 */

void APP_AT25DF_Tasks( void );


#endif /* APP_AT25DF_H */

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

/*******************************************************************************
 End of File
 */

