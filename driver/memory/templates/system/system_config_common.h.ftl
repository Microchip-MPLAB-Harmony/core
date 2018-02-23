/* Memory Driver Global Configuration Options */
#define DRV_MEMORY_INSTANCES_NUMBER         ${DRV_MEMORY_NUM_INSTANCES}

<#if DRV_MEMORY_COMMON_FS_ENABLE >
#define DRV_MEMORY_SYS_FS_REGISTER
</#if>
