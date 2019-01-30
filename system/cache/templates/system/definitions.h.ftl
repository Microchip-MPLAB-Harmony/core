<#if core.DATA_CACHE_ENABLE?? || core.INSTRUCTION_CACHE_ENABLE??  >
    <#if core.DATA_CACHE_ENABLE == true || core.INSTRUCTION_CACHE_ENABLE == true >
        <#lt>#include "system/cache/sys_cache.h"
    </#if>
</#if>