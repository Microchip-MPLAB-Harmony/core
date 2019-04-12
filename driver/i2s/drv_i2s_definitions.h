/*******************************************************************************
  SPI Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_i2s_definitions.h

  Summary:
    I2S Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the I2S
	driver's system interface.
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

#ifndef DRV_I2S_DEFINITIONS_H
#define DRV_I2S_DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <device.h>
#include "system/int/sys_int.h"
#include "system/dma/sys_dma.h"
#include "stddef.h"
#include "system/system_module.h"
#include "driver/driver.h"
#include "driver/driver_common.h"
#include "system/int/sys_int.h"

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Data Types
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* I2S Driver Setup Data

  Summary:
    Defines the data required to setup the I2S transfer

  Description:
    This data type defines the data required to setup the I2S transfer. The
    data is passed to the DRV_I2S_TransferSetup API to setup the I2S peripheral
    settings dynamically.

  Remarks:
    None.
*/

typedef enum
{
    DRV_I2S_ERROR_NONE = 0,
    DRV_I2S_ERROR_OVERRUN = 1

}DRV_I2S_ERROR;

typedef enum
{
    DRV_I2S_DMA_WIDTH_8_BIT = 0,
    DRV_I2S_DMA_WIDTH_16_BIT = 1

}DRV_I2S_DMA_WIDTH;

typedef    void (* DRV_BAUDSET)(const uint32_t);

typedef    uint32_t (* DRV_I2S_LRCLK_GET)();

// *****************************************************************************
/* I2S Driver PLIB Interface Data

  Summary:
    Defines the data required to initialize the I2S driver PLIB Interface.

  Description:
    This data type defines the data required to initialize the I2S driver
    PLIB Interface.

  Remarks:
    None.
*/

typedef struct
{
	/* I2S PLIB baud rate set function */
	DRV_BAUDSET	setBaud;
    DRV_I2S_LRCLK_GET   I2S_LRCLK_Get;

} DRV_I2S_PLIB_INTERFACE;

// *****************************************************************************
/* I2S Driver Initialization Data

  Summary:
    Defines the data required to initialize the I2S driver

  Description:
    This data type defines the data required to initialize or the I2S driver.

  Remarks:
    None.
*/

typedef struct
{
    /* Identifies the PLIB API set to be used by the driver to access the
     * peripheral. */
    DRV_I2S_PLIB_INTERFACE      *i2sPlib;

    /* Interrupt source ID for the I2S interrupt. */
    INT_SOURCE                  interruptI2S;

	/* Memory Pool for Client Objects */
	uintptr_t                   clientObjPool;

    /* Number of clients */
    size_t                      numClients;

    /* Queue for Transfer Objects */
    uintptr_t                   transferObjPool;

    /* Driver Queue Size */
    size_t                      queueSize;

    /* I2S transmit DMA channel. */
    SYS_DMA_CHANNEL                 dmaChannelTransmit;

    /* I2S receive DMA channel. */
    SYS_DMA_CHANNEL                 dmaChannelReceive;

    /* I2S transmit register address used for DMA operation. */
    void                        *i2sTransmitAddress;

    /* I2S receive register address used for DMA operation. */
    void                        *i2sReceiveAddress;

    /* Interrupt source ID for DMA interrupt. */
    INT_SOURCE                  interruptDMA;

    /* DMA data length from I2S or SSC PLIB */
    uint8_t                     dmaDataLength;

} DRV_I2S_INIT;


//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

#endif // #ifndef DRV_I2S_DEFINITIONS_H

/*******************************************************************************
 End of File
*/
