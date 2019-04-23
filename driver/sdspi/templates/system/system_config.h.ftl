/* SDSPI Driver Instance ${INDEX?string} Configuration Options */
#define DRV_SDSPI_INDEX_${INDEX?string}                       ${INDEX?string}
#define DRV_SDSPI_CLIENTS_NUMBER_IDX${INDEX?string}           ${DRV_SDSPI_NUM_CLIENTS?string}
<#if drv_sdspi.DRV_SDSPI_COMMON_MODE == "Asynchronous" >
#define DRV_SDSPI_QUEUE_SIZE_IDX${INDEX?string}               ${DRV_SDSPI_QUEUE_SIZE?string}
</#if>
#define DRV_SDSPI_CHIP_SELECT_PIN_IDX${INDEX?string}          ${DRV_SDSPI_CHIP_SELECT_PIN?string}
#define DRV_SDSPI_SPEED_HZ_IDX${INDEX?string}                 ${DRV_SDSPI_SPEED_HZ?string}
#define DRV_SDSPI_POLLING_INTERVAL_MS_IDX${INDEX?string}      ${DRV_SDSPI_POLLING_INTERVAL?string}

<#if DRV_SDSPI_TX_RX_DMA == true>
#define DRV_SDSPI_DMA_MODE
#define DRV_SDSPI_XMIT_DMA_CH_IDX${INDEX?string}              SYS_DMA_CHANNEL_${DRV_SDSPI_TX_DMA_CHANNEL}
#define DRV_SDSPI_RCV_DMA_CH_IDX${INDEX?string}               SYS_DMA_CHANNEL_${DRV_SDSPI_RX_DMA_CHANNEL}
</#if>

<#if DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING == true>
#define DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECK
#define DRV_SDSPI_WRITE_PROTECT_PIN_IDX${INDEX?string}        ${DRV_SDSPI_WRITE_PROTECT_PIN?string}
</#if>

<#if HarmonyCore.SELECT_RTOS != "BareMetal">
    <#lt>/* SDSPI Driver Instance ${INDEX?string} RTOS Configurations*/
    <#lt>#define DRV_SDSPI_STACK_SIZE_IDX${INDEX?string}               ${DRV_SDSPI_RTOS_STACK_SIZE}
    <#lt>#define DRV_SDSPI_PRIORITY_IDX${INDEX?string}                 ${DRV_SDSPI_RTOS_TASK_PRIORITY}
</#if>
