/*******************************************************************************
  SD Card (SPI) Driver Definitions Header File

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdspi_definitions.h

  Summary:
    SD Card (SPI) Driver Definitions Header File

  Description:
    This file provides implementation-specific definitions for the SD Card (SPI)
    driver's system interface.
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

#ifndef DRV_SDSPI_DEFINITIONS_H
#define DRV_SDSPI_DEFINITIONS_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "system/ports/sys_ports.h"
#include "system/dma/sys_dma.h"

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Data Types
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* SDSPI Driver Initialization Data

  Summary:
    Defines the data required to initialize the SDSPI driver

  Description:
    This data type defines the data required to initialize or the SDSPI driver.

  Remarks:
    None.
*/

typedef struct
{
    /* SPI Driver Instance used by the SDSPI driver */
    uint32_t                        spiDrvIndex;

    bool                            isFsEnabled;

    /* Number of clients */
    size_t                          numClients;

    /* Memory Pool for Client Objects */
    uintptr_t                       clientObjPool;

    SYS_PORT_PIN                    chipSelectPin;

    SYS_PORT_PIN                    writeProtectPin;

    uint32_t                        blockStartAddress;

    /* Speed at which SD card communication should happen */
    uint32_t                        sdcardSpeedHz;

    uint32_t                        pollingIntervalMs;


} DRV_SDSPI_INIT;


//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

#endif // #ifndef DRV_SDSPI_DEFINITIONS_H

/*******************************************************************************
 End of File
*/
