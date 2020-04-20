/******************************************************************************
  DRV_AT24 Library Interface Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_at24.c

  Summary:
    AT24 EEPROM Driver Library Interface implementation

  Description:
    The AT24 Library provides a interface to access the AT24 external EEPROM.
    This file implements the AT24 Library interface.
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

// *****************************************************************************
// *****************************************************************************
// Section: Include Files
// *****************************************************************************
// *****************************************************************************
#include "configuration.h"
#include "driver/at24/drv_at24.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

/* This is the driver instance object array. */
static DRV_AT24_OBJ gDrvAT24Obj;

// *****************************************************************************
// *****************************************************************************
// Section: DRV_AT24 Driver Local Functions
// *****************************************************************************
// *****************************************************************************

/**
  * Submits a dummy I2C request to read the status of EEPROM internal write.
  * Returns true if the requested is accepted, false otherwise.
  */
static uint8_t _DRV_AT24_ReadStatus(void)
{
    gDrvAT24Obj.writeBuffer[0] = 0x00;

    /* Submit a dummy write to check internal write cycle status */
    if (gDrvAT24Obj.i2cPlib->write(gDrvAT24Obj.slaveAddress, \
            gDrvAT24Obj.writeBuffer, 1) == true)
    {
        return true;
    }

    return false;
}

static bool _DRV_AT24_Write(
    void* txData,
    uint32_t txDataLength,
    uint32_t address
)
{
    bool isRequestAccepted = false;
    uint32_t nTransferBytes = 0;
    uint32_t nBytes = 0;
    uint16_t slaveAddr;
    uint16_t i;

    if ((address + txDataLength) > gDrvAT24Obj.flashSize)
    {
        /* Writing past end of flash results in error */
        return isRequestAccepted;
    }

    gDrvAT24Obj.transferStatus = DRV_AT24_TRANSFER_STATUS_BUSY;

    /* Calculate the max number of bytes that can be written in the current page */
    nTransferBytes = gDrvAT24Obj.pageSize - (address % gDrvAT24Obj.pageSize);

    /* Check if the pending bytes are greater than nTransferBytes */
    nTransferBytes = txDataLength >= nTransferBytes? nTransferBytes: txDataLength;

    slaveAddr = gDrvAT24Obj.slaveAddress;
    /* Frame the EEPROM address */
    if (gDrvAT24Obj.flashSize > 131072)    /* For 18-bit address */
    {
        slaveAddr |= ((unsigned char*)&address)[2] & 0x02;
    }
    if (gDrvAT24Obj.flashSize > 65536)     /* For 17-bit address */
    {
        slaveAddr |= ((unsigned char*)&address)[2] & 0x01;
    }
    if (gDrvAT24Obj.flashSize > 256)       /* For 16-bit address */
    {
        gDrvAT24Obj.writeBuffer[nBytes++] = (address & 0x0000FF00) >> 8;
    }
    /* For 8-bit address */
    gDrvAT24Obj.writeBuffer[nBytes++] = (address & 0x000000FF);

    for (i = 0 ; i < nTransferBytes; i++)
    {
        gDrvAT24Obj.writeBuffer[nBytes + i] = ((uint8_t*)txData)[i];
    }

    gDrvAT24Obj.nextMemoryAddr = address + nTransferBytes;
    gDrvAT24Obj.nextBufferAddr = (uint8_t *)((uint8_t*)txData + nTransferBytes);
    gDrvAT24Obj.nPendingBytes = txDataLength - nTransferBytes;

    gDrvAT24Obj.command = DRV_AT24_CMD_WRITE;

    /* Submit a write request to I2C PLIB */
    if (gDrvAT24Obj.i2cPlib->write(slaveAddr, \
            (uint8_t*)gDrvAT24Obj.writeBuffer, (nBytes + nTransferBytes)) == true)
    {
        isRequestAccepted = true;
    }
    else
    {
        gDrvAT24Obj.transferStatus = DRV_AT24_TRANSFER_STATUS_ERROR;
    }

    return isRequestAccepted;
}

static void _DRV_AT24_Handler(DRV_AT24_I2C_ERROR transferStatus)
{
    switch(gDrvAT24Obj.command)
    {
        case DRV_AT24_CMD_WRITE:
            if (transferStatus == DRV_AT24_I2C_ERROR_NONE)
            {
                /* Read the status of EEPROM internal write cycle */
                if (_DRV_AT24_ReadStatus() == false)
                {
                    gDrvAT24Obj.transferStatus = DRV_AT24_TRANSFER_STATUS_ERROR;
                }
                else
                {
                    gDrvAT24Obj.command = DRV_AT24_CMD_WAIT_WRITE_COMPLETE;
                }
            }
            else
            {
                gDrvAT24Obj.transferStatus = DRV_AT24_TRANSFER_STATUS_ERROR;
            }
            break;
        case DRV_AT24_CMD_WAIT_WRITE_COMPLETE:
            if (transferStatus == DRV_AT24_I2C_ERROR_NONE)
            {
                /* Internal write complete. Now check if more data pending */
                if (gDrvAT24Obj.nPendingBytes)
                {
                    if (_DRV_AT24_Write(gDrvAT24Obj.nextBufferAddr,
                            gDrvAT24Obj.nPendingBytes,
                            gDrvAT24Obj.nextMemoryAddr) == false)
                    {
                        gDrvAT24Obj.transferStatus = DRV_AT24_TRANSFER_STATUS_ERROR;
                    }
                }
                else
                {
                    gDrvAT24Obj.transferStatus = DRV_AT24_TRANSFER_STATUS_COMPLETED;
                }
            }
            else
            {
                /* Keep reading the status of EEPROM internal write cycle */
                if (_DRV_AT24_ReadStatus() == false)
                {
                    gDrvAT24Obj.transferStatus = DRV_AT24_TRANSFER_STATUS_ERROR;
                }
            }
            break;
        case DRV_AT24_CMD_READ:
            if (transferStatus == DRV_AT24_I2C_ERROR_NONE)
            {
                gDrvAT24Obj.transferStatus = DRV_AT24_TRANSFER_STATUS_COMPLETED;
            }
            else
            {
                gDrvAT24Obj.transferStatus = DRV_AT24_TRANSFER_STATUS_ERROR;
            }

            break;
        default:
            break;
    }
}

/* This function will be called by I2C PLIB when transfer is completed */
static void _I2CEventHandler(uintptr_t context )
{
    _DRV_AT24_Handler(gDrvAT24Obj.i2cPlib->errorGet());

    /* If transfer is complete, notify the application */
    if (gDrvAT24Obj.transferStatus != DRV_AT24_TRANSFER_STATUS_BUSY)
    {
        if (gDrvAT24Obj.eventHandler)
        {
            gDrvAT24Obj.eventHandler(gDrvAT24Obj.transferStatus, gDrvAT24Obj.context);
        }
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: DRV_AT24 Driver Global Functions
// *****************************************************************************
// *****************************************************************************

SYS_MODULE_OBJ DRV_AT24_Initialize(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT * const init
)
{
    DRV_AT24_INIT *at24Init = (DRV_AT24_INIT *)init;

    /* Validate the request */
    if(drvIndex >= DRV_AT24_INSTANCES_NUMBER)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    if(gDrvAT24Obj.inUse == true)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    gDrvAT24Obj.status                     = SYS_STATUS_UNINITIALIZED;
    gDrvAT24Obj.inUse                      = true;
    gDrvAT24Obj.nClients                   = 0;
    gDrvAT24Obj.transferStatus             = DRV_AT24_TRANSFER_STATUS_ERROR;

    gDrvAT24Obj.i2cPlib                    = at24Init->i2cPlib;
    gDrvAT24Obj.slaveAddress               = at24Init->slaveAddress;
    gDrvAT24Obj.pageSize                   = at24Init->pageSize;
    gDrvAT24Obj.flashSize                  = at24Init->flashSize;
    gDrvAT24Obj.nClientsMax                = at24Init->numClients;
    gDrvAT24Obj.blockStartAddress          = at24Init->blockStartAddress;

    gDrvAT24Obj.eventHandler               = NULL;
    gDrvAT24Obj.context                    = 0;

    gDrvAT24Obj.i2cPlib->callbackRegister(_I2CEventHandler, (uintptr_t)NULL);

    /* Update the status */
    gDrvAT24Obj.status                     = SYS_STATUS_READY;

    /* Return the object structure */
    return ( (SYS_MODULE_OBJ)drvIndex );

}

SYS_STATUS DRV_AT24_Status( const SYS_MODULE_INDEX drvIndex )
{
    /* Return the driver status */
    return (gDrvAT24Obj.status);
}

DRV_HANDLE DRV_AT24_Open(
    const SYS_MODULE_INDEX drvIndex,
    const DRV_IO_INTENT ioIntent
)
{
    /* Validate the request */
    if (drvIndex >= DRV_AT24_INSTANCES_NUMBER)
    {
        return DRV_HANDLE_INVALID;
    }

    if((gDrvAT24Obj.status != SYS_STATUS_READY) || \
            (gDrvAT24Obj.inUse == false) || \
            (gDrvAT24Obj.nClients >= gDrvAT24Obj.nClientsMax))
    {
        return DRV_HANDLE_INVALID;
    }

    gDrvAT24Obj.nClients++;

    return ((DRV_HANDLE)0);
}

void DRV_AT24_Close( const DRV_HANDLE handle )
{
    if((handle != DRV_HANDLE_INVALID) && (handle == 0))
    {
        gDrvAT24Obj.nClients--;
    }
}

void DRV_AT24_EventHandlerSet(
    const DRV_HANDLE handle,
    const DRV_AT24_EVENT_HANDLER eventHandler,
    const uintptr_t context
)
{
    if((handle != DRV_HANDLE_INVALID) && (handle == 0) && \
            gDrvAT24Obj.transferStatus != DRV_AT24_TRANSFER_STATUS_BUSY)
    {
        gDrvAT24Obj.eventHandler = eventHandler;
        gDrvAT24Obj.context = context;
    }
}

bool DRV_AT24_Read(
    const DRV_HANDLE handle,
    void* rxData,
    uint32_t rxDataLength,
    uint32_t address
)
{
    bool isRequestAccepted = false;
    uint32_t nBytes = 0;
    uint16_t slaveAddr;

    if((handle == DRV_HANDLE_INVALID) || (handle > 0) || (rxData == NULL) || \
            (rxDataLength == 0) || (gDrvAT24Obj.transferStatus == DRV_AT24_TRANSFER_STATUS_BUSY))
    {
        return isRequestAccepted;
    }

    if ((address + rxDataLength) > gDrvAT24Obj.flashSize)
    {
        /* Writing past end of flash results in error */
        return isRequestAccepted;
    }

    gDrvAT24Obj.transferStatus = DRV_AT24_TRANSFER_STATUS_BUSY;

    /* Frame the EEPROM address */
    slaveAddr = gDrvAT24Obj.slaveAddress;
    if (gDrvAT24Obj.flashSize > 131072)    /* For 18-bit address */
    {
        slaveAddr |= ((unsigned char*)&address)[2] & 0x02;
    }
    if (gDrvAT24Obj.flashSize > 65536)     /* For 17-bit address */
    {
        slaveAddr |= ((unsigned char*)&address)[2] & 0x01;
    }
    if (gDrvAT24Obj.flashSize > 256)       /* For 16-bit address */
    {
        gDrvAT24Obj.writeBuffer[nBytes++] = (address & 0x0000FF00) >> 8;
    }
    /* For 8-bit address */
    gDrvAT24Obj.writeBuffer[nBytes++] = (address & 0x000000FF);

    gDrvAT24Obj.command = DRV_AT24_CMD_READ;

    if(gDrvAT24Obj.i2cPlib->writeRead(slaveAddr, \
            (uint8_t*)gDrvAT24Obj.writeBuffer, nBytes, rxData, rxDataLength) == true)
    {
        isRequestAccepted = true;
    }
    else
    {
        gDrvAT24Obj.transferStatus = DRV_AT24_TRANSFER_STATUS_ERROR;
    }

    return isRequestAccepted;
}

bool DRV_AT24_Write(
    const DRV_HANDLE handle,
    void* txData,
    uint32_t txDataLength,
    uint32_t address
)
{
    if((handle != DRV_HANDLE_INVALID) && (handle == 0) && (txData != NULL) \
            && (txDataLength != 0) && (gDrvAT24Obj.transferStatus != DRV_AT24_TRANSFER_STATUS_BUSY))
    {
        return _DRV_AT24_Write(txData, txDataLength, address);
    }
    else
    {
        return false;
    }
}

bool DRV_AT24_PageWrite(const DRV_HANDLE handle, void *txData, uint32_t address )
{
    return DRV_AT24_Write(handle, txData, gDrvAT24Obj.pageSize, address );
}

DRV_AT24_TRANSFER_STATUS DRV_AT24_TransferStatusGet(const DRV_HANDLE handle)
{
    if((handle != DRV_HANDLE_INVALID) && (handle == 0))
    {
        return gDrvAT24Obj.transferStatus;
    }
    else
    {
        return DRV_AT24_TRANSFER_STATUS_ERROR;
    }
}

bool DRV_AT24_GeometryGet(const DRV_HANDLE handle, DRV_AT24_GEOMETRY *geometry)
{
    uint32_t flash_size = 0;

    if((handle == DRV_HANDLE_INVALID) || (handle > 0))
    {
        return false;
    }

    flash_size = gDrvAT24Obj.flashSize;

    if ((flash_size == 0) ||
        (gDrvAT24Obj.blockStartAddress >= flash_size))
    {
        return false;
    }

    flash_size = flash_size - gDrvAT24Obj.blockStartAddress;

    /* Flash size should be at-least of a Write Block size */
    if (flash_size < gDrvAT24Obj.pageSize)
    {
        return false;
    }

    /* Read block size and number of blocks */
    geometry->readBlockSize = 1;
    geometry->readNumBlocks = flash_size;

    /* Write block size and number of blocks */
    geometry->writeBlockSize = gDrvAT24Obj.pageSize;
    geometry->writeNumBlocks = (flash_size / gDrvAT24Obj.pageSize);

    /* Erase block size and number of blocks */
    geometry->eraseBlockSize = 1;
    geometry->eraseNumBlocks = flash_size;

    /* Number of regions */
    geometry->readNumRegions = 1;
    geometry->writeNumRegions = 1;
    geometry->eraseNumRegions = 1;

    /* Block start address */
    geometry->blockStartAddress = gDrvAT24Obj.blockStartAddress;

    return true;
}
