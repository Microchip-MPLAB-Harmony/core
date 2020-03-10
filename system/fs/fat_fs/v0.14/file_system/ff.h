/*----------------------------------------------------------------------------/
/  FatFs - Generic FAT Filesystem module  R0.14                               /
/-----------------------------------------------------------------------------/
/
/ Copyright (C) 2019, ChaN, all right reserved.
/
/ FatFs module is an open source software. Redistribution and use of FatFs in
/ source and binary forms, with or without modification, are permitted provided
/ that the following condition is met:

/ 1. Redistributions of source code must retain the above copyright notice,
/    this condition and the following disclaimer.
/
/ This software is provided by the copyright holder and contributors "AS IS"
/ and any warranties related to this software are DISCLAIMED.
/ The copyright owner or contributors be NOT LIABLE for any damages caused
/ by use of this software.
/
/----------------------------------------------------------------------------*/


#ifndef FF_DEFINED
#define FF_DEFINED	86606	/* Revision ID */

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdarg.h>

#include "device.h"

#include "system/fs/fat_fs/src/file_system/ffconf.h"		/* FatFs configuration options */

#if FF_DEFINED != FFCONF_DEF
#error Wrong configuration file (ffconf.h).
#endif


/* Integer types used for FatFs API */

#if defined(_WIN32)	/* Main development platform */
#define FF_INTDEF 2
#include <windows.h>
typedef unsigned __int64 QWORD;
#elif (defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L) || defined(__cplusplus)	/* C99 or later */
#define FF_INTDEF 2
#include <stdint.h>
typedef unsigned int	UINT;	/* int must be 16-bit or 32-bit */
typedef unsigned char	BYTE;	/* char must be 8-bit */
typedef uint16_t		WORD;	/* 16-bit unsigned integer */
typedef uint32_t		DWORD;	/* 32-bit unsigned integer */
typedef uint64_t		QWORD;	/* 64-bit unsigned integer */
typedef WORD			WCHAR;	/* UTF-16 character type */
#else  	/* Earlier than C99 */
#define FF_INTDEF 1
typedef unsigned int	UINT;	/* int must be 16-bit or 32-bit */
typedef unsigned char	BYTE;	/* char must be 8-bit */
typedef unsigned short	WORD;	/* 16-bit unsigned integer */
typedef unsigned long	DWORD;	/* 32-bit unsigned integer */
typedef WORD			WCHAR;	/* UTF-16 character type */
#endif


/* Definitions of volume management */

#if FF_MULTI_PARTITION		/* Multiple partition configuration */
typedef struct {
	uint8_t pd;	/* Physical drive number */
	uint8_t pt;	/* Partition: 0:Auto detect, 1-4:Forced partition) */
} PARTITION;
extern PARTITION VolToPart[FF_VOLUMES];	/* Volume - Partition mapping table */
#endif

#if FF_STR_VOLUME_ID
#ifndef FF_VOLUME_STRS
extern const char* VolumeStr[FF_VOLUMES];	/* User defied volume ID */
#endif
#endif



/* Type of path name strings on FatFs API */

#ifndef _INC_TCHAR
#define _INC_TCHAR

#if FF_USE_LFN && FF_LFN_UNICODE == 1 	/* Unicode in UTF-16 encoding */
typedef WCHAR TCHAR;
#define _T(x) L ## x
#define _TEXT(x) L ## x
#elif FF_USE_LFN && FF_LFN_UNICODE == 2	/* Unicode in UTF-8 encoding */
typedef char TCHAR;
#define _T(x) u8 ## x
#define _TEXT(x) u8 ## x
#elif FF_USE_LFN && FF_LFN_UNICODE == 3	/* Unicode in UTF-32 encoding */
typedef DWORD TCHAR;
#define _T(x) U ## x
#define _TEXT(x) U ## x
#elif FF_USE_LFN && (FF_LFN_UNICODE < 0 || FF_LFN_UNICODE > 3)
#error Wrong FF_LFN_UNICODE setting
#else									/* ANSI/OEM code in SBCS/DBCS */
typedef char TCHAR;
#define _T(x) x
#define _TEXT(x) x
#endif

#endif



/* Type of file size and LBA variables */

#if FF_FS_EXFAT
#if FF_INTDEF != 2
#error exFAT feature wants C99 or later
#endif
typedef QWORD FSIZE_t;
#if FF_LBA64
typedef QWORD LBA_t;
#else
typedef DWORD LBA_t;
#endif
#else
#if FF_LBA64
#error exFAT needs to be enabled when enable 64-bit LBA
#endif
typedef DWORD FSIZE_t;
typedef DWORD LBA_t;
#endif



/* Filesystem object structure (FATFS) */

typedef struct {
	BYTE	fs_type;		/* Filesystem type (0:not mounted) */
	BYTE	pdrv;			/* Associated physical drive */
	BYTE	n_fats;			/* Number of FATs (1 or 2) */
	BYTE	wflag;			/* win[] flag (b0:dirty) */
	BYTE	fsi_flag;		/* FSINFO flags (b7:disabled, b0:dirty) */
	WORD	id;				/* Volume mount ID */
	WORD	n_rootdir;		/* Number of root directory entries (FAT12/16) */
	WORD	csize;			/* Cluster size [sectors] */
#if FF_MAX_SS != FF_MIN_SS
	WORD	ssize;			/* Sector size (512, 1024, 2048 or 4096) */
#endif
#if FF_USE_LFN
	WCHAR*	lfnbuf;			/* LFN working buffer */
#endif
#if FF_FS_EXFAT
	BYTE*	dirbuf;			/* Directory entry block scratchpad buffer for exFAT */
#endif
#if FF_FS_REENTRANT
	FF_SYNC_t	sobj;		/* Identifier of sync object */
#endif
#if !FF_FS_READONLY
	DWORD	last_clst;		/* Last allocated cluster */
	DWORD	free_clst;		/* Number of free clusters */
#endif
#if FF_FS_RPATH
	DWORD	cdir;			/* Current directory start cluster (0:root) */
#if FF_FS_EXFAT
	DWORD	cdc_scl;		/* Containing directory start cluster (invalid when cdir is 0) */
	DWORD	cdc_size;		/* b31-b8:Size of containing directory, b7-b0: Chain status */
	DWORD	cdc_ofs;		/* Offset in the containing directory (invalid when cdir is 0) */
#endif
#endif
	DWORD	n_fatent;		/* Number of FAT entries (number of clusters + 2) */
	DWORD	fsize;			/* Size of an FAT [sectors] */
	LBA_t	volbase;		/* Volume base sector */
	LBA_t	fatbase;		/* FAT base sector */
	LBA_t	dirbase;		/* Root directory base sector/cluster */
	LBA_t	database;		/* Data base sector */
#if FF_FS_EXFAT
	LBA_t	bitbase;		/* Allocation bitmap base sector */
#endif
	LBA_t	winsect;		/* Current sector appearing in the win[] */
	BYTE	CACHE_ALIGN win[FF_MAX_SS];	/* Disk access window for Directory, FAT (and file data at tiny cfg) */
} FATFS;

/* Object ID and allocation information (FFOBJID) */

typedef struct {
	FATFS*	fs;				/* Pointer to the hosting volume of this object */
	WORD	id;				/* Hosting volume mount ID */
	BYTE	attr;			/* Object attribute */
	BYTE	stat;			/* Object chain status (b1-0: =0:not contiguous, =2:contiguous, =3:fragmented in this session, b2:sub-directory stretched) */
	DWORD	sclust;			/* Object data start cluster (0:no cluster or root directory) */
	FSIZE_t	objsize;		/* Object size (valid when sclust != 0) */
#if FF_FS_EXFAT
	DWORD	n_cont;			/* Size of first fragment - 1 (valid when stat == 3) */
	DWORD	n_frag;			/* Size of last fragment needs to be written to FAT (valid when not zero) */
	DWORD	c_scl;			/* Containing directory start cluster (valid when sclust != 0) */
	DWORD	c_size;			/* b31-b8:Size of containing directory, b7-b0: Chain status (valid when c_scl != 0) */
	DWORD	c_ofs;			/* Offset in the containing directory (valid when file object and sclust != 0) */
#endif
#if FF_FS_LOCK
	UINT	lockid;			/* File lock ID origin from 1 (index of file semaphore table Files[]) */
#endif
} FFOBJID;



/* File object structure (FIL) */

typedef struct {
	FFOBJID	obj;			/* Object identifier (must be the 1st member to detect invalid object pointer) */
	BYTE	flag;			/* File status flags */
	BYTE	err;			/* Abort flag (error code) */
	FSIZE_t	fptr;			/* File read/write pointer (Zeroed on file open) */
	DWORD	clust;			/* Current cluster of fpter (invalid when fptr is 0) */
	LBA_t	sect;			/* Sector number appearing in buf[] (0:invalid) */
#if !FF_FS_READONLY
	LBA_t	dir_sect;		/* Sector number containing the directory entry (not used at exFAT) */
	BYTE*	dir_ptr;		/* Pointer to the directory entry in the win[] (not used at exFAT) */
#endif
#if FF_USE_FASTSEEK
	DWORD*	cltbl;			/* Pointer to the cluster link map table (nulled on open, set by application) */
#endif
#if !FF_FS_TINY
	BYTE	CACHE_ALIGN buf[FF_MAX_SS];	/* File private data read/write window */
#endif
} FIL;



/* Directory object structure (DIR) */

typedef struct {
	FFOBJID	obj;			/* Object identifier */
	DWORD	dptr;			/* Current read/write offset */
	DWORD	clust;			/* Current cluster */
	LBA_t	sect;			/* Current sector (0:Read operation has terminated) */
	BYTE*	dir;			/* Pointer to the directory item in the win[] */
	BYTE	fn[12];			/* SFN (in/out) {body[8],ext[3],status[1]} */
#if FF_USE_LFN
	DWORD	blk_ofs;		/* Offset of current entry block being processed (0xFFFFFFFF:Invalid) */
#endif
#if FF_USE_FIND
	const TCHAR* pat;		/* Pointer to the name matching pattern */
#endif
} DIR;



/* File information structure (FILINFO) */

typedef struct {
	FSIZE_t	fsize;			/* File size */
	WORD	fdate;			/* Modified date */
	WORD	ftime;			/* Modified time */
	BYTE	fattrib;		/* File attribute */
#if FF_USE_LFN
	TCHAR	altname[FF_SFN_BUF + 1];/* Altenative file name */
	TCHAR	fname[FF_LFN_BUF + 1];	/* Primary file name */
#else
	TCHAR	fname[12 + 1];	/* File name */
#endif
} FILINFO;



/* Format parameter structure (MKFS_PARM) */

typedef struct {
	BYTE fmt;			/* Format option (FM_FAT, FM_FAT32, FM_EXFAT and FM_SFD) */
	BYTE n_fat;			/* Number of FATs */
	UINT align;			/* Data area alignment (sector) */
	UINT n_root;		/* Number of root directory entries */
	DWORD au_size;		/* Cluster size (byte) */
} MKFS_PARM;



/* File function return code (FRESULT) */

typedef enum {
	FR_OK = 0,				/* (0) Succeeded */
	FR_DISK_ERR,			/* (1) A hard error occurred in the low level disk I/O layer */
	FR_INT_ERR,				/* (2) Assertion failed */
	FR_NOT_READY,			/* (3) The physical drive cannot work */
	FR_NO_FILE,				/* (4) Could not find the file */
	FR_NO_PATH,				/* (5) Could not find the path */
	FR_INVALID_NAME,		/* (6) The path name format is invalid */
	FR_DENIED,				/* (7) Access denied due to prohibited access or directory full */
	FR_EXIST,				/* (8) Access denied due to prohibited access */
	FR_INVALID_OBJECT,		/* (9) The file/directory object is invalid */
	FR_WRITE_PROTECTED,		/* (10) The physical drive is write protected */
	FR_INVALID_DRIVE,		/* (11) The logical drive number is invalid */
	FR_NOT_ENABLED,			/* (12) The volume has no work area */
	FR_NO_FILESYSTEM,		/* (13) There is no valid FAT volume */
	FR_MKFS_ABORTED,		/* (14) The f_mkfs() aborted due to any problem */
	FR_TIMEOUT,				/* (15) Could not get a grant to access the volume within defined period */
	FR_LOCKED,				/* (16) The operation is rejected according to the file sharing policy */
	FR_NOT_ENOUGH_CORE,		/* (17) LFN working buffer could not be allocated */
	FR_TOO_MANY_OPEN_FILES,	/* (18) Number of open files > FF_FS_LOCK */
	FR_INVALID_PARAMETER	/* (19) Given parameter is invalid */
} FRESULT;



/*--------------------------------------------------------------*/
/* FatFs module application interface                           */
//int f_mount (FATFS* fs, const TCHAR* path, uint8_t opt);			/* Mount/Unmount a logical drive */
int f_mount (uint8_t vol);								/* Mount a logical drive */
int f_unmount (uint8_t vol);
int f_open (uintptr_t handle, const char* path, uint8_t mode);				/* Open or create a file */
int f_read (uintptr_t handle, void* buff, uint32_t btr, uint32_t* br);			/* Read data from a file */
int f_lseek (uintptr_t handle, uint32_t ofs);								/* Move file pointer of a file object */
int f_close (uintptr_t handle);											/* Close an open file object */
int f_opendir (uintptr_t handle, const TCHAR* path);						/* Open a directory */
int f_readdir (uintptr_t handle, uintptr_t fno);							/* Read a directory item */
int f_closedir (uintptr_t handle);										/* Close an open directory */
int f_stat (const char* path, uintptr_t ptr);					/* Get file status */
int f_write (uintptr_t handle, const void* buff, uint32_t btw, uint32_t* bw);	/* Write data to a file */
int f_getfree (const TCHAR* path, uint32_t* nclst, FATFS** fatfs);	/* Get number of free clusters on the drive */
int f_truncate (uintptr_t handle);										/* Truncate file */
int f_sync (uintptr_t handle);											/* Flush cached data of a writing file */
int f_unlink (const TCHAR* path);								/* Delete an existing file or directory */
int f_mkdir (const TCHAR* path);								/* Create a sub directory */
int f_chmod (const TCHAR* path, uint8_t attr, uint8_t mask);			/* Change attribute of the file/dir */
int f_utime (const TCHAR* path, const uintptr_t fno);			/* Change times-tamp of the file/dir */
int f_rename (const TCHAR* path_old, const TCHAR* path_new);	/* Rename/Move a file or directory */
int f_chdrive (uint8_t drv);								/* Change current drive */
int f_chdir (const TCHAR* path);								/* Change current directory */
int f_getcwd (TCHAR* buff, uint32_t len);							/* Get current directory */
int f_getlabel (const TCHAR* path, TCHAR* label, uint32_t* vsn);	/* Get volume label */
int f_setlabel (const TCHAR* label);							/* Set volume label */
int f_forward (uintptr_t handle, uint32_t(*func)(const uint8_t*, uint32_t), uint32_t btf, uint32_t* bf);	/* Forward data to the stream */
//int f_mkfs (uint8_t vol, uint8_t sfd, uint32_t au);				/* Create a file system on the volume */
int f_mkfs (uint8_t vol, const MKFS_PARM* opt, void* work, uint32_t len);	/* Create a FAT volume */
int f_fdisk (uint8_t pdrv, const uint32_t szt[], void* work);			/* Divide a physical drive into some partitions */
int f_putc (TCHAR c, uintptr_t handle);										/* Put a character to the file */
int f_puts (const TCHAR* str, uintptr_t handle);								/* Put a string to the file */
int f_printf (uintptr_t handle, const TCHAR* str, va_list argList);				/* Put a formatted string to the file */
TCHAR* f_gets (TCHAR* buff, int len, uintptr_t handle);						/* Get a string from the file */
int f_findfirst (uintptr_t handle, uintptr_t fno, const TCHAR* path, const TCHAR* pattern);	/* Find first file */
FRESULT f_findnext (uintptr_t handle, uintptr_t fno);							/* Find next file */
int f_getclusters (const char *path, uint32_t *tot_sec, uint32_t *free_sec);

//#define f_tell(fp) ((fp)->fptr)
//#define f_eof(fp) ((int)((fp)->fptr == (fp)->fsize))
//#define f_size(fp) ((fp)->fsize)
//#define f_error(fp) ((fp)->err)
//#define f_rewind(fp) f_lseek((fp), 0)
//#define f_rewinddir(dp) f_readdir((dp), 0)

uint32_t f_tell(uintptr_t handle);
bool f_eof(uintptr_t handle);
uint32_t f_size(uintptr_t handle);
bool f_error(uintptr_t handle);


#ifndef EOF
#define EOF (-1)
#endif




/*--------------------------------------------------------------*/
/* Additional user defined functions                            */

/* RTC function */
#if !FF_FS_READONLY && !FF_FS_NORTC
uint32_t get_fattime (void);
#endif

/* LFN support functions */
#if FF_USE_LFN >= 1						/* Code conversion (defined in unicode.c) */
WCHAR ff_oem2uni (WCHAR oem, WORD cp);	/* OEM code to Unicode conversion */
WCHAR ff_uni2oem (DWORD uni, WORD cp);	/* Unicode to OEM code conversion */
DWORD ff_wtoupper (DWORD uni);			/* Unicode upper-case conversion */
#endif
#if FF_USE_LFN == 3						/* Dynamic memory allocation */
void* ff_memalloc (UINT msize);			/* Allocate memory block */
void ff_memfree (void* mblock);			/* Free memory block */
#endif

/* Sync functions */
#if FF_FS_REENTRANT
int ff_cre_syncobj (BYTE vol, FF_SYNC_t* sobj);	/* Create a sync object */
int ff_req_grant (FF_SYNC_t sobj);		/* Lock sync object */
void ff_rel_grant (FF_SYNC_t sobj);		/* Unlock sync object */
int ff_del_syncobj (FF_SYNC_t sobj);	/* Delete a sync object */
#endif




/*--------------------------------------------------------------*/
/* Flags and offset address                                     */


/* File access mode and open method flags (3rd argument of f_open) */
#define	FA_READ				0x01
#define	FA_WRITE			0x02
#define	FA_OPEN_EXISTING	0x00
#define	FA_CREATE_NEW		0x04
#define	FA_CREATE_ALWAYS	0x08
#define	FA_OPEN_ALWAYS		0x10
#define	FA_OPEN_APPEND		0x30

/* Fast seek controls (2nd argument of f_lseek) */
#define CREATE_LINKMAP	((FSIZE_t)0 - 1)

/* Format options (2nd argument of f_mkfs) */
#define FM_FAT		0x01
#define FM_FAT32	0x02
#define FM_EXFAT	0x04
#define FM_ANY		0x07
#define FM_SFD		0x08

/* Filesystem type (FATFS.fs_type) */
#define FS_FAT12	1
#define FS_FAT16	2
#define FS_FAT32	3
#define FS_EXFAT	4

/* File attribute bits for directory entry (FILINFO.fattrib) */
#define	AM_RDO	0x01	/* Read only */
#define	AM_HID	0x02	/* Hidden */
#define	AM_SYS	0x04	/* System */
#define AM_DIR	0x10	/* Directory */
#define AM_ARC	0x20	/* Archive */

typedef struct
{
    uint8_t inUse;
    FATFS volObj;
} FATFS_VOLUME_OBJECT;

typedef struct
{
    uint8_t inUse;
    FIL fileObj;
} FATFS_FILE_OBJECT;

typedef struct
{
    uint8_t inUse;
    DIR dirObj;
} FATFS_DIR_OBJECT;

#ifdef __cplusplus
}
#endif

#endif /* FF_DEFINED */
