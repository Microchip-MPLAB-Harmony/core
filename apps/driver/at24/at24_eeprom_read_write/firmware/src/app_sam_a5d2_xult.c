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
//DOM-IGNORE-BEGIN
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
//DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "app_sam_a5d2_xult.h"
#include "definitions.h"
#include <string.h>         //included for memcpy(..)

// *****************************************************************************
// AT24 - Connect EEPROM 3 click to SAMA5D2 Xplained Ultra board.
// *****************************************************************************

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************
#define AT24_EEPROM_MEM_ADDR             0x0000
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
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

/* TODO:  Add any necessary callback functions.
*/
void APP_SAM_A5D2_XULT_EEPROM_EventHandler(DRV_AT24_TRANSFER_STATUS event, uintptr_t context)
{
    switch(event)
    {
        case DRV_AT24_TRANSFER_STATUS_COMPLETED:
            app_sam_a5d2_xultData.isTransferDone = true;
            break;
        case DRV_AT24_TRANSFER_STATUS_ERROR:
        default:
            app_sam_a5d2_xultData.isTransferDone = false;
            break;
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

    app_sam_a5d2_xultData.isTransferDone = false;

    /* TODO: Initialize your application's state machine and other
     * parameters.
     */
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
        
            app_sam_a5d2_xultData.drvHandle = DRV_AT24_Open(DRV_AT24_INDEX, 0);
            
            if (app_sam_a5d2_xultData.drvHandle != DRV_HANDLE_INVALID)
            {                                
                DRV_AT24_EventHandlerSet(app_sam_a5d2_xultData.drvHandle, APP_SAM_A5D2_XULT_EEPROM_EventHandler, 0);
                
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_WRITE;
            }
            else
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
            }            
            break;
            
        case APP_SAM_A5D2_XULT_STATE_WRITE:
            app_sam_a5d2_xultData.writeBuffer[0] = (AT24_EEPROM_MEM_ADDR >> 8) & 0xff;
            app_sam_a5d2_xultData.writeBuffer[1] = AT24_EEPROM_MEM_ADDR & 0xff;
            /* Fill up the write buffer */
            for (uint32_t i = 2; i < BUFFER_SIZE; i++)
            {
                app_sam_a5d2_xultData.writeBuffer[i] = i;
            }                       
            
            if (DRV_AT24_Write(app_sam_a5d2_xultData.drvHandle, 
                    app_sam_a5d2_xultData.writeBuffer, 
                    BUFFER_SIZE, 
                    AT24_EEPROM_MEM_ADDR) == false)
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;            
            }
            else
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_WAIT_WRITE_COMPLETE;            
            }                        
            
            break;
            
        case APP_SAM_A5D2_XULT_STATE_WAIT_WRITE_COMPLETE:                        
            
            if (app_sam_a5d2_xultData.isTransferDone == true)            
            {
                app_sam_a5d2_xultData.isTransferDone = false;
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_READ;
            }            
            break;
            
        case APP_SAM_A5D2_XULT_STATE_READ:
                        
            if (DRV_AT24_Read(app_sam_a5d2_xultData.drvHandle, 
                    app_sam_a5d2_xultData.readBuffer, 
                    BUFFER_SIZE, 
                    AT24_EEPROM_MEM_ADDR) == false)
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
            }
            else
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_WAIT_READ_COMPLETE;
            }                        
            
            break;
            
        case APP_SAM_A5D2_XULT_STATE_WAIT_READ_COMPLETE:
            
            if (app_sam_a5d2_xultData.isTransferDone == true)
            {
                app_sam_a5d2_xultData.isTransferDone = false;
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_VERIFY;
            }            
            break;
            
        case APP_SAM_A5D2_XULT_STATE_VERIFY:
                                    
            if (memcmp(app_sam_a5d2_xultData.writeBuffer, app_sam_a5d2_xultData.readBuffer, BUFFER_SIZE ) == 0)
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_IDLE;
            }
            else
            {
                app_sam_a5d2_xultData.state = APP_SAM_A5D2_XULT_STATE_ERROR;
            }            
            break;
            
        case APP_SAM_A5D2_XULT_STATE_IDLE:
            /* Turn on the LED to indicate success */
            LED_On();
            break;
            
        case APP_SAM_A5D2_XULT_STATE_ERROR:
        default:
            break;
    }
}


/*******************************************************************************
 End of File
 */
