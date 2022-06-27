# Library Interface

Debug System Service library provides the following interfaces:

**Functions**

|Name|Description|
|----|-----------|
|SYS\_DEBUG\_Initialize|Initializes the global error level and specific module instance|
|SYS\_DEBUG\_Status|Returns status of the specific instance of the debug service module|
|SYS\_DEBUG\_ErrorLevelSet|Sets the global system error reporting level|
|SYS\_DEBUG\_ErrorLevelGet|Returns the global system Error reporting level|
|SYS\_DEBUG\_Redirect|Allows re-direction of debug system service to another console instance|
|SYS\_DEBUG\_ConsoleInstanceGet|Returns console instance used by debug system service|

**Data types and constants**

|Name|Type|Description|
|----|----|-----------|
|SYS\_ERROR\_LEVEL|Enum|System error message priority levels|
|SYS\_DEBUG\_INDEX\_0|Macro|Debug System Service index|
|SYS\_DEBUG\_MESSAGE|Macro|Prints a debug message if the system error level is defined at or lower than the level specified|
|SYS\_DEBUG\_PRINT|Macro|Formats and prints an error message if the system error level is defined at or lower than the level specified|
|SYS\_DEBUG\_BreakPoint|Macro|Inserts a software breakpoint instruction when building in Debug mode|

-   **[SYS\_DEBUG\_Initialize Function](GUID-76AC2CF8-EF78-49D0-8123-4FBCCD8EFE2E.md)**  

-   **[SYS\_DEBUG\_Status Function](GUID-0AAFE706-5859-4761-97D4-223C2EF91279.md)**  

-   **[SYS\_DEBUG\_ErrorLevelSet Function](GUID-090F979E-B329-47FA-B6CA-D7BE390EAB02.md)**  

-   **[SYS\_DEBUG\_ErrorLevelGet Function](GUID-01431AF2-8257-4F6A-8069-1B2CB1BD7B5D.md)**  

-   **[SYS\_DEBUG\_Redirect Function](GUID-DD1D5912-45D3-4227-8720-01869BD15139.md)**  

-   **[SYS\_DEBUG\_ConsoleInstanceGet Function](GUID-E21F3B3B-3CAA-4C6B-8B66-56BF29565731.md)**  

-   **[SYS\_ERROR\_LEVEL Enum](GUID-BA771AE9-3E03-4F87-BE24-51D33B871898.md)**  

-   **[SYS\_DEBUG\_INDEX\_0 Macro](GUID-8E283F11-3204-43A3-86D5-10CF8066E03F.md)**  

-   **[SYS\_DEBUG\_MESSAGE Macro](GUID-09E87B48-98E8-49F7-BBBD-6C049105F75C.md)**  

-   **[SYS\_DEBUG\_PRINT Macro](GUID-223F4EC1-EFAC-46A1-BF77-0DB6B8CB27BB.md)**  

-   **[SYS\_DEBUG\_BreakPoint Macro](GUID-F4092B61-8FC4-4D6E-A043-E20E2965D24D.md)**  


**Parent topic:**[Debug System Service](GUID-4F625306-2206-49B1-8846-60C97E40A440.md)

