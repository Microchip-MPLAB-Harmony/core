// <editor-fold defaultstate="collapsed" desc="DRV_MEMORY Instance ${INDEX?string} Initialization Data">

uint8_t gDrvMemory${INDEX?string}EraseBuffer[DRV_MEMORY_ERASE_BUFFER_SIZE_IDX${INDEX?string}] __attribute__((aligned(32)));

DRV_MEMORY_BUFFER_OBJECT gDrvMemory${INDEX?string}BufferObject[DRV_MEMORY_BUFFER_QUEUE_SIZE_IDX${INDEX?string}] = { 0 };

DRV_MEMORY_CLIENT_OBJECT gDrvMemory${INDEX?string}ClientObject[DRV_MEMORY_CLIENTS_NUMBER_IDX${INDEX?string}] = { 0 };

const MEMORY_DEVICE_API drvMemory${INDEX?string}DeviceAPI = {
    .SectorErase        = ${DRV_MEMORY_DEVICE}_SectorErase,
    .Read               = ${DRV_MEMORY_DEVICE}_Read,
    .PageWrite          = ${DRV_MEMORY_DEVICE}_PageWrite,
    .GeometryGet        = (GEOMETRY_GET)${DRV_MEMORY_DEVICE}_GeometryGet,
    .TransferStatusGet  = (TRANSFER_STATUS_GET)${DRV_MEMORY_DEVICE}_TransferStatusGet
};

const DRV_MEMORY_INIT drvMemory${INDEX?string}InitData =
{
    .memoryDevice         = &drvMemory${INDEX?string}DeviceAPI,
<#if DRV_MEMORY_FS_ENABLE >
    .deviceMediaType      = (uint8_t)${DRV_MEMORY_DEVICE_TYPE},
</#if>
    .inInterruptMode      = ${DRV_MEMORY_INTERRUPT_ENABLE?string},
<#if DRV_MEMORY_INTERRUPT_ENABLE >
    .interruptSource      = DRV_MEMORY_INT_SRC_IDX${INDEX?string},
</#if>
    .ewBuffer             = &gDrvMemory${INDEX?string}EraseBuffer[0],
    .bufferObj            = (uintptr_t)&gDrvMemory${INDEX?string}BufferObject[0],
    .clientObjPool        = (uintptr_t)&gDrvMemory${INDEX?string}ClientObject[0],
    .queueSize            = DRV_MEMORY_BUFFER_QUEUE_SIZE_IDX${INDEX?string},
    .nClientsMax          = DRV_MEMORY_CLIENTS_NUMBER_IDX${INDEX?string}
};

// </editor-fold>