/*******************************************************************************
  AT24 Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_twi_definitions.h

  Summary:
    AT24 Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the AT24
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

#ifndef DRV_AT24_DEFINITIONS_H
#define DRV_AT24_DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <device.h>

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
    DRV_AT24_I2C_ERROR_NONE = 0,

    /* Slave returned Nack */
    DRV_AT24_I2C_ERROR_NACK,

}DRV_AT24_I2C_ERROR;

typedef void (* DRV_AT24_PLIB_CALLBACK)( uintptr_t );

typedef    bool (* DRV_WRITEREAD)(uint16_t , uint8_t* , uint32_t , uint8_t* , uint32_t);

typedef    bool (* DRV_WRITE)(uint16_t , uint8_t* , uint32_t );

typedef    bool (* DRV_READ)(uint16_t , uint8_t* , uint32_t);

typedef    bool (* DRV_IS_BUSY)(void);

typedef    DRV_AT24_I2C_ERROR (* DRV_ERROR_GET)(void);

typedef    void (* DRV_CALLBACK_REGISTER)(DRV_AT24_PLIB_CALLBACK, uintptr_t);

// *****************************************************************************
/* AT24 Driver PLIB Interface Data

  Summary:
    Defines the data required to initialize the AT24 driver PLIB Interface.

  Description:
    This data type defines the data required to initialize the AT24 driver
    PLIB Interface.

  Remarks:
    None.
*/

typedef struct
{
    /* AT24 PLIB writeRead API */
    DRV_WRITEREAD               writeRead;

    /* AT24 PLIB write API */
    DRV_WRITE               write;

    /* AT24 PLIB read API */
    DRV_READ               read;

    /* AT24 PLIB Transfer status API */
    DRV_IS_BUSY                 isBusy;

    /* AT24 PLIB Error get API */
    DRV_ERROR_GET               errorGet;

    /* AT24 PLIB callback register API */
    DRV_CALLBACK_REGISTER       callbackRegister;

} DRV_AT24_PLIB_INTERFACE;

// *****************************************************************************
/* AT24 Driver Initialization Data

  Summary:
    Defines the data required to initialize the AT24 driver

  Description:
    This data type defines the data required to initialize or the AT24 driver.

  Remarks:
    None.
*/

typedef struct
{
    /* Identifies the PLIB API set to be used by the driver to access the
     * peripheral. */
    DRV_AT24_PLIB_INTERFACE        *i2cPlib;
    
    /* Address of the I2C slave */
    uint16_t                        slaveAddress;
    
    /* Page size (in Bytes) of the EEPROM */
    uint32_t                        pageSize;
    
    /* Total size (in Bytes) of the EEPROM */
    uint32_t                        flashSize;

    /* Number of clients */
    size_t                          numClients;

    uint32_t                        blockStartAddress;

} DRV_AT24_INIT;


//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

#endif // #ifndef DRV_AT24_DEFINITIONS_H

/*******************************************************************************
 End of File
*/
