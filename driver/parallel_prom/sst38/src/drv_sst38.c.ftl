/******************************************************************************
  SST38 Driver Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sst38.c

  Summary:
    SST38 Driver Interface Definition

  Description:
    The SST38 Driver provides a interface to access the SST38 memory. 
    This file should be included in the project if SST38 driver
    functionality is needed.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2022 Microchip Technology Inc. and its subsidiaries.
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

#include "driver/sst38/drv_sst38_local.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

static DRV_SST38_OBJECT gDrvSST38Obj;
static DRV_SST38_OBJECT *dObj = &gDrvSST38Obj;


// *****************************************************************************
// *****************************************************************************
// Section: SST38 Driver Global Functions
// *****************************************************************************
// *****************************************************************************

bool DRV_SST38_ReadProductId( const DRV_HANDLE handle, uint16_t* manufacturer, uint16_t* device )
{
    bool status = false;
    bool isCacheEnabled = (DATA_CACHE_IS_ENABLED() != 0U);
    bool isEccEnabled = false;

    if(handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    /* Disable ECC for PROM commands write_t if enabled */
    isEccEnabled = dObj->sst38Plib->eccDisable((uint8_t)DRV_SST38_CHIP_SELECT);

    if (isCacheEnabled)
    {
        DCACHE_DISABLE();
    }

    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x555U<<DRV_SST38_ADDR_SHIFT), 0xAAU);
    __DSB();
    __ISB();
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x2AAU<<DRV_SST38_ADDR_SHIFT), 0x55U);
    __DSB();
    __ISB();
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x555U<<DRV_SST38_ADDR_SHIFT), 0x90U);
    __DSB();
    __ISB();

    /* Read ID */
    
    *manufacturer = dObj->sst38Plib->read_t(DRV_SST38_START_ADDRESS);
    *device = dObj->sst38Plib->read_t(DRV_SST38_START_ADDRESS+2U);

    __DSB();
    __ISB();

    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x555U<<DRV_SST38_ADDR_SHIFT), 0xF0U);
    __DSB();
    __ISB();

    if (isCacheEnabled)
    {
        DCACHE_ENABLE();
    }

    /* Enable back ECC if it was disabled */
    if (isEccEnabled)
    {
        (void) dObj->sst38Plib->eccEnable((uint8_t)DRV_SST38_CHIP_SELECT);
    }

    status = true;
 
    return status;
}

bool DRV_SST38_Read( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address )
{
    bool status = false;
    uint32_t i = 0U;
    uint16_t* pBuffer = (uint16_t*)rx_data;

    if(handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    for (i=0; i<(rx_data_length-1U); i+=2U)
    {
        pBuffer[i/2U] = dObj->sst38Plib->read_t(address+i);
    }

    if ( (rx_data_length % 2U) != 0U)
    {
        *( (uint8_t*)rx_data+i ) = (uint8_t)(dObj->sst38Plib->read_t(address+i));
    }

    status = true;

    return status;
}

bool DRV_SST38_PageWrite( const DRV_HANDLE handle, void *tx_data, uint32_t address )
{
    bool status = false;
    bool isCacheEnabled = (DATA_CACHE_IS_ENABLED() != 0U);
    uint32_t index = 0U;
    uint16_t* pBuffer = (uint16_t*)tx_data;
    uint16_t readData = 0U;
    bool isEccEnabled = false;

    if(handle == DRV_HANDLE_INVALID)
    {
        return status;
    }

    /* Disable ECC for PROM commands write_t if enabled */
    isEccEnabled = dObj->sst38Plib->eccDisable((uint8_t)DRV_SST38_CHIP_SELECT);

    if (isCacheEnabled)
    {
        DCACHE_DISABLE();
    }

    for (index=0;index<DRV_SST38_PAGE_SIZE;index+=2U)
    {
        /* Send Program Byte command */
        dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x555U<<DRV_SST38_ADDR_SHIFT), 0xAAU);
        __DSB();
        __ISB();
        dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x2AAU<<DRV_SST38_ADDR_SHIFT), 0x55U);
        __DSB();
        __ISB();
        dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x555U<<DRV_SST38_ADDR_SHIFT), 0xA0U);
        __DSB();
        __ISB();
         dObj->sst38Plib->write_t(address+index, (uint16_t)pBuffer[(index/2U)]);
        __DSB();
        __ISB();
    
        /* Wait Program Byte by polling bit DQ7 */
        do
        {
            readData = dObj->sst38Plib->read_t(address+index);
        }
        while ( (readData & 0x80U) != (pBuffer[index/2U] & 0x80U) );
    }

    if (isCacheEnabled)
    {
        DCACHE_ENABLE();
    }

    /* Enable back ECC if it was disabled */
    if (isEccEnabled)
    {
        (void) dObj->sst38Plib->eccEnable((uint8_t)DRV_SST38_CHIP_SELECT);
    }

    status = true;

    return status;
}

bool DRV_SST38_SectorErase( const DRV_HANDLE handle, uint32_t address )
{
    bool isCacheEnabled = (DATA_CACHE_IS_ENABLED() != 0U);
    uint8_t readData = 0U;
    bool isEccEnabled = false;

    if(handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    /* Disable ECC for PROM commands write_t if enabled */
    isEccEnabled = dObj->sst38Plib->eccDisable((uint8_t)DRV_SST38_CHIP_SELECT);
 
    if (isCacheEnabled)
    {
        DCACHE_DISABLE();
    }

    /* Send Chip erase command */
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x555U<<DRV_SST38_ADDR_SHIFT), 0xAAU);
    __DSB();
    __ISB();
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x2AAU<<DRV_SST38_ADDR_SHIFT), 0x55U);
    __DSB();
    __ISB();
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x555U<<DRV_SST38_ADDR_SHIFT), 0x80U);
    __DSB();
    __ISB();
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x555U<<DRV_SST38_ADDR_SHIFT), 0xAAU);
    __DSB();
    __ISB();
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x2AAU<<DRV_SST38_ADDR_SHIFT), 0x55U);
    __DSB();
    __ISB();
    dObj->sst38Plib->write_t(address, 0x50U);
    __DSB();
    __ISB();
    
    /* Wait Erase by polling bit DQ7 */
    do
    {
        readData = (uint8_t)dObj->sst38Plib->read_t(address);
    }
    while ( (readData & 0x80U) == 0x00U );

    if (isCacheEnabled)
    {
        DCACHE_ENABLE();
    }

    /* Enable back ECC if it was disabled */
    if (isEccEnabled)
    {
        (void) dObj->sst38Plib->eccEnable((uint8_t)DRV_SST38_CHIP_SELECT);
    }

    return true;
}

bool DRV_SST38_ChipErase( const DRV_HANDLE handle )
{
    bool isCacheEnabled = (DATA_CACHE_IS_ENABLED() != 0U);
    uint8_t readData = 0;
    bool isEccEnabled = false;

    if(handle == DRV_HANDLE_INVALID)
    {
        return false;
    }

    /* Disable ECC for PROM commands write_t if enabled */
    isEccEnabled = dObj->sst38Plib->eccDisable((uint8_t)DRV_SST38_CHIP_SELECT);

    if (isCacheEnabled)
    {
        DCACHE_DISABLE();
    }

    /* Send Chip erase command */
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x555U<<DRV_SST38_ADDR_SHIFT), 0xAAU);
    __DSB();
    __ISB();
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x2AAU<<DRV_SST38_ADDR_SHIFT), 0x55U);
    __DSB();
    __ISB();
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x555U<<DRV_SST38_ADDR_SHIFT), 0x80U);
    __DSB();
    __ISB();
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x555U<<DRV_SST38_ADDR_SHIFT), 0xAAU);
    __DSB();
    __ISB();
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x2AAU<<DRV_SST38_ADDR_SHIFT), 0x55U);
    __DSB();
    __ISB();
    dObj->sst38Plib->write_t(DRV_SST38_START_ADDRESS+(0x555U<<DRV_SST38_ADDR_SHIFT), 0x10U);
    __DSB();
    __ISB();

    /* Wait Erase by polling bit DQ7 */
    do
    {
        readData = (uint8_t)dObj->sst38Plib->read_t(DRV_SST38_START_ADDRESS);
    }
    while ( (readData & 0x80U) == 0x00U );

    if (isCacheEnabled)
    {
        DCACHE_ENABLE();
    }

    /* Enable back ECC if it was disabled */
    if (isEccEnabled)
    {
        (void) dObj->sst38Plib->eccEnable((uint8_t)DRV_SST38_CHIP_SELECT);
    }

    return true;
}

DRV_HANDLE DRV_SST38_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent )
{
    uint32_t status;
    
    if ((dObj->status != SYS_STATUS_READY) ||
        (dObj->nClients >= DRV_SST38_CLIENTS_NUMBER))
    {
        status = DRV_HANDLE_INVALID;
    }
    else
    {
        dObj->nClients++;

        dObj->ioIntent = ioIntent;
        status = ((DRV_HANDLE)drvIndex);
    }

    return status;
}

void DRV_SST38_Close( const DRV_HANDLE handle )
{
    if ( (handle != DRV_HANDLE_INVALID) &&
         (dObj->nClients > 0U))
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
SYS_MODULE_OBJ DRV_SST38_Initialize
(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT *const init
)
{
    DRV_SST38_INIT *sst38Init = NULL;

    /* Check if the instance has already been initialized. */
    if (dObj->inUse == true)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    dObj->status    = SYS_STATUS_UNINITIALIZED;

    /* Indicate that this object is in use */
    dObj->inUse     = true;
    dObj->nClients  = 0U;

    /* Assign to the local pointer the init data passed */
    sst38Init       = (DRV_SST38_INIT *)init;

    /* Initialize the attached memory device functions */
    dObj->sst38Plib = sst38Init->sst38Plib;

    dObj->status    = SYS_STATUS_READY;

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

SYS_STATUS DRV_SST38_Status( const SYS_MODULE_INDEX drvIndex )
{
    /* Return the driver status */
    return (gDrvSST38Obj.status);
}
