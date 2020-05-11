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
#include "osal/osal.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************
#define APP_TEMP_AT30TSE75X_SLAVE_ADDR              0x004B
#define APP_TEMP_TEMPERATURE_REG_ADDR               0x00

#define APP_TEMP_READ_RATE_MS                       1000
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
static APP_I2C_TEMP_SENSOR_DATA appTempSensorData;

/* Define a temperature ready semaphore to signal the EEPROM thread to write new
 * temperature value
*/
OSAL_SEM_DECLARE(temperatureReady);

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

uint8_t APP_TEMPERATURE_SENSOR_GetTemperature(void)
{
    return appTempSensorData.temperature;
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_I2C_TEMP_SENSOR_Initialize ( void )

  Remarks:
    See prototype in app_i2c_temp_sensor.h.
 */

void APP_I2C_TEMP_SENSOR_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    appTempSensorData.state = APP_I2C_TEMP_SENSOR_STATE_INIT;

    if (OSAL_SEM_Create(&temperatureReady, OSAL_SEM_TYPE_BINARY, 0, 0) == OSAL_RESULT_FALSE)
    {
        /* Handle error condition. Not sufficient memory to create semaphore */
    }
}

/******************************************************************************
  Function:
    void APP_I2C_TEMP_SENSOR_Tasks ( void )

  Remarks:
    See prototype in app_i2c_temp_sensor.h.
 */

void APP_I2C_TEMP_SENSOR_Tasks ( void )
{
    uint8_t registerAddr;
    int16_t temp;

    /* Check the application's current state. */
    switch (appTempSensorData.state)
    {
        case APP_I2C_TEMP_SENSOR_STATE_INIT:
            /* Open I2C driver instance */
            appTempSensorData.drvI2CHandle = DRV_I2C_Open( DRV_I2C_INDEX_0, DRV_IO_INTENT_READWRITE);

            if(appTempSensorData.drvI2CHandle != DRV_HANDLE_INVALID)
            {
                appTempSensorData.state = APP_I2C_TEMP_SENSOR_STATE_READ_SENSOR;
            }
            else
            {
                appTempSensorData.state = APP_I2C_TEMP_SENSOR_STATE_ERROR;
            }
            break;

        case APP_I2C_TEMP_SENSOR_STATE_READ_SENSOR:

            /* Read temperature readings every 1000 ms */
            vTaskDelay(APP_TEMP_READ_RATE_MS/portTICK_PERIOD_MS);

            SYS_CONSOLE_PRINT("Reading temperature from sensor...");

            registerAddr = APP_TEMP_TEMPERATURE_REG_ADDR;

            /* Read temperature reading */
            if (DRV_I2C_WriteReadTransfer(appTempSensorData.drvI2CHandle, APP_TEMP_AT30TSE75X_SLAVE_ADDR, (void*)&registerAddr, 1, (void *)appTempSensorData.rxBuffer, 2 ) == true)
            {
                // Convert the temperature value read from sensor to readable format (Degree Celsius)
                // For demonstration purpose, temperature value is assumed to be positive.
                // The maximum positive temperature measured by sensor is +125 C
                temp = (appTempSensorData.rxBuffer[0] << 8) | appTempSensorData.rxBuffer[1];
                temp = (temp >> 7) * 0.5;
                appTempSensorData.temperature = (uint8_t)temp;

                SYS_CONSOLE_PRINT("%d C\r\n", appTempSensorData.temperature);

                /* Notify the EEPROM task to write the temperature value to EEPROM */
                OSAL_SEM_Post(&temperatureReady);
            }
            else
            {
                appTempSensorData.state = APP_I2C_TEMP_SENSOR_STATE_ERROR;
            }
            break;

        case APP_I2C_TEMP_SENSOR_STATE_ERROR:
            SYS_CONSOLE_PRINT("Temperature Sensor Task Error \r\n");
            appTempSensorData.state = APP_I2C_TEMP_SENSOR_STATE_IDLE;            
            break;
            
        case APP_I2C_TEMP_SENSOR_STATE_IDLE:
            /* Allow other threads to run */
            vTaskSuspend(NULL);
            break;
            
        default:
            break;
    }
}

/*******************************************************************************
 End of File
 */