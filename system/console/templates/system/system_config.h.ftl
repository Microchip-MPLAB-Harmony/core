#define SYS_CONSOLE_INDEX_${INDEX?string}                       ${INDEX?string}
<#if SYS_CONSOLE_DEVICE_SET == "UART">

</#if>

<#if SYS_CONSOLE_DEVICE_SET == "USB_CDC">
/* RX buffer size has one additional element for the empty spot needed in circular buffer */
#define SYS_CONSOLE_USB_CDC_RD_BUFFER_SIZE_IDX${INDEX?string}    ${(SYS_CONSOLE_RX_BUFFER_SIZE + 1)}

/* TX buffer size has one additional element for the empty spot needed in circular buffer */
#define SYS_CONSOLE_USB_CDC_WR_BUFFER_SIZE_IDX${INDEX?string}    ${(SYS_CONSOLE_TX_BUFFER_SIZE + 1)}
</#if>

<#if SYS_CONSOLE_DEVICE_SET == "USB_CDC">
<#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS != "BareMetal">
    <#lt>/* Console Driver Instance ${INDEX?string} RTOS Configurations*/
    <#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
        <#lt>#define SYS_CONSOLE_RTOS_STACK_SIZE_IDX${INDEX?string}               ${SYS_CONSOLE_RTOS_STACK_SIZE / 4}
    <#else>
        <#lt>#define SYS_CONSOLE_RTOS_STACK_SIZE_IDX${INDEX?string}               ${SYS_CONSOLE_RTOS_STACK_SIZE}
    </#if>
    <#lt>#define SYS_CONSOLE_RTOS_TASK_PRIORITY_IDX${INDEX?string}                     ${SYS_CONSOLE_RTOS_TASK_PRIORITY}
    <#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
        <#lt>#define SYS_CONSOLE_RTOS_TASK_MSG_QTY_IDX${INDEX?string}        ${SYS_CONSOLE_RTOS_TASK_MSG_QTY}u
        <#lt>#define SYS_CONSOLE_RTOS_TASK_TIME_QUANTA_IDX${INDEX?string}    ${SYS_CONSOLE_RTOS_TASK_TIME_QUANTA}u
    </#if>
</#if>
</#if>