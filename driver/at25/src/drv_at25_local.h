/*******************************************************************************
  AT25 Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_at25_local.h

  Summary:
    AT25 Driver Local Data Structures

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

#ifndef _DRV_AT25_LOCAL_H
#define _DRV_AT25_LOCAL_H


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
/* DRV_AT25 Command set

  Summary:
    Enumeration listing the DRV_AT25 commands.

  Description:
    This enumeration defines the commands used to interact with the DRV_AT25
    series of devices.

  Remarks:
    None
*/

typedef enum
{
    /* Write enable command. */
    DRV_AT25_CMD_WRITE_ENABLE       = 0x06,

    /* Page Program command. */
    DRV_AT25_CMD_PAGE_PROGRAM       = 0x02,

    /* Command to read the Flash status register. */
    DRV_AT25_CMD_READ_STATUS_REG    = 0x05,

    /* Command to read the Flash. */
    DRV_AT25_CMD_READ               = 0x03

} DRV_AT25_CMD;

typedef enum
{
    DRV_AT25_STATE_WRITE_EN,
    DRV_AT25_STATE_WRITE_CMD_ADDR,
    DRV_AT25_STATE_WRITE_DATA,
    DRV_AT25_STATE_CHECK_WRITE_STATUS,
    DRV_AT25_STATE_WAIT_WRITE_COMPLETE,
    DRV_AT25_STATE_READ_CMD_ADDR,
    DRV_AT25_STATE_READ_DATA,
    DRV_AT25_STATE_WAIT_READ_COMPLETE,
}DRV_AT25_STATE;

// *****************************************************************************
/* AT25 Driver Instance Object

  Summary:
    Object used to keep any data required for an instance of the AT25 driver.

  Description:
    None.

  Remarks:
    None.
*/

typedef struct
{
    /* Flag to indicate this object is in use  */
    bool                            inUse;

    DRV_AT25_STATE                 state;

    /* Keep track of the number of clients
      that have opened this driver */
    size_t                          nClients;

    /* Maximum number of clients */
    size_t                          nClientsMax;

    /* The status of the driver */
    SYS_STATUS                      status;

    /* PLIB API list that will be used by the driver to access the hardware */
    DRV_AT25_PLIB_INTERFACE        *spiPlib;

    uint8_t                         at25Command[4];

    bool                            writeCompleted;

    SYS_PORT_PIN                    chipSelectPin;

    SYS_PORT_PIN                    holdPin;

    SYS_PORT_PIN                    writeProtectPin;

    /* Points to the next EEPROM memory address to write to */
    uint32_t                        memoryAddr;

    /* Pointer to the write buffer to write data from */
    uint8_t*                        bufferAddr;

    /* Pointer to the write buffer to write data from */
    uint32_t                        nPendingBytes;

    /* Page size information */
    uint32_t                        pageSize;

    /* Total flash size */
    uint32_t                        flashSize;

    uint32_t                        blockStartAddress;

    /* Application event handler */
    DRV_AT25_EVENT_HANDLER          eventHandler;

    /* Application context */
    uintptr_t                       context;

    volatile DRV_AT25_TRANSFER_STATUS       transferStatus;

} DRV_AT25_OBJ;


#endif //#ifndef _DRV_AT25_LOCAL_H
