/*******************************************************************************
 System Tasks Header File

  File Name:
    sys_tasks.h

  Summary:
    This file contains declarations for task handles.

  Description:
    Task handles declared in this header file can be used by the application
    to control the behavior of the tasks.

  Remarks:
    None
 *******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2023 Microchip Technology Inc. and its subsidiaries.
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

#ifndef SYS_TASKS_H
#define SYS_TASKS_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

<#if ENABLE_DRV_COMMON == true ||
     ENABLE_SYS_COMMON == true ||
     ENABLE_APP_FILE == true >
    <#lt>#include "configuration.h"
</#if>
#include "definitions.h"

<#if SELECT_RTOS != "BareMetal">
    <#lt>// *****************************************************************************
    <#lt>// *****************************************************************************
    <#lt>// Section: RTOS "Tasks" Handles
    <#lt>// *****************************************************************************
    <#lt>// *****************************************************************************
    <#lt>${core.LIST_SYSTEM_TASKS_HANDLE_DECLARATION}
</#if>

#endif //SYS_TASKS_H