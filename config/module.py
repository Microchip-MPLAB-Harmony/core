def loadModule():

    #define drivers and system services
    coreComponents = [{"name":"usart", "type":"driver", "dependency":["USART"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
                    {"name":"memory", "type":"driver", "dependency":["memory_dev"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
                    {"name":"sdhc", "type":"driver", "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
                    {"name":"mediaflash", "type":"driver", "dependency":["EFC"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
                    {"name":"time", "type":"system", "dependency":["TC"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
                    {"name":"fs", "type":"system", "condition":"True"},
                    {"name":"i2c", "type":"driver", "dependency":["TWIHS"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
                    {"name":"spi", "type":"driver", "dependency":["SPI"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'}]
    #load drivers and system services defined above
    execfile(Module.getPath() + "/config/core.py")
