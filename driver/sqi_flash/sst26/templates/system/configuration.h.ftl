/* SST26 Driver Instance Configuration */
#define DRV_SST26_INDEX                 0
#define DRV_SST26_CLIENTS_NUMBER        ${DRV_SST26_NUM_CLIENTS}
#define DRV_SST26_START_ADDRESS         0x${START_ADDRESS}
#define DRV_SST26_PAGE_SIZE             256
#define DRV_SST26_ERASE_BUFFER_SIZE     ${ERASE_BUFFER_SIZE}
<#if DRV_SST26_PLIB?contains("SQI") >
    <#lt>#define DRV_SST26_BUFF_DESC_NUMBER      ${DRV_SST26_NUM_BUFFER_DESC}
</#if>
<#if DRV_SST26_PROTOCOL == "SPI" >
    <#lt>#define DRV_SST26_CHIP_SELECT_PIN       ${SPI_CHIP_SELECT_PIN?string}
<#if DRV_SST26_TX_RX_DMA == true>
    <#lt>#define DRV_SST26_XMIT_DMA_CH                       SYS_DMA_CHANNEL_${DRV_SST26_TX_DMA_CHANNEL}
    <#lt>#define DRV_SST26_RCV_DMA_CH                        SYS_DMA_CHANNEL_${DRV_SST26_RX_DMA_CHANNEL}
</#if>
</#if>
