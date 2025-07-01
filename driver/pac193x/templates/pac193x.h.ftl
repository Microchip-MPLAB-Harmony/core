/* ************************************************************************** */
/** PAC193x driver

  @Company
    Microchip Technology

  @File Name
    pac193x.h

  @Summary
    Driver to access the PAC193x power management IC on a SAMA7G54-EK board through I2C bus

  @Description
    Provide functions to access the registers of the PAC193x family through the
    I2C bus available on the SAMA7G54-EK board.
 */
/* ************************************************************************** */

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

#ifndef _PAC1934_H    /* Guard against multiple inclusion */
#define _PAC1934_H

#include <stdint.h>
#include <stdbool.h>

/* *****************************************************************************
 * Section: C++ Compatibility
 * ************************************************************************** */
/* Ensure the header can be used in C++ projects */
#ifdef __cplusplus
extern "C"
{
#endif

/* *****************************************************************************
 * Section: Macro Definitions
 * ************************************************************************** */
/* Default I2C address for PAC1934 */
#define PAC1934_I2C_ADDR            0x${i2c_address}

/* Default sense resistor values in milliohms for each channel */
#define PAC_RSENSE_1                ${channel_rsense_1}
#define PAC_RSENSE_2                ${channel_rsense_2} 
#define PAC_RSENSE_3                ${channel_rsense_3} 
#define PAC_RSENSE_4                ${channel_rsense_4}

/* Macro to identify the CPU voltage monitor channel */
#define PAC_VDDCPU_MONITOR_ID       ${cpu_channel}

/* *****************************************************************************
 * Section: Type Definitions
 * ************************************************************************** */

/* Enum: pac_channel_id_t
 * Description: Identifies each channel of the PAC1934 device.
 */
typedef enum
{
    PAC_CHANNEL_1   = 0,    /* Channel 1 */
    PAC_CHANNEL_2   = 1,    /* Channel 2 */
    PAC_CHANNEL_3   = 2,    /* Channel 3 */
    PAC_CHANNEL_4   = 3     /* Channel 4 */
} pac_channel_id_t;

/* Enum: pac_reg_field_id_t
 * Description: Identifies all registers and fields of the PAC1934.
 *              Fields are grouped after their parent register.
 */
typedef enum
{
    // REFRESH COMMAND register
    R_PAC1934_REFRESH                 = 0,

    // CTRL register & fields
    R_PAC1934_CTRL                       ,
        F_PAC1934_CTRL__OVF              ,
        F_PAC1934_CTRL__OVF_ALERT        ,
        F_PAC1934_CTRL__ALERT_CC         ,
        F_PAC1934_CTRL__ALERT_PIN        ,
        F_PAC1934_CTRL__SING             ,
        F_PAC1934_CTRL__SLEEP            ,
        F_PAC1934_CTRL__Sample_Rate      ,

    // ACC_COUNT: 3 registers in a row
    R_PAC1934_ACC_COUNT                  ,

    // VPOWERx_ACC: 6 registers in a row for each channel
    R_PAC1934_VPOWER1_ACC                ,
    R_PAC1934_VPOWER2_ACC                ,
    R_PAC1934_VPOWER3_ACC                ,
    R_PAC1934_VPOWER4_ACC                ,

    // VBUSx: 2 registers in a row for each channel
    R_PAC1934_VBUS1                      ,
    R_PAC1934_VBUS2                      ,
    R_PAC1934_VBUS3                      ,
    R_PAC1934_VBUS4                      ,

    // VSENSEx: 2 registers in a row for each channel
    R_PAC1934_VSENSE1                    ,
    R_PAC1934_VSENSE2                    ,
    R_PAC1934_VSENSE3                    ,
    R_PAC1934_VSENSE4                    ,

    // VBUSx_AVG: 2 registers in a row for each channel
    R_PAC1934_VBUS1_AVG                  ,
    R_PAC1934_VBUS2_AVG                  ,
    R_PAC1934_VBUS3_AVG                  ,
    R_PAC1934_VBUS4_AVG                  ,

    // VSENSEx_AVG: 2 registers in a row for each channel
    R_PAC1934_VSENSE1_AVG                ,
    R_PAC1934_VSENSE2_AVG                ,
    R_PAC1934_VSENSE3_AVG                ,
    R_PAC1934_VSENSE4_AVG                ,

    // VPOWERx: 4 registers in a row for each channel
    R_PAC1934_VPOWER1                    ,
    R_PAC1934_VPOWER2                    ,
    R_PAC1934_VPOWER3                    ,
    R_PAC1934_VPOWER4                    ,

    // CHANNEL_DIS AND SMBUS: register & fields
    R_PAC1934_CH_DIS                     ,
        F_PAC1934_CH_DIS__NO_SKIP        ,
        F_PAC1934_CH_DIS__BYTE_COUNT     ,
        F_PAC1934_CH_DIS__TIMEOUT        ,
        F_PAC1934_CH_DIS__CH4_OFF        ,
        F_PAC1934_CH_DIS__CH3_OFF        ,
        F_PAC1934_CH_DIS__CH2_OFF        ,
        F_PAC1934_CH_DIS__CH1_OFF        ,

    // NEG_PWR register & fields
    R_PAC1934_NEG_PWR                    ,
        F_PAC1934_NEG_PWR__CH4_BIDV      ,
        F_PAC1934_NEG_PWR__CH3_BIDV      ,
        F_PAC1934_NEG_PWR__CH2_BIDV      ,
        F_PAC1934_NEG_PWR__CH1_BIDV      ,
        F_PAC1934_NEG_PWR__CH4_BIDI      ,
        F_PAC1934_NEG_PWR__CH3_BIDI      ,
        F_PAC1934_NEG_PWR__CH2_BIDI      ,
        F_PAC1934_NEG_PWR__CH1_BIDI      ,

    // REFRESH_G register
    R_PAC1934_REFRESH_G                  ,

    // REFRESH_V register
    R_PAC1934_REFRESH_V                  ,

    // SLOW register & fields
    R_PAC1934_SLOW                       ,
        F_PAC1934_SLOW__POR              ,
        F_PAC1934_SLOW__R_V_FALL         ,
        F_PAC1934_SLOW__R_FALL           ,
        F_PAC1934_SLOW__R_V_RISE         ,
        F_PAC1934_SLOW__R_RISE           ,
        F_PAC1934_SLOW__SLOW_HL          ,
        F_PAC1934_SLOW__SLOW_LH          ,
        F_PAC1934_SLOW__SLOW             ,

    // CTRL_ACT register & fields
    R_PAC1934_CTRL_ACT                   ,
        F_PAC1934_CTRL_ACT__OVF          ,
        F_PAC1934_CTRL_ACT__OVF_ALERT    ,
        F_PAC1934_CTRL_ACT__ALERT_CC     ,
        F_PAC1934_CTRL_ACT__ALERT_PIN    ,
        F_PAC1934_CTRL_ACT__SING         ,
        F_PAC1934_CTRL_ACT__SLEEP        ,
        F_PAC1934_CTRL_ACT__Sample_Rate  ,

    // CHANNEL DIS_ACT register & fields
    R_PAC1934_CH_DIS_ACT                 ,
        F_PAC1934_CH_DIS_ACT__CH4_OFF    ,
        F_PAC1934_CH_DIS_ACT__CH3_OFF    ,
        F_PAC1934_CH_DIS_ACT__CH2_OFF    ,
        F_PAC1934_CH_DIS_ACT__CH1_OFF    ,

    // NEG_PWR_ACT register & fields
    R_PAC1934_NEG_PWR_ACT                ,
        F_PAC1934_NEG_PWR_ACT__CH4_BIDV  ,
        F_PAC1934_NEG_PWR_ACT__CH3_BIDV  ,
        F_PAC1934_NEG_PWR_ACT__CH2_BIDV  ,
        F_PAC1934_NEG_PWR_ACT__CH1_BIDV  ,
        F_PAC1934_NEG_PWR_ACT__CH4_BIDI  ,
        F_PAC1934_NEG_PWR_ACT__CH3_BIDI  ,
        F_PAC1934_NEG_PWR_ACT__CH2_BIDI  ,
        F_PAC1934_NEG_PWR_ACT__CH1_BIDI  ,

    // CTRL_LAT register & fields
    R_PAC1934_CTRL_LAT                   ,
        F_PAC1934_CTRL_LAT__OVF          ,
        F_PAC1934_CTRL_LAT__OVF_ALERT    ,
        F_PAC1934_CTRL_LAT__ALERT_CC     ,
        F_PAC1934_CTRL_LAT__ALERT_PIN    ,
        F_PAC1934_CTRL_LAT__SING         ,
        F_PAC1934_CTRL_LAT__SLEEP        ,
        F_PAC1934_CTRL_LAT__Sample_Rate  ,

    // CHANNEL DIS_LAT register & fields
    R_PAC1934_CH_DIS_LAT                 ,
        F_PAC1934_CH_DIS_LAT__CH4_OFF    ,
        F_PAC1934_CH_DIS_LAT__CH3_OFF    ,
        F_PAC1934_CH_DIS_LAT__CH2_OFF    ,
        F_PAC1934_CH_DIS_LAT__CH1_OFF    ,

    // NEG_PWR_LAT register & fields
    R_PAC1934_NEG_PWR_LAT                ,
        F_PAC1934_NEG_PWR_LAT__CH4_BIDV  ,
        F_PAC1934_NEG_PWR_LAT__CH3_BIDV  ,
        F_PAC1934_NEG_PWR_LAT__CH2_BIDV  ,
        F_PAC1934_NEG_PWR_LAT__CH1_BIDV  ,
        F_PAC1934_NEG_PWR_LAT__CH4_BIDI  ,
        F_PAC1934_NEG_PWR_LAT__CH3_BIDI  ,
        F_PAC1934_NEG_PWR_LAT__CH2_BIDI  ,
        F_PAC1934_NEG_PWR_LAT__CH1_BIDI  ,

    // PRODUCT ID register
    R_PAC1934_PID                        ,

    // MANUFACTURER ID register
    R_PAC1934_MID                        ,

    // REVISION ID register
    R_PAC1934_RID

} pac_reg_field_id_t;

/* Struct: pac193x_id_t
 * Description: Holds identification information for the PAC1934 device.
 */
typedef struct
{
    uint8_t product_id;         /* Product ID register value */
    uint8_t manufacturer_id;    /* Manufacturer ID register value */
    uint8_t revision_id;        /* Revision ID register value */
} pac193x_id_t;

/* Struct: pac193x_r_sense_mOhms_t
 * Description: Holds the sense resistor values (in milliohms) for each channel.
 */
typedef struct
{
    uint32_t rsense_1;  /* Sense resistor for channel 1 */
    uint32_t rsense_2;  /* Sense resistor for channel 2 */
    uint32_t rsense_3;  /* Sense resistor for channel 3 */
    uint32_t rsense_4;  /* Sense resistor for channel 4 */
} pac193x_r_sense_mOhms_t;

/* Struct: pac_measure_t
 * Description: Holds a measurement value, which can be either unipolar (unsigned)
 *              or bipolar (signed), depending on the is_bipolar flag.
 */
typedef struct
{
    bool is_bipolar;    /* True if value is bipolar (signed), false if unipolar (unsigned) */
    union
    {
        uint32_t unipolar;  /* Unipolar value */
        int32_t  bipolar;   /* Bipolar value */
    };
} pac_measure_t;


// *****************************************************************************
// *****************************************************************************
// Section: Interface Functions
// *****************************************************************************
// *****************************************************************************

/**
  @Function
    uint32_t PMIC_Open( const uint8_t i2c_device_address )

  @Summary
    Open an I2C communication channel with the Power Measurement Integrated Circuit PAC193X on a board.

  @Description
    Setup up and open the communication with the I2C Driver instance. Affects an address
    to this I2C device.

  @Precondition
    None.

  @Parameters
    @param i2c_device_address Precise the address of the device on the I2C bus.

  @Returns
    List (if feasible) and describe the return values of the function.
    <ul>
      <li>EXIT_FAILURE   Indicates an error occurred
      <li>EXIT_SUCCESS   Indicates an error did not occur
    </ul>

  @Remarks
    First function to be called

  @Example
    @code
    if ( PMIC_Open( 0x10 ) != EXIT_SUCCESS )
    {

    }
 */

uint32_t PAC_Open( const uint8_t i2c_device_address, const pac193x_r_sense_mOhms_t r_sense_values );
uint32_t PAC_Close( void );

uint32_t PAC_GetFieldValue( const pac_reg_field_id_t field_id, uint8_t* const field_value );
uint32_t PAC_SetFieldValue( const pac_reg_field_id_t field_id, const uint8_t field_value );
uint32_t PAC_GetRegisterValue( const pac_reg_field_id_t register_id, uint8_t* const register_buf, const uint8_t register_buf_size );
uint32_t PAC_SetRegisterValue( const pac_reg_field_id_t register_id, const uint8_t* const register_buf, const uint8_t register_buf_size );

uint32_t PAC_GetIDs( pac193x_id_t* const ids );
uint32_t PAC_EnableChannel( const pac_channel_id_t channel_id );
uint32_t PAC_DisableChannel( const pac_channel_id_t channel_id );
uint32_t PAC_SetSampleRate( const uint16_t sample_rate );
uint32_t PAC_GetSampleRate( uint16_t* const sample_rate );
uint32_t PAC_ResetCounters( const bool reset_accumulator );
uint32_t PAC_SetVoltagePolarity( const pac_channel_id_t channel_id, const bool bipolar );
uint32_t PAC_SetCurrentPolarity( const pac_channel_id_t channel_id, const bool bipolar );
uint32_t PAC_SetAllPolarity( const pac_channel_id_t channel_id, const bool bipolar );
uint32_t PAC_GetVoltageMeasure( const pac_channel_id_t channel_id, const bool read_averaged_value, pac_measure_t* const voltage_in_mV );
uint32_t PAC_GetCurrentMeasure( const pac_channel_id_t channel_id, const bool read_averaged_value, pac_measure_t* const current_in_mA );
uint32_t PAC_GetPowerMeasure( const pac_channel_id_t channel_id, pac_measure_t* const power_in_mW );
uint32_t PAC_GetEnergyMeasure( const pac_channel_id_t channel_id, pac_measure_t* const energy );
uint32_t PAC_GetAllMeasures( const pac_channel_id_t channel_id, const bool read_averaged_value, pac_measure_t* const voltage_in_mV,
                            pac_measure_t* const current_in_mA, pac_measure_t* const power_in_mW, pac_measure_t* const energy_mJ );
<#if pac193x_unittest == true>

/* ************************************************************************** */
/* Section: UNIT-TESTING FUNCTIONS                                            */
/* ************************************************************************** */

uint32_t PAC1934_UNITTEST_registers_and_fields_accesses( void );
uint32_t PAC1934_UNITTEST_get_ids( void );
uint32_t PAC1934_UNITTEST_voltage_polarity( void );
uint32_t PAC1934_UNITTEST_get_sense_voltage_in_ms( void );
uint32_t PAC1934_UNITTEST_change_sample_rate( void );
uint32_t PAC1934_UNITTEST_voltage_computation( void );
uint32_t PAC1934_UNITTEST_current_computation( void );
uint32_t PAC1934_UNITTEST_power_computation( void );
uint32_t PAC1934_UNITTEST_power_coherency( void );
</#if>

/* Provide C++ Compatibility */
#ifdef __cplusplus
}
#endif

#endif /* _PAC1934_H */

/* *****************************************************************************
 End of File
 */
