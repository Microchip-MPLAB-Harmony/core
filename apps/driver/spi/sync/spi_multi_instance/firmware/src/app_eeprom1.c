/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_eeprom1.c

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

#include "app_eeprom1.h"
#include "app_monitor.h"
#include <string.h>

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

#define EEPROM1_CMD_WRITE                       0x02
#define EEPROM1_CMD_READ                        0x03
#define EEPROM1_CMD_RDSR                        0x05
#define EEPROM1_CMD_WREN                        0x06
#define EEPROM1_STATUS_BUSY_BIT                 0x01

#define APP_EEPROM1_SPI_CLK_SPEED               1000000

#define APP_EEPROM1_READ_WRITE_RATE_MS          1000

/* For demonstration 16 bytes are written to EEPROM in each write cycle */
#define EEPROM1_NUM_BYTES_RD_WR                 16

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_EEPROM1_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

static APP_EEPROM1_DATA app_eeprom1Data;

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

bool APP_EEPROM1_Task_GetStatus(void)
{
    return app_eeprom1Data.status;
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
    void APP_EEPROM1_Initialize ( void )

  Remarks:
    See prototype in app_eeprom1.h.
 */

void APP_EEPROM1_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    app_eeprom1Data.state = APP_EEPROM1_STATE_INIT;
    app_eeprom1Data.eeprom_addr = 0;
    app_eeprom1Data.status = APP_ERROR;
}


/******************************************************************************
  Function:
    void APP_EEPROM1_Tasks ( void )

  Remarks:
    Writes 16 bytes (1 page) of data to EEPROM every 1 second.
 */

void APP_EEPROM1_Tasks ( void )
{
    uint32_t i;

    switch (app_eeprom1Data.state)
    {
        case APP_EEPROM1_STATE_INIT:

            app_eeprom1Data.spiSetup.baudRateInHz = APP_EEPROM1_SPI_CLK_SPEED;
            app_eeprom1Data.spiSetup.clockPhase = DRV_SPI_CLOCK_PHASE_VALID_LEADING_EDGE;
            app_eeprom1Data.spiSetup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
            app_eeprom1Data.spiSetup.dataBits = DRV_SPI_DATA_BITS_8;
            app_eeprom1Data.spiSetup.chipSelect = APP_EEPROM1_CS_PIN;
            app_eeprom1Data.spiSetup.csPolarity = DRV_SPI_CS_POLARITY_ACTIVE_LOW;

            app_eeprom1Data.spiHandle = DRV_SPI_Open( DRV_SPI_INDEX_0, 0 );

            if (app_eeprom1Data.spiHandle != DRV_HANDLE_INVALID)
            {
                DRV_SPI_TransferSetup(app_eeprom1Data.spiHandle, &app_eeprom1Data.spiSetup);
                app_eeprom1Data.state = APP_EEPROM1_STATE_WRITE_ENABLE;
            }
            else
            {
                app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
            }
            break;

        case APP_EEPROM1_STATE_WRITE_ENABLE:

            /* Enable Writes to EEPROM */
            app_eeprom1Data.wrBuffer[0] = EEPROM1_CMD_WREN;

            if (DRV_SPI_WriteTransfer(app_eeprom1Data.spiHandle, app_eeprom1Data.wrBuffer, 1) == true)
            {
                app_eeprom1Data.state = APP_EEPROM1_STATE_WRITE;
            }
            else
            {
                app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
            }
            break;

        case APP_EEPROM1_STATE_WRITE:

            /* Write data to EEPROM */
            app_eeprom1Data.wrBuffer[0] = EEPROM1_CMD_WRITE;
            app_eeprom1Data.wrBuffer[1] = (uint8_t)(app_eeprom1Data.eeprom_addr >> 16);
            app_eeprom1Data.wrBuffer[2] = (uint8_t)(app_eeprom1Data.eeprom_addr >> 8);
            app_eeprom1Data.wrBuffer[3] = (uint8_t)(app_eeprom1Data.eeprom_addr);

            /* Copy the data to be written to the EEPROM */
            for (i = 0; i < EEPROM1_NUM_BYTES_RD_WR; i++)
            {
                app_eeprom1Data.wrBuffer[4+i] = i;
            }

            if (DRV_SPI_WriteTransfer(app_eeprom1Data.spiHandle, app_eeprom1Data.wrBuffer, (4+EEPROM1_NUM_BYTES_RD_WR)) == true)
            {
                app_eeprom1Data.state = APP_EEPROM1_STATE_INTERNAL_WRITE_WAIT;
            }
            else
            {
                app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
            }
            break;

        case APP_EEPROM1_STATE_INTERNAL_WRITE_WAIT:

            /* Poll for the write status to ensure that the EEPROM's internal write is complete */
            app_eeprom1Data.wrBuffer[0] = EEPROM1_CMD_RDSR;

            if (DRV_SPI_WriteReadTransfer(app_eeprom1Data.spiHandle, app_eeprom1Data.wrBuffer, 1, app_eeprom1Data.rdBuffer, (1+1)) == true)
            {
                /* Check the busy bit (bit 0) of the status register */
                if ((app_eeprom1Data.rdBuffer[1] & EEPROM1_STATUS_BUSY_BIT) == 0x00)
                {
                    app_eeprom1Data.state = APP_EEPROM1_STATE_READ;
                }
                else
                {
                    /* EEPROM is still busy. Keep checking the status. */
                }
            }
            else
            {
                app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
            }
            break;

        case APP_EEPROM1_STATE_READ:

            /* Read data from EEPROM */
            app_eeprom1Data.wrBuffer[0] = EEPROM1_CMD_READ;
            app_eeprom1Data.wrBuffer[1] = (uint8_t)(app_eeprom1Data.eeprom_addr >> 16);
            app_eeprom1Data.wrBuffer[2] = (uint8_t)(app_eeprom1Data.eeprom_addr >> 8);
            app_eeprom1Data.wrBuffer[3] = (uint8_t)(app_eeprom1Data.eeprom_addr);

            /* Clear the read buffer */
            memset(app_eeprom1Data.rdBuffer, 0, sizeof(app_eeprom1Data.rdBuffer));

            if (DRV_SPI_WriteReadTransfer(app_eeprom1Data.spiHandle, app_eeprom1Data.wrBuffer, 4, app_eeprom1Data.rdBuffer, (4+EEPROM1_NUM_BYTES_RD_WR)) == true)
            {
                /* Verify the read data */
                if (memcmp(&app_eeprom1Data.rdBuffer[4], &app_eeprom1Data.wrBuffer[4], EEPROM1_NUM_BYTES_RD_WR) == 0)
                {
                    app_eeprom1Data.state = APP_EEPROM1_STATE_SUCCESS;
                }
                else
                {
                    app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
                }
            }
            else
            {
                app_eeprom1Data.state = APP_EEPROM1_STATE_ERROR;
            }
            break;

        case APP_EEPROM1_STATE_SUCCESS:

            DRV_SPI_Close(app_eeprom1Data.spiHandle);
            app_eeprom1Data.status = APP_SUCCESS;
            app_eeprom1Data.state = APP_EEPROM1_STATE_IDLE;
            break;

        case APP_EEPROM1_STATE_ERROR:

            DRV_SPI_Close(app_eeprom1Data.spiHandle);
            app_eeprom1Data.status = APP_ERROR;
            app_eeprom1Data.state = APP_EEPROM1_STATE_IDLE;
            break;

        case APP_EEPROM1_STATE_IDLE:
        default:
            break;
    }
}


/*******************************************************************************
 End of File
 */
