/* AT24 Driver Configuration Options */

<#assign TOTAL_WRITE_BUFFER_SIZE = EEPROM_PAGE_SIZE + EEPROM_ADDR_LEN>

#define DRV_AT24_INSTANCES_NUMBER              ${DRV_AT24_NUM_INSTANCES}
#define DRV_AT24_INDEX                         0
#define DRV_AT24_CLIENTS_NUMBER_IDX            ${DRV_AT24_NUM_CLIENTS?string}
#define DRV_AT24_INT_SRC_IDX                   ${DRV_AT24_PLIB?string}_IRQn
#define DRV_AT24_EEPROM_FLASH_SIZE             ${EEPROM_FLASH_SIZE}
#define DRV_AT24_EEPROM_PAGE_SIZE              ${EEPROM_PAGE_SIZE}
#define DRV_AT24_WRITE_BUFFER_SIZE             ${TOTAL_WRITE_BUFFER_SIZE}