    /* MISRA C-2012 Rule 11.3, 11.8 deviated below. Deviation record ID -  
    H3_MISRAC_2012_R_11_3_DR_1 & H3_MISRAC_2012_R_11_8_DR_1*/
    <#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
    #pragma coverity compliance block \
    (deviate:2 "MISRA C-2012 Rule 11.3" "H3_MISRAC_2012_R_11_3_DR_1" )\
    (deviate:4 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1" )   
    </#if> 
    
    sysObj.sysTime = SYS_TIME_Initialize(SYS_TIME_INDEX_0, (SYS_MODULE_INIT *)&sysTimeInitData);
    
    <#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
    #pragma coverity compliance end_block "MISRA C-2012 Rule 11.3"
    #pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"        
    </#if> 
    /* MISRAC 2012 deviation block end */