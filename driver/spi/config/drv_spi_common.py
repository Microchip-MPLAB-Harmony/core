# coding: utf-8
"""*****************************************************************************
* © 2018 Microchip Technology Inc. and its subsidiaries.
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

def instantiateComponent(spiComponentCommon):

    res = Database.activateComponents(["HarmonyCore"])

    spiMode = spiComponentCommon.createKeyValueSetSymbol("DRV_SPI_COMMON_MODE", None)
    spiMode.setLabel("Driver Mode")
    spiMode.addKey("ASYNC", "0", "Asynchronous")
    spiMode.addKey("SYNC", "1", "Synchronous")
    spiMode.setDisplayMode("Description")
    spiMode.setOutputMode("Key")
    spiMode.setVisible(True)
    spiMode.setDefaultValue(0)

    spiSymCommonSysCfgFile = spiComponentCommon.createFileSymbol("DRV_SPI_COMMON_CFG", None)
    spiSymCommonSysCfgFile.setType("STRING")
    spiSymCommonSysCfgFile.setOutputName("core.LIST_SYSTEM_CONFIG_H_DRIVER_CONFIGURATION")
    spiSymCommonSysCfgFile.setSourcePath("driver/spi/templates/system/system_config_common.h.ftl")
    spiSymCommonSysCfgFile.setMarkup(True)

    spiSymSystemDefIncFile = spiComponentCommon.createFileSymbol("DRV_SPI_SYSTEM_DEF", None)
    spiSymSystemDefIncFile.setType("STRING")
    spiSymSystemDefIncFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    spiSymSystemDefIncFile.setSourcePath("driver/spi/templates/system/system_definitions.h.ftl")
    spiSymSystemDefIncFile.setMarkup(True)
