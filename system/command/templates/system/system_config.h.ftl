
#define SYS_CMD_ENABLE
#define SYS_CMD_DEVICE_MAX_INSTANCES       SYS_CONSOLE_DEVICE_MAX_INSTANCES
#define SYS_CMD_PRINT_BUFFER_SIZE          ${SYS_COMMAND_PRINT_BUFFER_SIZE}
#define SYS_CMD_BUFFER_DMA_READY
<#if SYS_COMMAND_CONSOLE_ENABLE == true>
    <#lt>#define SYS_CMD_REMAP_SYS_CONSOLE_MESSAGE
</#if>
<#if SYS_COMMAND_DEBUG_ENABLE == true>
    <#lt>#define SYS_CMD_REMAP_SYS_DEBUG_MESSAGE
</#if>
<#if HarmonyCore.SELECT_RTOS != "BareMetal">
    <#lt>/* Command System Service RTOS Configurations*/
    <#lt>#define SYS_CMD_RTOS_STACK_SIZE                ${SYS_COMMAND_RTOS_STACK_SIZE}
    <#lt>#define SYS_CMD_RTOS_TASK_PRIORITY             ${SYS_COMMAND_RTOS_TASK_PRIORITY}
</#if>
