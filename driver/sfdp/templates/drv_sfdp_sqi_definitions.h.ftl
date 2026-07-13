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
    driver's system interface when using SQI PLIB.
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
#include "peripheral/sqi/plib_${DRV_SFDP_PLIB?lower_case}.h"

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

/* SQI PLIB API Set

  Summary:
  The set of PLIB APIs used by the SFDP driver when using SQI interface.

  Description:
  The API set holds the function names available at the PLIB level for the
  corresponding functionality. The SFDP driver may call these functions to make
  use of the features provided by the SQI PLIB for DMA-based descriptor chain
  operations and SFDP discovery.

  Remarks:
    This interface is used when DRV_SFDP_PROTOCOL is set to "SQI" and the
    connected PLIB is an SQI PLIB (sqi_04044).
*/

/* Pointer to perform DMA Transfer with SQI PLIB.
 *
 * Summary:
 *   Initiates a DMA transfer using the provided descriptor chain.
 *
 * Description:
 *   This function pointer is used to initiate DMA-based SQI operations using
 *   a linked list of buffer descriptors (sqi_dma_desc_t). The SFDP driver
 *   builds descriptor chains for SFDP read operations (command 0x5A) and
 *   normal flash operations.
 *
 * Parameters:
 *   sqiDmaDesc - Pointer to the first descriptor in the chain
 */
typedef void (*DRV_SFDP_PLIB_DMA_TRANSFER)( sqi_dma_desc_t *sqiDmaDesc );

/* Pointer to Register event handler with SQI PLIB.
 *
 * Summary:
 *   Registers a callback function for SQI transfer complete events.
 *
 * Description:
 *   This function pointer is used to register an event handler that will be
 *   called when SQI DMA transfers complete. The SFDP driver uses this for
 *   asynchronous operation notifications.
 *
 * Parameters:
 *   event_handler - Callback function pointer (SQI_EVENT_HANDLER type)
 *   context - Context pointer passed back to the callback
 */
typedef void (*DRV_SFDP_PLIB_REGISTER_CALLBACK)( SQI_EVENT_HANDLER event_handler, uintptr_t context );

/* SFDP Driver PLIB Interface
 *
 * Summary:
 *   Structure containing SQI PLIB function pointers.
 *
 * Description:
 *   This structure defines the PLIB interface for SQI-based SFDP driver
 *   operation. It contains function pointers for DMA transfer and callback
 *   registration.
 */
typedef struct
{
    /* DMA transfer function */
    DRV_SFDP_PLIB_DMA_TRANSFER DMATransfer;

    /* Register callback function */
    DRV_SFDP_PLIB_REGISTER_CALLBACK RegisterCallback;

} DRV_SFDP_PLIB_INTERFACE;

/* SFDP Driver Initialization Data
 *
 * Summary:
 *   Data structure containing SFDP driver initialization parameters for SQI.
 *
 * Description:
 *   This structure is used to pass initialization parameters to the SFDP
 *   driver when using SQI interface. It contains a pointer to the SQI PLIB
 *   interface.
 */
typedef struct
{
    /* Identifies the PLIB API set to be used by the driver to access the
     * peripheral. */
    const DRV_SFDP_PLIB_INTERFACE *sfdpPlib;

} DRV_SFDP_INIT;

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END


#endif // #ifndef DRV_SFDP_DEFINITIONS_H
