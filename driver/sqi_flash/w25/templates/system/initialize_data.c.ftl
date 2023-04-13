// <editor-fold defaultstate="collapsed" desc="DRV_W25 Initialization Data">

<#if DRV_W25_PLIB?contains("QMSPI") >
	<#lt>static const DRV_W25_PLIB_INTERFACE drvW25PlibAPI = {
	<#lt>    .Write               = ${DRV_W25_PLIB}_Write,
	<#lt>    .Read                = ${DRV_W25_PLIB}_Read,
	<#lt>    .DMATransferRead     = ${DRV_W25_PLIB}_DMATransferRead,
	<#lt>    .DMATransferWrite    = ${DRV_W25_PLIB}_DMATransferWrite
	<#lt>};
</#if>

static const DRV_W25_INIT drvW25InitData =
{
    .w25Plib      = &drvW25PlibAPI,
};
// </editor-fold>
