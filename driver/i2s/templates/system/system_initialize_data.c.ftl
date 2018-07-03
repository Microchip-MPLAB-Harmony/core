// <editor-fold defaultstate="collapsed" desc="DRV_I2S Instance ${INDEX?string} Initialization Data">

/* I2S PLIB Interface Initialization */
DRV_I2S_PLIB_INTERFACE drvI2S${INDEX?string}PlibAPI =
{  
    /* I2S PLIB Set Baud */
    .setBaud = (DRV_BAUDSET)SSC0_BaudSet
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
    
<#if DRV_SSC_TX_RX_DMA == true>
    .dmaChannelTransmit = DRV_SSC_XMIT_DMA_CH_IDX${INDEX?string},
    .dmaChannelReceive  = DRV_SSC_RCV_DMA_CH_IDX${INDEX?string},
<#if DRV_I2S_PLIB == "SSC0">
    .i2sTransmitAddress = (void *)SSC_TRANSMIT_ADDRESS,
    .i2sReceiveAddress = (void *)SSC_RECEIVE_ADDRESS,
<#else>
    .i2sTransmitAddress = (void *)${DRV_I2S_PLIB}_TRANSMIT_ADDRESS,
    .i2sReceiveAddress = (void *)${DRV_I2S_PLIB}_RECEIVE_ADDRESS,
</#if>
<#else>
    .dmaChannelTransmit = DMA_CHANNEL_NONE,
    .dmaChannelReceive = DMA_CHANNEL_NONE,
</#if>
    .interruptDMA = XDMAC_IRQn,

    .dmaDataLength = DRV_I2S_DATA_LENGTH_IDX${INDEX?string},
};

// </editor-fold>
