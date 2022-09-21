/*******************************************************************************
  AT24 Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_at24_definitions.h

  Summary:
    AT24 Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the AT24
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

typedef void (* DRV_AT24_PLIB_CALLBACK)( uintptr_t contextHandle);

typedef bool (* DRV_AT24_PLIB_WRITE_READ)(uint16_t address, uint8_t *wdata, uint32_t wlength, uint8_t *rdata, uint32_t rlength);

typedef bool (* DRV_AT24_PLIB_WRITE)(uint16_t address, uint8_t *pdata, uint32_t length);

typedef bool (* DRV_AT24_PLIB_READ)(uint16_t address, uint8_t *pdata, uint32_t length);

typedef bool (* DRV_AT24_PLIB_IS_BUSY)(void);

typedef DRV_AT24_I2C_ERROR (* DRV_AT24_PLIB_ERROR_GET)(void);

typedef void (* DRV_AT24_PLIB_CALLBACK_REGISTER)(DRV_AT24_PLIB_CALLBACK callback, uintptr_t contextHandle);

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
    DRV_AT24_PLIB_WRITE_READ               writeRead;

    /* AT24 PLIB write API */
    DRV_AT24_PLIB_WRITE                     write_t;

    /* AT24 PLIB read API */
    DRV_AT24_PLIB_READ                      read_t;

    /* AT24 PLIB Transfer status API */
    DRV_AT24_PLIB_IS_BUSY                   isBusy;

    /* AT24 PLIB Error get API */
    DRV_AT24_PLIB_ERROR_GET                 errorGet;

    /* AT24 PLIB callback register API */
    DRV_AT24_PLIB_CALLBACK_REGISTER         callbackRegister;

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
    const DRV_AT24_PLIB_INTERFACE*      i2cPlib;

    /* Address of the I2C slave */
    uint16_t                            slaveAddress;

    /* Page size (in Bytes) of the EEPROM */
    uint32_t                            pageSize;

    /* Total size (in Bytes) of the EEPROM */
    uint32_t                            flashSize;

    /* Number of clients */
    size_t                              numClients;

    uint32_t                            blockStartAddress;

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
