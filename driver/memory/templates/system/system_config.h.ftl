
/* Memory Driver Instance ${INDEX?string} Configuration */
#define DRV_MEMORY_INDEX_${INDEX?string}                   ${INDEX?string}
#define DRV_MEMORY_CLIENTS_NUMBER_IDX${INDEX?string}       ${DRV_MEMORY_NUM_CLIENTS?string}
#define DRV_MEMORY_ERASE_BUFFER_SIZE_IDX${INDEX?string}    ${DRV_MEMORY_ERASE_BUFF_SIZE}
<#if drv_memory.DRV_MEMORY_COMMON_MODE == "ASYNC" >
    <#lt>#define DRV_MEMORY_BUFFER_QUEUE_SIZE_IDX${INDEX?string}    ${DRV_MEMORY_BUFFER_QUEUE_SIZE?string}
</#if>
<#if DRV_MEMORY_INTERRUPT_ENABLE >
    <#lt>#define DRV_MEMORY_INT_SRC_IDX${INDEX?string}              ${DRV_MEMORY_INTERRUPT_SOURCE}
</#if>
<#if DRV_MEMORY_DEVICE == "EFC0" >
    <#lt>#define DRV_MEMORY_DEVICE_START_ADDRESS      0x${DRV_MEMORY_DEVICE_START_ADDRESS}
    <#lt>#define DRV_MEMORY_DEVICE_MEDIA_SIZE         ${efc0.EFC_MEMORY_MEDIA_SIZE}
</#if>

<#if Harmony.SELECT_RTOS != "BareMetal">
    <#lt>/* Memory Driver Instance ${INDEX?string} RTOS Configurations*/
    <#lt>#define DRV_MEMORY_STACK_SIZE_IDX${INDEX?string}           ${DRV_MEMORY_RTOS_STACK_SIZE}
    <#lt>#define DRV_MEMORY_PRIORITY_IDX${INDEX?string}             ${DRV_MEMORY_RTOS_TASK_PRIORITY}
</#if>
