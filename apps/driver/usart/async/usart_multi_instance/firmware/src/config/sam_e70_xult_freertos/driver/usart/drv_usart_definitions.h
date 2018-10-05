/*******************************************************************************
  USART Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_usart_definitions.h

  Summary:
    USART Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the USART
    driver's system interface.
*******************************************************************************/

//DOM-IGNORE-BEGIN
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
//DOM-IGNORE-END

#ifndef DRV_USART_DEFINITIONS_H
#define DRV_USART_DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************
#include "system/int/sys_int.h"
#include "system/dma/sys_dma.h"

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

// *****************************************************************************
/* USART Driver Errors Declaration */

typedef enum _DRV_USART_ERROR
{
    DRV_USART_ERROR_NONE = 0,

    DRV_USART_ERROR_OVERRUN = 1,

    DRV_USART_ERROR_PARITY = 2,

    DRV_USART_ERROR_FRAMING = 3

}_DRV_USART_ERROR;

// *****************************************************************************
/* USART Serial Setup */

typedef enum
{
    DRV_USART_DATA_5_BIT = 0,
    DRV_USART_DATA_6_BIT = 1,
    DRV_USART_DATA_7_BIT = 2,
    DRV_USART_DATA_8_BIT = 3,
    DRV_USART_DATA_9_BIT = 4,

    /* Force the compiler to reserve 32-bit memory space for each enum */
    DRV_USART_DATA_BIT_INVALID = 0xFFFFFFFF

} DRV_USART_DATA_BIT;

typedef enum
{
    DRV_USART_PARITY_NONE = 0,
    DRV_USART_PARITY_EVEN = 1,
    DRV_USART_PARITY_ODD = 2,
    DRV_USART_PARITY_MARK = 3,
    DRV_USART_PARITY_SPACE = 4,
    DRV_USART_PARITY_MULTIDROP = 5,

    /* Force the compiler to reserve 32-bit memory space for each enum */
    DRV_USART_PARITY_INVALID = 0xFFFFFFFF

} DRV_USART_PARITY;

typedef enum
{
    DRV_USART_STOP_1_BIT = 0,
    DRV_USART_STOP_1_5_BIT = 1,
    DRV_USART_STOP_2_BIT = 2,

    /* Force the compiler to reserve 32-bit memory space for each enum */
    DRV_USART_STOP_BIT_INVALID = 0xFFFFFFFF

} DRV_USART_STOP_BIT;

typedef struct _DRV_USART_SERIAL_SETUP
{
    uint32_t baudRate;

    DRV_USART_PARITY parity;

    DRV_USART_DATA_BIT dataWidth;

    DRV_USART_STOP_BIT stopBits;

} _DRV_USART_SERIAL_SETUP;

// *****************************************************************************
/* USART PLIB API Set needed by the driver */

typedef bool(*USART_ReadCallbackRegister)(void * callback, uintptr_t context);
typedef size_t(*USART_Read)(void *buffer, const size_t size);
typedef bool(*USART_ReadIsBusy)(void);
typedef size_t(*USART_ReadCountGet)(void);

typedef bool(*USART_WriteCallbackRegister)(void * callback, uintptr_t context);
typedef size_t(*USART_Write)(void *buffer, const size_t size);
typedef bool(*USART_WriteIsBusy)(void);
typedef size_t(*USART_WriteCountGet)(void);

typedef _DRV_USART_ERROR(*USART_ErrorGet)(void);
typedef bool(*USART_SerialSetup)(_DRV_USART_SERIAL_SETUP* setup, uint32_t clkSrc);

typedef struct
{
    USART_ReadCallbackRegister readCallbackRegister;
    USART_Read read;
    USART_ReadIsBusy readIsBusy;
    USART_ReadCountGet readCountGet;

    USART_WriteCallbackRegister writeCallbackRegister;
    USART_Write write;
    USART_WriteIsBusy writeIsBusy;
    USART_WriteCountGet writeCountGet;

    USART_ErrorGet errorGet;
    USART_SerialSetup serialSetup;

} USART_PLIB_API;


// *****************************************************************************
/* USART Driver Initialization Data Declaration */

struct _DRV_USART_INIT
{
    /* Identifies the PLIB API set to be used by the driver to access the
     * peripheral. */
    USART_PLIB_API *usartPlib;

    /* This is the USART transmit DMA channel. */
    SYS_DMA_CHANNEL dmaChannelTransmit;

    /* This is the USART receive DMA channel. */
    SYS_DMA_CHANNEL dmaChannelReceive;

    /* This is the USART transmit register address. Used for DMA operation. */
    void * usartTransmitAddress;

    /* This is the USART receive register address. Used for DMA operation. */
    void * usartReceiveAddress;

    uint32_t *remapDataWidth;
    uint32_t *remapParity;
    uint32_t *remapStopBits;
    uint32_t *remapError;


    /* This is the receive buffer queue size. This is the maximum
     * number of read requests that driver will queue. This can be updated
     * through DRV_USART_RCV_QUEUE_SIZE_IDXn macro in configuration.h */
    unsigned int queueSizeReceive;

    /* This is the transmit buffer queue size. This is the maximum
     * number of write requests that driver will queue. This can be updated
     * through DRV_USART_XMIT_QUEUE_SIZE_IDXn macro in configuration.h */
    unsigned int queueSizeTransmit;

    /* Interrupt source ID for the USART interrupt. */
    INT_SOURCE interruptUSART;

    /* This is the DMA channel interrupt source. */
    INT_SOURCE interruptDMA;

};



//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END


#endif // #ifndef DRV_USART_DEFINITIONS_H
