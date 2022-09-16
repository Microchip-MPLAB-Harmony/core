/*******************************************************************************
  SD Card SPI Driver Interface Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdspi_driver_interface.h

  Summary:
    SD Card - (SPI) Driver Interface implementation

  Description:
    This interface file segregates the SD Card SPI protocol from the underlying
    hardware layer implementation.
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

#ifndef DRV_SDSPI_DRIVER_INTERFACE_H
#define DRV_SDSPI_DRIVER_INTERFACE_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "drv_sdspi_local.h"
#include "driver/spi/drv_spi.h"

// *****************************************************************************
// *****************************************************************************
// Section: Data Type Definitions
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* SDSPI SPI Driver Event Handler

  Summary:
    Event handler registered by the SD card driver with the SPI driver

  Description:
    This event handler is called by the SPI driver when a request is complete

  Remarks:
*/

void DRV_SDSPI_SPIDriverEventHandler(
    DRV_SPI_TRANSFER_EVENT event,
    DRV_SPI_TRANSFER_HANDLE transferHandle,
    uintptr_t context
);

// *****************************************************************************
/* SD Card SPI Write

  Summary:
    Submits a write request to the SPI Driver

  Description:

  Remarks:
    This is a non-blocking implementation.
*/

bool DRV_SDSPI_SPIWrite(
    DRV_SDSPI_OBJ* dObj,
    void* pWriteBuffer,
    uint32_t nBytes
);

// *****************************************************************************
/* SD Card SPI Write With CS Disabled

  Summary:
    Submits a write request to the SPI Driver with CS disabled

  Description:

  Remarks:
    This is a non-blocking implementation.
*/

bool DRV_SDSPI_SPIWriteWithChipSelectDisabled(
    DRV_SDSPI_OBJ* dObj,
    void* pWriteBuffer,
    uint32_t nBytes
);

// *****************************************************************************
/* SD Card SPI read

  Summary:
    Submits a read request to the SPI Driver.

  Description:

  Remarks:
    This is a non-blocking implementation.
*/

bool DRV_SDSPI_SPIRead(
    DRV_SDSPI_OBJ* dObj,
    void* pReadBuffer,
    uint32_t nBytes
);

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
bool DRV_SDSPI_SPIExclusiveAccess(DRV_SDSPI_OBJ* const dObj, bool isExclusive);

// *****************************************************************************
/* Card Insertion/Removal Polling Timer

  Summary:
    Registers an event handler with the Timer System Service and starts the
    timer.

  Description:
    The registered event handler is called when the time period elapses.

  Remarks:

*/

bool DRV_SDSPI_CardDetectPollingTimerStart(
    DRV_SDSPI_OBJ* const dObj,
    uint32_t period
);

// *****************************************************************************
/* SD Card Timer Start

  Summary:
    Starts the SD card timer.

  Description:
    The registered event handler is called when the time period elapses.

  Remarks:

*/

bool DRV_SDSPI_TimerStart(
    DRV_SDSPI_OBJ* const dObj,
    uint32_t period
);

// *****************************************************************************
/* SD Card Command-Response Timer Start

  Summary:
    Starts the command-response timer.

  Description:
    The registered event handler is called when the time period elapses.

  Remarks:

*/
bool DRV_SDSPI_CmdResponseTimerStart(
    DRV_SDSPI_OBJ* const dObj,
    uint32_t period
);

// *****************************************************************************
/* SD Card Timer Stop

  Summary:
    Stops the SD card timer.

  Description:
    None.

  Remarks:

*/

bool DRV_SDSPI_TimerStop( DRV_SDSPI_OBJ* const dObj );

// *****************************************************************************
/* SD Card Command-Response Timer Stop

  Summary:
    Stops the command-response timer.

  Description:
    None.

  Remarks:

*/
bool DRV_SDSPI_CmdResponseTimerStop( DRV_SDSPI_OBJ* const dObj );

// *****************************************************************************
/* SD Card SPI Speed Setup

  Summary:
    Configures the SPI clock frequency by calling the SPI Driver.

  Description:
    This function is used by the SD Card driver to switch between the initial
    low frequency and to higher clock frequency once the SD card is initialized.

  Remarks:

*/

bool DRV_SDSPI_SPISpeedSetup(
    DRV_SDSPI_OBJ* const dObj,
    uint32_t clockFrequency,
    SYS_PORT_PIN chipSelectPin
);

#endif //#ifndef DRV_SDSPI_DRIVER_INTERFACE_H