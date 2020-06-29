<#list 0..(GEN_APP_TASK_COUNT - 1) as i>
    <#assign GEN_APP_TASK_NAME = "GEN_APP_TASK_NAME_" + i>
    <#assign APP_NAME = GEN_APP_TASK_NAME?eval>
    <#assign GEN_APP_TASK_ENABLE = "GEN_APP_TASK_ENABLE_" + i>
    <#if .vars[GEN_APP_TASK_ENABLE] == true>
    ${APP_NAME?upper_case}_Initialize();
    </#if>
</#list>