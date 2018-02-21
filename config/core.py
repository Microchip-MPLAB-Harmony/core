
print("Load Module: Harmony Drivers & System Services")

#load hamrony core components
harmonySystemService = Module.CreateSharedComponent("sys_core", "Harmony Core System Service", "/System Services", "system/config/system.py")
harmonySystemService.addCapability("sys_core", "sys_core")

harmonyDriver = Module.CreateSharedComponent("drv_core", "Harmony Core Driver", "/Drivers", "driver/config/driver.py")
harmonyDriver.addCapability("drv_core", "drv_core")

#load hamrony drivers and system services from the list 
for coreComponent in coreComponents:

	#check if component should be created
	if eval(coreComponent['condition']):
		Name = coreComponent['name']

		#create system component
		if coreComponent['type'] == "system":
			print("create component: " + Name.upper() + " System Service")
			Component = Module.CreateSharedComponent("sys_" + Name, Name.upper() + " System Service", "/System Services", "system/" + Name + "/config/sys_" + Name + ".py")
			Component.addCapability("sys_" + Name, "sys_" + Name)
			Component.addDependency("SYS_Dependency", "sys_core")
		#create drvier component
		else:
			print("create component: " + Name.upper() + " Driver")
			Component = Module.CreateGeneratorComponent("drv_" + Name, Name.upper() + " Driver", "/Drivers/", "driver/" + Name + "/config/drv_" + Name + "_common.py", "driver/" + Name + "/config/drv_" + Name + ".py")
			Component.addCapability("drv_" + Name, "drv_" + Name)
			Component.addDependency("drv_dependency", "drv_core")
			if "dependency" in coreComponent:
				Component.addDependency("drv_" + Name + "_dependency", coreComponent['dependency'])

