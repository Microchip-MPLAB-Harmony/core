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
#include "app_instance2.h"
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
    This structure should be initialized by the APP_INSTANCE1_Initialize function.
    
    Application strings and buffers are be defined outside this structure.
*/

APP_INSTANCE1_DATA app_instance1Data;

uint8_t __attribute__ ((aligned (32))) txData0[]  = "----WRITING AND READING DATA ON FIRST INSTANCE EEPROM 0";

uint8_t __attribute__ ((aligned (32))) rxData0[sizeof(txData0)];

/* EEPROM Commands */
#define EEPROM0_CMD_WREN                       0x06
#define EEPROM0_CMD_WRITE                      0x02
#define EEPROM0_CMD_RDSR                       0x05
#define EEPROM0_CMD_READ                       0x03

uint8_t writeEnableCommand0 = EEPROM0_CMD_WREN;
uint8_t readStatusCommand0  = EEPROM0_CMD_RDSR;

#define EEPROM0_START_ADDRESS                  0x000000
// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

void SPIInstance1EventHandler (DRV_SPI_TRANSFER_EVENT event,
        DRV_SPI_TRANSFER_HANDLE transferHandle, uintptr_t context )
{
    if (event == DRV_SPI_TRANSFER_EVENT_COMPLETE)
    {
        if(transferHandle == app_instance1Data.transferHandle3)
        {
            if(!(rxData0[1] & 0x01))
            {
                app_instance1Data.state = APP_INSTANCE1_STATE_READ;
            }
            else
            {
                app_instance1Data.state = APP_INSTANCE1_STATE_WAIT_FOR_WRITE_COMPLETE;
            }
        }
        else if(transferHandle == app_instance1Data.transferHandle4)
        {
            // Both the transfers are done, update the state to compare the received data.
            app_instance1Data.state = APP_INSTANCE1_STATE_DATA_COMPARISON;
        }  
    }
    else
    {
        app_instance1Data.clientTransferSuccess = false;
        app_instance1Data.state = APP_INSTANCE1_STATE_IDLE;
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************
bool Instance1TransferSuccessStatus(void)
{
    return app_instance1Data.clientTransferSuccess;
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
    app_instance1Data.state = APP_INSTANCE1_STATE_DATA_INIT;
    app_instance1Data.drvSPIHandle = DRV_HANDLE_INVALID;
    app_instance1Data.clientTransferSuccess = false;
    
    APP_EEPROM0_CS_Set();
    APP_EEPROM0_WP_Set();
    APP_EEPROM0_HOLD_Set();
    
    /* Clear the receive data array */
    memset(&rxData0, 0, sizeof(rxData0));
}


/******************************************************************************
  Function:
    void APP_INSTANCE1_Tasks ( void )

  Remarks:
    See prototype in app_instance1.h.
 */

void APP_INSTANCE1_Tasks ( void )
{   
    uint32_t eepromAddr = EEPROM0_START_ADDRESS; 
    
    /* Check the application's current state. */
    switch ( app_instance1Data.state )
    {
        /* Application's initial state. */
        case APP_INSTANCE1_STATE_DATA_INIT:
        {
            /* Setup SPI for instance 1 which is EEPROM 0 */
            app_instance1Data.setup.baudRateInHz = 600000;
            app_instance1Data.setup.clockPhase = DRV_SPI_CLOCK_PHASE_VALID_LEADING_EDGE;
            app_instance1Data.setup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
            app_instance1Data.setup.dataBits = DRV_SPI_DATA_BITS_8;
            app_instance1Data.setup.chipSelect = APP_EEPROM0_CS_PIN;
            app_instance1Data.setup.csPolarity = DRV_SPI_CS_POLARITY_ACTIVE_LOW;
        
            app_instance1Data.state = APP_INSTANCE1_STATE_DRIVER_SETUP;
            break;
        }
        case APP_INSTANCE1_STATE_DRIVER_SETUP:
        {
            /* Open the SPI Driver for instance 1 */
            if(app_instance1Data.drvSPIHandle == DRV_HANDLE_INVALID)
            {
                app_instance1Data.drvSPIHandle = DRV_SPI_Open( DRV_SPI_INDEX_0, DRV_IO_INTENT_READWRITE );
            }
            if(app_instance1Data.drvSPIHandle != DRV_HANDLE_INVALID)
            {
                if(DRV_SPI_TransferSetup(app_instance1Data.drvSPIHandle, &app_instance1Data.setup) == false)
                {
                   app_instance1Data.state = APP_INSTANCE1_STATE_IDLE; 
                }
               
                DRV_SPI_TransferEventHandlerSet(app_instance1Data.drvSPIHandle, SPIInstance1EventHandler, (uintptr_t)NULL);
                app_instance1Data.state = APP_INSTANCE1_STATE_WRITE_ENABLE;
            }
            break;
        }

        case APP_INSTANCE1_STATE_WRITE_ENABLE:
        {            
            DRV_SPI_WriteTransferAdd(app_instance1Data.drvSPIHandle, &writeEnableCommand0, 1, &app_instance1Data.transferHandle1 );
            if(app_instance1Data.transferHandle1 == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                /* Remain in the same state */
                app_instance1Data.state = APP_INSTANCE1_STATE_WRITE_ENABLE;
            }
            else
            {
                app_instance1Data.state = APP_INSTANCE1_STATE_WRITE;
            }
            break;
        }
        case APP_INSTANCE1_STATE_WRITE:
        {   
                //Write to EEPROM 
                txData0[0] = EEPROM0_CMD_WRITE;
                txData0[1] = (uint8_t)(eepromAddr>>16);
                txData0[2] = (uint8_t)(eepromAddr>>8);                 
                txData0[3] = (uint8_t)(eepromAddr);
                
                
                DRV_SPI_WriteTransferAdd(app_instance1Data.drvSPIHandle, txData0, sizeof(txData0), &app_instance1Data.transferHandle2 );   
                if(app_instance1Data.transferHandle2 == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    /* Remain in the same state */
                    app_instance1Data.state = APP_INSTANCE1_STATE_WRITE;
                }
                else
                {
                    app_instance1Data.state = APP_INSTANCE1_STATE_WAIT_FOR_WRITE_COMPLETE;
                }
            break;
        }
        case APP_INSTANCE1_STATE_WAIT_FOR_WRITE_COMPLETE:
        {   
                app_instance1Data.state = APP_INSTANCE1_STATE_IDLE;
            
                DRV_SPI_WriteReadTransferAdd(app_instance1Data.drvSPIHandle, &readStatusCommand0, 1, rxData0, 2, &app_instance1Data.transferHandle3 );   
                if(app_instance1Data.transferHandle3 == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    /* Remain in the same state */
                    app_instance1Data.state = APP_INSTANCE1_STATE_WAIT_FOR_WRITE_COMPLETE;
                }
                else
                {
                    
                }
            break;
        }
        case APP_INSTANCE1_STATE_READ:
        {   
                app_instance1Data.state = APP_INSTANCE1_STATE_IDLE;
                
                //Read from EEPROM     
                txData0[0] = EEPROM0_CMD_READ;
                txData0[1] = (uint8_t)(eepromAddr>>16);
                txData0[2] = (uint8_t)(eepromAddr>>8);                 
                txData0[3] = (uint8_t)(eepromAddr);
                
                DRV_SPI_WriteReadTransferAdd(app_instance1Data.drvSPIHandle, txData0, 4, rxData0, sizeof(rxData0), &app_instance1Data.transferHandle4 );   
                if(app_instance1Data.transferHandle4 == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    /* Remain in the same state */
                    app_instance1Data.state = APP_INSTANCE1_STATE_READ;
                }
                else
                {
                    
                }
            break;
        }
        case APP_INSTANCE1_STATE_DATA_COMPARISON:
        {
            /* Transfer Status polling is not done here as we have already checked the transfer status in the SPIEventHandler callback function */
            if (memcmp(&txData0[4], &rxData0[4], sizeof(txData0)-4) != 0)            
            {
                app_instance1Data.clientTransferSuccess = false;
            }
            else   
            {
                app_instance1Data.clientTransferSuccess = true;
            }
            app_instance1Data.state = APP_INSTANCE1_STATE_IDLE;
 
            break;
        }
        case APP_INSTANCE1_STATE_IDLE:
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
