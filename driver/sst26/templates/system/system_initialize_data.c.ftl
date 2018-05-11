// <editor-fold defaultstate="collapsed" desc="DRV_SST26 Initialization Data">

const SST26_PLIB_API drvSST26PlibAPI = {
    .CommandWrite  = ${DRV_SST26_PLIB}_CommandWrite,
    .RegisterRead  = ${DRV_SST26_PLIB}_RegisterRead,
    .RegisterWrite = ${DRV_SST26_PLIB}_RegisterWrite,
    .MemoryRead    = ${DRV_SST26_PLIB}_MemoryRead,
    .MemoryWrite   = ${DRV_SST26_PLIB}_MemoryWrite
};

const DRV_SST26_INIT drvSST26InitData =
{
    .sst26Plib         = &drvSST26PlibAPI,
};

// </editor-fold>