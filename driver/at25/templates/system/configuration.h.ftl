/* AT25M Driver Configuration Options */
#define DRV_AT25_INSTANCES_NUMBER              ${DRV_AT25_NUM_INSTANCES}
#define DRV_AT25_INDEX                         0
#define DRV_AT25_CLIENTS_NUMBER_IDX            ${DRV_AT25_NUM_CLIENTS?string}
#define DRV_AT25_INT_SRC_IDX                   ${DRV_AT25_PLIB?string}_IRQn
#define DRV_AT25_EEPROM_FLASH_SIZE             ${EEPROM_FLASH_SIZE}
#define DRV_AT25_EEPROM_PAGE_SIZE              ${EEPROM_PAGE_SIZE}
#define DRV_AT25_CHIP_SELECT_PIN_IDX           ${DRV_AT25_CHIP_SELECT_PIN?string}
#define DRV_AT25_HOLD_PIN_IDX                  ${DRV_AT25_HOLD_PIN?string}
#define DRV_AT25_WP_PIN_IDX                    ${DRV_AT25_WRITE_PROTECT_PIN?string}