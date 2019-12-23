/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_eeprom2.c

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

#include "app_eeprom2.h"
#include "app_monitor.h"
#include <string.h>

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************
/* EEPROM Commands */
#define EEPROM2_CMD_WREN                       0x06
#define EEPROM2_CMD_WRITE                      0x02
#define EEPROM2_CMD_RDSR                       0x05
#define EEPROM2_CMD_READ                       0x03
#define EEPROM2_START_ADDRESS                  0x000000
#define EEPROM2_STATUS_BUSY_BIT                0x01

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_EEPROM2_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

static APP_EEPROM2_DATA app_eeprom2Data;
static const uint8_t EEPROM2_MSG_STR[] = "WRITING AND READING DATA ON EEPROM 2 SLAVE";
/* On devices with cache, the array size has to be of multiple of cache line size and aligned to 
 * cache line boundary */
static uint8_t CACHE_ALIGN eeprom2TxData[64];
static uint8_t CACHE_ALIGN eeprom2RxData[64];

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

static void SPI_EEEPROM2_EventHandler (
    DRV_SPI_TRANSFER_EVENT event,
    DRV_SPI_TRANSFER_HANDLE transferHandle,
    uintptr_t context
)
{
    if (event == DRV_SPI_TRANSFER_EVENT_COMPLETE)
    {
        app_eeprom2Data.isTransferComplete = true;
    }
    else
    {
        app_eeprom2Data.isTransferComplete = false;
        app_eeprom2Data.state = APP_EEPROM2_STATE_ERROR;
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************
bool APP_EEPROM2_TransferStatus(void)
{
    return app_eeprom2Data.transferStatus;
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_EEPROM2_Initialize ( void )

  Remarks:
    See prototype in app_eeprom2.h.
 */

void APP_EEPROM2_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app_eeprom2Data.state               = APP_EEPROM2_STATE_DATA_INIT;
    app_eeprom2Data.drvSPIHandle        = DRV_HANDLE_INVALID;
    app_eeprom2Data.transferStatus      = APP_ERROR;
    app_eeprom2Data.isTransferComplete  = false;    

    memset(eeprom2TxData, 0, sizeof(eeprom2TxData));
    memset(eeprom2RxData, 0, sizeof(eeprom2RxData));

    APP_EEPROM2_CS_Set();

    /* As EEPROM2 WP and HOLD pins are already latched high from
     * Pin Configuration, no need to set both pins high again.
     */
}


/******************************************************************************
  Function:
    void APP_EEPROM2_Tasks ( void )

  Remarks:
    See prototype in app_eeprom2.h.
 */

void APP_EEPROM2_Tasks ( void )
{
    uint32_t eepromAddr = EEPROM2_START_ADDRESS;

    /* Check the application's current state. */
    switch ( app_eeprom2Data.state )
    {
        /* Application's initial state. */
        case APP_EEPROM2_STATE_DATA_INIT:

            /* Setup SPI for client 2 which is EEPROM 2 */
            app_eeprom2Data.setup.baudRateInHz  = 700000;
            app_eeprom2Data.setup.clockPhase    = DRV_SPI_CLOCK_PHASE_VALID_LEADING_EDGE;
            app_eeprom2Data.setup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
            app_eeprom2Data.setup.dataBits      = DRV_SPI_DATA_BITS_8;
            app_eeprom2Data.setup.chipSelect    = (SYS_PORT_PIN)APP_EEPROM2_CS_PIN;
            app_eeprom2Data.setup.csPolarity    = DRV_SPI_CS_POLARITY_ACTIVE_LOW;
            app_eeprom2Data.state               = APP_EEPROM2_STATE_DRIVER_SETUP;
            break;

        case APP_EEPROM2_STATE_DRIVER_SETUP:

            /* Open the SPI Driver for client 2 */
            app_eeprom2Data.drvSPIHandle = DRV_SPI_Open( DRV_SPI_INDEX_0, DRV_IO_INTENT_READWRITE );
            if(app_eeprom2Data.drvSPIHandle != DRV_HANDLE_INVALID)
            {
                if(DRV_SPI_TransferSetup(app_eeprom2Data.drvSPIHandle, &app_eeprom2Data.setup) == true)
                {
                    DRV_SPI_TransferEventHandlerSet(app_eeprom2Data.drvSPIHandle, SPI_EEEPROM2_EventHandler, (uintptr_t)0);
                    app_eeprom2Data.state = APP_EEPROM2_STATE_WRITE_ENABLE;
                }
                else
                {
                    app_eeprom2Data.state = APP_EEPROM2_STATE_ERROR;
                }
            }
            else
            {
                app_eeprom2Data.state = APP_EEPROM2_STATE_ERROR;
            }
            break;

        case APP_EEPROM2_STATE_WRITE_ENABLE:

            /* Set the next state first as callback may be fired before the state
             * is changed; potentially over-writing error state set from the callback */
            
            app_eeprom2Data.state = APP_EEPROM2_STATE_WRITE;
            
            eeprom2TxData[0] = EEPROM2_CMD_WREN;
            
            DRV_SPI_WriteTransferAdd(app_eeprom2Data.drvSPIHandle, eeprom2TxData, 1, &app_eeprom2Data.transferHandle );
            
            if(app_eeprom2Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                app_eeprom2Data.state = APP_EEPROM2_STATE_ERROR;
            }
            break;

        case APP_EEPROM2_STATE_WRITE:
            if (app_eeprom2Data.isTransferComplete == true)
            {
                app_eeprom2Data.isTransferComplete = false;

                // Write to EEPROM
                eeprom2TxData[0] = EEPROM2_CMD_WRITE;
                eeprom2TxData[1] = (uint8_t)(eepromAddr>>16);
                eeprom2TxData[2] = (uint8_t)(eepromAddr>>8);
                eeprom2TxData[3] = (uint8_t)(eepromAddr);

                memcpy(&eeprom2TxData[4], EEPROM2_MSG_STR, strlen((const char*)EEPROM2_MSG_STR));

                app_eeprom2Data.state = APP_EEPROM2_STATE_WAIT_FOR_WRITE_COMPLETE;

                DRV_SPI_WriteTransferAdd(app_eeprom2Data.drvSPIHandle, eeprom2TxData, (4 + strlen((const char*)EEPROM2_MSG_STR)), &app_eeprom2Data.transferHandle );

                if(app_eeprom2Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    app_eeprom2Data.state = APP_EEPROM2_STATE_ERROR;
                }
            }
            break;

        case APP_EEPROM2_STATE_WAIT_FOR_WRITE_COMPLETE:
            if (app_eeprom2Data.isTransferComplete == true)
            {
                app_eeprom2Data.isTransferComplete = false;
                
                eeprom2TxData[0] = EEPROM2_CMD_RDSR;

                app_eeprom2Data.state = APP_EEPROM2_STATE_CHECK_STATUS;

                DRV_SPI_WriteReadTransferAdd(app_eeprom2Data.drvSPIHandle, eeprom2TxData, 1, eeprom2RxData, 2, &app_eeprom2Data.transferHandle );

                if(app_eeprom2Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    app_eeprom2Data.state = APP_EEPROM2_STATE_ERROR;
                }
            }
            break;

        case APP_EEPROM2_STATE_CHECK_STATUS:
            if (app_eeprom2Data.isTransferComplete == true)
            {
                app_eeprom2Data.isTransferComplete = false;
                if((eeprom2RxData[1] & EEPROM2_STATUS_BUSY_BIT) == 0x00)
                {
                    app_eeprom2Data.state = APP_EEPROM2_STATE_READ;
                }
                else
                {
                    /* EEPROM is still busy. Keep checking the status. */
                    DRV_SPI_WriteReadTransferAdd(app_eeprom2Data.drvSPIHandle, eeprom2TxData, 1, eeprom2RxData, 2, &app_eeprom2Data.transferHandle);
                    if(app_eeprom2Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
                    {
                        app_eeprom2Data.state = APP_EEPROM2_STATE_ERROR;
                    }
                }
            }
            break;

        case APP_EEPROM2_STATE_READ:

            // Read from EEPROM
            eeprom2TxData[0] = EEPROM2_CMD_READ;
            eeprom2TxData[1] = (uint8_t)(eepromAddr>>16);
            eeprom2TxData[2] = (uint8_t)(eepromAddr>>8);
            eeprom2TxData[3] = (uint8_t)(eepromAddr);

            app_eeprom2Data.state = APP_EEPROM2_STATE_DATA_COMPARISON;

            DRV_SPI_WriteReadTransferAdd(app_eeprom2Data.drvSPIHandle, eeprom2TxData, 4, eeprom2RxData, (4 + strlen((const char*)EEPROM2_MSG_STR)), &app_eeprom2Data.transferHandle);

            if(app_eeprom2Data.transferHandle == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                app_eeprom2Data.state = APP_EEPROM2_STATE_ERROR;
            }
            break;

        case APP_EEPROM2_STATE_DATA_COMPARISON:
            if (app_eeprom2Data.isTransferComplete == true)
            {
                app_eeprom2Data.isTransferComplete = false;

                if (memcmp(&eeprom2RxData[4], EEPROM2_MSG_STR, strlen((const char*)EEPROM2_MSG_STR)) == 0)
                {
                    app_eeprom2Data.state = APP_EEPROM2_STATE_SUCCESS;
                }
                else
                {
                    app_eeprom2Data.state = APP_EEPROM2_STATE_ERROR;
                }                
            }
            break;
            
        case APP_EEPROM2_STATE_SUCCESS:
            app_eeprom2Data.transferStatus = APP_SUCCESS;
            app_eeprom2Data.state = APP_EEPROM2_STATE_IDLE;
            break;

        case APP_EEPROM2_STATE_ERROR:
            app_eeprom2Data.transferStatus = APP_ERROR;
            app_eeprom2Data.state = APP_EEPROM2_STATE_IDLE;
            break;

        case APP_EEPROM2_STATE_IDLE:
        default:
            break;
    }
}

/*******************************************************************************
 End of File
 */
