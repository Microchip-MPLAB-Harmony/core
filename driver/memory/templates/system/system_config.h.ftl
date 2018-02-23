/* Memory Driver Instance ${INDEX?string} Configuration Options */
#define DRV_MEMORY_INDEX_${INDEX?string}                   ${INDEX?string}
#define DRV_MEMORY_CLIENTS_NUMBER_IDX${INDEX?string}       ${DRV_MEMORY_NUM_CLIENTS?string}
#define DRV_MEMORY_BUFFER_QUEUE_SIZE_IDX${INDEX?string}    ${DRV_MEMORY_BUFFER_QUEUE_SIZE?string}
#define DRV_MEMORY_ERASE_BUFFER_SIZE_IDX${INDEX?string}    ${DRV_MEMORY_ERASE_BUFF_SIZE}
<#if DRV_MEMORY_INTERRUPT_ENABLE >
#define DRV_MEMORY_INT_SRC_IDX${INDEX?string}              ${DRV_MEMORY_INTERRUPT_SOURCE}
</#if>
<#if DRV_MEMORY_DEVICE == "EFC0" >
#define DRV_MEMORY_DEVICE_START_ADDRESS      0x${DRV_MEMORY_DEVICE_START_ADDRESS}
</#if>
