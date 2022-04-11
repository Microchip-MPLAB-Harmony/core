/*******************************************************************************
  SST26 Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sst26_local.h

  Summary:
    SST26 driver local declarations and definitions

  Description:
    This file contains the SST26 driver's local declarations and definitions.
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

#ifndef _DRV_SST26_LOCAL_H
#define _DRV_SST26_LOCAL_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************
#include <string.h>
#include "configuration.h"
#include "driver/sst26/drv_sst26.h"
<#if DRV_SST26_INTERFACE_TYPE == "SPI_DRV" >
#include "driver/driver.h"
</#if>
// *****************************************************************************
// *****************************************************************************
// Section: Local Data Type Definitions
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* SST26 Command set

  Summary:
    Enumeration listing the SST26VF commands.

  Description:
    This enumeration defines the commands used to interact with the SST26VF
    series of devices.

  Remarks:
    None
*/

typedef enum
{
    /* Reset enable command. */
    SST26_CMD_FLASH_RESET_ENABLE = 0x66,

    /* Command to reset the flash. */
    SST26_CMD_FLASH_RESET        = 0x99,

    /* Command to Enable QUAD IO */
    SST26_CMD_ENABLE_QUAD_IO     = 0x38,

    /* Command to Reset QUAD IO */
    SST26_CMD_RESET_QUAD_IO      = 0xFF,

    /* Command to read JEDEC-ID of the flash device. */
    SST26_CMD_JEDEC_ID_READ      = 0x9F,

    /* QUAD Command to read JEDEC-ID of the flash device. */
    SST26_CMD_QUAD_JEDEC_ID_READ = 0xAF,

    /* Command to perform High Speed Read */
    SST26_CMD_HIGH_SPEED_READ    = 0x0B,

    /* Write enable command. */
    SST26_CMD_WRITE_ENABLE       = 0x06,

    /* Page Program command. */
    SST26_CMD_PAGE_PROGRAM       = 0x02,

    /* Command to read the Flash status register. */
    SST26_CMD_READ_STATUS_REG    = 0x05,

    /* Command to perform sector erase */
    SST26_CMD_SECTOR_ERASE       = 0x20,

    /* Command to perform Bulk erase */
    SST26_CMD_BULK_ERASE_64K     = 0xD8,

    /* Command to perform Chip erase */
    SST26_CMD_CHIP_ERASE         = 0xC7,

    /* Command to unlock the flash device. */
    SST26_CMD_UNPROTECT_GLOBAL   = 0x98

} SST26_CMD;

<#if DRV_SST26_PROTOCOL == "SQI">
    <#lt>// *****************************************************************************
    <#lt>/* SST26 Driver operations.

    <#lt>  Summary:
    <#lt>    Enumeration listing the SST26 driver operations.

    <#lt>  Description:
    <#lt>    This enumeration defines the possible SST26 driver operations.

    <#lt>  Remarks:
    <#lt>    None
    <#lt>*/

    <#lt>typedef enum
    <#lt>{
    <#lt>    /* Request is a command operation */
    <#lt>    DRV_SST26_OPERATION_TYPE_CMD = 0,

    <#lt>    /* Request is read operation. */
    <#lt>    DRV_SST26_OPERATION_TYPE_READ,

    <#lt>    /* Request is write operation. */
    <#lt>    DRV_SST26_OPERATION_TYPE_WRITE,

    <#lt>    /* Request is erase operation. */
    <#lt>    DRV_SST26_OPERATION_TYPE_ERASE,

    <#lt>} DRV_SST26_OPERATION_TYPE;

    <#lt>/**************************************
    <#lt> * SST26 Driver Hardware Instance Object
    <#lt> **************************************/
    <#lt>typedef struct
    <#lt>{
    <#lt>    /* Flag to indicate in use  */
    <#lt>    bool inUse;

    <#lt>    /* Flag to indicate status of transfer */
    <#lt>    volatile bool isTransferDone;

    <#lt>    /* The status of the driver */
    <#lt>    SYS_STATUS status;

    <#lt>    /* Intent of opening the driver */
    <#lt>    DRV_IO_INTENT ioIntent;

    <#lt>    /* Indicates the number of clients that have opened this driver */
    <#lt>    size_t nClients;

    <#lt>    /* Current Operation */
    <#lt>    DRV_SST26_OPERATION_TYPE curOpType;

    <#lt>    /* PLIB API list that will be used by the driver to access the hardware */
    <#lt>    const DRV_SST26_PLIB_INTERFACE *sst26Plib;

    <#lt>} DRV_SST26_OBJECT;

<#elseif DRV_SST26_PROTOCOL == "SPI">
    <#lt>typedef enum
    <#lt>{
    <#lt>    DRV_SST26_STATE_READ_DATA,
    <#lt>    DRV_SST26_STATE_WAIT_READ_COMPLETE,
    <#lt>    DRV_SST26_STATE_WRITE_CMD_ADDR,
    <#lt>    DRV_SST26_STATE_WRITE_DATA,
    <#lt>    DRV_SST26_STATE_CHECK_ERASE_WRITE_STATUS,
    <#lt>    DRV_SST26_STATE_WAIT_ERASE_WRITE_COMPLETE,
    <#lt>    DRV_SST26_STATE_ERASE,
    <#lt>    DRV_SST26_STATE_UNLOCK_FLASH,
    <#lt>    DRV_SST26_STATE_WAIT_UNLOCK_FLASH_COMPLETE,
    <#lt>    DRV_SST26_STATE_WAIT_RESET_FLASH_COMPLETE,
    <#lt>    DRV_SST26_STATE_WAIT_JEDEC_ID_READ_COMPLETE
    <#lt>} DRV_SST26_STATE;

    <#lt>typedef struct
    <#lt>{
    <#lt>    /* Pointer to the receive data */
    <#lt>    void*   pReceiveData;

    <#lt>    /* Pointer to the transmit data */
    <#lt>    void*   pTransmitData;

    <#lt>    /* Number of bytes to be written */
    <#lt>    size_t  txSize;

    <#lt>    /* Number of bytes to be read */
    <#lt>    size_t  rxSize;  

    <#lt>}DRV_SST26_TRANSFER_OBJ;

    <#lt>/**************************************
    <#lt> * SST26 Driver Hardware Instance Object
    <#lt> **************************************/
    <#lt>typedef struct
    <#lt>{
    <#lt>    /* Flag to indicate in use  */
    <#lt>    bool inUse;

    <#lt>    /* Flag to indicate state  */
    <#lt>    DRV_SST26_STATE state;

    <#lt>    /* Flag to indicate status of transfer */
    <#lt>    volatile DRV_SST26_TRANSFER_STATUS transferStatus;

    <#lt>    /* The status of the driver */
    <#lt>    SYS_STATUS status;

    <#lt>    /* Intent of opening the driver */
    <#lt>    DRV_IO_INTENT ioIntent;

    <#lt>    /* Indicates the number of clients that have opened this driver */
    <#lt>    size_t nClients;

    <#lt>    /* Points to the FLASH memory address */
    <#lt>    uint32_t memoryAddr;

    <#lt>    /* Pointer to the buffer */
    <#lt>    uint8_t* bufferAddr;

    <#lt>    /* Number of bytes pending to read/write */
    <#lt>    uint32_t nPendingBytes;

    <#lt>    /* Stores the command to be sent */
    <#lt>    uint8_t currentCommand;

    <#lt>    /* Chip Select pin used */
    <#lt>    SYS_PORT_PIN chipSelectPin;

    <#lt>    /* Application event handler */
    <#lt>    DRV_SST26_EVENT_HANDLER eventHandler;

    <#lt>    /* Application context */
    <#lt>    uintptr_t context;

<#if DRV_SST26_INTERFACE_TYPE == "SPI_DRV" >
    <#lt>    uint32_t spiDrvIndex;

    <#lt>    DRV_HANDLE spiDrvHandle;
<#else>
    <#lt>    /* PLIB API list that will be used by the driver to access the hardware */
    <#lt>    const DRV_SST26_PLIB_INTERFACE *sst26Plib;
</#if>

    <#lt>    DRV_SST26_TRANSFER_OBJ          transferDataObj;

<#if DRV_SST26_TX_RX_DMA == true>
    <#lt>    /* Transmit DMA Channel */
    <#lt>    SYS_DMA_CHANNEL                 txDMAChannel;

    <#lt>    /* Receive DMA Channel */
    <#lt>    SYS_DMA_CHANNEL                 rxDMAChannel;

    <#lt>    /* This is the SPI transmit register address. Used for DMA operation. */
    <#lt>    void*                           txAddress;

    <#lt>    /* This is the SPI receive register address. Used for DMA operation. */
    <#lt>    void*                           rxAddress;

<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == true>
    <#lt>    /* Number of bytes pending to be written */
    <#lt>    size_t  txPending;

    <#lt>    /* Number of bytes to pending to be read */
    <#lt>    size_t  rxPending;

    <#lt>    /* Number of bytes transferred */
    <#lt>    size_t  nBytesTransferred;
<#else>
    <#lt>    /* Dummy data is read into this variable by RX DMA */
    <#lt>    uint32_t                        rxDummyData;

    <#lt>    /* This holds the number of dummy data to be transmitted */
    <#lt>    size_t                          txDummyDataSize;

    <#lt>    /* This holds the number of dummy data to be received */
    <#lt>    size_t                          rxDummyDataSize;
</#if>      

</#if>
    <#lt>} DRV_SST26_OBJECT;
</#if>




#endif //#ifndef _DRV_SST26_LOCAL_H

/*******************************************************************************
 End of File
*/

