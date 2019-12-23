/*******************************************************************************
  PORTS Service

  Company:
    Microchip Technology Inc.

  File Name:
    sys_ports.h

  Summary:
    PORTS Service Header File

  Description:
    This library provides an interface to control and interact with PORTS
    System Service.

*******************************************************************************/

/*******************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*******************************************************************************/

#ifndef SYS_PORTS_H
#define SYS_PORTS_H

#include "device.h"
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>


// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif
// DOM-IGNORE-END


/*******************************************************************************
  PLIB PIO SYS_PORT

  Company:
    Microchip Technology Inc.

  File Name:
    plib_pio_sysport.h

  Summary:
    Datatypes needed to support Haromny Core SYS_PORT functions.

  Description:
    Define datatypes needed by Harmony Core SYS_PORT layer.
    
*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*******************************************************************************/
// DOM-IGNORE-END

#ifndef PLIB_PIO_SYSPORT_H
#define PLIB_PIO_SYSPORT_H

#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif

// *****************************************************************************
// *****************************************************************************
// Section: Data types and constants
// *****************************************************************************
// *****************************************************************************


// *****************************************************************************
/* Sys Port

  Summary:
    Identifies the available Port Channels.

  Description:
    This enumeration identifies the available Port Channels.

  Remarks:
    The caller should not rely on the specific numbers assigned to any of
    these values as they may change from one processor to the next.

    Not all ports are available on all devices.  Refer to the specific
    device data sheet to determine which ports are supported.
*/


typedef enum
{
    SYS_PORT_A = (uint32_t)&(PIO_REGS->PIO_GROUP[0]),
    SYS_PORT_B = (uint32_t)&(PIO_REGS->PIO_GROUP[1]),
    SYS_PORT_C = (uint32_t)&(PIO_REGS->PIO_GROUP[2]),
    SYS_PORT_D = (uint32_t)&(PIO_REGS->PIO_GROUP[3]),
    SYS_PORT_E = (uint32_t)&(PIO_REGS->PIO_GROUP[4]),
    SYS_PORT_F = (uint32_t)&(PIO_REGS->PIO_GROUP[5]),
    SYS_PORT_G = (uint32_t)&(PIO_REGS->PIO_GROUP[6])
} SYS_PORT;


// *****************************************************************************
/* Sys Port Pins

  Summary:
    Identifies the available port pins.

  Description:
    This enumeration identifies the available port pins.

  Remarks:
    The caller should not rely on the specific numbers assigned to any of
    these values as they may change from one processor to the next.

    Not all pins are available on all devices.  Refer to the specific
    device data sheet to determine which pins are supported.
*/

typedef enum
{
    SYS_PORT_PIN_PA0 = 0,
    SYS_PORT_PIN_PA1 = 1,
    SYS_PORT_PIN_PA2 = 2,
    SYS_PORT_PIN_PA3 = 3,
    SYS_PORT_PIN_PA4 = 4,
    SYS_PORT_PIN_PA5 = 5,
    SYS_PORT_PIN_PA6 = 6,
    SYS_PORT_PIN_PA7 = 7,
    SYS_PORT_PIN_PA8 = 8,
    SYS_PORT_PIN_PA9 = 9,
    SYS_PORT_PIN_PA10 = 10,
    SYS_PORT_PIN_PA11 = 11,
    SYS_PORT_PIN_PA12 = 12,
    SYS_PORT_PIN_PA13 = 13,
    SYS_PORT_PIN_PA16 = 16,
    SYS_PORT_PIN_PA17 = 17,
    SYS_PORT_PIN_PA19 = 19,
    SYS_PORT_PIN_PA20 = 20,
    SYS_PORT_PIN_PA21 = 21,
    SYS_PORT_PIN_PA22 = 22,
    SYS_PORT_PIN_PA23 = 23,
    SYS_PORT_PIN_PA24 = 24,
    SYS_PORT_PIN_PA25 = 25,
    SYS_PORT_PIN_PA26 = 26,
    SYS_PORT_PIN_PA27 = 27,
    SYS_PORT_PIN_PA28 = 28,
    SYS_PORT_PIN_PB0 = 32,
    SYS_PORT_PIN_PB1 = 33,
    SYS_PORT_PIN_PB2 = 34,
    SYS_PORT_PIN_PB3 = 35,
    SYS_PORT_PIN_PB4 = 36,
    SYS_PORT_PIN_PB5 = 37,
    SYS_PORT_PIN_PB6 = 38,
    SYS_PORT_PIN_PB7 = 39,
    SYS_PORT_PIN_PB8 = 40,
    SYS_PORT_PIN_PB9 = 41,
    SYS_PORT_PIN_PB10 = 42,
    SYS_PORT_PIN_PB11 = 43,
    SYS_PORT_PIN_PB12 = 44,
    SYS_PORT_PIN_PB13 = 45,
    SYS_PORT_PIN_PB14 = 46,
    SYS_PORT_PIN_PB15 = 47,
    SYS_PORT_PIN_PB16 = 48,
    SYS_PORT_PIN_PB17 = 49,
    SYS_PORT_PIN_PB18 = 50,
    SYS_PORT_PIN_PB19 = 51,
    SYS_PORT_PIN_PB20 = 52,
    SYS_PORT_PIN_PB21 = 53,
    SYS_PORT_PIN_PB22 = 54,
    SYS_PORT_PIN_PB23 = 55,
    SYS_PORT_PIN_PB24 = 56,
    SYS_PORT_PIN_PB25 = 57,
    SYS_PORT_PIN_PB26 = 58,
    SYS_PORT_PIN_PB27 = 59,
    SYS_PORT_PIN_PB28 = 60,
    SYS_PORT_PIN_PB29 = 61,
    SYS_PORT_PIN_PC0 = 64,
    SYS_PORT_PIN_PC1 = 65,
    SYS_PORT_PIN_PC2 = 66,
    SYS_PORT_PIN_PC3 = 67,
    SYS_PORT_PIN_PC4 = 68,
    SYS_PORT_PIN_PC5 = 69,
    SYS_PORT_PIN_PC6 = 70,
    SYS_PORT_PIN_PC7 = 71,
    SYS_PORT_PIN_PC8 = 72,
    SYS_PORT_PIN_PC9 = 73,
    SYS_PORT_PIN_PC10 = 74,
    SYS_PORT_PIN_PC11 = 75,
    SYS_PORT_PIN_PC12 = 76,
    SYS_PORT_PIN_PC13 = 77,
    SYS_PORT_PIN_PC14 = 78,
    SYS_PORT_PIN_PC15 = 79,
    SYS_PORT_PIN_PC16 = 80,
    SYS_PORT_PIN_PC17 = 81,
    SYS_PORT_PIN_PC18 = 82,
    SYS_PORT_PIN_PC19 = 83,
    SYS_PORT_PIN_PC20 = 84,
    SYS_PORT_PIN_PC21 = 85,
    SYS_PORT_PIN_PC22 = 86,
    SYS_PORT_PIN_PC23 = 87,
    SYS_PORT_PIN_PC24 = 88,
    SYS_PORT_PIN_PC25 = 89,
    SYS_PORT_PIN_PC26 = 90,
    SYS_PORT_PIN_PC27 = 91,
    SYS_PORT_PIN_PC28 = 92,
    SYS_PORT_PIN_PC29 = 93,
    SYS_PORT_PIN_PC30 = 94,
    SYS_PORT_PIN_PC31 = 95,
    SYS_PORT_PIN_PD0 = 96,
    SYS_PORT_PIN_PD1 = 97,
    SYS_PORT_PIN_PD2 = 98,
    SYS_PORT_PIN_PD3 = 99,
    SYS_PORT_PIN_PD4 = 100,
    SYS_PORT_PIN_PD5 = 101,
    SYS_PORT_PIN_PD6 = 102,
    SYS_PORT_PIN_PD7 = 103,
    SYS_PORT_PIN_PD8 = 104,
    SYS_PORT_PIN_PD9 = 105,
    SYS_PORT_PIN_PD10 = 106,
    SYS_PORT_PIN_PD11 = 107,
    SYS_PORT_PIN_PD12 = 108,
    SYS_PORT_PIN_PD13 = 109,
    SYS_PORT_PIN_PD14 = 110,
    SYS_PORT_PIN_PD15 = 111,
    SYS_PORT_PIN_PD16 = 112,
    SYS_PORT_PIN_PD17 = 113,
    SYS_PORT_PIN_PD18 = 114,
    SYS_PORT_PIN_PD19 = 115,
    SYS_PORT_PIN_PD20 = 116,
    SYS_PORT_PIN_PD21 = 117,
    SYS_PORT_PIN_PD22 = 118,
    SYS_PORT_PIN_PD23 = 119,
    SYS_PORT_PIN_PD24 = 120,
    SYS_PORT_PIN_PD25 = 121,
    SYS_PORT_PIN_PD26 = 122,
    SYS_PORT_PIN_PD27 = 123,
    SYS_PORT_PIN_PD28 = 124,
    SYS_PORT_PIN_PD29 = 125,
    SYS_PORT_PIN_PD30 = 126,
    SYS_PORT_PIN_PD31 = 127,
    SYS_PORT_PIN_PE0 = 128,
    SYS_PORT_PIN_PE1 = 129,
    SYS_PORT_PIN_PE2 = 130,
    SYS_PORT_PIN_PE3 = 131,
    SYS_PORT_PIN_PE4 = 132,
    SYS_PORT_PIN_PE5 = 133,
    SYS_PORT_PIN_PE6 = 134,
    SYS_PORT_PIN_PE7 = 135,
    SYS_PORT_PIN_PE8 = 136,
    SYS_PORT_PIN_PE9 = 137,
    SYS_PORT_PIN_PE10 = 138,
    SYS_PORT_PIN_PE11 = 139,
    SYS_PORT_PIN_PE12 = 140,
    SYS_PORT_PIN_PF0 = 160,
    SYS_PORT_PIN_PF1 = 161,
    SYS_PORT_PIN_PF2 = 162,
    SYS_PORT_PIN_PF3 = 163,
    SYS_PORT_PIN_PF4 = 164,
    SYS_PORT_PIN_PF5 = 165,
    SYS_PORT_PIN_PF6 = 166,
    SYS_PORT_PIN_PF7 = 167,
    SYS_PORT_PIN_PF8 = 168,
    SYS_PORT_PIN_PF9 = 169,
    SYS_PORT_PIN_PF10 = 170,
    SYS_PORT_PIN_PF11 = 171,
    SYS_PORT_PIN_PF12 = 172,
    SYS_PORT_PIN_PF13 = 173,
    SYS_PORT_PIN_PF14 = 174,
    SYS_PORT_PIN_PF15 = 175,
    SYS_PORT_PIN_PF16 = 176,
    SYS_PORT_PIN_PF17 = 177,
    SYS_PORT_PIN_PF18 = 178,
    SYS_PORT_PIN_PF19 = 179,
    SYS_PORT_PIN_PF20 = 180,
    SYS_PORT_PIN_PF21 = 181,
    SYS_PORT_PIN_PF22 = 182,
    SYS_PORT_PIN_PF23 = 183,
    SYS_PORT_PIN_PF24 = 184,
    SYS_PORT_PIN_PF25 = 185,
    SYS_PORT_PIN_PF26 = 186,
    SYS_PORT_PIN_PF27 = 187,
    SYS_PORT_PIN_PF28 = 188,
    SYS_PORT_PIN_PF29 = 189,
    SYS_PORT_PIN_PF30 = 190,
    SYS_PORT_PIN_PG0 = 192,
    SYS_PORT_PIN_PG1 = 193,
    SYS_PORT_PIN_PG2 = 194,
    SYS_PORT_PIN_PG3 = 195,
    SYS_PORT_PIN_PG4 = 196,
    SYS_PORT_PIN_PG5 = 197,
    SYS_PORT_PIN_PG6 = 198,
    SYS_PORT_PIN_PG7 = 199,
    SYS_PORT_PIN_PG8 = 200,
    SYS_PORT_PIN_PG9 = 201,
    SYS_PORT_PIN_PG10 = 202,
    SYS_PORT_PIN_PG11 = 203,
    SYS_PORT_PIN_PG12 = 204,
    SYS_PORT_PIN_PG13 = 205,
    SYS_PORT_PIN_PG14 = 206,
    SYS_PORT_PIN_PG15 = 207,
    SYS_PORT_PIN_PG16 = 208,
    SYS_PORT_PIN_PG17 = 209,
    SYS_PORT_PIN_PG18 = 210,
    SYS_PORT_PIN_PG19 = 211,
    SYS_PORT_PIN_PG20 = 212,
    SYS_PORT_PIN_PG21 = 213,
    SYS_PORT_PIN_PG22 = 214,
    SYS_PORT_PIN_PG23 = 215,
    SYS_PORT_PIN_PG24 = 216,
    SYS_PORT_PIN_PG25 = 217,
    SYS_PORT_PIN_PG26 = 218,
    SYS_PORT_PIN_PG27 = 219,
    SYS_PORT_PIN_PG30 = 222,
    SYS_PORT_PIN_PG31 = 223,
    /* This element should not be used in any of the PORTS APIs.
       It will be used by other modules or application to denote that none of the PORT Pin is used */
    SYS_PORT_PIN_NONE = -1
} SYS_PORT_PIN;

#ifdef __cplusplus  // Provide C++ Compatibility

    }

#endif

#endif // PLIB_PIO_SYSPORT_H

/*******************************************************************************
 End of File
*/



// *****************************************************************************
// *****************************************************************************
// Section: SYS PORT Functions which operates on one pin at a time
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    void SYS_PORT_PinWrite(SYS_PORT_PIN pin, bool value)

  Summary:
    Writes to the selected pin.

  Description:
    This function writes/drives the "value" on the selected I/O line/pin.

  Precondition:
    Port Initialization must have been done using appropriate Initialize API call.

  Parameters:
    pin       - One of the IO pins from the enum SYS_PORT_PIN
    value     - value to be written on the selected pin:
                true  = set pin to high (1).
                false = clear pin to low (0).

  Returns:
    None.

  Example:
    <code>
    SYS_PORT_PinWrite(SYS_PORT_PIN_PB3, true);
    </code>

  Remarks:
    None.
*/
static inline void SYS_PORT_PinWrite(SYS_PORT_PIN pin, bool value);

// *****************************************************************************
/* Function:
    bool SYS_PORT_PinRead(SYS_PORT_PIN pin)

  Summary:
    Read the selected pin value.

  Description:
    This function reads the selected pin value.
    it reads the value regardless of pin configuration, whether uniquely as an
    input, or driven by the PIO Controller, or driven by peripheral.

  Precondition:
    Reading the I/O line levels requires the clock of the PIO Controller to be
    enabled, otherwise this API reads the levels present on the I/O line at the
    time the clock was disabled.

  Parameters:
    pin - One of the IO pins from the enum SYS_PORT_PIN

  Returns:
    Returns the read value of the selected I/O pin.

  Example:
    <code>

    bool value;
    value = SYS_PORT_PinRead(SYS_PORT_PIN_PB3);

    </code>

  Remarks:
       To read the latched value on this pin, SYS_PORT_PinLatchRead API should be used.
*/
static inline bool SYS_PORT_PinRead(SYS_PORT_PIN pin);

// *****************************************************************************
/* Function:
    bool SYS_PORT_PinLatchRead ( SYS_PORT_PIN pin )

  Summary:
    Read the value driven on the selected pin.

  Description:
    This function reads the data driven on the selected I/O line/pin.
    Whatever data is written/driven on I/O line by using any of the PORTS
    APIs, will be read by this API.

  Precondition:
    None.

  Parameters:
    pin - One of the IO pins from the enum SYS_PORT_PIN

  Returns:
    Returns the value driven on the selected I/O pin.

  Example:
    <code>

    bool value;
    value = SYS_PORT_PinLatchRead(SYS_PORT_PIN_PB3);

    </code>

  Remarks:
    To read actual pin value, SYS_PORT_PinRead API should be used.
*/
static inline bool SYS_PORT_PinLatchRead(SYS_PORT_PIN pin);

// *****************************************************************************
/* Function:
    void SYS_PORT_PinToggle(SYS_PORT_PIN pin)

  Summary:
    Toggles the selected pin.

  Description:
    This function toggles/inverts the value on the selected I/O line/pin.

  Precondition:
    Port Initialization must have been done using appropriate Initialize API call.

  Parameters:
    pin - One of the IO pins from the enum SYS_PORT_PIN

  Returns:
    None.

  Example:
    <code>

    SYS_PORT_PinToggle(SYS_PORT_PIN_PB3);

    </code>

  Remarks:
    None.
*/
static inline void SYS_PORT_PinToggle(SYS_PORT_PIN pin);

// *****************************************************************************
/* Function:
    void SYS_PORT_PinSet(SYS_PORT_PIN pin)

  Summary:
    Sets the selected pin.

  Description:
    This function drives '1' on the selected I/O line/pin.

  Precondition:
    None.

  Parameters:
    pin - One of the IO pins from the enum SYS_PORT_PIN

  Returns:
    None.

  Example:
    <code>

    SYS_PORT_PinSet(SYS_PORT_PIN_PB3);

    </code>

  Remarks:
    None.
*/
static inline void SYS_PORT_PinSet(SYS_PORT_PIN pin);

// *****************************************************************************
/* Function:
    void SYS_PORT_PinClear(SYS_PORT_PIN pin)

  Summary:
    Clears the selected pin.

  Description:
    This function drives '0' on the selected I/O line/pin.

  Precondition:
    None.

  Parameters:
    pin - One of the IO pins from the enum SYS_PORT_PIN

  Returns:
    None.

  Example:
    <code>

    SYS_PORT_PinClear(SYS_PORT_PIN_PB3);

    </code>

  Remarks:
    None.
*/
static inline void SYS_PORT_PinClear(SYS_PORT_PIN pin);

// *****************************************************************************
/* Function:
    void SYS_PORT_PinInputEnable(SYS_PORT_PIN pin)

  Summary:
    Enables selected IO pin as input.

  Description:
    This function enables selected IO pin as input.

  Precondition:
    None.

  Parameters:
    pin - One of the IO pins from the enum SYS_PORT_PIN

  Returns:
    None.

  Example:
    <code>

    SYS_PORT_PinInputEnable(SYS_PORT_PIN_PB3);

    </code>

  Remarks:
    None.
*/
static inline void SYS_PORT_PinInputEnable(SYS_PORT_PIN pin);

// *****************************************************************************
/* Function:
    void SYS_PORT_PinOutputEnable(SYS_PORT_PIN pin)

  Summary:
    Enables selected IO pin as output.

  Description:
    This function enables selected IO pin as output.

  Precondition:
    None.

  Parameters:
    pin - One of the IO pins from the enum SYS_PORT_PIN

  Returns:
    None.

  Example:
    <code>

    SYS_PORT_PinOutputEnable(SYS_PORT_PIN_PB3);

    </code>

  Remarks:
    None.
*/
static inline void SYS_PORT_PinOutputEnable(SYS_PORT_PIN pin);


#include "sys_ports_mapping.h"

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    }

#endif
// DOM-IGNORE-END
#endif // SYS_PORTS_H
