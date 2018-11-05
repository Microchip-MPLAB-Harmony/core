    sysObj.sysConsole${INDEX?string} = SYS_CONSOLE_Initialize(SYS_CONSOLE_INDEX_${INDEX?string}, (SYS_MODULE_INIT *)&sysConsole${INDEX?string}Init);
<#if SYS_DEBUG_ENABLE == true>
    sysObj.sysDebug = SYS_DEBUG_Initialize(SYS_DEBUG_INDEX_0, (SYS_MODULE_INIT*)&debugInit);
</#if>
<#if SYS_COMMAND_ENABLE == true>
    SYS_CMD_Initialize((SYS_MODULE_INIT*)&sysCmdInit);
</#if>
