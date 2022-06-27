# Library Interface

AT25 driver library provides the following interfaces:

**Functions**

|Name|Description|
|----|-----------|
|DRV\_AT25\_Initialize|Initializes the AT25 EEPROM device|
|DRV\_AT25\_Status|Gets the current status of the AT25 driver module|
|DRV\_AT25\_Open|Opens the specified AT25 driver instance and returns a handle to it|
|DRV\_AT25\_Close|Closes the opened-instance of the AT25 driver|
|DRV\_AT25\_Read|Reads 'n' bytes of data from the specified start address of EEPROM|
|DRV\_AT25\_Write|Writes 'n' bytes of data starting at the specified address|
|DRV\_AT25\_PageWrite|Writes one page of data starting at the specified address|
|DRV\_AT25\_TransferStatusGet|Gets the current status of the transfer request|
|DRV\_AT25\_GeometryGet|Returns the geometry of the device|
|DRV\_AT25\_EventHandlerSet|Allows a client to identify a transfer event handling function for the driver to call back when the requested transfer has finished|

**Data types and constants**

|Name|Type|Description|
|----|----|-----------|
|DRV\_AT25\_TRANSFER\_STATUS|Enum|Defines the data type for AT25 Driver transfer status|
|DRV\_AT25\_GEOMETRY|Struct|Defines the data type for AT25 EEPROM Geometry details|
|DRV\_AT25\_EVENT\_HANDLER|Typedef|Pointer to a AT25 Driver Event handler function|

-   **[DRV\_AT25\_Initialize Function](GUID-09CD262E-94FF-4332-B87D-B39C2EB24755.md)**  

-   **[DRV\_AT25\_Status Function](GUID-DCC39687-E45F-46D1-B489-0AFC1262B40B.md)**  

-   **[DRV\_AT25\_Open Function](GUID-12F1A1E3-E31A-45D6-9D59-6CEF9F0B1684.md)**  

-   **[DRV\_AT25\_Close Function](GUID-68C15981-33D0-4B83-9016-A7F1A10940AB.md)**  

-   **[DRV\_AT25\_Read Function](GUID-3D691B46-43E2-44A8-8FDF-855290108FAC.md)**  

-   **[DRV\_AT25\_Write Function](GUID-6666B157-1614-4C2E-8B25-F23A183D36E0.md)**  

-   **[DRV\_AT25\_PageWrite Function](GUID-DECFF1FB-9C12-4E95-8C07-6244681BB99A.md)**  

-   **[DRV\_AT25\_TransferStatusGet Function](GUID-AAF0F727-6A9B-4935-AF27-0921A436A210.md)**  

-   **[DRV\_AT25\_GeometryGet Function](GUID-94CD1F4B-606F-483B-985B-58EE4E5C6A27.md)**  

-   **[DRV\_AT25\_EventHandlerSet Function](GUID-0DEAE4F8-7490-4EC9-9B9E-91B684AE3B07.md)**  

-   **[DRV\_AT25\_TRANSFER\_STATUS Enum](GUID-310793D7-0A33-4671-A43E-209D3061FADA.md)**  

-   **[DRV\_AT25\_GEOMETRY Struct](GUID-413DE7BF-9304-4F7F-BBA8-CCC29E41A668.md)**  

-   **[DRV\_AT25\_EVENT\_HANDLER Typedef](GUID-436E9B1F-FE7C-4BBB-99D3-161DBFE1CF93.md)**  


**Parent topic:**[AT25 Driver](GUID-78C407C0-91E3-468C-9D3A-F01AF5A9CCB9.md)

