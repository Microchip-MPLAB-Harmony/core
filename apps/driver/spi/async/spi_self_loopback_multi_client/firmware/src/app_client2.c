/*******************************************************************************
  MPLAB Harmony Application Source File
  
  Company:
    Microchip Technology Inc.
  
  File Name:
    app.c

  Summary:
    This file contains the source code for client 2 of the MPLAB Harmony
    application.

  Description:
    This file has the source code for client 2 which transfers the data on SPI
    line at a particular baud rate.
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
    This structure should be initialized by the APP_CLIENT2_Initialize function.
    
    Application strings and buffers are be defined outside this structure.
*/

APP_CLIENT2_DATA app_client2Data;

uint8_t __attribute__ ((aligned (32))) txDataB[]  = "SECOND CLIENT TRANSMITTING ITS DATA AT FREQ 5MHZ";

uint8_t __attribute__ ((aligned (32))) rxDataB[sizeof(txDataB)];

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************


// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************
bool Client2TransferSuccessStatus(void)
{
    return app_client2Data.clientTransferSuccess;
}

bool Client2TransferQueuedStatus(void)
{
    return app_client2Data.clientTransferAdded;
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
    app_client2Data.state = APP_CLIENT2_STATE_DATA_INIT;
    app_client2Data.drvSPIHandle = DRV_HANDLE_INVALID;
    app_client2Data.clientTransferSuccess = false;
    app_client2Data.clientTransferAdded = false;
    
    /* Clear the receive data array */
    memset(&rxDataB, 0, sizeof(rxDataB));
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
        case APP_CLIENT2_STATE_DATA_INIT:
        {          
            /* Setup SPI for client 2 */
            app_client2Data.setup.baudRateInHz = 5000000;
            app_client2Data.setup.clockPhase = DRV_SPI_CLOCK_PHASE_VALID_TRAILING_EDGE;
            app_client2Data.setup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
            app_client2Data.setup.dataBits = DRV_SPI_DATA_BITS_8;
            app_client2Data.setup.chipSelect = SYS_PORT_PIN_PD11;
            app_client2Data.setup.csPolarity = DRV_SPI_CS_POLARITY_ACTIVE_LOW;
        
            app_client2Data.state = APP_CLIENT2_STATE_SPI_OPEN_CLIENT;
            break;
        }

        case APP_CLIENT2_STATE_SPI_OPEN_CLIENT:
        {
            /* Open the SPI Driver for client 2 */
            if(app_client2Data.drvSPIHandle == DRV_HANDLE_INVALID)
            {
                app_client2Data.drvSPIHandle = DRV_SPI_Open( DRV_SPI_INDEX_0, DRV_IO_INTENT_READWRITE );
            }
            if(app_client2Data.drvSPIHandle != DRV_HANDLE_INVALID)
            {
                if(DRV_SPI_TransferSetup(app_client2Data.drvSPIHandle, &app_client2Data.setup) == false)
                {
                   app_client2Data.state = APP_CLIENT2_STATE_IDLE; 
                }
                
                app_client2Data.state = APP_CLIENT2_STATE_SPI_TRANSFER_START;
            }
            break;
        }
        case APP_CLIENT2_STATE_SPI_TRANSFER_START:
        {               
            DRV_SPI_WriteReadTransferAdd(app_client2Data.drvSPIHandle, &txDataB, sizeof(txDataB), &rxDataB, sizeof(rxDataB), &app_client2Data.transferHandle1);
            if(app_client2Data.transferHandle1 == DRV_SPI_TRANSFER_HANDLE_INVALID)
            {
                /* Remain in the same state */
                app_client2Data.state = APP_CLIENT2_STATE_SPI_TRANSFER_START;
            }
            else
            {
                /* Transfer request is queued successfully, go to next state */
                app_client2Data.clientTransferAdded = true;
                app_client2Data.state = APP_CLIENT2_STATE_SPI_DATA_COMPARISON;
            }
            break;
        }
        case APP_CLIENT2_STATE_SPI_DATA_COMPARISON:
        {
            /* Transfer Status polling is needed here as we didn't register any callback function */
            if(DRV_SPI_TransferStatusGet(app_client2Data.transferHandle1) <= DRV_SPI_TRANSFER_EVENT_ERROR)
            {
                app_client2Data.clientTransferSuccess = false;
                app_client2Data.state = APP_CLIENT2_STATE_IDLE;
            }
            else if(DRV_SPI_TransferStatusGet(app_client2Data.transferHandle1) >= DRV_SPI_TRANSFER_EVENT_COMPLETE)
            {
                if(memcmp(txDataB, rxDataB, sizeof(txDataB)) != 0)
                {
                    app_client2Data.clientTransferSuccess = false;
                }
                else   
                {
                    app_client2Data.clientTransferSuccess = true;
                }
                app_client2Data.state = APP_CLIENT2_STATE_IDLE;
            }
            else
            {
                /* It means transfer is still pending, wait in the same state */
            }
            break;
        }
        case APP_CLIENT2_STATE_IDLE:
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
