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
#include "user.h"
#include <string.h>

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************
// *****************************************************************************
#define APP_EEPROM_MEMORY_ADDR                  0x0000
/* Size of the string written to EEPROM must be less than or equal to the EEPROM page size */
#define APP_EEPROM_TEST_DATA                    "I2C EEPROM Demo"
#define APP_EEPROM_TEST_DATA_SIZE               (sizeof(APP_EEPROM_TEST_DATA)-1)
#define APP_EEPROM_RX_BUFFER_SIZE               APP_EEPROM_TEST_DATA_SIZE
#if APP_EEPROM_ADDR_LEN_BITS == 18 || APP_EEPROM_ADDR_LEN_BITS == 16
    /* For 18 bit address, A16 and A17 are part of the EEPROM slave address.
     * The A16 and A17 bits are set to 0 in this demonstration. */
    #define APP_EEPROM_NUM_ADDR_BYTES           2
#elif APP_EEPROM_ADDR_LEN_BITS == 8
    #define APP_EEPROM_NUM_ADDR_BYTES           1
#endif
#define APP_EEPROM_TX_BUFFER_SIZE        (APP_EEPROM_TEST_DATA_SIZE + APP_EEPROM_NUM_ADDR_BYTES)

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

static uint8_t testTxData[APP_EEPROM_TX_BUFFER_SIZE] = {0};
static uint8_t testRxData[APP_EEPROM_RX_BUFFER_SIZE] = {0};

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
#if APP_EEPROM_NUM_ADDR_BYTES == 2
    testTxData[0] = (APP_EEPROM_MEMORY_ADDR >> 8);
    testTxData[1] = APP_EEPROM_MEMORY_ADDR;
    memcpy(&testTxData[2], (const void*)APP_EEPROM_TEST_DATA, APP_EEPROM_TEST_DATA_SIZE);
#else
    testTxData[0] = APP_EEPROM_MEMORY_ADDR;
    memcpy(&testTxData[1], (const void*)APP_EEPROM_TEST_DATA, APP_EEPROM_TEST_DATA_SIZE);
#endif

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
                APP_EEPROM_SLAVE_ADDR,
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
                    APP_EEPROM_SLAVE_ADDR,
                    (void *)&testTxData[0],
                    APP_EEPROM_TX_BUFFER_SIZE,
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
                //EEPROM is not ready. Keep checking until it is ready to receive commands.
                //Some EEPROMs need stabilization time before they can start responding to commands.
                appData.state = APP_STATE_IS_EEPROM_READY;
            }
            break;

        case APP_STATE_WAIT_WRITE_COMPLETE:
            if (appData.transferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                appData.transferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;

                /* Add a dummy write request to check if EEPROM's internal write cycle is complete */
                DRV_I2C_WriteTransferAdd(
                    appData.drvI2CHandle,
                    APP_EEPROM_SLAVE_ADDR,
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
                    APP_EEPROM_SLAVE_ADDR,
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
                APP_EEPROM_SLAVE_ADDR,
                (void *)&testTxData[0],
                APP_EEPROM_NUM_ADDR_BYTES,
                (void *)&testRxData[0],
                APP_EEPROM_TEST_DATA_SIZE,
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
            if (memcmp(&testTxData[APP_EEPROM_NUM_ADDR_BYTES], &testRxData[0], APP_EEPROM_TEST_DATA_SIZE) == 0)
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