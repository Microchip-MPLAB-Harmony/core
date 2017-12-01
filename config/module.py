def loadModule():
	print("Load Module: Harmony Drivers & System Services")

	if (Peripheral.moduleExists("USART")):
		print("create component: Driver USART")
		usartComponent = Module.CreateGeneratorComponent("drv_usart", "USART Driver", "/Drivers/", "driver/usart/config/usart.py")
		usartComponent.addCapability("DRV_USART")
		usartComponent.addDependency("USART", "USART")
	else:
		print("No USART peripheral")


