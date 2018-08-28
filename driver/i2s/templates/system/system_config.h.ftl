/* I2S Driver Instance ${INDEX?string} Configuration Options */
#define DRV_I2S_INDEX_${INDEX?string}                       ${INDEX?string}
#define DRV_I2S_CLIENTS_NUMBER_IDX${INDEX?string}           ${DRV_I2S_NUM_CLIENTS?string}
#define DRV_I2S_QUEUE_DEPTH_COMBINED          ${DRV_I2S_QUEUE_SIZE?string}
#define DRV_I2S_QUEUE_SIZE_IDX${INDEX?string}               ${DRV_I2S_QUEUE_SIZE?string}
#define DRV_I2S_DATA_LENGTH_IDX${INDEX?string}              ${I2S_DATA_LENGTH?string}
<#if DRV_I2S_PLIB == "SSC0">
#define DRV_I2S_INT_SRC_IDX${INDEX?string}                  SSC_IRQn
<#else>
#define DRV_I2S_INT_SRC_IDX${INDEX?string}                  ${DRV_I2S_PLIB}_IRQn
</#if>
#define DRV_I2S_XMIT_DMA_CH_IDX${INDEX?string}              DMA_CHANNEL_${DRV_I2S_TX_DMA_CHANNEL}
#define DRV_I2S_RCV_DMA_CH_IDX${INDEX?string}               DMA_CHANNEL_${DRV_I2S_RX_DMA_CHANNEL}

