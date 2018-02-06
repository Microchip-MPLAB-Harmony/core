def loadModule():
    print("Load Module: Harmony Drivers & System Services")

    harmonyCoreComponent = Module.CreateSharedComponent("harmonyCore", "Harmony Core", '/', "config/core.py")

    if (Peripheral.moduleExists("USART")):
        print("create component: Driver USART")
        usartComponent = Module.CreateGeneratorComponent("drv_usart", "USART Driver", "/Drivers/", "driver/usart/config/drv_usart.py")
        usartComponent.addCapability("drv_usart", "DRV_USART")
        usartComponent.addDependency("DRV_USART_Dependency", "USART")
    else:
        print("No USART peripheral")

    intComponent = Module.CreateSharedComponent("sys_int", "Interrupt System Service", "/System/", "system/int/config/sys_int.py")

    dmaComponent = Module.CreateSharedComponent("sys_dma", "DMA System Service", "/System/", "system/dma/config/sys_dma.py")
