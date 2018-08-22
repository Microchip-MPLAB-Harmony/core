// <editor-fold defaultstate="collapsed" desc="DRV_I2C Instance ${INDEX?string} Initialization Data">

/* I2C Client Objects Pool */
DRV_I2C_CLIENT_OBJ drvI2C${INDEX}ClientObjPool[DRV_I2C_CLIENTS_NUMBER_IDX${INDEX?string}] = {0};
<#if drv_i2c.DRV_I2C_MODE == "ASYNC">

/* I2C Transfer Objects Pool */
DRV_I2C_TRANSFER_OBJ drvI2C${INDEX?string}TransferObj[DRV_I2C_QUEUE_SIZE_IDX${INDEX?string}] = {0};
</#if>

/* I2C PLib Interface Initialization */
DRV_I2C_PLIB_INTERFACE drvI2C${INDEX?string}PLibAPI = {
    
    /* I2C PLib Transfer Setup */
    .transferSetup = (DRV_I2C_TRANSFER_SETUP_CALLBACK)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_TransferSetup,
    
    /* I2C PLib Transfer Read Add function */
    .read = (DRV_I2C_READ_CALLBACK)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_Read,
    
    /* I2C PLib Transfer Write Add function */
    .write = (DRV_I2C_WRITE_CALLBACK)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_Write,
    
    /* I2C PLib Transfer Write Read Add function */
    .writeRead = (DRV_I2C_WRITE_READ_CALLBACK)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_WriteRead,
    
    /* I2C PLib Transfer Status function */
    .errorGet = (DRV_I2C_ERROR_GET_CALLBACK)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_ErrorGet,
    
    /* I2C PLib Callback Register */
    .callbackRegister = (DRV_I2C_CALLBACK_REGISTER_CALLBACK)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_CallbackRegister,
};

/* I2C Driver Initialization Data */
DRV_I2C_INIT drvI2C${INDEX?string}InitData =
{
    /* I2C PLib API */
    .i2cPlib = &drvI2C${INDEX?string}PLibAPI,

    /* I2C Number of clients */
    .numClients = DRV_I2C_CLIENTS_NUMBER_IDX${INDEX?string},

    /* I2C Client Objects Pool */
    .clientObjPool = (uintptr_t)&drvI2C${INDEX?string}ClientObjPool[0],
<#if drv_i2c.DRV_I2C_MODE == "ASYNC">

    /* I2C IRQ */
    .interruptI2C = DRV_I2C_INT_SRC_IDX${INDEX?string},
    
    /* I2C TWI Queue Size */
    .queueSize = DRV_I2C_QUEUE_SIZE_IDX${INDEX?string},
    
    /* I2C Transfer Objects */
    .transferObj = (uintptr_t)&drvI2C${INDEX?string}TransferObj[0],
</#if>

    /* I2C Clock Speed */
    .clockSpeed = DRV_I2C_CLOCK_SPEED_IDX${INDEX?string},
};

// </editor-fold>
