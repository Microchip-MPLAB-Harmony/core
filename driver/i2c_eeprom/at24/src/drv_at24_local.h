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

#ifndef DRV_AT24_LOCAL_H
#define DRV_AT24_LOCAL_H


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
    const DRV_AT24_PLIB_INTERFACE*  i2cPlib;

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
    DRV_AT24_CMD                    command;

    /* Application event handler */
    DRV_AT24_EVENT_HANDLER          eventHandler;

    /* Application context */
    uintptr_t                       context;

    /* Status of the transfer */
    volatile DRV_AT24_TRANSFER_STATUS       transferStatus;

} DRV_AT24_OBJ;


#endif //#ifndef DRV_AT24C_LOCAL_H
