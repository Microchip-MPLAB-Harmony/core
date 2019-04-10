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

def handleMessage(messageID, args):
    result_dict = {}
    print "handleMessage called"
    if (messageID == "SYS_CONSOLE_UART_CONNECTION_COUNTER_INC"):
        consoleUARTCounter = Database.getSymbolValue("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER")
        Database.setSymbolValue("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER", consoleUARTCounter + 1)
    if (messageID == "SYS_CONSOLE_UART_CONNECTION_COUNTER_DEC"):
        consoleUARTCounter = Database.getSymbolValue("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER")
        if (consoleUARTCounter != 0):
            Database.setSymbolValue("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER", consoleUARTCounter - 1)
        else:
            return None
    if (messageID == "SYS_CONSOLE_USB_CONNECTION_COUNTER_INC"):
        consoleUSBCounter = Database.getSymbolValue("sys_console", "SYS_CONSOLE_USB_CONNECTION_COUNTER")
        Database.setSymbolValue("sys_console", "SYS_CONSOLE_USB_CONNECTION_COUNTER", consoleUSBCounter + 1)
    if (messageID == "SYS_CONSOLE_USB_CONNECTION_COUNTER_DEC"):
        consoleUSBCounter = Database.getSymbolValue("sys_console", "SYS_CONSOLE_USB_CONNECTION_COUNTER")
        if (consoleUSBCounter != 0):
            Database.setSymbolValue("sys_console", "SYS_CONSOLE_USB_CONNECTION_COUNTER", consoleUSBCounter - 1)
        else:
            return None

    return result_dict

def updateConsoleUARTConnectionCounter(symbol, event):

    consoleUARTCounter = Database.getSymbolValue("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER")
    consoleInstances = filter(lambda k: "sys_console_" in k, Database.getActiveComponentIDs())

    print "updateConsoleUARTConnectionCounter :- consoleInstances :", consoleInstances

    count = 0
    for consoleInstance in sorted(consoleInstances):
        if Database.getSymbolValue(consoleInstance, "SYS_CONSOLE_DEVICE") != "":
            Database.setSymbolValue(consoleInstance, "SYS_CONSOLE_DEVICE_UART_INDEX", count, 1)
            count += 1
            print "for :- connected :-",  consoleInstance

def updateConsoleUSBConnectionCounter(symbol, event):
    global consoleUSBCounter

    if event["value"] == True:
        consoleUSBCounter = consoleUSBCounter + 1
    else:
        if consoleUSBCounter != 0:
            consoleUSBCounter = consoleUSBCounter - 1

################################################################################
#### Component ####
################################################################################

def instantiateComponent(consoleComponent):

    res = Database.activateComponents(["HarmonyCore"])

    consoleUARTConnectionCounter = consoleComponent.createIntegerSymbol("SYS_CONSOLE_UART_CONNECTION_COUNTER", None)
    consoleUARTConnectionCounter.setLabel("Number of Instances Using UART")
    consoleUARTConnectionCounter.setVisible(True)
    consoleUARTConnectionCounter.setDefaultValue(0)
    consoleUARTConnectionCounter.setUseSingleDynamicValue(True)

    consoleUSBConnectionCounter = consoleComponent.createIntegerSymbol("SYS_CONSOLE_USB_CONNECTION_COUNTER", None)
    consoleUSBConnectionCounter.setLabel("Number of Instances Using USB")
    consoleUSBConnectionCounter.setVisible(True)
    consoleUSBConnectionCounter.setDefaultValue(0)
    consoleUSBConnectionCounter.setUseSingleDynamicValue(True)

    consoleUARTConnectionEnable = consoleComponent.createBooleanSymbol("SYS_CONSOLE_UART_CONNECTION_COUNTER_UPDATE", None)
    consoleUARTConnectionEnable.setVisible(False)
    consoleUARTConnectionEnable.setDependencies(updateConsoleUARTConnectionCounter, ["SYS_CONSOLE_UART_CONNECTION_COUNTER"])

    consoleUSBConnectionEnable = consoleComponent.createBooleanSymbol("SYS_CONSOLE_USB_CONNECTION_COUNTER_UPDATE", None)
    consoleUSBConnectionEnable.setVisible(False)
    consoleUSBConnectionEnable.setDependencies(updateConsoleUSBConnectionCounter, ["SYS_CONSOLE_USB_CONNECTION_COUNTER"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    consoleHeaderFile = consoleComponent.createFileSymbol("SYS_CONSOLE_HEADER", None)
    consoleHeaderFile.setSourcePath("system/console/sys_console.h")
    consoleHeaderFile.setOutputName("sys_console.h")
    consoleHeaderFile.setDestPath("system/console/")
    consoleHeaderFile.setProjectPath("config/" + configName + "/system/console/")
    consoleHeaderFile.setType("HEADER")
    consoleHeaderFile.setOverwrite(True)

    consoleHeaderLocalFile = consoleComponent.createFileSymbol("SYS_CONSOLE_LOCAL", None)
    consoleHeaderLocalFile.setSourcePath("system/console/src/sys_console_local.h")
    consoleHeaderLocalFile.setOutputName("sys_console_local.h")
    consoleHeaderLocalFile.setDestPath("system/console/src")
    consoleHeaderLocalFile.setProjectPath("config/" + configName + "/system/console/")
    consoleHeaderLocalFile.setType("SOURCE")
    consoleHeaderLocalFile.setOverwrite(True)

    consoleSourceFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SOURCE", None)
    consoleSourceFile.setSourcePath("system/console/src/sys_console.c")
    consoleSourceFile.setOutputName("sys_console.c")
    consoleSourceFile.setDestPath("system/console/src")
    consoleSourceFile.setProjectPath("config/" + configName + "/system/console/")
    consoleSourceFile.setType("SOURCE")
    consoleSourceFile.setOverwrite(True)

    consoleUARTHeaderFile = consoleComponent.createFileSymbol("SYS_CONSOLE_UART_HEADER", None)
    consoleUARTHeaderFile.setSourcePath("system/console/src/sys_console_uart.h")
    consoleUARTHeaderFile.setOutputName("sys_console_uart.h")
    consoleUARTHeaderFile.setDestPath("system/console/src")
    consoleUARTHeaderFile.setProjectPath("config/" + configName + "/system/console/")
    consoleUARTHeaderFile.setType("SOURCE")
    consoleUARTHeaderFile.setOverwrite(True)

    consoleUARTDefinitionsHeaderFile = consoleComponent.createFileSymbol("SYS_CONSOLE_UART_DEFINITIONS_HEADER", None)
    consoleUARTDefinitionsHeaderFile.setSourcePath("system/console/src/sys_console_uart_definitions.h")
    consoleUARTDefinitionsHeaderFile.setOutputName("sys_console_uart_definitions.h")
    consoleUARTDefinitionsHeaderFile.setDestPath("system/console/src")
    consoleUARTDefinitionsHeaderFile.setProjectPath("config/" + configName + "/system/console/")
    consoleUARTDefinitionsHeaderFile.setType("SOURCE")
    consoleUARTDefinitionsHeaderFile.setOverwrite(True)

    consoleUARTSourceFile = consoleComponent.createFileSymbol("SYS_CONSOLE_UART_SOURCE", None)
    consoleUARTSourceFile.setSourcePath("system/console/src/sys_console_uart.c")
    consoleUARTSourceFile.setOutputName("sys_console_uart.c")
    consoleUARTSourceFile.setDestPath("system/console/src")
    consoleUARTSourceFile.setProjectPath("config/" + configName + "/system/console/")
    consoleUARTSourceFile.setType("SOURCE")
    consoleUARTSourceFile.setOverwrite(True)

    consoleSystemDefFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_DEF", None)
    consoleSystemDefFile.setType("STRING")
    consoleSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    consoleSystemDefFile.setSourcePath("system/console/templates/system/system_definitions.h.ftl")
    consoleSystemDefFile.setMarkup(True)

    consoleSystemCommonConfigFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_COMMON_CONFIG", None)
    consoleSystemCommonConfigFile.setType("STRING")
    consoleSystemCommonConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION")
    consoleSystemCommonConfigFile.setSourcePath("system/console/templates/system/system_config_common.h.ftl")
    consoleSystemCommonConfigFile.setMarkup(True)