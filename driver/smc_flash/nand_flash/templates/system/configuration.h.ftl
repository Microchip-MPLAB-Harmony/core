/* NAND FLASH Driver Instance Configuration */
#define DRV_NAND_FLASH_INDEX                          (0U)
#define DRV_NAND_FLASH_CLIENTS_NUMBER                 (${DRV_NAND_FLASH_NUM_CLIENTS}U)
#define DRV_NAND_FLASH_CS                             (${DRV_NAND_FLASH_CHIP_SELECT}U)
#define DRV_NAND_FLASH_START_ADDRESS                  (0x${START_ADDRESS}U)
#define DRV_NAND_FLASH_PAGE_SIZE                      (${NAND_FLASH_PAGE_SIZE}U)
#define DRV_NAND_FLASH_ERASE_BUFFER_SIZE              (${ERASE_BUFFER_SIZE}U)
#define DRV_NAND_FLASH_ENABLE_PMECC                   (<#if DRV_NAND_FLASH_PMECC_ENABLE == true>1<#else>0</#if>)
<#if DRV_NAND_FLASH_PMECC_ENABLE == true>
  <#if .vars["${DRV_NAND_FLASH_PLIB?lower_case}"].PMECC_SAREA_SPARESIZE??>
    <#assign ECC_SPARE_SIZE = DRV_NAND_FLASH_PLIB?lower_case + "." + "PMECC_SAREA_SPARESIZE">
    <#assign ECC_START_ADDR = DRV_NAND_FLASH_PLIB?lower_case + "." + "PMECC_SADDR_STARTADDR">
    <#assign ECC_END_ADDR = DRV_NAND_FLASH_PLIB?lower_case + "." + "PMECC_EADDR_ENDADDR">
    <#assign ECC_PAGE_SIZE = DRV_NAND_FLASH_PLIB?lower_case + "." + "PMECC_CFG_PAGESIZE">
    <#assign ECC_SECTOR_SIZE = DRV_NAND_FLASH_PLIB?lower_case + "." + "PMECC_CFG_SECTORSZ">
    <#assign ECC_BCH_ERR = DRV_NAND_FLASH_PLIB?lower_case + "." + "PMECC_CFG_BCH_ERR">
  <#else>
    <#assign ECC_SPARE_SIZE = DRV_NAND_FLASH_PLIB?lower_case + "." + "SMC_PMECC_SPARE_AREA_SIZE">
    <#assign ECC_START_ADDR = DRV_NAND_FLASH_PLIB?lower_case + "." + "SMC_PMECC_START_ADDRESS">
    <#assign ECC_END_ADDR = DRV_NAND_FLASH_PLIB?lower_case + "." + "SMC_PMECC_END_ADDRESS">
    <#assign ECC_PAGE_SIZE = DRV_NAND_FLASH_PLIB?lower_case + "." + "SMC_PMECC_SECTORS_PER_PAGE">
    <#assign ECC_SECTOR_SIZE = DRV_NAND_FLASH_PLIB?lower_case + "." + "SMC_PMECC_SECTOR_SIZE">
    <#assign ECC_BCH_ERR = DRV_NAND_FLASH_PLIB?lower_case + "." + "SMC_PMECC_ERROR_CORRECTION_CAPABILITY">
  </#if>
  <#lt>#define DRV_NAND_FLASH_PMECC_ECC_SPARE_SIZE           (${(ECC_SPARE_SIZE)?eval}U)
  <#lt>#define DRV_NAND_FLASH_PMECC_ECC_START_ADDR           (${(ECC_START_ADDR)?eval}U)
  <#lt>#define DRV_NAND_FLASH_PMECC_ECC_END_ADDR             (${(ECC_END_ADDR)?eval}U)
  <#assign NUM_OF_SECTORS = 8>
  <#if (ECC_PAGE_SIZE)?eval == "0x0">
    <#assign NUM_OF_SECTORS = 1>
  <#elseif (ECC_PAGE_SIZE)?eval == "0x1">
    <#assign NUM_OF_SECTORS = 2>
  <#elseif (ECC_PAGE_SIZE)?eval == "0x2">
    <#assign NUM_OF_SECTORS = 4>
  <#elseif (ECC_PAGE_SIZE)?eval == "0x3">
    <#assign NUM_OF_SECTORS = 8>
  </#if>
  <#lt>#define DRV_NAND_FLASH_PMECC_NUMBER_OF_SECTORS        (${NUM_OF_SECTORS}U)
  <#assign SECTOR_SIZE = 512>
  <#if (ECC_SECTOR_SIZE)?eval?number == 1>
    <#assign SECTOR_SIZE = 1024>
  <#else>
    <#assign SECTOR_SIZE = 512>
  </#if>
  <#lt>#define DRV_NAND_FLASH_PMECC_SECTOR_SIZE              (${SECTOR_SIZE}U)
    <#assign ECC_ERR_CAPABILITY = 4>
  <#if (ECC_BCH_ERR)?eval == "0x0">
    <#assign ECC_ERR_CAPABILITY = 2>
  <#elseif (ECC_BCH_ERR)?eval == "0x1">
    <#assign ECC_ERR_CAPABILITY = 4>
  <#elseif (ECC_BCH_ERR)?eval == "0x2">
    <#assign ECC_ERR_CAPABILITY = 8>
  <#elseif (ECC_BCH_ERR)?eval == "0x3">
    <#assign ECC_ERR_CAPABILITY = 12>
  <#elseif (ECC_BCH_ERR)?eval == "0x4">
    <#assign ECC_ERR_CAPABILITY = 24>
  </#if>
  <#lt>#define DRV_NAND_FLASH_PMECC_ECC_ERR_CAPABILITY       ${ECC_ERR_CAPABILITY}U
</#if>
<#if DRV_NAND_FLASH_TX_RX_DMA == true>
#define DRV_NAND_FLASH_TX_RX_DMA_CH_IDX               SYS_DMA_CHANNEL_${DRV_NAND_FLASH_TX_RX_DMA_CHANNEL}
</#if>
