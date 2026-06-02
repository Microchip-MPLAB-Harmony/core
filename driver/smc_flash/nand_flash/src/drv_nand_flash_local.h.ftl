/*******************************************************************************
  NAND FLASH Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_nand_flash_local.h

  Summary:
    NAND FLASH driver local declarations and definitions

  Description:
    This file contains the NAND FLASH driver's local declarations and definitions.
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

#ifndef DRV_NAND_FLASH_LOCAL_H
#define DRV_NAND_FLASH_LOCAL_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************
#include <string.h>
#include "configuration.h"
#include "driver/smc_flash/nand_flash/drv_nand_flash.h"

#ifdef __cplusplus  // Provide C++ Compatibility
    extern "C" {
#endif

// *****************************************************************************
// *****************************************************************************
// Section: Version Numbers
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
// *****************************************************************************
// Section: Local Data Type Definitions
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* NAND FLASH Command set

  Summary:
    Enumeration listing the NAND FLASH commands.

  Description:
    This enumeration defines the commands used to interact with the NAND FLASH
    series of devices.

  Remarks:
    None
*/
typedef enum
{
    /* Read command for cycle1 */
    NAND_FLASH_CMD_READ1         = 0x00,

    /* Read (page) command for cycle2 */
    NAND_FLASH_CMD_READ2         = 0x30,

    /* Copyback read (Read for internal data move) command for cycle 2 */
    NAND_FLASH_CMD_COPYBACK_READ = 0x35,

    /* Change read column (Random data read) command for cycle 1 */
    NAND_FLASH_CMD_CHANGE_RD_CLMN1 = 0x05,

    /* Change read column (Random data read) command for cycle 2 */
    NAND_FLASH_CMD_CHANGE_RD_CLMN2 = 0xE0,

    /* Read cache enhanced (Read page cache random) command for cycle 2 */
    NAND_FLASH_CMD_READ_CACHE_ENHANCED = 0x31,

    /* Read cache (Read page cache sequential) command for cycle 1 */
    NAND_FLASH_CMD_READ_CACHE = 0x31,

    /* Read cache end (Read page cache last) command for cycle 1 */
    NAND_FLASH_CMD_READ_CACHE_END = 0x3F,

    /* Block erase command for cycle 1 */
    NAND_FLASH_CMD_BLOCK_ERASE1 = 0x60,

    /* Block erase command for cycle 2 */
    NAND_FLASH_CMD_BLOCK_ERASE2 = 0xD0,

    /* Block erase interleaved command for cycle 2 */
    NAND_FLASH_CMD_BLOCK_ERASE_INTERLEAVED = 0xD1,

    /* Read status command for cycle 1 */
    NAND_FLASH_CMD_READ_STATUS = 0x70,

    /* Read status enhanced command for cycle 1 */
    NAND_FLASH_CMD_READ_STATUS_ENHANCED = 0x78,

    /* Page program command for cycle 1 */
    NAND_FLASH_CMD_PAGE_PROGRAM1 = 0x80,

    /* Page program command for cycle 2 */
    NAND_FLASH_CMD_PAGE_PROGRAM2 = 0x10,

    /* Page program interleaved command for cycle 2 */
    NAND_FLASH_CMD_PAGE_PRGM_INTERLEAVE = 0x11,

    /* Page cache program command for cycle 2 */
    NAND_FLASH_CMD_PAGE_CACHE_PROGRAM = 0x15,

    /* Copyback program command for cycle 1 */
    NAND_FLASH_CMD_CPYBACK_PRGM1 = 0x85,

    /* Copyback program command for cycle 2 */
    NAND_FLASH_CMD_CPYBACK_PRGM2 = 0x10,

    /* Copyback program interleaved command for cycle 2 */
    NAND_FLASH_CMD_CPYBACK_PRGM_INTERLEAVE = 0x11,

    /* Change write column (Random data input) command for cycle 1 */
    NAND_FLASH_CMD_CHANGE_WRITE_COLUMN = 0x85,

    /* Read ID command for cycle 1 */
    NAND_FLASH_CMD_READ_ID = 0x90,

    /* Read parameter page for cycle 1 */
    NAND_FLASH_CMD_READ_PARAMETER_PAGE = 0xEC,

    /* Read unique ID command for cycle 1 */
    NAND_FLASH_CMD_READ_UNIQUE_ID = 0xED,

    /* Get features command for cycle 1 */
    NAND_FLASH_CMD_GET_FEATURES = 0xEE,

    /* Set features command for cycle 1 */
    NAND_FLASH_CMD_SET_FEATURES = 0xEF,

    /* Reset command for cycle 1 */
    NAND_FLASH_CMD_RESET = 0xFF,

} NAND_FLASH_CMD;

/**************************************
 * NAND FLASH Driver Hardware Instance Object
 **************************************/
typedef struct
{
    /* Flag to indicate in use  */
    bool inUse;

    /* The status of the driver */
    SYS_STATUS status;

    /* Intent of opening the driver */
    DRV_IO_INTENT ioIntent;

    /* Indicates the number of clients that have opened this driver */
    size_t nClients;

<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
    SYS_DMA_CHANNEL txrxDMAChannel;

    /* NAND Flash transfer status. Used for DMA operation only */
    volatile DRV_NAND_FLASH_TRANSFER_STATUS transferStatus;

</#if>

    /* PLIB API list that will be used by the driver to access the hardware */
    const DRV_NAND_FLASH_PLIB_INTERFACE *nandFlashPlib;
} DRV_NAND_FLASH_OBJECT;

#ifdef __cplusplus
}
#endif

#endif //#ifndef DRV_NAND_FLASH_LOCAL_H

/*******************************************************************************
 End of File
*/

