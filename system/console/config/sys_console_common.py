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
    if (messageID == "SYS_CONSOLE_UART_CONNECTION_COUNTER_INC"):
        consoleUARTCounter = Database.getSymbolValue("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER")
        Database.setSymbolValue("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER", consoleUARTCounter + 1)
    if (messageID == "SYS_CONSOLE_UART_CONNECTION_COUNTER_DEC"):
        consoleUARTCounter = Database.getSymbolValue("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER")
        if (consoleUARTCounter != 0):
            Database.setSymbolValue("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER", consoleUARTCounter - 1)
    if (messageID == "SYS_CONSOLE_USB_CONNECTION_COUNTER_INC"):
        consoleUSBCounter = Database.getSymbolValue("sys_console", "SYS_CONSOLE_USB_CONNECTION_COUNTER")
        Database.setSymbolValue("sys_console", "SYS_CONSOLE_USB_CONNECTION_COUNTER", consoleUSBCounter + 1)
    if (messageID == "SYS_CONSOLE_USB_CONNECTION_COUNTER_DEC"):
        consoleUSBCounter = Database.getSymbolValue("sys_console", "SYS_CONSOLE_USB_CONNECTION_COUNTER")
        if (consoleUSBCounter != 0):
            Database.setSymbolValue("sys_console", "SYS_CONSOLE_USB_CONNECTION_COUNTER", consoleUSBCounter - 1)

    return result_dict

def updateConsoleConnectionCounter(symbol, event):

    consoleUARTCounter = Database.getSymbolValue("sys_console", "SYS_CONSOLE_UART_CONNECTION_COUNTER")
    consoleInstances = filter(lambda k: "sys_console_" in k, Database.getActiveComponentIDs())

    uart_count = 0
    usb_count = 0
    for consoleInstance in sorted(consoleInstances):
        if Database.getSymbolValue(consoleInstance, "SYS_CONSOLE_DEVICE_SET") == "UART":
            Database.setSymbolValue(consoleInstance, "SYS_CONSOLE_DEVICE_UART_INDEX", uart_count, 1)
            uart_count += 1
        if Database.getSymbolValue(consoleInstance, "SYS_CONSOLE_DEVICE_SET") == "USB_CDC":
            Database.setSymbolValue(consoleInstance, "SYS_CONSOLE_DEVICE_USB_INDEX", usb_count, 1)
            usb_count += 1
            if Database.getSymbolValue(consoleInstance, "SYS_CONSOLE_USB_DEVICE_SPEED") == "High Speed":
                Database.setSymbolValue("sys_console", "SYS_CONSOLE_USB_READ_WRITE_BUFFER_SIZE", 512)
            else:
                Database.setSymbolValue("sys_console", "SYS_CONSOLE_USB_READ_WRITE_BUFFER_SIZE", 64)

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
    consoleUARTConnectionCounter.setReadOnly(True)

    consoleUSBConnectionCounter = consoleComponent.createIntegerSymbol("SYS_CONSOLE_USB_CONNECTION_COUNTER", None)
    consoleUSBConnectionCounter.setLabel("Number of Instances Using USB")
    consoleUSBConnectionCounter.setVisible(True)
    consoleUSBConnectionCounter.setDefaultValue(0)
    consoleUSBConnectionCounter.setUseSingleDynamicValue(True)
    consoleUSBConnectionCounter.setReadOnly(True)

    consolePrintBufferSize = consoleComponent.createIntegerSymbol("SYS_CONSOLE_PRINT_BUFFER_SIZE", None)
    consolePrintBufferSize.setLabel("Console Print Buffer Size (128-8192)")
    consolePrintBufferSize.setMin(128)
    consolePrintBufferSize.setMax(8192)
    consolePrintBufferSize.setDefaultValue(200)

    consoleUARTConnectionEnable = consoleComponent.createBooleanSymbol("SYS_CONSOLE_UART_CONNECTION_COUNTER_UPDATE", None)
    consoleUARTConnectionEnable.setVisible(False)
    consoleUARTConnectionEnable.setDependencies(updateConsoleConnectionCounter, ["SYS_CONSOLE_UART_CONNECTION_COUNTER"])

    consoleUSBConnectionEnable = consoleComponent.createBooleanSymbol("SYS_CONSOLE_USB_CONNECTION_COUNTER_UPDATE", None)
    consoleUSBConnectionEnable.setVisible(False)
    consoleUSBConnectionEnable.setDependencies(updateConsoleConnectionCounter, ["SYS_CONSOLE_USB_CONNECTION_COUNTER"])

    consoleUSBConnectionEnable = consoleComponent.createIntegerSymbol("SYS_CONSOLE_USB_READ_WRITE_BUFFER_SIZE", None)
    consoleUSBConnectionEnable.setVisible(False)
    consoleUSBConnectionEnable.setDefaultValue(512)

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

    consoleSourceFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SOURCE", None)
    consoleSourceFile.setSourcePath("system/console/src/sys_console.c")
    consoleSourceFile.setOutputName("sys_console.c")
    consoleSourceFile.setDestPath("system/console/src")
    consoleSourceFile.setProjectPath("config/" + configName + "/system/console/")
    consoleSourceFile.setType("SOURCE")
    consoleSourceFile.setOverwrite(True)

    consoleHeaderLocalFile = consoleComponent.createFileSymbol("SYS_CONSOLE_UART_LOCAL", None)
    consoleHeaderLocalFile.setSourcePath("system/console/sys_console_local.h")
    consoleHeaderLocalFile.setOutputName("sys_console_local.h")
    consoleHeaderLocalFile.setDestPath("system/console/src")
    consoleHeaderLocalFile.setProjectPath("config/" + configName + "/system/console/")
    consoleHeaderLocalFile.setType("SOURCE")
    consoleHeaderLocalFile.setOverwrite(True)

    consoleSystemCommonConfigFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_COMMON_CONFIG", None)
    consoleSystemCommonConfigFile.setType("STRING")
    consoleSystemCommonConfigFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_SYSTEM_SERVICE_CONFIGURATION")
    consoleSystemCommonConfigFile.setSourcePath("system/console/templates/system/system_config_common.h.ftl")
    consoleSystemCommonConfigFile.setMarkup(True)

    consoleSystemDefFile = consoleComponent.createFileSymbol("SYS_CONSOLE_SYS_DEF", None)
    consoleSystemDefFile.setType("STRING")
    consoleSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    consoleSystemDefFile.setSourcePath("system/console/templates/system/system_definitions.h.ftl")
    consoleSystemDefFile.setMarkup(True)