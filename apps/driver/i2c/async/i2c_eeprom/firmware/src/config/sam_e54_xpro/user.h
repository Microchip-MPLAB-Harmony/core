/*******************************************************************************
  User Configuration Header

  File Name:
    user.h

  Summary:
    Build-time configuration header for the user defined by this project.

  Description:
    An MPLAB Project may have multiple configurations.  This file defines the
    build-time options for a single configuration.

  Remarks:
    It only provides macro definitions for build-time configuration options

*******************************************************************************/

#ifndef USER_H
#define USER_H

#include "bsp/bsp.h"
// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

extern "C" {

#endif
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: User Configuration macros
// *****************************************************************************
// *****************************************************************************

#define LED_ON()        LED_On()
#define LED_OFF()       LED_Off()
#define LED_TOGGLE()    LED_Toggle()

//Defines the on-board EEPROM AT24MAC402's I2C Address.
#define APP_AT24MAC_DEVICE_ADDR             0x0056
#define APP_AT24MAC_MEMORY_ADDR             0x00
#define APP_WRITE_DATA_LENGTH               17
#define APP_READ_DATA_LENGTH                16

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

#endif // USER_H
/*******************************************************************************
 End of File
*/
