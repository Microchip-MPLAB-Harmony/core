/*******************************************************************************
  I2C Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_i2c_local.h

  Summary:
    I2C Driver Local Data Structures

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

#ifndef _DRV_I2C_LOCAL_H
#define _DRV_I2C_LOCAL_H


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


// *****************************************************************************
/* I2C Driver client Handle Macros

  Summary:
    I2C driver client Handle Macros

  Description:
    Client handle related utility macros. I2C client handle is equal
    to client token. The token is a 32 bit number that is incremented for
    every new driver open request.

  Remarks:
    None
*/

#define DRV_I2C_CLIENT_INDEX_MASK               (0x000000FF)
#define DRV_I2C_INSTANCE_INDEX_MASK             (0x0000FF00)
#define DRV_I2C_TOKEN_MASK                      (0xFFFF0000)
#define DRV_I2C_TOKEN_MAX                       (DRV_I2C_TOKEN_MASK >> 16)



// *****************************************************************************
/* I2C Transfer Status

  Summary:
    Defines the transfer status of the I2C request

  Description:
    This enumeration defines the status codes of the I2C request.

  Remarks:

*/

typedef enum
{
    /* All data was transferred successfully. */
    DRV_I2C_TRANSFER_STATUS_COMPLETE,

    /* There was an error while processing transfer request. */
    DRV_I2C_TRANSFER_STATUS_ERROR,

} DRV_I2C_TRANSFER_STATUS;

// *****************************************************************************
/* I2C Driver Instance Object

  Summary:
    Object used to keep any data required for an instance of the I2C driver.

  Description:
    None.

  Remarks:
    None.
*/

typedef struct
{
    /* Flag to indicate that driver has been opened Exclusively*/
    bool isExclusive;

    /* Keep track of the number of clients
      that have opened this driver */
    size_t nClients;

    /* Maximum number of clients */
    size_t nClientsMax;

    bool inUse;

    /* The status of the driver */
    SYS_STATUS status;

    /* PLIB API list that will be used by the driver to access the hardware */
    DRV_I2C_PLIB_INTERFACE* i2cPlib;

    /* Memory pool for Client Objects */
    uintptr_t clientObjPool;

    /* This is an instance specific token counter used to generate unique client
     * handles
     */
    uint16_t i2cTokenCount;

    /* The client of the active transfer on this driver instance */
    uintptr_t activeClient;

    /* Status of the active transfer */
    DRV_I2C_TRANSFER_STATUS transferStatus;

    /* Mutex to protect access to the peripheral */
    OSAL_MUTEX_DECLARE(transferMutex);

    /* Mutex to protect access to the client object pool */
    OSAL_MUTEX_DECLARE(clientMutex);

    /* Semaphore to wait for transfer to complete. This is released from ISR*/
    OSAL_SEM_DECLARE(transferDone);

} DRV_I2C_OBJ;

// *****************************************************************************
/* I2C Driver Client Object

  Summary:
    Object used to track a single client.

  Description:
    This object is used to keep the data necesssary to keep track of a single
    client.

  Remarks:
    None.
*/

typedef struct
{
    /* The hardware instance object associated with the client */
    DRV_I2C_OBJ* hDriver;

    /* The IO intent with which the client was opened */
    DRV_IO_INTENT ioIntent;

    /* Errors associated with the I2C transfer */
    DRV_I2C_ERROR errors;

    /* This flags indicates if the object is in use or is
     * available */
    bool inUse;

    /* Client handle assigned to this client object when it was opened */
    DRV_HANDLE clientHandle;

} DRV_I2C_CLIENT_OBJ;

#endif //#ifndef _DRV_I2C_LOCAL_H
