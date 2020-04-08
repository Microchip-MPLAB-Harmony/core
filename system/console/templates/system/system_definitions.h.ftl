#include "system/console/sys_console.h"
<#if SYS_CONSOLE_UART_CONNECTION_COUNTER != 0>
#include "system/console/src/sys_console_uart_definitions.h"
</#if>
<#if SYS_CONSOLE_USB_CONNECTION_COUNTER != 0>
#include "system/console/src/sys_console_usb_cdc_definitions.h"
</#if>