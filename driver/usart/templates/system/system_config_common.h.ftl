/* USART Driver Global Configuration Options */
#define DRV_USART_INSTANCES_NUMBER         ${__INSTANCE_COUNT}
<#if DRV_USART_COMMON_MODE == "Asynchronous">
#define DRV_USART_QUEUE_DEPTH_COMBINED     ${DRV_USART_BUFFER_POOL_SIZE}
</#if>