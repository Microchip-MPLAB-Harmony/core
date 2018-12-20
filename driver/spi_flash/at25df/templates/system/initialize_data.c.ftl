/* SPI PLIB Interface Initialization for AT25DF Driver */
const DRV_AT25DF_PLIB_INTERFACE drvAT25DFPlibAPI = {

    /* SPI PLIB WriteRead function */
    .writeRead = (DRV_AT25DF_PLIB_WRITE_READ)${.vars["${DRV_AT25DF_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_WriteRead,

    /* SPI PLIB Write function */
    .write = (DRV_AT25DF_PLIB_WRITE)${.vars["${DRV_AT25DF_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_Write,

    /* SPI PLIB Read function */
    .read = (DRV_AT25DF_PLIB_READ)${.vars["${DRV_AT25DF_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_Read,

    /* SPI PLIB Transfer Status function */
    .isBusy = (DRV_AT25DF_PLIB_IS_BUSY)${.vars["${DRV_AT25DF_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_IsBusy,

    /* SPI PLIB Callback Register */
    .callbackRegister = (DRV_AT25DF_PLIB_CALLBACK_REGISTER)${.vars["${DRV_AT25DF_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_CallbackRegister,
};

/* AT25DF Driver Initialization Data */
const DRV_AT25DF_INIT drvAT25DFInitData =
{
    /* SPI PLIB API  interface*/
    .spiPlib = &drvAT25DFPlibAPI,

    /* AT25DF Number of clients */
    .numClients = DRV_AT25DF_CLIENTS_NUMBER_IDX,

    /* FLASH Page Size in bytes */
    .pageSize = DRV_AT25DF_PAGE_SIZE,

    /* Total size of the FLASH in bytes */
    .flashSize = DRV_AT25DF_FLASH_SIZE,

    .blockStartAddress = 0x${START_ADDRESS},

    .chipSelectPin = DRV_AT25DF_CHIP_SELECT_PIN_IDX
};
