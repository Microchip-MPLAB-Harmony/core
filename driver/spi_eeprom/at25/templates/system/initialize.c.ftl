    /* MISRA C-2012 Rule 11.3, 11.8 deviated below. Deviation record ID -  
     H3_MISRAC_2012_R_11_3_DR_1 & H3_MISRAC_2012_R_11_8_DR_1*/
    <#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>   
    #pragma coverity compliance block \
    (deviate:1 "MISRA C-2012 Rule 11.3" "H3_MISRAC_2012_R_11_3_DR_1" )\
    (deviate:1 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1" )   
    </#if>
    
    sysObj.drvAT25 = DRV_AT25_Initialize(DRV_AT25_INDEX, (SYS_MODULE_INIT *)&drvAT25InitData);
    
    <#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
    #pragma coverity compliance end_block "MISRA C-2012 Rule 11.3"
    #pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"       
    </#if> 
    /* MISRAC 2012 deviation block end */
