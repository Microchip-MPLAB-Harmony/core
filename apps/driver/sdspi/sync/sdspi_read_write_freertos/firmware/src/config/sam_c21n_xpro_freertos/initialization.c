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


// ****************************************************************************
// ****************************************************************************
// Section: Configuration Bits
// ****************************************************************************
// ****************************************************************************


// *****************************************************************************
// *****************************************************************************
// Section: Driver Initialization Data
// *****************************************************************************
// *****************************************************************************
// <editor-fold defaultstate="collapsed" desc="DRV_SDSPI Instance 0 Initialization Data">

/* SD Card Client Objects Pool */
DRV_SDSPI_CLIENT_OBJ drvSDSPI0ClientObjPool[DRV_SDSPI_CLIENTS_NUMBER_IDX0] = {0};

/* SPI PLIB Interface Initialization for SDSPI Driver */
DRV_SDSPI_PLIB_INTERFACE drvSDSPI0PlibAPI = {

    /* SPI PLIB WriteRead function */
    .writeRead = (DRV_SDSPI_WRITEREAD)SERCOM1_SPI_WriteRead,

    /* SPI PLIB Write function */
    .write = (DRV_SDSPI_WRITE)SERCOM1_SPI_Write,

    /* SPI PLIB Read function */
    .read = (DRV_SDSPI_READ)SERCOM1_SPI_Read,

    /* SPI PLIB Transfer Status function */
    .isBusy = (DRV_SDSPI_IS_BUSY)SERCOM1_SPI_IsBusy,

    .transferSetup = (DRV_SDSPI_SETUP)SERCOM1_SPI_TransferSetup,

    /* SPI PLIB Callback Register */
    .callbackRegister = (DRV_SDSPI_CALLBACK_REGISTER)SERCOM1_SPI_CallbackRegister,
};

uint32_t drvSDSPI0remapDataBits[]= { 0x0, 0x1, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF };
uint32_t drvSDSPI0remapClockPolarity[] = { 0x0, 0x20000000 };
uint32_t drvSDSPI0remapClockPhase[] = { 0x10000000, 0x0 };
/* SDSPI Driver Initialization Data */
DRV_SDSPI_INIT drvSDSPI0InitData =
{
    /* SD Card SPI PLIB API interface*/
    .spiPlib            = &drvSDSPI0PlibAPI,

    .remapDataBits = drvSDSPI0remapDataBits,

    .remapClockPolarity = drvSDSPI0remapClockPolarity,

    .remapClockPhase = drvSDSPI0remapClockPhase,

    /* SDSPI Number of clients */
    .numClients         = DRV_SDSPI_CLIENTS_NUMBER_IDX0,

    /* SDSPI Client Objects Pool */
    .clientObjPool      = (uintptr_t)&drvSDSPI0ClientObjPool[0],

    .chipSelectPin      = DRV_SDSPI_CHIP_SELECT_PIN_IDX0,

    .sdcardSpeedHz      = DRV_SDSPI_SPEED_HZ_IDX0,

    .writeProtectPin    = SYS_PORT_PIN_NONE,

    .isRegisterWithFS   = DRV_SDSPI_REGISTER_WITH_FS_IDX0,

    /* DMA Channel for Transmit */
    .txDMAChannel = DRV_SDSPI_XMIT_DMA_CH_IDX0,

    /* DMA Channel for Receive */
    .rxDMAChannel  = DRV_SDSPI_RCV_DMA_CH_IDX0,

    /* SPI Transmit Register */
    .txAddress = (void *)&(SERCOM1_REGS->SPI.DATA),

    /* SPI Receive Register */
    .rxAddress  = (void *)&(SERCOM1_REGS->SPI.DATA),
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


// *****************************************************************************
// *****************************************************************************
// Section: System Initialization
// *****************************************************************************
// *****************************************************************************
// <editor-fold defaultstate="collapsed" desc="SYS_TIME Initialization Data">

TIME_PLIB_API sysTimePlibAPI = {
    .timerCallbackSet = (TIME_CallbackSet)TC0_TimerCallbackRegister,
    .timerCounterGet = (TIME_CounterGet)TC0_Timer16bitCounterGet,
     .timerPeriodSet = (TIME_PeriodSet)TC0_Timer16bitPeriodSet,
    .timerFrequencyGet = (TIME_FrequencyGet)TC0_TimerFrequencyGet,
    .timerCompareSet = (TIME_CompareSet)TC0_Timer16bitCompareSet,
    .timerStart = (TIME_Start)TC0_TimerStart,
    .timerStop = (TIME_Stop)TC0_TimerStop
};

SYS_TIME_INIT sysTimeInitData =
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



    NVIC_Initialize();
    DMAC_Initialize();

	BSP_Initialize();
    EVSYS_Initialize();

    SERCOM1_SPI_Initialize();

    TC0_TimerInitialize();


    /* Initialize SDSPI0 Driver Instance */
    sysObj.drvSDSPI0 = DRV_SDSPI_Initialize(DRV_SDSPI_INDEX_0, (SYS_MODULE_INIT *)&drvSDSPI0InitData);

    sysObj.sysTime = SYS_TIME_Initialize(SYS_TIME_INDEX_0, (SYS_MODULE_INIT *)&sysTimeInitData);


    APP_Initialize();


}


/*******************************************************************************
 End of File
*/

