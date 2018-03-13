def instantiateComponent(timerComponent):
	num = timerComponent.getID()[-1:]

	timerMenu = timerComponent.createMenuSymbol("TIMER_MENU", None)
	timerMenu.setLabel("Timer " + num)
	
	usetimer = timerComponent.createBooleanSymbol("USE_TIMER_" + num, timerMenu)
	usetimer.setLabel("Use Timer " + num + "?")
	usetimer.setDescription("Enables timer instance " + num)