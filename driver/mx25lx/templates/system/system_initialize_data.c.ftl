// <editor-fold defaultstate="collapsed" desc="DRV_MX25L Initialization Data">

const DRV_MX25L_PLIB_INTERFACE drvMX25LPlibAPI = {
    .CommandWrite  = ${DRV_MX25L_PLIB}_CommandWrite,
    .RegisterRead  = ${DRV_MX25L_PLIB}_RegisterRead,
    .RegisterWrite = ${DRV_MX25L_PLIB}_RegisterWrite,
    .MemoryRead    = ${DRV_MX25L_PLIB}_MemoryRead,
    .MemoryWrite   = ${DRV_MX25L_PLIB}_MemoryWrite
};

const DRV_MX25L_INIT drvMX25LInitData =
{
    .mx25lPlib         = &drvMX25LPlibAPI,
};

// </editor-fold>