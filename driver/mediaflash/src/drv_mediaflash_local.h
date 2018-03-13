 /*******************************************************************************
  MEDIAFLASH Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_mediaflash_local.h

  Summary:
    MEDIAFLASH driver local declarations and definitions

  Description:
    This file contains the timer driver's local declarations and definitions.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
Copyright (c) 2017 released Microchip Technology Inc.  All rights reserved.

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

#ifndef _DRV_MEDIAFLASH_LOCAL_H
#define _DRV_MEDIAFLASH_LOCAL_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <string.h>
#include "driver/mediaflash/drv_mediaflash.h"


// *****************************************************************************
// *****************************************************************************
// Section: Version Numbers
// *****************************************************************************
// *****************************************************************************
/* Versioning of the driver */

// *****************************************************************************
/* MEDIAFLASH Driver Version Macros

  Summary:
    MEDIAFLASH driver version

  Description:
    These constants provide MEDIAFLASH driver version information. The driver
    version is
    DRV_MEDIAFLASH_VERSION_MAJOR.DRV_MEDIAFLASH_VERSION_MINOR.DRV_MEDIAFLASH_VERSION_PATCH.
    It is represented in DRV_MEDIAFLASH_VERSION as
    MAJOR *10000 + MINOR * 100 + PATCH, so as to allow comparisons.
    It is also represented in string format in DRV_MEDIAFLASH_VERSION_STR.
    DRV_MEDIAFLASH_TYPE provides the type of the release when the release is alpha
    or beta. The interfaces DRV_MEDIAFLASH_VersionGet() and
    DRV_MEDIAFLASH_VersionStrGet() provide interfaces to the access the version
    and the version string.

  Remarks:
    Modify the return value of DRV_MEDIAFLASH_VersionStrGet and the
    DRV_MEDIAFLASH_VERSION_MAJOR, DRV_MEDIAFLASH_VERSION_MINOR,
    DRV_MEDIAFLASH_VERSION_PATCH and DRV_MEDIAFLASH_VERSION_TYPE
*/

#define _DRV_MEDIAFLASH_VERSION_MAJOR         0
#define _DRV_MEDIAFLASH_VERSION_MINOR         2
#define _DRV_MEDIAFLASH_VERSION_PATCH         0
#define _DRV_MEDIAFLASH_VERSION_TYPE          "Alpha"
#define _DRV_MEDIAFLASH_VERSION_STR           "0.2.0 Alpha"

// *****************************************************************************
/* MEDIAFLASH Flash Read/Write/Erase Region Index Numbers

  Summary:
    MEDIAFLASH Geometry Table Index definitions.

  Description:
    These constants provide MEDIAFLASH Geometry Table index definitions.

  Remarks:
    None
*/
#define GEOMETRY_TABLE_READ_ENTRY   (0)
#define GEOMETRY_TABLE_WRITE_ENTRY  (1)
#define GEOMETRY_TABLE_ERASE_ENTRY  (2)

/*****************************************************************************
 * If the MEDIAFLASH needs to be controlled by media manager, then declare the
 * following as 1. Otherwise, declare as 0.
 *
 *****************************************************************************/

// *****************************************************************************
/* MEDIAFLASH Driver Buffer Handle Macros

  Summary:
    MEDIAFLASH driver Buffer Handle Macros

  Description:
    Buffer handle related utility macros. MEDIAFLASH driver buffer handle is a 
    combination of buffer token and the buffer object index. The buffertoken
    is a 16 bit number that is incremented for every new write or erase request
    and is used along with the buffer object index to generate a new buffer 
    handle for every request.

  Remarks:
    None
*/

#define _DRV_MEDIAFLASH_BUF_TOKEN_MAX         (0xFFFF)
#define _DRV_MEDIAFLASH_MAKE_HANDLE(token, index) ((token) << 16 | (index))
#define _DRV_MEDIAFLASH_UPDATE_BUF_TOKEN(token) \
{ \
    (token)++; \
    (token) = ((token) == _DRV_MEDIAFLASH_BUF_TOKEN_MAX) ? 0: (token); \
}

// *****************************************************************************
// *****************************************************************************
// Section: Local Data Type Definitions
// *****************************************************************************
// *****************************************************************************

extern SYS_FS_MEDIA_REGION_GEOMETRY *gMEDIAFLASHGeometryTable;
/****************************************
 * This enumeration defines the possible 
 * MEDIAFLASH driver operations.
 ****************************************/

typedef enum
{
    /* Write Operation to be performed on the buffer*/
    DRV_MEDIAFLASH_BUFFER_FLAG_WRITE                 /*DOM-IGNORE-BEGIN*/ = 1 << 0/*DOM-IGNORE-END*/,

    /* Read Operation to be performed on the buffer */
    DRV_MEDIAFLASH_BUFFER_FLAG_READ                  /*DOM-IGNORE-BEGIN*/ = 1 << 1/*DOM-IGNORE-END*/,

    /* Erase Operation to be performed on the buffer */
    DRV_MEDIAFLASH_BUFFER_FLAG_ERASE                  /*DOM-IGNORE-BEGIN*/ = 1 << 2/*DOM-IGNORE-END*/,

    /* Erase and write operation */
    DRV_MEDIAFLASH_BUFFER_FLAG_ERASE_WRITE             /*DOM-IGNORE-BEGIN*/ = 1 << 3/*DOM-IGNORE-END*/

} DRV_MEDIAFLASH_BUFFER_FLAGS;

/*******************************************
 * MEDIAFLASH Driver Buffer Object that services
 * a driver request.
 ******************************************/

typedef struct _DRV_MEDIAFLASH_BUFFER_OBJECT
{
    /* True if object is allocated */
    bool inUse;

    /* Client source or destination pointer */
    uint8_t * appDataPointer;
    uint32_t * flashMemPointer;

    /* Size of the request */
    uint32_t size;

    /* Client that owns this buffer */
    DRV_HANDLE hClient;

    /* Present status of this command */
    DRV_MEDIAFLASH_COMMAND_STATUS status;

    /* Type of MEDIAFLASH driver operation */
    DRV_MEDIAFLASH_BUFFER_FLAGS flag;

    /* Pointer to the next buffer in the queue */
    struct _DRV_MEDIAFLASH_BUFFER_OBJECT * next;

    /* Pointer to the previous buffer in the queue */
    struct _DRV_MEDIAFLASH_BUFFER_OBJECT * previous;

    /* Current command handle of this buffer object */
    DRV_MEDIAFLASH_COMMAND_HANDLE commandHandle;

    /* Number of pending blocks to be procssed */
    uint32_t nBlocksPending;

    /* Size of each block in this request */
    uint32_t blockSize;

} DRV_MEDIAFLASH_BUFFER_OBJECT;

typedef enum 
{
    DRV_MEDIAFLASH_ERASE_WRITE_STEP_ERASE_COMPLETE = 0x1,
    DRV_MEDIAFLASH_ERASE_WRITE_STEP_WRITE_PAGE = 0x2,
    DRV_MEDIAFLASH_ERASE_WRITE_STEP_ERASE_NEXT_PAGE = 0x4
            
} DRV_MEDIAFLASH_ERASE_WRITE_STEP;

/**************************************
 * MEDIAFLASH Driver Hardware Instance Object
 **************************************/
typedef struct
{
    /* The module index associated with the object*/
    MEDIAFLASH_MODULE_ID moduleId;

    /* Object Index */
    SYS_MODULE_INDEX objIndex;

    /* The buffer Q for the write operations */
    DRV_MEDIAFLASH_BUFFER_OBJECT * writeEraseQ;

    /* The status of the driver */
    SYS_STATUS status;

    /* Flag to indicate in use  */
    bool inUse;

    /* Flag to indicate that SAMPLE is used in exclusive access mode */
    bool isExclusive;

    /* Number of clients connected to the hardware instance */
    uint8_t numClients;

    /* Interrupt Source for TX Interrupt */
    INT_SOURCE interruptSource;

    /* Interrupt status flag*/
    bool intStatus;

    /* Erase page buffer */
    uint8_t * eraseBuffer;

    /* Current write buffer address in case of
     * erase and write operation */
    uint32_t eraseWriteStartAddress;

    /* No of erase and write blocks pending */
    uint32_t    nRowsPending;

    /* Blocks overlayed in this page */
    uint8_t * appDataMemory;

    /* Erase Write Step */
    DRV_MEDIAFLASH_ERASE_WRITE_STEP eraseWriteStep;

    /* Block start address */
    uint32_t blockStartAddress;

} DRV_MEDIAFLASH_OBJECT;

/**************************************
 * MEDIAFLASH Driver Client 
 **************************************/
typedef struct _DRV_MEDIAFLASH_CLIENT_OBJ_STRUCT
{
    /* The hardware instance object associate with the client */
    void * driverObj;

    /* Status of the client object */
    SYS_STATUS sysStatus;

    /* The intent with which the client was opened */
    DRV_IO_INTENT intent;

    /* Flag to indicate in use */
    bool inUse;

    /* Client specific event handler */
    DRV_MEDIAFLASH_EVENT_HANDLER  eventHandler;

    /* Client specific context */
    uintptr_t context;

} DRV_MEDIAFLASH_CLIENT_OBJECT;

/****************************************
 * Local functions
 *****************************************/
DRV_MEDIAFLASH_CLIENT_OBJECT * _DRV_MEDIAFLASH_ClientHandleValidate(DRV_HANDLE handle);
void  _DRV_MEDIAFLASH_EraseBufferObjProcess(DRV_MEDIAFLASH_OBJECT * dObj, DRV_MEDIAFLASH_BUFFER_OBJECT * bufferObj);
DRV_MEDIAFLASH_COMMAND_HANDLE _DRV_MEDIAFLASH_BlockOperation (DRV_HANDLE handle,uint8_t * sourceBuffer, uint32_t blockStart,
                                               uint32_t nBlock, DRV_MEDIAFLASH_BUFFER_FLAGS flag,
                                               uint32_t blockSize);
extern DRV_MEDIAFLASH_BUFFER_OBJECT gDrvMEDIAFLASHBufferObject[];
extern uint16_t gDrvMEDIAFLASHBufferToken;

#endif //#ifndef _DRV_MEDIAFLASH_LOCAL_H

/*******************************************************************************
 End of File
*/
