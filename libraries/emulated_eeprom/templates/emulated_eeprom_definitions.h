/*******************************************************************************
  EEPROM Emulator Interface Definition

  Company:
    Microchip Technology Inc.

  File Name:
    emulated_eeprom_definitions.h

  Summary:
    EEPROM Emulator Library Interface definitions.

  Description:
    This file provides common definitions.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2021 Microchip Technology Inc. and its subsidiaries.
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

#ifndef EMULATED_EEPROM_DEFINITIONS_H
#define EMULATED_EEPROM_DEFINITIONS_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// *****************************************************************************
/* Emulated EEPROM Status

  Summary:
    Identifies the current status/state of EEPROM operation.

  Description:
    This enumeration identifies the current status/state of the EEPROM operation

  Remarks:
    None
*/

typedef enum
{
    /* Operation is successful or EEPROM Emulator is successfully initialized. */
    EMU_EEPROM_STATUS_OK,
    /* No EEPROM section has been allocated in the device */
    EMU_EEPROM_STATUS_ERR_NO_MEMORY,
    /* If an address outside the valid emulated EEPROM memory space was supplied */
    EMU_EEPROM_STATUS_ERR_BAD_ADDRESS,
    /* Emulated EEPROM memory is corrupt or not formatted or is incompatible with this version or scheme of the EEPROM emulator*/
    EMU_EEPROM_STATUS_ERR_BAD_FORMAT,
    /* Emulated EEPROM is not initialized */
    EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED

}EMU_EEPROM_STATUS;

// *****************************************************************************
/* Emulated EEPROM parameters

  Summary:
    Provides different Emulated EEPROM configuration paramters

  Description:
    This structure provides configuration parameters for the Emulated EEPROM.

    This structure object has to be passed to EMU_EEPROM_ParametersGet() API
    to retreive the current configured parameters

  Remarks:
    None
*/
typedef struct
{
    /** Number of bytes per emulated EEPROM page */
    uint16_t  page_size;

    /** Number of emulated pages of EEPROM */
    uint16_t eeprom_num_logical_pages;

    /** Logical size of emulated EEPROM */
    uint32_t eeprom_logical_size;
} EMU_EEPROM_PARAMETERS ;

/** @} */

#ifdef __cplusplus
}
#endif

#endif /* EMULATED_EEPROM_DEFINITIONS_H */
