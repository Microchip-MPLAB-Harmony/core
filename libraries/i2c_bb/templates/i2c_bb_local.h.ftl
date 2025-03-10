/*******************************************************************************
  I2C BITBANG Library Interface Header File

  Company
    Microchip Technology Inc.

  File Name
    I2C_BB_local.h

  Summary
    I2C BITBANG library interface.

  Description

  Remarks:

*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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

#ifndef I2C_BB_LOCAL_H
#define I2C_BB_LOCAL_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

/*  This section lists the other files that are included in this file.
*/
#include <stdbool.h>
#include <stddef.h>
#include "system/ports/sys_ports.h"
// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif
// DOM-IGNORE-END
#define OUTPUT              false
#define INPUT               true

#define LOW                 false
#define HIGH                true

#define M_ACK               false
#define M_NACK              true

<#assign TMR_CLOCK_FREQUENCY = "core." + I2CBB_CONNECTED_TIMER + "_CLOCK_FREQUENCY">
#define ${I2CBB_INSTANCE_NAME}_IRQn   ${.vars["${I2CBB_CONNECTED_TIMER?lower_case}"].IRQ_ENUM_NAME}
#define ${I2CBB_INSTANCE_NAME}_TMR_CLOCK_FREQUENCY  ${I2CBB_CONNECTED_TIMER_FRQUENCY}


#define I2C_BB_DATA_PIN SYS_PORT_PIN_${I2CBB_SDA_PIN}
#define I2C_BB_CLK_PIN  SYS_PORT_PIN_${I2CBB_SCL_PIN}

#define TIME_HW_COUNTER_WIDTH            ${.vars["${I2CBB_CONNECTED_TIMER?lower_case}"].TIMER_WIDTH}
// *****************************************************************************
// *****************************************************************************
// Section: Data Types
// *****************************************************************************
// *****************************************************************************

/* MISRA C-2012 Rule 5.2 deviated:6 Deviation record ID -  H3_MISRAC_2012_R_5_2_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:6 "MISRA C-2012 Rule 5.2" "H3_MISRAC_2012_R_5_2_DR_1"    
</#if>

typedef enum
{
    I2CBB_BUS_STATE_NULL_STATE = 0,

    /* Start condition on I2C BUS with SDA low */
    I2CBB_BUS_STATE_SDA_LOW_START,

    /* I2C SDA low start check */
    I2CBB_BUS_STATE_SDA_LOW_START_CHECK,

    /* Start condition on I2C Bus with SCL low after SDA low */
    I2CBB_BUS_STATE_SCL_LOW_START,

    /* I2C SCL low start check */
    I2CBB_BUS_STATE_SCL_LOW_START_CHECK,

    /* setting SDA high on RESTART */
    I2CBB_BUS_STATE_SDA_HIGH_RESTART,

    /* check SDA high RESTART */
    I2CBB_BUS_STATE_SDA_HIGH_RESTART_CHECK,

    /* setting SCL high on RESTART */
    I2CBB_BUS_STATE_SCL_HIGH_RESTART,

    /* check SCL high on RESTART */
    I2CBB_BUS_STATE_SCL_HIGH_RESTART_CHECK,

    /* SCL High during data transfer to ensure Data is not changing */
    I2CBB_BUS_STATE_SCL_HIGH_DATA,

    /* High data check */
    I2CBB_BUS_STATE_SCL_HIGH_DATA_CHECK,

    /* SCL Low during data transfer where data can change */
    I2CBB_BUS_STATE_SCL_LOW_DATA,

    /* SCL low data check */
    I2CBB_BUS_STATE_SCL_LOW_DATA_CHECK,

    /* keep SCL and SDA low for 1 BRG time */
    I2CBB_BUS_STATE_SCL_SDA_LOW_STOP,

    /* keep SCL and SDA low check */
    I2CBB_BUS_STATE_SCL_SDA_LOW_STOP_CHECK,

    /* SCL going high during STOP condition */
    I2CBB_BUS_STATE_SCL_HIGH_STOP,

    /* SCL going HIGH check*/
    I2CBB_BUS_STATE_SCL_HIGH_STOP_CHECK,

    /* SDA going low during STOP condition */
    I2CBB_BUS_STATE_SDA_HIGH_STOP,

    /* SDA going high STOP check */
    I2CBB_BUS_STATE_SDA_HIGH_STOP_CHECK

} I2CBB_BUS_STATE;

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 5.2"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>    
</#if>
/* MISRAC 2012 deviation block end */

typedef enum
{
    /* No error has occurred. */
   I2CBB_ERROR_NONE,

    /* A bus transaction was NAK'ed */
   I2CBB_ERROR_NAK,

    /* A bus error has occurred. */
   I2CBB_ERROR_BUS,

} I2CBB_ERROR;

typedef enum
{

  I2CBB_TRANSFER_STATE_READ,

  I2CBB_TRANSFER_STATE_WRITE,

  I2CBB_TRANSFER_STATE_WRITE_READ,

  I2CBB_TRANSFER_STATE_DONE,

}I2CBB_TRANSFER_STATE;

typedef void (* I2CBB_CALLBACK)( uintptr_t context );

typedef void (*I2C_BB_TMR_PLIB_CALLBACK)(uint32_t status, uintptr_t context);

typedef void (*I2C_BB_TMR_PLIB_START)(void);

typedef void (*I2C_BB_TMR_PLIB_STOP)(void);

typedef void (*I2C_BB_TMR_PLIB_CALLBACK_REGISTER)( I2C_BB_TMR_PLIB_CALLBACK callback, uintptr_t context);

#if (TIME_HW_COUNTER_WIDTH == 16)
typedef void (*I2C_BB_TMR_PLIB_PERIOD_SET)(uint16_t period);
#else
typedef void (*I2C_BB_TMR_PLIB_PERIOD_SET)(uint32_t period);
#endif
typedef struct
{
    I2C_BB_TMR_PLIB_START                   timerStart;

    I2C_BB_TMR_PLIB_STOP                    timerStop;

    I2C_BB_TMR_PLIB_PERIOD_SET              timerPeriodset;

    I2C_BB_TMR_PLIB_CALLBACK_REGISTER       timerCallbackRegister;
}I2C_BB_TMR_PLIB_INTERFACE;

typedef struct
{
    const I2C_BB_TMR_PLIB_INTERFACE*       i2cbbTmrPlib;

    SYS_PORT_PIN                           i2cbbSDAPin;

    SYS_PORT_PIN                           i2cbbSCLPin;

    uint32_t                               i2cClockSpeed;
}I2C_BB_INIT;

typedef struct
{
    /* I2C Clock Speed */
    uint32_t clkSpeed;

} I2CBB_TRANSFER_SETUP;

typedef struct I2CBB_OBJ_T
{
    I2CBB_BUS_STATE        i2cState;

    uint32_t               i2cClockSpeed;

    uint32_t               timerSrcClkFreq;

    uint16_t               I2CSWCounter;

    uint16_t               I2CSWData;

    bool                   I2CNACKOut;

    bool                   I2CACKStatus;

    uint16_t               I2CReadData;

    uint32_t               errorTimeOut;

    bool                  i2c_bit_written;

    bool                  ACKSTATUS_M;

    uint16_t              address;

    uint8_t               *writeBuffer;

    uint8_t               *readBuffer;

    size_t                writeSize;

    size_t                readSize;

    size_t                writeCount;

    size_t                readCount;

    volatile              I2CBB_TRANSFER_STATE transferState;

    volatile              I2CBB_ERROR errorStatus;

<#if I2C_INCLUDE_FORCED_WRITE_API == true>
    bool                  forcedWrite;
</#if>

    I2CBB_CALLBACK        callback;

    uintptr_t context;

} I2CBB_OBJ;

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    }

#endif
// DOM-IGNORE-END

#endif // I2C_BB_LOCAL_H

/*******************************************************************************
 End of File
*/
