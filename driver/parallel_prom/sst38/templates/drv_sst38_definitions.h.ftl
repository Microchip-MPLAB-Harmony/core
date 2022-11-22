/*******************************************************************************
  SST38 Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sst38_definitions.h

  Summary:
    SST38 Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the SST38
	driver's system interface.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2022 Microchip Technology Inc. and its subsidiaries.
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

#ifndef DRV_SST38_DEFINITIONS_H
#define DRV_SST38_DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include "system/system.h"
#include "driver/driver.h"

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

/* SST38 PLIB API Set

  Summary:
  The set of PLIB APIs used by the SST38 driver.

  Description:
  The API set holds the function names available at the PLIb level for the
  corresponding functionality. Driver may call these functions to make use of
  the features provided by the PLIB.

  Remarks:
    None.
*/

/* Pointer to 16-bit write data to SST38 memory interface. */
typedef void (* DRV_SST38_PLIB_WRITE)(uint32_t, uint16_t);

/* Pointer to 16-bit read data to SST38 memory interface. */
typedef uint16_t (* DRV_SST38_PLIB_READ)(uint32_t);

/* Pointer to disable ECC to SST38 memory interface. */
typedef bool (* DRV_SST38_PLIB_ECC_DISABLE)(uint8_t chipSelect);

/* Pointer to enable ECC to SST38 memory interface. */
typedef bool (* DRV_SST38_PLIB_ECC_ENABLE)(uint8_t chipSelect);

typedef struct
{
    /* SST38 PLIB write API */
    DRV_SST38_PLIB_WRITE                     write;

    /* SST38 PLIB read API */
    DRV_SST38_PLIB_READ                      read;

    /* SST38 PLIB Disable ECC API */
    DRV_SST38_PLIB_ECC_DISABLE               eccDisable;

    /* SST38 PLIB Enable ECC API */
    DRV_SST38_PLIB_ECC_ENABLE                eccEnable;

} DRV_SST38_PLIB_INTERFACE;

/* SST38 Driver Initialization Data Declaration */

typedef struct
{
    /* Identifies the PLIB API set to be used by the driver to access the
     * peripheral. */
    const DRV_SST38_PLIB_INTERFACE *sst38Plib;

} DRV_SST38_INIT;


//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END


#endif // #ifndef DRV_SST38_DEFINITIONS_H
