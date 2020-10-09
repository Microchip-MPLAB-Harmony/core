// <editor-fold defaultstate="collapsed" desc="DRV_NAND_FLASH Initialization Data">

const DRV_NAND_FLASH_PLIB_INTERFACE drvNandFlashPlibAPI = {
    .DataAddressGet              = ${DRV_NAND_FLASH_PLIB}_DataAddressGet,
    .CommandWrite                = ${DRV_NAND_FLASH_PLIB}_CommandWrite,
    .CommandWrite16              = ${DRV_NAND_FLASH_PLIB}_CommandWrite16,
    .AddressWrite                = ${DRV_NAND_FLASH_PLIB}_AddressWrite,
    .AddressWrite16              = ${DRV_NAND_FLASH_PLIB}_AddressWrite16,
    .DataWrite                   = ${DRV_NAND_FLASH_PLIB}_DataWrite,
    .DataWrite16                 = ${DRV_NAND_FLASH_PLIB}_DataWrite16,
    .DataRead                    = ${DRV_NAND_FLASH_PLIB}_DataRead,
    .DataRead16                  = ${DRV_NAND_FLASH_PLIB}_DataRead16<#if DRV_NAND_FLASH_PMECC_ENABLE == true>,
    .DataPhaseStart              = ${.vars["${DRV_NAND_FLASH_PLIB?lower_case}"].PMECC_API_PREFIX}_DataPhaseStart,
    .StatusIsBusy                = ${.vars["${DRV_NAND_FLASH_PLIB?lower_case}"].PMECC_API_PREFIX}_StatusIsBusy,
    .ErrorGet                    = ${.vars["${DRV_NAND_FLASH_PLIB?lower_case}"].PMECC_API_PREFIX}_ErrorGet,
    .RemainderGet                = ${.vars["${DRV_NAND_FLASH_PLIB?lower_case}"].PMECC_API_PREFIX}_RemainderGet,
    .ECCGet                      = ${.vars["${DRV_NAND_FLASH_PLIB?lower_case}"].PMECC_API_PREFIX}_ECCGet,
    .ErrorLocationGet            = ${.vars["${DRV_NAND_FLASH_PLIB?lower_case}"].PMERRLOC_API_PREFIX}_ErrorLocationGet,
    .ErrorLocationDisable        = ${.vars["${DRV_NAND_FLASH_PLIB?lower_case}"].PMERRLOC_API_PREFIX}_ErrorLocationDisable,
    .SigmaSet                    = ${.vars["${DRV_NAND_FLASH_PLIB?lower_case}"].PMERRLOC_API_PREFIX}_SigmaSet,
    .ErrorLocationFindNumOfRoots = ${.vars["${DRV_NAND_FLASH_PLIB?lower_case}"].PMERRLOC_API_PREFIX}_ErrorLocationFindNumOfRoots
</#if>
};

const DRV_NAND_FLASH_INIT drvNandFlashInitData =
{
    .nandFlashPlib         = &drvNandFlashPlibAPI,
};

// </editor-fold>