/*******************************************************************************
  SST39 Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sst39_definitions.h

  Summary:
    SST39 Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the SST39
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

#ifndef DRV_SST39_DEFINITIONS_H
#define DRV_SST39_DEFINITIONS_H

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

/* SST39 PLIB API Set

  Summary:
  The set of PLIB APIs used by the SST39 driver.

  Description:
  The API set holds the function names available at the PLIb level for the
  corresponding functionality. Driver may call these functions to make use of
  the features provided by the PLIB.

  Remarks:
    None.
*/

/* Pointer to 8-bit write data to SST39 memory interface. */
typedef void (* DRV_SST39_PLIB_WRITE)(uint32_t, uint8_t);

/* Pointer to 8-bit read data to SST39 memory interface. */
typedef uint8_t (* DRV_SST39_PLIB_READ)(uint32_t);

/* Pointer to disable ECC to SST39 memory interface. */
typedef bool (* DRV_SST39_PLIB_ECC_DISABLE)(uint8_t chipSelect);

/* Pointer to enable ECC to SST39 memory interface. */
typedef bool (* DRV_SST39_PLIB_ECC_ENABLE)(uint8_t chipSelect);

typedef struct
{
    /* SST39 PLIB write API */
    DRV_SST39_PLIB_WRITE                     write;

    /* SST39 PLIB read API */
    DRV_SST39_PLIB_READ                      read;

    /* SST39 PLIB Disable ECC API */
    DRV_SST39_PLIB_ECC_DISABLE               eccDisable;

    /* SST39 PLIB Enable ECC API */
    DRV_SST39_PLIB_ECC_ENABLE                eccEnable;

} DRV_SST39_PLIB_INTERFACE;

/* SST39 Driver Initialization Data Declaration */

typedef struct
{
    /* Identifies the PLIB API set to be used by the driver to access the
     * peripheral. */
    const DRV_SST39_PLIB_INTERFACE *sst39Plib;

} DRV_SST39_INIT;


//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END


#endif // #ifndef DRV_SST39_DEFINITIONS_H
