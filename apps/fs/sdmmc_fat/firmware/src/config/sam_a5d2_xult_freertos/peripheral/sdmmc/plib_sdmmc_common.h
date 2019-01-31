/*******************************************************************************
  SDMMC PLIB

  Company:
    Microchip Technology Inc.

  File Name:
    plib_sdmmc_common.h

  Summary:
    Contains definitions common to all the instances of SDMMC PLIB

  Description:
    None

*******************************************************************************/

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

#ifndef PLIB_SDMMC_COMMON_H
#define PLIB_SDMMC_COMMON_H

#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>
#include "device.h"

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif
// DOM-IGNORE-END

/* ADMA Descriptor Table Attribute Mask */
#define SDMMC_DESC_TABLE_ATTR_NO_OP          (0x00 << 4)
#define SDMMC_DESC_TABLE_ATTR_RSVD           (0x01 << 4)
#define SDMMC_DESC_TABLE_ATTR_XFER_DATA      (0x02 << 4)
#define SDMMC_DESC_TABLE_ATTR_LINK_DESC      (0x03 << 4)

#define SDMMC_DESC_TABLE_ATTR_VALID          (1 << 0)
#define SDMMC_DESC_TABLE_ATTR_END            (1 << 1)
#define SDMMC_DESC_TABLE_ATTR_INTR           (1 << 2)

#define SDMMC_CLOCK_FREQ_400_KHZ             (400000)
#define SDMMC_CLOCK_FREQ_DS_25_MHZ           (25000000)
#define SDMMC_CLOCK_FREQ_HS_50_MHZ           (50000000)

#define SDMMC_CLOCK_FREQ_HS_26_MHZ           (26000000)
#define SDMMC_CLOCK_FREQ_HS_52_MHZ           (52000000)

typedef enum
{
    SDMMC_BUS_WIDTH_1_BIT = 0,
    SDMMC_BUS_WIDTH_4_BIT

} SDMMC_BUS_WIDTH;

typedef enum
{
    SDMMC_SPEED_MODE_NORMAL = 0,
    SDMMC_SPEED_MODE_HIGH

} SDMMC_SPEED_MODE;

typedef enum SDMMC_CMD_RESP_TYPE
{
    SDMMC_CMD_RESP_NONE,   /*!< no response type */
    SDMMC_CMD_RESP_R1,     /*!< normal response command */
    SDMMC_CMD_RESP_R1B,    /*!< normal with busy signal */
    SDMMC_CMD_RESP_R2,     /*!< CID, CSD register */
    SDMMC_CMD_RESP_R3,     /*!< OCR register */
    SDMMC_CMD_RESP_R4,     /*!< */
    SDMMC_CMD_RESP_R5,     /*!< */
    SDMMC_CMD_RESP_R6,     /*!< Published RCA response  */
    SDMMC_CMD_RESP_R7      /*!< Card interface condition  */

} SDMMC_CMD_RESP_TYPE;


typedef enum
{
    SDMMC_READ_RESP_REG_0 = 0,
    SDMMC_READ_RESP_REG_1,
    SDMMC_READ_RESP_REG_2,
    SDMMC_READ_RESP_REG_3,
    SDMMC_READ_RESP_REG_ALL

} SDMMC_READ_RESPONSE_REG;

typedef enum
{
    SDMMC_RESET_ALL = 0x01,
    SDMMC_RESET_CMD = 0x02,
    SDMMC_RESET_DAT = 0x04

} SDMMC_RESET_TYPE;

typedef enum
{
    SDMMC_DIVIDED_CLK_MODE = 0,
    SDMMC_PROGRAMMABLE_CLK_MODE

}SDMMC_CLK_MODE;

typedef enum
{
    SDMMC_XFER_STATUS_IDLE           = 0x00,
    SDMMC_XFER_STATUS_CMD_COMPLETED  = 0x01,
    SDMMC_XFER_STATUS_DATA_COMPLETED = 0x02,
    SDMMC_XFER_STATUS_CARD_INSERTED  = 0x04,
    SDMMC_XFER_STATUS_CARD_REMOVED   = 0x08

}SDMMC_XFER_STATUS;

typedef enum
{
    SDMMC_DATA_TRANSFER_TYPE_SINGLE = 0,
    SDMMC_DATA_TRANSFER_TYPE_MULTI,

}SDMMC_DATA_TRANSFER_TYPE;

typedef enum
{
    SDMMC_DATA_TRANSFER_DIR_WRITE = 0,
    SDMMC_DATA_TRANSFER_DIR_READ

}SDMMC_DATA_TRANSFER_DIR;

typedef struct
{
    bool                                isDataPresent;
    SDMMC_DATA_TRANSFER_DIR             transferDir;
    SDMMC_DATA_TRANSFER_TYPE            transferType;

}SDMMC_DataTransferFlags;

typedef struct
{
    uint16_t                            attribute;
    uint16_t                            length;
    uint32_t                            address;
} SDMMC_ADMA_DESCR;

typedef  void (*SDMMC_CALLBACK) (SDMMC_XFER_STATUS xferStatus, uintptr_t context);

typedef struct
{
    bool                                isCmdInProgress;
    bool                                isDataInProgress;
    uint16_t                            errorStatus;
    SDMMC_CALLBACK                      callback;
    uintptr_t                           context;

} SDMMC_OBJECT;

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility
    }
#endif

// DOM-IGNORE-END
#endif // PLIB_SDMMC_COMMON_H
