def loadModule():

    #define drivers and system services
    coreComponents = [{"name":"usart", "label": "USART", "type":"driver", "dependency":["USART","UART"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
                    {"name":"memory", "label": "MEMORY", "type":"driver", "dependency":["MEMORY"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
                    {"name":"sdhc", "label":"SDHC", "type":"driver", "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
                    {"name":"time", "label": "TIME", "type":"system", "dependency":["TC"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
                    {"name":"fs", "label": "FILE SYSTEM", "type":"system", "condition":"True"},
                    {"name":"i2c", "label": "I2C", "type":"driver", "dependency":["I2C"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
                    {"name":"spi", "label": "SPI", "type":"driver", "dependency":["SPI"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'}]
    #load drivers and system services defined above
    execfile(Module.getPath() + "/config/core.py")
