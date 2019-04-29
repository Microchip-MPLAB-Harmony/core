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
// <editor-fold defaultstate="collapsed" desc="DRV_USART Instance 1 Initialization Data">

static DRV_USART_CLIENT_OBJ drvUSART1ClientObjPool[DRV_USART_CLIENTS_NUMBER_IDX1];

/* USART transmit/receive transfer objects pool */
static DRV_USART_BUFFER_OBJ drvUSART1BufferObjPool[DRV_USART_QUEUE_SIZE_IDX1];

const DRV_USART_PLIB_INTERFACE drvUsart1PlibAPI = {
    .readCallbackRegister = (DRV_USART_PLIB_READ_CALLBACK_REG)SERCOM0_USART_ReadCallbackRegister,
    .read = (DRV_USART_PLIB_READ)SERCOM0_USART_Read,
    .readIsBusy = (DRV_USART_PLIB_READ_IS_BUSY)SERCOM0_USART_ReadIsBusy,
    .readCountGet = (DRV_USART_PLIB_READ_COUNT_GET)SERCOM0_USART_ReadCountGet,
    .writeCallbackRegister = (DRV_USART_PLIB_WRITE_CALLBACK_REG)SERCOM0_USART_WriteCallbackRegister,
    .write = (DRV_USART_PLIB_WRITE)SERCOM0_USART_Write,
    .writeIsBusy = (DRV_USART_PLIB_WRITE_IS_BUSY)SERCOM0_USART_WriteIsBusy,
    .writeCountGet = (DRV_USART_PLIB_WRITE_COUNT_GET)SERCOM0_USART_WriteCountGet,
    .errorGet = (DRV_USART_PLIB_ERROR_GET)SERCOM0_USART_ErrorGet,
    .serialSetup = (DRV_USART_PLIB_SERIAL_SETUP)SERCOM0_USART_SerialSetup
};

const uint32_t drvUsart1remapDataWidth[] = { 0x5, 0x6, 0x7, 0x0, 0x1 };
const uint32_t drvUsart1remapParity[] = { 0x2, 0x0, 0x80000, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF };
const uint32_t drvUsart1remapStopBits[] = { 0x0, 0xFFFFFFFF, 0x40 };
const uint32_t drvUsart1remapError[] = { 0x4, 0x0, 0x2 };

const DRV_USART_INTERRUPT_SOURCES drvUSART1InterruptSources =
{
    /* Peripheral has more than one interrupt vector */
    .isSingleIntSrc                        = false,

    /* Peripheral interrupt lines */
    .intSources.multi.usartTxCompleteInt   = SERCOM0_1_IRQn,
    .intSources.multi.usartTxReadyInt      = SERCOM0_0_IRQn,
    .intSources.multi.usartRxCompleteInt   = SERCOM0_2_IRQn,
    .intSources.multi.usartErrorInt        = SERCOM0_OTHER_IRQn,
};

const DRV_USART_INIT drvUsart1InitData =
{
    .usartPlib = &drvUsart1PlibAPI,

    /* USART Number of clients */
    .numClients = DRV_USART_CLIENTS_NUMBER_IDX1,

    /* USART Client Objects Pool */
    .clientObjPool = (uintptr_t)&drvUSART1ClientObjPool[0],

    .dmaChannelTransmit = SYS_DMA_CHANNEL_NONE,

    .dmaChannelReceive = SYS_DMA_CHANNEL_NONE,

    /* Combined size of transmit and receive buffer objects */
    .bufferObjPoolSize = DRV_USART_QUEUE_SIZE_IDX1,

    /* USART transmit and receive buffer buffer objects pool */
    .bufferObjPool = (uintptr_t)&drvUSART1BufferObjPool[0],

    .interruptSources = &drvUSART1InterruptSources,

    .remapDataWidth = drvUsart1remapDataWidth,

    .remapParity = drvUsart1remapParity,

    .remapStopBits = drvUsart1remapStopBits,

    .remapError = drvUsart1remapError,
};

// </editor-fold>
// <editor-fold defaultstate="collapsed" desc="DRV_USART Instance 0 Initialization Data">

static DRV_USART_CLIENT_OBJ drvUSART0ClientObjPool[DRV_USART_CLIENTS_NUMBER_IDX0];

/* USART transmit/receive transfer objects pool */
static DRV_USART_BUFFER_OBJ drvUSART0BufferObjPool[DRV_USART_QUEUE_SIZE_IDX0];

const DRV_USART_PLIB_INTERFACE drvUsart0PlibAPI = {
    .readCallbackRegister = (DRV_USART_PLIB_READ_CALLBACK_REG)SERCOM2_USART_ReadCallbackRegister,
    .read = (DRV_USART_PLIB_READ)SERCOM2_USART_Read,
    .readIsBusy = (DRV_USART_PLIB_READ_IS_BUSY)SERCOM2_USART_ReadIsBusy,
    .readCountGet = (DRV_USART_PLIB_READ_COUNT_GET)SERCOM2_USART_ReadCountGet,
    .writeCallbackRegister = (DRV_USART_PLIB_WRITE_CALLBACK_REG)SERCOM2_USART_WriteCallbackRegister,
    .write = (DRV_USART_PLIB_WRITE)SERCOM2_USART_Write,
    .writeIsBusy = (DRV_USART_PLIB_WRITE_IS_BUSY)SERCOM2_USART_WriteIsBusy,
    .writeCountGet = (DRV_USART_PLIB_WRITE_COUNT_GET)SERCOM2_USART_WriteCountGet,
    .errorGet = (DRV_USART_PLIB_ERROR_GET)SERCOM2_USART_ErrorGet,
    .serialSetup = (DRV_USART_PLIB_SERIAL_SETUP)SERCOM2_USART_SerialSetup
};

const uint32_t drvUsart0remapDataWidth[] = { 0x5, 0x6, 0x7, 0x0, 0x1 };
const uint32_t drvUsart0remapParity[] = { 0x2, 0x0, 0x80000, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF };
const uint32_t drvUsart0remapStopBits[] = { 0x0, 0xFFFFFFFF, 0x40 };
const uint32_t drvUsart0remapError[] = { 0x4, 0x0, 0x2 };

const DRV_USART_INTERRUPT_SOURCES drvUSART0InterruptSources =
{
    /* Peripheral has more than one interrupt vector */
    .isSingleIntSrc                        = false,

    /* Peripheral interrupt lines */
    .intSources.multi.usartTxCompleteInt   = SERCOM2_1_IRQn,
    .intSources.multi.usartTxReadyInt      = SERCOM2_0_IRQn,
    .intSources.multi.usartRxCompleteInt   = SERCOM2_2_IRQn,
    .intSources.multi.usartErrorInt        = SERCOM2_OTHER_IRQn,
};

const DRV_USART_INIT drvUsart0InitData =
{
    .usartPlib = &drvUsart0PlibAPI,

    /* USART Number of clients */
    .numClients = DRV_USART_CLIENTS_NUMBER_IDX0,

    /* USART Client Objects Pool */
    .clientObjPool = (uintptr_t)&drvUSART0ClientObjPool[0],

    .dmaChannelTransmit = SYS_DMA_CHANNEL_NONE,

    .dmaChannelReceive = SYS_DMA_CHANNEL_NONE,

    /* Combined size of transmit and receive buffer objects */
    .bufferObjPoolSize = DRV_USART_QUEUE_SIZE_IDX0,

    /* USART transmit and receive buffer buffer objects pool */
    .bufferObjPool = (uintptr_t)&drvUSART0BufferObjPool[0],

    .interruptSources = &drvUSART0InterruptSources,

    .remapDataWidth = drvUsart0remapDataWidth,

    .remapParity = drvUsart0remapParity,

    .remapStopBits = drvUsart0remapStopBits,

    .remapError = drvUsart0remapError,
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


    SERCOM2_USART_Initialize();

	BSP_Initialize();
    EVSYS_Initialize();

    SERCOM0_USART_Initialize();


    sysObj.drvUsart1 = DRV_USART_Initialize(DRV_USART_INDEX_1, (SYS_MODULE_INIT *)&drvUsart1InitData);

    sysObj.drvUsart0 = DRV_USART_Initialize(DRV_USART_INDEX_0, (SYS_MODULE_INIT *)&drvUsart0InitData);




    APP1_Initialize();
    APP2_Initialize();


    NVIC_Initialize();

}


/*******************************************************************************
 End of File
*/
