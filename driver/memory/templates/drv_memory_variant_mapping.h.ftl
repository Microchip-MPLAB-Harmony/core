/*******************************************************************************
  MEMORY Driver Feature Variant Implementations

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sst26_variant_mapping.h

  Summary:
    MEMORY Driver Feature Variant Implementations

  Description:
    This file implements the functions which differ based on different parts
    and various implementations of the same feature.
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

#ifndef _DRV_MEMORY_VARIANT_MAPPING_H
#define _DRV_MEMORY_VARIANT_MAPPING_H

#include "configuration.h"

// *****************************************************************************
// *****************************************************************************
// Section: Feature Variant Mapping
// *****************************************************************************
// *****************************************************************************
/* Some variants are determined by hardware feature existence, some features
   are determined user configuration of the driver, and some variants are
   combination of the two.
*/

<#if DRV_MEMORY_COMMON_FS_ENABLE >

#include "system/fs/sys_fs_media_manager.h"

// *****************************************************************************

/* Registers the MEMORY driver services with the File System */

void DRV_MEMORY_RegisterWithSysFs( const SYS_MODULE_INDEX drvIndex, uint8_t mediaType);

#define _DRV_MEMORY_RegisterWithSysFs(x, y) DRV_MEMORY_RegisterWithSysFs(x, y)

typedef SYS_FS_MEDIA_REGION_GEOMETRY        _DRV_MEMORY_REGION_GEOMETRY;

typedef SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE   _DRV_MEMORY_COMMAND_HANDLE;

typedef SYS_FS_MEDIA_GEOMETRY               _DRV_MEMORY_GEOMETRY;

typedef SYS_FS_MEDIA_EVENT_HANDLER          _DRV_MEMORY_TRANSFER_HANDLER;

#define DRV_MEMORY_SUPPORTS_BYTE_WRITES     SYS_FS_MEDIA_SUPPORTS_BYTE_WRITES

#define DRV_MEMORY_SUPPORTS_READ_ONLY       SYS_FS_MEDIA_SUPPORTS_READ_ONLY

#define DRV_MEMORY_SUPPORTS_ONE_TIME_PROGRAMING SYS_FS_MEDIA_SUPPORTS_ONE_TIME_PROGRAMING

#define DRV_MEMORY_READ_IS_BLOCKING         SYS_FS_MEDIA_READ_IS_BLOCKING

#define DRV_MEMORY_WRITE_IS_BLOCKING        SYS_FS_MEDIA_WRITE_IS_BLOCKING

#define _DRV_MEMORY_COMMAND_HANDLE_INVALID  SYS_FS_MEDIA_BLOCK_COMMAND_HANDLE_INVALID

#define _DRV_MEMORY_EVENT_COMMAND_COMPLETE  SYS_FS_MEDIA_EVENT_BLOCK_COMMAND_COMPLETE

#define _DRV_MEMORY_EVENT_COMMAND_ERROR     SYS_FS_MEDIA_EVENT_BLOCK_COMMAND_ERROR

#define _DRV_MEMORY_COMMAND_COMPLETED       SYS_FS_MEDIA_COMMAND_COMPLETED

#define _DRV_MEMORY_COMMAND_QUEUED          SYS_FS_MEDIA_COMMAND_QUEUED

#define _DRV_MEMORY_COMMAND_IN_PROGRESS     SYS_FS_MEDIA_COMMAND_IN_PROGRESS

#define _DRV_MEMORY_COMMAND_ERROR_UNKNOWN   SYS_FS_MEDIA_COMMAND_UNKNOWN

<#else >

typedef enum
{
    /* Media supports Byte Write */
    DRV_MEMORY_SUPPORTS_BYTE_WRITES = 0x01,

    /* Media supports only Read operation */
    DRV_MEMORY_SUPPORTS_READ_ONLY = 0x02,

    /* Media supports OTP (One Time Programming) */
    DRV_MEMORY_SUPPORTS_ONE_TIME_PROGRAMING = 0x04,

    /* Read in blocking */
    DRV_MEMORY_READ_IS_BLOCKING = 0x08,

    /* Write is blocking */
    DRV_MEMORY_WRITE_IS_BLOCKING = 0x10,

} DRV_MEMORY_PROPERTY;

typedef struct
{
    /* Size of a each block in Bytes */
    uint32_t blockSize;

    /* Number of Blocks of identical size within the Region */
    uint32_t numBlocks;

} _DRV_MEMORY_REGION_GEOMETRY;

typedef struct 
{
    /* Properties of a Media. For a device, if multiple properties  are
       applicable, they can be ORed */
    DRV_MEMORY_PROPERTY mediaProperty;

    /* Number of Read Regions */
    uint32_t numReadRegions;

    /* Number of Write Regions */
    uint32_t numWriteRegions;

    /* Number of Erase Regions */
    uint32_t numEraseRegions;

    /* Pointer to the table containing the geometry information */
    _DRV_MEMORY_REGION_GEOMETRY *geometryTable;

} _DRV_MEMORY_GEOMETRY;

typedef uintptr_t           _DRV_MEMORY_COMMAND_HANDLE;

typedef enum
{
    /* Block operation has been completed successfully. */
    _DRV_MEMORY_EVENT_COMMAND_COMPLETE,

    /* There was an error during the block operation */
    _DRV_MEMORY_EVENT_COMMAND_ERROR

} _DRV_MEMORY_EVENT;

typedef enum
{
    /*Done OK and ready */
    _DRV_MEMORY_COMMAND_COMPLETED          = 0 ,

    /*Scheduled but not started */
    _DRV_MEMORY_COMMAND_QUEUED             = 1,

    /*Currently being in transfer */
    _DRV_MEMORY_COMMAND_IN_PROGRESS        = 2,

    /*Unknown buffer */
    _DRV_MEMORY_COMMAND_ERROR_UNKNOWN      = -1,

} _DRV_MEMORY_COMMAND_STATUS;

typedef void (* _DRV_MEMORY_TRANSFER_HANDLER)
(
    _DRV_MEMORY_EVENT event,
    _DRV_MEMORY_COMMAND_HANDLE commandHandle,
    uintptr_t context
);

#define _DRV_MEMORY_RegisterWithSysFs(x, y)

#define _DRV_MEMORY_COMMAND_HANDLE_INVALID  ((_DRV_MEMORY_COMMAND_HANDLE)(-1))

</#if>

// *****************************************************************************
/* Interrupt Source Control

  Summary:
    Macros to enable, disable or clear the interrupt source

  Description:
    This macro enables, disables or clears the interrupt source

    The macros get mapped to the respective SYS module APIs if the driver instance
    is configured to interrupt mode.
 
  Remarks:
    This macro is mandatory
*/

#define _DRV_MEMORY_InterruptSourceEnable(source)          SYS_INT_SourceEnable( source )
#define _DRV_MEMORY_InterruptSourceDisable(source)         SYS_INT_SourceDisable( source )
#define _DRV_MEMORY_InterruptSourceClear(source)           SYS_INT_SourceStatusClear( source )

#define _DRV_MEMORY_InterruptSourceStatusGet(source)       SYS_INT_SourceStatusGet( source )

#endif //_DRV_MEMORY_VARIANT_MAPPING_H

/*******************************************************************************
 End of File
*/

