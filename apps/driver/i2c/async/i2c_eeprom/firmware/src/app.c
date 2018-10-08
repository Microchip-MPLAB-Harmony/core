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
    This structure should be initialized by the APP_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_DATA appData;

// *****************************************************************************
/* Application Test Write Data array

  Summary:
    Holds the application test write data.

  Description:
    This array holds the application's test write data.

  Remarks:
    None.
*/

static const uint8_t testWriteData[APP_WRITE_DATA_LENGTH] = 
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

static uint8_t  testReadData[APP_READ_DATA_LENGTH] = {0};

// *****************************************************************************
/* Application EEPROM Ready Flag.

  Summary:
    Flag to indicate whether EEPROM is ready.

  Description:
    This boolean flag indicates whether EEPROM is ready.

  Remarks:
    None.
*/

bool eepromReady = false;

// *****************************************************************************
/* Application Write Complete Flag.

  Summary:
    Flag to indicate whether EEPROM Write is done.

  Description:
    This boolean flag indicates whether EEPROM Write is done.

  Remarks:
    None.
*/

bool writeComplete = false;

// *****************************************************************************
/* Application EEPROM Write Cycle State.

  Summary:
    Enumeration to indicates EEPROM Write Cycle State.

  Description:
    This Enumeration indicates EEPROM Write Cycle State.

  Remarks:
    None.
*/

APP_EEPROM_WRITE_CYCLE writeCycle = APP_EEPROM_WRITE_CYCLE_INIT;

// *****************************************************************************
/* Application EEPROM Read Complete Flag.

  Summary:
    Flag to indicate whether EEPROM Read is complete.

  Description:
    This boolean flag indicates whether EEPROM read is complete.

  Remarks:
    None.
*/

bool readComplete = false;

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

void APP_I2CEventHandler ( DRV_I2C_TRANSFER_EVENT  event,
                           DRV_I2C_TRANSFER_HANDLE transferHandle, 
                           uintptr_t               context )
{
    /* Checks for valid buffer handle */
    if( transferHandle == DRV_I2C_TRANSFER_HANDLE_INVALID )
    {
        return;
    }
    
    if( transferHandle == appData.hReadyTransfer &&
        event == DRV_I2C_TRANSFER_EVENT_COMPLETE )
    {
        /* EEPROM is ready for write/read operation */
        eepromReady = true;
    }
    
    if( transferHandle == appData.hWriteTransfer &&
        event == DRV_I2C_TRANSFER_EVENT_COMPLETE )
    {
        /* EEPROM write operation is complete */
        writeComplete = true;
    }
        
    if( transferHandle == appData.hAckTransfer )
    {
        if( event == DRV_I2C_TRANSFER_EVENT_COMPLETE )
        {
            /* EEPROM write cycle complete */
            writeCycle = APP_EEPROM_WRITE_CYCLE_COMPLETE;
        }
        else
        {
            /* EEPROM write cycle in progress */
            writeCycle = APP_EEPROM_WRITE_CYCLE_IN_PROGRESS;
        }
    }
    
    if( transferHandle == appData.hReadTransfer &&
        event == DRV_I2C_TRANSFER_EVENT_COMPLETE )
    {
        /* EEPROM read is complete */
        readComplete = true;
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
    appData.hReadyTransfer = DRV_I2C_TRANSFER_HANDLE_INVALID;
    appData.hWriteTransfer = DRV_I2C_TRANSFER_HANDLE_INVALID;
    appData.hAckTransfer   = DRV_I2C_TRANSFER_HANDLE_INVALID;
    appData.hReadTransfer  = DRV_I2C_TRANSFER_HANDLE_INVALID;
    
    /* Initialize the success LED */
    LED1_Off();
}

/******************************************************************************
  Function:
    void APP_Tasks ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Tasks ( void )
{
    uint32_t i;

    /* Check the application's current state. */
    switch ( appData.state )
    {
        /* Application's initial state. */
        case APP_STATE_INIT:
        {
            /* Open the I2C Driver */
            appData.drvI2CHandle = DRV_I2C_Open( DRV_I2C_INDEX_0, 
                                                 DRV_IO_INTENT_READWRITE );
            if( DRV_HANDLE_INVALID == appData.drvI2CHandle )
            {
                return;
            }
            
            /* Register the I2C Driver event Handler */
            DRV_I2C_TransferEventHandlerSet( appData.drvI2CHandle, 
                                             APP_I2CEventHandler, 
                                             (uintptr_t)NULL );
            
            appData.state  = APP_STATE_IS_EEPROM_READY;
            
            break;
        }
        
        case APP_STATE_IS_EEPROM_READY:
        {
            /* Add a Write Transfer request to verify whether EEPROM is ready */
            DRV_I2C_WriteTransferAdd( appData.drvI2CHandle,
                                      APP_AT24MAC_DEVICE_ADDR,
                                      (void *)&ackData,
                                      APP_ACK_DATA_LENGTH,
                                      &appData.hReadyTransfer );
            
            if( appData.hReadyTransfer == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                appData.state = APP_STATE_ERROR;
            }
            else
            {
                appData.state = APP_STATE_UPDATE;
            }
            
            break;
        }

        case APP_STATE_DATA_WRITE:
        {
            /* Add a request to write the application data */
            DRV_I2C_WriteTransferAdd( appData.drvI2CHandle,
                                      APP_AT24MAC_DEVICE_ADDR,
                                      (void *)&testWriteData[0],
                                      APP_WRITE_DATA_LENGTH,
                                      &appData.hWriteTransfer );
            
            if( appData.hWriteTransfer == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                appData.state = APP_STATE_ERROR;
            }
            else
            {
                appData.state = APP_STATE_UPDATE;
            }
            
            break;
        }
        
        case APP_STATE_ACK_CYCLE:
        {
            /* Add a request to verify if EEPROM write cycle is complete */
            DRV_I2C_WriteTransferAdd( appData.drvI2CHandle,
                                      APP_AT24MAC_DEVICE_ADDR,
                                      (void *)&ackData,
                                      APP_ACK_DATA_LENGTH,
                                      &appData.hAckTransfer );
            
            if( appData.hAckTransfer == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                appData.state = APP_STATE_ERROR;
            }
            else
            {
                appData.state = APP_STATE_UPDATE;
            }
            
            break;
        }
        
        case APP_STATE_DATA_READ:
        {
            /* Add a request to read data from EEPROM. */
            DRV_I2C_ReadTransferAdd(  appData.drvI2CHandle,
                                      APP_AT24MAC_DEVICE_ADDR,
                                      (void *)&testReadData[0],
                                      APP_READ_DATA_LENGTH,
                                      &appData.hReadTransfer );
            
            if( appData.hReadTransfer == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                appData.state = APP_STATE_ERROR;
            }
            else
            {
                appData.state = APP_STATE_UPDATE;
            }

            break;
        }
        
        case APP_STATE_DATA_VERIFY:
        {
            /* compare data written and data read */
            for( i = 0; i < APP_READ_DATA_LENGTH; i++ )
            {
                if( testWriteData[i + 1] != testReadData[i] )
                {
                    break;
                }
            }
            
            /* Success if data written is equal to data read */
            if( i == APP_READ_DATA_LENGTH )
            {
                appData.state = APP_STATE_SUCCESS;
            }
            /* Data written is not same as data read, Error!!!*/
            else
            {
                appData.state = APP_STATE_ERROR;
            }
            
            break;
        }
        
        case APP_STATE_UPDATE:
        {
            if( eepromReady )
            {
                /* EEPROM is ready for write Operation */
                appData.state = APP_STATE_DATA_WRITE;
                eepromReady = false;
            }
            else if( writeComplete )
            {
                /* Write is complete, verify if EEPROM is busy*/
                appData.state = APP_STATE_ACK_CYCLE;
                writeComplete = false;
            }
            else if( writeCycle != APP_EEPROM_WRITE_CYCLE_INIT)
            {
                if( writeCycle == APP_EEPROM_WRITE_CYCLE_IN_PROGRESS)
                {
                    /* write cycle is in progress, repeat dummy write */
                    appData.state = APP_STATE_ACK_CYCLE;
                }
                else
                {
                    /* write cycle is complete, now read the written data */
                    appData.state = APP_STATE_DATA_READ;
                }
                
                writeCycle = APP_EEPROM_WRITE_CYCLE_INIT;
            }
            else if( readComplete )
            {
                /* read is complete, compare data written and data read */
                appData.state = APP_STATE_DATA_VERIFY;
            }
            
            break;
        }
        
        case APP_STATE_SUCCESS:
        {
            /* On success make LED 0 on*/
            LED1_On();
            appData.state = APP_STATE_DONE;
            break;
        }
        
        case APP_STATE_ERROR:
        {
            appData.state = APP_STATE_DONE;
            break;
        }

        default:
        {
            break;
        }
    }
}

/*******************************************************************************
 End of File
 */
