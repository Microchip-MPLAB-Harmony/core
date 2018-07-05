SYS_CONSOLE_Tasks(sysObj.sysConsole${INDEX?string});
<#if SYS_COMMAND_ENABLE == true>
    SYS_CMD_Tasks();
</#if>
