// <editor-fold defaultstate="collapsed" desc="DRV_AT24 Initialization Data">

/* I2C PLIB Interface Initialization for AT24 Driver */
const DRV_AT24_PLIB_INTERFACE drvAT24PlibAPI = {

    /* I2C PLIB WriteRead function */
    .writeRead = (DRV_AT24_WRITEREAD)${.vars["${DRV_AT24_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_WriteRead,

    /* I2C PLIB Write function */
    .write = (DRV_AT24_WRITE)${.vars["${DRV_AT24_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_Write,

    /* I2C PLIB Read function */
    .read = (DRV_AT24_READ)${.vars["${DRV_AT24_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_Read,

    /* I2C PLIB Transfer Status function */
    .isBusy = (DRV_AT24_IS_BUSY)${.vars["${DRV_AT24_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_IsBusy,

    /* I2C PLIB Error Status function */
    .errorGet = (DRV_AT24_ERROR_GET)${.vars["${DRV_AT24_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_ErrorGet,

    /* I2C PLIB Callback Register */
    .callbackRegister = (DRV_AT24_CALLBACK_REGISTER)${.vars["${DRV_AT24_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_CallbackRegister,
};

/* AT24 Driver Initialization Data */
const DRV_AT24_INIT drvAT24InitData =
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

// </editor-fold>