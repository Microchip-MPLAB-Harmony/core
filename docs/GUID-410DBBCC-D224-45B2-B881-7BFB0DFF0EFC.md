# Library Interface

MX25L driver library provides the following interfaces:

**Functions**

|Name|Description|
|----|-----------|
|DRV\_MX25L\_Initialize|Initializes the MX25L Driver|
|DRV\_MX25L\_Open|Opens the specified MX25L driver instance and returns a handle to it|
|DRV\_MX25L\_Close|Closes an opened-instance of the MX25L driver|
|DRV\_MX25L\_Status|Gets the current status of the MX25L driver module|
|DRV\_MX25L\_ResetFlash|Reset the flash device to standby mode|
|DRV\_MX25L\_ReadJedecId|Reads JEDEC-ID of the flash device|
|DRV\_MX25L\_SectorErase|Erase the sector from the specified block start address|
|DRV\_MX25L\_BlockErase|Erase a block from the specified block start address|
|DRV\_MX25L\_ChipErase|Erase entire flash memory|
|DRV\_MX25L\_Read|Reads n bytes of data from the specified start address of flash memory|
|DRV\_MX25L\_PageWrite|Writes one page of data starting at the specified address|
|DRV\_MX25L\_TransferStatusGet|Gets the current status of the transfer request|
|DRV\_MX25L\_GeometryGet|Returns the geometry of the device|

**Data types and constants**

|Name|Type|Description|
|----|----|-----------|
|DRV\_MX25L\_TRANSFER\_STATUS|Enum|MX25L Driver Transfer Status|
|DRV\_MX25L\_GEOMETRY|Struct|MX25L Device Geometry data|

-   **[DRV\_MX25L\_Initialize Function](GUID-0381E2F0-27AD-4688-8C95-60FC00AD42FF.md)**  

-   **[DRV\_MX25L\_Open Function](GUID-EC748BA1-9BAC-4215-A451-951C7AD230DA.md)**  

-   **[DRV\_MX25L\_Close Function](GUID-42849F24-7399-4889-A3D2-18673DDDD78D.md)**  

-   **[DRV\_MX25L\_Status Function](GUID-6CDF8842-E92B-4F0E-8E5D-95DAFE16410D.md)**  

-   **[DRV\_MX25L\_ResetFlash Function](GUID-6667FC20-3017-4F29-82D8-D2873B38AC8E.md)**  

-   **[DRV\_MX25L\_ReadJedecId Function](GUID-030A860C-69CB-4950-B0D8-91A9E1DA2839.md)**  

-   **[DRV\_MX25L\_SectorErase Function](GUID-918010E3-6FC5-4A07-9626-4E16FC61ECCE.md)**  

-   **[DRV\_MX25L\_BlockErase Function](GUID-75EA4FAD-10D6-4276-A80E-4F19FC9E6F9D.md)**  

-   **[DRV\_MX25L\_ChipErase Function](GUID-77D7DF1E-E1CB-47CD-B5C1-6DFC3700CF3D.md)**  

-   **[DRV\_MX25L\_Read Function](GUID-B9E79528-189C-4FA7-9252-A96AF3636B2B.md)**  

-   **[DRV\_MX25L\_PageWrite Function](GUID-304B5F79-B8A0-478C-9C98-3D405FD8C868.md)**  

-   **[DRV\_MX25L\_TransferStatusGet Function](GUID-7F7AA1C9-FF6A-4C0F-A381-68CD1DE5049E.md)**  

-   **[DRV\_MX25L\_GeometryGet Function](GUID-B923A6E5-4C36-4DCA-8F94-360FC1E49735.md)**  

-   **[DRV\_MX25L\_TRANSFER\_STATUS Enum](GUID-1F957550-41AD-4F0F-A9D8-8E289DD36931.md)**  

-   **[DRV\_MX25L\_GEOMETRY Struct](GUID-03E37865-7F03-4BF3-B654-845323CBE7E4.md)**  


**Parent topic:**[MX25L Driver](GUID-276B2413-47FF-4F2A-8221-2808537B02CE.md)

