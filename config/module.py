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

def loadModule():

    #define drivers and system services
    coreComponents = [{"name":"time", "label": "TIME", "type":"system", "capability":["SYS_TIME"], "dependency":["TMR"], "condition": "True"},
                    {"name":"console", "label": "CONSOLE", "type":"system", "capability":["SYS_CONSOLE"], "dependency":["UART"], "condition":"True"},
                    {"name":"fs", "label": "FILE SYSTEM", "type":"system", "capability":["SYS_FS"], "dependency":["DRV_MEDIA"], "dependency_type":"multi", "condition":"True"},
                    {"name":"usart", "label": "USART", "type":"driver", "instance":"multi", "capability":["DRV_USART"], "dependency":["UART"], "condition":"True"},
                    {"name":"memory", "label": "MEMORY", "type":"driver", "instance":"multi", "capability":["DRV_MEDIA"], "capability_type":"multi", "dependency":["MEMORY"], "condition":"True"},
                    {"name":"sst26", "label": "SST26", "type":"driver", "instance":"single", "capability":["MEMORY"], "dependency":["QSPI"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAME70", "SAMS70"])'},
                    {"name":"sdhc", "label":"SDHC", "type":"driver", "instance":"multi", "capability":["DRV_MEDIA"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70"])'},
                    {"name":"i2c", "label": "I2C", "type":"driver", "instance":"multi", "capability":["DRV_I2C"], "dependency":["I2C"], "condition":"True"},
                    {"name":"spi", "label": "SPI", "type":"driver", "instance":"multi", "capability":["DRV_SPI"], "dependency":["SPI"], "condition":"True"},
                    {"name":"i2s", "label": "I2S", "type":"driver", "instance":"multi", "capability":["DRV_I2S"], "dependency":["I2S"], "condition":'any(x in Variables.get("__PROCESSOR") for x in ["SAMV70", "SAMV71", "SAME70", "SAMS70", "SAMD21"])'},
                    {"name":"at24", "label": "AT24", "type":"driver", "instance":"single", "capability":["MEMORY"], "dependency":["I2C"], "condition":"True"},
                    {"name":"at25", "label": "AT25", "type":"driver", "instance":"single", "capability":["MEMORY"], "dependency":["SPI"], "condition":"True"},
                    {"name":"sdspi", "label": "SD Card (SPI)", "type":"driver", "instance":"multi", "capability":["DRV_MEDIA"], "dependency":["SPI"], "condition":"True"}
                    ]
    #load drivers and system services defined above
    execfile(Module.getPath() + "/config/core.py")
