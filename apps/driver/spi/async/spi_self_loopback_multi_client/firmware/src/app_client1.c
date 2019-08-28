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
#include <string.h>

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

uint8_t __attribute__ ((aligned (32))) txBufferA[]  = "First client transmitting its txBufferA buffer at frequency 2MHZ";
uint8_t __attribute__ ((aligned (32))) txBufferB[]  = "First client transmitting its txBufferB buffer at frequency 2MHZ";

uint8_t __attribute__ ((aligned (32))) rxBufferA[sizeof(txBufferA)];
uint8_t __attribute__ ((aligned (32))) rxBufferB[sizeof(txBufferB)];


// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

static void APP_CLIENT1_SPIEventHandler (
    DRV_SPI_TRANSFER_EVENT event,
    DRV_SPI_TRANSFER_HANDLE transferHandle, 
    uintptr_t context 
)
{
    if (event == DRV_SPI_TRANSFER_EVENT_COMPLETE)
    {
        if(transferHandle == app_client1Data.transferHandle1)
        {
            /* Do nothing */
        }
        else if(transferHandle == app_client1Data.transferHandle2)
        {
            /* Both the transfers are complete. Set a flag to indicate the same to the state machine */
            app_client1Data.transferStatus = true;
        }  
    }
    else
    {
        app_client1Data.transferStatus = false;
        
        /* Move the state machine into Error state */
        app_client1Data.state = APP_CLIENT1_STATE_ERROR;
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************
bool APP_CLIENT1_TransferSuccessStatus(void)
{
    if (app_client1Data.state == APP_CLIENT1_STATE_IDLE)
    {
        return true;
    }
    else
    {
        return false;
    }
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
    app_client1Data.state = APP_CLIENT1_STATE_INIT;
    app_client1Data.drvSPIHandle = DRV_HANDLE_INVALID;
    app_client1Data.transferStatus = false;
    
    /* Clear the receive buffers */
    memset(&rxBufferA, 0, sizeof(rxBufferA));
    memset(&rxBufferB, 0, sizeof(rxBufferB));
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
        case APP_CLIENT1_STATE_INIT:
        
            /* Setup SPI for client 1 */
            app_client1Data.setup.baudRateInHz = 2000000;
            app_client1Data.setup.clockPhase = DRV_SPI_CLOCK_PHASE_VALID_TRAILING_EDGE;
            app_client1Data.setup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
            app_client1Data.setup.dataBits = DRV_SPI_DATA_BITS_8;
            app_client1Data.setup.chipSelect = (SYS_PORT_PIN)CLIENT1_CS_PIN;
            app_client1Data.setup.csPolarity = DRV_SPI_CS_POLARITY_ACTIVE_LOW;
        
            app_client1Data.state = APP_CLIENT1_STATE_OPEN_DRIVER;
            break;
        
        case APP_CLIENT1_STATE_OPEN_DRIVER:
            
            /* Open the SPI Driver for client 1 */
            app_client1Data.drvSPIHandle = DRV_SPI_Open( DRV_SPI_INDEX_0, DRV_IO_INTENT_READWRITE );
            
            if(app_client1Data.drvSPIHandle != DRV_HANDLE_INVALID)
            {
                if(DRV_SPI_TransferSetup(app_client1Data.drvSPIHandle, &app_client1Data.setup) == true)
                {
                    /* Register an event handler with the SPI driver */
                    DRV_SPI_TransferEventHandlerSet(app_client1Data.drvSPIHandle, APP_CLIENT1_SPIEventHandler, (uintptr_t)NULL);
                    
                    app_client1Data.state = APP_CLIENT1_STATE_QUEUE_SPI_REQUEST;
                }
                else
                {
                    app_client1Data.state = APP_CLIENT1_STATE_ERROR; 
                }                              
            }
            else
            {
                app_client1Data.state = APP_CLIENT1_STATE_ERROR; 
            }    
            break;        

        case APP_CLIENT1_STATE_QUEUE_SPI_REQUEST:
        
            app_client1Data.state = APP_CLIENT1_STATE_CHECK_TRANSFER_STATUS;
        
            DRV_SPI_WriteReadTransferAdd(app_client1Data.drvSPIHandle, txBufferA, sizeof(txBufferA), rxBufferA, sizeof(rxBufferA), &app_client1Data.transferHandle1 );
                                                                 
            if(app_client1Data.transferHandle1 == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                /* Maybe the driver could not queue in the request. Try increasing the SPI driver transfer queue size from MHC */
                app_client1Data.state = APP_CLIENT1_STATE_ERROR;
            }
            else
            {
                /* First request is queued in successfully. Use the queueing feature of the SPI driver to queue up another SPI request. 
                   Make sure the SPI driver queue size is large enough to queue in multiple requests.
                */
                DRV_SPI_WriteReadTransferAdd(app_client1Data.drvSPIHandle, txBufferB, sizeof(txBufferB), rxBufferB, sizeof(rxBufferB), &app_client1Data.transferHandle2 );  
                
                if(app_client1Data.transferHandle2 == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    /* Maybe the driver could not queue in the request. Try increasing the SPI driver transfer queue size from MHC */
                    app_client1Data.state = APP_CLIENT1_STATE_ERROR;
                }
            }
            break;
        
        case APP_CLIENT1_STATE_CHECK_TRANSFER_STATUS:
           
            if(app_client1Data.transferStatus == true)
            {
                /* Both the queued SPI requests are complete. Now, validate the loopbacked data in the receive buffer */
                app_client1Data.state = APP_CLIENT1_STATE_LOOPBACK_DATA_VERIFY;                
            }
            break;
        
        case APP_CLIENT1_STATE_LOOPBACK_DATA_VERIFY:
                    
            if ((memcmp(txBufferA, rxBufferA, sizeof(txBufferA)) != 0) || (memcmp(txBufferB, rxBufferB, sizeof(txBufferB)) != 0))            
            {
                app_client1Data.state = APP_CLIENT1_STATE_ERROR;
            }
            else   
            {
                app_client1Data.state = APP_CLIENT1_STATE_IDLE;
            }            
 
            break;
        
        case APP_CLIENT1_STATE_IDLE:        
            break;
            
        case APP_CLIENT1_STATE_ERROR:
            break;
               
        default:
            break;
    }
}

/*******************************************************************************
 End of File
 */
