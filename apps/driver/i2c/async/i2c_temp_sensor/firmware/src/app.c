/*******************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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

/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app.c

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

#include "app.h"
#include "user.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************
#define APP_TEMP_SENSOR_SLAVE_ADDR              0x0018
#define APP_TEMPERATURE_MEM_ADDR                0x05
// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

static APP_DATA appData;
static uint8_t wrData;
static uint8_t rdData[2];

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************
static void APP_I2CEventHandler (
    DRV_I2C_TRANSFER_EVENT event,
    DRV_I2C_TRANSFER_HANDLE transferHandle,
    uintptr_t context
)
{
    APP_I2C_TRANSFER_STATUS* transferStatus = (APP_I2C_TRANSFER_STATUS*)context;

    if (event == DRV_I2C_TRANSFER_EVENT_COMPLETE)
    {
        if (transferStatus)
        {
            *transferStatus = APP_I2C_TRANSFER_STATUS_SUCCESS;
        }
    }
    else
    {
        if (transferStatus)
        {
            *transferStatus = APP_I2C_TRANSFER_STATUS_ERROR;
        }
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************
static uint16_t APP_CalculateTemperature(uint16_t rawTemperature)
{
    uint16_t temperature;
    uint8_t upperByte = (uint8_t)rawTemperature;
    uint8_t lowerByte = ((uint8_t*)&rawTemperature)[1];
        
    upperByte = upperByte & 0x1F;
    
    if ((upperByte & 0x10) == 0x10)         // Ta < 0 degC
    {
        upperByte = upperByte & 0x0F;       // Clear sign bit
        temperature = 256 - ((upperByte * 16) + lowerByte/16);
    }
    else
    {
        temperature = ((upperByte * 16) + lowerByte/16);
    }
    
    return temperature;
    
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    appData.state = APP_STATE_INIT;
}


/******************************************************************************
  Function:
    void APP_Tasks ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Tasks ( void )
{
    switch (appData.state)
    {
        case APP_STATE_INIT:

            appData.drvI2CHandle = DRV_I2C_Open( DRV_I2C_INDEX_0, DRV_IO_INTENT_READWRITE );
            if(appData.drvI2CHandle == DRV_HANDLE_INVALID)
            {
                appData.state = APP_STATE_XFER_ERROR;
            }
            else
            {
                /* Register the I2C Driver event Handler */
                DRV_I2C_TransferEventHandlerSet(
                    appData.drvI2CHandle,
                    APP_I2CEventHandler,
                    (uintptr_t)&appData.transferStatus
                );
                
                appData.state = APP_STATE_CHECK_TEMP_SENSOR_READY;                               
            }                        
            break;
            
        case APP_STATE_CHECK_TEMP_SENSOR_READY:
            
            /* Add a dummy write transfer to verify if Temperature Sensor is ready */
            appData.transferStatus = APP_I2C_TRANSFER_STATUS_IN_PROGRESS;

            DRV_I2C_WriteTransferAdd(
                appData.drvI2CHandle,
                APP_TEMP_SENSOR_SLAVE_ADDR,
                (void *)&appData.ackData,
                1,
                &appData.transferHandle
            );

            if( appData.transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                appData.state = APP_STATE_XFER_ERROR;
            }
            else
            {
                appData.state = APP_STATE_WAIT_TEMP_SENSOR_READY;
            }
                
            break;

        case APP_STATE_WAIT_TEMP_SENSOR_READY:

            if (appData.transferStatus == APP_I2C_TRANSFER_STATUS_SUCCESS)
            {
                /* Temperature sensor is ready. Ask user to press switch to read temperature */
                printf("Press switch to read temperature\r\n");

                appData.state = APP_STATE_WAIT_SWITCH_PRESS;
            }
            else if (appData.transferStatus == APP_I2C_TRANSFER_STATUS_ERROR)
            {
                /* Temperature sensor is not ready. 
                 * Keep checking until it is ready. */
                appData.state = APP_STATE_CHECK_TEMP_SENSOR_READY;
            }
            break;
               
        case APP_STATE_WAIT_SWITCH_PRESS:

            if (SWITCH_GET() == SWITCH_IS_PRESSED)
            {
                appData.state = APP_STATE_READ_TEMPERATURE;
            }
            break;

        case APP_STATE_READ_TEMPERATURE:
            
            appData.transferStatus = APP_I2C_TRANSFER_STATUS_IN_PROGRESS;

            wrData = APP_TEMPERATURE_MEM_ADDR;
            
            DRV_I2C_WriteReadTransferAdd(
                appData.drvI2CHandle,
                APP_TEMP_SENSOR_SLAVE_ADDR,
                (void *)&wrData,
                1,
                (void *)&rdData[0],
                2,
                &appData.transferHandle
            );

            if( appData.transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                appData.state = APP_STATE_XFER_ERROR;
            }
            else
            {
                appData.state = APP_STATE_PRINT_TEMPERATURE;
            }
                                
            break;            

        case APP_STATE_PRINT_TEMPERATURE:

            if (appData.transferStatus == APP_I2C_TRANSFER_STATUS_SUCCESS)
            {
                appData.temperature = APP_CalculateTemperature(*((uint16_t*)rdData));
                printf("Temperature = %d C\r\n", appData.temperature);

                appData.state = APP_STATE_WAIT_SWITCH_RELEASE;
            }
            else if (appData.transferStatus == APP_I2C_TRANSFER_STATUS_ERROR)
            {
                appData.state = APP_STATE_XFER_ERROR;
            }
            break;

        case APP_STATE_WAIT_SWITCH_RELEASE:

            if (SWITCH_GET() == SWITCH_IS_RELEASED)
            {
                appData.state = APP_STATE_WAIT_SWITCH_PRESS;
            }                
            break;

        case APP_STATE_XFER_ERROR:

            printf("I2C Transfer Error!");
            appData.state = APP_STATE_IDLE;
            break;

        case APP_STATE_IDLE:
            break;

        default:
            break;
    }
}


/*******************************************************************************
 End of File
 */
