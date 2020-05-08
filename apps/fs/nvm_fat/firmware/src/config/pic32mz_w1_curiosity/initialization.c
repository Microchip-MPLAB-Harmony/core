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




/*** FBCFG0 ***/
#pragma config BUHSWEN =    OFF
#pragma config PCSCMODE =    DUAL
#pragma config BOOTISA =    MIPS32



/*** DEVCFG0 ***/
#pragma config TDOEN =      ON
#pragma config TROEN =     OFF
#pragma config JTAGEN =     OFF
#pragma config FCPRI =      LRSA
#pragma config DMAPRI =    LRSA
#pragma config EXLPRI =    LRSA
#pragma config USBSSEN =     OFF
#pragma config PMULOCK =     OFF
#pragma config PGLOCK =      OFF
#pragma config PMDLOCK =   OFF
#pragma config IOLOCK =  OFF
#pragma config CFGLOCK =   OFF
#pragma config OC_ACLK =  OCMP_TMR2_TMR3
#pragma config IC_ACLK =  ICAP_TMR2_TMR3
#pragma config CANFDDIV =  0
#pragma config PCM =  SFR
#pragma config UPLLHWMD =  OFF
#pragma config SPLLHWMD =   OFF
#pragma config BTPLLHWMD =        OFF
#pragma config ETHPLLHWMD =        OFF
#pragma config FECCCON =         OFF
#pragma config ETHTPSF =         RPSF
#pragma config EPGMCLK =         FRC


/*** DEVCFG1 ***/
#pragma config DEBUG =         EMUC
#pragma config ICESEL =         ICS_PGx2
#pragma config TRCEN =         ON
#pragma config FMIIEN =         OFF
#pragma config ETHEXEREF =         OFF
#pragma config CLASSBDIS =         DISABLE
#pragma config USBIDIO =         ON
#pragma config VBUSIO =         ON
#pragma config HSSPIEN =         OFF
#pragma config SMCLR =      MCLR_NORM
#pragma config USBDMTRIM =      0
#pragma config USBDPTRIM =      0
#pragma config HSUARTEN =    ON
#pragma config WDTPSS =    PSS1



/*** DEVCFG2 ***/
#pragma config DMTINTV =    WIN_63_64
#pragma config POSCMOD =    HS
#pragma config WDTRMCS =    LPRC
#pragma config SOSCSEL =    CRYSTAL
#pragma config WAKE2SPD =    ON
#pragma config CKSWEN =    ON
#pragma config FSCMEN =    ON
#pragma config WDTPS =    PS1
#pragma config WDTSPGM =    STOP
#pragma config WINDIS =    NORMAL
#pragma config WDTEN =    OFF
#pragma config WDTWINSZ =    WINSZ_25
#pragma config DMTCNT =    DMT31
#pragma config DMTEN =    OFF



/*** DEVCFG4 ***/
#pragma config SOSCCFG =    0
#pragma config VBZPBOREN =    ON
#pragma config DSZPBOREN =    ON
#pragma config DSWDTPS =    DSPS1
#pragma config DSWDTOSC =    LPRC
#pragma config DSWDTEN =    OFF
#pragma config DSEN =    OFF
#pragma config SOSCEN =    OFF




// *****************************************************************************
// *****************************************************************************
// Section: Driver Initialization Data
// *****************************************************************************
// *****************************************************************************
// <editor-fold defaultstate="collapsed" desc="DRV_MEMORY Instance 0 Initialization Data">

static uint8_t gDrvMemory0EraseBuffer[NVM_ERASE_BUFFER_SIZE] CACHE_ALIGN;

static DRV_MEMORY_CLIENT_OBJECT gDrvMemory0ClientObject[DRV_MEMORY_CLIENTS_NUMBER_IDX0];

static DRV_MEMORY_BUFFER_OBJECT gDrvMemory0BufferObject[DRV_MEMORY_BUFFER_QUEUE_SIZE_IDX0];

const DRV_MEMORY_DEVICE_INTERFACE drvMemory0DeviceAPI = {
    .Open               = DRV_NVM_Open,
    .Close              = DRV_NVM_Close,
    .Status             = DRV_NVM_Status,
    .SectorErase        = DRV_NVM_SectorErase,
    .Read               = DRV_NVM_Read,
    .PageWrite          = DRV_NVM_PageWrite,
    .EventHandlerSet    = (DRV_MEMORY_DEVICE_EVENT_HANDLER_SET)DRV_NVM_EventHandlerSet,
    .GeometryGet        = (DRV_MEMORY_DEVICE_GEOMETRY_GET)DRV_NVM_GeometryGet,
    .TransferStatusGet  = (DRV_MEMORY_DEVICE_TRANSFER_STATUS_GET)DRV_NVM_TransferStatusGet
};

const DRV_MEMORY_INIT drvMemory0InitData =
{
    .memDevIndex                = 0,
    .memoryDevice               = &drvMemory0DeviceAPI,
    .isMemDevInterruptEnabled   = true,
    .isFsEnabled                = true,
    .deviceMediaType            = (uint8_t)SYS_FS_MEDIA_TYPE_NVM,
    .ewBuffer                   = &gDrvMemory0EraseBuffer[0],
    .clientObjPool              = (uintptr_t)&gDrvMemory0ClientObject[0],
    .bufferObj                  = (uintptr_t)&gDrvMemory0BufferObject[0],
    .queueSize                  = DRV_MEMORY_BUFFER_QUEUE_SIZE_IDX0,
    .nClientsMax                = DRV_MEMORY_CLIENTS_NUMBER_IDX0
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
    /* Start out with interrupts disabled before configuring any modules */
    __builtin_disable_interrupts();

  
    SYS_PMU_MLDO_TRIM();
    CLK_Initialize();
    /* Configure Wait States */
    PRECONbits.PFMWS = 5;



	GPIO_Initialize();

	BSP_Initialize();
    NVM_Initialize();


    sysObj.drvMemory0 = DRV_MEMORY_Initialize((SYS_MODULE_INDEX)DRV_MEMORY_INDEX_0, (SYS_MODULE_INIT *)&drvMemory0InitData);



    /*** File System Service Initialization Code ***/
    SYS_FS_Initialize( (const void *) sysFSInit );


    APP_Initialize();


    EVIC_Initialize();

	/* Enable global interrupts */
    __builtin_enable_interrupts();


}


/*******************************************************************************
 End of File
*/
