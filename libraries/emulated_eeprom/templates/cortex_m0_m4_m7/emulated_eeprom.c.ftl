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

#include <string.h>
#include "system/system_module.h"
<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
#include "system/cache/sys_cache.h"
</#if>
#include "emulated_eeprom_local.h"
#include "peripheral/${EEPROM_EMULATOR_NVM_PLIB?lower_case}/plib_${EEPROM_EMULATOR_NVM_PLIB?lower_case}.h"
#include "emulated_eeprom.h"

#define EEPROM_EMULATOR_VERSION_STR             "EMv1"

/**
 * \internal
 * \brief Internal EEPROM emulator instance.
 */
static EEPROM_MODULE  eeprom_instance =
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
    const EEPROM_PAGE* flashAddr = NULL;

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
    SYS_CACHE_InvalidateDCache_by_Addr((uint32_t *)flashAddr, EEPROM_EMULATOR_PAGE_SIZE);
</#if>

    return flashAddr->header.logical_page;
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

<#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED?? && EEPROM_EMULATOR_RWWEE_ENABLED??>
    <#if EEPROM_EMULATOR_MAIN_ARRAY_ENABLED == true && EEPROM_EMULATOR_RWWEE_ENABLED == true && core.CoreArchitecture != "CORTEX-M23">
        <#lt>   if (physical_page >= EEPROM_EMULATOR_NUM_MAIN_ARRAY_PHY_PAGES)
        <#lt>   {
        <#if EEPROM_EMULATOR_RWWEE_MEM_NAME == "RWWEE">
            <#lt>   (void) ${EEPROM_EMULATOR_NVM_PLIB}_RWWEEPROM_RowErase((uint32_t)flashAddr);
        <#elseif EEPROM_EMULATOR_RWWEE_MEM_NAME == "Data Flash">
            <#lt>   (void) ${EEPROM_EMULATOR_NVM_PLIB}_DATA_FLASH_RowErase((uint32_t)flashAddr);
        </#if>
        <#lt>   }
        <#lt>   else
        <#lt>   {
        <#lt>       (void) ${EEPROM_EMULATOR_NVM_PLIB}_RowErase((uint32_t)flashAddr);
        <#lt>   }
    <#elseif EEPROM_EMULATOR_RWWEE_ENABLED == true && core.CoreArchitecture != "CORTEX-M23">
        <#if EEPROM_EMULATOR_RWWEE_MEM_NAME == "RWWEE">
            <#lt>   ${EEPROM_EMULATOR_NVM_PLIB}_RWWEEPROM_RowErase((uint32_t)flashAddr);
        <#elseif EEPROM_EMULATOR_RWWEE_MEM_NAME == "Data Flash">
            <#lt>   ${EEPROM_EMULATOR_NVM_PLIB}_DATA_FLASH_RowErase((uint32_t)flashAddr);
        </#if>
    <#else>
        <#lt>   (void) ${EEPROM_EMULATOR_NVM_PLIB}_RowErase((uint32_t)flashAddr);
    </#if>
<#else>
    <#if EEPROM_EMULATOR_NVM_PLIB == "NVMCTRL">
        <#lt>   ${EEPROM_EMULATOR_NVM_PLIB}_BlockErase((uint32_t)flashAddr);
    <#else>
        <#lt>   ${EEPROM_EMULATOR_NVM_PLIB}_SectorErase((uint32_t)flashAddr);
    </#if>
</#if>

    while (${EEPROM_EMULATOR_NVM_PLIB}_IsBusy())
    {
        /* Nothing to do*/
    }

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_InvalidateDCache_by_Addr((uint32_t *)flashAddr, EEPROM_EMULATOR_ROW_SIZE);
</#if>
}

/* MISRA C-2012 Rule 11.8 deviated:1 Deviation record ID -  H3_MISRAC_2012_R_11_8_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:1 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1"
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

   (void) ${EEPROM_EMULATOR_NVM_PLIB}_PageBufferWrite((uint32_t*)data, (uint32_t)flashAddr);

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_CleanDCache_by_Addr((void*)flashAddr, EEPROM_EMULATOR_PAGE_SIZE);
</#if>
}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"
</#if>
/* MISRAC 2012 deviation block end */

/** \internal
 *  \brief Commits the internal NVM controller page buffer to physical memory.
 *
 *  \param[in] physical_page  Physical page in EEPROM space to commit
 */
static void EMU_EEPROM_NVMBufferCommit(const uint16_t physical_page)
{
    EEPROM_PAGE* flashAddr = EMU_EEPROM_PageToAddrTranslation(physical_page);

   (void) ${EEPROM_EMULATOR_NVM_PLIB}_PageBufferCommit((uint32_t)flashAddr);

    while (${EEPROM_EMULATOR_NVM_PLIB}_IsBusy())
    {
        /* Nothing to do*/
    }

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
    SYS_CACHE_InvalidateDCache_by_Addr((uint32_t *)flashAddr, EEPROM_EMULATOR_PAGE_SIZE);
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
    SYS_CACHE_InvalidateDCache_by_Addr((uint32_t *)flashAddr, EEPROM_EMULATOR_PAGE_SIZE);
</#if>

    (void) ${EEPROM_EMULATOR_NVM_PLIB}_Read( (uint32_t*)data, EEPROM_EMULATOR_PAGE_SIZE, (uint32_t)flashAddr );
}

/**
 * \brief Commits any cached data to physical non-volatile memory.
 *
 * Commits the internal SRAM caches to physical non-volatile memory, to ensure
 * that any outstanding cached data is preserved. This function should be called
 * prior to a system reset or shutdown to prevent data loss.
 *
 * \note This should be the first function executed in a BOD33 Early Warning
 *       callback to ensure that any outstanding cache data is fully written to
 *       prevent data loss.
 *
 *
 * \note This function should also be called before using the NVM controller
 *       directly in the user-application for any other purposes to prevent
 *       data loss.
 *
 * \return Status code indicating the status of the operation.
 */
static void EMU_EEPROM_CachedDataCommit(void)
{
    uint16_t cached_logical_page = eeprom_instance.cache.header.logical_page;

    /* If cache is inactive, no need to commit anything to physical memory */
    if (eeprom_instance.cache_active != false)
    {
       /* Perform the page write to commit the NVM page buffer to FLASH */
       EMU_EEPROM_NVMBufferCommit(eeprom_instance.page_map[cached_logical_page]);

       __DSB(); // Enforce ordering to prevent incorrect cache state
       eeprom_instance.cache_active = false;
    }
}

/**
 * \brief Initializes the emulated EEPROM memory, destroying the current contents.
 */
 /* MISRA C-2012 Rule 11.3 deviated:4 Deviation record ID -  H3_MISRAC_2012_R_11_3_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance block deviate:8 "MISRA C-2012 Rule 11.3" "H3_MISRAC_2012_R_11_3_DR_1"
</#if>
static void EMU_EEPROM_MemFormat(void)
{
    uint16_t logical_page = 0;
    uint16_t physical_page = 0;
    /* Make a buffer to hold the initialized EEPROM page */
    EEPROM_PAGE data;

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
            (void) memset(&data, 0xFF, sizeof(data));

            /* Set up the new EEPROM row's header */
            data.header.logical_page = logical_page;
            if ((physical_page % EEPROM_EMULATOR_PAGES_PER_ROW) == 0U)
            {
                data.header.version_str = *(uint16_t*)&EEPROM_EMULATOR_VERSION_STR[0];
            }
            else if ((physical_page % EEPROM_EMULATOR_PAGES_PER_ROW) == 1U)
            {
                data.header.version_str = *(uint16_t*)&EEPROM_EMULATOR_VERSION_STR[2];
            }
            else
            {
                /* Nothing to do */
            }

            /* Write the page out to physical memory */
            EMU_EEPROM_NVMBufferFill(physical_page, &data);
            EMU_EEPROM_NVMBufferCommit(physical_page);

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
        if(flashAddr[c].header.logical_page == flashAddr[EEPROM_EMULATOR_NUM_LOGICAL_PAGES_PER_ROW].header.logical_page)
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
    /* Erase the old/full row*/
    if(EMU_EEPROM_IsFullRow(pre_phy_page))
    {
         EMU_EEPROM_NVMRowErase(pre_phy_page/EEPROM_EMULATOR_PAGES_PER_ROW);
    }
    else
    {
        EMU_EEPROM_NVMRowErase(next_phy_page/EEPROM_EMULATOR_PAGES_PER_ROW);
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

        /* Commit any cached data to physical non-volatile memory */
        EMU_EEPROM_CachedDataCommit();

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
        if ((new_page % EEPROM_EMULATOR_PAGES_PER_ROW) == 0U)
        {
            eeprom_instance.cache.header.version_str = *(uint16_t*)&EEPROM_EMULATOR_VERSION_STR[0];
        }
        else if ((new_page % EEPROM_EMULATOR_PAGES_PER_ROW) == 1U)
        {
            eeprom_instance.cache.header.version_str = *(uint16_t*)&EEPROM_EMULATOR_VERSION_STR[2];
        }
        else
        {
            /* Nothing to do */
        }

        /* Fill the physical NVM buffer with the new data so that it can be
         * quickly committed in the future if needed due to a low power
         * condition */

        EMU_EEPROM_NVMBufferFill((uint16_t)new_page, &eeprom_instance.cache);

        /* Update the page map with the new page location and indicate that
         * the cache now holds new data */

        eeprom_instance.page_map[page_trans[c].logical_page] = (uint8_t)new_page;
        eeprom_instance.cache_active = true;
    }

    /* Commit any cached data to physical non-volatile memory */
    EMU_EEPROM_CachedDataCommit();

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
    if ((eeprom_instance.cache_active == true) && (eeprom_instance.cache.header.logical_page == logical_page))
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

    /* Check if the cache is active and the currently cached page is not the
     * page that is being written (if not, we need to commit and cache the new
     * page) */
    if ((eeprom_instance.cache_active == true) && (eeprom_instance.cache.header.logical_page != logical_page))
    {
        /* Commit the currently cached data buffer to non-volatile memory */
        EMU_EEPROM_CachedDataCommit();
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

    /* Copy the version string if the physical page are first two pages of the row */
    if ((new_page % EEPROM_EMULATOR_PAGES_PER_ROW) == 0U)
    {
        eeprom_instance.cache.header.version_str = *(uint16_t*)&EEPROM_EMULATOR_VERSION_STR[0];
    }
    else if ((new_page % EEPROM_EMULATOR_PAGES_PER_ROW) == 1U)
    {
        eeprom_instance.cache.header.version_str = *(uint16_t*)&EEPROM_EMULATOR_VERSION_STR[2];
    }
    else
    {
        /* Nothing to do */
    }

    /* Update the page cache contents with the new data */
   (void) memcpy(&eeprom_instance.cache.data,
            data,
            EEPROM_EMULATOR_PAGE_DATA_SIZE);

    /* Fill the physical NVM buffer with the new data so that it can be quickly
     * committed in the future if needed due to a low power condition */
    EMU_EEPROM_NVMBufferFill(new_page, &eeprom_instance.cache);

    /* Update the cache parameters and mark the cache as active */
    eeprom_instance.page_map[logical_page] = (uint8_t)new_page;

    __DSB(); // Enforce ordering to prevent incorrect cache state
    eeprom_instance.cache_active           = true;

    return EMU_EEPROM_STATUS_OK;
}

static bool EMU_EEPROM_IsValidVersionStrExists(void)
{
    uint8_t version_str[5] = {0};
    uint16_t physical_page = 0;
    uint16_t logical_page = 0;
    EEPROM_PAGE* page_ptr = NULL;
    bool isVerStringValid = false;

    /* Check for a valid version string. A 4 byte version string is stored in first two pages of each row. First two bytes of version string
     * are stored in first page of the row and the remaining two bytes are stored in the second page of the same row */

    for (physical_page = 0; physical_page < EEPROM_EMULATOR_NUM_PHYSICAL_PAGES; physical_page+=EEPROM_EMULATOR_PAGES_PER_ROW)
    {
        /* Read in the logical page stored in the current physical page */
        logical_page = EMU_EEPROM_PhysicalToLogicalPage(physical_page);

        page_ptr = EMU_EEPROM_PageToAddrTranslation(physical_page);

        /* If the logical page number is valid, check for version string */
        if ((logical_page != EEPROM_EMULATOR_INVALID_PAGE_NUMBER) && (logical_page < EEPROM_EMULATOR_NUM_LOGICAL_PAGES))
        {
            *((uint16_t*)&version_str[0]) = page_ptr[0].header.version_str;
            *((uint16_t*)&version_str[2]) = page_ptr[1].header.version_str;

            if (strncmp((char *)version_str, EEPROM_EMULATOR_VERSION_STR, sizeof(EEPROM_EMULATOR_VERSION_STR)) == 0)
            {
                isVerStringValid = true;
                break;
            }
        }
    }

    return isVerStringValid;
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.3"
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

    /* Clear EEPROM page write cache on initialization */
    eeprom_instance.cache_active = false;

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
 * \brief Commits any cached data to physical non-volatile memory.
 *
 * Commits the internal SRAM caches to physical non-volatile memory, to ensure
 * that any outstanding cached data is preserved. This function should be called
 * prior to a system reset or shutdown to prevent data loss.
 *
 * \note This should be the first function executed in a BOD33 Early Warning
 *       callback to ensure that any outstanding cache data is fully written to
 *       prevent data loss.
 *
 *
 * \note This function should also be called before using the NVM controller
 *       directly in the user-application for any other purposes to prevent
 *       data loss.
 *
 * \return Status code indicating the status of the operation.
 */
EMU_EEPROM_STATUS EMU_EEPROM_PageBufferCommit(void)
{
    EMU_EEPROM_STATUS error_code = EMU_EEPROM_STATUS_OK;

    /* Guard against multiple threads trying access the EEPROM memory */
    if(OSAL_MUTEX_Lock(&eeprom_instance.EmulatedEEPROMAccessLock, OSAL_WAIT_FOREVER) == OSAL_RESULT_FAIL)
    {
        return EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED;
    }

    EMU_EEPROM_CachedDataCommit();

    /* Release the mutex */
    (void) OSAL_MUTEX_Unlock(&eeprom_instance.EmulatedEEPROMAccessLock);

    return error_code;
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

    /* Clear EEPROM page write cache on initialization */
    eeprom_instance.cache_active = false;

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
 * \note Data stored in pages may be cached in volatile RAM memory; to commit
 *       any cached data to physical non-volatile memory, the
 *       \ref EMU_EEPROM_CachedDataCommit() function should be called.
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
 * \note Data stored in pages may be cached in volatile RAM memory; to commit
 *       any cached data to physical non-volatile memory, the
 *       \ref EMU_EEPROM_CachedDataCommit() function should be called.
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
    uint8_t buffer[EEPROM_EMULATOR_PAGE_DATA_SIZE];
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
        error_code = EMU_EEPROM_PageDataRead(logical_page, buffer);

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
        buffer[c % EEPROM_EMULATOR_PAGE_DATA_SIZE] = data[c - offset];
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
            error_code = EMU_EEPROM_PageDataWrite(logical_page, buffer);
            page_dirty = false;

            if (error_code != EMU_EEPROM_STATUS_OK)
            {
                break;
            }

            /* Increment the page number we are looking at */
            logical_page++;

            /* Read the next page from non-volatile memory into the temporary
             * buffer in case of a partial page write */
            error_code = EMU_EEPROM_PageDataRead(logical_page, buffer);

            if (error_code != EMU_EEPROM_STATUS_OK)
            {
                /* Release the mutex */
                (void) OSAL_MUTEX_Unlock(&eeprom_instance.EmulatedEEPROMAccessLock);

                return error_code;
            }
        }
        /* Copy the next byte of data from the user's buffer to the temporary buffer */
        buffer[c % EEPROM_EMULATOR_PAGE_DATA_SIZE] = data[c - offset];
        page_dirty = true;
    }

    /* If the current page is dirty, write it */
    if (page_dirty)
    {
        error_code = EMU_EEPROM_PageDataWrite(logical_page, buffer);
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
