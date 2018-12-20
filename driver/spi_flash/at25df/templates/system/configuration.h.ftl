/* AT25DF Driver Configuration Options */
#define DRV_AT25DF_INSTANCES_NUMBER              ${DRV_AT25DF_NUM_INSTANCES}
#define DRV_AT25DF_INDEX                         0
#define DRV_AT25DF_CLIENTS_NUMBER_IDX            ${DRV_AT25DF_NUM_CLIENTS?string}
#define DRV_AT25DF_INT_SRC_IDX                   ${DRV_AT25DF_PLIB?string}_IRQn
#define DRV_AT25DF_FLASH_SIZE                    ${FLASH_SIZE}
#define DRV_AT25DF_PAGE_SIZE                     ${PAGE_SIZE}
#define DRV_AT25DF_ERASE_BUFFER_SIZE             ${ERASE_BUFFER_SIZE}
#define DRV_AT25DF_CHIP_SELECT_PIN_IDX           ${DRV_AT25DF_CHIP_SELECT_PIN?string}