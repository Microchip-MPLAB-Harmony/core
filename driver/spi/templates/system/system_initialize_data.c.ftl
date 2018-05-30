// <editor-fold defaultstate="collapsed" desc="DRV_SPI Instance ${INDEX?string} Initialization Data">

/* SPI Client Objects Pool */
DRV_SPI_CLIENT_OBJ drvSPI${INDEX}ClientObjPool[DRV_SPI_CLIENTS_NUMBER_IDX${INDEX?string}] = {0};
<#if DRV_SPI_MODE == false>

/* SPI Transfer Objects Pool */
DRV_SPI_TRANSFER_OBJ drvSPI${INDEX?string}TransferObjPool[DRV_SPI_QUEUE_SIZE_IDX${INDEX?string}] = {0};
</#if>

/* SPI PLIB Interface Initialization */
DRV_SPI_PLIB_INTERFACE drvSPI${INDEX?string}PlibAPI = {

    /* SPI PLIB Setup */
    .setup = (DRV_SETUP)${DRV_SPI_PLIB}_TransferSetup,

    /* SPI PLIB WriteRead function */
    .writeRead = (DRV_WRITEREAD)${DRV_SPI_PLIB}_WriteRead,

    /* SPI PLIB Transfer Status function */
    .isBusy = (DRV_IS_BUSY)${DRV_SPI_PLIB}_IsBusy,

    /* SPI PLIB Error Status function */
    .errorGet = (DRV_ERROR_GET)${DRV_SPI_PLIB}_ErrorGet,

    /* SPI PLIB Callback Register */
    .callbackRegister = (DRV_CALLBACK_REGISTER)${DRV_SPI_PLIB}_CallbackRegister,
};

/* SPI Driver Initialization Data */
DRV_SPI_INIT drvSPI${INDEX?string}InitData =
{
    /* SPI PLIB API */
    .spiPlib = &drvSPI${INDEX?string}PlibAPI,

    /* SPI Number of clients */
    .numClients = DRV_SPI_CLIENTS_NUMBER_IDX${INDEX?string},

    /* SPI Client Objects Pool */
    .clientObjPool = (uintptr_t)&drvSPI${INDEX?string}ClientObjPool[0],

    /* SPI setup parameters */
    .baudRateInHz = (uint32_t)${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_BAUD_RATE},

    /* SPI Clock Phase */
    .clockPhase = (DRV_SPI_CLOCK_PHASE)SPI_CSR_NCPHA_${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CSR_NCPHA},

    /* SPI Clock Polarity */
    .clockPolarity = (DRV_SPI_CLOCK_POLARITY)SPI_CSR_CPOL_${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CSR_CPOL},

    /* SPI data length per transfer */
    .dataBits = (DRV_SPI_DATA_BITS)SPI_CSR_BITS${.vars["${DRV_SPI_PLIB?lower_case}"].SPI_CSR_BITS},

<#if DRV_SPI_TX_RX_DMA == true>
    /* DMA Channel for Transmit */
    .dmaChannelTransmit = DRV_SPI_XMIT_DMA_CH_IDX${INDEX?string},

    /* DMA Channel for Receive */
    .dmaChannelReceive  = DRV_SPI_RCV_DMA_CH_IDX${INDEX?string},

    /* SPI Transmit Register */
    .spiTransmitAddress = (void *)${DRV_SPI_PLIB}_TRANSMIT_ADDRESS,

    /* SPI Receive Register */
    .spiReceiveAddress  = (void *)${DRV_SPI_PLIB}_RECEIVE_ADDRESS,
<#else>
    /* DMA Channel for Transmit */
    .dmaChannelTransmit = DMA_CHANNEL_NONE,

    /* DMA Channel for Receive */
    .dmaChannelReceive  = DMA_CHANNEL_NONE,
</#if>

<#if DRV_SPI_MODE == false>
    <#if DRV_SPI_TX_RX_DMA == true>
        <#lt>    /* Interrupt source is DMA */
        <#lt>    .interruptSource    = XDMAC_IRQn,
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