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



// *****************************************************************************
// *****************************************************************************
// Section: Driver Initialization Data
// *****************************************************************************
// *****************************************************************************
// <editor-fold defaultstate="collapsed" desc="DRV_SDMMC Instance 0 Initialization Data">

/* SDMMC Client Objects Pool */
static DRV_SDMMC_CLIENT_OBJ drvSDMMC0ClientObjPool[DRV_SDMMC_CLIENTS_NUMBER_IDX0];

/* SDMMC Transfer Objects Pool */
static DRV_SDMMC_BUFFER_OBJ drvSDMMC0BufferObjPool[DRV_SDMMC_QUEUE_SIZE_IDX0];


const DRV_SDMMC_PLIB_API drvSDMMC0PlibAPI = {
    .sdhostCallbackRegister = (DRV_SDMMC_PLIB_CALLBACK_REGISTER)SDMMC0_CallbackRegister,
    .sdhostInitModule = (DRV_SDMMC_PLIB_INIT_MODULE)SDMMC0_ModuleInit,
    .sdhostSetClock  = (DRV_SDMMC_PLIB_SET_CLOCK)SDMMC0_ClockSet,
    .sdhostIsCmdLineBusy = (DRV_SDMMC_PLIB_IS_CMD_LINE_BUSY)SDMMC0_IsCmdLineBusy,
    .sdhostIsDatLineBusy = (DRV_SDMMC_PLIB_IS_DATA_LINE_BUSY)SDMMC0_IsDatLineBusy,
    .sdhostSendCommand = (DRV_SDMMC_PLIB_SEND_COMMAND)SDMMC0_CommandSend,
    .sdhostReadResponse = (DRV_SDMMC_PLIB_READ_RESPONSE)SDMMC0_ResponseRead,
    .sdhostSetBlockCount = (DRV_SDMMC_PLIB_SET_BLOCK_COUNT)SDMMC0_BlockCountSet,
    .sdhostSetBlockSize = (DRV_SDMMC_PLIB_SET_BLOCK_SIZE)SDMMC0_BlockSizeSet,
    .sdhostSetBusWidth = (DRV_SDMMC_PLIB_SET_BUS_WIDTH)SDMMC0_BusWidthSet,
    .sdhostSetSpeedMode = (DRV_SDMMC_PLIB_SET_SPEED_MODE)SDMMC0_SpeedModeSet,
    .sdhostSetupDma = (DRV_SDMMC_PLIB_SETUP_DMA)SDMMC0_DmaSetup,
    .sdhostGetCommandError = (DRV_SDMMC_PLIB_GET_COMMAND_ERROR)SDMMC0_CommandErrorGet,
    .sdhostGetDataError = (DRV_SDMMC_PLIB_GET_DATA_ERROR)SDMMC0_DataErrorGet,
    .sdhostClockEnable = (DRV_SDMMC_PLIB_CLOCK_ENABLE)SDMMC0_ClockEnable,
    .sdhostResetError = (DRV_SDMMC_PLIB_RESET_ERROR)SDMMC0_ErrorReset,
    .sdhostIsCardAttached = (DRV_SDMMC_PLIB_IS_CARD_ATTACHED)NULL,
    .sdhostIsWriteProtected = (DRV_SDMMC_PLIB_IS_WRITE_PROTECTED)NULL,
};

/*** SDMMC Driver Initialization Data ***/
const DRV_SDMMC_INIT drvSDMMC0InitData =
{
    .sdmmcPlib                      = &drvSDMMC0PlibAPI,
    .bufferObjPool                  = (uintptr_t)&drvSDMMC0BufferObjPool[0],
    .bufferObjPoolSize              = DRV_SDMMC_QUEUE_SIZE_IDX0,
    .clientObjPool                  = (uintptr_t)&drvSDMMC0ClientObjPool[0],
    .numClients                     = DRV_SDMMC_CLIENTS_NUMBER_IDX0,
    .protocol                       = DRV_SDMMC_PROTOCOL_SUPPORT_IDX0,
    .cardDetectionMethod            = DRV_SDMMC_CARD_DETECTION_METHOD_IDX0,
    .cardDetectionPollingIntervalMs = 100,
    .isWriteProtectCheckEnabled     = false,
    .speedMode                      = DRV_SDMMC_CONFIG_SPEED_MODE_IDX0,
    .busWidth                       = DRV_SDMMC_CONFIG_BUS_WIDTH_IDX0,
    .isFsEnabled                    = false,
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

const SYS_TIME_PLIB_INTERFACE sysTimePlibAPI = {
    .timerCallbackSet = (SYS_TIME_PLIB_CALLBACK_REGISTER)TC0_CH0_TimerCallbackRegister,
    .timerStart = (SYS_TIME_PLIB_START)TC0_CH0_TimerStart,
    .timerStop = (SYS_TIME_PLIB_STOP)TC0_CH0_TimerStop ,
    .timerFrequencyGet = (SYS_TIME_PLIB_FREQUENCY_GET)TC0_CH0_TimerFrequencyGet,
    .timerPeriodSet = (SYS_TIME_PLIB_PERIOD_SET)TC0_CH0_TimerPeriodSet,
    .timerCompareSet = (SYS_TIME_PLIB_COMPARE_SET)TC0_CH0_TimerCompareSet,
    .timerCounterGet = (SYS_TIME_PLIB_COUNTER_GET)TC0_CH0_TimerCounterGet,
};

const SYS_TIME_INIT sysTimeInitData =
{
    .timePlib = &sysTimePlibAPI,
    .hwTimerIntNum = TC0_IRQn,
};

// </editor-fold>



// *****************************************************************************
// *****************************************************************************
// Section: Local initialization functions
// *****************************************************************************
// *****************************************************************************
/*******************************************************************************
  Function:
    void SYSC_Disable ( void )

  Summary:
    Disables ununsed SYSC peripherals

  Remarks:
 */
static void SYSC_Disable( void )
{
    //save context and disable write protection
    uint32_t sysc_wpmr = SYSCWP_REGS->SYSCWP_SYSC_WPMR &
      (SYSCWP_SYSC_WPMR_WPEN_Msk | SYSCWP_SYSC_WPMR_WPITEN_Msk);
    SYSCWP_REGS->SYSCWP_SYSC_WPMR = SYSCWP_SYSC_WPMR_WPKEY_PASSWD &
                                    ~(SYSCWP_SYSC_WPMR_WPITEN_Msk |
                                    SYSCWP_SYSC_WPMR_WPITEN_Msk);


    /* ----------------------------   RTC  -------------------------------*/
    //Disable interrupts
    RTC_REGS->RTC_IDR = RTC_IDR_Msk;

    //Clear interrupt status
    RTC_REGS->RTC_SCCR = RTC_SCCR_Msk;

    /* ----------------------------   RTT  -------------------------------*/
    //Disable Timer and interrupt
    uint32_t rtt_mr = RTT_REGS->RTT_MR;
    RTT_REGS->RTT_MR = rtt_mr & ~(RTT_MR_RTTDIS_Msk | RTT_MR_RTTINCIEN_Msk);

    //Clear status
    RTT_REGS->RTT_SR;

    /* ----------------------------   RSTC  ------------------------------*/
    // Disable interrupt
    uint32_t rstc_mr = RSTC_REGS->RSTC_MR & (RSTC_MR_ENGCLR_Msk |
                                             RSTC_MR_ERSTL_Msk |
                                             RSTC_MR_URSTIEN_Msk |
                                             RSTC_MR_URSTASYNC_Msk |
                                             RSTC_MR_SCKSW_Msk |
                                             RSTC_MR_URSTEN_Msk);
    rstc_mr = rstc_mr & (~RSTC_MR_URSTIEN_Msk);
    RSTC_REGS->RSTC_MR = RSTC_MR_KEY_PASSWD | rstc_mr;

    /* ----------------------------   PIT  -------------------------------*/
    //Disable Timer and interrupt
    uint32_t pit_mr = PIT_REGS->PIT_MR & PIT_MR_PIV_Msk;
    PIT_REGS->PIT_MR = pit_mr & ~(PIT_MR_PITEN_Msk | PIT_MR_PITIEN_Msk);

    //Clear status
    PIT_REGS->PIT_SR;

   //Context restore SYSC write protect registers
   SYSCWP_REGS->SYSCWP_SYSC_WPMR = (SYSCWP_SYSC_WPMR_WPKEY_PASSWD | sysc_wpmr);
}




/*******************************************************************************
  Function:
    void SYS_Initialize ( void *data )

  Summary:
    Initializes the board, services, drivers, application and other modules.

  Remarks:
 */

void SYS_Initialize ( void* data )
{
	SYSC_Disable( );

  
    CLK_Initialize();

	PIO_Initialize();



	BSP_Initialize();
    MMU_Initialize();

    INT_Initialize();
    
    /* Disable WDT   */
    WDT_REGS->WDT_MR = WDT_MR_WDDIS_Msk;

	SDMMC0_Initialize();

 
    TC0_CH0_TimerInitialize(); 
     
    


    sysObj.drvSDMMC0 = DRV_SDMMC_Initialize(DRV_SDMMC_INDEX_0,(SYS_MODULE_INIT *)&drvSDMMC0InitData);


    sysObj.sysTime = SYS_TIME_Initialize(SYS_TIME_INDEX_0, (SYS_MODULE_INIT *)&sysTimeInitData);


    APP_Initialize();



}


/*******************************************************************************
 End of File
*/
