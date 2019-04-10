
/* RX queue size has one additional element for the empty spot needed in circular queue */
#define SYS_CONSOLE_UART_RD_QUEUE_DEPTH_IDX${INDEX?string}    ${(SYS_CONSOLE_RX_QUEUE_SIZE + 1)}

/* TX queue size has one additional element for the empty spot needed in circular queue */
#define SYS_CONSOLE_UART_WR_QUEUE_DEPTH_IDX${INDEX?string}    ${(SYS_CONSOLE_TX_QUEUE_SIZE + 1)}
#define SYS_CONSOLE_BUFFER_DMA_READY
