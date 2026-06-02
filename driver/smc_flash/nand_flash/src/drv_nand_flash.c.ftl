/******************************************************************************
  NAND FLASH Driver Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_nand_flash.c

  Summary:
    NAND FLASH Driver Interface Definition

  Description:
    The NAND FLASH Driver provides a interface to access the NAND FLASH peripheral on the SAM
    Devices. This file should be included in the project if NAND FLASH driver
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

#include "driver/smc_flash/nand_flash/src/drv_nand_flash_local.h"
<#if DRV_NAND_FLASH_PMECC_ENABLE == true>
#include "driver/smc_flash/nand_flash/src/drv_nand_flash_pmecc.h"
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
static DRV_NAND_FLASH_OBJECT gDrvNandFlashObj = { .txrxDMAChannel = DRV_NAND_FLASH_TX_RX_DMA_CH_IDX };
<#else>
static DRV_NAND_FLASH_OBJECT gDrvNandFlashObj;
</#if>
static DRV_NAND_FLASH_DATA gDrvNandFlashData;

// *****************************************************************************
// *****************************************************************************
// Section: NAND FLASH Driver Local Functions
// *****************************************************************************
// *****************************************************************************

<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
static void DRV_NAND_FLASH_DMA_CallbackHandler(SYS_DMA_TRANSFER_EVENT event, uintptr_t context)
{
    if (event == SYS_DMA_TRANSFER_COMPLETE)
    {
        gDrvNandFlashObj.transferStatus = DRV_NAND_FLASH_TRANSFER_COMPLETED;
    }
    else
    {
        gDrvNandFlashObj.transferStatus = DRV_NAND_FLASH_TRANSFER_ERROR_UNKNOWN;
    }
}
</#if>

static void DRV_NAND_FLASH_ColumnAddressWrite(uint16_t columnAddress)
{
    uint16_t dataSize = (uint16_t)gDrvNandFlashData.nandFlashGeometry.pageSize;

    /* Check the data bus width */
    if (gDrvNandFlashData.nandFlashGeometry.dataBusWidth == 16U)
    {
        /* Divide by 2 for 16-bit address */
        columnAddress >>= 1;
    }

    /* Send column address */
    while (dataSize > 2U)
    {
        if (gDrvNandFlashData.nandFlashGeometry.dataBusWidth == 16U)
        {
            gDrvNandFlashObj.nandFlashPlib->AddressWrite16(gDrvNandFlashData.dataAddress, (columnAddress & 0xFFU));
        }
        else
        {
            gDrvNandFlashObj.nandFlashPlib->AddressWrite(gDrvNandFlashData.dataAddress, (columnAddress & 0xFFU));
        }
        dataSize >>= 8;
        columnAddress >>= 8;
    }
}

static void DRV_NAND_FLASH_RowAddressWrite(uint32_t rowAddress)
{
    /* Calculate number of pages in Flash device */
    uint32_t numOfPages = gDrvNandFlashData.nandFlashGeometry.deviceSize / gDrvNandFlashData.nandFlashGeometry.pageSize;

    /* Send row address */
    while (numOfPages > 0U)
    {
        if (gDrvNandFlashData.nandFlashGeometry.dataBusWidth == 16U)
        {
            gDrvNandFlashObj.nandFlashPlib->AddressWrite16(gDrvNandFlashData.dataAddress, (rowAddress & 0xFFU));
        }
        else
        {
            gDrvNandFlashObj.nandFlashPlib->AddressWrite(gDrvNandFlashData.dataAddress, (rowAddress & 0xFFU));
        }
        numOfPages >>= 8;
        rowAddress >>= 8;
    }
}
/* MISRA C-2012 Rule 11.1, 11.3, 11.6 and 11.8 deviated below. Deviation record ID -
   H3_MISRAC_2012_R_11_1_DR_1, H3_MISRAC_2012_R_11_3_DR_1
   H3_MISRAC_2012_R_11_6_DR_1 and H3_MISRAC_2012_R_11_8_DR_1*/
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:1 "MISRA C-2012 Rule 11.1" "H3_MISRAC_2012_R_11_1_DR_1" )\
(deviate:10 "MISRA C-2012 Rule 11.3" "H3_MISRAC_2012_R_11_3_DR_1" )\
(deviate:7 "MISRA C-2012 Rule 11.6" "H3_MISRAC_2012_R_11_6_DR_1" )\
(deviate:1 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1" )
</#if>
static void DRV_NAND_FLASH_DataWrite(uint32_t dataAddress, uint8_t *data, uint32_t size)
{
    uint32_t count = 0;
    uint16_t *data16 = NULL;
    uint32_t dataSize16 = 0;

    if (gDrvNandFlashData.nandFlashGeometry.dataBusWidth == 16U)
    {
        data16 = (uint16_t *)data;
        dataSize16 = (size + 1U) >> 1;

        /* Write page for 16-bit data bus */
        for (count = 0; count < dataSize16; count++)
        {
            gDrvNandFlashObj.nandFlashPlib->DataWrite16(dataAddress, data16[count]);
        }
    }
    else
    {
        /* Write page for 8-bit data bus */
        for (count = 0; count < size; count++)
        {
            gDrvNandFlashObj.nandFlashPlib->DataWrite(dataAddress, data[count]);
        }
    }
}

static void DRV_NAND_FLASH_DataRead(uint32_t dataAddress, uint8_t *data, uint32_t size)
{
    uint32_t count = 0;
    uint16_t *data16 = NULL;
    uint32_t dataSize16 = 0;

    if (gDrvNandFlashData.nandFlashGeometry.dataBusWidth == 16U)
    {
        data16 = (uint16_t *)data;
        dataSize16 = (size + 1U) >> 1;

        /* Read page for 16-bit data bus */
        for (count = 0; count < dataSize16; count++)
        {
            data16[count] = gDrvNandFlashObj.nandFlashPlib->DataRead16(dataAddress);
        }
    }
    else
    {
        /* Read page for 8-bit data bus */
        for (count = 0; count < size; count++)
        {
            data[count] = gDrvNandFlashObj.nandFlashPlib->DataRead(dataAddress);
        }
    }
}

static bool DRV_NAND_FLASH_PageRead(const DRV_HANDLE handle, uint16_t blockNum, uint16_t pageNum, uint8_t *data, uint8_t *spare)
{
    bool status = false;
    uint32_t columnAddress = 0;
    uint32_t rowAddress = 0;
    DRV_NAND_FLASH_TRANSFER_STATUS transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    /* Row address of the page */
    rowAddress = ((blockNum * (gDrvNandFlashData.nandFlashGeometry.blockSize / gDrvNandFlashData.nandFlashGeometry.pageSize)) + pageNum);

    /* Column address of the page */
    if (data != NULL)
    {
        columnAddress = 0;
    }
    else
    {
        columnAddress = gDrvNandFlashData.nandFlashGeometry.pageSize;
    }

    /* Send read command for cycle 1 */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_READ1);

    /* Send column address */
    DRV_NAND_FLASH_ColumnAddressWrite((uint16_t)columnAddress);

    /* Send row address */
    DRV_NAND_FLASH_RowAddressWrite(rowAddress);

    /* Send read page command for cycle 2 */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_READ2);

    /* Read the ready status */
    while (transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
    {
        transferStatus = DRV_NAND_FLASH_TransferStatusGet(handle);
    }

    if (transferStatus == DRV_NAND_FLASH_TRANSFER_COMPLETED)
    {
        /* Re-enable the data output mode by sending read mode command */
        gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_READ1);

        if (data != NULL)
        {
<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
            if (gDrvNandFlashObj.txrxDMAChannel != SYS_DMA_CHANNEL_NONE)
            {
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
                /* Invalidate the data buffer to force the CPU to read from the main memory */
                SYS_CACHE_InvalidateDCache_by_Addr(data, (int32_t)gDrvNandFlashData.nandFlashGeometry.pageSize);
</#if>
                gDrvNandFlashObj.transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;

                (void) SYS_DMA_ChannelTransfer(gDrvNandFlashObj.txrxDMAChannel,
                                       (const void *)gDrvNandFlashData.dataAddress,
                                       (const void *)data,
                                        gDrvNandFlashData.nandFlashGeometry.pageSize);

                /* Wait for DMA transfer completion */
                while (gDrvNandFlashObj.transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
                {
                    /* Nothing to do */
                }

                if (gDrvNandFlashObj.transferStatus != DRV_NAND_FLASH_TRANSFER_COMPLETED)
                {
                    return false;
                }
            }
            else
            {
                /* Read data page */
                DRV_NAND_FLASH_DataRead(gDrvNandFlashData.dataAddress, data, gDrvNandFlashData.nandFlashGeometry.pageSize);
            }
<#else>
            /* Read data page */
            DRV_NAND_FLASH_DataRead(gDrvNandFlashData.dataAddress, data, gDrvNandFlashData.nandFlashGeometry.pageSize);
</#if>
        }

        if (spare != NULL)
        {
<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
            if (gDrvNandFlashObj.txrxDMAChannel != SYS_DMA_CHANNEL_NONE)
            {
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
                /* Invalidate the spare buffer to force the CPU to read from the main memory */
                SYS_CACHE_InvalidateDCache_by_Addr(spare, (int32_t)gDrvNandFlashData.nandFlashGeometry.spareSize);
</#if>
                gDrvNandFlashObj.transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;

                (void) SYS_DMA_ChannelTransfer(gDrvNandFlashObj.txrxDMAChannel,
                                       (const void *)gDrvNandFlashData.dataAddress,
                                       (const void *)spare,
                                        gDrvNandFlashData.nandFlashGeometry.spareSize);

                /* Wait for DMA transfer completion */
                while (gDrvNandFlashObj.transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
                {
                    /* Nothing to do */
                }

                if (gDrvNandFlashObj.transferStatus != DRV_NAND_FLASH_TRANSFER_COMPLETED)
                {
                    return false;
                }
            }
            else
            {
                /* Read spare page */
                DRV_NAND_FLASH_DataRead(gDrvNandFlashData.dataAddress, spare, gDrvNandFlashData.nandFlashGeometry.spareSize);
            }
<#else>
            /* Read spare page */
            DRV_NAND_FLASH_DataRead(gDrvNandFlashData.dataAddress, spare, gDrvNandFlashData.nandFlashGeometry.spareSize);
</#if>
        }

        status = true;
    }

    return status;
}

static bool DRV_NAND_FLASH_PageWrite(const DRV_HANDLE handle, uint16_t blockNum, uint16_t pageNum, uint8_t *data, uint8_t *spare)
{
    uint32_t columnAddress = 0;
    uint32_t rowAddress = 0;
    DRV_NAND_FLASH_TRANSFER_STATUS transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;
    uint32_t spareDataAddress = 0;
    bool status = false;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    /* Row address of the page */
    rowAddress = ((blockNum * (gDrvNandFlashData.nandFlashGeometry.blockSize / gDrvNandFlashData.nandFlashGeometry.pageSize)) + pageNum);

    /* Column address of the page */
    if (data != NULL)
    {
        columnAddress = 0;
        spareDataAddress = gDrvNandFlashData.dataAddress + gDrvNandFlashData.nandFlashGeometry.pageSize;
    }
    else
    {
        columnAddress = gDrvNandFlashData.nandFlashGeometry.pageSize;
        spareDataAddress = gDrvNandFlashData.dataAddress;
    }

    /* Send page program command for cycle 1 */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_PAGE_PROGRAM1);

    /* Send column address */
    DRV_NAND_FLASH_ColumnAddressWrite((uint16_t)columnAddress);

    /* Send row address */
    DRV_NAND_FLASH_RowAddressWrite(rowAddress);

    if (data != NULL)
    {
<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
        if (gDrvNandFlashObj.txrxDMAChannel != SYS_DMA_CHANNEL_NONE)
        {
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
            /* Clean the data buffer to push the data to the main memory */
            SYS_CACHE_CleanDCache_by_Addr(data, (int32_t)gDrvNandFlashData.nandFlashGeometry.pageSize);
</#if>
            gDrvNandFlashObj.transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;

            (void) SYS_DMA_ChannelTransfer(gDrvNandFlashObj.txrxDMAChannel,
                                   (const void *)data,
                                   (const void *)gDrvNandFlashData.dataAddress,
                                    gDrvNandFlashData.nandFlashGeometry.pageSize);

            /* Wait for DMA transfer completion */
            while (gDrvNandFlashObj.transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
            {
                /* Nothing to do */
            }

            if (gDrvNandFlashObj.transferStatus != DRV_NAND_FLASH_TRANSFER_COMPLETED)
            {
                return false;
            }
        }
        else
        {
            /* Write data page */
            DRV_NAND_FLASH_DataWrite(gDrvNandFlashData.dataAddress, data, gDrvNandFlashData.nandFlashGeometry.pageSize);
        }
<#else>
        /* Write data page */
        DRV_NAND_FLASH_DataWrite(gDrvNandFlashData.dataAddress, data, gDrvNandFlashData.nandFlashGeometry.pageSize);
</#if>
    }

    if (spare != NULL)
    {
<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
        if (gDrvNandFlashObj.txrxDMAChannel != SYS_DMA_CHANNEL_NONE)
        {
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
            /* Clean the spare buffer to push the data to the main memory */
            SYS_CACHE_CleanDCache_by_Addr(spare, (int32_t)gDrvNandFlashData.nandFlashGeometry.spareSize);
</#if>
            gDrvNandFlashObj.transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;

            (void) SYS_DMA_ChannelTransfer(gDrvNandFlashObj.txrxDMAChannel,
                                   (const void *)spare,
                                   (const void *)spareDataAddress,
                                    gDrvNandFlashData.nandFlashGeometry.spareSize);

            /* Wait for DMA transfer completion */
            while (gDrvNandFlashObj.transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
            {
                /* Nothing to do */
            }

            if (gDrvNandFlashObj.transferStatus != DRV_NAND_FLASH_TRANSFER_COMPLETED)
            {
                return false;
            }
        }
        else
        {
            /* Write spare page */
            DRV_NAND_FLASH_DataWrite(spareDataAddress, spare, gDrvNandFlashData.nandFlashGeometry.spareSize);
        }
<#else>
        /* Write spare page */
        DRV_NAND_FLASH_DataWrite(spareDataAddress, spare, gDrvNandFlashData.nandFlashGeometry.spareSize);
</#if>
    }

    /* Send page program command for cycle 2 */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_PAGE_PROGRAM2);

    /* Read the ready status */
    while (transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
    {
        transferStatus = DRV_NAND_FLASH_TransferStatusGet(handle);
    }

    if (transferStatus == DRV_NAND_FLASH_TRANSFER_COMPLETED)
    {
        status = true;
    }

    return status;
}

<#if DRV_NAND_FLASH_PMECC_ENABLE == true>
static bool DRV_NAND_FLASH_PageReadPmecc(const DRV_HANDLE handle, uint16_t blockNum, uint16_t pageNum, uint8_t *data)
{
    bool status = false;
    uint32_t columnAddress = 0;
    uint32_t rowAddress = 0;
    DRV_NAND_FLASH_TRANSFER_STATUS transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    uint32_t temp;
</#if>

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    /* Row address of the page */
    rowAddress = ((blockNum * (gDrvNandFlashData.nandFlashGeometry.blockSize / gDrvNandFlashData.nandFlashGeometry.pageSize)) + pageNum);

    /* Send read command for cycle 1 */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_READ1);

    /* Send column address */
    DRV_NAND_FLASH_ColumnAddressWrite((uint16_t)columnAddress);

    /* Send row address */
    DRV_NAND_FLASH_RowAddressWrite(rowAddress);

    /* Send read page command for cycle 2 */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_READ2);

    /* Read the ready status */
    while (transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
    {
        transferStatus = DRV_NAND_FLASH_TransferStatusGet(handle);
    }

    if (transferStatus == DRV_NAND_FLASH_TRANSFER_COMPLETED)
    {
        /* Re-enable the data output mode by sending read mode command */
        gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_READ1);

        /* Enable Read access and start data phase */
        gDrvNandFlashObj.nandFlashPlib->DataPhaseStart(0);

<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
        if (gDrvNandFlashObj.txrxDMAChannel != SYS_DMA_CHANNEL_NONE)
        {
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
            temp = (gDrvNandFlashData.nandFlashGeometry.pageSize + DRV_NAND_FLASH_PMECC_ECC_START_ADDR + (uint32_t)DRV_NAND_FLASH_PMECC_ECC_SPARE_SIZE);
            /* Invalidate the data buffer to force the CPU to read from the main memory */
            SYS_CACHE_InvalidateDCache_by_Addr(data, (int32_t)temp);
</#if>
            gDrvNandFlashObj.transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;

            (void) SYS_DMA_ChannelTransfer(gDrvNandFlashObj.txrxDMAChannel,
                                   (const void *)gDrvNandFlashData.dataAddress,
                                   (const void *)data,
                                   (gDrvNandFlashData.nandFlashGeometry.pageSize + DRV_NAND_FLASH_PMECC_ECC_START_ADDR + (uint32_t)DRV_NAND_FLASH_PMECC_ECC_SPARE_SIZE));

            /* Wait for DMA transfer completion */
            while (gDrvNandFlashObj.transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
            {
                /* Nothing to do */
            }

            if (gDrvNandFlashObj.transferStatus != DRV_NAND_FLASH_TRANSFER_COMPLETED)
            {
                return false;
            }
        }
        else
        {
            /* Read data page */
            DRV_NAND_FLASH_DataRead(gDrvNandFlashData.dataAddress, data,
            (gDrvNandFlashData.nandFlashGeometry.pageSize + DRV_NAND_FLASH_PMECC_ECC_START_ADDR + (uint32_t)DRV_NAND_FLASH_PMECC_ECC_SPARE_SIZE));
        }
<#else>
        /* Read data page */
        DRV_NAND_FLASH_DataRead(gDrvNandFlashData.dataAddress, data,
        (gDrvNandFlashData.nandFlashGeometry.pageSize + DRV_NAND_FLASH_PMECC_ECC_START_ADDR + DRV_NAND_FLASH_PMECC_ECC_SPARE_SIZE));
</#if>

        /* Wait until PMECC is not busy */
        while (gDrvNandFlashObj.nandFlashPlib->StatusIsBusy() == true)
        {
            /* Nothing to do */
        }

        status = true;
    }

    return status;
}

static bool DRV_NAND_FLASH_PageReadWithPMECC(const DRV_HANDLE handle, uint16_t blockNum, uint16_t pageNum, uint8_t *data)
{
    bool status = false, tempPmeccCorrection;
    uint32_t pmeccErrorStatus = 0;
    uint32_t count = 0;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    /* Read Page */
    if (!DRV_NAND_FLASH_PageReadPmecc(handle, blockNum, pageNum, data))
    {
        return status;
    }

    /* Check PMECC Error */
    pmeccErrorStatus = gDrvNandFlashObj.nandFlashPlib->ErrorGet();
    if (pmeccErrorStatus != 0U)
    {
        /* Check if spare area is erased */
        (void) DRV_NAND_FLASH_PageRead(handle, blockNum, pageNum, NULL, gDrvNandFlashData.spareBuffer);

        for (count = 0; count < gDrvNandFlashData.nandFlashGeometry.spareSize; count++)
        {
            if (gDrvNandFlashData.spareBuffer[count] != 0xFFU)
            {
                break;
            }
        }
        if (count == gDrvNandFlashData.nandFlashGeometry.spareSize)
        {
            pmeccErrorStatus = 0;
        }
    }

    tempPmeccCorrection = (DRV_NAND_FLASH_PmeccCorrection(pmeccErrorStatus, (uint32_t)data) == false);
    /* Perform bit correction in data buffer */
    if ((pmeccErrorStatus != 0U) && tempPmeccCorrection)
    {
        status = false;
    }
    else
    {
        status = true;
    }
    return status;
}

static bool DRV_NAND_FLASH_PageWriteWithPMECC(const DRV_HANDLE handle, uint16_t blockNum, uint16_t pageNum, uint8_t *data)
{
    uint32_t columnAddress = 0;
    uint32_t rowAddress = 0;
    DRV_NAND_FLASH_TRANSFER_STATUS transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;
    uint32_t count = 0;
    uint32_t byteIndex = 0;
    uint32_t eccStartAddr = 0;
    bool status = false;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    /* Row address of the page */
    rowAddress = ((blockNum * (gDrvNandFlashData.nandFlashGeometry.blockSize / gDrvNandFlashData.nandFlashGeometry.pageSize)) + pageNum);

    /* ECC start address of the page */
    eccStartAddr = gDrvNandFlashData.nandFlashGeometry.pageSize + DRV_NAND_FLASH_PMECC_ECC_START_ADDR;

    /* Enable Write access and start data phase */
    gDrvNandFlashObj.nandFlashPlib->DataPhaseStart(1);

    /* Send page program command for cycle 1 */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_PAGE_PROGRAM1);

    /* Send column address */
    DRV_NAND_FLASH_ColumnAddressWrite((uint16_t)columnAddress);

    /* Send row address */
    DRV_NAND_FLASH_RowAddressWrite(rowAddress);

<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
    if (gDrvNandFlashObj.txrxDMAChannel != SYS_DMA_CHANNEL_NONE)
    {
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
        /* Clean the data buffer to push the data to the main memory */
        SYS_CACHE_CleanDCache_by_Addr(data, (int32_t)gDrvNandFlashData.nandFlashGeometry.pageSize);
</#if>
        gDrvNandFlashObj.transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;

        (void) SYS_DMA_ChannelTransfer(gDrvNandFlashObj.txrxDMAChannel,
                               (const void *)data,
                               (const void *)gDrvNandFlashData.dataAddress,
                                gDrvNandFlashData.nandFlashGeometry.pageSize);

        /* Wait for DMA transfer completion */
        while (gDrvNandFlashObj.transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
        {
            /* Nothing to do */
        }

        if (gDrvNandFlashObj.transferStatus != DRV_NAND_FLASH_TRANSFER_COMPLETED)
        {
            return false;
        }
    }
    else
    {
        /* Write data page */
        DRV_NAND_FLASH_DataWrite(gDrvNandFlashData.dataAddress, data, gDrvNandFlashData.nandFlashGeometry.pageSize);
    }
<#else>
    /* Write data page */
    DRV_NAND_FLASH_DataWrite(gDrvNandFlashData.dataAddress, data, gDrvNandFlashData.nandFlashGeometry.pageSize);
</#if>

    /* Send change write column (Random data input) command for cycle 1 */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_CHANGE_WRITE_COLUMN);

    /* Send ECC start address */
    DRV_NAND_FLASH_ColumnAddressWrite((uint16_t)eccStartAddr);

    /* Wait until PMECC is not busy */
    while (gDrvNandFlashObj.nandFlashPlib->StatusIsBusy() == true)
    {
        /* Nothing to do */
    }

    /* Read all ECC registers */
    for (count = 0; count < (uint32_t)DRV_NAND_FLASH_PMECC_NUMBER_OF_SECTORS; count++)
    {
        for (byteIndex = 0; byteIndex < ((uint32_t)DRV_NAND_FLASH_PMECC_ECC_SPARE_SIZE / (uint32_t)DRV_NAND_FLASH_PMECC_NUMBER_OF_SECTORS); byteIndex++)
        {
            gDrvNandFlashData.spareBuffer[(count * ((uint32_t)DRV_NAND_FLASH_PMECC_ECC_SPARE_SIZE / (uint32_t)DRV_NAND_FLASH_PMECC_NUMBER_OF_SECTORS)) + byteIndex] =
            gDrvNandFlashObj.nandFlashPlib->ECCGet(count, byteIndex);
        }
    }

<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
    if (gDrvNandFlashObj.txrxDMAChannel != SYS_DMA_CHANNEL_NONE)
    {
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
        /* Clean the data buffer to push the data to the main memory */
        SYS_CACHE_CleanDCache_by_Addr(gDrvNandFlashData.spareBuffer, DRV_NAND_FLASH_PMECC_ECC_SPARE_SIZE);
</#if>
        gDrvNandFlashObj.transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;

        (void) SYS_DMA_ChannelTransfer(gDrvNandFlashObj.txrxDMAChannel,
                               (const void *)gDrvNandFlashData.spareBuffer,
                               (const void *)gDrvNandFlashData.dataAddress,
                                DRV_NAND_FLASH_PMECC_ECC_SPARE_SIZE);

        /* Wait for DMA transfer completion */
        while (gDrvNandFlashObj.transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
        {
            /* Nothing to do */
        }

        if (gDrvNandFlashObj.transferStatus != DRV_NAND_FLASH_TRANSFER_COMPLETED)
        {
            return false;
        }
    }
    else
    {
        /* Write spare page */
        DRV_NAND_FLASH_DataWrite(gDrvNandFlashData.dataAddress, gDrvNandFlashData.spareBuffer, DRV_NAND_FLASH_PMECC_ECC_SPARE_SIZE);
    }
<#else>
    /* Write spare page */
    DRV_NAND_FLASH_DataWrite(gDrvNandFlashData.dataAddress, gDrvNandFlashData.spareBuffer, DRV_NAND_FLASH_PMECC_ECC_SPARE_SIZE);
</#if>

    /* Send page program command for cycle 2 */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_PAGE_PROGRAM2);

    /* Read the ready status */
    while (transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
    {
        transferStatus = DRV_NAND_FLASH_TransferStatusGet(handle);
    }

    if (transferStatus == DRV_NAND_FLASH_TRANSFER_COMPLETED)
    {
        status = true;
    }

    return status;
}
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: NAND FLASH Driver Global Functions
// *****************************************************************************
// *****************************************************************************

bool DRV_NAND_FLASH_ResetFlash(const DRV_HANDLE handle)
{
    DRV_NAND_FLASH_TRANSFER_STATUS transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;

    if (handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_RESET);

    /* Read the ready status */
    while (transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
    {
        transferStatus = DRV_NAND_FLASH_TransferStatusGet(handle);
    }

    if (transferStatus != DRV_NAND_FLASH_TRANSFER_COMPLETED)
    {
        return false;
    }

    return true;
}

DRV_NAND_FLASH_TRANSFER_STATUS DRV_NAND_FLASH_TransferStatusGet(const DRV_HANDLE handle)
{
    uint8_t reg_status = 0;
    DRV_NAND_FLASH_TRANSFER_STATUS transferStatus = DRV_NAND_FLASH_TRANSFER_ERROR_UNKNOWN;

    if (handle == DRV_HANDLE_INVALID)
    {
        return transferStatus;
    }

    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_READ_STATUS);

    reg_status = gDrvNandFlashObj.nandFlashPlib->DataRead(gDrvNandFlashData.dataAddress);

    // Check Ready bit
    if ((reg_status & (1UL << 6)) != 0U)
    {
        // Check Fail bit
        if ((reg_status & (1UL << 0)) != 0U)
        {
            transferStatus = DRV_NAND_FLASH_TRANSFER_FAIL;
        }
        else
        {
            transferStatus = DRV_NAND_FLASH_TRANSFER_COMPLETED;
        }
    }
    else
    {
        transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;
    }

    return transferStatus;
}

bool DRV_NAND_FLASH_IdRead(const DRV_HANDLE handle, uint32_t *readId, uint8_t address)
{
    uint8_t *data = (uint8_t *)readId;
    uint8_t count = 0;

    if (handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    /* Send Read ID command */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_READ_ID);

    /* Send Address */
    gDrvNandFlashObj.nandFlashPlib->AddressWrite(gDrvNandFlashData.dataAddress, address);

    /* Read data */
    for (count = 0; count < sizeof(*readId); count++)
    {
        data[count] = gDrvNandFlashObj.nandFlashPlib->DataRead(gDrvNandFlashData.dataAddress);
    }

    return true;
}

bool DRV_NAND_FLASH_FeatureSet(const DRV_HANDLE handle, uint8_t *featureData, uint8_t featureDataSize, uint8_t featureAddress)
{
    uint8_t count = 0;

    if (handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    /* Send set feature command */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_SET_FEATURES);

    /* Send Address */
    gDrvNandFlashObj.nandFlashPlib->AddressWrite(gDrvNandFlashData.dataAddress, featureAddress);

    /* Set features data */
    for (count = 0; count < featureDataSize; count++)
    {
        gDrvNandFlashObj.nandFlashPlib->DataWrite(gDrvNandFlashData.dataAddress, featureData[count]);
    }

    return true;
}

bool DRV_NAND_FLASH_FeatureGet(const DRV_HANDLE handle, uint8_t *featureData, uint8_t featureDataSize, uint8_t featureAddress)
{
    uint8_t count = 0;

    if (handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    /* Send get feature command */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_GET_FEATURES);

    /* Send Address */
    gDrvNandFlashObj.nandFlashPlib->AddressWrite(gDrvNandFlashData.dataAddress, featureAddress);

    /* Get features data */
    for (count = 0; count < featureDataSize; count++)
    {
        featureData[count] = gDrvNandFlashObj.nandFlashPlib->DataRead(gDrvNandFlashData.dataAddress);
    }

    return true;
}

bool DRV_NAND_FLASH_ParameterPageRead(const DRV_HANDLE handle, uint8_t *parameterPage, uint32_t size)
{
    DRV_NAND_FLASH_TRANSFER_STATUS transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;
    uint32_t count = 0;

    if (handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    if (size > 256U)
    {
        size = 256;
    }

    /* Send Read Parameter Page command */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_READ_PARAMETER_PAGE);

    /* Send Address */
    gDrvNandFlashObj.nandFlashPlib->AddressWrite(gDrvNandFlashData.dataAddress, 0x00);

    /* Read the ready status */
    while (transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
    {
        transferStatus = DRV_NAND_FLASH_TransferStatusGet(handle);
    }

    if (transferStatus == DRV_NAND_FLASH_TRANSFER_COMPLETED)
    {
        /* Re-enable the data output mode by sending read mode command */
        gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_READ1);

        /* Read Parameter Page */
        for (count = 0; count < size; count++)
        {
            parameterPage[count] = gDrvNandFlashObj.nandFlashPlib->DataRead(gDrvNandFlashData.dataAddress);
        }
    }
    else
    {
        return false;
    }

    return true;
}

bool DRV_NAND_FLASH_GeometryGet(const DRV_HANDLE handle, DRV_NAND_FLASH_GEOMETRY *geometry)
{
    uint32_t numOfPages = 0;
    uint32_t numOfBlocks = 0;
    uint8_t flashParameter[116];
    bool status = false;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    if (DRV_NAND_FLASH_ParameterPageRead(handle, flashParameter, sizeof(flashParameter)))
    {
        /* JEDEC Manufacturer ID */
        geometry->deviceId = flashParameter[64];

        /* Bus Width */
        geometry->dataBusWidth = ((flashParameter[6] & 0x01U) != 0U) ? 16U : 8U;

        /* Get number of data bytes per page */
        (void) memcpy((uint8_t*)&geometry->pageSize, &flashParameter[80], 4);

        /* Get number of spare bytes per page */
        (void) memcpy((uint8_t*)&geometry->spareSize, &flashParameter[84], 2);

        /* Get Block Size */
        (void) memcpy((uint8_t*)&numOfPages, &flashParameter[92], 4);
        geometry->blockSize = geometry->pageSize * numOfPages;

        /* Get Device Size */
        (void) memcpy((uint8_t*)&numOfBlocks, &flashParameter[96], 4);
        geometry->deviceSize = geometry->blockSize * numOfBlocks;

        /* Get number of logical units */
        geometry->numberOfLogicalUnits = flashParameter[100];

        /* Get number of bits of ECC correction */
        geometry->eccCorrectability = flashParameter[112];

        status = true;
    }

    return status;
}

bool DRV_NAND_FLASH_SkipBlock_BlockCheck(const DRV_HANDLE handle, uint16_t blockNum)
{
    uint8_t marker[2];
    bool status = false;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    if (DRV_NAND_FLASH_PageRead(handle, blockNum, 0, NULL, gDrvNandFlashData.spareBuffer))
    {
        marker[0] = gDrvNandFlashData.spareBuffer[0];
        if (DRV_NAND_FLASH_PageRead(handle, blockNum, 1, NULL, gDrvNandFlashData.spareBuffer))
        {
            marker[1] = gDrvNandFlashData.spareBuffer[0];
            if ((marker[0] == 0xFFU) && (marker[1] == 0xFFU))
            {
                /* Good block */
                status = true;
            }
        }
    }

    return status;
}

bool DRV_NAND_FLASH_SkipBlock_BlockErase(const DRV_HANDLE handle, uint16_t blockNum, bool disableBlockCheck)
{
    DRV_NAND_FLASH_TRANSFER_STATUS transferStatus = DRV_NAND_FLASH_TRANSFER_BUSY;
    uint32_t rowAddress = 0;
    bool status = false;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    if (!disableBlockCheck)
    {
        if (!DRV_NAND_FLASH_SkipBlock_BlockCheck(handle, blockNum))
        {
            return status;
        }
    }

    /* Send block erase command for cycle 1 */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_BLOCK_ERASE1);

    /* Calculate row address used for erase */
    rowAddress = blockNum * (gDrvNandFlashData.nandFlashGeometry.blockSize / gDrvNandFlashData.nandFlashGeometry.pageSize);

    /* Send row address */
    DRV_NAND_FLASH_RowAddressWrite(rowAddress);

    /* Send block erase command for cycle 2 */
    gDrvNandFlashObj.nandFlashPlib->CommandWrite(gDrvNandFlashData.dataAddress, NAND_FLASH_CMD_BLOCK_ERASE2);

    /* Read the ready status */
    while (transferStatus == DRV_NAND_FLASH_TRANSFER_BUSY)
    {
        transferStatus = DRV_NAND_FLASH_TransferStatusGet(handle);
    }

    if (transferStatus == DRV_NAND_FLASH_TRANSFER_COMPLETED)
    {
        status = true;
    }

    return status;
}

bool DRV_NAND_FLASH_SkipBlock_BlockTag(const DRV_HANDLE handle, uint16_t blockNum, bool badBlock)
{
    bool status = false;
    uint8_t count = 0;

    if (handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    status = DRV_NAND_FLASH_SkipBlock_BlockCheck(handle, blockNum);

    if ((badBlock && (status == false)) || ((badBlock == false) && status))
    {
        return true;
    }

    status = DRV_NAND_FLASH_SkipBlock_BlockErase(handle, blockNum, true);
    if (status)
    {
        if (badBlock)
        {
            /* Tag bad block */
            (void) memset(gDrvNandFlashData.spareBuffer, 0xFF, sizeof(gDrvNandFlashData.spareBuffer));
            gDrvNandFlashData.spareBuffer[0] = 0xDE;

            for (count = 0U; count < 2U; count++)
            {
                status = DRV_NAND_FLASH_PageWrite(handle, blockNum, count, NULL, gDrvNandFlashData.spareBuffer);
                if (status == false)
                {
                    return status;
                }
                gDrvNandFlashData.spareBuffer[0] = 0xAD;
            }
        }
        else
        {
            /* Tag good block */
            status = DRV_NAND_FLASH_SkipBlock_BlockCheck(handle, blockNum);
        }
    }

    return status;
}

bool DRV_NAND_FLASH_SkipBlock_PageRead(const DRV_HANDLE handle, uint16_t blockNum, uint16_t pageNum, uint8_t *data, uint8_t *spare, bool disableBlockCheck)
{
    if (handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    if (!disableBlockCheck)
    {
        if (!DRV_NAND_FLASH_SkipBlock_BlockCheck(handle, blockNum))
        {
            return false;
        }
    }

<#if DRV_NAND_FLASH_PMECC_ENABLE == false>
    if (!DRV_NAND_FLASH_PageRead(handle, blockNum, pageNum, data, spare))
    {
        return false;
    }
<#else>
    if (spare != NULL)
    {
        if (!DRV_NAND_FLASH_PageRead(handle, blockNum, pageNum, data, spare))
        {
            return false;
        }
    }
    else
    {
        if (!DRV_NAND_FLASH_PageReadWithPMECC(handle, blockNum, pageNum, data))
        {
            return false;
        }
    }
</#if>

    return true;
}

bool DRV_NAND_FLASH_SkipBlock_BlockRead(const DRV_HANDLE handle, uint16_t blockNum, uint8_t *data, bool disableBlockCheck)
{
    uint32_t count = 0;

    if (handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    if (!disableBlockCheck)
    {
        if (!DRV_NAND_FLASH_SkipBlock_BlockCheck(handle, blockNum))
        {
            return false;
        }
    }

    for (count = 0; count < (gDrvNandFlashData.nandFlashGeometry.blockSize / gDrvNandFlashData.nandFlashGeometry.pageSize); count++)
    {

<#if DRV_NAND_FLASH_PMECC_ENABLE == false>
        if (!DRV_NAND_FLASH_PageRead(handle, blockNum, (uint16_t)count, data, NULL))
        {
            return false;
        }
<#else>
        if (!DRV_NAND_FLASH_PageReadWithPMECC(handle, blockNum, (uint16_t)count, data))
        {
            return false;
        }
</#if>
        data = data + gDrvNandFlashData.nandFlashGeometry.pageSize;
    }

    return true;
}

bool DRV_NAND_FLASH_SkipBlock_PageWrite(const DRV_HANDLE handle, uint16_t blockNum, uint16_t pageNum, uint8_t *data, uint8_t *spare, bool disableBlockCheck)
{
    if (handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    if (!disableBlockCheck)
    {
        if (!DRV_NAND_FLASH_SkipBlock_BlockCheck(handle, blockNum))
        {
            return false;
        }
    }
<#if DRV_NAND_FLASH_PMECC_ENABLE == false>
    if (!DRV_NAND_FLASH_PageWrite(handle, blockNum, pageNum, data, spare))
    {
        return false;
    }
<#else>
    if (spare != NULL)
    {
        if (!DRV_NAND_FLASH_PageWrite(handle, blockNum, pageNum, data, spare))
        {
            return false;
        }
    }
    else
    {
        if (!DRV_NAND_FLASH_PageWriteWithPMECC(handle, blockNum, pageNum, data))
        {
            return false;
        }
    }
</#if>

    return true;
}

bool DRV_NAND_FLASH_SkipBlock_BlockWrite(const DRV_HANDLE handle, uint16_t blockNum, uint8_t *data, bool disableBlockCheck)
{
    uint32_t count = 0;

    if (handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    if (!disableBlockCheck)
    {
        if (!DRV_NAND_FLASH_SkipBlock_BlockCheck(handle, blockNum))
        {
            return false;
        }
    }

    for (count = 0; count < (gDrvNandFlashData.nandFlashGeometry.blockSize / gDrvNandFlashData.nandFlashGeometry.pageSize); count++)
    {
<#if DRV_NAND_FLASH_PMECC_ENABLE == false>
        if (!DRV_NAND_FLASH_PageWrite(handle, blockNum, (uint16_t)count, data, NULL))
        {
            return false;
        }
<#else>
        if (!DRV_NAND_FLASH_PageWriteWithPMECC(handle, blockNum, (uint16_t)count, data))
        {
            return false;
        }
</#if>
        data = data + gDrvNandFlashData.nandFlashGeometry.pageSize;
    }

    return true;
}

DRV_HANDLE DRV_NAND_FLASH_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    DRV_NAND_FLASH_GEOMETRY geometry;

    if ((gDrvNandFlashObj.status != SYS_STATUS_READY) ||
        (gDrvNandFlashObj.nClients >= DRV_NAND_FLASH_CLIENTS_NUMBER))
    {
        return DRV_HANDLE_INVALID;
    }

    /* Reset NAND Flash */
    if (!DRV_NAND_FLASH_ResetFlash((DRV_HANDLE)drvIndex))
    {
        return DRV_HANDLE_INVALID;
    }

    /* Store the NAND Flash data */
    if (DRV_NAND_FLASH_GeometryGet((DRV_HANDLE)drvIndex, &geometry))
    {
        gDrvNandFlashData.nandFlashGeometry.deviceId = geometry.deviceId;
        gDrvNandFlashData.nandFlashGeometry.dataBusWidth = geometry.dataBusWidth;
        gDrvNandFlashData.nandFlashGeometry.pageSize = geometry.pageSize;
        gDrvNandFlashData.nandFlashGeometry.spareSize = geometry.spareSize;
        gDrvNandFlashData.nandFlashGeometry.blockSize = geometry.blockSize;
        gDrvNandFlashData.nandFlashGeometry.deviceSize = geometry.deviceSize;
        gDrvNandFlashData.nandFlashGeometry.numberOfLogicalUnits = geometry.numberOfLogicalUnits;
        gDrvNandFlashData.nandFlashGeometry.eccCorrectability = geometry.eccCorrectability;
<#if DRV_NAND_FLASH_PMECC_ENABLE == true>
        if (!DRV_NAND_FLASH_PmeccDescSetup(geometry.pageSize, geometry.spareSize, &gDrvNandFlashObj))
        {
            return DRV_HANDLE_INVALID;
        }
</#if>
<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
        /* Setup data bus width with DMA System Service */
        if (gDrvNandFlashObj.txrxDMAChannel != SYS_DMA_CHANNEL_NONE)
        {
            if (gDrvNandFlashData.nandFlashGeometry.dataBusWidth == 16U)
            {
                SYS_DMA_DataWidthSetup(gDrvNandFlashObj.txrxDMAChannel, SYS_DMA_WIDTH_16_BIT);
            }
            else
            {
                SYS_DMA_DataWidthSetup(gDrvNandFlashObj.txrxDMAChannel, SYS_DMA_WIDTH_8_BIT);
            }
        }
</#if>
    }
    else
    {
        return DRV_HANDLE_INVALID;
    }

    gDrvNandFlashObj.nClients++;

    gDrvNandFlashObj.ioIntent = ioIntent;

    return ((DRV_HANDLE)drvIndex);
}

void DRV_NAND_FLASH_Close( const DRV_HANDLE handle )
{
    if ( (handle != DRV_HANDLE_INVALID) &&
         (gDrvNandFlashObj.nClients > 0U))
    {
        gDrvNandFlashObj.nClients--;
    }
}

SYS_MODULE_OBJ DRV_NAND_FLASH_Initialize
(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT *const init
)
{
    DRV_NAND_FLASH_INIT *nandFlashInit = NULL;

    /* Check if the instance has already been initialized. */
    if (gDrvNandFlashObj.inUse)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    gDrvNandFlashObj.status = SYS_STATUS_UNINITIALIZED;

    /* Indicate that this object is in use */
    gDrvNandFlashObj.inUse = true;
    gDrvNandFlashObj.nClients  = 0;

    /* Assign to the local pointer the init data passed */
    nandFlashInit = (DRV_NAND_FLASH_INIT *)init;

    /* Initialize the attached memory device functions */
    gDrvNandFlashObj.nandFlashPlib = nandFlashInit->nandFlashPlib;

    /* Get the data address of NAND Flash */
    gDrvNandFlashData.dataAddress = gDrvNandFlashObj.nandFlashPlib->DataAddressGet(DRV_NAND_FLASH_CS);

<#if core.DMA_ENABLE?has_content && DRV_NAND_FLASH_TX_RX_DMA?? && DRV_NAND_FLASH_TX_RX_DMA == true>
    gDrvNandFlashObj.transferStatus  = DRV_NAND_FLASH_TRANSFER_COMPLETED;

    /* Register call-backs with the DMA System Service */
    if (gDrvNandFlashObj.txrxDMAChannel != SYS_DMA_CHANNEL_NONE)
    {
        SYS_DMA_ChannelCallbackRegister(gDrvNandFlashObj.txrxDMAChannel, DRV_NAND_FLASH_DMA_CallbackHandler, 0);
    }
</#if>

    gDrvNandFlashObj.status = SYS_STATUS_READY;

    /* Return the driver index */
    return drvIndex;
}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.3"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.6"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */

SYS_STATUS DRV_NAND_FLASH_Status( const SYS_MODULE_INDEX drvIndex )
{
    /* Return the driver status */
    return (gDrvNandFlashObj.status);
}
