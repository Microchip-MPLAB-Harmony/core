/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_i2c_eeprom_sam_a5d2_xult.c

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

#include "app_i2c_eeprom_sam_a5d2_xult.h"
#include "bsp/bsp.h"
#include "definitions.h"
#include <string.h>

/*
 * EEPROM AT24MAC402
 * EEPROM Address Range: 00h to FFh (256 bytes)
 * EEPROM Page Size: 16 bytes
 */

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************
#define APP_EEPROM_MEMORY_ADDR                     0x00
/* Size of the test string must be less than or equal to EEPROM page size (16 bytes)*/
#define APP_EEPROM_TEST_STRING                     "ATSAM TWIHS DEMO"
#define APP_EEPROM_TEST_STRING_SIZE                strlen(APP_EEPROM_TEST_STRING)
#define APP_EEPROM_AT24MAC402_SLAVE_ADDR           0x0054
#define LED_On() LED_BLUE_On()
// *****************************************************************************

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_I2C_EEPROM_SAM_A5D2_XULT_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_I2C_EEPROM_SAM_A5D2_XULT_DATA app_i2c_eeprom_sam_a5d2_xultData;

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
    void APP_I2C_EEPROM_SAM_A5D2_XULT_Initialize ( void )

  Remarks:
    See prototype in app_i2c_eeprom_sam_a5d2_xult.h.
 */

void APP_I2C_EEPROM_SAM_A5D2_XULT_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app_i2c_eeprom_sam_a5d2_xultData.state = APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_INIT;



    /* TODO: Initialize your application's state machine and other
     * parameters.
     */
}


/******************************************************************************
  Function:
    void APP_I2C_EEPROM_SAM_A5D2_XULT_Tasks ( void )

  Remarks:
    See prototype in app_i2c_eeprom_sam_a5d2_xult.h.
 */

void APP_I2C_EEPROM_SAM_A5D2_XULT_Tasks ( void )
{
    uint8_t dummyData = 0;
    static bool isSuccess = false;

    /* Check the application's current state. */
    switch(app_i2c_eeprom_sam_a5d2_xultData.state)
    {
        case APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_INIT:
            /* Open I2C driver instance */
            app_i2c_eeprom_sam_a5d2_xultData.drvI2CHandle = DRV_I2C_Open( DRV_I2C_INDEX_0, DRV_IO_INTENT_READWRITE);

            if(app_i2c_eeprom_sam_a5d2_xultData.drvI2CHandle != DRV_HANDLE_INVALID)
            {
                /* Optionally, if required, the application can change the
                 * default clock speed using the DRV_I2C_TransferSetup() API
                */
                app_i2c_eeprom_sam_a5d2_xultData.state = APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_WRITE;
            }
            else
            {
                app_i2c_eeprom_sam_a5d2_xultData.state = APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_ERROR;
            }
            break;

        case APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_WRITE:

            /* Setup the data to be transmitted */
            app_i2c_eeprom_sam_a5d2_xultData.txBuffer[0] = APP_EEPROM_MEMORY_ADDR;
            memcpy(&app_i2c_eeprom_sam_a5d2_xultData.txBuffer[1], APP_EEPROM_TEST_STRING, APP_EEPROM_TEST_STRING_SIZE);

            /* Write data to EEPROM */
            if (DRV_I2C_WriteTransfer( app_i2c_eeprom_sam_a5d2_xultData.drvI2CHandle, APP_EEPROM_AT24MAC402_SLAVE_ADDR, (void *)app_i2c_eeprom_sam_a5d2_xultData.txBuffer, (1+APP_EEPROM_TEST_STRING_SIZE)) == true)
            {
                /* Poll EEPROM busy status. EEPROM will NAK while write is in progress*/
                while (DRV_I2C_WriteTransfer( app_i2c_eeprom_sam_a5d2_xultData.drvI2CHandle, APP_EEPROM_AT24MAC402_SLAVE_ADDR, (void *)&dummyData, 1 ) == false);
                app_i2c_eeprom_sam_a5d2_xultData.state = APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_READ;
            }
            else
            {
                app_i2c_eeprom_sam_a5d2_xultData.state = APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_ERROR;
            }
            break;

        case APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_READ:
            /* Read data from EEPROM */
            if (DRV_I2C_WriteReadTransfer(app_i2c_eeprom_sam_a5d2_xultData.drvI2CHandle, APP_EEPROM_AT24MAC402_SLAVE_ADDR, (void*)app_i2c_eeprom_sam_a5d2_xultData.txBuffer, 1, (void *)app_i2c_eeprom_sam_a5d2_xultData.rxBuffer, APP_EEPROM_TEST_STRING_SIZE) == true)
            {
                app_i2c_eeprom_sam_a5d2_xultData.state = APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_VERIFY;
            }
            else
            {
                app_i2c_eeprom_sam_a5d2_xultData.state = APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_ERROR;
            }
            break;

        case APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_VERIFY:
            /* Compare the read data with the written data */
            if (memcmp(app_i2c_eeprom_sam_a5d2_xultData.rxBuffer, &app_i2c_eeprom_sam_a5d2_xultData.txBuffer[1], APP_EEPROM_TEST_STRING_SIZE) == 0)
            {
                isSuccess = true;
                app_i2c_eeprom_sam_a5d2_xultData.state = APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_IDLE;
            }
            else
            {
                app_i2c_eeprom_sam_a5d2_xultData.state = APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_ERROR;
            }
            DRV_I2C_Close(app_i2c_eeprom_sam_a5d2_xultData.drvI2CHandle);
            break;

        case APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_ERROR:
            isSuccess = false;
            app_i2c_eeprom_sam_a5d2_xultData.state = APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_IDLE;
            break;

        case APP_I2C_EEPROM_SAM_A5D2_XULT_STATE_IDLE:
            if (isSuccess == true)
            {
                LED_On();
            }
            vTaskSuspend(NULL);
            break;
    }
}


/*******************************************************************************
 End of File
 */