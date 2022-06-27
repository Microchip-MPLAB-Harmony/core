# SYS\_FS\_FileCharacterPut Function

**Parent topic:**[Library Interface](GUID-42556FDF-A632-49FE-8A5E-9303A926578C.md)

## C

```c
SYS_FS_RESULT SYS_FS_FileCharacterPut
(
    SYS_FS_HANDLE handle,
    char data
);
```

## Summary

Writes a character to a file.

## Description

This function writes a character to a file.

## Precondition

The file into which a character has to be written, has to be present and should have been opened.

## Parameters

|Param|Description|
|-----|-----------|
|handle|file handle to which the character is to be written.|
|data|character to be written to the file.|

## Returns

*SYS\_FS\_RES\_SUCCESS* - Write operation was successful.

*SYS\_FS\_RES\_FAILURE* - Write operation was unsuccessful. The reason for<br />the failure can be retrieved with SYS\_FS\_Error or SYS\_FS\_FileError.

## Example

```c
SYS_FS_RESULT res;
SYS_FS_HANDLE fileHandle;

fileHandle = SYS_FS_FileOpen("/mnt/myDrive/FILE.txt", (SYS_FS_FILE_OPEN_WRITE_PLUS));

if(fileHandle != SYS_FS_HANDLE_INVALID)
{
    // File open is successful
}

// Write a character to the file.
res = SYS_FS_FileCharacterPut(fileHandle, 'c');

if(res != SYS_FS_RES_SUCCESS)
{
    // Character write operation failed.
}
```

## Remarks

None.

