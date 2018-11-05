// <editor-fold defaultstate="collapsed" desc="SYS_CONSOLE Instance ${INDEX?string} Initialization Data">

QElement sysConsole${INDEX?string}UARTRdQueueElements[SYS_CONSOLE_UART_RD_QUEUE_DEPTH_IDX${INDEX?string}];
QElement sysConsole${INDEX?string}UARTWrQueueElements[SYS_CONSOLE_UART_WR_QUEUE_DEPTH_IDX${INDEX?string}];

/* Declared in console device implementation (sys_console_uart.c) */
extern const SYS_CONSOLE_DEV_DESC sysConsoleUARTDevDesc;

const SYS_CONSOLE_UART_PLIB_API sysConsole${INDEX?string}UARTPlibAPI = 
{
    .read = (SYS_CONSOLE_UART_READ)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_Read,
    .write = (SYS_CONSOLE_UART_WRITE)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_Write,        
    .readCallbackRegister = (SYS_CONSOLE_UART_REGISTER_CALLBACK_READ)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_ReadCallbackRegister,        
    .writeCallbackRegister = (SYS_CONSOLE_UART_REGISTER_CALLBACK_WRITE)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_WriteCallbackRegister,        
    .errorGet = (SYS_CONSOLE_UART_ERROR_GET)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_ErrorGet,
};

const SYS_CONSOLE_UART_INIT_DATA sysConsole${INDEX?string}UARTInitData = 
{
    .uartPLIB = &sysConsole${INDEX?string}UARTPlibAPI,
    .readQueueElementsArr = sysConsole${INDEX?string}UARTRdQueueElements,
    .writeQueueElementsArr = sysConsole${INDEX?string}UARTWrQueueElements,
    .readQueueDepth = SYS_CONSOLE_UART_RD_QUEUE_DEPTH_IDX${INDEX?string},
    .writeQueueDepth = SYS_CONSOLE_UART_WR_QUEUE_DEPTH_IDX${INDEX?string},
    .interruptSource = ${SYS_CONSOLE_DEVICE}_IRQn,
};

const SYS_CONSOLE_INIT sysConsole${INDEX?string}Init =
{
    .deviceInitData = (const void*)&sysConsole${INDEX?string}UARTInitData,      
    .consDevDesc = &sysConsoleUARTDevDesc,
    .deviceIndex = 0,
};

<#if SYS_DEBUG_ENABLE == true>
const SYS_DEBUG_INIT debugInit =
{
    .moduleInit = {0},
    .errorLevel = SYS_DEBUG_GLOBAL_ERROR_LEVEL,
    .consoleIndex = 0,
};
</#if>

<#if SYS_COMMAND_ENABLE == true>
const SYS_CMD_INIT sysCmdInit =
{
    .moduleInit = {0},
    .consoleCmdIOParam = SYS_CMD_SINGLE_CHARACTER_READ_CONSOLE_IO_PARAM,
};
</#if>
// </editor-fold>