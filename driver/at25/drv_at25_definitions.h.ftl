/*******************************************************************************
  AT25 Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_at25_definitions.h

  Summary:
    AT25 Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the AT25
    driver's system interface.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
Copyright (c) 2018 released Microchip Technology Inc.  All rights reserved.

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

#ifndef DRV_AT25_DEFINITIONS_H
#define DRV_AT25_DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <device.h>
#include "system/ports/sys_ports.h"


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

typedef enum
{
    DRV_AT25_SPI_ERROR_NONE = 0,
    <#if .vars["${DRV_AT25_PLIB?lower_case}"].SPI_STATUS_OVERRUN_MASK?has_content>
    <#lt>    DRV_AT25_SPI_ERROR_OVERRUN = ${.vars["${DRV_AT25_PLIB?lower_case}"].SPI_STATUS_OVERRUN_MASK},
    </#if>

}DRV_AT25_SPI_ERROR;

typedef void (* DRV_AT25_PLIB_CALLBACK)( uintptr_t );

typedef    bool (* DRV_AT25_WRITEREAD)(void*, size_t, void *, size_t);

typedef    bool (* DRV_AT25_WRITE)(void*, size_t);

typedef    bool (* DRV_AT25_READ)(void*, size_t);

typedef    bool (* DRV_AT25_IS_BUSY)(void);

typedef    DRV_AT25_SPI_ERROR (* DRV_AT25_ERROR_GET)(void);

typedef    void (* DRV_AT25_CALLBACK_REGISTER)(DRV_AT25_PLIB_CALLBACK, uintptr_t);

// *****************************************************************************
/* AT25 Driver PLIB Interface Data

  Summary:
    Defines the data required to initialize the AT25 driver PLIB Interface.

  Description:
    This data type defines the data required to initialize the AT25 driver
    PLIB Interface.

  Remarks:
    None.
*/

typedef struct
{

    /* AT25 PLIB writeRead API */
    DRV_AT25_WRITEREAD               writeRead;

    /* AT25 PLIB write API */
    DRV_AT25_WRITE               write;

    /* AT25 PLIB read API */
    DRV_AT25_READ               read;

    /* AT25 PLIB Transfer status API */
    DRV_AT25_IS_BUSY                 isBusy;

    /* AT25 PLIB Error get API */
    DRV_AT25_ERROR_GET               errorGet;

    /* AT25 PLIB callback register API */
    DRV_AT25_CALLBACK_REGISTER       callbackRegister;

} DRV_AT25_PLIB_INTERFACE;

// *****************************************************************************
/* AT25 Driver Initialization Data

  Summary:
    Defines the data required to initialize the AT25 driver

  Description:
    This data type defines the data required to initialize or the AT25 driver.

  Remarks:
    None.
*/

typedef struct
{
    /* Identifies the PLIB API set to be used by the driver to access the
     * peripheral. */
    DRV_AT25_PLIB_INTERFACE        *spiPlib;

    /* Number of clients */
    size_t                          numClients;

    SYS_PORT_PIN                    chipSelectPin;

    SYS_PORT_PIN                    holdPin;

    SYS_PORT_PIN                    writeProtectPin;

    /* Page size (in Bytes) of the EEPROM */
    uint32_t                        pageSize;

    /* Total size (in Bytes) of the EEPROM */
    uint32_t                        flashSize;

    uint32_t                        blockStartAddress;

} DRV_AT25_INIT;


//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

#endif // #ifndef DRV_AT25_DEFINITIONS_H

/*******************************************************************************
 End of File
*/
