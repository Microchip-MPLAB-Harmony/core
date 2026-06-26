/*******************************************************************************
  EEPROM Emulator File

  File Name:
    emulated_eeprom.c

  Summary:
    This file contains EEPROM Emulator library source code

  Description:
    This file contains EEPROM Emulator library source code
 *******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2021 Microchip Technology Inc. and its subsidiaries.
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
// DOM-IGNORE-END
/* MIPS file*/

#include <string.h>
#include "system/system_module.h"
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
#include "system/cache/sys_cache.h"
</#if>
#include "emulated_eeprom_local.h"
#include "peripheral/${EEPROM_EMULATOR_NVM_PLIB?lower_case}/plib_${EEPROM_EMULATOR_NVM_PLIB?lower_case}.h"
#include "emulated_eeprom.h"
#include "definitions.h"

#define EEPROM_EMULATOR_VERSION             0x02
#define CRC8_POLY  0x07  // Polynomial: x^8 + x^2 + x^1 + 1 (0x07)

static uint8_t buffer_write[EEPROM_EMULATOR_PAGE_DATA_SIZE] CACHE_ALIGN;
/**
 * \internal
 * \brief Internal EEPROM emulator instance.
 */
static EEPROM_MODULE  eeprom_instance CACHE_ALIGN =
{
    .initialized = false,
};

static EEPROM_PAGE* EMU_EEPROM_PageToAddrTranslation(uint16_t physical_page)
{
    EEPROM_PAGE* flashAddr = NULL;

<#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED?? && EEPROM_EMULATOR_RWWEE_ENABLED??>
    <#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED == true && EEPROM_EMULATOR_RWWEE_ENABLED == true>
        <#lt>   if (physical_page >= EEPROM_EMULATOR_NUM_MAIN_ARRAY_PHY_PAGES)
        <#lt>   {
        <#lt>       flashAddr = (EEPROM_PAGE*)&eeprom_instance.rwwee[physical_page - EEPROM_EMULATOR_NUM_MAIN_ARRAY_PHY_PAGES];
        <#lt>   }
        <#lt>   else
        <#lt>   {
        <#lt>       flashAddr = (EEPROM_PAGE*)&eeprom_instance.main_array[physical_page];
        <#lt>   }
    <#elseif EEPROM_EMULATOR_RWWEE_ENABLED == true>
        <#lt>   flashAddr = (EEPROM_PAGE*)&eeprom_instance.rwwee[physical_page];
    <#else>
        <#lt>   flashAddr = (EEPROM_PAGE*)&eeprom_instance.main_array[physical_page];
    </#if>
<#else>
    flashAddr = (EEPROM_PAGE*)&eeprom_instance.main_array[physical_page];
</#if>

    return flashAddr;
}

static uint16_t EMU_EEPROM_PhysicalToLogicalPage(uint16_t physical_page)
{
    EEPROM_PAGE* flashAddr = NULL;

<#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED?? && EEPROM_EMULATOR_RWWEE_ENABLED??>
    <#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED == true && EEPROM_EMULATOR_RWWEE_ENABLED == true>
        <#lt>   if (physical_page >= EEPROM_EMULATOR_NUM_MAIN_ARRAY_PHY_PAGES)
        <#lt>   {
        <#lt>       flashAddr = &eeprom_instance.rwwee[physical_page - EEPROM_EMULATOR_NUM_MAIN_ARRAY_PHY_PAGES];
        <#lt>   }
        <#lt>   else
        <#lt>   {
        <#lt>       flashAddr = &eeprom_instance.main_array[physical_page];
        <#lt>   }
    <#elseif EEPROM_EMULATOR_RWWEE_ENABLED == true>
        <#lt>   flashAddr = &eeprom_instance.rwwee[physical_page];
    <#else>
        <#lt>   flashAddr = &eeprom_instance.main_array[physical_page];
    </#if>
<#else>
    flashAddr = &eeprom_instance.main_array[physical_page];
</#if>

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_InvalidateDCache_by_Addr(flashAddr, (int32_t)EEPROM_EMULATOR_PAGE_SIZE);
</#if>

    return flashAddr->header.logical_page;
}

/** \internal
 *  \brief Calculates the CRC-8 checksum for a given data buffer.
 *
 *  This function computes an 8-bit CRC value over the provided data
 *  using the polynomial defined by CRC8_POLY. The CRC is calculated
 *  byte-by-byte, where each byte is XORed with the current CRC value
 *  followed by bitwise processing for 8 iterations.
 *
 *  \param[in] data    Pointer to the input data buffer
 *  \param[in] length  Number of bytes in the input buffer
 *
 *  \return Calculated 8-bit CRC value
 */
static uint8_t crc8_calculate(uint8_t *data, uint32_t length) {
    uint8_t crc = 0x00;  // Initial value

    for (uint32_t i = 0; i < length; i++) 
    {
        crc ^= data[i];  // XOR with input byte

        for (uint8_t j = 0; j < 8; j++) 
        {
            if ((crc & 0x80U) != 0U)
            {  /* Check MSB */
                crc = (uint8_t)((uint8_t)(crc << 1U) ^ CRC8_POLY);
            } 
            else 
            {
                crc <<= 1;
            }
        }
    }
    return crc;
}

/** \internal
 *  \brief Verifies the CRC validity of a given physical EEPROM page.
 *
 *  This function reads the specified physical page from EEPROM emulator
 *  memory and calculates the CRC-8 checksum over the page data. The
 *  calculated CRC is then compared with the checksum stored in the
 *  page header to determine data integrity.
 *
 *  \param[in] physical_page  Physical page number in EEPROM emulator space
 *
 *  \return true  if the stored checksum matches the calculated CRC value
 *  \return false if the checksum validation fails
 */
static bool EMU_EEPROM_isPageCRCValid(const uint16_t physical_page)
{
    EEPROM_PAGE* page_ptr = NULL;
    page_ptr = EMU_EEPROM_PageToAddrTranslation(physical_page);
    return page_ptr->header.checksum == crc8_calculate(page_ptr->data, EEPROM_EMULATOR_PAGE_DATA_SIZE);
}

/** \internal
 *  \brief Erases a given row within the physical EEPROM memory space.
 *
 *  \param[in] row  Physical row in EEPROM space to erase
 */
static void EMU_EEPROM_NVMRowErase(const uint16_t row)
{
    uint16_t physical_page = (uint16_t)row * EEPROM_EMULATOR_PAGES_PER_ROW;
    EEPROM_PAGE* flashAddr = EMU_EEPROM_PageToAddrTranslation(physical_page);

    (void)NVM_PageErase((uint32_t)flashAddr);

    while (${EEPROM_EMULATOR_NVM_PLIB}_IsBusy())
    {
        /* Wait for operation to complete */
    }

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_InvalidateDCache_by_Addr(flashAddr, (int32_t)EEPROM_EMULATOR_ROW_SIZE);
</#if>
}

#ifdef DEBUG
// 32-bit aligned buffer for NVM_Read
uint32_t eeprom_debug_buffer[4096];  // 16384/4 = 4096 uint32_t

void print_full_row_from_nvm(uint32_t flashAddr, uint32_t row_size, uint32_t page_size)
{
    printf("\n=== Full Row Dump via NVM_Read (Size: %u bytes, Page size: %u) ===\n\r", row_size, page_size);
    
    // Read entire row using uint32_t* buffer (NVM_Read compliant)
    NVM_Read(eeprom_debug_buffer, row_size, flashAddr);
    
    uint8_t* row_data = (uint8_t*)eeprom_debug_buffer;
    
    for(uint32_t offset = 0; offset < row_size; offset += 16) {
        printf("%08X: ", (uint32_t)(flashAddr + offset));
        
        for(uint32_t i = 0; i < 16 && (offset + i) < row_size; i++) {
            printf("%02X ", row_data[offset + i]);
        }
        uint32_t bytes_this_line = (offset + 16 > row_size ? row_size - offset : 16);
        for(uint32_t i = bytes_this_line; i < 16; i++) {
            printf("   ");
        }
        
        printf(" | ");
        for(uint32_t i = 0; i < bytes_this_line; i++) {
            uint8_t ch = row_data[offset + i];
            printf("%c", (ch >= 32 && ch <= 126) ? ch : '.');
        }
        printf("\n\r");
    }
    printf("=== End Row via NVM_Read (%u bytes) ===\n\n\r", row_size);
}

void EMU_EEPROM_MemDump(void)
{
    uint16_t pg1;
    uint16_t pg2;
    uint16_t pg3;
    uint16_t pg4;
    uint16_t pg5;
    uint16_t pg6;
    uint16_t pg7;
    uint16_t pg8;    
    
    printf("\r\n-------------------------------------------------------------------------\r\n");
    
    for (uint8_t i = 0, j = 0; i<(EEPROM_EMULATOR_NUM_PHYSICAL_PAGES/EEPROM_EMULATOR_PAGES_PER_ROW); i++, j+=EEPROM_EMULATOR_PAGES_PER_ROW)
    {        
        NVM_Read((uint32_t*)&pg1, 2, (uint32_t)&eeprom_instance.main_array[j+0].header.logical_page);
        NVM_Read((uint32_t*)&pg2, 2, (uint32_t)&eeprom_instance.main_array[j+1].header.logical_page);
        NVM_Read((uint32_t*)&pg3, 2, (uint32_t)&eeprom_instance.main_array[j+2].header.logical_page);
        NVM_Read((uint32_t*)&pg4, 2, (uint32_t)&eeprom_instance.main_array[j+3].header.logical_page);        
        NVM_Read((uint32_t*)&pg5, 2, (uint32_t)&eeprom_instance.main_array[j+4].header.logical_page);
        NVM_Read((uint32_t*)&pg6, 2, (uint32_t)&eeprom_instance.main_array[j+5].header.logical_page);
        NVM_Read((uint32_t*)&pg7, 2, (uint32_t)&eeprom_instance.main_array[j+6].header.logical_page);
        NVM_Read((uint32_t*)&pg8, 2, (uint32_t)&eeprom_instance.main_array[j+7].header.logical_page);
        
        printf("| %04x | %04x | %04x | %04x | %04x | %04x | %04x | %04x |\r\n", pg1, pg2, pg3, pg4, pg5, pg6, pg7, pg8);
    }
    
    printf("\r\n-------------------------------------------------------------------------\r\n");
}
#endif

/* MISRA C-2023 Rule 11.8 deviated:1 Deviation record ID -  H3_MISRAC_2023_R_11_8_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:1 "MISRA C-2023 Rule 11.8" "H3_MISRAC_2023_R_11_8_DR_1"
</#if>
/** \internal
 *  \brief Fills the internal NVM controller page buffer in physical EEPROM memory space.
 *
 *  \param[in] physical_page  Physical page in EEPROM space to fill
 *  \param[in] data           Data to write to the physical memory page
 */
static void EMU_EEPROM_NVMBufferFill( const uint16_t physical_page, const void* const data)
{
    EEPROM_PAGE* flashAddr = EMU_EEPROM_PageToAddrTranslation(physical_page);

   (void) NVM_RowWrite((uint32_t*)data, (uint32_t)flashAddr);
    
    while (NVM_IsBusy())
    {
        /* Wait for operation to complete */
    }
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr(flashAddr, (int32_t)EEPROM_EMULATOR_PAGE_SIZE);
</#if>
}

/** \internal
 *  \brief Reads a page of data stored in physical EEPROM memory space.
 *
 *  \param[in]  physical_page  Physical page in EEPROM space to read
 *  \param[out] data           Destination buffer to fill with the read data
 */
static void EMU_EEPROM_NVMPageRead(const uint16_t physical_page, void* const data)
{
    EEPROM_PAGE* flashAddr = EMU_EEPROM_PageToAddrTranslation(physical_page);

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_InvalidateDCache_by_Addr(flashAddr, (int32_t)EEPROM_EMULATOR_PAGE_SIZE);
</#if>

    (void) ${EEPROM_EMULATOR_NVM_PLIB}_Read( (uint32_t*)data, EEPROM_EMULATOR_PAGE_SIZE, (uint32_t)flashAddr );
}

/* Make a buffer to hold the initialized EEPROM page */
static EEPROM_PAGE format_data CACHE_ALIGN;

/**
 * \brief Initializes the emulated EEPROM memory, destroying the current contents.
 */
 /* MISRA C-2023 Rule 11.3 deviated:4 Deviation record ID -  H3_MISRAC_2023_R_11_3_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance block deviate:8 "MISRA C-2023 Rule 11.3" "H3_MISRAC_2023_R_11_3_DR_1"
</#if>
static void EMU_EEPROM_MemFormat(void)
{
    uint16_t logical_page = 0;
    uint16_t physical_page = 0;

    /* Set row 0 as the spare row */
    eeprom_instance.spare_row = 0;
    EMU_EEPROM_NVMRowErase(eeprom_instance.spare_row);

    for (physical_page = EEPROM_EMULATOR_PAGES_PER_ROW; physical_page < EEPROM_EMULATOR_NUM_PHYSICAL_PAGES; physical_page++)
    {
        /* If we are at the first page in a new row, erase the entire row */
        if ((physical_page % EEPROM_EMULATOR_PAGES_PER_ROW) == 0U)
        {
            EMU_EEPROM_NVMRowErase(physical_page / EEPROM_EMULATOR_PAGES_PER_ROW);
        }

        /* EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW number of logical pages are stored in each physical row; program in a
         * pair of initialized but blank set of emulated EEPROM pages */
        if ((physical_page % EEPROM_EMULATOR_PAGES_PER_ROW) < EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW)
        {
            (void) memset(&format_data, 0xFF, sizeof(format_data));

            /* Set up the new EEPROM row's header */
            format_data.header.logical_page = logical_page;
            format_data.header.version = EEPROM_EMULATOR_VERSION;
            format_data.header.checksum = crc8_calculate(format_data.data, EEPROM_EMULATOR_PAGE_DATA_SIZE);

            /* Write the page out to physical memory */
            EMU_EEPROM_NVMBufferFill(physical_page, &format_data);

            /* Increment the logical EEPROM page address now that the current
             * address' page has been initialized */
            logical_page++;
        }
    }
}

/**
 * \brief Check if a row is a full row
 *  because the page is a invalid page, so if two pages have data,
 *  it is the full row.
 *
 *  \param[in]  phy_page  Physical page that in a row
 */
static bool EMU_EEPROM_IsFullRow(uint16_t phy_page)
{
    uint16_t c = 0;
    const EEPROM_PAGE* flashAddr;

    flashAddr = (const EEPROM_PAGE *)EMU_EEPROM_PageToAddrTranslation(phy_page);

    for (c = 0; c < EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW; c++)
    {
        if ((flashAddr[c].header.logical_page == flashAddr[EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW].header.logical_page) ||
            (flashAddr[c].header.logical_page == flashAddr[EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW + 1U].header.logical_page))
        {
            return true;
        }
    }

    return false;
}

/**
 * \brief Erase one invalid page according to two invalid physical page
 *
 *  \param[in]  pre_phy_page  One physical invalid page
 *  \param[in]  next_phy_page Another physical invalid page
 */
static void EMU_EEPROM_InvalidPageErase(uint16_t pre_phy_page, uint16_t next_phy_page)
{
    /* Keep the old/full row*/
    if(EMU_EEPROM_IsFullRow(pre_phy_page))
    {
         EMU_EEPROM_NVMRowErase(next_phy_page/EEPROM_EMULATOR_PAGES_PER_ROW);
    }
    else
    {
        EMU_EEPROM_NVMRowErase(pre_phy_page/EEPROM_EMULATOR_PAGES_PER_ROW);
    }
}

/** \internal
 *  \brief Scans and sanitizes all logical pages in the EEPROM emulator.
 *
 *  This function iterates through all physical rows in the EEPROM emulator memory
 *  and ensures the integrity and consistency of logical pages stored within each row.
 *  The sanitization process includes:
 *    - Identifying completely empty rows to mark as spare.
 *    - Detecting corrupted rows based on invalid logical page numbers, incorrect
 *      version numbers, or CRC failures, and erasing them to maintain data integrity.
 *    - Handling partially corrupted rows by relocating valid logical pages to
 *      a spare row, recalculating checksums, and erasing the faulty row.
 *
 *  The function works on the principle that each row may contain multiple logical pages
 *  (as defined by EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW) and ensures that the
 *  most recent valid versions of logical pages are preserved.
 *
 *  \note This is an internal function used by the EEPROM emulator to maintain
 *        data integrity after events like power loss or unexpected write failures.
 *
 *  \return void
 */
static void EMU_EEPROM_SanitizeLogicalPages(void)
{
    uint16_t p0 = 0;
    uint16_t p1 = 0;
    uint16_t p2 = 0;
    uint16_t p3 = 0;
    uint16_t p4 = 0;
    uint16_t p5 = 0;
    uint16_t p6 = 0;
    uint16_t p7 = 0;
    const EEPROM_PAGE *row_data = NULL;
    bool spare_row_found = false;
    uint16_t spare_row = 0;
    uint32_t new_page = 0;
    EEPROM_PAGE* page_ptr = NULL;
    
    struct
    {
        uint16_t logical_page;
        uint16_t physical_page;
    } page_trans[EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW];
      
    /* Scan through each row and sanitize each row */
    uint16_t row_num = 0U;
    for (uint16_t i = 0U; i < EEPROM_EMULATOR_NUM_PHYSICAL_PAGES; i = i + EEPROM_EMULATOR_PAGES_PER_ROW)
    {
        /* Read out the 8 physical pages stored in this row */
        p0 = EMU_EEPROM_PhysicalToLogicalPage(i);
        p1 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 1U));
        p2 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 2U));
        p3 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 3U));
        p4 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 4U));
        p5 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 5U));
        p6 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 6U));
        p7 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 7U));

        page_ptr = EMU_EEPROM_PageToAddrTranslation(i);

        if ((p0 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) && (p1 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) && \
                (p2 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) && (p3 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&\
                (p4 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) && (p5 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&\
                (p6 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) && (p7 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER))
        {
            spare_row_found = true;
            spare_row = row_num;
            row_num++;
            continue;
        }

        if ((p0 >= EEPROM_EMULATOR_NUM_LOGICAL_PAGES) || (p1 >= EEPROM_EMULATOR_NUM_LOGICAL_PAGES) || (p2 >= EEPROM_EMULATOR_NUM_LOGICAL_PAGES) || (p3 >= EEPROM_EMULATOR_NUM_LOGICAL_PAGES) ||\
                (p1 != (p0 + 1)) || (p2 != (p1 + 1)) || (p3 != (p2 + 1)) ||\
                (page_ptr[0].header.version != EEPROM_EMULATOR_VERSION) || \
                (page_ptr[1].header.version != EEPROM_EMULATOR_VERSION) || \
                (page_ptr[2].header.version != EEPROM_EMULATOR_VERSION) || \
                (page_ptr[3].header.version != EEPROM_EMULATOR_VERSION) || \
                (EMU_EEPROM_isPageCRCValid(i) == false) || \
                (EMU_EEPROM_isPageCRCValid((uint16_t)(i + 1U)) == false) )
        {
            /* If in a row, p0 or p1 is having incorrect value (value not in range of 0 to max logical page number), then erase that row.
             * This can happen only when a row is full and data is being copied to the spare row, and during copy the power goes off.
             * When this happens, the full row should still be intact and hence it should be safe to erase the row with corrupted p0 or p1.*/
            EMU_EEPROM_NVMRowErase(row_num);
            spare_row_found = true;
            spare_row = row_num;
        }
        row_num++;
    }

    row_num = 0U;
    for (uint16_t i = 0U; i < EEPROM_EMULATOR_NUM_PHYSICAL_PAGES; i = i + EEPROM_EMULATOR_PAGES_PER_ROW)
    {
        /* Read out the all physical pages stored in this row */
        p0 = EMU_EEPROM_PhysicalToLogicalPage(i);
        p1 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 1U));
        p2 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 2U));
        p3 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 3U));
        p4 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 4U));
        p5 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 5U));
        p6 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 6U));
        p7 = EMU_EEPROM_PhysicalToLogicalPage((uint16_t)(i + 7U));

        page_ptr = EMU_EEPROM_PageToAddrTranslation(i);

        if ((p0 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&
            (p1 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&
            (p2 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&
            (p3 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&
            (p4 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&
            (p5 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&
            (p6 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&
            (p7 == EEPROM_EMULATOR_INVALID_PAGE_NUMBER))
        {
            row_num++;
            continue;
        }

        if ((spare_row_found == true) &&
            (
                /* p4 */
                ((p4 != EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&
                 (((p4 != p0) && (p4 != p1) && (p4 != p2) && (p4 != p3)) ||
                  (EMU_EEPROM_isPageCRCValid((uint16_t)(i + 4U)) == false))) ||

                /* p5 */
                ((p5 != EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&
                 (((p5 != p0) && (p5 != p1) && (p5 != p2) && (p5 != p3)) ||
                  (EMU_EEPROM_isPageCRCValid((uint16_t)(i + 5U)) == false))) ||

                /* p6 */
                ((p6 != EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&
                 (((p6 != p0) && (p6 != p1) && (p6 != p2) && (p6 != p3)) ||
                  (EMU_EEPROM_isPageCRCValid((uint16_t)(i + 6U)) == false))) ||

                /* p7 */
                ((p7 != EEPROM_EMULATOR_INVALID_PAGE_NUMBER) &&
                 (((p7 != p0) && (p7 != p1) && (p7 != p2) && (p7 != p3)) ||
                  (EMU_EEPROM_isPageCRCValid((uint16_t)(i + 7U)) == false)))
            ))
        {
            /* If the first EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW pages have correct logical page values (value in range of 0 to max logical page number),
             * but later pages in the row contain value different than previous pages of the row
             * then discard the incorrect pages.
             * To do this, take backup (in RAM) of the most recent logical pages in this row.
             * Then find a spare row and copy the backup data in the spare row.
             * Once done, erase the faulty (this) row.
             */
            row_data = (const EEPROM_PAGE *)EMU_EEPROM_PageToAddrTranslation(i);
            /* There should be four logical pages of data in each row, possibly with
             * multiple revisions (right-most version is the newest). Start by assuming
             * the left-most four pages contain the newest page revisions. */

            for (uint32_t m = 0; m < EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW; m++)
            {
                page_trans[m].logical_page  = row_data[m].header.logical_page;
                page_trans[m].physical_page = (uint16_t)(i + m);
            }

            /* Look for newer revisions of the four logical pages stored in the row */
            for (uint32_t m = 0; m < EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW; m++)
            {
                /* Look through the remaining pages in the row for any newer revisions */
                for (uint32_t n = EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW; n < EEPROM_EMULATOR_PAGES_PER_ROW; n++)
                {
                    if (page_trans[m].logical_page == row_data[n].header.logical_page)
                    {
                        page_trans[m].physical_page = (uint16_t)(i + n);
                    }
                }
            }
            /* Spare row is already available (no need to find it). Now, need to move four saved logical pages stored in the same row */
            for (uint16_t c = 0; c < EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW; c++)
            {
                /* Find the physical page index for the new spare row pages */
                new_page = (((uint32_t)spare_row * (uint32_t)EEPROM_EMULATOR_PAGES_PER_ROW) + (uint32_t)c);

                /* Copy existing EEPROM page to cache buffer wholesale */
                EMU_EEPROM_NVMPageRead(page_trans[c].physical_page, &eeprom_instance.cache);

                /* Copy the version number */
                eeprom_instance.cache.header.version = EEPROM_EMULATOR_VERSION;
                eeprom_instance.cache.header.checksum = crc8_calculate(eeprom_instance.cache.data, EEPROM_EMULATOR_PAGE_DATA_SIZE);

                /* Write the cached logical page to the physical memory pointed by new_page */

                EMU_EEPROM_NVMBufferFill((uint16_t)new_page, &eeprom_instance.cache);

                //EMU_EEPROM_NVMBufferCommit(new_page);
            }

            /* Now erase the faulty row */
            EMU_EEPROM_NVMRowErase(row_num);

            /* Set this as the new spare row */
            spare_row = row_num;
        }
        row_num++;
    }        
}

/**
 * \brief Check if there exist rows with same logical pages due to power drop
 *  when writing or erasing page.
 *  when existed same logical page, the old(full) row will be erased.
 */
static void EMU_EEPROM_CheckLogicalPage(void)
{
    uint16_t i = 0;
    uint16_t j = 0;
    uint16_t pre_logical_page = 0;
    uint16_t next_logical_page = 0;

    for (i = 0; i < EEPROM_EMULATOR_NUM_PHYSICAL_PAGES; i=i+EEPROM_EMULATOR_PAGES_PER_ROW)
    {
        pre_logical_page = EMU_EEPROM_PhysicalToLogicalPage(i);

        if( pre_logical_page == EEPROM_EMULATOR_INVALID_PAGE_NUMBER)
        {
            continue;
        }

        for (j = EEPROM_EMULATOR_PAGES_PER_ROW+i; j < EEPROM_EMULATOR_NUM_PHYSICAL_PAGES; j=j+EEPROM_EMULATOR_PAGES_PER_ROW)
        {
            next_logical_page = EMU_EEPROM_PhysicalToLogicalPage(j);

            if( next_logical_page == EEPROM_EMULATOR_INVALID_PAGE_NUMBER)
            {
                continue;
            }

            if(pre_logical_page == next_logical_page)
            {
                /* Found invalid logical page and erase it */
                EMU_EEPROM_InvalidPageErase(i,j);
            }
        }
    }
}


/**
 * \brief Creates a map in SRAM to translate logical EEPROM pages to physical FLASH pages.
 */
static void EMU_EEPROM_PageMappingUpdate(void)
{
    uint16_t logical_page = 0;
    uint16_t physical_page = 0;
    uint16_t c = 0;
    bool spare_row_found = true;

    /* Check if exists invalid logical page */
    EMU_EEPROM_CheckLogicalPage();

    /* Scan through all physical pages, to map physical and logical pages */
    for (c = 0; c < EEPROM_EMULATOR_NUM_PHYSICAL_PAGES; c++)
    {
        /* Read in the logical page stored in the current physical page */
        logical_page = EMU_EEPROM_PhysicalToLogicalPage(c);

        /* If the logical page number is valid, add it to the mapping */
        if ((logical_page != EEPROM_EMULATOR_INVALID_PAGE_NUMBER) && (logical_page < EEPROM_EMULATOR_NUM_LOGICAL_PAGES))
        {
            eeprom_instance.page_map[logical_page] = (uint8_t)c;
        }
    }

    /* Use an invalid page number as the spare row until a valid one has been found */
    eeprom_instance.spare_row = EEPROM_EMULATOR_INVALID_ROW_NUMBER;

    /* Scan through all physical rows, to find an erased row to use as the spare */
    for (c = 0; c < (EEPROM_EMULATOR_NUM_PHYSICAL_PAGES / EEPROM_EMULATOR_PAGES_PER_ROW); c++)
    {
        spare_row_found = true;

        /* Look through pages within the row to see if they are all erased */
        for (uint16_t c2 = 0; c2 < EEPROM_EMULATOR_PAGES_PER_ROW; c2++)
        {
            physical_page = (c * EEPROM_EMULATOR_PAGES_PER_ROW) + c2;
            logical_page = EMU_EEPROM_PhysicalToLogicalPage(physical_page);

            if (logical_page != EEPROM_EMULATOR_INVALID_PAGE_NUMBER)
            {
                spare_row_found = false;
            }
        }

        /* If we've now found the spare row, store it and abort the search */
        if (spare_row_found == true)
        {
            eeprom_instance.spare_row = c;
            break;
        }
    }
}

/**
 * \brief Finds the next free page in the given row if one is available.
 *
 * \param[in]  start_physical_page  Physical FLASH page index of the row to
 *                                  search
 * \param[out] free_physical_page   Index of the physical FLASH page that is
 *                                  currently free (if one was found)
 *
 * \return Whether a free page was found in the specified row.
 *
 * \retval \c true   If a free page was found
 * \retval \c false  If the specified row was full and needs an erase
 */
static bool EMU_EEPROM_IsPageFreeOnRow( const uint16_t start_physical_page, uint16_t *const free_physical_page)
{
    /* Convert physical page number to a FLASH row and page within the row */
    uint16_t row         = (start_physical_page / EEPROM_EMULATOR_PAGES_PER_ROW);
    uint16_t page_in_row = (start_physical_page % EEPROM_EMULATOR_PAGES_PER_ROW);
    uint16_t page = 0;

    /* Look in the current row for a page that isn't currently used */
    for (uint16_t c = page_in_row; c < EEPROM_EMULATOR_PAGES_PER_ROW; c++)
    {
        /* Calculate the page number for the current page being examined */
        page = (row * EEPROM_EMULATOR_PAGES_PER_ROW) + c;

        /* If the page is free, pass it to the caller and exit */
        if (EMU_EEPROM_PhysicalToLogicalPage(page) == EEPROM_EMULATOR_INVALID_PAGE_NUMBER)
        {
            *free_physical_page = page;
            return true;
        }
    }

    /* No free page in the current row was found */
    return false;
}

/**
 * \brief Moves data from the specified logical page to the spare row.
 *
 * Moves the contents of the specified row into the spare row, so that the
 * original row can be erased and re-used. The contents of the given logical
 * page is replaced with a new buffer of data.
 *
 * \param[in] row_number    Physical row to examine
 * \param[in] logical_page  Logical EEPROM page number in the row to update
 * \param[in] data          New data to replace the old in the logical page
 *
 * \return Status code indicating the status of the operation.
 */
static void EMU_EEPROM_MoveDataToSpare( const uint16_t row_number, const uint16_t logical_page, const uint8_t *const data )
{
    uint8_t c = 0;
    uint8_t c2 = 0;
    uint32_t new_page = 0;
    const EEPROM_PAGE *row_data = NULL;

    struct
    {
        uint16_t logical_page;
        uint16_t physical_page;
    } page_trans[EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW];

    row_data = (const EEPROM_PAGE *)EMU_EEPROM_PageToAddrTranslation(row_number * EEPROM_EMULATOR_PAGES_PER_ROW);

    /* There should be two logical pages of data in each row, possibly with
     * multiple revisions (right-most version is the newest). Start by assuming
     * the left-most two pages contain the newest page revisions. */

    for (c = 0; c < EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW; c++)
    {
        page_trans[c].logical_page  = row_data[c].header.logical_page;
        page_trans[c].physical_page = (row_number * EEPROM_EMULATOR_PAGES_PER_ROW) + c;
    }

    /* Look for newer revisions of the two logical pages stored in the row */
    for (c = 0; c < EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW; c++)
    {
        /* Look through the remaining pages in the row for any newer revisions */
        for (c2 = EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW; c2 < EEPROM_EMULATOR_PAGES_PER_ROW; c2++)
        {
            if (page_trans[c].logical_page == row_data[c2].header.logical_page)
            {
                page_trans[c].physical_page = (row_number * EEPROM_EMULATOR_PAGES_PER_ROW) + c2;
            }
        }
    }

    /* Need to move both saved logical pages stored in the same row */
    for (c = 0; c < EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW; c++)
    {
        /* Find the physical page index for the new spare row pages */
        new_page = (((uint32_t)eeprom_instance.spare_row * (uint32_t)EEPROM_EMULATOR_PAGES_PER_ROW) + (uint32_t)c);

        /* Check if we we are looking at the page the calling function wishes
         * to change during the move operation */
        if (logical_page == page_trans[c].logical_page)
        {
            /* Fill out new (updated) logical page's header in the cache */
            eeprom_instance.cache.header.logical_page = logical_page;

            /* Write data to SRAM cache */
            (void) memcpy(eeprom_instance.cache.data, data, EEPROM_EMULATOR_PAGE_DATA_SIZE);
        }
        else
        {
            /* Copy existing EEPROM page to cache buffer wholesale */
            EMU_EEPROM_NVMPageRead(page_trans[c].physical_page, &eeprom_instance.cache);
        }

        /* Copy the version string if the physical page are first two pages of the row */
        eeprom_instance.cache.header.version = EEPROM_EMULATOR_VERSION;
        eeprom_instance.cache.header.checksum = crc8_calculate(eeprom_instance.cache.data, EEPROM_EMULATOR_PAGE_DATA_SIZE);

        /* Fill the physical NVM buffer with the new data so that it can be
         * quickly committed in the future if needed due to a low power
         * condition */

        EMU_EEPROM_NVMBufferFill((uint16_t)new_page, &eeprom_instance.cache);

        /* Update the page map with the new page location and indicate that
         * the cache now holds new data */

        eeprom_instance.page_map[page_trans[c].logical_page] = (uint8_t)new_page;

    }

    /* Erase the row that was moved and set it as the new spare row */
    EMU_EEPROM_NVMRowErase(row_number);

    /* Keep the index of the new spare row */
    eeprom_instance.spare_row = row_number;
    return ;
}

static EMU_EEPROM_STATUS EMU_EEPROM_PageDataRead( const uint16_t logical_page, uint8_t *const data)
{
    EEPROM_PAGE temp;

    /* Ensure the emulated EEPROM has been initialized first */
    if (eeprom_instance.initialized == false)
    {
        return EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED;
    }

    /* Make sure the read address is within the allowable address space */
    if (logical_page >= EEPROM_EMULATOR_NUM_LOGICAL_PAGES)
    {
        return EMU_EEPROM_STATUS_ERR_BAD_ADDRESS;
    }

    /* Check if the page to read is currently cached (and potentially out of
     * sync/newer than the physical memory) */
    if ((eeprom_instance.cache.header.logical_page == logical_page))
    {
        /* Copy the potentially newer cached data into the user buffer */
        (void) memcpy(data, eeprom_instance.cache.data, EEPROM_EMULATOR_PAGE_DATA_SIZE);
    }
    else
    {
        /* Copy the data from non-volatile memory into the temporary buffer */
        EMU_EEPROM_NVMPageRead(eeprom_instance.page_map[logical_page], &temp);

        /* Copy the data portion of the read page to the user's buffer */
        (void) memcpy(data, temp.data, EEPROM_EMULATOR_PAGE_DATA_SIZE);
    }

    return EMU_EEPROM_STATUS_OK;
}

static EMU_EEPROM_STATUS EMU_EEPROM_PageDataWrite( const uint16_t logical_page, const uint8_t* const data)
{
    uint16_t new_page = 0;
    bool page_spare = false;

    /* Ensure the emulated EEPROM has been initialized first */
    if (eeprom_instance.initialized == false)
    {
        return EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED;
    }

    /* Make sure the write address is within the allowable address space */
    if (logical_page >= EEPROM_EMULATOR_NUM_LOGICAL_PAGES)
    {
        return EMU_EEPROM_STATUS_ERR_BAD_ADDRESS;
    }

    /* Check if we have space in the current page location's physical row for
     * a new version, and if so get the new page index */

    page_spare  = EMU_EEPROM_IsPageFreeOnRow(eeprom_instance.page_map[logical_page], &new_page);

    /* Check if the current row is full, and we need to swap it out with a
     * spare row */
    if (page_spare == false)
    {
        /* Move the other page we aren't writing that is stored in the same
         * page to the new row, and replace the old current page with the
         * new page contents (cache is updated to match) */
        (void) EMU_EEPROM_MoveDataToSpare(
                (uint16_t)eeprom_instance.page_map[logical_page] / EEPROM_EMULATOR_PAGES_PER_ROW,
                logical_page,
                data);

        /* New data is now written and the cache is updated, exit */
        return EMU_EEPROM_STATUS_OK;
    }

    /* Update the page cache header section with the new page header */
    eeprom_instance.cache.header.logical_page = logical_page;

    /* Copy the version number */
    eeprom_instance.cache.header.version = EEPROM_EMULATOR_VERSION;        
       
    eeprom_instance.cache.header.checksum = crc8_calculate(eeprom_instance.cache.data, EEPROM_EMULATOR_PAGE_DATA_SIZE);

    /* Update the page cache contents with the new data */
   (void) memcpy(&eeprom_instance.cache.data,
            data,
            EEPROM_EMULATOR_PAGE_DATA_SIZE);

    /* Fill the physical NVM buffer with the new data so that it can be quickly
     * committed in the future if needed due to a low power condition */
    EMU_EEPROM_NVMBufferFill(new_page, &eeprom_instance.cache);

    /* Update the cache parameters and mark the cache as active */
    eeprom_instance.page_map[logical_page] = (uint8_t)new_page;

    return EMU_EEPROM_STATUS_OK;
}

static bool EMU_EEPROM_IsValidVersionStrExists(void)
{
    uint16_t physical_page = 0;
    EEPROM_PAGE* page_ptr = NULL;
    bool isVerStringValid = false;

    /* Check for a valid version string. A 4 byte version string is stored in first two pages of each row. First two bytes of version string
     * are stored in first page of the row and the remaining two bytes are stored in the second page of the same row */

    for (physical_page = 0; physical_page < EEPROM_EMULATOR_NUM_PHYSICAL_PAGES; physical_page++)
    {        
        page_ptr = EMU_EEPROM_PageToAddrTranslation(physical_page);
        
        /* If the logical page number is valid, check for version string */
        if (page_ptr->header.logical_page < EEPROM_EMULATOR_NUM_LOGICAL_PAGES)
        {
            if (page_ptr->header.version == EEPROM_EMULATOR_VERSION)
            {
                isVerStringValid = true;
                break;
            }
        }
    }

    return isVerStringValid;
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2023 Rule 11.3"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */

/**
 * \brief Initializes the EEPROM Emulator service.
 *
 * Initializes the emulated EEPROM memory space; if the emulated EEPROM memory
 * has not been previously initialized, it will need to be explicitly formatted
 * via \ref EMU_EEPROM_EraseMemory(). The EEPROM memory space will \b not
 * be automatically erased by the initialization function, so that partial data
 * may be recovered by the user application manually if the service is unable to
 * initialize successfully.
 *
 * \return Status code indicating the status of the operation.
 *
 * \retval EMU_EEPROM_STATUS_OK              EEPROM emulation service was successfully
 *                                initialized
 * \retval EMU_EEPROM_STATUS_ERR_NO_MEMORY   No EEPROM section has been allocated in the
 *                                device
 * \retval EMU_EEPROM_STATUS_ERR_BAD_FORMAT  Emulated EEPROM memory is corrupt or not
 *                                formatted or is incompatible with this version or scheme of the EEPROM emulator
 */

SYS_MODULE_OBJ EMU_EEPROM_Initialize(const SYS_MODULE_INDEX drvIndex, const SYS_MODULE_INIT* const init)
{
    /* Ensure the device fuses are configured for at least
     * one user EEPROM data row and one spare row */

    eeprom_instance.status = EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED;

    /* Create mutex */
    if(OSAL_MUTEX_Create(&eeprom_instance.EmulatedEEPROMAccessLock) != OSAL_RESULT_SUCCESS)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    /* Configure the EEPROM instance starting physical address in FLASH and
     * pre-compute the index of the first page in FLASH used for EEPROM */

<#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED?? && EEPROM_EMULATOR_RWWEE_ENABLED??>
    <#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED == true>
    <#lt>   eeprom_instance.main_array = (EEPROM_PAGE*)EEPROM_EMULATOR_MAIN_ARRAY_EEPROM_START_ADDRESS;
    </#if>

    <#if EEPROM_EMULATOR_RWWEE_ENABLED == true>
    <#lt>   eeprom_instance.rwwee = (EEPROM_PAGE*)EEPROM_EMULATOR_RWWEE_START_ADDRESS;
    </#if>
<#else>
    eeprom_instance.main_array = (EEPROM_PAGE*)EEPROM_EMULATOR_EEPROM_START_ADDRESS;
</#if>


    EMU_EEPROM_SanitizeLogicalPages();

    /* Scan physical memory and re-create logical to physical page mapping
     * table to locate logical pages of EEPROM data in physical FLASH */
    EMU_EEPROM_PageMappingUpdate();

    /* Could not find spare row - abort as the memory appears to be corrupt */
    if (eeprom_instance.spare_row == EEPROM_EMULATOR_INVALID_ROW_NUMBER)
    {
        eeprom_instance.status = EMU_EEPROM_STATUS_ERR_BAD_FORMAT;

        return SYS_MODULE_OBJ_INVALID;
    }

    if (EMU_EEPROM_IsValidVersionStrExists() == true)
    {
        eeprom_instance.status = EMU_EEPROM_STATUS_OK;

        /* Mark initialization as complete */
        eeprom_instance.initialized = true;
    }
    else
    {
        eeprom_instance.status = EMU_EEPROM_STATUS_ERR_BAD_FORMAT;

        return SYS_MODULE_OBJ_INVALID;
    }

    return ( (SYS_MODULE_OBJ)drvIndex );
}

EMU_EEPROM_STATUS EMU_EEPROM_StatusGet( void )
{
    return eeprom_instance.status;
}


/**
 * \brief Retrieves the parameters of the EEPROM Emulator memory layout.
 *
 * Retrieves the configuration parameters of the EEPROM Emulator, after it has
 * been initialized.
 *
 * \param[out] parameters  EEPROM Emulator parameter struct to fill
 *
 * \return Status of the operation.
 *
 * \retval EMU_EEPROM_STATUS_OK                    If the emulator parameters were retrieved
 *                                      successfully
 * \retval EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED   If the EEPROM Emulator is not initialized
 */
EMU_EEPROM_STATUS EMU_EEPROM_ParametersGet( EMU_EEPROM_PARAMETERS *const parameters)
{
    if (eeprom_instance.initialized == false)
    {
        return EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED;
    }

    parameters->page_size                   = EEPROM_EMULATOR_PAGE_DATA_SIZE;
    parameters->eeprom_num_logical_pages    = EEPROM_EMULATOR_NUM_LOGICAL_PAGES;
    parameters->eeprom_logical_size         = EEPROM_EMULATOR_LOGICAL_SIZE_BYTES;

    return EMU_EEPROM_STATUS_OK;
}

/**
 * \brief Erases the entire emulated EEPROM memory space.
 *
 * Erases and re-initializes the emulated EEPROM memory space, destroying any
 * existing data.
 */
bool EMU_EEPROM_FormatMemory(void)
{
    bool isSuccess = false;

    /* Guard against multiple threads trying access the EEPROM memory */
    if(OSAL_MUTEX_Lock(&eeprom_instance.EmulatedEEPROMAccessLock, OSAL_WAIT_FOREVER) == OSAL_RESULT_FAIL)
    {
        return isSuccess;
    }

    eeprom_instance.status = EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED;

    eeprom_instance.initialized = false;

    /* Create new EEPROM memory block in EEPROM emulation section */
    EMU_EEPROM_MemFormat();


    /* Scan physical memory and re-create logical to physical page mapping
     * table to locate logical pages of EEPROM data in physical FLASH */
    EMU_EEPROM_PageMappingUpdate();

    /* Could not find spare row - abort as the memory appears to be corrupt */
    if (eeprom_instance.spare_row != EEPROM_EMULATOR_INVALID_ROW_NUMBER)
    {
        if (EMU_EEPROM_IsValidVersionStrExists() == true)
        {
            eeprom_instance.status = EMU_EEPROM_STATUS_OK;

            /* Mark initialization as complete */
            eeprom_instance.initialized = true;

            isSuccess = true;
        }
        else
        {
            eeprom_instance.status = EMU_EEPROM_STATUS_ERR_BAD_FORMAT;
        }
    }
    else
    {
        eeprom_instance.status = EMU_EEPROM_STATUS_ERR_BAD_FORMAT;
    }

    /* Release the mutex */
    (void) OSAL_MUTEX_Unlock(&eeprom_instance.EmulatedEEPROMAccessLock);

    return isSuccess;
}

/**
 * \brief Writes a page of data to an emulated EEPROM memory page.
 *
 * Writes an emulated EEPROM page of data to the emulated EEPROM memory space.
 *
 *
 * \param[in] logical_page  Logical EEPROM page number to write to
 * \param[in] data          Pointer to the data buffer containing source data to
 *                          write
 *
 * \return Status code indicating the status of the operation.
 *
 * \retval EMU_EEPROM_STATUS_OK                    If the page was successfully read
 * \retval EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED   If the EEPROM emulator is not initialized
 * \retval EMU_EEPROM_STATUS_ERR_BAD_ADDRESS       If an address outside the valid emulated
 *                                      EEPROM memory space was supplied
 */
EMU_EEPROM_STATUS EMU_EEPROM_PageWrite( const uint16_t logical_page, const uint8_t* const data)
{
    EMU_EEPROM_STATUS error_code = EMU_EEPROM_STATUS_OK;

    /* Guard against multiple threads trying access the EEPROM memory */
    if(OSAL_MUTEX_Lock(&eeprom_instance.EmulatedEEPROMAccessLock, OSAL_WAIT_FOREVER) == OSAL_RESULT_FAIL)
    {
        return EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED;
    }

    error_code = EMU_EEPROM_PageDataWrite(logical_page, data);

    /* Release the mutex */
   (void) OSAL_MUTEX_Unlock(&eeprom_instance.EmulatedEEPROMAccessLock);

    return error_code;
}

/**
 * \brief Reads a page of data from an emulated EEPROM memory page.
 *
 * Reads an emulated EEPROM page of data from the emulated EEPROM memory space.
 *
 * \param[in]  logical_page  Logical EEPROM page number to read from
 * \param[out] data          Pointer to the destination data buffer to fill
 *
 * \return Status code indicating the status of the operation.
 *
 * \retval EMU_EEPROM_STATUS_OK                    If the page was successfully read
 * \retval EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED   If the EEPROM emulator is not initialized
 * \retval EMU_EEPROM_STATUS_ERR_BAD_ADDRESS       If an address outside the valid emulated
 *                                      EEPROM memory space was supplied
 */
EMU_EEPROM_STATUS EMU_EEPROM_PageRead( const uint16_t logical_page, uint8_t *const data)
{
    EMU_EEPROM_STATUS error_code = EMU_EEPROM_STATUS_OK;

    /* Guard against multiple threads trying access the EEPROM memory */
    if(OSAL_MUTEX_Lock(&eeprom_instance.EmulatedEEPROMAccessLock, OSAL_WAIT_FOREVER) == OSAL_RESULT_FAIL)
    {
        return EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED;
    }

    error_code = EMU_EEPROM_PageDataRead(logical_page, data);

    /* Release the mutex */
   (void) OSAL_MUTEX_Unlock(&eeprom_instance.EmulatedEEPROMAccessLock);

    return error_code;
}

/**
 * \brief Writes a buffer of data to the emulated EEPROM memory space.
 *
 * Writes a buffer of data to a section of emulated EEPROM memory space. The
 * source buffer may be of any size, and the destination may lie outside of an
 * emulated EEPROM page boundary.
 *
 *
 * \param[in] offset  Starting byte offset to write to, in emulated EEPROM
 *                    memory space
 * \param[in] data    Pointer to the data buffer containing source data to write
 * \param[in] length  Length of the data to write, in bytes
 *
 * \return Status code indicating the status of the operation.
 *
 * \retval EMU_EEPROM_STATUS_OK                    If the page was successfully read
 * \retval EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED   If the EEPROM emulator is not initialized
 * \retval EMU_EEPROM_STATUS_ERR_BAD_ADDRESS       If an address outside the valid emulated
 *                                      EEPROM memory space was supplied
 */

EMU_EEPROM_STATUS EMU_EEPROM_BufferWrite( const uint16_t offset, const uint8_t *const data, const uint16_t length)
{
    EMU_EEPROM_STATUS error_code = EMU_EEPROM_STATUS_OK;
    uint16_t logical_page = offset / EEPROM_EMULATOR_PAGE_DATA_SIZE;
    uint16_t c = offset;

    /* Keep track of whether the currently updated page has been written */
    bool page_dirty = false;

    /* Guard against multiple threads trying access the EEPROM memory */
    if(OSAL_MUTEX_Lock(&eeprom_instance.EmulatedEEPROMAccessLock, OSAL_WAIT_FOREVER) == OSAL_RESULT_FAIL)
    {
        return EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED;
    }

    /** Perform the initial page read if necessary*/
    if (((offset % EEPROM_EMULATOR_PAGE_DATA_SIZE) != 0U) || (length < EEPROM_EMULATOR_PAGE_DATA_SIZE))
    {
        error_code = EMU_EEPROM_PageDataRead(logical_page, buffer_write);

        if (error_code != EMU_EEPROM_STATUS_OK)
        {
            /* Release the mutex */
           (void) OSAL_MUTEX_Unlock(&eeprom_instance.EmulatedEEPROMAccessLock);

            return error_code;
        }
    }

    /* To avoid entering into the initial if in the loop the first time */
    if ((offset % EEPROM_EMULATOR_PAGE_DATA_SIZE) == 0U)
    {
        buffer_write[c % EEPROM_EMULATOR_PAGE_DATA_SIZE] = data[c - offset];
        page_dirty = true;
        c=c+1U;
    }

    /* Write the specified data to the emulated EEPROM memory space */
    for (; c < (length + offset); c++)
    {
        /* Check if we have written up to a new EEPROM page boundary */
        if ((c % EEPROM_EMULATOR_PAGE_DATA_SIZE) == 0U)
        {
            /* Write the current page to non-volatile memory from the temporary buffer */
            error_code = EMU_EEPROM_PageDataWrite(logical_page, buffer_write);
            page_dirty = false;

            if (error_code != EMU_EEPROM_STATUS_OK)
            {
                break;
            }

            /* Increment the page number we are looking at */
            logical_page++;

            /* Read the next page from non-volatile memory into the temporary
             * buffer in case of a partial page write */
            error_code = EMU_EEPROM_PageDataRead(logical_page, buffer_write);

            if (error_code != EMU_EEPROM_STATUS_OK)
            {
                /* Release the mutex */
                (void) OSAL_MUTEX_Unlock(&eeprom_instance.EmulatedEEPROMAccessLock);

                return error_code;
            }
        }
        /* Copy the next byte of data from the user's buffer to the temporary buffer */
        buffer_write[c % EEPROM_EMULATOR_PAGE_DATA_SIZE] = data[c - offset];
        page_dirty = true;
    }

    /* If the current page is dirty, write it */
    if (page_dirty)
    {
        error_code = EMU_EEPROM_PageDataWrite(logical_page, buffer_write);
    }

    /* Release the mutex */
    (void) OSAL_MUTEX_Unlock(&eeprom_instance.EmulatedEEPROMAccessLock);

    return error_code;
}

/**
 * \brief Reads a buffer of data from the emulated EEPROM memory space.
 *
 * Reads a buffer of data from a section of emulated EEPROM memory space. The
 * destination buffer may be of any size, and the source may lie outside of an
 * emulated EEPROM page boundary.
 *
 * \param[in]  offset  Starting byte offset to read from, in emulated EEPROM
 *                     memory space
 * \param[out] data    Pointer to the data buffer containing source data to read
 * \param[in]  length  Length of the data to read, in bytes
 *
 * \return Status code indicating the status of the operation.
 *
 * \retval EMU_EEPROM_STATUS_OK                    If the page was successfully read
 * \retval EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED   If the EEPROM emulator is not initialized
 * \retval EMU_EEPROM_STATUS_ERR_BAD_ADDRESS       If an address outside the valid emulated
 *                                      EEPROM memory space was supplied
 */
EMU_EEPROM_STATUS EMU_EEPROM_BufferRead( const uint16_t offset, uint8_t *const data, const uint16_t length)
{
    EMU_EEPROM_STATUS error_code;
    uint8_t buffer[EEPROM_EMULATOR_PAGE_DATA_SIZE];
    uint16_t logical_page = offset / EEPROM_EMULATOR_PAGE_DATA_SIZE;
    uint16_t c = offset;

    /* Guard against multiple threads trying access the EEPROM memory */
    if(OSAL_MUTEX_Lock(&eeprom_instance.EmulatedEEPROMAccessLock, OSAL_WAIT_FOREVER) == OSAL_RESULT_FAIL)
    {
        return EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED;
    }

    /** Perform the initial page read  */
    error_code = EMU_EEPROM_PageDataRead(logical_page, buffer);

    if (error_code != EMU_EEPROM_STATUS_OK)
    {
        /* Release the mutex */
        (void) OSAL_MUTEX_Unlock(&eeprom_instance.EmulatedEEPROMAccessLock);

        return error_code;
    }

    /* To avoid entering into the initial if in the loop the first time */
    if ((offset % EEPROM_EMULATOR_PAGE_DATA_SIZE) == 0U)
    {
        data[0] = buffer[0];
        c=c+1U;
    }

    /* Read in the specified data from the emulated EEPROM memory space */
    for (; c < (length + offset); c++)
    {
        /* Check if we have read up to a new EEPROM page boundary */
        if ((c % EEPROM_EMULATOR_PAGE_DATA_SIZE) == 0U)
        {
            /* Increment the page number we are looking at */
            logical_page++;

            /* Read the next page from non-volatile memory into the temporary buffer */
            error_code = EMU_EEPROM_PageDataRead(logical_page, buffer);

            if (error_code != EMU_EEPROM_STATUS_OK)
            {
                /* Release the mutex */
               (void) OSAL_MUTEX_Unlock(&eeprom_instance.EmulatedEEPROMAccessLock);

                return error_code;
            }
        }

        /* Copy the next byte of data from the temporary buffer to the user's buffer */
        data[c - offset] = buffer[c % EEPROM_EMULATOR_PAGE_DATA_SIZE];
    }

    /* Release the mutex */
    (void) OSAL_MUTEX_Unlock(&eeprom_instance.EmulatedEEPROMAccessLock);

    return error_code;
}
