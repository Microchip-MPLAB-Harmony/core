# Microchip MPLAB Harmony 3 Release Notes
## Core Release v3.1.0
### NEW FEATURES
- **New part support** - This release introduces initial support for [SAM C20/C21](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-c-mcus), [SAM D20/D21](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-d-mcus), [SAM S70](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-s-mcus), [SAM E70](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-e-mcus), [SAM V70/V71](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-v-mcus) families of 32-bit microcontrollers.

- **Driver and System Services** - The following table provides the list of core components

| Type | Module Name |  Module Caption |
| --- | --- | --- |
| Driver | DRV\_AT24 | [AT24](https://www.microchip.com/design-centers/memory/serial-eeprom) I2C EEPROM Driver |
| Driver | DRV\_AT25 | [AT25](https://www.microchip.com/design-centers/memory/serial-eeprom) SPI EEPROM Driver |
| Driver | DRV\_I2C | I2C Driver |
| Driver | DRV\_I2S | I2S Driver |
| Driver | DRV\_MEMORY | MEMORY Driver |
| Driver | DRV\_SDHC | SDHC Driver |
| Driver | DRV\_SDSPI | SD Card (SPI) Driver |
| Driver | DRV\_SPI | SPI Driver |
| Driver | DRV\_SST26 | [SST26](https://www.microchip.com/ParamChartSearch/chart.aspx?branchID=71201) QSPI Flash Driver |
| Driver | DRV\_USART | USART Driver |
| OSAL | OSAL | OSAL Library |
| System Service | SYS\_CMD | Command Processor System Service |
| System Service | SYS\_CONSOLE | Console System Service |
| System Service | SYS\_DEBUG | Debug System Service |
| System Service | SYS\_DMA | DMA System Service |
| System Service | SYS\_FS | File System Service |
| System Service | SYS\_INT | Interrupt System Service |
| System Service | SYS\_PORT | Port System Service |
| System Service | SYS\_TIME | Time System Service |

- **Development kit and demo application support** - The following table provides number of bare-metal and RTOS demo application available for different development kits.

| Development kits | Bare-metal applications | RTOS applications |
| --- | --- | --- |
| [SAM C21N Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMC21-XPRO) | 11 | 11 |
| [SAM D20 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD20-XPRO) | 7 | 1 |
| [SAM D21 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD21-XPRO) | 7 | 1 |
| [SAM E70 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAME70-XULT) | 17 | 29 |
| [SAM V71 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMV71-XULT) | 10 | 19 |

### KNOWN ISSUES

The current known issues are as follows:

- The device does not run after programming the device through EDBG. The user needs to reset the device manually using the reset button on the Xplained boards to run the firmware.

- **Programming and debugging through EDBG is not supported.** The ICD4 needs to be used for programming and debugging.

- The ICD4 loads the reset line of the SAM V71 Xplained Ultra board. Do not press reset button on the Xplained Ultra board while ICD4 is connected to the board.

- Interactive help using the Show User Manual Entry in the Right-click menu for configuration options provided by this module is not yet available from within the MPLAB Harmony Configurator (MHC).  Please see the &quot;Configuring the Library&quot; section in the help documentation in the doc folder for this module instead.  Help is available in both CHM and PDF formats.

### DEVELOPMENT TOOLS

- [MPLAB X IDE v5.10](https://www.microchip.com/mplab/mplab-x-ide)
- [MPLAB XC32 C/C++ Compiler v2.15](https://www.microchip.com/mplab/compilers)
- MPLAB X IDE plug-ins:
 - MPLAB Harmony Configurator (MHC) v3.1
