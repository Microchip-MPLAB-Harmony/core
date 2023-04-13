// <editor-fold defaultstate="collapsed" desc="DRV_SST38 Initialization Data">

static const DRV_SST38_PLIB_INTERFACE drvSST38PlibAPI = {
    .write_t              = (DRV_SST38_PLIB_WRITE)${DRV_SST38_PLIB}_Write16,
    .read_t               = (DRV_SST38_PLIB_READ)${DRV_SST38_PLIB}_Read16,
    .eccDisable         = (DRV_SST38_PLIB_ECC_DISABLE)${DRV_SST38_PLIB}_DisableECC,
    .eccEnable          = (DRV_SST38_PLIB_ECC_ENABLE)${DRV_SST38_PLIB}_EnableECC,
};

static const DRV_SST38_INIT drvSST38InitData =
{
    .sst38Plib      = &drvSST38PlibAPI,
};

// </editor-fold>
