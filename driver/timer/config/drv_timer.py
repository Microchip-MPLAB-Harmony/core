def instantiateComponent(timerComponent, index):
	timerMenu = timerComponent.createMenuSymbol("TIMER_DRV_MENU", None)
	timerMenu.setLabel("Driver Settings")
	
	timerEnable = timerComponent.createBooleanSymbol("USE_TIMER", timerMenu)
	timerEnable.setLabel("Use Timer Driver?")
	timerEnable.setDescription("Enables timer driver instance")
