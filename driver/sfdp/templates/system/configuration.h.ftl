/* SFDP Driver Instance Configuration */
#define DRV_SFDP_INDEX                 (0U)
#define DRV_SFDP_CLIENTS_NUMBER        (${DRV_SFDP_NUM_CLIENTS}U)
#define DRV_SFDP_START_ADDRESS         (0x${START_ADDRESS}U)
#define DRV_SFDP_PAGE_SIZE             (256U)
#define DRV_SFDP_ERASE_BUFFER_SIZE     (${ERASE_BUFFER_SIZE}U)
<#if DRV_SFDP_PLIB?contains("SQI") >
    <#lt>#define DRV_SFDP_BUFF_DESC_NUMBER      (${DRV_SFDP_NUM_BUFFER_DESC}U)
</#if>
<#if DRV_SFDP_PROTOCOL == "SPI" >
    <#lt>#define DRV_SFDP_CHIP_SELECT_PIN       ${SPI_CHIP_SELECT_PIN?string}
<#if DRV_SFDP_TX_RX_DMA == true>
    <#lt>#define DRV_SFDP_XMIT_DMA_CH                       SYS_DMA_CHANNEL_${DRV_SFDP_TX_DMA_CHANNEL}
    <#lt>#define DRV_SFDP_RCV_DMA_CH                        SYS_DMA_CHANNEL_${DRV_SFDP_RX_DMA_CHANNEL}
</#if>
</#if>
