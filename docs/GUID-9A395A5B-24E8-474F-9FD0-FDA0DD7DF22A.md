# SYS\_FS\_CurrentDriveSet Function

**Parent topic:**[Library Interface](GUID-42556FDF-A632-49FE-8A5E-9303A926578C.md)

## C

```c
SYS_FS_RESULT SYS_FS_CurrentDriveSet
(
    const char* path
);
```

## Summary

Sets the drive.

## Description

This function sets the present drive to the one as specified by the path.<br />By default, the drive mounted last becomes the current drive for the<br />system. This is useful for applications where only one drive \(volume\) is<br />used. In such an application, there is no need to call the<br />SYS\_FS\_CurrentDriveSet function.

However, in the case of an application where there are multiple volumes,<br />the user can select the current drive for the application by calling this function.

## Precondition

The disk has to be mounted.

## Parameters

|Param|Description|
|-----|-----------|
|path|Path for the drive to be set.|

## Returns

*SYS\_FS\_RES\_SUCCESS* - Current drive set operation was successful.

*SYS\_FS\_RES\_FAILURE* - Current drive set operation was unsuccessful. The<br />reason for the failure can be retrieved with SYS\_FS\_Error.

## Example

```c
SYS_FS_RESULT res;

res = SYS_FS_CurrentDriveSet("/mnt/myDrive");
if(res == SYS_FS_RES_FAILURE)
{
    // Drive change failed
}
```

## Remarks

None.

