// <editor-fold defaultstate="collapsed" desc="DRV_USART Instance ${INDEX?string} Initialization Data">

static DRV_USART_CLIENT_OBJ drvUSART${INDEX?string}ClientObjPool[DRV_USART_CLIENTS_NUMBER_IDX${INDEX?string}] = {0};

<#if drv_usart.DRV_USART_COMMON_MODE == "Asynchronous">
/* USART transmit/receive transfer objects pool */
static DRV_USART_BUFFER_OBJ drvUSART${INDEX?string}BufferObjPool[DRV_USART_QUEUE_SIZE_IDX${INDEX?string}] = {0};
</#if>

const DRV_USART_PLIB_INTERFACE drvUsart${INDEX?string}PlibAPI = {
        .readCallbackRegister = (DRV_USART_PLIB_READ_CALLBACK_REG)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_ReadCallbackRegister,
        .read = (DRV_USART_PLIB_READ)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_Read,
        .readIsBusy = (DRV_USART_PLIB_READ_IS_BUSY)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_ReadIsBusy,
        .readCountGet = (DRV_USART_PLIB_READ_COUNT_GET)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_ReadCountGet,
        .writeCallbackRegister = (DRV_USART_PLIB_WRITE_CALLBACK_REG)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_WriteCallbackRegister,
        .write = (DRV_USART_PLIB_WRITE)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_Write,
        .writeIsBusy = (DRV_USART_PLIB_WRITE_IS_BUSY)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_WriteIsBusy,
        .writeCountGet = (DRV_USART_PLIB_WRITE_COUNT_GET)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_WriteCountGet,
        .errorGet = (DRV_USART_PLIB_ERROR_GET)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_ErrorGet,
        .serialSetup = (DRV_USART_PLIB_SERIAL_SETUP)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_SerialSetup
};

<@compress single_line=true>
const uint32_t drvUsart${INDEX?string}remapDataWidth[] = {
    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_DATA_5_BIT_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_DATA_5_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_DATA_6_BIT_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_DATA_6_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_DATA_7_BIT_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_DATA_7_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_DATA_8_BIT_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_DATA_8_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_DATA_9_BIT_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_DATA_9_BIT_MASK}
    <#else>
        0xFFFFFFFF
    </#if>
};
</@compress>

<@compress single_line=true>
const uint32_t drvUsart${INDEX?string}remapParity[] = {
    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_NONE_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_NONE_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_ODD_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_ODD_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_EVEN_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_EVEN_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_MARK_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_MARK_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_SPACE_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_SPACE_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_MULTIDROP_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_MULTIDROP_MASK}
    <#else>
        0xFFFFFFFF
    </#if>
};
</@compress>

<@compress single_line=true>
const uint32_t drvUsart${INDEX?string}remapStopBits[] = {

    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_STOP_1_BIT_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_STOP_1_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_STOP_1_5_BIT_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_STOP_1_5_BIT_MASK},
    <#else>
        0xFFFFFFFF,
    </#if>

    <#if .vars["${DRV_USART_PLIB?lower_case}"].USART_STOP_2_BIT_MASK?has_content>
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_STOP_2_BIT_MASK}
    <#else>
        0xFFFFFFFF
    </#if>
};
</@compress>

<@compress single_line=true>
const uint32_t drvUsart${INDEX?string}remapError[] = {
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_OVERRUN_ERROR_VALUE},
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_PARITY_ERROR_VALUE},
        ${.vars["${DRV_USART_PLIB?lower_case}"].USART_FRAMING_ERROR_VALUE}
};
</@compress>


const DRV_USART_INIT drvUsart${INDEX?string}InitData =
{
    .usartPlib = &drvUsart${INDEX?string}PlibAPI,

    /* USART Number of clients */
    .numClients = DRV_USART_CLIENTS_NUMBER_IDX${INDEX?string},

    /* USART Client Objects Pool */
    .clientObjPool = (uintptr_t)&drvUSART${INDEX?string}ClientObjPool[0],

<#if core.DMA_ENABLE?has_content>
    <#if DRV_USART_TX_DMA == true>
        <#lt>    .dmaChannelTransmit = DRV_USART_XMIT_DMA_CH_IDX${INDEX?string},

        <#lt>    .usartTransmitAddress = (void *)${.vars["${DRV_USART_PLIB?lower_case}"].TRANSMIT_DATA_REGISTER},
    <#else>
        <#lt>    .dmaChannelTransmit = SYS_DMA_CHANNEL_NONE,
    </#if>

    <#if DRV_USART_RX_DMA == true>
        <#lt>    .dmaChannelReceive = DRV_USART_RCV_DMA_CH_IDX${INDEX?string},

        <#lt>    .usartReceiveAddress = (void *)${.vars["${DRV_USART_PLIB?lower_case}"].RECEIVE_DATA_REGISTER},
    <#else>
        <#lt>    .dmaChannelReceive = SYS_DMA_CHANNEL_NONE,
    </#if>
</#if>

<#if drv_usart.DRV_USART_COMMON_MODE == "Asynchronous">

    /* Combined size of transmit and receive buffer objects */
    .bufferObjPoolSize = DRV_USART_QUEUE_SIZE_IDX${INDEX?string},

    /* USART transmit and receive buffer buffer objects pool */
    .bufferObjPool = (uintptr_t)&drvUSART${INDEX?string}BufferObjPool[0],

    .interruptUSART = ${DRV_USART_PLIB}_IRQn,

    <#if core.DMA_ENABLE?has_content>
        <#lt>    .interruptDMA = ${core.DMA_INSTANCE_NAME}_IRQn,
    </#if>

</#if>

    .remapDataWidth = drvUsart${INDEX?string}remapDataWidth,

    .remapParity = drvUsart${INDEX?string}remapParity,

    .remapStopBits = drvUsart${INDEX?string}remapStopBits,

    .remapError = drvUsart${INDEX?string}remapError,
};

// </editor-fold>