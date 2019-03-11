/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app.c

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

// DOM-IGNORE-BEGIN
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
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "app.h"
#include <string.h>

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_DATA appData;

static const uint8_t testTxData[APP_WRITE_DATA_LENGTH] = 
{
	APP_AT24MAC_MEMORY_ADDR, 
    'A', 'T', 'S', 'A', 'M', ' ', 'T', 'W', 'I', 'H', 'S', ' ', 'D', 'e', 'm', 'o',
};

static uint8_t testRxData[APP_READ_DATA_LENGTH] = {0};

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
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Initialize ( void )
{
    /* Initialize the appData structure. */
    appData.state = APP_STATE_INIT;
    appData.drvI2CHandle   = DRV_HANDLE_INVALID;
    appData.transferHandle = DRV_I2C_TRANSFER_HANDLE_INVALID;   
    appData.transferStatus = APP_TRANSFER_STATUS_ERROR;
    
    /* Initialize the LED to failure state */
    LED_OFF();
}

/******************************************************************************
  Function:
    void APP_Tasks ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Tasks ( void )
{        
    /* Check the application's current state. */
    switch ( appData.state )
    {
        /* Application's initial state. */
        case APP_STATE_INIT:
            
            /* Open the I2C Driver */
            appData.drvI2CHandle = DRV_I2C_Open( DRV_I2C_INDEX_0, DRV_IO_INTENT_READWRITE );
            if(appData.drvI2CHandle == DRV_HANDLE_INVALID)
            {
                appData.state = APP_STATE_ERROR;
            }    
            else
            {
                /* Register the I2C Driver event Handler */
                DRV_I2C_TransferEventHandlerSet( 
                    appData.drvI2CHandle, 
                    APP_I2CEventHandler, 
                    (uintptr_t)&appData.transferStatus 
                );            
                appData.state  = APP_STATE_IS_EEPROM_READY;
            }                        
            break;
                
        case APP_STATE_IS_EEPROM_READY:
        
            appData.transferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
            /* Add a dummy write transfer request to verify whether EEPROM is ready */
            DRV_I2C_WriteTransferAdd( 
                appData.drvI2CHandle,
                APP_AT24MAC_DEVICE_ADDR,
                (void *)&appData.dummyData,
                1,
                &appData.transferHandle 
            );
            
            if( appData.transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                appData.state = APP_STATE_ERROR;
            }
            else
            {
                appData.state = APP_STATE_DATA_WRITE;
            }            
            break;        

        case APP_STATE_DATA_WRITE:
            if (appData.transferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                appData.transferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                
                /* Add a request to write the application data */
                DRV_I2C_WriteTransferAdd(
                    appData.drvI2CHandle,
                    APP_AT24MAC_DEVICE_ADDR,
                    (void *)&testTxData[0],
                    APP_WRITE_DATA_LENGTH,
                    &appData.transferHandle 
                );
                
                if( appData.transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
                {
                    appData.state = APP_STATE_ERROR;
                }
                else
                {
                    appData.state = APP_STATE_WAIT_WRITE_COMPLETE;
                }
            }
            else if (appData.transferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                // EEPROM is not ready. Go to error state.
                appData.state = APP_STATE_ERROR;
            }            
            break;
        
        case APP_STATE_WAIT_WRITE_COMPLETE:
            if (appData.transferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                appData.transferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                
                /* Add a dummy write request to check if EEPROM's internal write cycle is complete */
                DRV_I2C_WriteTransferAdd( 
                    appData.drvI2CHandle,
                    APP_AT24MAC_DEVICE_ADDR,
                    (void *)&appData.dummyData,
                    1,
                    &appData.transferHandle 
                );

                if( appData.transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
                {
                    appData.state = APP_STATE_ERROR;
                }
                else
                {
                    appData.state = APP_STATE_EEPROM_CHECK_INTERNAL_WRITE_STATUS;
                }
            }
            else if (appData.transferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                appData.state = APP_STATE_ERROR;
            }
            break;
            
        case APP_STATE_EEPROM_CHECK_INTERNAL_WRITE_STATUS:
            if (appData.transferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                appData.state = APP_STATE_DATA_READ;
            }
            else if (appData.transferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                appData.transferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                
                /* Keep checking if EEPROM's internal write cycle is complete */
                DRV_I2C_WriteTransferAdd( 
                    appData.drvI2CHandle,
                    APP_AT24MAC_DEVICE_ADDR,
                    (void *)&appData.dummyData,
                    1,
                    &appData.transferHandle 
                );

                if( appData.transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
                {
                    appData.state = APP_STATE_ERROR;
                }                
            }                        
            break;
                
        case APP_STATE_DATA_READ:
        
            appData.transferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
            
            /* Add a request to read data from EEPROM. */
            DRV_I2C_WriteReadTransferAdd(  
                appData.drvI2CHandle,
                APP_AT24MAC_DEVICE_ADDR,
                (void *)&testTxData[0],
                1,
                (void *)&testRxData[0],
                APP_READ_DATA_LENGTH,
                &appData.transferHandle
            );
            
            if( appData.transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                appData.state = APP_STATE_ERROR;
            }
            else
            {
                appData.state = APP_STATE_WAIT_READ_COMPLETE;
            }
            break;
                
        case APP_STATE_WAIT_READ_COMPLETE:
            if (appData.transferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                appData.state = APP_STATE_DATA_VERIFY;
            }
            else if (appData.transferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                appData.state = APP_STATE_ERROR;
            }            
            break;
            
        case APP_STATE_DATA_VERIFY:
            
            /* Compare data written and data read */
            if (memcmp(&testTxData[1], &testRxData[0], APP_READ_DATA_LENGTH) == 0)
            {                                       
                appData.state = APP_STATE_SUCCESS;
            }            
            else
            {
                appData.state = APP_STATE_ERROR;
            }
            
            break;
                        
        case APP_STATE_SUCCESS:
        
            /* On success turn LED on*/
            LED_ON();
            appData.state = APP_STATE_IDLE;
            break;
                
        case APP_STATE_ERROR:
            
            LED_OFF();
            appData.state = APP_STATE_IDLE;
            break;
            
        case APP_STATE_IDLE:
        default:        
            break;        
    }
}

/*******************************************************************************
 End of File
 */