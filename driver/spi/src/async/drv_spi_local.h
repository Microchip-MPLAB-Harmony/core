/*******************************************************************************
  SPI Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_spi_local.h

  Summary:
    SPI Driver Local Data Structures

  Description:
    Driver Local Data Structures
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
Copyright (c) 2017 released Microchip Technology Inc.  All rights reserved.

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

#ifndef _DRV_SPI_LOCAL_H
#define _DRV_SPI_LOCAL_H


// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
#include "osal/osal.h"

// *****************************************************************************
// *****************************************************************************
// Section: Data Type Definitions
// *****************************************************************************
// *****************************************************************************


/* SPI Driver Handle Macros*/
#define DRV_SPI_INDEX_MASK                      (0x000000FF)

#define DRV_SPI_INSTANCE_MASK                   (0x0000FF00)

#define DRV_SPI_TOKEN_MAX                       (0xFFFF)


#define _USE_FREQ_CONFIGURED_IN_CLOCK_MANAGER       0
#define NULL_INDEX                                  0xFF
// *****************************************************************************
/* SPI Client-Specific Driver Status

  Summary:
    Defines the client-specific status of the SPI driver.

  Description:
    This enumeration defines the client-specific status codes of the SPI
    driver.

  Remarks:
    Returned by the DRV_SPI_ClientStatus function.
*/

typedef enum
{
    /* An error has occurred.*/
    DRV_SPI_CLIENT_STATUS_ERROR    = DRV_CLIENT_STATUS_ERROR,

    /* The driver is closed, no operations for this client are ongoing,
    and/or the given handle is invalid. */
    DRV_SPI_CLIENT_STATUS_CLOSED   = DRV_CLIENT_STATUS_CLOSED,

    /* The driver is currently busy and cannot start additional operations. */
    DRV_SPI_CLIENT_STATUS_BUSY     = DRV_CLIENT_STATUS_BUSY,

    /* The module is running and ready for additional operations */
    DRV_SPI_CLIENT_STATUS_READY    = DRV_CLIENT_STATUS_READY

} DRV_SPI_CLIENT_STATUS;

typedef enum
{
    /* Configure DMA to transmit dummy data from a fixed memory location */
    DRV_SPI_CONFIG_DMA_TX_DUMMY_DATA_XFER = 0,

    /* Configure DMA to transmit data from a memory buffer */
    DRV_SPI_CONFIG_DMA_TX_BUFFER_DATA_XFER,

    /* Configure DMA to receive dummy data to a fixed memory location */
    DRV_SPI_CONFIG_DMA_RX_DUMMY_DATA_XFER,

    /* Configure DMA to receive data to a memory buffer */
    DRV_SPI_CONFIG_DMA_RX_BUFFER_DATA_XFER,

}DRV_SPI_CONFIG_DMA;

typedef enum
{
    /* DMA data width 8 bit */
    DRV_SPI_DMA_WIDTH_8_BIT = 0,

    /* DMA data width 16 bit */
    DRV_SPI_DMA_WIDTH_16_BIT,

    /* DMA data width 32 bit */
    DRV_SPI_DMA_WIDTH_32_BIT,

}DRV_SPI_DMA_WIDTH;

// *****************************************************************************
/* SPI Driver Transfer Object

  Summary:
    Object used to keep track of a client's buffer.

  Description:
    None.

  Remarks:
    None.
*/

typedef struct _DRV_SPI_TRANSFER_OBJ
{
    /* Pointer to the receive data */
    void                    *pReceiveData;

    /* Pointer to the transmit data */
    void                    *pTransmitData;

    /* Number of bytes to be written */
    size_t                  txSize;

    /* Number of bytes to be written */
    size_t                  rxSize;

    /* Current status of the buffer */
    DRV_SPI_TRANSFER_EVENT  event;

    /* The hardware instance object that owns this buffer */
    void                    *hClient;

    /* Buffer Handle object that was assigned to this buffer
    when it was added to the queue. */
    DRV_SPI_TRANSFER_HANDLE transferHandle;

    /* next index to manage the linked list of transfer objects */
    uint8_t                 nextIndex;

} DRV_SPI_TRANSFER_OBJ;

// *****************************************************************************
/* SPI Driver Instance Object

  Summary:
    Object used to keep any data required for an instance of the SPI driver.

  Description:
    None.

  Remarks:
    None.
*/

typedef struct
{
    /* Flag to indicate this object is in use  */
    bool inUse;

    /* Flag to indicate that driver has been opened Exclusively*/
    bool isExclusive;

    /* Keep track of the number of clients
      that have opened this driver */
    size_t nClients;

    /* Maximum number of clients */
    size_t nClientsMax;

    /* Memory pool for Client Objects */
    uintptr_t clientObjPool;

    /* The status of the driver */
    SYS_STATUS status;

    /* PLIB API list that will be used by the driver to access the hardware */
    DRV_SPI_PLIB_INTERFACE *spiPlib;

    /* start of the memory pool for transfer objects */
    DRV_SPI_TRANSFER_OBJ *transferArray;

    /* size/depth of the queue */
    uint8_t transferQueueSize;

    /* objects will be allocated from this end one by one */
    uint8_t freePoolHeadIndex;

    /* objects will be processed from this end one by one */
    uint8_t queueHeadIndex;

    /* new objects will be added at this end */
    uint8_t queueTailIndex;

    /* Default baud rate */
    uint32_t    baudRateInHz;

    /* Default clock phase */
    DRV_SPI_CLOCK_PHASE clockPhase;

    /* Default clock polarity */
    DRV_SPI_CLOCK_POLARITY  clockPolarity;

    /* Default data bits */
    DRV_SPI_DATA_BITS   dataBits;

    /* Instance specific token counter used to generate unique client/transfer handles */
    uint16_t spiTokenCount;

    /* to identify if we are running from interrupt context or not */
    uint8_t interruptNestingCount;

    /* DMA related elements */
    /* Transmit DMA Channel */
    SYS_DMA_CHANNEL txDMAChannel;

    /* Receive DMA Channel */
    SYS_DMA_CHANNEL rxDMAChannel;

    /* This is the SPI transmit register address. Used for DMA operation. */
    void* txAddress;

    /* This is the SPI receive register address. Used for DMA operation. */
    void* rxAddress;

    /* Dummy data is read into this variable by RX DMA */
    uint32_t rxDummyData;

    /* This holds the number of dummy data to be transmitted */
    size_t txDummyDataSize;

    /* This holds the number of dummy data to be received */
    size_t rxDummyDataSize;

    /* Interrupt source ID for SPI or DMA interrupt. */
    INT_SOURCE interruptSource;

    /* Mutex to protect access to the client objects */
    OSAL_MUTEX_DECLARE(mutexClientObjects);

    /* Mutex to protect access to the transfer objects */
    OSAL_MUTEX_DECLARE(mutexTransferObjects);

} DRV_SPI_OBJ;

// *****************************************************************************
/* SPI Driver Client Object

  Summary:
    Object used to track a single client.

  Description:
    This object is used to keep the data necessary to keep track of a single
    client.

  Remarks:
    None.
*/

typedef struct _DRV_SPI_CLIENT_OBJ
{
    /* The hardware instance index associated with the client */
    SYS_MODULE_INDEX                drvIndex;

    /* The IO intent with which the client was opened */
    DRV_IO_INTENT                   ioIntent;

    /* This flags indicates if the object is in use or is
     * available */
    bool                            inUse;

    /* Event handler for this function */
    DRV_SPI_TRANSFER_EVENT_HANDLER  eventHandler;

    /* Application Context associated with this client */
    uintptr_t                       context;

    /* Client specific setup */
    DRV_SPI_TRANSFER_SETUP          setup;

    /* Flag to save setup changed status */
    bool                            setupChanged;

    /* Client handle assigned to this client object when it was opened */
    DRV_HANDLE                      clientHandle;

} DRV_SPI_CLIENT_OBJ;


#endif //#ifndef _DRV_SPI_LOCAL_H
