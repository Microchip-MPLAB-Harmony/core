# Library Interface

SST26 driver library provides the following interfaces:

**Functions**

|Name|Description|
|----|-----------|
|DRV\_SST26\_Initialize|Initializes the SST26 Driver|
|DRV\_SST26\_Open|Opens the specified SST26 driver instance and returns a handle to it|
|DRV\_SST26\_Close|Closes an opened-instance of the SST26 driver|
|DRV\_SST26\_Status|Gets the current status of the SST26 driver module|
|DRV\_SST26\_UnlockFlash|Unlocks the flash device for Erase and Program operations|
|DRV\_SST26\_ReadJedecId|Reads JEDEC-ID of the flash device|
|DRV\_SST26\_SectorErase|Erase the sector from the specified block start address|
|DRV\_SST26\_BulkErase|Erase a block from the specified block start address|
|DRV\_SST26\_ChipErase|Erase entire flash memory|
|DRV\_SST26\_Read|Reads n bytes of data from the specified start address of flash memory|
|DRV\_SST26\_PageWrite|Writes one page of data starting at the specified address|
|DRV\_SST26\_TransferStatusGet|Gets the current status of the transfer request|
|DRV\_SST26\_GeometryGet|Returns the geometry of the device|
|DRV\_SST26\_EventHandlerSet|Allows a client to identify a transfer event handling function for the driver to call back when the requested transfer has finished|

**Data types and constants**

|Name|Type|Description|
|----|----|-----------|
|DRV\_SST26\_TRANSFER\_STATUS|Enum|SST26 Driver Transfer Status|
|DRV\_SST26\_GEOMETRY|Struct|SST26 Device Geometry data|
|DRV\_SST26\_EVENT\_HANDLER|Typedef|Pointer to a SST26 Driver Event handler function|

-   **[DRV\_SST26\_Initialize Function](GUID-D64948C5-0865-4700-974A-6EFC4BA20290.md)**  

-   **[DRV\_SST26\_Open Function](GUID-0A0D0DD6-3DF8-4DBF-A8DE-81EB0726D30A.md)**  

-   **[DRV\_SST26\_Close Function](GUID-4F45A6E9-23AF-473C-9001-8C1E9EBF58DB.md)**  

-   **[DRV\_SST26\_Status Function](GUID-78FE973E-69BA-4A7F-ACE0-669D8F7B9241.md)**  

-   **[DRV\_SST26\_UnlockFlash Function](GUID-5FE0390A-B22A-411C-8F18-4D3CE8BCBDF9.md)**  

-   **[DRV\_SST26\_ReadJedecId Function](GUID-8B644CA2-82B6-4CFE-8F73-6079A6CC5256.md)**  

-   **[DRV\_SST26\_SectorErase Function](GUID-30C3EC2E-74C5-4262-9786-362DBA86AFEA.md)**  

-   **[DRV\_SST26\_BulkErase Function](GUID-17D19DF8-7FD4-4C76-A204-5CEFB779D8A9.md)**  

-   **[DRV\_SST26\_ChipErase Function](GUID-DF41BC8C-CD07-476D-A7FC-B6FEE97C373E.md)**  

-   **[DRV\_SST26\_Read Function](GUID-D4834F35-FAA3-48E7-BBFB-694C9BA6476E.md)**  

-   **[DRV\_SST26\_PageWrite Function](GUID-BC696779-C030-4709-B540-2779B58ABC08.md)**  

-   **[DRV\_SST26\_TransferStatusGet Function](GUID-16F6C851-DB9F-4997-8669-1E9C6C128B45.md)**  

-   **[DRV\_SST26\_GeometryGet Function](GUID-ACA74B78-E632-4CE1-BF4B-C0073C64D35F.md)**  

-   **[DRV\_SST26\_EventHandlerSet Function](GUID-EF5DB136-2E82-44C7-83C5-278C3F5A5816.md)**  

-   **[DRV\_SST26\_TRANSFER\_STATUS Enum](GUID-1BD4F2ED-A921-4BA7-BD26-6A82515F4CB4.md)**  

-   **[DRV\_SST26\_GEOMETRY Struct](GUID-F9E815F6-E87D-440E-991F-639B3C38F3D3.md)**  

-   **[DRV\_SST26\_EVENT\_HANDLER Typedef](GUID-AAF04ADC-3D87-41C9-B3F1-E24105F2CB81.md)**  


**Parent topic:**[SST26 Driver](GUID-11624F96-C547-408B-81F9-B4FA1C9487D6.md)

