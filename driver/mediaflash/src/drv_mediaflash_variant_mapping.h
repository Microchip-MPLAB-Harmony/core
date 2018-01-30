/*******************************************************************************
  MEDIAFLASH Driver Feature Variant Implementations

  Company:
    Microchip Technology Inc.

  File Name:
    drv_mediaflash_variant_mapping.h

  Summary:
    MEDIAFLASH Driver Feature Variant Implementations

  Description:
    This file implements the functions which differ based on different parts
    and various implementations of the same feature.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
Copyright (c) 2017 released Microchip Technology Inc.  All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED AS IS WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR
CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF
SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
*******************************************************************************/
//DOM-IGNORE-END


#ifndef _DRV_MEDIAFLASH_VARIANT_MAPPING_H
#define _DRV_MEDIAFLASH_VARIANT_MAPPING_H

// *****************************************************************************
// *****************************************************************************
// Section: Feature Variant Mapping
// *****************************************************************************
// *****************************************************************************
/* Some variants are determined by hardware feature existence, some features
   are determined user configuration of the driver, and some variants are
   combination of the two.
*/


// *****************************************************************************
/* Interrupt Source Control

  Summary:
    Macros to enable, disable or clear the interrupt source

  Description:
    This macro enables, disables or clears the interrupt source

    The macros get mapped to the respective SYS module APIs if the configuration
    option DRV_MEDIAFLASH_INTERRUPT_MODE is set to true
 
  Remarks:
    This macro is mandatory
*/



#if(DRV_MEDIAFLASH_INTERRUPT_MODE == true)

    #define _DRV_MEDIAFLASH_InterruptSourceEnable(source)          SYS_INT_SourceEnable( source )
    #define _DRV_MEDIAFLASH_InterruptSourceDisable(source)         SYS_INT_SourceDisable( source )
    #define _DRV_MEDIAFLASH_InterruptSourceClear(source)           SYS_INT_SourceStatusClear( source )

    #define _DRV_MEDIAFLASH_InterruptSourceStatusGet(source)       SYS_INT_SourceStatusGet( source )

#else

#define _DRV_MEDIAFLASH_InterruptSourceEnable(source)
#define _DRV_MEDIAFLASH_InterruptSourceDisable(source)         false
#define _DRV_MEDIAFLASH_InterruptSourceClear(source)           SYS_INT_SourceStatusClear( source )

#define _DRV_MEDIAFLASH_InterruptSourceStatusGet(source)       SYS_INT_SourceStatusGet( source )

#endif

#if defined (__PIC32MX__)
    #define _DRV_MEDIAFLASH_UnlockKeySequence0(x,y)
#elif defined (__PIC32MZ__)
    #define _DRV_MEDIAFLASH_UnlockKeySequence0(x,y)     PLIB_MEDIAFLASH_FlashWriteKeySequence( x, y)
#endif

#if defined (DRV_MEDIAFLASH_ERASE_WRITE_ENABLE)
    #define DRV_MEDIAFLASH_ERASE_BUFFER_SIZE            DRV_MEDIAFLASH_PAGE_SIZE
    #define _DRV_MEDIAFLASH_ERASE_WRITE_WRAPPER         DRV_MEDIAFLASH_EraseWrite
#else
    #define DRV_MEDIAFLASH_ERASE_BUFFER_SIZE 0
    #define _DRV_MEDIAFLASH_ERASE_WRITE_WRAPPER NULL
#endif

#if defined (DRV_MEDIAFLASH_DISABLE_ERROR_CHECK)
#define _DRV_MEDIAFLASH_VALIDATE_EXPR(y, z)
#else
#define _DRV_MEDIAFLASH_VALIDATE_EXPR(y, z) if ((y)) return (z);
#endif

#if defined (DRV_MEDIAFLASH_SYS_FS_REGISTER)
#define _DRV_MEDIAFLASH_RegisterWithSysFs(x, y, z) SYS_FS_MEDIA_MANAGER_Register((SYS_MODULE_OBJ)x, (SYS_MODULE_INDEX)y, &z, SYS_FS_MEDIA_TYPE_MEDIAFLASH)
#else
#define _DRV_MEDIAFLASH_RegisterWithSysFs(x, y, z)
#endif

typedef enum {
	MEDIAFLASH_ID_0 = 0,
	MEDIAFLASH_NUMBER_OF_MODULES = 1
} MEDIAFLASH_MODULE_ID;

#endif //_DRV_MEDIAFLASH_VARIANT_MAPPING_H

/*******************************************************************************
 End of File
*/

