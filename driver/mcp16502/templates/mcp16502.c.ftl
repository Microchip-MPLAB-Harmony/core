/* ************************************************************************** */
/** MCP16502 Driver

  @Company
    Microchip Technology

  @File Name
    mcp16502.c

  @Summary
    Driver to access the MCP16502 PMIC on a SAMA7G54-EK board through I2C bus

  @Description
    Provide functions to access the registers of the MCP16502 through the
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

#include "mcp16502.h"
#include "definitions.h"


/* ************************************************************************** */
/* ************************************************************************** */
/* Section: File Scope or Global Data                                         */
/* ************************************************************************** */
/* ************************************************************************** */

#define MCP16502_DRV_I2C_INDEX     DRV_I2C_INDEX_0

#define PMIC_REGUL_STATUS_ID_OFFSET    (R_MCP16502_STS_B2 - R_MCP16502_STS_B1)
#define PMIC_REGUL_MODE_ID_OFFSET      (R_MCP16502_OUT2_A - R_MCP16502_OUT1_A)

#define MCP16502_MODE_ID_OFFSET        (R_MCP16502_OUT1_LPM - R_MCP16502_OUT1_A)
#define MCP16502_MODE_ID_OFFSET_VSET   (F_MCP16502_OUT1_A__VSET - R_MCP16502_OUT1_A)
#define MCP16502_MODE_ID_OFFSET_MODE   (F_MCP16502_OUT1_A__MODE - R_MCP16502_OUT1_A)
#define MCP16502_MODE_ID_OFFSET_EN     (F_MCP16502_OUT1_A__EN - R_MCP16502_OUT1_A)

#define MCP16502_STATUS_ID_OFFSET_ENS       (F_MCP16502_STS_B1__ENS - R_MCP16502_STS_B1)
#define MCP16502_STATUS_ID_OFFSET_POK       (F_MCP16502_STS_B1__POK - R_MCP16502_STS_B1)
#define MCP16502_STATUS_ID_OFFSET_SSD       (F_MCP16502_STS_B1__SSD - R_MCP16502_STS_B1)
#define MCP16502_STATUS_ID_OFFSET_ILIM      (F_MCP16502_STS_B1__ILIM - R_MCP16502_STS_B1)
#define MCP16502_STATUS_ID_OFFSET_ZCD       (F_MCP16502_STS_B1__ZCD - R_MCP16502_STS_B1)
#define MCP16502_STATUS_ID_OFFSET_ILIMNEG   (F_MCP16502_STS_B1__ILIMNEG - R_MCP16502_STS_B1)
#define MCP16502_STATUS_ID_OFFSET_HICCUP    (F_MCP16502_STS_B1__HICCUP - R_MCP16502_STS_B1)
#define MCP16502_STATUS_ID_OFFSET_FLT       (F_MCP16502_STS_B1__FLT - R_MCP16502_STS_B1)

static pmic_reg_field_id_t s_pmic_register_offset_mode[] =
{
    R_MCP16502_OUT1_A,
    R_MCP16502_OUT2_A,
    R_MCP16502_OUT3_A,
    R_MCP16502_OUT4_A,
    R_MCP16502_LDO1_A,
    R_MCP16502_LDO2_A,
};

static pmic_reg_field_id_t s_pmic_register_offset_status[] =
{
    R_MCP16502_STS_B1,
    R_MCP16502_STS_B2,
    R_MCP16502_STS_B3,
    R_MCP16502_STS_B4,
    R_MCP16502_STS_L1,
    R_MCP16502_STS_L2,
};

typedef enum
{
    VOUT_RANGE_B1_L1_L2 = 0,
    VOUT_RANGE_B2_B3_B4
} vout_range_t;

typedef struct
{
    uint8_t vset;
    uint16_t vout[2];
} vset_vout_item_t;

typedef struct
{
    uint8_t addr;
    uint8_t mask;
    uint8_t shift;
} pmic_reg_field_info_t;

static SYS_MODULE_INDEX s_drv_i2c_inst_index = 0;
static DRV_HANDLE s_drv_i2c_handle = DRV_HANDLE_INVALID;

static uint16_t s_i2c_device_base_address = 0;

// See MCP16502 datasheet TABLE 4-5: VOLTAGE CODE DEFINITION BITS (VSET[5:0])
static const vset_vout_item_t s_vset_map[] =
{
    // VSET[5:0]        Voltage for Buck1, LDO[2:1]    Voltage for Buck[4:2]
    {  0x0D,           {         1200,                           600         } },
    {  0x0E,           {         1250,                           625         } },
    {  0x0F,           {         1300,                           650         } },
    {  0x10,           {         1350,                           675         } },
    {  0x11,           {         1400,                           700         } },
    {  0x12,           {         1450,                           725         } },
    {  0x13,           {         1500,                           750         } },
    {  0x14,           {         1550,                           775         } },
    {  0x15,           {         1600,                           800         } },
    {  0x16,           {         1650,                           825         } },
    {  0x17,           {         1700,                           850         } },
    {  0x18,           {         1750,                           875         } },
    {  0x19,           {         1800,                           900         } },
    {  0x1A,           {         1850,                           925         } },
    {  0x1B,           {         1900,                           950         } },
    {  0x1C,           {         1950,                           975         } },
    {  0x1D,           {         2000,                          1000         } },
    {  0x1E,           {         2050,                          1025         } },
    {  0x1F,           {         2100,                          1050         } },
    {  0x20,           {         2150,                          1075         } },
    {  0x21,           {         2200,                          1100         } },
    {  0x22,           {         2250,                          1125         } },
    {  0x23,           {         2300,                          1150         } },
    {  0x24,           {         2350,                          1175         } },
    {  0x25,           {         2400,                          1200         } },
    {  0x26,           {         2450,                          1225         } },
    {  0x27,           {         2500,                          1250         } },
    {  0x28,           {         2550,                          1275         } },
    {  0x29,           {         2600,                          1300         } },
    {  0x2A,           {         2650,                          1325         } },
    {  0x2B,           {         2700,                          1350         } },
    {  0x2C,           {         2750,                          1375         } },
    {  0x2D,           {         2800,                          1400         } },
    {  0x2E,           {         2850,                          1425         } },
    {  0x2F,           {         2900,                          1450         } },
    {  0x30,           {         2950,                          1475         } },
    {  0x31,           {         3000,                          1500         } },
    {  0x32,           {         3050,                          1525         } },
    {  0x33,           {         3100,                          1550         } },
    {  0x34,           {         3150,                          1575         } },
    {  0x35,           {         3200,                          1600         } },
    {  0x36,           {         3250,                          1625         } },
    {  0x37,           {         3300,                          1650         } },
    {  0x38,           {         3350,                          1675         } },
    {  0x39,           {         3400,                          1700         } },
    {  0x3A,           {         3450,                          1725         } },
    {  0x3B,           {         3500,                          1750         } },
    {  0x3C,           {         3550,                          1775         } },
    {  0x3D,           {         3600,                          1800         } },
    {  0x3E,           {         3650,                          1825         } },
    {  0x3F,           {         3700,                          1850         } }
};


// List all the fields information: mask and shift for the corresponding register
static const pmic_reg_field_info_t s_reg_field_info[] = {
    // register offset   |    field mask   |    field bit shift
    //----------------------------------------------------------
    // SYS-ADR register
    {  0x00              ,    0xFF         ,    0      },  // Register: R_MCP16502_SYS_ADR
    {  0x00              ,    0x7F         ,    0      },  // Field: F_MCP16502_SYS_ADR__ADR
    // SYS-ID register
    {  0x01              ,    0xFF         ,    0      },  // Register: R_MCP16502_SYS_ID
    {  0x01              ,    0x0F         ,    0      },  // Field: F_MCP16502_SYS_ID__REV
    {  0x01              ,    0xF0         ,    4      },  // Field: F_MCP16502_SYS_ID__ID
    // SYS-TMG register
    {  0x02              ,    0xFF         ,    0      },  // Register: R_MCP16502_SYS_TMG
    {  0x02              ,    0x07         ,    0      },  // Field: F_MCP16502_SYS_TMG__RSTDLY
    {  0x02              ,    0x30         ,    4      },  // Field: F_MCP16502_SYS_TMG__PBINTTO
    {  0x02              ,    0xC0         ,    6      },  // Field: F_MCP16502_SYS_TMG__PBTO
    // SYS-CFG register
    {  0x03              ,    0xFF         ,    0      },  // Register: R_MCP16502_SYS_CFG
    {  0x03              ,    0x01         ,    0      },  // Field: F_MCP16502_SYS_CFG__USER
    {  0x03              ,    0x02         ,    1      },  // Field: F_MCP16502_SYS_CFG__B1HCEN
    {  0x03              ,    0x0C         ,    2      },  // Field: F_MCP16502_SYS_CFG__FSD
    {  0x03              ,    0x10         ,    4      },  // Field: F_MCP16502_SYS_CFG__AWKPDIS
    {  0x03              ,    0x20         ,    5      },  // Field: F_MCP16502_SYS_CFG__HPMPEN
    {  0x03              ,    0x40         ,    6      },  // Field: F_MCP16502_SYS_CFG__TWRMSK
    {  0x03              ,    0x80         ,    7      },  // Field: F_MCP16502_SYS_CFG__TSDMSK
    // STS-SYS register
    {  0x04              ,    0xFF         ,    0      },  // Register: R_MCP16502_STS_SYS
    {  0x04              ,    0x20         ,    5      },  // Field: F_MCP16502_STS_SYS__PBINT
    {  0x04              ,    0x40         ,    6      },  // Field: F_MCP16502_STS_SYS__TWR
    {  0x04              ,    0x80         ,    7      },  // Field: F_MCP16502_STS_SYS__TSD
    // STS-B1 register
    {  0x05              ,    0xFF         ,    0      },  // Register: R_MCP16502_STS_B1
    {  0x05              ,    0x01         ,    0      },  // Field: F_MCP16502_STS_B1__ENS
    {  0x05              ,    0x02         ,    1      },  // Field: F_MCP16502_STS_B1__POK
    {  0x05              ,    0x04         ,    2      },  // Field: F_MCP16502_STS_B1__SSD
    {  0x05              ,    0x08         ,    3      },  // Field: /!\ NOT USED F_MCP16502_STS_B1__ILIM
    {  0x05              ,    0x10         ,    4      },  // Field: F_MCP16502_STS_B1__ZCD
    {  0x05              ,    0x20         ,    5      },  // Field: F_MCP16502_STS_B1__ILIMNEG
    {  0x05              ,    0x40         ,    6      },  // Field: F_MCP16502_STS_B1__HICCUP
    {  0x05              ,    0x80         ,    7      },  // Field: F_MCP16502_STS_B1__FLT
    // STS-B2 register
    {  0x06              ,    0xFF         ,    0      },  // Register: R_MCP16502_STS_B2
    {  0x06              ,    0x01         ,    0      },  // Field: F_MCP16502_STS_B2__ENS
    {  0x06              ,    0x02         ,    1      },  // Field: F_MCP16502_STS_B2__POK
    {  0x06              ,    0x04         ,    2      },  // Field: F_MCP16502_STS_B2__SSD
    {  0x06              ,    0x08         ,    3      },  // Field: /!\ NOT USED F_MCP16502_STS_B2__ILIM
    {  0x06              ,    0x10         ,    4      },  // Field: F_MCP16502_STS_B2__ZCD
    {  0x06              ,    0x20         ,    5      },  // Field: F_MCP16502_STS_B2__ILIMNEG
    {  0x06              ,    0x40         ,    6      },  // Field: F_MCP16502_STS_B2__HICCUP
    {  0x06              ,    0x80         ,    7      },  // Field: F_MCP16502_STS_B2__FLT
    // STS-B3 register
    {  0x07              ,    0xFF         ,    0      },  // Register: R_MCP16502_STS_B3
    {  0x07              ,    0x01         ,    0      },  // Field: F_MCP16502_STS_B3__ENS
    {  0x07              ,    0x02         ,    1      },  // Field: F_MCP16502_STS_B3__POK
    {  0x07              ,    0x04         ,    2      },  // Field: F_MCP16502_STS_B3__SSD
    {  0x07              ,    0x08         ,    3      },  // Field: /!\ NOT USED F_MCP16502_STS_B3__ILIM
    {  0x07              ,    0x10         ,    4      },  // Field: F_MCP16502_STS_B3__ZCD
    {  0x07              ,    0x20         ,    5      },  // Field: F_MCP16502_STS_B3__ILIMNEG
    {  0x07              ,    0x40         ,    6      },  // Field: F_MCP16502_STS_B3__HICCUP
    {  0x07              ,    0x80         ,    7      },  // Field: F_MCP16502_STS_B3__FLT
    // STS-B4 register
    {  0x08              ,    0xFF         ,    0      },  // Register: R_MCP16502_STS_B4
    {  0x08              ,    0x01         ,    0      },  // Field: F_MCP16502_STS_B4__ENS
    {  0x08              ,    0x02         ,    1      },  // Field: F_MCP16502_STS_B4__POK
    {  0x08              ,    0x04         ,    2      },  // Field: F_MCP16502_STS_B4__SSD
    {  0x08              ,    0x08         ,    3      },  // Field: /!\ NOT USED F_MCP16502_STS_B4__ILIM
    {  0x08              ,    0x10         ,    4      },  // Field: F_MCP16502_STS_B4__ZCD
    {  0x08              ,    0x20         ,    5      },  // Field: F_MCP16502_STS_B4__ILIMNEG
    {  0x08              ,    0x40         ,    6      },  // Field: F_MCP16502_STS_B4__HICCUP
    {  0x08              ,    0x80         ,    7      },  // Field: F_MCP16502_STS_B4__FLT
    // STS-L1 register
    {  0x09              ,    0xFF         ,    0      },  // Register: R_MCP16502_STS_L1
    {  0x09              ,    0x01         ,    0      },  // Field: F_MCP16502_STS_L1__ENS
    {  0x09              ,    0x02         ,    1      },  // Field: F_MCP16502_STS_L1__POK
    {  0x09              ,    0x04         ,    2      },  // Field: F_MCP16502_STS_L1__SSD
    {  0x09              ,    0x08         ,    3      },  // Field: F_MCP16502_STS_L1__ILIM
    {  0x09              ,    0x10         ,    4      },  // Field: /!\ NOT USED F_MCP16502_STS_L1__ZCD
    {  0x09              ,    0x20         ,    5      },  // Field: /!\ NOT USED F_MCP16502_STS_L1__ILIMNEG
    {  0x09              ,    0x40         ,    6      },  // Field: /!\ NOT USED F_MCP16502_STS_L1__HICCUP
    {  0x09              ,    0x80         ,    7      },  // Field: F_MCP16502_STS_L1__FLT
    // STS-L2 register
    {  0x0A              ,    0xFF         ,    0      },  // Register: R_MCP16502_STS_L2
    {  0x0A              ,    0x01         ,    0      },  // Field: F_MCP16502_STS_L2__ENS
    {  0x0A              ,    0x02         ,    1      },  // Field: F_MCP16502_STS_L2__POK
    {  0x0A              ,    0x04         ,    2      },  // Field: F_MCP16502_STS_L2__SSD
    {  0x0A              ,    0x08         ,    3      },  // Field: F_MCP16502_STS_L2__ILIM
    {  0x0A              ,    0x10         ,    4      },  // Field: /!\ NOT USED F_MCP16502_STS_L2__ZCD
    {  0x0A              ,    0x20         ,    5      },  // Field: /!\ NOT USED F_MCP16502_STS_L2__ILIMNEG
    {  0x0A              ,    0x40         ,    6      },  // Field: /!\ NOT USED F_MCP16502_STS_L2__HICCUP
    {  0x0A              ,    0x80         ,    7      },  // Field: F_MCP16502_STS_L2__FLT
    // OUT1-A register
    {  0x10              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT1_A
    {  0x10              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT1_A__VSET
    {  0x10              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT1_A__MODE
    {  0x10              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT1_A__EN
    // OUT1-LPM register
    {  0x11              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT1_LPM
    {  0x11              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT1_LPM__VSET
    {  0x11              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT1_LPM__MODE
    {  0x11              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT1_LPM__EN
    // OUT1-HIB register
    {  0x12              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT1_HIB
    {  0x12              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT1_HIB__VSET
    {  0x12              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT1_HIB__MODE
    {  0x12              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT1_HIB__EN
    // OUT1-HPM register
    {  0x13              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT1_HPM
    {  0x13              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT1_HPM__VSET
    {  0x13              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT1_HPM__MODE
    {  0x13              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT1_HPM__EN
    // OUT1-SEQ register
    {  0x14              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT1_SEQ
    {  0x14              ,    0x07         ,    0      },  // Field: F_MCP16502_OUT1_SEQ__DELAY
    {  0x14              ,    0x08         ,    3      },  // Field: F_MCP16502_OUT1_SEQ__SEQEN
    {  0x14              ,    0x30         ,    4      },  // Field: F_MCP16502_OUT1_SEQ__SEQ
    {  0x14              ,    0xC0         ,    6      },  // Field: F_MCP16502_OUT1_SEQ__SSR
    // OUT1-CFG register
    {  0x15              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT1_CFG
    {  0x15              ,    0x01         ,    0      },  // Field: F_MCP16502_OUT1_CFG__RCON
    {  0x15              ,    0x02         ,    1      },  // Field: F_MCP16502_OUT1_CFG__REN
    {  0x15              ,    0x0C         ,    2      },  // Field: F_MCP16502_OUT1_CFG__DVSR
    {  0x15              ,    0x10         ,    4      },  // Field: F_MCP16502_OUT1_CFG__PHASE
    {  0x15              ,    0x20         ,    5      },  // Field: F_MCP16502_OUT1_CFG__DISCH
    {  0x15              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT1_CFG__HCPEN
    {  0x15              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT1_CFG__FLTMSK
    // OUT2-A register
    {  0x20              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT2_A
    {  0x20              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT2_A__VSET
    {  0x20              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT2_A__MODE
    {  0x20              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT2_A__EN
    // OUT2-LPM register
    {  0x21              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT2_LPM
    {  0x21              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT2_LPM__VSET
    {  0x21              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT2_LPM__MODE
    {  0x21              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT2_LPM__EN
    // OUT2-HIB register
    {  0x22              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT2_HIB
    {  0x22              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT2_HIB__VSET
    {  0x22              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT2_HIB__MODE
    {  0x22              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT2_HIB__EN
    // OUT2-HPM register
    {  0x23              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT2_HPM
    {  0x23              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT2_HPM__VSET
    {  0x23              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT2_HPM__MODE
    {  0x23              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT2_HPM__EN
    // OUT2-SEQ register
    {  0x24              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT2_SEQ
    {  0x24              ,    0x07         ,    0      },  // Field: F_MCP16502_OUT2_SEQ__DELAY
    {  0x24              ,    0x08         ,    3      },  // Field: F_MCP16502_OUT2_SEQ__SEQEN
    {  0x24              ,    0x30         ,    4      },  // Field: F_MCP16502_OUT2_SEQ__SEQ
    {  0x24              ,    0xC0         ,    6      },  // Field: F_MCP16502_OUT2_SEQ__SSR
    // OUT2-CFG register
    {  0x25              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT2_CFG
    {  0x25              ,    0x01         ,    0      },  // Field: F_MCP16502_OUT2_CFG__RCON
    {  0x25              ,    0x02         ,    1      },  // Field: F_MCP16502_OUT2_CFG__REN
    {  0x25              ,    0x0C         ,    2      },  // Field: F_MCP16502_OUT2_CFG__DVSR
    {  0x25              ,    0x10         ,    4      },  // Field: F_MCP16502_OUT2_CFG__PHASE
    {  0x25              ,    0x20         ,    5      },  // Field: F_MCP16502_OUT2_CFG__DISCH
    {  0x25              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT2_CFG__HCPEN
    {  0x25              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT2_CFG__FLTMSK
    // OUT3-A register
    {  0x30              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT3_A
    {  0x30              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT3_A__VSET
    {  0x30              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT3_A__MODE
    {  0x30              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT3_A__EN
    // OUT3-LPM register
    {  0x31              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT3_LPM
    {  0x31              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT3_LPM__VSET
    {  0x31              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT3_LPM__MODE
    {  0x31              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT3_LPM__EN
    // OUT3-HIB register
    {  0x32              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT3_HIB
    {  0x32              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT3_HIB__VSET
    {  0x32              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT3_HIB__MODE
    {  0x32              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT3_HIB__EN
    // OUT3-HPM register
    {  0x33              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT3_HPM
    {  0x33              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT3_HPM__VSET
    {  0x33              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT3_HPM__MODE
    {  0x33              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT3_HPM__EN
    // OUT3-SEQ register
    {  0x34              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT3_SEQ
    {  0x34              ,    0x07         ,    0      },  // Field: F_MCP16502_OUT3_SEQ__DELAY
    {  0x34              ,    0x08         ,    3      },  // Field: F_MCP16502_OUT3_SEQ__SEQEN
    {  0x34              ,    0x30         ,    4      },  // Field: F_MCP16502_OUT3_SEQ__SEQ
    {  0x34              ,    0xC0         ,    6      },  // Field: F_MCP16502_OUT3_SEQ__SSR
    // OUT3-CFG register
    {  0x35              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT3_CFG
    {  0x35              ,    0x01         ,    0      },  // Field: F_MCP16502_OUT3_CFG__RCON
    {  0x35              ,    0x02         ,    1      },  // Field: F_MCP16502_OUT3_CFG__REN
    {  0x35              ,    0x0C         ,    2      },  // Field: F_MCP16502_OUT3_CFG__DVSR
    {  0x35              ,    0x10         ,    4      },  // Field: F_MCP16502_OUT3_CFG__PHASE
    {  0x35              ,    0x20         ,    5      },  // Field: F_MCP16502_OUT3_CFG__DISCH
    {  0x35              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT3_CFG__HCPEN
    {  0x35              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT3_CFG__FLTMSK
    // OUT4-A register
    {  0x40              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT4_A
    {  0x40              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT4_A__VSET
    {  0x40              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT4_A__MODE
    {  0x40              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT4_A__EN
    // OUT1-LPM register
    {  0x41              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT4_LPM
    {  0x41              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT4_LPM__VSET
    {  0x41              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT4_LPM__MODE
    {  0x41              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT4_LPM__EN
    // OUT4-HIB register
    {  0x42              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT4_HIB
    {  0x42              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT4_HIB__VSET
    {  0x42              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT4_HIB__MODE
    {  0x42              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT4_HIB__EN
    // OUT4-HPM register
    {  0x43              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT4_HPM
    {  0x43              ,    0x3F         ,    0      },  // Field: F_MCP16502_OUT4_HPM__VSET
    {  0x43              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT4_HPM__MODE
    {  0x43              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT4_HPM__EN
    // OUT4-SEQ register
    {  0x44              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT4_SEQ
    {  0x44              ,    0x07         ,    0      },  // Field: F_MCP16502_OUT4_SEQ__DELAY
    {  0x44              ,    0x08         ,    3      },  // Field: F_MCP16502_OUT4_SEQ__SEQEN
    {  0x44              ,    0x30         ,    4      },  // Field: F_MCP16502_OUT4_SEQ__SEQ
    {  0x44              ,    0xC0         ,    6      },  // Field: F_MCP16502_OUT4_SEQ__SSR
    // OUT4-CFG register
    {  0x45              ,    0xFF         ,    0      },  // Register: R_MCP16502_OUT4_CFG
    {  0x45              ,    0x01         ,    0      },  // Field: F_MCP16502_OUT4_CFG__RCON
    {  0x45              ,    0x02         ,    1      },  // Field: F_MCP16502_OUT4_CFG__REN
    {  0x45              ,    0x0C         ,    2      },  // Field: F_MCP16502_OUT4_CFG__DVSR
    {  0x45              ,    0x10         ,    4      },  // Field: F_MCP16502_OUT4_CFG__PHASE
    {  0x45              ,    0x20         ,    5      },  // Field: F_MCP16502_OUT4_CFG__DISCH
    {  0x45              ,    0x40         ,    6      },  // Field: F_MCP16502_OUT4_CFG__HCPEN
    {  0x45              ,    0x80         ,    7      },  // Field: F_MCP16502_OUT4_CFG__FLTMSK
    // LDO1-A register
    {  0x50              ,    0xFF         ,    0      },  // Register: R_MCP16502_LDO1_A
    {  0x50              ,    0x3F         ,    0      },  // Field: F_MCP16502_LDO1_A__VSET
    {  0x50              ,    0x00         ,    6      },  // Field: F_MCP16502_LDO1_A__UNUSED
    {  0x50              ,    0x80         ,    7      },  // Field: F_MCP16502_LDO1_A__EN
    // LDO1-LPM register
    {  0x51              ,    0xFF         ,    0      },  // Register: R_MCP16502_LDO1_LPM
    {  0x51              ,    0x3F         ,    0      },  // Field: F_MCP16502_LDO1_LPM__VSET
    {  0x51              ,    0x00         ,    6      },  // Field: F_MCP16502_LDO1_LPM__UNUSED
    {  0x51              ,    0x80         ,    7      },  // Field: F_MCP16502_LDO1_LPM__EN
    // LDO1-HIB register
    {  0x52              ,    0xFF         ,    0      },  // Register: R_MCP16502_LDO1_HIB
    {  0x52              ,    0x3F         ,    0      },  // Field: F_MCP16502_LDO1_HIB__VSET
    {  0x52              ,    0x00         ,    6      },  // Field: F_MCP16502_LDO1_HIB__UNUSED
    {  0x52              ,    0x80         ,    7      },  // Field: F_MCP16502_LDO1_HIB__EN
    // LDO1-HPM register
    {  0x53              ,    0xFF         ,    0      },  // Register: R_MCP16502_LDO1_HPM
    {  0x53              ,    0x3F         ,    0      },  // Field: F_MCP16502_LDO1_HPM__VSET
    {  0x53              ,    0x00         ,    6      },  // Field: F_MCP16502_LDO1_HPM__UNUSED
    {  0x53              ,    0x80         ,    7      },  // Field: F_MCP16502_LDO1_HPM__EN
    // LDO1-SEQ register
    {  0x54              ,    0xFF         ,    0      },  // Register: R_MCP16502_LDO1_SEQ
    {  0x54              ,    0x07         ,    0      },  // Field: F_MCP16502_LDO1_SEQ__DELAY
    {  0x54              ,    0x08         ,    3      },  // Field: F_MCP16502_LDO1_SEQ__SEQEN
    {  0x54              ,    0x30         ,    4      },  // Field: F_MCP16502_LDO1_SEQ__SEQ
    {  0x54              ,    0xC0         ,    6      },  // Field: F_MCP16502_LDO1_SEQ__SSR
    // LDO1-CFG register
    {  0x55              ,    0xFF         ,    0      },  // Register: R_MCP16502_LDO1_CFG
    {  0x55              ,    0x01         ,    0      },  // Field: F_MCP16502_LDO1_CFG__RCON
    {  0x55              ,    0x02         ,    1      },  // Field: F_MCP16502_LDO1_CFG__REN
    {  0x55              ,    0x0C         ,    2      },  // Field: F_MCP16502_LDO1_CFG__DVSR
    {  0x55              ,    0x00         ,    4      },  // Field: F_MCP16502_LDO1_CFG__UNUSED1
    {  0x55              ,    0x20         ,    5      },  // Field: F_MCP16502_LDO1_CFG__DISCH
    {  0x55              ,    0x00         ,    6      },  // Field: F_MCP16502_LDO1_CFG__UNUSED2
    {  0x55              ,    0x80         ,    7      },  // Field: F_MCP16502_LDO1_CFG__FLTMSK
    // LDO2-A register
    {  0x60              ,    0xFF         ,    0      },  // Register: R_MCP16502_LDO2_A
    {  0x60              ,    0x3F         ,    0      },  // Field: F_MCP16502_LDO2_A__VSET
    {  0x60              ,    0x00         ,    6      },  // Field: F_MCP16502_LDO2_A__UNUSED
    {  0x60              ,    0x80         ,    7      },  // Field: F_MCP16502_LDO2_A__EN
    // LDO2-LPM register
    {  0x61              ,    0xFF         ,    0      },  // Register: R_MCP16502_LDO2_LPM
    {  0x61              ,    0x3F         ,    0      },  // Field: F_MCP16502_LDO2_LPM__VSET
    {  0x61              ,    0x00         ,    6      },  // Field: F_MCP16502_LDO2_LPM__UNUSED
    {  0x61              ,    0x80         ,    7      },  // Field: F_MCP16502_LDO2_LPM__EN
    // LDO2-HIB register
    {  0x62              ,    0xFF         ,    0      },  // Register: R_MCP16502_LDO2_HIB
    {  0x62              ,    0x3F         ,    0      },  // Field: F_MCP16502_LDO2_HIB__VSET
    {  0x62              ,    0x00         ,    6      },  // Field: F_MCP16502_LDO2_HIB__UNUSED
    {  0x62              ,    0x80         ,    7      },  // Field: F_MCP16502_LDO2_HIB__EN
    // LDO2-HPM register
    {  0x63              ,    0xFF         ,    0      },  // Register: R_MCP16502_LDO2_HPM
    {  0x63              ,    0x3F         ,    0      },  // Field: F_MCP16502_LDO2_HPM__VSET
    {  0x63              ,    0x00         ,    6      },  // Field: F_MCP16502_LDO2_HPM__UNUSED
    {  0x63              ,    0x80         ,    7      },  // Field: F_MCP16502_LDO2_HPM__EN
    // LDO2-SEQ register
    {  0x64              ,    0xFF         ,    0      },  // Register: R_MCP16502_LDO2_SEQ
    {  0x64              ,    0x07         ,    0      },  // Field: F_MCP16502_LDO2_SEQ__DELAY
    {  0x64              ,    0x08         ,    3      },  // Field: F_MCP16502_LDO2_SEQ__SEQEN
    {  0x64              ,    0x30         ,    4      },  // Field: F_MCP16502_LDO2_SEQ__SEQ
    {  0x64              ,    0xC0         ,    6      },  // Field: F_MCP16502_LDO2_SEQ__SSR
    // LDO2-CFG register
    {  0x65              ,    0xFF         ,    0      },  // Register: R_MCP16502_LDO2_CFG
    {  0x65              ,    0x01         ,    0      },  // Field: F_MCP16502_LDO2_CFG__RCON
    {  0x65              ,    0x02         ,    1      },  // Field: F_MCP16502_LDO2_CFG__REN
    {  0x65              ,    0x0C         ,    2      },  // Field: F_MCP16502_LDO2_CFG__DVSR
    {  0x65              ,    0x00         ,    4      },  // Field: F_MCP16502_LDO2_CFG__UNUSED1
    {  0x65              ,    0x20         ,    5      },  // Field: F_MCP16502_LDO2_CFG__DISCH
    {  0x65              ,    0x00         ,    6      },  // Field: F_MCP16502_LDO2_CFG__UNUSED2
    {  0x65              ,    0x80         ,    7      }   // Field: F_MCP16502_LDO2_CFG__FLTMSK
};

/* ************************************************************************** */
/* ************************************************************************** */
// Section: Interface Functions                                               */
/* ************************************************************************** */
/* ************************************************************************** */


// Opens the I2C driver for communication with the PMIC device.
// Stores the I2C instance index and device address for future operations.
// Returns EXIT_SUCCESS on success, EXIT_FAILURE on error.
static uint32_t __PMIC_OpenI2C( SYS_MODULE_INDEX i2c_instance_index, const uint8_t i2c_device_address )
{
    uint32_t ret = EXIT_SUCCESS;
    s_i2c_device_base_address = i2c_device_address;
    s_drv_i2c_inst_index = i2c_instance_index;

    // Open I2C driver
    s_drv_i2c_handle = DRV_I2C_Open(s_drv_i2c_inst_index, DRV_IO_INTENT_SHARED);

    if (s_drv_i2c_handle == DRV_HANDLE_INVALID)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nSYS_ERROR_ERROR Failed to open I2C instance index %u", i2c_instance_index);
        ret = EXIT_FAILURE;
    }
    else
    {
        // Setup I2C driver with 400kHz clock speed
        DRV_I2C_TRANSFER_SETUP setup = {.clockSpeed = 400000};
        bool setup_ret = DRV_I2C_TransferSetup( s_drv_i2c_handle, &setup );
        SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nSYS_ERROR_DEBUG I2C handle 0x%X return %u", s_drv_i2c_handle, setup_ret);
        if ( !setup_ret )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nI2C handle 0x%X failed with error %u", s_drv_i2c_handle, DRV_I2C_ErrorGet( s_drv_i2c_handle ) );
            ret = EXIT_FAILURE;
        }
    }
    return ret;
}

// Reads data from a PMIC register over I2C.
// register_offset_to_read: Register address to read from.
// read_buffer: Buffer to store the read data.
// read_buffer_size: Number of bytes to read.
// Returns EXIT_SUCCESS on success, EXIT_FAILURE on error.
static uint32_t __PMIC_ReadI2C( const uint8_t register_offset_to_read,
                                uint8_t* const read_buffer,
                                const size_t read_buffer_size )
{
    uint32_t ret = EXIT_SUCCESS;
    uint8_t* const write_buffer = (uint8_t * const)&register_offset_to_read;

    if ( !DRV_I2C_WriteReadTransfer( s_drv_i2c_handle, s_i2c_device_base_address,
                                     write_buffer, 1, read_buffer, read_buffer_size ) )
    {
        SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nSYS_ERROR_ERROR failed to read %u bytes @offset=0x%04X of I2C handle 0x%X: error %u", 
                            read_buffer_size, register_offset_to_read, s_drv_i2c_handle, DRV_I2C_ErrorGet( s_drv_i2c_handle ));
        ret = EXIT_FAILURE;
    }
    return ret;
}

// Writes data to a PMIC register over I2C.
// register_offset_to_write: Register address to write to.
// write_buffer: Data to write.
// write_buffer_size: Number of bytes to write.
// Returns EXIT_SUCCESS on success, EXIT_FAILURE on error.
static uint32_t __PMIC_WriteI2C( const uint8_t register_offset_to_write,
                                 const uint8_t* const write_buffer,
                                 const size_t write_buffer_size )
{
    uint32_t ret = EXIT_FAILURE;
    size_t full_write_buffer_size = write_buffer_size + 1;
    uint8_t* const full_write_buffer = (uint8_t * const)malloc( full_write_buffer_size * sizeof(uint8_t) );

    if (full_write_buffer != NULL)
    {
        // First byte is register offset, followed by data
        full_write_buffer[0] = register_offset_to_write;
        memcpy( full_write_buffer + 1, write_buffer, write_buffer_size );

        if ( !DRV_I2C_WriteTransfer( s_drv_i2c_handle, s_i2c_device_base_address, full_write_buffer, full_write_buffer_size) )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "Failed to write %u bytes @offset=0x%04X of I2C handle 0x%X: error %u", 
                        write_buffer_size, register_offset_to_write, s_drv_i2c_handle, DRV_I2C_ErrorGet( s_drv_i2c_handle ));
            ret = EXIT_FAILURE;
        }
        else
        {
            ret = EXIT_SUCCESS;
        }
        free(full_write_buffer);
    }
    else
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "Failed to allocate memory for I2C write buffer");
        ret = EXIT_FAILURE;
    }
    return ret;
}

// Closes the I2C driver handle if open.
// Returns EXIT_SUCCESS on success, EXIT_FAILURE if an error was reported.
static uint32_t __PMIC_CloseI2C(void)
{
    uint32_t ret = EXIT_SUCCESS;
    if ( s_drv_i2c_handle != DRV_HANDLE_INVALID )
    {
        DRV_I2C_ERROR i2c_error_code = DRV_I2C_ErrorGet( s_drv_i2c_handle );
        DRV_I2C_Close( s_drv_i2c_handle );
        s_drv_i2c_handle = 0;
        if ( i2c_error_code != DRV_I2C_ERROR_NONE )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nI2C driver reported an error %u", i2c_error_code);
            ret = EXIT_FAILURE;
        }
    }
    return ret;
}

// Converts a VSET code to the corresponding output voltage (VOUT) in mV, based on the range.
// Returns the voltage in mV, or (uint16_t)-1 if VSET is invalid.
static uint16_t __PMIC_GetVoutFromVset( uint8_t vset, vout_range_t range )
{
    uint16_t ret = (uint16_t)-1;
    if ( ( vset < VSET_MIN ) || ( vset > VSET_MAX ) )
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nInvalid VSET value 0x%02X. Please refer to the datasheet.", vset);
    }
    else
    {
        ret = s_vset_map[vset - VSET_MIN].vout[range];
    }
    return ret;
}

// Converts a voltage (VOUT) in mV to the corresponding VSET code, based on the range.
// Returns the VSET code, or (uint8_t)-1 if VOUT is invalid.
static uint8_t __PMIC_GetVsetFromVout( uint16_t vout, vout_range_t range )
{
    uint8_t ret = (uint8_t)-1;
    for (uint8_t i = 0; i < (VSET_MAX - VSET_MIN + 1); i++)
    {
        if ( s_vset_map[i].vout[range] == vout )
        {
            ret = s_vset_map[i].vset;
            break;
        }
    }
    if (ret == (uint8_t)-1)
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nInvalid VOUT value %u. Please refer to the datasheet", vout);
    }
    return ret;
}

// Checks if a register_id corresponds to a valid regulator register.
// include_LDO: If true, includes LDO registers in the check.
// Returns true if valid, false otherwise.
static bool __PMIC_IsValidRegulatorRegister( const pmic_reg_field_id_t register_id, bool include_LDO )
{
    switch( register_id )
    {
        // OUT1 registers
        case R_MCP16502_OUT1_A:
        case R_MCP16502_OUT1_LPM:
        case R_MCP16502_OUT1_HIB:
        case R_MCP16502_OUT1_HPM:
        // OUT2 registers
        case R_MCP16502_OUT2_A:
        case R_MCP16502_OUT2_LPM:
        case R_MCP16502_OUT2_HIB:
        case R_MCP16502_OUT2_HPM:
        // OUT3 registers
        case R_MCP16502_OUT3_A:
        case R_MCP16502_OUT3_LPM:
        case R_MCP16502_OUT3_HIB:
        case R_MCP16502_OUT3_HPM:
        // OUT4 registers
        case R_MCP16502_OUT4_A:
        case R_MCP16502_OUT4_LPM:
        case R_MCP16502_OUT4_HIB:
        case R_MCP16502_OUT4_HPM:
            return true;

        // LDO1 registers
        case R_MCP16502_LDO1_A:
        case R_MCP16502_LDO1_LPM:
        case R_MCP16502_LDO1_HIB:
        case R_MCP16502_LDO1_HPM:
        // LDO2 registers
        case R_MCP16502_LDO2_A:
        case R_MCP16502_LDO2_LPM:
        case R_MCP16502_LDO2_HIB:
        case R_MCP16502_LDO2_HPM:
            if ( !include_LDO )
            {
                return false;
            } 
            else
            {
                return true;
            }
        default:
            return false;
    }
}


// Determines the voltage output range for a given register_id.
// Returns the corresponding vout_range_t.
static vout_range_t __PMIC_GetVoutRange( const pmic_reg_field_id_t register_id )
{
    vout_range_t ret = VOUT_RANGE_B1_L1_L2;
    if ( ( register_id >= R_MCP16502_OUT2_A ) && ( register_id < R_MCP16502_LDO1_A ) )
    {
        ret = VOUT_RANGE_B2_B3_B4;
    }
    return ret;
}

// Checks if a register or field ID is valid.
// Returns EXIT_SUCCESS if valid, EXIT_FAILURE otherwise.
static uint32_t __PMIC_CheckFieldID( const pmic_reg_field_id_t register_or_field_id )
{
    uint32_t ret = EXIT_SUCCESS;
    if ( register_or_field_id > F_MCP16502_LDO2_CFG__FLTMSK )
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nInvalid register or field ID %u", register_or_field_id);
        ret = EXIT_FAILURE;
    }
    return ret;
}

// Extracts a field value from a register value using mask and shift.
// Returns the extracted field value.
uint8_t __PMIC_ExtractFieldFromRegisterValue( const pmic_reg_field_id_t field_id, const uint8_t register_value )
{
    uint8_t field_value = 0;
    pmic_reg_field_info_t field_info = s_reg_field_info[ field_id ];

    field_value = register_value & field_info.mask;
    field_value >>= field_info.shift;

    return field_value;
}

// Inserts a field value into a register value using mask and shift.
// Returns EXIT_SUCCESS on success, EXIT_FAILURE if field_value is out of range.
uint32_t __PMIC_InsertFieldIntoRegisterValue( const pmic_reg_field_id_t field_id, const uint8_t field_value, uint8_t* const register_value )
{
    uint32_t ret = EXIT_SUCCESS;
    pmic_reg_field_info_t field_info = s_reg_field_info[ field_id ];

    if ( field_value > ( field_info.mask >> field_info.shift ) )
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nField value %u is out of range %u", field_value, field_info.mask >> field_info.shift);
        ret = EXIT_FAILURE;
    }
    else
    {
        *register_value &= ~field_info.mask;
        *register_value |= field_value << field_info.shift;
    }
    return ret;
}

// Public API: Opens the PMIC device using the specified I2C address.
uint32_t PMIC_Open( const uint8_t i2c_device_address )
{
    return __PMIC_OpenI2C( MCP16502_DRV_I2C_INDEX, i2c_device_address );
}

// Reads the device info (system address and ID) from the PMIC.
uint32_t PMIC_GetDeviceInfo( uint8_t* const sys_addr, uint8_t* const sys_id )
{
    uint32_t ret = EXIT_SUCCESS;
    if ( PMIC_GetRegisterOrFieldValue( R_MCP16502_SYS_ADR, sys_addr ) != EXIT_SUCCESS )
    {
        ret = EXIT_FAILURE;
    }
    else if ( PMIC_GetRegisterOrFieldValue( R_MCP16502_SYS_ID, sys_id ) != EXIT_SUCCESS )
    {
        ret = EXIT_FAILURE;
    }
    return ret;
}

// Reads the system timing and configuration registers and populates the sys_tmg_cfg structure.
uint32_t PMIC_GetSysTimingAndConfig( pmic_sys_tmg_cfg_t* const sys_tmg_cfg )
{
    uint32_t ret = EXIT_SUCCESS;
    uint8_t reg_value = 0;

    // Read SYS-TMG register
    if ( PMIC_GetRegisterOrFieldValue( R_MCP16502_SYS_TMG, &reg_value) != EXIT_SUCCESS )
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Populate SYS-TMG field structure
        sys_tmg_cfg->sys_tmp_RSTDLY = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_SYS_TMG__RSTDLY, reg_value );
        sys_tmg_cfg->sys_tmp_PBINTTO = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_SYS_TMG__PBINTTO, reg_value );
        sys_tmg_cfg->sys_tmp_PBTO = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_SYS_TMG__PBTO, reg_value );

        // Read SYS-CFG register
        if ( PMIC_GetRegisterOrFieldValue( R_MCP16502_SYS_CFG, &reg_value) != EXIT_SUCCESS )
        {
            ret = EXIT_FAILURE;
        }
        else
        {
            // Populate SYS-CFG field structure
            sys_tmg_cfg->sys_cfg_USER = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_SYS_CFG__USER, reg_value );
            sys_tmg_cfg->sys_cfg_B1HCEN = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_SYS_CFG__B1HCEN, reg_value );
            sys_tmg_cfg->sys_cfg_FSD = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_SYS_CFG__FSD, reg_value );
            sys_tmg_cfg->sys_cfg_AWKPDIS = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_SYS_CFG__AWKPDIS, reg_value );
            sys_tmg_cfg->sys_cfg_HPMPEN = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_SYS_CFG__HPMPEN, reg_value );
            sys_tmg_cfg->sys_cfg_TWRMSK = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_SYS_CFG__TWRMSK, reg_value );
            sys_tmg_cfg->sys_cfg_TSDMSK = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_SYS_CFG__TSDMSK, reg_value );
        }
    }
    return ret;
}

// Sets the system timing and configuration registers from the sys_tmg_cfg structure.
uint32_t PMIC_SetSysTimingAndConfig( const pmic_sys_tmg_cfg_t sys_tmg_cfg )
{
    uint32_t err = 0;
    uint8_t reg_value;

    // Populate SYS-TMG fields
    reg_value = 0;
    err += __PMIC_InsertFieldIntoRegisterValue( F_MCP16502_SYS_TMG__RSTDLY, sys_tmg_cfg.sys_tmp_RSTDLY, &reg_value );
    err += __PMIC_InsertFieldIntoRegisterValue( F_MCP16502_SYS_TMG__PBINTTO, sys_tmg_cfg.sys_tmp_PBINTTO, &reg_value );
    err += __PMIC_InsertFieldIntoRegisterValue( F_MCP16502_SYS_TMG__PBTO, sys_tmg_cfg.sys_tmp_PBTO, &reg_value );

    uint32_t ret = EXIT_SUCCESS;
    if ( err || ( PMIC_SetRegisterOrFieldValue( R_MCP16502_SYS_TMG, reg_value) != EXIT_SUCCESS) )
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Populate SYS-CFG fields
        reg_value = 0;
        err += __PMIC_InsertFieldIntoRegisterValue( F_MCP16502_SYS_CFG__USER, sys_tmg_cfg.sys_cfg_USER, &reg_value );
        err += __PMIC_InsertFieldIntoRegisterValue( F_MCP16502_SYS_CFG__B1HCEN, sys_tmg_cfg.sys_cfg_B1HCEN, &reg_value );
        err += __PMIC_InsertFieldIntoRegisterValue( F_MCP16502_SYS_CFG__FSD, sys_tmg_cfg.sys_cfg_FSD, &reg_value );
        err += __PMIC_InsertFieldIntoRegisterValue( F_MCP16502_SYS_CFG__AWKPDIS, sys_tmg_cfg.sys_cfg_AWKPDIS, &reg_value );
        err += __PMIC_InsertFieldIntoRegisterValue( F_MCP16502_SYS_CFG__HPMPEN, sys_tmg_cfg.sys_cfg_HPMPEN, &reg_value );
        err += __PMIC_InsertFieldIntoRegisterValue( F_MCP16502_SYS_CFG__TWRMSK, sys_tmg_cfg.sys_cfg_TWRMSK, &reg_value );
        err += __PMIC_InsertFieldIntoRegisterValue( F_MCP16502_SYS_CFG__TSDMSK, sys_tmg_cfg.sys_cfg_TSDMSK, &reg_value );

        if ( err || ( PMIC_SetRegisterOrFieldValue( R_MCP16502_SYS_CFG, reg_value) != EXIT_SUCCESS ) )
        {
            ret = EXIT_FAILURE;
        }
    }
    return ret;
}

// Reads a register or field value from the PMIC.
// Returns EXIT_SUCCESS on success, EXIT_FAILURE on error.
uint32_t PMIC_GetRegisterOrFieldValue( const pmic_reg_field_id_t register_or_field_id, uint8_t* const field_value )
{
    uint32_t ret = EXIT_SUCCESS;
    if ( __PMIC_CheckFieldID( register_or_field_id ) != EXIT_SUCCESS )
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        uint8_t reg_value = 0;
        pmic_reg_field_info_t field_info = s_reg_field_info[ register_or_field_id ];

        if ( __PMIC_ReadI2C( field_info.addr, &reg_value, sizeof(uint8_t)) != EXIT_SUCCESS )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read PMIC @0x%02X", field_info.addr);
            ret = EXIT_FAILURE;
        }
        else
        {
            *field_value = reg_value & field_info.mask;
            *field_value >>= field_info.shift;

            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nReading PMIC @0x%02X (mask = 0x%02X, shift = %u): reg=0x%02X => field=0x%02X", field_info.addr, field_info.mask, field_info.shift, reg_value, *field_value);
        }
    }
    return ret;
}

// Writes a field value to a PMIC register.
// Returns EXIT_SUCCESS on success, EXIT_FAILURE on error.
uint32_t PMIC_SetRegisterOrFieldValue( const pmic_reg_field_id_t register_or_field_id, uint8_t const field_value )
{
    uint32_t ret = EXIT_SUCCESS;
    if ( __PMIC_CheckFieldID( register_or_field_id ) != EXIT_SUCCESS )
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        uint8_t old_value, new_value = 0;
        pmic_reg_field_info_t field_info = s_reg_field_info[ register_or_field_id ];

        if ( field_value > (field_info.mask >> field_info.shift) )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nValue to write 0x%02X is out of range 0x%02X", field_value, field_info.mask >> field_info.shift);
            ret = EXIT_FAILURE;
        }
        else
        {
            if ( __PMIC_ReadI2C( field_info.addr, &old_value, sizeof(uint8_t)) != EXIT_SUCCESS )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nFailed to read PMIC @0x%02X", field_info.addr);
                ret = EXIT_FAILURE;
            }
            else
            {
                new_value  = old_value & ~field_info.mask;    // Clear the field bits
                new_value |= field_value << field_info.shift;     // Set the field bits

                if ( __PMIC_WriteI2C( field_info.addr, &new_value, sizeof(uint8_t)) != EXIT_SUCCESS )
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nFailed to write %u on PMIC @0x%02X", new_value, field_info.addr);
                    ret = EXIT_FAILURE;
                }
            }
        }
    }
    return ret;
}

// Reads the system status register and populates the system_status structure.
uint32_t PMIC_GetSystemStatus( pmic_system_status_t* const system_status )
{
    uint32_t ret = EXIT_SUCCESS;
    uint8_t reg_value = 0;

    // Read STS-SYS register
    if ( PMIC_GetRegisterOrFieldValue( R_MCP16502_STS_SYS, &reg_value) != EXIT_SUCCESS )
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Populate SYS-TMG field structure
        system_status->sts_sys_PBINT = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_STS_SYS__PBINT, reg_value );
        system_status->sts_sys_TWR = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_STS_SYS__TWR, reg_value );
        system_status->sts_sys_TSD = __PMIC_ExtractFieldFromRegisterValue( F_MCP16502_STS_SYS__TSD, reg_value );
    }
    return ret;
}

// Reads the status of a specific regulator and populates the regulator_status structure.
uint32_t PMIC_GetRegulatorStatus( const pmic_regulator_id_t regulator_id, pmic_regulator_status_t* const regulator_status )
{
    uint32_t ret = EXIT_SUCCESS;
    uint8_t reg_value = 0;
    pmic_reg_field_id_t register_id = s_pmic_register_offset_status[regulator_id];

    // Read STS-SYS register
    if ( PMIC_GetRegisterOrFieldValue( register_id, &reg_value ) != EXIT_SUCCESS )
    {
        ret = EXIT_FAILURE;
    }
    else
    {
        // Populate SYS-TMG field structure
        regulator_status->sts_sys_ENS = __PMIC_ExtractFieldFromRegisterValue( register_id + MCP16502_STATUS_ID_OFFSET_ENS, reg_value ) != 0;
        regulator_status->sts_sys_POK = __PMIC_ExtractFieldFromRegisterValue( register_id + MCP16502_STATUS_ID_OFFSET_POK, reg_value ) != 0;
        regulator_status->sts_sys_SSD = __PMIC_ExtractFieldFromRegisterValue( register_id + MCP16502_STATUS_ID_OFFSET_SSD, reg_value ) != 0;
        regulator_status->sts_sys_ILIM = __PMIC_ExtractFieldFromRegisterValue( register_id + MCP16502_STATUS_ID_OFFSET_ILIM, reg_value ) != 0;
        regulator_status->sts_sys_ZCD = __PMIC_ExtractFieldFromRegisterValue( register_id + MCP16502_STATUS_ID_OFFSET_ZCD, reg_value ) != 0;
        regulator_status->sts_sys_ILIMNEG = __PMIC_ExtractFieldFromRegisterValue( register_id + MCP16502_STATUS_ID_OFFSET_ILIMNEG, reg_value ) != 0;
        regulator_status->sts_sys_HICCUP = __PMIC_ExtractFieldFromRegisterValue( register_id + MCP16502_STATUS_ID_OFFSET_HICCUP, reg_value ) != 0;
        regulator_status->sts_sys_FLT = __PMIC_ExtractFieldFromRegisterValue( register_id + MCP16502_STATUS_ID_OFFSET_FLT, reg_value ) != 0;
    }
    return ret;
}

// Sets the voltage and mode for a specific regulator and state.
// Returns EXIT_SUCCESS on success, EXIT_FAILURE on error.
uint32_t PMIC_SetRegulatorSettings( const pmic_regulator_id_t regulator_id,
                                    const pmic_state_id_t state_id,
                                    const uint32_t voltage_in_mv,
                                    const pmic_mode_t mode )
{
    uint32_t ret = EXIT_SUCCESS;
    pmic_reg_field_id_t register_id = s_pmic_register_offset_mode[regulator_id] + MCP16502_MODE_ID_OFFSET * state_id;

    // Check register_id is actually targeting a regulator mode register
    if ( !__PMIC_IsValidRegulatorRegister( register_id, true ) )
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nRegister ID %u does not target a valid regulator register", register_id);
        ret = EXIT_FAILURE;
    }
    else
    {
        vout_range_t vout_range = __PMIC_GetVoutRange( register_id );
        uint8_t vset = __PMIC_GetVsetFromVout( voltage_in_mv, vout_range );
        if ( vset == (uint8_t)-1 )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to convert VOUT=%lu to a valid VSET for register ID %u", voltage_in_mv, register_id);
            ret = EXIT_FAILURE;
        }
        else
        {
            pmic_reg_field_info_t reg_info = s_reg_field_info[ register_id ];

            uint8_t old_value = 0, new_value;

            if ( __PMIC_ReadI2C( reg_info.addr, &old_value, sizeof(uint8_t)) != EXIT_SUCCESS )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read PMIC @0x%02X", reg_info.addr);
                ret = EXIT_FAILURE;
            }
            else
            {
                pmic_reg_field_info_t vset_info = s_reg_field_info[ register_id + MCP16502_MODE_ID_OFFSET_VSET ];
                pmic_reg_field_info_t mode_info = s_reg_field_info[ register_id + MCP16502_MODE_ID_OFFSET_MODE ];

                // Clear VSET and MODe bits
                new_value  = old_value & ~( vset_info.mask | mode_info.mask );
                // Set VSET and MODe bits
                new_value |= ( vset << vset_info.shift ) | ( mode << mode_info.shift );

                if ( __PMIC_WriteI2C( reg_info.addr, &new_value, sizeof(uint8_t)) != EXIT_SUCCESS )
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to write %u on PMIC @0x%02X", new_value, reg_info.addr);
                    ret = EXIT_FAILURE;
                }
            }
        }
    }
    return ret;
}

// Reads the voltage, mode, and enable status for a specific regulator and state.
uint32_t PMIC_GetRegulatorSettings( const pmic_regulator_id_t regulator_id,
                                    const pmic_state_id_t state_id,
                                    uint32_t* const p_voltage_in_mv,
                                    pmic_mode_t* const p_mode,
                                    bool* const p_enabled )
{
    uint32_t ret = EXIT_SUCCESS;
    pmic_reg_field_id_t register_id = s_pmic_register_offset_mode[regulator_id] + MCP16502_MODE_ID_OFFSET * state_id;

    // Check register_id is actually targeting a regulator register
    if ( !__PMIC_IsValidRegulatorRegister( register_id, true ) )
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nRegister ID %u does not target a valid regulator mode register", register_id);
        ret = EXIT_FAILURE;
    }
    else
    {
        // Get the VSET and compute the associated VOUT
        if ( p_voltage_in_mv != NULL )
        {
            uint8_t vset = 0;
            if ( PMIC_GetRegisterOrFieldValue( register_id + MCP16502_MODE_ID_OFFSET_VSET, &vset ) != EXIT_SUCCESS )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read VSET bits of register ID %u", register_id);
                ret = EXIT_FAILURE + 1;
            }
            else
            {
                vout_range_t vout_range = __PMIC_GetVoutRange( register_id );
                *p_voltage_in_mv = __PMIC_GetVoutFromVset( vset, vout_range );
                if ( *p_voltage_in_mv == (uint16_t)-1 )
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to convert VSET=0x%02X to a valid voltage for register ID %u", vset, register_id);
                    ret = EXIT_FAILURE + 2;
                }
            }
        }

        // Get the MODE bit
        if ((ret == EXIT_SUCCESS) && (p_mode != NULL))
        {
            if ( PMIC_GetRegisterOrFieldValue( register_id + MCP16502_MODE_ID_OFFSET_MODE, p_mode ) != EXIT_SUCCESS )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read VSET bits of register ID %u", register_id);
                ret = EXIT_FAILURE + 3;
            }
        }

        // Get the EN bit
        if ((ret == EXIT_SUCCESS) && (p_enabled != NULL))
        {
            uint8_t en;
            if ( PMIC_GetRegisterOrFieldValue( register_id + MCP16502_MODE_ID_OFFSET_EN, &en ) != EXIT_SUCCESS )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read VSET bits of register ID %u", register_id);
                ret = EXIT_FAILURE + 4;
            }
            else
            {
                *p_enabled = en ? true : false;
            }
        }
    }
    return ret;
}

// Enables or disables a specific regulator for a given state.
// Returns EXIT_SUCCESS on success, EXIT_FAILURE on error.
uint32_t PMIC_EnableDisableRegulator( const pmic_regulator_id_t regulator_id,
                                      const pmic_state_id_t state_id,
                                      const bool enable )
{
    uint32_t ret = EXIT_SUCCESS;
    pmic_reg_field_id_t register_id = s_pmic_register_offset_mode[regulator_id] + MCP16502_MODE_ID_OFFSET * state_id;

    // Check register_id is actually targeting a regulator mode register
    if ( !__PMIC_IsValidRegulatorRegister( register_id, true ) )
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nRegister ID %u does not target a valid regulator mode register", register_id);
        ret = EXIT_FAILURE;
    }
    else
    {
        uint8_t field_value = enable ? 1 : 0;

        if ( PMIC_SetRegisterOrFieldValue( register_id + MCP16502_MODE_ID_OFFSET_EN, field_value ) != EXIT_SUCCESS )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to write %u to EN bit of register ID %i", field_value, register_id + 3);
            ret = EXIT_FAILURE;
        }
    }
    return ret;
}

// Public API: Closes the PMIC device (I2C handle).
uint32_t PMIC_Close()
{
    return __PMIC_CloseI2C();
}

<#if DRV_MCP16502_mcp_unittest == true>
/* ************************************************************************** */
/* ************************************************************************** */
/* Section: UNIT-TESTING FUNCTIONS                                            */
/* ************************************************************************** */
/* ************************************************************************** */

#define MCP16502_REG_SYS_ADR_DEFAULT_VALUE   0x80

typedef enum 
{
    READ_ONLY,
    READ_CHECK,
    READ_MODIFY_WRITE,
    READ_MODIFY_WRITE_CHECK,
    READ_MODIFY_WRITE_CHECK_RESTORE
} operation_t;

//****************************
// PMIC registers addresses

enum 
{
    MCP16502_REG_ADDR_SYS_ADR     = 0x00,
    MCP16502_REG_ADDR_SYS_ID      = 0x01,
    MCP16502_REG_ADDR_SYS_TMG     = 0x02,
    MCP16502_REG_ADDR_SYS_CFG     = 0x03,

    MCP16502_REG_ADDR_STS_SYS     = 0x04,
    MCP16502_REG_ADDR_STS_B1      = 0x05,
    MCP16502_REG_ADDR_STS_B2      = 0x06,
    MCP16502_REG_ADDR_STS_B3      = 0x07,
    MCP16502_REG_ADDR_STS_B4      = 0x08,
    MCP16502_REG_ADDR_STS_L1      = 0x09,
    MCP16502_REG_ADDR_STS_L2      = 0x0A,

    MCP16502_REG_ADDR_OUT1_A      = 0x10,
    MCP16502_REG_ADDR_OUT1_LPM    = 0x11,
    MCP16502_REG_ADDR_OUT1_HIB    = 0x12,
    MCP16502_REG_ADDR_OUT1_HPM    = 0x13,
    MCP16502_REG_ADDR_OUT1_SEQ    = 0x14,
    MCP16502_REG_ADDR_OUT1_CFG    = 0x15,

    MCP16502_REG_ADDR_OUT2_A      = 0x20,
    MCP16502_REG_ADDR_OUT2_LPM    = 0x21,
    MCP16502_REG_ADDR_OUT2_HIB    = 0x22,
    MCP16502_REG_ADDR_OUT2_HPM    = 0x23,
    MCP16502_REG_ADDR_OUT2_SEQ    = 0x24,
    MCP16502_REG_ADDR_OUT2_CFG    = 0x25,

    MCP16502_REG_ADDR_OUT3_A      = 0x30,
    MCP16502_REG_ADDR_OUT3_LPM    = 0x31,
    MCP16502_REG_ADDR_OUT3_HIB    = 0x32,
    MCP16502_REG_ADDR_OUT3_HPM    = 0x33,
    MCP16502_REG_ADDR_OUT3_SEQ    = 0x34,
    MCP16502_REG_ADDR_OUT3_CFG    = 0x35,

    MCP16502_REG_ADDR_OUT4_A      = 0x40,
    MCP16502_REG_ADDR_OUT4_LPM    = 0x41,
    MCP16502_REG_ADDR_OUT4_HIB    = 0x42,
    MCP16502_REG_ADDR_OUT4_HPM    = 0x43,
    MCP16502_REG_ADDR_OUT4_SEQ    = 0x44,
    MCP16502_REG_ADDR_OUT4_CFG    = 0x45,

    MCP16502_REG_ADDR_LDO1_A      = 0x50,
    MCP16502_REG_ADDR_LDO1_LPM    = 0x51,
    MCP16502_REG_ADDR_LDO1_HIB    = 0x52,
    MCP16502_REG_ADDR_LDO1_HPM    = 0x53,
    MCP16502_REG_ADDR_LDO1_SEQ    = 0x54,
    MCP16502_REG_ADDR_LDO1_CFG    = 0x55,

    MCP16502_REG_ADDR_LDO2_A      = 0x60,
    MCP16502_REG_ADDR_LDO2_LPM    = 0x61,
    MCP16502_REG_ADDR_LDO2_HIB    = 0x62,
    MCP16502_REG_ADDR_LDO2_HPM    = 0x63,
    MCP16502_REG_ADDR_LDO2_SEQ    = 0x64,
    MCP16502_REG_ADDR_LDO2_CFG    = 0x65
} pmic_register_addr_e;


// Unit test to verify that the size of the register/field enum matches the size of the s_reg_field_info array.
// Returns EXIT_SUCCESS if sizes match, EXIT_FAILURE otherwise.
uint32_t MCP16502_UNITTEST_registers_and_fields_table_sizes()
{
    uint32_t ret = EXIT_SUCCESS;
    uint32_t sizeof_enum = F_MCP16502_LDO2_CFG__FLTMSK + 1;
    uint32_t sizeof_array = sizeof(s_reg_field_info) / sizeof(s_reg_field_info[0]);

    if ( sizeof_enum != sizeof_array )
    {
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nRegister and field definition array sizes do not match: Size of enum (= %u) and size of array (= %u)", sizeof_enum, sizeof_array);
        ret = EXIT_FAILURE;
    }
    return ret;
}

// Unit test to verify read/write access to all PMIC registers and fields.
// Performs read, write, and restore operations depending on register type.
// Returns EXIT_SUCCESS if all accesses succeed, EXIT_FAILURE otherwise.
uint32_t MCP16502_UNITTEST_registers_and_fields_accesses()
{
    uint32_t ret = EXIT_SUCCESS;
    uint8_t val_origin, val, val_expect;
    operation_t operation;
    pmic_reg_field_info_t field_info;
    uint8_t* p_new_value = NULL;
    uint8_t new_value;

    // Iterate over all register/field IDs
    for (pmic_reg_field_id_t field_idx = 0; field_idx <= F_MCP16502_LDO2_CFG__FLTMSK && ret == EXIT_SUCCESS; field_idx++)
    {
        field_info = s_reg_field_info[field_idx];
        p_new_value = NULL;

        // Determine the type of operation to perform based on register address
        switch (field_info.addr)
        {
            case MCP16502_REG_ADDR_SYS_ADR:
                operation = READ_CHECK;
                val_expect = MCP16502_REG_SYS_ADR_DEFAULT_VALUE + s_i2c_device_base_address;
                break;
            case MCP16502_REG_ADDR_SYS_ID:
                operation = READ_ONLY;
                break;
            case MCP16502_REG_ADDR_SYS_TMG:
            case MCP16502_REG_ADDR_SYS_CFG:
                operation = READ_MODIFY_WRITE_CHECK_RESTORE;
                break;
            // Status registers are read-only
            case MCP16502_REG_ADDR_STS_SYS:
            case MCP16502_REG_ADDR_STS_B1:
            case MCP16502_REG_ADDR_STS_B2:
            case MCP16502_REG_ADDR_STS_B3:
            case MCP16502_REG_ADDR_STS_B4:
            case MCP16502_REG_ADDR_STS_L1:
            case MCP16502_REG_ADDR_STS_L2:
                operation = READ_ONLY;
                break;
            // Regulator mode registers: test read-modify-write-restore
            case MCP16502_REG_ADDR_OUT1_A:
            case MCP16502_REG_ADDR_OUT1_LPM:
            case MCP16502_REG_ADDR_OUT1_HIB:
            case MCP16502_REG_ADDR_OUT1_HPM:
            case MCP16502_REG_ADDR_OUT2_A:
            case MCP16502_REG_ADDR_OUT2_LPM:
            case MCP16502_REG_ADDR_OUT2_HIB:
            case MCP16502_REG_ADDR_OUT2_HPM:
            case MCP16502_REG_ADDR_OUT3_A:
            case MCP16502_REG_ADDR_OUT3_LPM:
            case MCP16502_REG_ADDR_OUT3_HIB:
            case MCP16502_REG_ADDR_OUT3_HPM:
            case MCP16502_REG_ADDR_OUT4_A:
            case MCP16502_REG_ADDR_OUT4_LPM:
            case MCP16502_REG_ADDR_OUT4_HIB:
            case MCP16502_REG_ADDR_OUT4_HPM:
            case MCP16502_REG_ADDR_LDO1_A:
            case MCP16502_REG_ADDR_LDO1_LPM:
            case MCP16502_REG_ADDR_LDO1_HIB:
            case MCP16502_REG_ADDR_LDO1_HPM:
            case MCP16502_REG_ADDR_LDO2_A:
            case MCP16502_REG_ADDR_LDO2_LPM:
            case MCP16502_REG_ADDR_LDO2_HIB:
            case MCP16502_REG_ADDR_LDO2_HPM:
                operation = READ_MODIFY_WRITE_CHECK_RESTORE;
                new_value = 0xF8;
                p_new_value = &new_value;
                break;
            // Sequence and config registers are read-only
            case MCP16502_REG_ADDR_OUT1_SEQ:
            case MCP16502_REG_ADDR_OUT2_SEQ:
            case MCP16502_REG_ADDR_OUT3_SEQ:
            case MCP16502_REG_ADDR_OUT4_SEQ:
            case MCP16502_REG_ADDR_LDO1_SEQ:
            case MCP16502_REG_ADDR_LDO2_SEQ:
            case MCP16502_REG_ADDR_OUT1_CFG:
            case MCP16502_REG_ADDR_OUT2_CFG:
            case MCP16502_REG_ADDR_OUT3_CFG:
            case MCP16502_REG_ADDR_OUT4_CFG:
            case MCP16502_REG_ADDR_LDO1_CFG:
            case MCP16502_REG_ADDR_LDO2_CFG:
                operation = READ_ONLY;
                break;
            default:
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nUnknown register offset 0x%02X", field_info.addr);
                ret = EXIT_FAILURE;
                break;
        }
        if (ret != EXIT_SUCCESS) break;

        // Read the original value
        val_origin = 0;
        if (PMIC_GetRegisterOrFieldValue(field_idx, &val_origin) != EXIT_SUCCESS)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nPMIC_GetRegisterValue failed on field index %u", field_idx);
            ret = EXIT_FAILURE;
        }
        SYS_DEBUG_PRINT(SYS_ERROR_DEBUG, "\r\nInitial read @x%02X = 0x%02X", field_info.addr, val_origin);

        if (operation == READ_ONLY || ret != EXIT_SUCCESS)
            continue;

        // For READ_CHECK, compare the value to the expected value
        if (operation == READ_CHECK)
        {
            if (val_origin != ((val_expect & field_info.mask) >> field_info.shift))
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nInvalid register value @0x%02X: read 0x%02X but expect 0x%02X", field_info.addr, val_origin, val_expect);
                ret = EXIT_FAILURE;
            }
            continue;
        }

        // For read-modify-write, compute the value to write
        if (p_new_value == NULL)
            val_expect = (~val_origin & field_info.mask) >> field_info.shift;
        else
            val_expect = (new_value & field_info.mask) >> field_info.shift;

        // Write the new value
        if (PMIC_SetRegisterOrFieldValue(field_idx, val_expect) != EXIT_SUCCESS)
        {
            SYS_DEBUG_MESSAGE(SYS_ERROR_ERROR, "\r\nPMIC_SetRegisterValue failed");
            ret = EXIT_FAILURE;
        }
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nWrote 0x%02X @x%02X", val_expect, field_info.addr);

        if (operation == READ_MODIFY_WRITE || ret != EXIT_SUCCESS)
            continue;

        // Read back and check the written value
        val = 0;
        if (PMIC_GetRegisterOrFieldValue(field_idx, &val) != EXIT_SUCCESS)
        {
            SYS_DEBUG_MESSAGE(SYS_ERROR_ERROR, "\r\nPMIC_GetRegisterValue failed");
            ret = EXIT_FAILURE;
        }
        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nRead after write @x%02X = 0x%02X (expect 0x%02X)", field_info.addr, val, val_expect);

        if (val != val_expect)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nInvalid register value @0x%02X: read 0x%02X but expect 0x%02X", field_info.addr, val, val_expect);
            ret = EXIT_FAILURE;
        }
        if (operation == READ_MODIFY_WRITE_CHECK || ret != EXIT_SUCCESS)
            continue;

        // Restore the original value and verify
        if (PMIC_SetRegisterOrFieldValue(field_idx, val_origin) != EXIT_SUCCESS)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to write the original value 0x%02X @0x%02X", val_origin, field_info.addr);
            ret = EXIT_FAILURE;
        }
        if (PMIC_GetRegisterOrFieldValue(field_idx, &val) != EXIT_SUCCESS)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read @0x%02X", field_info.addr);
            ret = EXIT_FAILURE;
        }
        if (val != val_origin)
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to restore original value @0x%02X: read 0x%02X but expect 0x%02X", field_info.addr, val, val_origin);
            ret = EXIT_FAILURE;
        }
    }
    return ret;
}

// Unit test to verify VSET <-> VOUT conversion functions for both voltage ranges.
// Checks that conversions are correct and out-of-range values are handled.
uint32_t MCP16502_UNITTEST_vset_vout_convertion()
{
    uint32_t ret = EXIT_SUCCESS;
    uint16_t vout, vout_exp;
    uint8_t vset, vset_exp;

    // Test VSET to VOUT for B1/L1/L2 range
    for ( vset = 0x0C; vset < 0x41 && ret == EXIT_SUCCESS; vset++ )
    {
        vout = __PMIC_GetVoutFromVset( vset, VOUT_RANGE_B1_L1_L2 );
        if ( ( vset < VSET_MIN ) || ( vset > VSET_MAX ) )
        {
            if ( vout != (uint16_t)-1 )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to detect VSET=0x%02X is out of range", vset);
                ret = EXIT_FAILURE;
            }
            continue;
        }
        vout_exp = VOUT_B1_L1_L2_MIN + VOUT_B1_L1_L2_STEP * (vset - VSET_MIN);
        if ( vout != vout_exp )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to get VOUT on B1/L1/L2 corresponding to VSET=0x%02X: get %u but expect %u", vset, vout, vout_exp);
            ret = EXIT_FAILURE;
        }
    }

    // Test VSET to VOUT for B2/B3/B4 range
    for ( vset = 0x0C; vset < 0x41 && ret == EXIT_SUCCESS; vset++ )
    {
        vout = __PMIC_GetVoutFromVset( vset, VOUT_RANGE_B2_B3_B4 );
        if ( ( vset < VSET_MIN ) || ( vset > VSET_MAX ) )
        {
            if ( vout != (uint16_t)-1 )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to detect VSET=0x%02X is out of range", vset );
                ret = EXIT_FAILURE;
            }
            continue;
        }
        vout_exp = VOUT_B2_B3_B4_MIN + VOUT_B2_B3_B4_STEP * (vset - VSET_MIN);
        if ( vout != vout_exp )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to get VOUT on B2/B3/B4 corresponding to VSET=0x%02X: get %u but expect %u", vset, vout, vout_exp);
            ret = EXIT_FAILURE;
        }
    }

    // Test VOUT to VSET for B1/L1/L2 range
    for ( vout = 1100; vout < 3800 && ret == EXIT_SUCCESS; vout += 50 )
    {
        vset = __PMIC_GetVsetFromVout( vout, VOUT_RANGE_B1_L1_L2 );
        if ( ( vout < VOUT_B1_L1_L2_MIN ) || ( vout > VOUT_B1_L1_L2_MAX ) )
        {
            if ( vset != (uint8_t)-1 )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to detect VOUT=%u on B1/L1/L2 is out of range", vout);
                ret = EXIT_FAILURE;
            }
            continue;
        }
        vset_exp = VSET_MIN + (vout - VOUT_B1_L1_L2_MIN) / VOUT_B1_L1_L2_STEP;
        if ( vset != vset_exp )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to get VSET corresponding to VOUT=%u on B1/L1/L2: get %u but expect %u", vout, vset, vset_exp);
            ret = EXIT_FAILURE;
        }
    }

    // Test VOUT to VSET for B2/B3/B4 range
    for ( vout = 550; vout < 1900 && ret == EXIT_SUCCESS; vout += 25 )
    {
        vset = __PMIC_GetVsetFromVout( vout, VOUT_RANGE_B2_B3_B4 );
        if ( ( vout < VOUT_B2_B3_B4_MIN ) || ( vout > VOUT_B2_B3_B4_MAX ) )
        {
            if ( vset != (uint8_t)-1 )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to detect VOUT=0x%02X on B2/B3/B4 is out of range", vout);
                ret = EXIT_FAILURE;
            }
            continue;
        }
        vset_exp = VSET_MIN + (vout - VOUT_B2_B3_B4_MIN) / VOUT_B2_B3_B4_STEP;
        if ( vset != vset_exp )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to get VSET corresponding to VOUT=0x%02X on B2/B3/B4: get %u but expect %u", vout, vset, vset_exp);
            ret = EXIT_FAILURE;
        }
    }

    return ret;
}

// Unit test to verify __PMIC_IsValidRegulatorRegister() for all register IDs and LDO inclusion options.
uint32_t MCP16502_UNITTEST_is_regulator_register_valid()
{
    uint32_t ret = EXIT_SUCCESS;
    bool res;
    bool res_expect;
    pmic_reg_field_info_t field_info;

    for ( uint8_t include_ldo = 0; include_ldo <= 1 && ret == EXIT_SUCCESS; include_ldo++ )
    {
        for ( pmic_reg_field_id_t id = R_MCP16502_SYS_ADR; id < F_MCP16502_LDO2_CFG__FLTMSK && ret == EXIT_SUCCESS; id++ )
        {
            res = __PMIC_IsValidRegulatorRegister( id, include_ldo );
            field_info = s_reg_field_info[ id ];
            res_expect = true;
            // Heuristic: only registers with mask 0xFF and valid address are considered valid
            if ( field_info.mask != 0xFF )
            {
                res_expect = false;
            }
            else
            {
                if ( ( field_info.addr & 0x0C ) || ( ( field_info.addr & 0xF0 ) == 0 ) )
                {
                    res_expect = false;
                }
                else
                {
                    if ( !include_ldo && ( ( field_info.addr & 0xF0 ) >= 0x50 ) )
                    {
                        res_expect = false;
                    }
                }
            }
            if ( res != res_expect )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nResult should be %u for register Id = %u and include LDO = %u", res_expect, id, include_ldo);
                ret = EXIT_FAILURE;
            }
        }
    }
    return ret;
}

// Unit test to verify setting and restoring regulator voltages for all regulators and states.
uint32_t MCP16502_UNITTEST_get_set_voltage()
{
    uint32_t ret = EXIT_SUCCESS;
    uint32_t origin_voltage, new_voltage, curr_voltage;
    uint8_t vset, new_vset;
    pmic_mode_t mode;
    vout_range_t vout_range;

    for ( pmic_regulator_id_t regulator_id = PMIC_BUCK1; regulator_id <= PMIC_LDO2 && ret == EXIT_SUCCESS; regulator_id++ )
    {
        for ( pmic_state_id_t state_id = PMIC_STATE_A; state_id <= PMIC_STATE_LPM && ret == EXIT_SUCCESS; state_id++ )
        {
            pmic_reg_field_id_t register_id = s_pmic_register_offset_mode[regulator_id] + MCP16502_MODE_ID_OFFSET * state_id;

            pmic_reg_field_info_t register_info = s_reg_field_info[ register_id ];
            if ( register_info.mask != 0xFF )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nID %u is not a valid register ID", register_id);
                ret = EXIT_FAILURE;
            }
            else if ( PMIC_GetRegulatorSettings( regulator_id, state_id, &origin_voltage, &mode, NULL ) )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read the voltage of the regulator ID %u", regulator_id);
                ret = EXIT_FAILURE;
            }
            else
            {
                // Determine voltage range for this register
                if ( ( register_id < R_MCP16502_OUT2_A ) || ( register_id >= R_MCP16502_LDO1_A ) )
                    vout_range = VOUT_RANGE_B1_L1_L2;
                else
                    vout_range = VOUT_RANGE_B2_B3_B4;

                vset = __PMIC_GetVsetFromVout( origin_voltage, vout_range );
                if ( vset == (uint8_t)-1 )
                {
                    ret = EXIT_FAILURE;
                }
                else
                {
                    // Choose a new VSET value (increment or decrement)
                    if ( vset == VSET_MIN )
                        new_vset = ++vset;
                    else if ( vset == VSET_MAX )
                        new_vset = --vset;
                    else
                        new_vset = ++vset;

                    new_voltage = __PMIC_GetVoutFromVset( new_vset, vout_range );
                    if ( new_voltage == (uint16_t)-1 )
                    {
                        ret = EXIT_FAILURE;
                    }
                    else if ( PMIC_SetRegulatorSettings( regulator_id, state_id, new_voltage, mode ) )
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to write the new voltage %lu on PMIC @0x%02X", new_voltage, register_info.addr);
                        ret = EXIT_FAILURE;
                    }
                    else if ( PMIC_GetRegulatorSettings( regulator_id, state_id, &curr_voltage, &mode, NULL ) )
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read the current voltage on PMIC @0x%02X", register_info.addr);
                        ret = EXIT_FAILURE;
                    }
                    else if ( curr_voltage != new_voltage )
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nInvalid voltage on PMIC @0x%02X: read %lu but expect %lu", register_info.addr, curr_voltage, new_voltage);
                        ret = EXIT_FAILURE;
                    }
                    // Restore original voltage
                    else if ( PMIC_SetRegulatorSettings( regulator_id, state_id, origin_voltage, mode ) )
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to write the original voltage %lu back on PMIC @0x%02X", origin_voltage, register_info.addr);
                        ret = EXIT_FAILURE;
                    }
                    else if ( PMIC_GetRegulatorSettings( regulator_id, state_id, &curr_voltage, NULL, NULL ) )
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read the current voltage on PMIC @0x%02X", register_info.addr);
                        ret = EXIT_FAILURE;
                    }
                    else if ( curr_voltage != origin_voltage )
                    {
                        SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nInvalid voltage on PMIC @0x%02X: read %lu but expect %lu", register_info.addr, curr_voltage, origin_voltage);
                        ret = EXIT_FAILURE;
                    }
                }
            }
        }
    }
    return ret;
}

// Unit test to verify enabling and disabling a regulator (LDO2) for all states.
uint32_t MCP16502_UNITTEST_enable_disable_regulator()
{
    uint32_t ret = EXIT_SUCCESS;
    uint8_t value = 0;

    for ( pmic_state_id_t state_id = PMIC_STATE_A; state_id <= PMIC_STATE_HPM && ret == EXIT_SUCCESS; state_id++ )
    {
        pmic_reg_field_id_t reg_id = s_pmic_register_offset_mode[PMIC_LDO2] + MCP16502_MODE_ID_OFFSET * state_id;

        PMIC_GetRegisterOrFieldValue( reg_id + MCP16502_MODE_ID_OFFSET_EN, &value );

        // If enabled, disable and check
        if ( value != 0 )
        {
            if ( PMIC_EnableDisableRegulator( PMIC_LDO2, state_id, false ) != EXIT_SUCCESS )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to disable regulator with register ID %u", reg_id);
                ret = EXIT_FAILURE;
            }
            else if ( PMIC_GetRegisterOrFieldValue( reg_id + MCP16502_MODE_ID_OFFSET_EN, &value ) != EXIT_SUCCESS )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read EN bit with field ID %u", reg_id + MCP16502_MODE_ID_OFFSET_EN);
                ret = EXIT_FAILURE;
            }
            else if ( value != 0 )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nUnexpected value (%u) for field ID %u", value, reg_id + MCP16502_MODE_ID_OFFSET_EN);
                ret = EXIT_FAILURE;
            }
        }

        if (ret != EXIT_SUCCESS) continue;

        // Enable and check
        if ( PMIC_EnableDisableRegulator( PMIC_LDO2, state_id, true ) != EXIT_SUCCESS )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to enable regulator with register ID %u", reg_id);
            ret = EXIT_FAILURE;
        }
        else if ( PMIC_GetRegisterOrFieldValue( reg_id + MCP16502_MODE_ID_OFFSET_EN, &value ) != EXIT_SUCCESS )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read EN bit with field ID %u", reg_id + MCP16502_MODE_ID_OFFSET_EN);
            ret = EXIT_FAILURE;
        }
        else if ( value != 1 )
        {
            SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nUnexpected value (%u) for field ID %u", value, reg_id + MCP16502_MODE_ID_OFFSET_EN);
            ret = EXIT_FAILURE;
        }

        if (ret != EXIT_SUCCESS) continue;

        // If enabled, disable and check again
        if ( value == 0 )
        {
            if ( PMIC_EnableDisableRegulator( PMIC_LDO2, state_id, false ) != EXIT_SUCCESS )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to disable regulator with register ID %u", reg_id);
                ret = EXIT_FAILURE;
            }
            else if ( PMIC_GetRegisterOrFieldValue( reg_id + MCP16502_MODE_ID_OFFSET_EN, &value ) != EXIT_SUCCESS )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read EN bit with field ID %u", reg_id + MCP16502_MODE_ID_OFFSET_EN);
                ret = EXIT_FAILURE;
            }
            else if ( value != 0 )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nUnexpected value (%u) for field ID %u", value, reg_id + MCP16502_MODE_ID_OFFSET_EN);
                ret = EXIT_FAILURE;
            }
        }
    }
    return ret;
}

// Unit test to verify changing the mode (FPWM/AUTOPFM) of all buck regulators for all states.
uint32_t MCP16502_UNITTEST_change_regulator_mode()
{
    uint32_t ret = EXIT_SUCCESS;
    uint32_t voltage;
    uint8_t mode;

    for ( pmic_regulator_id_t r = PMIC_BUCK1; r <= PMIC_BUCK4 && ret == EXIT_SUCCESS; r++ )
    {
        for ( pmic_state_id_t s = PMIC_STATE_A; s <= PMIC_STATE_HPM && ret == EXIT_SUCCESS; s++ )
        {
            pmic_reg_field_id_t reg_id = s_pmic_register_offset_mode[r] + MCP16502_MODE_ID_OFFSET * s;

            // Read current settings
            if ( PMIC_GetRegulatorSettings( r, s, &voltage, &mode, NULL) != EXIT_SUCCESS )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nPMIC_GetRegulatorSettings failed for regulator Id %u and state ID %u", r, s);
                ret = EXIT_FAILURE;
            }
            // If in AUTOPFM, switch to FPWM and check
            else if ( mode == PMIC_MODE_AUTOPFM )
            {
                if ( PMIC_SetRegulatorSettings( r, s, voltage, PMIC_MODE_FPWM ) != EXIT_SUCCESS )
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nPMIC_SetRegulatorSettings failed with regulator Id %u and state ID %u", r, s);
                    ret = EXIT_FAILURE;
                }
                else if ( PMIC_GetRegisterOrFieldValue( reg_id + MCP16502_MODE_ID_OFFSET_MODE, &mode) != EXIT_SUCCESS )
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nPMIC_GetRegisterOrFieldValue failed with field ID %u", reg_id + MCP16502_MODE_ID_OFFSET_MODE);
                    ret = EXIT_FAILURE;
                }
                else if ( mode != PMIC_MODE_FPWM )
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nUnexpected value (%u) for field ID %u", mode, reg_id + MCP16502_MODE_ID_OFFSET_MODE);
                    ret = EXIT_FAILURE;
                }
            }
            if (ret != EXIT_SUCCESS) continue;

            // Switch back to AUTOPFM and check
            if ( PMIC_SetRegulatorSettings( r, s, voltage, PMIC_MODE_AUTOPFM ) != EXIT_SUCCESS )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nPMIC_SetRegulatorSettings failed with regulator Id %u and state ID %u", r, s);
                ret = EXIT_FAILURE;
            }
            else if ( PMIC_GetRegisterOrFieldValue( reg_id + MCP16502_MODE_ID_OFFSET_MODE, &mode ) != EXIT_SUCCESS )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read MODE bit with field ID %u", reg_id + MCP16502_MODE_ID_OFFSET_MODE);
                ret = EXIT_FAILURE;
            }
            else if ( mode != PMIC_MODE_AUTOPFM )
            {
                SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nUnexpected value (%u) for field ID %u", mode, reg_id + MCP16502_MODE_ID_OFFSET_MODE);
                ret = EXIT_FAILURE;
            }
            if (ret != EXIT_SUCCESS) continue;

            // If in FPWM, switch to FPWM and check
            if ( mode == PMIC_MODE_FPWM )
            {
                if ( PMIC_SetRegulatorSettings( r, s, voltage, PMIC_MODE_FPWM) != EXIT_SUCCESS )
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nPMIC_SetRegulatorSettings failed with regulator Id %u and state ID %u", r, s);
                    ret = EXIT_FAILURE;
                }
                else if ( PMIC_GetRegisterOrFieldValue( reg_id + MCP16502_MODE_ID_OFFSET_MODE, &mode ) != EXIT_SUCCESS )
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nFailed to read MODE bit with field ID %u", reg_id + MCP16502_MODE_ID_OFFSET_MODE);
                    ret = EXIT_FAILURE;
                }
                else if ( mode != PMIC_MODE_FPWM )
                {
                    SYS_DEBUG_PRINT(SYS_ERROR_ERROR, "\r\nUnexpected value (%u) for field ID %u", mode, reg_id + MCP16502_MODE_ID_OFFSET_MODE);
                    ret = EXIT_FAILURE;
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
