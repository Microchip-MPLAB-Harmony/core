// <editor-fold defaultstate="collapsed" desc="SYS_CONSOLE Instance ${INDEX?string} Initialization Data">

static QElement sysConsole${INDEX?string}UARTRdQueueElements[SYS_CONSOLE_UART_RD_QUEUE_DEPTH_IDX${INDEX?string}];
static QElement sysConsole${INDEX?string}UARTWrQueueElements[SYS_CONSOLE_UART_WR_QUEUE_DEPTH_IDX${INDEX?string}];

/* Declared in console device implementation (sys_console_uart.c) */
extern const SYS_CONSOLE_DEV_DESC sysConsoleUARTDevDesc;

const SYS_CONSOLE_UART_PLIB_INTERFACE sysConsole${INDEX?string}UARTPlibAPI =
{
    .read = (SYS_CONSOLE_UART_PLIB_READ)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_Read,
    .write = (SYS_CONSOLE_UART_PLIB_WRITE)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_Write,
    .readCallbackRegister = (SYS_CONSOLE_UART_PLIB_REGISTER_CALLBACK_READ)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_ReadCallbackRegister,
    .writeCallbackRegister = (SYS_CONSOLE_UART_PLIB_REGISTER_CALLBACK_WRITE)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_WriteCallbackRegister,
    .errorGet = (SYS_CONSOLE_UART_PLIB_ERROR_GET)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_ErrorGet,
};

<#assign USART_PLIB = "SYS_CONSOLE_DEVICE">
<#assign USART_PLIB_MULTI_IRQn = "core." + USART_PLIB?eval + "_MULTI_IRQn">
<#assign USART_PLIB_SINGLE_IRQn = "core." + USART_PLIB?eval + "_SINGLE_IRQn">
<#if USART_PLIB_MULTI_IRQn?eval??>
    <#assign USART_PLIB_TX_COMPLETE_INDEX = "core." + USART_PLIB?eval + "_USART_TX_COMPLETE_INT_SRC">
    <#assign USART_PLIB_TX_READY_INDEX = "core." + USART_PLIB?eval + "_USART_TX_READY_INT_SRC">
    <#assign USART_PLIB_RX_INDEX = "core." + USART_PLIB?eval + "_USART_RX_INT_SRC">
    <#assign USART_PLIB_ERROR_INDEX = "core." + USART_PLIB?eval + "_USART_ERROR_INT_SRC">
</#if>

const SYS_CONSOLE_UART_INTERRUPT_SOURCES sysConsole${INDEX?string}UARTInterruptSources =
{
    <#if USART_PLIB_MULTI_IRQn?eval??>
        <#lt>    /* Peripheral has more than one interrupt vector */
        <#lt>    .isSingleIntSrc                        = false,

        <#lt>    /* Peripheral interrupt lines */
        <#if USART_PLIB_TX_COMPLETE_INDEX?eval??>
            <#lt>    .intSources.multi.usartTxCompleteInt   = ${USART_PLIB_TX_COMPLETE_INDEX?eval},
        <#else>
            <#lt>    .intSources.multi.usartTxCompleteInt   = -1,
        </#if>
        <#if USART_PLIB_TX_READY_INDEX?eval??>
            <#lt>    .intSources.multi.usartTxReadyInt      = ${USART_PLIB_TX_READY_INDEX?eval},
        <#else>
            <#lt>    .intSources.multi.usartTxReadyInt      = -1,
        </#if>
        <#if USART_PLIB_RX_INDEX?eval??>
            <#lt>    .intSources.multi.usartRxCompleteInt   = ${USART_PLIB_RX_INDEX?eval},
        <#else>
            <#lt>    .intSources.multi.usartTxReadyInt      = -1,
        </#if>
        <#if USART_PLIB_ERROR_INDEX?eval??>
            <#lt>    .intSources.multi.usartErrorInt        = ${USART_PLIB_ERROR_INDEX?eval},
        <#else>
            <#lt>    .intSources.multi.usartErrorInt        = -1,
        </#if>
    <#else>
        <#lt>    /* Peripheral has single interrupt vector */
        <#lt>    .isSingleIntSrc                        = true,

        <#lt>    /* Peripheral interrupt line */
        <#if USART_PLIB_SINGLE_IRQn?eval??>
            <#lt>    .intSources.usartInterrupt             = ${USART_PLIB_SINGLE_IRQn?eval},
        <#else>
            <#lt>    .intSources.usartInterrupt             = ${SYS_CONSOLE_DEVICE}_IRQn,
        </#if>
    </#if>
};

const SYS_CONSOLE_UART_INIT_DATA sysConsole${INDEX?string}UARTInitData =
{
    .uartPLIB = &sysConsole${INDEX?string}UARTPlibAPI,
    .readQueueElementsArr = sysConsole${INDEX?string}UARTRdQueueElements,
    .writeQueueElementsArr = sysConsole${INDEX?string}UARTWrQueueElements,
    .readQueueDepth = SYS_CONSOLE_UART_RD_QUEUE_DEPTH_IDX${INDEX?string},
    .writeQueueDepth = SYS_CONSOLE_UART_WR_QUEUE_DEPTH_IDX${INDEX?string},
    .interruptSources = &sysConsole${INDEX?string}UARTInterruptSources,
};

const SYS_CONSOLE_INIT sysConsole${INDEX?string}Init =
{
    .deviceInitData = (const void*)&sysConsole${INDEX?string}UARTInitData,
    .consDevDesc = &sysConsoleUARTDevDesc,
    .deviceIndex = 0,
};

<#if SYS_DEBUG_ENABLE == true>
    <#lt>const SYS_DEBUG_INIT debugInit =
    <#lt>{
    <#lt>    .moduleInit = {0},
    <#lt>    .errorLevel = SYS_DEBUG_GLOBAL_ERROR_LEVEL,
    <#lt>    .consoleIndex = 0,
    <#lt>};
</#if>

<#if SYS_COMMAND_ENABLE == true>
    <#lt>const SYS_CMD_INIT sysCmdInit =
    <#lt>{
    <#lt>    .moduleInit = {0},
    <#lt>    .consoleCmdIOParam = SYS_CMD_SINGLE_CHARACTER_READ_CONSOLE_IO_PARAM,
    <#lt>};
</#if>
// </editor-fold>
