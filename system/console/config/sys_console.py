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

################################################################################
#### Business Logic ####
################################################################################

def selectDeviceSet(symbol, event):
    symbol.clearValue()
    if "USART" or "UART" or "SERCOM" or "FLEXCOM" in event["value"]:
        symbol.setValue("UART")
    elif "USB" in event["value"]:
        symbol.setValue("USB_CDC")
    elif "APP" in event["value"]:
        symbol.setValue("APPIO")
    else:
        Log.WriteErrorMessage("Incorrect Component is attached to Console System Service")

################################################################################
#### Component ####
################################################################################

def instantiateComponent(consoleComponent, index):

    # Enable dependent Harmony core components
    if (Database.getSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON")
        Database.setSymbolValue("HarmonyCore", "ENABLE_SYS_COMMON", True)

    if (Database.getSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON") == False):
        Database.clearSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON")
        Database.setSymbolValue("HarmonyCore", "ENABLE_DRV_COMMON", True)

    consoleIndex = consoleComponent.createIntegerSymbol("INDEX", None)
    consoleIndex.setVisible(False)
    consoleIndex.setDefaultValue(index)

    consoleDevice = consoleComponent.createStringSymbol("SYS_CONSOLE_DEVICE", None)
    consoleDevice.setLabel("Device Used")
    consoleDevice.setReadOnly(True)
    consoleDevice.setDefaultValue("")

    consoleUARTIndex = consoleComponent.createIntegerSymbol("SYS_CONSOLE_DEVICE_UART_INDEX", None)
    consoleUARTIndex.setVisible(False)
    consoleUARTIndex.setDefaultValue(0)
    consoleUARTIndex.setUseSingleDynamicValue(True)

    consoleDeviceSet = consoleComponent.createStringSymbol("SYS_CONSOLE_DEVICE_SET", None)
    consoleDeviceSet.setLabel("Device Set")
    consoleDeviceSet.setVisible(False)
    consoleDeviceSet.setDependencies(selectDeviceSet, ["SYS_CONSOLE_DEVICE"])
    consoleDeviceSet.setDefaultValue("")

    consoleSymTXQueueSize = consoleComponent.createIntegerSymbol("SYS_CONSOLE_TX_QUEUE_SIZE", None)
    consoleSymTXQueueSize.setLabel("Transmit Buffer Queue Size (1-128)")
    consoleSymTXQueueSize.setMin(1)
    consoleSymTXQueueSize.setMax(128)
    consoleSymTXQueueSize.setDefaultValue(64)

    consoleSymRXQueueSize = consoleComponent.createIntegerSymbol("SYS_CONSOLE_RX_QUEUE_SIZE", None)
    consoleSymRXQueueSize.setLabel("Receive Buffer Queue Size (1-128)")
    consoleSymRXQueueSize.setMin(1)
    consoleSymRXQueueSize.setMax(128)
    consoleSymRXQueueSize.setDefaultValue(10)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    consoleSystemDefObjFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_DEF_OBJ", None)
    consoleSystemDefObjFile.setType("STRING")
    consoleSystemDefObjFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_OBJECTS")
    consoleSystemDefObjFile.setSourcePath("system/console/templates/system/system_definitions_objects.h.ftl")
    consoleSystemDefObjFile.setMarkup(True)

    consoleSystemConfigFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_CONFIG", None)
    consoleSystemConfigFile.setType("STRING")
    consoleSystemConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION")
    consoleSystemConfigFile.setSourcePath("system/console/templates/system/system_config.h.ftl")
    consoleSystemConfigFile.setMarkup(True)

    consoleSystemInitDataFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_INIT_DATA", None)
    consoleSystemInitDataFile.setType("STRING")
    consoleSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYSTEM_INITIALIZATION")
    consoleSystemInitDataFile.setSourcePath("system/console/templates/system/system_initialize_data.c.ftl")
    consoleSystemInitDataFile.setMarkup(True)

    consoleSystemInitFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_INIT", None)
    consoleSystemInitFile.setType("STRING")
    consoleSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_INITIALIZE_SYSTEM_SERVICES")
    consoleSystemInitFile.setSourcePath("system/console/templates/system/system_initialize.c.ftl")
    consoleSystemInitFile.setMarkup(True)

############################################################################
#### Dependency ####
############################################################################

def onAttachmentConnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]
    
    print "local component"
    print localComponent.getID()

    if connectID == "sys_console_UART_dependency" :
        deviceUsed = localComponent.getSymbolByID("SYS_CONSOLE_DEVICE")
        deviceUsed.setValue(remoteID.upper())

        if "USART" or "UART" or "SERCOM" or "FLEXCOM" in remoteID:
            console_uart_connection_counter_dict = {}
            console_uart_connection_counter_dict = Database.sendMessage("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER_INC", console_uart_connection_counter_dict)
        elif "USB" in remoteID:
            console_usb_connection_counter_dict = {}
            console_usb_connection_counter_dict = Database.sendMessage("sys_console", "SYS_CONSOLE_USB_CONNECTION_COUNTER_INC", console_usb_connection_counter_dict)

def onAttachmentDisconnected(source, target):
    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if connectID == "sys_console_UART_dependency" :
        deviceUsed = localComponent.getSymbolByID("SYS_CONSOLE_DEVICE")
        deviceUsed.clearValue()

        if "USART" or "UART" or "SERCOM" or "FLEXCOM" in remoteID:
            console_uart_connection_counter_dict = {}
            console_uart_connection_counter_dict = Database.sendMessage("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER_DEC", console_uart_connection_counter_dict)
            #localComponent.getSymbolByID("SYS_CONSOLE_DEVICE_UART_INDEX").setValue(0)
        elif "USB" in remoteID:
            console_usb_connection_counter_dict = {}
            console_usb_connection_counter_dict = Database.sendMessage("sys_console", "SYS_CONSOLE_USB_CONNECTION_COUNTER_INC", console_usb_connection_counter_dict)