
print("Load Module: Harmony Drivers & System Services")

harmonySystemService = Module.CreateSharedComponent("Harmony", "Harmony Core", "/Harmony", "config/harmonycore.py")

thirdPartyFreeRTOS = Module.CreateComponent("FreeRTOS", "FreeRTOS", "//Third Party Libraries/RTOS/", "config/freertos.py")
thirdPartyFreeRTOS.setDisplayType("Third Party Library")
thirdPartyFreeRTOS.addCapability("FreeRTOS", "RTOS")

#load harmony drivers and system services from the list 
for coreComponent in coreComponents:

    #check if component should be created
    if eval(coreComponent['condition']):
        Name = coreComponent['name']
        Label = coreComponent['label']
        Capability = coreComponent['capability']

        #create system component
        if coreComponent['type'] == "system":
            print("create component: " + Name.upper() + " System Service")
            Component = Module.CreateSharedComponent("sys_" + Name, Label, "/Harmony/System Services", "system/" + Name + "/config/sys_" + Name + ".py")
            Component.addCapability("sys_" + Name, Capability)
            if "dependency" in coreComponent:
                for item in coreComponent['dependency']:
                    Component.addDependency("sys_" + Name + "_" + item + "_dependency", item)
            Component.setDisplayType("System Service")
        #create driver component
        else:
            print("create component: " + Name.upper() + " Driver")

            if coreComponent['instance'] == "multi":
                Component = Module.CreateGeneratorComponent("drv_" + Name, Label, "/Harmony/Drivers/", "driver/" + Name + "/config/drv_" + Name + "_common.py", "driver/" + Name + "/config/drv_" + Name + ".py")
            elif coreComponent['instance'] == "single":
                Component = Module.CreateComponent("drv_" + Name, Label, "/Harmony/Drivers/", "driver/" + Name + "/config/drv_" + Name + ".py")

            Component.addCapability("drv_" + Name, Capability)
            Component.setDisplayType("Driver")
            if "dependency" in coreComponent:
                for item in coreComponent['dependency']:
                    Component.addDependency("drv_" + Name + "_" + item + "_dependency", item)
