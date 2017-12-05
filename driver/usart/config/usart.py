def instantiateComponent(usartComponent, index):

	usartMenu = usartComponent.createMenuSymbol(None, None)
	usartMenu.setLabel("USART Driver " + str(index))

	usartEnable = usartComponent.createBooleanSymbol("USE_USART_" + str(index), usartMenu)
	usartEnable.setLabel("Use USART " + str(index) + "?")
	usartEnable.setDescription("Enables usart instance " + str(index))

	usartBL = usartComponent.createBooleanSymbol("BL" + str(index), usartMenu)
	usartBL.setDependencies(usartBusinessLogic, ["USE_USART_" + str(index)])



def usartBusinessLogic(usartBL, usartEnable):
	if (usartEnable.getValue() == True):
		print("USART Driver is enabled. setting plib...")
		usartBL.getComponent().getDependencyComponent("USART_Dependency").setSymbolValue("Config1", "Leonard", True, 1)
	else:
		print("USART Driver is disabled. clearing plib...")
		usartBL.getComponent().getDependencyComponent("USART_Dependency").setSymbolValue("Config1", "Leonard", False, 1)


