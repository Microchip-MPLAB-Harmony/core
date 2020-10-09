/*******************************************************************************
  NAND FLASH Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_nand_flash_definitions.h

  Summary:
    NAND FLASH Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the NAND FLASH
    driver's system interface.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2020 Microchip Technology Inc. and its subsidiaries.
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

#ifndef DRV_NAND_FLASH_DEFINITIONS_H
#define DRV_NAND_FLASH_DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include "system/system.h"
#include "driver/driver.h"
#include "peripheral/smc/plib_${DRV_NAND_FLASH_PLIB?lower_case}.h"
<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
#include "system/dma/sys_dma.h"
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
#include "system/cache/sys_cache.h"
</#if>
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

/* SMC PLIB API Set

  Summary:
  The set of PLIB APIs used by the NAND FLASH driver.

  Description:
  The API set holds the function names available at the PLIb level for the
  corresponding functionality. Driver may call these functions to make use of
  the features provided by the PLIB.

  Remarks:
    None.
*/

/* Pointer to get EBI Address to SMC NAND Flash device. */
typedef uint32_t (*DRV_NAND_FLASH_PLIB_DATA_ADDRESS_GET)(uint8_t chipSelect);

/* Pointer to 8-bit write command to SMC NAND Flash device. */
typedef void (*DRV_NAND_FLASH_PLIB_CMD_WRITE)(uint32_t dataAddress, uint8_t command);

/* Pointer to 16-bit write command to SMC NAND Flash device. */
typedef void (*DRV_NAND_FLASH_PLIB_CMD_WRITE16)(uint32_t dataAddress, uint16_t command);

/* Pointer to 8-bit write address to SMC NAND Flash device. */
typedef void (*DRV_NAND_FLASH_PLIB_ADDRESS_WRITE)(uint32_t dataAddress, uint8_t address);

/* Pointer to 16-bit write address to SMC NAND Flash device. */
typedef void (*DRV_NAND_FLASH_PLIB_ADDRESS_WRITE16)(uint32_t dataAddress, uint16_t address);

/* Pointer to 8-bit write data to SMC NAND Flash device. */
typedef void (*DRV_NAND_FLASH_PLIB_DATA_WRITE)(uint32_t dataAddress, uint8_t data);

/* Pointer to 16-bit write data to SMC NAND Flash device. */
typedef void (*DRV_NAND_FLASH_PLIB_DATA_WRITE16)(uint32_t dataAddress, uint16_t data);

/* Pointer to 8-bit read data to SMC NAND Flash device. */
typedef uint8_t (*DRV_NAND_FLASH_PLIB_DATA_READ)(uint32_t dataAddress);

/* Pointer to 16-bit read data to SMC NAND Flash device. */
typedef uint16_t (*DRV_NAND_FLASH_PLIB_DATA_READ16)(uint32_t dataAddress);

<#if DRV_NAND_FLASH_PMECC_ENABLE == true>
/* Pointer to PMECC data phase start for NAND Flash device. */
typedef void (*DRV_NAND_FLASH_PLIB_DATA_PHASE_START)(bool writeEnable);

/* Pointer to PMECC status for NAND Flash device. */
typedef bool (*DRV_NAND_FLASH_PLIB_STATUS_IS_BUSY)(void);

/* Pointer to PMECC error for NAND Flash device. */
typedef uint8_t (*DRV_NAND_FLASH_PLIB_ERROR_GET)(void);

/* Pointer to PMECC remainder for NAND Flash device. */
typedef int16_t (*DRV_NAND_FLASH_PLIB_REMAINDER_GET)(uint32_t sector, uint32_t remainderIndex);

/* Pointer to PMECC ECC for NAND Flash device. */
typedef uint8_t (*DRV_NAND_FLASH_PLIB_ECC_GET)(uint32_t sector, uint32_t byteIndex);

/* Pointer to PMERRLOC error location for NAND Flash device. */
typedef uint32_t (*DRV_NAND_FLASH_PLIB_ERROR_LOCATION_GET)(uint8_t position);

/* Pointer to PMERRLOC error location disable for NAND Flash device. */
typedef void (*DRV_NAND_FLASH_PLIB_ERROR_LOCATION_DISABLE)(void);

/* Pointer to PMERRLOC sigma for NAND Flash device. */
typedef void (*DRV_NAND_FLASH_PLIB_SIGMA_SET)(uint32_t sigmaVal, uint32_t sigmaNum);

/* Pointer to PMERRLOC find number of roots for NAND Flash device. */
typedef uint32_t (*DRV_NAND_FLASH_PLIB_EL_FIND_NO_OF_ROOTS)(uint32_t sectorSizeInBits, uint32_t errorNumber);
</#if>

typedef struct
{
    /* Pointer to get EBI Address to SMC NAND Flash device. */
    DRV_NAND_FLASH_PLIB_DATA_ADDRESS_GET DataAddressGet;

    /* Pointer to 8-bit write command to SMC NAND Flash device. */
    DRV_NAND_FLASH_PLIB_CMD_WRITE CommandWrite;

    /* Pointer to 16-bit write command to SMC NAND Flash device. */
    DRV_NAND_FLASH_PLIB_CMD_WRITE16 CommandWrite16;

    /* Pointer to 8-bit write address to SMC NAND Flash device. */
    DRV_NAND_FLASH_PLIB_ADDRESS_WRITE AddressWrite;

    /* Pointer to 16-bit write address to SMC NAND Flash device. */
    DRV_NAND_FLASH_PLIB_ADDRESS_WRITE16 AddressWrite16;

    /* Pointer to 8-bit write data to SMC NAND Flash device. */
    DRV_NAND_FLASH_PLIB_DATA_WRITE DataWrite;

    /* Pointer to 16-bit write data to SMC NAND Flash device. */
    DRV_NAND_FLASH_PLIB_DATA_WRITE16 DataWrite16;

    /* Pointer to 8-bit read data to SMC NAND Flash device. */
    DRV_NAND_FLASH_PLIB_DATA_READ DataRead;

    /* Pointer to 16-bit read data to SMC NAND Flash device. */
    DRV_NAND_FLASH_PLIB_DATA_READ16 DataRead16;

<#if DRV_NAND_FLASH_PMECC_ENABLE == true>
    /* Pointer to PMECC data phase start for NAND Flash device. */
    DRV_NAND_FLASH_PLIB_DATA_PHASE_START DataPhaseStart;

    /* Pointer to PMECC status for NAND Flash device. */
    DRV_NAND_FLASH_PLIB_STATUS_IS_BUSY StatusIsBusy;

    /* Pointer to PMECC error get for NAND Flash device. */
    DRV_NAND_FLASH_PLIB_ERROR_GET ErrorGet;

    /* Pointer to PMECC remainder get for NAND Flash device. */
    DRV_NAND_FLASH_PLIB_REMAINDER_GET RemainderGet;

    /* Pointer to PMECC ECC get for NAND Flash device. */
    DRV_NAND_FLASH_PLIB_ECC_GET ECCGet;

    /* Pointer to PMERRLOC error location get for NAND Flash device. */
    DRV_NAND_FLASH_PLIB_ERROR_LOCATION_GET ErrorLocationGet;

    /* Pointer to PMERRLOC error location disable for NAND Flash device. */
    DRV_NAND_FLASH_PLIB_ERROR_LOCATION_DISABLE ErrorLocationDisable;

    /* Pointer to PMERRLOC sigma for NAND Flash device. */
    DRV_NAND_FLASH_PLIB_SIGMA_SET SigmaSet;

    /* Pointer to PMERRLOC find number of roots for NAND Flash device. */
    DRV_NAND_FLASH_PLIB_EL_FIND_NO_OF_ROOTS ErrorLocationFindNumOfRoots;
</#if>
} DRV_NAND_FLASH_PLIB_INTERFACE;

/* NAND FLASH Driver Initialization Data Declaration */

typedef struct
{
    /* Identifies the PLIB API set to be used by the driver to access the
     * peripheral. */
    const DRV_NAND_FLASH_PLIB_INTERFACE *nandFlashPlib;

} DRV_NAND_FLASH_INIT;


//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END


#endif // #ifndef DRV_NAND_FLASH_DEFINITIONS_H

