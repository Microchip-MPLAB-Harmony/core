def loadModule():

    #define drivers and system services
    coreComponents = [{"name":"usart", "label": "USART", "type":"driver", "instance":"multi", "capability":["DRV_USART"], "dependency":["UART"], "condition":"True"},
                    {"name":"memory", "label": "MEMORY", "type":"driver", "instance":"multi", "capability":["DRV_MEDIA"], "dependency":["MEMORY"], "condition":"True"},
                    {"name":"sst26", "label": "SST26", "type":"driver", "instance":"single", "capability":["MEMORY"], "dependency":["QSPI"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAME70", "SAMS70"])'},
                    {"name":"sdhc", "label":"SDHC", "type":"driver", "instance":"multi", "capability":["DRV_MEDIA"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70"])'},
                    {"name":"time", "label": "TIME", "type":"system", "capability":["SYS_TIME"], "dependency":["TMR"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70"])'},
                    {"name":"console", "label": "CONSOLE", "type":"system", "capability":["SYS_CONSOLE"], "dependency":["UART"], "condition":"True"},
                    {"name":"fs", "label": "FILE SYSTEM", "type":"system", "capability":["SYS_FS"], "dependency":["DRV_MEDIA"], "condition":"True"},
                    {"name":"i2c", "label": "I2C", "type":"driver", "instance":"multi", "capability":["DRV_I2C"], "dependency":["I2C"], "condition":"True"},
                    {"name":"spi", "label": "SPI", "type":"driver", "instance":"multi", "capability":["DRV_SPI"], "dependency":["SPI"], "condition":"True"},
                    {"name":"i2s", "label": "I2S", "type":"driver", "instance":"multi", "capability":["DRV_I2S"], "dependency":["I2S"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "SAMD21"])'},
                    {"name":"at24", "label": "AT24", "type":"driver", "instance":"single", "capability":["MEMORY"], "dependency":["I2C"], "condition":"True"},
                    {"name":"at25", "label": "AT25", "type":"driver", "instance":"single", "capability":["MEMORY"], "dependency":["SPI"], "condition":"True"}
                    ]
    #load drivers and system services defined above
    execfile(Module.getPath() + "/config/core.py")
