// <editor-fold defaultstate="collapsed" desc="DRV_SFDP Initialization Data">

<#if DRV_SFDP_INTERFACE_TYPE == "SQI_PLIB" >
    <#if DRV_SFDP_PLIB?contains("QSPI") >
        <#lt>static const DRV_SFDP_PLIB_INTERFACE drvSFDPPlibAPI = {
        <#lt>    .CommandWrite   = ${DRV_SFDP_PLIB}_CommandWrite,
        <#lt>    .RegisterRead   = ${DRV_SFDP_PLIB}_RegisterRead,
        <#lt>    .RegisterWrite  = ${DRV_SFDP_PLIB}_RegisterWrite,
        <#lt>    .MemoryRead     = ${DRV_SFDP_PLIB}_MemoryRead,
        <#lt>    .MemoryWrite    = ${DRV_SFDP_PLIB}_MemoryWrite
        <#lt>};
    <#elseif DRV_SFDP_PLIB?contains("SQI") >
        <#lt>static const DRV_SFDP_PLIB_INTERFACE drvSFDPPlibAPI = {
        <#lt>    .DMATransfer       = ${DRV_SFDP_PLIB}_DMATransfer,
        <#lt>    .RegisterCallback  = ${DRV_SFDP_PLIB}_RegisterCallback,
        <#lt>};
    </#if>

    <#lt>static const DRV_SFDP_INIT drvSFDPInitData =
    <#lt>{
    <#lt>    .sfdpPlib      = &drvSFDPPlibAPI,
    <#lt>};
<#elseif DRV_SFDP_INTERFACE_TYPE == "SPI_PLIB" >
    <#lt>static const DRV_SFDP_PLIB_INTERFACE drvSFDPPlibAPI = {
    <#lt>    .writeRead          = (DRV_SFDP_PLIB_WRITE_READ)${.vars["${DRV_SFDP_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_WriteRead,
    <#lt>    .write_t              = (DRV_SFDP_PLIB_WRITE)${.vars["${DRV_SFDP_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_Write,
    <#lt>    .read_t               = (DRV_SFDP_PLIB_READ)${.vars["${DRV_SFDP_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_Read,
    <#lt>    .isBusy             = (DRV_SFDP_PLIB_IS_BUSY)${.vars["${DRV_SFDP_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_IsBusy,
    <#lt>    .callbackRegister   = (DRV_SFDP_PLIB_CALLBACK_REGISTER)${.vars["${DRV_SFDP_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_CallbackRegister,
    <#lt>};

    <#lt>static const DRV_SFDP_INIT drvSFDPInitData =
    <#lt>{
    <#lt>    .sfdpPlib      = &drvSFDPPlibAPI,
    <#lt>    .chipSelectPin  = DRV_SFDP_CHIP_SELECT_PIN,
<#if DRV_SFDP_TX_RX_DMA == true>
    <#lt>    /* DMA Channel for Transmit */
    <#lt>    .txDMAChannel = DRV_SFDP_XMIT_DMA_CH,

    <#lt>    /* DMA Channel for Receive */
    <#lt>    .rxDMAChannel  = DRV_SFDP_RCV_DMA_CH,

    <#lt>    /* SPI Transmit Register */
    <#lt>    .txAddress =  (void *)${.vars["${DRV_SFDP_PLIB?lower_case}"].TRANSMIT_DATA_REGISTER},

    <#lt>    /* SPI Receive Register */
    <#lt>    .rxAddress  = (void *)${.vars["${DRV_SFDP_PLIB?lower_case}"].RECEIVE_DATA_REGISTER},
</#if>
    <#lt>};
<#elseif DRV_SFDP_INTERFACE_TYPE == "SPI_DRV" >
    <#lt>static const DRV_SFDP_INIT drvSFDPInitData =
    <#lt>{
    <#lt>    .chipSelectPin  = DRV_SFDP_CHIP_SELECT_PIN,
    <#lt>    .spiDrvIndex    = ${DRV_SFDP_SPI_DRIVER_INSTANCE},
    <#lt>};
</#if>
// </editor-fold>
