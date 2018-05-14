<#list 0..(GEN_APP_TASK_COUNT - 1) as i>
<#assign APP_TASK_NAME_STR = "GEN_APP_TASK_NAME_" + i>
<#assign APP_TASK_NAME = APP_TASK_NAME_STR?eval>
#include "${APP_TASK_NAME?lower_case}.h"
</#list>