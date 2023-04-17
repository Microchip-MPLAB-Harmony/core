// <editor-fold defaultstate="collapsed" desc="SYS_CONSOLE Instance ${INDEX?string} Initialization Data">

<#if SYS_CONSOLE_DEVICE_SET == "UART">

/* Declared in console device implementation (sys_console_uart.c) */
extern const SYS_CONSOLE_DEV_DESC sysConsoleUARTDevDesc;

static const SYS_CONSOLE_UART_PLIB_INTERFACE sysConsole${INDEX?string}UARTPlibAPI =
{
    .read_t = (SYS_CONSOLE_UART_PLIB_READ)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_Read,
	.readCountGet = (SYS_CONSOLE_UART_PLIB_READ_COUNT_GET)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_ReadCountGet,
	.readFreeBufferCountGet = (SYS_CONSOLE_UART_PLIB_READ_FREE_BUFFFER_COUNT_GET)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_ReadFreeBufferCountGet,
    .write_t = (SYS_CONSOLE_UART_PLIB_WRITE)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_Write,
	.writeCountGet = (SYS_CONSOLE_UART_PLIB_WRITE_COUNT_GET)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_WriteCountGet,
	.writeFreeBufferCountGet = (SYS_CONSOLE_UART_PLIB_WRITE_FREE_BUFFER_COUNT_GET)${.vars["${SYS_CONSOLE_DEVICE?lower_case}"].USART_PLIB_API_PREFIX}_WriteFreeBufferCountGet,
};

static const SYS_CONSOLE_UART_INIT_DATA sysConsole${INDEX?string}UARTInitData =
{
    .uartPLIB = &sysConsole${INDEX?string}UARTPlibAPI,    
};

static const SYS_CONSOLE_INIT sysConsole${INDEX?string}Init =
{
    .deviceInitData = (const void*)&sysConsole${INDEX?string}UARTInitData,
    .consDevDesc = &sysConsoleUARTDevDesc,
    .deviceIndex = ${SYS_CONSOLE_DEVICE_UART_INDEX},
};

</#if>

<#if SYS_CONSOLE_DEVICE_SET == "USB_CDC">
/* These buffers are passed to the USB CDC Function Driver */
static uint8_t CACHE_ALIGN sysConsole${INDEX?string}USBCdcRdBuffer[SYS_CONSOLE_USB_CDC_READ_WRITE_BUFFER_SIZE];
static uint8_t CACHE_ALIGN sysConsole${INDEX?string}USBCdcWrBuffer[SYS_CONSOLE_USB_CDC_READ_WRITE_BUFFER_SIZE];

/* These are the USB CDC Ring Buffers. Data received from USB layer are copied to these ring buffer. */
static uint8_t sysConsole${INDEX?string}USBCdcRdRingBuffer[SYS_CONSOLE_USB_CDC_RD_BUFFER_SIZE_IDX${INDEX?string}];
static uint8_t sysConsole${INDEX?string}USBCdcWrRingBuffer[SYS_CONSOLE_USB_CDC_WR_BUFFER_SIZE_IDX${INDEX?string}];

/* Declared in console device implementation (sys_console_usb_cdc.c) */
extern const SYS_CONSOLE_DEV_DESC sysConsoleUSBCdcDevDesc;

const SYS_CONSOLE_USB_CDC_INIT_DATA sysConsole${INDEX?string}USBCdcInitData =
{
	.cdcInstanceIndex			= ${SYS_CONSOLE_DEVICE_INDEX},
	.cdcReadBuffer				= sysConsole${INDEX?string}USBCdcRdBuffer,
	.cdcWriteBuffer				= sysConsole${INDEX?string}USBCdcWrBuffer,
    .consoleReadBuffer 			= sysConsole${INDEX?string}USBCdcRdRingBuffer,
    .consoleWriteBuffer 		= sysConsole${INDEX?string}USBCdcWrRingBuffer,
    .consoleReadBufferSize 		= SYS_CONSOLE_USB_CDC_RD_BUFFER_SIZE_IDX${INDEX?string},
    .consoleWriteBufferSize 	= SYS_CONSOLE_USB_CDC_WR_BUFFER_SIZE_IDX${INDEX?string},
};

const SYS_CONSOLE_INIT sysConsole${INDEX?string}Init =
{
    .deviceInitData = (const void*)&sysConsole${INDEX?string}USBCdcInitData,
    .consDevDesc = &sysConsoleUSBCdcDevDesc,
    .deviceIndex = ${SYS_CONSOLE_DEVICE_USB_INDEX},
};

</#if>

// </editor-fold>
