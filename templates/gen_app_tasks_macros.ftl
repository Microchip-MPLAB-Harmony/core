<#list 0..(GEN_APP_TASK_COUNT - 1) as i>
    <#assign GEN_APP_TASK_NAME = "GEN_APP_TASK_NAME_" + i>
    <#if SELECT_RTOS == "BareMetal">
    <#lt>    /* Call Application task ${.vars[GEN_APP_TASK_NAME]?upper_case}. */
    <#lt>    ${.vars[GEN_APP_TASK_NAME]?upper_case}_Tasks();

    </#if>
</#list>