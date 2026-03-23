/******************************************************************************
  SFDP Driver Implementation for SQI

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sfdp.c

  Summary:
    SFDP Driver Interface Definition for SQI Interface

  Description:
    The SFDP Driver provides an interface to access JEDEC-compliant NOR Flash
    devices using Serial Flash Discoverable Parameters (SFDP). This implementation
    uses SQI PLIB with DMA descriptor chains.
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
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
#include "system/cache/sys_cache.h"
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

<#if CHIP_SELECT == "Chip Select 0">
    <#lt>#define SQI_CHIP_SELECT         SQI_BDCTRL_SPI_DEV_SEL10(0x00)
<#elseif CHIP_SELECT == "Chip Select 1">
    <#lt>#define SQI_CHIP_SELECT         SQI_BDCTRL_SPI_DEV_SEL10(0x01)
</#if>

<#if LANE_MODE == "QUAD">
#define SQI_LANE_MODE_M           SQI_BDCTRL_MODE(0x02)
<#else>
#define SQI_LANE_MODE_M           SQI_BDCTRL_MODE(0x00)
</#if>

/* For SFDP discovery */
#define SQI_LANE_MODE_SINGLE      SQI_BDCTRL_MODE(0x00)

#define CMD_DESC_NUMBER           5
#define DUMMY_BYTE                0xFF

static DRV_SFDP_OBJECT gDrvSFDPObj;
static DRV_SFDP_OBJECT *dObj = &gDrvSFDPObj;

static sqi_dma_desc_t CACHE_ALIGN sqiCmdDesc[CMD_DESC_NUMBER];
static sqi_dma_desc_t CACHE_ALIGN sqiBufDesc[DRV_SFDP_BUFF_DESC_NUMBER];

static uint8_t CACHE_ALIGN sqiCmdBuffer[32];
static uint8_t CACHE_ALIGN sqiReadBuffer[32];

static CACHE_ALIGN DRV_SFDP_HEADER sfdpHeader = { 0 };
static CACHE_ALIGN DRV_SFDP_PARAM_HEADER parameterHeader = { 0 };
static CACHE_ALIGN uint32_t dwordData[20] = { 0 };

// *****************************************************************************
// *****************************************************************************
// Section: SFDP Driver Local Functions
// *****************************************************************************
// *****************************************************************************

/* Reads SFDP data using DMA descriptor chain.
 * Per JESD216, SFDP must be read in single-bit SPI mode (1-1-1) */
static bool DRV_SFDP_ReadSFDPData(uint32_t address, uint8_t *data, uint32_t length)
{
    void *ptr = NULL;

    if ((data == NULL) || (length == 0U))
    {
        return false;
    }

    dObj->isTransferDone = false;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_InvalidateDCache_by_Addr(data, (int32_t)length);
</#if>

    /* Descriptor 0: SFDP Read Command (0x5A) */
    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_READ_SFDP;
    /* Descriptor 0: 24-bit Address */
    sqiCmdBuffer[1] = (uint8_t)((address >> 16) & 0xFFU);
    sqiCmdBuffer[2] = (uint8_t)((address >> 8) & 0xFFU);
    sqiCmdBuffer[3] = (uint8_t)(address & 0xFFU);
    /* Descriptor 0: 8 Dummy Cycles (1 byte) */
    sqiCmdBuffer[4] = DUMMY_BYTE;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(5) | SQI_LANE_MODE_SINGLE |
                             SQI_CHIP_SELECT | SQI_BDCTRL_DESC_EN_Msk);
    ptr = &sqiCmdBuffer[0];
    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(ptr);
    sqiCmdDesc[0].bd_stat = 0;
    ptr = &sqiBufDesc[0];
    sqiCmdDesc[0].bd_nxtptr = (sqi_dma_desc_t *)(ptr);


    /* Descriptor 0: Data Read */
    sqiBufDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(length) |
                             SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_LANE_MODE_SINGLE | SQI_BDCTRL_DIR_Msk |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);
    sqiBufDesc[0].bd_bufaddr = (uint32_t *)(data);
    sqiBufDesc[0].bd_stat = 0;
    sqiBufDesc[0].bd_nxtptr = NULL;

    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_READ;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 5);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t));
    SYS_CACHE_CleanDCache_by_Addr(&sqiBufDesc[0], (int32_t)sizeof(sqi_dma_desc_t));
</#if>

    /* Initiate DMA transfer */
    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    /* Wait for completion (blocking for SFDP discovery) */
    while (dObj->isTransferDone == false)
    {
        /* Nothing to do */
    }

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_InvalidateDCache_by_Addr(data, (int32_t)length);
</#if>

    return true;
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
        uint8_t addrMode = (uint8_t)((dwordData[0] >> 17U) & 0x03U);
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
                flashParams->flashSize = (1U << (n - 3U));
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
                flashParams->fastReadOpcode_1_4_4 = (uint8_t)((dwordData[2] >> 8U) & 0xFFU);
                /* Bits 4:0 - Number of dummy cycles for 1-4-4 */
                flashParams->fastReadDummyCycles_1_4_4 = (uint8_t)(dwordData[2] & 0x1FU) + (uint8_t)((dwordData[2] >> 5U) & 0x7U);
            }

            /* Parse 1-1-4 Fast Read (Quad Output) */
            if (flashParams->supports_1_1_4)
            {
                /* Bits 31:24 - 1-1-4 Fast Read instruction */
                flashParams->fastReadOpcode_1_1_4 = (uint8_t)((dwordData[2] >> 24U) & 0xFFU);
                /* Bits 20:16 - Number of dummy cycles for 1-1-4 */
                /* Note: Dummy cycles for 1-1-4 */
                flashParams->fastReadDummyCycles_1_1_4 = (uint8_t)((dwordData[2] >> 16U) & 0x1FU);
            }
        }

        /* Parse DWORD 4: Fast Read capabilities */
        if (readLength >= 20U)
        {
            /* Bit 4: Supports 4-4-4 Fast Read (Quad command) */
            flashParams->supports_4_4_4 = ((dwordData[4] & 0x10U) != 0U);
        }

        /* Parse DWORD 6: Fast Read instructions and dummy cycles */
        if (readLength >= 28U)
        {
            /* Parse 4-4-4 Fast Read (Quad command) */
            if (flashParams->supports_4_4_4)
            {
                /* Bits 31:24 - 4-4-4 Fast Read instruction */
                flashParams->fastReadOpcode_4_4_4 = (uint8_t)((dwordData[6] >> 24U) & 0xFFU);
                /* Bits 20:16 - Number of dummy cycles for 4-4-4 */
                /* Note: Dummy cycles for 4-4-4 */
                flashParams->fastReadDummyCycles_4_4_4 = (uint8_t)((dwordData[6] >> 16U) & 0x1FU) + (uint8_t)((dwordData[6] >> 21U) & 0x7U);
            }
        }

        /* Parse DWORD 7: Sector Erase (4KB) - Bits 7:0 size, Bits 15:8 opcode */
        if (readLength >= 32U)
        {
            flashParams->eraseOpcode4K = (uint8_t)((dwordData[7] >> 8U) & 0xFFU);
            /* Sector size encoding: 2^N bytes */
            uint8_t sizeExp = (uint8_t)(dwordData[7] & 0xFFU);
            if (sizeExp != 0U)
            {
                flashParams->sectorSize = (1U << sizeExp);
            }
        }

        /* Parse DWORD 8: Block Erase Types */
        if (readLength >= 36U)
        {
            /* Erase 64KB: Bits 31:24 opcode, Bits 23:16 size */
            flashParams->eraseOpcode64K = (uint8_t)((dwordData[8] >> 24U) & 0xFFU);
            if (flashParams->eraseOpcode64K == 0xFFU)
            {
                flashParams->eraseOpcode64K = SFDP_CMD_BLOCK_ERASE_64K;
            }
            uint8_t blockSizeExp = (uint8_t)((dwordData[8] >> 16U) & 0xFFU);
            if (blockSizeExp != 0U)
            {
                flashParams->blockSize = (1U << blockSizeExp);
            }
        }

        /* Default page size */
        flashParams->pageSize = 256U;

        /* Parse DWORD 10: Page Size - Bits 7:4 (2^N bytes) */
        if (readLength >= 44U)
        {
            uint8_t pageSizeExp = (uint8_t)((dwordData[10] >> 4U) & 0x0FU);
            if (pageSizeExp != 0U)
            {
                flashParams->pageSize = (1U << pageSizeExp);
            }
        }

        /* Parse DWORD 14:  Quad command enable - Bits 8:4, Quad command disable - Bits 3:0 */
        if (readLength >= 60U)
        {
            uint8_t quadEnable = (uint8_t)((dwordData[14] >> 4U) & 0x1FU);
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
                // do nothing
            }

            uint8_t quadDisable = (uint8_t)(dwordData[14] & 0xFU);
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
                // do nothing
            }
        }

        /* Select optimal read mode based on priority and map to SQI width modes.
         * The driver automatically uses the best available mode supported by the
         * flash device as discovered through SFDP Basic Flash Parameter Table.
         */
        if (flashParams->supports_4_4_4)
        {
            /* Quad mode */
            flashParams->optimalReadWidth = SQI_LANE_MODE_M;
            flashParams->optimalReadOpcode = flashParams->fastReadOpcode_4_4_4;
            flashParams->optimalReadDummyCycles = flashParams->fastReadDummyCycles_4_4_4;
        }
        else if (flashParams->supports_1_4_4)
        {
            /* Quad mode */
            flashParams->optimalReadWidth = SQI_LANE_MODE_M;
            flashParams->optimalReadOpcode = flashParams->fastReadOpcode_1_4_4;
            flashParams->optimalReadDummyCycles = flashParams->fastReadDummyCycles_1_4_4;
        }
        else if (flashParams->supports_1_1_4)
        {
            /* Quad mode */
            flashParams->optimalReadWidth = SQI_LANE_MODE_M;
            flashParams->optimalReadOpcode = flashParams->fastReadOpcode_1_1_4;
            flashParams->optimalReadDummyCycles = flashParams->fastReadDummyCycles_1_1_4;
        }
        else
        {
            /* Single SPI mode */
            flashParams->optimalReadWidth = SQI_LANE_MODE_SINGLE;
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

static bool DRV_SFDP_InitiateReadStatus(void)
{
    void *ptr = NULL;

    dObj->isTransferDone = false;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_InvalidateDCache_by_Addr(sqiReadBuffer, (int32_t)sizeof(sqiReadBuffer));
</#if>

    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_READ_STATUS_REG;

<#if LANE_MODE == "QUAD">
    sqiCmdBuffer[1] = DUMMY_BYTE;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(2) | SQI_LANE_MODE_M |
                             SQI_CHIP_SELECT | SQI_BDCTRL_DESC_EN_Msk);
<#else>
    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_LANE_MODE_M |
                             SQI_CHIP_SELECT | SQI_BDCTRL_DESC_EN_Msk);
</#if>
    ptr = &sqiCmdBuffer[0];
    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(ptr);
    sqiCmdDesc[0].bd_stat = 0;
    ptr = &sqiBufDesc[0];
    sqiCmdDesc[0].bd_nxtptr = (sqi_dma_desc_t *)(ptr);

    sqiBufDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_LANE_MODE_M | SQI_BDCTRL_DIR_Msk |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);
    ptr = sqiReadBuffer;
    sqiBufDesc[0].bd_bufaddr = (uint32_t *)(ptr);
    sqiBufDesc[0].bd_stat = 0;
    sqiBufDesc[0].bd_nxtptr = NULL;

    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_READ_STATUS;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 2);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t));
    SYS_CACHE_CleanDCache_by_Addr(&sqiBufDesc[0], (int32_t)sizeof(sqi_dma_desc_t));
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    return true;
}

static void DRV_SFDP_EventHandler(uintptr_t context)
{
    DRV_SFDP_OBJECT *obj = (DRV_SFDP_OBJECT *)context;

    obj->isTransferDone = true;

    if (obj->curOpType == DRV_SFDP_OPERATION_TYPE_WRITE || obj->curOpType == DRV_SFDP_OPERATION_TYPE_ERASE)
    {
        (void)DRV_SFDP_InitiateReadStatus();
    }
    else if (obj->curOpType == DRV_SFDP_OPERATION_TYPE_READ_STATUS)
    {
        if ((sqiReadBuffer[0] & 0x81U) == 0U)
        {
            obj->internal_write_complete_flag = true;
        }
        else
        {
            (void)DRV_SFDP_InitiateReadStatus();
        }
    }
    else
    {
        // Do nothing
    }
}

/* MISRA C-2023 Rule 11.3 deviated:40 Deviation record ID -  H3_MISRAC_2023_R_11_3_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:40 "MISRA C-2023 Rule 11.3" "H3_MISRAC_2023_R_11_3_DR_1"
</#if>

static void DRV_SFDP_ResetFlash(void)
{
    dObj->isTransferDone = false;
    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_CMD;

    /* Reset Enable Command */
    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_FLASH_RESET_ENABLE;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);

    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[0]);
    sqiCmdDesc[0].bd_stat = 0;
    sqiCmdDesc[0].bd_nxtptr = NULL;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 1);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t));
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    while (dObj->isTransferDone == false)
    {
        /* Nothing to do */
    }

    dObj->isTransferDone = false;

    /* Reset Command */
    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_FLASH_RESET;

    sqiCmdDesc[1].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);

    sqiCmdDesc[1].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[0]);
    sqiCmdDesc[1].bd_stat = 0;
    sqiCmdDesc[1].bd_nxtptr = NULL;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 1);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[1], (int32_t)sizeof(sqi_dma_desc_t));
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[1]));

    while (dObj->isTransferDone == false)
    {
        /* Nothing to do */
    }
}

static void DRV_SFDP_WriteEnable(void)
{
    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_WRITE_ENABLE;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_LANE_MODE_M |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);

    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[0]);
    sqiCmdDesc[0].bd_stat = 0;
    sqiCmdDesc[0].bd_nxtptr = (sqi_dma_desc_t *)(&sqiCmdDesc[1]);
}

<#if LANE_MODE == "QUAD">
static void DRV_SFDP_EnableQuadIO(void)
{
    /* Only enable Quad command if device supports 4-4-4 mode */
    if (dObj->flashParams.supports_4_4_4)
    {
        dObj->isTransferDone = false;

        sqiCmdBuffer[0] = (uint8_t)dObj->flashParams.quadCommandEnable;

        sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_BDCTRL_PKT_INT_EN_Msk |
                                 SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                                 SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                                 SQI_BDCTRL_DESC_EN_Msk);

        sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[0]);
        sqiCmdDesc[0].bd_stat = 0;
        sqiCmdDesc[0].bd_nxtptr = NULL;

        dObj->curOpType = DRV_SFDP_OPERATION_TYPE_CMD;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
        SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 1);
        SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t));
</#if>

        dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

        while (dObj->isTransferDone == false)
        {
            /* Nothing to do */
        }
    }
}

static void DRV_SFDP_DisableQuadIO(void)
{
    dObj->isTransferDone = false;

    sqiCmdBuffer[0] = (uint8_t)0xFFU;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);

    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[0]);
    sqiCmdDesc[0].bd_stat = 0;
    sqiCmdDesc[0].bd_nxtptr = NULL;

    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_CMD;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 1);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t));
</#if>
    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    while (dObj->isTransferDone == false)
    {
        /* Nothing to do */
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

/* N25Q256 Quad Enable */
static bool DRV_SFDP_EnableQuadIO_N25Q(void)
{
    bool status = false;
    uint8_t config_reg = 0x1FU; /* Quad protocol enabled, 10 dummy cycles */

    /* First send write enable command */
    DRV_SFDP_WriteEnable();

    dObj->isTransferDone = false;

    /* Setup command descriptor for Enhanced Volatile Config Register write */
    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_WRITE_ENABLE;
    sqiCmdBuffer[1] = (uint8_t)SFDP_CMD_WRITE_ENHANCED_VOLATILE_CONFIG_REG;
    sqiCmdBuffer[2] = config_reg;

    /* Write enable descriptor */
    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_LANE_MODE_SINGLE |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);
    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[0]);
    sqiCmdDesc[0].bd_stat = 0;
    sqiCmdDesc[0].bd_nxtptr = (sqi_dma_desc_t *)(&sqiCmdDesc[1]);

    /* Enhanced volatile config register write descriptor */
    sqiCmdDesc[1].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(2) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_LANE_MODE_SINGLE | SQI_CHIP_SELECT |
                             SQI_BDCTRL_CS_ASSERT_Msk | SQI_BDCTRL_DESC_EN_Msk);
    sqiCmdDesc[1].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[1]);
    sqiCmdDesc[1].bd_stat = 0;
    sqiCmdDesc[1].bd_nxtptr = NULL;

    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_CMD;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 3);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t) * 2);
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    while (dObj->isTransferDone == false)
    {
        /* Nothing to do */
    }

    status = true;

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

    dObj->isTransferDone = false;

    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_ENABLE_QUAD_IO_MX25L;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);

    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[0]);
    sqiCmdDesc[0].bd_stat = 0;
    sqiCmdDesc[0].bd_nxtptr = NULL;

    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_CMD;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 1);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t));
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    while (dObj->isTransferDone == false)
    {
        /* Nothing to do */
    }

    status = true;

    return status;
}

/* S25FL Quad Enable */
static bool DRV_SFDP_EnableQuadIO_S25FL(void)
{
    bool status = false;
    uint8_t statusReg1 = 0;
    uint8_t statusReg2 = 0;

    /* Read Status Register 1 using single bit mode */
    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_READ_STATUS_REG;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_LANE_MODE_SINGLE |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);
    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[0]);
    sqiCmdDesc[0].bd_stat = 0;
    sqiCmdDesc[0].bd_nxtptr = (sqi_dma_desc_t *)(&sqiCmdDesc[1]);

    sqiCmdDesc[1].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_LANE_MODE_SINGLE | SQI_CHIP_SELECT |
                             SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);
    sqiCmdDesc[1].bd_bufaddr = (uint32_t *)(&statusReg1);
    sqiCmdDesc[1].bd_stat = 0;
    sqiCmdDesc[1].bd_nxtptr = NULL;

    dObj->isTransferDone = false;
    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_READ_STATUS;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 1);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t) * 2);
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    while (dObj->isTransferDone == false) { /* Wait */ }

    /* Read Configuration Register (acts as SR2 for S25FL) */
    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_READ_CONFIG_REG;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_LANE_MODE_SINGLE |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);
    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[0]);
    sqiCmdDesc[0].bd_stat = 0;
    sqiCmdDesc[0].bd_nxtptr = (sqi_dma_desc_t *)(&sqiCmdDesc[1]);

    sqiCmdDesc[1].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_LANE_MODE_SINGLE | SQI_CHIP_SELECT |
                             SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);
    sqiCmdDesc[1].bd_bufaddr = (uint32_t *)(&statusReg2);
    sqiCmdDesc[1].bd_stat = 0;
    sqiCmdDesc[1].bd_nxtptr = NULL;

    dObj->isTransferDone = false;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 1);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t) * 2);
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    while (dObj->isTransferDone == false) { /* Wait */ }

    /* Set QE bit (bit 1 of Configuration Register) */
    statusReg2 |= (1U << 1);

    /* Write enable */
    DRV_SFDP_WriteEnable();

    /* Write both Status Register 1 and Configuration Register */
    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_WRITE_ENABLE;
    sqiCmdBuffer[1] = (uint8_t)SFDP_CMD_WRITE_STATUS_REG;
    sqiCmdBuffer[2] = statusReg1;
    sqiCmdBuffer[3] = statusReg2;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_LANE_MODE_SINGLE |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);
    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[0]);
    sqiCmdDesc[0].bd_stat = 0;
    sqiCmdDesc[0].bd_nxtptr = (sqi_dma_desc_t *)(&sqiCmdDesc[1]);

    sqiCmdDesc[1].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(3) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_LANE_MODE_SINGLE | SQI_CHIP_SELECT |
                             SQI_BDCTRL_CS_ASSERT_Msk | SQI_BDCTRL_DESC_EN_Msk);
    sqiCmdDesc[1].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[1]);
    sqiCmdDesc[1].bd_stat = 0;
    sqiCmdDesc[1].bd_nxtptr = NULL;

    dObj->isTransferDone = false;
    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_CMD;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 4);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t) * 2);
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    while (dObj->isTransferDone == false) { /* Wait */ }

    status = true;
    return status;
}

/* IS25 Quad Enable */
static bool DRV_SFDP_EnableQuadIO_IS25(void)
{
    bool status = false;
    uint8_t statusReg2 = 0;

    /* Read Status Register 2 */
    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_READ_STATUS_REG2;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_LANE_MODE_SINGLE |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);
    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[0]);
    sqiCmdDesc[0].bd_stat = 0;
    sqiCmdDesc[0].bd_nxtptr = (sqi_dma_desc_t *)(&sqiCmdDesc[1]);

    sqiCmdDesc[1].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_LANE_MODE_SINGLE | SQI_CHIP_SELECT |
                             SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);
    sqiCmdDesc[1].bd_bufaddr = (uint32_t *)(&statusReg2);
    sqiCmdDesc[1].bd_stat = 0;
    sqiCmdDesc[1].bd_nxtptr = NULL;

    dObj->isTransferDone = false;
    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_READ_STATUS;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 1);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t) * 2);
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    while (dObj->isTransferDone == false) { /* Wait */ }

    /* Set QE bit (bit 7 of Status Register 2) */
    statusReg2 |= (1U << 7);

    /* Write enable */
    DRV_SFDP_WriteEnable();

    /* Write Status Register 2 */
    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_WRITE_ENABLE;
    sqiCmdBuffer[1] = (uint8_t)SFDP_CMD_WRITE_STATUS_REG2;
    sqiCmdBuffer[2] = statusReg2;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_LANE_MODE_SINGLE |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);
    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[0]);
    sqiCmdDesc[0].bd_stat = 0;
    sqiCmdDesc[0].bd_nxtptr = (sqi_dma_desc_t *)(&sqiCmdDesc[1]);

    sqiCmdDesc[1].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(2) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_LANE_MODE_SINGLE | SQI_CHIP_SELECT |
                             SQI_BDCTRL_CS_ASSERT_Msk | SQI_BDCTRL_DESC_EN_Msk);
    sqiCmdDesc[1].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[1]);
    sqiCmdDesc[1].bd_stat = 0;
    sqiCmdDesc[1].bd_nxtptr = NULL;

    dObj->isTransferDone = false;
    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_CMD;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 3);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t) * 2);
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    while (dObj->isTransferDone == false) { /* Wait */ }

    status = true;
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
                DRV_SFDP_EnableQuadIO(); /* Existing function */
                status = true;
            }
            else
            {
                status = true; /* No quad mode available */
            }
            break;
    }

    return status;
}
</#if>

static bool DRV_SFDP_ValidateHandleAndCheckBusy(const DRV_HANDLE handle)
{
    bool validatecheck = false;
    /* Validate the handle.
     * If isTransferDone is False then there is an operation in progress.
     */
    if((handle == DRV_HANDLE_INVALID) || (dObj->isTransferDone == false))
    {
        validatecheck = true;
    }

    return validatecheck;
}

// *****************************************************************************
// *****************************************************************************
// Section: SFDP Driver Global Functions
// *****************************************************************************
// *****************************************************************************

bool DRV_SFDP_UnlockFlash(const DRV_HANDLE handle)
{
    bool status = true;
    bool blockWriteProtection = false;
    uint32_t bdctrlBufLen = 0U;
    <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    uint8_t bufLen = 0U;
    </#if>

    if(DRV_SFDP_ValidateHandleAndCheckBusy(handle) == true)
    {
        status = false;
    }
    else
    {
        <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
        SYS_CACHE_InvalidateDCache_by_Addr(sqiReadBuffer, 4);
        </#if>

        if (DRV_SFDP_ReadJedecId(handle, (void *)sqiReadBuffer) == false)
        {
            status = false;
        }
        else
        {
            /* Check for SST26 devices (Microchip vendor ID = 0xBF) */
            if (sqiReadBuffer[0] == 0xBFU)
            {
                if (sqiReadBuffer[2] == 0x12U || sqiReadBuffer[2] == 0x18U)
                {
                    blockWriteProtection = true;
                }
            }

            dObj->isTransferDone = false;

            DRV_SFDP_WriteEnable();

            if (blockWriteProtection == true)
            {
                sqiCmdBuffer[4] = (uint8_t)SFDP_CMD_WRITE_STATUS_REG;
                sqiCmdBuffer[5] = 0U;
                bdctrlBufLen = 2U;
                <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
                bufLen                        = 6U;
                </#if>
            }
            else
            {
                sqiCmdBuffer[4] = (uint8_t)SFDP_CMD_UNPROTECT_GLOBAL;
                bdctrlBufLen = 1U;
                <#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
                bufLen                        = 5U;
                </#if>
            }

            sqiCmdDesc[1].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(bdctrlBufLen) | SQI_BDCTRL_PKT_INT_EN_Msk |
                                     SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                                     SQI_LANE_MODE_M | SQI_CHIP_SELECT |
                                     SQI_BDCTRL_CS_ASSERT_Msk | SQI_BDCTRL_DESC_EN_Msk);

            sqiCmdDesc[1].bd_bufaddr = (uint32_t *)(&sqiCmdBuffer[4]);
            sqiCmdDesc[1].bd_stat = 0;
            sqiCmdDesc[1].bd_nxtptr = NULL;

            dObj->curOpType = DRV_SFDP_OPERATION_TYPE_CMD;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
            SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], (int32_t)bufLen);
            SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], 2 * (int32_t)sizeof(sqi_dma_desc_t));
</#if>

            dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

            while (dObj->isTransferDone == false)
            {
                /* Nothing to do */
            }
        }
    }

    return status;
}

bool DRV_SFDP_ReadJedecId(const DRV_HANDLE handle, void *jedec_id)
{
    if(DRV_SFDP_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    dObj->isTransferDone = false;

<#if LANE_MODE == "QUAD">
    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_QUAD_JEDEC_ID_READ;
    sqiCmdBuffer[1] = DUMMY_BYTE;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(2) | SQI_LANE_MODE_M |
                             SQI_CHIP_SELECT | SQI_BDCTRL_DESC_EN_Msk);
<#else>
    sqiCmdBuffer[0] = (uint8_t)SFDP_CMD_JEDEC_ID_READ;

    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1) | SQI_LANE_MODE_M |
                             SQI_CHIP_SELECT | SQI_BDCTRL_DESC_EN_Msk);
</#if>

    sqiCmdDesc[0].bd_bufaddr    = (uint32_t *)(&sqiCmdBuffer[0]);
    sqiCmdDesc[0].bd_stat       = 0;
    sqiCmdDesc[0].bd_nxtptr     = (sqi_dma_desc_t *)(&sqiBufDesc[0]);

    sqiBufDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(4) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             SQI_LANE_MODE_M | SQI_BDCTRL_DIR_Msk |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);

    sqiBufDesc[0].bd_bufaddr = (uint32_t *)(jedec_id);
    sqiBufDesc[0].bd_stat = 0;
    sqiBufDesc[0].bd_nxtptr = NULL;

    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_READ;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 2);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], (int32_t)sizeof(sqi_dma_desc_t));
    SYS_CACHE_CleanDCache_by_Addr(&sqiBufDesc[0], (int32_t)sizeof(sqi_dma_desc_t));
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    while (dObj->isTransferDone == false)
    {
        /* Nothing to do */
    }

    return true;
}

bool DRV_SFDP_ReadStatus(const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length)
{
    (void)rx_data_length;

    uint8_t *status = (uint8_t *)rx_data;

    if (status == NULL)
    {
        return false;
    }

    if(DRV_SFDP_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    (void)DRV_SFDP_InitiateReadStatus();

    while (dObj->isTransferDone == false)
    {
        /* Nothing to do */
    }

    *status = sqiReadBuffer[0];

    return true;
}

DRV_SFDP_TRANSFER_STATUS DRV_SFDP_TransferStatusGet(const DRV_HANDLE handle)
{
    DRV_SFDP_TRANSFER_STATUS status = DRV_SFDP_TRANSFER_ERROR_UNKNOWN;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    if (dObj->curOpType == DRV_SFDP_OPERATION_TYPE_READ)
    {
        if (dObj->isTransferDone == true)
        {
            status = DRV_SFDP_TRANSFER_COMPLETED;
        }
        else
        {
            status = DRV_SFDP_TRANSFER_BUSY;
        }
    }
    else if (dObj->curOpType == DRV_SFDP_OPERATION_TYPE_WRITE ||
             dObj->curOpType == DRV_SFDP_OPERATION_TYPE_ERASE ||
             dObj->curOpType == DRV_SFDP_OPERATION_TYPE_READ_STATUS)
    {
        if (dObj->isTransferDone == true && dObj->internal_write_complete_flag == true)
        {
            dObj->internal_write_complete_flag = false;
            status = DRV_SFDP_TRANSFER_COMPLETED;
        }
        else
        {
            status = DRV_SFDP_TRANSFER_BUSY;
        }
    }
    else
    {
        //Do nothing
    }

    return status;
}

bool DRV_SFDP_Read(const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address)
{
    void *ptr = NULL;
    uint32_t pendingBytes = rx_data_length;
    uint8_t *readBuffer = (uint8_t *)rx_data;
    uint32_t numBytes = 0;
    uint32_t i = 0;
    uint8_t addrBytes = 0;

    if (DRV_SFDP_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    if ((rx_data_length == 0U) || (rx_data_length > (dObj->flashParams.pageSize * DRV_SFDP_BUFF_DESC_NUMBER)))
    {
        return false;
    }

    dObj->isTransferDone = false;

    /* Device-specific read command selection */
    uint8_t readOpcode;
    uint32_t readWidth;
    uint8_t dummyCycles;

    if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_W25)
    {
        /* W25 uses 0xEB for Quad I/O Read */
        readOpcode = (uint8_t)SFDP_CMD_FAST_READ_QUAD_IO_W25;
        readWidth = SQI_LANE_MODE_M;
        dummyCycles = 6;
    }
    else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_N25Q)
    {
        /* N25Q256 uses 0x0B with 10 dummy cycles in quad mode */
        readOpcode = (uint8_t)SFDP_CMD_HIGH_SPEED_READ;
        readWidth = SQI_LANE_MODE_M;
        dummyCycles = 10;
    }
    else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_MX25L)
    {
        /* MX25L/MX66 uses 0xEB with 6 dummy cycles in quad command mode */
        readOpcode = (uint8_t)SFDP_CMD_HIGH_SPEED_QREAD_MX25L;
        readWidth = SQI_LANE_MODE_M;
        dummyCycles = 6;
    }
    else
    {
        /* Use optimal read opcode and parameters discovered from SFDP */
        readOpcode = dObj->flashParams.optimalReadOpcode;
        readWidth = dObj->flashParams.optimalReadWidth;
        dummyCycles = dObj->flashParams.optimalReadDummyCycles;
    }

    sqiCmdBuffer[0] = readOpcode;

    /* 32-bit address support: Check if device requires 4-byte addressing or address exceeds 24-bit */
    if ((dObj->flashParams.addressBytes == 4U) || (address > 0xFFFFFFU))
    {
        addrBytes = 4U;
    }
    else
    {
        addrBytes = 3U;
    }

    if (addrBytes == 4U)
    {
        sqiCmdBuffer[1] = (uint8_t)((address >> 24) & 0xFFU);
        sqiCmdBuffer[2] = (uint8_t)((address >> 16) & 0xFFU);
        sqiCmdBuffer[3] = (uint8_t)((address >> 8) & 0xFFU);
        sqiCmdBuffer[4] = (uint8_t)(address & 0xFFU);
    }
    else
    {
        sqiCmdBuffer[1] = (uint8_t)((address >> 16) & 0xFFU);
        sqiCmdBuffer[2] = (uint8_t)((address >> 8) & 0xFFU);
        sqiCmdBuffer[3] = (uint8_t)(address & 0xFFU);
    }

    /* Command descriptor */
    sqiCmdDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1 + addrBytes) | readWidth |
                             SQI_CHIP_SELECT | SQI_BDCTRL_DESC_EN_Msk);
    ptr = &sqiCmdBuffer[0];
    sqiCmdDesc[0].bd_bufaddr = (uint32_t *)(ptr);
    sqiCmdDesc[0].bd_stat = 0;

    /* Add dummy cycles if needed */
    if (dummyCycles > 0U)
    {
        uint8_t dummyBytes;
        uint8_t j;

        if ((dObj->flashParams.supports_4_4_4) ||
            (dObj->flashParams.supports_1_4_4) ||
            (dObj->flashParams.supports_1_1_4))
        {
            dummyBytes = dummyCycles / 2U;
        }
        else
        {
            dummyBytes = dummyCycles / 8U;
        }

        for (j = 0; j < dummyBytes; j++)
        {
            sqiCmdBuffer[8 + j] = DUMMY_BYTE;
        }

        ptr = &sqiCmdDesc[1];
        sqiCmdDesc[0].bd_nxtptr = (sqi_dma_desc_t *)(ptr);

        sqiCmdDesc[1].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(dummyBytes) | readWidth |
                                 SQI_CHIP_SELECT | SQI_BDCTRL_DESC_EN_Msk);
        ptr = &sqiCmdBuffer[8];
        sqiCmdDesc[1].bd_bufaddr = (uint32_t *)(ptr);
        sqiCmdDesc[1].bd_stat = 0;
        ptr = &sqiBufDesc[0];
        sqiCmdDesc[1].bd_nxtptr = (sqi_dma_desc_t *)(ptr);
    }
    else
    {
        ptr = &sqiBufDesc[0];
        sqiCmdDesc[0].bd_nxtptr = (sqi_dma_desc_t *)(ptr);
    }

    /* Build data descriptor chain */
    i = 0U;
    while (i < DRV_SFDP_BUFF_DESC_NUMBER && pendingBytes > 0U)
    {
        if (pendingBytes >= dObj->flashParams.pageSize)
        {
            numBytes = dObj->flashParams.pageSize;
        }
        else
        {
            numBytes = pendingBytes;
        }

        sqiBufDesc[i].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(numBytes) | SQI_BDCTRL_PKT_INT_EN_Msk |
                                 readWidth | SQI_BDCTRL_DIR_Msk |
                                 SQI_CHIP_SELECT | SQI_BDCTRL_DESC_EN_Msk);

        sqiBufDesc[i].bd_bufaddr = (uint32_t *)(readBuffer);
        sqiBufDesc[i].bd_stat = 0;

        pendingBytes -= numBytes;
        readBuffer += numBytes;

        if (pendingBytes == 0U)
        {
            sqiBufDesc[i].bd_ctrl |= (SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk | SQI_BDCTRL_CS_ASSERT_Msk);
            sqiBufDesc[i].bd_nxtptr = NULL;
        }
        else
        {
            ptr = &sqiBufDesc[i + 1U];
            sqiBufDesc[i].bd_nxtptr = (sqi_dma_desc_t *)(ptr);
        }

        i++;
    }

    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_READ;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 16);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], 2 * (int32_t)sizeof(sqi_dma_desc_t));
    SYS_CACHE_CleanDCache_by_Addr(&sqiBufDesc[0], (int32_t)i * (int32_t)sizeof(sqi_dma_desc_t));
    SYS_CACHE_InvalidateDCache_by_Addr(rx_data, (int32_t)rx_data_length);
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    return true;
}

bool DRV_SFDP_PageWrite(const DRV_HANDLE handle, void *tx_data, uint32_t address)
{
    void *ptr = NULL;
    uint32_t pageSize = dObj->flashParams.pageSize;
    uint8_t addrBytes;

    if (DRV_SFDP_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    dObj->isTransferDone = false;

    DRV_SFDP_WriteEnable();

    /* Device-specific page program command */
    uint8_t writeOpcode;
    uint32_t writeWidth;

    if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_W25)
    {
        /* W25 Quad Input Page Program */
        writeOpcode = (uint8_t)SFDP_CMD_QUAD_INPUT_PAGE_PROGRAM;
        writeWidth = SQI_LANE_MODE_M;
    }
    else
    {
        /* Standard page program for other devices */
        writeOpcode = (uint8_t)SFDP_CMD_PAGE_PROGRAM;
        writeWidth = dObj->flashParams.optimalWriteWidth;
    }

    sqiCmdBuffer[4] = writeOpcode;

    /* 32-bit address support */
    if ((dObj->flashParams.addressBytes == 4U) || (address > 0xFFFFFFU))
    {
        addrBytes = 4U;
    }
    else
    {
        addrBytes = 3U;
    }

    if (addrBytes == 4U)
    {
        sqiCmdBuffer[5] = (uint8_t)((address >> 24) & 0xFFU);
        sqiCmdBuffer[6] = (uint8_t)((address >> 16) & 0xFFU);
        sqiCmdBuffer[7] = (uint8_t)((address >> 8) & 0xFFU);
        sqiCmdBuffer[8] = (uint8_t)(address & 0xFFU);
    }
    else
    {
        sqiCmdBuffer[5] = (uint8_t)((address >> 16) & 0xFFU);
        sqiCmdBuffer[6] = (uint8_t)((address >> 8) & 0xFFU);
        sqiCmdBuffer[7] = (uint8_t)(address & 0xFFU);
    }

    sqiCmdDesc[1].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(1 + addrBytes) | writeWidth |
                             SQI_CHIP_SELECT | SQI_BDCTRL_DESC_EN_Msk);
    ptr = &sqiCmdBuffer[4];
    sqiCmdDesc[1].bd_bufaddr = (uint32_t *)(ptr);
    sqiCmdDesc[1].bd_stat = 0;
    ptr = &sqiBufDesc[0];
    sqiCmdDesc[1].bd_nxtptr = (sqi_dma_desc_t *)(ptr);

    /* Data descriptor */
    sqiBufDesc[0].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(pageSize) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             writeWidth | SQI_BDCTRL_STAT_CHECK_Msk |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);

    sqiBufDesc[0].bd_bufaddr = (uint32_t *)(tx_data);
    sqiBufDesc[0].bd_stat = 0;
    sqiBufDesc[0].bd_nxtptr = NULL;

    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_WRITE;

    dObj->internal_write_complete_flag = false;
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 9);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], 2 * (int32_t)sizeof(sqi_dma_desc_t));
    SYS_CACHE_CleanDCache_by_Addr(&sqiBufDesc[0], (int32_t)sizeof(sqi_dma_desc_t));
    SYS_CACHE_CleanDCache_by_Addr(tx_data, (int32_t)pageSize);
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    return true;
}

static bool DRV_SFDP_Erase(uint8_t instruction, uint32_t address)
{
    void *ptr = NULL;
    uint8_t addrBytes = dObj->flashParams.addressBytes;
    uint32_t bufLen = 1U + addrBytes;

    dObj->isTransferDone = false;

    DRV_SFDP_WriteEnable();

    sqiCmdBuffer[4] = instruction;

    if (addrBytes == 4U)
    {
        sqiCmdBuffer[5] = (uint8_t)((address >> 24) & 0xFFU);
        sqiCmdBuffer[6] = (uint8_t)((address >> 16) & 0xFFU);
        sqiCmdBuffer[7] = (uint8_t)((address >> 8) & 0xFFU);
        sqiCmdBuffer[8] = (uint8_t)(address & 0xFFU);
    }
    else
    {
        sqiCmdBuffer[5] = (uint8_t)((address >> 16) & 0xFFU);
        sqiCmdBuffer[6] = (uint8_t)((address >> 8) & 0xFFU);
        sqiCmdBuffer[7] = (uint8_t)(address & 0xFFU);
    }

    sqiCmdDesc[1].bd_ctrl = (SQI_BDCTRL_BD_BUFLEN(bufLen) | SQI_BDCTRL_PKT_INT_EN_Msk |
                             SQI_BDCTRL_LIFM_Msk | SQI_BDCTRL_LAST_BD_Msk |
                             dObj->flashParams.optimalWriteWidth | SQI_BDCTRL_STAT_CHECK_Msk |
                             SQI_CHIP_SELECT | SQI_BDCTRL_CS_ASSERT_Msk |
                             SQI_BDCTRL_DESC_EN_Msk);

    ptr = &sqiCmdBuffer[4];
    sqiCmdDesc[1].bd_bufaddr = (uint32_t *)(ptr);
    sqiCmdDesc[1].bd_stat = 0;
    sqiCmdDesc[1].bd_nxtptr = NULL;

    dObj->curOpType = DRV_SFDP_OPERATION_TYPE_ERASE;

    dObj->internal_write_complete_flag = false;
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdBuffer[0], 9);
    SYS_CACHE_CleanDCache_by_Addr(&sqiCmdDesc[0], 2 * (int32_t)sizeof(sqi_dma_desc_t));
</#if>

    dObj->sfdpPlib->DMATransfer((sqi_dma_desc_t *)(&sqiCmdDesc[0]));

    return true;
}

bool DRV_SFDP_SectorErase(const DRV_HANDLE handle, uint32_t address)
{
    if (DRV_SFDP_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    return (DRV_SFDP_Erase(dObj->flashParams.eraseOpcode4K, address));
}

bool DRV_SFDP_BulkErase(const DRV_HANDLE handle, uint32_t address)
{
    if (DRV_SFDP_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    return (DRV_SFDP_Erase(dObj->flashParams.eraseOpcode64K, address));
}

bool DRV_SFDP_ChipErase(const DRV_HANDLE handle)
{
    if (DRV_SFDP_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    return (DRV_SFDP_Erase((uint8_t)SFDP_CMD_CHIP_ERASE, 0));
}

bool DRV_SFDP_GeometryGet(const DRV_HANDLE handle, DRV_SFDP_GEOMETRY *geometry)
{
    uint32_t flash_size = 0;
    bool status = true;

    if ((handle == DRV_HANDLE_INVALID) || (geometry == NULL))
    {
        return false;
    }

    if (!dObj->sfdpDiscovered)
    {
        return false;
    }

    flash_size = dObj->flashParams.flashSize;

    if (flash_size == 0U)
    {
        status = false;
    }

    if (DRV_SFDP_START_ADDRESS >= flash_size)
    {
        status = false;
    }
    else
    {
        flash_size = flash_size - DRV_SFDP_START_ADDRESS;

        if (flash_size < dObj->flashParams.sectorSize)
        {
            status = false;
        }
        else
        {
            geometry->read_blockSize = 1;
            geometry->read_numBlocks = flash_size;

            geometry->write_blockSize = dObj->flashParams.pageSize;
            geometry->write_numBlocks = (flash_size / dObj->flashParams.pageSize);

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

DRV_HANDLE DRV_SFDP_Open(const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent)
{
    if ((dObj->status != SYS_STATUS_READY) ||
        (dObj->nClients >= DRV_SFDP_CLIENTS_NUMBER))
    {
        return DRV_HANDLE_INVALID;
    }

<#if LANE_MODE == "QUAD">
    DRV_SFDP_DisableQuadIO();
</#if>
    /* Reset SFDP Flash device */
    DRV_SFDP_ResetFlash();

    /* Discover flash parameters using SFDP */
    if (DRV_SFDP_DiscoverFlashParams() == false)
    {
        return DRV_HANDLE_INVALID;
    }

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
            dObj->flashParams.optimalReadWidth = SQI_LANE_MODE_M;
            dObj->flashParams.optimalReadDummyCycles = 10;
        }
        else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_W25)
        {
            /* W25 specific: Use 1-4-4 mode (Quad I/O) */
            dObj->flashParams.supports_1_4_4 = true;
            dObj->flashParams.optimalReadWidth = SQI_LANE_MODE_M;
            dObj->flashParams.optimalReadOpcode = 0xEB;
            dObj->flashParams.optimalReadDummyCycles = 6;
        }
        else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_MX25L)
        {
            /* MX25L/MX66 specific: Use 4-4-4 mode (Quad Command) */
            dObj->flashParams.supports_4_4_4 = true;
            dObj->flashParams.optimalReadWidth = SQI_LANE_MODE_M;
            dObj->flashParams.optimalReadOpcode = 0xEB;
            dObj->flashParams.optimalReadDummyCycles = 6;
        }
        else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_S25FL)
        {
            /* S25FL specific: Use SFDP-discovered quad mode with QE bit enabled */
            /* Parameters are already discovered from SFDP, just ensure quad modes are enabled */
            if (dObj->flashParams.supports_1_4_4)
            {
                dObj->flashParams.optimalReadWidth = SQI_LANE_MODE_M;
            }
            else if (dObj->flashParams.supports_1_1_4)
            {
                dObj->flashParams.optimalReadWidth = SQI_LANE_MODE_M;
            }
        }
        else if (dObj->flashParams.deviceType == SFDP_DEVICE_TYPE_IS25)
        {
            /* IS25 specific: Use SFDP-discovered quad mode with QE bit enabled */
            /* Parameters are already discovered from SFDP, just ensure quad modes are enabled */
            if (dObj->flashParams.supports_1_4_4)
            {
                dObj->flashParams.optimalReadWidth = SQI_LANE_MODE_M;
            }
            else if (dObj->flashParams.supports_1_1_4)
            {
                dObj->flashParams.optimalReadWidth = SQI_LANE_MODE_M;
            }
        }
        else
        {
            /* For SST26 and generic devices, use SFDP-discovered parameters */
        }
    }

<#if LANE_MODE == "QUAD">
    /* Enable QUAD IO Mode using device-specific method */
    if (dObj->flashParams.supports_4_4_4 || dObj->flashParams.supports_1_4_4)
    {
        if (DRV_SFDP_EnableQuadIO_DeviceSpecific() == false)
        {
            /* Continue even if quad enable fails - fall back to single SPI */
            dObj->flashParams.optimalReadWidth = SQI_LANE_MODE_SINGLE;
            dObj->flashParams.optimalWriteWidth = SQI_LANE_MODE_SINGLE;
        }
    }
</#if>

    if (((uint32_t)ioIntent & (uint32_t)DRV_IO_INTENT_WRITE) == ((uint32_t)DRV_IO_INTENT_WRITE))
    {
        (void)DRV_SFDP_UnlockFlash((DRV_HANDLE)drvIndex);
    }

    dObj->nClients++;

    dObj->ioIntent = ioIntent;

    return ((DRV_HANDLE)drvIndex);
}

void DRV_SFDP_Close(const DRV_HANDLE handle)
{
    if ((handle != DRV_HANDLE_INVALID) &&
        (dObj->nClients > 0U))
    {
        dObj->nClients--;
    }
}
/* MISRA C-2023 Rule 11.8 deviated:1 Deviation record ID -  H3_MISRAC_2023_R_11_8_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:1 "MISRA C-2023 Rule 11.8" "H3_MISRAC_2023_R_11_8_DR_1"
</#if>

SYS_MODULE_OBJ DRV_SFDP_Initialize
(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT *const init
)
{
    DRV_SFDP_INIT *sfdpInit = NULL;

    if (dObj->inUse == true)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    dObj->status = SYS_STATUS_UNINITIALIZED;

    dObj->inUse = true;
    dObj->nClients = 0;
    dObj->sfdpDiscovered = false;
    dObj->isTransferDone = true;
    dObj->internal_write_complete_flag = false;

    (void)memset((void *)&dObj->flashParams, 0, sizeof(DRV_SFDP_FLASH_PARAMS));

    sfdpInit = (DRV_SFDP_INIT *)init;

    dObj->sfdpPlib = sfdpInit->sfdpPlib;

    /* Register callback */
    dObj->sfdpPlib->RegisterCallback(DRV_SFDP_EventHandler, (uintptr_t)dObj);

    dObj->status = SYS_STATUS_READY;

    return ((SYS_MODULE_OBJ)drvIndex);
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2023 Rule 11.3"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2023 deviation block end */

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2023 Rule 11.8"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2023 deviation block end */

SYS_STATUS DRV_SFDP_Status(const SYS_MODULE_INDEX drvIndex)
{
    return (gDrvSFDPObj.status);
}
