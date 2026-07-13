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

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

static DRV_SFDP_OBJECT gDrvSFDPObj;
static DRV_SFDP_OBJECT *dObj = &gDrvSFDPObj;

static qspi_command_xfer_t qspi_command_xfer = { 0 };
static qspi_register_xfer_t qspi_register_xfer = { 0 };
static qspi_memory_xfer_t qspi_memory_xfer = { 0 };

static CACHE_ALIGN DRV_SFDP_HEADER sfdpHeader = { 0 };
static CACHE_ALIGN DRV_SFDP_PARAM_HEADER parameterHeader = { 0 };
static CACHE_ALIGN uint32_t dwordData[20] = { 0 };

// *****************************************************************************
// *****************************************************************************
// Section: SFDP Driver Local Functions
// *****************************************************************************
// *****************************************************************************

/* MISRA C-2023 Rule 11.3, 10.3 deviated below. Deviation record ID -
   H3_MISRAC_2023_R_11_3_DR_1, H3_MISRAC_2023_R_10_3_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:10 "MISRA C-2023 Rule 11.3" "H3_MISRAC_2023_R_11_3_DR_1" )\
(deviate:8 "MISRA C-2023 Rule 10.3" "H3_MISRAC_2023_R_10_3_DR_1" )
</#if>

static bool DRV_SFDP_ReadSFDPData(uint32_t address, uint8_t *data, uint32_t length)
{
    bool status = false;

    if ((data == NULL) || (length == 0U))
    {
        return status;
    }

    (void) memset((void *)&qspi_memory_xfer, 0, sizeof(qspi_memory_xfer_t));

    qspi_memory_xfer.instruction = (uint8_t)SFDP_CMD_READ_SFDP;
    qspi_memory_xfer.width = SINGLE_BIT_SPI;
    qspi_memory_xfer.dummy_cycles = 8U;
    qspi_memory_xfer.addr_len = ADDRL_24_BIT;

    status = dObj->sfdpPlib->MemoryRead(&qspi_memory_xfer, (uint32_t *)data, length, address);

    return status;
}

static bool DRV_SFDP_ReadHeader(DRV_SFDP_HEADER *header)
{
    bool status = false;

    if (header == NULL)
    {
        return status;
    }

    status = DRV_SFDP_ReadSFDPData(0x000000U, (uint8_t *)header, sizeof(DRV_SFDP_HEADER));

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

    status = DRV_SFDP_ReadSFDPData(address, (uint8_t *)paramHeader, sizeof(DRV_SFDP_PARAM_HEADER));

    return status;
}

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

    if ((flashParams == NULL) || (tableLengthDwords == 0U))
    {
        return status;
    }

    /* Limit read to maximum expected size (typically 16-20 DWORDs) */
    readLength = (tableLengthDwords > 20U) ? 20U : tableLengthDwords;
    readLength = readLength * 4U; /* Convert DWORDs to bytes */

    /* Read the Basic Flash Parameter Table */
    status = DRV_SFDP_ReadSFDPData(tableAddress, (uint8_t *)dwordData, readLength);

    if (status == true)
    {
        /* Parse DWORD 0: Block/Sector Erase Sizes */
        /* Bits 1:0 - Erase Granularity and 4KB Erase */
        if ((dwordData[0] & 0x00000003U) != 0U)
        {
            flashParams->eraseOpcode4K = (uint8_t)SFDP_CMD_SECTOR_ERASE_4K;
            flashParams->sectorSize = 4096U;
        }

        /* Parse DWORD 0: Fast Read capabilities */
        /* Bit 21: Supports 1-1-4 Fast Read (Quad Output) */
        flashParams->supports_1_1_4 = ((dwordData[0] & 0x00400000U) != 0U);

        /* Bit 22: Supports 1-4-4 Fast Read (Quad I/O) */
        flashParams->supports_1_4_4 = ((dwordData[0] & 0x00200000U) != 0U);

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
            uint32_t n = density & 0x7FFFFFFFU;
            /* Convert bits to bytes: 2^n bits = 2^(n-3) bytes */
            if (n >= 3U)
            {
                flashParams->flashSize = ((uint32_t)1U << (n - 3U));
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

        /* Parse DWORD 2: Fast Read instructions and dummy cycles */
        if (readLength >= 12U)
        {
            /* Parse 1-4-4 Fast Read (Quad Output) */
            if (flashParams->supports_1_4_4)
            {
                /* Bits 15:8 - 1-4-4 Fast Read instruction */
                uint32_t opcode144Temp = (dwordData[2] >> 8U) & 0xFFU;
                flashParams->fastReadOpcode_1_4_4 = (uint8_t)opcode144Temp;
                /* Bits 4:0 - Number of dummy cycles for 1-4-4 */
                uint32_t waitStates144 = dwordData[2] & 0x1FU;
                uint32_t modeClocks144 = (dwordData[2] >> 5U) & 0x7U;
                flashParams->fastReadDummyCycles_1_4_4 = (uint8_t)waitStates144 + (uint8_t)modeClocks144;
            }

            /* Parse 1-1-4 Fast Read (Quad Output) */
            if (flashParams->supports_1_1_4)
            {
                /* Bits 31:24 - 1-1-4 Fast Read instruction */
                uint32_t opcode114Temp = (dwordData[2] >> 24U) & 0xFFU;
                flashParams->fastReadOpcode_1_1_4 = (uint8_t)opcode114Temp;
                /* Bits 20:16 - Number of dummy cycles for 1-1-4 */
                /* Note: Dummy cycles for 1-1-4 */
                uint32_t dummy114Temp = (dwordData[2] >> 16U) & 0x1FU;
                flashParams->fastReadDummyCycles_1_1_4 = (uint8_t)dummy114Temp;
            }
        }

        /* Parse DWORD 4: Fast Read capabilities */
        if (readLength >= 20U)
        {
            /* Bit 4: Supports 4-4-4 Fast Read (Quad command) */
            bool tempSupports444 = ((dwordData[4] & 0x10U) != 0U);
            flashParams->supports_4_4_4 = tempSupports444;
        }

        /* Parse DWORD 6: Fast Read instructions and dummy cycles */
        if (readLength >= 28U)
        {
            /* Parse 4-4-4 Fast Read (Quad command) */
            if (flashParams->supports_4_4_4)
            {
                /* Bits 31:24 - 4-4-4 Fast Read instruction */
                uint32_t opcode444Temp = (dwordData[6] >> 24U) & 0xFFU;
                flashParams->fastReadOpcode_4_4_4 = (uint8_t)opcode444Temp;
                /* Bits 20:16 - Number of dummy cycles for 4-4-4 */
                /* Note: Dummy cycles for 4-4-4 */
                uint32_t dummy_low_temp = (dwordData[6] >> 16U) & 0x1FU;
                uint32_t dummy_high_temp = (dwordData[6] >> 21U) & 0x7U;
                uint8_t dummy_low = (uint8_t)dummy_low_temp;
                uint8_t dummy_high = (uint8_t)dummy_high_temp;
                flashParams->fastReadDummyCycles_4_4_4 = dummy_low + dummy_high;
            }
        }

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
            if (flashParams->eraseOpcode64K == 0xFFU)
            {
                flashParams->eraseOpcode64K = (uint8_t)SFDP_CMD_BLOCK_ERASE_64K;
            }
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

        /* Parse DWORD 14:  Quad command enable - Bits 8:4, Quad command disable - Bits 3:0 */
        if (readLength >= 60U)
        {
            uint32_t quadEnableTemp = (dwordData[14] >> 4U) & 0x1FU;
            uint8_t quadEnable = (uint8_t)quadEnableTemp;
            if ((quadEnable & 0x3U) != 0U)
            {
                flashParams->quadCommandEnable = 0x38U;
            }
            else if ((quadEnable & 0x4U) != 0U)
            {
                flashParams->quadCommandEnable = 0x35U;
            }
            else
            {
                /* Do nothing */
            }

            uint32_t quadDisableTemp = dwordData[14] & 0xFU;
            uint8_t quadDisable = (uint8_t)quadDisableTemp;
            if ((quadDisable & 0x1U) != 0U)
            {
                flashParams->quadCommandDisable = 0xFFU;
            }
            else if ((quadDisable & 0x2U) != 0U)
            {
                flashParams->quadCommandDisable = 0xF5U;
            }
            else
            {
                /* Do nothing */
            }
        }

        /* Select optimal read mode based on priority and map to QSPI width modes.
         * The driver automatically uses the best available mode supported by the
         * flash device as discovered through SFDP Basic Flash Parameter Table.
         */
        if (flashParams->supports_4_4_4)
        {
            /* Quad Command mode */
            flashParams->optimalReadWidth = (uint8_t)QUAD_CMD;
            flashParams->optimalReadOpcode = flashParams->fastReadOpcode_4_4_4;
            flashParams->optimalReadDummyCycles = flashParams->fastReadDummyCycles_4_4_4;
        }
        else if (flashParams->supports_1_4_4)
        {
            /* Quad I/O mode */
            flashParams->optimalReadWidth = (uint8_t)QUAD_IO;
            flashParams->optimalReadOpcode = flashParams->fastReadOpcode_1_4_4;
            flashParams->optimalReadDummyCycles = flashParams->fastReadDummyCycles_1_4_4;
        }
        else if (flashParams->supports_1_1_4)
        {
            /* Quad Output mode */
            flashParams->optimalReadWidth = (uint8_t)QUAD_OUTPUT;
            flashParams->optimalReadOpcode = flashParams->fastReadOpcode_1_1_4;
            flashParams->optimalReadDummyCycles = flashParams->fastReadDummyCycles_1_1_4;
        }
        else
        {
            /* Single SPI mode */
            flashParams->optimalReadWidth = (uint8_t)SINGLE_BIT_SPI;
            flashParams->optimalReadOpcode = flashParams->fastReadOpcode_1_1_1;
            flashParams->optimalReadDummyCycles = flashParams->fastReadDummyCycles_1_1_1;
        }

        flashParams->optimalWriteWidth = flashParams->optimalReadWidth;
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
            status = DRV_SFDP_ReadParamHeader(i, &parameterHeader);

            if (status == true)
            {
                uint16_t paramId = DRV_SFDP_GetParamId(&parameterHeader);

                /* Check for Basic Flash Parameter Table (ID = 0xFF00) */
                if (paramId == SFDP_BASIC_PARAM_TABLE_ID)
                {
                    uint32_t tableAddress = DRV_SFDP_GetTableAddress(&parameterHeader);

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

static bool DRV_SFDP_ResetFlash(void)
{
    bool status = false;

    (void) memset((void *)&qspi_command_xfer, 0, sizeof(qspi_command_xfer_t));

    qspi_command_xfer.instruction = (uint8_t)SFDP_CMD_FLASH_RESET_ENABLE;
    qspi_command_xfer.width = SINGLE_BIT_SPI;

    if (dObj->sfdpPlib->CommandWrite(&qspi_command_xfer, 0) == false)
    {
        return status;
    }

    qspi_command_xfer.instruction = (uint8_t)SFDP_CMD_FLASH_RESET;
    qspi_command_xfer.width = SINGLE_BIT_SPI;

    status  = dObj->sfdpPlib->CommandWrite(&qspi_command_xfer, 0);

    return status;
}

static bool DRV_SFDP_EnableQuadIO(void)
{
    bool status = false;

    /* Only enable Quad command if device supports 4-4-4 mode */
    if (dObj->flashParams.supports_4_4_4)
    {
        (void) memset((void *)&qspi_command_xfer, 0, sizeof(qspi_command_xfer_t));

        qspi_command_xfer.instruction = dObj->flashParams.quadCommandEnable;
        qspi_command_xfer.width = SINGLE_BIT_SPI;

        status  = dObj->sfdpPlib->CommandWrite(&qspi_command_xfer, 0);
    }

    return status;
}

static void DRV_SFDP_DisableQuadIO(void)
{
    if (dObj->flashParams.supports_4_4_4)
    {
        (void) memset((void *)&qspi_command_xfer, 0, sizeof(qspi_command_xfer_t));

        qspi_command_xfer.instruction = dObj->flashParams.quadCommandDisable;
        qspi_command_xfer.width = dObj->flashParams.optimalWriteWidth;

        (void)dObj->sfdpPlib->CommandWrite(&qspi_command_xfer, 0);
    }
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
    bool status = false;

    (void) memset((void *)&qspi_command_xfer, 0, sizeof(qspi_command_xfer_t));

    /* Use optimal write width determined from SFDP discovery */
    qspi_command_xfer.instruction = (uint8_t)SFDP_CMD_WRITE_ENABLE;
    qspi_command_xfer.width = dObj->flashParams.optimalWriteWidth;

    status  = dObj->sfdpPlib->CommandWrite(&qspi_command_xfer, 0);

    return status;
}

/* N25Q Quad Enable */
static bool DRV_SFDP_EnableQuadIO_N25Q(void)
{
    bool status = false;
    uint32_t config_reg = 0x1FU;

    /* Write enable required before config register write */
    if (DRV_SFDP_WriteEnable() == false)
    {
        return false;
    }

    (void) memset((void *)&qspi_register_xfer, 0, sizeof(qspi_register_xfer_t));

    qspi_register_xfer.instruction = (uint8_t)SFDP_CMD_WRITE_ENHANCED_VOLATILE_CONFIG_REG;
    qspi_register_xfer.width = SINGLE_BIT_SPI;
    qspi_register_xfer.dummy_cycles = 0U;

    status = dObj->sfdpPlib->RegisterWrite(&qspi_register_xfer, &config_reg, 1);

    return status;
}

/* W25 Quad Enable */
static bool DRV_SFDP_EnableQuadIO_W25(void)
{
    return true;
}

/* MX25L/MX66 Quad Enable */
static bool DRV_SFDP_EnableQuadIO_MX25L(void)
{
    bool status = false;

    (void) memset((void *)&qspi_command_xfer, 0, sizeof(qspi_command_xfer_t));

    qspi_command_xfer.instruction = (uint8_t)SFDP_CMD_ENABLE_QUAD_IO_MX25L;
    qspi_command_xfer.width = SINGLE_BIT_SPI;

    status = dObj->sfdpPlib->CommandWrite(&qspi_command_xfer, 0);

    return status;
}

/* S25FL Quad Enable */
static bool DRV_SFDP_EnableQuadIO_S25FL(void)
{
    bool status = false;
    uint8_t statusReg1 = 0;
    uint8_t statusReg2 = 0;
    uint16_t statusRegs = 0;

    /* Read Status Register 1 */
    (void) memset((void *)&qspi_register_xfer, 0, sizeof(qspi_register_xfer_t));
    qspi_register_xfer.instruction = (uint8_t)SFDP_CMD_READ_STATUS_REG;
    qspi_register_xfer.width = SINGLE_BIT_SPI;
    qspi_register_xfer.dummy_cycles = 0U;

    if (dObj->sfdpPlib->RegisterRead(&qspi_register_xfer, (uint32_t *)&statusReg1, 1) == false)
    {
        return false;
    }

    /* Read Status Register 2 (Configuration Register for S25FL) */
    (void) memset((void *)&qspi_register_xfer, 0, sizeof(qspi_register_xfer_t));
    qspi_register_xfer.instruction = (uint8_t)SFDP_CMD_READ_CONFIG_REG;
    qspi_register_xfer.width = SINGLE_BIT_SPI;
    qspi_register_xfer.dummy_cycles = 0U;

    if (dObj->sfdpPlib->RegisterRead(&qspi_register_xfer, (uint32_t *)&statusReg2, 1) == false)
    {
        return false;
    }

    /* Set QE bit (bit 1 of Status Register 2 / Configuration Register) */
    statusReg2 |= (1U << 1);

    /* Write enable before writing status registers */
    if (DRV_SFDP_WriteEnable() == false)
    {
        return false;
    }

    /* Combine both registers for write: SR1 in lower byte, SR2/CR in upper byte */
    statusRegs = ((uint16_t)statusReg2 << 8) | statusReg1;

    /* Write both Status Register 1 and Configuration Register */
    (void) memset((void *)&qspi_register_xfer, 0, sizeof(qspi_register_xfer_t));
    qspi_register_xfer.instruction = (uint8_t)SFDP_CMD_WRITE_STATUS_REG;
    qspi_register_xfer.width = SINGLE_BIT_SPI;
    qspi_register_xfer.dummy_cycles = 0U;

    status = dObj->sfdpPlib->RegisterWrite(&qspi_register_xfer, (uint32_t *)&statusRegs, 2);

    return status;
}

/* IS25 Quad Enable */
static bool DRV_SFDP_EnableQuadIO_IS25(void)
{
    bool status = false;
    uint8_t statusReg2 = 0;

    /* Read Status Register 2 */
    (void) memset((void *)&qspi_register_xfer, 0, sizeof(qspi_register_xfer_t));
    qspi_register_xfer.instruction = (uint8_t)SFDP_CMD_READ_STATUS_REG2;
    qspi_register_xfer.width = SINGLE_BIT_SPI;
    qspi_register_xfer.dummy_cycles = 0U;

    if (dObj->sfdpPlib->RegisterRead(&qspi_register_xfer, (uint32_t *)&statusReg2, 1) == false)
    {
        return false;
    }

    /* Set QE bit (bit 7 of Status Register 2) */
    statusReg2 |= (1U << 7);

    /* Write enable before writing status register */
    if (DRV_SFDP_WriteEnable() == false)
    {
        return false;
    }

    /* Write Status Register 2 */
    (void) memset((void *)&qspi_register_xfer, 0, sizeof(qspi_register_xfer_t));
    qspi_register_xfer.instruction = (uint8_t)SFDP_CMD_WRITE_STATUS_REG2;
    qspi_register_xfer.width = SINGLE_BIT_SPI;
    qspi_register_xfer.dummy_cycles = 0U;

    status = dObj->sfdpPlib->RegisterWrite(&qspi_register_xfer, (uint32_t *)&statusReg2, 1);

    return status;
}

/* Generic device-aware quad enable dispatcher */
static bool DRV_SFDP_EnableQuadIO_DeviceSpecific(void)
{
    bool status = false;

    switch (dObj->flashParams.deviceType)
    {
        case SFDP_DEVICE_TYPE_N25Q:
            status = DRV_SFDP_EnableQuadIO_N25Q();
            break;

        case SFDP_DEVICE_TYPE_W25:
            status = DRV_SFDP_EnableQuadIO_W25();
            break;

        case SFDP_DEVICE_TYPE_MX25L:
            status = DRV_SFDP_EnableQuadIO_MX25L();
            break;

        case SFDP_DEVICE_TYPE_S25FL:
            status = DRV_SFDP_EnableQuadIO_S25FL();
            break;

        case SFDP_DEVICE_TYPE_IS25:
            status = DRV_SFDP_EnableQuadIO_IS25();
            break;

        case SFDP_DEVICE_TYPE_SST26:
        case SFDP_DEVICE_TYPE_GENERIC:
        default:
            /* Use SFDP-discovered quad enable method */
            if (dObj->flashParams.supports_4_4_4 || dObj->flashParams.supports_1_4_4)
            {
                status = DRV_SFDP_EnableQuadIO(); /* Existing function */
            }
            else
            {
                status = true; /* No quad mode available */
            }
            break;
    }

    return status;
}

// *****************************************************************************
// *****************************************************************************
// Section: SFDP Driver Global Functions
// *****************************************************************************
// *****************************************************************************

bool DRV_SFDP_UnlockFlash( const DRV_HANDLE handle )
{
    bool status = false;
    bool blockWriteProtection = false;
    uint8_t jedecID[3] = { 0 };

    if(handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    if (DRV_SFDP_ReadJedecId(handle, (void *)&jedecID) == false)
    {
        status = false;
    }
    else
    {
        /* Unblock block write protection using write status register command */
        /* Check for SST26 devices (Microchip vendor ID = 0xBF) */
        if (jedecID[0] == 0xBFU)
        {
            if (jedecID[2] == 0x12U || jedecID[2] == 0x18U)
            {
                blockWriteProtection = true;
            }
            else
            {
                blockWriteProtection = false;
            }
        }
        else
        {
            blockWriteProtection = false;
        }

        if (DRV_SFDP_WriteEnable() == false)
        {
            return status;
        }

        if (blockWriteProtection == true)
        {
            uint32_t statusRegister = 0;

            (void) memset((void *)&qspi_register_xfer, 0, sizeof(qspi_register_xfer_t));

            qspi_register_xfer.instruction = (uint8_t)SFDP_CMD_WRITE_STATUS_REG;
            qspi_register_xfer.width = dObj->flashParams.optimalWriteWidth;

            status  = dObj->sfdpPlib->RegisterWrite(&qspi_register_xfer, &statusRegister, 1);
        }
        else
        {
            (void) memset((void *)&qspi_command_xfer, 0, sizeof(qspi_command_xfer_t));

            qspi_command_xfer.instruction = (uint8_t)SFDP_CMD_UNPROTECT_GLOBAL;
            qspi_command_xfer.width = dObj->flashParams.optimalWriteWidth;

            status  = dObj->sfdpPlib->CommandWrite(&qspi_command_xfer, 0);
        }
    }

    return status;
}

bool DRV_SFDP_ReadJedecId( const DRV_HANDLE handle, void *jedec_id)
{
    bool status = false;
    uint8_t dummyCycles = 0;

    if(handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    (void) memset((void *)&qspi_register_xfer, 0, sizeof(qspi_register_xfer_t));

    /* Use appropriate width and opcode based on optimal mode */
    if (dObj->flashParams.optimalWriteWidth == (uint8_t)QUAD_CMD)
    {
        /* Quad mode - use quad JEDEC ID read command */
        qspi_register_xfer.instruction = (uint8_t)SFDP_CMD_QUAD_JEDEC_ID_READ;
        qspi_register_xfer.width = QUAD_CMD;
        dummyCycles = 2U;
    }
    else
    {
        /* Single SPI mode */
        qspi_register_xfer.instruction = (uint8_t)SFDP_CMD_JEDEC_ID_READ;
        qspi_register_xfer.width = SINGLE_BIT_SPI;
        dummyCycles = 0U;
    }

    qspi_register_xfer.dummy_cycles = dummyCycles;

    status  = dObj->sfdpPlib->RegisterRead(&qspi_register_xfer, (uint32_t *)jedec_id, 3);

    return status;
}

bool DRV_SFDP_ReadStatus( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length )
{
    bool status = false;
    uint8_t dummyCycles = 0;

    if(handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    (void) memset((void *)&qspi_register_xfer, 0, sizeof(qspi_register_xfer_t));

    /* Use optimal write width for command operations */
    qspi_register_xfer.instruction = (uint8_t)SFDP_CMD_READ_STATUS_REG;
    qspi_register_xfer.width = dObj->flashParams.optimalWriteWidth;

    /* Quad mode typically requires dummy cycles for status read */
    if (dObj->flashParams.optimalWriteWidth == (uint8_t)QUAD_CMD)
    {
        dummyCycles = 2U;
    }
    else
    {
        dummyCycles = 0U;
    }

    qspi_register_xfer.dummy_cycles = dummyCycles;

    status  = dObj->sfdpPlib->RegisterRead(&qspi_register_xfer, (uint32_t *)rx_data, rx_data_length);

    return status;
}

DRV_SFDP_TRANSFER_STATUS DRV_SFDP_TransferStatusGet( const DRV_HANDLE handle )
{
    DRV_SFDP_TRANSFER_STATUS status = DRV_SFDP_TRANSFER_ERROR_UNKNOWN;

    uint8_t reg_status = 0;

    if(handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    if (gDrvSFDPObj.curOpType == DRV_SFDP_OPERATION_TYPE_READ )
    {
        return DRV_SFDP_TRANSFER_COMPLETED;
    }

    if (DRV_SFDP_ReadStatus(handle, (void *)&reg_status, 1) == false)
    {
        return status;
    }

    if((reg_status & (1UL<<0)) != 0U)
    {
        status = DRV_SFDP_TRANSFER_BUSY;
    }
    else
    {
        status = DRV_SFDP_TRANSFER_COMPLETED;
    }

    return status;
}

bool DRV_SFDP_Read( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address )
{
    bool status = false;

    if(handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    (void) memset((void *)&qspi_memory_xfer, 0, sizeof(qspi_memory_xfer_t));

    /* Device-specific read command selection */
    if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_W25)
    {
        /* W25 uses 0xEB for Quad I/O Read */
        qspi_memory_xfer.instruction = (uint8_t)SFDP_CMD_FAST_READ_QUAD_IO_W25;
        qspi_memory_xfer.width = QUAD_IO;
        qspi_memory_xfer.dummy_cycles = 6U;
    }
    else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_N25Q)
    {
        /* N25Q256 uses 0x0B with 10 dummy cycles in quad mode */
        qspi_memory_xfer.instruction = (uint8_t)SFDP_CMD_HIGH_SPEED_READ;
        qspi_memory_xfer.width = QUAD_CMD;
        qspi_memory_xfer.dummy_cycles = 10U;
    }
    else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_MX25L)
    {
        /* MX25L/MX66 uses 0xEB with 6 dummy cycles in quad command mode */
        qspi_memory_xfer.instruction = (uint8_t)SFDP_CMD_HIGH_SPEED_QREAD_MX25L;
        qspi_memory_xfer.width = QUAD_CMD;
        qspi_memory_xfer.dummy_cycles = 6U;
    }
    else
    {
        /* Use optimal read opcode and parameters discovered from SFDP */
        qspi_memory_xfer.instruction = dObj->flashParams.optimalReadOpcode;
        qspi_memory_xfer.width = dObj->flashParams.optimalReadWidth;
        qspi_memory_xfer.dummy_cycles = dObj->flashParams.optimalReadDummyCycles;
    }

    /* 32-bit address support: Check if device requires 4-byte addressing or address exceeds 24-bit */
    if ((dObj->flashParams.addressBytes == 4U) || (address > 0xFFFFFFU))
    {
        qspi_memory_xfer.addr_len = ADDRL_32_BIT;
    }
    else
    {
        qspi_memory_xfer.addr_len = ADDRL_24_BIT;
    }

    status = dObj->sfdpPlib->MemoryRead(&qspi_memory_xfer, (uint32_t *)rx_data, rx_data_length, address);

    gDrvSFDPObj.curOpType = DRV_SFDP_OPERATION_TYPE_READ;

    return status;
}

bool DRV_SFDP_PageWrite( const DRV_HANDLE handle, void *tx_data, uint32_t address )
{
    bool status = false;
    uint32_t pageSize = dObj->flashParams.pageSize;

    if(handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    if (DRV_SFDP_WriteEnable() == false)
    {
        return status;
    }

    (void) memset((void *)&qspi_memory_xfer, 0, sizeof(qspi_memory_xfer_t));

    /* Device-specific page program command */
    if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_W25)
    {
        /* W25 Quad Input Page Program */
        qspi_memory_xfer.instruction = (uint8_t)SFDP_CMD_QUAD_INPUT_PAGE_PROGRAM;
        qspi_memory_xfer.width = QUAD_OUTPUT;
    }
    else
    {
        /* Standard page program for other devices */
        qspi_memory_xfer.instruction = (uint8_t)SFDP_CMD_PAGE_PROGRAM;
        qspi_memory_xfer.width = dObj->flashParams.optimalWriteWidth;
    }

    /* 32-bit address support */
    if ((dObj->flashParams.addressBytes == 4U) || (address > 0xFFFFFFU))
    {
        qspi_memory_xfer.addr_len = ADDRL_32_BIT;
    }
    else
    {
        qspi_memory_xfer.addr_len = ADDRL_24_BIT;
    }

    status = dObj->sfdpPlib->MemoryWrite(&qspi_memory_xfer, (uint32_t *)tx_data, pageSize, address);

    gDrvSFDPObj.curOpType = DRV_SFDP_OPERATION_TYPE_WRITE;

    return status;
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2023 Rule 11.3"
#pragma coverity compliance end_block "MISRA C-2023 Rule 10.3"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2023 deviation block end */

/* MISRA C-2023 Rule 10.4, 10.3 deviated below. Deviation record ID - H3_MISRAC_2023_R_10_4_DR_1, H3_MISRAC_2023_R_10_3_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:1 "MISRA C-2023 Rule 10.4" "H3_MISRAC_2023_R_10_4_DR_1" )\
(deviate:1 "MISRA C-2023 Rule 10.3" "H3_MISRAC_2023_R_10_3_DR_1" )
</#if>

static bool DRV_SFDP_Erase( uint8_t instruction, uint32_t address )
{
    bool status = false;

    if (DRV_SFDP_WriteEnable() == false)
    {
        return status;
    }

    /* Use optimal write width for erase operations */
    qspi_command_xfer.instruction = instruction;
    qspi_command_xfer.width = dObj->flashParams.optimalWriteWidth;
    if (instruction != (uint8_t)SFDP_CMD_CHIP_ERASE)
    {
        qspi_command_xfer.addr_en = 1U;

        /* 32-bit address support */
        if ((dObj->flashParams.addressBytes == 4U) || (address > 0xFFFFFFU))
        {
            qspi_command_xfer.addr_len = ADDRL_32_BIT;
        }
        else
        {
            qspi_command_xfer.addr_len = ADDRL_24_BIT;
        }
    }

    status = dObj->sfdpPlib->CommandWrite(&qspi_command_xfer, address);

    gDrvSFDPObj.curOpType = DRV_SFDP_OPERATION_TYPE_ERASE;

    return status;
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2023 Rule 10.4"
#pragma coverity compliance end_block "MISRA C-2023 Rule 10.3"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2023 deviation block end */

bool DRV_SFDP_SectorErase( const DRV_HANDLE handle, uint32_t address )
{
    if(handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    /* Use sector erase opcode discovered from SFDP */
    return (DRV_SFDP_Erase(dObj->flashParams.eraseOpcode4K, address));
}

bool DRV_SFDP_BulkErase( const DRV_HANDLE handle, uint32_t address )
{
    if(handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    /* Use block erase opcode discovered from SFDP */
    return (DRV_SFDP_Erase(dObj->flashParams.eraseOpcode64K, address));
}

bool DRV_SFDP_ChipErase( const DRV_HANDLE handle )
{
    if(handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    return (DRV_SFDP_Erase((uint8_t)SFDP_CMD_CHIP_ERASE, 0));
}

bool DRV_SFDP_GeometryGet( const DRV_HANDLE handle, DRV_SFDP_GEOMETRY *geometry )
{
    uint32_t flash_size = 0;
    bool status = true;

    if ((handle == DRV_HANDLE_INVALID) || (geometry == NULL))
    {
        return false;
    }

    /* Check if SFDP discovery was successful */
    if (!dObj->sfdpDiscovered)
    {
        return false;
    }

    flash_size = dObj->flashParams.flashSize;

    if (flash_size == 0U)
    {
        status = false;
    }

    if(DRV_SFDP_START_ADDRESS >= flash_size)
    {
        status = false;
    }
    else
    {
        flash_size = flash_size - DRV_SFDP_START_ADDRESS;

        /* Flash size should be at-least of a Erase Block size */
        if (flash_size < dObj->flashParams.sectorSize)
        {
            status = false;
        }
        else
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
    }

    return status;
}

DRV_HANDLE DRV_SFDP_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    if ((dObj->status != SYS_STATUS_READY) ||
        (dObj->nClients >= DRV_SFDP_CLIENTS_NUMBER))
    {
        return DRV_HANDLE_INVALID;
    }

    /* Reset SFDP Flash device */
    if (DRV_SFDP_ResetFlash() == false)
    {
        return DRV_HANDLE_INVALID;
    }

    /* Discover flash parameters using SFDP */
    if (DRV_SFDP_DiscoverFlashParams() == false)
    {
        return DRV_HANDLE_INVALID;
    }

    /* Mark SFDP discovery as completed */
    dObj->sfdpDiscovered = true;

    /* Read JEDEC ID for device-specific detection */
    uint8_t jedecID[3] = { 0 };

    if (DRV_SFDP_ReadJedecId((DRV_HANDLE)drvIndex, (void *)&jedecID) == false)
    {
        /* Continue with generic mode if JEDEC ID read fails */
        dObj->flashParams.deviceType = SFDP_DEVICE_TYPE_GENERIC;
    }
    else
    {
        /* Detect device type and apply device-specific overrides */
        dObj->flashParams.deviceType = DRV_SFDP_DetectDeviceType(jedecID, &dObj->flashParams);

        /* Apply device-specific parameter overrides */
        if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_N25Q)
        {
            /* N25Q256 specific: Force quad command mode and 10 dummy cycles */
            dObj->flashParams.supports_4_4_4 = true;
            dObj->flashParams.optimalReadWidth = (uint8_t)QUAD_CMD;
            dObj->flashParams.optimalReadDummyCycles = 10U;
        }
        else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_W25)
        {
            /* W25 specific: Use 1-4-4 mode (Quad I/O) */
            dObj->flashParams.supports_1_4_4 = true;
            dObj->flashParams.optimalReadWidth = (uint8_t)QUAD_IO;
            dObj->flashParams.optimalReadOpcode = 0xEBU;
            dObj->flashParams.optimalReadDummyCycles = 6U;
        }
        else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_MX25L)
        {
            /* MX25L/MX66 specific: Use 4-4-4 mode (Quad Command) */
            dObj->flashParams.supports_4_4_4 = true;
            dObj->flashParams.optimalReadWidth = (uint8_t)QUAD_CMD;
            dObj->flashParams.optimalReadOpcode = 0xEBU;
            dObj->flashParams.optimalReadDummyCycles = 6U;
        }
        else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_S25FL)
        {
            /* S25FL specific: Use SFDP-discovered quad mode with QE bit enabled */
            /* Parameters are already discovered from SFDP, just ensure quad modes are enabled */
            if (dObj->flashParams.supports_1_4_4)
            {
                dObj->flashParams.optimalReadWidth = (uint8_t)QUAD_IO;
            }
            else if (dObj->flashParams.supports_1_1_4)
            {
                dObj->flashParams.optimalReadWidth = (uint8_t)QUAD_OUTPUT;
            }
            else
            {
                /* Use default SFDP-discovered mode */
            }
        }
        else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_IS25)
        {
            /* IS25 specific: Use SFDP-discovered quad mode with QE bit enabled */
            /* Parameters are already discovered from SFDP, just ensure quad modes are enabled */
            if (dObj->flashParams.supports_1_4_4)
            {
                dObj->flashParams.optimalReadWidth = (uint8_t)QUAD_IO;
            }
            else if (dObj->flashParams.supports_1_1_4)
            {
                dObj->flashParams.optimalReadWidth = (uint8_t)QUAD_OUTPUT;
            }
            else
            {
                /* Use default SFDP-discovered mode */
            }
        }
        else
        {
            /* For SST26 and generic devices, use SFDP-discovered parameters */
        }
    }

    /* Enable QUAD IO Mode using device-specific method */
    if (dObj->flashParams.supports_4_4_4 || dObj->flashParams.supports_1_4_4)
    {
        if (DRV_SFDP_EnableQuadIO_DeviceSpecific() == false)
        {
            /* Continue even if quad enable fails - fall back to single SPI */
            dObj->flashParams.optimalReadWidth = (uint8_t)SINGLE_BIT_SPI;
            dObj->flashParams.optimalWriteWidth = (uint8_t)SINGLE_BIT_SPI;
        }
    }

    if (((uint32_t)ioIntent & (uint32_t)DRV_IO_INTENT_WRITE) == ((uint32_t)DRV_IO_INTENT_WRITE))
    {
        /* Unlock the Flash */
        if (DRV_SFDP_UnlockFlash((DRV_HANDLE)drvIndex) == false)
        {
            /* Continue even if unlock fails - some devices don't require unlock */
        }
    }

    dObj->nClients++;

    dObj->ioIntent = ioIntent;

    return ((DRV_HANDLE)drvIndex);
}

void DRV_SFDP_Close( const DRV_HANDLE handle )
{
    if ( (handle != DRV_HANDLE_INVALID) &&
         (dObj->nClients > 0U))
    {
        DRV_SFDP_DisableQuadIO();
        dObj->nClients--;
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

    /* Initialize SFDP discovery flag */
    dObj->sfdpDiscovered = false;

    /* Initialize flash parameters to default values */
    (void) memset((void *)&dObj->flashParams, 0, sizeof(DRV_SFDP_FLASH_PARAMS));

    /* Assign to the local pointer the init data passed */
    sfdpInit       = (DRV_SFDP_INIT *)init;

    /* Initialize the attached memory device functions */
    dObj->sfdpPlib = sfdpInit->sfdpPlib;

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
/* MISRAC 2023 deviation block end */

SYS_STATUS DRV_SFDP_Status( const SYS_MODULE_INDEX drvIndex )
{
    /* Return the driver status */
    return (gDrvSFDPObj.status);
}
