/******************************************************************************
  DRV_AT25M Library Interface Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_at25m.c

  Summary:
    AT25M EEPROM Driver Library Interface implementation

  Description:
    The AT25M Library provides a interface to access the AT25M external EEPROM.
    This file implements the AT25M Library interface.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
Copyright (c) 2018 released Microchip Technology Inc. All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED AS IS WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR
CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF
SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
*******************************************************************************/
//DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Include Files
// *****************************************************************************
// *****************************************************************************
#include "configuration.h"
#include <string.h>
#include "drv_at25m.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

/* This is the driver instance object array. */
DRV_AT25M_OBJ gDrvAT25MObj;


// *****************************************************************************
// *****************************************************************************
// Section: DRV_AT25M Driver Local Functions
// *****************************************************************************
// *****************************************************************************

static bool _DRV_AT25M_WriteEnable(void)
{
    bool status = false;

    gDrvAT25MObj.at25mCommand[0] = DRV_AT25M_CMD_WRITE_ENABLE;

    /* Assert Chip Select */
    SYS_PORT_PinClear(gDrvAT25MObj.chipSelectPin);

    if(gDrvAT25MObj.spiPlib->write(gDrvAT25MObj.at25mCommand, 1) == true)
    {
        while(gDrvAT25MObj.spiPlib->isBusy() == true);
        status = true;
    }

    /* De-assert the chip select */
    SYS_PORT_PinSet(gDrvAT25MObj.chipSelectPin);

    return status;
}

static uint8_t _DRV_AT25M_ReadStatus(void)
{
    uint8_t status = 0x01;

    gDrvAT25MObj.at25mCommand[0] = DRV_AT25M_CMD_READ_STATUS_REG;

    /* Assert Chip Select */
    SYS_PORT_PinClear(gDrvAT25MObj.chipSelectPin);

    if(gDrvAT25MObj.spiPlib->writeRead(gDrvAT25MObj.at25mCommand, 1, &gDrvAT25MObj.at25mCommand[2], 2 ) == true)
    {
        while(gDrvAT25MObj.spiPlib->isBusy() == true);
        status = gDrvAT25MObj.at25mCommand[3];
    }

    /* De-assert the chip select */
    SYS_PORT_PinSet(gDrvAT25MObj.chipSelectPin);

    return status;
}

/* This function will be called by SPI PLIB when transfer is completed */
static void _SPIEventHandler(uintptr_t context )
{
    /* De-assert the chip select */
    SYS_PORT_PinSet(gDrvAT25MObj.chipSelectPin);

    if (gDrvAT25MObj.spiPlib->errorGet() != DRV_AT25M_SPI_ERROR_NONE)
    {
        gDrvAT25MObj.transferStatus = DRV_AT25M_TRANSFER_ERROR;
    }
    else if ((DRV_AT25M_CMD)context == DRV_AT25M_CMD_READ)
    {
        gDrvAT25MObj.transferStatus = DRV_AT25M_TRANSFER_COMPLETED;
    }
    else
    {
        /* Even though write command along with the content has been transmitted by SPI,
           it will take some time to complete the write  operation, so don't update the
           transfer status to complete here. Transfer status for write case will be
           updated in "DRV_AT25M_TransferStatusGet" function */
    }
    gDrvAT25MObj.spiPlib->callbackRegister(NULL, (uintptr_t)NULL);
}


// *****************************************************************************
// *****************************************************************************
// Section: DRV_AT25M Driver Global Functions
// *****************************************************************************
// *****************************************************************************

SYS_MODULE_OBJ DRV_AT25M_Initialize( const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT * const init)
{
    DRV_AT25M_INIT *at25mInit = (DRV_AT25M_INIT *)init;

    /* Validate the request */
    if(drvIndex >= DRV_AT25M_INSTANCES_NUMBER)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    if(gDrvAT25MObj.inUse == true)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    gDrvAT25MObj.status                = SYS_STATUS_UNINITIALIZED;

    gDrvAT25MObj.inUse                 = true;
    gDrvAT25MObj.nClients              = 0;
    gDrvAT25MObj.transferStatus        = DRV_AT25M_TRANSFER_ERROR;
    gDrvAT25MObj.writeCompleted        = true;

    gDrvAT25MObj.spiPlib               = at25mInit->spiPlib;
    gDrvAT25MObj.nClientsMax           = at25mInit->numClients;
    gDrvAT25MObj.blockStartAddress     = at25mInit->blockStartAddress;
    gDrvAT25MObj.chipSelectPin         = at25mInit->chipSelectPin;
    gDrvAT25MObj.holdPin               = at25mInit->holdPin;
    gDrvAT25MObj.writeProtectPin       = at25mInit->writeProtectPin;

    /* De-assert Chip Select, Hold and Write protect pin to begin with. */
    SYS_PORT_PinSet(gDrvAT25MObj.chipSelectPin);
    SYS_PORT_PinSet(gDrvAT25MObj.holdPin);
    SYS_PORT_PinSet(gDrvAT25MObj.writeProtectPin);

    /* Update the status */
    gDrvAT25MObj.status                = SYS_STATUS_READY;

    /* Return the object structure */
    return ( (SYS_MODULE_OBJ)drvIndex );

}

SYS_STATUS DRV_AT25M_Status( const SYS_MODULE_INDEX drvIndex )
{
    /* Return the driver status */
    return (gDrvAT25MObj.status);
}

DRV_HANDLE DRV_AT25M_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    /* Validate the request */
    if (drvIndex >= DRV_AT25M_INSTANCES_NUMBER)
    {
        return DRV_HANDLE_INVALID;
    }

    if((gDrvAT25MObj.status != SYS_STATUS_READY) || (gDrvAT25MObj.inUse == false) || (gDrvAT25MObj.nClients >= gDrvAT25MObj.nClientsMax))
    {
        return DRV_HANDLE_INVALID;
    }

    gDrvAT25MObj.nClients++;

    return ((DRV_HANDLE)0);
}

void DRV_AT25M_Close( const DRV_HANDLE handle )
{
    if((handle != DRV_HANDLE_INVALID) && (handle == 0))
    {
        gDrvAT25MObj.nClients--;
    }
}

bool DRV_AT25M_Read( const DRV_HANDLE handle, void *rxData, uint32_t rxDataLength, uint32_t address )
{
    bool status = false;

    if((handle == DRV_HANDLE_INVALID) || (handle > 0))
    {
        return status;
    }

    gDrvAT25MObj.at25mCommand[0] = DRV_AT25M_CMD_READ;
    gDrvAT25MObj.at25mCommand[1] = (uint8_t)(address>>16);
    gDrvAT25MObj.at25mCommand[2] = (uint8_t)(address>>8);
    gDrvAT25MObj.at25mCommand[3] = (uint8_t)(address);

    /* Assert Chip Select */
    SYS_PORT_PinClear(gDrvAT25MObj.chipSelectPin);

    if(gDrvAT25MObj.spiPlib->write(gDrvAT25MObj.at25mCommand, 4) == true)
    {
        while(gDrvAT25MObj.spiPlib->isBusy() == true);

        gDrvAT25MObj.spiPlib->callbackRegister(&_SPIEventHandler, (uintptr_t)DRV_AT25M_CMD_READ);

        if (gDrvAT25MObj.spiPlib->read((uint8_t*)rxData, rxDataLength) == true)
        {
            gDrvAT25MObj.transferStatus = DRV_AT25M_TRANSFER_BUSY;
            status = true;
        }
        else
        {
            /* If request was not accepted, de-register the callback */
            gDrvAT25MObj.spiPlib->callbackRegister(NULL, (uintptr_t)NULL);
        }
    }

    return status;
}

bool DRV_AT25M_Write( const DRV_HANDLE handle, void *txData, uint32_t txDataLength, uint32_t address )
{
    bool status = false;

    if((handle == DRV_HANDLE_INVALID) || (handle > 0))
    {
        return status;
    }

    if (_DRV_AT25M_WriteEnable() == true)
    {
        gDrvAT25MObj.at25mCommand[0] = DRV_AT25M_CMD_PAGE_PROGRAM;
        gDrvAT25MObj.at25mCommand[1] = (uint8_t)(address>>16);
        gDrvAT25MObj.at25mCommand[2] = (uint8_t)(address>>8);
        gDrvAT25MObj.at25mCommand[3] = (uint8_t)(address);

        /* Assert Chip Select */
        SYS_PORT_PinClear(gDrvAT25MObj.chipSelectPin);

        if(gDrvAT25MObj.spiPlib->write(gDrvAT25MObj.at25mCommand, 4) == true)
        {
            while(gDrvAT25MObj.spiPlib->isBusy() == true);

            gDrvAT25MObj.spiPlib->callbackRegister(&_SPIEventHandler, (uintptr_t)DRV_AT25M_CMD_PAGE_PROGRAM);

            if (gDrvAT25MObj.spiPlib->write((uint8_t*)txData, txDataLength) == true)
            {
                gDrvAT25MObj.transferStatus = DRV_AT25M_TRANSFER_BUSY;
                gDrvAT25MObj.writeCompleted = false;
                status = true;
            }
            else
            {
                /* If request was not accepted, de-register the callback */
                gDrvAT25MObj.spiPlib->callbackRegister(NULL, (uintptr_t)NULL);
            }
        }
    }

    return status;
}

bool DRV_AT25M_PageWrite(const DRV_HANDLE handle, void *txData, uint32_t address )
{
    return DRV_AT25M_Write(handle, txData, DRV_AT25M_PAGE_SIZE, address );
}

DRV_AT25M_TRANSFER_STATUS DRV_AT25M_TransferStatusGet(const DRV_HANDLE handle)
{
    if((gDrvAT25MObj.spiPlib->isBusy() == false) && (gDrvAT25MObj.writeCompleted == false))
    {
        if ((_DRV_AT25M_ReadStatus() & 0x01) == 0x0)
        {
            gDrvAT25MObj.transferStatus = DRV_AT25M_TRANSFER_COMPLETED;
            gDrvAT25MObj.writeCompleted = true;
        }
    }
    return gDrvAT25MObj.transferStatus;
}

bool DRV_AT25M_GeometryGet(const DRV_HANDLE handle, DRV_AT25M_GEOMETRY *geometry)
{
    uint32_t flashSize = 0x40000; // 2 MBit = 256 KByte

    if((handle == DRV_HANDLE_INVALID) || (handle > 0))
    {
        return false;
    }

    /* Read block size and number of blocks */
    geometry->readBlockSize = 1;
    geometry->readNumBlocks = flashSize;

    /* Write block size and number of blocks */
    geometry->writeBlockSize = 256;
    geometry->writeNumBlocks = flashSize >> 8;

    /* Erase block size and number of blocks */
    geometry->eraseBlockSize = 1;
    geometry->eraseNumBlocks = flashSize;

    /* Number of regions */
    geometry->readNumRegions = 1;
    geometry->writeNumRegions = 1;
    geometry->eraseNumRegions = 1;

    /* Block start address */
    geometry->blockStartAddress = gDrvAT25MObj.blockStartAddress;

    return true;
}


