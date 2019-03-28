/*******************************************************************************
  MPLAB Harmony Application Header File

  Company:
    Microchip Technology Inc.

  File Name:
    app_l21.h

  Summary:
    This header file provides prototypes and definitions for the application.

  Description:
    This header file provides function prototypes and data type definitions for
    the application.  Some of these are required by the system (such as the
    "APP_L21_Initialize" and "APP_L21_Tasks" prototypes) and some of them are only used
    internally by the application (such as the "APP_L21_STATES" definition).  Both
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

#ifndef _APP_L21_H
#define _APP_L21_H

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
#include "peripheral/port/plib_port.h"
#include "driver/i2c/drv_i2c.h"
#include "driver/i2c/drv_i2c.h"
#include "peripheral/sercom/i2cm/plib_sercom2_i2c.h"
#include "peripheral/sercom/i2cm/plib_sercom_i2c_master.h"

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

    // *****************************************************************************
/* I2C Address for the EEPROM 3 CLICK Board.

  Summary:
    Defines the EEPROM 3 CLICK Board's I2C Address.

  Description:
    This #define defines the on-board EEPROM 3 CLICK Board's I2C Address. It is used
    by the TWIHS PLib API's to transmit and receive data.
*/

#define APP_L21_AT24CM_DEVICE_ADDR             0x0054

// *****************************************************************************
/* EEPROM AT24MAC402 Word Address.

  Summary:
    Defines the EEPROM 3 CLICK Board's Word Address.

  Description:
    This #define defines the EEPROM 3 CLICK Board's Word Address. Data is
    read/write from/to the location starting from this address.
 */

#define APP_L21_AT24CM_MEMORY_ADDR             0x00
#define APP_L21_AT24CM_MEMORY_ADDR1            0x00
// *****************************************************************************
/* Transmit data length.

  Summary:
    Defines the length of the data to be transmitted to EEPROM 3 CLICK Board.

  Description:
    This #define defines the length of the data to be tranmitted to the EEPROM 3 CLICK Board.
    This define is used by the TWIHS PLib Write API.
 */

#define APP_L21_WRITE_DATA_LENGTH            19

// *****************************************************************************
/* Acknowledge polling data length.

  Summary:
    Defines the length of the data to be transmitted to EEPROM 3 CLICK Board
    during Acknowledge polling.

  Description:
    This #define defines the length of the data to be tranmitted to the EEPROM 3 CLICK Board
    during Acknowledge polling. This define is used by the TWIHS
    PLib Write API.
 */

#define APP_L21_ACK_DATA_LENGTH                 1

// *****************************************************************************
/* Dummy write data length.

  Summary:
    Defines the length of the dummy bytes to be written to read actual data.

  Description:
    This #define defines the length of the dummy bytes(actually Address bytes)to be written to read actual data from EEPROM 3 CLICK Board.
 *  This define is used by the TWIHS PLib Read API.
 */

#define APP_L21_RECEIVE_DUMMY_WRITE_LENGTH           2

// *****************************************************************************
/* Receive data length.

  Summary:
    Defines the length of the data to be received from EEPROM 3 CLICK Board.

  Description:
    This #define defines the length of the data to be received from the EEPROM 3 CLICK Board.
 *  This define is used by the TWIHS PLib Read API.
 */

#define APP_L21_READ_DATA_LENGTH           17
    
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
    APP_L21_STATE_INIT=0,
            
   /* Application EEPROM ready state */
    APP_L21_STATE_IS_EEPROM_READY,
            
    /* Application transmit bytes state */
    APP_L21_STATE_DATA_WRITE,

    /* Application acknowledge state */
    APP_L21_STATE_ACK_CYCLE,
            
    /* Application data receive state */
    APP_L21_STATE_DATA_READ,
    
    /* Application data verify state */
    APP_L21_STATE_DATA_VERIFY,
            
    /* Application state update state */
    APP_L21_STATE_UPDATE,
            
    /* Application success state */
    APP_L21_STATE_SUCCESS,
            
    /* Application error state */
    APP_L21_STATE_ERROR,
            
    /* Application done state */
    APP_L21_STATE_DONE,

} APP_L21_STATES;


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
    APP_L21_STATES state;

    /* I2C Driver Handle */
    DRV_HANDLE drvI2CHandle;
    
    /* Ready transfer handle */
    DRV_I2C_TRANSFER_HANDLE hReadyTransfer;
    
    /* Write transfer handle */
    DRV_I2C_TRANSFER_HANDLE hWriteTransfer;
    
    /* Acknowledge transfer handle */
    DRV_I2C_TRANSFER_HANDLE hAckTransfer;

    /* Read transfer handle */
    DRV_I2C_TRANSFER_HANDLE hReadTransfer;
    
} APP_L21_DATA;


typedef enum
{
    /* Application EERPOM Write Cycle Init State */
    APP_L21_EEPROM_WRITE_CYCLE_INIT=0,
    
    /* Application EEPROM Write Cycle In Progress State */
    APP_L21_EEPROM_WRITE_CYCLE_IN_PROGRESS,
            
    /* Application EEPROM write Cycle Complete State */
    APP_L21_EEPROM_WRITE_CYCLE_COMPLETE,
            
} APP_EEPROM_WRITE_CYCLE;


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
    void APP_L21_Initialize ( void )

  Summary:
     MPLAB Harmony application initialization routine.

  Description:
    This function initializes the Harmony application.  It places the
    application in its initial state and prepares it to run so that its
    APP_L21_Tasks function can be called.

  Precondition:
    All other system initialization routines should be called before calling
    this routine (in "SYS_Initialize").

  Parameters:
    None.

  Returns:
    None.

  Example:
    <code>
    APP_L21_Initialize();
    </code>

  Remarks:
    This routine must be called from the SYS_Initialize function.
*/

void APP_L21_Initialize ( void );


/*******************************************************************************
  Function:
    void APP_L21_Tasks ( void )

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
    APP_L21_Tasks();
    </code>

  Remarks:
    This routine must be called from SYS_Tasks() routine.
 */

void APP_L21_Tasks( void );



#endif /* _APP_L21_H */

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

/*******************************************************************************
 End of File
 */

