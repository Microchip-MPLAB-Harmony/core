/*******************************************************************************
  MPLAB Harmony Application Header File

  Company:
    Microchip Technology Inc.

  File Name:
    app_sam_a5d2_xult.h

  Summary:
    This header file provides prototypes and definitions for the application.

  Description:
    This header file provides function prototypes and data type definitions for
    the application.  Some of these are required by the system (such as the
    "APP_SAM_A5D2_XULT_Initialize" and "APP_SAM_A5D2_XULT_Tasks" prototypes) and some of them are only used
    internally by the application (such as the "APP_SAM_A5D2_XULT_STATES" definition).  Both
    are defined here for convenience.
*******************************************************************************/

#ifndef _APP_SAM_A5D2_XULT_H
#define _APP_SAM_A5D2_XULT_H

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

// *****************************************************************************
/* I2C Address for the on-board EEPROM AT24MAC402.

  Summary:
    Defines the on-board EEPROM AT24MAC402's I2C Address.

  Description:
    This #define defines the on-board EEPROM AT24MAC402's I2C Address. It is used 
    by the I2C Driver API's to write and read data.
*/

#define APP_AT24MAC_DEVICE_ADDR             0x0054

// *****************************************************************************
/* EEPROM AT24MAC402 Word Address.

  Summary:
    Defines the on-board EEPROM AT24MAC402 Word Address.

  Description:
    This #define defines the on-board EEPROM AT24MAC402 Word Address. Data is 
    read/write from/to the location starting from this address. 
 */
    
#define APP_AT24MAC_MEMORY_ADDR             0x00

// *****************************************************************************
/* Write data length.

  Summary:
    Defines the length of the data to be written to on-board EEPROM AT24MAC402.

  Description:
    This #define defines the length of the data to be written to the on-board 
    EEPROM AT24MAC402. This define is used by the I2C Driver write API.
 */

#define APP_WRITE_DATA_LENGTH            17

// *****************************************************************************
/* Acknowledge polling data length.

  Summary:
    Defines the length of the data to be written to on-board EEPROM AT24MAC402 
    during Acknowledge polling.

  Description:
    This #define defines the length of the data to be written to the on-board 
    EEPROM AT24MAC402 during Acknowledge polling. This define is used by the I2C
    Driver Transmit API.
 */
    
#define APP_ACK_DATA_LENGTH                 1

// *****************************************************************************
/* Read data length.

  Summary:
    Defines the length of the data to be read from on-board EEPROM AT24MAC402.

  Description:
    This #define defines the length of the data to be read from the on-board 
    EEPROM AT24MAC402. This define is used by the I2C Driver Read API.
 */

#define APP_READ_DATA_LENGTH             16

/* Transfer status enum

  Summary:
    Enumerator to define transfer status.

  Description:
    This enumerator defines all the possible transfer states.

  Remarks:
    None.
*/
typedef enum
{
    APP_TRANSFER_STATUS_IN_PROGRESS,
    APP_TRANSFER_STATUS_SUCCESS,
    APP_TRANSFER_STATUS_ERROR,
    APP_TRANSFER_STATUS_IDLE,

} APP_TRANSFER_STATUS;    

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
    APP_SAM_A5D2_XULT_STATE_INIT=0,

    /* Is EEPROM ready */
    APP_SAM_A5D2_XULT_STATE_IS_EEPROM_READY,
            
    /* EEPROM write state */
	APP_SAM_A5D2_XULT_STATE_DATA_WRITE,
    
    /* Wait for EEPROM write to complete */
    APP_SAM_A5D2_XULT_STATE_WAIT_WRITE_COMPLETE,
            
    /* Check if EEPROM's internal write cycle has completed */
    APP_SAM_A5D2_XULT_STATE_EEPROM_CHECK_INTERNAL_WRITE_STATUS,

    /* Read data from EEPROM */
    APP_SAM_A5D2_XULT_STATE_DATA_READ,
            
    /* Wait for the read to complete */
    APP_SAM_A5D2_XULT_STATE_WAIT_READ_COMPLETE,
	
    /* Verify the read data with the written data */
    APP_SAM_A5D2_XULT_STATE_DATA_VERIFY,
                            
    /* Application success state */
    APP_SAM_A5D2_XULT_STATE_SUCCESS,
            
    /* Application error state */
    APP_SAM_A5D2_XULT_STATE_ERROR,
            
    /* Application idle state */
    APP_SAM_A5D2_XULT_STATE_IDLE,

} APP_SAM_A5D2_XULT_STATES;


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
    APP_SAM_A5D2_XULT_STATES state;

    /* I2C Driver Handle */
    DRV_HANDLE drvI2CHandle;
    
    /* Ready transfer handle */
    DRV_I2C_TRANSFER_HANDLE transferHandle;        
    
    /* Transfer status */
    volatile APP_TRANSFER_STATUS transferStatus;

} APP_SAM_A5D2_XULT_DATA;

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
    void APP_SAM_A5D2_XULT_Initialize ( void )

  Summary:
     MPLAB Harmony application initialization routine.

  Description:
    This function initializes the Harmony application.  It places the
    application in its initial state and prepares it to run so that its
    APP_SAM_A5D2_XULT_Tasks function can be called.

  Precondition:
    All other system initialization routines should be called before calling
    this routine (in "SYS_Initialize").

  Parameters:
    None.

  Returns:
    None.

  Example:
    <code>
    APP_SAM_A5D2_XULT_Initialize();
    </code>

  Remarks:
    This routine must be called from the SYS_Initialize function.
*/

void APP_SAM_A5D2_XULT_Initialize ( void );


/*******************************************************************************
  Function:
    void APP_SAM_A5D2_XULT_Tasks ( void )

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
    APP_SAM_A5D2_XULT_Tasks();
    </code>

  Remarks:
    This routine must be called from SYS_Tasks() routine.
 */

void APP_SAM_A5D2_XULT_Tasks( void );



#endif /* _APP_SAM_A5D2_XULT_H */

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

/*******************************************************************************
 End of File
 */

