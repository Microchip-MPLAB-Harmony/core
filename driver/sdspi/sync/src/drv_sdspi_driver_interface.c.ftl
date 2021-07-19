/******************************************************************************
  SD Card (SPI) Driver Interface Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdspi_driver_interface.c

  Summary:
    SD Card (SPI) Driver - SPI Driver Interface implementation

  Description:
    This interface file segregates the SD Card SPI protocol from the underlying
    hardware layer implementation for SPI and Timer System service
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
// Section: Include Files
// *****************************************************************************
// *****************************************************************************

#include "driver/spi/drv_spi.h"
#include "drv_sdspi_driver_interface.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************


// *****************************************************************************
// *****************************************************************************
// Section: DRV_SDSPI Driver Local Functions
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Timer Event Handler

  Summary:
    Event handler registered by the SD card driver with the Timer System Service

  Description:
    This event handler is called by the Timer System Service when the requested
    time period has elapsed.

  Remarks:

*/

static void DRV_SDSPI_TimerCallback( uintptr_t context )
{
    bool *flag = (bool *)context;
    *flag = true;
}


// *****************************************************************************
/* SDSPI Write Block

  Summary:
    Transfers a block (512) bytes of data over SPI using the SPI Driver.

  Description:

  Remarks:
    The function blocks on a semaphore which is released from the interrupt
    handler (in the callback registered by SPI Driver) once the transfer is complete.
*/

bool _DRV_SDSPI_SPIBlockWrite(
    DRV_SDSPI_OBJ* dObj,
    void* pWriteBuffer
)
{
    bool isSuccess = false;

    if (_DRV_SDSPI_SPIWrite(dObj, pWriteBuffer, _DRV_SDSPI_MEDIA_BLOCK_SIZE) == true)
    {
        isSuccess = true;
    }

    return isSuccess;
}

// *****************************************************************************
/* SD Card SPI Write

  Summary:
    Writes the requested number of bytes to the SD Card

  Description:

  Remarks:
    The function blocks on a semaphore which is released from the interrupt
    handler (in the callback registered by SPI Driver) once the transfer is complete.
*/

bool _DRV_SDSPI_SPIWrite(
    DRV_SDSPI_OBJ* dObj,
    void* pWriteBuffer,
    uint32_t nBytes
)
{
    bool isSuccess = false;

    if (DRV_SPI_WriteTransfer(dObj->spiDrvHandle, pWriteBuffer,  nBytes) == true)
    {
        isSuccess = true;
    }

    return isSuccess;
}

// *****************************************************************************
/* SDSPI Read Block

  Summary:
    Transfers a block (512) bytes of data over SPI using the SPI Driver.

  Description:

  Remarks:
    The function blocks on a semaphore which is released from the interrupt
    handler (in the callback registered by SPI Driver) once the transfer is complete.
*/

bool _DRV_SDSPI_SPIBlockRead(
    DRV_SDSPI_OBJ* dObj,
    void* pReadBuffer
)
{
    bool isSuccess = false;

    if (_DRV_SDSPI_SPIRead(dObj, pReadBuffer, _DRV_SDSPI_MEDIA_BLOCK_SIZE) == true)
    {
        isSuccess = true;
    }

    return isSuccess;
}

// *****************************************************************************
/* SD Card SPI read

  Summary:
    Reads the requested number of bytes from the SD Card

  Description:

  Remarks:
    The function blocks on a semaphore which is released from the interrupt
    handler (in the callback registered by SPI Driver) once the transfer is complete.
*/

bool _DRV_SDSPI_SPIRead(
    DRV_SDSPI_OBJ* dObj,
    void* pReadBuffer,
    uint32_t nBytes
)
{
    bool isSuccess = false;

    if (DRV_SPI_ReadTransfer(dObj->spiDrvHandle, pReadBuffer,  nBytes) == true)
    {
        isSuccess = true;
    }

    return isSuccess;
}

// *****************************************************************************
/* SD Card SPI Speed Setup

  Summary:
    Configures the SPI clock frequency.

  Description:
    This function is used by the SD Card driver to switch between the initial
    low frequency and to higher clock frequency once the SD card is initialized.

  Remarks:

*/

bool _DRV_SDSPI_SPISpeedSetup(
    DRV_SDSPI_OBJ* const dObj,
    uint32_t clockFrequency,
    SYS_PORT_PIN chipSelectPin
)
{
    bool isSuccess = false;

    DRV_SPI_TRANSFER_SETUP sdspiSetup;

    /* SD Card reads the data on the rising edge of SCK, which means SPI Mode 0
     * and 3 => CPOL = 0, CPHA = 0 and CPOL = 1, CPHA = 1 are supported */

    sdspiSetup.baudRateInHz = clockFrequency;
    sdspiSetup.clockPhase = DRV_SPI_CLOCK_PHASE_VALID_LEADING_EDGE;
    sdspiSetup.clockPolarity = DRV_SPI_CLOCK_POLARITY_IDLE_LOW;
    sdspiSetup.dataBits = DRV_SPI_DATA_BITS_8;
    sdspiSetup.chipSelect = chipSelectPin;
    sdspiSetup.csPolarity = DRV_SPI_CS_POLARITY_ACTIVE_LOW;

    isSuccess = DRV_SPI_TransferSetup(dObj->spiDrvHandle, &sdspiSetup);

    return isSuccess;
}


bool _DRV_SDSPI_SPIWriteWithChipSelectDisabled(
    DRV_SDSPI_OBJ* dObj,
    void* pWriteBuffer,
    uint32_t nBytes
)
{
    bool isSuccess = false;

    /* Disable Chip Select */
    _DRV_SDSPI_SPISpeedSetup(dObj, _DRV_SDSPI_SPI_INITIAL_SPEED, SYS_PORT_PIN_NONE);

    if (_DRV_SDSPI_SPIWrite(dObj, pWriteBuffer, nBytes) == true)
    {
        isSuccess = true;
    }

    /* Re-enable Chip Select */
    _DRV_SDSPI_SPISpeedSetup(dObj, _DRV_SDSPI_SPI_INITIAL_SPEED, dObj->chipSelectPin);

    return isSuccess;
}


// *****************************************************************************
/* SD Card SPI driver exclusive access lock

  Summary:
    Locks the SPI driver for exclusive use by the SDSPI driver

  Description:
    SDSPI driver calls this API to lock the SPI driver during the entire command-response
    sequence.

  Remarks:
    None
*/

bool _DRV_SDSPI_SPIExclusiveAccess(DRV_SDSPI_OBJ* const dObj, bool isExclusive)
{
    return DRV_SPI_Lock(dObj->spiDrvHandle, isExclusive);
}

// *****************************************************************************
/* Card detection polling timer Start

  Summary:
    Registers an event handler with the Timer System Service and starts
    a timer to detect presence of card.

  Description:
    The registered event handler is called when the time period elapses.

  Remarks:

*/
bool _DRV_SDSPI_CardDetectPollingTimerStart(
    DRV_SDSPI_OBJ* const dObj,
    uint32_t period
)
{
    bool isSuccess = false;
    dObj->cardPollingTimerExpired = false;

    dObj->cardPollingTmrHandle = SYS_TIME_CallbackRegisterMS(DRV_SDSPI_TimerCallback,
             (uintptr_t)&dObj->cardPollingTimerExpired, period, SYS_TIME_SINGLE);

    if (dObj->cardPollingTmrHandle != SYS_TIME_HANDLE_INVALID)
    {
        isSuccess = true;
    }

    return isSuccess;
}

// *****************************************************************************
/* Command Response Timer Start

  Summary:
    Registers an event handler with the Timer System Service and starts the
    command-response timer.

  Description:
    The registered event handler is called when the time period elapses.

  Remarks:

*/
bool _DRV_SDSPI_CmdResponseTimerStart(
    DRV_SDSPI_OBJ* const dObj,
    uint32_t period
)
{
    bool isSuccess = false;
    dObj->cmdRespTmrExpired = false;

    dObj->cmdRespTmrHandle = SYS_TIME_CallbackRegisterMS(DRV_SDSPI_TimerCallback,
             (uintptr_t)&dObj->cmdRespTmrExpired, period, SYS_TIME_SINGLE);

    if (dObj->cmdRespTmrHandle != SYS_TIME_HANDLE_INVALID)
    {
        isSuccess = true;
    }

    return isSuccess;
}

// *****************************************************************************
/* Command Response Timer Stop

  Summary:
    Stops the command-response timer.

  Description:

  Remarks:

*/

bool _DRV_SDSPI_CmdResponseTimerStop( DRV_SDSPI_OBJ* const dObj )
{
    bool isSuccess = false;

    if (dObj->cmdRespTmrHandle != SYS_TIME_HANDLE_INVALID)
    {
        SYS_TIME_TimerDestroy(dObj->cmdRespTmrHandle);
        isSuccess = true;
    }

    return isSuccess;
}

// *****************************************************************************
/* SD Card Timer Start

  Summary:
    Starts the SD card timer.

  Description:
    The registered event handler is called when the time period elapses.

  Remarks:

*/

bool _DRV_SDSPI_TimerStart(
    DRV_SDSPI_OBJ* const dObj,
    uint32_t period
)
{
    bool isSuccess = false;
    dObj->timerExpired = false;

    dObj->timerHandle = SYS_TIME_CallbackRegisterMS(DRV_SDSPI_TimerCallback,
             (uintptr_t)&dObj->timerExpired, period, SYS_TIME_SINGLE);

    if (dObj->timerHandle != SYS_TIME_HANDLE_INVALID)
    {
        isSuccess = true;
    }

    return isSuccess;
}

// *****************************************************************************
/* SD Card Timer Stop

  Summary:
    Stops the SD card timer.

  Description:
    The registered event handler is called when the time period elapses.

  Remarks:

*/

bool _DRV_SDSPI_TimerStop( DRV_SDSPI_OBJ* const dObj )
{
    bool isSuccess = false;

    if (dObj->timerHandle != SYS_TIME_HANDLE_INVALID)
    {
        SYS_TIME_TimerDestroy(dObj->timerHandle);
        isSuccess = true;
    }

    return isSuccess;
}

