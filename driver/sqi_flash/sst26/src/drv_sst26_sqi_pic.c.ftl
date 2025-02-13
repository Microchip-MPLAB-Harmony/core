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
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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
#include "sys/kmem.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

<#if CHIP_SELECT == "Chip Select 0">
    <#lt>#define SQI_CHIP_SELECT         SQI_BDCTRL_SQICS_CS0
<#elseif CHIP_SELECT == "Chip Select 1">
    <#lt>#define SQI_CHIP_SELECT         SQI_BDCTRL_SQICS_CS1
</#if>

#define DRV_SQI_LANE_MODE       SQI_BDCTRL_MODE_${LANE_MODE}_LANE

#define CMD_DESC_NUMBER         5
#define DUMMY_BYTE              0xFF

static DRV_SST26_OBJECT gDrvSST26Obj;
static DRV_SST26_OBJECT *dObj = &gDrvSST26Obj;

/* Table mapping the Flash ID's to their sizes. */
static uint32_t gSstFlashIdSizeTable [9][2] = {
    {0x12, 0x40000},  /* 2 MBit */
    {0x54, 0x80000},  /* 4 MBit */
    {0x18, 0x100000}, /* 8 MBit */
    {0x58, 0x100000}, /* 8 MBit */
    {0x01, 0x200000}, /* 16 MBit */
    {0x41, 0x200000}, /* 16 MBit */
    {0x02, 0x400000}, /* 32 MBit */
    {0x42, 0x400000}, /* 32 MBit */
    {0x43, 0x800000}  /* 64 MBit */
};

static sqi_dma_desc_t CACHE_ALIGN sqiCmdDesc[CMD_DESC_NUMBER];
static sqi_dma_desc_t CACHE_ALIGN sqiBufDesc[DRV_SST26_BUFF_DESC_NUMBER];

static uint8_t CACHE_ALIGN statusRegVal;

static uint8_t CACHE_ALIGN jedecID[4];

static uint8_t CACHE_ALIGN sqi_cmd_jedec[2];
<#if LANE_MODE == "QUAD" >
static uint8_t CACHE_ALIGN sqi_cmd_eqio;
</#if>
static uint8_t CACHE_ALIGN sqi_cmd_rsten;
static uint8_t CACHE_ALIGN sqi_cmd_rst;
static uint8_t CACHE_ALIGN sqi_cmd_wren;
static uint8_t CACHE_ALIGN sqi_cmd_rdsr[2];
static uint8_t CACHE_ALIGN sqi_cmd_wrsr[2];
static uint8_t CACHE_ALIGN sqi_cmd_ce;
static uint8_t CACHE_ALIGN sqi_cmd_se[4];
static uint8_t CACHE_ALIGN sqi_cmd_be[4];
static uint8_t CACHE_ALIGN sqi_cmd_pp[4];
static uint8_t CACHE_ALIGN sqi_cmd_hsr[7];
static uint8_t CACHE_ALIGN sqi_cmd_ULBPR;
<#if LANE_MODE == "QUAD" >
static uint8_t CACHE_ALIGN sqi_cmd_dummy[6];
</#if>


// *****************************************************************************
// *****************************************************************************
// Section: SST26 Driver Local Functions
// *****************************************************************************
// *****************************************************************************

static void DRV_SST26_EventHandler(uintptr_t context)
{
    DRV_SST26_OBJECT *obj = (DRV_SST26_OBJECT *)context;

    obj->isTransferDone = true;
}

/* This function returns the flash size in bytes for the specified deviceId. A
 * zero is returned if the device id is not supported. */
static uint32_t DRV_SST26_GetFlashSize( uint8_t deviceId )
{
    uint8_t i = 0;

    for (i = 0; i < 9; i++)
    {
        if (deviceId == gSstFlashIdSizeTable[i][0])
        {
            return gSstFlashIdSizeTable[i][1];
        }
    }

    return 0;
}

static void DRV_SST26_ResetFlash(void)
{
    dObj->isTransferDone = false;

    dObj->curOpType = DRV_SST26_OPERATION_TYPE_CMD;

    sqi_cmd_rsten               = (uint8_t)SST26_CMD_FLASH_RESET_ENABLE;

    sqiCmdDesc[0].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(1) | SQI_BDCTRL_PKTINTEN |
                                    SQI_BDCTRL_LASTPKT | SQI_BDCTRL_LASTBD |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DEASSERT |
                                    SQI_BDCTRL_DESCEN);

    sqiCmdDesc[0].bd_bufaddr    = (uint32_t *)KVA_TO_PA(&sqi_cmd_rsten);
    sqiCmdDesc[0].bd_stat       = 0;
    sqiCmdDesc[0].bd_nxtptr     = NULL;

    dObj->sst26Plib->DMATransfer((sqi_dma_desc_t *)KVA_TO_PA(&sqiCmdDesc[0]));

    while(dObj->isTransferDone == false)
    {
        /* Wait for transfer to complete */
    }

    dObj->isTransferDone = false;

    sqi_cmd_rst                 = (uint8_t)SST26_CMD_FLASH_RESET;

    sqiCmdDesc[1].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(1) | SQI_BDCTRL_PKTINTEN |
                                    SQI_BDCTRL_LASTPKT | SQI_BDCTRL_LASTBD |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DEASSERT |
                                    SQI_BDCTRL_DESCEN);

    sqiCmdDesc[1].bd_bufaddr    = (uint32_t *)KVA_TO_PA(&sqi_cmd_rst);
    sqiCmdDesc[1].bd_stat       = 0;
    sqiCmdDesc[1].bd_nxtptr     = NULL;

    dObj->sst26Plib->DMATransfer((sqi_dma_desc_t *)KVA_TO_PA(&sqiCmdDesc[1]));

    while(dObj->isTransferDone == false)
    {
        /* Wait for transfer to complete */
    }
}

<#if LANE_MODE == "QUAD" >
    <#lt>static void DRV_SST26_EnableQuadIO(void)
    <#lt>{
    <#lt>    dObj->isTransferDone = false;

    <#lt>    sqi_cmd_eqio                = (uint8_t)SST26_CMD_ENABLE_QUAD_IO;

    <#lt>    sqiCmdDesc[0].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(1) | SQI_BDCTRL_PKTINTEN |
    <#lt>                                    SQI_BDCTRL_LASTPKT | SQI_BDCTRL_LASTBD |
    <#lt>                                    SQI_CHIP_SELECT | SQI_BDCTRL_DEASSERT |
    <#lt>                                    SQI_BDCTRL_DESCEN);

    <#lt>    sqiCmdDesc[0].bd_bufaddr    = (uint32_t *)KVA_TO_PA(&sqi_cmd_eqio);
    <#lt>    sqiCmdDesc[0].bd_stat       = 0;
    <#lt>    sqiCmdDesc[0].bd_nxtptr     = NULL;

    <#lt>    dObj->curOpType = DRV_SST26_OPERATION_TYPE_CMD;

    <#lt>    dObj->sst26Plib->DMATransfer((sqi_dma_desc_t *)KVA_TO_PA(&sqiCmdDesc[0]));

    <#lt>    while(dObj->isTransferDone == false)
    <#lt>    {
    <#lt>        /* Wait for transfer to finish */
    <#lt>    }
    <#lt>}
</#if>

static void DRV_SST26_WriteEnable(void)
{
    sqi_cmd_wren                = (uint8_t)SST26_CMD_WRITE_ENABLE;

    sqiCmdDesc[0].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(1) | DRV_SQI_LANE_MODE |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DEASSERT |
                                    SQI_BDCTRL_DESCEN);

    sqiCmdDesc[0].bd_bufaddr    = (uint32_t *)KVA_TO_PA(&sqi_cmd_wren);
    sqiCmdDesc[0].bd_stat       = 0;
    sqiCmdDesc[0].bd_nxtptr     = (sqi_dma_desc_t *)KVA_TO_PA(&sqiCmdDesc[1]);
}

static bool DRV_SST26_ValidateHandleAndCheckBusy( const DRV_HANDLE handle )
{
    /* Validate the handle.
     * If isTransferDone is False then there is an operation in progress.
     */
    if(handle == DRV_HANDLE_INVALID || dObj->isTransferDone == false)
    {
        return true;
    }

    return false;
}
// *****************************************************************************
// *****************************************************************************
// Section: SST26 Driver Global Functions
// *****************************************************************************
// *****************************************************************************

bool DRV_SST26_UnlockFlash( const DRV_HANDLE handle )
{
    bool status = true;
    bool blockWriteProtection = false;
    uint8_t bdctrlBufLen = 0U;

    if(DRV_SST26_ValidateHandleAndCheckBusy(handle) == true)
    {
        status = false;
    }
    else
    {
        if (DRV_SST26_ReadJedecId(handle, (void *)&jedecID) == false)
        {
            status = false;
        }
        else
        {
            /* Unblock block write protection using write status register command */
            if (jedecID[2] == 0x12U || jedecID[2] == 0x18U)
            {
                blockWriteProtection = true;
            }
            else
            {
                blockWriteProtection = false;
            }

            dObj->isTransferDone = false;

            DRV_SST26_WriteEnable();

            if (blockWriteProtection == true)
            {
                sqi_cmd_wrsr[0]             = (uint8_t)SST26_CMD_WRITE_STATUS_REG;
                sqi_cmd_wrsr[1]             = 0U;
                bdctrlBufLen                = 2U;
                sqiCmdDesc[1].bd_bufaddr    = (uint32_t *)KVA_TO_PA(&sqi_cmd_wrsr[0]);
            }
            else
            {
                sqi_cmd_ULBPR               = (uint8_t)SST26_CMD_UNPROTECT_GLOBAL;
                bdctrlBufLen                = 1U;
                sqiCmdDesc[1].bd_bufaddr    = (uint32_t *)KVA_TO_PA(&sqi_cmd_ULBPR);
            }

            sqiCmdDesc[1].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(bdctrlBufLen) | SQI_BDCTRL_PKTINTEN |
                                            SQI_BDCTRL_LASTPKT | SQI_BDCTRL_LASTBD |
                                            DRV_SQI_LANE_MODE | SQI_CHIP_SELECT |
                                            SQI_BDCTRL_DEASSERT | SQI_BDCTRL_DESCEN);

            sqiCmdDesc[1].bd_stat       = 0;
            sqiCmdDesc[1].bd_nxtptr     = NULL;

            dObj->curOpType = DRV_SST26_OPERATION_TYPE_CMD;

            dObj->sst26Plib->DMATransfer((sqi_dma_desc_t *)KVA_TO_PA(&sqiCmdDesc[0]));

            while(dObj->isTransferDone == false)
            {
                /* Wait for  transfer to complete */
            }
        }
    }

    return status;
}

bool DRV_SST26_ReadJedecId( const DRV_HANDLE handle, void *jedec_id)
{
    if(DRV_SST26_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    dObj->isTransferDone = false;

<#if LANE_MODE == "QUAD" >
    sqi_cmd_jedec[0]            = (uint8_t)SST26_CMD_QUAD_JEDEC_ID_READ;
    sqi_cmd_jedec[1]            = DUMMY_BYTE;

    sqiCmdDesc[0].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(2) | DRV_SQI_LANE_MODE |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DESCEN);
<#else>
    sqi_cmd_jedec[0]            = SST26_CMD_JEDEC_ID_READ;

    sqiCmdDesc[0].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(1) | DRV_SQI_LANE_MODE |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DESCEN);
</#if>

    sqiCmdDesc[0].bd_bufaddr    = (uint32_t *)KVA_TO_PA(&sqi_cmd_jedec);
    sqiCmdDesc[0].bd_stat       = 0;
    sqiCmdDesc[0].bd_nxtptr     = (sqi_dma_desc_t *)KVA_TO_PA(&sqiBufDesc[0]);

    sqiBufDesc[0].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(4) | SQI_BDCTRL_PKTINTEN |
                                    SQI_BDCTRL_LASTPKT | SQI_BDCTRL_LASTBD |
                                    DRV_SQI_LANE_MODE | SQI_BDCTRL_DIR_READ |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DEASSERT |
                                    SQI_BDCTRL_DESCEN);

    sqiBufDesc[0].bd_bufaddr    = (uint32_t *)KVA_TO_PA((uint8_t*)jedec_id);
    sqiBufDesc[0].bd_stat       = 0;
    sqiBufDesc[0].bd_nxtptr     = NULL;

    dObj->curOpType = DRV_SST26_OPERATION_TYPE_READ;

    // Initialize the root buffer descriptor
    dObj->sst26Plib->DMATransfer((sqi_dma_desc_t *)KVA_TO_PA(&sqiCmdDesc[0]));

    while(dObj->isTransferDone == false)
    {
        /* Wait for transfer to complete */
    }

    return true;
}

bool DRV_SST26_ReadStatus( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length )
{
    uint8_t *status = (uint8_t *)rx_data;

    if(DRV_SST26_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    dObj->isTransferDone = false;

    sqi_cmd_rdsr[0]             = (uint8_t)SST26_CMD_READ_STATUS_REG;

<#if LANE_MODE == "QUAD" >
    sqi_cmd_rdsr[1]             = DUMMY_BYTE;

    sqiCmdDesc[0].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(2) | DRV_SQI_LANE_MODE |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DESCEN);
<#else>
    sqiCmdDesc[0].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(1) | DRV_SQI_LANE_MODE |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DESCEN);
</#if>

    sqiCmdDesc[0].bd_bufaddr    = (uint32_t *)KVA_TO_PA(&sqi_cmd_rdsr);
    sqiCmdDesc[0].bd_stat       = 0;
    sqiCmdDesc[0].bd_nxtptr     = (sqi_dma_desc_t *)KVA_TO_PA(&sqiBufDesc[0]);

    sqiBufDesc[0].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(rx_data_length) | SQI_BDCTRL_PKTINTEN |
                                    SQI_BDCTRL_LASTPKT | SQI_BDCTRL_LASTBD |
                                    DRV_SQI_LANE_MODE | SQI_BDCTRL_DIR_READ |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DEASSERT |
                                    SQI_BDCTRL_DESCEN);

    sqiBufDesc[0].bd_bufaddr    = (uint32_t *)KVA_TO_PA(&statusRegVal);
    sqiBufDesc[0].bd_stat       = 0;
    sqiBufDesc[0].bd_nxtptr     = NULL;

    dObj->curOpType = DRV_SST26_OPERATION_TYPE_READ;

    // Initialize the root buffer descriptor
    dObj->sst26Plib->DMATransfer((sqi_dma_desc_t *)KVA_TO_PA(&sqiCmdDesc[0]));

    while(dObj->isTransferDone == false)
    {
        /* Wait for transfer to complete */
    }

    *status = statusRegVal;

    return true;
}

DRV_SST26_TRANSFER_STATUS DRV_SST26_TransferStatusGet( const DRV_HANDLE handle )
{
    DRV_SST26_TRANSFER_STATUS status = DRV_SST26_TRANSFER_ERROR_UNKNOWN;

    if(handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    if (dObj->isTransferDone == true)
    {
        status = DRV_SST26_TRANSFER_COMPLETED;
    }
    else
    {
        status = DRV_SST26_TRANSFER_BUSY;
    }

    return status;
}

bool DRV_SST26_Read( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address )
{
    uint32_t pendingBytes   = rx_data_length;
    uint8_t *readBuffer     = (uint8_t *)rx_data;
    uint32_t numBytes       = 0;
    uint32_t i              = 0;

    if(DRV_SST26_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    if ((rx_data_length == 0U) || (rx_data_length > (DRV_SST26_PAGE_SIZE * DRV_SST26_BUFF_DESC_NUMBER)))
    {
        return false;
    }

    dObj->isTransferDone = false;

    // Construct parameters to issue read command
    sqi_cmd_hsr[0] = (uint8_t)SST26_CMD_HIGH_SPEED_READ;
    sqi_cmd_hsr[1] = (uint8_t)(0xFFU & (address >> 16));
    sqi_cmd_hsr[2] = (uint8_t)(0xFFU & (address >> 8));
    sqi_cmd_hsr[3] = (uint8_t)(0xFFU & (address >> 0));
    sqi_cmd_hsr[4] = DUMMY_BYTE;

    sqiCmdDesc[0].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(5) | DRV_SQI_LANE_MODE |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DESCEN);

    sqiCmdDesc[0].bd_bufaddr    = (uint32_t *)KVA_TO_PA(&sqi_cmd_hsr);
    sqiCmdDesc[0].bd_stat       = 0;
<#if LANE_MODE == "QUAD" >
    sqiCmdDesc[0].bd_nxtptr     = (sqi_dma_desc_t *)KVA_TO_PA(&sqiCmdDesc[1]);

    sqi_cmd_dummy[0]            = DUMMY_BYTE;
    sqi_cmd_dummy[1]            = DUMMY_BYTE;

    sqiCmdDesc[1].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(2) | DRV_SQI_LANE_MODE |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DESCEN);

    sqiCmdDesc[1].bd_bufaddr    = (uint32_t *)KVA_TO_PA(&sqi_cmd_dummy);
    sqiCmdDesc[1].bd_stat       = 0;
    sqiCmdDesc[1].bd_nxtptr     = (sqi_dma_desc_t *)KVA_TO_PA(&sqiBufDesc[0]);
<#else>
    sqiCmdDesc[0].bd_nxtptr     = (sqi_dma_desc_t *)KVA_TO_PA(&sqiBufDesc[0]);
</#if>

    while (i < DRV_SST26_BUFF_DESC_NUMBER)
    {
        if (pendingBytes >= DRV_SST26_PAGE_SIZE)
        {
            numBytes = DRV_SST26_PAGE_SIZE;
        }
        else
        {
            numBytes = pendingBytes;
        }

        sqiBufDesc[i].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(numBytes) | SQI_BDCTRL_PKTINTEN |
                                        DRV_SQI_LANE_MODE | SQI_BDCTRL_DIR_READ |
                                        SQI_CHIP_SELECT | SQI_BDCTRL_DESCEN);

        sqiBufDesc[i].bd_bufaddr    = (uint32_t *)KVA_TO_PA(readBuffer);
        sqiBufDesc[i].bd_stat       = 0;
        sqiBufDesc[i].bd_nxtptr     = (sqi_dma_desc_t *)KVA_TO_PA(&sqiBufDesc[i+1]);

        pendingBytes    -= numBytes;
        readBuffer      += numBytes;
        i++;
        if (pendingBytes == 0U)
        {
            break;
        }
    }

    /* The last descriptor must indicate the end of the descriptor list */
    sqiBufDesc[i-1].bd_ctrl         |= (SQI_BDCTRL_LASTPKT | SQI_BDCTRL_LASTBD |
                                        SQI_BDCTRL_DEASSERT);

    sqiBufDesc[i-1].bd_nxtptr       = NULL;

    dObj->curOpType = DRV_SST26_OPERATION_TYPE_READ;

    // Initialize the root buffer descriptor
    dObj->sst26Plib->DMATransfer((sqi_dma_desc_t *)KVA_TO_PA(&sqiCmdDesc[0]));

    return true;
}

bool DRV_SST26_PageWrite( const DRV_HANDLE handle, void *tx_data, uint32_t address )
{
    if(DRV_SST26_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    dObj->isTransferDone = false;

    DRV_SST26_WriteEnable();

    // Construct parameters to issue page program command
    sqi_cmd_pp[0] = (uint8_t)SST26_CMD_PAGE_PROGRAM;
    sqi_cmd_pp[1] = (uint8_t)(0xFFU & (address >> 16));
    sqi_cmd_pp[2] = (uint8_t)(0xFFU & (address >> 8));
    sqi_cmd_pp[3] = (uint8_t)(0xFFU & (address >> 0));

    sqiCmdDesc[1].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(4) | DRV_SQI_LANE_MODE |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DESCEN);

    sqiCmdDesc[1].bd_bufaddr    = (uint32_t *)KVA_TO_PA(&sqi_cmd_pp);
    sqiCmdDesc[1].bd_stat       = 0;
    sqiCmdDesc[1].bd_nxtptr     = (sqi_dma_desc_t *)KVA_TO_PA(&sqiBufDesc[0]);

    sqiBufDesc[0].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(DRV_SST26_PAGE_SIZE) | SQI_BDCTRL_PKTINTEN |
                                    SQI_BDCTRL_LASTPKT | SQI_BDCTRL_LASTBD |
                                    DRV_SQI_LANE_MODE | SQI_BDCTRL_SCHECK |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DEASSERT |
                                    SQI_BDCTRL_DESCEN);

    sqiBufDesc[0].bd_bufaddr    = (uint32_t *)KVA_TO_PA((uint8_t*)tx_data);
    sqiBufDesc[0].bd_stat       = 0;
    sqiBufDesc[0].bd_nxtptr     = NULL;

    dObj->curOpType = DRV_SST26_OPERATION_TYPE_WRITE;

    // Initialize the root buffer descriptor
    dObj->sst26Plib->DMATransfer((sqi_dma_desc_t *)KVA_TO_PA(&sqiCmdDesc[0]));

    return true;
}

static bool DRV_SST26_Erase( uint8_t *instruction, uint32_t length )
{
    dObj->isTransferDone = false;

    DRV_SST26_WriteEnable();

    sqiCmdDesc[1].bd_ctrl       = ( SQI_BDCTRL_BUFFLEN_VAL(length) | SQI_BDCTRL_PKTINTEN |
                                    SQI_BDCTRL_LASTPKT | SQI_BDCTRL_LASTBD |
                                    DRV_SQI_LANE_MODE | SQI_BDCTRL_SCHECK |
                                    SQI_CHIP_SELECT | SQI_BDCTRL_DEASSERT |
                                    SQI_BDCTRL_DESCEN);

    sqiCmdDesc[1].bd_bufaddr    = (uint32_t *)KVA_TO_PA(instruction);
    sqiCmdDesc[1].bd_stat       = 0;
    sqiCmdDesc[1].bd_nxtptr     = NULL;

    dObj->curOpType = DRV_SST26_OPERATION_TYPE_ERASE;

    dObj->sst26Plib->DMATransfer((sqi_dma_desc_t *)KVA_TO_PA(&sqiCmdDesc[0]));

    return true;
}

bool DRV_SST26_SectorErase( const DRV_HANDLE handle, uint32_t address )
{
    if(DRV_SST26_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    sqi_cmd_se[0] = (uint8_t)SST26_CMD_SECTOR_ERASE;
    sqi_cmd_se[1] = (uint8_t)(0xFFU & (address >> 16));
    sqi_cmd_se[2] = (uint8_t)(0xFFU & (address >> 8));
    sqi_cmd_se[3] = (uint8_t)(0xFFU & (address >> 0));

    return (DRV_SST26_Erase(&sqi_cmd_se[0], 4));
}

bool DRV_SST26_BulkErase( const DRV_HANDLE handle, uint32_t address )
{
    if(DRV_SST26_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    sqi_cmd_be[0] = (uint8_t)SST26_CMD_BULK_ERASE_64K;
    sqi_cmd_be[1] = (uint8_t)(0xFFU & (address >> 16));
    sqi_cmd_be[2] = (uint8_t)(0xFFU & (address >> 8));
    sqi_cmd_be[3] = (uint8_t)(0xFFU & (address >> 0));

    return (DRV_SST26_Erase(&sqi_cmd_be[0], 4));
}

bool DRV_SST26_ChipErase( const DRV_HANDLE handle )
{
    if(DRV_SST26_ValidateHandleAndCheckBusy(handle) == true)
    {
        return false;
    }

    sqi_cmd_ce = (uint8_t)SST26_CMD_CHIP_ERASE;

    return (DRV_SST26_Erase(&sqi_cmd_ce, 1));
}

bool DRV_SST26_GeometryGet( const DRV_HANDLE handle, DRV_SST26_GEOMETRY *geometry )
{
    uint32_t flash_size = 0;
    bool status = true;

    if (DRV_SST26_ReadJedecId(handle, (void *)&jedecID) == false)
    {
        status = false;
    }
    else
    {
        flash_size = DRV_SST26_GetFlashSize(jedecID[2]);

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
                geometry->read_blockSize    = 1;
                geometry->read_numBlocks    = flash_size;

                /* Write block size and number of blocks */
                geometry->write_blockSize   = DRV_SST26_PAGE_SIZE;
                geometry->write_numBlocks   = (flash_size / DRV_SST26_PAGE_SIZE);

                /* Erase block size and number of blocks */
                geometry->erase_blockSize   = DRV_SST26_ERASE_BUFFER_SIZE;
                geometry->erase_numBlocks   = (flash_size / DRV_SST26_ERASE_BUFFER_SIZE);

                geometry->numReadRegions    = 1;
                geometry->numWriteRegions   = 1;
                geometry->numEraseRegions   = 1;

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

    /* Reset SST26 Flash device */
    DRV_SST26_ResetFlash();

<#if LANE_MODE == "QUAD" >
    /* Put SST26 Flash device on QUAD IO Mode */
    DRV_SST26_EnableQuadIO();
</#if>

    if ((ioIntent & DRV_IO_INTENT_WRITE) == (DRV_IO_INTENT_WRITE))
    {
        /* Unlock the Flash */
        if (DRV_SST26_UnlockFlash((DRV_HANDLE)drvIndex) == false)
        {
            return DRV_HANDLE_INVALID;
        }
    }

    dObj->nClients++;

    dObj->ioIntent = ioIntent;

    return ((DRV_HANDLE)drvIndex);
}

void DRV_SST26_Close( const DRV_HANDLE handle )
{
    if ( (handle != DRV_HANDLE_INVALID) &&
         (dObj->nClients > 0))
    {
        dObj->nClients--;
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

    /* Initialize the attached memory device functions */
    dObj->sst26Plib = sst26Init->sst26Plib;

    dObj->sst26Plib->RegisterCallback(DRV_SST26_EventHandler, (uintptr_t)dObj);

    dObj->isTransferDone    = true;
    dObj->status            = SYS_STATUS_READY;

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
