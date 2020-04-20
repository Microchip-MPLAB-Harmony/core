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

#include "device.h"
#include "plib_clk.h"




/*********************************************************************************
Initialize AUDIO PLL
*********************************************************************************/

static void CLK_AudioPLLInitialize(void)
{
    /* Disable PLL */
    PMC_REGS->PMC_AUDIO_PLL0 = 0;

    /* Release PLL from reset */
    PMC_REGS->PMC_AUDIO_PLL0 |= PMC_AUDIO_PLL0_RESETN(1);

    /* Configure PLL parameters */
    PMC_REGS->PMC_AUDIO_PLL0 |= PMC_AUDIO_PLL0_QDPMC(5) | PMC_AUDIO_PLL0_ND(51);
    PMC_REGS->PMC_AUDIO_PLL1 = PMC_AUDIO_PLL1_QDAUDIO(1) | PMC_AUDIO_PLL1_DIV(0x2) | PMC_AUDIO_PLL1_FRACR(0);

    /* Enable PLL */
    PMC_REGS->PMC_AUDIO_PLL0 |= PMC_AUDIO_PLL0_PLLEN(1) | PMC_AUDIO_PLL0_PADEN(0) | PMC_AUDIO_PLL0_PMCEN(1);

    /* Wait for 100 us for PLL in Calling/Driver code */
}


/*********************************************************************************
Initialize Generic clock
*********************************************************************************/

static void CLK_GenericClockInitialize(void)
{
    /* Enable GCLK for peripheral ID 31 */
    PMC_REGS->PMC_PCR = PMC_PCR_PID(31) | PMC_PCR_GCKCSS(0x5) | PMC_PCR_CMD_Msk | PMC_PCR_GCKDIV(0) | PMC_PCR_EN_Msk | PMC_PCR_GCKEN_Msk;
    /* Enable GCLK for peripheral ID 32 */
    PMC_REGS->PMC_PCR = PMC_PCR_PID(32) | PMC_PCR_GCKCSS(0x5) | PMC_PCR_CMD_Msk | PMC_PCR_GCKDIV(0) | PMC_PCR_EN_Msk | PMC_PCR_GCKEN_Msk;
}



/*********************************************************************************
Initialize Peripheral clock
*********************************************************************************/

static void CLK_PeripheralClockInitialize(void)
{
    /* Enable clock for the selected peripherals, since the rom boot will turn on
     * certain clocks turn off all clocks not expressly enabled */
   	PMC_REGS->PMC_PCER0=0x80042000;
    PMC_REGS->PMC_PCDR0=~0x80042000;
    PMC_REGS->PMC_PCER1=0x9;
    PMC_REGS->PMC_PCDR1=~0x9;
}



/*********************************************************************************
Clock Initialize
*********************************************************************************/

void CLK_Initialize( void )
{
    /* Initialize Audio PLL */
    CLK_AudioPLLInitialize();

	/* Initialize Generic Clock */
	CLK_GenericClockInitialize();

	/* Initialize Peripheral Clock */
	CLK_PeripheralClockInitialize();

}

