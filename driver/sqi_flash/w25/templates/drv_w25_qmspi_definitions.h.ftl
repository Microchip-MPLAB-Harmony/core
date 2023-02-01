/*******************************************************************************
  W25 Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_w25_definitions.h

  Summary:
    W25 Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the W25
	driver's system interface.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2023 Microchip Technology Inc. and its subsidiaries.
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

#ifndef DRV_W25_DEFINITIONS_H
#define DRV_W25_DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include "system/system.h"
#include "driver/driver.h"
#include "peripheral/qmspi/plib_${DRV_W25_PLIB?lower_case}.h"

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

/* QMSPI PLIB API Set

  Summary:
  The set of PLIB APIs used by the W25 driver.

  Description:
  The API set holds the function names available at the PLIb level for the
  corresponding functionality. Driver may call these functions to make use of
  the features provided by the PLIB.

  Remarks:
    None.
*/

/* Pointer to write command to QMSPI slave device. */
typedef bool (*DRV_W25_PLIB_WRITE)(QMSPI_XFER_T *qmspiXfer, void* pTransmitData, size_t txSize);

/* Pointer to read particular register of QMSPI slave device. */
typedef bool (*DRV_W25_PLIB_READ)(QMSPI_XFER_T *qmspiXfer, void* pReceiveData, size_t rxSize);

/* Pointer to read from the specified address of the flash device. */
typedef uint32_t (*DRV_W25_PLIB_DMA_TRANSFER_READ)(QMSPI_DESCRIPTOR_XFER_T *qmspiDescXfer, void* pTransmitData, size_t txSize);

/* Pointer to write to the specified address of the flash device. */
typedef uint32_t (*DRV_W25_PLIB_DMA_TRANSFER_WRITE)(QMSPI_DESCRIPTOR_XFER_T *qmspiDescXfer, void* pReceiveData, size_t rxSize);

typedef struct
{
    /* Pointer to write command/register to QMSPI slave device. */
    DRV_W25_PLIB_WRITE Write;

    /* Pointer to read register of QMSPI slave device. */
    DRV_W25_PLIB_READ Read;

    /* Pointer to read from the specified address of the flash device. */
    DRV_W25_PLIB_DMA_TRANSFER_READ DMATransferRead;

    /* Pointer to write to the specified address of the flash device. */
    DRV_W25_PLIB_DMA_TRANSFER_WRITE DMATransferWrite;

} DRV_W25_PLIB_INTERFACE;

/* W25 Driver Initialization Data Declaration */

typedef struct
{
    /* Identifies the PLIB API set to be used by the driver to access the
     * peripheral. */
    const DRV_W25_PLIB_INTERFACE *w25Plib;
} DRV_W25_INIT;


//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END


#endif // #ifndef DRV_W25_DEFINITIONS_H
