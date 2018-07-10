// <editor-fold defaultstate="collapsed" desc="DRV_AT24 Initialization Data">

/* I2C PLIB Interface Initialization for AT24 Driver */
DRV_AT24_PLIB_INTERFACE drvAT24PlibAPI = {

    /* I2C PLIB WriteRead function */
    .writeRead = (DRV_WRITEREAD)${DRV_AT24_PLIB}_WriteRead,

    /* I2C PLIB Write function */
    .write = (DRV_WRITE)${DRV_AT24_PLIB}_Write,

    /* I2C PLIB Read function */
    .read = (DRV_READ)${DRV_AT24_PLIB}_Read,

    /* I2C PLIB Transfer Status function */
    .isBusy = (DRV_IS_BUSY)${DRV_AT24_PLIB}_IsBusy,

    /* I2C PLIB Error Status function */
    .errorGet = (DRV_ERROR_GET)${DRV_AT24_PLIB}_ErrorGet,

    /* I2C PLIB Callback Register */
    .callbackRegister = (DRV_CALLBACK_REGISTER)${DRV_AT24_PLIB}_CallbackRegister,
};

/* AT24 Driver Initialization Data */
DRV_AT24_INIT drvAT24InitData =
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