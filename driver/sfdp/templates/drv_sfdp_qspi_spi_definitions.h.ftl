/*******************************************************************************
  SFDP Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sfdp_definitions.h

  Summary:
    SFDP Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the SFDP
    driver's system interface when using SPI PLIB or SPI Driver.
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

#ifndef DRV_SFDP_DEFINITIONS_H
#define DRV_SFDP_DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include "system/system.h"
#include "driver/driver.h"
#include "system/ports/sys_ports.h"
<#if DRV_SFDP_TX_RX_DMA == true>
    <#lt>#include "system/dma/sys_dma.h"
</#if>

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
<#if DRV_SFDP_INTERFACE_TYPE != "SPI_DRV">
/* SFDP SPI PLIB API Set

  Summary:
  The set of PLIB APIs used by the SFDP driver when using SPI interface.

  Description:
  The API set holds the function names available at the PLIB level for the
  corresponding functionality. The SFDP driver may call these functions to make
  use of the features provided by the SPI PLIB for SFDP discovery and flash
  operations.

  Remarks:
    This interface is used when DRV_SFDP_PROTOCOL is set to "SPI" and the
    interface type is SPI_PLIB (not SPI_DRV).
*/

/* Callback function pointer type.
 *
 * Summary:
 *   Defines the callback function type for SPI transfer complete events.
 *
 * Description:
 *   This function pointer type is used for SPI PLIB callback registration.
 *   The callback is invoked when SPI transfers complete.
 *
 * Parameters:
 *   context - Context pointer passed during callback registration
 */
typedef void (* DRV_SFDP_PLIB_CALLBACK)( uintptr_t context );

/* Write-Read function pointer type.
 *
 * Summary:
 *   Performs a combined write then read SPI operation.
 *
 * Description:
 *   This function pointer is used for SPI write-read operations where
 *   data is first transmitted and then received. Commonly used for
 *   command-data sequences.
 *
 * Parameters:
 *   pTransmitData - Pointer to transmit buffer
 *   txSize - Number of bytes to transmit
 *   pReceiveData - Pointer to receive buffer
 *   rxSize - Number of bytes to receive
 *
 * Returns:
 *   true if operation initiated successfully, false otherwise
 */
typedef bool (* DRV_SFDP_PLIB_WRITE_READ)(void* pTransmitData, size_t txSize, void *pReceiveData, size_t rxSize);

/* Write function pointer type.
 *
 * Summary:
 *   Performs an SPI write operation.
 *
 * Description:
 *   This function pointer is used for SPI write-only operations.
 *
 * Parameters:
 *   pTransmitData - Pointer to transmit buffer
 *   txSize - Number of bytes to transmit
 *
 * Returns:
 *   true if operation initiated successfully, false otherwise
 */
typedef bool (* DRV_SFDP_PLIB_WRITE)(void* pTransmitData, size_t txSize);

/* Read function pointer type.
 *
 * Summary:
 *   Performs an SPI read operation.
 *
 * Description:
 *   This function pointer is used for SPI read-only operations.
 *
 * Parameters:
 *   pReceiveData - Pointer to receive buffer
 *   rxSize - Number of bytes to receive
 *
 * Returns:
 *   true if operation initiated successfully, false otherwise
 */
typedef bool (* DRV_SFDP_PLIB_READ)(void* pReceiveData, size_t rxSize);

/* Is Busy function pointer type.
 *
 * Summary:
 *   Checks if SPI peripheral is busy.
 *
 * Description:
 *   This function pointer is used to poll the SPI peripheral busy status.
 *
 * Returns:
 *   true if SPI is busy, false if idle
 */
typedef bool (* DRV_SFDP_PLIB_IS_BUSY)(void);

/* Is Transmitter Busy function pointer type.
 *
 * Summary:
 *   Checks if SPI transmitter is busy.
 *
 * Description:
 *   This function pointer is used to poll the SPI transmitter busy status.
 *
 * Returns:
 *   true if transmitter is busy, false if idle
 */
typedef bool (*DRV_SFDP_PLIB_IS_TX_BUSY) (void);

/* Callback Register function pointer type.
 *
 * Summary:
 *   Registers a callback function for SPI events.
 *
 * Description:
 *   This function pointer is used to register event handler callbacks
 *   for SPI transfer complete events.
 *
 * Parameters:
 *   callback - Callback function pointer
 *   context - Context to pass to callback
 */
typedef void (* DRV_SFDP_PLIB_CALLBACK_REGISTER)(DRV_SFDP_PLIB_CALLBACK callback, uintptr_t context);

/* SFDP Driver PLIB Interface
 *
 * Summary:
 *   Structure containing SPI PLIB function pointers.
 *
 * Description:
 *   This structure defines the PLIB interface for SPI-based SFDP driver
 *   operation. It contains function pointers for all SPI operations.
 */
typedef struct
{
    /* SFDP PLIB writeRead API */
    DRV_SFDP_PLIB_WRITE_READ                writeRead;

    /* SFDP PLIB write API */
    DRV_SFDP_PLIB_WRITE                     write_t;

    /* SFDP PLIB read API */
    DRV_SFDP_PLIB_READ                      read_t;

    /* SFDP PLIB Transfer status API */
    DRV_SFDP_PLIB_IS_BUSY                   isBusy;

    /* SFDP PLIB Transmitter busy status API */
    DRV_SFDP_PLIB_IS_TX_BUSY                isTransmitterBusy;

    /* SFDP PLIB callback register API */
    DRV_SFDP_PLIB_CALLBACK_REGISTER         callbackRegister;

} DRV_SFDP_PLIB_INTERFACE;

/* SFDP Driver Initialization Data
 *
 * Summary:
 *   Data structure containing SFDP driver initialization parameters for SPI PLIB.
 *
 * Description:
 *   This structure is used to pass initialization parameters to the SFDP
 *   driver when using SPI PLIB interface. It contains the PLIB interface
 *   pointer, chip select pin, and optional DMA configuration.
 */
typedef struct
{
    /* Identifies the PLIB API set to be used by the driver to access the
     * peripheral. */
    const DRV_SFDP_PLIB_INTERFACE *sfdpPlib;

    /* Chip Select pin to be used */
    SYS_PORT_PIN chipSelectPin;

<#if DRV_SFDP_TX_RX_DMA == true>
    /* Transmit DMA Channel */
    SYS_DMA_CHANNEL                 txDMAChannel;

    /* Receive DMA Channel */
    SYS_DMA_CHANNEL                 rxDMAChannel;

    /* This is the SPI transmit register address. Used for DMA operation. */
    void*                           txAddress;

    /* This is the SPI receive register address. Used for DMA operation. */
    void*                           rxAddress;
</#if>
} DRV_SFDP_INIT;

<#else>
/* SFDP Driver Initialization Data (SPI Driver Mode)
 *
 * Summary:
 *   Data structure for SFDP driver initialization when using SPI Driver.
 *
 * Description:
 *   This structure is used to pass initialization parameters to the SFDP
 *   driver when using SPI Driver interface instead of SPI PLIB. It contains
 *   the chip select pin and SPI driver index.
 */
typedef struct
{
    /* Chip Select pin to be used */
    SYS_PORT_PIN    chipSelectPin;

    /* SPI Driver instance index */
    uint32_t        spiDrvIndex;

} DRV_SFDP_INIT;
</#if>


//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END


#endif // #ifndef DRV_SFDP_DEFINITIONS_H
