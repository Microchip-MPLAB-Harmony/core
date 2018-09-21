/* SPI Driver Instance ${INDEX?string} Configuration Options */
#define DRV_SPI_INDEX_${INDEX?string}                       ${INDEX?string}
#define DRV_SPI_CLIENTS_NUMBER_IDX${INDEX?string}           ${DRV_SPI_NUM_CLIENTS?string}

<#if DRV_SPI_TX_RX_DMA == true>
#define DRV_SPI_DMA_MODE
#define DRV_SPI_XMIT_DMA_CH_IDX${INDEX?string}              SYS_DMA_CHANNEL_${DRV_SPI_TX_DMA_CHANNEL}
#define DRV_SPI_RCV_DMA_CH_IDX${INDEX?string}               SYS_DMA_CHANNEL_${DRV_SPI_RX_DMA_CHANNEL}
</#if>
<#if DRV_SPI_MODE == false>
#define DRV_SPI_INT_SRC_IDX${INDEX?string}                  ${DRV_SPI_PLIB?string}_IRQn
#define DRV_SPI_QUEUE_SIZE_IDX${INDEX?string}               ${DRV_SPI_QUEUE_SIZE?string}
</#if>