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
#include "configuration.h"
#include "user.h"
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
/* Size of the string written to EEPROM must be less than or equal to the EEPROM page size */
#define APP_EEPROM_TEST_DATA                        "I2C EEPROM Demo"
#define APP_EEPROM_TEST_DATA_SIZE                   (sizeof(APP_EEPROM_TEST_DATA)-1)
#define APP_EEPROM_RX_BUFFER_SIZE                   APP_EEPROM_TEST_DATA_SIZE
#if APP_EEPROM_ADDR_LEN_BITS == 18 || APP_EEPROM_ADDR_LEN_BITS == 16
    /* For 18 bit address, A16 and A17 are part of the EEPROM slave address.
     * The A16 and A17 bits are set to 0 in this demonstration. */
    #define APP_EEPROM_NUM_ADDR_BYTES               2
#elif APP_EEPROM_ADDR_LEN_BITS == 8
    #define APP_EEPROM_NUM_ADDR_BYTES               1
#endif

#define APP_EEPROM_TX_BUFFER_SIZE                   (APP_EEPROM_TEST_DATA_SIZE + APP_EEPROM_NUM_ADDR_BYTES)

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
    APP_I2C_EEPROM_STATE_INIT=0,
            
    APP_I2C_EEPROM_STATE_READY_WAIT,

    APP_I2C_EEPROM_STATE_WRITE,

    APP_I2C_EEPROM_STATE_READ,

    APP_I2C_EEPROM_STATE_VERIFY,

    APP_I2C_EEPROM_STATE_SUCCESS,

    APP_I2C_EEPROM_STATE_ERROR,

    APP_I2C_EEPROM_STATE_IDLE,

} APP_I2C_EEPROM_STATES;


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
    APP_I2C_EEPROM_STATES state;

    /* TODO: Define any additional data used by the application. */
     DRV_HANDLE drvI2CHandle;

     uint8_t txBuffer[APP_EEPROM_TX_BUFFER_SIZE];

     uint8_t rxBuffer[APP_EEPROM_RX_BUFFER_SIZE];

     uint8_t dummyData;
} APP_I2C_EEPROM_DATA;


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


