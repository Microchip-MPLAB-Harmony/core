/*******************************************************************************
  I2S Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_i2s_local.h

  Summary:
    I2S Driver Local Data Structures

  Description:
    Driver Local Data Structures
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
Copyright (c) 2018 released Microchip Technology Inc.  All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute Software
only when embedded on a Microchip microcontroller or digital  signal  controller
that is integrated into your product or third party  product  (pursuant  to  the
sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED AS IS  WITHOUT  WARRANTY  OF  ANY  KIND,
EITHER EXPRESS  OR  IMPLIED,  INCLUDING  WITHOUT  LIMITATION,  ANY  WARRANTY  OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A  PARTICULAR  PURPOSE.
IN NO EVENT SHALL MICROCHIP OR  ITS  LICENSORS  BE  LIABLE  OR  OBLIGATED  UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION,  BREACH  OF  WARRANTY,  OR
OTHER LEGAL  EQUITABLE  THEORY  ANY  DIRECT  OR  INDIRECT  DAMAGES  OR  EXPENSES
INCLUDING BUT NOT LIMITED TO ANY  INCIDENTAL,  SPECIAL,  INDIRECT,  PUNITIVE  OR
CONSEQUENTIAL DAMAGES, LOST  PROFITS  OR  LOST  DATA,  COST  OF  PROCUREMENT  OF
SUBSTITUTE  GOODS,  TECHNOLOGY,  SERVICES,  OR  ANY  CLAIMS  BY  THIRD   PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE  THEREOF),  OR  OTHER  SIMILAR  COSTS.
*******************************************************************************/
//DOM-IGNORE-END

#ifndef DRV_I2S_LOCAL_H
#define DRV_I2S_LOCAL_H


// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
#include "driver/i2s/drv_i2s_definitions.h"
#include "driver/i2s/drv_i2s.h"
#include "osal/osal.h"

// *****************************************************************************
// *****************************************************************************
// Section: Data Type Definitions
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* I2S Driver Buffer Handle Macros

  Summary:
    I2S driver Buffer Handle Macros

  Description:
    Buffer handle related utility macros. I2S driver buffer handle is a
    combination of buffer token and the buffer object index. The token
    is a 16 bit number that is incremented for every new read or write request
    and is used along with the buffer object index to generate a new buffer
    handle for every request.

  Remarks:
    None
*/

#define _DRV_I2S_BUFFER_TOKEN_MAX         (0xFFFF)
#define _DRV_I2S_MAKE_HANDLE(token, index) ((token) << 16 | (index))
#define _DRV_I2S_UPDATE_BUFFER_TOKEN(token) \
{ \
    (token)++; \
    if ((token) >= _DRV_I2S_BUFFER_TOKEN_MAX) \
        (token) = 0; \
    else \
        (token) = (token); \
}

// *****************************************************************************
/* I2S Driver Buffer States

   Summary
    Identifies the possible state of the buffer that can result from a
    buffer request add or queue purge request.

   Description
    This enumeration identifies the possible state of the buffer that can
    result from a buffer request add or queue purge request by the client.

   Remarks:
    DRV_I2S_BUFFER_IS_FREE is the state of the buffer which is in the
    free buffer pool.

*/

typedef enum
{
    /* Buffer is not added to either write or read queue. In other words,
     * the buffer is in the free pool. */
    DRV_I2S_BUFFER_IS_FREE,

    /* Buffer is in the queue. */
    DRV_I2S_BUFFER_IS_IN_QUEUE,

    /* I2S is processing the buffer. */
    DRV_I2S_BUFFER_IS_PROCESSING

} DRV_I2S_BUFFER_STATE;


// *****************************************************************************
/* I2S Driver Transfer Direction

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
    DRV_I2S_DIRECTION_RX,

    /* Transmit Operation */
    DRV_I2S_DIRECTION_TX

} DRV_I2S_DIRECTION;

// *****************************************************************************
/* I2S Driver Buffer Object

  Summary:
    Object used to keep track of a client's buffer.

  Description:
    None.

  Remarks:
    None.
*/

typedef struct _DRV_I2S_BUFFER_OBJ
{
    /* The hardware instance object that owns this buffer */
    void * dObj;

    /* This flag tracks whether this object is in use */
    volatile bool inUse;

    /* Pointer to the application read or write buffer */
    void *txbuffer;
    void *rxbuffer;

    /* Number of bytes to be transferred */
    size_t size;

    /* Number of bytes completed */
    size_t nCount;

    /* Next buffer pointer */
    struct _DRV_I2S_BUFFER_OBJ * next;

    /* Current state of the buffer */
    DRV_I2S_BUFFER_STATE currentState;

    /* Current status of the buffer */
    DRV_I2S_BUFFER_EVENT status;

    /* Buffer Handle that was assigned to this buffer when it was added to the
     * queue. */
    DRV_I2S_BUFFER_HANDLE bufferHandle;

} DRV_I2S_BUFFER_OBJ;

// *****************************************************************************
/* I2S Driver Instance Object

  Summary:
    Object used to keep any data required for an instance of the I2S driver.

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

    /* Event handler for the client */
    DRV_I2S_BUFFER_EVENT_HANDLER eventHandler;

    /* Application Context associated with the client */
    uintptr_t context;

    /* PLIB API list that will be used by the driver to access the hardware */
    DRV_I2S_PLIB_INTERFACE *i2sPlib;

    /* Errors associated with the I2S hardware instance */
    DRV_I2S_ERROR errors;

    /* Interrupt Source of I2S */
    INT_SOURCE interruptI2S;

    /* Hardware instance mutex */
    OSAL_MUTEX_DECLARE(mutexDriverInstance);

    /* The buffer queue for the write operations */
    DRV_I2S_BUFFER_OBJ  *queueWrite;

    /* The buffer queue for the read operations */
    DRV_I2S_BUFFER_OBJ  *queueRead;

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

    /* This is the I2S transmit register address. Used for DMA operation. */
    void * txAddress;

    /* This is the I2S receive register address. Used for DMA operation. */
    void * rxAddress;

    /* This is the DMA channel interrupt source. */
    INT_SOURCE interruptDMA;

    /* Size of DMA channel in I2S or SSC PLIB */
    uint8_t dmaDataLength;

} DRV_I2S_OBJ;

#endif //#ifndef DRV_I2S_LOCAL_H

