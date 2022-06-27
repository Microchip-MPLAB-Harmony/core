# DRV\_I2C\_TRANSFER\_HANDLE Typedef

**Parent topic:**[Library Interface](GUID-5A5146D2-73C2-43B1-8ADE-95E0184AF1A5.md)

## C

```c
typedef uintptr_t DRV_I2C_TRANSFER_HANDLE;

```

## Summary

Handle identifying a read, write or write followed by read transfer passed to the driver.

## Description

A transfer handle value is returned by a call to the DRV\_I2C\_ReadTransferAdd/<br />DRV\_I2C\_WriteTransferAdd or DRV\_I2C\_WriteReadTransferAdd functions. This<br />handle is associated with the transfer passed into the function and it allows<br />the application to track the completion of the data from \(or into\) that<br />transfer. The transfer handle value returned from the "transfer add" function<br />is returned back to the client by the "event handler callback" function<br />registered with the driver.

The transfer handle assigned to a client request expires when the client has<br />been notified of the completion of the buffer transfer \(after event handler<br />function that notifies the client returns\) or after the transfer has been<br />retired by the driver if no event handler callback was set.

## Remarks

None

