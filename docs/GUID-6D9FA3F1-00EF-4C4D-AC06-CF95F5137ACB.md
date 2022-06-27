# Library Interface

AT25DF driver library provides the following interfaces:

**Functions**

|Name|Description|
|----|-----------|
|DRV\_AT25DF\_Initialize|Initializes the AT25DF FLASH device|
|DRV\_AT25DF\_Status|Gets the current status of the AT25DF driver module|
|DRV\_AT25DF\_Open|Opens the specified AT25DF driver instance and returns a handle to it|
|DRV\_AT25DF\_Close|Closes the opened-instance of the AT25DF driver|
|DRV\_AT25DF\_Read|Reads 'n' bytes of data from the specified start address of FLASH|
|DRV\_AT25DF\_Write|Writes 'n' bytes of data starting at the specified address|
|DRV\_AT25DF\_PageWrite|Writes one page of data starting at the specified address|
|DRV\_AT25DF\_SectorErase|Erase the sector from the specified block start address|
|DRV\_AT25DF\_BlockErase|Erase a block from the specified block start address|
|DRV\_AT25DF\_ChipErase|Erase entire flash memory|
|DRV\_AT25DF\_TransferStatusGet|Gets the current status of the transfer request|
|DRV\_AT25DF\_GeometryGet|Returns the geometry of the device|
|DRV\_AT25DF\_EventHandlerSet|Allows a client to identify a transfer event handling function for the driver to call back when the requested transfer has finished|

**Data types and constants**

|Name|Type|Description|
|----|----|-----------|
|DRV\_AT25DF\_TRANSFER\_STATUS|Enum|Defines the data type for AT25DF Driver transfer status|
|DRV\_AT25DF\_GEOMETRY|Struct|Defines the data type for AT25DF FLASH Geometry details|
|DRV\_AT25DF\_EVENT\_HANDLER|Typedef|Pointer to a AT25DF Driver Event handler function|

-   **[DRV\_AT25DF\_Initialize Function](GUID-0F92AB40-ECB3-45CB-9BFD-D633997B307A.md)**  

-   **[DRV\_AT25DF\_Status Function](GUID-BAAA2F94-E63D-4BFF-9C13-DFE7C8689DF6.md)**  

-   **[DRV\_AT25DF\_Open Function](GUID-800334F1-1A78-4C3E-BB99-649A323AB083.md)**  

-   **[DRV\_AT25DF\_Close Function](GUID-CDE5A5C3-D8BA-43BB-9287-A1087E688C15.md)**  

-   **[DRV\_AT25DF\_Read Function](GUID-143402B1-D8C1-4503-B7C3-0D6DF2FAB253.md)**  

-   **[DRV\_AT25DF\_Write Function](GUID-F19C5010-4548-446A-80C6-3642EA7ABA79.md)**  

-   **[DRV\_AT25DF\_PageWrite Function](GUID-B8B88178-A501-4BA9-A5BA-56BD4ECCC0AF.md)**  

-   **[DRV\_AT25DF\_SectorErase Function](GUID-2DA31F3A-13A0-4B9F-97BC-DEBDA757C12C.md)**  

-   **[DRV\_AT25DF\_BlockErase Function](GUID-81B8750A-FEF9-44BB-9CB0-27329B377E77.md)**  

-   **[DRV\_AT25DF\_ChipErase Function](GUID-7146CF6C-8560-4757-A481-2BFE6F65F08C.md)**  

-   **[DRV\_AT25DF\_TransferStatusGet Function](GUID-084F0A8A-2149-4A06-8CCB-7AD00C30134B.md)**  

-   **[DRV\_AT25DF\_GeometryGet Function](GUID-5A9D0D4F-5BBF-4CA3-89A9-1E47BDD90F01.md)**  

-   **[DRV\_AT25DF\_EventHandlerSet Function](GUID-279921BE-6BA3-4C5A-83A3-C14760945710.md)**  

-   **[DRV\_AT25DF\_TRANSFER\_STATUS Enum](GUID-3FA52A35-7013-4C4F-B9A2-F42CEB0E6AED.md)**  

-   **[DRV\_AT25DF\_GEOMETRY Struct](GUID-60293D0A-331A-49A7-ACDF-2982AD6CE6B0.md)**  

-   **[DRV\_AT25DF\_EVENT\_HANDLER Typedef](GUID-3DC42773-D3EB-409B-8F4B-F1E4025E9E90.md)**  


**Parent topic:**[AT25DF Driver](GUID-474B546B-7629-40E2-AF5A-F6A6146CE8DE.md)

