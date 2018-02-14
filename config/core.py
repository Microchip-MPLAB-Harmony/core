def instantiateComponent(harmonyCoreComponent):
    Log.writeInfoMessage("Loaded Harmony Drivers and System Services")

    # Load driver layer common content
    execfile(Module.getPath() + "/driver/config/driver.py")

    # Load system service layer common content
    execfile(Module.getPath() + "/system/config/system.py")