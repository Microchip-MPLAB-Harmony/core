// <editor-fold defaultstate="collapsed" desc="DRV_I2C Instance ${INDEX?string} Initialization Data">

/* I2C Client Objects Pool */
DRV_I2C_CLIENT_OBJ drvI2C${INDEX}ClientObjPool[DRV_I2C_CLIENTS_NUMBER_IDX${INDEX?string}] = {0};

/* I2C Transfer Objects Pool */
DRV_I2C_TRANSFER_OBJ drvI2C${INDEX?string}TransferObj[DRV_I2C_QUEUE_SIZE_IDX${INDEX?string}] = {0};

/* I2C PLib Interface Initialization */
DRV_I2C_PLIB_INTERFACE drvI2C${INDEX?string}PLibAPI = {
    
    /* I2C PLib Transfer Setup */
    .transferSetup = (DRV_I2C_TRANSFER_SETUP_CALLBACK)${DRV_I2C_PLIB}_TransferSetup,
    
    /* I2C PLib Transfer Read Add function */
    .read = (DRV_I2C_READ_CALLBACK)${DRV_I2C_PLIB}_Read,
    
    /* I2C PLib Transfer Write Add function */
    .write = (DRV_I2C_WRITE_CALLBACK)${DRV_I2C_PLIB}_Write,
    
    /* I2C PLib Transfer Write Read Add function */
    .writeRead = (DRV_I2C_WRITE_READ_CALLBACK)${DRV_I2C_PLIB}_WriteRead,
    
    /* I2C PLib Transfer Status function */
    .errorGet = (DRV_I2C_ERROR_GET_CALLBACK)${DRV_I2C_PLIB}_ErrorGet,
    
    /* I2C PLib Callback Register */
    .callbackRegister = (DRV_I2C_CALLBACK_REGISTER_CALLBACK)${DRV_I2C_PLIB}_CallbackRegister,
};

/* I2C Driver Initialization Data */
DRV_I2C_INIT drvI2C${INDEX?string}InitData =
{
    /* I2C PLib API */
    .i2cPlib = &drvI2C${INDEX?string}PLibAPI,

    /* I2C IRQ */
    .interruptI2C = DRV_I2C_INT_SRC_IDX${INDEX?string},
    
    /* I2C TWI Queue Size */
    .queueSize = DRV_I2C_QUEUE_SIZE_IDX${INDEX?string},
    
    /* I2C Transfer Objects */
    .transferObj = (uintptr_t)&drvI2C${INDEX?string}TransferObj[0],
    
    /* I2C Number of clients */
    .numClients = DRV_I2C_CLIENTS_NUMBER_IDX${INDEX?string},
    
    /* I2C Client Objects Pool */
    .clientObjPool = (uintptr_t)&drvI2C${INDEX?string}ClientObjPool[0],
    
};

// </editor-fold>
