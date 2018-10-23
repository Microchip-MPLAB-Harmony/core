/*******************************************************************************
  MPLAB Harmony Application Source File
  
  Company:
    Microchip Technology Inc.
  
  File Name:
    app_instance2.c

  Summary:
    This file contains the source code for instance 2 of the MPLAB Harmony
    application.

  Description:
    This file has the source code for instance 2 which transfers the data on SPI
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
    This structure should be initialized by the APP_INSTANCE2_Initialize function.
    
    Application strings and buffers are be defined outside this structure.
*/

APP_INSTANCE2_DATA app_instance2Data;

uint8_t __attribute__ ((aligned (32))) txData1[]  = "----WRITING AND READING DATA ON FIRST INSTANCE EEPROM 1";

uint8_t __attribute__ ((aligned (32))) rxData1[sizeof(txData1)];

/* EEPROM Commands */
#define EEPROM1_CMD_WREN                       0x06
#define EEPROM1_CMD_WRITE                      0x02
#define EEPROM1_CMD_RDSR                       0x05
#define EEPROM1_CMD_READ                       0x03

uint8_t writeEnableCommand1 = EEPROM1_CMD_WREN;
uint8_t readStatusCommand1  = EEPROM1_CMD_RDSR;

#define EEPROM1_START_ADDRESS                  0x000000
// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

void SPIInstance2EventHandler (DRV_SPI_TRANSFER_EVENT event,
        DRV_SPI_TRANSFER_HANDLE transferHandle, uintptr_t context )
{
    if (event == DRV_SPI_TRANSFER_EVENT_COMPLETE)
    {
        if(transferHandle == app_instance2Data.transferHandle3)
        {
            if(!(rxData1[1] & 0x01))
            {
                app_instance2Data.state = APP_INSTANCE2_STATE_READ;
            }
            else
            {
                app_instance2Data.state = APP_INSTANCE2_STATE_WAIT_FOR_WRITE_COMPLETE;
            }
        }
        else if(transferHandle == app_instance2Data.transferHandle4)
        {
            // Both the transfers are done, update the state to compare the received data.
            app_instance2Data.state = APP_INSTANCE2_STATE_DATA_COMPARISON;
        }  
    }
    else
    {
        app_instance2Data.clientTransferSuccess = false;
        app_instance2Data.state = APP_INSTANCE2_STATE_IDLE;
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************
bool Instance2TransferSuccessStatus(void)
{
    return app_instance2Data.clientTransferSuccess;
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_INSTANCE2_Initialize ( void )

  Remarks:
    See prototype in app_instance2.h.
 */

void APP_INSTANCE2_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app_instance2Data.state = APP_INSTANCE2_STATE_DATA_INIT;
    app_instance2Data.drvSPIHandle = DRV_HANDLE_INVALID;
    app_instance2Data.clientTransferSuccess = false;
    
    APP_EEPROM1_CS_Set();
    APP_EEPROM1_WP_Set();
    APP_EEPROM1_HOLD_Set();
    
    /* Clear the receive data array */
    memset(&rxData1, 0, sizeof(rxData1));
}


/******************************************************************************
  Function:
    void APP_INSTANCE2_Tasks ( void )

  Remarks:
    See prototype in app_instance2.h.
 */

void APP_INSTANCE2_Tasks ( void )
{
    uint32_t eepromAddr = EEPROM1_START_ADDRESS; 
    
    /* Check the application's current state. */
    switch ( app_instance2Data.state )
    {
        /* Application's initial state. */
        case APP_INSTANCE2_STATE_DATA_INIT:
        {
            /* Setup SPI for instance 2 which is EEPROM 1 */
            app_instance2Data.setup.baudRateInHz = 500000;
            app_instance2Data.setup.clockPhase = DRV_SPI_CLOCK_PHASE_VALID_LEADING_EDGE;
            app_instance2Data.setup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
            app_instance2Data.setup.dataBits = DRV_SPI_DATA_BITS_8;
            app_instance2Data.setup.chipSelect = APP_EEPROM1_CS_PIN;
            app_instance2Data.setup.csPolarity = DRV_SPI_CS_POLARITY_ACTIVE_LOW;
        
            app_instance2Data.state = APP_INSTANCE2_STATE_DRIVER_SETUP;
            break;
        }
        case APP_INSTANCE2_STATE_DRIVER_SETUP:
        {
            /* Open the SPI Driver for instance 2 */
            if(app_instance2Data.drvSPIHandle == DRV_HANDLE_INVALID)
            {
                app_instance2Data.drvSPIHandle = DRV_SPI_Open( DRV_SPI_INDEX_1, DRV_IO_INTENT_READWRITE );
            }
            if(app_instance2Data.drvSPIHandle != DRV_HANDLE_INVALID)
            {
                if(DRV_SPI_TransferSetup(app_instance2Data.drvSPIHandle, &app_instance2Data.setup) == false)
                {
                   app_instance2Data.state = APP_INSTANCE2_STATE_IDLE; 
                }
               
                DRV_SPI_TransferEventHandlerSet(app_instance2Data.drvSPIHandle, SPIInstance2EventHandler, (uintptr_t)NULL);
                app_instance2Data.state = APP_INSTANCE2_STATE_WRITE_ENABLE;
            }
            break;
        }

        case APP_INSTANCE2_STATE_WRITE_ENABLE:
        {            
            DRV_SPI_WriteTransferAdd(app_instance2Data.drvSPIHandle, &writeEnableCommand1, 1, &app_instance2Data.transferHandle1 );
            if(app_instance2Data.transferHandle1 == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                /* Remain in the same state */
                app_instance2Data.state = APP_INSTANCE2_STATE_WRITE_ENABLE;
            }
            else
            {
                app_instance2Data.state = APP_INSTANCE2_STATE_WRITE;
            }
            break;
        }
        case APP_INSTANCE2_STATE_WRITE:
        {   
                //Write to EEPROM 
                txData1[0] = EEPROM1_CMD_WRITE;
                txData1[1] = (uint8_t)(eepromAddr>>16);
                txData1[2] = (uint8_t)(eepromAddr>>8);                 
                txData1[3] = (uint8_t)(eepromAddr);
                
                DRV_SPI_WriteTransferAdd(app_instance2Data.drvSPIHandle, txData1, sizeof(txData1), &app_instance2Data.transferHandle2 );   
                if(app_instance2Data.transferHandle2 == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    /* Remain in the same state */
                    app_instance2Data.state = APP_INSTANCE2_STATE_WRITE;
                }
                else
                {
                    app_instance2Data.state = APP_INSTANCE2_STATE_WAIT_FOR_WRITE_COMPLETE;
                }
            break;
        }
        case APP_INSTANCE2_STATE_WAIT_FOR_WRITE_COMPLETE:
        {   
                app_instance2Data.state = APP_INSTANCE2_STATE_IDLE;
            
                DRV_SPI_WriteReadTransferAdd(app_instance2Data.drvSPIHandle, &readStatusCommand1, 1, rxData1, 2, &app_instance2Data.transferHandle3 );   
                if(app_instance2Data.transferHandle3 == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    /* Remain in the same state */
                    app_instance2Data.state = APP_INSTANCE2_STATE_WAIT_FOR_WRITE_COMPLETE;
                }
                else
                {
                    
                }
            break;
        }
        case APP_INSTANCE2_STATE_READ:
        {   
                app_instance2Data.state = APP_INSTANCE2_STATE_IDLE;
                
                //Read from EEPROM     
                txData1[0] = EEPROM1_CMD_READ;
                txData1[1] = (uint8_t)(eepromAddr>>16);
                txData1[2] = (uint8_t)(eepromAddr>>8);                 
                txData1[3] = (uint8_t)(eepromAddr);
                
                DRV_SPI_WriteReadTransferAdd(app_instance2Data.drvSPIHandle, txData1, 4, rxData1, sizeof(rxData1), &app_instance2Data.transferHandle4 );   
                if(app_instance2Data.transferHandle4 == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    /* Remain in the same state */
                    app_instance2Data.state = APP_INSTANCE2_STATE_READ;
                }
                else
                {
                    
                }
            break;
        }
        case APP_INSTANCE2_STATE_DATA_COMPARISON:
        {
            /* Transfer Status polling is not done here as we have already checked the transfer status in the SPIEventHandler callback function */
            if (memcmp(&txData1[4], &rxData1[4], sizeof(txData1)-4) != 0)            
            {
                app_instance2Data.clientTransferSuccess = false;
            }
            else   
            {
                app_instance2Data.clientTransferSuccess = true;
            }
            app_instance2Data.state = APP_INSTANCE2_STATE_IDLE;
 
            break;
        }
        case APP_INSTANCE2_STATE_IDLE:
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
