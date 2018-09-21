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

#include "osal/osal.h"

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************


// *****************************************************************************
// *****************************************************************************
// Section: Data Type Definitions
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* SPI Driver client Handle Macros

  Summary:
    SPI driver client Handle Macros

  Description:
    client handle related utility macros. SPI client client handle is a combination
    of client index (8-bit), instance index (8-bit) and token (16-bit). The token
    is incremented for every new driver open request.

  Remarks:
    None
*/

#define DRV_SPI_CLIENT_INDEX_MASK               (0x000000FF)
#define DRV_SPI_INSTANCE_INDEX_MASK             (0x0000FF00)
#define DRV_SPI_TOKEN_MASK                      (0xFFFF0000)
#define DRV_SPI_TOKEN_MAX                       (0x0000FFFF)

#define _USE_FREQ_CONFIGURED_IN_CLOCK_MANAGER   0

typedef enum
{
    /* All data was transferred successfully. */
    DRV_SPI_TRANSFER_STATUS_COMPLETE,

    /* There was an error while processing transfer request. */
    DRV_SPI_TRANSFER_STATUS_ERROR,

} DRV_SPI_TRANSFER_STATUS;

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
    DRV_SPI_PLIB_INTERFACE* spiPlib;

    /* Default baud rate */
    uint32_t    baudRateInHz;

    /* Default clock phase */
    DRV_SPI_CLOCK_PHASE clockPhase;

    /* Default clock polarity */
    DRV_SPI_CLOCK_POLARITY  clockPolarity;

    /* Default data bits */
    DRV_SPI_DATA_BITS   dataBits;

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
    uint32_t txDummyDataSize;

    /* This holds the number of dummy data to be received */
    uint32_t rxDummyDataSize;

    /* This contains the address of the application transmit buffer from which
     * the transmission should continue. This is used for the case where the
     * transmission is split into two, when rxSize is less than txSize.
     */
    uintptr_t pNextTransmitData;

    /* The active client for this driver instance */
    uintptr_t activeClient;

    /* This is an instance specific token counter used to generate unique client
     * handles
     */
    uint16_t spiTokenCount;

    /* Status of the last data transfer on this driver instance */
    DRV_SPI_TRANSFER_STATUS transferStatus;

    /* Mutex to protect access to PLIB */
    OSAL_MUTEX_DECLARE(transferMutex);

    /* Mutex to protect access to the client object pool */
    OSAL_MUTEX_DECLARE(clientMutex);

    /* Semaphore to wait for data exchange to complete.
    *  This is released from ISR.
    */
    OSAL_SEM_DECLARE(transferDone);

} DRV_SPI_OBJ;

// *****************************************************************************
/* SPI Driver Client Object

  Summary:
    Object used to track a single client.

  Description:
    This object is used to keep the data necesssary to keep track of a single
    client.

  Remarks:
    None.
*/

typedef struct _DRV_SPI_CLIENT_OBJ
{
    /* The hardware instance object associated with the client */
    DRV_SPI_OBJ*                   hDriver;

    /* The IO intent with which the client was opened */
    DRV_IO_INTENT                  ioIntent;

    /* This flags indicates if the object is in use or is
     * available */
    bool                           inUse;

    /* Client specific setup */
    DRV_SPI_TRANSFER_SETUP         setup;

    /* Indicates whether the client has changed the SPI setup */
    bool                           setupChanged;

    /* Client handle assigned to this client object when it was opened */
    DRV_HANDLE                     clientHandle;
} DRV_SPI_CLIENT_OBJ;

#endif //#ifndef _DRV_SPI_LOCAL_H
