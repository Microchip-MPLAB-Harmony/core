// <editor-fold defaultstate="collapsed" desc="DRV_AT24 Initialization Data">

/* MISRA C-2012 Rule 11.1 deviated:4 Deviation record ID -  H3_MISRAC_2012_R_11_1_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:4 "MISRA C-2012 Rule 11.1" "H3_MISRAC_2012_R_11_1_DR_1"    
</#if>

/* I2C PLIB Interface Initialization for AT24 Driver */
static const DRV_AT24_PLIB_INTERFACE drvAT24PlibAPI = {

    /* I2C PLIB WriteRead function */
    .writeRead = (DRV_AT24_PLIB_WRITE_READ)${.vars["${DRV_AT24_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_WriteRead,

    /* I2C PLIB Write function */
    .write_t = (DRV_AT24_PLIB_WRITE)${.vars["${DRV_AT24_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_Write,

    /* I2C PLIB Read function */
    .read_t = (DRV_AT24_PLIB_READ)${.vars["${DRV_AT24_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_Read,

    /* I2C PLIB Transfer Status function */
    .isBusy = (DRV_AT24_PLIB_IS_BUSY)${.vars["${DRV_AT24_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_IsBusy,

    /* I2C PLIB Error Status function */
    .errorGet = (DRV_AT24_PLIB_ERROR_GET)${.vars["${DRV_AT24_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_ErrorGet,

    /* I2C PLIB Callback Register */
    .callbackRegister = (DRV_AT24_PLIB_CALLBACK_REGISTER)${.vars["${DRV_AT24_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_CallbackRegister,
};

/* AT24 Driver Initialization Data */
static const DRV_AT24_INIT drvAT24InitData =
{
    /* I2C PLIB API  interface*/
    .i2cPlib = &drvAT24PlibAPI,

    /* 7-bit I2C Slave address */
    .slaveAddress = 0x${I2C_EEPROM_ADDDRESS},

    /* EEPROM Page Size in bytes */
    .pageSize = DRV_AT24_EEPROM_PAGE_SIZE,

    /* Total size of the EEPROM in bytes */
    .flashSize = DRV_AT24_EEPROM_FLASH_SIZE,

    /* AT24 Number of clients */
    .numClients = DRV_AT24_CLIENTS_NUMBER_IDX,

    .blockStartAddress =    0x${START_ADDRESS},
};

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.1"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>    
</#if>
/* MISRAC 2012 deviation block end */
// </editor-fold>