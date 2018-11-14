/*******************************************************************************
  SD Card Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdcard_definitions.h

  Summary:
    SD Card Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the SD Card
    driver's system interface.
*******************************************************************************/

// DOM-IGNORE-BEGIN
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
// DOM-IGNORE-END

#ifndef DRV_SDCARD_DEFINITIONS_H
#define DRV_SDCARD_DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************
#include "drv_sdcard.h"

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
typedef SYS_MODULE_OBJ (*DRV_SDCARD_INITIALIZE)(const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT * const init );
typedef DRV_HANDLE (*DRV_SDCARD_OPEN) (const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent);
typedef SYS_STATUS (*DRV_SDCARD_STATUS)( SYS_MODULE_OBJ object );
typedef void (*DRV_SDCARD_TASKS) ( SYS_MODULE_OBJ object );
typedef void (*DRV_SDCARD_CLOSE)(const DRV_HANDLE handle);
typedef bool (*DRV_SDCARD_IS_ATTACHED)(const DRV_HANDLE handle);
typedef bool (*DRV_SDCARD_IS_WRITE_PROTECTED)( const DRV_HANDLE handle );
typedef DRV_SDCARD_COMMAND_STATUS (*DRV_SDCARD_CMD_STATUS)( const DRV_HANDLE handle, const DRV_SDCARD_COMMAND_HANDLE commandHandle );
typedef void (*DRV_SDCARD_EVENT_HANDLER_SET)( const DRV_HANDLE handle, const void * eventHandler, const uintptr_t context );
typedef SYS_MEDIA_GEOMETRY* (*DRV_SDCARD_GEOMETRY_GET) ( const DRV_HANDLE handle );
typedef bool (*DRV_SDCARD_READ_SYNC) ( const DRV_HANDLE handle, void* targetBuffer, uint32_t blockStart, uint32_t nBlock);
typedef bool (*DRV_SDCARD_WRITE_SYNC)( const DRV_HANDLE handle, void* sourceBuffer, uint32_t blockStart, uint32_t nBlock);
typedef void (*DRV_SDCARD_READ_ASYNC) ( const DRV_HANDLE handle, DRV_SDCARD_COMMAND_HANDLE *commandHandle, void* targetBuffer, uint32_t blockStart, uint32_t nBlock);
typedef void (*DRV_SDCARD_WRITE_ASYNC)( const DRV_HANDLE handle, DRV_SDCARD_COMMAND_HANDLE *commandHandle, void* sourceBuffer, uint32_t blockStart, uint32_t nBlock);
typedef void (*DRV_SDCARD_FS_READ) ( const DRV_HANDLE handle, DRV_SDCARD_COMMAND_HANDLE *commandHandle, void* targetBuffer, uint32_t blockStart, uint32_t nBlock);
typedef void (*DRV_SDCARD_FS_WRITE)( const DRV_HANDLE handle, DRV_SDCARD_COMMAND_HANDLE *commandHandle, void* sourceBuffer, uint32_t blockStart, uint32_t nBlock);

// *****************************************************************************
/* SDCARD Driver Initialization Data

  Summary:
    Defines the data required to initialize the SDCARD driver

  Description:
    This data type defines the data required to initialize or the SDCARD driver.

  Remarks:
    None.
*/

typedef struct
{
    DRV_SDCARD_INITIALIZE           initialize;
    DRV_SDCARD_OPEN                 open;
    DRV_SDCARD_STATUS               status;
    DRV_SDCARD_TASKS                tasks;
    DRV_SDCARD_CLOSE                close;
    DRV_SDCARD_IS_ATTACHED          isAttached;
    DRV_SDCARD_IS_WRITE_PROTECTED   isWriteProtected;
    DRV_SDCARD_CMD_STATUS           commandStatus;
    DRV_SDCARD_EVENT_HANDLER_SET    eventHandlerSet;
    DRV_SDCARD_GEOMETRY_GET         geometryGet;
    DRV_SDCARD_READ_SYNC            readSync;
    DRV_SDCARD_WRITE_SYNC           writeSync;
    DRV_SDCARD_READ_ASYNC           readAsync;
    DRV_SDCARD_WRITE_ASYNC          writeAsync;
    DRV_SDCARD_FS_READ              fsRead;
    DRV_SDCARD_FS_WRITE             fsWrite;

    const SYS_MODULE_INIT*          sdDriverInitData;
    bool                            isFsEnabled;

}DRV_SDCARD_INIT;

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

#endif // #ifndef DRV_SDCARD_DEFINITIONS_H

/*******************************************************************************
 End of File
*/