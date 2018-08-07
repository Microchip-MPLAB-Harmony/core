// <editor-fold defaultstate="collapsed" desc="DRV_USART Instance ${INDEX?string} Initialization Data">
<#if DRV_USART_MODE == true>

DRV_USART_CLIENT_OBJ drvUSART${INDEX?string}ClientObjPool[DRV_USART_CLIENTS_NUMBER_IDX${INDEX?string}] = {0};
</#if>

USART_PLIB_API drvUsart${INDEX?string}PlibAPI = {
        .readCallbackRegister = (USART_ReadCallbackRegister)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_ReadCallbackRegister,
        .read = (USART_Read)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_Read,
        .readIsBusy = (USART_ReadIsBusy)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_ReadIsBusy,
        .readCountGet = (USART_ReadCountGet)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_ReadCountGet,
        .writeCallbackRegister = (USART_WriteCallbackRegister)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_WriteCallbackRegister,
        .write = (USART_Write)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_Write,
        .writeIsBusy = (USART_WriteIsBusy)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_WriteIsBusy,
        .writeCountGet = (USART_WriteCountGet)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_WriteCountGet,
        .errorGet = (USART_ErrorGet)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_ErrorGet,
        .serialSetup = (USART_SerialSetup)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_SerialSetup
};

DRV_USART_INIT drvUsart${INDEX?string}InitData =
{
    .usartPlib = &drvUsart${INDEX?string}PlibAPI,

<#if DRV_USART_TX_DMA == true>
    .dmaChannelTransmit = DRV_USART_XMIT_DMA_CH_IDX${INDEX?string},

    .usartTransmitAddress = (void *)${DRV_USART_PLIB}_TRANSMIT_ADDRESS,
<#else>
    .dmaChannelTransmit = DMA_CHANNEL_NONE,
</#if>

<#if DRV_USART_RX_DMA == true>
    .dmaChannelReceive = DRV_USART_RCV_DMA_CH_IDX${INDEX?string},

    .usartReceiveAddress = (void *)${DRV_USART_PLIB}_RECEIVE_ADDRESS,
<#else>
    .dmaChannelReceive = DMA_CHANNEL_NONE,
</#if>
<#if DRV_USART_MODE == false>

    .queueSizeTransmit = DRV_USART_XMIT_QUEUE_SIZE_IDX${INDEX?string},

    .queueSizeReceive = DRV_USART_RCV_QUEUE_SIZE_IDX${INDEX?string},

    .interruptUSART = ${DRV_USART_PLIB}_IRQn,

<#if core.XDMAC_ENABLE?has_content>
    .interruptDMA = XDMAC_IRQn,
<#elseif core.DMAC_ENABLE?has_content>
    .interruptDMA = DMAC_IRQn,
</#if>
<#else>

    .numClients = DRV_USART_CLIENTS_NUMBER_IDX0,

    .clientObjPool = (uintptr_t)&drvUSART${INDEX?string}ClientObjPool[0],
</#if>

};

// </editor-fold>