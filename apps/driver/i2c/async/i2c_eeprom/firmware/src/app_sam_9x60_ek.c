/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_sam_9x60_ek.c

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
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "app_sam_9x60_ek.h"

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
    This structure should be initialized by the APP_SAM_9X60_EK_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_SAM_9X60_EK_DATA app_sam_9x60_ekData;

// *****************************************************************************
/* Application Test Write Data array

  Summary:
    Holds the application test write data.

  Description:
    This array holds the application's test write data.

  Remarks:
    None.
*/

static const uint8_t testWriteData[APP_SAM_9X60_EK_WRITE_DATA_LENGTH] = 
{
    APP_SAM_9X60_EK_AT24CM_MEMORY_ADDR,APP_SAM_9X60_EK_AT24CM_MEMORY_ADDR, 
    'A', 'T', 'S', 'A', 'M', ' ', 'S', 'E', 'R', 'C', 'O','M', ' ', 'D', 'E', 'M', 'O',
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

static uint8_t  testReadData[APP_SAM_9X60_EK_READ_DATA_LENGTH] = {0};

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

APP_EEPROM_WRITE_CYCLE writeCycle = APP_SAM_9X60_EK_EEPROM_WRITE_CYCLE_INIT;

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
    
    if( transferHandle == app_sam_9x60_ekData.hReadyTransfer &&
        event == DRV_I2C_TRANSFER_EVENT_COMPLETE )
    {
        /* EEPROM is ready for write/read operation */
        eepromReady = true;
    }
    
    if( transferHandle == app_sam_9x60_ekData.hWriteTransfer &&
        event == DRV_I2C_TRANSFER_EVENT_COMPLETE )
    {
        /* EEPROM write operation is complete */
        writeComplete = true;
    }
        
    if( transferHandle == app_sam_9x60_ekData.hAckTransfer )
    {
        if( event == DRV_I2C_TRANSFER_EVENT_COMPLETE )
        {
            /* EEPROM write cycle complete */
            writeCycle = APP_SAM_9X60_EK_EEPROM_WRITE_CYCLE_COMPLETE;
        }
        else
        {
            /* EEPROM write cycle in progress */
            writeCycle = APP_SAM_9X60_EK_EEPROM_WRITE_CYCLE_IN_PROGRESS;
        }
    }
    
    if( transferHandle == app_sam_9x60_ekData.hReadTransfer &&
        event == DRV_I2C_TRANSFER_EVENT_COMPLETE )
    {
        /* EEPROM read is complete */
        readComplete = true;
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
    void APP_SAM_9X60_EK_Initialize ( void )

  Remarks:
    See prototype in app_sam_9x60_ek.h.
 */

void APP_SAM_9X60_EK_Initialize ( void )
{
    /* Initialize the app_sam_9x60_ekData structure. */
    app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_INIT;
    app_sam_9x60_ekData.drvI2CHandle   = DRV_HANDLE_INVALID;
    app_sam_9x60_ekData.hReadyTransfer = DRV_I2C_TRANSFER_HANDLE_INVALID;
    app_sam_9x60_ekData.hWriteTransfer = DRV_I2C_TRANSFER_HANDLE_INVALID;
    app_sam_9x60_ekData.hAckTransfer   = DRV_I2C_TRANSFER_HANDLE_INVALID;
    app_sam_9x60_ekData.hReadTransfer  = DRV_I2C_TRANSFER_HANDLE_INVALID;
    
    /* Initialize the success LED */
    LED_OFF();
}


/******************************************************************************
  Function:
    void APP_SAM_9X60_EK_Tasks ( void )

  Remarks:
    See prototype in app_sam_9x60_ek.h.
 */

void APP_SAM_9X60_EK_Tasks ( void )
{
   uint32_t i;

    /* Check the application's current state. */
    switch ( app_sam_9x60_ekData.state )
    {
        /* Application's initial state. */
        case APP_SAM_9X60_EK_STATE_INIT:
        {
            /* Open the I2C Driver */
            app_sam_9x60_ekData.drvI2CHandle = DRV_I2C_Open( DRV_I2C_INDEX_0, 
                                                 DRV_IO_INTENT_READWRITE );
            if( DRV_HANDLE_INVALID == app_sam_9x60_ekData.drvI2CHandle )
            {
                return;
            }
            
            /* Register the I2C Driver event Handler */
            DRV_I2C_TransferEventHandlerSet( app_sam_9x60_ekData.drvI2CHandle, 
                                             APP_I2CEventHandler, 
                                             (uintptr_t)NULL );
            
            app_sam_9x60_ekData.state  = APP_SAM_9X60_EK_STATE_IS_EEPROM_READY;
            
            break;
        }
        
        case APP_SAM_9X60_EK_STATE_IS_EEPROM_READY:
        {
            /* Add a Write Transfer request to verify whether EEPROM is ready */
            DRV_I2C_WriteTransferAdd( app_sam_9x60_ekData.drvI2CHandle,
                                      APP_SAM_9X60_EK_AT24CM_DEVICE_ADDR,
                                      (void *)&ackData,
                                      APP_SAM_9X60_EK_ACK_DATA_LENGTH,
                                      &app_sam_9x60_ekData.hReadyTransfer );
            
            if( app_sam_9x60_ekData.hReadyTransfer == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_ERROR;
            }
            else
            {
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_UPDATE;
            }
            
            break;
        }

        case APP_SAM_9X60_EK_STATE_DATA_WRITE:
        {
            /* Add a request to write the application data */
            DRV_I2C_WriteTransferAdd( app_sam_9x60_ekData.drvI2CHandle,
                                      APP_SAM_9X60_EK_AT24CM_DEVICE_ADDR,
                                      (void *)&testWriteData[0],
                                      APP_SAM_9X60_EK_WRITE_DATA_LENGTH,
                                      &app_sam_9x60_ekData.hWriteTransfer );
            
            if( app_sam_9x60_ekData.hWriteTransfer == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_ERROR;
            }
            else
            {
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_UPDATE;
            }
            
            break;
        }
        
        case APP_SAM_9X60_EK_STATE_ACK_CYCLE:
        {
            /* Add a request to verify if EEPROM write cycle is complete */
            DRV_I2C_WriteTransferAdd( app_sam_9x60_ekData.drvI2CHandle,
                                      APP_SAM_9X60_EK_AT24CM_DEVICE_ADDR,
                                      (void *)&ackData,
                                      APP_SAM_9X60_EK_ACK_DATA_LENGTH,
                                      &app_sam_9x60_ekData.hAckTransfer );
            
            if( app_sam_9x60_ekData.hAckTransfer == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_ERROR;
            }
            else
            {
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_UPDATE;
            }
            
            break;
        }
        
        case APP_SAM_9X60_EK_STATE_DATA_READ:
        {
            /* Add a request to read data from EEPROM. */
          
            DRV_I2C_WriteReadTransferAdd( app_sam_9x60_ekData.drvI2CHandle,
                                            APP_SAM_9X60_EK_AT24CM_DEVICE_ADDR,
                                           (void *)&testWriteData[0],
                                           2,
                                           (void *)&testReadData[0],
                                           APP_SAM_9X60_EK_READ_DATA_LENGTH,
                                           &app_sam_9x60_ekData.hReadTransfer);
            
            if( app_sam_9x60_ekData.hReadTransfer == DRV_I2C_TRANSFER_HANDLE_INVALID )
            {
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_ERROR;
            }
            else
            {
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_UPDATE;
            }

            break;
        }
        
        case APP_SAM_9X60_EK_STATE_DATA_VERIFY:
        {
            /* compare data written and data read */
            for( i = 0; i < APP_SAM_9X60_EK_READ_DATA_LENGTH; i++ )
            {
                if( testWriteData[i + 2] != testReadData[i] )
                {
                    break;
                }
            }
            
            /* Success if data written is equal to data read */
            if( i == APP_SAM_9X60_EK_READ_DATA_LENGTH )
            {
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_SUCCESS;
            }
            /* Data written is not same as data read, Error!!!*/
            else
            {
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_ERROR;
            }
            
            break;
        }
        
        case APP_SAM_9X60_EK_STATE_UPDATE:
        {
            if( eepromReady )
            {
                /* EEPROM is ready for write Operation */
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_DATA_WRITE;
                eepromReady = false;
            }
            else if( writeComplete )
            {
                /* Write is complete, verify if EEPROM is busy*/
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_ACK_CYCLE;
                writeComplete = false;
            }
            else if( writeCycle != APP_SAM_9X60_EK_EEPROM_WRITE_CYCLE_INIT)
            {
                if( writeCycle == APP_SAM_9X60_EK_EEPROM_WRITE_CYCLE_IN_PROGRESS)
                {
                    /* write cycle is in progress, repeat dummy write */
                    app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_ACK_CYCLE;
                }
                else
                {
                    /* write cycle is complete, now read the written data */
                    app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_DATA_READ;
                }
                
                writeCycle = APP_SAM_9X60_EK_EEPROM_WRITE_CYCLE_INIT;
            }
            else if( readComplete )
            {
                /* read is complete, compare data written and data read */
                app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_DATA_VERIFY;
            }
            
            break;
        }
        
        case APP_SAM_9X60_EK_STATE_SUCCESS:
        {
            /* On success make LED 0 on*/
            LED_ON();
            app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_DONE;
            break;
        }
        
        case APP_SAM_9X60_EK_STATE_ERROR:
        {
            app_sam_9x60_ekData.state = APP_SAM_9X60_EK_STATE_DONE;
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
