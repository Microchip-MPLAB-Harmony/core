/* ************************************************************************** */
/** PAC193x driver

  @Company
    Microchip Technology

  @File Name
    pac193x.c

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

/* ************************************************************************** */
/* ************************************************************************** */
/* Section: Included Files                                                    */
/* ************************************************************************** */
/* ************************************************************************** */

#include <string.h>

#include "pac193x.h"
#include "definitions.h"


/* ************************************************************************** */
/* ************************************************************************** */
/* Section: File Scope or Global Data                                         */
/* ************************************************************************** */
/* ************************************************************************** */

#define PAC1934_DRV_I2C_INDEX   DRV_I2C_INDEX_0

#define PAC_CHANNEL_NUM_MAX     4

#define PAC193X_UNIPOLAR_DENOMINATOR_2POW   16UL
#define PAC193X_BIPOLAR_DENOMINATOR_2POW    15UL
#define PAC193X_FULL_SCALE_VBUS             32.0
#define PAC193X_FULL_SCALE_VBUS_2POW        5
#define PAC193X_FULL_SCALE_VSENSE           100.0

#define PAC193X_VOLTAGE_AVG_ID_OFFSET       ( R_PAC1934_VBUS1_AVG - R_PAC1934_VBUS1 )
#define PAC193X_VOLTAGE_CH_ID_OFFSET        ( R_PAC1934_VBUS2_AVG - R_PAC1934_VBUS1_AVG )

#define CH_BIDV_MASK(ch) (1 << (7 - (ch)))

/**
 * @brief Structure describing a PAC193X register or field.
 */
typedef struct
{
    uint8_t addr;        // Register address
    uint8_t mask;        // Bit mask for the field
    uint8_t size_shift;  // Size in bytes for registers or bit shift for fields
} pac_reg_field_info_t;

/**
 * @brief PAC193X sample rate codes.
 */
enum
{
    PAC_SAMPLE_RATE_1024   = 0,
    PAC_SAMPLE_RATE_256    = 1,
    PAC_SAMPLE_RATE_64     = 2,
    PAC_SAMPLE_RATE_8      = 3
} PAC_SAMPLE_RATE_E;

// Global driver state
static SYS_MODULE_INDEX s_drv_i2c_inst_index = 0;
static DRV_HANDLE s_drv_i2c_handle = DRV_HANDLE_INVALID;
static uint16_t s_i2c_device_base_address = 0;
static uint32_t s_r_sense_values_in_mOhms[PAC_CHANNEL_NUM_MAX] = {0,0,0,0};

// List all the fields information: mask and shift for the corresponding register
static const pac_reg_field_info_t s_reg_field_info[] = {
    // register offset   |    field mask   |    field bit shift
    //----------------------------------------------------------
    // REFRESH COMMAND register
    {  0x00              ,    0xFF         ,    0      },  // Register: R_PAC1934_REFRESH
    // CTRL register
    {  0x01              ,    0xFF         ,    1      },  // Register: R_PAC1934_CTRL
    {  0x01              ,    0x01         ,    0      },  // Field: F_PAC1934_CTRL__OVF
    {  0x01              ,    0x02         ,    1      },  // Field: F_PAC1934_CTRL__OVF_ALERT
    {  0x01              ,    0x04         ,    2      },  // Field: F_PAC1934_CTRL__ALERT_CC
    {  0x01              ,    0x08         ,    3      },  // Field: F_PAC1934_CTRL__ALERT_PIN
    {  0x01              ,    0x10         ,    4      },  // Field: F_PAC1934_CTRL__SING
    {  0x01              ,    0x20         ,    5      },  // Field: F_PAC1934_CTRL__SLEEP
    {  0x01              ,    0xC0         ,    6      },  // Field: F_PAC1934_CTRL__Sample_Rate
    // ACC_COUNT register
    {  0x02              ,    0xFF         ,    3      },  // Register: R_PAC1934_ACC_COUNT
    // VPOWER1_ACC register
    {  0x03              ,    0xFF         ,    6      },  // Register: R_PAC1934_VPOWER1_ACC
    // VPOWER2_ACC register
    {  0x04              ,    0xFF         ,    6      },  // Register: R_PAC1934_VPOWER2_ACC
    // VPOWER3_ACC register
    {  0x05              ,    0xFF         ,    6      },  // Register: R_PAC1934_VPOWER3_ACC
    // VPOWER4_ACC register
    {  0x06              ,    0xFF         ,    6      },  // Register: R_PAC1934_VPOWER4_ACC
    // VBUS1 register
    {  0x07              ,    0xFF         ,    2      },  // Register: R_PAC1934_VBUS1
    // VBUS2 register
    {  0x08              ,    0xFF         ,    2      },  // Register: R_PAC1934_VBUS2
    // VBUS3 register
    {  0x09              ,    0xFF         ,    2      },  // Register: R_PAC1934_VBUS3
    // VBUS4 register
    {  0x0A              ,    0xFF         ,    2      },  // Register: R_PAC1934_VBUS4
    // VSENSE1 register
    {  0x0B              ,    0xFF         ,    2      },  // Register: R_PAC1934_VSENSE1
    // VSENSE2 register
    {  0x0C              ,    0xFF         ,    2      },  // Register: R_PAC1934_VSENSE2
    // VSENSE3 register
    {  0x0D              ,    0xFF         ,    2      },  // Register: R_PAC1934_VSENSE3
    // VSENSE4 register
    {  0x0E              ,    0xFF         ,    2      },  // Register: R_PAC1934_VSENSE4
    // VBUS1_AVG register
    {  0x0F              ,    0xFF         ,    2      },  // Register: R_PAC1934_VBUS1_AVG
    // VBUS2_AVG register
    {  0x10              ,    0xFF         ,    2      },  // Register: R_PAC1934_VBUS2_AVG
    // VBUS3_AVG register
    {  0x11              ,    0xFF         ,    2      },  // Register: R_PAC1934_VBUS3_AVG
    // VBUS4_AVG register
    {  0x12              ,    0xFF         ,    2      },  // Register: R_PAC1934_VBUS4_AVG
    // VSENSE1_AVG register
    {  0x13              ,    0xFF         ,    2      },  // Register: R_PAC1934_VSENSE1_AVG
    // VSENSE2_AVG register
    {  0x14              ,    0xFF         ,    2      },  // Register: R_PAC1934_VSENSE2_AVG
    // VSENSE3_AVG register
    {  0x15              ,    0xFF         ,    2      },  // Register: R_PAC1934_VSENSE3_AVG
    // VSENSE4_AVG register
    {  0x16              ,    0xFF         ,    2      },  // Register: R_PAC1934_VSENSE4_AVG
    // VPOWER1 register
    {  0x17              ,    0xFF         ,    4      },  // Register: R_PAC1934_VPOWER1
    // VPOWER2 register
    {  0x18              ,    0xFF         ,    4      },  // Register: R_PAC1934_VPOWER2
    // VPOWER3 register
    {  0x19              ,    0xFF         ,    4      },  // Register: R_PAC1934_VPOWER3
    // VPOWER4 register
    {  0x1A              ,    0xFF         ,    4      },   // Register: R_PAC1934_VPOWER4
    // CHANNEL_DIS AND SMBUS register
    {  0x1C              ,    0xFF         ,    1      },   // Register: R_PAC1934_CH_DIS
    {  0x1C              ,    0x02         ,    1      },   // Field: F_PAC1934_CH_DIS__NO_SKIP
    {  0x1C              ,    0x04         ,    2      },   // Field: F_PAC1934_CH_DIS__BYTE_COUNT
    {  0x1C              ,    0x08         ,    3      },   // Field: F_PAC1934_CH_DIS__TIMEOUT
    {  0x1C              ,    0x10         ,    4      },   // Field: F_PAC1934_CH_DIS__CH4_OFF
    {  0x1C              ,    0x20         ,    5      },   // Field: F_PAC1934_CH_DIS__CH3_OFF
    {  0x1C              ,    0x40         ,    6      },   // Field: F_PAC1934_CH_DIS__CH2_OFF
    {  0x1C              ,    0x80         ,    7      },   // Field: F_PAC1934_CH_DIS__CH1_OFF
    // NEG_PWR register
    {  0x1D              ,    0xFF         ,    1      },   // Register: R_PAC1934_NEG_PWR
    {  0x1D              ,    0x01         ,    0      },   // Field: F_PAC1934_NEG_PWR__CH4_BIDV
    {  0x1D              ,    0x02         ,    1      },   // Field: F_PAC1934_NEG_PWR__CH3_BIDV
    {  0x1D              ,    0x04         ,    2      },   // Field: F_PAC1934_NEG_PWR__CH2_BIDV
    {  0x1D              ,    0x08         ,    3      },   // Field: F_PAC1934_NEG_PWR__CH1_BIDV
    {  0x1D              ,    0x10         ,    4      },   // Field: F_PAC1934_NEG_PWR__CH4_BIDI
    {  0x1D              ,    0x20         ,    5      },   // Field: F_PAC1934_NEG_PWR__CH3_BIDI
    {  0x1D              ,    0x40         ,    6      },   // Field: F_PAC1934_NEG_PWR__CH2_BIDI
    {  0x1D              ,    0x80         ,    7      },   // Field: F_PAC1934_NEG_PWR__CH1_BIDI
    // REFRESH_G COMMAND register
    {  0x1E              ,    0xFF         ,    0      },   // Register: R_PAC1934_REFRESH_G
    // REFRESH_V COMMAND register
    {  0x1F              ,    0xFF         ,    0      },   // Register: R_PAC1934_REFRESH_V
    // SLOW register
    {  0x20              ,    0xFF         ,    1      },   // Register: R_PAC1934_SLOW
    {  0x20              ,    0x01         ,    0      },   // Field: F_PAC1934_SLOW__POR
    {  0x20              ,    0x02         ,    1      },   // Field: F_PAC1934_SLOW__R_V_FALL
    {  0x20              ,    0x04         ,    2      },   // Field: F_PAC1934_SLOW__R_FALL
    {  0x20              ,    0x08         ,    3      },   // Field: F_PAC1934_SLOW__R_V_RISE
    {  0x20              ,    0x10         ,    4      },   // Field: F_PAC1934_SLOW__R_RISE
    {  0x20              ,    0x20         ,    5      },   // Field: F_PAC1934_SLOW__SLOW_HL
    {  0x20              ,    0x40         ,    6      },   // Field: F_PAC1934_SLOW__SLOW_LH
    {  0x20              ,    0x80         ,    7      },   // Field: F_PAC1934_SLOW__SLOW
    // CTRL_ACT register
    {  0x21              ,    0xFF         ,    1      },   // Register: R_PAC1934_CTRL_ACT
    {  0x21              ,    0x01         ,    0      },   // Field: F_PAC1934_CTRL_ACT__OVF
    {  0x21              ,    0x02         ,    1      },   // Field: F_PAC1934_CTRL_ACT__OVF_ALERT
    {  0x21              ,    0x04         ,    2      },   // Field: F_PAC1934_CTRL_ACT__ALERT_CC
    {  0x21              ,    0x08         ,    3      },   // Field: F_PAC1934_CTRL_ACT__ALERT_PIN
    {  0x21              ,    0x10         ,    4      },   // Field: F_PAC1934_CTRL_ACT__SING
    {  0x21              ,    0x20         ,    5      },   // Field: F_PAC1934_CTRL_ACT__SLEEP
    {  0x21              ,    0xC0         ,    6      },   // Field: F_PAC1934_CTRL_ACT__Sample_Rate
    // CHANNEL_DIS_ACT register
    {  0x22              ,    0xFF         ,    1      },   // Register: R_PAC1934_CH_DIS_ACT
    {  0x22              ,    0x10         ,    4      },   // Field: F_PAC1934_CH_DIS_ACT__CH4_OFF
    {  0x22              ,    0x20         ,    5      },   // Field: F_PAC1934_CH_DIS_ACT__CH3_OFF
    {  0x22              ,    0x40         ,    6      },   // Field: F_PAC1934_CH_DIS_ACT__CH2_OFF
    {  0x22              ,    0x80         ,    7      },   // Field: F_PAC1934_CH_DIS_ACT__CH1_OFF
    // NEG_PWR_ACT register
    {  0x23              ,    0xFF         ,    1      },   // Register: R_PAC1934_NEG_PWR_ACT
    {  0x23              ,    0x01         ,    0      },   // Field: F_PAC1934_NEG_PWR_ACT__CH4_BIDV
    {  0x23              ,    0x02         ,    1      },   // Field: F_PAC1934_NEG_PWR_ACT__CH3_BIDV
    {  0x23              ,    0x04         ,    2      },   // Field: F_PAC1934_NEG_PWR_ACT__CH2_BIDV
    {  0x23              ,    0x08         ,    3      },   // Field: F_PAC1934_NEG_PWR_ACT__CH1_BIDV
    {  0x23              ,    0x10         ,    4      },   // Field: F_PAC1934_NEG_PWR_ACT__CH4_BIDI
    {  0x23              ,    0x20         ,    5      },   // Field: F_PAC1934_NEG_PWR_ACT__CH3_BIDI
    {  0x23              ,    0x40         ,    6      },   // Field: F_PAC1934_NEG_PWR_ACT__CH2_BIDI
    {  0x23              ,    0x80         ,    7      },   // Field: F_PAC1934_NEG_PWR_ACT__CH1_BIDI
    // CTRL_LAT register
    {  0x24              ,    0xFF         ,    1      },   // Register: R_PAC1934_CTRL_LAT
    {  0x24              ,    0x01         ,    0      },   // Field: F_PAC1934_CTRL_LAT__OVF
    {  0x24              ,    0x02         ,    1      },   // Field: F_PAC1934_CTRL_LAT__OVF_ALERT
    {  0x24              ,    0x04         ,    2      },   // Field: F_PAC1934_CTRL_LAT__ALERT_CC
    {  0x24              ,    0x08         ,    3      },   // Field: F_PAC1934_CTRL_LAT__ALERT_PIN
    {  0x24              ,    0x10         ,    4      },   // Field: F_PAC1934_CTRL_LAT__SING
    {  0x24              ,    0x20         ,    5      },   // Field: F_PAC1934_CTRL_LAT__SLEEP
    {  0x24              ,    0xC0         ,    6      },   // Field: F_PAC1934_CTRL_LAT__Sample_Rate
    //  CHANNEL_DIS_LAT register
    {  0x25              ,    0xFF         ,    1      },   // Register: R_PAC1934_CH_DIS_LAT
    {  0x25              ,    0x10         ,    4      },   // Field: F_PAC1934_CH_DIS_LAT__CH4_OFF
    {  0x25              ,    0x20         ,    5      },   // Field: F_PAC1934_CH_DIS_LAT__CH3_OFF
    {  0x25              ,    0x40         ,    6      },   // Field: F_PAC1934_CH_DIS_LAT__CH2_OFF
    {  0x25              ,    0x80         ,    7      },   // Field: F_PAC1934_CH_DIS_LAT__CH1_OFF
    // NEG_PWR_LAT register
    {  0x26              ,    0xFF         ,    1      },   // Register: R_PAC1934_NEG_PWR_LAT
    {  0x26              ,    0x01         ,    0      },   // Field: F_PAC1934_NEG_PWR_LAT__CH4_BIDV
    {  0x26              ,    0x02         ,    1      },   // Field: F_PAC1934_NEG_PWR_LAT__CH3_BIDV
    {  0x26              ,    0x04         ,    2      },   // Field: F_PAC1934_NEG_PWR_LAT__CH2_BIDV
    {  0x26              ,    0x08         ,    3      },   // Field: F_PAC1934_NEG_PWR_LAT__CH1_BIDV
    {  0x26              ,    0x10         ,    4      },   // Field: F_PAC1934_NEG_PWR_LAT__CH4_BIDI
    {  0x26              ,    0x20         ,    5      },   // Field: F_PAC1934_NEG_PWR_LAT__CH3_BIDI
    {  0x26              ,    0x40         ,    6      },   // Field: F_PAC1934_NEG_PWR_LAT__CH2_BIDI
    {  0x26              ,    0x80         ,    7      },   // Field: F_PAC1934_NEG_PWR_LAT__CH1_BIDI
    //  PRODUCT ID register
    {  0xFD              ,    0xFF         ,    1      },   // Register: R_PAC1934_PID
    //  MANUFACTURER ID register
    {  0xFE              ,    0xFF         ,    1      },   // Register: R_PAC1934_MID
    //  REVISION ID register
    {  0xFF              ,    0xFF         ,    1      }    // Register: R_PAC1934_RID
};

/* ************************************************************************** */
/* ************************************************************************** */
// Section: Interface Functions                                               */
/* ************************************************************************** */
/* ************************************************************************** */

/**
 * @brief Open an I2C communication channel with the PAC193X device.
 * @param i2c_instance_index The I2C driver instance index.
 * @param i2c_device_address The I2C address of the PAC193X device.
 * @return EXIT_SUCCESS on success, EXIT_FAILURE on error.
 */
static uint32_t __PAC_OpenI2C(SYS_MODULE_INDEX i2c_instance_index, const uint8_t i2c_device_address)
{
    s_i2c_device_base_address = i2c_device_address;
    s_drv_i2c_inst_index = i2c_instance_index;
    uint32_t ret = EXIT_SUCCESS;

    // Open I2C driver
    s_drv_i2c_handle = DRV_I2C_Open(s_drv_i2c_inst_index, DRV_IO_INTENT_SHARED);
    if (s_drv_i2c_handle == DRV_HANDLE_INVALID)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to open I2C instance index %u", i2c_instance_index);
        ret = EXIT_FAILURE;
    }
    else
    {
        // Setup I2C driver for 400kHz operation
        DRV_I2C_TRANSFER_SETUP setup = { .clockSpeed = 400000 };
        bool setup_ret = DRV_I2C_TransferSetup(s_drv_i2c_handle, &setup);
        if (!setup_ret)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nI2C handle 0x%X failed with error %u",
                      s_drv_i2c_handle, DRV_I2C_ErrorGet(s_drv_i2c_handle));
            ret = EXIT_FAILURE;
        }
    }
    return ret;
}


/**
 * @brief Read data from a PAC193X register over I2C.
 * @param register_offset_to_read Register address to read from.
 * @param read_buffer Buffer to store the read data.
 * @param read_buffer_size Number of bytes to read.
 * @return EXIT_SUCCESS on success, EXIT_FAILURE on error.
 */
static uint32_t __PAC_ReadI2C(const uint8_t register_offset_to_read,
                              uint8_t* const read_buffer,
                              const size_t read_buffer_size)
{
    uint8_t* const write_buffer = (uint8_t * const)&register_offset_to_read;
    uint32_t ret = EXIT_SUCCESS;

    if (!DRV_I2C_WriteReadTransfer(s_drv_i2c_handle, s_i2c_device_base_address,
                                   write_buffer, 1, read_buffer, read_buffer_size))
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read %u bytes @offset=0x%04X of I2C handle 0x%X: error %u",
                  read_buffer_size, register_offset_to_read, s_drv_i2c_handle, DRV_I2C_ErrorGet(s_drv_i2c_handle));
        ret = EXIT_FAILURE;
    }
    else
    {
        SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nSucceeded to read %u bytes @addr=0x%02X-offset=0x%04X of I2C handle 0x%X",
              read_buffer_size, s_i2c_device_base_address, register_offset_to_read, s_drv_i2c_handle);
    }
    return ret;
}


/**
 * @brief Write data to a PAC193X register over I2C.
 * @param register_offset_to_write Register address to write to.
 * @param write_buffer Buffer containing data to write.
 * @param write_buffer_size Number of bytes to write.
 * @return EXIT_SUCCESS on success, EXIT_FAILURE on error.
 */
static uint32_t __PAC_WriteI2C(const uint8_t register_offset_to_write,
                               const uint8_t* const write_buffer,
                               const size_t write_buffer_size)
{
    uint32_t ret = EXIT_FAILURE;
    size_t full_write_buffer_size = write_buffer_size + 1;
    uint8_t* const full_write_buffer = (uint8_t * const)malloc(full_write_buffer_size * sizeof(uint8_t));
    if (!full_write_buffer) {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nMemory allocation failed in __PAC_WriteI2C");
        ret =  EXIT_FAILURE;
    }
    else
    {
        full_write_buffer[0] = register_offset_to_write;
        if (write_buffer_size > 0)
        {
            memcpy(full_write_buffer + 1, write_buffer, write_buffer_size);
        }

        if (!DRV_I2C_WriteTransfer(s_drv_i2c_handle, s_i2c_device_base_address, full_write_buffer, full_write_buffer_size))
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to write %u bytes @offset=0x%04X of I2C handle 0x%X: error %u",
                      write_buffer_size, register_offset_to_write, s_drv_i2c_handle, DRV_I2C_ErrorGet(s_drv_i2c_handle));
        }
        else
        {
            ret = EXIT_SUCCESS;
        }

        free(full_write_buffer);
    }
    return ret;
}


/**
 * @brief Close the I2C communication channel.
 * @return EXIT_SUCCESS on success, EXIT_FAILURE on error.
 */
static uint32_t __PAC_CloseI2C(void)
{
    uint32_t ret = EXIT_SUCCESS;

    if (s_drv_i2c_handle != DRV_HANDLE_INVALID)
    {
        DRV_I2C_ERROR i2c_error_code = DRV_I2C_ErrorGet(s_drv_i2c_handle);
        DRV_I2C_Close(s_drv_i2c_handle);
        s_drv_i2c_handle = 0;
        if (i2c_error_code != DRV_I2C_ERROR_NONE)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nI2C driver reported an error %u", i2c_error_code);
            ret = EXIT_FAILURE;
        }
    }
    return ret;
}


/**
 * @brief Sleep for a specified period in milliseconds.
 * @param period_in_ms Number of milliseconds to sleep.
 */
static void __PAC_sleep(uint32_t period_in_ms)
{
#if defined(PLIB_GENERIC_TIMER_H)
    GENERIC_TIMER_DelayMs(period_in_ms);
#endif
}


/**
 * @brief Checks if the given field ID is valid and retrieves its field info.
 *
 * @param[in]  field_id  The field ID to check.
 * @param[out] reg_info  Pointer to a pac_reg_field_info_t structure to receive the info.
 */
static void __PAC_CheckFieldID(const pac_reg_field_id_t field_id, pac_reg_field_info_t *reg_info)
{
    // Default to invalid
    *reg_info = (pac_reg_field_info_t){0, 0, 0};

    // Check if the field ID is within the supported range
    if (field_id > R_PAC1934_RID)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nID %u is not a supported field", field_id);
    }
    else
    {
        *reg_info = s_reg_field_info[field_id];

        // Check if the mask indicates this is not a valid field
        if (reg_info->mask == 0xFF)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\n%u is not a valid field ID", field_id);
            *reg_info = (pac_reg_field_info_t){0, 0, 0};
        }
    }
}


/**
 * @brief Checks if the given register ID is valid and retrieves its field info.
 *
 * @param[in]  register_id  The register ID to check.
 * @param[out] reg_info     Pointer to a pac_reg_field_info_t structure to receive the info.
 */
static void __PAC_CheckRegisterID(const pac_reg_field_id_t register_id, pac_reg_field_info_t *reg_info)
{
    bool error = false;

    // Check if the register ID is within the supported range
    if (register_id > R_PAC1934_RID)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nID %u is not a supported register", register_id);
        error = true;
    }
    else
    {
        *reg_info = s_reg_field_info[register_id];

        // Check if the mask indicates this is not a valid register
        if (reg_info->mask != 0xFF)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\n%u is not a valid register ID", register_id);
            error = true;
        }
    }

    if (error)
    {
        *reg_info = (pac_reg_field_info_t){0, 0, 0};
    }
    return;
}

/**
 * @brief Checks if the given channel ID is valid.
 *
 * @param channel_id The channel ID to check.
 * @return true if valid, false otherwise.
 */
static bool __PAC_CheckChannelID(pac_channel_id_t channel_id)
{
    bool result = true;

    // Only allow valid channel IDs
    switch (channel_id)
    {
        case PAC_CHANNEL_1:
        case PAC_CHANNEL_2:
        case PAC_CHANNEL_3:
        case PAC_CHANNEL_4:
            // Valid channel, do nothing
            break;
        default:
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nInvalid channel ID %u", channel_id);
            result = false;
            break;
    }
    return result;
}


/**
 * @brief Sends a refresh command to the PAC193X device.
 *        Optionally resets accumulators if requested.
 *
 * @param reset_accumulators If true, reset accumulators; otherwise, just refresh.
 * @return EXIT_SUCCESS on success, EXIT_FAILURE on error.
 */
static uint32_t __PAC_SendRefreshCommand(bool reset_accumulators)
{
    uint8_t reg_value = 0;
    pac_reg_field_id_t reg_id = reset_accumulators ? R_PAC1934_REFRESH : R_PAC1934_REFRESH_V;
    uint32_t ret = EXIT_SUCCESS;

    // Write the refresh command to the device
    if (PAC_SetRegisterValue(reg_id, &reg_value, 0) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Wait for the device to process the refresh
        __PAC_sleep(150);
    }

    return ret;
}


/**
 * @brief Converts a sample rate value to its corresponding PAC193X code.
 *
 * @param sample_rate The sample rate value (e.g., 1024, 256, 64, 8).
 * @return The corresponding code, or (uint8_t)-1 if unsupported.
 */
static uint8_t __PAC_get_code_from_sample_rate(const uint16_t sample_rate)
{
    uint8_t sample_rate_code = 0;

    // Map the sample rate value to the corresponding code
    switch (sample_rate)
    {
        case 1024:
            sample_rate_code = PAC_SAMPLE_RATE_1024;
            break;
        case 256:
            sample_rate_code = PAC_SAMPLE_RATE_256;
            break;
        case 64:
            sample_rate_code = PAC_SAMPLE_RATE_64;
            break;
        case 8:
            sample_rate_code = PAC_SAMPLE_RATE_8;
            break;
        default:
            // Log an error if the sample rate is not supported
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\n%u is not a supported sample rate. Please refer to datasheet to get the supported values.", sample_rate);
            return (uint8_t)-1;
    }
    return sample_rate_code;
}

/**
 * @brief Converts a PAC193X sample rate code to its corresponding sample rate value.
 *
 * @param sample_rate_code The code to convert.
 * @return The sample rate value, or (uint16_t)-1 if unsupported.
 */
static uint16_t __PAC_get_sample_rate_from_code(const uint8_t sample_rate_code)
{
    uint16_t sample_rate = 0;

    // Map the code to the corresponding sample rate value
    switch (sample_rate_code)
    {
        case PAC_SAMPLE_RATE_1024:
            sample_rate = 1024;
            break;
        case PAC_SAMPLE_RATE_256:
            sample_rate = 256;
            break;
        case PAC_SAMPLE_RATE_64:
            sample_rate = 64;
            break;
        case PAC_SAMPLE_RATE_8:
            sample_rate = 8;
            break;
        default:
            // Log an error if the code is not supported
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\n%u is not a supported sample rate code. Please refer to datasheet to get the supported values.", sample_rate_code);
            return (uint16_t)-1;
    }
    return sample_rate;
}


/**
 * @brief Compute the voltage in mV from register value.
 *
 * This function converts a big-endian 2-byte register value to a host-endian 16-bit integer,
 * computes the voltage in mV based on whether the value is bipolar or unipolar, and stores
 * the result in the provided pac_measure_t structure.
 *
 * @param[in]  register_value_to_convert Pointer to register value (big-endian).
 * @param[in]  is_bipolar                True if the value is bipolar, false if unipolar.
 * @param[out] voltage_in_mV             Pointer to structure to store the computed voltage.
 */
static void __PAC_compute_voltage_in_mV(const uint8_t* register_value_to_convert,
                                        const bool is_bipolar,
                                        pac_measure_t* voltage_in_mV)
{
    voltage_in_mV->is_bipolar = is_bipolar;
    double voltage;

    // Convert big-endian 2-byte register value to host-endian uint16_t
    uint16_t register_value = 0;
    register_value += register_value_to_convert[0];
    register_value <<= 8;
    register_value += register_value_to_convert[1];

    // Compute voltage
    if (is_bipolar)
    {
        // "* 1000.0" is to get the result in mV
        voltage = (double)((int16_t)register_value) * PAC193X_FULL_SCALE_VBUS * 1000.0;
        voltage /= 1UL << PAC193X_BIPOLAR_DENOMINATOR_2POW;
        voltage_in_mV->bipolar = (int32_t)voltage;
    }
    else
    {
        voltage = (double)((uint16_t)register_value) * PAC193X_FULL_SCALE_VBUS * 1000.0;
        voltage /= 1UL << PAC193X_UNIPOLAR_DENOMINATOR_2POW;
        voltage_in_mV->unipolar = (uint32_t)voltage;
    }
}


/**
 * @brief Computes the current in mA from PAC193X register values.
 *
 * This function converts a big-endian 2-byte register value to a host-endian 16-bit integer,
 * calculates the full-scale current, and computes the current in mA based on whether the measurement
 * is bipolar or unipolar. The result is stored in the provided pac_measure_t structure.
 *
 * @param[in]  register_value_to_convert Pointer to 2-byte register value (big endian).
 * @param[in]  is_bipolar                True if the measurement is bipolar, false if unipolar.
 * @param[in]  sense_resistor_in_mOhms   Value of the sense resistor in milliohms.
 * @param[out] current_in_mA             Pointer to structure to store the computed current.
 */
static void __PAC_compute_current_in_mA(const uint8_t* register_value_to_convert,
                                        const bool is_bipolar,
                                        const uint32_t sense_resistor_in_mOhms,
                                        pac_measure_t* current_in_mA)
{
    // Set the mode (bipolar/unipolar) in the output structure
    current_in_mA->is_bipolar = is_bipolar;

    // Calculate full-scale current (FSC) in mA
    // PAC193X_FULL_SCALE_VSENSE is a device-specific constant
    double fsc = PAC193X_FULL_SCALE_VSENSE * 1000.0 / (double)sense_resistor_in_mOhms; // Convert r_sense from mOhms to Ohms

    // Convert big-endian 2-byte register value to host-endian uint16_t
    uint16_t register_value = 0;
    register_value += register_value_to_convert[0];
    register_value <<= 8;
    register_value += register_value_to_convert[1];

    // Compute current based on the measurement mode
    if (is_bipolar)
    {
        // Bipolar: signed conversion
        double current = (double)((int16_t)register_value) * fsc;
        current /= 1UL << PAC193X_BIPOLAR_DENOMINATOR_2POW;
        current_in_mA->bipolar = (int32_t)current;
    }
    else
    {
        // Unipolar: unsigned conversion
        double current = (double)register_value * fsc;
        current /= 1UL << PAC193X_UNIPOLAR_DENOMINATOR_2POW;
        current_in_mA->unipolar = (uint32_t)current;
    }
}


/**
 * @brief Computes the power in mW from PAC193X register values.
 *
 * This function converts a big-endian 4-byte register value to a host-endian 32-bit integer,
 * calculates the full-scale power, and computes the power in mW based on whether the measurement
 * is bipolar or unipolar. The result is stored in the provided pac_measure_t structure.
 *
 * @param[in]  register_value_to_convert Pointer to 4-byte register value (big endian).
 * @param[in]  is_bipolar                True if the measurement is bipolar, false if unipolar.
 * @param[in]  sense_resistor_in_mOhms   Value of the sense resistor in milliohms.
 * @param[out] power_in_mW               Pointer to structure to store the computed power.
 */
static void __PAC_compute_power_in_mW(const uint8_t* register_value_to_convert,
                                      const bool is_bipolar,
                                      const uint32_t sense_resistor_in_mOhms,
                                      pac_measure_t* power_in_mW)
{
    // Set the mode (bipolar/unipolar) in the output structure
    power_in_mW->is_bipolar = is_bipolar;

    // Convert big-endian 4-byte register value to host-endian uint32_t
    uint32_t register_value = 0;
    register_value += register_value_to_convert[0];
    register_value <<= 8;
    register_value += register_value_to_convert[1];
    register_value <<= 8;
    register_value += register_value_to_convert[2];
    register_value <<= 8;
    register_value += register_value_to_convert[3];
    // No 4-bit shift to keep signed value for bipolar; compensate later in calculation

    // Calculate full-scale power (FSR) in mW
    // PAC193X_FULL_SCALE_VBUS and PAC193X_FULL_SCALE_VSENSE are device-specific constants
    double power_fsr = PAC193X_FULL_SCALE_VBUS * PAC193X_FULL_SCALE_VSENSE * 1000.0 / (double)sense_resistor_in_mOhms;

    // Compute power based on the measurement mode
    if (is_bipolar)
    {
        // Bipolar: signed conversion, denominator includes extra +1 for VPOWER unipolarity
        double power = (double)((int32_t)register_value) * power_fsr;
        power /= 1ULL << (2 * PAC193X_BIPOLAR_DENOMINATOR_2POW + 1);
        power_in_mW->bipolar = (int32_t)power;
    }
    else
    {
        // Unipolar: unsigned conversion
        double power = (double)register_value * power_fsr;
        power /= 1ULL << (2 * PAC193X_UNIPOLAR_DENOMINATOR_2POW);
        power_in_mW->unipolar = (uint32_t)power;
    }
}


/**
 * @brief Computes the energy in millijoules (mJ) from a 6-byte register value.
 *
 * This function converts a big-endian 6-byte register value to a host-endian 64-bit integer,
 * calculates the full-scale power, and computes the energy in mJ based on whether the measurement
 * is bipolar or unipolar. The result is stored in the provided pac_measure_t structure.
 *
 * @param[in]  register_value_to_convert  Pointer to the 6-byte register value (big-endian).
 * @param[in]  is_bipolar                 True if the measurement is bipolar, false if unipolar.
 * @param[in]  sense_resistor_in_mOhms    Value of the sense resistor in milliohms.
 * @param[in]  sample_rate                Sample rate used for the measurement.
 * @param[out] energy_in_mJ               Pointer to the structure to store the computed energy.
 */
static void __PAC_compute_energy_in_mJ(const uint8_t* register_value_to_convert,
                                       const bool is_bipolar,
                                       const uint32_t sense_resistor_in_mOhms,
                                       const uint16_t sample_rate,
                                       pac_measure_t* energy_in_mJ)
{
    // Set the mode (bipolar/unipolar) in the output structure
    energy_in_mJ->is_bipolar = is_bipolar;

    // Convert big-endian 6-byte register value to host-endian uint64_t
    uint64_t register_value = 0;
    register_value += (uint64_t)register_value_to_convert[0] << 40;
    register_value += (uint64_t)register_value_to_convert[1] << 32;
    register_value += (uint64_t)register_value_to_convert[2] << 24;
    register_value += (uint64_t)register_value_to_convert[3] << 16;
    register_value += (uint64_t)register_value_to_convert[4] << 8;
    register_value += (uint64_t)register_value_to_convert[5];
    register_value <<= 16; // Shift left by 16 bits to align with internal format

    // Calculate full-scale power (FSR) in milliwatts (mW)
    // PAC193X_FULL_SCALE_VBUS and PAC193X_FULL_SCALE_VSENSE are device-specific constants
    double power_fsr = PAC193X_FULL_SCALE_VBUS * PAC193X_FULL_SCALE_VSENSE * 1000.0 / (double)sense_resistor_in_mOhms;

    // Compute energy based on the measurement mode
    if (is_bipolar)
    {
        // Bipolar mode: treat register value as signed, adjust denominator for format
        double energy = (double)((int64_t)register_value) * power_fsr;
        // Denominator includes bit shifts and device-specific scaling
        energy /= 1ULL << (2 * PAC193X_BIPOLAR_DENOMINATOR_2POW + 12 + 1);
        energy /= (double)sample_rate;
        energy_in_mJ->bipolar = (int32_t)energy;
    }
    else
    {
        // Unipolar mode: treat register value as unsigned, adjust denominator for format
        double energy = (double)register_value * power_fsr;
        // Denominator includes bit shifts and device-specific scaling
        energy /= 1ULL << (2 * PAC193X_UNIPOLAR_DENOMINATOR_2POW + 12);
        energy /= (double)sample_rate;
        energy_in_mJ->unipolar = (uint32_t)energy;
    }
}

/**
 * @brief Reads and computes the bus voltage in mV for a given channel.
 *
 * @param channel_id Channel to read.
 * @param read_averaged_value If true, read averaged value; else, read instantaneous.
 * @param voltage_in_mV Output pointer for the computed voltage.
 * @return EXIT_SUCCESS on success, EXIT_FAILURE on error.
 */
static uint32_t __PAC_GetVoltageMeasure(const pac_channel_id_t channel_id, const bool read_averaged_value, pac_measure_t* const voltage_in_mV)
{
    uint32_t ret = EXIT_SUCCESS;

    // Read NEG_PWR register to determine if the bus voltage is unsigned (unipolar) or signed (bipolar)
    uint8_t is_bipolar = 0;
    if (PAC_GetFieldValue(F_PAC1934_NEG_PWR_ACT__CH1_BIDV - channel_id, &is_bipolar) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Read the BUS voltage register
        uint8_t value[2];
        uint8_t value_size = sizeof(value);

        pac_reg_field_id_t reg_id = R_PAC1934_VBUS1 + channel_id * PAC193X_VOLTAGE_CH_ID_OFFSET;
        reg_id += read_averaged_value ? PAC193X_VOLTAGE_AVG_ID_OFFSET : 0;

        if (PAC_GetRegisterValue(reg_id, value, value_size) != EXIT_SUCCESS)
        {
            ret = EXIT_FAILURE;
        }
        else
        {
            // Compute source voltage
            __PAC_compute_voltage_in_mV(value, is_bipolar == 1, voltage_in_mV);
            if (voltage_in_mV->is_bipolar)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nis_bipolar=%u VBUS%u=0x%02X%02X => %lu mV", voltage_in_mV->is_bipolar, channel_id + 1, value[0], value[1], voltage_in_mV->bipolar);
            }
            else
            {
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nis_bipolar=%u VBUS%u=0x%02X%02X => %lu mV", voltage_in_mV->is_bipolar, channel_id + 1, value[0], value[1], voltage_in_mV->unipolar);
            }
        }
    }

    return ret;
}


/**
 * @brief Reads and computes the current in mA for a given channel.
 *
 * @param channel_id Channel to read.
 * @param read_averaged_value If true, read averaged value; else, read instantaneous.
 * @param current_in_mA Output pointer for the computed current.
 * @return EXIT_SUCCESS on success, EXIT_FAILURE on error.
 */
static uint32_t __PAC_GetCurrentMeasure(const pac_channel_id_t channel_id, const bool read_averaged_value, pac_measure_t* const current_in_mA)
{
    uint32_t ret = EXIT_SUCCESS;

    // Read NEG_PWR register to determine if the bus voltage is unsigned (unipolar) or signed (bipolar)
    uint8_t is_bipolar = 0;
    if (PAC_GetFieldValue(F_PAC1934_NEG_PWR_ACT__CH1_BIDI - channel_id, &is_bipolar) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Read the SENSE voltage register
        uint8_t value[2];
        uint8_t value_size = sizeof(value);

        pac_reg_field_id_t reg_id = R_PAC1934_VSENSE1 + channel_id * PAC193X_VOLTAGE_CH_ID_OFFSET;
        reg_id += read_averaged_value ? PAC193X_VOLTAGE_AVG_ID_OFFSET : 0;

        if (PAC_GetRegisterValue(reg_id, value, value_size) != EXIT_SUCCESS)
        {
            ret = EXIT_FAILURE;
        }
        else
        {
            // Compute current
            __PAC_compute_current_in_mA(value, is_bipolar == 1, s_r_sense_values_in_mOhms[channel_id], current_in_mA);
            if (current_in_mA->is_bipolar)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nis_bipolar=%u VSENSE%u=0x%02X%02X => %lu mA", current_in_mA->is_bipolar, channel_id + 1, value[0], value[1], current_in_mA->bipolar);
            }
            else
            {
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nis_bipolar=%u VSENSE%u=0x%02X%02X => %lu mA", current_in_mA->is_bipolar, channel_id + 1, value[0], value[1], current_in_mA->unipolar);
            }
        }
    }

    return ret;
}

/**
 * @brief Reads and computes the power in mW for a given channel.
 *
 * @param channel_id Channel to read.
 * @param power_in_mW Output pointer for the computed power.
 * @return EXIT_SUCCESS on success, EXIT_FAILURE on error.
 */
static uint32_t __PAC_GetPowerMeasure(const pac_channel_id_t channel_id, pac_measure_t* const power_in_mW)
{
    uint32_t ret = EXIT_SUCCESS;

    // Read NEG_PWR register to determine if the bus voltage is unsigned (unipolar) or signed (bipolar)
    uint8_t neg_pwr_value = 0;
    if (PAC_GetRegisterValue(R_PAC1934_NEG_PWR_ACT, &neg_pwr_value, 1) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        bool is_bipolar = (neg_pwr_value & CH_BIDV_MASK(channel_id)) ? true : false;

        // Read the VPOWER register
        uint8_t value[4];
        uint8_t value_size = sizeof(value);

        pac_reg_field_id_t reg_id = R_PAC1934_VPOWER1 + channel_id * PAC193X_VOLTAGE_CH_ID_OFFSET;

        if (PAC_GetRegisterValue(reg_id, value, value_size) != EXIT_SUCCESS)
        {
            ret = EXIT_FAILURE;
        }
        else
        {
            // Compute power
            __PAC_compute_power_in_mW(value, is_bipolar, s_r_sense_values_in_mOhms[channel_id], power_in_mW);
            if (power_in_mW->is_bipolar)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nis_bipolar=%u VPOWER%u=0x%02X%02X%02X%02X => %li mW", power_in_mW->is_bipolar, channel_id + 1, value[0], value[1], value[2], value[3], power_in_mW->bipolar);
            }
            else
            {
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nis_bipolar=%u VPOWER%u=0x%02X%02X%02X%02X => %lu mW", power_in_mW->is_bipolar, channel_id + 1, value[0], value[1], value[2], value[3], power_in_mW->unipolar);
            }
        }
    }

    return ret;
}

/**
 * @brief Reads and computes the energy in mJ for a given channel.
 *
 * @param channel_id Channel to read.
 * @param energy_in_mJ Output pointer for the computed energy.
 * @return EXIT_SUCCESS on success, EXIT_FAILURE on error.
 */
static uint32_t __PAC_GetEnergyMeasure(const pac_channel_id_t channel_id, pac_measure_t* const energy_in_mJ)
{
    uint32_t ret = EXIT_SUCCESS;

    // Read NEG_PWR register to determine if the bus voltage is unsigned (unipolar) or signed (bipolar)
    uint8_t neg_pwr_value = 0;
    if (PAC_GetRegisterValue(R_PAC1934_NEG_PWR_ACT, &neg_pwr_value, 1) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        bool is_bipolar = ((0x88 >> channel_id) & neg_pwr_value) ? true : false;

        // Read the sample rate from CTRL_ACT register
        uint8_t sample_rate_code = 0;
        if (PAC_GetFieldValue(F_PAC1934_CTRL_ACT__Sample_Rate, &sample_rate_code) != EXIT_SUCCESS)
        {
            ret = EXIT_FAILURE;
        }
        else
        {
            uint16_t sample_rate = 0;
            switch (sample_rate_code)
            {
                case PAC_SAMPLE_RATE_1024:
                    sample_rate = 1024;
                    break;
                case PAC_SAMPLE_RATE_256:
                    sample_rate = 256;
                    break;
                case PAC_SAMPLE_RATE_64:
                    sample_rate = 64;
                    break;
                case PAC_SAMPLE_RATE_8:
                    sample_rate = 8;
                    break;
                default:
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nInvalid sample rate code %d read from CTRL_ACT register", sample_rate_code);
                    ret = EXIT_FAILURE;
                    break;
            }
            if (ret == EXIT_SUCCESS)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nCurrent sample rate code from CTRL_ACT is 0x%X meaning %u samples per second", sample_rate_code, sample_rate);

                // Read the VACCUM (=VPOWER_AVG) register
                uint8_t value[6];
                uint8_t value_size = sizeof(value);

                if (PAC_GetRegisterValue(R_PAC1934_VPOWER1_ACC + channel_id * PAC193X_VOLTAGE_CH_ID_OFFSET, value, value_size) != EXIT_SUCCESS)
                {
                    ret = EXIT_FAILURE;
                }
                else
                {
                    // Compute energy
                    __PAC_compute_energy_in_mJ(value, is_bipolar, s_r_sense_values_in_mOhms[channel_id], sample_rate, energy_in_mJ);
                    if (energy_in_mJ->is_bipolar)
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nis_bipolar=%u VPOWER%u_ACC=0x%02X%02X%02X%02X => %li mJ", energy_in_mJ->is_bipolar, channel_id + 1, value[0], value[1], value[2], value[3], energy_in_mJ->bipolar);
                    }
                    else
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nis_bipolar=%u VPOWER%u_ACC=0x%02X%02X%02X%02X => %lu mJ", energy_in_mJ->is_bipolar, channel_id + 1, value[0], value[1], value[2], value[3], energy_in_mJ->unipolar);
                    }
                }
            }
        }
    }

    return ret;
}

/**
 * @brief Initializes the PAC193X driver and stores sense resistor values.
 *
 * @param i2c_device_address I2C address of the PAC193X device.
 * @param rsense_values Structure containing sense resistor values for each channel.
 * @return EXIT_SUCCESS on success, error code otherwise.
 */
uint32_t PAC_Open(const uint8_t i2c_device_address, const pac193x_r_sense_mOhms_t rsense_values)
{
    // Save R sense values into local array
    s_r_sense_values_in_mOhms[0] = rsense_values.rsense_1;
    s_r_sense_values_in_mOhms[1] = rsense_values.rsense_2;
    s_r_sense_values_in_mOhms[2] = rsense_values.rsense_3;
    s_r_sense_values_in_mOhms[3] = rsense_values.rsense_4;
    for (uint8_t i = 0; i < 4; i++)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nRsense%u = %u mOhms", i, s_r_sense_values_in_mOhms[i]);
    }

    // Open I2C driver communication
    return __PAC_OpenI2C(PAC1934_DRV_I2C_INDEX, i2c_device_address);
}

/**
 * @brief Closes the PAC193X driver and releases resources.
 *
 * @return EXIT_SUCCESS on success, error code otherwise.
 */
uint32_t PAC_Close()
{
    return __PAC_CloseI2C();
}


// Reads a specific field value from a PAC register.
// field_id: The field identifier.
// field_value: Pointer to store the read value.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_GetFieldValue(const pac_reg_field_id_t field_id, uint8_t* const field_value)
{
    uint32_t ret = EXIT_SUCCESS;

    // Get field info (address, mask, shift) for the given field ID.
    pac_reg_field_info_t field_info;
    __PAC_CheckFieldID(field_id, &field_info);

    if (field_info.mask == 0)
    {
        // Invalid field ID.
        ret = EXIT_FAILURE;
    }
    else
    {
        uint8_t reg_value;
        // Read the register value over I2C.
        if (__PAC_ReadI2C(field_info.addr, &reg_value, sizeof(uint8_t)) != EXIT_SUCCESS)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read PAC193X field @0x%02X", field_info.addr);
            ret = EXIT_FAILURE;
        }
        else
        {
            // Mask and shift to extract the field value.
            *field_value = reg_value & field_info.mask;
            *field_value >>= field_info.size_shift;

            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nRead PAC193X field @0x%02X (mask = 0x%02X, shift = %u): reg=0x%02X => field=0x%X",
                  field_info.addr, field_info.mask, field_info.size_shift, reg_value, *field_value);
        }
    }

    return ret;
}

// Writes a specific field value to a PAC register.
// field_id: The field identifier.
// field_value: The value to write.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_SetFieldValue(const pac_reg_field_id_t field_id, const uint8_t field_value)
{
    uint32_t ret = EXIT_SUCCESS;

    // Get field info (address, mask, shift) for the given field ID.
    pac_reg_field_info_t field_info;
    __PAC_CheckFieldID(field_id, &field_info);

    if (field_info.mask == 0)
    {
        // Invalid field ID.
        ret = EXIT_FAILURE;
    }
    else
    {
        uint8_t old_value = 0;
        // Prepare the new value by shifting into position.
        uint8_t new_value = field_value << field_info.size_shift;

        // Check if the value fits in the field.
        if (new_value & ~field_info.mask)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nValue to write 0x%02X is out of range 0x%02X", field_value, field_info.mask >> field_info.size_shift);
            ret = EXIT_FAILURE;
        }
        else
        {
            // Read the current register value.
            if (__PAC_ReadI2C(field_info.addr, &old_value, sizeof(uint8_t)) != EXIT_SUCCESS)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read PAC193X @0x%02X", field_info.addr);
                ret = EXIT_FAILURE;
            }
            else
            {
                // Merge the new field value with the unchanged bits.
                new_value |= old_value & ~field_info.mask;

                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nWrite PAC193X @0x%02X (mask = 0x%02X, shift = %u): old reg=0x%02X => new reg=0x%02X",
                          field_info.addr, field_info.mask, field_info.size_shift, old_value, new_value);

                // Write the new register value over I2C.
                if (__PAC_WriteI2C(field_info.addr, &new_value, sizeof(uint8_t)) != EXIT_SUCCESS)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to write 0x%02X on PAC193X @0x%02X", new_value, field_info.addr);
                    ret = EXIT_FAILURE;
                }
            }
        }
    }
    return ret;
}

// Reads a full register value from the PAC device.
// register_id: The register identifier.
// register_buf: Buffer to store the register value.
// register_buf_size: Size of the buffer.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_GetRegisterValue(const pac_reg_field_id_t register_id,
                             uint8_t* const register_buf,
                             const uint8_t register_buf_size)
{
    uint32_t ret = EXIT_SUCCESS;
    pac_reg_field_info_t register_info;

    __PAC_CheckRegisterID(register_id, &register_info);

    // Check if the buffer is large enough.
    if (register_buf_size < register_info.size_shift)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nSize of the input buffer is not large enough: provide %u but expect %u",
                  register_buf_size, register_info.size_shift);
        ret = EXIT_FAILURE;
    }
    else
    {
        // Read the register value over I2C.
        if (__PAC_ReadI2C(register_info.addr, register_buf, register_info.size_shift) != EXIT_SUCCESS)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read PAC193X register @0x%02X", register_info.addr);
            ret = EXIT_FAILURE;
        }
        else
        {
            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nRead PAC193X register @0x%02X (mask = 0x%02X, size = %u)",
                  register_info.addr, register_info.mask, register_info.size_shift);
        }
    }

    return ret;
}


// Writes a full register value to the PAC device.
// register_id: The register identifier.
// register_buf: Buffer containing the value to write.
// register_buf_size: Size of the buffer.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_SetRegisterValue(const pac_reg_field_id_t register_id,
                             const uint8_t* const register_buf,
                             const uint8_t register_buf_size)
{
    uint32_t ret = EXIT_SUCCESS;
    pac_reg_field_info_t register_info;

    __PAC_CheckRegisterID(register_id, &register_info);

    // Check if the buffer size matches the register size.
    if (register_buf_size != register_info.size_shift)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nSize of the input buffer is invalid: provide %u but expect %u",
                  register_buf_size, register_info.size_shift);
        ret = EXIT_FAILURE;
    }
    else
    {
        // Write the register value over I2C.
        if (__PAC_WriteI2C(register_info.addr, register_buf, register_info.size_shift) != EXIT_SUCCESS)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to write %u bytes on PAC193X @0x%02X",
                      register_info.size_shift, register_info.addr);
            ret = EXIT_FAILURE;
        }
    }
    return ret;
}


// Reads the product, manufacturer, and revision IDs from the PAC device.
// ids: Pointer to a struct to store the IDs.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_GetIDs(pac193x_id_t* const ids)
{
    uint32_t ret = EXIT_SUCCESS;

    if (ids == NULL)
    {
        SYS_DEBUG_MESSAGE(SYS_ERROR_ERROR, "\r\nInput parameter must not be NULL");
        ret = EXIT_FAILURE;
    }
    else if (PAC_GetRegisterValue(R_PAC1934_PID, &ids->product_id, sizeof(uint8_t)) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else if (PAC_GetRegisterValue(R_PAC1934_MID, &ids->manufacturer_id, sizeof(uint8_t)) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else if (PAC_GetRegisterValue(R_PAC1934_RID, &ids->revision_id, sizeof(uint8_t)) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }

    return ret;
}


// Enables a specific channel on the PAC device.
// channel_id: The channel to enable.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_EnableChannel(const pac_channel_id_t channel_id)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PAC_CheckChannelID(channel_id))
    {
        ret = EXIT_FAILURE;
    }
    else if (PAC_SetFieldValue(F_PAC1934_CH_DIS__CH1_OFF - channel_id, 0) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Send refresh command to apply the change.
        ret = __PAC_SendRefreshCommand(false);
    }

    return ret;
}

// Disables a specific channel on the PAC device.
// channel_id: The channel to disable.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_DisableChannel(const pac_channel_id_t channel_id)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PAC_CheckChannelID(channel_id))
    {
        ret = EXIT_FAILURE;
    }
    else if (PAC_SetFieldValue(F_PAC1934_CH_DIS__CH1_OFF - channel_id, 1) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Send refresh command to apply the change.
        ret = __PAC_SendRefreshCommand(false);
    }

    return ret;
}

// Resets the measurement counters (optionally the accumulator).
// reset_accumulator: If true, also resets the accumulator.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_ResetCounters(const bool reset_accumulator)
{
    return __PAC_SendRefreshCommand(reset_accumulator);
}

// Sets the voltage polarity (bipolar/unipolar) for a channel.
// channel_id: The channel to configure.
// bipolar: true for bipolar, false for unipolar.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_SetVoltagePolarity(const pac_channel_id_t channel_id, const bool bipolar)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PAC_CheckChannelID(channel_id))
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        uint8_t polarity = bipolar ? 1 : 0;

        if (PAC_SetFieldValue(F_PAC1934_NEG_PWR__CH1_BIDV - channel_id, polarity) != EXIT_SUCCESS)
        {
            ret = EXIT_FAILURE;
        }
        else
        {
            // Send refresh command to apply the change.
            ret = __PAC_SendRefreshCommand(true);
        }
    }

    return ret;
}

// Sets the current polarity (bipolar/unipolar) for a channel.
// channel_id: The channel to configure.
// bipolar: true for bipolar, false for unipolar.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_SetCurrentPolarity(const pac_channel_id_t channel_id, const bool bipolar)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PAC_CheckChannelID(channel_id))
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        uint8_t polarity = bipolar ? 1 : 0;

        if (PAC_SetFieldValue(F_PAC1934_NEG_PWR__CH1_BIDI - channel_id, polarity) != EXIT_SUCCESS)
        {
            ret = EXIT_FAILURE;
        }
        else
        {
            // Send refresh command to apply the change.
            ret = __PAC_SendRefreshCommand(true);
        }
    }

    return ret;
}

// Sets both voltage and current polarity for a channel.
// channel_id: The channel to configure.
// bipolar: true for bipolar, false for unipolar.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_SetAllPolarity(const pac_channel_id_t channel_id, const bool bipolar)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PAC_CheckChannelID(channel_id))
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        uint8_t polarity = bipolar ? 1 : 0;

        if (PAC_SetFieldValue(F_PAC1934_NEG_PWR__CH1_BIDV - channel_id, polarity) != EXIT_SUCCESS)
        {
            ret = EXIT_FAILURE;
        }
        else if (PAC_SetFieldValue(F_PAC1934_NEG_PWR__CH1_BIDI - channel_id, polarity) != EXIT_SUCCESS)
        {
            ret = EXIT_FAILURE;
        }
        else
        {
            // Send refresh command to apply the change.
            ret = __PAC_SendRefreshCommand(true);
        }
    }

    return ret;
}


// Sets the ADC sample rate for the PAC device.
// sample_rate: The desired sample rate.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_SetSampleRate(const uint16_t sample_rate)
{
    uint32_t ret = EXIT_SUCCESS;

    // Convert the sample rate to the corresponding code.
    uint8_t sample_rate_code = __PAC_get_code_from_sample_rate(sample_rate);
    if (sample_rate_code == (uint8_t)-1)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\n%u is not a valid sample rate. Please refer to datasheet to get the possible sample rate values.", sample_rate);
        ret = EXIT_FAILURE;
    }
    else if (PAC_SetFieldValue(F_PAC1934_CTRL__Sample_Rate, sample_rate_code) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Send refresh command to apply the change.
        ret = __PAC_SendRefreshCommand(false);
    }

    return ret;
}

// Gets the current ADC sample rate from the PAC device.
// sample_rate: Pointer to store the sample rate.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_GetSampleRate(uint16_t* const sample_rate)
{
    uint32_t ret = EXIT_SUCCESS;
    uint8_t sample_rate_code;

    if (PAC_GetFieldValue(F_PAC1934_CTRL_ACT__Sample_Rate, &sample_rate_code) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        *sample_rate = __PAC_get_sample_rate_from_code(sample_rate_code);
        if (*sample_rate == (uint16_t)-1)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\n%u is not a valid sample rate. Please refer to datasheet to get the possible sample rate values.", *sample_rate);
            ret = EXIT_FAILURE;
        }
    }
    return ret;
}

// Reads the voltage measurement for a channel.
// channel_id: The channel to read.
// read_averaged_value: true to read averaged value, false for instantaneous.
// voltage_in_mV: Pointer to store the voltage in mV.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_GetVoltageMeasure(const pac_channel_id_t channel_id, const bool read_averaged_value, pac_measure_t* const voltage_in_mV)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PAC_CheckChannelID(channel_id))
    {
        ret = EXIT_FAILURE;
    }
    else if (__PAC_SendRefreshCommand(false) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Get the voltage measurement.
        ret = __PAC_GetVoltageMeasure(channel_id, read_averaged_value, voltage_in_mV);
    }

    return ret;
}

// Reads the current measurement for a channel.
// channel_id: The channel to read.
// read_averaged_value: true to read averaged value, false for instantaneous.
// current_in_mA: Pointer to store the current in mA.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_GetCurrentMeasure(const pac_channel_id_t channel_id, const bool read_averaged_value, pac_measure_t* const current_in_mA)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PAC_CheckChannelID(channel_id))
    {
        ret = EXIT_FAILURE;
    }
    else if (__PAC_SendRefreshCommand(false) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Get the current measurement.
        ret = __PAC_GetCurrentMeasure(channel_id, read_averaged_value, current_in_mA);
    }

    return ret;
}


// Reads the power measurement for a channel.
// channel_id: The channel to read.
// power_in_mW: Pointer to store the power in mW.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_GetPowerMeasure(const pac_channel_id_t channel_id, pac_measure_t* const power_in_mW)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PAC_CheckChannelID(channel_id))
    {
        ret = EXIT_FAILURE;
    }
    else if (__PAC_SendRefreshCommand(false) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Get the power measurement.
        ret = __PAC_GetPowerMeasure(channel_id, power_in_mW);
    }

    return ret;
}


// Reads the energy measurement for a channel.
// channel_id: The channel to read.
// energy_in_mJ: Pointer to store the energy in mJ.
// Returns EXIT_SUCCESS or EXIT_FAILURE.
uint32_t PAC_GetEnergyMeasure(const pac_channel_id_t channel_id, pac_measure_t* const energy_in_mJ)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PAC_CheckChannelID(channel_id))
    {
        ret = EXIT_FAILURE;
    }
    else if (__PAC_SendRefreshCommand(false) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Get the energy measurement.
        ret = __PAC_GetEnergyMeasure(channel_id, energy_in_mJ);
    }

    return ret;
}

// Reads all measurements (voltage, current, power, energy) for a channel.
// channel_id: The channel to read.
// read_averaged_value: true to read averaged values, false for instantaneous.
// voltage_in_mV, current_in_mA, power_in_mW, energy_mJ: Pointers to store results (can be NULL).
// Returns a bitwise OR of all called function results (EXIT_SUCCESS/EXIT_FAILURE).
uint32_t PAC_GetAllMeasures(const pac_channel_id_t channel_id, const bool read_averaged_value,
                           pac_measure_t* const voltage_in_mV, pac_measure_t* const current_in_mA,
                           pac_measure_t* const power_in_mW, pac_measure_t* const energy_mJ)
{
    uint32_t ret = EXIT_SUCCESS;

    if (!__PAC_CheckChannelID(channel_id))
    {
        ret = EXIT_FAILURE;
    }
    else if (__PAC_SendRefreshCommand(false) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Read each measurement if the pointer is not NULL.
        if (voltage_in_mV != NULL)
        {
            ret |= __PAC_GetVoltageMeasure(channel_id, read_averaged_value, voltage_in_mV);
        }
        if (current_in_mA != NULL)
        {
            ret |= __PAC_GetCurrentMeasure(channel_id, read_averaged_value, current_in_mA);
        }
        if (power_in_mW != NULL)
        {
            ret |= __PAC_GetPowerMeasure(channel_id, power_in_mW);
        }
        if (energy_mJ != NULL)
        {
            ret |= __PAC_GetEnergyMeasure(channel_id, energy_mJ);
        }
    }
    return ret;
}

<#if pac193x_unittest == true>
/* ************************************************************************** */
/* ************************************************************************** */
/* UNIT-TESTING SECTION                                                       */
/* ************************************************************************** */
/* ************************************************************************** */

#define PAC193X_DEFAULT_PRODUCT_ID          0x5B
#define PAC193X_DEFAULT_MANUFACTURER_ID     0x5D
#define PAC193X_DEFAULT_REVISION_ID         0x03

// Structure to hold expected register values and computed measurement values for tests
typedef struct
{
    uint8_t reg_value[4];
    pac_measure_t compute_value;
} pac_expected_data_t;

// Test register and field access functions for all valid/invalid IDs
uint32_t PAC1934_UNITTEST_registers_and_fields_accesses()
{
    uint8_t buf[6];
    uint32_t ret = EXIT_SUCCESS;

    // Iterate over all register/field IDs
    for (pac_reg_field_id_t id = R_PAC1934_REFRESH; id <= R_PAC1934_RID; id++)
    {
        pac_reg_field_info_t info = s_reg_field_info[id];

        // Skip refresh commands (not readable)
        switch (id)
        {
            case R_PAC1934_REFRESH:
            case R_PAC1934_REFRESH_V:
            case R_PAC1934_REFRESH_G:
                continue;
            default: break;
        }

        // Test PAC_GetRegisterValue for each ID
        memset(buf, 0, sizeof(buf));
        uint32_t get_reg_ret = PAC_GetRegisterValue(id, buf, sizeof(buf));
        if (info.mask != 0xFF)
        {
            // Should fail for invalid registers
            if (get_reg_ret != EXIT_FAILURE)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nID=%u has not been detected as an invalid register", id);
                ret = EXIT_FAILURE;
                break;
            }
        }
        else if (get_reg_ret != EXIT_SUCCESS)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read register ID=%u", id);
            ret = EXIT_FAILURE;
            break;
        }

        // Test PAC_GetFieldValue for each ID
        buf[0] = 0;
        uint32_t get_field_ret = PAC_GetFieldValue(id, buf);
        if (info.mask == 0xFF)
        {
            // Should fail for invalid fields
            if (get_field_ret != EXIT_FAILURE)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nID=%u has not been detected as an invalid field", id);
                ret = EXIT_FAILURE;
                break;
            }
        }
        else if (get_field_ret != EXIT_SUCCESS)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read field ID=%u", id);
            ret = EXIT_FAILURE;
            break;
        }
    }
    return ret;
}

// Test reading device IDs and compare with expected defaults
uint32_t PAC1934_UNITTEST_get_ids()
{
    pac193x_id_t ids = {0, 0, 0};
    uint32_t ret = EXIT_SUCCESS;

    // Read all IDs from the device
    if (PAC_GetIDs(&ids) != EXIT_SUCCESS)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nPAC_GetIDs returned an error");
        ret = EXIT_FAILURE;
    }
    else if (ids.product_id != PAC193X_DEFAULT_PRODUCT_ID)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nInvalid Product ID: got 0x%02X but expect 0x%02X", ids.product_id, PAC193X_DEFAULT_PRODUCT_ID);
        ret = EXIT_FAILURE;
    }
    else if (ids.manufacturer_id != PAC193X_DEFAULT_MANUFACTURER_ID)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nInvalid Manufacturer ID: got 0x%02X but expect 0x%02X", ids.manufacturer_id, PAC193X_DEFAULT_MANUFACTURER_ID);
        ret = EXIT_FAILURE;
    }
    else if (ids.revision_id != PAC193X_DEFAULT_REVISION_ID)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nInvalid Revision ID: got 0x%02X but expect 0x%02X", ids.revision_id, PAC193X_DEFAULT_REVISION_ID);
        ret = EXIT_FAILURE;
    }
    return ret;
}

// Test setting and reading voltage/current polarity for all channels and both polarities
uint32_t PAC1934_UNITTEST_voltage_polarity()
{
    uint32_t ret_func = EXIT_SUCCESS;
    bool ch_check = false;
    uint8_t orig_reg_value, new_reg_val, field_value;
    pac_reg_field_info_t info;
    bool error = false;

    // Test both unipolar and bipolar settings
    for (int i = 0; i <= 1 && !error; i++)
    {
        bool bipolar = i == 0;
        for (pac_channel_id_t ch = PAC_CHANNEL_1; ch <= PAC_CHANNEL_4 && !error; ch++)
        {
            ch_check = __PAC_CheckChannelID(ch);

            // Save original register value for later comparison
            if (PAC_GetRegisterValue(R_PAC1934_NEG_PWR_ACT, &orig_reg_value, 1) != EXIT_SUCCESS)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor BUS, PAC_GetRegisterValue failed on register ID = %u", R_PAC1934_NEG_PWR_ACT);
                ret_func = EXIT_FAILURE;
                error = true;
                break;
            }

            // Set voltage polarity and check result
            uint32_t set_ret = PAC_SetVoltagePolarity(ch, bipolar);

            if (set_ret != EXIT_SUCCESS)
            {
                // Should fail for invalid channel
                if (ch_check)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor BUS, PAC_ChangeBusVoltagePolarity failed on channel ID%u with bipolar=%u", ch, bipolar);
                    ret_func = EXIT_FAILURE;
                    error = true;
                    break;
                }
            }
            else
            {
                // Should succeed for valid channel
                if (!ch_check)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor BUS, PAC_ChangeBusVoltagePolarity did not detect channel ID%u is invalid", ch);
                    ret_func = EXIT_FAILURE;
                    error = true;
                    break;
                }
                // Read back field value and check correctness
                if (PAC_GetFieldValue(F_PAC1934_NEG_PWR_ACT__CH1_BIDV - ch, &field_value) != EXIT_SUCCESS)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor BUS, PAC_GetFieldValue failed on field ID = %u", F_PAC1934_NEG_PWR_ACT__CH1_BIDV - ch);
                    ret_func = EXIT_FAILURE;
                    error = true;
                    break;
                }
                if ((field_value == 1) != bipolar)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor BUS, invalid value of field ID = %u: read %u but expect %u", F_PAC1934_NEG_PWR_ACT__CH1_BIDV - ch, field_value, bipolar);
                    ret_func = EXIT_FAILURE;
                    error = true;
                    break;
                }
                // Ensure no other bits changed in the register
                info = s_reg_field_info[F_PAC1934_NEG_PWR_ACT__CH1_BIDV - ch];
                if (PAC_GetRegisterValue(R_PAC1934_NEG_PWR_ACT, &new_reg_val, 1) != EXIT_SUCCESS)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor BUS, PAC_GetRegisterValue failed on register ID = %u", R_PAC1934_NEG_PWR_ACT);
                    ret_func = EXIT_FAILURE;
                    error = true;
                    break;
                }
                if ((new_reg_val & ~info.mask) != (orig_reg_value & ~info.mask))
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor BUS, other bit have changed: original = 0x%02X, current ) 0x%02X", new_reg_val & ~info.mask, orig_reg_value & ~info.mask);
                    ret_func = EXIT_FAILURE;
                    error = true;
                    break;
                }
            }

            // Repeat for current polarity
            if (PAC_GetRegisterValue(R_PAC1934_NEG_PWR_ACT, &orig_reg_value, 1) != EXIT_SUCCESS)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor BUS, PAC_GetRegisterValue failed on register ID = %u", R_PAC1934_NEG_PWR_ACT);
                ret_func = EXIT_FAILURE;
                error = true;
                break;
            }

            set_ret = PAC_SetCurrentPolarity(ch, bipolar);

            if (set_ret != EXIT_SUCCESS)
            {
                // Should fail for invalid channel
                if (ch_check)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor SENSE, PAC_ChangeBusVoltagePolarity failed on channel ID%u with bipolar=%u", ch, bipolar);
                    ret_func = EXIT_FAILURE;
                    error = true;
                    break;
                }
            }
            else
            {
                // Should succeed for valid channel
                if (!ch_check)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor SENSE, PAC_ChangeBusVoltagePolarity did not detect channel ID%u is invalid", ch);
                    ret_func = EXIT_FAILURE;
                    error = true;
                    break;
                }
                // Read back field value and check correctness
                if (PAC_GetFieldValue(F_PAC1934_NEG_PWR_ACT__CH1_BIDI - ch, &field_value) != EXIT_SUCCESS)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor SENSE, PAC_GetFieldValue failed on field ID = %u", F_PAC1934_NEG_PWR_ACT__CH1_BIDI - ch);
                    ret_func = EXIT_FAILURE;
                    error = true;
                    break;
                }
                if ((field_value == 1) != bipolar)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor SENSE, invalid value of field ID = %u: read %u but expect %u", F_PAC1934_NEG_PWR_ACT__CH1_BIDI - ch, field_value, bipolar);
                    ret_func = EXIT_FAILURE;
                    error = true;
                    break;
                }
                // Ensure no other bits changed in the register
                info = s_reg_field_info[F_PAC1934_NEG_PWR_ACT__CH1_BIDI - ch];
                if (PAC_GetRegisterValue(R_PAC1934_NEG_PWR_ACT, &new_reg_val, 1) != EXIT_SUCCESS)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor SENSE, PAC_GetRegisterValue failed on register ID = %u", R_PAC1934_NEG_PWR_ACT);
                    ret_func = EXIT_FAILURE;
                    error = true;
                    break;
                }
                if ((new_reg_val & ~info.mask) != (orig_reg_value & ~info.mask))
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFor SENSE, other bit have changed: original = 0x%02X, current ) 0x%02X", new_reg_val & ~info.mask, orig_reg_value & ~info.mask);
                    ret_func = EXIT_FAILURE;
                    error = true;
                    break;
                }
            }
        }
    }
    return ret_func;
}

// Test changing the sample rate and verifying the change
uint32_t PAC1934_UNITTEST_change_sample_rate()
{
    uint16_t pac_sample_rate_ref, pac_sample_rate;
    uint8_t pac_sample_rate_code;
    uint32_t ret = EXIT_SUCCESS;

    // Read current sample rate code and value
    if (PAC_GetFieldValue(F_PAC1934_CTRL_ACT__Sample_Rate, &pac_sample_rate_code) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nCurrent sample rate code is %u", pac_sample_rate_code);

        pac_sample_rate = __PAC_get_sample_rate_from_code(pac_sample_rate_code);
        SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nCurrent sample rate is %u", pac_sample_rate);

        if (PAC_GetSampleRate(&pac_sample_rate_ref) != EXIT_SUCCESS)
        {
            ret = EXIT_FAILURE;
        }
        else if (pac_sample_rate_ref != pac_sample_rate)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nError reading the PAC193X sample rate: read 2 different values: %u != %u", pac_sample_rate, pac_sample_rate_ref);
            ret = EXIT_FAILURE;
        }
        else
        {
            // Change sample rate to the other supported value (1024 <-> 256)
            pac_sample_rate_ref = (pac_sample_rate == 1024) ? 256 : 1024;
            if (PAC_SetSampleRate(pac_sample_rate_ref) != EXIT_SUCCESS)
            {
                ret = EXIT_FAILURE;
            }
            else
            {
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nChanged sample rate of PAC193X to %u", pac_sample_rate_ref);

                // Verify the change took effect
                if (PAC_GetFieldValue(F_PAC1934_CTRL_ACT__Sample_Rate, &pac_sample_rate_code) != EXIT_SUCCESS)
                {
                    ret = EXIT_FAILURE;
                }
                else
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nCurrent sample rate code is %u", pac_sample_rate_code);

                    if (PAC_GetSampleRate(&pac_sample_rate) != EXIT_SUCCESS)
                    {
                        ret = EXIT_FAILURE;
                    }
                    else if (pac_sample_rate_ref != pac_sample_rate)
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to change the sample rate of the PAC193X: read %u but expect %u", pac_sample_rate, pac_sample_rate_ref);
                        ret = EXIT_FAILURE;
                    }
                }
            }
        }
    }
    return ret;
}

// Compute expected voltage value for a given register value and polarity
static void __PAC1934_UNITTEST_compute_expected_voltage(const uint16_t le_reg_value,
                                                       const bool is_bipolar,
                                                       pac_expected_data_t* data)
{
    // Swap bytes because PAC193X is big-endian
    data->reg_value[0] = (le_reg_value >> 8) & 0xFF;
    data->reg_value[1] = le_reg_value & 0xFF;

    if (is_bipolar)
    {
        // Bipolar calculation
        double value = (double)((int16_t)le_reg_value) * PAC193X_FULL_SCALE_VBUS * 1000.0 / (1 << PAC193X_BIPOLAR_DENOMINATOR_2POW);
        data->compute_value.bipolar = (int32_t)value;
    }
    else
    {
        // Unipolar calculation
        double value = (double)((uint16_t)le_reg_value) * PAC193X_FULL_SCALE_VBUS * 1000.0 / (1 << PAC193X_UNIPOLAR_DENOMINATOR_2POW);
        data->compute_value.unipolar = (uint32_t)value;
    }
}


// Compute expected current value for a given register value, polarity, and sense resistor
static void __PAC1934_UNITTEST_compute_expected_current(const uint16_t le_reg_value,
                                                       const bool is_bipolar,
                                                       const uint32_t r_sense_in_mOhms,
                                                       pac_expected_data_t* data)
{
    double value;

    // Swap bytes because PAC193X is big-endian
    data->reg_value[0] = (le_reg_value >> 8) & 0xFF;
    data->reg_value[1] = le_reg_value & 0xFF;

    double fsc = PAC193X_FULL_SCALE_VSENSE * 1000.0 / (double)r_sense_in_mOhms;

    if (is_bipolar)
    {
        // Bipolar calculation
        value = (double)((int16_t)le_reg_value) * fsc / (1 << PAC193X_BIPOLAR_DENOMINATOR_2POW);
        data->compute_value.bipolar = (int32_t)value;
    }
    else
    {
        // Unipolar calculation
        value = (double)((uint16_t)le_reg_value) * fsc / (1 << PAC193X_UNIPOLAR_DENOMINATOR_2POW);
        data->compute_value.unipolar = (uint32_t)value;
    }
}


// Compute expected power value for a given register value, polarity, and sense resistor
static void __PAC1934_UNITTEST_compute_expected_power(const uint32_t le_reg_value,
                                                     const bool is_bipolar,
                                                     const uint32_t r_sense_in_mOhms,
                                                     pac_expected_data_t* data)
{
    double value;

    // Swap bytes because PAC139X is big-endian
    data->reg_value[0] = (le_reg_value >> 24) & 0xFF;
    data->reg_value[1] = (le_reg_value >> 16) & 0xFF;
    data->reg_value[2] = (le_reg_value >> 8) & 0xFF;
    data->reg_value[3] = le_reg_value & 0xFF;

    double power_fsr = PAC193X_FULL_SCALE_VBUS * PAC193X_FULL_SCALE_VSENSE * 1000.0 / (double)r_sense_in_mOhms;

    if (is_bipolar)
    {
        // Bipolar calculation
        value = (double)((int32_t)le_reg_value) * power_fsr / (1ULL << (2 * PAC193X_BIPOLAR_DENOMINATOR_2POW + 1));
        data->compute_value.bipolar = (int32_t)value;
    }
    else
    {
        // Unipolar calculation
        value = (double)le_reg_value * power_fsr / (1ULL << (2 * PAC193X_UNIPOLAR_DENOMINATOR_2POW));
        data->compute_value.unipolar = (uint32_t)value;
    }
}


// Test voltage computation for a variety of register values and both polarities
uint32_t PAC1934_UNITTEST_voltage_computation(void)
{
    uint16_t reg_value_list[] = {0x0, 0x3, 0x7FFF, 0xFF00, 0xFFFD};
    uint32_t reg_value_list_size = sizeof(reg_value_list) / sizeof(reg_value_list[0]);
    uint32_t ret = EXIT_SUCCESS;
    bool error = false;

    for (uint8_t bipolar = 0; bipolar <= 1 && !error; bipolar++)
    {
        bool is_bipolar = bipolar == 1;

        for (uint32_t i = 0; i < reg_value_list_size && !error; i++)
        {
            uint16_t reg_value = reg_value_list[i];

            // Compute expected and actual voltage
            pac_expected_data_t value_expect;
            __PAC1934_UNITTEST_compute_expected_voltage(reg_value, is_bipolar, &value_expect);
            pac_measure_t value_compute;
            __PAC_compute_voltage_in_mV(value_expect.reg_value, is_bipolar, &value_compute);
            if (value_compute.is_bipolar != is_bipolar)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\npolarity error: value_compute variable has polarity %u but %u is expected", value_compute.is_bipolar, is_bipolar);
                ret = EXIT_FAILURE;
                error = true;
                break;
            }
            if (is_bipolar)
            {
                if (value_compute.bipolar != value_expect.compute_value.bipolar)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nVoltage computation error of value 0x%04X with bipolar=%u: computed %li mV but expect %li mV", reg_value, is_bipolar, value_compute.bipolar, value_expect.compute_value.bipolar);
                    ret = EXIT_FAILURE;
                    error = true;
                    break;
                }
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nVoltage computation for value 0x%04X with bipolar=%u: %li mV", reg_value, is_bipolar, value_compute.bipolar);
            }
            else
            {
                if (value_compute.unipolar != value_expect.compute_value.unipolar)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nVoltage computation error of value 0x%04X with bipolar=%u: computed %lu mV but expect %lu mV", reg_value, is_bipolar, value_compute.unipolar, value_expect.compute_value.unipolar);
                    ret = EXIT_FAILURE;
                    error = true;
                    break;
                }
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nVoltage computation for value 0x%04X with bipolar=%u: %lu mV", reg_value, is_bipolar, value_compute.unipolar);
            }
        }
    }
    return ret;
}

// Test current computation for a variety of register values and both polarities
uint32_t PAC1934_UNITTEST_current_computation(void)
{
    uint16_t reg_value_list[] = {0x0, 0x7, 0x7FFF, 0x8000, 0xFFF0, 0xFFFF};
    uint32_t reg_value_list_size = sizeof(reg_value_list) / sizeof(reg_value_list[0]);
    uint32_t r_sense_in_mOhms = s_r_sense_values_in_mOhms[0];
    uint32_t ret = EXIT_SUCCESS;
    bool error = false;

    for (uint8_t bipolar = 0; bipolar <= 1 && !error; bipolar++)
    {
        bool is_bipolar = bipolar == 1;

        for (uint32_t i = 0; i < reg_value_list_size && !error; i++)
        {
            uint16_t reg_value = reg_value_list[i];

            // Compute expected and actual current
            pac_expected_data_t value_expect;
            __PAC1934_UNITTEST_compute_expected_current(reg_value, is_bipolar, r_sense_in_mOhms, &value_expect);
            pac_measure_t value_compute;
            __PAC_compute_current_in_mA(value_expect.reg_value, is_bipolar, r_sense_in_mOhms, &value_compute);
            if (value_compute.is_bipolar != is_bipolar)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\npolarity error: value_compute variable has polarity %u but %u is expected", value_compute.is_bipolar, is_bipolar);
                ret = EXIT_FAILURE;
                error = true;
                break;
            }
            if (is_bipolar)
            {
                if (value_compute.bipolar != value_expect.compute_value.bipolar)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nCurrent computation error of value 0x%04X with bipolar=%u: computed %li mA but expect %li mA", reg_value, is_bipolar, value_compute.bipolar, value_expect.compute_value.bipolar);
                    ret = EXIT_FAILURE;
                    error = true;
                    break;
                }
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nCurrent computation for value 0x%04X with bipolar=%u: %li mA", reg_value, is_bipolar, value_compute.bipolar);
            }
            else
            {
                if (value_compute.unipolar != value_expect.compute_value.unipolar)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nCurrent computation error of value 0x%04X with bipolar=%u: computed %lu mA but expect %lu mA", reg_value, is_bipolar, value_compute.unipolar, value_expect.compute_value.unipolar);
                    ret = EXIT_FAILURE;
                    error = true;
                    break;
                }
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nCurrent computation for value 0x%04X with bipolar=%u: %lu mA", reg_value, is_bipolar, value_compute.unipolar);
            }
        }
    }

    return ret;
}

// Test power computation for a variety of register values and both polarities
uint32_t PAC1934_UNITTEST_power_computation(void)
{
    uint32_t reg_value_list[] = {0x0, 0x10000, 0x7FFFFFFF, 0x80000000, 0xFFFFF000, 0xFFFFFFFF};
    uint32_t reg_value_list_size = sizeof(reg_value_list) / sizeof(reg_value_list[0]);
    uint32_t r_sense_in_mOhms = s_r_sense_values_in_mOhms[0];
    uint32_t ret = EXIT_SUCCESS;
    bool error = false;

    for (uint8_t bipolar = 0; bipolar <= 1 && !error; bipolar++)
    {
        bool is_bipolar = bipolar == 1;

        for (uint32_t i = 0; i < reg_value_list_size && !error; i++)
        {
            uint32_t reg_value = reg_value_list[i];

            // Compute expected and actual power
            pac_expected_data_t value_expect;
            __PAC1934_UNITTEST_compute_expected_power(reg_value, is_bipolar, r_sense_in_mOhms, &value_expect);
            pac_measure_t value_compute;
            __PAC_compute_power_in_mW(value_expect.reg_value, is_bipolar, r_sense_in_mOhms, &value_compute);
            if (value_compute.is_bipolar != is_bipolar)
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\npolarity error: value_compute variable has polarity %u but %u is expected", value_compute.is_bipolar, is_bipolar);
                ret = EXIT_FAILURE;
                error = true;
                break;
            }
            if (is_bipolar)
            {
                if (value_compute.bipolar != value_expect.compute_value.bipolar)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nPower computation error of value 0x%08X with bipolar=%u: computed %li mW but expect %li mW", reg_value, is_bipolar, value_compute.bipolar, value_expect.compute_value.bipolar);
                    ret = EXIT_FAILURE;
                    error = true;
                    break;
                }
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nPower computation for value 0x%08X with bipolar=%u: %li mW", reg_value, is_bipolar, value_compute.bipolar);
            }
            else
            {
                if (value_compute.unipolar != value_expect.compute_value.unipolar)
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nPower computation error of value 0x%08X with bipolar=%u: computed %lu mW but expect %lu mW", reg_value, is_bipolar, value_compute.unipolar, value_expect.compute_value.unipolar);
                    ret = EXIT_FAILURE;
                    error = true;
                    break;
                }
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nPower computation for value 0x%08X with bipolar=%u: %lu mW", reg_value, is_bipolar, value_compute.unipolar);
            }
        }
    }

    return ret;
}

// Test that measured power is coherent with voltage and current, and that energy increases over time
uint32_t PAC1934_UNITTEST_power_coherency(void)
{
    pac_measure_t voltage, current, power, energy, energy_prev;
    bool p_bipolar = true;
    pac_channel_id_t channel_id = PAC_CHANNEL_4;
    double tolerance = 0.05;
    double power_expect;
    uint32_t power_min, power_max;
    uint16_t sample_rate;
    uint32_t cnt_max = 3;
    uint32_t ret = EXIT_SUCCESS;
    bool error = false;

    // Get current sample rate
    if (PAC_GetSampleRate(&sample_rate) != EXIT_SUCCESS)
    {
        ret = EXIT_FAILURE;
        error = true;
    }
    else
    {
        SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nSample rate: %u samples/s", sample_rate);

        // Test all combinations of voltage and current polarity
        for (uint8_t v_bipolar = 0; v_bipolar <= 1 && !error; v_bipolar++)
        {
            for (uint8_t c_bipolar = 0; c_bipolar <= 1 && !error; c_bipolar++)
            {
                // Set voltage and current polarity for the channel
                if (PAC_SetVoltagePolarity(channel_id, v_bipolar == 1) != EXIT_SUCCESS)
                {
                    ret = EXIT_FAILURE;
                    error = true;
                    break;
                }
                if (PAC_SetCurrentPolarity(channel_id, c_bipolar == 1) != EXIT_SUCCESS)
                {
                    ret = EXIT_FAILURE;
                    error = true;
                    break;
                }

                energy_prev = (pac_measure_t){0};

                for (uint8_t cnt = 0; cnt <= cnt_max && !error; cnt++)
                {
                    // Read all measurements
                    if (PAC_GetAllMeasures(channel_id, false, &voltage, &current, &power, &energy) != EXIT_SUCCESS)
                    {
                        ret = EXIT_FAILURE;
                        error = true;
                        break;
                    }

                    // Check polarity of measured values
                    if (voltage.is_bipolar != (v_bipolar == 1))
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\npolarity error: voltage variable has polarity %u but %u is expected", voltage.is_bipolar, (v_bipolar == 1));
                        ret = EXIT_FAILURE;
                        error = true;
                        break;
                    }
                    if (current.is_bipolar != (c_bipolar == 1))
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\npolarity error: current variable has polarity %u but %u is expected", current.is_bipolar, (c_bipolar == 1));
                        ret = EXIT_FAILURE;
                        error = true;
                        break;
                    }
                    if (power.is_bipolar != (bool)(c_bipolar + v_bipolar))
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\npolarity error: power variable has polarity %u but %u is expected", power.is_bipolar, (bool)(c_bipolar + v_bipolar));
                        ret = EXIT_FAILURE;
                        error = true;
                        break;
                    }
                    if (energy.is_bipolar != (bool)(c_bipolar + v_bipolar))
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\npolarity error: energy variable has polarity %u but %u is expected", energy.is_bipolar, (bool)(c_bipolar + v_bipolar));
                        ret = EXIT_FAILURE;
                        error = true;
                        break;
                    }

                    // Check power is the product of voltage and current with a tolerance
                    if (v_bipolar)
                    {
                        power_expect = voltage.bipolar;
                        if (c_bipolar)
                        {
                            power_expect *= current.bipolar / 1000.0; // mW
                            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nvoltage = %i mV x current = %i mA => power = %li mW (expect %0.1lf mW), energy = %li mJ",
                                        voltage.bipolar, current.bipolar, power.bipolar, power_expect, energy.bipolar);
                        }
                        else
                        {
                            power_expect *= current.unipolar / 1000.0; // mW
                            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nvoltage = %i mV x current = %u mA => power = %li mW (expect %0.1lf mW), energy = %li mJ",
                                        voltage.bipolar, current.unipolar, power.bipolar, power_expect, energy.bipolar);
                        }
                    }
                    else
                    {
                        power_expect = voltage.unipolar;
                        if (c_bipolar)
                        {
                            power_expect *= current.bipolar / 1000.0; // mW
                            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nvoltage = %u mV x current = %i mA => power = %li mW (expect %0.1lf mW), energy = %li mJ",
                                        voltage.unipolar, current.bipolar, power.bipolar, power_expect, energy.bipolar);
                        }
                        else
                        {
                            power_expect *= current.unipolar / 1000.0; // mW
                            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nvoltage = %u mV x current = %u mA => power = %lu mW (expect %0.1lf mW), energy = %lu mJ",
                                        voltage.unipolar, current.unipolar, power.unipolar, power_expect, energy.unipolar);
                            p_bipolar = false;
                        }
                    }

                    power_min = power_expect * (1.0 - tolerance);
                    power_max = power_expect * (1.0 + tolerance);

                    // Check measured power is within tolerance
                    if (p_bipolar)
                    {
                        if ((power.bipolar < power_min) || (power.bipolar > power_max))
                        {
                            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nMeasured power = %li mW is out of %f tolerance of expected power = %0.1lf mW", power.bipolar, tolerance, power_expect);
                            ret = EXIT_FAILURE;
                            error = true;
                            break;
                        }
                    }
                    else
                    {
                        if ((power.unipolar < power_min) || (power.unipolar > power_max))
                        {
                            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nMeasured power = %lu mW is out of %f tolerance of expected power = %0.1lf mW", power.unipolar, tolerance, power_expect);
                            ret = EXIT_FAILURE;
                            error = true;
                            break;
                        }
                    }

                    // Check that energy increases over time
                    if (cnt > 0)
                    {
                        if (energy.bipolar <= energy_prev.bipolar)
                        {
                            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nEnergy must increase with time: latest measure %li mJ shall be greater than previous measure %li mJ", energy.bipolar, energy_prev.bipolar);
                            ret = EXIT_FAILURE;
                            error = true;
                            break;
                        }
                    }

                    energy_prev = energy;

                    __PAC_sleep(1000); // Wait 1 second between measurements
                }
            }
        }
    }
    return ret;
}
</#if>

/* *****************************************************************************
 End of File
 */
