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
