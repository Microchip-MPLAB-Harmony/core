/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_instance1.c

  Summary:
    This file contains the source code for instance 1 of the MPLAB Harmony
    application.

  Description:
    This file has the source code for instance 1 which transfers the data on SPI
    line at two different baud rates.
 *******************************************************************************/

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


// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "app_instance1.h"
#include "app_monitor.h"
#include <string.h>

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************
/* EEPROM Commands */
#define EEPROM1_CMD_WREN                       0x06
#define EEPROM1_CMD_WRITE                      0x02
#define EEPROM1_CMD_RDSR                       0x05
#define EEPROM1_CMD_READ                       0x03
#define EEPROM1_START_ADDRESS                  0x000000
#define EEPROM1_STATUS_BUSY_BIT                0x01

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_INSTANCE1_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

static APP_INSTANCE1_DATA app_instance1Data;
static const uint8_t EEPROM1_MSG_STR[] = "WRITING AND READING DATA ON FIRST INSTANCE EEPROM 1";
static uint8_t CACHE_ALIGN eeprom1TxData[64];
static uint8_t CACHE_ALIGN eeprom1RxData[64];

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************
static void SPIInstance1EventHandler (
    DRV_SPI_TRANSFER_EVENT event,
    DRV_SPI_TRANSFER_HANDLE transferHandle,
    uintptr_t context
)
{
    if (event == DRV_SPI_TRANSFER_EVENT_COMPLETE)
    {
        app_instance1Data.isTransferComplete = true;
    }
    else
    {
        app_instance1Data.isTransferComplete = false;
        app_instance1Data.state = APP_INSTANCE1_STATE_ERROR;
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************
bool APP_INSTANCE1_TransferStatus(void)
{
    return app_instance1Data.transferStatus;
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_INSTANCE1_Initialize ( void )

  Remarks:
    See prototype in app_instance1.h.
 */

void APP_INSTANCE1_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app_instance1Data.state             = APP_INSTANCE1_STATE_DATA_INIT;
    app_instance1Data.drvSPIHandle      = DRV_HANDLE_INVALID;
    app_instance1Data.transferStatus    = APP_ERROR;    

    memset(eeprom1TxData, 0, sizeof(eeprom1TxData) );
    memset(eeprom1RxData, 0, sizeof(eeprom1RxData) );

    APP_EEPROM1_CS_Set();
    APP_EEPROM1_WP_Set();
    APP_EEPROM1_HOLD_Set();
}


/******************************************************************************
  Function:
    void APP_INSTANCE1_Tasks ( void )

  Remarks:
    See prototype in app_instance1.h.
 */

void APP_INSTANCE1_Tasks ( void )
{
    uint32_t eepromAddr = EEPROM1_START_ADDRESS;

    /* Check the application's current state. */
    switch ( app_instance1Data.state )
    {
        /* Application's initial state. */
        case APP_INSTANCE1_STATE_DATA_INIT:

            /* Setup SPI for instance 1 which is EEPROM 0 */
            app_instance1Data.setup.baudRateInHz    = 600000;
            app_instance1Data.setup.clockPhase      = DRV_SPI_CLOCK_PHASE_VALID_LEADING_EDGE;
            app_instance1Data.setup.clockPolarity   = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
            app_instance1Data.setup.dataBits        = DRV_SPI_DATA_BITS_8;
            app_instance1Data.setup.chipSelect      = APP_EEPROM1_CS_PIN;
            app_instance1Data.setup.csPolarity      = DRV_SPI_CS_POLARITY_ACTIVE_LOW;
            app_instance1Data.state                 = APP_INSTANCE1_STATE_DRIVER_SETUP;
            break;

         case APP_INSTANCE1_STATE_DRIVER_SETUP:

            /* Open the SPI Driver instance 1 */
            app_instance1Data.drvSPIHandle = DRV_SPI_Open( DRV_SPI_INDEX_0, DRV_IO_INTENT_READWRITE );

            if(app_instance1Data.drvSPIHandle != DRV_HANDLE_INVALID)
            {
                if(DRV_SPI_TransferSetup(app_instance1Data.drvSPIHandle, &app_instance1Data.setup) == true)
                {
                    DRV_SPI_TransferEventHandlerSet(app_instance1Data.drvSPIHandle, SPIInstance1EventHandler, (uintptr_t)0);
                    app_instance1Data.state = APP_INSTANCE1_STATE_WRITE_ENABLE;
                }
                else
                {
                    app_instance1Data.state = APP_INSTANCE1_STATE_ERROR;
                }
            }
            else
            {
                app_instance1Data.state = APP_INSTANCE1_STATE_ERROR;
            }
            break;

        case APP_INSTANCE1_STATE_WRITE_ENABLE:

            /* Set the next state first as callback may be fired before the state
             * is changed; potentially over-writing error state set from the callback */
            
            eeprom1TxData[0] = EEPROM1_CMD_WREN;

            app_instance1Data.state = APP_INSTANCE1_STATE_WRITE;

            DRV_SPI_WriteTransferAdd(app_instance1Data.drvSPIHandle, eeprom1TxData, 1, &app_instance1Data.transferHandle );

            if(app_instance1Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                app_instance1Data.state = APP_INSTANCE1_STATE_ERROR;
            }
            break;

        case APP_INSTANCE1_STATE_WRITE:

            if (app_instance1Data.isTransferComplete == true)
            {
                app_instance1Data.isTransferComplete = false;

                // Write to EEPROM
                eeprom1TxData[0] = EEPROM1_CMD_WRITE;
                eeprom1TxData[1] = (uint8_t)(eepromAddr>>16);
                eeprom1TxData[2] = (uint8_t)(eepromAddr>>8);
                eeprom1TxData[3] = (uint8_t)(eepromAddr);

                memcpy(&eeprom1TxData[4], EEPROM1_MSG_STR, strlen((const char*)EEPROM1_MSG_STR));

                app_instance1Data.state = APP_INSTANCE1_STATE_WAIT_FOR_WRITE_COMPLETE;

                DRV_SPI_WriteTransferAdd(app_instance1Data.drvSPIHandle, eeprom1TxData, (4 + strlen((const char*)EEPROM1_MSG_STR)), &app_instance1Data.transferHandle );

                if(app_instance1Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    app_instance1Data.state = APP_INSTANCE1_STATE_ERROR;
                }
            }
            break;

        case APP_INSTANCE1_STATE_WAIT_FOR_WRITE_COMPLETE:

            if (app_instance1Data.isTransferComplete == true)
            {
                app_instance1Data.isTransferComplete = false;
                
                eeprom1TxData[0] = EEPROM1_CMD_RDSR;

                app_instance1Data.state = APP_INSTANCE1_STATE_CHECK_STATUS;

                DRV_SPI_WriteReadTransferAdd(app_instance1Data.drvSPIHandle, eeprom1TxData, 1, eeprom1RxData, 2, &app_instance1Data.transferHandle );

                if(app_instance1Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    app_instance1Data.state = APP_INSTANCE1_STATE_ERROR;
                }
            }
            break;

        case APP_INSTANCE1_STATE_CHECK_STATUS:

            if (app_instance1Data.isTransferComplete == true)
            {
                app_instance1Data.isTransferComplete = false;
                if((eeprom1RxData[1] & EEPROM1_STATUS_BUSY_BIT) == 0x00)
                {
                    app_instance1Data.state = APP_INSTANCE1_STATE_READ;
                }
                else
                {
                    /* EEPROM is still busy. Keep checking the status. */
                    DRV_SPI_WriteReadTransferAdd(app_instance1Data.drvSPIHandle, eeprom1TxData, 1, eeprom1RxData, 2, &app_instance1Data.transferHandle );

                    if(app_instance1Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
                    {
                        app_instance1Data.state = APP_INSTANCE1_STATE_ERROR;
                    }
                }
            }
            break;

        case APP_INSTANCE1_STATE_READ:

            // Read from EEPROM
            eeprom1TxData[0] = EEPROM1_CMD_READ;
            eeprom1TxData[1] = (uint8_t)(eepromAddr>>16);
            eeprom1TxData[2] = (uint8_t)(eepromAddr>>8);
            eeprom1TxData[3] = (uint8_t)(eepromAddr);

            app_instance1Data.state = APP_INSTANCE1_STATE_DATA_COMPARISON;

            DRV_SPI_WriteReadTransferAdd(app_instance1Data.drvSPIHandle, eeprom1TxData, 4, eeprom1RxData, (4 + strlen((const char*)EEPROM1_MSG_STR)), &app_instance1Data.transferHandle);

            if(app_instance1Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                app_instance1Data.state = APP_INSTANCE1_STATE_ERROR;
            }
            break;

        case APP_INSTANCE1_STATE_DATA_COMPARISON:

            if (app_instance1Data.isTransferComplete == true)
            {
                app_instance1Data.isTransferComplete = false;

                if (memcmp(&eeprom1RxData[4], EEPROM1_MSG_STR, strlen((const char*)EEPROM1_MSG_STR)) == 0)
                {
                    app_instance1Data.state = APP_INSTANCE1_STATE_SUCCESS;
                }
                else
                {
                    app_instance1Data.state = APP_INSTANCE1_STATE_ERROR;
                }
            }
            break;

        case APP_INSTANCE1_STATE_SUCCESS:
            app_instance1Data.transferStatus = APP_SUCCESS;
            app_instance1Data.state = APP_INSTANCE1_STATE_IDLE;
            break;

        case APP_INSTANCE1_STATE_ERROR:
            app_instance1Data.transferStatus = APP_ERROR;
            app_instance1Data.state = APP_INSTANCE1_STATE_IDLE;
            break;

        case APP_INSTANCE1_STATE_IDLE:
        default:
            break;
    }
}
