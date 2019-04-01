/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_at24cm02_i2c_eeprom.c

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

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "app_at24cm02_i2c_eeprom.h"
#include <string.h>
// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************
#define APP_AT24CM02_EEPROM_MEMORY_ADDR                     0x00
#define APP_AT24CM02_EEPROM_MEMORY_ADDR1                    0x00
#define APP_AT24CM02_EEPROM_TEST_STRING                     "PIC32MX I2C DEMO"
#define APP_AT24CM02_EEPROM_TEST_STRING_SIZE                strlen(APP_AT24CM02_EEPROM_TEST_STRING)
#define APP_AT24CM02_EEPROM_EEPROM3_CLICK_SLAVE_ADDR        0x0054
// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_AT24CM02_I2C_EEPROM_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_AT24CM02_I2C_EEPROM_DATA app_at24cm02_i2c_eepromData;

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
    void APP_AT24CM02_I2C_EEPROM_Initialize ( void )

  Remarks:
    See prototype in app_at24cm02_i2c_eeprom.h.
 */

void APP_AT24CM02_I2C_EEPROM_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app_at24cm02_i2c_eepromData.state = APP_AT24CM02_I2C_EEPROM_STATE_INIT;



    /* TODO: Initialize your application's state machine and other
     * parameters.
     */
}


/******************************************************************************
  Function:
    void APP_AT24CM02_I2C_EEPROM_Tasks ( void )

  Remarks:
    See prototype in app_at24cm02_i2c_eeprom.h.
 */

void APP_AT24CM02_I2C_EEPROM_Tasks ( void )
{
    uint8_t dummyData = 0;
    static bool isSuccess = false;

    /* Check the application's current state. */
    switch ( app_at24cm02_i2c_eepromData.state )
    {
        case APP_AT24CM02_I2C_EEPROM_STATE_INIT:
            /* Open I2C driver instance */
            app_at24cm02_i2c_eepromData.drvI2CHandle = DRV_I2C_Open( DRV_I2C_INDEX_0, DRV_IO_INTENT_READWRITE);

            if(app_at24cm02_i2c_eepromData.drvI2CHandle != DRV_HANDLE_INVALID)
            {
                /* Optionally, if required, the application can change the
                 * default clock speed using the DRV_I2C_TransferSetup() API
                */
                app_at24cm02_i2c_eepromData.state = APP_AT24CM02_I2C_EEPROM_STATE_WRITE;
            }
            else
            {
                app_at24cm02_i2c_eepromData.state = APP_AT24CM02_I2C_EEPROM_STATE_ERROR;
            }
            break;

        case APP_AT24CM02_I2C_EEPROM_STATE_WRITE:

            /* Setup the data to be transmitted */
            app_at24cm02_i2c_eepromData.txBuffer[0] = APP_AT24CM02_EEPROM_MEMORY_ADDR;
            app_at24cm02_i2c_eepromData.txBuffer[1] = APP_AT24CM02_EEPROM_MEMORY_ADDR1;
            memcpy(&app_at24cm02_i2c_eepromData.txBuffer[2], APP_AT24CM02_EEPROM_TEST_STRING, APP_AT24CM02_EEPROM_TEST_STRING_SIZE);

            /* Write data to EEPROM */
            if (DRV_I2C_WriteTransfer( app_at24cm02_i2c_eepromData.drvI2CHandle, APP_AT24CM02_EEPROM_EEPROM3_CLICK_SLAVE_ADDR, (void *)app_at24cm02_i2c_eepromData.txBuffer, (2+APP_AT24CM02_EEPROM_TEST_STRING_SIZE)) == true)
            {
                /* Poll EEPROM busy status. EEPROM will NAK while write is in progress*/
                while (DRV_I2C_WriteTransfer( app_at24cm02_i2c_eepromData.drvI2CHandle, APP_AT24CM02_EEPROM_EEPROM3_CLICK_SLAVE_ADDR, (void *)&dummyData, 1 ) == false);
                app_at24cm02_i2c_eepromData.state = APP_AT24CM02_I2C_EEPROM_STATE_READ;
            }
            else
            {
                app_at24cm02_i2c_eepromData.state = APP_AT24CM02_I2C_EEPROM_STATE_ERROR;
            }
            break;

        case APP_AT24CM02_I2C_EEPROM_STATE_READ:
            /* Read data from EEPROM */
            if (DRV_I2C_WriteReadTransfer(app_at24cm02_i2c_eepromData.drvI2CHandle, APP_AT24CM02_EEPROM_EEPROM3_CLICK_SLAVE_ADDR, (void*)app_at24cm02_i2c_eepromData.txBuffer, 2, (void *)app_at24cm02_i2c_eepromData.rxBuffer, APP_AT24CM02_EEPROM_TEST_STRING_SIZE) == true)
            {
                app_at24cm02_i2c_eepromData.state = APP_AT24CM02_I2C_EEPROM_STATE_VERIFY;
            }
            else
            {
                app_at24cm02_i2c_eepromData.state = APP_AT24CM02_I2C_EEPROM_STATE_ERROR;
            }
            break;

        case APP_AT24CM02_I2C_EEPROM_STATE_VERIFY:
            /* Compare the read data with the written data */
            if (memcmp(app_at24cm02_i2c_eepromData.rxBuffer, &app_at24cm02_i2c_eepromData.txBuffer[2], APP_AT24CM02_EEPROM_TEST_STRING_SIZE) == 0)
            {
                isSuccess = true;
                app_at24cm02_i2c_eepromData.state = APP_AT24CM02_I2C_EEPROM_STATE_IDLE;
            }
            else
            {
                app_at24cm02_i2c_eepromData.state = APP_AT24CM02_I2C_EEPROM_STATE_ERROR;
            }
            DRV_I2C_Close(app_at24cm02_i2c_eepromData.drvI2CHandle);
            break;

        case APP_AT24CM02_I2C_EEPROM_STATE_ERROR:
            isSuccess = false;
            app_at24cm02_i2c_eepromData.state = APP_AT24CM02_I2C_EEPROM_STATE_IDLE;
            break;

        case APP_AT24CM02_I2C_EEPROM_STATE_IDLE:
            if (isSuccess == true)
            {
                LED_ON();
            }
            else
            {
                LED_OFF();
            }
            vTaskSuspend(NULL);
            break;
    }
}


/*******************************************************************************
 End of File
 */
