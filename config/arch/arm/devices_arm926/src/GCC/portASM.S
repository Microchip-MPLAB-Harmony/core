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

#define AIC         0xFFFFF100
#define AIC_IVR     0x010
#define AIC_SMR     0x004
#define AIC_EOICR   0x038

#define I_BIT       0x80
#define F_BIT       0x40
	

	.text
	.arm

	.set SYS_MODE,	0x1f
	.set SVC_MODE,	0x13
	.set IRQ_MODE,	0x12


	/* Variables and functions. */
	.extern resetVector
	.extern vTaskSwitchContext
	.extern ulPortYieldRequired
	.extern vApplicationIRQHandler
	.extern	vTaskSwitchContext
	.extern ulCriticalNesting
	.extern	pxCurrentTCB
	.extern	ulPortTaskHasFPUContext
	.global vPortStartFirstTask
	.global FreeRTOS_SWI_Handler
	.global FreeRTOS_IRQ_Handler



.macro portSAVE_CONTEXT

	// Push R0 as we are going to use the register. 					
	STMDB	SP!, {R0}

	// Set R0 to point to the task stack pointer. 					
	STMDB	SP, {SP}^
	NOP
	SUB		SP, SP, #4
	LDMIA	SP!, {R0}

	// Push the return address onto the stack. 						
	STMDB	R0!, {LR}

	// Now we have saved LR we can use it instead of R0. 				
	MOV		LR, R0

	// Pop R0 so we can save it onto the system mode stack. 			
	LDMIA	SP!, {R0}

	// Push all the system mode registers onto the task stack. 		
	STMDB	LR, {R0-LR}^
	NOP
	SUB		LR, LR, #60

	// Push the SPSR onto the task stack. 							
	MRS		R0, SPSR
	STMDB	LR!, {R0}

	LDR		R0, =ulCriticalNesting 
	LDR		R0, [R0]
	STMDB	LR!, {R0}

	// Store the new top of stack for the task. 						
	LDR		R1, =pxCurrentTCB
	LDR		R0, [R1]
	STR		LR, [R0]

	.endm


/**********************************************************************/

.macro portRESTORE_CONTEXT

	/*Set the LR to the task stack.*/ 									
	LDR		R1, =pxCurrentTCB
	LDR		R0, [R1]
	LDR		LR, [R0]

	/* The critical nesting depth is the first item on the stack. 	
	   Load it into the ulCriticalNesting variable*/ 					
	LDR		R0, =ulCriticalNesting
	LDMFD	LR!, {R1}
	STR		R1, [R0]

	// Get the SPSR from the stack. 									
	LDMFD	LR!, {R0}
	MSR		SPSR_cxsf, R0

	// Restore all system mode registers for the task. 				
	LDMFD	LR, {R0-R14}^
	NOP

	// Restore the return address. 									
	LDR		LR, [LR, #+60]

	/* And return - correcting the offset in the LR to obtain the 	
	 correct address. */												
	SUBS	PC, LR, #4

	.endm
/******************************************************************************
 * SVC handler is used to yield a task.
 *****************************************************************************/
.align 4
.type FreeRTOS_SWI_Handler, %function
FreeRTOS_SWI_Handler:
	ADD		LR, LR, #4			// Add 4 to the LR to make the LR appear exactly
								// as if the context was saved during and IRQ
								// handler.
								
	portSAVE_CONTEXT			// Save the context of the current task...
	LDR R0, =vTaskSwitchContext	// before selecting the next task to execute.
	mov     lr, pc
	BX R0
	portRESTORE_CONTEXT			// Restore the context of the selected task.


/******************************************************************************
 * IRQ interrupt handler used when individual priorities cannot be masked
 *****************************************************************************/
.align 4
.type FreeRTOS_IRQ_Handler, %function
FreeRTOS_IRQ_Handler:
			portSAVE_CONTEXT
	
			/* Write in the IVR to support Protect Mode */
			LDR 	lr, =AIC
			LDR 	r0, [r14, #AIC_IVR]
			STR 	lr, [r14, #AIC_IVR]
			
			// Dummy read to force AIC_IVR write completion
			LDR         lr, [r14, #AIC_SMR]

			// Branch to interrupt handler in Supervisor mode

			MSR         CPSR_c, #SVC_MODE
			STMFD       sp!, { r1-r3, r4, r12, lr}

			// Check for 8-byte alignment and save lr plus a
			// word to indicate the stack adjustment used (0 or 4)

			AND         r1, sp, #4
			SUB         sp, sp, r1
			STMFD       sp!, {r1, lr}
	
			/* Branch to C portion of the interrupt handler */
			MOV 	lr, pc
			BX		r0
			
			LDMIA       sp!, {r1, lr}
			ADD         sp, sp, r1

			LDMIA       sp!, { r1-r3, r4, r12, lr}
			MSR         CPSR_c, #IRQ_MODE | I_BIT | F_BIT
	
			/* Acknowledge interrupt */
			LDR 	lr, =AIC
			STR 	lr, [r14, #AIC_EOICR]
	
			portRESTORE_CONTEXT

/*-----------------------------------------------------------*/
.align 4
.type vPortStartFirstTask, %function
vPortStartFirstTask:
		portRESTORE_CONTEXT		



	.end


