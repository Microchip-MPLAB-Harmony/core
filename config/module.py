def loadModule():

    #define drivers and system services
    coreComponents = [{"name":"usart", "label": "USART", "type":"driver", "instance":"multi", "capability":"DRV_USART", "dependency":["UART"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70"])'},
                    {"name":"memory", "label": "MEMORY", "type":"driver", "instance":"multi", "capability":"DRV_MEMORY", "dependency":["MEMORY"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70"])'},
                    {"name":"sst26", "label": "SST26", "type":"driver", "instance":"single", "capability":"MEMORY", "dependency":["QSPI"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAME70", "SAMS70"])'},
                    {"name":"sdhc", "label":"SDHC", "type":"driver", "instance":"multi", "capability":"DRV_SDHC", "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70"])'},
                    {"name":"time", "label": "TIME", "type":"system", "capability":"SYS_TIME", "dependency":["TMR"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70"])'},
                    {"name":"console", "label": "CONSOLE", "type":"system", "capability":"SYS_CONSOLE", "dependency":["UART"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70"])'},
                    {"name":"fs", "label": "FILE SYSTEM", "type":"system", "capability":"SYS_FS", "condition":"True"},
                    {"name":"i2c", "label": "I2C", "type":"driver", "instance":"multi", "capability":"DRV_I2C", "dependency":["I2C"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70"])'},
                    {"name":"spi", "label": "SPI", "type":"driver", "instance":"multi", "capability":"DRV_SPI", "dependency":["SPI"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70"])'},
                    {"name":"i2s", "label": "I2S", "type":"driver", "instance":"multi", "capability":"DRV_I2S", "dependency":["I2S"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70"])'},
                    {"name":"at24", "label": "AT24", "type":"driver", "instance":"single", "capability":"MEMORY", "dependency":["I2C"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAME70", "SAMS70"])'},
                    {"name":"at25", "label": "AT25", "type":"driver", "instance":"single", "capability":"MEMORY", "dependency":["SPI"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAME70", "SAMS70"])'}
					]
    #load drivers and system services defined above
    execfile(Module.getPath() + "/config/core.py")
