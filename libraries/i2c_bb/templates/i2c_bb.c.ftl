/*******************************************************************************
  I2C BIT BANG Library Source File

  Company
    Microchip Technology Inc.

  File Name
    ${I2CBB_INSTANCE_NAME?lower_case}.c

  Summary
    I2C BIT BANG library interface.

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

// *****************************************************************************
// *****************************************************************************
// Included Files
// *****************************************************************************
// *****************************************************************************

#include "device.h"
#include "${I2CBB_INSTANCE_NAME?lower_case}.h"
#include "definitions.h"
// *****************************************************************************
// *****************************************************************************
// Local Data Type Definitions
// *****************************************************************************
// *****************************************************************************
#define ERROR_TIMEOUT_COUNT         2000000


// *****************************************************************************
// *****************************************************************************
// Global Data
// *****************************************************************************
// *****************************************************************************

static I2CBB_OBJ ${I2CBB_INSTANCE_NAME?lower_case}Obj;

const I2C_BB_TMR_PLIB_INTERFACE i2cTimerPlibAPI = {
    .timerStart = (I2C_BB_TMR_PLIB_START)${.vars["${I2CBB_CONNECTED_TIMER?lower_case}"].TIMER_START_API_NAME},

    .timerStop = (I2C_BB_TMR_PLIB_STOP)${.vars["${I2CBB_CONNECTED_TIMER?lower_case}"].TIMER_STOP_API_NAME},

    .timerPeriodset = (I2C_BB_TMR_PLIB_PERIOD_SET)${.vars["${I2CBB_CONNECTED_TIMER?lower_case}"].PERIOD_SET_API_NAME},

    .timerCallbackRegister = (I2C_BB_TMR_PLIB_CALLBACK_REGISTER)${.vars["${I2CBB_CONNECTED_TIMER?lower_case}"].CALLBACK_API_NAME}
};


const I2C_BB_INIT i2cBBInitData =
{
    .i2cbbTmrPlib        = &i2cTimerPlibAPI,
    .i2cbbSDAPin         = I2C_BB_DATA_PIN,
    .i2cbbSCLPin         = I2C_BB_CLK_PIN,
    .i2cbbBaudRate       = ${I2C_CLOCK_SPEED}

};

static void ${I2CBB_INSTANCE_NAME}_InitiateTransfer(void)
{
#if (TIME_HW_COUNTER_WIDTH == 16)
    uint16_t timerPeriod;
#else
    uint32_t timerPeriod;
#endif
    I2C_BB_INIT* dObj =(I2C_BB_INIT*)&i2cBBInitData;

    timerPeriod = ${I2CBB_INSTANCE_NAME}_TMR_CLOCK_FREQUENCY/((dObj->i2cbbBaudRate)<<2);

    ${I2CBB_INSTANCE_NAME?lower_case}Obj.writeCount = 0;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.readCount = 0;
    /* send START command only if SCL and SDA are pulled high */
    if ((SYS_PORT_PinRead(dObj->i2cbbSCLPin) == HIGH) && (SYS_PORT_PinRead(dObj->i2cbbSDAPin) == HIGH))
    {
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SDA_LOW_START;
        dObj->i2cbbTmrPlib->timerStop();
        dObj->i2cbbTmrPlib->timerPeriodset(timerPeriod);
        dObj->i2cbbTmrPlib->timerStart();
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CNACKOut = false;
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CACKStatus = false;

        ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut = ERROR_TIMEOUT_COUNT;
    }
}

static void ${I2CBB_INSTANCE_NAME}_tasks(void)
{
    I2C_BB_INIT* dObj =(I2C_BB_INIT*)&i2cBBInitData;

    switch(${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState)
    {
      case I2CBB_BUS_STATE_SDA_LOW_START:
        SYS_PORT_PinOutputEnable(dObj->i2cbbSDAPin);
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SDA_LOW_START_CHECK;
        break;

      case I2CBB_BUS_STATE_SDA_LOW_START_CHECK:
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_LOW_START;
        break;

      case I2CBB_BUS_STATE_SCL_LOW_START:
        SYS_PORT_PinOutputEnable(dObj->i2cbbSCLPin);
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_LOW_START_CHECK;
        break;

      case I2CBB_BUS_STATE_SCL_LOW_START_CHECK:

        if ((${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState == I2CBB_TRANSFER_STATE_WRITE_READ) &&
          (${I2CBB_INSTANCE_NAME?lower_case}Obj.writeCount > (${I2CBB_INSTANCE_NAME?lower_case}Obj.writeSize))) {
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState = I2CBB_TRANSFER_STATE_READ;
        }
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWData = ${I2CBB_INSTANCE_NAME?lower_case}Obj.address;
        if (${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState == I2CBB_TRANSFER_STATE_READ) {
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWData |= 0x01;
        }
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_LOW_DATA_CHECK;
        break;

      case I2CBB_BUS_STATE_SDA_HIGH_RESTART:
        SYS_PORT_PinInputEnable(dObj->i2cbbSDAPin);
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut = ERROR_TIMEOUT_COUNT;
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SDA_HIGH_RESTART_CHECK;
        break;

      case I2CBB_BUS_STATE_SDA_HIGH_RESTART_CHECK:
        if (SYS_PORT_PinRead(dObj->i2cbbSDAPin) == INPUT) {
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_HIGH_RESTART;
        } else {
          if (!(${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut--)) {
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorStatus = I2CBB_ERROR_BUS;
            dObj->i2cbbTmrPlib->timerStop();
             dObj->i2cbbTmrPlib->timerPeriodset(0);
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut = ERROR_TIMEOUT_COUNT;
          } else {
            SYS_PORT_PinInputEnable(dObj->i2cbbSDAPin);
          }
        }
        break;

      case I2CBB_BUS_STATE_SCL_HIGH_RESTART:
        SYS_PORT_PinInputEnable(dObj->i2cbbSCLPin);
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut = ERROR_TIMEOUT_COUNT;
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_HIGH_RESTART_CHECK;
        break;

      case I2CBB_BUS_STATE_SCL_HIGH_RESTART_CHECK:
        if (SYS_PORT_PinRead(dObj->i2cbbSCLPin) == INPUT) {
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SDA_LOW_START;
        } else {
          if (!(${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut--)) {
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorStatus = I2CBB_ERROR_BUS;
            dObj->i2cbbTmrPlib->timerStop();
             dObj->i2cbbTmrPlib->timerPeriodset(0);
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut = ERROR_TIMEOUT_COUNT;
          } else {
            SYS_PORT_PinInputEnable(dObj->i2cbbSCLPin);
          }
        }
        break;

      case I2CBB_BUS_STATE_SCL_LOW_DATA_CHECK:
        SYS_PORT_PinOutputEnable(dObj->i2cbbSCLPin);
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_LOW_DATA;
        break;

      case I2CBB_BUS_STATE_SCL_LOW_DATA:
        if (${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWCounter > 1) {
          if ((bool)(${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWData & 0x80)) {
            SYS_PORT_PinInputEnable(dObj->i2cbbSDAPin);
          } else {
            SYS_PORT_PinOutputEnable(dObj->i2cbbSDAPin);
          }
        }
        // just before the 9th clock prepare for an acknowledge.
        else if (${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWCounter == 1) {
          ${I2CBB_INSTANCE_NAME?lower_case}Obj._i2c_bit_written = 0;
          if ((${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState == I2CBB_TRANSFER_STATE_READ) &&
            ((${I2CBB_INSTANCE_NAME?lower_case}Obj.readCount != ${I2CBB_INSTANCE_NAME?lower_case}Obj.readSize)
              &&
              (${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWData == 0xFF00))) {
            SYS_PORT_PinOutputEnable(dObj->i2cbbSDAPin);
          } else {
            SYS_PORT_PinInputEnable(dObj->i2cbbSDAPin);
          }
        }
        // After the 9th clock
        if (${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWCounter == 0) {
          if ((${I2CBB_INSTANCE_NAME?lower_case}Obj.writeCount != (${I2CBB_INSTANCE_NAME?lower_case}Obj.writeSize)) &&
            ((${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CACKStatus == M_ACK))
            &&((${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState == I2CBB_TRANSFER_STATE_WRITE) ||
              (${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState == I2CBB_TRANSFER_STATE_WRITE_READ))) {
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWData = * ${I2CBB_INSTANCE_NAME?lower_case}Obj.writeBuffer++;
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_LOW_DATA;
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWCounter = 9;
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.writeCount++;
          }
          else if ((${I2CBB_INSTANCE_NAME?lower_case}Obj.readCount != (${I2CBB_INSTANCE_NAME?lower_case}Obj.readSize)) &&
            (${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CACKStatus == M_ACK) &&
            (${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState == I2CBB_TRANSFER_STATE_READ)) {
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWData = 0xFF;
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_LOW_DATA;
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWCounter = 9;
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.readCount++;
            if ((${I2CBB_INSTANCE_NAME?lower_case}Obj.readCount != (${I2CBB_INSTANCE_NAME?lower_case}Obj.readSize))) {
              ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CNACKOut = 0x01;
            } else {
              ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CNACKOut = 0;
            }
          }
          else if ((${I2CBB_INSTANCE_NAME?lower_case}Obj.writeCount == (${I2CBB_INSTANCE_NAME?lower_case}Obj.writeSize)) &&
            (${I2CBB_INSTANCE_NAME?lower_case}Obj.readCount != (${I2CBB_INSTANCE_NAME?lower_case}Obj.readSize)) &&
            (${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CACKStatus == M_ACK) &&
            (${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState == I2CBB_TRANSFER_STATE_WRITE_READ)) {
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState = I2CBB_TRANSFER_STATE_READ;
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SDA_HIGH_RESTART;
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWCounter = 9;
          }
          else {
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_SDA_LOW_STOP;
          }
        } else {
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_HIGH_DATA; //if clock count is not 0
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWCounter--; //decrement clock counter
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWData <<= 1; //shift data byte
        }
        break;

      case I2CBB_BUS_STATE_SCL_HIGH_DATA:
        if ((${I2CBB_INSTANCE_NAME?lower_case}Obj._i2c_bit_written == 1)) {
          /* check the value of bit that is just written onto the bus */
          if ((bool)(SYS_PORT_PinRead(dObj->i2cbbSDAPin)) == (bool) ${I2CBB_INSTANCE_NAME?lower_case}Obj._i2c_bit_written) {
            SYS_PORT_PinInputEnable(dObj->i2cbbSCLPin);
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_HIGH_DATA_CHECK;
          } else {
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorStatus = I2CBB_ERROR_BUS;
            dObj->i2cbbTmrPlib->timerStop();
            dObj->i2cbbTmrPlib->timerPeriodset(0);
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut = ERROR_TIMEOUT_COUNT;
            SYS_PORT_PinInputEnable(dObj->i2cbbSCLPin);
          }
        } else {
          SYS_PORT_PinInputEnable(dObj->i2cbbSCLPin);
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_HIGH_DATA_CHECK;
        }
        break;

      case I2CBB_BUS_STATE_SCL_HIGH_DATA_CHECK:
        if (SYS_PORT_PinRead(dObj->i2cbbSCLPin) == INPUT) {
          if ((${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState == I2CBB_TRANSFER_STATE_READ) &&
            (${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWCounter > 0) &&
            (${I2CBB_INSTANCE_NAME?lower_case}Obj.readSize > 0)) {
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CReadData <<= 1;
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CReadData |= SYS_PORT_PinRead(dObj->i2cbbSDAPin);
          }
          if (${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWCounter == 0) {
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CACKStatus = SYS_PORT_PinRead(dObj->i2cbbSDAPin);
            if ((${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState == I2CBB_TRANSFER_STATE_READ) &&
              (${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWData == 0xFE00)) {
              * ${I2CBB_INSTANCE_NAME?lower_case}Obj.readBuffer++ = ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CReadData;
            }
          }
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_LOW_DATA_CHECK;
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut = ERROR_TIMEOUT_COUNT;
        } else {
          if (!(${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut--)) {
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorStatus = I2CBB_ERROR_BUS;
            dObj->i2cbbTmrPlib->timerStop(); //stop and clear Timer
            dObj->i2cbbTmrPlib->timerPeriodset(0);
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut = ERROR_TIMEOUT_COUNT;
          }
        }
        break;

      case I2CBB_BUS_STATE_SCL_SDA_LOW_STOP:
        SYS_PORT_PinOutputEnable(dObj->i2cbbSCLPin);
        SYS_PORT_PinOutputEnable(dObj->i2cbbSDAPin);
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_SDA_LOW_STOP_CHECK;
        break;
      case I2CBB_BUS_STATE_SCL_SDA_LOW_STOP_CHECK:
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_HIGH_STOP;
        break;
      case I2CBB_BUS_STATE_SCL_HIGH_STOP:
        SYS_PORT_PinInputEnable(dObj->i2cbbSCLPin);
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SCL_HIGH_STOP_CHECK;
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut = ERROR_TIMEOUT_COUNT;
        break;

      case I2CBB_BUS_STATE_SCL_HIGH_STOP_CHECK:
        if (SYS_PORT_PinRead(dObj->i2cbbSCLPin) == INPUT) {
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SDA_HIGH_STOP;
        } else {
          if (!(${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut--)) //decrement error counter
          {
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorStatus = I2CBB_ERROR_BUS;
            dObj->i2cbbTmrPlib->timerStop(); //stop and clear Timer
             dObj->i2cbbTmrPlib->timerPeriodset(0);
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorTimeOut = ERROR_TIMEOUT_COUNT; //reset error counter
          } else {
            SYS_PORT_PinInputEnable(dObj->i2cbbSCLPin);
          }
        }
        break;
      case I2CBB_BUS_STATE_SDA_HIGH_STOP:
        SYS_PORT_PinInputEnable(dObj->i2cbbSDAPin);
        ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_SDA_HIGH_STOP_CHECK;
        break;
      case I2CBB_BUS_STATE_SDA_HIGH_STOP_CHECK:
        if ((${I2CBB_INSTANCE_NAME?lower_case}Obj.writeCount == ${I2CBB_INSTANCE_NAME?lower_case}Obj.writeSize) && (${I2CBB_INSTANCE_NAME?lower_case}Obj.readCount == ${I2CBB_INSTANCE_NAME?lower_case}Obj.readSize)) {
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState = I2CBB_TRANSFER_STATE_DONE;
        }else if(${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CACKStatus != M_ACK)
        {
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorStatus = I2CBB_ERROR_NAK;
            dObj->i2cbbTmrPlib->timerStop(); //stop and clear Timer
            dObj->i2cbbTmrPlib->timerPeriodset(0);
            ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_NULL_STATE;
            if (${I2CBB_INSTANCE_NAME?lower_case}Obj.callback != NULL) {
              ${I2CBB_INSTANCE_NAME?lower_case}Obj.callback(${I2CBB_INSTANCE_NAME?lower_case}Obj.context);
            }
        }



        if ((${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState == I2CBB_TRANSFER_STATE_DONE) || (${I2CBB_INSTANCE_NAME?lower_case}Obj.errorStatus == I2CBB_ERROR_BUS)) {
          dObj->i2cbbTmrPlib->timerStop(); //stop and clear Timer
          dObj->i2cbbTmrPlib->timerPeriodset(0);
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState = I2CBB_BUS_STATE_NULL_STATE;

           if (${I2CBB_INSTANCE_NAME?lower_case}Obj.callback != NULL) {
          ${I2CBB_INSTANCE_NAME?lower_case}Obj.callback(${I2CBB_INSTANCE_NAME?lower_case}Obj.context);
        }
        }
        break;

      default:
        break;
    }

}

static void ${I2CBB_INSTANCE_NAME}_eventHandler(uint32_t status, uintptr_t context)
{
    ${I2CBB_INSTANCE_NAME}_tasks();
}

void ${I2CBB_INSTANCE_NAME}_Initialize(void)
{
    I2C_BB_INIT* dObj =(I2C_BB_INIT*)&i2cBBInitData;

    dObj->i2cbbTmrPlib->timerCallbackRegister(I2C_BB_eventHandler,(uintptr_t)0);
}

bool ${I2CBB_INSTANCE_NAME}_Read(uint16_t address, uint8_t *pdata, size_t length)
{
    // Check for ongoing transfer
    if( ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState != I2CBB_BUS_STATE_NULL_STATE )
    {
        return false;
    }

    ${I2CBB_INSTANCE_NAME?lower_case}Obj.address=address << 1;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.readBuffer=pdata;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.readSize=length;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.writeBuffer=NULL;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.writeSize=0;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState= I2CBB_TRANSFER_STATE_READ;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorStatus = I2CBB_ERROR_NONE;

    ${I2CBB_INSTANCE_NAME}_InitiateTransfer();
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWCounter = 9;

    return true;
}

bool ${I2CBB_INSTANCE_NAME}_Write(uint16_t address, uint8_t *pdata, size_t length)
{
    // Check for ongoing transfer
    if( ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState != I2CBB_BUS_STATE_NULL_STATE )
    {
        return false;
    }

    ${I2CBB_INSTANCE_NAME?lower_case}Obj.address=address << 1;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.readBuffer=NULL;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.readSize=0;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.writeBuffer=pdata;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.writeSize=length;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState= I2CBB_TRANSFER_STATE_WRITE;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorStatus = I2CBB_ERROR_NONE;

    ${I2CBB_INSTANCE_NAME}_InitiateTransfer();
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWCounter = 9;
    return true;
}

bool ${I2CBB_INSTANCE_NAME}_WriteRead(uint16_t address, uint8_t *wdata, size_t wlength, uint8_t *rdata, size_t rlength)
{

    // Check for ongoing transfer
    if( ${I2CBB_INSTANCE_NAME?lower_case}Obj.i2cState != I2CBB_BUS_STATE_NULL_STATE )
    {
        return false;
    }

    ${I2CBB_INSTANCE_NAME?lower_case}Obj.address=address << 1;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.readBuffer=rdata;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.readSize=rlength;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.writeBuffer=wdata;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.writeSize=wlength;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.transferState= I2CBB_TRANSFER_STATE_WRITE_READ;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorStatus = I2CBB_ERROR_NONE;

    ${I2CBB_INSTANCE_NAME}_InitiateTransfer();
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.I2CSWCounter = 9;

    return true;
}

void ${I2CBB_INSTANCE_NAME}_CallbackRegister(I2CBB_CALLBACK callback, uintptr_t contextHandle)
{
    if (callback == NULL)
    {
        return;
    }

    ${I2CBB_INSTANCE_NAME?lower_case}Obj.callback = callback;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.context = contextHandle;
}



I2CBB_ERROR ${I2CBB_INSTANCE_NAME}_ErrorGet(void)
{
    I2CBB_ERROR error;

    error = ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorStatus;
    ${I2CBB_INSTANCE_NAME?lower_case}Obj.errorStatus = I2CBB_ERROR_NONE;

    return error;
}

