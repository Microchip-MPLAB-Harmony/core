/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_i2c_eeprom.c

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

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "app_i2c_eeprom.h"
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
#define APP_EEPROM_I2C_CLOCK_SPEED                 400000
#define APP_EEPROM_MEMORY_ADDR                     0x00
/* Size of the test string must be less than or equal to EEPROM page size (16 bytes)*/
#define APP_EEPROM_TEST_STRING                     "ATSAM TWIHS DEMO"
#define APP_EEPROM_TEST_STRING_SIZE                strlen(APP_EEPROM_TEST_STRING)

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_I2C_EEPROM_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_I2C_EEPROM_DATA appData;

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
    void APP_I2C_EEPROM_Initialize ( void )

  Remarks:
    See prototype in app_i2c_eeprom.h.
 */

void APP_I2C_EEPROM_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    appData.state = APP_I2C_EEPROM_STATE_INIT;



    /* TODO: Initialize your application's state machine and other
     * parameters.
     */
}


/******************************************************************************
  Function:
    void APP_I2C_EEPROM_Tasks ( void )

  Remarks:
    See prototype in app_i2c_eeprom.h.
 */

void APP_I2C_EEPROM_Tasks ( void )
{
    uint8_t dummyData = 0;
    static bool isSuccess = false;

    /* Check the application's current state. */
    switch(appData.state)
    {
        case APP_I2C_EEPROM_STATE_INIT:
            /* Open I2C driver instance */
            appData.drvI2CHandle = DRV_I2C_Open( DRV_I2C_INDEX_0, DRV_IO_INTENT_READWRITE);

            if(appData.drvI2CHandle != DRV_HANDLE_INVALID)
            {
                /* Optionally, if required, the application can change the
                 * default clock speed using the DRV_I2C_TransferSetup() API
                */
                appData.state = APP_I2C_EEPROM_STATE_WRITE;
            }
            else
            {
                appData.state = APP_I2C_EEPROM_STATE_ERROR;
            }
            break;

        case APP_I2C_EEPROM_STATE_WRITE:

            /* Setup the data to be transmitted */
            appData.txBuffer[0] = APP_EEPROM_MEMORY_ADDR;
            memcpy(&appData.txBuffer[1], APP_EEPROM_TEST_STRING, APP_EEPROM_TEST_STRING_SIZE);

            /* Write data to EEPROM */
            if (DRV_I2C_WriteTransfer( appData.drvI2CHandle, APP_EEPROM_AT24MAC402_SLAVE_ADDR, (void *)appData.txBuffer, (1+APP_EEPROM_TEST_STRING_SIZE)) == true)
            {
                /* Poll EEPROM busy status. EEPROM will NAK while write is in progress*/
                while (DRV_I2C_WriteTransfer( appData.drvI2CHandle, APP_EEPROM_AT24MAC402_SLAVE_ADDR, (void *)&dummyData, 1 ) == false);
                appData.state = APP_I2C_EEPROM_STATE_READ;
            }
            else
            {
                appData.state = APP_I2C_EEPROM_STATE_ERROR;
            }
            break;

        case APP_I2C_EEPROM_STATE_READ:
            /* Read data from EEPROM */
            if (DRV_I2C_WriteReadTransfer(appData.drvI2CHandle, APP_EEPROM_AT24MAC402_SLAVE_ADDR, (void*)appData.txBuffer, 1, (void *)appData.rxBuffer, APP_EEPROM_TEST_STRING_SIZE) == true)
            {
                appData.state = APP_I2C_EEPROM_STATE_VERIFY;
            }
            else
            {
                appData.state = APP_I2C_EEPROM_STATE_ERROR;
            }
            break;

        case APP_I2C_EEPROM_STATE_VERIFY:
            /* Compare the read data with the written data */
            if (memcmp(appData.rxBuffer, &appData.txBuffer[1], APP_EEPROM_TEST_STRING_SIZE) == 0)
            {
                isSuccess = true;
                appData.state = APP_I2C_EEPROM_STATE_IDLE;
            }
            else
            {
                appData.state = APP_I2C_EEPROM_STATE_ERROR;
            }
            DRV_I2C_Close(appData.drvI2CHandle);
            break;

        case APP_I2C_EEPROM_STATE_ERROR:
            isSuccess = false;
            appData.state = APP_I2C_EEPROM_STATE_IDLE;
            break;

        case APP_I2C_EEPROM_STATE_IDLE:
            if (isSuccess == true)
            {
                LED1_On();
            }
            vTaskSuspend(NULL);
            break;
    }
}


/*******************************************************************************
 End of File
 */
