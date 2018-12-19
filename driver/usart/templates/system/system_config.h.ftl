/* USART Driver Instance ${INDEX?string} Configuration Options */
#define DRV_USART_INDEX_${INDEX?string}                  ${INDEX?string}
#define DRV_USART_CLIENTS_NUMBER_IDX${INDEX?string}      ${DRV_USART_CLIENTS_NUM}
<#if DRV_USART_TX_DMA == true>
    <#lt>#define DRV_USART_XMIT_DMA_CH_IDX${INDEX?string}         SYS_DMA_CHANNEL_${DRV_USART_TX_DMA_CHANNEL}
</#if>
<#if DRV_USART_RX_DMA == true>
    <#lt>#define DRV_USART_RCV_DMA_CH_IDX${INDEX?string}          SYS_DMA_CHANNEL_${DRV_USART_RX_DMA_CHANNEL}
</#if>
<#if drv_usart.DRV_USART_COMMON_MODE == "Asynchronous">
    <#lt>#define DRV_USART_QUEUE_SIZE_IDX${INDEX?string}          ${DRV_USART_QUEUE_SIZE}
</#if>
