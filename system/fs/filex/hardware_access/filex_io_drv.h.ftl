/**************************************************************************/
/*                                                                        */
/*       Copyright (c) Microsoft Corporation. All rights reserved.        */
/*                                                                        */
/*       This software is licensed under the Microsoft Software License   */
/*       Terms for Microsoft Azure RTOS. Full text of the license can be  */
/*       found in the LICENSE file at https://aka.ms/AzureRTOS_EULA       */
/*       and in the root directory of this software.                      */
/*                                                                        */
/**************************************************************************/

/*-----------------------------------------------------------------------/
/  Low level media I/O interface include file                            /
/-----------------------------------------------------------------------*/

#ifndef _FILEX_IO_DRV_DEFINED
#define _FILEX_IO_DRV_DEFINED

#include <stdint.h>
#include "fx_api.h"
<#if ((SYS_FS_FAT == true) && (SYS_FS_FILEX == true))>
#include "ff.h"
</#if>

#ifdef __cplusplus
extern "C" {
#endif

/* Results of FILEX IO Functions */
typedef enum {
    RESULT_OK = 0,     /* 0: Successful */
    RESULT_ERROR,      /* 1: R/W Error */
    RESULT_WRPRT,      /* 2: Write Protected */
    RESULT_NOTRDY,     /* 3: Not Ready */
    RESULT_PARERR      /* 4: Invalid Parameter */
} FILEX_IO_RESULT;

<#if !((SYS_FS_FAT == true) && (SYS_FS_FILEX == true))>
typedef struct {
    uint8_t pd; /* Physical drive number */
    uint8_t pt; /* Partition: 0:Auto detect, 1-4:Forced partition) */
} PARTITION;

extern PARTITION VolToPart[];   /* Volume - Partition mapping table */
</#if>

void filex_io_drv_entry(FX_MEDIA *media_ptr);
uint32_t filex_io_disk_get_sector_count(uint8_t pdrv);

#ifdef __cplusplus
}
#endif

#endif //_FILEX_IO_DRV_DEFINED
