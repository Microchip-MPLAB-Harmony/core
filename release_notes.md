![Microchip logo](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_logo.png)
![Harmony logo small](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_mplab_harmony_logo_small.png)

# Microchip MPLAB® Harmony 3 Release Notes
## Core Release v3.2.1
### New Features

- **New part support** - This release introduces initial support for [PIC32MK](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mk-family) family of 32-bit microcontrollers.

- **Development kit and demo application support** - The following table provides number of demo application available for different development kits newly added in this release.

    | Development kits | Bare-metal applications | RTOS applications |
    | --- | --- | --- |
    | [PIC32MK GP Development Kit](https://www.microchip.com/developmenttools/ProductDetails/dm320106) | 6 |3|
    | [ATSAMA5D2C-XULT](https://www.microchip.com/Developmenttools/ProductDetails/ATSAMA5D2C-XULT) | 13 |22|
    | [PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit (Crypto)](https://www.microchip.com/DevelopmentTools/ProductDetails/DM320010-C) | 7 |5|
    | [PIC32MZ Embedded Connectivity with FPU (EF) Starter Kit](https://www.microchip.com/Developmenttools/ProductDetails/Dm320007) | 8 |11|
    | [SAM E54 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAME54-XPRO) | 15|16|
    | [SAM C21N Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMC21-XPRO) | 11 | 11 |
    | [SAM D20 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD20-XPRO) | 7 | 1 |
    | [SAM D21 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD21-XPRO) | 7 | 1 |
    | [SAM E70 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAME70-XULT) | 17 | 29 |
    | [SAM V71 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMV71-XULT) | 10 | 19 |

### Known Issues

The current known issues are as follows:

- Programming and debugging through PKOB is not yet supported for PIC32MZ DA, need to use external debugger (ICD4)

- PIC32MZ DA(S) device family will be supported by next coming XC32 release.

- The ICD4 loads the reset line of the SAM V71 Xplained Ultra board. The ICD4 flex cable must be removed after programming the device to run the application.

- Interactive help using the Show User Manual Entry in the Right-click menu for configuration options provided by this module is not yet available from within the MPLAB Harmony Configurator (MHC).  Please see the &quot;Configuring the Library&quot; section in the help documentation in the doc folder for this module instead.  Help is available in both CHM and PDF formats.

- ATSAMA5D2C demo applications build with a warning message: ```Warning[Pe111]: statement is unreachable for return ( EXIT_FAILURE ); statement of main() in IAR```

### Development Tools

* [MPLAB® X IDE v5.15](https://www.microchip.com/mplab/mplab-x-ide)
* [MPLAB® XC32 C/C++ Compiler v2.15](https://www.microchip.com/mplab/compilers)
* [IAR Embedded Workbench® for ARM® (v8.32 or above)](https://www.iar.com/iar-embedded-workbench/#!?architecture=Arm)
* MPLAB® X IDE plug-ins:
  * MPLAB® Harmony Configurator (MHC) v3.2.0.0 and above.

## Core Release v3.2.0
### New Features

- **New part support** - This release introduces initial support for [SAME5x](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-e-mcus), [SAMD5x](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-d-mcus), [SAMA5D2](https://www.microchip.com/design-centers/32-bit-mpus/microprocessors/sama5/sama5d2-series), [PIC32MZ EF](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mz-ef-family), [PIC32MZ DA](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mz-da-family) families of 32-bit microcontrollers.

- **Driver and System Services** - The following table provides the list of newly added core components

    | Type | Module Name |  Module Caption |
    | --- | --- | --- |
    | Driver | DRV\_SDMMC | SDMMC Driver |
    | Driver | DRV_MX25L | MX25L SQI Flash Driver |
    | Driver | DRV_AT25DF | AT25DF SPI Flash Driver |
    | System Service | SYS\_CACHE | Cache System Service |

    The SDHC Driver (DRV_SDHC) is renamed to SDMMC Driver (DRV_SDMMC)

- **Development kit and demo application support** - The following table provides number of demo application available for different development kits newly added in this release.

    | Development kits | Bare-metal applications | RTOS applications |
    | --- | --- | --- |
    | [ATSAMA5D2C-XULT](https://www.microchip.com/Developmenttools/ProductDetails/ATSAMA5D2C-XULT) | 13 |22|
    | [PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit (Crypto)](https://www.microchip.com/DevelopmentTools/ProductDetails/DM320010-C) | 7 |5|
    | [PIC32MZ Embedded Connectivity with FPU (EF) Starter Kit](https://www.microchip.com/Developmenttools/ProductDetails/Dm320007) | 8 |11|
    | [SAM E54 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAME54-XPRO) | 15|16|
    | [SAM C21N Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMC21-XPRO) | 11 | 11 |
    | [SAM D20 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD20-XPRO) | 7 | 1 |
    | [SAM D21 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD21-XPRO) | 7 | 1 |
    | [SAM E70 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAME70-XULT) | 17 | 29 |
    | [SAM V71 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMV71-XULT) | 10 | 19 |


### Known Issues

The current known issues are as follows:

- Programming and debugging through PKOB is not yet supported for PIC32MZ DA, need to use external debugger (ICD4)

- PIC32MZ DA(S) device family will be supported by next coming XC32 release.

- The ICD4 loads the reset line of the SAM V71 Xplained Ultra board. The ICD4 flex cable must be removed after programming the device to run the application.

- Interactive help using the Show User Manual Entry in the Right-click menu for configuration options provided by this module is not yet available from within the MPLAB Harmony Configurator (MHC).  Please see the &quot;Configuring the Library&quot; section in the help documentation in the doc folder for this module instead.  Help is available in both CHM and PDF formats.

- ATSAMA5D2C demo applications build with a warning message: ```Warning[Pe111]: statement is unreachable for return ( EXIT_FAILURE ); statement of main() in IAR```

### Development Tools

* [MPLAB® X IDE v5.15](https://www.microchip.com/mplab/mplab-x-ide)
* [MPLAB® XC32 C/C++ Compiler v2.15](https://www.microchip.com/mplab/compilers)
* [IAR Embedded Workbench® for ARM® (v8.32 or above)](https://www.iar.com/iar-embedded-workbench/#!?architecture=Arm)
* MPLAB® X IDE plug-ins:
  * MPLAB® Harmony Configurator (MHC) v3.2.0.0 and above.

## Core Release v3.1.1
### New Features

- Moved HTML doc to specific folder for better Github integration (https://microchip-mplab-harmony.github.io/core)
- Minor documentation update.

## Core Release v3.1.0
### New Features

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

### Known Issues

The current known issues are as follows:

- The device does not run after programming the device through EDBG. The user needs to reset the device manually using the reset button on the Xplained boards to run the firmware.

- **Programming and debugging through EDBG is not supported.** The ICD4 needs to be used for programming and debugging.

- The ICD4 loads the reset line of the SAM V71 Xplained Ultra board. The ICD4 flex cable must be removed after programming the device to run the application.

- Interactive help using the Show User Manual Entry in the Right-click menu for configuration options provided by this module is not yet available from within the MPLAB® Harmony Configurator (MHC).  Please see the &quot;Configuring the Library&quot; section in the help documentation in the doc folder for this module instead.  Help is available in both CHM and PDF formats.

### Development Tools

* [MPLAB® X IDE v5.10](https://www.microchip.com/mplab/mplab-x-ide)
* [MPLAB® XC32 C/C++ Compiler v2.15](https://www.microchip.com/mplab/compilers)
* MPLAB® X IDE plug-ins:
  * MPLAB® Harmony Configurator (MHC) v3.1.0 and above.
