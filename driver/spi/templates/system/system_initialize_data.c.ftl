// <editor-fold defaultstate="collapsed" desc="DRV_SPI Instance ${INDEX?string} Initialization Data">

/* SPI Client Objects Pool */
static DRV_SPI_CLIENT_OBJ drvSPI${INDEX}ClientObjPool[DRV_SPI_CLIENTS_NUMBER_IDX${INDEX?string}];
<#if DRV_SPI_MODE == "Asynchronous">

/* SPI Transfer Objects Pool */
static DRV_SPI_TRANSFER_OBJ drvSPI${INDEX?string}TransferObjPool[DRV_SPI_QUEUE_SIZE_IDX${INDEX?string}];
</#if>

/* SPI PLIB Interface Initialization */
const DRV_SPI_PLIB_INTERFACE drvSPI${INDEX?string}PlibAPI = {

    /* SPI PLIB Setup */
    .setup = (DRV_SPI_PLIB_SETUP)${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_TransferSetup,

    /* SPI PLIB WriteRead function */
    .writeRead = (DRV_SPI_PLIB_WRITE_READ)${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_WriteRead,

    /* SPI PLIB Transfer Status function */
    .isBusy = (DRV_SPI_PLIB_IS_BUSY)${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_IsBusy,

    /* SPI PLIB Callback Register */
    .callbackRegister = (DRV_SPI_PLIB_CALLBACK_REGISTER)${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_CallbackRegister,
};

<@compress single_line=true>
const uint32_t drvSPI${INDEX?string}remapDataBits[]=
{
    <#if .vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_8_BIT_MASK?has_content>
        ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_8_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_9_BIT_MASK?has_content>
        ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_9_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_10_BIT_MASK?has_content>
        ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_10_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_11_BIT_MASK?has_content>
        ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_11_BIT_MASK},
     <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_12_BIT_MASK?has_content>
        ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_12_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_13_BIT_MASK?has_content>
        ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_13_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_14_BIT_MASK?has_content>
        ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_14_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_15_BIT_MASK?has_content>
        ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_15_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_16_BIT_MASK?has_content>
        ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_16_BIT_MASK}
    <#else>
        0xFFFFFFFF
    </#if>
};
</@compress>

<@compress single_line=true>
const uint32_t drvSPI${INDEX?string}remapClockPolarity[] =
{
    ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CLOCK_POLARITY_LOW_MASK},
    ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CLOCK_POLARITY_HIGH_MASK}
};
</@compress>

<@compress single_line=true>
const uint32_t drvSPI${INDEX?string}remapClockPhase[] =
{
    ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CLOCK_PHASE_TRAILING_MASK},
    ${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CLOCK_PHASE_LEADING_MASK}
};
</@compress>

<#if DRV_SPI_MODE == "Asynchronous">
    <#if core.DMA_ENABLE?has_content>
        <#assign DMA_PLIB = "core.DMA_INSTANCE_NAME">
        <#assign DMA_PLIB_MULTI_IRQn = "core." + DMA_PLIB?eval + "_MULTI_IRQn">
        <#if DMA_PLIB_MULTI_IRQn?eval??>
            <#assign DMA_TX_CHANNEL = "DRV_SPI_TX_DMA_CHANNEL">
            <#assign DMA_TX_CHANNEL_INDEX = "core." + DMA_PLIB?eval + "_CHANNEL" + DMA_TX_CHANNEL?eval + "_INT_SRC">
            <#assign DMA_RX_CHANNEL = "DRV_SPI_RX_DMA_CHANNEL">
            <#assign DMA_RX_CHANNEL_INDEX = "core." + DMA_PLIB?eval + "_CHANNEL" + DMA_RX_CHANNEL?eval + "_INT_SRC">
        </#if>
    </#if>
    <#assign SPI_PLIB = "DRV_SPI_PLIB">
    <#assign SPI_PLIB_MULTI_IRQn = "core." + SPI_PLIB?eval + "_MULTI_IRQn">
    <#assign SPI_PLIB_SINGLE_IRQn = "core." + SPI_PLIB?eval + "_SINGLE_IRQn">
    <#if SPI_PLIB_MULTI_IRQn?eval??>
        <#assign SPI_PLIB_TX_READY_INDEX = "core." + SPI_PLIB?eval + "_SPI_TX_READY_INT_SRC">
        <#assign SPI_PLIB_TX_COMPLETE_INDEX = "core." + SPI_PLIB?eval + "_SPI_TX_COMPLETE_INT_SRC">
        <#assign SPI_PLIB_RX_INDEX = "core." + SPI_PLIB?eval + "_SPI_RX_INT_SRC">
        <#assign SPI_PLIB_ERROR_INDEX = "core." + SPI_PLIB?eval + "_SPI_ERROR_INT_SRC">
    </#if>

const DRV_SPI_INTERRUPT_SOURCES drvSPI${INDEX?string}InterruptSources =
{
    <#if SPI_PLIB_MULTI_IRQn?eval??>
        <#lt>    /* Peripheral has more than one interrupt vectors */
        <#lt>    .isSingleIntSrc                        = false,

        <#lt>    /* Peripheral interrupt lines */
        <#if SPI_PLIB_TX_READY_INDEX?eval??>
            <#lt>    .intSources.multi.spiTxReadyInt      = ${SPI_PLIB_TX_READY_INDEX?eval},
        <#else>
            <#lt>    .intSources.multi.spiTxReadyInt      = -1,
        </#if>
        <#if SPI_PLIB_TX_COMPLETE_INDEX?eval??>
            <#lt>    .intSources.multi.spiTxCompleteInt   = ${SPI_PLIB_TX_COMPLETE_INDEX?eval},
        <#else>
            <#lt>    .intSources.multi.spiTxCompleteInt   = -1,
        </#if>
        <#if SPI_PLIB_RX_INDEX?eval??>
            <#lt>    .intSources.multi.spiRxInt           = ${SPI_PLIB_RX_INDEX?eval},
        <#else>
            <#lt>    .intSources.multi.spiRxInt           = -1,
        </#if>
    <#else>
        <#lt>    /* Peripheral has single interrupt vector */
        <#lt>    .isSingleIntSrc                        = true,

        <#lt>    /* Peripheral interrupt line */
        <#if SPI_PLIB_SINGLE_IRQn?eval??>
            <#lt>    .intSources.spiInterrupt             = ${SPI_PLIB_SINGLE_IRQn?eval},
        <#else>
            <#lt>    .intSources.spiInterrupt             = ${DRV_SPI_PLIB}_IRQn,
        </#if>
    </#if>
    <#if core.DMA_ENABLE?has_content>
        <#if DMA_PLIB_MULTI_IRQn?eval??>
            <#if DRV_SPI_TX_RX_DMA == true>
                <#lt>    /* DMA Tx interrupt line */
                <#lt>    .intSources.multi.dmaTxChannelInt      = ${DMA_TX_CHANNEL_INDEX?eval},
                <#lt>    /* DMA Rx interrupt line */
                <#lt>    .intSources.multi.dmaRxChannelInt      = ${DMA_RX_CHANNEL_INDEX?eval},
            </#if>
        <#else>
            <#if DRV_SPI_TX_RX_DMA == true>
                <#lt>    /* DMA interrupt line */
                <#lt>    .intSources.dmaInterrupt               = ${core.DMA_INSTANCE_NAME}_IRQn,
            </#if>
        </#if>
    </#if>
};
</#if>

/* SPI Driver Initialization Data */
const DRV_SPI_INIT drvSPI${INDEX?string}InitData =
{
    /* SPI PLIB API */
    .spiPlib = &drvSPI${INDEX?string}PlibAPI,

    .remapDataBits = drvSPI${INDEX?string}remapDataBits,

    .remapClockPolarity = drvSPI${INDEX?string}remapClockPolarity,

    .remapClockPhase = drvSPI${INDEX?string}remapClockPhase,

    /* SPI Number of clients */
    .numClients = DRV_SPI_CLIENTS_NUMBER_IDX${INDEX?string},

    /* SPI Client Objects Pool */
    .clientObjPool = (uintptr_t)&drvSPI${INDEX?string}ClientObjPool[0],

<#if core.DMA_ENABLE?has_content>
<#if DRV_SPI_TX_RX_DMA == true>
    /* DMA Channel for Transmit */
    .dmaChannelTransmit = DRV_SPI_XMIT_DMA_CH_IDX${INDEX?string},

    /* DMA Channel for Receive */
    .dmaChannelReceive  = DRV_SPI_RCV_DMA_CH_IDX${INDEX?string},

    /* SPI Transmit Register */
    .spiTransmitAddress =  (void *)${.vars["${DRV_SPI_PLIB?lower_case}"].TRANSMIT_DATA_REGISTER},

    /* SPI Receive Register */
    .spiReceiveAddress  = (void *)${.vars["${DRV_SPI_PLIB?lower_case}"].RECEIVE_DATA_REGISTER},
<#else>
    /* DMA Channel for Transmit */
    .dmaChannelTransmit = SYS_DMA_CHANNEL_NONE,

    /* DMA Channel for Receive */
    .dmaChannelReceive  = SYS_DMA_CHANNEL_NONE,
</#if>
</#if>

<#if DRV_SPI_MODE == "Asynchronous">
    /* SPI Queue Size */
    .transferObjPoolSize = DRV_SPI_QUEUE_SIZE_IDX${INDEX?string},

    /* SPI Transfer Objects Pool */
    .transferObjPool = (uintptr_t)&drvSPI${INDEX?string}TransferObjPool[0],

    /* SPI interrupt sources (SPI peripheral and DMA) */
    .interruptSources = &drvSPI${INDEX?string}InterruptSources,
</#if>
};

// </editor-fold>