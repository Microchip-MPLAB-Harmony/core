![Microchip logo](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_logo.png)
![Harmony logo small](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_mplab_harmony_logo_small.png)

# Microchip MPLAB® Harmony 3 Release Notes

## Core Release v3.14.0

### New Features

- **New Features and Enhancements**
  - Added Drivers, System services and FreeRTOS support for PIC32CM-GC/SG, PIC32CX-BZ6 and PIC32CZ-CA70 family of devices
  - FreeRTOS support updated to the latest V11.1.0 with FreeRTOS-Kernel repository
  - Updated LittleFS support to the latest version v2.9.3
  - Added SDIO protocol support in SDMMC driver
  - Added MPU mode support in FreeRTOS for Cortex-M4 devices, It allows application tasks to create restricted tasks
  - Added support for creation of application tasks using static memory in FreeRTOS
  - Other bug fixes and enhancements

- **Applications**
  - MPLAB Harmony provides large number of application examples to accelerate learning and reduce the development cycles for your embedded systems with reusable software components. The application examples are available in the respective [product family specific repository](apps/readme.md).

### Known Issues

-  None

### Development Tools

- [MPLAB® X IDE v6.20](https://www.microchip.com/mplab/mplab-x-ide) or higher
- [MPLAB® XC32 C/C++ Compiler v4.45](https://www.microchip.com/mplab/compilers)
- MPLAB® X IDE plug-ins:
    - MPLAB® Code Configurator 5.5.1 or higher

### Notes

- With core v3.14.0, FreeRTOS source dependency is changed from [CMSIS-FreeRTOS](https://github.com/ARM-software/CMSIS-FreeRTOS) to [FreeRTOS-Kernel](https://github.com/FreeRTOS/FreeRTOS-Kernel) repository.

## Core Release v3.14.0-E1

### New Features
- Updated package.yml to support the Engineering release of PIC32CX-BZ6 family of devices.

### Bug fixes
- None

## Core Release v3.13.5

### New Features
- N/A

### Bug fixes
- Fixed MISRA-C violations in SST26, SST38, SST39 and NAND Flash Drivers
- Updated System Time Service for DVRT support

## Core Release v3.13.4

### New Features
- N/A

### Bug fixes
- Fixed variable overflow issue in SDMMC, SD-SPI and Memory Drivers
- Fixed build issue in SYS_COMMAND service

## Core Release v3.13.3

### New Features
- N/A

### Bug fixes
-  Removed dependencies on FileX and LittleFs packages

## Core Release v3.13.2

### New Features
- N/A

### Bug fixes
- Fixed MISRA-C violations in driver and system services
- Fixed hard-coded path names in FreeRTOS port files
- Fixed build error in memory driver

## Core Release v3.13.1

### New Features
- N/A

### Bug fixes
- Fixed issue where SYS_FS component will not be launched if FileX repository is not present

### Known Issues
- Same as v3.13.0

### Development Tools
- Same as v3.13.0

## Core Release v3.13.0

### New Features

- **New Features and Enhancements**
  - MISRA-C 2012 mandatory and required rules compliance for all Drivers and System Services
  - Azure FileX support
  - Updated FatFS to R0.15
  - Updated CMSIS-FreeRTOS to v10.5.1
  - FreeRTOS support for Cortex-M33 devices
  - Other bug fixes and enhancements

- **Applications**
  - MPLAB Harmony provides large number of application examples to accelerate learning and reduce the development cycles for your embedded systems with reusable software components. The application examples are available in the respective [product family specific repository](apps/readme.md).

### Known Issues

The current known issues are as follows:
- The following product families specifically requires the below mentioned DFP versions to be [installed](https://microchipdeveloper.com/mplabx:projects-packs)  with MPLABX v6.05. It is always recommended to use the latest version of DFPs for all products provided by Microchip.
     -  **SAMA7G5 Family**: SAMA7G5 DFP v1.2.176 or higher
     -  **PIC32CZ-CA80 Family**: PIC32CZ-CA80 DFP v1.2.150 or higher
     -  **PIC32CZ-CA90 Family**: PIC32CZ-CA80 DFP v1.3.150 or higher
     -  **PIC32CK-GC Family**: PIC32CK-GC DFP v1.0.131 or higher
     -  **PIC32CK-SG Family**: PIC32CK-SG DFP v1.0.141 or higher

### Development Tools

- [MPLAB® X IDE v6.05](https://www.microchip.com/mplab/mplab-x-ide) or higher
- [MPLAB® XC32 C/C++ Compiler v4.21](https://www.microchip.com/mplab/compilers)
- MPLAB® X IDE plug-ins:
  - MPLAB® Code Configurator 5.3.0 or higher

### Notes

- MPLAB® Harmony 3 SYS_FS File System service has dependency on FileX hence [FileX](https://github.com/azure-rtos/filex) need to be downloaded using content manager by following these [instructions](https://github.com/Microchip-MPLAB-Harmony/contentmanager/wiki)

## Core Release v3.12.0

### New Features

- **New Features and Enhancements**
  - Added UART, I2C, I2C EEPROM, SYS Console and SYS Time driver support for CEC173x family of devices
  - Added support for W25 SPI flash device for CEC173x family of devices

- **Applications**
  - MPLAB Harmony provides large number of application examples to accelerate learning and reduce the development cycles for your embedded systems with reusable software components. The application examples are available in the respective [product family specific repository](apps/readme.md).

### Known Issues

Same as v3.12.0-E1

### Development Tools

For CEC173x family of devices:

- [MPLAB® X IDE v6.05](https://www.microchip.com/mplab/mplab-x-ide)
- [MPLAB® XC32 C/C++ Compiler v4.21](https://www.microchip.com/mplab/compilers)
- MPLAB® X IDE plug-ins:
  - MPLAB® Code Configurator 5.2.2 or higher

For all other parts:

  - Same as v3.12.0-E1
  
### Notes

-  None

## Core Release v3.12.0-E1

### New Features
- This engineering release adds support for the PIC32CK-GC/SG family of devices

### Bug fixes
- None

### Known Issues
- Same as v3.11.0

### Development Tools
- Same as v3.11.0

## Core Release v3.11.1

### New Features
- N/A

### Bug fixes
- Fixed issue in buffer allocation logic in Async SPI driver. This issue impacts when the driver is used in multi-instance mode.
- Fixed a potential race condition in updating the 64-bit counter in the SYS TIME module
- Minor updates to the SST26 driver

### Known Issues
- Same as v3.11.0

### Development Tools
- Same as v3.11.0

## Core Release v3.11.0

### New Features

- **New Features and Enhancements**
  - Updated FatFS to R0.14b
  - Updated CMSIS-FreeRTOS to v10.4.6
  - Updated SST26 driver to support DMA based transfers when SPI mode is used. Added capability to use SST26 driver with SPI driver.
  - Updated AT25DF driver to support AT25DF081A flash memory
  - Updated MX25L driver to support 4 byte address mode and added support for all MX25L Flash devices

- **Applications**
  - MPLAB Harmony provides large number of application examples to accelerate learning and reduce the development cycles for your embedded systems with reusable software components. The application examples are available in the respective [product family specific repository](apps/readme.md).

### Known Issues

The current known issues are as follows:
- The default/max clock for ATSAMG55 devices is changed from 120MHz to 100MHz. Some of the clock dependent peripheral configuration may need to be verified/updated.
- The following product families specifically requires the below mentioned DFP versions to be [installed](https://microchipdeveloper.com/mplabx:projects-packs)  with MPLABX v6.00. It is always recommended to use the latest version of DFPs for all products provided by Microchip.
     -  **CEC173x Family**: CEC DFP v1.5.142 or higher
     -  **PIC32CX-BZ2 family of wireless microcontrollers (MCUs) and WBZ451 modules**: PIC32CX-BZ DFP 1.0.107 or higher

### Development Tools

- [MPLAB® X IDE v6.00](https://www.microchip.com/mplab/mplab-x-ide)
- [MPLAB® XC32 C/C++ Compiler v4.10](https://www.microchip.com/mplab/compilers)
- MPLAB® X IDE plug-ins:
  - MPLAB® Code Configurator 5.1.9 or higher

### Notes

-  None

# Microchip MPLAB® Harmony 3 Release Notes

## Core Release v3.10.0

### New Features

- **New Features and Enhancements**
  - Emulated EEPROM support for ARM Cortex based MCUs
  - Optimized read transfer with unaligned buffers in MPFS/FatFS
  - Added littleFS support in File System Service
  - RAM media support in File System Service
  - Lock and Unlock support in SPI driver to transfer multiple SPI frames without preemption

- **Applications**
  - MPLAB Harmony provides large number of application examples to accelerate learning and reduce the development cycles for your embedded systems with reusable software components. The application examples are available in the respective [product family specific repository](apps/readme.md).
  - All MPLAB X applications are updated to work with both MHC and MCC tools.

### Known Issues

The current known issues are as follows:
- The following product families specifically requires the below mentioned DFP versions to be [installed](https://microchipdeveloper.com/mplabx:projects-packs)  with MPLABX v5.50. It is always recommended to use the latest version of DFPs for all products provided by Microchip.
     -  **SAM L11 Family**: SAML11 DFP v4.3.139 or higher
     -  **SAM RH707 Family**: SAMRH707 DFP 1.0.28 or higher


### Development Tools

- [MPLAB® X IDE v5.50](https://www.microchip.com/mplab/mplab-x-ide)
- [MPLAB® XC32 C/C++ Compiler v3.01](https://www.microchip.com/mplab/compilers)
- [IAR EWARM v8.50](https://www.iar.com/iar-embedded-workbench/#!?architecture=Arm)
- [KEIL MDK v5.31](https://www2.keil.com/mdk5)
- MPLAB® X IDE plug-ins:
  - MPLAB® Harmony Configurator (MHC) v3.8.0


### Notes

-  None

## Core Release v3.9.2

### New Features
- Added MHC UI option to configure maximum command groups and command arguments in Command System Service 

### Bug fixes
- N/A

### Known Issues
- No changes from v3.9.0

### Development Tools
- No changes from v3.9.0

## Core Release v3.9.1

### New Features
- N/A

### Bug fixes
- Fixed issues reported by MPLAB XC32 Compiler v3.00 in File System and OSAL

### Known Issues
- No changes from v3.9.0

### Development Tools
- No changes from v3.9.0

## Core Release v3.9.0

### New Features

- **New Features and Enhancements**
  - Added compatibility with C++
  - Added NAND Flash driver support on SAM 9X60
  - Added Mbed OS 6 RTOS support for Cortex M0+, M4 and M7
  - Updated Fat-fs code to version R0.14a and removed support for older Fat-fs version R0.11a
  - Updated Time System Service to work with Systick

- **Applications**
  - MPLAB Harmony provides large number of application examples to accelerate learning and reduce the development cycles for your embedded systems with reusable software components. The application examples are available in the respective [product family specific repository](apps/readme.md).

### Known Issues

The current known issues are as follows:
-  Any File system based project which runs into Fat-Fs file path error during regeneration needs to remove and add file system component in MHC project graph
-  The clock PLIB on SAM D20 is updated to use DFLL in closed loop mode by default. This requires enabling the internal 8 MHZ Oscillator clock source for GLCK1 in MHC Clock configurator, which is used as a reference clock for DFLL.
- The following product families specifically requires the below mentioned DFP versions to be [installed](https://microchipdeveloper.com/mplabx:projects-packs)  with MPLABX v5.45. It is always recommended to use the latest version of DFPs for all products provided by Microchip.
     -  **SAM 9X6 Family**: SAM9X6 DFP v1.5.50 or higher
     -  **SAM A5D2 Family**: SAMA5D2 DFP 1.5.53 or higher
     -  **SAM D51 Family**: SAMD51 DFP v3.4.91 or higher
     -  **SAM E51 Family**: SAME51 DFP v3.4.98 or higher
     -  **SAM E53 Family**: SAME53 DFP v3.4.79 or higher
     -  **SAM E54 Family**: SAME54 DFP v3.5.87 or higher
     -  **PIC32MZ-W Family**: PIC32MZ-W DFP v1.4.193 or higher


### Development Tools

- [MPLAB® X IDE v5.45](https://www.microchip.com/mplab/mplab-x-ide)
- [MPLAB® XC32 C/C++ Compiler v2.50](https://www.microchip.com/mplab/compilers)
- [IAR EWARM v8.50](https://www.iar.com/iar-embedded-workbench/#!?architecture=Arm)
- [KEIL MDK v5.31](https://www2.keil.com/mdk5)
- MPLAB® X IDE plug-ins:
  - MPLAB® Harmony Configurator (MHC) v3.7.0


### Notes

-  Removed weak declaration for interrupts that are enabled in NVIC to enforce definition of interrupt handlers for MISRA C Required rules compliance. Any interrupts that are enabled without a corresponding interrupt handler will result in build error and hence the unused interrupts must be disabled.

## Core Release v3.8.1
### New Features
- Updated supported product families

### Bug fixes
- N/A

### Known Issues
- No changes from v3.8.0

### Development Tools
- No changes from v3.8.0

## Core Release v3.8.0

### New Features

- **New Features and Enhancements**
  - eMMC support for MCU devices with SDHC/SDMMC peripheral viz., PIC32MZ DA, SAM D5x/E5x and SAM E70
  - Added support for exFAT file system
  - Added Reset System Service
  - Added support for Single-lane mode in SST26 QSPI Flash driver
  - Added support for CMSIS FreeRTOS v10.3.1

- **Applications**
  - MPLAB Harmony provides large number of application examples to accelerate learning and reduce the development cycles for your embeeded systems with reusable software components. The application examples are moved to the [product family specific repository](apps/readme.md).



### Known Issues

The current known issues are as follows:
  -  Default linker file is added to the MPLAB X projects. The applications that uses custom linker script must disable the linker file generation.
  -  The following product family requires newer DFP version to be downloaded from packs server and to be used in the MPLAB project to build with MPLAB X IDE v5.4.
     -  **SAM L21 Family**: SAML21_DFP v3.4.80
     -  **SAM L22 Family**: SAML22_DFP v3.4.59
     -  **SAM L10/L11 Family**: SAML10_DFP v3.3.82, SAML11_DFP v4.0.114     
     -  **PIC32MK MCM/GPK Family**: PIC32MK-GP_DFP v1.4.117, PIC32MK-MC_DFP v1.5.115


### Development Tools

- [MPLAB® X IDE v5.40](https://www.microchip.com/mplab/mplab-x-ide)
- [MPLAB® XC32 C/C++ Compiler v2.41](https://www.microchip.com/mplab/compilers)
- [IAR EWARM v8.50](https://www.iar.com/iar-embedded-workbench/#!?architecture=Arm)
- [KEIL MDK v5.29](https://www2.keil.com/mdk5)
- MPLAB® X IDE plug-ins:
  - MPLAB® Harmony Configurator (MHC) v3.6.0

## Core Release v3.7.2
### New Features
- N/A

### Bug fixes
- Updated the Console System Service to use the DBGU peripheral as UART console

### Known Issues
- No changes from v3.7.1

### Development Tools
- No changes from v3.7.1

## Core Release v3.7.1
### New Features
- N/A

### Bug fixes
- Updated dependent package version information

### Known Issues
- No changes from v3.7.0

### Development Tools
- No changes from v3.7.0

## Core Release v3.7.0

### New Features

- **New part support** - This release introduces support for
[SAM L11](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-l-mcus/sam-l10-and-l11-microcontroller-family),
[SAM RH71 Revision C](https://www.microchip.com/wwwproducts/en/SAMRH71)
devices.

- **New Features and Enhancements**
  - Updated File System Framework to support FatFs R0.14
  - Updated to support CMSIS FreeRTOS v10.3.0
  - FreeRTOS support for Cortex-M23 with TrustZone
  - Added support for USB CDC interface in Console System Service
  - Updated SDSPI driver to use SPI driver optionally
  - Added SPI mode support for SST26 driver
  - Added IAR EWARM Projects for Cortex-M MCU, SAM A5D2 MPU and SAM 9X60 MPU devices
  - Added KEIL MDK Projects for Cortex-M MCU devices
  - Created group project with at91bootloader for SAM A5D2 MPU to debug with MPLAB X IDE

- **Development kit and demo application support** - The following table provides number of application examples available for different development kits and toolchain.

    | Development Kits                                                                                                                               | MPLAB X   | IAR EWARM |  KEIL MDK |
    |------------------------------------------------------------------------------------------------------------------------------------------------|-----------|-----------|-----------|
    | [SAM E70 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAME70-XULT)                   |    52     |           |     1     |
    | [SAM V71 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMV71-XULT)                   |    30     |           |           |
    | [SAM C21N Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/ATSAMC21N-XPRO)                               |    23     |           |     1     |
    | [SAM D20 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD20-XPRO)                     |     9     |           |           |
    | [SAM D21 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD21-XPRO)                     |    14     |           |           |
    | [SAM E54 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAME54-XPRO)                                 |    35     |           |     1     |
    | [PIC32MZ Embedded Connectivity with FPU (EF) Starter Kit](https://www.microchip.com/Developmenttools/ProductDetails/Dm320007)                  |    23     |           |           |
    | [PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit (Crypto)](https://www.microchip.com/DevelopmentTools/ProductDetails/DM320010-C) |    17     |           |           |
    | [PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/DM320010)     |     9     |           |           |
    | [PIC32MZ Embedded Graphics with External DRAM (DA) Starter Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/DM320008)     |     2     |           |           |
    | [PIC32MK GP Development Kit](https://www.microchip.com/developmenttools/ProductDetails/dm320106)                                               |    11     |           |           |
    | [SAMA5D2 Xplained Ultra Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/atsama5d2c-xult)                             |    37     |     36    |           |
    | [SAM L21 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/ATSAML21-XPRO-B)                        |    10     |           |           |
    | [SAM L22 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/atsaml22-xpro-b)                               |     9     |           |           |
    | [PIC32MX470 Curisoity Development Board](https://www.microchip.com/DevelopmentTools/ProductDetails/dm320103)                                   |    18     |           |           |
    | [PIC32MX274 XLP Starter Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/DM320105)                                        |     7     |           |           |
    | [ATSAM9X60-EK](https://www.microchip.com/design-centers/32-bit-mpus/microprocessors/sam9)                                                      |    27     |     27    |           |
    | [SAM L10 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/dm320204)                                      |    10     |           |     1     |
    | [SAM G55 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/atsamg55-xpro)                                 |    14     |           |           |
    | PIC32MK MCJ Curiosity Pro                                                                                                                      |    14     |           |           |
    | [SAM DA1 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/ATSAMDA1-XPRO)                          |     8     |           |           |
    | [PIC32 Ethernet Starter Kit II](https://www.microchip.com/DevelopmentTools/ProductDetails/dm320004-2)                                          |     3     |           |           |
    | [SAMRH71 Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/SAMRH71F20-EK)                                       |    10     |           |           |
    | PIC32MK MCM Curiosity Pro                                                                                                                      |    11     |           |           |
    | PIC32MZ W1 Curiosity Board                                                                                                                     |    13     |           |           |
    | [SAM HA1G16A Xplained Pro](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/ATSAMHA1G16A-XPRO)                                 |     9     |           |           |
    | [SAM L11 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/dm320205)                                      |     1     |           |           |

### **Known Issues**

The current known issues are as follows:

- ATSAMA5D2C and SAM9X60 example applications build with a warning message: ```Warning[Pe111]: statement is unreachable for return ( EXIT_FAILURE ); statement of main() in IAR```
- The Console system service API signatures (and behavior) have changed but the Macros used to print console and debug messages remain unchanged.
- When using MPLABx to program/debug SAMA5D27C projects

  - "Run project" feature is not supported. Clicking on the "Run Project" button will not run the application on the target board.
  - "Step out" feature is not supported. Clicking on the "Step Out" button (or pressing Ctrl + F7) while debugging an application will not move the program counter.

- SYS_FS_DriveFormat API signature has changed with the latest Fat-FS code. Existing applications/middle-wares using the API with the latest Fat-FS, will need to update to the new API signature. An MHC option is provided to use the older version of Fat-FS code

- SYS_FS_FSTAT structure has been modified to align with latest Fat-Fs code. For getting large file names applications/middlewares need to use fname parameter instead of lfname. Below are the affected API's
  - SYS_FS_FileStat
  - SYS_FS_DirRead
  - SYS_FS_DirSearch
  
- Updating File System based applications created with Harmony Core v3.6.x for PIC32MZ devices to Harmony Core v3.7.x will require removing and adding the File System component in the MHC Project Graph 

### **Development Tools**

- [MPLAB® X IDE v5.4](https://www.microchip.com/mplab/mplab-x-ide)
- [MPLAB® XC32 C/C++ Compiler v2.41](https://www.microchip.com/mplab/compilers)
- [IAR EWARM v8.50](https://www.iar.com/iar-embedded-workbench/#!?architecture=Arm)
- [KEIL MDK v5.29](https://www2.keil.com/mdk5)
- MPLAB® X IDE plug-ins:
  - MPLAB® Harmony Configurator (MHC) v3.5.0



## Core Release v3.6.1
### New Features
- Regenerated PIC32MK MCJ Family Applications to work with updated BSP

### Bug fixes
- None

### Known Issues
- No changes from v3.6.0

### Development Tools
- No changes from v3.6.0

## Core Release v3.6.0
### New Features

- **New part support** - This release adds support for
[SAM HA1](https://www.microchip.com/wwwproducts/en/ATSAMHA1G16A-B) and
PIC32MZ W1 families of 32-bit microcontrollers.

- **New Features and Enhancements**
   * Added Tick mode support in Time System Service
   * Added eMMC support in SDMMC driver for SAM A5D2 device
   * Updated Error Get API prototype in USART and I2C driver to report error based on transfer handle instead of client handle
   * Added XC32 based demo applications for SAM9x60 device

- **Development kit and demo application support** - The following table provides number of demo application available for different development kits newly added in this release.

    | Development kits | Bare-metal applications | RTOS applications |
    | --- | --- | --- |
    | [SAM C21N Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMC21-XPRO) | 11 | 11 |
    | [SAM D20 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD20-XPRO) | 7 | 1 |
    | [SAM D21 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD21-XPRO) | 9 | 1 |
    | [SAM DA1 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/ATSAMDA1-XPRO) | 4 | 2 |
    | [SAM G55 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/atsamg55-xpro) | 8 | 6 |
    | [SAM HA1G16A Xplained Pro](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/ATSAMHA1G16A-XPRO) | 7 | 2 |
    | [SAM L10 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/dm320204) | 7 | 1 |
    | [SAM L21 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML21-XPRO-B) | 6 | 2 |
    | [SAM L22 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML22-XPRO-B) | 5 | 2 |
    | [SAM E54 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAME54-XPRO) | 15 | 16 |
    | [SAM E70 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAME70-XULT) | 18 | 29 |
    | SAMRH71 Evaluation Kit | 6 | 4 |
    | [SAM V71 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMV71-XULT) | 10 | 19 |
    | [PIC32 Ethernet Starter Kit II](https://www.microchip.com/DevelopmentTools/ProductDetails/dm320004-2) | 2 | 1 |
    | [PIC32MX XLP Starter Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/DM320105) | 5 | 1 |
    | [PIC32MX Curiosity Development Board](https://www.microchip.com/Developmenttools/ProductDetails/dm320103) | 8 | 6 |
    | [PIC32MK GP Development Kit](https://www.microchip.com/developmenttools/ProductDetails/dm320106) | 8 | 2 |
    | PIC32MK MCJ Curiosity Pro | 9 | 4 |
    | PIC32MK MCM Curiosity Pro | 6 | 4 |
    | [PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit ](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/DM320010)     | 5 | 3 |
    | [PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit (Crypto) ](https://www.microchip.com/DevelopmentTools/ProductDetails/DM320010-C) | 8 | 6 |
    | [PIC32MZ Embedded Graphics with External DRAM (DA) Starter Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/DM320008)     | 1 | 0 |
    | [PIC32MZ Embedded Connectivity with FPU (EF) Starter Kit](https://www.microchip.com/Developmenttools/ProductDetails/Dm320007) | 9 | 11 |
    | PIC32MZ W1 Curiosity Board | 6 | 5 |
    | [ATSAMA5D2C-XULT](https://www.microchip.com/Developmenttools/ProductDetails/ATSAMA5D2C-XULT) | 14 | 23 |
    | [ATSAM9X60-EK](https://www.microchip.com/design-centers/32-bit-mpus/microprocessors/sam9) | 11 | 16 |

### Known Issues

The current known issues are as follows:

* Use MPLAB X IDE V5.25 with SAM D10 Xplained Mini, SAM RH71 and SAM DA1 Xplained Pro.

* SAM HA1 and PIC32MZ W1 will be supported in the next version of MPLAB X IDE release.

* ATSAMA5D2C and SAM9X60 example applications build with a warning message: ```Warning[Pe111]: statement is unreachable for return ( EXIT_FAILURE ); statement of main() in IAR```

### Development Tools

* [MPLAB® X IDE v5.30](https://www.microchip.com/mplab/mplab-x-ide)
* [MPLAB® XC32 C/C++ Compiler v2.30](https://www.microchip.com/mplab/compilers)
* [IAR Embedded Workbench® for ARM® v8.4](https://www.iar.com/iar-embedded-workbench/#!?architecture=Arm)
* MPLAB® X IDE plug-ins:
  * MPLAB® Harmony Configurator (MHC) v3.4.1 and above.


## Core Release v3.5.2
### New Features
- N/A

### Bug fixes
- Fixing module metadata

### Known Issues
- No changes from v3.5.1

### Development Tools
- No changes from v3.5.1

## Core Release v3.5.1
### New Features
- N/A

### Bug fixes
- Fixing ThreadX support

### Known Issues
- No changes from v3.5.0

### Development Tools
- No changes from v3.5.0

## Core Release v3.5.0
### New Features

- **New part support** - This release introduces initial support for following products
[SAM DA1](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-l-mcus), [SAM D09/D10/D11](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-g-mcus), [PIC32MX5XX/6XX/7XX](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mx-family), PIC32MK GPH/GPG/MCJ, PIC32MK GPK/GPL/MCM, and SAM RH71
families of 32-bit microcontrollers.

- **Development kit and demo application support** - The following table provides number of demo application available for different development kits newly added in this release.

    | Development kits | Bare-metal applications | RTOS applications |
    | --- | --- | --- |
    | [SAM C21N Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMC21-XPRO) | 9 | 11 |
    | [SAM D20 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD20-XPRO) | 7 | 1 |
    | [SAM D21 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD21-XPRO) | 9 | 1 |
    | [SAM DA1 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/ATSAMDA1-XPRO) | 4 | 2 |
    | [SAM G55 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/atsamg55-xpro) | 8 | 6 |
    | [SAM L10 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/dm320204) | 7 | 1 |
    | [SAM L21 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML21-XPRO-B) | 6 | 2 |
    | [SAM L22 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML22-XPRO-B) | 5 | 2 |
    | [SAM E54 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAME54-XPRO) | 15 | 17 |
    | [SAM E70 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAME70-XULT) | 18 | 30 |
    | SAMRH71 Evaluation Kit | 6 | 4 |
    | [SAM V71 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMV71-XULT) | 10 | 19 |
    | [PIC32 Ethernet Starter Kit II](https://www.microchip.com/DevelopmentTools/ProductDetails/dm320004-2) | 2 | 1 |
    | [PIC32MX XLP Starter Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/DM320105) | 5 | 1 |
    | [PIC32MX Curiosity Development Board](https://www.microchip.com/Developmenttools/ProductDetails/dm320103) | 8 | 6 |
    | [PIC32MK GP Development Kit](https://www.microchip.com/developmenttools/ProductDetails/dm320106) | 8 | 2 |
    | PIC32MK MCJ Curiosity Pro | 9 | 4 |
    | PIC32MK GPL Curiosity Pro | 6 | 4 |
    | [PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit ](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/DM320010)     | 5 | 3 |
    | [PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit (Crypto) ](https://www.microchip.com/DevelopmentTools/ProductDetails/DM320010-C) | 8 | 6 |
    | [PIC32MZ Embedded Graphics with External DRAM (DA) Starter Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/DM320008)     | 1 | 0 |
    | [PIC32MZ Embedded Connectivity with FPU (EF) Starter Kit](https://www.microchip.com/Developmenttools/ProductDetails/Dm320007) | 9 | 11 |
    | [ATSAMA5D2C-XULT](https://www.microchip.com/Developmenttools/ProductDetails/ATSAMA5D2C-XULT) | 13 | 23 |
    | [ATSAM9X60-EK](https://www.microchip.com/design-centers/32-bit-mpus/microprocessors/sam9) | 10 | 16 |

### Known Issues

The current known issues are as follows:

- Configuration fuse macros are not generated for SAM D09/D11/D12 devices.

- PIC32MK GPK/GPL/MCM and SAM RH71 will be supported in the next version of MPLAB X IDE release.

- Interactive help using the Show User Manual Entry in the Right-click menu for configuration options provided by this module is not yet available from within the MPLAB Harmony Configurator (MHC).
  Please see the *Configuring the Library* section in the help documentation in the doc folder for this Harmony 3 module instead. Help is available in CHM format.

- ATSAMA5D2C and SAM9X60 example applications build with a warning message: ```Warning[Pe111]: statement is unreachable for return ( EXIT_FAILURE ); statement of main() in IAR```

- For FreeRTOS projects the task's stack size configuration has been changed to Bytes from words. All applications using FreeRTOS need to verify the stack size of RTOS tasks are as expected.

- Timer System Services is only supported with Coretimer PLIB on PIC32M devices.

### Development Tools

* [MPLAB® X IDE v5.25](https://www.microchip.com/mplab/mplab-x-ide)
* [MPLAB® XC32 C/C++ Compiler v2.30](https://www.microchip.com/mplab/compilers)
* [IAR Embedded Workbench® for ARM® v8.4](https://www.iar.com/iar-embedded-workbench/#!?architecture=Arm)
* MPLAB® X IDE plug-ins:
  * MPLAB® Harmony Configurator (MHC) v3.3.0.0 and above.

## Core Release v3.4.0
### New Features

- **New part support** - This release introduces initial support for [SAML10](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-l-mcus),
[SAMG55](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-g-mcus) families of 32-bit microcontrollers

- **Development kit and demo application support** - The following table provides number of demo application available for different development kits newly added in this release.

    | Development kits | Bare-metal applications | RTOS applications |
    | --- | --- | --- |
    | [SAM C21N Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMC21-XPRO) | 9 | 11 |
    | [SAM D20 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD20-XPRO) | 7 | 1 |
    | [SAM D21 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD21-XPRO) | 9 | 1 |
    | [SAM G55 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/atsamg55-xpro) | 8 | 6 |
    | [SAM L10 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/dm320204) | 7 | 1 |
    | [SAM L21 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML21-XPRO-B) | 6 | 2 |
    | [SAM L22 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML22-XPRO-B) | 5 | 2 |
    | [SAM E54 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAME54-XPRO) | 15 | 17 |
    | [SAM E70 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAME70-XULT) | 18 | 30 |
    | [SAM V71 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMV71-XULT) | 10 | 19 |
    | [PIC32MX XLP Starter Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/DM320105) | 5 | 1 |
    | [PIC32MX Curiosity Development Board](https://www.microchip.com/Developmenttools/ProductDetails/dm320103) | 8 | 6 |
    | [PIC32MK GP Development Kit](https://www.microchip.com/developmenttools/ProductDetails/dm320106) | 8 | 2 |
    | [PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit (Crypto)](https://www.microchip.com/DevelopmentTools/ProductDetails/DM320010-C) | 8 | 6 |
    | [PIC32MZ Embedded Connectivity with FPU (EF) Starter Kit](https://www.microchip.com/Developmenttools/ProductDetails/Dm320007) | 9 | 11 |
    | [ATSAMA5D2C-XULT](https://www.microchip.com/Developmenttools/ProductDetails/ATSAMA5D2C-XULT) | 13 | 23 |
    | [ATSAM9X60-EK](https://www.microchip.com/design-centers/32-bit-mpus/microprocessors/sam9) | 10 | 16 |

### Known Issues

The current known issues are as follows:

- Preliminary support added for ATSAMA5D2C using MPLAB X and XC32. This complete tooling support will be added in future release of MPLAB X.

- ATSAMA5D2C demo applications build with a warning message: ```Warning[Pe111]: statement is unreachable for return ( EXIT_FAILURE ); statement of main() in IAR```

### Development Tools

* [MPLAB® X IDE v5.20](https://www.microchip.com/mplab/mplab-x-ide)
* [MPLAB® XC32 C/C++ Compiler v2.20](https://www.microchip.com/mplab/compilers)
* [IAR Embedded Workbench® for ARM® (v8.32 or above)](https://www.iar.com/iar-embedded-workbench/#!?architecture=Arm)
* MPLAB® X IDE plug-ins:
  * MPLAB® Harmony Configurator (MHC) v3.3.0.1 and above.

## Core Release v3.3.0
### New Features

- **New part support** - This release introduces initial support for [SAML21](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-l-mcus),
[SAML22](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-l-mcus),
[PIC32MX 1/2/5](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mx-family),
[PIC32MX 1/2 XLP](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mx-family),
[PIC32MX 3/4](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mx-family) families of 32-bit microcontrollers
and [SAM9X60](https://www.microchip.com/design-centers/32-bit-mpus/microprocessors/sam9) family of 32-bit microprocessors.

- Added support for the SDMMC (Async) driver on PIC32MZ DA.

- Added support for the SDSPI (Async) driver for all platforms.

- Separated out the Console, Debug and Command System Service.

- All FreeRTOS based applications are tested with the CMSIS-FreeRTOS v10.2.0.

- **Development kit and demo application support** - The following table provides number of demo application available for different development kits newly added in this release.

    | Development kits | Bare-metal applications | RTOS applications |
    | --- | --- | --- |
    | [SAM C21N Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMC21-XPRO) | 9 | 11 |
    | [SAM D20 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD20-XPRO) | 7 | 1 |
    | [SAM D21 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD21-XPRO) | 9 | 1 |
    | [SAM L21 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML21-XPRO-B) | 6 | 2 |
    | [SAM L22 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML22-XPRO-B) | 5 | 2 |
    | [SAM E54 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAME54-XPRO) | 15 | 17 |
    | [SAM E70 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAME70-XULT) | 18 | 30 |
    | [SAM V71 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMV71-XULT) | 10 | 19 |
    | [PIC32MX XLP Starter Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/DM320105) | 5 | 1 |
    | [PIC32MX Curiosity Development Board](https://www.microchip.com/Developmenttools/ProductDetails/dm320103) | 8 | 6 |
    | [PIC32MK GP Development Kit](https://www.microchip.com/developmenttools/ProductDetails/dm320106) | 8 | 2 |
    | [PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit (Crypto)](https://www.microchip.com/DevelopmentTools/ProductDetails/DM320010-C) | 8 | 6 |
    | [PIC32MZ Embedded Connectivity with FPU (EF) Starter Kit](https://www.microchip.com/Developmenttools/ProductDetails/Dm320007) | 9 | 11 |
    | [ATSAMA5D2C-XULT](https://www.microchip.com/Developmenttools/ProductDetails/ATSAMA5D2C-XULT) | 13 | 23 |
    | [ATSAM9X60-EK](https://www.microchip.com/design-centers/32-bit-mpus/microprocessors/sam9) | 10 | 16 |

### Known Issues

The current known issues are as follows:

- Applications using Console System Service should be regenerated by reconfiguring the Console System Service in MHC Project Graph.

- Applications using the FreeRTOS component must be regenerated by removing and adding the FreeRTOS component again in MHC Project Graph.

- Flash wait states are now calculated as part of respective flash PLIB (EFC/NVMCTRL) instead of clock manager for SAM microcontrollers. Older projects must be reconfigured to add the respective Flash PLIB to the MHC Project Graph.

- Timer System Services is only supported with Coretimer PLIB on PIC32M devices.

- ATSAMA5D2C demo applications build with a warning message: ```Warning[Pe111]: statement is unreachable for return ( EXIT_FAILURE ); statement of main() in IAR```

### Development Tools

* [MPLAB® X IDE v5.20](https://www.microchip.com/mplab/mplab-x-ide)
* [MPLAB® XC32 C/C++ Compiler v2.20](https://www.microchip.com/mplab/compilers)
* [IAR Embedded Workbench® for ARM® (v8.32 or above)](https://www.iar.com/iar-embedded-workbench/#!?architecture=Arm)
* MPLAB® X IDE plug-ins:
  * MPLAB® Harmony Configurator (MHC) v3.3.0.1 and above.

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
