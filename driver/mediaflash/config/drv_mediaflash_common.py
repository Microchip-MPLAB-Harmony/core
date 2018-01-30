def instantiateComponent(mediaflashComponent):
    
    mediaflashSymNumInst = mediaflashComponent.createIntegerSymbol("DRV_MEDIAFLASH_NUM_INSTANCES", None)
    mediaflashSymNumInst.setLabel("Number of Instances")
    mediaflashSymNumInst.setMax(10)
    mediaflashSymNumInst.setDefaultValue(1)

    