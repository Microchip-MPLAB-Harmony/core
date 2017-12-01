def instantiateComponent(usartComponent, index):

	usartMenu = usartComponent.createMenuSymbol(None, None)
	usartMenu.setLabel("USART Driver " + str(index))

	useUsart = usartComponent.createBooleanSymbol("USE_USART_" + str(index), usartMenu)
	useUsart.setLabel("Use USART " + str(index) + "?")
	useUsart.setDescription("Enables usart instance " + str(index))

	print("Set USART0 Config1 " + str(Database.setSymbolValue("usart0", "Config1", "Leonard", True, 1)))


