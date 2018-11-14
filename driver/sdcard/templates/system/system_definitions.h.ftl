#include "driver/sdcard/drv_sdcard.h"
#include "driver/sdcard/drv_sdcard_definitions.h"
<#if DRV_SDCARD_SELECT_PROTOCOL == "SDHC">
    <#lt>#include "driver/sdcard/sdhc/drv_sdhc.h"
<#elseif DRV_SDCARD_SELECT_PROTOCOL == "SDSPI">
    <#lt>#include "driver/sdcard/sdspi/drv_sdspi.h"
</#if>