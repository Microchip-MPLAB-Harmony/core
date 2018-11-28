/*******************************************************************************
  MPLAB Harmony Application Header File

  Company:
    Microchip Technology Inc.

  File Name:
    app_i2c_eeprom_sam_a5d2_xult.h

  Summary:
    This header file provides prototypes and definitions for the application.

  Description:
    This header file provides function prototypes and data type definitions for
    the application.  Some of these are required by the system (such as the
    "APP_I2C_EEPROM_SAM_A5D2_XULT_Initialize" and "APP_I2C_EEPROM_SAM_A5D2_XULT_Tasks" prototypes) and some of them are only used
    internally by the application (such as the "APP_I2C_EEPROM_SAM_A5D2_XULT_STATES" definition).  Both
    are defined here for convenience.
*******************************************************************************/

#ifndef _APP_I2C_EEPROM_SAM_A5D2_XULT_H
#define _APP_I2C_EEPROM_SAM_A5D2_XULT_H

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
#include "FreeRTOS.h"
#include "task.h"
#include "driver/i2c/drv_i2c.h"

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
#define APP_EEPROM_PAGE_SIZE                       16

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
    /* Application's state machine's initial state. */
    APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_INIT=0,

    APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_WRITE,

    APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_READ,

    APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_VERIFY,

    APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_ERROR,

    APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_IDLE,
    /* TODO: Define states used by the application state machine. */

} APP_I2C_EEPROM_SAM_A5D2_XULT_STATES;


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
    /* The application's current state */
    APP_I2C_EEPROM_SAM_A5D2_XULT_STATES state;

    /* TODO: Define any additional data used by the application. */
     DRV_HANDLE drvI2CHandle;

     uint8_t txBuffer[1 + APP_EEPROM_PAGE_SIZE];

     uint8_t rxBuffer[APP_EEPROM_PAGE_SIZE];

} APP_I2C_EEPROM_SAM_A5D2_XULT_DATA;

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
    void APP_I2C_EEPROM_SAM_A5D2_XULT_Initialize ( void )

  Summary:
     MPLAB Harmony application initialization routine.

  Description:
    This function initializes the Harmony application.  It places the
    application in its initial state and prepares it to run so that its
    APP_I2C_EEPROM_SAM_A5D2_XULT_Tasks function can be called.

  Precondition:
    All other system initialization routines should be called before calling
    this routine (in "SYS_Initialize").

  Parameters:
    None.

  Returns:
    None.

  Example:
    <code>
    APP_I2C_EEPROM_SAM_A5D2_XULT_Initialize();
    </code>

  Remarks:
    This routine must be called from the SYS_Initialize function.
*/

void APP_I2C_EEPROM_SAM_A5D2_XULT_Initialize ( void );


/*******************************************************************************
  Function:
    void APP_I2C_EEPROM_SAM_A5D2_XULT_Tasks ( void )

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
    APP_I2C_EEPROM_SAM_A5D2_XULT_Tasks();
    </code>

  Remarks:
    This routine must be called from SYS_Tasks() routine.
 */

void APP_I2C_EEPROM_SAM_A5D2_XULT_Tasks( void );



#endif /* _APP_I2C_EEPROM_SAM_A5D2_XULT_H */

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

/*******************************************************************************
 End of File
 */
