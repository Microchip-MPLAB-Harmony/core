/*******************************************************************************
  MPLAB Harmony Application Source File
  
  Company:
    Microchip Technology Inc.
  
  File Name:
    app_client1.c

  Summary:
    This file contains the source code for client 1 of the MPLAB Harmony
    application.

  Description:
    This file has the source code for client 1 which transfers the data on SPI
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

#include "app_client1.h"
#include "app_client2.h"
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
    This structure should be initialized by the APP_CLIENT1_Initialize function.
    
    Application strings and buffers are be defined outside this structure.
*/

APP_CLIENT1_DATA app_client1Data;

uint8_t __attribute__ ((aligned (32))) txDataA[]  = "FIRST CLIENT TRANSMITTING ITS FIRST SET OF DATA AT FREQ 2MHZ";
uint8_t __attribute__ ((aligned (32))) txDataC[]  = "AGAIN FIRST CLIENT TRANSMITTING NEW DATA AT FREQ OF 2MHZ";

uint8_t __attribute__ ((aligned (32))) rxDataA[sizeof(txDataA)];
uint8_t __attribute__ ((aligned (32))) rxDataC[sizeof(txDataC)];


// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

void SPIEventHandler (DRV_SPI_TRANSFER_EVENT event,
        DRV_SPI_TRANSFER_HANDLE transferHandle, uintptr_t context )
{
    if (event == DRV_SPI_TRANSFER_EVENT_COMPLETE)
    {
        if(transferHandle == app_client1Data.transferHandle1)
        {
            // Do nothing
        }
        else if(transferHandle == app_client1Data.transferHandle2)
        {
            // Both the transfers are done, update the state to compare the received data.
            app_client1Data.state = APP_CLIENT1_STATE_SPI_DATA_COMPARISON;
        }  
    }
    else
    {
        app_client1Data.clientTransferSuccess = false;
        app_client1Data.state = APP_CLIENT1_STATE_IDLE;
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************
bool Client1TransferSuccessStatus(void)
{
    return app_client1Data.clientTransferSuccess;
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_CLIENT1_Initialize ( void )

  Remarks:
    See prototype in app_client1.h.
 */

void APP_CLIENT1_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app_client1Data.state = APP_CLIENT1_STATE_DATA_INIT;
    app_client1Data.drvSPIHandle = DRV_HANDLE_INVALID;
    app_client1Data.clientTransferSuccess = false;
    
    /* Clear the receive data array */
    memset(&rxDataA, 0, sizeof(rxDataA));
    memset(&rxDataC, 0, sizeof(rxDataC));
}


/******************************************************************************
  Function:
    void APP_CLIENT1_Tasks ( void )

  Remarks:
    See prototype in app_client1.h.
 */

void APP_CLIENT1_Tasks ( void )
{   
    /* Check the application's current state. */
    switch ( app_client1Data.state )
    {
        /* Application's initial state. */
        case APP_CLIENT1_STATE_DATA_INIT:
        {
            /* Setup SPI for client 1 */
            app_client1Data.setup.baudRateInHz = 2000000;
            app_client1Data.setup.clockPhase = DRV_SPI_CLOCK_PHASE_VALID_TRAILING_EDGE;
            app_client1Data.setup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
            app_client1Data.setup.dataBits = DRV_SPI_DATA_BITS_8;
            app_client1Data.setup.chipSelect = (SYS_PORT_PIN)CHIP_SELECT0_PIN;
            app_client1Data.setup.csPolarity = DRV_SPI_CS_POLARITY_ACTIVE_LOW;
        
            app_client1Data.state = APP_CLIENT1_STATE_SPI_OPEN_CLIENT;
            break;
        }
        case APP_CLIENT1_STATE_SPI_OPEN_CLIENT:
        {
            /* Open the SPI Driver for client 1 */
            if(app_client1Data.drvSPIHandle == DRV_HANDLE_INVALID)
            {
                app_client1Data.drvSPIHandle = DRV_SPI_Open( DRV_SPI_INDEX_0, DRV_IO_INTENT_READWRITE );
            }
            if(app_client1Data.drvSPIHandle != DRV_HANDLE_INVALID)
            {
                if(DRV_SPI_TransferSetup(app_client1Data.drvSPIHandle, &app_client1Data.setup) == false)
                {
                   app_client1Data.state = APP_CLIENT1_STATE_IDLE; 
                }
               
                DRV_SPI_TransferEventHandlerSet(app_client1Data.drvSPIHandle, SPIEventHandler, (uintptr_t)NULL);
                app_client1Data.state = APP_CLIENT1_STATE_SPI_TRANSFER_START;
            }
            break;
        }

        case APP_CLIENT1_STATE_SPI_TRANSFER_START:
        {            
            app_client1Data.state = APP_CLIENT1_STATE_SPI_NEXT_TRANSFER_AFTER_CLIENT2;
            
            DRV_SPI_WriteReadTransferAdd(app_client1Data.drvSPIHandle, &txDataA, sizeof(txDataA), &rxDataA, sizeof(rxDataA), &app_client1Data.transferHandle1 );
            if(app_client1Data.transferHandle1 == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                /* Remain in the same state */
                app_client1Data.state = APP_CLIENT1_STATE_SPI_TRANSFER_START;
            }
            else
            {
                /* Transfer request is queued successfully, go to the next state as assigned just before the Add request */     
            }
            break;
        }
        case APP_CLIENT1_STATE_SPI_NEXT_TRANSFER_AFTER_CLIENT2:
        {   
            if(Client2TransferQueuedStatus() == true)
            {
                app_client1Data.state = APP_CLIENT1_STATE_IDLE;

                DRV_SPI_WriteReadTransferAdd(app_client1Data.drvSPIHandle, &txDataC, sizeof(txDataC), &rxDataC, sizeof(rxDataC), &app_client1Data.transferHandle2 );
                if(app_client1Data.transferHandle2 == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    /* Remain in the same state */
                    app_client1Data.state = APP_CLIENT1_STATE_SPI_NEXT_TRANSFER_AFTER_CLIENT2;
                }
                else
                {
                    /* Transfer request is queued successfully, go to the next state as assigned just before the Add request */     
                }
            }
            break;
        }
        case APP_CLIENT1_STATE_SPI_DATA_COMPARISON:
        {
            /* Transfer Status polling is not done here as we have already checked the transfer status in the SPIEventHandler callback function */
            if ((memcmp(txDataA, rxDataA, sizeof(txDataA)) != 0) || (memcmp(txDataC, rxDataC, sizeof(txDataC)) != 0))            
            {
                app_client1Data.clientTransferSuccess = false;
            }
            else   
            {
                app_client1Data.clientTransferSuccess = true;
            }
            app_client1Data.state = APP_CLIENT1_STATE_IDLE;
 
            break;
        }
        case APP_CLIENT1_STATE_IDLE:
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
