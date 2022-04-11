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

USBNamesList        = ["USB", "USBHS", "UDP"]
SDHCNamesList       = ["HSMCI", "SDHC", "SDMMC"]
SQINamesList        = ["QSPI", "SQI"]

def hasPeripheral(peripheralList):
    periphNode          = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
    peripherals         = periphNode.getChildren()

    for module in range (0, len(peripherals)):
        periphName = str(peripherals[module].getAttribute("name"))

        if ((any(x == periphName for x in peripheralList) == True)):
            return True
    return False

def emulated_eeprom_condition():
    arch = ATDF.getNode( "/avr-tools-device-file/devices/device" ).getAttribute( "architecture" )
    if arch == "CORTEX-M0PLUS" or arch == "CORTEX-M4" or arch == "CORTEX-M7" or arch == "CORTEX-M23":
        return True
    else:
        return False

def loadModule():

    i2c_bbComponent = Module.CreateComponent("i2c_bb", "I2C_BB", "/Libraries/", "/libraries/i2c_bb/config/lib_i2c_bb.py")
    i2c_bbComponent.setDisplayType("I2C BIT BANG")
    i2c_bbComponent.addCapability("I2C", "I2C", False)
    i2c_bbComponent.addDependency("TMR", "TMR", False, True)

    #define drivers and system services
    coreComponents = [
        {"name":"time", "label": "TIME", "type":"system", "display_path":"", "actual_path":"", "capability":["SYS_TIME"], "capability_type":"generic", "dependency":[  "TMR"], "condition": "True"},

        {"name":"console", "label": "CONSOLE", "type":"system", "display_path":"", "actual_path":"", "instance":"multi", "capability":["SYS_CONSOLE"], "capability_type":"multi", "dependency":["UART", "USB_DEVICE_CDC"] if hasPeripheral(USBNamesList) else ["UART"], "condition":"True", "is_dependency_required": "False"},

        {"name":"command", "label": "COMMAND", "type":"system", "display_path":"", "actual_path":"", "capability":["SYS_COMMAND"], "capability_type":"generic", "dependency":["SYS_CONSOLE"], "condition":"True"},

        {"name":"debug", "label": "DEBUG", "type":"system", "display_path":"", "actual_path":"", "capability":["SYS_DEBUG"], "capability_type":"generic", "dependency":["SYS_CONSOLE"], "condition":"True"},

        {"name":"fs", "label": "FILE SYSTEM", "type":"system", "display_path":"", "actual_path":"", "capability":["SYS_FS"], "capability_type":"generic", "dependency":["DRV_MEDIA"], "dependency_type":"multi", "condition":"True"},

        {"name":"usart", "label": "USART", "type":"driver", "display_path":"", "actual_path":"", "instance":"multi", "capability":["DRV_USART"], "dependency":["UART"], "condition":"True"},

        {"name":"memory", "label": "MEMORY", "type":"driver", "display_path":"", "actual_path":"", "instance":"multi", "capability":["DRV_MEDIA"], "capability_type":"multi", "dependency":["MEMORY"], "condition":"True"},

        {"name":"sst26", "label": "SST26", "type":"driver", "display_path":"SQI Flash", "actual_path":"sqi_flash", "instance":"single", "capability":["MEMORY"], "dependency":["SQI", "SPI", "DRV_SPI"] if hasPeripheral(SQINamesList) else ["SPI", "DRV_SPI"], "condition":"True"},

        {"name":"mx25l", "label": "MX25L", "type":"driver", "display_path":"SQI Flash", "actual_path":"sqi_flash", "instance":"single", "capability":["MEMORY"], "dependency":["SQI"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "SAMD5", "SAME5", "SAMA5D2", "SAM9X60"])'},

        {"name":"i2c", "label": "I2C", "type":"driver", "display_path":"", "actual_path":"", "instance":"multi", "capability":["DRV_I2C"], "dependency":["I2C"], "condition":"True"},

        {"name":"spi", "label": "SPI", "type":"driver", "display_path":"", "actual_path":"", "instance":"multi", "capability":["DRV_SPI"], "dependency":["SPI"], "condition":"True"},

        {"name":"at24", "label": "AT24", "type":"driver", "display_path":"I2C EEPROM", "actual_path":"i2c_eeprom", "instance":"single", "capability":["MEMORY"], "dependency":["I2C"], "condition":"True"},

        {"name":"at25", "label": "AT25", "type":"driver", "display_path":"SPI EEPROM", "actual_path":"spi_eeprom", "instance":"single", "capability":["MEMORY"], "dependency":["SPI"], "condition":"True"},

        {"name":"at25df", "label": "AT25DF", "type":"driver", "display_path":"SPI FLASH", "actual_path":"spi_flash", "instance":"single", "capability":["MEMORY"], "dependency":["SPI"], "condition":"True"},

        {"name":"sdmmc", "label":"SDMMC", "type":"driver", "display_path":"SDCARD", "actual_path":"", "instance":"multi", "capability":["DRV_MEDIA"], "capability_type":"multi", "dependency":["SDHC", "SYS_TIME"], "condition":'hasPeripheral(SDHCNamesList)'},

        {"name":"sdspi", "label": "SD Card (SPI)", "type":"driver", "display_path":"SDCARD", "actual_path":"", "instance":"multi", "capability":["DRV_MEDIA"], "capability_type":"multi", "dependency":["SPI", "DRV_SPI", "SYS_TIME"], "condition":"True", "is_dependency_required": "False"},

        {"name":"nand_flash", "label": "NAND FLASH", "type":"driver", "display_path":"SMC FLASH", "actual_path":"smc_flash", "instance":"single", "dependency":["NAND_CS"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAM9X"])'},

        {"name":"emulated_eeprom", "label": "Emulated EEPROM", "type":"library", "display_path":"", "actual_path":"", "instance":"single", "dependency":["MEMORY"], "condition":'emulated_eeprom_condition()'},

        ]

    #load drivers and system services defined above
    execfile(Module.getPath() + "/config/core.py")
