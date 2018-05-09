// <editor-fold defaultstate="collapsed" desc="DRV_AT25M Instance ${DRV_AT25M_INDEX?string} Initialization Data">

/* SPI PLIB Interface Initialization for AT25M Driver */
DRV_AT25M_PLIB_INTERFACE drvAT25M${DRV_AT25M_INDEX?string}PlibAPI = {

    /* SPI PLIB WriteRead function */
    .writeRead = (DRV_WRITEREAD)${DRV_AT25M_PLIB}_WriteRead,

    /* SPI PLIB Write function */
    .write = (DRV_WRITE)${DRV_AT25M_PLIB}_Write,
    
    /* SPI PLIB Read function */
    .read = (DRV_READ)${DRV_AT25M_PLIB}_Read,
    
    /* SPI PLIB Transfer Status function */
    .isBusy = (DRV_IS_BUSY)${DRV_AT25M_PLIB}_IsBusy,

    /* SPI PLIB Error Status function */
    .errorGet = (DRV_ERROR_GET)${DRV_AT25M_PLIB}_ErrorGet,

    /* SPI PLIB Callback Register */
    .callbackRegister = (DRV_CALLBACK_REGISTER)${DRV_AT25M_PLIB}_CallbackRegister,
};

/* AT25M Driver Initialization Data */
DRV_AT25M_INIT drvAT25M${DRV_AT25M_INDEX?string}InitData =
{
    /* SPI PLIB API  interface*/
    .spiPlib = &drvAT25M${DRV_AT25M_INDEX?string}PlibAPI,

    /* AT25M Number of clients */
    .numClients = DRV_AT25M_CLIENTS_NUMBER_IDX${DRV_AT25M_INDEX?string},
    
    .chipSelectPin    = DRV_AT25M_CHIP_SELECT_PIN_IDX${DRV_AT25M_INDEX?string},
    
    .holdPin    = DRV_AT25M_HOLD_PIN_IDX${DRV_AT25M_INDEX?string},
    
    .writeProtectPin    = DRV_AT25M_WP_PIN_IDX${DRV_AT25M_INDEX?string},
    
    .blockStartAddress =    0x${START_ADDRESS},
};

// </editor-fold>