/*******************************************************************************
  TEMP SENSOR PLIB

  Company:
    Microchip Technology Inc.

  File Name:
    temp_sensor.c

  Summary:
    This module provides an interface for initializing and reading values from 
    the on-chip temperature sensor, with support for multiple temperature units.

  Description
    The temperature sensor module abstracts the hardware-specific details of the
    microcontroller internal temperature sensor. 
    It offers functions to initialize the sensor, retrieve temperature readings 
    in Celsius, Fahrenheit, or Kelvin, and perform unit conversions. 
    The module defines relevant constants and data types to facilitate easy integration 
    and usage in embedded applications. By using this interface, developers can reliably 
    obtain temperature measurements without dealing directly with low-level ADC 
    configuration or calibration data.

  Remarks:
    None.
*******************************************************************************/

/*
Copyright (C) 2025, Microchip Technology Inc., and its subsidiaries. All rights reserved.

The software and documentation is provided by Microchip and its contributors "as is" and any express,
implied or statutory warranties, including, but not limited to, the implied warranties of merchantability,
fitness for a particular purpose and non-infringement of third party intellectual property rights are
disclaimed to the fullest extent permitted by law. In no event shall Microchip or its contributors be
liable for any direct, indirect, incidental, special,exemplary, or consequential damages (including,
but not limited to, procurement of substitute goods or services; loss of use, data, or profits;
or business interruption) however caused and on any theory of liability, whether in contract, strict liability,
or tort (including negligence or otherwise) arising in any way out of the use of the software and documentation,
even if advised of the possibility of such damage.

Except as expressly permitted hereunder and subject to the applicable license terms for any third-party software
incorporated in the software and any applicable open source software license terms, no license or other rights,
whether express or implied, are granted under any patent or other intellectual property rights of Microchip or any third party.
*/

/* ************************************************************************** */
/* ************************************************************************** */
/* Section: Included Files                                                    */
/* ************************************************************************** */
/* ************************************************************************** */

#include "temp_sensor.h"
#include "definitions.h"

/* ************************************************************************** */
/* ************************************************************************** */
/* Section: File Scope or Global Data                                         */
/* ************************************************************************** */
/* ************************************************************************** */

#define TEMP_SENSOR_PRECISION_WARNING   "Precision of the temperature measurement will be +/- 20°C."

// If OTP read fails, these defaults are used
static int8_t TSCAL_P1 = 27;          // default value
static uint32_t TSCAL_P4 = 639436;    // default value
static uint32_t TSCAL_P6 = 1198021;   // default value

#define ADC_TIMEOUT 1000000UL

/* ************************************************************************** */
/* ************************************************************************** */
// Section: Local Functions                                                   */
/* ************************************************************************** */
/* ************************************************************************** */

/**
 * @brief Initialize the ADC for temperature sensor measurements.
 *
 * This function configures the ADC peripheral for temperature sensor operation,
 * including prescaler, timing, resolution, and enabling the temperature channel.
 */
static void __TEMP_init_ADC(void)
{
    // Software reset
    ADC_REGS->ADC_CR = ADC_CR_SWRST_Msk;

    /* Prescaler and different time settings as per CLOCK section  */
    ADC_REGS->ADC_MR =  ADC_MR_PRESCAL(4U) | ADC_MR_TRACKTIM(7U) | ADC_MR_STARTUP_SUT512 | ADC_MR_TRANSFER(2U) | ADC_MR_ANACH_ALLOWED;

    /* Resolution and Sign mode of result */
    ADC_REGS->ADC_EMR = ADC_EMR_OSR_OSR256 | ADC_EMR_ASTE_Msk | ADC_EMR_SIGNMODE_SE_UNSG_DF_SIGN | ADC_EMR_TAG_Msk  | ADC_EMR_TRACKX_TRACKTIMX4;

    // Disable TEMP thresholds
    ADC_REGS->ADC_TEMPCWR &= ~(ADC_TEMPCWR_TLOWTHRES_Msk | ADC_TEMPCWR_THIGHTHRES_Msk);
    ADC_REGS->ADC_TEMPCWR |= ADC_TEMPCWR_TLOWTHRES(0U) | ADC_TEMPCWR_THIGHTHRES(0U);

    // Enable TEMP measurement
    ADC_REGS->ADC_TEMPMR &= ~(ADC_TEMPMR_TEMPON_Msk | ADC_TEMPMR_TEMPCMPMOD_Msk);
    ADC_REGS->ADC_TEMPMR |= ADC_TEMPMR_TEMPON_Msk | ADC_TEMPMR_TEMPCMPMOD_LOW;

    // Enable TEMP channel
    ADC_REGS->ADC_CHER |= ADC_CHER_CH31_Msk;
}

/**
 * @brief Initialize temperature sensor calibration data from OTP memory.
 *
 * This function reads calibration data from OTP memory and updates the calibration
 * parameters used for temperature calculation. If OTP emulation is enabled or
 * calibration data is not found, a warning is logged and default values are used.
 *
 * @return EXIT_SUCCESS on success, EXIT_FAILURE otherwise.
 */
static uint32_t __TEMP_init_OTP(void)
{
    uint32_t ret = EXIT_FAILURE;

    // Check if OTP Emulation is enabled
    bool emul = OTPC_REGS->OTPC_SR & OTPC_SR_EMUL_1;
    if (emul)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_WARNING, "\r\n/!\\ Temperature sensor calibration data in OTP cannot be accessed because OTP emulation mode is still active.");
        SYS_DEBUG_PRINT(SYS_ERROR_WARNING, "\r\n/!\\ Please refer to DS00004530 Application Note to allow OTP access");
    }
    else
    {
        uint16_t packet_addr = OTP_OFFSET_TEMP_CALIB_DATA;  // address is in DWORD (32 bit word)
        uint32_t readBuffer[18] = {0};
        uint16_t readSize = 0;

        otpc_error_code_t retcode = OTPC_ReadPacket(packet_addr, readBuffer, sizeof(readBuffer), &readSize);

        if (retcode == OTPC_ERROR_PACKET_NOT_FOUND)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_WARNING, "\r\n/!\\ Calibration data for the temperature sensor could not be found in OTP. %s", TEMP_SENSOR_PRECISION_WARNING);
        }
        else if (retcode != OTPC_NO_ERROR)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_WARNING, "\r\n/!\\ Failed to read OTP @0x%X: error code = %u. %s", packet_addr, retcode, TEMP_SENSOR_PRECISION_WARNING);
        }
        else
        {
            // Check TSCAL tag in the packet payload
            if (readBuffer[0] != *(uint32_t*)"TSCA")
            {
                SYS_DEBUG_PRINT(SYS_ERROR_WARNING, "\r\n/!\\ Invalid temperature sensor calibration data: cannot find TSCA tag. %s", TEMP_SENSOR_PRECISION_WARNING);
                // ret remains EXIT_FAILURE
            }
            else
            {
                // Extract the calibration data from OTP payload
                TSCAL_P1 = (int8_t)(readBuffer[1] & 0xFF);
                TSCAL_P4 = readBuffer[4];
                TSCAL_P6 = readBuffer[6];
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nTemperature calibration data: TSCAL_P1=%i, TSCAL_P4=%lu, TSCAL_P6=%lu", TSCAL_P1, TSCAL_P4, TSCAL_P6);
                ret = EXIT_SUCCESS; // Set to success only if everything is OK
            }
        }
    }
    return ret;
}


/**
 * @brief Compute the temperature in Celsius from ADC readings and calibration data.
 *
 * @param v_temp The raw ADC value for the temperature sensor.
 * @param v_bg   The raw ADC value for the bandgap reference.
 * @param p1     Calibration parameter 1 (offset).
 * @param p4     Calibration parameter 4.
 * @param p6     Calibration parameter 6.
 *
 * @return The computed temperature in Celsius.
 */
static float __TEMP_compute( const uint16_t v_temp, const uint16_t v_bg,
                             const int8_t p1, const uint32_t p4, const uint32_t p6 )
{
    double res = (double)v_temp / (double)v_bg * p6;
    res -= p4;
    res /= (double)TEMP_VOLTAGE_SENSITIVITY;
    res += p1;
    return (float)res;
}

/* ************************************************************************** */
/* ************************************************************************** */
// Section: Interface Functions                                               */
/* ************************************************************************** */
/* ************************************************************************** */

/**
 * @brief Initialize the temperature sensor module.
 *
 * This function initializes the ADC and loads calibration data from OTP.
 *
 * @return 0 on success, non-zero on failure.
 */
uint32_t TEMP_Initialize(void)
{
    uint32_t ret = 0;
    __TEMP_init_ADC();
    ret |= __TEMP_init_OTP();
    return ret;
}

/**
 * @brief Convert a temperature from Celsius to Fahrenheit.
 *
 * @param celsius Temperature in Celsius.
 * @return Temperature in Fahrenheit.
 */
float TEMP_Celsius2Fahrenheit( const float celsius )
{
    return celsius * 9.0 / 5.0 + 32;
}

/**
 * @brief Convert a temperature from Celsius to Kelvin.
 *
 * @param celsius Temperature in Celsius.
 * @return Temperature in Kelvin.
 */
float TEMP_Celsius2Kelvin( const float celsius )
{
    return celsius + 273.15;
}

/**
 * @brief Get the current temperature in the specified unit.
 *
 * This function performs ADC conversions to read the temperature sensor and bandgap
 * reference, computes the temperature in Celsius, and converts it to the requested unit.
 *
 * @param unit The temperature unit to return (Celsius, Fahrenheit, or Kelvin).
 * @return The measured temperature in the specified unit.
 */
float TEMP_Get(const enum E_TEMP_UNIT unit)
{
    unsigned long timeout = ADC_TIMEOUT;
    float result;

    // Set VTEMP
    ADC_REGS->ADC_ACR &= ~ADC_ACR_SRCLCH_Msk; 
    ADC_REGS->ADC_ACR |= ADC_ACR_SRCLCH_VTEMP;
    ADC_ConversionStart();
    while (!ADC_ChannelResultIsReady(TEMP_SENSOR_CH_ID) && --timeout);
    if (timeout == 0)
    {
        // Handle timeout error
        SYS_DEBUG_PRINT(SYS_ERROR_WARNING, "\r\n/!\\ ADC is not ready");
        result = -40;
    }
    else
    {
        // ADC is ready, proceed to read the result
        uint16_t v_temp = ADC_ChannelResultGet(TEMP_SENSOR_CH_ID);

        // Get VBG
        ADC_REGS->ADC_ACR &= ~ADC_ACR_SRCLCH_Msk;
        ADC_REGS->ADC_ACR |= ADC_ACR_SRCLCH_VBG;
        ADC_ConversionStart();
        timeout = ADC_TIMEOUT;
        while (!ADC_ChannelResultIsReady(TEMP_SENSOR_CH_ID) && --timeout);
        if (timeout == 0)
        {
            // Handle timeout error
            SYS_DEBUG_PRINT(SYS_ERROR_WARNING, "\r\n/!\\ ADC is not ready");
            result = -40;
        }
        else
        {
            // ADC is ready, proceed to read the result
            uint16_t v_bg = ADC_ChannelResultGet(TEMP_SENSOR_CH_ID);

            float temp_celsius = __TEMP_compute(v_temp, v_bg, TSCAL_P1, TSCAL_P4, TSCAL_P6);
            switch (unit)
            {
                case TEMP_FAHRENHEIT: 
                    result = TEMP_Celsius2Fahrenheit(temp_celsius);
                    break;
                case TEMP_KELVIN: 
                    result = TEMP_Celsius2Kelvin(temp_celsius);
                    break;
                default:
                    // TEMP_CELSIUS
                    result = temp_celsius;
                    break;
            }
        }
    }
    return result;
}


/* *****************************************************************************
 End of File
 */
