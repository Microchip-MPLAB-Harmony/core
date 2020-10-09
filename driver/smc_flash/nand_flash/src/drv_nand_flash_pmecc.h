/*******************************************************************************
  NAND FLASH Driver PMECC Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_nand_flash_pmecc.h

  Summary:
    NAND FLASH driver PMECC declarations and definitions

  Description:
    This file contains the NAND FLASH driver's PMECC declarations and definitions.
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

#ifndef _DRV_NAND_FLASH_PMECC_H
#define _DRV_NAND_FLASH_PMECC_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

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
// Section: Data Type Definitions
// *****************************************************************************
// *****************************************************************************

/* Defines the maximum value of the error correcting capability (24 + 1) */
#define PMECC_NB_ERROR_MAX    25
#define PMECC_GF_512_SIZE     0x2000
#define PMECC_GF_1024_SIZE    0x4000

/* PMECC configuration descriptor */
typedef struct
{
    /* Defines the error correcting capability selected at encoding/decoding time */
    int32_t tt;

    /* Degree of the remainders, GF(2**mm) */
    int32_t mm;

    /* Length of codeword =  nn=2**mm -1 */
    int32_t nn;

    /* Galois field table */
    const int16_t *alphaTo;

    /* Index of Galois field table */
    const int16_t *indexOf;

    /* Partial syndromes */
    int16_t partialSyn[2 * PMECC_NB_ERROR_MAX];

    /* Holds the current syndrome value, an element of that table belongs to the field.*/
    int16_t si[2 * PMECC_NB_ERROR_MAX];

    /* sigma table */
    int16_t smu[PMECC_NB_ERROR_MAX + 2][2 * PMECC_NB_ERROR_MAX + 1];

    /* polynom order */
    int16_t lmu[PMECC_NB_ERROR_MAX + 1];
} DRV_NAND_FLASH_PMECC_DESCRIPTOR;

bool DRV_NAND_FLASH_PmeccCorrection(uint32_t pmeccStatus, uint32_t pageBuffer);
bool DRV_NAND_FLASH_PmeccDescSetup(uint32_t pageSize, uint16_t spareSize, DRV_NAND_FLASH_OBJECT *dObj);

#ifdef __cplusplus
}
#endif

#endif //#ifndef _DRV_NAND_FLASH_PMECC_H

/*******************************************************************************
 End of File
*/
