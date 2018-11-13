// <editor-fold defaultstate="collapsed" desc="DRV_USART Instance ${INDEX?string} Initialization Data">
<#if DRV_USART_MODE == true>

DRV_USART_CLIENT_OBJ drvUSART${INDEX?string}ClientObjPool[DRV_USART_CLIENTS_NUMBER_IDX${INDEX?string}] = {0};
</#if>

const USART_PLIB_API drvUsart${INDEX?string}PlibAPI = {
        .readCallbackRegister = (USART_ReadCallbackRegister)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_ReadCallbackRegister,
        .read = (USART_Read)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_Read,
        .readIsBusy = (USART_ReadIsBusy)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_ReadIsBusy,
        .readCountGet = (USART_ReadCountGet)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_ReadCountGet,
        .writeCallbackRegister = (USART_WriteCallbackRegister)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_WriteCallbackRegister,
        .write = (USART_Write)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_Write,
        .writeIsBusy = (USART_WriteIsBusy)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_WriteIsBusy,
        .writeCountGet = (USART_WriteCountGet)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_WriteCountGet,
        .errorGet = (USART_ErrorGet)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_ErrorGet,
        .serialSetup = (USART_SerialSetup)${.vars["${DRV_USART_PLIB?lower_case}"].USART_PLIB_API_PREFIX}_SerialSetup
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
    .remapDataWidth = drvUsart${INDEX?string}remapDataWidth,
    .remapParity = drvUsart${INDEX?string}remapParity,
    .remapStopBits = drvUsart${INDEX?string}remapStopBits,
    .remapError = drvUsart${INDEX?string}remapError,

<#if DRV_USART_TX_DMA == true>
    .dmaChannelTransmit = DRV_USART_XMIT_DMA_CH_IDX${INDEX?string},

    .usartTransmitAddress = (void *)${.vars["${DRV_USART_PLIB?lower_case}"].TRANSMIT_DATA_REGISTER},
<#else>
    .dmaChannelTransmit = SYS_DMA_CHANNEL_NONE,
</#if>

<#if DRV_USART_RX_DMA == true>
    .dmaChannelReceive = DRV_USART_RCV_DMA_CH_IDX${INDEX?string},

    .usartReceiveAddress = (void *)${.vars["${DRV_USART_PLIB?lower_case}"].RECEIVE_DATA_REGISTER},
<#else>
    .dmaChannelReceive = SYS_DMA_CHANNEL_NONE,
</#if>
<#if DRV_USART_MODE == false>

    .queueSizeTransmit = DRV_USART_XMIT_QUEUE_SIZE_IDX${INDEX?string},

    .queueSizeReceive = DRV_USART_RCV_QUEUE_SIZE_IDX${INDEX?string},

    .interruptUSART = ${DRV_USART_PLIB}_IRQn,

<#if core.DMA_ENABLE?has_content>
    .interruptDMA = ${core.DMA_INSTANCE_NAME}_IRQn,
</#if>
<#else>

    .numClients = DRV_USART_CLIENTS_NUMBER_IDX0,

    .clientObjPool = (uintptr_t)&drvUSART${INDEX?string}ClientObjPool[0],
</#if>

};

// </editor-fold>