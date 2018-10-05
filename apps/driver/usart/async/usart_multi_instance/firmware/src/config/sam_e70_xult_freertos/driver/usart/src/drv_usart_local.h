/*******************************************************************************
  USART Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_usart_local.h

  Summary:
    USART Driver Local Data Structures

  Description:
    Driver Local Data Structures
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

#ifndef DRV_USART_LOCAL_H
#define DRV_USART_LOCAL_H


// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
#include "driver/usart/drv_usart_definitions.h"
#include "driver/usart/drv_usart.h"
#include "osal/osal.h"

// *****************************************************************************
// *****************************************************************************
// Section: Data Type Definitions
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* USART Driver Buffer Handle Macros

  Summary:
    USART driver Buffer Handle Macros

  Description:
    Buffer handle related utility macros. USART driver buffer handle is a
    combination of buffer token and the buffer object index. The token
    is a 16 bit number that is incremented for every new read or write request
    and is used along with the buffer object index to generate a new buffer
    handle for every request.

  Remarks:
    None
*/

#define _DRV_USART_BUFFER_TOKEN_MAX         (0xFFFF)
#define _DRV_USART_MAKE_HANDLE(token, index) ((token) << 16 | (index))
#define _DRV_USART_UPDATE_BUFFER_TOKEN(token) \
{ \
    (token)++; \
    if ((token) >= _DRV_USART_BUFFER_TOKEN_MAX) \
        (token) = 0; \
    else \
        (token) = (token); \
}

// *****************************************************************************
/* USART Driver Buffer States

   Summary
    Identifies the possible state of the buffer that can result from a
    buffer request add or queue purge request.

   Description
    This enumeration identifies the possible state of the buffer that can
    result from a buffer request add or queue purge request by the client.

   Remarks:
    DRV_USART_BUFFER_IS_FREE is the state of the buffer which is in the
    free buffer pool.

*/

typedef enum
{
    /* Buffer is not added to either write or read queue. In other words,
     * the buffer is in the free pool. */
    DRV_USART_BUFFER_IS_FREE,

    /* Buffer is in the queue. */
    DRV_USART_BUFFER_IS_IN_QUEUE,

    /* USART is processing the buffer. */
    DRV_USART_BUFFER_IS_PROCESSING

} DRV_USART_BUFFER_STATE;


// *****************************************************************************
/* USART Driver Transfer Direction

   Summary
    Identifies the direction of transfer.

   Description
    This enumeration identifies the direction of transfer.

   Remarks:
    None.

*/

typedef enum
{
    /* Receive Operation */
    DRV_USART_DIRECTION_RX,

    /* Transmit Operation */
    DRV_USART_DIRECTION_TX

} DRV_USART_DIRECTION;

// *****************************************************************************
/* USART Driver Buffer Object

  Summary:
    Object used to keep track of a client's buffer.

  Description:
    None.

  Remarks:
    None.
*/

typedef struct _DRV_USART_BUFFER_OBJ
{
    /* The hardware instance object that owns this buffer */
    void * dObj;

    /* This flag tracks whether this object is in use */
    volatile bool inUse;

    /* Pointer to the application read or write buffer */
    void * buffer;

    /* Number of bytes to be transferred */
    size_t size;

    /* Number of bytes completed */
    size_t nCount;

    /* Next buffer pointer */
    struct _DRV_USART_BUFFER_OBJ * next;

    /* Current state of the buffer */
    DRV_USART_BUFFER_STATE currentState;

    /* Current status of the buffer */
    DRV_USART_BUFFER_EVENT status;

    /* Buffer Handle that was assigned to this buffer when it was added to the
     * queue. */
    DRV_USART_BUFFER_HANDLE bufferHandle;

} DRV_USART_BUFFER_OBJ;

// *****************************************************************************
/* USART Driver Instance Object

  Summary:
    Object used to keep any data required for an instance of the USART driver.

  Description:
    None.

  Remarks:
    None.
*/

typedef struct
{
    /* Flag to indicate this object is in use  */
    bool inUse;

    /* The status of the driver */
    SYS_STATUS status;

    /* This flags indicates if the client has opened the driver */
    bool clientInUse;

    /* to identify if we are running from interrupt context or not */
    uint8_t interruptNestingCount;

    /* Event handler for the client */
    DRV_USART_BUFFER_EVENT_HANDLER eventHandler;

    /* Application Context associated with the client */
    uintptr_t context;

    /* PLIB API list that will be used by the driver to access the hardware */
    USART_PLIB_API *usartPlib;

    /* Errors associated with the USART hardware instance */
    DRV_USART_ERROR errors;

    /* Interrupt Source of USART */
    INT_SOURCE interruptUSART;

    /* Hardware instance mutex */
    OSAL_MUTEX_DECLARE(mutexDriverInstance);

    /* The buffer queue for the write operations */
    DRV_USART_BUFFER_OBJ  *queueWrite;

    /* The buffer queue for the read operations */
    DRV_USART_BUFFER_OBJ  *queueRead;

    /* Read queue size */
    size_t queueSizeRead;

    /* Write queue size */
    size_t queueSizeWrite;

    /* Current read queue size */
    size_t queueSizeCurrentRead;

    /* Current read queue size */
    size_t queueSizeCurrentWrite;

    /* TX DMA Channel */
    SYS_DMA_CHANNEL txDMAChannel;

    /* RX DMA Channel */
    SYS_DMA_CHANNEL rxDMAChannel;

    /* This is the USART transmit register address. Used for DMA operation. */
    void * txAddress;

    /* This is the USART receive register address. Used for DMA operation. */
    void * rxAddress;

    /* This is the DMA channel interrupt source. */
    INT_SOURCE interruptDMA;
    uint32_t *remapDataWidth;
    uint32_t *remapParity;
    uint32_t *remapStopBits;
    uint32_t *remapError;
} DRV_USART_OBJ;

#endif //#ifndef DRV_USART_LOCAL_H

