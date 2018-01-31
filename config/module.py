def loadModule():

	#define drivers and system services
	coreComponents = [{"name":"usart", "type":"driver", "dependency":"USART", "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'},
					{"name":"int", "type":"system", "condition":"True"},
					{"name":"dma", "type":"system", "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "PIC32CZ"])'}]

	#load drivers and system services defined above
	execfile(Module.getPath() + "/config/core.py")