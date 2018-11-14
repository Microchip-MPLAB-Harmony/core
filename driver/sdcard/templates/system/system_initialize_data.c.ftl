const DRV_SDCARD_INIT drvSDCard${INDEX?string}InitData =
{
    .initialize = ${DRV_SDCARD_PROTOCOL?upper_case}_Initialize,
    .open = ${DRV_SDCARD_PROTOCOL?upper_case}_Open,
    .close = ${DRV_SDCARD_PROTOCOL?upper_case}_Close,
    .status = ${DRV_SDCARD_PROTOCOL?upper_case}_Status,
    .tasks = ${DRV_SDCARD_PROTOCOL?upper_case}_Tasks,
    .eventHandlerSet = ${DRV_SDCARD_PROTOCOL?upper_case}_EventHandlerSet,
    .commandStatus = (void*)${DRV_SDCARD_PROTOCOL?upper_case}_CommandStatus,
    .geometryGet = ${DRV_SDCARD_PROTOCOL?upper_case}_GeometryGet,
    .isAttached = ${DRV_SDCARD_PROTOCOL?upper_case}_IsAttached,
    .isWriteProtected = ${DRV_SDCARD_PROTOCOL?upper_case}_IsWriteProtected,
<#if DRV_SDCARD_SELECT_PROTOCOL == "SDSPI">
    .readSync = ${DRV_SDCARD_PROTOCOL?upper_case}_SyncRead,
    .writeSync = ${DRV_SDCARD_PROTOCOL?upper_case}_SyncWrite,
    .readAsync = NULL,
    .writeAsync = NULL,
    <#if DRV_SDCARD_FS_ENABLE == true>
        <#lt>    .fsRead = ${DRV_SDCARD_PROTOCOL?upper_case}_FS_Read,
        <#lt>    .fsWrite = ${DRV_SDCARD_PROTOCOL?upper_case}_FS_Write,
    <#else>
        <#lt>    .fsRead = NULL,
        <#lt>    .fsWrite = NULL,
    </#if>
    .sdDriverInitData = (const SYS_MODULE_INIT *)&drvSDSPI${INDEX?string}InitData,
<#elseif DRV_SDCARD_SELECT_PROTOCOL == "SDHC">
    .readSync = NULL,
    .writeSync = NULL,
    .readAsync = ${DRV_SDCARD_PROTOCOL?upper_case}_Read,
    .writeAsync = ${DRV_SDCARD_PROTOCOL?upper_case}_Write,
    <#if DRV_SDCARD_FS_ENABLE == true>
        <#lt>    .fsRead = ${DRV_SDCARD_PROTOCOL?upper_case}_Read,
        <#lt>    .fsWrite = ${DRV_SDCARD_PROTOCOL?upper_case}_Write,
    <#else>
        <#lt>    .fsRead = NULL,
        <#lt>    .fsWrite = NULL,
    </#if>
    .sdDriverInitData = (SYS_MODULE_INIT *)&drvSDHCInitData,
</#if>
    .isFsEnabled = ${DRV_SDCARD_FS_ENABLE?c},
};
