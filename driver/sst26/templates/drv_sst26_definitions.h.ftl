/*******************************************************************************
  SST26 Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sst26_definitions.h

  Summary:
    SST26 Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the SST26 
	driver's system interface. 
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
Copyright (c) 2017 released Microchip Technology Inc.  All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED AS IS  WITHOUT  WARRANTY  OF  ANY  KIND,
EITHER EXPRESS  OR  IMPLIED,  INCLUDING  WITHOUT  LIMITATION,  ANY  WARRANTY  OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A  PARTICULAR  PURPOSE.
IN NO EVENT SHALL MICROCHIP OR  ITS  LICENSORS  BE  LIABLE  OR  OBLIGATED  UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION,  BREACH  OF  WARRANTY,  OR
OTHER LEGAL  EQUITABLE  THEORY  ANY  DIRECT  OR  INDIRECT  DAMAGES  OR  EXPENSES
INCLUDING BUT NOT LIMITED TO ANY  INCIDENTAL,  SPECIAL,  INDIRECT,  PUNITIVE  OR
CONSEQUENTIAL DAMAGES, LOST  PROFITS  OR  LOST  DATA,  COST  OF  PROCUREMENT  OF
SUBSTITUTE  GOODS,  TECHNOLOGY,  SERVICES,  OR  ANY  CLAIMS  BY  THIRD   PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE  THEREOF),  OR  OTHER  SIMILAR  COSTS.
*******************************************************************************/
//DOM-IGNORE-END

#ifndef DRV_SST26_DEFINITIONS_H
#define DRV_SST26_DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include "system/system.h"
#include "driver/driver.h"
#include "peripheral/qspi/plib_${DRV_SST26_PLIB?lower_case}.h"

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

/* QSPI PLIB API Set

  Summary:
  The set of PLIB APIs used by the SST26 driver.

  Description:
  The API set holds the function names available at the PLIb level for the 
  corresponding functionality. Driver may call these functions to make use of
  the features provided by the PLIB.

  Remarks:
    None.
*/

typedef struct
{
    /* Pointer to write command to QSPI slave device. */
    bool (*CommandWrite)( qspi_command_xfer_t *qspi_command_xfer, uint32_t address );

    /* Pointer to read particular register of QSPI slave device. */
    bool (*RegisterRead)( qspi_register_xfer_t *qspi_register_xfer, uint32_t *rx_data, uint8_t rx_data_length );

    /* Pointer to write to particular register of QSPI slave device. */
    bool (*RegisterWrite)( qspi_register_xfer_t *qspi_register_xfer, uint32_t *tx_data, uint8_t tx_data_length );

    /* Pointer to read from the specified address of the flash device. */
    bool (*MemoryRead)( qspi_memory_xfer_t *qspi_memory_xfer, uint32_t *rx_data, uint32_t rx_data_length, uint32_t address );

    /* Pointer to write to the specified address of the flash device. */
    bool (*MemoryWrite)( qspi_memory_xfer_t *qspi_memory_xfer, uint32_t *tx_data, uint32_t tx_data_length, uint32_t address );

} SST26_PLIB_API;

/* SST26 Driver Initialization Data Declaration */

typedef struct
{
    /* Identifies the PLIB API set to be used by the driver to access the 
     * peripheral. */
    const SST26_PLIB_API *sst26Plib;
} DRV_SST26_INIT;


//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END


#endif // #ifndef DRV_SST26_DEFINITIONS_H

