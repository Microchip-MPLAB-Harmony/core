def instantiateComponent(timerComponent, index):
	timerMenu = timerComponent.createMenuSymbol(None, None)
	timerMenu.setLabel("Driver Settings")
	
	timerEnable = timerComponent.createBooleanSymbol("USE_TIMER", timerMenu)
	timerEnable.setLabel("Use Timer Driver?")
	timerEnable.setDescription("Enables timer driver instance")
