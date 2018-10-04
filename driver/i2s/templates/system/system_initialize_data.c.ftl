// <editor-fold defaultstate="collapsed" desc="DRV_I2S Instance ${INDEX?string} Initialization Data">

/* I2S PLIB Interface Initialization */
DRV_I2S_PLIB_INTERFACE drvI2S${INDEX?string}PlibAPI =
{
    .I2S_LRCLK_Get = (DRV_I2S_LRCLK_GET)${DRV_I2S_PLIB}_LRCLK_Get,  
};

/* I2S Driver Initialization Data */
DRV_I2S_INIT drvI2S${INDEX?string}InitData =
{
    /* I2S PLIB API */
    .i2sPlib = &drvI2S${INDEX?string}PlibAPI,

    /* I2S IRQ */
    .interruptI2S = DRV_I2S_INT_SRC_IDX${INDEX?string},

    /* I2S Number of clients */
    .numClients = DRV_I2S_CLIENTS_NUMBER_IDX${INDEX?string},

    /* I2S Queue Size */
    .queueSize = DRV_I2S_QUEUE_SIZE_IDX0,  

<#if DRV_I2S_TX_RX_DMA == true>
    .dmaChannelTransmit = DRV_I2S_XMIT_DMA_CH_IDX${INDEX?string},
    .dmaChannelReceive  = DRV_I2S_RCV_DMA_CH_IDX${INDEX?string},
    .i2sTransmitAddress = (void *)${.vars["${DRV_I2S_PLIB?lower_case}"].TRANSMIT_DATA_REGISTER},
    .i2sReceiveAddress = (void *)${.vars["${DRV_I2S_PLIB?lower_case}"].RECEIVE_DATA_REGISTER},

<#else>
    .dmaChannelTransmit = SYS_DMA_CHANNEL_NONE,
    .dmaChannelReceive = SYS_DMA_CHANNEL_NONE,

</#if>
<#if core.DMA_ENABLE?has_content>
    .interruptDMA = ${core.DMA_INSTANCE_NAME}_IRQn,
</#if>

    .dmaDataLength = DRV_I2S_DATA_LENGTH_IDX${INDEX?string},
};

// </editor-fold>
