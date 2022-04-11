// <editor-fold defaultstate="collapsed" desc="DRV_SST26 Initialization Data">

<#if DRV_SST26_INTERFACE_TYPE == "SQI_PLIB" >
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

    <#lt>const DRV_SST26_INIT drvSST26InitData =
    <#lt>{
    <#lt>    .sst26Plib      = &drvSST26PlibAPI,
    <#lt>};
<#elseif DRV_SST26_INTERFACE_TYPE == "SPI_PLIB" >
    <#lt>const DRV_SST26_PLIB_INTERFACE drvSST26PlibAPI = {
    <#lt>    .writeRead          = (DRV_SST26_PLIB_WRITE_READ)${.vars["${DRV_SST26_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_WriteRead,
    <#lt>    .write              = (DRV_SST26_PLIB_WRITE)${.vars["${DRV_SST26_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_Write,
    <#lt>    .read               = (DRV_SST26_PLIB_READ)${.vars["${DRV_SST26_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_Read,
    <#lt>    .isBusy             = (DRV_SST26_PLIB_IS_BUSY)${.vars["${DRV_SST26_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_IsBusy,
    <#lt>    .callbackRegister   = (DRV_SST26_PLIB_CALLBACK_REGISTER)${.vars["${DRV_SST26_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_CallbackRegister,
    <#lt>};

    <#lt>const DRV_SST26_INIT drvSST26InitData =
    <#lt>{
    <#lt>    .sst26Plib      = &drvSST26PlibAPI,
    <#lt>    .chipSelectPin  = DRV_SST26_CHIP_SELECT_PIN,
<#if DRV_SST26_TX_RX_DMA == true>
    <#lt>    /* DMA Channel for Transmit */
    <#lt>    .txDMAChannel = DRV_SST26_XMIT_DMA_CH,

    <#lt>    /* DMA Channel for Receive */
    <#lt>    .rxDMAChannel  = DRV_SST26_RCV_DMA_CH,

    <#lt>    /* SPI Transmit Register */
    <#lt>    .txAddress =  (void *)${.vars["${DRV_SST26_PLIB?lower_case}"].TRANSMIT_DATA_REGISTER},

    <#lt>    /* SPI Receive Register */
    <#lt>    .rxAddress  = (void *)${.vars["${DRV_SST26_PLIB?lower_case}"].RECEIVE_DATA_REGISTER},
</#if>
    <#lt>};
<#elseif DRV_SST26_INTERFACE_TYPE == "SPI_DRV" >
    <#lt>const DRV_SST26_INIT drvSST26InitData =
    <#lt>{
    <#lt>    .chipSelectPin  = DRV_SST26_CHIP_SELECT_PIN,
    <#lt>    .spiDrvIndex    = ${DRV_SST26_SPI_DRIVER_INSTANCE},
    <#lt>};
</#if>
// </editor-fold>
