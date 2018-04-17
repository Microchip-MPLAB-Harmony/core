
print("Load Module: Harmony Drivers & System Services")

harmonySystemService = Module.CreateSharedComponent("Harmony", "Harmony Core", "/Harmony", "config/harmonycore.py")

#load harmony drivers and system services from the list 
for coreComponent in coreComponents:

	#check if component should be created
	if eval(coreComponent['condition']):
		Name = coreComponent['name']

		#create system component
		if coreComponent['type'] == "system":
			print("create component: " + Name.upper() + " System Service")
			Component = Module.CreateSharedComponent("sys_" + Name, Name.upper(), "/Harmony/System Services", "system/" + Name + "/config/sys_" + Name + ".py")
			Component.addCapability("sys_" + Name, "sys_" + Name)
			if "dependency" in coreComponent:
				for item in coreComponent['dependency']:
					Component.addDependency("sys_" + Name + "_" + item + "_dependency", item)
			Component.setDisplayType("System Service")
		#create driver component
		else:
			print("create component: " + Name.upper() + " Driver")
			Component = Module.CreateGeneratorComponent("drv_" + Name, Name.upper(), "/Harmony/Drivers/", "driver/" + Name + "/config/drv_" + Name + "_common.py", "driver/" + Name + "/config/drv_" + Name + ".py")
			Component.addCapability("drv_" + Name, "drv_" + Name)
			Component.setDisplayType("Driver")
			if "dependency" in coreComponent:
				for item in coreComponent['dependency']:
					Component.addDependency("drv_" + Name + "_" + item + "_dependency", item)
