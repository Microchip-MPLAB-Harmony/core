/* ************************************************************************** */
/** MCP16502 Driver

  @Company
    Microchip Technology

  @File Name
    mcp16502.h

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

#ifndef _PMIC_MCP16502_H    /* Guard against multiple inclusion */
#define _PMIC_MCP16502_H

#include <stdint.h>
#include <stdbool.h>

#define PMIC_I2C_ADDR               0x${DRV_MCP16502_I2C_ADDRESS}
#define PMIC_VDDCPU_REGULATOR_ID    ${DRV_MCP16502_cpu_port}

//****************************
// PMIC list of registers & fields

typedef enum
{
    // SYS-ADR register & fields
    R_MCP16502_SYS_ADR = 0,
        F_MCP16502_SYS_ADR__ADR,

    // SYS-ID register & fields
    R_MCP16502_SYS_ID,
        F_MCP16502_SYS_ID__REV,
        F_MCP16502_SYS_ID__ID,

    // SYS-TMG register & fields
    R_MCP16502_SYS_TMG,
        F_MCP16502_SYS_TMG__RSTDLY,
        F_MCP16502_SYS_TMG__PBINTTO,
        F_MCP16502_SYS_TMG__PBTO,

    // SYS-CFG register & fields
    R_MCP16502_SYS_CFG,
        F_MCP16502_SYS_CFG__USER,
        F_MCP16502_SYS_CFG__B1HCEN,
        F_MCP16502_SYS_CFG__FSD,
        F_MCP16502_SYS_CFG__AWKPDIS,
        F_MCP16502_SYS_CFG__HPMPEN,
        F_MCP16502_SYS_CFG__TWRMSK,
        F_MCP16502_SYS_CFG__TSDMSK,

    // STS-SYS register & fields
    R_MCP16502_STS_SYS,
        F_MCP16502_STS_SYS__PBINT,
        F_MCP16502_STS_SYS__TWR,
        F_MCP16502_STS_SYS__TSD,

    // STS-B1 register & fields
    R_MCP16502_STS_B1,
        F_MCP16502_STS_B1__ENS,
        F_MCP16502_STS_B1__POK,
        F_MCP16502_STS_B1__SSD,
        F_MCP16502_STS_B1__ILIM, // NOT USED: declared only to simplify the extraction of field values
        F_MCP16502_STS_B1__ZCD,
        F_MCP16502_STS_B1__ILIMNEG,
        F_MCP16502_STS_B1__HICCUP,
        F_MCP16502_STS_B1__FLT,

    // STS-B2 register & fields
    R_MCP16502_STS_B2,
        F_MCP16502_STS_B2__ENS,
        F_MCP16502_STS_B2__POK,
        F_MCP16502_STS_B2__SSD,
        F_MCP16502_STS_B2__ILIM, // NOT USED: declared only to simplify the extraction of field values
        F_MCP16502_STS_B2__ZCD,
        F_MCP16502_STS_B2__ILIMNEG,
        F_MCP16502_STS_B2__HICCUP,
        F_MCP16502_STS_B2__FLT,

    // STS-B3 register & fields
    R_MCP16502_STS_B3,
        F_MCP16502_STS_B3__ENS,
        F_MCP16502_STS_B3__POK,
        F_MCP16502_STS_B3__SSD,
        F_MCP16502_STS_B3__ILIM, // NOT USED: declared only to simplify the extraction of field values
        F_MCP16502_STS_B3__ZCD,
        F_MCP16502_STS_B3__ILIMNEG,
        F_MCP16502_STS_B3__HICCUP,
        F_MCP16502_STS_B3__FLT,

    // STS-B4 register & fields
    R_MCP16502_STS_B4,
        F_MCP16502_STS_B4__ENS,
        F_MCP16502_STS_B4__POK,
        F_MCP16502_STS_B4__SSD,
        F_MCP16502_STS_B4__ILIM, // NOT USED: declared only to simplify the extraction of field values
        F_MCP16502_STS_B4__ZCD,
        F_MCP16502_STS_B4__ILIMNEG,
        F_MCP16502_STS_B4__HICCUP,
        F_MCP16502_STS_B4__FLT,

    // STS-L1 register & fields
    R_MCP16502_STS_L1,
        F_MCP16502_STS_L1__ENS,
        F_MCP16502_STS_L1__POK,
        F_MCP16502_STS_L1__SSD,
        F_MCP16502_STS_L1__ILIM,
        F_MCP16502_STS_L1__ZCD, // NOT USED: declared only to simplify the extraction of field values
        F_MCP16502_STS_L1__ILIMNEG, // NOT USED: declared only to simplify the extraction of field values
        F_MCP16502_STS_L1__HICCUP, // NOT USED: declared only to simplify the extraction of field values
        F_MCP16502_STS_L1__FLT,

    // STS-L2 register & fields
    R_MCP16502_STS_L2,
        F_MCP16502_STS_L2__ENS,
        F_MCP16502_STS_L2__POK,
        F_MCP16502_STS_L2__SSD,
        F_MCP16502_STS_L2__ILIM,
        F_MCP16502_STS_L2__ZCD, // NOT USED: declared only to simplify the extraction of field values
        F_MCP16502_STS_L2__ILIMNEG, // NOT USED: declared only to simplify the extraction of field values
        F_MCP16502_STS_L2__HICCUP, // NOT USED: declared only to simplify the extraction of field values
        F_MCP16502_STS_L2__FLT,

    // OUT1-A register & fields
    R_MCP16502_OUT1_A,
        F_MCP16502_OUT1_A__VSET,
        F_MCP16502_OUT1_A__MODE,
        F_MCP16502_OUT1_A__EN,

    // OUT1-LPM register & fields
    R_MCP16502_OUT1_LPM,
        F_MCP16502_OUT1_LPM__VSET,
        F_MCP16502_OUT1_LPM__MODE,
        F_MCP16502_OUT1_LPM__EN,

    // OUT1-HIB register & fields
    R_MCP16502_OUT1_HIB,
        F_MCP16502_OUT1_HIB__VSET,
        F_MCP16502_OUT1_HIB__MODE,
        F_MCP16502_OUT1_HIB__EN,

    // OUT1-HPM register & fields
    R_MCP16502_OUT1_HPM,
        F_MCP16502_OUT1_HPM__VSET,
        F_MCP16502_OUT1_HPM__MODE,
        F_MCP16502_OUT1_HPM__EN,

    // OUT1-SEQ register & fields
    R_MCP16502_OUT1_SEQ,
        F_MCP16502_OUT1_SEQ__DELAY,
        F_MCP16502_OUT1_SEQ__SEQEN,
        F_MCP16502_OUT1_SEQ__SEQ,
        F_MCP16502_OUT1_SEQ__SSR,

    // OUT1-CFG register & fields
    R_MCP16502_OUT1_CFG,
        F_MCP16502_OUT1_CFG__RCON,
        F_MCP16502_OUT1_CFG__REN,
        F_MCP16502_OUT1_CFG__DVSR,
        F_MCP16502_OUT1_CFG__PHASE,
        F_MCP16502_OUT1_CFG__DISCH,
        F_MCP16502_OUT1_CFG__HCPEN,
        F_MCP16502_OUT1_CFG__FLTMSK,

    // OUT2-A register & fields
    R_MCP16502_OUT2_A,
        F_MCP16502_OUT2_A__VSET,
        F_MCP16502_OUT2_A__MODE,
        F_MCP16502_OUT2_A__EN,

    // OUT2-LPM register & fields
    R_MCP16502_OUT2_LPM,
        F_MCP16502_OUT2_LPM__VSET,
        F_MCP16502_OUT2_LPM__MODE,
        F_MCP16502_OUT2_LPM__EN,

    // OUT2-HIB register & fields
    R_MCP16502_OUT2_HIB,
        F_MCP16502_OUT2_HIB__VSET,
        F_MCP16502_OUT2_HIB__MODE,
        F_MCP16502_OUT2_HIB__EN,

    // OUT2-HPM register & fields
    R_MCP16502_OUT2_HPM,
        F_MCP16502_OUT2_HPM__VSET,
        F_MCP16502_OUT2_HPM__MODE,
        F_MCP16502_OUT2_HPM__EN,

    // OUT2-SEQ register & fields
    R_MCP16502_OUT2_SEQ,
        F_MCP16502_OUT2_SEQ__DELAY,
        F_MCP16502_OUT2_SEQ__SEQEN,
        F_MCP16502_OUT2_SEQ__SEQ,
        F_MCP16502_OUT2_SEQ__SSR,

    // OUT2-CFG register & fields
    R_MCP16502_OUT2_CFG,
        F_MCP16502_OUT2_CFG__RCON,
        F_MCP16502_OUT2_CFG__REN,
        F_MCP16502_OUT2_CFG__DVSR,
        F_MCP16502_OUT2_CFG__PHASE,
        F_MCP16502_OUT2_CFG__DISCH,
        F_MCP16502_OUT2_CFG__HCPEN,
        F_MCP16502_OUT2_CFG__FLTMSK,

    // OUT3-A register & fields
    R_MCP16502_OUT3_A,
        F_MCP16502_OUT3_A__VSET,
        F_MCP16502_OUT3_A__MODE,
        F_MCP16502_OUT3_A__EN,

    // OUT3-LPM register & fields
    R_MCP16502_OUT3_LPM,
        F_MCP16502_OUT3_LPM__VSET,
        F_MCP16502_OUT3_LPM__MODE,
        F_MCP16502_OUT3_LPM__EN,

    // OUT3-HIB register & fields
    R_MCP16502_OUT3_HIB,
        F_MCP16502_OUT3_HIB__VSET,
        F_MCP16502_OUT3_HIB__MODE,
        F_MCP16502_OUT3_HIB__EN,

    // OUT3-HPM register & fields
    R_MCP16502_OUT3_HPM,
        F_MCP16502_OUT3_HPM__VSET,
        F_MCP16502_OUT3_HPM__MODE,
        F_MCP16502_OUT3_HPM__EN,

    // OUT3-SEQ register & fields
    R_MCP16502_OUT3_SEQ,
        F_MCP16502_OUT3_SEQ__DELAY,
        F_MCP16502_OUT3_SEQ__SEQEN,
        F_MCP16502_OUT3_SEQ__SEQ,
        F_MCP16502_OUT3_SEQ__SSR,

    // OUT3-CFG register & fields
    R_MCP16502_OUT3_CFG,
        F_MCP16502_OUT3_CFG__RCON,
        F_MCP16502_OUT3_CFG__REN,
        F_MCP16502_OUT3_CFG__DVSR,
        F_MCP16502_OUT3_CFG__PHASE,
        F_MCP16502_OUT3_CFG__DISCH,
        F_MCP16502_OUT3_CFG__HCPEN,
        F_MCP16502_OUT3_CFG__FLTMSK,

    // OUT4-A register & fields
    R_MCP16502_OUT4_A,
        F_MCP16502_OUT4_A__VSET,
        F_MCP16502_OUT4_A__MODE,
        F_MCP16502_OUT4_A__EN,

    // OUT4-LPM register & fields
    R_MCP16502_OUT4_LPM,
        F_MCP16502_OUT4_LPM__VSET,
        F_MCP16502_OUT4_LPM__MODE,
        F_MCP16502_OUT4_LPM__EN,

    // OUT4-HIB register & fields
    R_MCP16502_OUT4_HIB,
        F_MCP16502_OUT4_HIB__VSET,
        F_MCP16502_OUT4_HIB__MODE,
        F_MCP16502_OUT4_HIB__EN,

    // OUT4-HPM register & fields
    R_MCP16502_OUT4_HPM,
        F_MCP16502_OUT4_HPM__VSET,
        F_MCP16502_OUT4_HPM__MODE,
        F_MCP16502_OUT4_HPM__EN,

    // OUT4-SEQ register & fields
    R_MCP16502_OUT4_SEQ,
        F_MCP16502_OUT4_SEQ__DELAY,
        F_MCP16502_OUT4_SEQ__SEQEN,
        F_MCP16502_OUT4_SEQ__SEQ,
        F_MCP16502_OUT4_SEQ__SSR,

    // OUT4-CFG register & fields
    R_MCP16502_OUT4_CFG,
        F_MCP16502_OUT4_CFG__RCON,
        F_MCP16502_OUT4_CFG__REN,
        F_MCP16502_OUT4_CFG__DVSR,
        F_MCP16502_OUT4_CFG__PHASE,
        F_MCP16502_OUT4_CFG__DISCH,
        F_MCP16502_OUT4_CFG__HCPEN,
        F_MCP16502_OUT4_CFG__FLTMSK,

    // LDO1-A register & fields
    R_MCP16502_LDO1_A,
        F_MCP16502_LDO1_A__VSET,
        F_MCP16502_LDO1_A__UNUSED,
        F_MCP16502_LDO1_A__EN,

    // LDO1-LPM register & fields
    R_MCP16502_LDO1_LPM,
        F_MCP16502_LDO1_LPM__VSET,
        F_MCP16502_LDO1_LPM__UNUSED,
        F_MCP16502_LDO1_LPM__EN,

    // LDO1-HIB register & fields
    R_MCP16502_LDO1_HIB,
        F_MCP16502_LDO1_HIB__VSET,
        F_MCP16502_LDO1_HIB__UNUSED,
        F_MCP16502_LDO1_HIB__EN,

    // LDO1-HPM register & fields
    R_MCP16502_LDO1_HPM,
        F_MCP16502_LDO1_HPM__VSET,
        F_MCP16502_LDO1_HPM__UNUSED,
        F_MCP16502_LDO1_HPM__EN,

    // LDO1-SEQ register & fields
    R_MCP16502_LDO1_SEQ,
        F_MCP16502_LDO1_SEQ__DELAY,
        F_MCP16502_LDO1_SEQ__SEQEN,
        F_MCP16502_LDO1_SEQ__SEQ,
        F_MCP16502_LDO1_SEQ__SSR,

    // LDO1-CFG register & fields
    R_MCP16502_LDO1_CFG,
        F_MCP16502_LDO1_CFG__RCON,
        F_MCP16502_LDO1_CFG__REN,
        F_MCP16502_LDO1_CFG__DVSR,
        F_MCP16502_LDO1_CFG__UNUSED1,
        F_MCP16502_LDO1_CFG__DISCH,
        F_MCP16502_LDO1_CFG__UNUSED2,
        F_MCP16502_LDO1_CFG__FLTMSK,

    // LDO2-A register & fields
    R_MCP16502_LDO2_A,
        F_MCP16502_LDO2_A__VSET,
        F_MCP16502_LDO2_A__UNUSED,
        F_MCP16502_LDO2_A__EN,

    // LDO2-LPM register & fields
    R_MCP16502_LDO2_LPM,
        F_MCP16502_LDO2_LPM__VSET,
        F_MCP16502_LDO2_LPM__UNUSED,
        F_MCP16502_LDO2_LPM__EN,

    // LDO2-HIB register & fields
    R_MCP16502_LDO2_HIB,
        F_MCP16502_LDO2_HIB__VSET,
        F_MCP16502_LDO2_HIB__UNUSED,
        F_MCP16502_LDO2_HIB__EN,

    // LDO2-HPM register & fields
    R_MCP16502_LDO2_HPM,
        F_MCP16502_LDO2_HPM__VSET,
        F_MCP16502_LDO2_HPM__UNUSED,
        F_MCP16502_LDO2_HPM__EN,

    // LDO2-SEQ register & fields
    R_MCP16502_LDO2_SEQ,
        F_MCP16502_LDO2_SEQ__DELAY,
        F_MCP16502_LDO2_SEQ__SEQEN,
        F_MCP16502_LDO2_SEQ__SEQ,
        F_MCP16502_LDO2_SEQ__SSR,

    // LDO2-CFG register & fields
    R_MCP16502_LDO2_CFG,
        F_MCP16502_LDO2_CFG__RCON,
        F_MCP16502_LDO2_CFG__REN,
        F_MCP16502_LDO2_CFG__DVSR,
        F_MCP16502_LDO2_CFG__UNUSED1,
        F_MCP16502_LDO2_CFG__DISCH,
        F_MCP16502_LDO2_CFG__UNUSED2,
        F_MCP16502_LDO2_CFG__FLTMSK
} pmic_reg_field_id_t;

//****************************
// VSET related constants
#define VSET_MIN      0x0D
#define VSET_MAX      0x3F

//****************************
// VOUT related constants
#define VOUT_B1_L1_L2_MIN       1200
#define VOUT_B1_L1_L2_MAX       3700
#define VOUT_B1_L1_L2_STEP      50

#define VOUT_B2_B3_B4_MIN       600
#define VOUT_B2_B3_B4_MAX       1850
#define VOUT_B2_B3_B4_STEP      25

/* Provide C++ Compatibility */
#ifdef __cplusplus
extern "C"
{
#endif

typedef enum
{
    PMIC_BUCK1 = 0,
    PMIC_BUCK2,
    PMIC_BUCK3,
    PMIC_BUCK4,
    PMIC_LDO1,
    PMIC_LDO2
} pmic_regulator_id_t;

typedef enum
{
    PMIC_STATE_A = 0,
    PMIC_STATE_LPM,
    PMIC_STATE_HIB,
    PMIC_STATE_HPM
} pmic_state_id_t;

typedef enum
{
    PMIC_MODE_AUTOPFM = 0,
    PMIC_MODE_FPWM
} pmic_mode_t;

typedef struct
{
    // SYS-TMP fields
    uint8_t sys_tmp_RSTDLY;
    uint8_t sys_tmp_PBINTTO;
    uint8_t sys_tmp_PBTO;
    // SYS-CFG fields
    bool    sys_cfg_USER;
    bool    sys_cfg_B1HCEN;
    uint8_t sys_cfg_FSD;
    bool    sys_cfg_AWKPDIS;
    bool    sys_cfg_HPMPEN;
    bool    sys_cfg_TWRMSK;
    bool    sys_cfg_TSDMSK;
} pmic_sys_tmg_cfg_t;

typedef struct
{
    bool sts_sys_PBINT;
    bool sts_sys_TWR;
    bool sts_sys_TSD;
} pmic_system_status_t;

typedef struct
{
    bool sts_sys_ENS;
    bool sts_sys_POK;
    bool sts_sys_SSD;
    bool sts_sys_ILIM;      // Not used on BUCK1234: read is undefined, write is ignored
    bool sts_sys_ZCD;       // Not used on LDO12: read is undefined, write is ignored
    bool sts_sys_ILIMNEG;   // Not used on LDO12: read is undefined, write is ignored
    bool sts_sys_HICCUP;    // Not used on LDO12: read is undefined, write is ignored
    bool sts_sys_FLT;
} pmic_regulator_status_t;

enum E_PMIC_DVSR
{
    PMIC_DVSR_0,
    PMIC_DVSR_1,
    PMIC_DVSR_2,
    PMIC_DVSR_3
};

enum E_PMIC_SEQ
{
    PMIC_SEQ_1,
    PMIC_SEQ_2,
    PMIC_SEQ_3,
    PMIC_SEQ_4
};

enum E_PMIC_DELAY
{
    PMIC_DELAY_0,
    PMIC_DELAY_0_5,
    PMIC_DELAY_1,
    PMIC_DELAY_2,
    PMIC_DELAY_4,
    PMIC_DELAY_8,
    PMIC_DELAY_12,
    PMIC_DELAY_16
};

enum E_PMIC_SSR
{
    PMIC_SSR_0,
    PMIC_SSR_1,
    PMIC_SSR_2,
    PMIC_SSR_3
};

enum E_PMIC_PBTO
{
    PMIC_PBTO_2,
    PMIC_PBTO_4,
    PMIC_PBTO_8,
    PMIC_PBTO_16
};

enum E_PMIC_FSD
{
    PMIC_FSD_0 = 1,
    PMIC_FSD_MINUS_16,
    PMIC_FSD_PLUS_16
};

enum E_PMIC_PBINTTO
{
    PMIC_PBINTTO_0_1,
    PMIC_PBINTTO_0_5,
    PMIC_PBINTTO_1,
    PMIC_PBINTTO_2
};

enum E_PMIC_RSTDLY
{
    PMIC_RSTDLY_1,
    PMIC_RSTDLY_2,
    PMIC_RSTDLY_4,
    PMIC_RSTDLY_8,
    PMIC_RSTDLY_16,
    PMIC_RSTDLY_32,
    PMIC_RSTDLY_64,
    PMIC_RSTDLY_128
};

// *****************************************************************************
// *****************************************************************************
// Section: Interface Functions
// *****************************************************************************
// *****************************************************************************

uint32_t PMIC_Open(const uint8_t i2c_device_address);
uint32_t PMIC_Close(void);

uint32_t PMIC_GetDeviceInfo(uint8_t* const sys_addr, uint8_t* const sys_id);
uint32_t PMIC_GetSysTimingAndConfig(pmic_sys_tmg_cfg_t* const sys_tmg_cfg);
uint32_t PMIC_SetSysTimingAndConfig(const pmic_sys_tmg_cfg_t sys_tmg_cfg);

uint32_t PMIC_GetSystemStatus(pmic_system_status_t* const system_status);

uint32_t PMIC_GetRegisterOrFieldValue(const pmic_reg_field_id_t register_id, uint8_t* const register_value);
uint32_t PMIC_SetRegisterOrFieldValue(const pmic_reg_field_id_t register_id, const uint8_t register_value);

uint32_t PMIC_GetRegulatorStatus(const pmic_regulator_id_t regulator_id, pmic_regulator_status_t* const regulator_status);
uint32_t PMIC_SetRegulatorStatus(const pmic_regulator_id_t regulator_id, pmic_regulator_status_t* const regulator_status);

uint32_t PMIC_GetRegulatorSettings(const pmic_regulator_id_t regulator_id, const pmic_state_id_t state_id, uint32_t* const p_voltage_in_mv, pmic_mode_t* const p_mode, bool* const p_enabled);
uint32_t PMIC_SetRegulatorSettings(const pmic_regulator_id_t regulator_id, const pmic_state_id_t state_id, const uint32_t voltage_in_mv, const pmic_mode_t mode);
uint32_t PMIC_EnableDisableRegulator(const pmic_regulator_id_t regulator_id, const pmic_state_id_t state_id, const bool enable);
<#if DRV_MCP16502_mcp_unittest == true>

/* ************************************************************************** */
/* Section: UNIT-TESTING FUNCTIONS                                            */
/* ************************************************************************** */
uint32_t MCP16502_UNITTEST_registers_and_fields_table_sizes(void);
uint32_t MCP16502_UNITTEST_registers_and_fields_accesses(void);
uint32_t MCP16502_UNITTEST_vset_vout_convertion(void);
uint32_t MCP16502_UNITTEST_is_regulator_register_valid(void);
uint32_t MCP16502_UNITTEST_get_set_voltage(void);
uint32_t MCP16502_UNITTEST_enable_disable_regulator(void);
uint32_t MCP16502_UNITTEST_change_regulator_mode(void);
</#if>

/* Provide C++ Compatibility */
#ifdef __cplusplus
}
#endif

#endif /* _PMIC_MCP16502_H */

/* *****************************************************************************
 End of File
 */
