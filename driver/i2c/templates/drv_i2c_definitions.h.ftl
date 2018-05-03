/*******************************************************************************
  I2C Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_twi_definitions.h

  Summary:
    I2C Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the I2C 
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

#ifndef DRV_I2C_DEFINITIONS_H
#define DRV_I2C_DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

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

#define SYS_DEBUG(x, y)
// *****************************************************************************
// *****************************************************************************
// Section: Data Types
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* I2C Driver Error

  Summary:
    Defines the error values

  Description:
    This data type defines the error values for the errors occured during transfer.

  Remarks:
    None.
*/

typedef enum
{
    /* Busy*/
    DRV_I2C_ERROR_NONE,
	
	/* Transfer Successful */
    DRV_I2C_ERROR_NACK,

} DRV_I2C_ERROR;

// *****************************************************************************
/* I2C Driver Transfer Setup Data

  Summary:
    Defines the data required to setup the I2C transfer

  Description:
    This data type defines the data required to setup the I2C transfer. The
    data is passed to the DRV_I2C_TransferSetup API to setup the I2C peripheral
    settings dynamically.

  Remarks:
    None.
*/

typedef struct
{   
    /* clock speed */
    uint32_t clockSpeed;
    
} DRV_I2C_TRANSFER_SETUP;

typedef void (* DRV_I2C_PLIB_CALLBACK)( uintptr_t );

typedef void (* DRV_I2C_TRANSFER_SETUP_CALLBACK)( DRV_I2C_TRANSFER_SETUP *, uint32_t );

typedef bool (* DRV_I2C_READ_CALLBACK)( uint16_t, uint8_t *, uint8_t );

typedef bool (* DRV_I2C_WRITE_CALLBACK)( uint16_t, uint8_t *, uint8_t );

typedef bool (* DRV_I2C_WRITE_READ_CALLBACK)( uint16_t, uint8_t *, uint8_t, uint8_t *, uint8_t );

typedef DRV_I2C_ERROR (* DRV_I2C_ERROR_GET_CALLBACK)( void );

typedef void (* DRV_I2C_CALLBACK_REGISTER_CALLBACK)(DRV_I2C_PLIB_CALLBACK, uintptr_t);

// *****************************************************************************
/* I2C Driver PLib Interface Data

  Summary:
    Defines the data required to initialize the I2C driver PLib Interface.

  Description:
    This data type defines the data required to initialize the I2C driver PLib
    Interface. If the driver is built statically, the members of this data
    structure are statically over-ridden by static override definitions in the
    configuration.h file.

  Remarks:
    None.
*/
  
typedef struct
{
    /* I2C PLib transfer setup API */
    DRV_I2C_TRANSFER_SETUP_CALLBACK transferSetup;
    
    /* I2C PLib read API */
    DRV_I2C_READ_CALLBACK read;
    
    /* I2C PLib write API */
    DRV_I2C_WRITE_CALLBACK write;
    
    /* I2C PLib writeRead API */
    DRV_I2C_WRITE_READ_CALLBACK writeRead;
    
    /* I2C PLib transfer */
    DRV_I2C_ERROR_GET_CALLBACK errorGet;
    
    /* I2C PLib callback register API */
    DRV_I2C_CALLBACK_REGISTER_CALLBACK callbackRegister;
    
} DRV_I2C_PLIB_INTERFACE;

// *****************************************************************************
/* I2C Driver Initialization Data

  Summary:
    Defines the data required to initialize the I2C driver

  Description:
    This data type defines the data required to initialize or the I2C driver.
    If the driver is built statically, the members of this data structure are 
    statically over-ridden by static override definitions in the
    configuration.h file.

  Remarks:
    None.
*/

typedef struct
{
    /* Identifies the PLIB API set to be used by the driver to access the 
     * peripheral. */
    DRV_I2C_PLIB_INTERFACE *i2cPlib;

    /* Memory Pool for Client Objects */
    uintptr_t clientObjPool;

    /* Number of clients */
    uint32_t numClients;
<#if DRV_I2C_MODE == "ASYNC">

    /* Interrupt source ID for the I2C interrupt. */
    INT_SOURCE interruptI2C;
    
    /* Driver Queue Size */
    size_t queueSize;

    /* Memory Pool for Transfer Objects */
    uintptr_t transferObj;
</#if>

    /* peripheral clock speed */
    uint32_t clockSpeed;
    
} DRV_I2C_INIT;

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

#endif // #ifndef DRV_I2C_DEFINITIONS_H

/*******************************************************************************
 End of File
*/
