# Using The Library

The Emulated EEPROM library builds on top of NVM or EFC PLIB and provides uniform interface to read/write to the Emulated EEPROM memory space.

The library provides APIs to read and write data from/to a logical page. It also provides APIs to read/write variable number of data across page boundaries.

In addition, it also provides APIs to format \(initialize\) the Emulated EEPROM memory region and status API that lets the application know if the Emulated EEPROM region is formatted and valid or not.

**Example application to read and write to Emulated EEPROM**

```c
#define SIZEOF(s, m) ((size_t) sizeof(((s *)0)->m))

#define EMU_EEPROM_READ(MEM, DEST) EMU_EEPROM_BufferRead(offsetof(EEPROM_DATA, MEM), (uint8_t*)DEST, SIZEOF(EEPROM_DATA, MEM))

#define EMU_EEPROM_WRITE(MEM, DATA) EMU_EEPROM_BufferWrite(offsetof(EEPROM_DATA, MEM), (const uint8_t*)DATA, SIZEOF(EEPROM_DATA, MEM))

APP_DATA appData;

EEPROM_DATA appTestData = {0};
EEPROM_DATA appRAMCopy = {0};

void APP_BufferFill(uint8_t* buffer, uint32_t nBytes)
{
    uint32_t i;

    for (i = 0; i < nBytes; i++)
    {
        buffer[i] = i;
    }
}

void APP_Initialize ( void )
{
    /* Place the App state machine in its initial state. */
    appData.state = APP_STATE_INIT;
}

void APP_Tasks ( void )
{
    EMU_EEPROM_STATUS libStatus;

    /* Check the application's current state. */
    switch ( appData.state )
    {
        /* Application's initial state. */
        case APP_STATE_INIT:

            libStatus = EMU_EEPROM_StatusGet();

            if (libStatus == EMU_EEPROM_STATUS_OK)
            {
                appData.state = APP_STATE_WRITE_DATA;
            }
            else if ((libStatus == EMU_EEPROM_STATUS_ERR_BAD_FORMAT) || (libStatus == EMU_EEPROM_STATUS_ERR_NOT_INITIALIZED))
            {
                /* Format EEPROM memory space */
                EMU_EEPROM_FormatMemory();
                appData.state = APP_STATE_LIB_STATUS_VERIFY;
            }
            else
            {
                appData.state = APP_STATE_ERROR;
            }

            break;

        case APP_STATE_LIB_STATUS_VERIFY:

            /* Make sure the EEPROM Emulator is initialized successfully after it was formatted */
            libStatus = EMU_EEPROM_StatusGet();

            if (libStatus == EMU_EEPROM_STATUS_OK)
            {
                appData.state = APP_STATE_WRITE_DATA;
            }
            else
            {
                appData.state = APP_STATE_ERROR;
            }
            break;

        case APP_STATE_WRITE_DATA:

            /* For demonstration purpose, write some random values to EEPROM memory region */
            appTestData.var_1 = 0x0A;

            EMU_EEPROM_WRITE(var_1, &appTestData.var_1);

            appTestData.var_2 = 0x1234;

            EMU_EEPROM_WRITE(var_2, &appTestData.var_2);

            appTestData.var_3 = 0x33445566;

            EMU_EEPROM_WRITE(var_3, &appTestData.var_3);

            appTestData.var_7 = 0x3189AB1C;

            EMU_EEPROM_WRITE(var_7, &appTestData.var_7);

            appTestData.var_7 = 0x9A7BC123;

            EMU_EEPROM_WRITE(var_7, &appTestData.var_7);

            appTestData.var_2 = 0x1256;

            EMU_EEPROM_WRITE(var_2, &appTestData.var_2);

            appTestData.var_7 = 0x882B7C9A;

            EMU_EEPROM_WRITE(var_7, &appTestData.var_7);

            appTestData.var_2 = 0x7788;

            EMU_EEPROM_WRITE(var_2, &appTestData.var_2);

            APP_BufferFill(appTestData.buffer_1, sizeof (appTestData.buffer_1));

            EMU_EEPROM_WRITE(buffer_1, &appTestData.buffer_1);

            appTestData.var_11 = 0x7498AFDD;

            EMU_EEPROM_WRITE(var_11, &appTestData.var_11);

            appTestData.var_7 = 0x1788BB8D;

            EMU_EEPROM_WRITE(var_7, &appTestData.var_7);

            appTestData.var_10 = 0x7744AABB;

            EMU_EEPROM_WRITE(var_10, &appTestData.var_10);

            appTestData.var_2 = 0x9922;

            EMU_EEPROM_WRITE(var_2, &appTestData.var_2);

            appTestData.var_5 = 0x59AF;

            EMU_EEPROM_WRITE(var_5, &appTestData.var_5);

            appTestData.var_9 = 0x99AA;

            EMU_EEPROM_WRITE(var_9, &appTestData.var_9);

            appTestData.var_10 = 0x88888888;

            EMU_EEPROM_WRITE(var_10, &appTestData.var_10);

            appTestData.var_12 = 0x5577;

            EMU_EEPROM_WRITE(var_12, &appTestData.var_12);

            appTestData.var_10 = 0x1AC87439;

            EMU_EEPROM_WRITE(var_10, &appTestData.var_10);

            appTestData.var_8 = 0x752B9ACE;

            EMU_EEPROM_WRITE(var_8, &appTestData.var_8);

            appTestData.var_2 = 0xA765;

            EMU_EEPROM_WRITE(var_2, &appTestData.var_2);

            appTestData.var_4 = 0xA7;

            EMU_EEPROM_WRITE(var_4, &appTestData.var_4);

            appTestData.var_9 = 0xEEF1;

            EMU_EEPROM_WRITE(var_9, &appTestData.var_9);

            appTestData.var_6 = 0xF497;

            EMU_EEPROM_WRITE(var_6, &appTestData.var_6);

            /* Commit any data that may be in EEPROM Emulator library's cache to physical memory */
            EMU_EEPROM_PageBufferCommit();

            appData.state = APP_STATE_READ_DATA;

            break;

        case APP_STATE_READ_DATA:

            /* Randomly read back the written values */
            EMU_EEPROM_READ(var_2, &appRAMCopy.var_2);

            EMU_EEPROM_READ(var_3, &appRAMCopy.var_3);

            EMU_EEPROM_READ(var_7, &appRAMCopy.var_7);

            EMU_EEPROM_READ(var_9, &appRAMCopy.var_9);

            EMU_EEPROM_READ(var_10, &appRAMCopy.var_10);

            EMU_EEPROM_READ(var_12, &appRAMCopy.var_12);

            EMU_EEPROM_READ(var_1, &appRAMCopy.var_1);

            EMU_EEPROM_READ(var_6, &appRAMCopy.var_6);

            EMU_EEPROM_READ(var_8, &appRAMCopy.var_8);

            EMU_EEPROM_READ(var_11, &appRAMCopy.var_11);

            EMU_EEPROM_READ(buffer_1, &appRAMCopy.buffer_1);

            EMU_EEPROM_READ(var_4, &appRAMCopy.var_4);

            EMU_EEPROM_READ(var_5, &appRAMCopy.var_5);

            appData.state = APP_STATE_VERIFY;

            break;

        case APP_STATE_VERIFY:
            if (memcmp((void const*)&appRAMCopy, (void const*)&appTestData, sizeof (EEPROM_DATA)) == 0)
            {
                LED_On();
            }
            else
            {
                LED_Off();
            }

            appData.state = APP_STATE_IDLE;
            break;

        case APP_STATE_IDLE:
            break;

        case APP_STATE_ERROR:
            break;

        /* TODO: implement your application state machine.*/


        /* The default state should never be executed. */
        default:
        {
            /* TODO: Handle error in application's state machine. */
            break;
        }
    }
}


```

**Parent topic:**[Emulated EEPROM](GUID-7D1381D7-9A05-495B-B0A8-D195FA444618.md)

