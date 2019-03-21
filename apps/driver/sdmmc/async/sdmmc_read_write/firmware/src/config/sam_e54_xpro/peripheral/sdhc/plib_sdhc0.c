/*******************************************************************************
  SDHC0 PLIB

  Company:
    Microchip Technology Inc.

  File Name:
    plib_sdhc0.c

  Summary:
    SDHC0 PLIB Implementation File

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

#include "device.h"
#include "plib_sdhc0.h"


// *****************************************************************************
// *****************************************************************************
// Section: Include Files
// *****************************************************************************
// *****************************************************************************

#include "plib_sdhc_common.h"

#define SDHC0_DMA_NUM_DESCR_LINES        1
#define SDHC0_BASE_CLOCK_FREQUENCY       120000000

static __attribute__((__aligned__(32))) SDHC_ADMA_DESCR sdhc0DmaDescrTable[SDHC0_DMA_NUM_DESCR_LINES];

static SDHC_OBJECT sdhc0Obj;

static void SDHC0_VariablesInit ( void )
{
    sdhc0Obj.errorStatus = 0;
    sdhc0Obj.isCmdInProgress = false;
    sdhc0Obj.isDataInProgress = false;
    sdhc0Obj.callback = NULL;
}

static void SDHC0_TransferModeSet ( uint32_t opcode )
{
    uint16_t transferMode = 0;

    switch(opcode)
    {
        case 51:
        case 6:
        case 17:
            /* Read single block of data from the device. */
            transferMode = (SDHC_TMR_DMAEN_ENABLE | SDHC_TMR_DTDSEL_Msk);
            break;

        case 18:
            /* Read multiple blocks of data from the device. */
            transferMode = (SDHC_TMR_DMAEN_ENABLE | SDHC_TMR_DTDSEL_Msk | SDHC_TMR_MSBSEL_Msk | SDHC_TMR_BCEN_Msk);
            break;

        case 24:
            /* Write single block of data to the device. */
            transferMode = SDHC_TMR_DMAEN_ENABLE;
            break;

        case 25:
            /* Write multiple blocks of data to the device. */
            transferMode = (SDHC_TMR_DMAEN_ENABLE | SDHC_TMR_MSBSEL_Msk | SDHC_TMR_BCEN_Msk);
            break;

        default:
            break;
    }

    SDHC0_REGS->SDHC_TMR = transferMode;
}

void SDHC0_InterruptHandler(void)
{
    uint16_t nistr = 0;
    uint16_t eistr = 0;
    SDHC_XFER_STATUS xferStatus = 0;

    nistr = SDHC0_REGS->SDHC_NISTR;
    eistr = SDHC0_REGS->SDHC_EISTR;
    /* Save the error in a global variable for later use */
    sdhc0Obj.errorStatus |= eistr;

    if (nistr & SDHC_NISTR_CINS_Msk)
    {
        xferStatus |= SDHC_XFER_STATUS_CARD_INSERTED;
    }
    if (nistr & SDHC_NISTR_CREM_Msk)
    {
        xferStatus |= SDHC_XFER_STATUS_CARD_REMOVED;
    }

    if (sdhc0Obj.isCmdInProgress == true)
    {
        if (nistr & (SDHC_NISTR_CMDC_Msk | SDHC_NISTR_TRFC_Msk | SDHC_NISTR_ERRINT_Msk))
        {
            if (nistr & SDHC_NISTR_ERRINT_Msk)
            {
                if (eistr & (SDHC_EISTR_CMDTEO_Msk | \
                                      SDHC_EISTR_CMDCRC_Msk | \
                                      SDHC_EISTR_CMDEND_Msk | \
                                      SDHC_EISTR_CMDIDX_Msk))
                {
                    SDHC0_ErrorReset (SDHC_RESET_CMD);
                }
            }
            sdhc0Obj.isCmdInProgress = false;
            xferStatus |= SDHC_XFER_STATUS_CMD_COMPLETED;
        }
    }

    if (sdhc0Obj.isDataInProgress == true)
    {
        if (nistr & (SDHC_NISTR_TRFC_Msk | SDHC_NISTR_DMAINT_Msk | SDHC_NISTR_ERRINT_Msk))
        {
            if (nistr & SDHC_NISTR_ERRINT_Msk)
            {
                if (eistr & (SDHC_EISTR_DATTEO_Msk | \
                            SDHC_EISTR_DATCRC_Msk | \
                            SDHC_EISTR_DATEND_Msk))
                {
                    SDHC0_ErrorReset (SDHC_RESET_DAT);
                }
            }
            if (nistr & SDHC_NISTR_TRFC_Msk)
            {
                /* Clear the data timeout error as transfer complete has higher priority */
                sdhc0Obj.errorStatus &= ~SDHC_EISTR_DATTEO_Msk;
            }
            sdhc0Obj.isDataInProgress = false;
            xferStatus |= SDHC_XFER_STATUS_DATA_COMPLETED;
        }
    }

    /* Clear normal interrupt and error status bits that have been processed */
    SDHC0_REGS->SDHC_NISTR = nistr;
    SDHC0_REGS->SDHC_EISTR = eistr;

    if ((sdhc0Obj.callback != NULL) && (xferStatus > 0))
    {
        sdhc0Obj.callback(xferStatus, sdhc0Obj.context);
    }
}

void SDHC0_ErrorReset ( SDHC_RESET_TYPE resetType )
{
    SDHC0_REGS->SDHC_SRR = resetType;

    /* Wait until host resets the error status */
    while (SDHC0_REGS->SDHC_SRR & resetType);
}

uint16_t SDHC0_GetError(void)
{
    return sdhc0Obj.errorStatus;
}

uint16_t SDHC0_CommandErrorGet(void)
{
    return (sdhc0Obj.errorStatus & (SDHC_EISTR_CMDTEO_Msk | SDHC_EISTR_CMDCRC_Msk | \
                SDHC_EISTR_CMDEND_Msk));
}

uint16_t SDHC0_DataErrorGet(void)
{
    return (sdhc0Obj.errorStatus & (SDHC_EISTR_ADMA_Msk | SDHC_EISTR_DATTEO_Msk | \
            SDHC_EISTR_DATCRC_Msk | SDHC_EISTR_DATEND_Msk));
}

void SDHC0_BusWidthSet ( SDHC_BUS_WIDTH busWidth )
{
    if (busWidth == SDHC_BUS_WIDTH_4_BIT)
    {
       SDHC0_REGS->SDHC_HC1R |= SDHC_HC1R_DW_4BIT;
    }
    else
    {
        SDHC0_REGS->SDHC_HC1R &= ~SDHC_HC1R_DW_4BIT;
    }
}

void SDHC0_SpeedModeSet ( SDHC_SPEED_MODE speedMode )
{
    if (speedMode == SDHC_SPEED_MODE_HIGH)
    {
       SDHC0_REGS->SDHC_HC1R |= SDHC_HC1R_HSEN_Msk;
    }
    else
    {
       SDHC0_REGS->SDHC_HC1R &= ~SDHC_HC1R_HSEN_Msk;
    }
}

bool SDHC0_IsCmdLineBusy ( void )
{
    return(((SDHC0_REGS->SDHC_PSR & SDHC_PSR_CMDINHC_Msk) == SDHC_PSR_CMDINHC_Msk)? true : false);
}

bool SDHC0_IsDatLineBusy ( void )
{
    return (((SDHC0_REGS->SDHC_PSR & SDHC_PSR_CMDINHD_Msk) == SDHC_PSR_CMDINHD_Msk)? true : false);
}

bool SDHC0_IsWriteProtected ( void )
{
   return false;
}

bool SDHC0_IsCardAttached ( void )
{
    return ((SDHC0_REGS->SDHC_PSR & SDHC_PSR_CARDINS_Msk) == SDHC_PSR_CARDINS_Msk)? true : false;
}

void SDHC0_BlockSizeSet ( uint16_t blockSize )
{
    SDHC0_REGS->SDHC_BSR = blockSize;
}

void SDHC0_BlockCountSet ( uint16_t numBlocks )
{
    SDHC0_REGS->SDHC_BCR = numBlocks;
}

void SDHC0_ClockEnable ( void )
{
    SDHC0_REGS->SDHC_CCR |= (SDHC_CCR_INTCLKEN_Msk | SDHC_CCR_SDCLKEN_Msk);
}

void SDHC0_ClockDisable ( void )
{
    SDHC0_REGS->SDHC_CCR &= ~(SDHC_CCR_INTCLKEN_Msk | SDHC_CCR_SDCLKEN_Msk);
}

void SDHC0_DmaSetup (
    uint8_t* buffer,
    uint32_t numBytes,
    SDHC_DATA_TRANSFER_DIR direction
)
{
    uint32_t i;
    uint32_t pendingBytes = numBytes;
    uint32_t nBytes = 0;

    (void)direction;

    /* Each ADMA2 descriptor can transfer 65536 bytes (or 128 blocks) of data.
     * Block count register being a 16 bit register, maximum number of blocks is
     * limited to 65536 blocks. Hence, combined length of data that can be
     * transferred by all the descriptors is 512 bytes x 65536 blocks, assuming
     * a block size of 512 bytes.
     */

    if (pendingBytes > (65536 * SDHC0_DMA_NUM_DESCR_LINES))
    {
        /* Too many blocks requested in one go */
        return;
    }

    for (i = 0; (i < SDHC0_DMA_NUM_DESCR_LINES) && (pendingBytes > 0); i++)
    {
        if (pendingBytes > 65536)
        {
            nBytes = 65536;
        }
        else
        {
            nBytes = pendingBytes;
        }
        sdhc0DmaDescrTable[i].address = (uint32_t)(buffer);
        sdhc0DmaDescrTable[i].length = nBytes;
        sdhc0DmaDescrTable[i].attribute = \
            (SDHC_DESC_TABLE_ATTR_XFER_DATA | SDHC_DESC_TABLE_ATTR_VALID | SDHC_DESC_TABLE_ATTR_INTR);

        pendingBytes = pendingBytes - nBytes;
    }

    /* The last descriptor line must indicate the end of the descriptor list */
    sdhc0DmaDescrTable[i-1].attribute |= (SDHC_DESC_TABLE_ATTR_END);

    /* Set the starting address of the descriptor table */
    SDHC0_REGS->SDHC_ASAR[0] = (uint32_t)(&sdhc0DmaDescrTable[0]);
}

bool SDHC0_ClockSet ( uint32_t speed)
{
    uint32_t baseclk_frq = 0;
    uint16_t divider = 0;
    uint32_t clkmul = 0;
    SDHC_CLK_MODE clkMode = SDHC_PROGRAMMABLE_CLK_MODE;

    /* Disable clock before changing it */
    if (SDHC0_REGS->SDHC_CCR & SDHC_CCR_SDCLKEN_Msk)
    {
        while (SDHC0_REGS->SDHC_PSR & (SDHC_PSR_CMDINHC_Msk | SDHC_PSR_CMDINHD_Msk));
        SDHC0_REGS->SDHC_CCR &= ~SDHC_CCR_SDCLKEN_Msk;
    }

    /* Get the base clock frequency */
    baseclk_frq = (SDHC0_REGS->SDHC_CA0R & (SDHC_CA0R_BASECLKF_Msk)) >> SDHC_CA0R_BASECLKF_Pos;
    if (baseclk_frq == 0)
    {
        baseclk_frq = SDHC0_BASE_CLOCK_FREQUENCY/2;
    }
    else
    {
        baseclk_frq *= 1000000;
    }

    if (clkMode == SDHC_DIVIDED_CLK_MODE)
    {
        /* F_SDCLK = F_BASECLK/(2 x DIV).
           For a given F_SDCLK, DIV = F_BASECLK/(2 x F_SDCLK)
        */

        divider =  baseclk_frq/(2 * speed);
        SDHC0_REGS->SDHC_CCR &= ~SDHC_CCR_CLKGSEL_Msk;
    }
    else
    {
        clkmul = (SDHC0_REGS->SDHC_CA1R & (SDHC_CA1R_CLKMULT_Msk)) >> SDHC_CA1R_CLKMULT_Pos;
        if (clkmul > 0)
        {
            /* F_SDCLK = F_MULTCLK/(DIV+1), where F_MULTCLK = F_BASECLK x (CLKMULT+1)
               F_SDCLK = (F_BASECLK x (CLKMULT + 1))/(DIV + 1)
               For a given F_SDCLK, DIV = [(F_BASECLK x (CLKMULT + 1))/F_SDCLK] - 1
            */
            divider = (baseclk_frq * (clkmul + 1)) / speed;
            if (divider > 0)
            {
                divider = divider - 1;
            }
            SDHC0_REGS->SDHC_CCR |= SDHC_CCR_CLKGSEL_Msk;
        }
        else
        {
            /* Programmable clock mode is not supported */
            return false;
        }
    }

    if (speed > SDHC_CLOCK_FREQ_DS_25_MHZ)
    {
        /* Enable the high speed mode */
        SDHC0_REGS->SDHC_HC1R |= SDHC_HC1R_HSEN_Msk;
    }
    else
    {
        /* Clear the high speed mode */
        SDHC0_REGS->SDHC_HC1R &= ~SDHC_HC1R_HSEN_Msk;
    }

    if ((SDHC0_REGS->SDHC_HC1R & SDHC_HC1R_HSEN_Msk) && (divider == 0))
    {
        /* IP limitation, if high speed mode is active divider must be non zero */
        divider = 1;
    }

    /* Set the divider */
    SDHC0_REGS->SDHC_CCR &= ~(SDHC_CCR_SDCLKFSEL_Msk | SDHC_CCR_USDCLKFSEL_Msk);
    SDHC0_REGS->SDHC_CCR |= SDHC_CCR_SDCLKFSEL((divider & 0xff)) | SDHC_CCR_USDCLKFSEL((divider >> 8));

    /* Enable internal clock */
    SDHC0_REGS->SDHC_CCR |= SDHC_CCR_INTCLKEN_Msk;

    /* Wait for the internal clock to stabilize */
    while((SDHC0_REGS->SDHC_CCR & SDHC_CCR_INTCLKS_Msk) == 0);

    /* Enable the SDCLK */
    SDHC0_REGS->SDHC_CCR |= SDHC_CCR_SDCLKEN_Msk;

    return true;
}

void SDHC0_ResponseRead (
    SDHC_READ_RESPONSE_REG respReg,
    uint32_t* response
)
{
    switch (respReg)
    {
        case SDHC_READ_RESP_REG_0:
        default:
            *response = SDHC0_REGS->SDHC_RR[0];
            break;

        case SDHC_READ_RESP_REG_1:
            *response = SDHC0_REGS->SDHC_RR[1];
            break;

        case SDHC_READ_RESP_REG_2:
            *response = SDHC0_REGS->SDHC_RR[2];
            break;

        case SDHC_READ_RESP_REG_3:
            *response = SDHC0_REGS->SDHC_RR[3];
            break;

        case SDHC_READ_RESP_REG_ALL:
            response[0] = SDHC0_REGS->SDHC_RR[0];
            response[1] = SDHC0_REGS->SDHC_RR[1];
            response[2] = SDHC0_REGS->SDHC_RR[2];
            response[3] = SDHC0_REGS->SDHC_RR[3];
            break;
    }
}

void SDHC0_CommandSend (
    uint8_t opCode,
    uint32_t argument,
    uint8_t respType,
    SDHC_DataTransferFlags transferFlags
)
{
    uint16_t cmd = 0;
    uint16_t normalIntSigEnable = 0;
    uint8_t flags = 0;

    /* Clear the flags */
    sdhc0Obj.isCmdInProgress = false;
    sdhc0Obj.isDataInProgress = false;
    sdhc0Obj.errorStatus = 0;

    /* Keep the card insertion and removal interrupts enabled */
    normalIntSigEnable = (SDHC_NISIER_CINS_Msk | SDHC_NISIER_CREM_Msk);

    switch (respType)
    {
        case SDHC_CMD_RESP_R1:
        case SDHC_CMD_RESP_R5:
        case SDHC_CMD_RESP_R6:
        case SDHC_CMD_RESP_R7:
            flags = (SDHC_CR_RESPTYP_48_BIT_Val | SDHC_CR_CMDCCEN_Msk | SDHC_CR_CMDICEN_Msk);
            break;

        case SDHC_CMD_RESP_R3:
        case SDHC_CMD_RESP_R4:
            flags = SDHC_CR_RESPTYP_48_BIT_Val;
            break;

        case SDHC_CMD_RESP_R1B:
            flags = (SDHC_CR_RESPTYP_48_BIT_BUSY_Val | SDHC_CR_CMDCCEN_Msk | SDHC_CR_CMDICEN_Msk);

            /* Commands with busy response will wait for transfer complete bit */
            normalIntSigEnable |= SDHC_NISIER_TRFC_Msk;
            break;

        case SDHC_CMD_RESP_R2:
            flags = (SDHC_CR_RESPTYP_136_BIT_Val | SDHC_CR_CMDCCEN_Msk);
            break;

        default:
            flags = SDHC_CR_RESPTYP_NONE_Val;
            break;
    }

    /* Enable command complete interrupt, for commands that do not have busy response type */
    if (respType != SDHC_CMD_RESP_R1B)
    {
        normalIntSigEnable |= SDHC_NISIER_CMDC_Msk;
    }

    if (transferFlags.isDataPresent == true)
    {
        sdhc0Obj.isDataInProgress = true;
        SDHC0_TransferModeSet(opCode);
        /* Enable data transfer complete and DMA interrupt */
        normalIntSigEnable |= (SDHC_NISIER_TRFC_Msk | SDHC_NISIER_DMAINT_Msk);
    }
    else
    {
        SDHC0_REGS->SDHC_TMR = 0;
    }

    /* Enable the needed normal interrupt signals */
    SDHC0_REGS->SDHC_NISIER = normalIntSigEnable;

    /* Enable all the error interrupt signals */
    SDHC0_REGS->SDHC_EISIER = SDHC_EISIER_Msk;

    SDHC0_REGS->SDHC_ARG1R = argument;

    sdhc0Obj.isCmdInProgress = true;

    cmd = (SDHC_CR_CMDIDX(opCode) | (transferFlags.isDataPresent << SDHC_CR_DPSEL_Pos) | flags);
    SDHC0_REGS->SDHC_CR = cmd;
}

void SDHC0_ModuleInit( void )
{
    /* Reset module*/
    SDHC0_REGS->SDHC_SRR |= SDHC_SRR_SWRSTALL_Msk;
    while((SDHC0_REGS->SDHC_SRR & SDHC_SRR_SWRSTALL_Msk) == SDHC_SRR_SWRSTALL_Msk);

    /* Clear the normal and error interrupt status flags */
    SDHC0_REGS->SDHC_EISTR = SDHC_EISTR_Msk;
    SDHC0_REGS->SDHC_NISTR = SDHC_NISTR_Msk;

    /* Enable all the normal interrupt status and error status generation */
    SDHC0_REGS->SDHC_NISTER = SDHC_NISTER_Msk;
    SDHC0_REGS->SDHC_EISTER = SDHC_EISTER_Msk;

    /* Set timeout control register */
    SDHC0_REGS->SDHC_TCR = SDHC_TCR_DTCVAL(0xE);

    /* If card detect line is not used, enable the card detect test signal */
    SDHC0_REGS->SDHC_HC1R |= SDHC_HC1R_CARDDTL_YES | SDHC_HC1R_CARDDSEL_TEST | SDHC_HC1R_DMASEL(2);

    /* SD Bus Voltage Select = 3.3V, SD Bus Power = On */
    SDHC0_REGS->SDHC_PCR = (SDHC_PCR_SDBVSEL_3V3 | SDHC_PCR_SDBPWR_ON);

    /* Set initial clock to 400 KHz*/
    SDHC0_ClockSet (SDHC_CLOCK_FREQ_400_KHZ);

    /* Clear the high speed bit and set the data width to 1-bit mode */
    SDHC0_REGS->SDHC_HC1R &= ~(SDHC_HC1R_HSEN_Msk | SDHC_HC1R_DW_Msk);

    /* Enable card inserted and card removed interrupt signals */
    SDHC0_REGS->SDHC_NISIER = (SDHC_NISIER_CINS_Msk | SDHC_NISIER_CREM_Msk);
}

void SDHC0_Initialize( void )
{
    SDHC0_VariablesInit();
    SDHC0_ModuleInit();
}

void SDHC0_CallbackRegister(SDHC_CALLBACK callback, uintptr_t contextHandle)
{
    if (callback != NULL)
    {
        sdhc0Obj.callback = callback;
        sdhc0Obj.context = contextHandle;
    }
}