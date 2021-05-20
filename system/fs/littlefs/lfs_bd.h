/*
 * Testing block device, wraps filebd and rambd while providing a bunch
 * of hooks for testing littlefs in various conditions.
 *
 * Copyright (c) 2017, Arm Limited. All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 */
#ifndef LFS_TESTBD_H
#define LFS_TESTBD_H

#include "lfs.h"
#include "lfs_util.h"


#ifdef __cplusplus
extern "C"
{
#endif
    
typedef struct
{
    uint8_t disk_num;
} BLOCK_DEV;


// Block device specific tracing
#ifdef LFS_TESTBD_YES_TRACE
#define LFS_TESTBD_TRACE(...) LFS_TRACE(__VA_ARGS__)
#else
#define LFS_TESTBD_TRACE(...)
#endif



/* Results of Disk Functions */
typedef enum {
	RES_OK = 0,		/* 0: Successful */
	RES_ERROR,		/* 1: R/W Error */
	RES_WRPRT,		/* 2: Write Protected */
	RES_NOTRDY,		/* 3: Not Ready */
	RES_PARERR		/* 4: Invalid Parameter */
} BDSTATUS;

/// Block device API ///


BDSTATUS lfs_bd_initilize (
    uint8_t pdrv);

// Read a block
int lfs_bd_read(const struct lfs_config *cfg, lfs_block_t block,
        lfs_off_t off, void *buffer, lfs_size_t size);

// Program a block
//
// The block must have previously been erased.
int lfs_bd_prog(const struct lfs_config *cfg, lfs_block_t block,
        lfs_off_t off, const void *buffer, lfs_size_t size);

// Erase a block
//
// A block must be erased before being programmed. The
// state of an erased block is undefined.
int lfs_bd_erase(const struct lfs_config *cfg, lfs_block_t block);

// Sync the block device
int lfs_bd_sync(const struct lfs_config *cfg);





#ifdef __cplusplus
} /* extern "C" */
#endif

#endif
