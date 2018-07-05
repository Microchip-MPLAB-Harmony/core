// <editor-fold defaultstate="collapsed" desc="SYS_CONSOLE Instance ${INDEX?string} Initialization Data">

SYS_MODULE_OBJ sysConsoleObjects[] = { SYS_MODULE_OBJ_INVALID };

/* Declared in console device implementation (sys_console_uart.c) */
extern SYS_CONSOLE_DEV_DESC consUsartDevDesc;

SYS_CONSOLE_INIT consUsartInit${INDEX?string} =
{
    .moduleInit = {0},
    .consDevDesc = &consUsartDevDesc,
};

<#if SYS_DEBUG_ENABLE == true>
SYS_DEBUG_INIT debugInit =
{
    .moduleInit = {0},
    .errorLevel = SYS_DEBUG_GLOBAL_ERROR_LEVEL
};
</#if>

<#if SYS_COMMAND_ENABLE == true>
SYS_CMD_INIT sysCmdInit =
{
    .moduleInit = {0},
    .consoleCmdIOParam = SYS_CMD_SINGLE_CHARACTER_READ_CONSOLE_IO_PARAM,
};
</#if>
// </editor-fold>