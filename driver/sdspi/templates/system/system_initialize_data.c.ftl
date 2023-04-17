// <editor-fold defaultstate="collapsed" desc="DRV_SDSPI Instance ${INDEX?string} Initialization Data">

/* SDSPI Client Objects Pool */
static DRV_SDSPI_CLIENT_OBJ drvSDSPI${INDEX}ClientObjPool[DRV_SDSPI_CLIENTS_NUMBER_IDX${INDEX?string}];

<#if drv_sdspi.DRV_SDSPI_COMMON_MODE == "Asynchronous" >
/* SDSPI Transfer Objects Pool */
static DRV_SDSPI_BUFFER_OBJ drvSDSPI${INDEX}TransferObjPool[DRV_SDSPI_QUEUE_SIZE_IDX${INDEX?string}];
</#if>

/* MISRA C-2012 Rule 11.1, 11.8 deviated below. Deviation record ID -  
   H3_MISRAC_2012_R_11_1_DR_1 & H3_MISRAC_2012_R_11_8_DR_1*/
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:3 "MISRA C-2012 Rule 11.1" "H3_MISRAC_2012_R_11_1_DR_1" )\
(deviate:2 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1" )   
</#if>
<#if DRV_SDSPI_INTERFACE_TYPE == "SPI_PLIB">
/* SPI PLIB Interface Initialization for SDSPI Driver */
static const DRV_SDSPI_PLIB_INTERFACE drvSDSPI${INDEX?string}PlibAPI = {

    /* SPI PLIB WriteRead function */
    .writeRead = (DRV_SDSPI_PLIB_WRITEREAD)${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_WriteRead,

    /* SPI PLIB Write function */
    .write_t = (DRV_SDSPI_PLIB_WRITE)${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_Write,

    /* SPI PLIB Read function */
    .read_t = (DRV_SDSPI_PLIB_READ)${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_Read,

    /* SPI PLIB Transfer Status function */
    .isTransmitterBusy = (DRV_SPI_PLIB_TRANSMITTER_IS_BUSY)${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_IsTransmitterBusy,

    .transferSetup = (DRV_SDSPI_PLIB_SETUP)${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_TransferSetup,

    /* SPI PLIB Callback Register */
    .callbackRegister = (DRV_SDSPI_PLIB_CALLBACK_REGISTER)${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_CallbackRegister,
};

<@compress single_line=true>
static const uint32_t drvSDSPI${INDEX?string}remapDataBits[]=
{
    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_8_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_8_BIT_MASK},
    <#else>
        0xFFFFFFFFU,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_9_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_9_BIT_MASK},
    <#else>
        0xFFFFFFFFU,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_10_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_10_BIT_MASK},
    <#else>
        0xFFFFFFFFU,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_11_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_11_BIT_MASK},
     <#else>
        0xFFFFFFFFU,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_12_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_12_BIT_MASK},
    <#else>
        0xFFFFFFFFU,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_13_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_13_BIT_MASK},
    <#else>
        0xFFFFFFFFU,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_14_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_14_BIT_MASK},
    <#else>
        0xFFFFFFFFU,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_15_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_15_BIT_MASK},
    <#else>
        0xFFFFFFFFU,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_16_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_16_BIT_MASK}
    <#else>
        0xFFFFFFFFU
    </#if>
};
</@compress>

<@compress single_line=true>
static const uint32_t drvSDSPI${INDEX?string}remapClockPolarity[] =
{
    ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CLOCK_POLARITY_LOW_MASK},
    ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CLOCK_POLARITY_HIGH_MASK}
};
</@compress>

<@compress single_line=true>
static const uint32_t drvSDSPI${INDEX?string}remapClockPhase[] =
{
    ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CLOCK_PHASE_TRAILING_MASK},
    ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CLOCK_PHASE_LEADING_MASK}
};
</@compress>

</#if>

/* SDSPI Driver Initialization Data */
static const DRV_SDSPI_INIT drvSDSPI${INDEX?string}InitData =
{
<#if DRV_SDSPI_INTERFACE_TYPE == "SPI_PLIB">
    /* SD Card SPI PLIB API interface*/
    .spiPlib                = &drvSDSPI${INDEX?string}PlibAPI,

    .remapDataBits          = drvSDSPI${INDEX?string}remapDataBits,

    .remapClockPolarity     = drvSDSPI${INDEX?string}remapClockPolarity,

    .remapClockPhase        = drvSDSPI${INDEX?string}remapClockPhase,

<#else>
    .spiDrvIndex            = ${DRV_SDSPI_SPI_DRIVER_INSTANCE},
</#if>

    /* SDSPI Number of clients */
    .numClients             = DRV_SDSPI_CLIENTS_NUMBER_IDX${INDEX?string},

    /* SDSPI Client Objects Pool */
    .clientObjPool          = (uintptr_t)&drvSDSPI${INDEX?string}ClientObjPool[0],

<#if drv_sdspi.DRV_SDSPI_COMMON_MODE == "Asynchronous" >
    /* SDSPI Transfer Objects Pool */
    .bufferObjPool          = (uintptr_t)&drvSDSPI${INDEX?string}TransferObjPool[0],

    /* SDSPI Transfer Objects Queue Size */
    .bufferObjPoolSize      = DRV_SDSPI_QUEUE_SIZE_IDX${INDEX?string},
</#if>

    .chipSelectPin          = DRV_SDSPI_CHIP_SELECT_PIN_IDX${INDEX?string},

    .sdcardSpeedHz          = DRV_SDSPI_SPEED_HZ_IDX${INDEX?string},

    .pollingIntervalMs      = DRV_SDSPI_POLLING_INTERVAL_MS_IDX${INDEX?string},

<#if DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING == true>
    .writeProtectPin        = DRV_SDSPI_WRITE_PROTECT_PIN_IDX${INDEX?string},
<#else>
    .writeProtectPin        = SYS_PORT_PIN_NONE,
</#if>

    .isFsEnabled            = ${DRV_SDSPI_FS_ENABLE?c},

<#if DRV_SDSPI_INTERFACE_TYPE == "SPI_PLIB">
<#if core.DMA_ENABLE?has_content && drv_sdspi.DRV_SDSPI_SYS_DMA_ENABLE == true>
    <#if DRV_SDSPI_TX_RX_DMA == true>
        <#lt>    /* DMA Channel for Transmit */
        <#lt>    .txDMAChannel           = DRV_SDSPI_XMIT_DMA_CH_IDX${INDEX?string},

        <#lt>    /* DMA Channel for Receive */
        <#lt>    .rxDMAChannel           = DRV_SDSPI_RCV_DMA_CH_IDX${INDEX?string},

        <#lt>    /* SPI Transmit Register */
        <#lt>    .txAddress              = (void *)${.vars["${DRV_SDSPI_PLIB?lower_case}"].TRANSMIT_DATA_REGISTER},

        <#lt>    /* SPI Receive Register */
        <#lt>    .rxAddress              = (void *)${.vars["${DRV_SDSPI_PLIB?lower_case}"].RECEIVE_DATA_REGISTER},
    <#else>
        <#lt>    /* DMA Channel for Transmit */
        <#lt>    .txDMAChannel           = SYS_DMA_CHANNEL_NONE,

        <#lt>    /* DMA Channel for Receive */
        <#lt>    .rxDMAChannel           = SYS_DMA_CHANNEL_NONE,
    </#if>
</#if>
</#if>
};
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>    
</#if>
/* MISRAC 2012 deviation block end */
// </editor-fold>
