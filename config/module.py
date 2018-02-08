def loadModule():

	#define drivers and system services
	coreComponents = [{"name":"usart", "type":"driver", "dependency":["USART", "sys_core","sys_dma", "sys_int", "OSAL"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
					{"name":"mediaflash", "type":"driver", "dependency":["EFC", "sys_core", "sys_int", "OSAL"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
					{"name":"int", "type":"system", "condition":"True"},
					{"name":"dma", "type":"system", "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
					{"name":"sdhc", "type":"driver", "dependency":["sys_core","sys_dma", "sys_int", "OSAL"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
					{"name":"fs", "type":"system", "condition":"True"},
                    {"name":"i2c", "type":"driver", "dependency":["TWI", "sys_core", "sys_int", "OSAL"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'}]

	#load drivers and system services defined above
	execfile(Module.getPath() + "/config/core.py")