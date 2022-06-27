# SYS\_FS\_FUNCTIONS Struct

**Parent topic:**[Library Interface](GUID-42556FDF-A632-49FE-8A5E-9303A926578C.md)

## C

```c
typedef struct
{
    /* Function pointer of native file system for mounting a volume */
    int (*mount) (uint8_t vol);
    /* Function pointer of native file system for unmounting a volume */
    int (*unmount) (uint8_t vol);
    /* Function pointer of native file system for opening a file */
    int (*open) (uintptr_t handle, const char* path, uint8_t mode);
    /* Function pointer of native file system for reading a file */
    int (*read) (uintptr_t fp, void* buff, uint32_t btr, uint32_t *br);
    /* Function pointer of native file system for writing to a file */
    int (*write) (uintptr_t fp, const void* buff, uint32_t btw, uint32_t* bw);
    /* Function pointer of native file system for closing a file */
    int (*close) (uintptr_t fp);
    /* Function pointer of native file system for moving the file pointer by a
    * desired offset */
    int (*seek) (uintptr_t handle, uint32_t offset);
    /* Function pointer of native file system for finding the position of the
    * file pointer */
    uint32_t (*tell) (uintptr_t handle);
    * reached */
    bool (*eof) (uintptr_t handle);
    /* Function pointer of native file system to know the size of file */
    uint32_t (*size) (uintptr_t handle);
    /* Function pointer of native file system to know the status of file */
    int (*fstat) (const char* path, uintptr_t fno);
    /* Function pointer of native file system to create a directory */
    int (*mkdir)(const char *path);
    /* Function pointer of native file system to change a directory */
    int (*chdir)(const char *path);
    /* Function pointer of native file system to remove a file or directory */
    int (*remove)(const char *path);
    /* Function pointer of native file system to get the volume label */
    int (*getlabel)(const char *path, char *buff, uint32_t *sn);
    /* Function pointer of native file system to set the volume label */
    int (*setlabel)(const char *label);
    /* Function pointer of native file system to truncate the file */
    int (*truncate)(uintptr_t handle);
    /* Function pointer of native file system to obtain the current working
    * directory */
    int (*currWD)(char* buff, uint32_t len);
    /* Function pointer of native file system to set the current drive */
    int(*chdrive)(uint8_t drive);
    /* Function pointer of native file system to change the attribute for file
    * or directory */
    int(*chmode)(const char* path, uint8_t attr, uint8_t mask);
    /* Function pointer of native file system to change the time for a file or
    * directory */
    int(*chtime)(const char* path, uintptr_t ptr);
    /* Function pointer of native file system to rename a file or directory */
    int(*rename)(const char *oldPath, const char *newPath);
    /* Function pointer of native file system to flush file */
    int(*sync)(uintptr_t fp);
    /* Function pointer of native file system to read a string from a file */
    char *(*getstrn)(char* buff, int len, uintptr_t handle);
    /* Function pointer of native file system to write a character into a file
    * */
    int(*putchr)(char c, uintptr_t handle);
    /* Function pointer of native file system to write a string into a file */
    int(*putstrn)(const char* str, uintptr_t handle);
    /* Function pointer of native file system to print a formatted string to
    * file */
    int(*formattedprint)(uintptr_t handle, const char *str, va_list argList);
    /* Function pointer of native file system to test an error in a file */
    bool(*testerror)(uintptr_t handle);
    /* Function pointer of native file system to format a disk */
    int(*formatDisk)(uint8_t vol, const SYS_FS_FORMAT_PARAM* opt, void* work, uint32_t len)
    /* Function pointer of native file system to open a directory */
    int(*openDir)(uintptr_t handle, const char *path);
    /* Function pointer of native file system to read a directory */
    int(*readDir)(uintptr_t handle, uintptr_t stat);
    /* Function pointer of native file system to close an opened directory */
    int(*closeDir)(uintptr_t handle);
    /* Function pointer of native file system to partition a physical drive */
    int(*partitionDisk)(uint8_t pdrv, const uint32_t szt[], void* work);
    /* Function pointer of native file system to get total sectors and free
    * sectors */
    int(*getCluster)(const char *path, uint32_t *tot_sec, uint32_t *free_sec);
} SYS_FS_FUNCTIONS;

```

## Summary

SYS FS Function signature structure for native file systems.

## Description

The SYS FS layer supports functions from each native file system layer. This<br />structure specifies the signature for each function from native file system<br />\(parameter that needs to be passed to each function and return type for each<br />function\). If a new native file system is to be integrated with the SYS FS<br />layer, the functions should follow the signature.

The structure of function pointer for the supported native file systems<br />is already populated in the initialization.c file. Hence the following<br />structure is not immediately useful for the user. But the explanation for<br />the structure is still provided for advanced users who would wish to<br />integrate a new native file system to the MPLAB Harmony File System framework.

## Remarks

None.

