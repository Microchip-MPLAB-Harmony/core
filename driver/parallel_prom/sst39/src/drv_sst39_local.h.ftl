/*******************************************************************************
  SST39 Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sst39_local.h

  Summary:
    SST39 driver local declarations and definitions

  Description:
    This file contains the SST39 driver's local declarations and definitions.
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

#ifndef DRV_SST39_LOCAL_H
#define DRV_SST39_LOCAL_H

// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************
#include <string.h>
#include "configuration.h"
#include "driver/sst39/drv_sst39.h"

// *****************************************************************************
// *****************************************************************************
// Section: Local Data Type Definitions
// *****************************************************************************
// *****************************************************************************

/**************************************
 * SST39 Driver Hardware Instance Object
 **************************************/
typedef struct
{
    /* Flag to indicate in use  */
    bool inUse;

    /* Status of transfer */
    DRV_SST39_TRANSFER_STATUS transferStatus;

    /* The status of the driver */
    SYS_STATUS status;

    /* Intent of opening the driver */
    DRV_IO_INTENT ioIntent;

    /* Indicates the number of clients that have opened this driver */
    size_t nClients;

    /* PLIB API list that will be used by the driver to access the hardware */
    const DRV_SST39_PLIB_INTERFACE *sst39Plib;

} DRV_SST39_OBJECT;


#endif //#ifndef DRV_SST39_LOCAL_H

/*******************************************************************************
 End of File
*/

