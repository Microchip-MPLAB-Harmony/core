/*******************************************************************************
  EEPROM Emulator Interface Header File

  Company:
    Microchip Technology Inc.

  File Name:
    emulated_eeprom.h

  Summary:
    EEPROM Emulator Library Interface header.

  Description:
    The EEPROM emulator Library provides a interface to EEPROM emulator routines.
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

#ifndef _EMULATED_EEPROM_H
#define _EMULATED_EEPROM_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#include "system/system_module.h"
#include "emulated_eeprom_definitions.h"

#ifdef __cplusplus
extern "C" {
#endif

// *****************************************************************************
/* Function:
    SYS_MODULE_OBJ EMU_EEPROM_Initialize(const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT* const init)

  Summary:
    Initializes the EEPROM Emulator library.

  Description:
   Initializes the emulated EEPROM memory space; if the emulated EEPROM memory
   has not been previously initialized, it will need to be explicitly formatted
   via EMU_EEPROM_EraseMemory(). The EEPROM memory space will not be
   automatically erased by the initialization function, so that partial data may
   be recovered by the user application manually if the service is unable to
   initialize successfully.

  Precondition:
    None.

  Parameters:
    drvIndex - Identifier for the instance to be initialized.

    init - Pointer to the init data structure containing any data necessary to
    initialize the driver.

  Returns:
    If successful, returns a valid handle to a driver instance object.
    Otherwise, returns SYS_MODULE_OBJ_INVALID.

  Example:
    <code>
    // The following code snippet shows an example I2C driver initialization.

    sysObj.libEMULATED_EEPROM0 = EMU_EEPROM_Initialize(EMULATED_EEPROM0, (SYS_MODULE_INIT *)NULL);

    </code>

  Remarks:
    This routine must be called before any other EEPROM Emulation library routine is called.
    This routine should only be called once during system initialization.
*/

SYS_MODULE_OBJ EMU_EEPROM_Initialize(const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT* const init);

// *****************************************************************************
/* Function:
    EMU_EEPROM_STATUS EMU_EEPROM_StatusGet( void )

  Summary:
    Gets the current status of the EEPROM Emulator library.

  Description:
    This routine provides the status of the EEPROM Emulator library.

  Precondition:
    Function EMU_EEPROM_Initialize should have been called
    before calling this function.

  Parameters:
    None

  Returns:
    EMU_EEPROM_STATUS - Enum of type EMU_EEPROM_STATUS.
    Status code indicating the status of the operation.

  Example:
    <code>
    if (EMU_EEPROM_StatusGet() == EMU_EEPROM_STATUS_ERR_BAD_FORMAT)
    {
        //Format the EEPROM Emulation memory if the initialization failed
        EMU_EEPROM_FormatMemory();
    }
    </code>

  Remarks:
    None
*/

EMU_EEPROM_STATUS EMU_EEPROM_StatusGet( void );

// *****************************************************************************
/* Function:
    bool EMU_EEPROM_FormatMemory(void)

  Summary:
    Erases the entire emulated EEPROM memory space.

  Description:
    Erases the entire emulated EEPROM memory space and formats it.

  Precondition:
    Function EMU_EEPROM_Initialize should have been called
    before calling this function.

  Parameters:
    None

  Returns:
    True - Memory is formatted successfully

    False - Error during formatting
  Example:
    <code>
    if (EMU_EEPROM_Status() == SYS_STATUS_UNINITIALIZED)
    {
        //Format the EEPROM Emulation memory if the initialization failed
        EMU_EEPROM_FormatMemory();
    }
    </code>

  Remarks:
    None
*/
bool EMU_EEPROM_FormatMemory(void);

// *****************************************************************************
/* Function:
    EMU_EEPROM_STATUS EMU_EEPROM_ParametersGet( EMU_EEPROM_PARAMETERS *const parameters)

  Summary:
    Returns EEPROM Emulation configuration parameters

  Description:
    Retrieves the configuration parameters of the EEPROM Emulator

  Precondition:
    Function EMU_EEPROM_Initialize should have been called
    before calling this function.

  Parameters:
    parameters - pointer to variable of type EMU_EEPROM_PARAMETERS

  Returns:
    EMU_EEPROM_STATUS - Enum of type EMU_EEPROM_STATUS

  Example:
    <code>
    EMU_EEPROM_PARAMETERS param;
    EMU_EEPROM_ParametersGet(&param);
    </code>

  Remarks:
    None
*/
EMU_EEPROM_STATUS EMU_EEPROM_ParametersGet( EMU_EEPROM_PARAMETERS *const parameters);

/* Function:
    EMU_EEPROM_STATUS EMU_EEPROM_PageBufferCommit(void)

  Summary:
    Commits any cached data to physical non-volatile memory

  Description:
    Commits the internal SRAM caches to physical non-volatile memory, to ensure
    that any outstanding cached data is preserved. This function should be called
    prior to a system reset or shutdown to prevent data loss.

  Precondition:
    Function EMU_EEPROM_Initialize should have been called
    before calling this function.

  Parameters:
    None

  Returns:
    EMU_EEPROM_STATUS - Enum of type EMU_EEPROM_STATUS. Status code indicating
    the status of the operation.

  Example:
    <code>
    EMU_EEPROM_PageBufferCommit();
    </code>

  Remarks:
    None
*/
EMU_EEPROM_STATUS EMU_EEPROM_PageBufferCommit(void);

/* Function:
    EMU_EEPROM_STATUS EMU_EEPROM_PageWrite(
        const uint8_t logical_page,
        const uint8_t *const data)

  Summary:
    Writes a page of data to an emulated EEPROM memory page.

  Description:
    Writes an emulated EEPROM page of data to the emulated EEPROM memory space

  Precondition:
    Function EMU_EEPROM_Initialize should have been called
    before calling this function.

  Parameters:
    logical_page - Logical EEPROM page number to write to
    data - Pointer to the data buffer containing source data to write

  Returns:
    EMU_EEPROM_STATUS - Enum of type EMU_EEPROM_STATUS. Status code indicating
    the status of the operation.

  Example:
    <code>
    uint8_t my_buffer[EMU_EEPROM_PAGE_DATA_SIZE];

    EMU_EEPROM_PageWrite(0, my_buffer);
    </code>

  Remarks:
    Data stored in pages may be cached in volatile RAM memory; to commit any
    cached data to physical non-volatile memory, the EMU_EEPROM_CachedDataCommit()
    function should be called.
*/
EMU_EEPROM_STATUS EMU_EEPROM_PageWrite(
        const uint8_t logical_page,
        const uint8_t *const data);

/* Function:
    EMU_EEPROM_STATUS EMU_EEPROM_PageRead(
        const uint8_t logical_page,
        uint8_t *const data)

  Summary:
    Reads a page of data from an emulated EEPROM memory page

  Description:
    Reads an emulated EEPROM page of data from the emulated EEPROM memory space

  Precondition:
    Function EMU_EEPROM_Initialize should have been called
    before calling this function.

  Parameters:
    logical_page - Logical EEPROM page number to write to
    data -  Pointer to the destination data buffer to fill

  Returns:
    EMU_EEPROM_STATUS - Enum of type EMU_EEPROM_STATUS. Status code indicating
    the status of the operation.

  Example:
    <code>
    uint8_t my_buffer[EMU_EEPROM_PAGE_DATA_SIZE];

    EMU_EEPROM_PageRead(0, my_buffer);
    </code>

  Remarks:
    None
*/
EMU_EEPROM_STATUS EMU_EEPROM_PageRead(
        const uint8_t logical_page,
        uint8_t *const data);

/* Function:
    EMU_EEPROM_STATUS EMU_EEPROM_BufferWrite(
        const uint16_t offset,
        const uint8_t *const data,
        const uint16_t length)

  Summary:
    Writes a buffer of data to the emulated EEPROM memory space

  Description:
    Writes a buffer of data to a section of emulated EEPROM memory space.
    The source buffer may be of any size, and the destination may lie outside
    of an emulated EEPROM page boundary.

  Precondition:
    Function EMU_EEPROM_Initialize should have been called
    before calling this function.

  Parameters:
    offset - Starting byte offset to write to, in emulated EEPROM memory space
    data - Pointer to the data buffer containing source data to write
    length - Length of the data to write, in bytes

  Returns:
    EMU_EEPROM_STATUS - Enum of type EMU_EEPROM_STATUS. Status code indicating
    the status of the operation.

  Example:
    <code>
    uint8_t my_buffer[5];

    EMU_EEPROM_BufferWrite(0, my_buffer, 5);
    </code>

  Remarks:
    Data stored in pages may be cached in volatile RAM memory; to commit any
    cached data to physical non-volatile memory, the EMU_EEPROM_CachedDataCommit()
    function should be called.
*/
EMU_EEPROM_STATUS EMU_EEPROM_BufferWrite(
        const uint16_t offset,
        const uint8_t *const data,
        const uint16_t length);

/* Function:
    EMU_EEPROM_STATUS EMU_EEPROM_BufferRead(
        const uint16_t offset,
        uint8_t *const data,
        const uint16_t length)

  Summary:
    Reads a buffer of data from the emulated EEPROM memory space

  Description:
    Reads a buffer of data from a section of emulated EEPROM memory space. The
    destination buffer may be of any size, and the source may lie outside of an
    emulated EEPROM page boundary.

  Precondition:
    Function EMU_EEPROM_Initialize should have been called
    before calling this function.

  Parameters:
    offset - Starting byte offset to write to, in emulated EEPROM memory space
    data - Pointer to the destination data buffer to fill
    length - Length of the data to write, in bytes

  Returns:
    EMU_EEPROM_STATUS - Enum of type EMU_EEPROM_STATUS. Status code indicating
    the status of the operation.

  Example:
    <code>
    uint8_t my_buffer[5];

    EMU_EEPROM_BufferRead(0, my_buffer, 5);
    </code>

  Remarks:
    None
*/
EMU_EEPROM_STATUS EMU_EEPROM_BufferRead(
        const uint16_t offset,
        uint8_t *const data,
        const uint16_t length);

/** @} */

#ifdef __cplusplus
}
#endif

#endif /* _EMULATED_EEPROM_H */
