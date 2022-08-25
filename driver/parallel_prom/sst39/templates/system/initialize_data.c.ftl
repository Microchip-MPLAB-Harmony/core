// <editor-fold defaultstate="collapsed" desc="DRV_SST39 Initialization Data">

const DRV_SST39_PLIB_INTERFACE drvSST39PlibAPI = {
    .write              = (DRV_SST39_PLIB_WRITE)${DRV_SST39_PLIB}_Write8,
    .read               = (DRV_SST39_PLIB_READ)${DRV_SST39_PLIB}_Read8,
    .eccDisable         = (DRV_SST39_PLIB_ECC_DISABLE)${DRV_SST39_PLIB}_DisableECC,
    .eccEnable          = (DRV_SST39_PLIB_ECC_ENABLE)${DRV_SST39_PLIB}_EnableECC,
};

const DRV_SST39_INIT drvSST39InitData =
{
    .sst39Plib      = &drvSST39PlibAPI,
};

// </editor-fold>
