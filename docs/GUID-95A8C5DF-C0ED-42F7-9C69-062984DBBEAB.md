# SYS\_FS\_DrivePartition Function

**Parent topic:**[Library Interface](GUID-42556FDF-A632-49FE-8A5E-9303A926578C.md)

## C

```c
SYS_FS_RESULT SYS_FS_DrivePartition
(
    const char *path,
    const uint32_t partition[],
    void * work
);
```

## Summary

Partitions a physical drive \(media\).

## Description

This function partitions a physical drive \(media\) into requested<br />partition sizes. This function will alter the MBR of the physical drive<br />and make it into multi partitions. Windows operating systems do not<br />support multi partitioned removable media. Maximum 4 partitions can be<br />created on a media.

## Precondition

Prior to partitioning the media, the media should have a valid MBR and it should be mounted as a volume with the file system.

## Parameters

|Param|Description|
|-----|-----------|
|path|Path to the volume with the volume name. The string of volume name has to be preceded by "/mnt/". Also, the volume name and directory name has to be separated by a slash "/".|
|partition|Array with 4 items, where each items mentions the sizes of each partition in terms of number of sector. 0th element of array specifies the number of sectors for first partition and 3rd element of array specifies the number of sectors for fourth partition.|
|work|Pointer to the buffer for function work area. The size must be at least FAT\_FS\_MAX\_SS bytes.|

## Returns

*SYS\_FS\_RES\_SUCCESS* - Partition was successful.

*SYS\_FS\_RES\_FAILURE* - Partition was unsuccessful. The reason for the<br />failure can be retrieved with SYS\_FS\_Error.

## Example

```c
//============================================================================
// Initially, consider the case of a SD card that has only one partition.
//============================================================================
SYS_FS_RESULT res;

// Following 4 element array specifies the size of 2 partitions as
// 256MB (=524288 sectors). The 3rd and 4th partition are not created
// since, the sizes of those are zero.
uint32_t plist[] = {524288, 524288, 0, 0};

// Work area for function SYS_FS_DrivePartition
char work[FAT_FS_MAX_SS];

switch(appState)
{
    case TRY_MOUNT:
    {
        if(SYS_FS_Mount("/dev/mmcblka1", "/mnt/myDrive", FAT, 0, NULL) != SYS_FS_RES_SUCCESS)
        {
            // Failure, try mounting again
        }
        else
        {
            // Mount was successful. Partition now.
            appState = PARTITION_DRIVE;
        }
        break;
    }

    case PARTITION_DRIVE:
    {
        res = SYS_FS_DrivePartition("/mnt/myDrive", plist, work);
        if(res == SYS_FS_RES_FAILURE)
        {
            // Drive partition went wrong
        }
        else
        {
            // Partition was successful. Power cycle the board so that
            // all partitions are recognized. Then try mounting both
            // partitions.
        }
        break;
    }

    default:
    {
        break;
    }
}

//============================================================================
//The following code is after the SD card is partitioned and then
//powered ON.
//============================================================================
SYS_FS_RESULT res;

switch(appState)
{
    case TRY_MOUNT_1ST_PARTITION:
    {
        if(SYS_FS_Mount("/dev/mmcblka1", "/mnt/myDrive1", FAT, 0, NULL) != SYS_FS_RES_SUCCESS)
        {
            // Failure, try mounting again
            appState = TRY_MOUNT_1ST_PARTITION;
        }
        else
        {
            // Mount was successful. Mount second partition.
            appState = TRY_MOUNT_2ND_PARTITION;
        }
        break;
    }

    case TRY_MOUNT_2ND_PARTITION:
    {
        if(SYS_FS_Mount("/dev/mmcblka2", "/mnt/myDrive2", FAT, 0, NULL) != SYS_FS_RES_SUCCESS)
        {
            // Failure, try mounting again
            appState = TRY_MOUNT_2ND_PARTITION;
        }
        else
        {
            // Mount was successful. Try formating first partition.
            appState = TRY_FORMATING_1ST_PARTITION;
        }
        break;
    }

    case TRY_FORMATING_1ST_PARTITION:
    {
        if(SYS_FS_DriveFormat("/mnt/myDrive1/", SYS_FS_FORMAT_FDISK, 0) == SYS_FS_RES_FAILURE)
        {
            // Failure
        }
        else
        {
            // Try formating second partitions.
            appState = TRY_FORMATING_2ND_PARTITION;
        }
        break;
    }

    case TRY_FORMATING_2ND_PARTITION:
    {
        if(SYS_FS_DriveFormat("/mnt/myDrive2/", SYS_FS_FORMAT_FDISK, 0) == SYS_FS_RES_FAILURE)
        {
            // Failure
        }
        else
        {
            // Use both partitions as 2 separate volumes.
        }
        break;
    }

    default:
    {
        break;
    }
}
```

## Remarks

None

