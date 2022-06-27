# DRV\_MEMORY\_DEVICE\_INTERFACE Struct

**Parent topic:**[Library Interface](GUID-E18B0923-4286-4E08-A2EB-9A482E0063AE.md)

## C

```c
/* Function pointer typedef to open the attached media */
typedef DRV_HANDLE (*DRV_MEMORY_DEVICE_OPEN)( const SYS_MODULE_INDEX drvIndex, const DRV_IO_INTENT ioIntent );

/* Function pointer typedef to close the attached media */
typedef void (*DRV_MEMORY_DEVICE_CLOSE)( const DRV_HANDLE handle );

/* Function pointer typedef to erase a sector from attached media */
typedef bool (*DRV_MEMORY_DEVICE_SECTOR_ERASE)( const DRV_HANDLE handle, uint32_t address);

/* Function pointer typedef to get the status of the attached media */
typedef SYS_STATUS (*DRV_MEMORY_DEVICE_STATUS)( const SYS_MODULE_INDEX drvIndex );

/* Function pointer typedef to read from the attached media */
typedef bool (*DRV_MEMORY_DEVICE_READ)( const DRV_HANDLE handle, void *rx_data, uint32_t rx_data_length, uint32_t address );

/* Function pointer typedef to write a page to the attached media */
typedef bool (*DRV_MEMORY_DEVICE_PAGE_WRITE)( const DRV_HANDLE handle, void *tx_data, uint32_t address );

/* Function pointer typedef to get the Geometry details from attached media */
typedef bool (*DRV_MEMORY_DEVICE_GEOMETRY_GET)( const DRV_HANDLE handle, MEMORY_DEVICE_GEOMETRY *geometry );

/* Function pointer typedef to get the transfer Status from attached media */
typedef uint32_t (*DRV_MEMORY_DEVICE_TRANSFER_STATUS_GET)( const DRV_HANDLE handle );

/* Function pointer typedef for event handler to be sent to attached media */
typedef void (*DRV_MEMORY_EVENT_HANDLER)( MEMORY_DEVICE_TRANSFER_STATUS status, uintptr_t context );

/* Function pointer typedef to set the event handler with attached media */
typedef void (*DRV_MEMORY_DEVICE_EVENT_HANDLER_SET) ( const DRV_HANDLE handle, DRV_MEMORY_EVENT_HANDLER eventHandler, uintptr_t context );

typedef struct
{
    DRV_MEMORY_DEVICE_OPEN Open;

    DRV_MEMORY_DEVICE_CLOSE Close;

    DRV_MEMORY_DEVICE_SECTOR_ERASE SectorErase;

    DRV_MEMORY_DEVICE_STATUS Status;

    DRV_MEMORY_DEVICE_READ Read;

    DRV_MEMORY_DEVICE_PAGE_WRITE PageWrite;

    DRV_MEMORY_DEVICE_EVENT_HANDLER_SET EventHandlerSet;

    DRV_MEMORY_DEVICE_GEOMETRY_GET GeometryGet;

    DRV_MEMORY_DEVICE_TRANSFER_STATUS_GET TransferStatusGet;
} DRV_MEMORY_DEVICE_INTERFACE;

```

## Summary

Memory Device API Interface.

## Description

This Data Structure is used by attached media to populate the<br />required device functions for media transactions.

This will be used in memory driver init structure.

## Remarks

None.

