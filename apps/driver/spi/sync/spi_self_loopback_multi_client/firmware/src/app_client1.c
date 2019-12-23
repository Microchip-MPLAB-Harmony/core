/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_client1.c

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

#include "app_client1.h"
#include "app_monitor.h"
#include <string.h>
// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

/* Make sure the size of the loop-back string is smaller than the buffer size
 * defined in app_client1.h file. */

#define APP_CLIENT1_STR                 "APP-Client1-Loopback-String"

#define APP_CLIENT1_NUM_BYTES           sizeof(APP_CLIENT1_STR)

#define APP_CLIENT1_SPI_CLK_SPEED       1000000

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

static APP_CLIENT1_DATA app_client1Data;

/* The DMA buffers must be aligned to 32 byte boundary and the size must be
 * a multiple of 32 bytes (cache line size) on MCUs that have data cache and use 
 * DMA */
static uint8_t CACHE_ALIGN app_client1_rdBuffer[APP_CLIENT1_TX_RX_BUFFER_SIZE];

static uint8_t CACHE_ALIGN app_client1_wrBuffer[APP_CLIENT1_TX_RX_BUFFER_SIZE];

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

bool APP_CLIENT1_GetStatus(void)
{
    return app_client1Data.status;
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************

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
    app_client1Data.status = APP_ERROR;
}


/******************************************************************************
  Function:
    void APP_CLIENT1_Tasks ( void )

  Remarks:
    See prototype in app_client1.h.
 */

void APP_CLIENT1_Tasks ( void )
{
    switch (app_client1Data.state)
    {
        case APP_CLIENT1_STATE_INIT:

            app_client1Data.spi_setup.baudRateInHz = APP_CLIENT1_SPI_CLK_SPEED;
            app_client1Data.spi_setup.clockPhase = DRV_SPI_CLOCK_PHASE_VALID_TRAILING_EDGE;
            app_client1Data.spi_setup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_HIGH;
            app_client1Data.spi_setup.dataBits = DRV_SPI_DATA_BITS_8;
            app_client1Data.spi_setup.chipSelect = (SYS_PORT_PIN)APP_CLIENT1_CS_PIN;
            app_client1Data.spi_setup.csPolarity = DRV_SPI_CS_POLARITY_ACTIVE_LOW;

            app_client1Data.spi_handle = DRV_SPI_Open( DRV_SPI_INDEX_0, DRV_IO_INTENT_READWRITE );

            if (app_client1Data.spi_handle != DRV_HANDLE_INVALID)
            {
                DRV_SPI_TransferSetup(app_client1Data.spi_handle, &app_client1Data.spi_setup);
                app_client1Data.state = APP_CLIENT1_STATE_SELF_LOOPBACK;
            }
            else
            {
                app_client1Data.state = APP_CLIENT1_STATE_ERROR;
            }
            break;

        case APP_CLIENT1_STATE_SELF_LOOPBACK:

            // Clear the read buffer
            memset(app_client1_rdBuffer, 0, APP_CLIENT1_TX_RX_BUFFER_SIZE);

            // Copy the loop-back data into the write buffer
            memcpy(app_client1_wrBuffer, APP_CLIENT1_STR, APP_CLIENT1_NUM_BYTES);

            if (DRV_SPI_WriteReadTransfer(app_client1Data.spi_handle, app_client1_wrBuffer, APP_CLIENT1_NUM_BYTES, app_client1_rdBuffer, APP_CLIENT1_NUM_BYTES) == false)
            {
                app_client1Data.state = APP_CLIENT1_STATE_ERROR;
            }
            else
            {
                /* Compare the received data */
                if (memcmp(app_client1_rdBuffer, app_client1_wrBuffer, APP_CLIENT1_NUM_BYTES) != 0)
                {
                    /* Received data does not match the transmitted data */
                    app_client1Data.state = APP_CLIENT1_STATE_ERROR;
                }
                else
                {
                    app_client1Data.status = APP_SUCCESS;
                }
            }
            break;

        case APP_CLIENT1_STATE_ERROR:

            DRV_SPI_Close(app_client1Data.spi_handle);

            app_client1Data.status = APP_ERROR;

            app_client1Data.state = APP_CLIENT1_STATE_IDLE;

        case APP_CLIENT1_STATE_IDLE:
        default:
            break;
    }
}


/*******************************************************************************
 End of File
 */