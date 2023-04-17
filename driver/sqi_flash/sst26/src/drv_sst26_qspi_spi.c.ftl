/******************************************************************************
  SST26 Driver Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sst26.c

  Summary:
    SST26 Driver Interface Definition

  Description:
    The SST26 Driver provides a interface to access the SST26 peripheral on the PIC32
    microcontroller. This file should be included in the project if SST26 driver
    functionality is needed.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2020 Microchip Technology Inc. and its subsidiaries.
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

// *****************************************************************************
// *****************************************************************************
// Section: Include Files
// *****************************************************************************
// *****************************************************************************

#include "driver/sst26/src/drv_sst26_local.h"

#include "drv_sst26_spi_interface.h"
<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == false && DRV_SST26_TX_RX_DMA == true && core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
#include "system/cache/sys_cache.h"
</#if>

/* Array to hold the commands to be sent  */
static CACHE_ALIGN uint8_t sst26Command[CACHE_ALIGNED_SIZE_GET(8)];

/* Stores Status Register value ([0]Dummy Byte, [1]Register value)*/
static CACHE_ALIGN uint8_t sst26Response[CACHE_ALIGNED_SIZE_GET(2)];

static CACHE_ALIGN uint8_t jedecID[CACHE_ALIGNED_SIZE_GET(4)] = { 0 };

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

static DRV_SST26_OBJECT gDrvSST26Obj;
static DRV_SST26_OBJECT *dObj = &gDrvSST26Obj;

/* Table mapping the Flash ID's to their sizes. */
static uint32_t gSstFlashIdSizeTable [5][2] = {
    {0x01, 0x200000}, /* 16 MBit */
    {0x41, 0x200000}, /* 16 MBit */
    {0x02, 0x400000}, /* 32 MBit */
    {0x42, 0x400000}, /* 32 MBit */
    {0x43, 0x800000}  /* 64 MBit */
};

// *****************************************************************************
// *****************************************************************************
// Section: SST26 Driver Local Functions
// *****************************************************************************
// *****************************************************************************

/* This function returns the flash size in bytes for the specified deviceId. A
 * zero is returned if the device id is not supported. */
static uint32_t DRV_SST26_GetFlashSize( uint8_t deviceId )
{
    uint8_t i = 0;

    for (i = 0U; i < 5U; i++)
    {
        if (deviceId == gSstFlashIdSizeTable[i][0])
        {
            return gSstFlashIdSizeTable[i][1];
        }
    }

    return 0;
}

static bool DRV_SST26_ResetFlash(void)
{
    dObj->transferStatus    = DRV_SST26_TRANSFER_BUSY;

    dObj->state             = DRV_SST26_STATE_WAIT_RESET_FLASH_COMPLETE;

    sst26Command[0] = (uint8_t)SST26_CMD_FLASH_RESET_ENABLE;
    dObj->transferDataObj.pTransmitData = sst26Command;

    dObj->transferDataObj.txSize = 1;

    (void) DRV_SST26_SPIWriteRead(dObj, &dObj->transferDataObj);

    while (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY)
    {
        /* Nothing to do */
    }


    dObj->transferStatus    = DRV_SST26_TRANSFER_BUSY;

    dObj->state             = DRV_SST26_STATE_WAIT_RESET_FLASH_COMPLETE;

    sst26Command[0] = (uint8_t)SST26_CMD_FLASH_RESET;
    dObj->transferDataObj.pTransmitData = sst26Command;
    dObj->transferDataObj.pReceiveData = NULL;

    dObj->transferDataObj.txSize = 1;
    dObj->transferDataObj.rxSize = 0;

    (void) DRV_SST26_SPIWriteRead(dObj, &dObj->transferDataObj);

    while (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY)
    {
        /* Nothing to do */
    }


    return true;
}

static bool DRV_SST26_WriteEnable(void)
{
    sst26Command[0] = (uint8_t)SST26_CMD_WRITE_ENABLE;
    dObj->transferDataObj.pTransmitData = sst26Command;
    dObj->transferDataObj.pReceiveData = NULL;

    dObj->transferDataObj.txSize = 1;
    dObj->transferDataObj.rxSize = 0;



    (void) DRV_SST26_SPIWriteRead(dObj, &dObj->transferDataObj);

    return true;
}

static bool lDRV_SST26_ReadStatus( void )
{
    /* Register Status will be stored in the second byte */
    sst26Response[1] = 0;
    sst26Command[0] = (uint8_t)SST26_CMD_READ_STATUS_REG;

    dObj->transferDataObj.pTransmitData = sst26Command;
    dObj->transferDataObj.txSize = 1;
    dObj->transferDataObj.pReceiveData = sst26Response;
    dObj->transferDataObj.rxSize = 2;

    (void) DRV_SST26_SPIWriteRead(dObj, &dObj->transferDataObj);

    return true;
}

static bool DRV_SST26_WriteCommandAddress( uint8_t command, uint32_t address )
{
    uint8_t nBytes = 0;

    /* Save the request */
    sst26Command[nBytes] = command;
    nBytes++;
    sst26Command[nBytes] = (uint8_t)(address >> 16);
    nBytes++;
    sst26Command[nBytes] = (uint8_t)(address >> 8);
    nBytes++;
    sst26Command[nBytes] = (uint8_t)address;
    nBytes++;

    if (command == (uint8_t)SST26_CMD_HIGH_SPEED_READ)
    {
        /* For high speed read, perform a dummy write */
        sst26Command[nBytes++] = 0xFF;
    }

    dObj->transferDataObj.pTransmitData = sst26Command;
    dObj->transferDataObj.txSize = nBytes;

    dObj->transferDataObj.pReceiveData = NULL;
    dObj->transferDataObj.rxSize = 0;

    (void) DRV_SST26_SPIWriteRead(dObj, &dObj->transferDataObj);

    return true;
}

static bool DRV_SST26_ReadData( void* rxData, uint32_t rxDataLength )
{
    dObj->transferDataObj.pTransmitData = NULL;
    dObj->transferDataObj.txSize = 0;
    dObj->transferDataObj.pReceiveData = rxData;
    dObj->transferDataObj.rxSize = rxDataLength;

    (void) DRV_SST26_SPIWriteRead(dObj, &dObj->transferDataObj);

    return true;
}

static bool DRV_SST26_WriteData( void* txData, uint32_t txDataLength, uint32_t address )
{
    dObj->transferDataObj.pTransmitData = txData;
    dObj->transferDataObj.txSize = txDataLength;
    dObj->transferDataObj.pReceiveData = NULL;
    dObj->transferDataObj.rxSize = 0;

    (void) DRV_SST26_SPIWriteRead(dObj, &dObj->transferDataObj);

    return true;
}

static bool DRV_SST26_Erase( uint8_t command, uint32_t address )
{
    bool status = false;

    dObj->transferStatus    = DRV_SST26_TRANSFER_BUSY;

    /* Save the request */
    dObj->currentCommand    = command;
    dObj->memoryAddr        = address;

    dObj->state             = DRV_SST26_STATE_ERASE;

    /* Start the transfer by submitting a Write Enable request. Further commands
     * will be issued from the interrupt context.
    */
    status = DRV_SST26_WriteEnable();

    if (status == false)
    {
        dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;
    }

    return status;
}

void DRV_SST26_Handler( void )
{
    switch(dObj->state)
    {
        case DRV_SST26_STATE_READ_DATA:
        {
            if (DRV_SST26_ReadData((void*)dObj->bufferAddr, dObj->nPendingBytes) == true)
            {
                dObj->state = DRV_SST26_STATE_WAIT_READ_COMPLETE;
            }
            else
            {
                dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;
            }
            break;
        }

        case DRV_SST26_STATE_WAIT_READ_COMPLETE:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            dObj->transferStatus = DRV_SST26_TRANSFER_COMPLETED;

            break;
        }

        case DRV_SST26_STATE_WRITE_CMD_ADDR:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            /* Send page write command and memory address */
            if (DRV_SST26_WriteCommandAddress(dObj->currentCommand,
                                               dObj->memoryAddr) == true)
            {
                dObj->state = DRV_SST26_STATE_WRITE_DATA;
            }
            else
            {
                dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;
            }
            break;
        }

        case DRV_SST26_STATE_WRITE_DATA:
        {
            if (DRV_SST26_WriteData(dObj->bufferAddr,
                                      dObj->nPendingBytes, dObj->memoryAddr) == true)
            {
                dObj->state = DRV_SST26_STATE_CHECK_ERASE_WRITE_STATUS;
            }
            else
            {
                dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;
            }
            break;
        }

        case DRV_SST26_STATE_CHECK_ERASE_WRITE_STATUS:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            /* Read the status of FLASH internal write cycle */
            if (lDRV_SST26_ReadStatus() == true)
            {
                dObj->state = DRV_SST26_STATE_WAIT_ERASE_WRITE_COMPLETE;
            }
            else
            {
                dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;
            }
            break;
        }

        case DRV_SST26_STATE_WAIT_ERASE_WRITE_COMPLETE:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            /* Check the busy bit in the status register. 0 = Ready, 1 = busy*/
            if ((sst26Response[1] & (1UL << 0)) != 0U)
            {
                /* Keep reading the status of FLASH internal write cycle */
                if (lDRV_SST26_ReadStatus() == false)
                {
                    dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;
                }
            }
            else
            {
                dObj->transferStatus = DRV_SST26_TRANSFER_COMPLETED;
            }
            break;
        }

        case DRV_SST26_STATE_ERASE:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            /* Send Erase command and memory address */
            if (DRV_SST26_WriteCommandAddress(dObj->currentCommand,
                                      dObj->memoryAddr) == true)
            {
                dObj->state = DRV_SST26_STATE_CHECK_ERASE_WRITE_STATUS;
            }
            else
            {
                dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;
            }
            break;
        }

        case DRV_SST26_STATE_UNLOCK_FLASH:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            /* Global Unprotect Flash command */
            sst26Command[0]     = (uint8_t)SST26_CMD_UNPROTECT_GLOBAL;
            dObj->transferDataObj.pTransmitData       = sst26Command;
            dObj->transferDataObj.txSize              = 1;
            dObj->transferDataObj.pReceiveData      = NULL;
            dObj->transferDataObj.rxSize                = 0;


            (void) DRV_SST26_SPIWriteRead(dObj, &dObj->transferDataObj);

            dObj->state = DRV_SST26_STATE_WAIT_UNLOCK_FLASH_COMPLETE;


            break;
        }

        case DRV_SST26_STATE_WAIT_UNLOCK_FLASH_COMPLETE:
        case DRV_SST26_STATE_WAIT_RESET_FLASH_COMPLETE:
        case DRV_SST26_STATE_WAIT_JEDEC_ID_READ_COMPLETE:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            dObj->transferStatus = DRV_SST26_TRANSFER_COMPLETED;

            break;
        }

        default:
        {
             /* Nothing to do */
            break;
        }
    }
    /* If transfer is complete, notify the application */
    if (dObj->transferStatus != DRV_SST26_TRANSFER_BUSY)
    {
        if (dObj->eventHandler != NULL) 
        {
            dObj->eventHandler(dObj->transferStatus, dObj->context);
        }
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: SST26 Driver Global Functions
// *****************************************************************************
// *****************************************************************************

bool DRV_SST26_UnlockFlash( const DRV_HANDLE handle )
{
    bool status = false;

    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY))
    {
        return status;
    }

    dObj->transferStatus    = DRV_SST26_TRANSFER_BUSY;
    dObj->currentCommand    = (uint8_t)SST26_CMD_UNPROTECT_GLOBAL;
    dObj->state             = DRV_SST26_STATE_UNLOCK_FLASH;

    /* Start the transfer by submitting a Write Enable request. Further commands
     * will be issued from the interrupt context.
    */
    status = DRV_SST26_WriteEnable();

    if (status == false)
    {
        dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;
    }

    return status;
}

bool DRV_SST26_ReadJedecId( const DRV_HANDLE handle, void* jedec_id )
{
    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY))
    {
        return false;
    }


    dObj->transferStatus    = DRV_SST26_TRANSFER_BUSY;

    dObj->state             = DRV_SST26_STATE_WAIT_JEDEC_ID_READ_COMPLETE;

    sst26Command[0]   = (uint8_t)SST26_CMD_JEDEC_ID_READ;

    dObj->transferDataObj.pTransmitData = sst26Command;
    dObj->transferDataObj.txSize = 1;
    dObj->transferDataObj.pReceiveData = jedec_id;
    dObj->transferDataObj.rxSize = 4;
    (void) DRV_SST26_SPIWriteRead(dObj, &dObj->transferDataObj);

    while (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY)
    {
        /* Nothing to do */
    }


    return true;
}

DRV_SST26_TRANSFER_STATUS DRV_SST26_TransferStatusGet( const DRV_HANDLE handle )
{
    if(handle == DRV_HANDLE_INVALID)
    {
        return DRV_SST26_TRANSFER_ERROR_UNKNOWN;
    }

    return dObj->transferStatus;
}

bool DRV_SST26_Read( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address )
{
    bool status = false;

    if( (handle == DRV_HANDLE_INVALID) ||
        (rx_data == NULL) ||
        (rx_data_length == 0U) ||
        (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY))
    {
        return status;
    }

    dObj->transferStatus    = DRV_SST26_TRANSFER_BUSY;

    /* save the request */
    dObj->nPendingBytes     = rx_data_length;
    dObj->bufferAddr        = rx_data;
    dObj->memoryAddr        = address;

    dObj->state             = DRV_SST26_STATE_READ_DATA;

    status = DRV_SST26_WriteCommandAddress((uint8_t)SST26_CMD_HIGH_SPEED_READ, address);

    if ( status == false)
    {
        dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;
    }

    return status;
}

bool DRV_SST26_PageWrite( const DRV_HANDLE handle, void *tx_data, uint32_t address )
{
    bool status = false;

    if( (handle == DRV_HANDLE_INVALID) ||
        (tx_data == NULL) ||
        (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY))
    {
        return status;
    }

    dObj->transferStatus    = DRV_SST26_TRANSFER_BUSY;

    /* save the request */
    dObj->currentCommand    = (uint8_t)SST26_CMD_PAGE_PROGRAM;
    dObj->nPendingBytes     = DRV_SST26_PAGE_SIZE;
    dObj->bufferAddr        = tx_data;
    dObj->memoryAddr        = address;

    dObj->state             = DRV_SST26_STATE_WRITE_CMD_ADDR;

    status = DRV_SST26_WriteEnable();

    if (status == false)
    {
        dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;
    }

    return status;
}

bool DRV_SST26_SectorErase( const DRV_HANDLE handle, uint32_t address )
{
    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY))
    {
        return false;
    }

    return (DRV_SST26_Erase((uint8_t)SST26_CMD_SECTOR_ERASE, address));
}

bool DRV_SST26_BulkErase( const DRV_HANDLE handle, uint32_t address )
{
    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY))
    {
        return false;
    }

    return (DRV_SST26_Erase((uint8_t)SST26_CMD_BULK_ERASE_64K, address));
}

bool DRV_SST26_ChipErase( const DRV_HANDLE handle )
{
    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY))
    {
        return false;
    }

    return (DRV_SST26_Erase((uint8_t)SST26_CMD_CHIP_ERASE, 0));
}

bool DRV_SST26_GeometryGet( const DRV_HANDLE handle, DRV_SST26_GEOMETRY *geometry )
{
    uint32_t flash_size = 0;
    bool status = true;

    if (DRV_SST26_ReadJedecId(handle, (void *)jedecID) == false)
    {
        status = false;
    }
    else
    {

        flash_size = DRV_SST26_GetFlashSize(jedecID[3]);

        if (flash_size == 0U) 
        {
            status = false;
        }        
        
        if(DRV_SST26_START_ADDRESS >= flash_size)
        {
            status = false;
        }
        else
        {

            flash_size = flash_size - DRV_SST26_START_ADDRESS;

            /* Flash size should be at-least of a Erase Block size */
            if (flash_size < DRV_SST26_ERASE_BUFFER_SIZE)
            {
                status = false;
            }
            else
            {
                /* Read block size and number of blocks */
                geometry->read_blockSize = 1;
                geometry->read_numBlocks = flash_size;

                /* Write block size and number of blocks */
                geometry->write_blockSize = DRV_SST26_PAGE_SIZE;
                geometry->write_numBlocks = (flash_size / DRV_SST26_PAGE_SIZE);

                /* Erase block size and number of blocks */
                geometry->erase_blockSize = DRV_SST26_ERASE_BUFFER_SIZE;
                geometry->erase_numBlocks = (flash_size / DRV_SST26_ERASE_BUFFER_SIZE);

                geometry->numReadRegions = 1;
                geometry->numWriteRegions = 1;
                geometry->numEraseRegions = 1;

                geometry->blockStartAddress = DRV_SST26_START_ADDRESS;
            }
        }
    }

    return status;
}

DRV_HANDLE DRV_SST26_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    if ((dObj->status != SYS_STATUS_READY) ||
        (dObj->nClients >= DRV_SST26_CLIENTS_NUMBER))
    {
        return DRV_HANDLE_INVALID;
    }

<#if DRV_SST26_INTERFACE_TYPE == "SPI_DRV">
    dObj->spiDrvHandle = DRV_SPI_Open((uint16_t)dObj->spiDrvIndex, DRV_IO_INTENT_READWRITE);
    if (dObj->spiDrvHandle != DRV_HANDLE_INVALID)
    {
        /* Register a callback with the SPI driver */
        DRV_SPI_TransferEventHandlerSet(dObj->spiDrvHandle, DRV_SST26_SPIDriverEventHandler, (uintptr_t)dObj);
    }
    else
    {
        return DRV_HANDLE_INVALID;
    }
</#if>

    /* Reset SST26 Flash device */
    if (DRV_SST26_ResetFlash() == false)
    {
        return DRV_HANDLE_INVALID;
    }

    if (((uint32_t)ioIntent & (uint32_t)DRV_IO_INTENT_WRITE) == (uint32_t)(DRV_IO_INTENT_WRITE))
    {
        /* Unlock the Flash */
        if (DRV_SST26_UnlockFlash((DRV_HANDLE)drvIndex) == false)
        {
            return DRV_HANDLE_INVALID;
        }

        while (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY)
        {
            /* Nothing to do */
        }
    }

    dObj->nClients++;

    dObj->ioIntent = ioIntent;

    return ((DRV_HANDLE)drvIndex);
}

void DRV_SST26_Close( const DRV_HANDLE handle )
{
    if ((handle != DRV_HANDLE_INVALID) &&
         (dObj->nClients > 0U))
    {
        dObj->nClients--;
    }
}

void DRV_SST26_EventHandlerSet(
    const DRV_HANDLE handle,
    const DRV_SST26_EVENT_HANDLER eventHandler,
    const uintptr_t context
)
{
    if(handle != DRV_HANDLE_INVALID)
    {
        dObj->eventHandler = eventHandler;
        dObj->context = context;
    }
}
/* MISRA C-2012 Rule 11.3, 11.8 deviated below. Deviation record ID -  
   H3_MISRAC_2012_R_11_3_DR_1 & H3_MISRAC_2012_R_11_8_DR_1*/
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:1 "MISRA C-2012 Rule 11.3" "H3_MISRAC_2012_R_11_3_DR_1" )\
(deviate:1 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1" )   
</#if>
SYS_MODULE_OBJ DRV_SST26_Initialize
(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT *const init
)
{
    DRV_SST26_INIT *sst26Init = NULL;

    /* Check if the instance has already been initialized. */
    if (dObj->inUse == true)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    dObj->status    = SYS_STATUS_UNINITIALIZED;

    /* Indicate that this object is in use */
    dObj->inUse     = true;
    dObj->nClients  = 0;

    /* Assign to the local pointer the init data passed */
    sst26Init       = (DRV_SST26_INIT *)init;

    dObj->chipSelectPin = sst26Init->chipSelectPin;

    DRV_SST26_InterfaceInit(dObj, sst26Init);

    /* De-assert Chip Select pin to begin with. */
    SYS_PORT_PinSet(dObj->chipSelectPin);

    dObj->transferStatus = DRV_SST26_TRANSFER_COMPLETED;

    dObj->status    = SYS_STATUS_READY;

    /* Return the driver index */
    return ( (SYS_MODULE_OBJ)drvIndex );
}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.3"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>    
</#if>
/* MISRAC 2012 deviation block end */

SYS_STATUS DRV_SST26_Status( const SYS_MODULE_INDEX drvIndex )
{
    /* Return the driver status */
    return (gDrvSST26Obj.status);
}
