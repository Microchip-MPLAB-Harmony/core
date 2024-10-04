/*******************************************************************************
  SD Host Controller Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdmmc_local.h

  Summary:
    SD Host Controller driver local declarations, structures and function
    prototypes.

  Description:
    This file contains the SD Host Controller driver's local declarations
    and definitions.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
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
//DOM-IGNORE-END


#ifndef DRV_SDMMC_LOCAL_H
#define DRV_SDMMC_LOCAL_H


// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#include "driver/sdmmc/drv_sdmmc.h"
#include "system/time/sys_time.h"
#include "osal/osal.h"

// *****************************************************************************
// *****************************************************************************
// Section: Helper Macros
// *****************************************************************************
// *****************************************************************************
/* SDMMC Driver Handle Macros*/
#define DRV_SDMMC_INDEX_MASK                     (0x000000FFU)
#define DRV_SDMMC_INSTANCE_MASK                  (0x0000FF00U)
#define DRV_SDMMC_TOKEN_MAX                      (0xFFFFU)

#define DRV_SDMMC_COMMAND_STATUS_SUCCESS         (0x00U)
#define DRV_SDMMC_COMMAND_STATUS_ERROR           (0x01U)
#define DRV_SDMMC_COMMAND_STATUS_TIMEOUT_ERROR   (0x02U)
#define DRV_SDMMC_COMMAND_STATUS_CRC_ERROR       (0x03U)
#define DRV_SDMMC_COMMAND_STATUS_IN_PROGRESS     (0x04U)

#define DRV_SDMMC_COMMAND_TIMEOUT_ERROR          (0x0001U)
#define DRV_SDMMC_COMMAND_CRC_ERROR              (0x0002U)
#define DRV_SDMMC_COMMAND_END_BIT_ERROR          (0x0004U)
#define DRV_SDMMC_COMMAND_INDEX_ERROR            (0x0008U)
// Using the reserved bit to indicate card removal event
#define DRV_SDMMC_CARD_REMOVAL_ERROR             (0x8000U)
#define DRV_SDMMC_ANY_COMMAND_ERRORS             (0x800FU)
#define DRV_SDMMC_DATA_TIMEOUT_ERROR             (0x0010U)
#define DRV_SDMMC_DATA_CRC_ERROR                 (0x0020U)
#define DRV_SDMMC_DATA_END_BIT_ERROR             (0x0040U)
#define DRV_SDMMC_ADMA_ERROR                     (0x0200U)
#define DRV_SDMMC_ANY_DATA_ERRORS                (0x8270U)

#define DRV_SDMMC_CSD_BUFFER_LEN                 (16U)
#define DRV_SDMMC_CID_BUFFER_LEN                 (16U)
#define DRV_SDMMC_SCR_BUFFER_LEN                 (CACHE_ALIGNED_SIZE_GET(8U))
#define DRV_SDMMC_SWITCH_STATUS_BUFFER_LEN       (64U)

// Section: OCR register bits
#define DRV_SDMMC_OCR_VDD_170_195                (1UL <<  7UL)
#define DRV_SDMMC_OCR_VDD_200_270                (0x7F1U << 8U)
#define DRV_SDMMC_OCR_VDD_27_28                  (1UL << 15UL)
#define DRV_SDMMC_OCR_VDD_28_29                  (1UL << 16UL)
#define DRV_SDMMC_OCR_VDD_29_30                  (1UL << 17UL)
#define DRV_SDMMC_OCR_VDD_30_31                  (1UL << 18UL)
#define DRV_SDMMC_OCR_VDD_31_32                  (1UL << 19UL)
#define DRV_SDMMC_OCR_VDD_32_33                  (1UL << 20UL)
#define DRV_SDMMC_OCR_VDD_33_34                  (1UL << 21UL)
#define DRV_SDMMC_OCR_VDD_34_35                  (1UL << 22UL)
#define DRV_SDMMC_OCR_VDD_35_36                  (1UL << 23UL)
#define DRV_SDMMC_OCR_ACCESS_MODE                (3UL << 29UL)
#define DRV_SDMMC_OCR_ACCESS_SECTOR              (2UL << 29UL)
#define DRV_SDMMC_OCR_NBUSY                      (1UL << 31UL)

/* R1 error bits for eMMC */
#define DRV_SDMMC_R1_E_ADDRESS_OUT_OF_RANGE      (1UL << 31UL)
#define DRV_SDMMC_R1_E_ADDRESS_ MISALIGN         (1UL << 30UL)
#define DRV_SDMMC_R1_E_BLOCK_LEN_ERROR           (1UL << 29UL)
#define DRV_SDMMC_R1_E_ERASE_SEQ_ERROR           (1UL << 28UL)
#define DRV_SDMMC_R1_E_ERASE_PARAM               (1UL << 27UL)
#define DRV_SDMMC_R1_E_WP_VIOLATION              (1UL << 26UL)
#define DRV_SDMMC_R1_E_LOCK_UNLOCK_FAILED        (1UL << 24UL)
#define DRV_SDMMC_R1_E_COM_CRC_ERROR             (1UL << 23UL)
#define DRV_SDMMC_R1_E_ILLEGAL_COMMAND           (1UL << 22UL)
#define DRV_SDMMC_R1_E_DEVICE_ECC_FAILED         (1UL << 21UL)
#define DRV_SDMMC_R1_E_CC_ERROR                  (1UL << 20UL)
#define DRV_SDMMC_R1_E_ERROR                     (1UL << 19UL)
#define DRV_SDMMC_R1_E_CID_CSD_OVERWRITE         (1UL << 16UL)
#define DRV_SDMMC_R1_E_WP_ERASE_SKIP             (1UL << 15UL)
#define DRV_SDMMC_R1_E_SWITCH_STATE              (1UL << 7UL)

#define DRV_SDMMC_R1_S_DEVICE_IS_LOCKED          (1UL << 25UL)

#define DRV_SDMMC_DEVICE_RCA_POS                 (16U)
#define DRV_SDMMC_DEVICE_RCA_VAL(rca)            ((rca) << DRV_SDMMC_DEVICE_RCA_POS)


#define DRV_SDMMC_TRAN_SPEED_UNIT_POS  (0x0U)
#define DRV_SDMMC_TRAN_SPEED_UNIT_MASK ((0x7U) << DRV_SDMMC_TRAN_SPEED_UNIT_POS)
#define DRV_SDMMC_TRAN_SPEED_UNIT_VAL(transSpeed) (((transSpeed) & (DRV_SDMMC_TRAN_SPEED_UNIT_MASK)) >> DRV_SDMMC_TRAN_SPEED_UNIT_POS)

#define DRV_SDMMC_TRAN_SPEED_MULT_POS  (0x3U)
#define DRV_SDMMC_TRAN_SPEED_MULT_MASK ((0x7U) << DRV_SDMMC_TRAN_SPEED_MULT_POS)
#define DRV_SDMMC_TRAN_SPEED_MULT_VAL(transSpeed) (((transSpeed) & (DRV_SDMMC_TRAN_SPEED_MULT_MASK)) >> DRV_SDMMC_TRAN_SPEED_MULT_POS)

#define DRV_SDMMC_EMMC_RCA             (2UL)
#define DRV_SDMMC_SEND_RCA_ARG         DRV_SDMMC_DEVICE_RCA_VAL(DRV_SDMMC_EMMC_RCA)


#define DRV_SDMMC_SUPPORTED_OP_COND    (DRV_SDMMC_OCR_VDD_31_32 | \
                                        DRV_SDMMC_OCR_VDD_32_33 | \
                                        DRV_SDMMC_OCR_VDD_33_34 | \
                                        DRV_SDMMC_OCR_ACCESS_SECTOR)

#define DRV_SDMMC_SET_RELATIVE_ADDR_ERROR  (DRV_SDMMC_R1_E_COM_CRC_ERROR | \
                                            DRV_SDMMC_R1_E_ILLEGAL_COMMAND | \
                                            DRV_SDMMC_R1_E_CC_ERROR | \
                                            DRV_SDMMC_R1_E_ERROR | \
                                            DRV_SDMMC_R1_E_CID_CSD_OVERWRITE)

#define DRV_SDMMC_GET_CSD_VERSION(csdPtr)   (((csdPtr[14]) >> 6U) & (3U))

/* MISRA C-2012 Rule 5.4 deviated:2 Deviation record ID -  H3_MISRAC_2012_R_5_4_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:2 "MISRA C-2012 Rule 5.4" "H3_MISRAC_2012_R_5_4_DR_1"
</#if>


#define DRV_SDMMC_EXT_CSD_CMD_SET_NORMAL            (1UL<<0UL)
#define DRV_SDMMC_EXT_CSD_CMD_SET_SECURE            (1UL<<1UL)
#define DRV_SDMMC_EXT_CSD_CMD_SET_CPSECURE          (1UL<<2UL)

#define DRV_SDMMC_EXT_CSD_BUS_WIDTH                 (183UL) /* R/W */
#define DRV_SDMMC_EXT_CSD_HS_TIMING                 (185UL) /* R/W */

#define DRV_SDMMC_EXT_CSD_BUS_WIDTH_1               (0U)   /* Card is in 1 bit mode */
#define DRV_SDMMC_EXT_CSD_BUS_WIDTH_4               (1U)   /* Card is in 4 bit mode */
#define DRV_SDMMC_EXT_CSD_BUS_WIDTH_8               (2U)   /* Card is in 8 bit mode */
#define DRV_SDMMC_EXT_CSD_DDR_BUS_WIDTH_4           (5U)   /* Card is in 4 bit DDR mode */
#define DRV_SDMMC_EXT_CSD_DDR_BUS_WIDTH_8           (6U)  /* Card is in 8 bit DDR mode */
#define DRV_SDMMC_EXT_CSD_BUS_WIDTH_STROBE BIT(7)   /* Enhanced strobe mode */

#define DRV_SDMMC_EXT_CSD_TIMING_BC                 (0U)   /* Backwards compatility */
#define DRV_SDMMC_EXT_CSD_TIMING_HS                 (1UL)   /* High speed */
#define DRV_SDMMC_EXT_CSD_TIMING_HS200              (2U)   /* HS200 */
#define DRV_SDMMC_EXT_CSD_TIMING_HS400              (3U)   /* HS400 */
#define DRV_SDMMC_EXT_CSD_DRV_STR_SHIFT             (4U)   /* Driver Strength shift */

#define DRV_SDMMC_SWITCH_MODE_CMD_SET               (0x00U)    /* Change the command set */
#define DRV_SDMMC_SWITCH_MODE_SET_BITS              (0x01U)    /* Set bits which are 1 in value */
#define DRV_SDMMC_SWITCH_MODE_CLEAR_BITS            (0x02U)    /* Clear bits which are 1 in value */
#define DRV_SDMMC_SWITCH_MODE_WRITE_BYTE            (0x03UL)    /* Set target to value */

#define DRV_SDMMC_EXT_CSD_GET_HS_SUPPORT(extcsdPtr) (0U != ((extcsdPtr[196]) & 0x01U))
#define DRV_SDMMC_EXT_CSD_GET_SEC_COUNT(extcsdPtr)   ((uint32_t)((extcsdPtr[215]) << 24U) |\
                                                      (uint32_t)((extcsdPtr[214]) << 16U) |\
                                                      (uint32_t)((extcsdPtr[213]) << 8U) |\
                                                      (uint32_t)(extcsdPtr[212]))

#define CMD6_EXT_CSD_MODE_ARGU(set, index, value) \
        (((DRV_SDMMC_SWITCH_MODE_WRITE_BYTE) << 24U) | \
          ((index) << 16) | \
          ((value) << 8) | \
          (set))

#define DRV_SDMMC_SWITCH_HS_ARGU CMD6_EXT_CSD_MODE_ARGU(DRV_SDMMC_EXT_CSD_CMD_SET_NORMAL,\
                                                        DRV_SDMMC_EXT_CSD_HS_TIMING,\
                                                        DRV_SDMMC_EXT_CSD_TIMING_HS)
#define DRV_SDMMC_SWITCH_BUS_WIDTH_ARGU(busWidth) CMD6_EXT_CSD_MODE_ARGU(DRV_SDMMC_EXT_CSD_CMD_SET_NORMAL,\
                                                                         DRV_SDMMC_EXT_CSD_BUS_WIDTH,\
                                                                         busWidth)


#define DRV_SDMMC_EXT_CSD_RESP_SIZE            (512U)

#define DRV_SDMMC_CMD_ARG_NULL                 (0U)

#define DRV_SDMMC_CLOCK_FREQ_400_KHZ           (400000U)
#define DRV_SDMMC_CLOCK_FREQ_DS_25_MHZ         (25000000U)
#define DRV_SDMMC_CLOCK_FREQ_HS_50_MHZ         (50000000U)

#define DRV_SDMMC_CLOCK_FREQ_DS_26_MHZ         (26000000U)
#define DRV_SDMMC_CLOCK_FREQ_HS_52_MHZ         (52000000U)


#define DRV_SDMMC_R4_MP_MSK                    (0x01UL << 27U)
#define DRV_SDMMC_R4_MP_POS                    (27U)
#define DRV_SDMMC_R4_NF_MSK                    (0x03UL << 28U)
#define DRV_SDMMC_R4_NF_POS                    (28U)
#define DRV_SDMMC_R4_OCR_MSK                   (0xFFFFFF << 0U)
#define DRV_SDMMC_R4_C_MSK                     (0x01UL << 31U)

#define DRV_SDMMC_FN0                           0UL
#define DRV_SDMMC_FN1                           1UL
#define DRV_SDMMC_FN2                           2UL
#define DRV_SDMMC_FN3                           3UL
#define DRV_SDMMC_FN4                           4UL
#define DRV_SDMMC_FN5                           5UL
#define DRV_SDMMC_FN6                           6UL
#define DRV_SDMMC_FN7                           7UL

#define DRV_SDMMC_FBR_OFFSET(fn)                (256UL * (fn))

#define DRV_SDMMC_SDIO_CMD52_CRC_ERR_MSK            (0x1U << 7U)
#define DRV_SDMMC_SDIO_CMD52_ILLEGAL_CMD_MSK        (0x1U << 6U)
#define DRV_SDMMC_SDIO_CMD52_IO_STATE_MSK           (0x3U << 4U)
#define DRV_SDMMC_SDIO_CMD52_ERR_MSK                (0x1U << 3U)
#define DRV_SDMMC_SDIO_CMD52_INVALID_FN_MSK         (0x1U << 1U)
#define DRV_SDMMC_SDIO_CMD52_INVALID_ARG_MSK        (0x1U << 0U)

/* Tuple related macros */
#define DRV_SDMMC_SDIO_CODE_CISPTL_NULL             0x00U
#define DRV_SDMMC_SDIO_CODE_CISPTL_CHKSUM           0x10U
#define DRV_SDMMC_SDIO_CODE_CISPTL_VERS1            0x15U
#define DRV_SDMMC_SDIO_CODE_CISPTL_ALTSTR           0x16U
#define DRV_SDMMC_SDIO_CODE_CISPTL_MANFID           0x20U
#define DRV_SDMMC_SDIO_CODE_CISPTL_FUNCID           0x21U
#define DRV_SDMMC_SDIO_CODE_CISPTL_FUNCE            0x22U
#define DRV_SDMMC_SDIO_CODE_CISPTL_SDIO_STD         0x91U
#define DRV_SDMMC_SDIO_CODE_CISPTL_SDIO_EXT         0x92U
#define DRV_SDMMC_SDIO_CODE_CISPTL_END              0xFFU


#define DRV_SDMMC_SDIO_CMD52_RESP_ERR_MSK           (DRV_SDMMC_SDIO_CMD52_CRC_ERR_MSK | \
                                                     DRV_SDMMC_SDIO_CMD52_ILLEGAL_CMD_MSK | \
                                                     DRV_SDMMC_SDIO_CMD52_ERR_MSK | \
                                                     DRV_SDMMC_SDIO_CMD52_INVALID_FN_MSK | \
                                                     DRV_SDMMC_SDIO_CMD52_INVALID_ARG_MSK)

#define DRV_SDMMC_SDIO_CMD52_RESP_FLAGS_GET(resp)       (((resp) & 0x0000FF00U) >> 8U)
#define DRV_SDMMC_SDIO_CMD52_RESP_DATA_GET(resp)        (((resp) & 0x000000FFU))


#define DRV_SDMMC_CCCR_ADDR_SDIO_REV                        0x0U
#define DRV_SDMMC_CCCR_ADDR_SD_SPEC_REV                     0x1U
#define DRV_SDMMC_CCCR_ADDR_IO_EN                           0x2U
#define DRV_SDMMC_CCCR_ADDR_IO_RDY                          0x3U
#define DRV_SDMMC_CCCR_ADDR_INT_EN                          0x4U
#define DRV_SDMMC_CCCR_ADDR_INT_PEND                        0x5U
#define DRV_SDMMC_CCCR_ADDR_IO_ABORT                        0x6U
#define DRV_SDMMC_CCCR_ADDR_BIC                             0x7U
#define DRV_SDMMC_CCCR_ADDR_CARD_CAP                        0x8U
#define DRV_SDMMC_CCCR_ADDR_CSIP                            0x9U
#define DRV_SDMMC_CCCR_ADDR_BUS_SUSPEND                     0xcU
#define DRV_SDMMC_CCCR_ADDR_FN_SEL                          0xdU
#define DRV_SDMMC_CCCR_ADDR_EXEC_FLAGS                      0xeU
#define DRV_SDMMC_CCCR_ADDR_RDY_FLAGS                       0xfU
#define DRV_SDMMC_CCCR_ADDR_FN0_BLK_SZ                      0x10U
#define DRV_SDMMC_CCCR_ADDR_PWR_CTRL                        0x12U
#define DRV_SDMMC_CCCR_ADDR_BUS_SPD_SEL                     0x13U


#define CARD_TYPE_SD_MEM                                    (1U<<0U)
#define CARD_TYPE_SD_IO                                     (1U<<1U)
#define CARD_TYPE_SDIO_COMBO                                (CARD_TYPE_SD_MEM | CARD_TYPE_SD_IO)


#define DRV_SDMMC_CCCR_LSC_MSK                              (1U << 6U)
#define DRV_SDMMC_CCCR_SMB_MSK                              (1U << 1U)
#define DRV_SDMMC_CCCR_4BLS_MSK                             (1U << 7U)
#define DRV_SDMMC_CCCR_BUS_WIDTH_MSK                        (0x83U)
#define DRV_SDMMC_CCCR_BUS_WIDTH_1B                         (0U)
#define DRV_SDMMC_CCCR_BUS_WIDTH_4B                         (0x82U)
#define DRV_SDMMC_CCCR_BUS_WIDTH_8B                         (0x83U)
#define DRV_SDMMC_CCCR_SHS_MSK                              (1U << 0U)
#define DRV_SDMMC_CCCR_EHS_MSK                              (1U << 1U)
#define DRV_SDMMC_CCCR_IO_ABORT_RES                         (1U << 3U)

#define DRV_SDMMC_CMD52_RD_DATA(fn, addr)               (((fn) << 28U) | ((addr) << 9U))
#define DRV_SDMMC_CMD52_WR_DATA(fn, addr, data, raw)    ((1UL << 31U) | ((fn) << 28U) | ((raw) << 27U) | ((addr) << 9U) | (data))

#define DRV_SDMMC_CMD53_RD_DATA(fn, addr, blkMode, count, addrIncr)    (((fn) << 28U) | ((blkMode) << 27U) | ((addrIncr) << 26U) | ((addr) << 9U) | (count))
#define DRV_SDMMC_CMD53_WR_DATA(fn, addr, blkMode, count, addrIncr)    ((1UL << 31U) | ((fn) << 28U) | ((blkMode) << 27U) | ((addrIncr) << 26U) | ((addr) << 9U) | (count))

#define DRV_SDMMC_DATA_XFER_DIR_WR                          0U
#define DRV_SDMMC_DATA_XFER_DIR_RD                          1U

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 5.4"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */

// *****************************************************************************
/* SDMMC Read/Write/Erase Region Index Numbers

  Summary:
    SDMMC Geometry Table Index definitions.

  Description:
    These constants provide SDMMC Geometry Table index definitions.

  Remarks:
    None
*/
#define GEOMETRY_TABLE_READ_ENTRY   (0U)
#define GEOMETRY_TABLE_WRITE_ENTRY  (1U)
#define GEOMETRY_TABLE_ERASE_ENTRY  (2U)

// *****************************************************************************
// *****************************************************************************
// Section: SD Host Controller constants
// *****************************************************************************
// *****************************************************************************

typedef enum
{
    /* Normal SD Host Controller */
    DRV_SDMMC_CARD_TYPE_STANDARD,

    /* SDMMC type Card */
    DRV_SDMMC_CARD_TYPE_HC,

    DRV_SDMMC_CARD_TYPE_UNKNOWN,

}DRV_SDMMC_CARD_TYPE;

typedef enum
{
    DRV_SDMMC_CMD_RESP_NONE,   /*!< no response type */
    DRV_SDMMC_CMD_RESP_R1,     /*!< normal response command */
    DRV_SDMMC_CMD_RESP_R1B,    /*!< normal with busy signal */
    DRV_SDMMC_CMD_RESP_R2,     /*!< CID, CSD register */
    DRV_SDMMC_CMD_RESP_R3,     /*!< OCR register */
    DRV_SDMMC_CMD_RESP_R4,     /*!< */
    DRV_SDMMC_CMD_RESP_R5,     /*!< */
    DRV_SDMMC_CMD_RESP_R6,     /*!< Published RCA response  */
    DRV_SDMMC_CMD_RESP_R7      /*!< Card interface condition  */

} DRV_SDMMC_CMD_RESP_TYPE;

typedef enum
{
    DRV_SDMMC_INIT_SET_INIT_SPEED,
    DRV_SDMMC_INIT_WAIT_POLLING_TIMEOUT,
    DRV_SDMMC_INIT_RESET_IO_CARD,
    DRV_SDMMC_INIT_RESET_MEM_CARD,
    DRV_SDMMC_INIT_CHK_IFACE_CONDITION,
    DRV_SDMMC_INIT_SDIO_CMD5,
    DRV_SDMMC_INIT_SEND_ACMD41,
    DRV_SDMMC_INIT_SEND_OP_COND,
    DRV_SDMMC_INIT_ALL_SEND_CID,
    DRV_SDMMC_INIT_GET_RCA,
    DRV_SDMMC_INIT_SET_RELATIVE_ADDR,
    DRV_SDMMC_INIT_READ_CSD,
    DRV_SDMMC_INIT_READ_EXT_CSD,
    DRV_SDMMC_INIT_SELECT_CARD,
    DRV_SDMMC_INIT_SDIO_READ_SDIO_CCCR_REV,
    DRV_SDMMC_INIT_RD_CARD_CAP_SDIO,
    DRV_SDMMC_INIT_SCR_READ,
    DRV_SDMMC_INIT_DECIDE_BUS_WIDTH,
    DRV_SDMMC_INIT_SET_SDIO_BUS_WIDTH,
    DRV_SDMMC_INIT_SET_SDMEM_BUS_WIDTH,
    DRV_SDMMC_INIT_SET_HOST_BUS_WIDTH,
    DRV_SDMMC_INIT_SET_DEFAULT_SPEED_HOST,
    DRV_SDMMC_INIT_CHK_SDIO_HS_SPEED_SUP,
    DRV_SDMMC_INIT_CHK_SDMEM_HS_SPEED_SUP,
    DRV_SDMMC_INIT_SET_HS_SPEED_SDIO,
    DRV_SDMMC_INIT_SET_HS_SPEED_SDMEM,
    DRV_SDMMC_INIT_SET_HS_SPEED_HOST,
    DRV_SDMMC_INIT_RD_MAX_BLK_SIZE_SDIO,
    DRV_SDMMC_INIT_SET_BLK_LEN_SDIO,
    DRV_SDMMC_INIT_FN_EN_SDIO,
    DRV_SDMMC_INIT_SET_BLK_LEN_SDMEM,
    DRV_SDMMC_INIT_DESELECT_CARD,
    DRV_SDMMC_INIT_DONE,
    DRV_SDMMC_INIT_ERROR,
} DRV_SDMMC_INIT_STATES;

typedef enum
{
    DRV_SDMMC_TASK_WAIT_FOR_DEVICE_ATTACH = 0,
    DRV_SDMMC_TASK_START_CD_LINE_DEBOUNCE_TIMER,
    DRV_SDMMC_TASK_WAIT_CD_LINE_DEBOUNCE_TIMEOUT,
    DRV_SDMMC_TASK_MEDIA_INIT,
    DRV_SDMMC_TASK_PROCESS_QUEUE,
    DRV_SDMMC_TASK_SLEEP_WAKE_CARD,
    DRV_SDMMC_TASK_CHECK_SDIO_SEL_CARD_DETACH,
    DRV_SDMMC_TASK_CHECK_SDIO_DESEL_CARD_DETACH,
    DRV_SDMMC_TASK_CHECK_CARD_DETACH,
    DRV_SDMMC_TASK_SELECT_CARD,
    DRV_SDMMC_TASK_SETUP_XFER,
    DRV_SDMMC_TASK_XFER_COMMAND,
    DRV_SDMMC_TASK_WAIT_DATA_XFER_COMPLETE,
    DRV_SDMMC_TASK_XFER_STATUS,
    DRV_SDMMC_TASK_SEND_STOP_TRANS_CMD,
    DRV_SDMMC_TASK_CHECK_CARD_STATUS,
    DRV_SDMMC_TASK_DESELECT_CARD,
    DRV_SDMMC_TASK_ERROR,
    DRV_SDMMC_TASK_TRANSFER_COMPLETE,
    DRV_SDMMC_TASK_HANDLE_CARD_DETACH

} DRV_SDMMC_TASK_STATES;

typedef enum
{
    /* Command code to reset the SD card /eMMC device */
    DRV_SDMMC_CMD_GO_IDLE_STATE = 0,

    /* Command code to get the operating condition of an MMC device */
    DRV_SDMMC_CMD_SEND_OP_COND  = 1,

    /* Broadcast command code to get all card IDs */
    DRV_SDMMC_CMD_ALL_SEND_CID  = 2,

    /* Command card to respond with its RCA, tells it to go to standby state */
    DRV_SDMMC_CMD_SEND_RCA  = 3,

    /* Command to eMMC device to set its relative addressas specified by host */
    DRV_SDMMC_CMD_SET_RELATIVE_ADDR = 3,

    /* Command to eMMC device to enter in and out of sleep mode */
    DRV_SDMMC_CMD_SLEEP_WAKE = 5,

    /* Command to SDIO device to send its OCR */
    DRV_SDMMC_CMD_SDIO_SEND_OP_COND = 5,

    /* ACMD6 sets the card's bus width between 1-bit and 4-bit, only available when the card is unlocked */
    DRV_SDMMC_CMD_SWITCH_FUNCTION = 6,

    /* ACMD6 sets the card's bus width between 1-bit and 4-bit, only available when the card is unlocked */
    DRV_SDMMC_CMD_SET_BUS_WIDTH  = 6,

    /* Command to switch modes of EMMC device */
    DRV_SDMMC_CMD_SWITCH = 6,

    /* Select/Deselect card message, sends the card to transfer state */
    DRV_SDMMC_CMD_SELECT_DESELECT_CARD = 7,

    /* This macro defined the command code to check for sector addressing */
    DRV_SDMMC_CMD_SEND_IF_COND  = 8,

    /* Command to fetch extended CSD for an MMC device */
    DRV_SDMMC_CMD_SEND_EXT_CSD = 8,

    /* Command code to get the Card Specific Data */
    DRV_SDMMC_CMD_SEND_CSD      = 9,

    /* Command code to get the Card Information */
    DRV_SDMMC_CMD_SEND_CID      = 10,

    /* Command code to stop transmission during a multi-block read */
    DRV_SDMMC_CMD_STOP_TRANSMISSION = 12,

    /* Command code to get the card status information */
    DRV_SDMMC_CMD_SEND_STATUS       = 13,

    /* Command code to set the block length of the card */
    DRV_SDMMC_CMD_SET_BLOCKLEN      = 16,

    /* Command code to read one block from the card */
    DRV_SDMMC_CMD_READ_SINGLE_BLOCK  = 17,

    /* Command code to read multiple blocks from the card */
    DRV_SDMMC_CMD_READ_MULTI_BLOCK   = 18,

    /* Command code to tell the media how many blocks to pre-erase
     (for faster multi-block writes to follow)
     Note: This is an "application specific" command.  This tells the media how
     many blocks to pre-erase for the subsequent WRITE_MULTI_BLOCK */
    DRV_SDMMC_CMD_SET_WR_BLK_ERASE_COUNT =  23,

    /* Command code to write one block to the card */
    DRV_SDMMC_CMD_WRITE_SINGLE_BLOCK  = 24,

    /* Command code to write multiple blocks to the card */
    DRV_SDMMC_CMD_WRITE_MULTI_BLOCK   = 25,

    /* Command code to set the address of the start of an erase operation */
    DRV_SDMMC_CMD_TAG_SECTOR_START    = 32,

    /* Command code to set the address of the end of an erase operation */
    DRV_SDMMC_CMD_TAG_SECTOR_END      = 33,

    /* Command code to erase all previously selected blocks */
    DRV_SDMMC_CMD_ERASE              =  38,

    /* Command code to initialize an SD card and provide the CSD register value.
    Note: this is an "application specific" command (specific to SD cards)
    and must be preceded by CMD_APP_CMD */
    DRV_SDMMC_CMD_SD_SEND_OP_COND     = 41,

    /* Command code to get the SCR register information from the card */
    DRV_SDMMC_CMD_READ_SCR            = 51,

    /* Single byte read/write command for SDIO cards */
    DRV_SDMMC_CMD_IO_RW_DIR           = 52,

    /* Multi byte read/write command for SDIO cards */
    DRV_SDMMC_CMD_IO_RW_EXT           = 53,

    /* Command code to begin application specific command inputs */
    DRV_SDMMC_CMD_APP_CMD             = 55,

    /* Command code to get the OCR register information from the card */
    DRV_SDMMC_CMD_READ_OCR            = 58,

    /* Command code to disable CRC checking */
    DRV_SDMMC_CMD_CRC_ON_OFF          = 59,

} DRV_SDMMC_SD_COMMAND;

typedef enum
{
    DRV_SDMMC_CMD_LINE_STATE_CHECK = 0,
    DRV_SDMMC_CMD_FRAME_AND_SEND_CMD,
    DRV_SDMMC_CMD_CHECK_TRANSFER_COMPLETE,
    DRV_SDMMC_CMD_EXEC_IS_COMPLETE

} DRV_SDMMC_COMMAND_STATES;

typedef enum
{
    /* Set the clock divider value. */
    DRV_SDMMC_CLOCK_SET_DIVIDER = 0,

    /* Wait for the internal clock stable bit to be set. */
    DRV_SDMMC_CLOCK_PRE_ENABLE_DELAY,

    /* Enable the clock. */
    DRV_SDMMC_CLOCK_ENABLE,

    /* Delay post clock enable. */
    DRV_SDMMC_CLOCK_POST_ENABLE_DELAY,

    /* Clock set is complete. */
    DRV_SDMMC_CLOCK_SET_COMPLETE

} DRV_SDMMC_CLOCK_STATES;

typedef enum
{
    DRV_SDMMC_EMMC_STATE_WAKE = 0,
    DRV_SDMMC_EMMC_STATE_SLEEP,

} DRV_SDMMC_EMMC_STATE;

typedef struct
{
    uint8_t __ALIGNED(4)            cidBuffer[DRV_SDMMC_CID_BUFFER_LEN];
    uint8_t __ALIGNED(4)            csdBuffer[DRV_SDMMC_CSD_BUFFER_LEN];
<#if core.PRODUCT_FAMILY?contains("PIC32MZ")>
    uint8_t*                        scrBuffer;
    uint8_t*                        switchStatusBuffer;
    uint8_t*                        extCSDBuffer;
<#else>
    uint8_t CACHE_ALIGN             scrBuffer[DRV_SDMMC_SCR_BUFFER_LEN];
    uint8_t CACHE_ALIGN             switchStatusBuffer[DRV_SDMMC_SWITCH_STATUS_BUFFER_LEN];
    uint8_t CACHE_ALIGN             extCSDBuffer[DRV_SDMMC_EXT_CSD_RESP_SIZE];
</#if>
    bool                            isAttached;
    DRV_SDMMC_BUS_WIDTH             busWidth;
    uint16_t                        rca;
    uint8_t                         cmd6Mode;
    uint8_t                         voltWindow;
    /* SDSD or SDHC card type */
    DRV_SDMMC_CARD_TYPE             cardType;
    /* Capacity of the card in number of blocks. */
    uint32_t                        discCapacity;
    uint8_t                         cardVer;
    bool                            isWriteProtected;
    bool                            isLocked;
    /* Variables to track the command/data transfer status. */
    bool                            isDataCompleted;
    bool                            isCommandCompleted;
    uint16_t                        errorFlag;
    uint32_t                        currentSpeed;
    uint32_t                        defaultSpeed;
    uint8_t                         nf;
    uint8_t                         mp;
    uint8_t                         sdioCardCapability;
    uint8_t                         currentFn;
    uint8_t                         sdioCCCRRev;
    uint32_t                        blockSize;
} DRV_SDHOST_CARD_CTXT;

// *****************************************************************************
/* SD Host Controller Driver Client Object

  Summary:
    Defines the object required for the maintenance of the software clients

  Description:
    This defines the object required for the maintenance of the software
    clients instance. This object exists once per client instance.

  Remarks:
    None
*/

typedef struct
{
    /* The hardware instance index associated with the client */
    SYS_MODULE_INDEX                    drvIndex;

    /* Flag to indicate in use  */
    bool                                inUse;

    /* The intent with which the client was opened */
    DRV_IO_INTENT                       intent;

    /* Client specific event handler */
    DRV_SDMMC_EVENT_HANDLER             eventHandler;

    /* Client specific context */
    uintptr_t                           context;

    /* Client handle assigned to this client object when it was opened */
    DRV_HANDLE                          clientHandle;

} DRV_SDMMC_CLIENT_OBJ;


typedef struct DRV_SDMMC_BUFFER_OBJ
{
    /* True if object is allocated */
    bool                                inUse;

    /* Handle to the client that owns this buffer object */
    DRV_HANDLE                          clientHandle;

    /* Present status of this command */
    DRV_SDMMC_COMMAND_STATUS            status;

    /* Current command handle of this buffer object */
    DRV_SDMMC_COMMAND_HANDLE            commandHandle;

    /* Pointer to the source/destination buffer */
    uint8_t*                            buffer;

    /* Start address of the operation. */
    uint32_t                            blockStart;

    /* Number of blocks */
    uint32_t                            nBlocks;

    /* Op code associated with the buffer object. */
    uint8_t                             opCode;

    /* Operation type - read/write */
    DRV_SDMMC_OPERATION_TYPE            opType;

    /* Pointer to the next buffer in the queue */
    struct DRV_SDMMC_BUFFER_OBJ*        next;

    uint8_t                             fn;

    bool                                isAddrInc;

    uint32_t                            arg;

    uint8_t                             respType;

} DRV_SDMMC_BUFFER_OBJ;


// *****************************************************************************
/* SD Host Controller Driver Hardware Instance Object

  Summary:
    Defines the object required for the maintenance of the hardware instance

  Description:
    This defines the object required for the maintenance of the hardware
    instance. This object exists once per hardware instance of the peripheral.

  Remarks:
    None
*/

typedef struct
{
    /* The status of the driver */
    SYS_STATUS                      status;

    /* Flag to indicate in use  */
    bool                            inUse;

    /* Card detection method to use */
    DRV_SDMMC_CD_METHOD             cardDetectionMethod;

    /* Rate at which card insertion/removal is checked if polling method is selected */
    uint32_t                        cardDetectionPollingIntervalMs;

    /* SDMMC PLIB API */
    const DRV_SDMMC_PLIB_API*       sdmmcPlib;

    /* Card context data */
    DRV_SDHOST_CARD_CTXT            cardCtxt;

    /* Flag to indicate if the driver is used in exclusive mode of operation */
    bool                            isExclusive;

    /* Instance specific token counter used to generate unique client/transfer handles */
    uint16_t                        sdmmcTokenCount;

    /* Size of buffer objects queue */
    uint32_t                        bufferObjPoolSize;

    /* Pointer to the buffer pool */
    uintptr_t                       bufferObjPool;

    /* Linked list of buffer objects */
    uintptr_t                       bufferObjList;

    /* Number of active clients */
    size_t                          nClients;

    /* Maximum number of clients */
    size_t                          nClientsMax;

    /* Memory Pool for Client Objects */
    uintptr_t                       clientObjPool;

    /* Whether the write protect pin should be used to check if the card is
     * write protected. */
    bool                            isWriteProtectCheckEnabled;

    /* Sent command status. */
    uint8_t                         commandStatus;

    /* Status of the device */
    SYS_MEDIA_STATUS                mediaState;

    /* This variable holds the current state of the DRV_SDMMC_Tasks */
    DRV_SDMMC_TASK_STATES           taskState;

    /* Different stages in media initialization */
    DRV_SDMMC_INIT_STATES           initState;

    DRV_SDMMC_INIT_STATES           nextInitState;

    /* Different states in sending a command */
    DRV_SDMMC_COMMAND_STATES        cmdState;

    /* Data transfer flags */
    DRV_SDMMC_DataTransferFlags     dataTransferFlags;

    /* Different states in setting up the clock */
    DRV_SDMMC_CLOCK_STATES          clockState;

    /* System Timer Handle */
    SYS_TIME_HANDLE                 tmrHandle;

    SYS_TIME_HANDLE                 generalTimerHandle;

    /* Protocol to be used */
    DRV_SDMMC_PROTOCOL              protocol;

    /* Speed mode - Default Speed or High Speed mode of operation. */
    DRV_SDMMC_SPEED_MODE            speedMode;

    /* Bus width to be used for the card. */
    DRV_SDMMC_BUS_WIDTH             busWidth;

    /* Timer command handle. */
    SYS_TIME_HANDLE                 cmdTimerHandle;

    /* Timer command state. */
    bool                            isCmdTimerExpired;

    /* Indicates if the eMMC card is put to sleep mode when it is idle */
    bool                            sleepWhenIdle;

    /* Indicates the status of eMMC card - either in Sleep or Wake state */
    DRV_SDMMC_EMMC_STATE            emmcSleepWakeState;

    /* Variable used to track the number of trials of a particular operation */
    uint16_t                        trials;

    /* SDMMC driver geometry object */
    SYS_MEDIA_GEOMETRY              mediaGeometryObj;

    /* SDMMC driver media geometry table. */
    SYS_MEDIA_REGION_GEOMETRY       mediaGeometryTable[3];

    /* Mutex to protect access to the transfer objects */
    OSAL_MUTEX_DECLARE(mutex);

    /* Mutex to protect access to the client objects */
    OSAL_MUTEX_DECLARE(mutexClientObjects);

    /* Bit-0 => SD Mem. Bit-1 => SD IO */
    uint8_t                         sdCardType;

} DRV_SDMMC_OBJ;

#endif //#ifndef DRV_SDMMC_LOCAL_H