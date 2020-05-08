/*******************************************************************************
  System Initialization File

  File Name:
    initialization.c

  Summary:
    This file contains source code necessary to initialize the system.

  Description:
    This file contains source code necessary to initialize the system.  It
    implements the "SYS_Initialize" function, defines the configuration bits,
    and allocates any necessary global system resources,
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

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
#include "configuration.h"
#include "definitions.h"
#include "device.h"



// ****************************************************************************
// ****************************************************************************
// Section: Configuration Bits
// ****************************************************************************
// ****************************************************************************
#pragma config BOD33_DIS = SET
#pragma config BOD33USERLEVEL = 0x1c
#pragma config BOD33_ACTION = RESET
#pragma config BOD33_HYST = 0x2
#pragma config NVMCTRL_BOOTPROT = 0
#pragma config NVMCTRL_SEESBLK = 0x0
#pragma config NVMCTRL_SEEPSZ = 0x0
#pragma config RAMECC_ECCDIS = SET
#pragma config WDT_ENABLE = CLEAR
#pragma config WDT_ALWAYSON = CLEAR
#pragma config WDT_PER = CYC8192
#pragma config WDT_WINDOW = CYC8192
#pragma config WDT_EWOFFSET = CYC8192
#pragma config WDT_WEN = CLEAR
#pragma config NVMCTRL_REGION_LOCKS = 0xffffffff




// *****************************************************************************
// *****************************************************************************
// Section: Driver Initialization Data
// *****************************************************************************
// *****************************************************************************
// <editor-fold defaultstate="collapsed" desc="DRV_MEMORY Instance 0 Initialization Data">


static DRV_MEMORY_CLIENT_OBJECT gDrvMemory0ClientObject[DRV_MEMORY_CLIENTS_NUMBER_IDX0];

static DRV_MEMORY_BUFFER_OBJECT gDrvMemory0BufferObject[DRV_MEMORY_BUFFER_QUEUE_SIZE_IDX0];

const DRV_MEMORY_DEVICE_INTERFACE drvMemory0DeviceAPI = {
    .Open               = DRV_AT24_Open,
    .Close              = DRV_AT24_Close,
    .Status             = DRV_AT24_Status,
    .SectorErase        = NULL,
    .Read               = DRV_AT24_Read,
    .PageWrite          = DRV_AT24_PageWrite,
    .EventHandlerSet    = NULL,
    .GeometryGet        = (DRV_MEMORY_DEVICE_GEOMETRY_GET)DRV_AT24_GeometryGet,
    .TransferStatusGet  = (DRV_MEMORY_DEVICE_TRANSFER_STATUS_GET)DRV_AT24_TransferStatusGet
};

const DRV_MEMORY_INIT drvMemory0InitData =
{
    .memDevIndex                = DRV_AT24_INDEX,
    .memoryDevice               = &drvMemory0DeviceAPI,
    .isMemDevInterruptEnabled   = false,
    .isFsEnabled                = true,
    .deviceMediaType            = (uint8_t)SYS_FS_MEDIA_TYPE_SPIFLASH,
    .ewBuffer                   = NULL,
    .clientObjPool              = (uintptr_t)&gDrvMemory0ClientObject[0],
    .bufferObj                  = (uintptr_t)&gDrvMemory0BufferObject[0],
    .queueSize                  = DRV_MEMORY_BUFFER_QUEUE_SIZE_IDX0,
    .nClientsMax                = DRV_MEMORY_CLIENTS_NUMBER_IDX0
};

// </editor-fold>
// <editor-fold defaultstate="collapsed" desc="DRV_AT24 Initialization Data">

/* I2C PLIB Interface Initialization for AT24 Driver */
const DRV_AT24_PLIB_INTERFACE drvAT24PlibAPI = {

    /* I2C PLIB WriteRead function */
    .writeRead = (DRV_AT24_PLIB_WRITE_READ)SERCOM7_I2C_WriteRead,

    /* I2C PLIB Write function */
    .write = (DRV_AT24_PLIB_WRITE)SERCOM7_I2C_Write,

    /* I2C PLIB Read function */
    .read = (DRV_AT24_PLIB_READ)SERCOM7_I2C_Read,

    /* I2C PLIB Transfer Status function */
    .isBusy = (DRV_AT24_PLIB_IS_BUSY)SERCOM7_I2C_IsBusy,

    /* I2C PLIB Error Status function */
    .errorGet = (DRV_AT24_PLIB_ERROR_GET)SERCOM7_I2C_ErrorGet,

    /* I2C PLIB Callback Register */
    .callbackRegister = (DRV_AT24_PLIB_CALLBACK_REGISTER)SERCOM7_I2C_CallbackRegister,
};

/* AT24 Driver Initialization Data */
const DRV_AT24_INIT drvAT24InitData =
{
    /* I2C PLIB API  interface*/
    .i2cPlib = &drvAT24PlibAPI,

    /* 7-bit I2C Slave address */
    .slaveAddress = 0x54,

    /* EEPROM Page Size in bytes */
    .pageSize = DRV_AT24_EEPROM_PAGE_SIZE,

    /* Total size of the EEPROM in bytes */
    .flashSize = DRV_AT24_EEPROM_FLASH_SIZE,

    /* AT24 Number of clients */
    .numClients = DRV_AT24_CLIENTS_NUMBER_IDX,

    .blockStartAddress =    0x0,
};

// </editor-fold>


// *****************************************************************************
// *****************************************************************************
// Section: System Data
// *****************************************************************************
// *****************************************************************************
/* Structure to hold the object handles for the modules in the system. */
SYSTEM_OBJECTS sysObj;

// *****************************************************************************
// *****************************************************************************
// Section: Library/Stack Initialization Data
// *****************************************************************************
// *****************************************************************************
// <editor-fold defaultstate="collapsed" desc="File System Initialization Data">


const SYS_FS_MEDIA_MOUNT_DATA sysfsMountTable[SYS_FS_VOLUME_NUMBER] =
{
    {NULL}
};

const SYS_FS_FUNCTIONS FatFsFunctions =
{
    .mount             = FATFS_mount,
    .unmount           = FATFS_unmount,
    .open              = FATFS_open,
    .read              = FATFS_read,
    .close             = FATFS_close,
    .seek              = FATFS_lseek,
    .fstat             = FATFS_stat,
    .getlabel          = FATFS_getlabel,
    .currWD            = FATFS_getcwd,
    .getstrn           = FATFS_gets,
    .openDir           = FATFS_opendir,
    .readDir           = FATFS_readdir,
    .closeDir          = FATFS_closedir,
    .chdir             = FATFS_chdir,
    .chdrive           = FATFS_chdrive,
    .write             = FATFS_write,
    .tell              = FATFS_tell,
    .eof               = FATFS_eof,
    .size              = FATFS_size,
    .mkdir             = FATFS_mkdir,
    .remove            = FATFS_unlink,
    .setlabel          = FATFS_setlabel,
    .truncate          = FATFS_truncate,
    .chmode            = FATFS_chmod,
    .chtime            = FATFS_utime,
    .rename            = FATFS_rename,
    .sync              = FATFS_sync,
    .putchr            = FATFS_putc,
    .putstrn           = FATFS_puts,
    .formattedprint    = FATFS_printf,
    .testerror         = FATFS_error,
    .formatDisk        = (FORMAT_DISK)FATFS_mkfs,
    .partitionDisk     = FATFS_fdisk,
    .getCluster        = FATFS_getclusters
};


const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
{
    {
        .nativeFileSystemType = FAT,
        .nativeFileSystemFunctions = &FatFsFunctions
    }
};

// </editor-fold>



// *****************************************************************************
// *****************************************************************************
// Section: System Initialization
// *****************************************************************************
// *****************************************************************************



// *****************************************************************************
// *****************************************************************************
// Section: Local initialization functions
// *****************************************************************************
// *****************************************************************************



/*******************************************************************************
  Function:
    void SYS_Initialize ( void *data )

  Summary:
    Initializes the board, services, drivers, application and other modules.

  Remarks:
 */

void SYS_Initialize ( void* data )
{
    NVMCTRL_Initialize( );

  
    PORT_Initialize();

    CLOCK_Initialize();




	BSP_Initialize();
    EVSYS_Initialize();

    SERCOM7_I2C_Initialize();


    sysObj.drvMemory0 = DRV_MEMORY_Initialize((SYS_MODULE_INDEX)DRV_MEMORY_INDEX_0, (SYS_MODULE_INIT *)&drvMemory0InitData);

    sysObj.drvAT24 = DRV_AT24_Initialize(DRV_AT24_INDEX, (SYS_MODULE_INIT *)&drvAT24InitData);



    /*** File System Service Initialization Code ***/
    SYS_FS_Initialize( (const void *) sysFSInit );


    APP_Initialize();


    NVIC_Initialize();

}


/*******************************************************************************
 End of File
*/
