/*******************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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

/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_sam_a5d2_xult.c

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

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "app_sam_a5d2_xult.h"
#include "bsp/bsp.h"
#include "definitions.h"
#include <string.h>

#define LED_ON() LED_BLUE_On()
#define LED_OFF() LED_BLUE_Off()

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
    This structure should be initialized by the APP_SAM_A5D2_XULT_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_SAM_A5D2_XULT_DATA app_sam_a5d2_xultData;

// *****************************************************************************
/* Application Test Write Data array

  Summary:
    Holds the application test write data.

  Description:
    This array holds the application's test write data.

  Remarks:
    None.
*/

static const uint8_t testTxData[APP_WRITE_DATA_LENGTH] = 
{
	APP_AT24MAC_MEMORY_ADDR, 
    'A', 'T', 'S', 'A', 'M', ' ', 'T', 'W', 'I', 'H', 'S', ' ', 'D', 'e', 'm', 'o',
};

// *****************************************************************************
/* Application Acknowledge polling Data byte.

  Summary:
    Holds the application acknowledge polling data byte.

  Description:
    This array holds the application's acknowledge polling data byte.

  Remarks:
    None.
*/

static uint8_t ackData = 0;

// *****************************************************************************
/* Application Test read Data array.

  Summary:
    Holds the application read test data.

  Description:
    This array holds the application's read test data.

  Remarks:
    None.
*/

static uint8_t  testRxData[APP_READ_DATA_LENGTH] = {0};

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

void APP_I2CEventHandler ( 
    DRV_I2C_TRANSFER_EVENT event,
    DRV_I2C_TRANSFER_HANDLE transferHandle, 
    uintptr_t context 
)
{
    APP_TRANSFER_STATUS* transferStatus = (APP_TRANSFER_STATUS*)context;
    
    if (event == DRV_I2C_TRANSFER_EVENT_COMPLETE)
    {
        if (transferStatus)
        {
            *transferStatus = APP_TRANSFER_STATUS_SUCCESS;
        }
    }
    else
    {
        if (transferStatus)
        {
            *transferStatus = APP_TRANSFER_STATUS_ERROR;
        }        
    }    
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************


/* TODO:  Add any necessary local functions.
*/


// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_SAM_A5D2_XULT_Initialize ( void )

  Remarks:
    See prototype in app_sam_a5d2_xult.h.
 */

void APP_SAM_A5D2_XULT_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_INIT;
    app_sam_a5d2_xultData.drvI2CHandle   = DRV_HANDLE_INVALID;
    app_sam_a5d2_xultData.transferHandle = DRV_I2C_TRANSFER_HANDLE_INVALID;   
    app_sam_a5d2_xultData.transferStatus = APP_TRANSFER_STATUS_ERROR;
    
    /* Initialize the success LED */
    LED_OFF();
}


/******************************************************************************
  Function:
    void APP_SAM_A5D2_XULT_Tasks ( void )

  Remarks:
    See prototype in app_sam_a5d2_xult.h.
 */

void APP_SAM_A5D2_XULT_Tasks ( void )
{        
    /* Check the application's current state. */
    switch ( app_sam_a5d2_xultData.state )
    {
        /* Application's initial state. */
        case APP_SAM_A5D2_XULT_STATE_INIT:
            
            /* Open the I2C Driver */
            app_sam_a5d2_xultData.drvI2CHandle = DRV_I2C_Open( DRV_I2C_INDEX_0, DRV_IO_INTENT_READWRITE );
            if(app_sam_a5d2_xultData.drvI2CHandle == DRV_HANDLE_INVALID)
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
            }    
            else
            {
                /* Register the I2C Driver event Handler */
                DRV_I2C_TransferEventHandlerSet( 
                    app_sam_a5d2_xultData.drvI2CHandle, 
                    APP_I2CEventHandler, 
                    (uintptr_t)&app_sam_a5d2_xultData.transferStatus 
                );            
                app_sam_a5d2_xultData.state  = APP_SAM_A5D2_XULT_STATE_IS_EEPROM_READY;
            }                        
            break;
                
        case APP_SAM_A5D2_XULT_STATE_IS_EEPROM_READY:
        
            app_sam_a5d2_xultData.transferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
            /* Add a Write Transfer request to verify whether EEPROM is ready */
            DRV_I2C_WriteTransferAdd( 
                app_sam_a5d2_xultData.drvI2CHandle,
                APP_AT24MAC_DEVICE_ADDR,
                (void *)&ackData,
                APP_ACK_DATA_LENGTH,
                &app_sam_a5d2_xultData.transferHandle 
            );
            
            if( app_sam_a5d2_xultData.transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
            }
            else
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_DATA_WRITE;
            }            
            break;        

        case APP_SAM_A5D2_XULT_STATE_DATA_WRITE:
            if (app_sam_a5d2_xultData.transferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                app_sam_a5d2_xultData.transferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                
                /* Add a request to write the application data */
                DRV_I2C_WriteTransferAdd(
                    app_sam_a5d2_xultData.drvI2CHandle,
                    APP_AT24MAC_DEVICE_ADDR,
                    (void *)&testTxData[0],
                    APP_WRITE_DATA_LENGTH,
                    &app_sam_a5d2_xultData.transferHandle 
                );
                
                if( app_sam_a5d2_xultData.transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
                {
                    app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
                }
                else
                {
                    app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_WAIT_WRITE_COMPLETE;
                }
            }
            else if (app_sam_a5d2_xultData.transferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                // EEPROM is not ready. Go to error state.
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
            }            
            break;
        
        case APP_SAM_A5D2_XULT_STATE_WAIT_WRITE_COMPLETE:
            if (app_sam_a5d2_xultData.transferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                app_sam_a5d2_xultData.transferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                
                /* Add a request to check if EEPROM's internal write cycle is complete */
                DRV_I2C_WriteTransferAdd( 
                    app_sam_a5d2_xultData.drvI2CHandle,
                    APP_AT24MAC_DEVICE_ADDR,
                    (void *)&ackData,
                    APP_ACK_DATA_LENGTH,
                    &app_sam_a5d2_xultData.transferHandle 
                );

                if( app_sam_a5d2_xultData.transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
                {
                    app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
                }
                else
                {
                    app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_EEPROM_CHECK_INTERNAL_WRITE_STATUS;
                }
            }
            else if (app_sam_a5d2_xultData.transferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
            }
            break;
            
        case APP_SAM_A5D2_XULT_STATE_EEPROM_CHECK_INTERNAL_WRITE_STATUS:
            if (app_sam_a5d2_xultData.transferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_DATA_READ;
            }
            else if (app_sam_a5d2_xultData.transferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                app_sam_a5d2_xultData.transferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                /* Keep checking if EEPROM's internal write cycle is complete */
                DRV_I2C_WriteTransferAdd( 
                    app_sam_a5d2_xultData.drvI2CHandle,
                    APP_AT24MAC_DEVICE_ADDR,
                    (void *)&ackData,
                    APP_ACK_DATA_LENGTH,
                    &app_sam_a5d2_xultData.transferHandle 
                );

                if( app_sam_a5d2_xultData.transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
                {
                    app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
                }                
            }                        
            break;
                
        case APP_SAM_A5D2_XULT_STATE_DATA_READ:
        
            app_sam_a5d2_xultData.transferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
            
            /* Add a request to read data from EEPROM. */
            DRV_I2C_ReadTransferAdd(  
                app_sam_a5d2_xultData.drvI2CHandle,
                APP_AT24MAC_DEVICE_ADDR,
                (void *)&testRxData[0],
                APP_READ_DATA_LENGTH,
                &app_sam_a5d2_xultData.transferHandle
            );
            
            if( app_sam_a5d2_xultData.transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
            }
            else
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_WAIT_READ_COMPLETE;
            }
            break;
                
        case APP_SAM_A5D2_XULT_STATE_WAIT_READ_COMPLETE:
            if (app_sam_a5d2_xultData.transferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_DATA_VERIFY;
            }
            else if (app_sam_a5d2_xultData.transferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
            }            
            break;
            
        case APP_SAM_A5D2_XULT_STATE_DATA_VERIFY:
            
            /* Compare data written and data read */
            if (memcmp(&testTxData[1], &testRxData[0], APP_READ_DATA_LENGTH) == 0)
            {                                       
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_SUCCESS;
            }            
            else
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
            }
            
            break;
                        
        case APP_SAM_A5D2_XULT_STATE_SUCCESS:
        
            /* On success make LED 0 on*/
            LED_ON();
            app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_IDLE;
            break;
                
        case APP_SAM_A5D2_XULT_STATE_ERROR:
        
            app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_IDLE;
            break;
            
        default:        
            break;        
    }
}


/*******************************************************************************
 End of File
 */
