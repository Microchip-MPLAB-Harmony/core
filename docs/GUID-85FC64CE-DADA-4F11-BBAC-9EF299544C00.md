# SYS\_FS\_DirRewind Function

**Parent topic:**[Library Interface](GUID-42556FDF-A632-49FE-8A5E-9303A926578C.md)

## C

```c
SYS_FS_RESULT SYS_FS_DirRewind
(
    SYS_FS_HANDLE handle
);
```

## Summary

Rewinds to the beginning of the directory.

## Description

This function rewinds the directory to the start. Once a search of<br />directory or directory read is completed, the rewind function is used to<br />begin searching the directory from the start.

## Precondition

A valid directory handle must be obtained before reading a directory.

## Parameters

|Param|Description|
|-----|-----------|
|handle|directory handle obtained during directory open.|

## Returns

*SYS\_FS\_RES\_SUCCESS* - Directory rewind operation was successful.

*SYS\_FS\_RES\_FAILURE* - Directory rewind operation was unsuccessful. The<br />reason for the failure can be retrieved with SYS\_FS\_Error or SYS\_FS\_FileError.

## Example

```c
SYS_FS_HANDLE dirHandle;
SYS_FS_FSTAT stat;

dirHandle = SYS_FS_DirOpen("/mnt/myDrive/Dir1");

if(dirHandle != SYS_FS_HANDLE_INVALID)
{
    // Directory open is successful
}

if(SYS_FS_DirRead(dirHandle, &stat) == SYS_FS_RES_FAILURE)
{
    // Directory read operation failed.
}

// Do more search
// Do some more search

// Now, rewind the directory to begin search from start

if(SYS_FS_DirRewind(dirHandle) == SYS_FS_RES_FAILURE)
{
    // Directory rewind failed.
}
```

## Remarks

None.

