/*******************************************************************************
  EVIC PLIB Header

  Company:
    Microchip Technology Inc.

  File Name:
    plib_evic.h

  Summary:
    PIC32MZ Interrupt Module PLIB Header File

  Description:
    None

*******************************************************************************/

// DOM-IGNORE-BEGIN
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
// DOM-IGNORE-END

#ifndef PLIB_EVIC_H
#define PLIB_EVIC_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
#include <device.h>
#include <stddef.h>
#include <stdbool.h>
#include <device.h>

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Data Types
// *****************************************************************************
// *****************************************************************************

typedef enum
{
    INT_SOURCE_CORE_TIMER = _CORE_TIMER_VECTOR,

    INT_SOURCE_CORE_SOFTWARE_0 = _CORE_SOFTWARE_0_VECTOR,

    INT_SOURCE_CORE_SOFTWARE_1 = _CORE_SOFTWARE_1_VECTOR,

    INT_SOURCE_EXTERNAL_0 = _EXTERNAL_0_VECTOR,

    INT_SOURCE_TIMER_1 = _TIMER_1_VECTOR,

    INT_SOURCE_INPUT_CAPTURE_1 = _INPUT_CAPTURE_1_VECTOR,

    INT_SOURCE_OUTPUT_COMPARE_1 = _OUTPUT_COMPARE_1_VECTOR,

    INT_SOURCE_EXTERNAL_1 = _EXTERNAL_1_VECTOR,

    INT_SOURCE_TIMER_2 = _TIMER_2_VECTOR,

    INT_SOURCE_INPUT_CAPTURE_2 = _INPUT_CAPTURE_2_VECTOR,

    INT_SOURCE_OUTPUT_COMPARE_2 = _OUTPUT_COMPARE_2_VECTOR,

    INT_SOURCE_EXTERNAL_2 = _EXTERNAL_2_VECTOR,

    INT_SOURCE_TIMER_3 = _TIMER_3_VECTOR,

    INT_SOURCE_INPUT_CAPTURE_3 = _INPUT_CAPTURE_3_VECTOR,

    INT_SOURCE_OUTPUT_COMPARE_3 = _OUTPUT_COMPARE_3_VECTOR,

    INT_SOURCE_EXTERNAL_3 = _EXTERNAL_3_VECTOR,

    INT_SOURCE_TIMER_4 = _TIMER_4_VECTOR,

    INT_SOURCE_INPUT_CAPTURE_4 = _INPUT_CAPTURE_4_VECTOR,

    INT_SOURCE_OUTPUT_COMPARE_4 = _OUTPUT_COMPARE_4_VECTOR,

    INT_SOURCE_EXTERNAL_4 = _EXTERNAL_4_VECTOR,

    INT_SOURCE_TIMER_5 = _TIMER_5_VECTOR,

    INT_SOURCE_INPUT_CAPTURE_5 = _INPUT_CAPTURE_5_VECTOR,

    INT_SOURCE_OUTPUT_COMPARE_5 = _OUTPUT_COMPARE_5_VECTOR,

    INT_SOURCE_ADC = _ADC_VECTOR,

    INT_SOURCE_FAIL_SAFE_MONITOR = _FAIL_SAFE_MONITOR_VECTOR,

    INT_SOURCE_RTCC = _RTCC_VECTOR,

    INT_SOURCE_FCE = _FCE_VECTOR,

    INT_SOURCE_COMPARATOR_1 = _COMPARATOR_1_VECTOR,

    INT_SOURCE_COMPARATOR_2 = _COMPARATOR_2_VECTOR,

    INT_SOURCE_USB_1 = _USB_1_VECTOR,

    INT_SOURCE_SPI_1 = _SPI_1_VECTOR,

    INT_SOURCE_UART_1 = _UART_1_VECTOR,

    INT_SOURCE_I2C_1 = _I2C_1_VECTOR,

    INT_SOURCE_CHANGE_NOTICE = _CHANGE_NOTICE_VECTOR,

    INT_SOURCE_PMP = _PMP_VECTOR,

    INT_SOURCE_SPI_2 = _SPI_2_VECTOR,

    INT_SOURCE_UART_2 = _UART_2_VECTOR,

    INT_SOURCE_I2C_2 = _I2C_2_VECTOR,

    INT_SOURCE_UART_3 = _UART_3_VECTOR,

    INT_SOURCE_UART_4 = _UART_4_VECTOR,

    INT_SOURCE_UART_5 = _UART_5_VECTOR,

    INT_SOURCE_CTMU = _CTMU_VECTOR,

    INT_SOURCE_DMA_0 = _DMA_0_VECTOR,

    INT_SOURCE_DMA_1 = _DMA_1_VECTOR,

    INT_SOURCE_DMA_2 = _DMA_2_VECTOR,

    INT_SOURCE_DMA_3 = _DMA_3_VECTOR,

} INT_SOURCE;

// *****************************************************************************
// *****************************************************************************
// Section: Interface Routines
// *****************************************************************************
// *****************************************************************************

void EVIC_Initialize ( void );

void EVIC_SourceEnable( INT_SOURCE source );

void EVIC_SourceDisable( INT_SOURCE source );

bool EVIC_SourceIsEnabled( INT_SOURCE source );

bool EVIC_SourceStatusGet( INT_SOURCE source );

void EVIC_SourceStatusSet( INT_SOURCE source );

void EVIC_SourceStatusClear( INT_SOURCE source );

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    }

#endif
// DOM-IGNORE-END

#endif // PLIB_EVIC_H
