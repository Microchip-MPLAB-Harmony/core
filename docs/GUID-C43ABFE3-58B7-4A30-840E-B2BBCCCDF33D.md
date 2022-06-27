# SYS\_FS\_DirRead Function

**Parent topic:**[Library Interface](GUID-42556FDF-A632-49FE-8A5E-9303A926578C.md)

## C

```c
SYS_FS_RESULT SYS_FS_DirRead
(
SYS_FS_HANDLE handle,
SYS_FS_FSTAT *stat
);
```

## Summary

Reads the files and directories of the specified directory.

## Description

This function reads the files and directories specified in the open<br />directory.

The file system supports 8.3 file name\(Short File Name\) and<br />also long file name. 8.3 filenames are limited to at most eight<br />characters, followed optionally by a filename extension<br />consisting of a period . and at most three further characters.<br />If the file name fits within the 8.3 limits then generally<br />there will be no valid LFN for it.

**For FAT File system**

-   If LFN is used the stat structure's altname field<br />will contain the short file name and fname will contain the long file name.<br />The "lfname" member of the SYS\_FS\_FSTAT is not applicable for FAT. It has to be<br />initialized to NULL before calling the API. If "lfname" is not NULL, then<br />first byte of lfname will be set to zero indicating no file found.


**For other File systems based on thier implementation**<br />-If LFN is used then the "lfname" member of the SYS\_FS\_FSTAT structure should be<br />initialized with the address of a suitable buffer and the "lfsize"<br />should be initialized with the size of the buffer. Once the function<br />returns, the buffer whose address is held in "lfname" will have<br />the file name\(long file name\).

-   The stat structure's fname field will contain the SFN and if<br />there is a valid LFN entry for the file then the long file name<br />will be copied into lfname member of the structure.


## Precondition

A valid directory handle must be obtained before reading a directory.

## Parameters

|Param|Description|
|-----|-----------|
|handle|Directory handle obtained during directory open.|
|stat|Pointer to SYS\_FS\_FSTAT, where the properties of the open directory will be populated after the SYS\_FS\_DirRead function returns successfully.|

## Returns

*SYS\_FS\_RES\_SUCCESS* - Indicates that the directory read operation was<br />successful. End of the directory condition is indicated by setting the fname and lfname\(if lfname is used\) fields of the SYS\_FS\_FSTAT structure to '\\0'

*SYS\_FS\_RES\_FAILURE* - Indicates that the directory read operation was<br />unsuccessful. The reason for the failure can be retrieved with SYS\_FS\_Error or SYS\_FS\_FileError.

## Example

```c
// For FAT File System

SYS_FS_HANDLE dirHandle;
SYS_FS_FSTAT stat;

dirHandle = SYS_FS_DirOpen("/mnt/myDrive/Dir1");

if(dirHandle != SYS_FS_HANDLE_INVALID)
{
    // Directory open is successful
}

if(SYS_FS_DirRead(dirHandle, &stat) == SYS_FS_RES_FAILURE)
{
    // Directory read failed.
}
else
{
    // Directory read succeeded.
    if (stat.fname[0] == '\0')
    {
        // reached the end of the directory.
    }
    else
    {
        // continue reading the directory.
    }
    
}
```

```c
// For other File Systems with LFN support

SYS_FS_HANDLE dirHandle;
SYS_FS_FSTAT stat;

char CACHE_ALIGN longFileName[512];

dirHandle = SYS_FS_DirOpen("/mnt/myDrive/Dir1");

if(dirHandle != SYS_FS_HANDLE_INVALID)
{
    // Directory open is successful
}

// If long file name is used, the following elements of the "stat"
// structure needs to be initialized with address of proper buffer.
stat.lfname = longFileName;
stat.lfsize = 512;

if(SYS_FS_DirRead(dirHandle, &stat) == SYS_FS_RES_FAILURE)
{
    // Directory read failed.
}
else
{
    // Directory read succeeded.
    if ((stat.lfname[0] == '\0') && (stat.fname[0] == '\0'))
    {
        // reached the end of the directory.
    }
    else
    {
        // continue reading the directory.
    }
    
}
```

## Remarks

None.

