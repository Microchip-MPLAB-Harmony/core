// <editor-fold defaultstate="collapsed" desc="DRV_I2C Instance ${INDEX?string} Initialization Data">

/* I2C Client Objects Pool */
static DRV_I2C_CLIENT_OBJ drvI2C${INDEX}ClientObjPool[DRV_I2C_CLIENTS_NUMBER_IDX${INDEX?string}];
<#if drv_i2c.DRV_I2C_MODE == "Asynchronous">

/* I2C Transfer Objects Pool */
static DRV_I2C_TRANSFER_OBJ drvI2C${INDEX?string}TransferObj[DRV_I2C_QUEUE_SIZE_IDX${INDEX?string}];
</#if>

/* I2C PLib Interface Initialization */
static const DRV_I2C_PLIB_INTERFACE drvI2C${INDEX?string}PLibAPI = {

    /* I2C PLib Transfer Read Add function */
    .read_t = (DRV_I2C_PLIB_READ)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_Read,

    /* I2C PLib Transfer Write Add function */
    .write_t = (DRV_I2C_PLIB_WRITE)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_Write,

    <#if drv_i2c.DRV_I2C_FORCED_WRITE_API_GENERATE != 0>
    <#assign I2C_PLIB_NAMESPACE = "DRV_I2C_PLIB?lower_case">
    <#assign I2C_PLIB_FORCE_WRITE_ENABLED = I2C_PLIB_NAMESPACE?eval + ".I2C_INCLUDE_FORCED_WRITE_API">
    <#if I2C_PLIB_FORCE_WRITE_ENABLED?eval?? && I2C_PLIB_FORCE_WRITE_ENABLED?eval>
    /* I2C PLib Transfer Forced Write Add function */
    .writeForced = (DRV_I2C_PLIB_WRITE)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_WriteForced,
    <#else>
    /* I2C PLib Transfer Forced Write Add function */
    .writeForced = (DRV_I2C_PLIB_WRITE)NULL,
    </#if>
    </#if>

    /* I2C PLib Transfer Write Read Add function */
    .writeRead = (DRV_I2C_PLIB_WRITE_READ)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_WriteRead,

    /*I2C PLib Transfer Abort function */
    <#if DRV_I2C_PLIB != "I2C_BB">
    .transferAbort = (DRV_I2C_PLIB_TRANSFER_ABORT)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_TransferAbort,
    <#else>
    .transferAbort = NULL,
    </#if>

    /* I2C PLib Transfer Status function */
    .errorGet = (DRV_I2C_PLIB_ERROR_GET)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_ErrorGet,

    /* I2C PLib Transfer Setup function */
    .transferSetup = (DRV_I2C_PLIB_TRANSFER_SETUP)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_TransferSetup,

    /* I2C PLib Callback Register */
    .callbackRegister = (DRV_I2C_PLIB_CALLBACK_REGISTER)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_PLIB_API_PREFIX}_CallbackRegister,
};

<#if drv_i2c.DRV_I2C_MODE == "Asynchronous">
    <#assign I2C_PLIB = "DRV_I2C_PLIB">
    <#assign I2C_PLIB_MULTI_IRQn = "core." + I2C_PLIB?eval + "_MULTI_IRQn">
    <#assign I2C_PLIB_SINGLE_IRQn = "core." + I2C_PLIB?eval + "_SINGLE_IRQn">
    <#if I2C_PLIB_MULTI_IRQn?eval??>
        <#assign I2C_PLIB_INT_INDEX0 = "core." + I2C_PLIB?eval + "_I2C_0_INT_SRC">
        <#assign I2C_PLIB_INT_INDEX1 = "core." + I2C_PLIB?eval + "_I2C_1_INT_SRC">
        <#assign I2C_PLIB_INT_INDEX2 = "core." + I2C_PLIB?eval + "_I2C_2_INT_SRC">
        <#assign I2C_PLIB_INT_INDEX3 = "core." + I2C_PLIB?eval + "_I2C_3_INT_SRC">
        <#assign I2C_PLIB_INT_INDEX4 = "core." + I2C_PLIB?eval + "_I2C_4_INT_SRC">
        <#assign I2C_PLIB_INT_INDEX5 = "core." + I2C_PLIB?eval + "_I2C_5_INT_SRC">
    </#if>

static const DRV_I2C_INTERRUPT_SOURCES drvI2C${INDEX?string}InterruptSources =
{
    <#if .vars["${DRV_I2C_PLIB?lower_case}"].MULTI_IRQn?has_content>
        <#lt>    /* Peripheral has more than one interrupt vector */
        <#lt>    .isSingleIntSrc                        = false,

        <#lt>    /* Peripheral interrupt lines */
        <#lt>   .intSources.multi.i2cInt0   = (int32_t)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_0_INT_SRC},
        <#lt>   .intSources.multi.i2cInt1   = (int32_t)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_1_INT_SRC},
        <#lt>   .intSources.multi.i2cInt2   = (int32_t)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_2_INT_SRC},
        <#lt>   .intSources.multi.i2cInt3   = (int32_t)${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_3_INT_SRC},
    <#else>
        <#if I2C_PLIB_MULTI_IRQn?eval??>
            <#lt>    /* Peripheral has more than one interrupt vector */
            <#lt>    .isSingleIntSrc                        = false,

            <#lt>    /* Peripheral interrupt lines */
            <#if I2C_PLIB_INT_INDEX0?eval??>
                <#lt>    .intSources.multi.i2cInt0          = (int32_t)${I2C_PLIB_INT_INDEX0?eval},
            <#else>
                <#lt>    .intSources.multi.i2cInt0          = -1,
            </#if>
            <#if I2C_PLIB_INT_INDEX1?eval??>
                <#lt>    .intSources.multi.i2cInt1          = (int32_t)${I2C_PLIB_INT_INDEX1?eval},
            <#else>
                <#lt>    .intSources.multi.i2cInt1          = -1,
            </#if>
            <#if I2C_PLIB_INT_INDEX2?eval??>
                <#lt>    .intSources.multi.i2cInt2          = (int32_t)${I2C_PLIB_INT_INDEX2?eval},
            <#else>
                <#lt>    .intSources.multi.i2cInt2          = -1,
            </#if>
            <#if I2C_PLIB_INT_INDEX3?eval??>
                <#lt>    .intSources.multi.i2cInt3          = (int32_t)${I2C_PLIB_INT_INDEX3?eval},
            <#else>
                <#lt>    .intSources.multi.i2cInt3          = -1,
            </#if>
        <#else>
            <#lt>    /* Peripheral has single interrupt vector */
            <#lt>    .isSingleIntSrc                        = true,

            <#lt>    /* Peripheral interrupt line */
            <#if .vars["${DRV_I2C_PLIB?lower_case}"].SINGLE_IRQn?has_content>
                <#lt>    .intSources.i2cInterrupt             = (int32_t)${.vars["${DRV_I2C_PLIB?lower_case}"].SINGLE_IRQn},
            <#elseif I2C_PLIB_SINGLE_IRQn?eval??>
                <#lt>    .intSources.i2cInterrupt             = (int32_t)${I2C_PLIB_SINGLE_IRQn?eval},
            <#else>
                <#lt>    .intSources.i2cInterrupt             = (int32_t)${DRV_I2C_PLIB}_IRQn,
            </#if>
        </#if>
    </#if>
};
</#if>

/* I2C Driver Initialization Data */
static const DRV_I2C_INIT drvI2C${INDEX?string}InitData =
{
    /* I2C PLib API */
    .i2cPlib = &drvI2C${INDEX?string}PLibAPI,

    /* I2C Number of clients */
    .numClients = DRV_I2C_CLIENTS_NUMBER_IDX${INDEX?string},

    /* I2C Client Objects Pool */
    .clientObjPool = (uintptr_t)&drvI2C${INDEX?string}ClientObjPool[0],
<#if drv_i2c.DRV_I2C_MODE == "Asynchronous">

    /* I2C TWI Queue Size */
    .transferObjPoolSize = DRV_I2C_QUEUE_SIZE_IDX${INDEX?string},

    /* I2C Transfer Objects */
    .transferObjPool = (uintptr_t)&drvI2C${INDEX?string}TransferObj[0],

    /* I2C interrupt sources */
    .interruptSources = &drvI2C${INDEX?string}InterruptSources,
</#if>

    /* I2C Clock Speed */
    .clockSpeed = DRV_I2C_CLOCK_SPEED_IDX${INDEX?string},
};
// </editor-fold>
