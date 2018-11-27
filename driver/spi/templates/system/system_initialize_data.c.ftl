// <editor-fold defaultstate="collapsed" desc="DRV_SPI Instance ${INDEX?string} Initialization Data">

/* SPI Client Objects Pool */
static DRV_SPI_CLIENT_OBJ drvSPI${INDEX}ClientObjPool[DRV_SPI_CLIENTS_NUMBER_IDX${INDEX?string}] = {0};
<#if DRV_SPI_MODE == "Asynchronous">

/* SPI Transfer Objects Pool */
static DRV_SPI_TRANSFER_OBJ drvSPI${INDEX?string}TransferObjPool[DRV_SPI_QUEUE_SIZE_IDX${INDEX?string}] = {0};
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
    <#if DRV_SPI_TX_RX_DMA == true>
        <#lt>    /* Interrupt source is DMA */
        <#lt> <#if core.DMA_ENABLE?has_content>
        <#lt>   .interruptSource = ${core.DMA_INSTANCE_NAME}_IRQn,
        <#lt> </#if>
    <#else>
        <#lt>    /* Interrupt source is SPI */
        <#lt>    .interruptSource    = DRV_SPI_INT_SRC_IDX${INDEX?string},
    </#if>

    /* SPI Queue Size */
    .queueSize = DRV_SPI_QUEUE_SIZE_IDX${INDEX?string},

    /* SPI Transfer Objects Pool */
    .transferObjPool = (uintptr_t)&drvSPI${INDEX?string}TransferObjPool[0],
</#if>
};

// </editor-fold>