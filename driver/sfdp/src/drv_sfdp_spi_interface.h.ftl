/*******************************************************************************
  SFDP Driver SPI Interface Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sfdp_spi_interface.h

  Summary:
    SFDP Driver PLIB Interface implementation

  Description:
    This interface file segregates the SFDP protocol from the underlying
    hardware layer implementation for SPI mode.
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

#ifndef DRV_SFDP_SPI_INTERFACE_H
#define DRV_SFDP_SPI_INTERFACE_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "drv_sfdp_local.h"

<#if DRV_SFDP_INTERFACE_TYPE == "SPI_DRV">
#include "driver/spi/drv_spi.h"
<#else>
<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == false && DRV_SFDP_TX_RX_DMA == true && core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
#include "system/cache/sys_cache.h"
</#if>
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: Data Type Definitions
// *****************************************************************************
// *****************************************************************************

/* Event Handlers
 *
 * Summary:
 *   Callback functions for different SPI operation modes.
 *
 * Description:
 *   These callback functions handle events from the underlying SPI hardware
 *   layer, whether using SPI Driver, DMA, or plain PLIB mode.
 */

<#if DRV_SFDP_INTERFACE_TYPE == "SPI_DRV">
/* SPI Driver Event Handler
 *
 * Summary:
 *   Handles events from SPI Driver.
 *
 * Description:
 *   This function is called by the SPI Driver when transfer events occur.
 *   It updates the SFDP driver state based on the event.
 *
 * Parameters:
 *   event - SPI transfer event type
 *   transferHandle - Handle to the transfer
 *   context - Context pointer (points to DRV_SFDP_OBJECT)
 */
void DRV_SFDP_SPIDriverEventHandler(
    DRV_SPI_TRANSFER_EVENT event,
    DRV_SPI_TRANSFER_HANDLE transferHandle,
    uintptr_t context
);
<#else>
<#if DRV_SFDP_TX_RX_DMA == true>
/* TX DMA Callback Handler
 *
 * Summary:
 *   Handles DMA transmit completion events.
 *
 * Description:
 *   This function is called when DMA transmit operations complete.
 *
 * Parameters:
 *   event - DMA transfer event
 *   context - Context pointer (points to DRV_SFDP_OBJECT)
 */
void DRV_SFDP_TX_DMA_CallbackHandler(
    SYS_DMA_TRANSFER_EVENT event,
    uintptr_t context
);

/* RX DMA Callback Handler
 *
 * Summary:
 *   Handles DMA receive completion events.
 *
 * Description:
 *   This function is called when DMA receive operations complete.
 *
 * Parameters:
 *   event - DMA transfer event
 *   context - Context pointer (points to DRV_SFDP_OBJECT)
 */
void DRV_SFDP_RX_DMA_CallbackHandler(
    SYS_DMA_TRANSFER_EVENT event,
    uintptr_t context
);
<#else>
/* SPI PLIB Callback Handler
 *
 * Summary:
 *   Handles SPI PLIB transfer completion events.
 *
 * Description:
 *   This function is called by the SPI PLIB when transfer operations complete.
 *
 * Parameters:
 *   context - Context pointer (points to DRV_SFDP_OBJECT)
 */
void DRV_SFDP_SPIPlibCallbackHandler(uintptr_t context);
</#if>
</#if>

/* Interface Initialization
 *
 * Summary:
 *   Initializes the SPI interface layer.
 *
 * Description:
 *   This function initializes the SPI interface, sets up callbacks, and
 *   configures DMA if enabled. It abstracts the differences between
 *   SPI PLIB and SPI Driver modes.
 *
 * Parameters:
 *   dObj - Pointer to SFDP driver object
 *   sfdpInit - Pointer to initialization data
 */
void DRV_SFDP_InterfaceInit(DRV_SFDP_OBJECT* dObj, DRV_SFDP_INIT* sfdpInit);

/* SPI Write-Read Operation
 *
 * Summary:
 *   Performs an SPI write-read operation.
 *
 * Description:
 *   This function initiates an SPI write-read operation using either
 *   SPI PLIB or SPI Driver, with optional DMA support.
 *
 * Parameters:
 *   dObj - Pointer to SFDP driver object
 *   transferObj - Pointer to transfer object containing buffers and sizes
 *
 * Returns:
 *   true if operation initiated successfully, false otherwise
 */
bool DRV_SFDP_SPIWriteRead(
    DRV_SFDP_OBJECT* dObj,
    DRV_SFDP_TRANSFER_OBJ* transferObj
);

/* State Machine Handler
 *
 * Summary:
 *   Handles SFDP driver state machine transitions.
 *
 * Description:
 *   This function is called to process the SFDP driver state machine.
 *   It must be called periodically or from event handlers to advance
 *   the state machine through operations.
 */
void DRV_SFDP_Handler(void);

#endif //#ifndef DRV_SFDP_SPI_INTERFACE_H
