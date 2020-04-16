/*******************************************************************************
  MPLAB Harmony Application Header File

  Company:
    Microchip Technology Inc.

  File Name:
    app_i2c_eeprom.h

  Summary:
    This header file provides prototypes and definitions for the application.

  Description:
    This header file provides function prototypes and data type definitions for
    the application.  Some of these are required by the system (such as the
    "APP_I2C_EEPROM_Initialize" and "APP_I2C_EEPROM_Tasks" prototypes) and some of them are only used
    internally by the application (such as the "APP_I2C_EEPROM_STATES" definition).  Both
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

#ifndef _APP_I2C_EEPROM_H
#define _APP_I2C_EEPROM_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include "configuration.h"
#include "driver/i2c/drv_i2c.h"
#include "system/console/sys_console.h"

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
#define APP_EEPROM_NUM_TEMP_VALUES_TO_SAVE          5
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
    /* Initial state. */
    APP_EEPROM_STATE_INIT,

    /* Write temperature data to EERPOM */
    APP_EEPROM_STATE_WRITE,

    /* Wait for EEPROM write transfer to complete */
    APP_EEPROM_STATE_WAIT_TRANSFER_COMPLETE,

    /* Wait for EEPROM's internal write cycle to complete */
    APP_EEPROM_STATE_WAIT_WRITE_COMPLETE,

    /* Check if user requested to read the temperature data from EEPROM */
    APP_EEPROM_STATE_CHECK_READ_REQ,

    /* Read temperature data from EEPROM */
    APP_EEPROM_STATE_READ,

    /* Wait for temperature data read to complete */
    APP_EEPROM_STATE_WAIT_READ_COMPLETE,

    /* Error state */
    APP_EEPROM_STATE_ERROR,

    APP_EEPROM_STATE_IDLE,

} APP_EEPROM_STATES;


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
    APP_EEPROM_STATES  state;

    /* I2C driver client handle */
    DRV_HANDLE i2cHandle;
    
    SYS_CONSOLE_HANDLE consoleHandle;

    /* I2C driver transfer handle */
    DRV_I2C_TRANSFER_HANDLE transferHandle;

    /* Variable to hold the character entered on the console */
    uint8_t consoleData;

    /* Buffer to hold temperature data to be written to EEPROM */
    uint8_t txBuffer[2];

    /* Buffer to hold temperature data read from EEPROM */
    uint8_t rxBuffer[APP_EEPROM_NUM_TEMP_VALUES_TO_SAVE];

    /* Temperature value written to EEPROM */
    uint8_t temperature;

    /* Variable to hold transfer status of every transfer */
    volatile DRV_I2C_TRANSFER_EVENT transferStatus;

    /* Flag to indicate whether temperature is read from the temperature sensor */
    volatile bool isTemperatureReady;
      
    uint32_t currentWriteIndex;

    uint8_t dummyData;

} APP_EEPROM_DATA;


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
    void APP_I2C_EEPROM_Initialize ( void )

  Summary:
     MPLAB Harmony application initialization routine.

  Description:
    This function initializes the Harmony application.  It places the
    application in its initial state and prepares it to run so that its
    APP_Tasks function can be called.

  Precondition:
    All other system initialization routines should be called before calling
    this routine (in "SYS_Initialize").

  Parameters:
    None.

  Returns:
    None.

  Example:
    <code>
    APP_I2C_EEPROM_Initialize();
    </code>

  Remarks:
    This routine must be called from the SYS_Initialize function.
*/

void APP_I2C_EEPROM_Initialize ( void );


/*******************************************************************************
  Function:
    void APP_I2C_EEPROM_Tasks ( void )

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
    APP_I2C_EEPROM_Tasks();
    </code>

  Remarks:
    This routine must be called from SYS_Tasks() routine.
 */

void APP_I2C_EEPROM_Tasks( void );



#endif /* _APP_I2C_EEPROM_H */

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

/*******************************************************************************
 End of File
 */

