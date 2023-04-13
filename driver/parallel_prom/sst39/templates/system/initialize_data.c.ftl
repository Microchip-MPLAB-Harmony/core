// <editor-fold defaultstate="collapsed" desc="DRV_SST39 Initialization Data">

static const DRV_SST39_PLIB_INTERFACE drvSST39PlibAPI = {
    .write_t              = (DRV_SST39_PLIB_WRITE)${DRV_SST39_PLIB}_Write8,
    .read_t               = (DRV_SST39_PLIB_READ)${DRV_SST39_PLIB}_Read8,
    .eccDisable         = (DRV_SST39_PLIB_ECC_DISABLE)${DRV_SST39_PLIB}_DisableECC,
    .eccEnable          = (DRV_SST39_PLIB_ECC_ENABLE)${DRV_SST39_PLIB}_EnableECC,
};

static const DRV_SST39_INIT drvSST39InitData =
{
    .sst39Plib      = &drvSST39PlibAPI,
};

// </editor-fold>
