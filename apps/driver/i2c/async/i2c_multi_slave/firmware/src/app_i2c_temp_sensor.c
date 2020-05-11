/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_i2c_temp_sensor.c

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

#include "app_i2c_temp_sensor.h"
#include "system/console/sys_console.h"
// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************
#define APP_TEMP_I2C_CLOCK_SPEED                    400000
#define APP_TEMP_SLAVE_ADDR                         0x004B
#define APP_TEMP_TEMPERATURE_REG_ADDR               0x00
#define APP_TEMP_SAMPLING_TIME                      1000

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_I2C_TEMP_SENSOR_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_TEMP_DATA appTempData;

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

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

static void APP_I2C_TEMP_SENSOR_TimerCallback ( uintptr_t context )
{
    appTempData.tmrExpired = true;
}

static void APP_I2C_TEMP_SENSOR_EventHandler(
    DRV_I2C_TRANSFER_EVENT event,
    DRV_I2C_TRANSFER_HANDLE transferHandle,
    uintptr_t context
)
{
    switch(event)
    {
        case DRV_I2C_TRANSFER_EVENT_COMPLETE:
            appTempData.isTransferDone = true;
            break;
        case DRV_I2C_TRANSFER_EVENT_ERROR:
            appTempData.state = APP_TEMP_STATE_ERROR;
            break;
        default:
            break;
    }
}
/*******************************************************************************
  Function:
    void APP_I2C_TEMP_SENSOR_Initialize ( void )

  Remarks:
    See prototype in app_i2c_temp_sensor.h.
 */

void APP_I2C_TEMP_SENSOR_Initialize ( void )
{
    /* Initialize the Temperature Sensor Application data */
    appTempData.state          = APP_TEMP_STATE_INIT;
    appTempData.i2cHandle      = DRV_HANDLE_INVALID;
    appTempData.transferHandle = DRV_I2C_TRANSFER_HANDLE_INVALID;
    appTempData.tmrExpired     = false;
}

/******************************************************************************
  Function:
    void APP_I2C_TEMP_SENSOR_Tasks ( void )

  Remarks:
    See prototype in app_i2c_temp_sensor.h.
 */

void APP_I2C_TEMP_SENSOR_Tasks ( void )
{
    int16_t temp;

    /* Check the application's current state. */
    switch ( appTempData.state )
    {
        case APP_TEMP_STATE_INIT:

            /* Open I2C driver client */
            appTempData.i2cHandle = DRV_I2C_Open( DRV_I2C_INDEX_0, DRV_IO_INTENT_READWRITE );
            if (appTempData.i2cHandle != DRV_HANDLE_INVALID)
            {
                /* Register the I2C Driver client event callback */
                DRV_I2C_TransferEventHandlerSet(appTempData.i2cHandle, APP_I2C_TEMP_SENSOR_EventHandler, 0);

                /* Register the Periodic Timer callback */
                appTempData.tmrHandle = SYS_TIME_CallbackRegisterMS(APP_I2C_TEMP_SENSOR_TimerCallback, 0, APP_TEMP_SAMPLING_TIME, SYS_TIME_PERIODIC);
                if (appTempData.tmrHandle == SYS_TIME_HANDLE_INVALID)
                {
                    /* Could not start a periodic timer */
                    appTempData.state = APP_TEMP_STATE_ERROR;
                }
                else
                {
                    appTempData.state = APP_TEMP_STATE_READ_TEMPERATURE;
                }                                
            }
            else
            {
                appTempData.state = APP_TEMP_STATE_ERROR;
            }
            break;

        case APP_TEMP_STATE_READ_TEMPERATURE:

            if (appTempData.tmrExpired == true)
            {
                appTempData.tmrExpired = false;

                SYS_CONSOLE_PRINT("Reading temperature from sensor...");

                /* Initiate a read transfer to read temperature value from temperature sensor */
                appTempData.registerAddr = APP_TEMP_TEMPERATURE_REG_ADDR;

                DRV_I2C_WriteReadTransferAdd(appTempData.i2cHandle, APP_TEMP_SLAVE_ADDR, (void*)&appTempData.registerAddr, 1, (void *)appTempData.rxBuffer, 2, &appTempData.transferHandle );

                if (appTempData.transferHandle != DRV_I2C_TRANSFER_HANDLE_INVALID)
                {
                    appTempData.state = APP_TEMP_STATE_WAIT_TRANSFER_COMPLETE;
                }
                else
                {
                    appTempData.state = APP_TEMP_STATE_ERROR;
                }
            }
            break;

        case APP_TEMP_STATE_WAIT_TRANSFER_COMPLETE:

            if (appTempData.isTransferDone == true)
            {
                appTempData.isTransferDone = false;

                // Convert the temperature value read from sensor to readable format (Degree Celsius)
                // For demonstration purpose, temperature value is assumed to be positive.
                // The maximum positive temperature measured by sensor is +125 C
                temp = (appTempData.rxBuffer[0] << 8) | appTempData.rxBuffer[1];
                temp = (temp >> 7) * 0.5;
                appTempData.temperature = (uint8_t)temp;

                SYS_CONSOLE_PRINT("%d C\r\n", appTempData.temperature);

                /* Notify EEPROM application that temperature data is available */
                APP_EEPROM_Notify(appTempData.temperature);

                appTempData.state = APP_TEMP_STATE_READ_TEMPERATURE;
            }
            break;

        case APP_TEMP_STATE_ERROR:
            SYS_CONSOLE_PRINT("Temperature Sensor Task Error \r\n");
            appTempData.state = APP_TEMP_STATE_IDLE;
            break;

        case APP_TEMP_STATE_IDLE:
            break;

        default:
            break;
    }
}

/*******************************************************************************
 End of File
 */