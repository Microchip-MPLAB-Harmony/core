/* I2C Driver Instance ${INDEX?string} Configuration Options */
#define DRV_I2C_INDEX_${INDEX?string}                       ${INDEX?string}
#define DRV_I2C_CLIENTS_NUMBER_IDX${INDEX?string}           ${DRV_I2C_NUM_CLIENTS?string}
#define DRV_I2C_INT_SRC_IDX${INDEX?string}                  ${DRV_I2C_PLIB?string}_IRQn
<#if drv_i2c.DRV_I2C_MODE == "Asynchronous">
#define DRV_I2C_QUEUE_SIZE_IDX${INDEX?string}               ${DRV_I2C_QUEUE_SIZE?string}
</#if>
#define DRV_I2C_CLOCK_SPEED_IDX${INDEX?string}              ${.vars["${DRV_I2C_PLIB?lower_case}"].I2C_CLOCK_SPEED}
