// <editor-fold defaultstate="collapsed" desc="DRV_SST26 Initialization Data">

<#if DRV_SST26_PLIB?contains("QSPI") >
    <#lt>const DRV_SST26_PLIB_INTERFACE drvSST26PlibAPI = {
    <#lt>    .CommandWrite   = ${DRV_SST26_PLIB}_CommandWrite,
    <#lt>    .RegisterRead   = ${DRV_SST26_PLIB}_RegisterRead,
    <#lt>    .RegisterWrite  = ${DRV_SST26_PLIB}_RegisterWrite,
    <#lt>    .MemoryRead     = ${DRV_SST26_PLIB}_MemoryRead,
    <#lt>    .MemoryWrite    = ${DRV_SST26_PLIB}_MemoryWrite
    <#lt>};
<#elseif DRV_SST26_PLIB?contains("SQI") >
    <#lt>const DRV_SST26_PLIB_INTERFACE drvSST26PlibAPI = {
    <#lt>    .DMATransfer       = ${DRV_SST26_PLIB}_DMATransfer,
    <#lt>    .RegisterCallback  = ${DRV_SST26_PLIB}_RegisterCallback,
    <#lt>};
</#if>

const DRV_SST26_INIT drvSST26InitData =
{
    .sst26Plib      = &drvSST26PlibAPI,
};

// </editor-fold>
