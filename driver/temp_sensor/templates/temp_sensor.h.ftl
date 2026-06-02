/*******************************************************************************
  TEMP SENSOR PLIB

  Company:
    Microchip Technology Inc.

  File Name:
    temp_sensor.h

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

#ifndef _TEMP_SENSOR_H
#define _TEMP_SENSOR_H

#include <stdint.h>

/* Provide C++ Compatibility */
#ifdef __cplusplus
extern "C" {
#endif

/* ************************************************************************** */
/* Section: Constants                                                         */
/* ************************************************************************** */

// SAMA7G5 specific settings
#define SAMA7G5_TEMP_SENSOR_CH_ID           ADC_CH31
#define SAMA7G5_TEMP_VOLTAGE_SENSITIVITY    2080UL
#define SAMA7G5_OTP_OFFSET_TEMP_CALIB_DATA  18

#define OTP_OFFSET_TEMP_CALIB_DATA          SAMA7G5_OTP_OFFSET_TEMP_CALIB_DATA
#define TEMP_SENSOR_CH_ID                   SAMA7G5_TEMP_SENSOR_CH_ID
#define TEMP_VOLTAGE_SENSITIVITY            SAMA7G5_TEMP_VOLTAGE_SENSITIVITY

/* ************************************************************************** */
/* Section: Data Types                                                        */
/* ************************************************************************** */

enum E_TEMP_UNIT
{
    TEMP_CELSIUS,
    TEMP_FAHRENHEIT,
    TEMP_KELVIN
};

/* ************************************************************************** */
/* Section: Interface Functions                                               */
/* ************************************************************************** */

uint32_t TEMP_Initialize(void);
float TEMP_Get(const enum E_TEMP_UNIT unit);
float TEMP_Celsius2Fahrenheit(const float celsius);
float TEMP_Celsius2Kelvin(const float celsius);

/* Provide C++ Compatibility */
#ifdef __cplusplus
}
#endif

#endif /* _TEMP_SENSOR_H */
