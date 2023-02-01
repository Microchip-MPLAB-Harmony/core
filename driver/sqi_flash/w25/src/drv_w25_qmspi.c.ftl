/******************************************************************************
  W25 Driver Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_w25.c

  Summary:
    W25 Driver Interface Definition

  Description:
    The W25 Driver provides a interface to access the W25 peripheral on the PIC32
    microcontroller. This file should be included in the project if W25 driver
    functionality is needed.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2023 Microchip Technology Inc. and its subsidiaries.
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

#include "driver/w25/src/drv_w25_local.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

#define ADDR_24_BIT_MASK 0xFFFFFFU

static DRV_W25_OBJECT gDrvW25Obj;
static DRV_W25_OBJECT *dObj = &gDrvW25Obj;

static QMSPI_XFER_T qmspiXfer = { 0 };
static QMSPI_DESCRIPTOR_XFER_T qmspiDescXfer = { 0 };

/* Table mapping the Flash ID's to their sizes. */
static uint32_t gSstFlashIdSizeTable [11][2] = {
    {0x10, 0x10000},   /* 512 KBit */
    {0x11, 0x20000},   /* 1 MBit */
    {0x12, 0x40000},   /* 2 MBit */
    {0x13, 0x80000},   /* 4 MBit */
    {0x14, 0x100000},  /* 8 MBit */
    {0x15, 0x200000},  /* 16 MBit */
    {0x16, 0x400000},  /* 32 MBit */
    {0x17, 0x800000},  /* 64 MBit */
    {0x18, 0x1000000}, /* 128 MBit */
    {0x19, 0x2000000}, /* 256 MBit */
    {0x20, 0x4000000}  /* 512 MBit */
};

// *****************************************************************************
// *****************************************************************************
// Section: W25 Driver Local Functions
// *****************************************************************************
// *****************************************************************************

/* This function returns the flash size in bytes for the specified deviceId. A
 * zero is returned if the device id is not supported. */
static uint32_t DRV_W25_GetFlashSize( uint8_t deviceId )
{
    uint8_t i = 0;

    for (i = 0; i < 11; i++)
    {
        if (deviceId == gSstFlashIdSizeTable[i][0])
        {
            return gSstFlashIdSizeTable[i][1];
        }
    }

    return 0;
}

static bool DRV_W25_ResetFlash(void)
{
    bool status = false;

    memset((void *)&qmspiXfer, 0, sizeof(QMSPI_XFER_T));

    qmspiXfer.command = W25_CMD_FLASH_RESET_ENABLE;
    qmspiXfer.qmspi_ifc_mode = SINGLE_BIT_SPI;

    if (dObj->w25Plib->Write(&qmspiXfer, NULL, 0) == false)
    {
        return status;
    }

    qmspiXfer.command = W25_CMD_FLASH_RESET;
    qmspiXfer.qmspi_ifc_mode = SINGLE_BIT_SPI;

    status  = dObj->w25Plib->Write(&qmspiXfer, NULL, 0);

    return status;
}

static bool DRV_W25_WriteEnable(void)
{
    bool status = false;

    memset((void *)&qmspiXfer, 0, sizeof(QMSPI_XFER_T));

    qmspiXfer.command = W25_CMD_WRITE_ENABLE;
    qmspiXfer.qmspi_ifc_mode = SINGLE_BIT_SPI;

    status  = dObj->w25Plib->Write(&qmspiXfer, NULL, 0);

    return status;
}

// *****************************************************************************
// *****************************************************************************
// Section: W25 Driver Global Functions
// *****************************************************************************
// *****************************************************************************

bool DRV_W25_UnlockFlash( const DRV_HANDLE handle )
{
    bool status = false;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    if (DRV_W25_WriteEnable() == false)
    {
        return status;
    }

    memset((void *)&qmspiXfer, 0, sizeof(QMSPI_XFER_T));

    qmspiXfer.command = W25_CMD_UNPROTECT_GLOBAL;
    qmspiXfer.qmspi_ifc_mode = SINGLE_BIT_SPI;

    status  = dObj->w25Plib->Write(&qmspiXfer, NULL, 0);

    return status;
}

bool DRV_W25_ReadJedecId( const DRV_HANDLE handle, void *jedec_id)
{
    bool status = false;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    memset((void *)&qmspiXfer, 0, sizeof(QMSPI_XFER_T));

    qmspiXfer.command = W25_CMD_JEDEC_ID_READ;
    qmspiXfer.qmspi_ifc_mode = SINGLE_BIT_SPI;

    status  = dObj->w25Plib->Read(&qmspiXfer, jedec_id, 3);

    return status;
}

bool DRV_W25_ReadStatus( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length )
{
    bool status = false;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    memset((void *)&qmspiXfer, 0, sizeof(QMSPI_XFER_T));

    qmspiXfer.command = W25_CMD_READ_STATUS_REG;
    qmspiXfer.qmspi_ifc_mode = SINGLE_BIT_SPI;

    status  = dObj->w25Plib->Read(&qmspiXfer, rx_data, rx_data_length);

    return status;
}

DRV_W25_TRANSFER_STATUS DRV_W25_TransferStatusGet( const DRV_HANDLE handle )
{
    DRV_W25_TRANSFER_STATUS status = DRV_W25_TRANSFER_ERROR_UNKNOWN;

    uint8_t reg_status = 0;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    if (gDrvW25Obj.curOpType == DRV_W25_OPERATION_TYPE_READ )
    {
        return DRV_W25_TRANSFER_COMPLETED;
    }

    if (DRV_W25_ReadStatus(handle, (void *)&reg_status, 1) == false)
    {
        return status;
    }

    if(reg_status & (1<<0))
        status = DRV_W25_TRANSFER_BUSY;
    else
        status = DRV_W25_TRANSFER_COMPLETED;

    return status;
}

bool DRV_W25_Read( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address )
{
    bool status = false;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    memset((void *)&qmspiDescXfer, 0, sizeof(QMSPI_DESCRIPTOR_XFER_T));

    qmspiDescXfer.command = W25_CMD_FAST_READ_QUAD_IO;
    qmspiDescXfer.qmspi_ifc_mode = QUAD_IO;
    qmspiDescXfer.address = address;
    qmspiDescXfer.ldma_enable = true;
    qmspiDescXfer.ldma_channel_num = QMSPI_LDMA_CHANNEL_0;
	if (address > ADDR_24_BIT_MASK)
	{
        qmspiDescXfer.num_of_dummy_byte = 2;
		qmspiDescXfer.address_32_bit_en = true;
	}
	else
	{
        qmspiDescXfer.num_of_dummy_byte = 3;
    }

    status = dObj->w25Plib->DMATransferRead(&qmspiDescXfer, rx_data, rx_data_length);

    gDrvW25Obj.curOpType = DRV_W25_OPERATION_TYPE_READ;

    return status;
}

bool DRV_W25_PageWrite( const DRV_HANDLE handle, void *tx_data, uint32_t address )
{
    bool status = false;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    if (DRV_W25_WriteEnable() == false)
    {
        return status;
    }

    memset((void *)&qmspiDescXfer, 0, sizeof(QMSPI_DESCRIPTOR_XFER_T));

    qmspiDescXfer.command = W25_CMD_QUAD_INPUT_PAGE_PROGRAM;
    qmspiDescXfer.qmspi_ifc_mode = QUAD_OUTPUT;
    qmspiDescXfer.address = address;
    qmspiDescXfer.ldma_enable = true;
    qmspiDescXfer.ldma_channel_num = QMSPI_LDMA_CHANNEL_0;
	if (address > ADDR_24_BIT_MASK)
	{
		qmspiDescXfer.address_32_bit_en = true;
	}

    status = dObj->w25Plib->DMATransferWrite(&qmspiDescXfer, tx_data, DRV_W25_PAGE_SIZE);

    gDrvW25Obj.curOpType = DRV_W25_OPERATION_TYPE_WRITE;

    return status;
}

static bool DRV_W25_Erase(uint8_t instruction, uint32_t address , bool address_enable)
{
    bool status = false;

    if (DRV_W25_WriteEnable() == false)
    {
        return status;
    }

    memset((void *)&qmspiXfer, 0, sizeof(QMSPI_XFER_T));

    qmspiXfer.command = instruction;
    qmspiXfer.qmspi_ifc_mode = SINGLE_BIT_SPI;
    qmspiXfer.address_enable = address_enable;
    qmspiXfer.address = address;
	if (address > ADDR_24_BIT_MASK)
	{
		qmspiXfer.address_32_bit_en = true;
	}

    status = dObj->w25Plib->Write(&qmspiXfer, NULL, 0);

    gDrvW25Obj.curOpType = DRV_W25_OPERATION_TYPE_ERASE;

    return status;
}

bool DRV_W25_SectorErase( const DRV_HANDLE handle, uint32_t address )
{
    if (handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    return (DRV_W25_Erase(W25_CMD_SECTOR_ERASE, address, true));
}

bool DRV_W25_BlockErase( const DRV_HANDLE handle, uint32_t address )
{
    if (handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    return (DRV_W25_Erase(W25_CMD_BLOCK_ERASE_64K, address, true));
}

bool DRV_W25_ChipErase( const DRV_HANDLE handle )
{
    if (handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    return (DRV_W25_Erase(W25_CMD_CHIP_ERASE, 0, false));
}

bool DRV_W25_GeometryGet( const DRV_HANDLE handle, DRV_W25_GEOMETRY *geometry )
{
    uint32_t flash_size = 0;
    uint8_t  jedec_id[3] = { 0 };

    if (DRV_W25_ReadJedecId(handle, (void *)&jedec_id[0]) == false)
    {
        return false;
    }

    flash_size = DRV_W25_GetFlashSize(jedec_id[2]);

    if ((flash_size == 0) ||
        (DRV_W25_START_ADDRESS >= flash_size))
    {
        return false;
    }

    flash_size = flash_size - DRV_W25_START_ADDRESS;

    /* Flash size should be at-least of a Erase Block size */
    if (flash_size < DRV_W25_ERASE_BUFFER_SIZE)
    {
        return false;
    }

    /* Read block size and number of blocks */
    geometry->read_blockSize = 1;
    geometry->read_numBlocks = flash_size;

    /* Write block size and number of blocks */
    geometry->write_blockSize = DRV_W25_PAGE_SIZE;
    geometry->write_numBlocks = (flash_size / DRV_W25_PAGE_SIZE);

    /* Erase block size and number of blocks */
    geometry->erase_blockSize = DRV_W25_ERASE_BUFFER_SIZE;
    geometry->erase_numBlocks = (flash_size / DRV_W25_ERASE_BUFFER_SIZE);

    geometry->numReadRegions = 1;
    geometry->numWriteRegions = 1;
    geometry->numEraseRegions = 1;

    geometry->blockStartAddress = DRV_W25_START_ADDRESS;

    return true;
}

DRV_HANDLE DRV_W25_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    if ((dObj->status != SYS_STATUS_READY) ||
        (dObj->nClients >= DRV_W25_CLIENTS_NUMBER))
    {
        return DRV_HANDLE_INVALID;
    }

    /* Reset W25 Flash device */
    if (DRV_W25_ResetFlash() == false)
    {
        return DRV_HANDLE_INVALID;
    }

    if ((ioIntent & DRV_IO_INTENT_WRITE) == (DRV_IO_INTENT_WRITE))
    {
        /* Unlock the Flash */
        if (DRV_W25_UnlockFlash((DRV_HANDLE)drvIndex) == false)
        {
            return DRV_HANDLE_INVALID;
        }
    }

    dObj->nClients++;

    dObj->ioIntent = ioIntent;

    return ((DRV_HANDLE)drvIndex);
}

void DRV_W25_Close( const DRV_HANDLE handle )
{
    if ( (handle != DRV_HANDLE_INVALID) &&
         (dObj->nClients > 0))
    {
        dObj->nClients--;
    }
}

SYS_MODULE_OBJ DRV_W25_Initialize
(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT *const init
)
{
    DRV_W25_INIT *w25Init = NULL;

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
    w25Init       = (DRV_W25_INIT *)init;

    /* Initialize the attached memory device functions */
    dObj->w25Plib = w25Init->w25Plib;

    dObj->status    = SYS_STATUS_READY;

    /* Return the driver index */
    return ( (SYS_MODULE_OBJ)drvIndex );
}

SYS_STATUS DRV_W25_Status( const SYS_MODULE_INDEX drvIndex )
{
    /* Return the driver status */
    return (gDrvW25Obj.status);
}
