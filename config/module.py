def loadModule():
	print("Load Module: Harmony Drivers & System Services")

	harmonySystemService = Module.CreateSharedComponent("sys_core", "Harmony Core System Service", "/System Services", "system/config/system.py")
	harmonySystemService.addCapability("sys_core", "SYS_CORE")

	intComponent = Module.CreateSharedComponent("sys_int", "Interrupt System Service", "/System Services", "system/int/config/sys_int.py")
	intComponent.addCapability("sys_int", "SYS_INT")

	dmaComponent = Module.CreateSharedComponent("sys_dma", "DMA System Service", "/System Services", "system/dma/config/sys_dma.py")
	dmaComponent.addCapability("sys_dma", "SYS_DMA")

	harmonyDriver = Module.CreateSharedComponent("drv_core", "Harmony Core Driver", "/Drivers", "driver/config/driver.py")
	harmonyDriver.addCapability("drv_core", "DRV_CORE")

	if (Peripheral.moduleExists("USART")):
		print("create component: Driver USART")
		usartComponent = Module.CreateGeneratorComponent("drv_usart", "USART Driver", "/Drivers/", "driver/usart/config/drv_usart_common.py", "driver/usart/config/drv_usart.py")
		usartComponent.addCapability("drv_usart", "DRV_USART")
		usartComponent.addDependency("DRV_USART_Dependency", "USART")
		usartComponent.addDependency("DRV_Dependency", "DRV_CORE")
	else:
		print("No USART peripheral")

