/*******************************************************************************
  MPLAB Harmony Application Source File
  
  Company:
    Microchip Technology Inc.
  
  File Name:
    app_client2.c

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

#include "app_client2.h"
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
    This structure should be initialized by the APP_CLIENT2_Initialize function.
    
    Application strings and buffers are be defined outside this structure.
*/

APP_CLIENT2_DATA app_client2Data;

uint8_t __attribute__ ((aligned (32))) txBufferC[]  = "Second client transmitting its txBufferC buffer at frequency 5MHZ";
uint8_t __attribute__ ((aligned (32))) txBufferD[]  = "Second client transmitting its txBufferD buffer at frequency 5MHZ";

uint8_t __attribute__ ((aligned (32))) rxBufferC[sizeof(txBufferC)];
uint8_t __attribute__ ((aligned (32))) rxBufferD[sizeof(txBufferD)];


// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

static void APP_CLIENT2_SPIEventHandler (
    DRV_SPI_TRANSFER_EVENT event,
    DRV_SPI_TRANSFER_HANDLE transferHandle, 
    uintptr_t context 
)
{
    if (event == DRV_SPI_TRANSFER_EVENT_COMPLETE)
    {
        if(transferHandle == app_client2Data.transferHandle1)
        {
            /* Do nothing */
        }
        else if(transferHandle == app_client2Data.transferHandle2)
        {
            /* Both the transfers are complete. Set a flag to indicate the same to the state machine */
            app_client2Data.transferStatus = true;
        }  
    }
    else
    {
        app_client2Data.transferStatus = false;
        
        /* Move the state machine into Error state */
        app_client2Data.state = APP_CLIENT2_STATE_ERROR;
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************
bool APP_CLIENT2_TransferSuccessStatus(void)
{
    if (app_client2Data.state == APP_CLIENT2_STATE_IDLE)
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
    void APP_CLIENT2_Initialize ( void )

  Remarks:
    See prototype in app_client2.h.
 */

void APP_CLIENT2_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app_client2Data.state = APP_CLIENT2_STATE_INIT;
    app_client2Data.drvSPIHandle = DRV_HANDLE_INVALID;
    app_client2Data.transferStatus = false;
    
    /* Clear the receive buffers */
    memset(&rxBufferC, 0, sizeof(rxBufferC));
    memset(&rxBufferD, 0, sizeof(rxBufferD));
}


/******************************************************************************
  Function:
    void APP_CLIENT2_Tasks ( void )

  Remarks:
    See prototype in app_client2.h.
 */

void APP_CLIENT2_Tasks ( void )
{   
    /* Check the application's current state. */
    switch ( app_client2Data.state )
    {
        /* Application's initial state. */
        case APP_CLIENT2_STATE_INIT:
        
            /* Setup SPI for client 1 */
            app_client2Data.setup.baudRateInHz = 5000000;
            app_client2Data.setup.clockPhase = DRV_SPI_CLOCK_PHASE_VALID_TRAILING_EDGE;
            app_client2Data.setup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
            app_client2Data.setup.dataBits = DRV_SPI_DATA_BITS_8;
            app_client2Data.setup.chipSelect = (SYS_PORT_PIN)CLIENT2_CS_PIN;
            app_client2Data.setup.csPolarity = DRV_SPI_CS_POLARITY_ACTIVE_LOW;
        
            app_client2Data.state = APP_CLIENT2_STATE_OPEN_DRIVER;
            break;
        
        case APP_CLIENT2_STATE_OPEN_DRIVER:
            
            /* Open the SPI Driver for client 1 */
            app_client2Data.drvSPIHandle = DRV_SPI_Open( DRV_SPI_INDEX_0, DRV_IO_INTENT_READWRITE );
            
            if(app_client2Data.drvSPIHandle != DRV_HANDLE_INVALID)
            {
                if(DRV_SPI_TransferSetup(app_client2Data.drvSPIHandle, &app_client2Data.setup) == true)
                {
                    /* Register an event handler with the SPI driver */
                    DRV_SPI_TransferEventHandlerSet(app_client2Data.drvSPIHandle, APP_CLIENT2_SPIEventHandler, (uintptr_t)NULL);
                    
                    app_client2Data.state = APP_CLIENT2_STATE_QUEUE_SPI_REQUEST;
                }
                else
                {
                    app_client2Data.state = APP_CLIENT2_STATE_ERROR; 
                }                              
            }
            else
            {
                app_client2Data.state = APP_CLIENT2_STATE_ERROR; 
            }    
            break;        

        case APP_CLIENT2_STATE_QUEUE_SPI_REQUEST:
        
            app_client2Data.state = APP_CLIENT2_STATE_CHECK_TRANSFER_STATUS;
        
            DRV_SPI_WriteReadTransferAdd(app_client2Data.drvSPIHandle, txBufferC, sizeof(txBufferC), rxBufferC, sizeof(rxBufferC), &app_client2Data.transferHandle1 );
                                                                 
            if(app_client2Data.transferHandle1 == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                /* Maybe the driver could not queue in the request. Try increasing the SPI driver transfer queue size from MHC */
                app_client2Data.state = APP_CLIENT2_STATE_ERROR;
            }
            else
            {
                /* First request is queued in successfully. Use the queueing feature of the SPI driver to queue up another SPI request. 
                   Make sure the SPI driver queue size is large enough to queue in multiple requests.
                */
                DRV_SPI_WriteReadTransferAdd(app_client2Data.drvSPIHandle, txBufferD, sizeof(txBufferD), rxBufferD, sizeof(rxBufferD), &app_client2Data.transferHandle2 );  
                
                if(app_client2Data.transferHandle2 == DRV_SPI_TRANSFER_HANDLE_INVALID)
                {
                    /* Maybe the driver could not queue in the request. Try increasing the SPI driver transfer queue size from MHC */
                    app_client2Data.state = APP_CLIENT2_STATE_ERROR;
                }
            }
            break;
        
        case APP_CLIENT2_STATE_CHECK_TRANSFER_STATUS:
           
            if(app_client2Data.transferStatus == true)
            {
                /* Both the queued SPI requests are complete. Now, validate the loopbacked data in the receive buffer */
                app_client2Data.state = APP_CLIENT2_STATE_LOOPBACK_DATA_VERIFY;                
            }
            break;
        
        case APP_CLIENT2_STATE_LOOPBACK_DATA_VERIFY:
                    
            if ((memcmp(txBufferC, rxBufferC, sizeof(txBufferC)) != 0) || (memcmp(txBufferD, rxBufferD, sizeof(txBufferD)) != 0))            
            {
                app_client2Data.state = APP_CLIENT2_STATE_ERROR;
            }
            else   
            {
                app_client2Data.state = APP_CLIENT2_STATE_IDLE;
            }            
 
            break;
        
        case APP_CLIENT2_STATE_IDLE:        
            break;
            
        case APP_CLIENT2_STATE_ERROR:
            break;
               
        default:
            break;
    }
}

/*******************************************************************************
 End of File
 */
