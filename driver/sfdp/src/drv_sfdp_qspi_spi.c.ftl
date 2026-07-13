/******************************************************************************
  SFDP Driver Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sfdp.c

  Summary:
    SFDP Driver Interface Definition

  Description:
    The SFDP Driver provides an interface to access JEDEC-compliant NOR Flash
    devices using Serial Flash Discoverable Parameters (SFDP) for runtime
    discovery of flash characteristics as per JESD216 standard.

*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2026 Microchip Technology Inc. and its subsidiaries.
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

#include "driver/sfdp/src/drv_sfdp_local.h"

#include "drv_sfdp_spi_interface.h"
<#if core.PRODUCT_FAMILY?matches("PIC32M.*") == false && DRV_SFDP_TX_RX_DMA == true && core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
#include "system/cache/sys_cache.h"
</#if>

/* Array to hold the commands to be sent  */
static CACHE_ALIGN uint8_t sfdpCommand[CACHE_ALIGNED_SIZE_GET(8)];

/* Stores Status Register value ([0]Dummy Byte, [1]Register value)*/
static CACHE_ALIGN uint8_t sfdpResponse[CACHE_ALIGNED_SIZE_GET(2)];

static CACHE_ALIGN uint8_t jedecID[CACHE_ALIGNED_SIZE_GET(4)] = { 0 };

/* SFDP discovery data structures */
static CACHE_ALIGN DRV_SFDP_HEADER sfdpHeader = { 0 };
static CACHE_ALIGN DRV_SFDP_PARAM_HEADER parameterHeader = { 0 };
static CACHE_ALIGN uint32_t dwordData[CACHE_ALIGNED_SIZE_GET(22)] = { 0 };

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

static DRV_SFDP_OBJECT gDrvSFDPObj;
static DRV_SFDP_OBJECT *dObj = &gDrvSFDPObj;

// *****************************************************************************
// *****************************************************************************
// Section: SFDP Driver Local Functions - SFDP Discovery
// *****************************************************************************
// *****************************************************************************

/* Read data from SFDP parameter tables using command 0x5A */
static bool DRV_SFDP_ReadSFDPData(uint32_t address, uint8_t *data, uint32_t length)
{
    uint8_t nBytes = 0;

    if ((data == NULL) || (length == 0U))
    {
        return false;
    }

    /* Build SFDP Read command sequence:
     * Command (0x5A) + 24-bit Address + Dummy Byte
     */
    sfdpCommand[nBytes++] = (uint8_t)SFDP_CMD_READ_SFDP;
    sfdpCommand[nBytes++] = (uint8_t)(address >> 16);
    sfdpCommand[nBytes++] = (uint8_t)(address >> 8);
    sfdpCommand[nBytes++] = (uint8_t)address;
    sfdpCommand[nBytes++] = 0xFFU; /* Dummy byte */

    /* Use write-then-read for SFDP command */
    dObj->transferDataObj.pTransmitData = sfdpCommand;
    dObj->transferDataObj.txSize = nBytes;
    dObj->transferDataObj.pReceiveData = data;
    dObj->transferDataObj.rxSize = length;

    return DRV_SFDP_SPIWriteRead(dObj, &dObj->transferDataObj);
}

/* MISRA C-2023 Rule 21.15 deviated below. Deviation record ID - H3_MISRAC_2023_R_21_15_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:2 "MISRA C-2023 Rule 21.15" "H3_MISRAC_2023_R_21_15_DR_1" )
</#if>

static bool DRV_SFDP_ReadHeader(DRV_SFDP_HEADER *header)
{
    bool status = false;

    if (header == NULL)
    {
        return status;
    }

    status = DRV_SFDP_ReadSFDPData(0x000000U, (uint8_t *)dwordData, (sizeof(DRV_SFDP_HEADER) + 5U));

    /* Wait for completion */
    while (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY)
    {
        /* Nothing to do */
    }

    (void)memcpy(header, ((uint8_t *)dwordData + 5U), sizeof(DRV_SFDP_HEADER));

    if (status == true)
    {
        if (header->signature != SFDP_SIGNATURE)
        {
            status = false;
        }
    }

    return status;
}

static bool DRV_SFDP_ReadParamHeader(uint32_t headerIndex, DRV_SFDP_PARAM_HEADER *paramHeader)
{
    bool status = false;
    uint32_t address = 0;

    if (paramHeader == NULL)
    {
        return status;
    }

    address = SFDP_HEADER_SIZE + (headerIndex * SFDP_PARAM_HEADER_SIZE);

    status = DRV_SFDP_ReadSFDPData(address, (uint8_t *)dwordData, (sizeof(DRV_SFDP_PARAM_HEADER) + 5U));

    /* Wait for completion */
    while (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY)
    {
        /* Nothing to do */
    }

    (void)memcpy(paramHeader, ((uint8_t *)dwordData + 5U), sizeof(DRV_SFDP_PARAM_HEADER));

    return status;
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2023 Rule 21.15"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2023 deviation block end */

static uint32_t DRV_SFDP_GetTableAddress(const DRV_SFDP_PARAM_HEADER *paramHeader)
{
    uint32_t address = 0;

    if (paramHeader != NULL)
    {
        address = ((uint32_t)paramHeader->tablePointer[0]) |
                  (((uint32_t)paramHeader->tablePointer[1]) << 8) |
                  (((uint32_t)paramHeader->tablePointer[2]) << 16);
    }

    return address;
}

static uint16_t DRV_SFDP_GetParamId(const DRV_SFDP_PARAM_HEADER *paramHeader)
{
    uint16_t paramId = 0;

    if (paramHeader != NULL)
    {
        paramId = ((uint16_t)paramHeader->paramIdLsb) |
                  (((uint16_t)paramHeader->paramIdMsb) << 8);
    }

    return paramId;
}

static bool DRV_SFDP_ParseBasicFlashParams(uint32_t tableAddress, uint8_t tableLengthDwords,
                                            DRV_SFDP_FLASH_PARAMS *flashParams)
{
    bool status = false;
    uint32_t readLength = 0;
    uint32_t density = 0;
    uint8_t *ptrData = (uint8_t *)dwordData;

    if ((flashParams == NULL) || (tableLengthDwords == 0U))
    {
        return status;
    }

    /* Limit read to maximum expected size */
    readLength = (tableLengthDwords > 20U) ? 20U : tableLengthDwords;
    readLength = readLength * 4U; /* Convert DWORDs to bytes */

    /* Read the Basic Flash Parameter Table */
    status = DRV_SFDP_ReadSFDPData(tableAddress, (uint8_t *)dwordData, (readLength + 5U));

    /* Wait for completion */
    while (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY)
    {
        /* Nothing to do */
    }

    (void)memmove(&ptrData[0], &ptrData[5], readLength);

    if (status == true)
    {
        /* Parse DWORD 0: Block/Sector Erase Sizes */
        /* Bits 1:0 - Erase Granularity and 4KB Erase */
        if ((dwordData[0] & 0x00000003U) != 0U)
        {
            flashParams->eraseOpcode4K = (uint8_t)SFDP_CMD_SECTOR_ERASE_4K;
            flashParams->sectorSize = 4096U;
        }

        /* Parse DWORD 0: Address Bytes */
        /* Bits 18:17 - Address Bytes: 00 = 3 byte */
        uint32_t addrModeTemp = (dwordData[0] >> 17U) & 0x03U;
        uint8_t addrMode = (uint8_t)addrModeTemp;
        if (addrMode == 0x02U)
        {
            flashParams->addressBytes = 4U;
        }
        else
        {
            flashParams->addressBytes = 3U;
        }

        /* Parse DWORD 1: Flash Memory Density */
        density = dwordData[1];
        if ((density & 0x80000000U) != 0U)
        {
            /* Bit 31 = 1: Density is 2^n bits */
            uint32_t n_bits = density & 0x7FFFFFFFU;
            /* Convert bits to bytes: 2^n bits = 2^(n-3) bytes */
            if (n_bits >= 3U)
            {
                flashParams->flashSize = ((uint32_t)1U << (n_bits - 3U));
            }
            else
            {
                /* Invalid density encoding */
                status = false;
            }
        }
        else
        {
            /* Bit 31 = 0: Density is (n+1) bits */
            flashParams->flashSize = (density + 1U) / 8U; /* Convert bits to bytes */
        }

        /* Default values */
        flashParams->fastReadOpcode_1_1_1 = (uint8_t)SFDP_CMD_HIGH_SPEED_READ;
        flashParams->fastReadDummyCycles_1_1_1 = 8U;

        /* Parse DWORD 7: Sector Erase (4KB) - Bits 7:0 size, Bits 15:8 opcode */
        if (readLength >= 32U)
        {
            uint32_t eraseOpcodeTemp = (dwordData[7] >> 8U) & 0xFFU;
            flashParams->eraseOpcode4K = (uint8_t)eraseOpcodeTemp;
            /* Sector size encoding: 2^N bytes */
            uint32_t sizeExpTemp = dwordData[7] & 0xFFU;
            uint8_t sizeExp = (uint8_t)sizeExpTemp;
            if (sizeExp != 0U)
            {
                flashParams->sectorSize = ((uint32_t)1U << sizeExp);
            }
        }

        /* Parse DWORD 8: Block Erase Types */
        if (readLength >= 36U)
        {
            /* Erase 64KB: Bits 31:24 opcode, Bits 23:16 size */
            uint32_t eraseOpcode64KTemp = (dwordData[8] >> 24U) & 0xFFU;
            flashParams->eraseOpcode64K = (uint8_t)eraseOpcode64KTemp;
            uint32_t blockSizeExpTemp = (dwordData[8] >> 16U) & 0xFFU;
            uint8_t blockSizeExp = (uint8_t)blockSizeExpTemp;
            if (blockSizeExp != 0U)
            {
                flashParams->blockSize = ((uint32_t)1U << blockSizeExp);
            }
        }

        /* Default page size */
        flashParams->pageSize = 256U;

        /* Parse DWORD 10: Page Size - Bits 7:4 (2^N bytes) */
        if (readLength >= 44U)
        {
            uint32_t pageSizeExpTemp = (dwordData[10] >> 4U) & 0x0FU;
            uint8_t pageSizeExp = (uint8_t)pageSizeExpTemp;
            if (pageSizeExp != 0U)
            {
                flashParams->pageSize = ((uint32_t)1U << pageSizeExp);
            }
        }

        /* Select optimal read mode - For SPI interface, only single-bit SPI mode is supported */
        flashParams->optimalReadOpcode = flashParams->fastReadOpcode_1_1_1;
        flashParams->optimalReadDummyCycles = flashParams->fastReadDummyCycles_1_1_1;
    }

    return status;
}

/* This function discovers flash parameters using SFDP.
 * Returns true on success, false on failure. */
static bool DRV_SFDP_DiscoverFlashParams(void)
{
    bool status = false;
    uint32_t i = 0;
    uint32_t numHeaders = 0;
    bool basicParamFound = false;

    /* Read and verify SFDP header */
    status = DRV_SFDP_ReadHeader(&sfdpHeader);

    if (status == true)
    {
        /* Calculate number of parameter headers (NPH field + 1) */
        numHeaders = (uint32_t)sfdpHeader.numParamHeaders + 1U;

        /* Limit search to maximum headers */
        if (numHeaders > SFDP_MAX_PARAM_HEADERS)
        {
            numHeaders = SFDP_MAX_PARAM_HEADERS;
        }

        /* Iterate through parameter headers to find Basic Flash Parameter Table */
        for (i = 0; i < numHeaders; i++)
        {
            dObj->transferStatus = DRV_SFDP_TRANSFER_BUSY;
            status = DRV_SFDP_ReadParamHeader(i, &parameterHeader);

            if (status == true)
            {
                uint16_t paramId = DRV_SFDP_GetParamId(&parameterHeader);

                /* Check for Basic Flash Parameter Table (ID = 0xFF00) */
                if (paramId == SFDP_BASIC_PARAM_TABLE_ID)
                {
                    uint32_t tableAddress = DRV_SFDP_GetTableAddress(&parameterHeader);

                    dObj->transferStatus = DRV_SFDP_TRANSFER_BUSY;
                    /* Parse the Basic Flash Parameter Table */
                    status = DRV_SFDP_ParseBasicFlashParams(tableAddress,
                                                            parameterHeader.lengthDwords,
                                                            &dObj->flashParams);

                    if (status == true)
                    {
                        basicParamFound = true;
                        break;
                    }
                }
            }
        }

        if (!basicParamFound)
        {
            status = false;
        }
    }

    return status;
}

// *****************************************************************************
// *****************************************************************************
// Section: SFDP Driver Local Functions - Flash Operations
// *****************************************************************************
// *****************************************************************************

static bool DRV_SFDP_ResetFlash(void)
{
    dObj->transferStatus    = DRV_SFDP_TRANSFER_BUSY;

    dObj->state             = DRV_SFDP_STATE_WAIT_RESET_FLASH_COMPLETE;

    sfdpCommand[0] = (uint8_t)SFDP_CMD_FLASH_RESET_ENABLE;
    dObj->transferDataObj.pTransmitData = sfdpCommand;

    dObj->transferDataObj.txSize = 1;

    (void) DRV_SFDP_SPIWriteRead(dObj, &dObj->transferDataObj);

    while (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY)
    {
        /* Nothing to do */
    }


    dObj->transferStatus    = DRV_SFDP_TRANSFER_BUSY;

    dObj->state             = DRV_SFDP_STATE_WAIT_RESET_FLASH_COMPLETE;

    sfdpCommand[0] = (uint8_t)SFDP_CMD_FLASH_RESET;
    dObj->transferDataObj.pTransmitData = sfdpCommand;
    dObj->transferDataObj.pReceiveData = NULL;

    dObj->transferDataObj.txSize = 1;
    dObj->transferDataObj.rxSize = 0;

    (void) DRV_SFDP_SPIWriteRead(dObj, &dObj->transferDataObj);

    while (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY)
    {
        /* Nothing to do */
    }


    return true;
}

/* Detect device type from JEDEC ID and apply device-specific configurations */
static SFDP_DEVICE_TYPE DRV_SFDP_DetectDeviceType(uint8_t *jedecId, DRV_SFDP_FLASH_PARAMS *flashParams)
{
    SFDP_DEVICE_TYPE deviceType = SFDP_DEVICE_TYPE_GENERIC;

    if ((jedecId == NULL) || (flashParams == NULL))
    {
        return deviceType;
    }

    /* Extract vendor and device ID */
    flashParams->vendorId = jedecId[0];
    flashParams->deviceId = ((uint16_t)jedecId[1] << 8) | jedecId[2];

    /* Detect device type by vendor ID */
    if (flashParams->vendorId == 0xBFU)
    {
        /* SST devices */
        deviceType = SFDP_DEVICE_TYPE_SST26;
    }
    else if (flashParams->vendorId == 0xEFU)
    {
        /* W25 devices */
        deviceType = SFDP_DEVICE_TYPE_W25;
    }
    else if (flashParams->vendorId == 0x20U)
    {
        /* N25Q devices */
        deviceType = SFDP_DEVICE_TYPE_N25Q;
    }
    else if (flashParams->vendorId == 0xC2U)
    {
        /* MX25L/MX66 devices */
        deviceType = SFDP_DEVICE_TYPE_MX25L;
    }
    else if (flashParams->vendorId == 0x01U)
    {
        /* S25FL devices */
        deviceType = SFDP_DEVICE_TYPE_S25FL;
    }
    else if (flashParams->vendorId == 0x9DU)
    {
        /* IS25 devices */
        deviceType = SFDP_DEVICE_TYPE_IS25;
    }
    else
    {
        deviceType = SFDP_DEVICE_TYPE_GENERIC;
    }

    return deviceType;
}

static bool DRV_SFDP_WriteEnable(void)
{
    sfdpCommand[0] = (uint8_t)SFDP_CMD_WRITE_ENABLE;
    dObj->transferDataObj.pTransmitData = sfdpCommand;
    dObj->transferDataObj.pReceiveData = NULL;

    dObj->transferDataObj.txSize = 1;
    dObj->transferDataObj.rxSize = 0;



    (void) DRV_SFDP_SPIWriteRead(dObj, &dObj->transferDataObj);

    return true;
}

static bool lDRV_SFDP_ReadStatus( void )
{
    /* Register Status will be stored in the second byte */
    sfdpResponse[1] = 0;
    sfdpCommand[0] = (uint8_t)SFDP_CMD_READ_STATUS_REG;

    dObj->transferDataObj.pTransmitData = sfdpCommand;
    dObj->transferDataObj.txSize = 1;
    dObj->transferDataObj.pReceiveData = sfdpResponse;
    dObj->transferDataObj.rxSize = 2;

    (void) DRV_SFDP_SPIWriteRead(dObj, &dObj->transferDataObj);

    return true;
}

static bool DRV_SFDP_WriteCommandAddress( uint8_t command, uint32_t address )
{
    uint8_t nBytes = 0;
    uint8_t dummyBytes = 0;

    /* Save the request */
    sfdpCommand[nBytes++] = command;

    /* Support both 24-bit and 32-bit addressing */
    if ((dObj->flashParams.addressBytes == 4U) || (address > 0xFFFFFFU))
    {
        /* 32-bit addressing */
        sfdpCommand[nBytes++] = (uint8_t)(address >> 24);
        sfdpCommand[nBytes++] = (uint8_t)(address >> 16);
        sfdpCommand[nBytes++] = (uint8_t)(address >> 8);
        sfdpCommand[nBytes++] = (uint8_t)address;
    }
    else
    {
        /* 24-bit addressing */
        sfdpCommand[nBytes++] = (uint8_t)(address >> 16);
        sfdpCommand[nBytes++] = (uint8_t)(address >> 8);
        sfdpCommand[nBytes++] = (uint8_t)address;
    }

    /* Add dummy bytes for fast read commands */
    if (command == dObj->flashParams.optimalReadOpcode)
    {
        dummyBytes = dObj->flashParams.optimalReadDummyCycles / 8U;
        for (uint8_t i = 0; i < dummyBytes; i++)
        {
            sfdpCommand[nBytes++] = 0xFFU;
        }
    }

    dObj->transferDataObj.pTransmitData = sfdpCommand;
    dObj->transferDataObj.txSize = nBytes;

    dObj->transferDataObj.pReceiveData = NULL;
    dObj->transferDataObj.rxSize = 0;

    (void) DRV_SFDP_SPIWriteRead(dObj, &dObj->transferDataObj);

    return true;
}

static bool DRV_SFDP_ReadData( void* rxData, uint32_t rxDataLength )
{
    dObj->transferDataObj.pTransmitData = NULL;
    dObj->transferDataObj.txSize = 0;
    dObj->transferDataObj.pReceiveData = rxData;
    dObj->transferDataObj.rxSize = rxDataLength;

    (void) DRV_SFDP_SPIWriteRead(dObj, &dObj->transferDataObj);

    return true;
}

static bool DRV_SFDP_WriteData( void* txData, uint32_t txDataLength, uint32_t address )
{
    dObj->transferDataObj.pTransmitData = txData;
    dObj->transferDataObj.txSize = txDataLength;
    dObj->transferDataObj.pReceiveData = NULL;
    dObj->transferDataObj.rxSize = 0;

    (void) DRV_SFDP_SPIWriteRead(dObj, &dObj->transferDataObj);

    return true;
}

static bool DRV_SFDP_Erase( uint8_t command, uint32_t address )
{
    bool status = false;

    dObj->transferStatus    = DRV_SFDP_TRANSFER_BUSY;

    /* Save the request */
    dObj->currentCommand    = command;
    dObj->memoryAddr        = address;

    dObj->state             = DRV_SFDP_STATE_ERASE;

    /* Start the transfer by submitting a Write Enable request. Further commands
     * will be issued from the interrupt context.
    */
    status = DRV_SFDP_WriteEnable();

    if (status == false)
    {
        dObj->transferStatus = DRV_SFDP_TRANSFER_ERROR_UNKNOWN;
    }

    return status;
}

void DRV_SFDP_Handler( void )
{
    switch(dObj->state)
    {
        case DRV_SFDP_STATE_READ_DATA:
        {
            if (DRV_SFDP_ReadData((void*)dObj->bufferAddr, dObj->nPendingBytes) == true)
            {
                dObj->state = DRV_SFDP_STATE_WAIT_READ_COMPLETE;
            }
            else
            {
                dObj->transferStatus = DRV_SFDP_TRANSFER_ERROR_UNKNOWN;
            }
            break;
        }

        case DRV_SFDP_STATE_WAIT_READ_COMPLETE:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            dObj->transferStatus = DRV_SFDP_TRANSFER_COMPLETED;

            break;
        }

        case DRV_SFDP_STATE_WRITE_CMD_ADDR:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            /* Send page write command and memory address */
            if (DRV_SFDP_WriteCommandAddress(dObj->currentCommand,
                                               dObj->memoryAddr) == true)
            {
                dObj->state = DRV_SFDP_STATE_WRITE_DATA;
            }
            else
            {
                dObj->transferStatus = DRV_SFDP_TRANSFER_ERROR_UNKNOWN;
            }
            break;
        }

        case DRV_SFDP_STATE_WRITE_DATA:
        {
            if (DRV_SFDP_WriteData(dObj->bufferAddr,
                                      dObj->nPendingBytes, dObj->memoryAddr) == true)
            {
                dObj->state = DRV_SFDP_STATE_CHECK_ERASE_WRITE_STATUS;
            }
            else
            {
                dObj->transferStatus = DRV_SFDP_TRANSFER_ERROR_UNKNOWN;
            }
            break;
        }

        case DRV_SFDP_STATE_CHECK_ERASE_WRITE_STATUS:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            /* Read the status of FLASH internal write cycle */
            if (lDRV_SFDP_ReadStatus() == true)
            {
                dObj->state = DRV_SFDP_STATE_WAIT_ERASE_WRITE_COMPLETE;
            }
            else
            {
                dObj->transferStatus = DRV_SFDP_TRANSFER_ERROR_UNKNOWN;
            }
            break;
        }

        case DRV_SFDP_STATE_WAIT_ERASE_WRITE_COMPLETE:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            /* Check the busy bit in the status register. 0 = Ready, 1 = busy*/
            if ((sfdpResponse[1] & (1UL << 0)) != 0U)
            {
                /* Keep reading the status of FLASH internal write cycle */
                if (lDRV_SFDP_ReadStatus() == false)
                {
                    dObj->transferStatus = DRV_SFDP_TRANSFER_ERROR_UNKNOWN;
                }
            }
            else
            {
                dObj->transferStatus = DRV_SFDP_TRANSFER_COMPLETED;
            }
            break;
        }

        case DRV_SFDP_STATE_ERASE:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            /* Send Erase command and memory address */
            if (DRV_SFDP_WriteCommandAddress(dObj->currentCommand,
                                      dObj->memoryAddr) == true)
            {
                dObj->state = DRV_SFDP_STATE_CHECK_ERASE_WRITE_STATUS;
            }
            else
            {
                dObj->transferStatus = DRV_SFDP_TRANSFER_ERROR_UNKNOWN;
            }
            break;
        }

        case DRV_SFDP_STATE_UNLOCK_FLASH:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            if (dObj->currentCommand == (uint8_t)SFDP_CMD_WRITE_STATUS_REG)
            {
                /* Write status register command */
                sfdpCommand[0] = (uint8_t)SFDP_CMD_WRITE_STATUS_REG;
                /* Clear block write protection in the status register */
                sfdpCommand[1] = 0;
                dObj->transferDataObj.pTransmitData = sfdpCommand;
                dObj->transferDataObj.txSize = 2;
            }
            else
            {
                /* Global Unprotect Flash command */
                sfdpCommand[0] = (uint8_t)SFDP_CMD_UNPROTECT_GLOBAL;
                dObj->transferDataObj.pTransmitData = sfdpCommand;
                dObj->transferDataObj.txSize = 1;
            }
            dObj->transferDataObj.pReceiveData = NULL;
            dObj->transferDataObj.rxSize = 0;


            (void) DRV_SFDP_SPIWriteRead(dObj, &dObj->transferDataObj);

            dObj->state = DRV_SFDP_STATE_WAIT_UNLOCK_FLASH_COMPLETE;


            break;
        }

        case DRV_SFDP_STATE_WAIT_UNLOCK_FLASH_COMPLETE:
        case DRV_SFDP_STATE_WAIT_RESET_FLASH_COMPLETE:
        case DRV_SFDP_STATE_WAIT_JEDEC_ID_READ_COMPLETE:
        case DRV_SFDP_STATE_DISCOVER_SFDP:
        {
            /* De-assert the chip select */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            dObj->transferStatus = DRV_SFDP_TRANSFER_COMPLETED;

            break;
        }

        default:
        {
             /* Nothing to do */
            break;
        }
    }
    /* If transfer is complete, notify the application */
    if (dObj->transferStatus != DRV_SFDP_TRANSFER_BUSY)
    {
        if (dObj->eventHandler != NULL)
        {
            dObj->eventHandler(dObj->transferStatus, dObj->context);
        }
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: SFDP Driver Global Functions
// *****************************************************************************
// *****************************************************************************

bool DRV_SFDP_UnlockFlash( const DRV_HANDLE handle )
{
    bool status = false;

    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY))
    {
        return status;
    }

    if (DRV_SFDP_ReadJedecId(handle, (void *)jedecID) == false)
    {
        status = false;
    }
    else
    {
        /* Unblock block write protection using write status register command */
        if (jedecID[3] == 0x12U || jedecID[3] == 0x18U)
        {
            dObj->currentCommand    = (uint8_t)SFDP_CMD_WRITE_STATUS_REG;
        }
        else
        {
            dObj->currentCommand    = (uint8_t)SFDP_CMD_UNPROTECT_GLOBAL;
        }

        dObj->transferStatus    = DRV_SFDP_TRANSFER_BUSY;
        dObj->state             = DRV_SFDP_STATE_UNLOCK_FLASH;

        /* Start the transfer by submitting a Write Enable request. Further commands
         * will be issued from the interrupt context.
         */
        status = DRV_SFDP_WriteEnable();

        if (status == false)
        {
            dObj->transferStatus = DRV_SFDP_TRANSFER_ERROR_UNKNOWN;
        }
    }

    return status;
}

bool DRV_SFDP_ReadJedecId( const DRV_HANDLE handle, void* jedec_id )
{
    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY))
    {
        return false;
    }


    dObj->transferStatus    = DRV_SFDP_TRANSFER_BUSY;

    dObj->state             = DRV_SFDP_STATE_WAIT_JEDEC_ID_READ_COMPLETE;

    sfdpCommand[0]   = (uint8_t)SFDP_CMD_JEDEC_ID_READ;

    dObj->transferDataObj.pTransmitData = sfdpCommand;
    dObj->transferDataObj.txSize = 1;
    dObj->transferDataObj.pReceiveData = jedec_id;
    dObj->transferDataObj.rxSize = 4;
    (void) DRV_SFDP_SPIWriteRead(dObj, &dObj->transferDataObj);

    while (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY)
    {
        /* Nothing to do */
    }


    return true;
}

DRV_SFDP_TRANSFER_STATUS DRV_SFDP_TransferStatusGet( const DRV_HANDLE handle )
{
    if(handle == DRV_HANDLE_INVALID)
    {
        return DRV_SFDP_TRANSFER_ERROR_UNKNOWN;
    }

    return dObj->transferStatus;
}

bool DRV_SFDP_Read( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address )
{
    bool status = false;

    if( (handle == DRV_HANDLE_INVALID) ||
        (rx_data == NULL) ||
        (rx_data_length == 0U) ||
        (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY))
    {
        return status;
    }

    dObj->transferStatus    = DRV_SFDP_TRANSFER_BUSY;

    /* save the request */
    dObj->nPendingBytes     = rx_data_length;
    dObj->bufferAddr        = rx_data;
    dObj->memoryAddr        = address;

    dObj->state             = DRV_SFDP_STATE_READ_DATA;

    /* Use optimal read opcode discovered via SFDP */
    status = DRV_SFDP_WriteCommandAddress(dObj->flashParams.optimalReadOpcode, address);

    if ( status == false)
    {
        dObj->transferStatus = DRV_SFDP_TRANSFER_ERROR_UNKNOWN;
    }

    return status;
}

bool DRV_SFDP_PageWrite( const DRV_HANDLE handle, void *tx_data, uint32_t address )
{
    bool status = false;

    if( (handle == DRV_HANDLE_INVALID) ||
        (tx_data == NULL) ||
        (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY))
    {
        return status;
    }

    dObj->transferStatus    = DRV_SFDP_TRANSFER_BUSY;

    /* save the request */
    dObj->currentCommand    = (uint8_t)SFDP_CMD_PAGE_PROGRAM;
    dObj->nPendingBytes     = dObj->flashParams.pageSize;
    dObj->bufferAddr        = tx_data;
    dObj->memoryAddr        = address;

    dObj->state             = DRV_SFDP_STATE_WRITE_CMD_ADDR;

    status = DRV_SFDP_WriteEnable();

    if (status == false)
    {
        dObj->transferStatus = DRV_SFDP_TRANSFER_ERROR_UNKNOWN;
    }

    return status;
}

bool DRV_SFDP_SectorErase( const DRV_HANDLE handle, uint32_t address )
{
    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY))
    {
        return false;
    }

    return (DRV_SFDP_Erase(dObj->flashParams.eraseOpcode4K, address));
}

bool DRV_SFDP_BulkErase( const DRV_HANDLE handle, uint32_t address )
{
    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY))
    {
        return false;
    }

    return (DRV_SFDP_Erase(dObj->flashParams.eraseOpcode64K, address));
}

bool DRV_SFDP_ChipErase( const DRV_HANDLE handle )
{
    if( (handle == DRV_HANDLE_INVALID) ||
        (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY))
    {
        return false;
    }

    return (DRV_SFDP_Erase((uint8_t)SFDP_CMD_CHIP_ERASE, 0));
}

bool DRV_SFDP_GeometryGet( const DRV_HANDLE handle, DRV_SFDP_GEOMETRY *geometry )
{
    bool status = true;
    uint32_t flash_size = 0;

    if ((handle == DRV_HANDLE_INVALID) || (geometry == NULL))
    {
        return false;
    }

    /* Flash parameters were already discovered during Open() via SFDP */
    flash_size = dObj->flashParams.flashSize;

    if (flash_size == 0U)
    {
        status = false;
    }

    if (DRV_SFDP_START_ADDRESS >= flash_size)
    {
        status = false;
    }

    if (status == true)
    {
        flash_size = flash_size - DRV_SFDP_START_ADDRESS;

        /* Flash size should be at-least of an Erase Block size */
        if (flash_size < dObj->flashParams.sectorSize)
        {
            status = false;
        }
    }

    if (status == true)
    {
        /* Read block size and number of blocks */
        geometry->read_blockSize = 1;
        geometry->read_numBlocks = flash_size;

        /* Write block size and number of blocks */
        geometry->write_blockSize = dObj->flashParams.pageSize;
        geometry->write_numBlocks = (flash_size / dObj->flashParams.pageSize);

        /* Erase block size and number of blocks */
        geometry->erase_blockSize = dObj->flashParams.sectorSize;
        geometry->erase_numBlocks = (flash_size / dObj->flashParams.sectorSize);

        geometry->numReadRegions = 1;
        geometry->numWriteRegions = 1;
        geometry->numEraseRegions = 1;

        geometry->blockStartAddress = DRV_SFDP_START_ADDRESS;
    }

    return status;
}

/* MISRA C-2023 Rule 18.6 deviated below. Deviation record ID - H3_MISRAC_2023_R_18_6_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate "MISRA C-2023 Rule 18.6" "H3_MISRAC_2023_R_18_6_DR_1"
</#if>

DRV_HANDLE DRV_SFDP_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    if ((dObj->status != SYS_STATUS_READY) ||
        (dObj->nClients >= DRV_SFDP_CLIENTS_NUMBER))
    {
        return DRV_HANDLE_INVALID;
    }

<#if DRV_SFDP_INTERFACE_TYPE == "SPI_DRV">
    dObj->spiDrvHandle = DRV_SPI_Open((uint16_t)dObj->spiDrvIndex, DRV_IO_INTENT_READWRITE);
    if (dObj->spiDrvHandle != DRV_HANDLE_INVALID)
    {
        /* Register a callback with the SPI driver */
        DRV_SPI_TransferEventHandlerSet(dObj->spiDrvHandle, DRV_SFDP_SPIDriverEventHandler, (uintptr_t)dObj);
    }
    else
    {
        return DRV_HANDLE_INVALID;
    }
</#if>

    /* Reset SFDP Flash device */
    if (DRV_SFDP_ResetFlash() == false)
    {
        return DRV_HANDLE_INVALID;
    }

    /* Perform SFDP discovery to determine flash parameters */
    dObj->transferStatus = DRV_SFDP_TRANSFER_BUSY;
    dObj->state = DRV_SFDP_STATE_DISCOVER_SFDP;

    if (DRV_SFDP_DiscoverFlashParams() == false)
    {
        return DRV_HANDLE_INVALID;
    }

    /* Read JEDEC ID for device-specific detection */
    uint8_t jedecIdLocal[3] = { 0 };

    if (DRV_SFDP_ReadJedecId((DRV_HANDLE)drvIndex, (void *)&jedecIdLocal) == false)
    {
        /* Continue with generic mode if JEDEC ID read fails */
        dObj->flashParams.deviceType = SFDP_DEVICE_TYPE_GENERIC;
    }
    else
    {
        while (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY)
        {
            /* Wait for JEDEC ID read to complete */
        }

        /* Detect device type and apply device-specific overrides */
        dObj->flashParams.deviceType = DRV_SFDP_DetectDeviceType(jedecIdLocal, &dObj->flashParams);

        /* For SPI mode, no quad enable needed, but we set device-specific parameters
         * that may affect read/write command selection */
        if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_N25Q)
        {
            /* N25Q256 specific parameters for SPI mode */
            dObj->flashParams.optimalReadDummyCycles = 8; /* Standard SPI dummy cycles */
        }
        else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_W25)
        {
            /* W25 specific parameters for SPI mode */
            dObj->flashParams.optimalReadDummyCycles = 8; /* Standard SPI dummy cycles */
        }
        else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_MX25L)
        {
            /* MX25L/MX66 specific parameters for SPI mode */
            dObj->flashParams.optimalReadDummyCycles = 8; /* Standard SPI dummy cycles */
        }
        else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_S25FL)
        {
            /* S25FL specific parameters for SPI mode */
            dObj->flashParams.optimalReadDummyCycles = 8; /* Standard SPI dummy cycles */
        }
        else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_IS25)
        {
            /* IS25 specific parameters for SPI mode */
            dObj->flashParams.optimalReadDummyCycles = 8; /* Standard SPI dummy cycles */
        }
        else
        {
            /* Generic device - use default parameters already set during SFDP parsing */
        }
    }

    if (((uint32_t)ioIntent & (uint32_t)DRV_IO_INTENT_WRITE) == (uint32_t)(DRV_IO_INTENT_WRITE))
    {
        /* Unlock the Flash */
        if (DRV_SFDP_UnlockFlash((DRV_HANDLE)drvIndex) == false)
        {
            return DRV_HANDLE_INVALID;
        }

        while (dObj->transferStatus == DRV_SFDP_TRANSFER_BUSY)
        {
            /* Nothing to do */
        }
    }

    dObj->nClients++;

    dObj->ioIntent = ioIntent;

    return ((DRV_HANDLE)drvIndex);
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2023 Rule 18.6"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2023 deviation block end */

void DRV_SFDP_Close( const DRV_HANDLE handle )
{
    if ((handle != DRV_HANDLE_INVALID) &&
         (dObj->nClients > 0U))
    {
        dObj->nClients--;
    }
}

void DRV_SFDP_EventHandlerSet(
    const DRV_HANDLE handle,
    const DRV_SFDP_EVENT_HANDLER eventHandler,
    const uintptr_t context
)
{
    if(handle != DRV_HANDLE_INVALID)
    {
        dObj->eventHandler = eventHandler;
        dObj->context = context;
    }
}
/* MISRA C-2023 Rule 11.3, 11.8 deviated below. Deviation record ID -
   H3_MISRAC_2023_R_11_3_DR_1 & H3_MISRAC_2023_R_11_8_DR_1*/
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:1 "MISRA C-2023 Rule 11.3" "H3_MISRAC_2023_R_11_3_DR_1" )\
(deviate:1 "MISRA C-2023 Rule 11.8" "H3_MISRAC_2023_R_11_8_DR_1" )
</#if>
SYS_MODULE_OBJ DRV_SFDP_Initialize
(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT *const init
)
{
    DRV_SFDP_INIT *sfdpInit = NULL;

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
    sfdpInit       = (DRV_SFDP_INIT *)init;

    dObj->chipSelectPin = sfdpInit->chipSelectPin;

    DRV_SFDP_InterfaceInit(dObj, sfdpInit);

    /* De-assert Chip Select pin to begin with. */
    SYS_PORT_PinSet(dObj->chipSelectPin);

    dObj->transferStatus = DRV_SFDP_TRANSFER_COMPLETED;

    dObj->status    = SYS_STATUS_READY;

    /* Return the driver index */
    return ( (SYS_MODULE_OBJ)drvIndex );
}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2023 Rule 11.3"
#pragma coverity compliance end_block "MISRA C-2023 Rule 11.8"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */

SYS_STATUS DRV_SFDP_Status( const SYS_MODULE_INDEX drvIndex )
{
    /* Return the driver status */
    return (gDrvSFDPObj.status);
}
