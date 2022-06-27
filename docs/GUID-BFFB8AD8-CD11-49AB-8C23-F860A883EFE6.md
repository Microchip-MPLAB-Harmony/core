# NAND Flash Driver

This driver provides the blocking functions to read, write and erase NAND Flash memory. The driver uses the below peripheral library to interface with the NAND Flash.

-   SMC Peripheral Library

    -   Supports NAND Flash Controller, Programmable Multi-bit Error Correcting Code \(PMECC\) and Programmable Multibit ECC Error Location Controller \(PMERRLOC\)


**Key Features:**

-   Supports Open NAND Flash Interface \(ONFI\) 1.0-compliant NAND Flash devices

-   Supports single instance of the NAND Flash and single client to the driver

-   Supports Block Erase Operations

-   Supports Page/Block Write and Read Operations

-   Supports Skip Block management

-   Supports Error Correction Code

-   Supports Direct memory access \(DMA\) for NAND Flash write and read operations

-   The library can be used in both Bare-Metal and RTOS environments


-   **[How the Library Works](GUID-349C448C-06FF-4386-B995-DB152263E91D.md)**  

-   **[Using The Library](GUID-593ADB30-88DF-480D-A357-40AFF127A20F.md)**  

-   **[Configuring The Library](GUID-670AE57E-73F2-4D46-A66C-8A60E8B4D5DC.md)**  

-   **[Library Interface](GUID-B826AB75-F4E4-4A5B-8189-23C99CCF9936.md)**  


**Parent topic:**[Driver Libraries](GUID-4FA4B38A-8C7F-46A3-9D08-4B8C5CE26712.md)

