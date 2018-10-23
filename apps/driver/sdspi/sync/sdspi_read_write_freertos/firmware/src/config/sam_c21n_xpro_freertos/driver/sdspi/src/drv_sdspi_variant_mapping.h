/*******************************************************************************
  SD Card (SPI) Driver Feature Variant Implementations

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdspi_variant_mapping.h

  Summary:
    SD Card (SPI) Driver Feature Variant Implementations

  Description:
    This file implements the functions which differ based on different parts
    and various implementations of the same feature.
*******************************************************************************/

// DOM-IGNORE-BEGIN
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
// DOM-IGNORE-END

#ifndef _DRV_SDSPI_VARIANT_MAPPING_H
#define _DRV_SDSPI_VARIANT_MAPPING_H

#include "configuration.h"

// *****************************************************************************
// *****************************************************************************
// Section: Feature Variant Mapping
// *****************************************************************************
// *****************************************************************************
/* Some variants are determined by hardware feature existence, some features
   are determined user configuration of the driver, and some variants are
   combination of the two.
*/

#if defined (DRV_SDSPI_DMA_MODE)
    #define _DRV_SDSPI_DMAChannelSettingsGet(dmaChannel)              XDMAC_ChannelSettingsGet(dmaChannel)
    #define _DRV_SDSPI_DMAChannelSettingsSet(dmaChannel,config)       XDMAC_ChannelSettingsSet(dmaChannel,config)
#else
    #define _DRV_SDSPI_DMAChannelSettingsGet(dmaChannel)              (0)
    #define _DRV_SDSPI_DMAChannelSettingsSet(dmaChannel,config)
#endif

#if defined (DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECK)
    #define _DRV_SDSPI_EnableWriteProtectCheck() true
#else
    #define _DRV_SDSPI_EnableWriteProtectCheck() false
#endif

void DRV_SDSPI_FS_Read (
    const DRV_HANDLE handle,
    DRV_SDSPI_COMMAND_HANDLE* commandHandle,
    void* targetBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);

void DRV_SDSPI_FS_Write(
    const DRV_HANDLE handle,
    DRV_SDSPI_COMMAND_HANDLE* commandHandle,
    void* sourceBuffer,
    uint32_t blockStart,
    uint32_t nBlock
);

#endif //_DRV_SDSPI_VARIANT_MAPPING_H

/*******************************************************************************
 End of File
*/

