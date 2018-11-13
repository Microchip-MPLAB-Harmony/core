// <editor-fold defaultstate="collapsed" desc="DRV_SDSPI Instance ${INDEX?string} Initialization Data">

/* SD Card Client Objects Pool */
DRV_SDSPI_CLIENT_OBJ drvSDSPI${INDEX}ClientObjPool[DRV_SDSPI_CLIENTS_NUMBER_IDX${INDEX?string}] = {0};

/* SPI PLIB Interface Initialization for SDSPI Driver */
const DRV_SDSPI_PLIB_INTERFACE drvSDSPI${INDEX?string}PlibAPI = {

    /* SPI PLIB WriteRead function */
    .writeRead = (DRV_SDSPI_WRITEREAD)${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_WriteRead,

    /* SPI PLIB Write function */
    .write = (DRV_SDSPI_WRITE)${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_Write,

    /* SPI PLIB Read function */
    .read = (DRV_SDSPI_READ)${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_Read,

    /* SPI PLIB Transfer Status function */
    .isBusy = (DRV_SDSPI_IS_BUSY)${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_IsBusy,

    .transferSetup = (DRV_SDSPI_SETUP)${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_TransferSetup,

    /* SPI PLIB Callback Register */
    .callbackRegister = (DRV_SDSPI_CALLBACK_REGISTER)${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_PLIB_API_PREFIX}_CallbackRegister,
};

<@compress single_line=true>
const uint32_t drvSDSPI${INDEX?string}remapDataBits[]=
{
    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_8_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_8_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_9_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_9_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_10_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_10_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_11_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_11_BIT_MASK},
     <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_12_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_12_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_13_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_13_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_14_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_14_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_15_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_15_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_16_BIT_MASK?has_content>
        ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CHARSIZE_BITS_16_BIT_MASK}
    <#else>
        0xFFFFFFFF
    </#if>
};
</@compress>

<@compress single_line=true>
const uint32_t drvSDSPI${INDEX?string}remapClockPolarity[] =
{
    ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CLOCK_POLARITY_LOW_MASK},
    ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CLOCK_POLARITY_HIGH_MASK}
};
</@compress>

<@compress single_line=true>
const uint32_t drvSDSPI${INDEX?string}remapClockPhase[] =
{
    ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CLOCK_PHASE_TRAILING_MASK},
    ${.vars["${DRV_SDSPI_PLIB?lower_case}"].SPI_CLOCK_PHASE_LEADING_MASK}
};
</@compress>

/* SDSPI Driver Initialization Data */
const DRV_SDSPI_INIT drvSDSPI${INDEX?string}InitData =
{
    /* SD Card SPI PLIB API interface*/
    .spiPlib            = &drvSDSPI${INDEX?string}PlibAPI,

    .remapDataBits = drvSDSPI${INDEX?string}remapDataBits,

    .remapClockPolarity = drvSDSPI${INDEX?string}remapClockPolarity,

    .remapClockPhase = drvSDSPI${INDEX?string}remapClockPhase,

    /* SDSPI Number of clients */
    .numClients         = DRV_SDSPI_CLIENTS_NUMBER_IDX${INDEX?string},

    /* SDSPI Client Objects Pool */
    .clientObjPool      = (uintptr_t)&drvSDSPI${INDEX?string}ClientObjPool[0],

    .chipSelectPin      = DRV_SDSPI_CHIP_SELECT_PIN_IDX${INDEX?string},

    .sdcardSpeedHz      = DRV_SDSPI_SPEED_HZ_IDX${INDEX?string},

<#if DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECKING == true>
    .writeProtectPin    = DRV_SDSPI_WRITE_PROTECT_PIN_IDX${INDEX?string},
<#else>
    .writeProtectPin    = SYS_PORT_PIN_NONE,
</#if>

    .isRegisterWithFS   = DRV_SDSPI_REGISTER_WITH_FS_IDX${INDEX?string},

<#if DRV_SDSPI_TX_RX_DMA == true>
    /* DMA Channel for Transmit */
    .txDMAChannel = DRV_SDSPI_XMIT_DMA_CH_IDX${INDEX?string},

    /* DMA Channel for Receive */
    .rxDMAChannel  = DRV_SDSPI_RCV_DMA_CH_IDX${INDEX?string},

    /* SPI Transmit Register */
    .txAddress = (void *)${.vars["${DRV_SDSPI_PLIB?lower_case}"].TRANSMIT_DATA_REGISTER},

    /* SPI Receive Register */
    .rxAddress  = (void *)${.vars["${DRV_SDSPI_PLIB?lower_case}"].RECEIVE_DATA_REGISTER},
<#else>
    /* DMA Channel for Transmit */
    .txDMAChannel = SYS_DMA_CHANNEL_NONE,

    /* DMA Channel for Receive */
    .rxDMAChannel  = SYS_DMA_CHANNEL_NONE,
</#if>
};

// </editor-fold>