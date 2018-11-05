/* Console System Service Configuration Options */
#define SYS_CONSOLE_DEVICE_MAX_INSTANCES   1
#define SYS_CONSOLE_INSTANCES_NUMBER       1
#define SYS_CONSOLE_UART_MAX_INSTANCES     1
/* RX queue size has one additional element for the empty spot needed in circular queue */
#define SYS_CONSOLE_UART_RD_QUEUE_DEPTH_IDX${INDEX?string}    ${(SYS_CONSOLE_RX_QUEUE_SIZE + 1)}
/* TX queue size has one additional element for the empty spot needed in circular queue */
#define SYS_CONSOLE_UART_WR_QUEUE_DEPTH_IDX${INDEX?string}    ${(SYS_CONSOLE_TX_QUEUE_SIZE + 1)}
#define SYS_CONSOLE_BUFFER_DMA_READY

<#if SYS_DEBUG_ENABLE == true>
#define SYS_DEBUG_ENABLE
#define SYS_DEBUG_GLOBAL_ERROR_LEVEL       ${SYS_DEBUG_LEVEL}
#define SYS_DEBUG_PRINT_BUFFER_SIZE        ${SYS_DEBUG_PRINT_BUFFER_SIZE}
#define SYS_DEBUG_BUFFER_DMA_READY
    <#if SYS_DEBUG_USE_CONSOLE == true>
#define SYS_DEBUG_USE_CONSOLE              
    </#if>
</#if>

<#if SYS_COMMAND_ENABLE == true>
#define SYS_CMD_ENABLE
#define SYS_CMD_DEVICE_MAX_INSTANCES       SYS_CONSOLE_DEVICE_MAX_INSTANCES
#define SYS_CMD_PRINT_BUFFER_SIZE          ${SYS_COMMAND_PRINT_BUFFER_SIZE}
#define SYS_CMD_BUFFER_DMA_READY
  <#if SYS_COMMAND_CONSOLE_ENABLE == true>
#define SYS_CMD_REMAP_SYS_CONSOLE_MESSAGE
  </#if>
  <#if SYS_COMMAND_DEBUG_ENABLE == true>
#define SYS_CMD_REMAP_SYS_DEBUG_MESSAGE
  </#if>
  <#if HarmonyCore.SELECT_RTOS != "BareMetal">
    <#lt>/* Command System Service RTOS Configurations*/
    <#lt>#define SYS_CMD_RTOS_STACK_SIZE                ${SYS_COMMAND_RTOS_STACK_SIZE}
    <#lt>#define SYS_CMD_RTOS_TASK_PRIORITY             ${SYS_COMMAND_RTOS_TASK_PRIORITY}
  </#if>  
</#if>