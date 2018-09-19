// <editor-fold defaultstate="collapsed" desc="DRV_MEMORY Instance ${INDEX?string} Initialization Data">

<#if DRV_MEMORY_ERASE_ENABLE >
    <#lt>uint8_t gDrvMemory${INDEX?string}EraseBuffer[${DRV_MEMORY_DEVICE}_ERASE_BUFFER_SIZE] __attribute__((aligned(32)));
</#if>

DRV_MEMORY_CLIENT_OBJECT gDrvMemory${INDEX?string}ClientObject[DRV_MEMORY_CLIENTS_NUMBER_IDX${INDEX?string}] = { 0 };

<#if drv_memory.DRV_MEMORY_COMMON_MODE == "ASYNC" >
    <#lt>DRV_MEMORY_BUFFER_OBJECT gDrvMemory${INDEX?string}BufferObject[DRV_MEMORY_BUFFER_QUEUE_SIZE_IDX${INDEX?string}] = { 0 };
</#if>

<#if DRV_MEMORY_PLIB?has_content >
    <#lt>const MEMORY_DEVICE_API drvMemory${INDEX?string}DeviceAPI = {
    <#lt>    .Open               = ${DRV_MEMORY_PLIB}_Open,
    <#lt>    .Close              = ${DRV_MEMORY_PLIB}_Close,
    <#lt>    .Status             = ${DRV_MEMORY_PLIB}_Status,
    <#lt><#if DRV_MEMORY_ERASE_ENABLE >
    <#lt>    .SectorErase        = ${DRV_MEMORY_PLIB}_SectorErase,
    <#lt><#else>
    <#lt>    .SectorErase        = NULL,
    <#lt></#if>
    <#lt>    .Read               = ${DRV_MEMORY_PLIB}_Read,
    <#lt>    .PageWrite          = ${DRV_MEMORY_PLIB}_PageWrite,
    <#lt><#if DRV_MEMORY_INTERRUPT_ENABLE >
    <#lt>    .EventHandlerSet    = ${DRV_MEMORY_PLIB}_EventHandlerSet,
    <#lt><#else>
    <#lt>    .EventHandlerSet    = NULL,
    <#lt></#if>
    <#lt>    .GeometryGet        = (GEOMETRY_GET)${DRV_MEMORY_PLIB}_GeometryGet,
    <#lt>    .TransferStatusGet  = (TRANSFER_STATUS_GET)${DRV_MEMORY_PLIB}_TransferStatusGet
    <#lt>};
<#else>
    <#lt>const MEMORY_DEVICE_API drvMemory${INDEX?string}DeviceAPI = {
    <#lt>    .Open               = ${DRV_MEMORY_DEVICE}_Open,
    <#lt>    .Close              = ${DRV_MEMORY_DEVICE}_Close,
    <#lt>    .Status             = ${DRV_MEMORY_DEVICE}_Status,
    <#lt><#if DRV_MEMORY_ERASE_ENABLE >
    <#lt>    .SectorErase        = ${DRV_MEMORY_DEVICE}_SectorErase,
    <#lt><#else>
    <#lt>    .SectorErase        = NULL,
    <#lt></#if>
    <#lt>    .Read               = ${DRV_MEMORY_DEVICE}_Read,
    <#lt>    .PageWrite          = ${DRV_MEMORY_DEVICE}_PageWrite,
    <#lt><#if DRV_MEMORY_INTERRUPT_ENABLE >
    <#lt>    .EventHandlerSet    = ${DRV_MEMORY_DEVICE}_EventHandlerSet,
    <#lt><#else>
    <#lt>    .EventHandlerSet    = NULL,
    <#lt></#if>
    <#lt>    .GeometryGet        = (GEOMETRY_GET)${DRV_MEMORY_DEVICE}_GeometryGet,
    <#lt>    .TransferStatusGet  = (TRANSFER_STATUS_GET)${DRV_MEMORY_DEVICE}_TransferStatusGet
    <#lt>};
</#if>

const DRV_MEMORY_INIT drvMemory${INDEX?string}InitData =
{
<#if DRV_MEMORY_PLIB?has_content >
    .memDevIndex                = 0,
<#else>
    .memDevIndex                = ${DRV_MEMORY_DEVICE}_INDEX,
</#if>
    .memoryDevice               = &drvMemory${INDEX?string}DeviceAPI,
<#if DRV_MEMORY_INTERRUPT_ENABLE >
    .isMemDevInterruptEnabled   = true,
    <#if drv_memory.DRV_MEMORY_COMMON_SYS_TIME_ENABLE >
        <#lt>    .memDevStatusPollUs         = 0,
    </#if>
<#else>
    .isMemDevInterruptEnabled   = false,
    <#if drv_memory.DRV_MEMORY_COMMON_SYS_TIME_ENABLE >
        <#lt>    .memDevStatusPollUs         = ${DRV_MEMORY_DEVICE_POLL_US},
    </#if>
</#if>
<#if DRV_MEMORY_FS_ENABLE >
    .isFsEnabled                = true,
    .deviceMediaType            = (uint8_t)${DRV_MEMORY_DEVICE_TYPE},
<#else>
    .isFsEnabled                = false,
</#if>
<#if DRV_MEMORY_ERASE_ENABLE >
    .ewBuffer                   = &gDrvMemory${INDEX?string}EraseBuffer[0],
<#else>
    .ewBuffer                   = NULL,
</#if>
    .clientObjPool              = (uintptr_t)&gDrvMemory${INDEX?string}ClientObject[0],
<#if drv_memory.DRV_MEMORY_COMMON_MODE == "ASYNC" >
    .bufferObj                  = (uintptr_t)&gDrvMemory${INDEX?string}BufferObject[0],
    .queueSize                  = DRV_MEMORY_BUFFER_QUEUE_SIZE_IDX${INDEX?string},
</#if>
    .nClientsMax                = DRV_MEMORY_CLIENTS_NUMBER_IDX${INDEX?string}
};

// </editor-fold>