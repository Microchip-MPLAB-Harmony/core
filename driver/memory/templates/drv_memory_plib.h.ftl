/*******************************************************************************
  Memory Driver ${DRV_MEMORY_DEVICE} Interface Definition

  Company:
    Microchip Technology Inc.

  File Name:
    drv_memory_${DRV_MEMORY_DEVICE?lower_case}.h

  Summary:
    Memory Driver ${DRV_MEMORY_DEVICE} Interface Definition

  Description:
    The Memory Driver provides a interface to access the ${DRV_MEMORY_DEVICE} peripheral on the
    microcontroller.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* © 2018 Microchip Technology Inc. and its subsidiaries.
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

#ifndef _DRV_MEMORY_${DRV_MEMORY_DEVICE}_H
#define _DRV_MEMORY_${DRV_MEMORY_DEVICE}_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <stdio.h>

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility
    extern "C" {
#endif

// DOM-IGNORE-END

DRV_HANDLE ${DRV_MEMORY_PLIB}_Open( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent );

void ${DRV_MEMORY_PLIB}_Close( const DRV_HANDLE handle );

SYS_STATUS ${DRV_MEMORY_PLIB}_Status( const SYS_MODULE_INDEX drvIndex );

bool ${DRV_MEMORY_PLIB}_SectorErase( const DRV_HANDLE handle, uint32_t address );

bool ${DRV_MEMORY_PLIB}_Read( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address );

bool ${DRV_MEMORY_PLIB}_PageWrite( const DRV_HANDLE handle, void *tx_data, uint32_t address );

<#if DRV_MEMORY_INTERRUPT_ENABLE == true>
    <#lt>void ${DRV_MEMORY_PLIB}_EventHandlerSet( const DRV_HANDLE handle, const DRV_MEMORY_EVENT_HANDLER eventHandler, const uintptr_t context );
</#if>

MEMORY_DEVICE_TRANSFER_STATUS ${DRV_MEMORY_PLIB}_TransferStatusGet( const DRV_HANDLE handle );

bool ${DRV_MEMORY_PLIB}_GeometryGet( const DRV_HANDLE handle, MEMORY_DEVICE_GEOMETRY *geometry );

#ifdef __cplusplus
}
#endif

#endif // #ifndef _DRV_MEMORY_${DRV_MEMORY_DEVICE}_H
/*******************************************************************************
 End of File
*/