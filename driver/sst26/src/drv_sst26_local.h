/*******************************************************************************
  SST26 Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sst26_local.h

  Summary:
    SST26 driver local declarations and definitions

  Description:
    This file contains the SST26 driver's local declarations and definitions.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
Copyright (c) 2016 - 2017 released Microchip Technology Inc. All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED AS IS WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR
CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF
SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
*******************************************************************************/
//DOM-IGNORE-END

#ifndef _DRV_SST26_LOCAL_H
#define _DRV_SST26_LOCAL_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************
#include <string.h>
#include "configuration.h"
#include "driver/sst26/drv_sst26.h"

// *****************************************************************************
// *****************************************************************************
// Section: Version Numbers
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* SST26 Driver Version Macros

  Summary:
    SST26 driver version

  Description:
    These constants provide SST26 driver version information. The driver
    version is
    DRV_SST26_VERSION_MAJOR.DRV_SST26_VERSION_MINOR.DRV_SST26_VERSION_PATCH.
    It is represented in DRV_SST26_VERSION as
    MAJOR *10000 + MINOR * 100 + PATCH, so as to allow comparisons.
    It is also represented in string format in DRV_SST26_VERSION_STR.
    DRV_SST26_TYPE provides the type of the release when the release is alpha
    or beta. The interfaces DRV_SST26_VersionGet() and
    DRV_SST26_VersionStrGet() provide interfaces to the access the version
    and the version string.

  Remarks:
    Modify the return value of DRV_SST26_VersionStrGet and the
    DRV_SST26_VERSION_MAJOR, DRV_SST26_VERSION_MINOR,
    DRV_SST26_VERSION_PATCH and DRV_SST26_VERSION_TYPE
*/

#define _DRV_SST26_VERSION_MAJOR         0
#define _DRV_SST26_VERSION_MINOR         2
#define _DRV_SST26_VERSION_PATCH         0
#define _DRV_SST26_VERSION_TYPE          "Alpha"
#define _DRV_SST26_VERSION_STR           "0.2.0 Alpha"

// *****************************************************************************
// *****************************************************************************
// Section: Local Data Type Definitions
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* SST26 Command set

  Summary:
    Enumeration listing the SST26VF commands.

  Description:
    This enumeration defines the commands used to interact with the SST26VF
    series of devices.

  Remarks:
    None
*/

typedef enum
{
    /* Reset enable command. */
    SST26_CMD_FLASH_RESET_ENABLE = 0x66,

    /* Command to reset the flash. */
    SST26_CMD_FLASH_RESET        = 0x99,

    /* Command to Enable QUAD IO */
    SST26_CMD_ENABLE_QUAD_IO     = 0x38,

    /* Command to Reset QUAD IO */
    SST26_CMD_RESET_QUAD_IO      = 0xFF,

    /* Command to read JEDEC-ID of the flash device. */
    SST26_CMD_JEDEC_ID_READ      = 0x9F,

    /* QUAD Command to read JEDEC-ID of the flash device. */
    SST26_CMD_QUAD_JEDEC_ID_READ = 0xAF,

    /* Command to perform High Speed Read */
    SST26_CMD_HIGH_SPEED_READ    = 0x0B,

    /* Write enable command. */
    SST26_CMD_WRITE_ENABLE       = 0x06,

    /* Page Program command. */
    SST26_CMD_PAGE_PROGRAM       = 0x02,

    /* Command to read the Flash status register. */
    SST26_CMD_READ_STATUS_REG    = 0x05,

    /* Command to perform sector erase */
    SST26_CMD_SECTOR_ERASE       = 0x20,

    /* Command to perform Bulk erase */
    SST26_CMD_BULK_ERASE_64K     = 0xD8,

    /* Command to perform Chip erase */
    SST26_CMD_CHIP_ERASE         = 0xC7,

    /* Command to unlock the flash device. */
    SST26_CMD_UNPROTECT_GLOBAL   = 0x98

} SST26_CMD;

// *****************************************************************************
/* SST26 Driver operations.

  Summary:
    Enumeration listing the SST26 driver operations.

  Description:
    This enumeration defines the possible SST26 driver operations.

  Remarks:
    None
*/

typedef enum
{
    /* Request is read operation. */
    DRV_SST26_OPERATION_TYPE_READ = 0,

    /* Request is write operation. */
    DRV_SST26_OPERATION_TYPE_WRITE,

    /* Request is erase operation. */
    DRV_SST26_OPERATION_TYPE_ERASE,

} DRV_SST26_OPERATION_TYPE;

/**************************************
 * SST26 Driver Hardware Instance Object
 **************************************/
typedef struct
{
    /* Flag to indicate in use  */
    bool inUse;

    /* The status of the driver */
    SYS_STATUS status;

    /* Current Operation */
    DRV_SST26_OPERATION_TYPE curOpType;

    /* PLIB API list that will be used by the driver to access the hardware */
    const SST26_PLIB_API *sst26Plib;
} DRV_SST26_OBJECT;

#endif //#ifndef _DRV_SST26_LOCAL_H

/*******************************************************************************
 End of File
*/

