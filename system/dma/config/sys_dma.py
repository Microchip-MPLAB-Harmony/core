################################################################################
#### Global Variables ####
################################################################################

################################################################################
#### Business Logic ####
################################################################################

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

    useSysDMAComment = dmaComponent.createCommentSymbol("USE_SYS_DMA_COMMENT", None)
    useSysDMAComment.setLabel("*** Configure DMA channels using DMA Manager ***")

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