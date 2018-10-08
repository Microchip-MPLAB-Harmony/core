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

#include "app_eeprom1.h"
#include "app_eeprom2.h"
#include "string.h"

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
    This structure should be initialized by the APP_EEPROM2_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_EEPROM2_DATA app_eeprom2Data;

/* Array size has to be of multiple of 32 because of cache alignment */
uint8_t __attribute__ ((aligned (32))) txData2[64]  = "----WRITING AND READING DATA ON SECOND CLIENT EEPROM 2";

uint8_t __attribute__ ((aligned (32))) rxData2[sizeof(txData2)];

/* EEPROM Commands */
#define EEPROM2_CMD_WREN                       0x06
#define EEPROM2_CMD_WRITE                      0x02
#define EEPROM2_CMD_RDSR                       0x05
#define EEPROM2_CMD_READ                       0x03

uint8_t writeEnableCommand2 = EEPROM2_CMD_WREN;
uint8_t readStatusCommand2  = EEPROM2_CMD_RDSR;

#define EEPROM2_START_ADDRESS                  0x000000
// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

void SpiEeprom2EventHandler (DRV_SPI_TRANSFER_EVENT event,
        DRV_SPI_TRANSFER_HANDLE transferHandle, uintptr_t context )
{
    if (event == DRV_SPI_TRANSFER_EVENT_COMPLETE)
    {
        if(transferHandle == app_eeprom2Data.transferHandle3)
        {            
            if(!(rxData2[1] & 0x01))
            {
                app_eeprom2Data.state = APP_EEPROM2_STATE_READ;
            }
            else
            {
                app_eeprom2Data.state = APP_EEPROM2_STATE_WAIT_FOR_WRITE_COMPLETE;
            }
        }
        else if(transferHandle == app_eeprom2Data.transferHandle4)
        {
            // Both the transfers are done, update the state to compare the received data.
            app_eeprom2Data.state = APP_EEPROM2_STATE_DATA_COMPARISON;
        }  
    }
    else
    {
        app_eeprom2Data.transferSuccess = false;
        app_eeprom2Data.state = APP_EEPROM2_STATE_IDLE;
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************
bool EEPROM2TransferSuccessStatus(void)
{
    return app_eeprom2Data.transferSuccess;
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
    app_eeprom2Data.state = APP_EEPROM2_STATE_DATA_INIT;
    app_eeprom2Data.drvSPIHandle = DRV_HANDLE_INVALID;
    app_eeprom2Data.transferSuccess = false;
    
    APP_EEPROM2_CS_Set();
    APP_EEPROM2_WP_Set();
    APP_EEPROM2_HOLD_Set();
    
    /* Clear the receive data array */
    memset(&rxData2, 0, sizeof(rxData2));
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
        {
            /* Setup SPI for client 2 which is EEPROM 2 */
            app_eeprom2Data.setup.baudRateInHz = 700000;
            app_eeprom2Data.setup.clockPhase = DRV_SPI_CLOCK_PHASE_VALID_LEADING_EDGE;
            app_eeprom2Data.setup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
            app_eeprom2Data.setup.dataBits = DRV_SPI_DATA_BITS_8;
            app_eeprom2Data.setup.chipSelect = APP_EEPROM2_CS_PIN;
            app_eeprom2Data.setup.csPolarity = DRV_SPI_CS_POLARITY_ACTIVE_LOW;
        
            app_eeprom2Data.state = APP_EEPROM2_STATE_DRIVER_SETUP;
            break;
        }
        case APP_EEPROM2_STATE_DRIVER_SETUP:
        {
            /* Open the SPI Driver for client 2 */
            if(app_eeprom2Data.drvSPIHandle == DRV_HANDLE_INVALID)
            {
                app_eeprom2Data.drvSPIHandle = DRV_SPI_Open( DRV_SPI_INDEX_0, DRV_IO_INTENT_READWRITE );
            }
            if(app_eeprom2Data.drvSPIHandle != DRV_HANDLE_INVALID)
            {
                if(DRV_SPI_TransferSetup(app_eeprom2Data.drvSPIHandle, &app_eeprom2Data.setup) == false)
                {
                   app_eeprom2Data.state = APP_EEPROM2_STATE_IDLE; 
                }
               
                DRV_SPI_TransferEventHandlerSet(app_eeprom2Data.drvSPIHandle, SpiEeprom2EventHandler, (uintptr_t)NULL);
                app_eeprom2Data.state = APP_EEPROM2_STATE_WRITE_ENABLE;
            }
            break;
        }

        case APP_EEPROM2_STATE_WRITE_ENABLE:
        {                        
            DRV_SPI_WriteTransferAdd(app_eeprom2Data.drvSPIHandle, &writeEnableCommand2, 1, &app_eeprom2Data.transferHandle1 );
            if(app_eeprom2Data.transferHandle1 == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                /* Remain in the same state */
                app_eeprom2Data.state = APP_EEPROM2_STATE_WRITE_ENABLE;
            }
            else
            {
                app_eeprom2Data.state = APP_EEPROM2_STATE_WRITE;
            }
            break;
        }
        case APP_EEPROM2_STATE_WRITE:
        {   
                //Write to EEPROM 
                txData2[0] = EEPROM2_CMD_WRITE;
                txData2[1] = (uint8_t)(eepromAddr>>16);
                txData2[2] = (uint8_t)(eepromAddr>>8);                 
                txData2[3] = (uint8_t)(eepromAddr);
                
                DRV_SPI_WriteTransferAdd(app_eeprom2Data.drvSPIHandle, &txData2, sizeof(txData2), &app_eeprom2Data.transferHandle2 );   
                if(app_eeprom2Data.transferHandle2 == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    /* Remain in the same state */
                    app_eeprom2Data.state = APP_EEPROM2_STATE_WRITE;
                }
                else
                {
                    app_eeprom2Data.state = APP_EEPROM2_STATE_WAIT_FOR_WRITE_COMPLETE;
                }
            break;
        }
        case APP_EEPROM2_STATE_WAIT_FOR_WRITE_COMPLETE:
        {   
                app_eeprom2Data.state = APP_EEPROM2_STATE_IDLE;
            
                DRV_SPI_WriteReadTransferAdd(app_eeprom2Data.drvSPIHandle, &readStatusCommand2, 1, rxData2, 2, &app_eeprom2Data.transferHandle3 );   
                if(app_eeprom2Data.transferHandle3 == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    /* Remain in the same state */
                    app_eeprom2Data.state = APP_EEPROM2_STATE_WAIT_FOR_WRITE_COMPLETE;
                }
                else
                {
                    
                }
            break;
        }
        case APP_EEPROM2_STATE_READ:
        {   
                app_eeprom2Data.state = APP_EEPROM2_STATE_IDLE;
            
                //Read from EEPROM     
                txData2[0] = EEPROM2_CMD_READ;
                txData2[1] = (uint8_t)(eepromAddr>>16);
                txData2[2] = (uint8_t)(eepromAddr>>8);                 
                txData2[3] = (uint8_t)(eepromAddr);

                DRV_SPI_WriteReadTransferAdd(app_eeprom2Data.drvSPIHandle, txData2, 4, rxData2, sizeof(rxData2), &app_eeprom2Data.transferHandle4 );   
                if(app_eeprom2Data.transferHandle4 == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    /* Remain in the same state */
                    app_eeprom2Data.state = APP_EEPROM2_STATE_READ;
                }
            break;
        }
        case APP_EEPROM2_STATE_DATA_COMPARISON:
        {
            /* Transfer Status polling is not done here as we have already checked the transfer status in the SPIEventHandler callback function */
            if (memcmp(&txData2[4], &rxData2[4], sizeof(txData2)-4) != 0)            
            {
                app_eeprom2Data.transferSuccess = false;
            }
            else   
            {
                app_eeprom2Data.transferSuccess = true;
            }
            app_eeprom2Data.state = APP_EEPROM2_STATE_IDLE;
 
            break;
        }
        case APP_EEPROM2_STATE_IDLE:
        {
            break;
        }       
        default:
            while (1);
    }
}

/*******************************************************************************
 End of File
 */
