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
// <editor-fold defaultstate="collapsed" desc="DRV_SDSPI Instance 0 Initialization Data">

/* SD Card Client Objects Pool */
static DRV_SDSPI_CLIENT_OBJ drvSDSPI0ClientObjPool[DRV_SDSPI_CLIENTS_NUMBER_IDX0];

/* SPI PLIB Interface Initialization for SDSPI Driver */
const DRV_SDSPI_PLIB_INTERFACE drvSDSPI0PlibAPI = {

    /* SPI PLIB WriteRead function */
    .writeRead = (DRV_SDSPI_PLIB_WRITEREAD)SERCOM4_SPI_WriteRead,

    /* SPI PLIB Write function */
    .write = (DRV_SDSPI_PLIB_WRITE)SERCOM4_SPI_Write,

    /* SPI PLIB Read function */
    .read = (DRV_SDSPI_PLIB_READ)SERCOM4_SPI_Read,

    /* SPI PLIB Transfer Status function */
    .isBusy = (DRV_SDSPI_PLIB_IS_BUSY)SERCOM4_SPI_IsBusy,

    .transferSetup = (DRV_SDSPI_PLIB_SETUP)SERCOM4_SPI_TransferSetup,

    /* SPI PLIB Callback Register */
    .callbackRegister = (DRV_SDSPI_PLIB_CALLBACK_REGISTER)SERCOM4_SPI_CallbackRegister,
};

const uint32_t drvSDSPI0remapDataBits[]= { 0x0, 0x1, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF };
const uint32_t drvSDSPI0remapClockPolarity[] = { 0x0, 0x20000000 };
const uint32_t drvSDSPI0remapClockPhase[] = { 0x10000000, 0x0 };
/* SDSPI Driver Initialization Data */
const DRV_SDSPI_INIT drvSDSPI0InitData =
{
    /* SD Card SPI PLIB API interface*/
    .spiPlib                = &drvSDSPI0PlibAPI,

    .remapDataBits          = drvSDSPI0remapDataBits,

    .remapClockPolarity     = drvSDSPI0remapClockPolarity,

    .remapClockPhase        = drvSDSPI0remapClockPhase,

    /* SDSPI Number of clients */
    .numClients             = DRV_SDSPI_CLIENTS_NUMBER_IDX0,

    /* SDSPI Client Objects Pool */
    .clientObjPool          = (uintptr_t)&drvSDSPI0ClientObjPool[0],

    .chipSelectPin          = DRV_SDSPI_CHIP_SELECT_PIN_IDX0,

    .sdcardSpeedHz          = DRV_SDSPI_SPEED_HZ_IDX0,

    .writeProtectPin        = SYS_PORT_PIN_NONE,

    .isFsEnabled            = true,

    /* DMA Channel for Transmit */
    .txDMAChannel           = DRV_SDSPI_XMIT_DMA_CH_IDX0,

    /* DMA Channel for Receive */
    .rxDMAChannel           = DRV_SDSPI_RCV_DMA_CH_IDX0,

    /* SPI Transmit Register */
    .txAddress              = (void *)&(SERCOM4_REGS->SPIM.SERCOM_DATA),

    /* SPI Receive Register */
    .rxAddress              = (void *)&(SERCOM4_REGS->SPIM.SERCOM_DATA),
};

// </editor-fold>

// <editor-fold defaultstate="collapsed" desc="DRV_MEMORY Instance 0 Initialization Data">

static uint8_t gDrvMemory0EraseBuffer[NVMCTRL_ERASE_BUFFER_SIZE] CACHE_ALIGN;

static DRV_MEMORY_CLIENT_OBJECT gDrvMemory0ClientObject[DRV_MEMORY_CLIENTS_NUMBER_IDX0];


const DRV_MEMORY_DEVICE_INTERFACE drvMemory0DeviceAPI = {
    .Open               = DRV_NVMCTRL_Open,
    .Close              = DRV_NVMCTRL_Close,
    .Status             = DRV_NVMCTRL_Status,
    .SectorErase        = DRV_NVMCTRL_SectorErase,
    .Read               = DRV_NVMCTRL_Read,
    .PageWrite          = DRV_NVMCTRL_PageWrite,
    .EventHandlerSet    = NULL,
    .GeometryGet        = (DRV_MEMORY_DEVICE_GEOMETRY_GET)DRV_NVMCTRL_GeometryGet,
    .TransferStatusGet  = (DRV_MEMORY_DEVICE_TRANSFER_STATUS_GET)DRV_NVMCTRL_TransferStatusGet
};

const DRV_MEMORY_INIT drvMemory0InitData =
{
    .memDevIndex                = 0,
    .memoryDevice               = &drvMemory0DeviceAPI,
    .isMemDevInterruptEnabled   = false,
    .memDevStatusPollUs         = 500,
    .isFsEnabled                = true,
    .deviceMediaType            = (uint8_t)SYS_FS_MEDIA_TYPE_NVM,
    .ewBuffer                   = &gDrvMemory0EraseBuffer[0],
    .clientObjPool              = (uintptr_t)&gDrvMemory0ClientObject[0],
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
/*** File System Initialization Data ***/


const SYS_FS_MEDIA_MOUNT_DATA sysfsMountTable[SYS_FS_VOLUME_NUMBER] = 
{
	{NULL}
};




const SYS_FS_REGISTRATION_TABLE sysFSInit [ SYS_FS_MAX_FILE_SYSTEM_TYPE ] =
{
    {
        .nativeFileSystemType = FAT,
        .nativeFileSystemFunctions = &FatFsFunctions
    }
};




// *****************************************************************************
// *****************************************************************************
// Section: System Initialization
// *****************************************************************************
// *****************************************************************************
// <editor-fold defaultstate="collapsed" desc="SYS_TIME Initialization Data">

const SYS_TIME_PLIB_INTERFACE sysTimePlibAPI = {
    .timerCallbackSet = (SYS_TIME_PLIB_CALLBACK_REGISTER)TC0_TimerCallbackRegister,
    .timerCounterGet = (SYS_TIME_PLIB_COUNTER_GET)TC0_Timer16bitCounterGet,
    .timerPeriodSet = (SYS_TIME_PLIB_PERIOD_SET)TC0_Timer16bitPeriodSet,
    .timerFrequencyGet = (SYS_TIME_PLIB_FREQUENCY_GET)TC0_TimerFrequencyGet,
    .timerCompareSet = (SYS_TIME_PLIB_COMPARE_SET)TC0_Timer16bitCompareSet,
    .timerStart = (SYS_TIME_PLIB_START)TC0_TimerStart,
    .timerStop = (SYS_TIME_PLIB_STOP)TC0_TimerStop
};

const SYS_TIME_INIT sysTimeInitData =
{
    .timePlib = &sysTimePlibAPI,
    .hwTimerIntNum = TC0_IRQn,
};

// </editor-fold>



/*******************************************************************************
  Function:
    void SYS_Initialize ( void *data )

  Summary:
    Initializes the board, services, drivers, application and other modules.

  Remarks:
 */

void SYS_Initialize ( void* data )
{
  
    PORT_Initialize();

    CLOCK_Initialize();



    NVMCTRL_Initialize( );

    EVSYS_Initialize();

    DMAC_Initialize();

    SERCOM4_SPI_Initialize();

    TC0_TimerInitialize();

	BSP_Initialize();

    /* Initialize SDSPI0 Driver Instance */
    sysObj.drvSDSPI0 = DRV_SDSPI_Initialize(DRV_SDSPI_INDEX_0, (SYS_MODULE_INIT *)&drvSDSPI0InitData);

    sysObj.drvMemory0 = DRV_MEMORY_Initialize((SYS_MODULE_INDEX)DRV_MEMORY_INDEX_0, (SYS_MODULE_INIT *)&drvMemory0InitData);


    sysObj.sysTime = SYS_TIME_Initialize(SYS_TIME_INDEX_0, (SYS_MODULE_INIT *)&sysTimeInitData);

    /*** File System Service Initialization Code ***/
    SYS_FS_Initialize( (const void *) sysFSInit );


    APP_Initialize();


    NVIC_Initialize();

}


/*******************************************************************************
 End of File
*/
