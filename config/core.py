# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*****************************************************************************"""


print("Load Module: Harmony Drivers & System Services")

thirdPartyFreeRTOS = Module.CreateComponent("FreeRTOS", "FreeRTOS", "/Third Party Libraries/RTOS/", "config/freertos.py")
thirdPartyFreeRTOS.setDisplayType("Third Party Library")
thirdPartyFreeRTOS.addCapability("FreeRTOS", "RTOS", True)
thirdPartyFreeRTOS.setHelpKeyword("MH3_CORE_FreeRTOS")

harmonySystemService = Module.CreateSharedComponent("HarmonyCore", "Core", "/Core/", "config/harmonycore.py")
harmonySystemService.setDisplayType("Harmony Core Service")
harmonySystemService.addDependency("harmony_RTOS_dependency", "RTOS", True, False)
harmonySystemService.addCapability("HarmonyCoreService", "Core Service", True)

#load harmony drivers and system services from the list
for coreComponent in coreComponents:

    #check if component should be created
    if eval(coreComponent['condition']):
        Name        = coreComponent['name']
        Label       = coreComponent['label']

        #create system component
        if coreComponent['type'] == "system":
            print("create component: " + Name.upper() + " System Service")
            actualPath  = "system/" + coreComponent['actual_path'] + "/"
            displayPath = "/System Services/" + coreComponent['display_path']

            if "instance" in coreComponent:
                Component = Module.CreateGeneratorComponent("sys_" + Name, Label, displayPath, actualPath + Name + "/config/sys_" + Name + "_common.py", actualPath + Name + "/config/sys_" + Name + ".py")
            else:
                Component = Module.CreateSharedComponent("sys_" + Name, Label, displayPath, actualPath + Name + "/config/sys_" + Name + ".py")

            if "capability" in coreComponent:
                for capability in coreComponent['capability']:
                    if "capability_type" in coreComponent:
                        if coreComponent['capability_type'] == "multi":
                            Component.addMultiCapability(capability.lower(), capability, capability)
                        elif coreComponent['capability_type'] == "generic":
                            Component.addCapability(capability.lower(), capability, True)
                        else:
                            Component.addCapability(capability.lower(), capability)
                    else:
                        Component.addCapability(capability.lower(), capability)

            if "dependency" in coreComponent:
                for dep in coreComponent['dependency']:
                    if "dependency_type" in coreComponent:
                        if coreComponent['dependency_type'] == "multi":
                            Component.addMultiDependency("sys_" + Name +  "_" + dep + "_dependency", dep, dep, True)
                        else:
                            Component.addDependency("sys_" + Name + "_" + dep + "_dependency", dep, False, True)
                    else:
                        if "is_dependency_required" in coreComponent:
                            Component.addDependency("sys_" + Name + "_" + dep + "_dependency", dep, False, eval(coreComponent['is_dependency_required']))
                        else:
                            Component.addDependency("sys_" + Name + "_" + dep + "_dependency", dep, False, True)

            Component.setDisplayType("System Service")

            # Add Generic Dependency on Core Service
            Component.addDependency("sys_" + Name + "_HarmonyCoreDependency", "Core Service", "Core Service", True, True)

        #create driver component
        elif coreComponent['type'] == "driver":
            print("create component: " + Name.upper() + " Driver")

            actualPath  = "driver/" + coreComponent['actual_path'] + "/"
            displayPath = "/Drivers/" + coreComponent['display_path']

            if coreComponent['instance'] == "multi":
                Component = Module.CreateGeneratorComponent("drv_" + Name, Label, displayPath, actualPath + Name + "/config/drv_" + Name + "_common.py", actualPath + Name + "/config/drv_" + Name + ".py")
            elif coreComponent['instance'] == "single":
                Component = Module.CreateComponent("drv_" + Name, Label, displayPath, actualPath + Name + "/config/drv_" + Name + ".py")
                Component.setHelpKeyword("MH3_CORE_drv_" + Name.lower())

            if "capability" in coreComponent:
                for capability in coreComponent['capability']:
                    if "capability_type" in coreComponent:
                        if coreComponent['capability_type'] == "multi":
                            Component.addMultiCapability(capability.lower(), capability, capability)
                        else:
                            Component.addCapability(capability.lower(), capability)
                    else:
                        Component.addCapability(capability.lower(), capability)

            if "dependency" in coreComponent:
                for dep in coreComponent['dependency']:
                    if (dep == "SYS_TIME"):
                        # Add generic dependency on Timer System Service
                        Component.addDependency("drv_" + Name + "_" + dep + "_dependency", dep, True, True)
                    else:
                        if "dependency_type" in coreComponent:
                            if coreComponent['dependency_type'] == "multi":
                                Component.addMultiDependency("drv_" + Name + "_" + dep + "_dependency", dep, dep, True)
                            else:
                                Component.addDependency("drv_" + Name + "_" + dep + "_dependency", dep, False, True)
                        else:
                            if "is_dependency_required" in coreComponent:
                                Component.addDependency("drv_" + Name + "_" + dep + "_dependency", dep, False, eval(coreComponent['is_dependency_required']))
                            else:
                                Component.addDependency("drv_" + Name + "_" + dep + "_dependency", dep, False, True)

            Component.setDisplayType("Driver")

            # Add Generic Dependency on Core Service
            Component.addDependency("drv_" + Name + "_HarmonyCoreDependency", "Core Service", "Core Service", True, True)

        #create library component
        elif coreComponent['type'] == "library":
            print("create component: " + Name.upper() + " Library")

            actualPath  = "libraries/" + coreComponent['actual_path'] + "/"
            displayPath = "/Libraries/" + coreComponent['display_path']

            if coreComponent['instance'] == "multi":
                Component = Module.CreateGeneratorComponent("lib_" + Name, Label, displayPath, actualPath + Name + "/config/lib_" + Name + "_common.py", actualPath + Name + "/config/lib_" + Name + ".py")
            elif coreComponent['instance'] == "single":
                Component = Module.CreateComponent("lib_" + Name, Label, displayPath, actualPath + Name + "/config/lib_" + Name + ".py")
                Component.setHelpKeyword("MH3_CORE_" + Name.lower())

            if "capability" in coreComponent:
                for capability in coreComponent['capability']:
                    if "capability_type" in coreComponent:
                        if coreComponent['capability_type'] == "multi":
                            Component.addMultiCapability(capability.lower(), capability, capability)
                        else:
                            Component.addCapability(capability.lower(), capability)
                    else:
                        Component.addCapability(capability.lower(), capability)

            if "dependency" in coreComponent:
                for dep in coreComponent['dependency']:
                    if (dep == "SYS_TIME"):
                        # Add generic dependency on Timer System Service
                        Component.addDependency("lib_" + Name + "_" + dep + "_dependency", dep, True, True)
                    else:
                        if "dependency_type" in coreComponent:
                            if coreComponent['dependency_type'] == "multi":
                                Component.addMultiDependency("lib_" + Name + "_" + dep + "_dependency", dep, dep, True)
                            else:
                                Component.addDependency("lib_" + Name + "_" + dep + "_dependency", dep, False, True)
                        else:
                            if "is_dependency_required" in coreComponent:
                                Component.addDependency("lib_" + Name + "_" + dep + "_dependency", dep, False, eval(coreComponent['is_dependency_required']))
                            else:
                                Component.addDependency("lib_" + Name + "_" + dep + "_dependency", dep, False, True)

            Component.setDisplayType("Library")

            # Add Generic Dependency on Core Service
            Component.addDependency("lib_" + Name + "_HarmonyCoreDependency", "Core Service", "Core Service", True, True)
