<#if core.CoreArchitecture?matches("CORTEX-M[2|3]3")>
#include "portasm.h"
<#elseif core.CoreArchitecture?matches("CORTEX-A5")>
#include "portmacro.h"
</#if>