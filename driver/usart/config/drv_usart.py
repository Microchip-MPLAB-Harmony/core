def instantiateComponent(usartComponent, index):

	usartMenu = usartComponent.createMenuSymbol(None, None)
	usartMenu.setLabel("Driver Settings")

	usartEnable = usartComponent.createBooleanSymbol("USE_USART", usartMenu)
	usartEnable.setLabel("Use USART Driver?")
	usartEnable.setDescription("Enables usart driver instance " + str(index))

	usartBL = usartComponent.createBooleanSymbol("BL", usartMenu)
	usartBL.setVisible(False)
	usartBL.setDependencies(usartBusinessLogic, ["USE_USART"])

	usartIndex = usartComponent.createIntegerSymbol("INDEX", usartMenu)
	usartIndex.setVisible(False)
	usartIndex.setDefaultValue(index)

	usartSource1File = usartComponent.createFileSymbol(None, None)
	usartSource1File.setSourcePath("driver/usart/templates/drv_usart.c.ftl")
	usartSource1File.setOutputName("drv_usart" + str(index) + ".c")
	usartSource1File.setDestPath("driver/usart/")
	usartSource1File.setProjectPath("driver/usart/")
	usartSource1File.setType("SOURCE")

def usartBusinessLogic(usartBL, usartEnable):
	if (usartEnable.getValue() == True):
		print("USART Driver is enabled. setting plib...")
#		usartBL.getComponent().getDependencyComponent("DRV_USART_Dependency").setSymbolValue("Config1", "Leonard", True, 1)
	else:
		print("USART Driver is disabled. clearing plib...")
#		usartBL.getComponent().getDependencyComponent("DRV_USART_Dependency").setSymbolValue("Config1", "Leonard", False, 1)


