/* AT25M Driver Instance ${DRV_AT25M_INDEX?string} Configuration Options */
#define DRV_AT25M_INSTANCES_NUMBER              ${DRV_AT25M_NUM_INSTANCES}
#define DRV_AT25M_INDEX_${DRV_AT25M_INDEX?string}                       ${DRV_AT25M_INDEX?string}
#define DRV_AT25M_CLIENTS_NUMBER_IDX${DRV_AT25M_INDEX?string}           ${DRV_AT25M_NUM_CLIENTS?string}
#define DRV_AT25M_INT_SRC_IDX${DRV_AT25M_INDEX?string}                  ${DRV_AT25M_PLIB?string}_IRQn
#define DRV_AT25M_CHIP_SELECT_PIN_IDX${DRV_AT25M_INDEX?string}          ${DRV_AT25M_CHIP_SELECT_PIN?string}
#define DRV_AT25M_HOLD_PIN_IDX${DRV_AT25M_INDEX?string}                 ${DRV_AT25M_HOLD_PIN?string}
#define DRV_AT25M_WP_PIN_IDX${DRV_AT25M_INDEX?string}                   ${DRV_AT25M_WRITE_PROTECT_PIN?string}