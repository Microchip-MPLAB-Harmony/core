/*******************************************************************************
  USART0 PLIB

  Company:
    Microchip Technology Inc.

  File Name:
    plib_usart0.c

  Summary:
    USART0 PLIB Implementation File

  Description:
    None

*******************************************************************************/

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

#include "device.h"
#include "plib_usart0.h"

// *****************************************************************************
// *****************************************************************************
// Section: USART0 Implementation
// *****************************************************************************
// *****************************************************************************

USART_OBJECT usart0Obj;

void static USART0_ISR_RX_Handler( void )
{
    if(usart0Obj.rxBusyStatus == true)
    {
        while((US_CSR_RXRDY_Msk == (USART0_REGS->US_CSR& US_CSR_RXRDY_Msk)) && (usart0Obj.rxSize > usart0Obj.rxProcessedSize) )
        {
            usart0Obj.rxBuffer[usart0Obj.rxProcessedSize++] = (USART0_REGS->US_RHR& US_RHR_RXCHR_Msk);
        }

        /* Check if the buffer is done */
        if(usart0Obj.rxProcessedSize >= usart0Obj.rxSize)
        {

            usart0Obj.rxBusyStatus = false;

            /* Disable Read, Overrun, Parity and Framing error interrupts */
            USART0_REGS->US_IDR = (US_IDR_RXRDY_Msk | US_IDR_USART_LIN_FRAME_Msk | US_IDR_USART_LIN_PARE_Msk | US_IDR_OVRE_Msk);

            if(usart0Obj.rxCallback != NULL)
            {
                usart0Obj.rxCallback(usart0Obj.rxContext);
            }
        }
    }
    else
    {
        /* Nothing to process */
        ;
    }

    return;
}

void static USART0_ISR_TX_Handler( void )
{
    if(usart0Obj.txBusyStatus == true)
    {
        while((US_CSR_TXEMPTY_Msk == (USART0_REGS->US_CSR& US_CSR_TXEMPTY_Msk)) && (usart0Obj.txSize > usart0Obj.txProcessedSize) )
        {
            USART0_REGS->US_THR|= usart0Obj.txBuffer[usart0Obj.txProcessedSize++];
        }

        /* Check if the buffer is done */
        if(usart0Obj.txProcessedSize >= usart0Obj.txSize)
        {
            usart0Obj.txBusyStatus = false;
            USART0_REGS->US_IDR = US_IDR_TXEMPTY_Msk;

            if(usart0Obj.txCallback != NULL)
            {
                usart0Obj.txCallback(usart0Obj.txContext);
            }
        }
    }
    else
    {
        /* Nothing to process */
        ;
    }

    return;
}

void USART0_InterruptHandler( void )
{
    /* Error status */
    uint32_t errorStatus = (USART0_REGS->US_CSR & (US_CSR_OVRE_Msk | US_CSR_USART_LIN_FRAME_Msk | US_CSR_USART_LIN_PARE_Msk));

    if(errorStatus != 0)
    {
        /* Client must call USARTx_ErrorGet() function to clear the errors */

        /* Disable Read, Overrun, Parity and Framing error interrupts */
        USART0_REGS->US_IDR = (US_IDR_RXRDY_Msk | US_IDR_USART_LIN_FRAME_Msk | US_IDR_USART_LIN_PARE_Msk | US_IDR_OVRE_Msk);

        usart0Obj.rxBusyStatus = false;

        /* USART errors are normally associated with the receiver, hence calling
         * receiver callback */
        if( usart0Obj.rxCallback != NULL )
        {
            usart0Obj.rxCallback(usart0Obj.rxContext);
        }
    }

    /* Receiver status */
    if(US_CSR_RXRDY_Msk == (USART0_REGS->US_CSR & US_CSR_RXRDY_Msk))
    {
        USART0_ISR_RX_Handler();
    }

    /* Transmitter status */
    if(US_CSR_TXRDY_Msk == (USART0_REGS->US_CSR & US_CSR_TXRDY_Msk))
    {
        USART0_ISR_TX_Handler();
    }

    return;
}


void static USART0_ErrorClear( void )
{
    uint8_t dummyData = 0u;

    USART0_REGS->US_CR|= US_CR_RSTSTA_Msk;

    /* Flush existing error bytes from the RX FIFO */
    while( US_CSR_RXRDY_Msk == (USART0_REGS->US_CSR& US_CSR_RXRDY_Msk) )
    {
        dummyData = (USART0_REGS->US_RHR& US_RHR_RXCHR_Msk);
    }

    /* Ignore the warning */
    (void)dummyData;

    return;
}

void USART0_Initialize( void )
{
    /* Reset USART0 */
    USART0_REGS->US_CR = (US_CR_RSTRX_Msk | US_CR_RSTTX_Msk | US_CR_RSTSTA_Msk);

    /* Enable USART0 */
    USART0_REGS->US_CR = (US_CR_TXEN_Msk | US_CR_RXEN_Msk);

    /* Configure USART0 mode */
    USART0_REGS->US_MR = (US_MR_USCLKS_MCK | US_MR_CHRL_8_BIT | US_MR_USART_PAR_NO | US_MR_USART_NBSTOP_1_BIT | (0 << US_MR_USART_OVER_Pos));

    /* Configure USART0 Baud Rate */
    USART0_REGS->US_BRGR = US_BRGR_CD(81);

    /* Initialize instance object */
    usart0Obj.rxBuffer = NULL;
    usart0Obj.rxSize = 0;
    usart0Obj.rxProcessedSize = 0;
    usart0Obj.rxBusyStatus = false;
    usart0Obj.rxCallback = NULL;
    usart0Obj.txBuffer = NULL;
    usart0Obj.txSize = 0;
    usart0Obj.txProcessedSize = 0;
    usart0Obj.txBusyStatus = false;
    usart0Obj.txCallback = NULL;

    return;
}

USART_ERROR USART0_ErrorGet( void )
{
    USART_ERROR errors = USART_ERROR_NONE;
    uint32_t status = USART0_REGS->US_CSR;

    errors = (USART_ERROR)(status & (US_CSR_OVRE_Msk | US_CSR_USART_LIN_PARE_Msk | US_CSR_USART_LIN_FRAME_Msk));

    if(errors != USART_ERROR_NONE)
    {
        USART0_ErrorClear();
    }

    /* All errors are cleared, but send the previous error state */
    return errors;
}

bool USART0_SerialSetup( USART_SERIAL_SETUP *setup, uint32_t srcClkFreq )
{
    uint32_t baud = setup->baudRate;
    uint32_t brgVal = 0;
    uint32_t overSampVal = 0;
    uint32_t usartMode;
    bool status = false;

    if((usart0Obj.rxBusyStatus == true) || (usart0Obj.txBusyStatus == true))
    {
        /* Transaction is in progress, so return without updating settings */
        return false;
    }

    if (setup != NULL)
    {
        baud = setup->baudRate;
        if(srcClkFreq == 0)
        {
            srcClkFreq = USART0_FrequencyGet();
        }

        /* Calculate BRG value */
        if (srcClkFreq >= (16 * baud))
        {
            brgVal = (srcClkFreq / (16 * baud));
        }
        else
        {
            brgVal = (srcClkFreq / (8 * baud));
            overSampVal = US_MR_USART_OVER(1);
        }

        /* Configure USART0 mode */
        usartMode = USART0_REGS->US_MR;
        usartMode &= ~(US_MR_CHRL_Msk | US_MR_USART_MODE9_Msk | US_MR_USART_PAR_Msk | US_MR_USART_NBSTOP_Msk | US_MR_USART_OVER_Msk);
        USART0_REGS->US_MR = usartMode | (setup->dataWidth | setup->parity | setup->stopBits | overSampVal);

        /* Configure USART0 Baud Rate */
        USART0_REGS->US_BRGR = US_BRGR_CD(brgVal);
        status = true;
    }

    return status;
}

bool USART0_Read( void *buffer, const size_t size )
{
    bool status = false;
    uint8_t * lBuffer = (uint8_t *)buffer;

    if(NULL != lBuffer)
    {
        /* Clear errors before submitting the request.
         * ErrorGet clears errors internally. */
        USART0_ErrorGet();

        /* Check if receive request is in progress */
        if(usart0Obj.rxBusyStatus == false)
        {
            usart0Obj.rxBuffer = lBuffer;
            usart0Obj.rxSize = size;
            usart0Obj.rxProcessedSize = 0;
            usart0Obj.rxBusyStatus = true;
            status = true;

            /* Enable Read, Overrun, Parity and Framing error interrupts */
            USART0_REGS->US_IER = (US_IER_RXRDY_Msk | US_IER_USART_LIN_FRAME_Msk | US_IER_USART_LIN_PARE_Msk | US_IER_OVRE_Msk);
        }
    }

    return status;
}

bool USART0_Write( void *buffer, const size_t size )
{
    bool status = false;
    uint8_t * lBuffer = (uint8_t *)buffer;

    if(NULL != lBuffer)
    {
        /* Check if transmit request is in progress */
        if(usart0Obj.txBusyStatus == false)
        {
            usart0Obj.txBuffer = lBuffer;
            usart0Obj.txSize = size;
            usart0Obj.txProcessedSize = 0;
            usart0Obj.txBusyStatus = true;
            status = true;

            /* Initiate the transfer by sending first byte */
            if(US_CSR_TXRDY_Msk == (USART0_REGS->US_CSR & US_CSR_TXRDY_Msk))
            {
                USART0_REGS->US_THR = (US_THR_TXCHR(*lBuffer) & US_THR_TXCHR_Msk);
                usart0Obj.txProcessedSize++;
            }

            USART0_REGS->US_IER = US_IER_TXEMPTY_Msk;
        }
    }

    return status;
}


void USART0_WriteCallbackRegister( USART_CALLBACK callback, uintptr_t context )
{
    usart0Obj.txCallback = callback;

    usart0Obj.txContext = context;
}

void USART0_ReadCallbackRegister( USART_CALLBACK callback, uintptr_t context )
{
    usart0Obj.rxCallback = callback;

    usart0Obj.rxContext = context;
}

bool USART0_WriteIsBusy( void )
{
    return usart0Obj.txBusyStatus;
}

bool USART0_ReadIsBusy( void )
{
    return usart0Obj.rxBusyStatus;
}

size_t USART0_WriteCountGet( void )
{
    return usart0Obj.txProcessedSize;
}

size_t USART0_ReadCountGet( void )
{
    return usart0Obj.rxProcessedSize;
}

