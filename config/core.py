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

thirdPartyFreeRTOS = Module.CreateComponent("FreeRTOS", "FreeRTOS", "//Third Party Libraries/RTOS/", "config/freertos.py")
thirdPartyFreeRTOS.setDisplayType("Third Party Library")
thirdPartyFreeRTOS.addCapability("FreeRTOS", "RTOS", True)

harmonySystemService = Module.CreateSharedComponent("HarmonyCore", "Core", "/Harmony", "config/harmonycore.py")
harmonySystemService.setDisplayType("Harmony Core Service")
harmonySystemService.addDependency("harmony_RTOS_dependency", "RTOS", True, False)
harmonySystemService.addCapability("HarmonyCoreService", "Core Service", True)

#load harmony drivers and system services from the list 
for coreComponent in coreComponents:

    #check if component should be created
    if eval(coreComponent['condition']):
        Name = coreComponent['name']
        Label = coreComponent['label']

        #create system component
        if coreComponent['type'] == "system":
            print("create component: " + Name.upper() + " System Service")
            Component = Module.CreateSharedComponent("sys_" + Name, Label, "/Harmony/System Services", "system/" + Name + "/config/sys_" + Name + ".py")

            if "capability" in coreComponent:
                for capability in coreComponent['capability']:
                    Component.addCapability(capability.lower(), capability)

            if "dependency" in coreComponent:
                for dep in coreComponent['dependency']:
                    if Name == "fs":
                        for media_idx in range(1, 4):
                            if (media_idx == 1):
                                Component.addDependency("sys_" + Name + "_" + dep + str(media_idx) + "_dependency", dep, False, True)
                            else:
                                Component.addDependency("sys_" + Name + "_" + dep + str(media_idx) + "_dependency", dep, False, False)
                    else:
                        Component.addDependency("sys_" + Name + "_" + dep + "_dependency", dep, False, True)

            Component.setDisplayType("System Service")
        #create driver component
        else:
            print("create component: " + Name.upper() + " Driver")

            if coreComponent['instance'] == "multi":
                Component = Module.CreateGeneratorComponent("drv_" + Name, Label, "/Harmony/Drivers/", "driver/" + Name + "/config/drv_" + Name + "_common.py", "driver/" + Name + "/config/drv_" + Name + ".py")
            elif coreComponent['instance'] == "single":
                Component = Module.CreateComponent("drv_" + Name, Label, "/Harmony/Drivers/", "driver/" + Name + "/config/drv_" + Name + ".py")

            if "capability" in coreComponent:
                for capability in coreComponent['capability']:
                    Component.addCapability(capability.lower(), capability)

            Component.setDisplayType("Driver")
            if "dependency" in coreComponent:
                for dep in coreComponent['dependency']:
                    Component.addDependency("drv_" + Name + "_" + dep + "_dependency", dep, False, True)

        Component.addDependency("drv_" + Name + "_HarmonyCoreDependency", "Core Service", "Core Service", True, True)
