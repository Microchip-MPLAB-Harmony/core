
/* Memory Driver Instance ${INDEX?string} Configuration */
#define DRV_MEMORY_INDEX_${INDEX?string}                   ${INDEX?string}
#define DRV_MEMORY_CLIENTS_NUMBER_IDX${INDEX?string}       ${DRV_MEMORY_NUM_CLIENTS?string}
<#if drv_memory.DRV_MEMORY_COMMON_MODE == "Asynchronous" >
    <#lt>#define DRV_MEMORY_BUFFER_QUEUE_SIZE_IDX${INDEX?string}    ${DRV_MEMORY_BUFFER_QUEUE_SIZE?string}
</#if>
<#if DRV_MEMORY_PLIB?has_content >
    <#lt>#define DRV_MEMORY_DEVICE_START_ADDRESS      0x${.vars["${DRV_MEMORY_DEVICE?lower_case}"].START_ADDRESS}
    <#lt>#define DRV_MEMORY_DEVICE_MEDIA_SIZE         ${.vars["${DRV_MEMORY_DEVICE?lower_case}"].MEMORY_MEDIA_SIZE}UL
    <#lt>#define DRV_MEMORY_DEVICE_PROGRAM_SIZE       ${.vars["${DRV_MEMORY_DEVICE?lower_case}"].FLASH_PROGRAM_SIZE}
    <#lt>#define DRV_MEMORY_DEVICE_ERASE_SIZE         ${.vars["${DRV_MEMORY_DEVICE?lower_case}"].FLASH_ERASE_SIZE}
</#if>

<#if HarmonyCore.SELECT_RTOS != "BareMetal">
    <#lt>/* Memory Driver Instance ${INDEX?string} RTOS Configurations*/
    <#lt>#define DRV_MEMORY_STACK_SIZE_IDX${INDEX?string}           ${DRV_MEMORY_RTOS_STACK_SIZE}
    <#lt>#define DRV_MEMORY_PRIORITY_IDX${INDEX?string}             ${DRV_MEMORY_RTOS_TASK_PRIORITY}
</#if>
