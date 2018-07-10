/*******************************************************************************
  AT24 Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_at24_local.h

  Summary:
    AT24 Driver Local Data Structures

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

#ifndef _DRV_AT24_LOCAL_H
#define _DRV_AT24_LOCAL_H


// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
#include "configuration.h"

// *****************************************************************************
// *****************************************************************************
// Section: Data Type Definitions
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* DRV_AT24 Active Command

  Summary:
    Enumeration listing of the active command.

  Description:
    This enumeration defines the currently active command

  Remarks:
    None
*/

typedef enum
{       
    /* Write command*/
    DRV_AT24_CMD_WRITE,
    
    /* Wait for EEPROM internal write complete command */
    DRV_AT24_CMD_WAIT_WRITE_COMPLETE,
    
    /* Read command */
    DRV_AT24_CMD_READ,
            
} DRV_AT24_CMD;

// *****************************************************************************
/* AT24 Driver Instance Object

  Summary:
    Object used to keep any data required for an instance of the AT24C driver.

  Description:
    None.

  Remarks:
    None.
*/

typedef struct
{    
    /* Flag to indicate this object is in use  */
    bool                            inUse;

    /* Indicates th number of clients that have opened this driver */
    size_t                          nClients;

    /* Maximum number of clients */
    size_t                          nClientsMax;

    /* The status of the driver */
    SYS_STATUS                      status;
        
    /* PLIB API list that will be used by the driver to access the hardware */
    DRV_AT24_PLIB_INTERFACE*       i2cPlib;
    
    /* EEPROM Slave Address*/
    uint16_t                        slaveAddress;        
    
    /* Points to the next EEPROM memory address to write to */
    uint32_t                        nextMemoryAddr;
    
    /* Pointer to the write buffer to write data from */
    uint8_t*                        nextBufferAddr;
    
    /* Pointer to the write buffer to write data from */
    uint32_t                        nPendingBytes;
        
    /* Page size information */
    uint32_t                        pageSize;
    
    /* Total flash size */
    uint32_t                        flashSize;
    
    /* Starting memory address of EEPROM */
    uint32_t                        blockStartAddress;
    
    /* Write buffer - must also hold the EEPROM memory address */
    uint8_t                         writeBuffer[DRV_AT24_WRITE_BUFFER_SIZE];
    
    /* The command currently being executed */
    DRV_AT24_CMD                   command;                            
    
    /* Application event handler */
    DRV_AT24_EVENT_HANDLER         eventHandler;
    
    /* Application context */
    uintptr_t                       context;
    
    /* Status of the transfer */
    volatile DRV_AT24_TRANSFER_STATUS       transferStatus;   

} DRV_AT24_OBJ;


#endif //#ifndef _DRV_AT24C_LOCAL_H
