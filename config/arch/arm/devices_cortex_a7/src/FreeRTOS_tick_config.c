/*
 * FreeRTOS Kernel V11.1.0
 * Copyright (C) 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * SPDX-License-Identifier: MIT
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * https://www.FreeRTOS.org
 * https://github.com/FreeRTOS
 *
 */

/* FreeRTOS includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "definitions.h"

extern void GIC_IRQHandler(uint32_t  iarRegVal);

void GENERIC_TIMER_InterruptHandler(void)
{
    uint64_t currentCompVal = PL1_GetPhysicalCompareValue();
    PL1_SetPhysicalCompareValue(currentCompVal + (GENERIC_TIMER_CounterFrequencyGet() / configTICK_RATE_HZ));

    /* Call FreeRTOS_Tick_Handler */
    FreeRTOS_Tick_Handler();
}

/*
 * The application must provide a function that configures a peripheral to
 * create the FreeRTOS tick interrupt, then define configSETUP_TICK_INTERRUPT()
 * in FreeRTOSConfig.h to call the function.  This file contains a function
 * that is suitable for use on the Cortex-A7.
 */
void vConfigureTickInterrupt(void)
{
    /* Initialize the Generic Timer to the desired frequency - specified in Generic Timer ticks. */
    GENERIC_TIMER_PeriodSet( GENERIC_TIMER_CounterFrequencyGet() / configTICK_RATE_HZ );

    /* Start Generic Timer */
    GENERIC_TIMER_Start();
}
/*-----------------------------------------------------------*/

/* The function called by the RTOS port layer after it has managed interrupt entry. */
void vApplicationIRQHandler(uint32_t ulICCIAR)
{
    /* Ensure the write takes before re-enabling interrupts */
    __DSB();
    __ISB();
    __enable_irq();

    /* Call the installed ISR */
    GIC_IRQHandler(ulICCIAR);
}
