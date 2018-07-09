// <editor-fold defaultstate="collapsed" desc="DRV_AT25 Initialization Data">

/* SPI PLIB Interface Initialization for AT25 Driver */
DRV_AT25_PLIB_INTERFACE drvAT25PlibAPI = {

    /* SPI PLIB WriteRead function */
    .writeRead = (DRV_WRITEREAD)${DRV_AT25_PLIB}_WriteRead,

    /* SPI PLIB Write function */
    .write = (DRV_WRITE)${DRV_AT25_PLIB}_Write,

    /* SPI PLIB Read function */
    .read = (DRV_READ)${DRV_AT25_PLIB}_Read,

    /* SPI PLIB Transfer Status function */
    .isBusy = (DRV_IS_BUSY)${DRV_AT25_PLIB}_IsBusy,

    /* SPI PLIB Error Status function */
    .errorGet = (DRV_ERROR_GET)${DRV_AT25_PLIB}_ErrorGet,

    /* SPI PLIB Callback Register */
    .callbackRegister = (DRV_CALLBACK_REGISTER)${DRV_AT25_PLIB}_CallbackRegister,
};

/* AT25 Driver Initialization Data */
DRV_AT25_INIT drvAT25InitData =
{
    /* SPI PLIB API  interface*/
    .spiPlib = &drvAT25PlibAPI,

    /* AT25 Number of clients */
    .numClients = DRV_AT25_CLIENTS_NUMBER_IDX,   
    
    /* EEPROM Page Size in bytes */
    .pageSize = DRV_AT25_EEPROM_PAGE_SIZE,
    
    /* Total size of the EEPROM in bytes */
    .flashSize = DRV_AT25_EEPROM_FLASH_SIZE,
    
    .blockStartAddress =    0x${START_ADDRESS},
    
    .chipSelectPin    = DRV_AT25_CHIP_SELECT_PIN_IDX,

    .holdPin    = DRV_AT25_HOLD_PIN_IDX,

    .writeProtectPin    = DRV_AT25_WP_PIN_IDX,    
};

// </editor-fold>