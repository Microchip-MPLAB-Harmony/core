################################################################################
#### Global Variables ####
################################################################################

################################################################################
#### Business Logic ####
################################################################################
def requestDMAComment(Sym, event):
    if(event["value"] == -2):
        Sym.setVisible(True)
    else:
        Sym.setVisible(False)
################################################################################
#### Component ####
################################################################################
def instantiateComponent(dmaComponent):
    Log.writeInfoMessage("Running DMA System Service ")

    useSysDMA = dmaComponent.createBooleanSymbol("USE_SYS_DMA", None)
    useSysDMA.setLabel("Use DMA System Service?")
    useSysDMA.setDescription("Enable DMA System Service?")
    useSysDMA.setDefaultValue(True)
    useSysDMA.setVisible(False)

    dmaPLIB = dmaComponent.createStringSymbol("SYS_DMA_PLIB", None)
    dmaPLIB.setLabel("PLIB Used")
    dmaPLIB.setReadOnly(True)
    dmaPLIB.setDefaultValue("XDMAC")

    useSysDMAComment = dmaComponent.createCommentSymbol("USE_SYS_DMA_COMMENT", None)
    useSysDMAComment.setLabel("*** Configure DMA channels using DMA Manager ***")

    # Reserve a DMA Channel for SYS_DMA
    perID = "Software Trigger"
    Database.clearSymbolValue("core", "DMA_CH_NEEDED_FOR_" + perID)
    Database.setSymbolValue("core", "DMA_CH_NEEDED_FOR_" + perID, True, 2)

    dmaChannelComment = dmaComponent.createCommentSymbol("SYS_DMA_CH_COMMENT", None)
    dmaChannelComment.setLabel("Warning!!! Couldn't Allocate any DMA Channel. Check DMA manager.")
    dmaChannelComment.setDependencies(requestDMAComment, ["core.DMA_CH_FOR_" + perID])
    dmaChannelComment.setVisible(False)

    ############################################################################
    #### Code Generation ####
    ############################################################################
    configName = Variables.get("__CONFIGURATION_NAME")

    dmaHeaderFile = dmaComponent.createFileSymbol(None, None)
    dmaHeaderFile.setSourcePath("system/dma/sys_dma.h")
    dmaHeaderFile.setOutputName("sys_dma.h")
    dmaHeaderFile.setDestPath("system/dma/")
    dmaHeaderFile.setProjectPath("config/" + configName + "/system/dma/")
    dmaHeaderFile.setType("HEADER")

    dmaHeaderMappingFile = dmaComponent.createFileSymbol(None, None)
    dmaHeaderMappingFile.setSourcePath("system/dma/sys_dma_mapping.h")
    dmaHeaderMappingFile.setOutputName("sys_dma_mapping.h")
    dmaHeaderMappingFile.setDestPath("system/dma/")
    dmaHeaderMappingFile.setProjectPath("config/" + configName + "/system/dma/")
    dmaHeaderMappingFile.setType("HEADER")

    dmaSystemDefFile = dmaComponent.createFileSymbol(None, None)
    dmaSystemDefFile.setType("STRING")
    dmaSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    dmaSystemDefFile.setSourcePath("system/dma/templates/system/system_definitions.h.ftl")
    dmaSystemDefFile.setMarkup(True)

    # Adding System Service common files to the project
    Database.clearSymbolValue("harmonyCore", "SYSTEM_SERVICE_NEEDED")
    Database.setSymbolValue("harmonyCore", "SYSTEM_SERVICE_NEEDED", True, 2)