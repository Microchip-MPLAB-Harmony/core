/*******************************************************************************
  Ports System Service Mapping File

  Company:
    Microchip Technology Inc.

  File Name:
    sys_ports_mapping.h

  Summary:
    Ports System Service mapping file.

  Description:
    This header file contains the mapping of the APIs defined in the API header
    to either the function implementations or macro implementation or the
    specific variant implementation.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/******************************************************************************
Copyright (c) 2018 released Microchip Technology Inc.  All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED 'AS IS' WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR
CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF
SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
*******************************************************************************/
//DOM-IGNORE-END

#ifndef SYS_PORTS_MAPPING_H
#define SYS_PORTS_MAPPING_H

#include "peripheral/pio/plib_pio.h"

// *****************************************************************************
// *****************************************************************************
// Section: PORTS System Service Mapping
// *****************************************************************************
// *****************************************************************************
#define SYS_PORT_PinWrite(pin, value)       PIO_PinWrite(pin, value)

#define SYS_PORT_PinRead(pin)               PIO_PinRead(pin) 

#define SYS_PORT_PinReadLatch(pin)          PIO_PinReadLatch(pin)

#define SYS_PORT_PinToggle(pin)             PIO_PinToggle(pin)

#define SYS_PORT_PinSet(pin)                PIO_PinSet(pin) 

#define SYS_PORT_PinClear(pin)              PIO_PinClear(pin) 

#define SYS_PORT_PinInputEnable(pin)        PIO_PinInputEnable(pin)

#define SYS_PORT_PinOutputEnable(pin)       PIO_PinOutputEnable(pin)

#define SYS_PORT_PinInterruptEnable(pin)    PIO_PinInterruptEnable(pin)

#define SYS_PORT_PinInterruptDisable(pin)   PIO_PinInterruptDisable(pin)


#endif // SYS_PORTS_MAPPING_H

/*******************************************************************************
 End of File
*/
