# Using The Library

**Interface Header File:** osal.h

The interface to the OSAL Library is defined in the osal.h header file. Any C language source \(.c\) file that uses the OSAL System Service library should include osal.h.

**Library File:**

-   osal.c

    -   Source files added to the project if using the "BareMetal" OSAL basic implementation used when no RTOS is present.

-   osal\_<vendor-specified RTOS name\>.c \(i.e., FreeRTOS, etc.\)


The OSAL Library consists of a basic implementation and individual ports of the OSAL to target operating systems. The basic implementation is used when any of the Third-Party Library RTOS is not instantiated.

When an RTOS is being used \(i.e. if any of Third-Party Library RTOS is instantiated, Ex: FreeRTOS\) then an external implementation file which provides the required interface wrappers should be added to the project. For instance for the FreeRTOS operating system the file osal\_freertos.c should be added, while for the Micriµm µC/OS-III operating system the file osal\_ucos3.c should be added.

The basic implementation and some generic ports are provided with the Library, however, it is the responsibility of third-party vendors to supply an implementation file for operating systems that are not already supported.

When the OSAL is using an underlying RTOS it may be necessary to allow the RTOS to perform one-time initialization before any calls to it are made. For instance, the RTOS might implement multiple memory pools for managing queues and semaphores, and it must be given the chance to create these pools before any of the objects are created. For this reason the application program should call OSAL\_Initialize\(\) early on and certainly before any MPLAB Harmony drivers or middleware is initialized \(since these may also create OSAL objects at creation time\).

Once the OSAL is initialized and any other remaining parts of the system are configured correctly, the specific RTOS can be started.

-   **[Semaphore Operations](GUID-959D7A17-0006-48BC-B5B5-00FB6D26B38D.md)**  

-   **[Mutex Operations](GUID-430ED88C-3DBA-4821-ABD7-E4C30EAB006C.md)**  

-   **[Critical Section Operations](GUID-5A8FD263-9070-43FB-9578-AE6D97182339.md)**  

-   **[Memory Operations](GUID-B770DB97-5472-46CE-9CEC-39A8C892C5B3.md)**  


**Parent topic:**[OSAL Library](GUID-8AEFE0B0-CE35-4F99-ACF4-7C8E10D3BBB6.md)

