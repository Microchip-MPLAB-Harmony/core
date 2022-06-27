# SYS\_FS\_FileNameGet Function

**Parent topic:**[Library Interface](GUID-42556FDF-A632-49FE-8A5E-9303A926578C.md)

## C

```c
bool SYS_FS_FileNameGet
(
    SYS_FS_HANDLE handle,
    uint8_t* cName,
    uint16_t wLen
);
```

## Summary

Reads the file name.

## Description

This function reads the file name of a file that is already open.

## Precondition

The file handle referenced by handle is already open.

## Parameters

|Param|Description|
|-----|-----------|
|handle|File handle obtained during file Open.|
|cName|Where to store the name of the file.|
|wLen|The maximum length of data to store in cName.|

## Returns

*true* - if the file name was read successfully.

*false* - if the file name was not read successfully. The reason for<br />the failure can be retrieved with SYS\_FS\_Error.

## Example

```c
SYS_FS_HANDLE fileHandle;
bool stat;
uint8_t fileName[255];

fileHandle = SYS_FS_FileOpen("/mnt/myDrive/FILE.txt", (SYS_FS_FILE_OPEN_READ));

if(fileHandle != SYS_FS_HANDLE_INVALID)
{
    // File open is successful
}
...
...

stat = SYS_FS_FileNameGet(fileHandle, fileName, 8 );

if(stat == false)
{
    // file not located based on handle passed
    // Check the error state using SYS_FS_FileError
}
```

## Remarks

None.

