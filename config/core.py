
print("Load Module: Harmony Drivers & System Services")

harmonySystemService = Module.CreateSharedComponent("Harmony", "Harmony Core", "/Harmony", "config/harmonycore.py")

#load hamrony drivers and system services from the list 
for coreComponent in coreComponents:

	#check if component should be created
	if eval(coreComponent['condition']):
		Name = coreComponent['name']

		#create system component
		if coreComponent['type'] == "system":
			print("create component: " + Name.upper() + " System Service")
			Component = Module.CreateSharedComponent("sys_" + Name, Name.upper() + " System Service", "/Harmony/System Services", "system/" + Name + "/config/sys_" + Name + ".py")
			Component.addCapability("sys_" + Name, "sys_" + Name)
		#create drvier component
		else:
			print("create component: " + Name.upper() + " Driver")
			Component = Module.CreateGeneratorComponent("drv_" + Name, Name.upper() + " Driver", "/Harmony/Drivers/", "driver/" + Name + "/config/drv_" + Name + "_common.py", "driver/" + Name + "/config/drv_" + Name + ".py")
			Component.addCapability("drv_" + Name, "drv_" + Name)
			if "dependency" in coreComponent:
				for item in coreComponent['dependency']:
					Component.addDependency("drv_" + Name + "_" + item + "_dependency", item)
