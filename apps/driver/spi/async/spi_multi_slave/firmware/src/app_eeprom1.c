/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_eeprom1.c

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

#include "app_eeprom1.h"
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
    This structure should be initialized by the APP_EEPROM1_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

static APP_EEPROM1_DATA app_eeprom1Data;
static const uint8_t EEPROM1_MSG_STR[] = "WRITING AND READING DATA ON EEPROM 1 SLAVE";
/* On devices with cache, the array size has to be of multiple of cache line size and aligned to 
 * cache line boundary */
static uint8_t CACHE_ALIGN eeprom1TxData[64];
static uint8_t CACHE_ALIGN eeprom1RxData[64];

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

static void SPI_EEEPROM1_EventHandler(
    DRV_SPI_TRANSFER_EVENT event,
    DRV_SPI_TRANSFER_HANDLE transferHandle,
    uintptr_t context
)
{
    if (event == DRV_SPI_TRANSFER_EVENT_COMPLETE)
    {
         app_eeprom1Data.isTransferComplete = true;
    }
    else
    {
        app_eeprom1Data.isTransferComplete = false;
        app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************
bool APP_EEPROM1_TransferStatus(void)
{
    return app_eeprom1Data.transferStatus;
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_EEPROM1_Initialize ( void )

  Remarks:
    See prototype in app_eeprom1.h.
 */

void APP_EEPROM1_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app_eeprom1Data.state               = APP_EEPROM1_STATE_DATA_INIT;
    app_eeprom1Data.drvSPIHandle        = DRV_HANDLE_INVALID;
    app_eeprom1Data.transferStatus      = APP_ERROR;
    app_eeprom1Data.isTransferComplete  = false;        

    memset(eeprom1TxData, 0, sizeof(eeprom1TxData));
    memset(eeprom1RxData, 0, sizeof(eeprom1RxData));

    APP_EEPROM1_CS_Set();

    /* As EEPROM1 WP and HOLD pins are already latched high from
     * Pin Configuration, no need to set both pins high again.
     */
}


/******************************************************************************
  Function:
    void APP_EEPROM1_Tasks ( void )

  Remarks:
    See prototype in app_eeprom1.h.
 */

void APP_EEPROM1_Tasks ( void )
{
    uint32_t eepromAddr = EEPROM1_START_ADDRESS;

    /* Check the application's current state. */
    switch ( app_eeprom1Data.state )
    {
        /* Application's initial state. */
        case APP_EEPROM1_STATE_DATA_INIT:

            /* Setup SPI for client 1 which is EEPROM 1 */
            app_eeprom1Data.setup.baudRateInHz  = 600000;
            app_eeprom1Data.setup.clockPhase    = DRV_SPI_CLOCK_PHASE_VALID_LEADING_EDGE;
            app_eeprom1Data.setup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
            app_eeprom1Data.setup.dataBits      = DRV_SPI_DATA_BITS_8;
            app_eeprom1Data.setup.chipSelect    = (SYS_PORT_PIN)APP_EEPROM1_CS_PIN;
            app_eeprom1Data.setup.csPolarity    = DRV_SPI_CS_POLARITY_ACTIVE_LOW;
            app_eeprom1Data.state               = APP_EEPROM1_STATE_DRIVER_SETUP;
            break;

        case APP_EEPROM1_STATE_DRIVER_SETUP:

            /* Open the SPI Driver for client 1 */
            app_eeprom1Data.drvSPIHandle = DRV_SPI_Open( DRV_SPI_INDEX_0, DRV_IO_INTENT_READWRITE );
            if(app_eeprom1Data.drvSPIHandle != DRV_HANDLE_INVALID)
            {
                if(DRV_SPI_TransferSetup(app_eeprom1Data.drvSPIHandle, &app_eeprom1Data.setup) == true)
                {
                    DRV_SPI_TransferEventHandlerSet(app_eeprom1Data.drvSPIHandle, SPI_EEEPROM1_EventHandler, (uintptr_t)0);
                    app_eeprom1Data.state = APP_EEPROM1_STATE_WRITE_ENABLE;
                }
                else
                {
                    app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
                }
            }
            else
            {
                app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
            }
            break;

        case APP_EEPROM1_STATE_WRITE_ENABLE:

            /* Set the next state first as callback may be fired before the state
             * is changed; potentially over-writing error state set from the callback */
            
            app_eeprom1Data.state = APP_EEPROM1_STATE_WRITE;
            
            eeprom1TxData[0] = EEPROM1_CMD_WREN;

            DRV_SPI_WriteTransferAdd(app_eeprom1Data.drvSPIHandle, eeprom1TxData, 1, &app_eeprom1Data.transferHandle);

            if(app_eeprom1Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
            }
            break;

        case APP_EEPROM1_STATE_WRITE:
            if (app_eeprom1Data.isTransferComplete == true)
            {
                app_eeprom1Data.isTransferComplete = false;

                // Write to EEPROM
                eeprom1TxData[0] = EEPROM1_CMD_WRITE;
                eeprom1TxData[1] = (uint8_t)(eepromAddr>>16);
                eeprom1TxData[2] = (uint8_t)(eepromAddr>>8);
                eeprom1TxData[3] = (uint8_t)(eepromAddr);

                memcpy(&eeprom1TxData[4], EEPROM1_MSG_STR, strlen((const char*)EEPROM1_MSG_STR));

                app_eeprom1Data.state = APP_EEPROM1_STATE_WAIT_FOR_WRITE_COMPLETE;

                DRV_SPI_WriteTransferAdd(app_eeprom1Data.drvSPIHandle, eeprom1TxData, (4 + strlen((const char*)EEPROM1_MSG_STR)), &app_eeprom1Data.transferHandle );

                if(app_eeprom1Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
                }
            }
            break;

        case APP_EEPROM1_STATE_WAIT_FOR_WRITE_COMPLETE:

            if (app_eeprom1Data.isTransferComplete == true)
            {
                app_eeprom1Data.isTransferComplete = false;
                
                eeprom1TxData[0] = EEPROM1_CMD_RDSR;

                app_eeprom1Data.state = APP_EEPROM1_STATE_CHECK_STATUS;

                DRV_SPI_WriteReadTransferAdd(app_eeprom1Data.drvSPIHandle, eeprom1TxData, 1, eeprom1RxData, 2, &app_eeprom1Data.transferHandle);

                if(app_eeprom1Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
                }
            }
            break;

        case APP_EEPROM1_STATE_CHECK_STATUS:
            if (app_eeprom1Data.isTransferComplete == true)
            {
                app_eeprom1Data.isTransferComplete = false;
                if((eeprom1RxData[1] & EEPROM1_STATUS_BUSY_BIT) == 0x00)
                {
                    app_eeprom1Data.state = APP_EEPROM1_STATE_READ;
                }
                else
                {
                    /* EEPROM is still busy. Keep checking the status. */
                    DRV_SPI_WriteReadTransferAdd(app_eeprom1Data.drvSPIHandle, eeprom1TxData, 1, eeprom1RxData, 2, &app_eeprom1Data.transferHandle);
                    if(app_eeprom1Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
                    {
                        app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
                    }
                }
            }
            break;

        case APP_EEPROM1_STATE_READ:

            // Read from EEPROM
            eeprom1TxData[0] = EEPROM1_CMD_READ;
            eeprom1TxData[1] = (uint8_t)(eepromAddr>>16);
            eeprom1TxData[2] = (uint8_t)(eepromAddr>>8);
            eeprom1TxData[3] = (uint8_t)(eepromAddr);

            app_eeprom1Data.state = APP_EEPROM1_STATE_DATA_COMPARISON;

            DRV_SPI_WriteReadTransferAdd(app_eeprom1Data.drvSPIHandle, eeprom1TxData, 4, eeprom1RxData, (4 + strlen((const char*)EEPROM1_MSG_STR)), &app_eeprom1Data.transferHandle);

            if(app_eeprom1Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
            }
            break;

        case APP_EEPROM1_STATE_DATA_COMPARISON:
            if (app_eeprom1Data.isTransferComplete == true)
            {
                app_eeprom1Data.isTransferComplete = false;
                if (memcmp(&eeprom1RxData[4], EEPROM1_MSG_STR, strlen((const char*)EEPROM1_MSG_STR)) == 0)
                {                    
                    app_eeprom1Data.state = APP_EEPROM1_STATE_SUCCESS;
                }
                else
                {
                    app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
                }                
            }
            break;

        case APP_EEPROM1_STATE_SUCCESS:
            app_eeprom1Data.transferStatus = APP_SUCCESS;
            app_eeprom1Data.state = APP_EEPROM1_STATE_IDLE;
            break;

        case APP_EEPROM1_STATE_ERROR:
            app_eeprom1Data.transferStatus = APP_ERROR;
            app_eeprom1Data.state = APP_EEPROM1_STATE_IDLE;
            break;

        case APP_EEPROM1_STATE_IDLE:
        default:
            break;
    }
}

/*******************************************************************************
 End of File
 */
