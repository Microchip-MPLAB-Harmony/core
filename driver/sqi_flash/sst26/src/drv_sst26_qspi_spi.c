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

    for (i = 0; i < 5; i++)
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
    bool status = false;

    dObj->transferStatus    = DRV_SST26_TRANSFER_BUSY;

    dObj->state             = DRV_SST26_STATE_WAIT_RESET_FLASH_COMPLETE;

    dObj->sst26Command[0]   = SST26_CMD_FLASH_RESET_ENABLE;

    /* Assert Chip Select */
    SYS_PORT_PinClear(dObj->chipSelectPin);

    if (dObj->sst26Plib->write(&dObj->sst26Command[0], 1) == false)
    {
        /* De-assert the chip select */
        SYS_PORT_PinSet(dObj->chipSelectPin);

        dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;

        return status;
    }

    while (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY);

    /* De-assert the chip select */
    SYS_PORT_PinSet(dObj->chipSelectPin);

    dObj->transferStatus    = DRV_SST26_TRANSFER_BUSY;

    dObj->state             = DRV_SST26_STATE_WAIT_RESET_FLASH_COMPLETE;

    dObj->sst26Command[0]   = SST26_CMD_FLASH_RESET;

    /* Assert Chip Select */
    SYS_PORT_PinClear(dObj->chipSelectPin);

    status = dObj->sst26Plib->write(&dObj->sst26Command[0], 1);

    if ( status == true)
    {
        while (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY);
    }
    else
    {
        dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;
    }

    /* De-assert the chip select */
    SYS_PORT_PinSet(dObj->chipSelectPin);

    return status;
}

static bool DRV_SST26_WriteEnable(void)
{
    bool status = false;

    dObj->sst26Command[0] = SST26_CMD_WRITE_ENABLE;

    /* Assert Chip Select */
    SYS_PORT_PinClear(dObj->chipSelectPin);

    status = dObj->sst26Plib->write(&dObj->sst26Command[0], 1);

    if ( status == false)
    {
        /* De-assert the chip select */
        SYS_PORT_PinSet(dObj->chipSelectPin);
    }

    return status;
}

static bool DRV_SST26_ReadStatus( void )
{
    bool status = false;

    /* Register Status will be stored in the second byte */
    dObj->regStatus[1]      = 0;
    dObj->sst26Command[0]   = SST26_CMD_READ_STATUS_REG;

    /* Assert Chip Select */
    SYS_PORT_PinClear(dObj->chipSelectPin);

    status = dObj->sst26Plib->writeRead(&dObj->sst26Command[0], 1, &dObj->regStatus[0], 2);

    if (status == false)
    {
        /* De-assert the chip select */
        SYS_PORT_PinSet(dObj->chipSelectPin);
    }

    return status;
}

static bool DRV_SST26_WriteCommandAddress( uint8_t command, uint32_t address )
{
    bool status = false;
    uint8_t nBytes = 0;

    /* Save the request */
    dObj->sst26Command[nBytes++] = command;
    dObj->sst26Command[nBytes++] = (address >> 16);
    dObj->sst26Command[nBytes++] = (address >> 8);
    dObj->sst26Command[nBytes++] = address;

    if (command == SST26_CMD_HIGH_SPEED_READ)
    {
        /* For high speed read, perform a dummy write */
        dObj->sst26Command[nBytes++] = 0xFF;
    }

    /* Assert Chip Select */
    SYS_PORT_PinClear(dObj->chipSelectPin);

    status = dObj->sst26Plib->write(&dObj->sst26Command[0], nBytes);

    if ( status == false)
    {
        /* De-assert the chip select */
        SYS_PORT_PinSet(dObj->chipSelectPin);
    }

    return status;
}

static bool DRV_SST26_ReadData( void* rxData, uint32_t rxDataLength )
{
    bool status = false;

    /* Assert Chip Select */
    SYS_PORT_PinClear(gDrvSST26Obj.chipSelectPin);

    status = dObj->sst26Plib->read((uint8_t*)rxData, rxDataLength);

    if (status == false)
    {
        /* De-assert the chip select */
        SYS_PORT_PinSet(gDrvSST26Obj.chipSelectPin);
    }

    return status;
}

static bool DRV_SST26_WriteData( void* txData, uint32_t txDataLength, uint32_t address )
{
    bool status = false;

    status = dObj->sst26Plib->write(txData, txDataLength);

    if (status == false)
    {
        /* De-assert the chip select */
        SYS_PORT_PinSet(gDrvSST26Obj.chipSelectPin);
    }

    return status;
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

static void DRV_SST26_Handler( void )
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
            if (DRV_SST26_ReadStatus() == true)
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
            if (dObj->regStatus[1] & (1 << 0))
            {
                /* Keep reading the status of FLASH internal write cycle */
                if (DRV_SST26_ReadStatus() == false)
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
            dObj->currentCommand = SST26_CMD_UNPROTECT_GLOBAL;

            /* Assert Chip Select and Send Global Unprotect Flash command */
            SYS_PORT_PinClear(dObj->chipSelectPin);

            if (dObj->sst26Plib->write(&dObj->currentCommand, 1) == true)
            {
                dObj->state = DRV_SST26_STATE_WAIT_UNLOCK_FLASH_COMPLETE;
            }
            else
            {
                dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;

                /* De-assert the chip select */
                SYS_PORT_PinSet(dObj->chipSelectPin);
            }
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
            break;
        }
    }
}

/* This function will be called by SPI/QSPI PLIB when transfer is completed */
static void sst26EventHandler(uintptr_t context )
{
    DRV_SST26_Handler();

    /* If transfer is complete, notify the application */
    if (dObj->transferStatus != DRV_SST26_TRANSFER_BUSY)
    {
        if (dObj->eventHandler)
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

bool DRV_SST26_ReadJedecId( const DRV_HANDLE handle, void *jedec_id )
{
    bool status = false;

    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY))
    {
        return status;
    }

    /* De-assert the chip select */
    SYS_PORT_PinSet(dObj->chipSelectPin);

    dObj->transferStatus    = DRV_SST26_TRANSFER_BUSY;

    dObj->state             = DRV_SST26_STATE_WAIT_JEDEC_ID_READ_COMPLETE;

    dObj->sst26Command[0]   = SST26_CMD_JEDEC_ID_READ;

    /* Assert Chip Select */
    SYS_PORT_PinClear(dObj->chipSelectPin);

    status = dObj->sst26Plib->writeRead(&dObj->sst26Command[0], 1, jedec_id, 4);

    if (status == true)
    {
        while (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY);
    }
    else
    {
        dObj->transferStatus = DRV_SST26_TRANSFER_ERROR_UNKNOWN;
    }

    /* De-assert the chip select */
    SYS_PORT_PinSet(dObj->chipSelectPin);

    return status;
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
        (rx_data_length == 0) ||
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

    status = DRV_SST26_WriteCommandAddress(SST26_CMD_HIGH_SPEED_READ, address);

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
    dObj->currentCommand    = SST26_CMD_PAGE_PROGRAM;
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

    return (DRV_SST26_Erase(SST26_CMD_SECTOR_ERASE, address));
}

bool DRV_SST26_BulkErase( const DRV_HANDLE handle, uint32_t address )
{
    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY))
    {
        return false;
    }

    return (DRV_SST26_Erase(SST26_CMD_BULK_ERASE_64K, address));
}

bool DRV_SST26_ChipErase( const DRV_HANDLE handle )
{
    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY))
    {
        return false;
    }

    return (DRV_SST26_Erase(SST26_CMD_CHIP_ERASE, 0));
}

bool DRV_SST26_GeometryGet( const DRV_HANDLE handle, DRV_SST26_GEOMETRY *geometry )
{
    uint32_t flash_size = 0;
    uint8_t  jedec_id[4] = { 0 };

    if (DRV_SST26_ReadJedecId(handle, (void *)&jedec_id) == false)
    {
        return false;
    }

    flash_size = DRV_SST26_GetFlashSize(jedec_id[3]);

    if ((flash_size == 0) ||
        (DRV_SST26_START_ADDRESS >= flash_size))
    {
        return false;
    }

    flash_size = flash_size - DRV_SST26_START_ADDRESS;

    /* Flash size should be at-least of a Erase Block size */
    if (flash_size < DRV_SST26_ERASE_BUFFER_SIZE)
    {
        return false;
    }

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

    return true;
}

DRV_HANDLE DRV_SST26_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    if ((dObj->status != SYS_STATUS_READY) ||
        (dObj->nClients >= DRV_SST26_CLIENTS_NUMBER))
    {
        return DRV_HANDLE_INVALID;
    }

    /* Reset SST26 Flash device */
    if (DRV_SST26_ResetFlash() == false)
    {
        return DRV_HANDLE_INVALID;
    }

    if ((ioIntent & DRV_IO_INTENT_WRITE) == (DRV_IO_INTENT_WRITE))
    {
        /* Unlock the Flash */
        if (DRV_SST26_UnlockFlash((DRV_HANDLE)drvIndex) == false)
        {
            return DRV_HANDLE_INVALID;
        }

        while (dObj->transferStatus == DRV_SST26_TRANSFER_BUSY);
    }

    dObj->nClients++;

    dObj->ioIntent = ioIntent;

    return ((DRV_HANDLE)drvIndex);
}

void DRV_SST26_Close( const DRV_HANDLE handle )
{
    if ((handle != DRV_HANDLE_INVALID) &&
         (dObj->nClients > 0))
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

    /* Initialize the attached memory device functions */
    dObj->sst26Plib = sst26Init->sst26Plib;

    dObj->chipSelectPin = sst26Init->chipSelectPin;

    dObj->sst26Plib->callbackRegister(sst26EventHandler, (uintptr_t)NULL);

    /* De-assert Chip Select pin to begin with. */
    SYS_PORT_PinSet(dObj->chipSelectPin);

    dObj->transferStatus = DRV_SST26_TRANSFER_COMPLETED;

    dObj->status    = SYS_STATUS_READY;

    /* Return the driver index */
    return ( (SYS_MODULE_OBJ)drvIndex );
}

SYS_STATUS DRV_SST26_Status( const SYS_MODULE_INDEX drvIndex )
{
    /* Return the driver status */
    return (gDrvSST26Obj.status);
}
