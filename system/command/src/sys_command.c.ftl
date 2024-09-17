/*******************************************************************************
  Command Processor System Service Implementation

  Company:
    Microchip Technology Inc.

  File Name:
    sys_command.c

  Summary:
    Command Processor System Service Implementation.

  Description:
    This file contains the source code for the Command Processor System
    Service.  It provides a way to interact with the Command Processor subsystem
    to manage the ASCII command requests from the user supported by the system.
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

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

#include "configuration.h"
#include "system/command/sys_command.h"
#include "system/console/sys_console.h"
#include "system/debug/sys_debug.h"
#include "system/reset/sys_reset.h"
#include "osal/osal.h"

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

typedef struct tagHistCmdNode
{
    struct tagHistCmdNode* next;
    struct tagHistCmdNode* prev;
    char    cmdBuff[SYS_CMD_MAX_LENGTH + 1];  // command itself
}histCmdNode;   // simple command history

typedef struct
{
    histCmdNode*    head;
    histCmdNode*    tail;
}histCmdList;     // doubly linked history command list

// standard VT100 key escape sequences
#define                 VT100_MAX_ESC_SEQ_SIZE    4               // max VT100 escape sequence size that is processed

// currently supported sequences received from the terminal:
// up arrow:    ESC [ A
// down arrow:  ESC [ B
// right arrow: ESC [ C
// left arrow:  ESC [ D
//
// VT100 control commands sent to the terminal:
// erase to the end of the line:    ESC [ K
// move cursor backwards:           ESC [ {COUNT} D
// move cursor forward:             ESC [ {COUNT} C
//


#define         LINE_TERM       "\r\n"          // line terminator
#define         promptStr      ">"             // prompt string

// descriptor of the command I/O node
typedef struct SYS_CMD_IO_DCPT
{
    SYS_CMD_DEVICE_NODE devNode;
    // internally maintained data
    struct SYS_CMD_IO_DCPT* next;   // linked list node
    const struct KEY_SEQ_DCPT_T* pSeqDcpt; // current escape sequence in progress
    int16_t         seqChars;   // # of characters from the escape sequence
    char            seqBuff[VT100_MAX_ESC_SEQ_SIZE + 2];     // 0x1b + escape sequence + \0
    char*           cmdPnt; // current pointer
    char*           cmdEnd; // command end
    char            cmdBuff[SYS_CMD_MAX_LENGTH + 1];   // buffer holding the command
    char            ctrlBuff[SYS_CMD_MAX_LENGTH + 10]; // buffer for terminal control
    // history
    histCmdList     histList;                           // arranged as list
    histCmdNode*    currHistN;      // current history node
    histCmdNode     histArray[COMMAND_HISTORY_DEPTH];   // array of history commands
} SYS_CMD_IO_DCPT;

// Defines the list structure to store a list of command instances.
typedef struct
{
    SYS_CMD_IO_DCPT* head;
    SYS_CMD_IO_DCPT* tail;

} SYS_CMD_DEVICE_LIST;


// Defines the command table structure for the Command Processor System Service.
typedef struct
{
    int                         nCmds;          // number of commands available in the table
    const SYS_CMD_DESCRIPTOR*   pCmd;           // pointer to an array of command descriptors
    const char*                 cmdGroupName;   // name identifying the commands
    const char*                 cmdMenuStr;     // help string
    SYS_CMD_Callback            usrCallback;    // user callback if any
    void*                       usrParam;       // user param
} SYS_CMD_DESCRIPTOR_TABLE;                 // table containing the supported commands

// *****************************************************************************
// *****************************************************************************
// Section: Global Variable Definitions
// *****************************************************************************
// *****************************************************************************

static SYS_CMD_DEVICE_LIST cmdIODevList = {0, 0};

static char printBuff[SYS_CMD_PRINT_BUFFER_SIZE] SYS_CMD_BUFFER_DMA_READY;
static int printBuffPtr = 0;

static SYS_CMD_INIT cmdInitData;       // data the command processor has been initialized with

static SYS_CMD_DESCRIPTOR_TABLE   usrCmdTbl[MAX_CMD_GROUP] = { {0} };    // current command table

static int stopRequested = 0;       // request to stop the command processor 

// function processing the VT100 escape sequence
typedef void (*keySeqProcess)(SYS_CMD_IO_DCPT* pCmdIO, const struct KEY_SEQ_DCPT_T* pSeqDcpt);

typedef struct KEY_SEQ_DCPT_T
{
    const char*     keyCode;    // pointer to the key code sequence
    keySeqProcess  keyFnc;     // key processing functions
    int             keySize;    // # of characters in the sequence
}KEY_SEQ_DCPT;


static void lkeyUpProcess(SYS_CMD_IO_DCPT* pCmdIO, const KEY_SEQ_DCPT* pSeqDcpt);
static void lkeyDownProcess(SYS_CMD_IO_DCPT* pCmdIO, const KEY_SEQ_DCPT* pSeqDcpt);
static void lkeyRightProcess(SYS_CMD_IO_DCPT* pCmdIO, const KEY_SEQ_DCPT* pSeqDcpt);
static void lkeyLeftProcess(SYS_CMD_IO_DCPT* pCmdIO, const KEY_SEQ_DCPT* pSeqDcpt);
static void lkeyHomeProcess(SYS_CMD_IO_DCPT* pCmdIO, const KEY_SEQ_DCPT* pSeqDcpt);
static void lkeyEndProcess(SYS_CMD_IO_DCPT* pCmdIO, const KEY_SEQ_DCPT* pSeqDcpt);


/* MISRA C-2012 Rule 4.1, 17.1 and 21.6 deviated below. Deviation record ID -
   H3_MISRAC_2012_R_4_1_DR_1, H3_MISRAC_2012_R_17_1_DR_1 and H3_MISRAC_2012_R_21_6_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:1 "MISRA C-2012 Rule 4.1" "H3_MISRAC_2012_R_4_1_DR_1" )\
(deviate:1 "MISRA C-2012 Rule 17.1" "H3_MISRAC_2012_R_17_1_DR_1" )\
(deviate:1 "MISRA C-2012 Rule 21.3" "H3_MISRAC_2012_R_21_3_DR_1" )\
(deviate:1 "MISRA C-2012 Rule 21.6" "H3_MISRAC_2012_R_21_6_DR_1" )
</#if>
// dummy table holding the escape sequences + expected sequence size
// detection of a sequence is done using only the first 3 characters
#define         VT100_DETECT_SEQ_SIZE    3
static const KEY_SEQ_DCPT keySeqTbl[] =
{
    // keyCode      keyFnc              keySize
    {"\x1b[A",      lkeyUpProcess,      (int32_t)sizeof("\x1b[A") - 1},
    {"\x1b[B",      lkeyDownProcess,    (int32_t)sizeof("\x1b[B") - 1},
    {"\x1b[C",      lkeyRightProcess,   (int32_t)sizeof("\x1b[C") - 1},
    {"\x1b[D",      lkeyLeftProcess,    (int32_t)sizeof("\x1b[D") - 1},
    {"\x1b[1~",     lkeyHomeProcess,    (int32_t)sizeof("\x1b[1~") - 1},
    {"\x1b[4~",     lkeyEndProcess,     (int32_t)sizeof("\x1b[4~") - 1},
};



// prototypes

static void     CommandReset(SYS_CMD_DEVICE_NODE* pCmdIO, int argc, char** argv);
static void     CommandQuit(SYS_CMD_DEVICE_NODE* pCmdIO, int argc, char** argv);              // command quit
static void     CommandHelp(SYS_CMD_DEVICE_NODE* pCmdIO, int argc, char** argv);              // help

static int      StringToArgs(char *str, char *argv[], size_t argvSize);
static void     ParseCmdBuffer(SYS_CMD_IO_DCPT* pCmdIO);      // parse the command buffer

static void     DisplayNodeMsg(SYS_CMD_IO_DCPT* pCmdIO, histCmdNode* pNext);

static void     CmdAddHead(histCmdList* pL, histCmdNode* pN);
static histCmdNode* CmdRemoveTail(histCmdList* pL);

static void     CmdAdjustPointers(SYS_CMD_IO_DCPT* pCmdIO);

static void SendCommandMessage(const void* cmdIoParam, const char* message);
static void SendCommandPrint(const void* cmdIoParam, const char* format, ...);
static void SendCommandCharacter(const void* cmdIoParam, char c);
static int IsCommandReady(const void* cmdIoParam);
static char GetCommandCharacter(const void* cmdIoParam);
static void RunCmdTask(SYS_CMD_IO_DCPT* pCmdIO);

static const SYS_CMD_API sysConsoleApi =
{
    .msg = SendCommandMessage,
    .print = SendCommandPrint,
    .putc_t = SendCommandCharacter,
    .isRdy = IsCommandReady,
    .getc_t = GetCommandCharacter,
};

// built-in command table
static const SYS_CMD_DESCRIPTOR    builtinCmdTbl[]=
{
    {"reset",   CommandReset,   ": Reset host"},
    {"q",       CommandQuit,    ": quit command processor"},
    {"help",    CommandHelp,    ": help"},
};

// *****************************************************************************
// *****************************************************************************
// Section: SYS CMD Operation Routines
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* MISRA C-2012 Rule 11.3 deviated : 2, 11.8 deviated :2. Deviation record ID -
   H3_MISRAC_2012_R_11_3_DR_1 & H3_MISRAC_2012_R_11_8_DR_1*/
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance block \
(deviate:2 "MISRA C-2012 Rule 11.3" "H3_MISRAC_2012_R_11_3_DR_1" )\
(deviate:2 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1" )
</#if>
/* Function:
    bool SYS_CMD_Initialize( const SYS_MODULE_INIT * const init  )

  Summary:
    Initializes data for the instance of the Command Processor module.

  Description:
    This function initializes the Command Processor module.
    It also initializes any internal data structures.

  Precondition:
    None.

  Parameters:
    init            - Pointer to a data structure containing any data necessary
                      to initialize the sys command. This pointer may be null if no
                      data is required because static overrides have been
                      provided.

  Returns:
    If successful, returns true.
    If there is an error, returns false.

  Remarks:
    This routine should only be called once during system initialization.
*/
bool SYS_CMD_Initialize(const SYS_MODULE_INIT * const init )
{
    SYS_CMD_INIT *initConfig = (SYS_CMD_INIT*)init;

    if (initConfig == NULL)
    {
        return false;
    }

    cmdInitData = *initConfig; // save a copy of the initialization data


    cmdIODevList.head = NULL;
    cmdIODevList.tail = NULL;

    cmdInitData.consoleIndex = initConfig->consoleIndex;

    stopRequested = 0;

    return true;
}


bool SYS_CMD_READY_TO_READ(void)
{
    return true;
}

// add new command group
bool  SYS_CMD_ADDGRP(const SYS_CMD_DESCRIPTOR* pCmdTbl, int nCmds, const char* groupName, const char* menuStr)
{
    int i, groupIx = -1, emptyIx = -1;
    int insertIx;
    SYS_CMD_Callback usrCallback = NULL;
    void* usrParam = NULL;

    // Check if there is space for new command group; If this table already added, also simply update.
    for (i = 0; i < MAX_CMD_GROUP; i++)
    {
        if(usrCmdTbl[i].pCmd == NULL)
        {   // empty slot
            emptyIx = i;
        }
        else if(usrCmdTbl[i].pCmd == pCmdTbl)
        {   // already have this group; sanity check against the group name
            if(strcmp(groupName, usrCmdTbl[i].cmdGroupName) != 0)
            {   // name mismatch
                return false;
            }

            groupIx = i;
            usrCallback = usrCmdTbl[i].usrCallback;
            usrParam = usrCmdTbl[i].usrParam;
            break;
        }
        else
        {
            /* Do Nothing */
        }
    }

    // reference the command group
    if (groupIx != -1)
    {
        insertIx = groupIx;
    }
    else if(emptyIx != -1)
    {
        insertIx = emptyIx;
    }
    else
    {
        return false;
    }

    usrCmdTbl[insertIx].pCmd = pCmdTbl;
    usrCmdTbl[insertIx].nCmds = nCmds;
    usrCmdTbl[insertIx].cmdGroupName = groupName;
    usrCmdTbl[insertIx].cmdMenuStr = menuStr;
    usrCmdTbl[insertIx].usrCallback = usrCallback;
    usrCmdTbl[insertIx].usrParam = usrParam;
    return true;

}

// Maintains the Command Processor System Service's internal state machine.
bool SYS_CMD_Tasks(void)
{
    SYS_CMD_IO_DCPT* pCmdIO;
    static bool error_reported = false;

    if(stopRequested != 0)
    {
        return true;
    }

    if (cmdIODevList.head == NULL)
    {
        if(SYS_CMDIO_ADD(&sysConsoleApi, &cmdInitData.consoleCmdIOParam, (int32_t)cmdInitData.consoleCmdIOParam) == NULL)
        {
            if(error_reported == false)
            {
                SYS_ERROR_PRINT(SYS_ERROR_WARNING, "Failed to create the Console API\r\n");
                error_reported = true;
            }
        }
    }

    for(pCmdIO = cmdIODevList.head; pCmdIO != NULL; pCmdIO = pCmdIO->next)
    {
        RunCmdTask(pCmdIO);
    }

    return true;
}

static void RunCmdTask(SYS_CMD_IO_DCPT* pCmdIO)
{
    char newCh;
    uint32_t ix;
    int len;
    const KEY_SEQ_DCPT *pKeyDcpt, *pFoundSeq;
    const SYS_CMD_API* pCmdApi = pCmdIO->devNode.pCmdApi;
    const void* cmdIoParam = pCmdIO->devNode.cmdIoParam;


    // Check if there's characters available
    if((*pCmdApi->isRdy)(cmdIoParam) == 0)
    {
        return;
    }

    // read the character
    newCh = (*pCmdApi->getc_t)(cmdIoParam); /* Read data from console. */

    if(pCmdIO->seqChars != 0)
    {   // in the middle of escape sequence
        pCmdIO->seqBuff[pCmdIO->seqChars] = newCh;
        pCmdIO->seqChars++;

        if(pCmdIO->seqChars == VT100_DETECT_SEQ_SIZE)
        {   // detect the exact escape sequence
            pCmdIO->seqBuff[pCmdIO->seqChars] = '\0';
            pKeyDcpt = keySeqTbl;
            pFoundSeq = NULL;

            ix = 0;
            while(ix < (sizeof(keySeqTbl) / sizeof(*keySeqTbl)))
            {
                if(strncmp(pCmdIO->seqBuff, pKeyDcpt->keyCode, VT100_DETECT_SEQ_SIZE) == 0)
                {   // found it
                    pFoundSeq = pKeyDcpt;
                    break;
                }
                ix++;
                pKeyDcpt++;
            }

            if(pFoundSeq == NULL)
            {   // unknown escape sequence
                pCmdIO->seqChars = 0;
                return;
            }

            pCmdIO->pSeqDcpt = pFoundSeq;
        }

        if((pCmdIO->seqChars >= VT100_DETECT_SEQ_SIZE) && (pCmdIO->seqChars == pCmdIO->pSeqDcpt->keySize))
        {   // check for complete sequence
            if(strcmp(pCmdIO->seqBuff, pCmdIO->pSeqDcpt->keyCode) == 0)
            {   // process sequence
                (*pCmdIO->pSeqDcpt->keyFnc)(pCmdIO, pCmdIO->pSeqDcpt);
            }

            // else unknown sequence ?
            pCmdIO->seqChars = 0;
            return;
        }

        return;

    }
    else if((newCh == '\r') || (newCh == '\n'))
    {   // new command assembled
        if(pCmdIO->cmdEnd ==  pCmdIO->cmdBuff)
        {   // just an extra \n or \r
            (*pCmdApi->msg)(cmdIoParam, LINE_TERM promptStr);
            return;
        }
        (*pCmdApi->msg)(cmdIoParam, LINE_TERM);
        *pCmdIO->cmdEnd = '\0';
        pCmdIO->cmdPnt = pCmdIO->cmdBuff;
        pCmdIO->cmdEnd = pCmdIO->cmdBuff;

        ParseCmdBuffer(pCmdIO);
        (*pCmdApi->msg)(cmdIoParam, promptStr);
    }
    else if(newCh == '\b')
    {
        if(pCmdIO->cmdPnt > pCmdIO->cmdBuff)
        {
            if(pCmdIO->cmdEnd > pCmdIO->cmdPnt)
            {
                char* pSrc = pCmdIO->cmdPnt; // current
                char* pDst = pCmdIO->cmdPnt - 1;
                len = pCmdIO->cmdEnd - pSrc;
                for(ix = 0; ix < (uint32_t)len; ix++)
                {
                    *pDst = *pSrc;
                    pDst++;
                    pSrc++;
                }
                pCmdIO->cmdPnt--; pCmdIO->cmdEnd--;
                // update the display; erase to the end of line(<ESC>[K) and move cursor backwards (<ESC>[{COUNT}D)
                *pCmdIO->cmdEnd = '\0';
                (void) sprintf(pCmdIO->ctrlBuff, "\b\x1b[K%s\x1b[%dD", pCmdIO->cmdPnt, len);
                (*pCmdApi->msg)(cmdIoParam, pCmdIO->ctrlBuff);
            }
            else
            {   // delete char under cursor
                (*pCmdApi->msg)(cmdIoParam, "\b\x1b[K");
                pCmdIO->cmdPnt--; pCmdIO->cmdEnd--;
            }
        }
    }
    else if((int32_t)newCh == 0x7f)
    {   // delete
        if(pCmdIO->cmdEnd > pCmdIO->cmdPnt)
        {
            char* pSrc = pCmdIO->cmdPnt + 1;
            char* pDst = pCmdIO->cmdPnt;
            len = pCmdIO->cmdEnd - pSrc;
            for(ix = 0; ix < (uint32_t)len; ix++)
            {
                *pDst = *pSrc;
                pDst++;
                pSrc++;
            }
            pCmdIO->cmdEnd--;
            // update the display; erase to the end of line(<ESC>[K) and move cursor backwards (<ESC>[{COUNT}D)
            *pCmdIO->cmdEnd = '\0';
            (void) sprintf(pCmdIO->ctrlBuff, "\x1b[K%s\x1b[%dD", pCmdIO->cmdPnt, len);
            (*pCmdApi->msg)(cmdIoParam, pCmdIO->ctrlBuff);
        }
    }
    else if((int32_t)newCh == 0x1b)
    {   // start escape sequence... wait for complete sequence
        pCmdIO->seqBuff[0] = newCh;
        pCmdIO->seqChars = 1;
    }
    else if((pCmdIO->cmdEnd - pCmdIO->cmdBuff) < ((int32_t)sizeof(pCmdIO->cmdBuff) - 1))
    {   // valid char; insert and echo it back
        int n_chars = pCmdIO->cmdEnd - pCmdIO->cmdPnt;  // existent chars
        if(n_chars != 0)
        {   // move the existing chars to the right, for insertion...
            char* pSrc = pCmdIO->cmdEnd - 1;
            char* pDst = pCmdIO->cmdEnd;
            for(ix = 0; ix < (uint32_t)n_chars; ix++)
            {
                *pDst = *pSrc;
                pDst--;
                pSrc--;
            }
            pCmdIO->cmdEnd++;
            *pCmdIO->cmdEnd = '\0';
            (void) sprintf(pCmdIO->ctrlBuff + 1, "%s\x1b[%dD", pCmdIO->cmdPnt + 1, n_chars);
        }
        else
        {
            pCmdIO->ctrlBuff[1] = (char)0;
        }
        pCmdIO->ctrlBuff[0] = newCh;

        (*pCmdApi->msg)(cmdIoParam, pCmdIO->ctrlBuff);
        *pCmdIO->cmdPnt = newCh;
        pCmdIO->cmdPnt++;
        CmdAdjustPointers(pCmdIO);
    }
    else
    {
        (*pCmdApi->msg)(cmdIoParam, " *** Command Processor buffer exceeded. Retry. ***" LINE_TERM);
        pCmdIO->cmdPnt = pCmdIO->cmdBuff;
        pCmdIO->cmdEnd = pCmdIO->cmdBuff;
        (*pCmdApi->msg)(cmdIoParam, promptStr);
    }
}

// *****************************************************************************
/* Function:
    void SYS_CMD_MESSAGE (const char* message)

  Summary:
    Outputs a message to the Command Processor System Service console.

  Description:
    This function outputs a message to the Command Processor System Service
    console.
.
  Precondition:
    SYS_CMD_Initialize was successfully run once.

  Parameters:
    None.

  Returns:
    None.

  Remarks:
    None.
*/
void SYS_CMD_MESSAGE(const char* message)
{
    SendCommandMessage(NULL, message);
}

// *****************************************************************************
/* Function:
    void SYS_CMD_PRINT(const char *format, ...)

  Summary:
    Outputs a printout to the Command Processor System Service console.

  Description:
    This function outputs a printout to the Command Processor System Service
    console.
.
  Precondition:
    SYS_CMD_Initialize was successfully run once.

  Parameters:
    None.

  Returns:
    None.

  Remarks:
    None.
*/
void SYS_CMD_PRINT(const char* format, ...)
{
    char tmpBuf[SYS_CMD_PRINT_BUFFER_SIZE];
    size_t len = 0;
    size_t padding = 0;
    va_list args ;
    va_start( args, format );

    len = (uint32_t)vsnprintf(tmpBuf, SYS_CMD_PRINT_BUFFER_SIZE, format, args);

    va_end( args );

    if ((len > 0U) && (len < SYS_CMD_PRINT_BUFFER_SIZE))
    {
        tmpBuf[len] = '\0';

        if ((len + (uint32_t)printBuffPtr) >= (SYS_CMD_PRINT_BUFFER_SIZE))
        {
            printBuffPtr = 0;
        }

        (void) strcpy(&printBuff[printBuffPtr], tmpBuf);
        SendCommandMessage(NULL, &printBuff[printBuffPtr]);

        padding = len % 4U;

        if (padding > 0U)
        {
            padding = 4U - padding;
        }

        printBuffPtr += (int32_t)len + (int32_t)padding;
    }
}

SYS_CMD_DEVICE_NODE* SYS_CMDIO_GET_HANDLE(short num)
{
    SYS_CMD_IO_DCPT* pNode = cmdIODevList.head;

     while((num != 0) && (pNode != NULL))
    {
        pNode = pNode->next;
        num--;
    }

    return ((pNode == NULL) ? (NULL) : (&pNode->devNode));
}

SYS_CMD_DEVICE_NODE* SYS_CMDIO_ADD(const SYS_CMD_API* opApi, const void* cmdIoParam, int unused)
{
    uint32_t ix;

    // Create new node
    SYS_CMD_IO_DCPT* pNewIo;

    pNewIo = (SYS_CMD_IO_DCPT*)OSAL_Malloc(sizeof(*pNewIo));
    if (pNewIo == NULL)
    {
        return NULL;
    }
    (void) memset(pNewIo, 0, sizeof(*pNewIo));
    pNewIo->devNode.pCmdApi = opApi;
    pNewIo->devNode.cmdIoParam = cmdIoParam;
    pNewIo->cmdPnt = pNewIo->cmdBuff;
    pNewIo->cmdEnd = pNewIo->cmdBuff;

    // construct the command history list
    for(ix = 0; ix < (sizeof(pNewIo->histArray) / sizeof(*pNewIo->histArray)); ix++)
    {
        CmdAddHead(&pNewIo->histList, pNewIo->histArray + ix);
    }

    // Insert node at end
    pNewIo->next = NULL;
    if(cmdIODevList.head == NULL)
    {
        cmdIODevList.head = pNewIo;
        cmdIODevList.tail = pNewIo;
    }
    else
    {
        cmdIODevList.tail->next = pNewIo;
        cmdIODevList.tail = pNewIo;
    }

    return &pNewIo->devNode;
}


bool SYS_CMD_DELETE(SYS_CMD_DEVICE_NODE* pDeviceNode)
{
    SYS_CMD_IO_DCPT* p_listnode = cmdIODevList.head;
    SYS_CMD_IO_DCPT* pre_listnode;
    SYS_CMD_IO_DCPT* pDevNode = (SYS_CMD_IO_DCPT*)pDeviceNode;

    // root list is empty or null node to be deleted
    if((p_listnode == NULL) || (pDevNode == NULL))
    {
        return false;
    }

    if(p_listnode == pDevNode)
    {   // delete the head
        //Root list has only one node
        if(cmdIODevList.tail == pDevNode)
        {
            cmdIODevList.head = NULL;
            cmdIODevList.tail = NULL;
        }
        else
        {
            cmdIODevList.head = p_listnode->next;
        }
        OSAL_Free(pDevNode);
        return true;
    }

    // delete mid node
    pre_listnode = p_listnode;
    while (p_listnode != NULL)
    {
        if(p_listnode == pDevNode)
        {
            pre_listnode->next = p_listnode->next;
            // Deleted node is tail
            if (cmdIODevList.tail==pDevNode) {
                cmdIODevList.tail = pre_listnode;
            }
            OSAL_Free(pDevNode);
            return true;
        }
        pre_listnode = p_listnode;
        p_listnode   = p_listnode->next;
    }


    return false;
}

SYS_CMD_HANDLE  SYS_CMD_CallbackRegister(const SYS_CMD_DESCRIPTOR* pCmdTbl, SYS_CMD_Callback func, void* hParam)
{
    SYS_CMD_HANDLE handle = NULL;

    if(func != NULL)
    {
        int ix;
        SYS_CMD_DESCRIPTOR_TABLE* pTbl = usrCmdTbl;

        ix = 0;
        while (ix < MAX_CMD_GROUP)
        {
            if(pTbl->pCmd == pCmdTbl)
            {   // requested group
                OSAL_CRITSECT_DATA_TYPE critSect =  OSAL_CRIT_Enter(OSAL_CRIT_TYPE_LOW);
                if(pTbl->usrCallback == NULL)
                {
                    pTbl->usrCallback = func;
                    pTbl->usrParam = hParam;
                    handle = pTbl;
                }
                OSAL_CRIT_Leave(OSAL_CRIT_TYPE_LOW, critSect);
            }
            ix++;
            pTbl++;
        }
    }

    return handle;
}

bool SYS_CMD_CallbackDeregister(SYS_CMD_HANDLE handle)
{
    bool res = false;

    SYS_CMD_DESCRIPTOR_TABLE* xTbl = (SYS_CMD_DESCRIPTOR_TABLE*)handle;

    int nIx = xTbl - usrCmdTbl;

    if( (0 <= nIx) && ((uint32_t)nIx < sizeof(usrCmdTbl) / sizeof(*usrCmdTbl)))
    {
        SYS_CMD_DESCRIPTOR_TABLE* pTbl = usrCmdTbl + nIx;

        if(pTbl == xTbl)
        {   // handle is correct
            OSAL_CRITSECT_DATA_TYPE critSect =  OSAL_CRIT_Enter(OSAL_CRIT_TYPE_LOW);
            if((pTbl->pCmd != NULL) && (pTbl->usrCallback != NULL))
            {   // in use
                pTbl->usrCallback = NULL;
                res = true;
            }
            OSAL_CRIT_Leave(OSAL_CRIT_TYPE_LOW, critSect);
        }
    }

    return res;
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.3"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"
</#if>
/* MISRAC 2012 deviation block end */
// ignore the console handle for now, we support a single system console
static void SendCommandMessage(const void* cmdIoParam, const char* message)
{
    (void) SYS_CONSOLE_Write(cmdInitData.consoleIndex, message, strlen(message));
}

static void SendCommandPrint(const void* cmdIoParam, const char* format, ...)
{
    char tmpBuf[SYS_CMD_PRINT_BUFFER_SIZE];
    size_t len = 0;
    size_t padding = 0;
    va_list args;
    va_start( args, format );

    len = (uint32_t)vsnprintf(tmpBuf, SYS_CMD_PRINT_BUFFER_SIZE, format, args);

    va_end( args );


    if ((len > 0U) && (len < SYS_CMD_PRINT_BUFFER_SIZE))
    {
        tmpBuf[len] = '\0';

        if ((len + (uint32_t)printBuffPtr) >= SYS_CMD_PRINT_BUFFER_SIZE)
        {
            printBuffPtr = 0;
        }

        (void) strcpy(&printBuff[printBuffPtr], tmpBuf);
        SendCommandMessage(NULL, &printBuff[printBuffPtr]);

        padding = len % 4U;

        if (padding > 0U)
        {
            padding = 4U - padding;
        }

        printBuffPtr += (int32_t)len + (int32_t)padding;
    }
}

static void SendCommandCharacter(const void* cmdIoParam, char c)
{
    if (SYS_CONSOLE_Status((SYS_MODULE_OBJ)cmdInitData.consoleIndex) == SYS_STATUS_READY)
    {
        (void) SYS_CONSOLE_Write(cmdInitData.consoleIndex, (const char*)&c, 1);
    }
}


static int IsCommandReady(const void* cmdIoParam)
{
    return (int)SYS_CONSOLE_ReadCountGet(cmdInitData.consoleIndex);
}

static char GetCommandCharacter(const void* cmdIoParam)
{
    char new_c;

    (void) SYS_CONSOLE_Read(cmdInitData.consoleIndex, &new_c, 1);

    return new_c;
}

// implementation
static void CommandReset(SYS_CMD_DEVICE_NODE* pCmdIO, int argc, char** argv)
{
    const void* cmdIoParam = pCmdIO->cmdIoParam;
    (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM " *** System Reboot ***\r\n" );

    SYS_RESET_SoftwareReset();

}

// quit
static void CommandQuit(SYS_CMD_DEVICE_NODE* pCmdIO, int argc, char** argv)
{
    SYS_CMD_IO_DCPT* pCmdIoNode;
    const void* cmdIoParam = pCmdIO->cmdIoParam;

    (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM " *** Quitting the Command Processor. Bye ***\r\n" );

    (void) memset(usrCmdTbl, 0x0, sizeof(usrCmdTbl));

    // delete all the nodes in cmdIODevList
    while((pCmdIoNode = cmdIODevList.head) != NULL)
    {
        if(cmdIODevList.head == cmdIODevList.tail)
        {
            cmdIODevList.head = cmdIODevList.tail = NULL;
        }
        else
        {
            cmdIODevList.head = cmdIODevList.head->next;
        }

        OSAL_Free(pCmdIoNode);
    }

    // no longer run the SYS_CMD_Tasks
    stopRequested = 1;
}

static void CommandHelp(SYS_CMD_DEVICE_NODE* pCmdIO, int argc, char** argv)
{
    uint32_t ix;
    int32_t groupIx;
    const SYS_CMD_DESCRIPTOR*  pDcpt;
    const SYS_CMD_DESCRIPTOR_TABLE* pTbl, *pDTbl;
    const void* cmdIoParam = pCmdIO->cmdIoParam;

    if(argc == 1)
    {   // no params help; display basic info
        bool hadHeader = false;
        pTbl = usrCmdTbl;
        for (groupIx=0; groupIx < MAX_CMD_GROUP; groupIx++)
        {
            if (pTbl->pCmd != NULL)
            {
                if(!hadHeader)
                {
                    (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM "------- Supported command groups ------");
                    hadHeader = true;
                }
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM " *** ");
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, pTbl->cmdGroupName);
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, pTbl->cmdMenuStr);
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, " ***");
            }
            pTbl++;
        }

        // display the basic commands
        (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM "---------- Built in commands ----------");

        ix = 0;
        pDcpt = builtinCmdTbl;
        while(ix < (sizeof(builtinCmdTbl)/sizeof(*builtinCmdTbl)))
        {
            (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM " *** ");
            (*pCmdIO->pCmdApi->msg)(cmdIoParam, pDcpt->cmdStr);
            (*pCmdIO->pCmdApi->msg)(cmdIoParam, pDcpt->cmdDescr);
            (*pCmdIO->pCmdApi->msg)(cmdIoParam, " ***");
            ix++;
            pDcpt++;
        }

        (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM);
    }
    else
    {   // we have a command group name
        pDTbl = NULL;
        pTbl = usrCmdTbl;
        for (groupIx=0; groupIx < MAX_CMD_GROUP; groupIx++)
        {
            if (pTbl->pCmd != NULL)
            {
                if(strcmp(pTbl->cmdGroupName, argv[1]) == 0)
                {   // match
                    pDTbl = pTbl;
                    break;
                }
            }
            pTbl++;
        }

        if(pDTbl != NULL)
        {
            ix = 0;
            pDcpt = pDTbl->pCmd;
            while(ix < (uint32_t)pDTbl->nCmds)
            {
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM " *** ");
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, pDcpt->cmdStr);
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, pDcpt->cmdDescr);
                (*pCmdIO->pCmdApi->msg)(cmdIoParam, " ***");
                ix++;
                pDcpt++;
            }

            (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM);
        }
        else
        {
            (*pCmdIO->pCmdApi->msg)(cmdIoParam, LINE_TERM "Unknown command group. Try help" LINE_TERM );
        }
    }

}

static void ParseCmdBuffer(SYS_CMD_IO_DCPT* pCmdIO)
{
    int  argc = 0;
    char *argv[MAX_CMD_ARGS] = {0};
    char saveCmd[SYS_CMD_MAX_LENGTH + 1];
    char usrSaveCmd[SYS_CMD_MAX_LENGTH + 1];
    const void* cmdIoParam = pCmdIO->devNode.cmdIoParam;

    uint32_t  ix;
    int grp_ix;
    const SYS_CMD_DESCRIPTOR* pDcpt;

    (void) strncpy(saveCmd, pCmdIO->cmdBuff, sizeof(saveCmd));     // make a copy of the command

    // standard parse a command string to *argv[]
    argc = StringToArgs(saveCmd, argv, MAX_CMD_ARGS);

    if(argc == 0)
    {
        (*pCmdIO->devNode.pCmdApi->msg)(cmdIoParam, " *** Command Processor: Please type in a command***" LINE_TERM);
    }
    else
    {
        if(argc > 0)
        {   // ok, there's smth here
            // add it to the history list
            histCmdNode* pN = CmdRemoveTail(&pCmdIO->histList);
            (void) strncpy(pN->cmdBuff, pCmdIO->cmdBuff, sizeof(pN->cmdBuff)); // Need save non-parsed string
            CmdAddHead(&pCmdIO->histList, pN);
            pCmdIO->currHistN = NULL;

            // try built-in commands first
            ix = 0;
            pDcpt = builtinCmdTbl;
            while(ix < (sizeof(builtinCmdTbl)/sizeof(*builtinCmdTbl)))
            {
                if(strcmp(argv[0], pDcpt->cmdStr) == 0)
                {   // command found
                    if(argc > MAX_CMD_ARGS)
                    {
                        (*pCmdIO->devNode.pCmdApi->print)(cmdIoParam, "\n\r Too many arguments. Maximum args supported: %d!\r\n", MAX_CMD_ARGS);
                    }
                    else
                    {   // OK, call command handler
                        pDcpt->cmdFnc(&pCmdIO->devNode, argc, argv);
                    }
                    return;
                }
                ix++;
                pDcpt++;
            }

            // search user commands
            SYS_CMD_DESCRIPTOR_TABLE* pTbl = usrCmdTbl;
            grp_ix = 0;
            while(grp_ix < MAX_CMD_GROUP)
            {
                if (pTbl->pCmd != NULL)
                {
                    if (pTbl->usrCallback != NULL)
                    {
                        // external parser; give it a fresh copy of the command
                        (void) strncpy(usrSaveCmd, pCmdIO->cmdBuff, sizeof(usrSaveCmd));
                        if(pTbl->usrCallback(pTbl->pCmd, &pCmdIO->devNode, usrSaveCmd, sizeof(usrSaveCmd), pTbl->usrParam))
                        {   // command processed externally
                            return;
                        }
                        // reparse the user modified command
                        argc = StringToArgs(usrSaveCmd, argv, MAX_CMD_ARGS);
                    }

                    if(argc > MAX_CMD_ARGS)
                    {
                        (*pCmdIO->devNode.pCmdApi->print)(cmdIoParam, "\n\r Too many arguments. Maximum args supported: %d!\r\n", MAX_CMD_ARGS);
                        return;
                    }

                    ix = 0;
                    pDcpt = usrCmdTbl[grp_ix].pCmd;
                    while(ix < (uint32_t)usrCmdTbl[grp_ix].nCmds)
                    {
                        if(strcmp(argv[0], pDcpt->cmdStr) == 0)
                        {
                            // command found
                            pDcpt->cmdFnc(&pCmdIO->devNode, argc, argv);
                            return;
                        }
                        ix++;
                        pDcpt++;
                    }
                }
                grp_ix++;
                pTbl++;
            }
        }

        // command not found
        (*pCmdIO->devNode.pCmdApi->msg)(cmdIoParam, " *** Command Processor: unknown command. ***\r\n");
    }
}

/*
  parse a string into '*argv[]' tokens
  token delimitor is space, tab or comma
  parts within quotes (") are parsed as a single token
  return number of parsed tokens
  < 0 if error
*/
static int StringToArgs(char *str, char *argv[], size_t argvSize)
{
    char* pTkn;
    char* qStart, *qEnd;   // special char '"' starting position;
    int nArgs = 0;

    while(str != NULL)
    {
        qStart = strchr(str, (int32_t)'"');
        if(qStart != NULL)
        {
            *qStart = (char)0;
        }

        // parse until quote
        while((pTkn = strtok(str, " \t,")) != NULL)
        {
            str = NULL;
            if((uint32_t)nArgs < argvSize)
            {
                argv[nArgs] = pTkn;
            }
            nArgs++;
        }

        if(qStart == NULL)
        {   // done
            break;
        }

        // get end quote
        qStart++;
        qEnd = strchr(qStart, (int32_t)'"');
        if((qEnd == NULL) || ((qEnd - qStart) == 0))
        {   // no matching quote end or empty string within quotes
            return -1;
        }
        *qEnd = (char)0;
        if((uint32_t)nArgs < argvSize)
        {
            argv[nArgs] = qStart;
        }
        nArgs++;

        // continue parsing
        str = qEnd + 1;
    }


    return nArgs;
}

static void lkeyUpProcess(SYS_CMD_IO_DCPT* pCmdIO, const KEY_SEQ_DCPT* pSeqDcpt)
{   // up arrow
    histCmdNode *pNext;

    if(pCmdIO->currHistN != NULL)
    {
        pNext = pCmdIO->currHistN->next;
        if(pNext == pCmdIO->histList.head)
        {
            return; // reached the end of list
        }
    }
    else
    {
        pNext = pCmdIO->histList.head;
    }

    DisplayNodeMsg(pCmdIO, pNext);
}

static void lkeyDownProcess(SYS_CMD_IO_DCPT* pCmdIO, const KEY_SEQ_DCPT* pSeqDcpt)
{   // down arrow
    histCmdNode *pNext;

    if(pCmdIO->currHistN != NULL)
    {
        pNext = pCmdIO->currHistN->prev;
        if(pNext != pCmdIO->histList.tail)
        {
            DisplayNodeMsg(pCmdIO, pNext);
        }
    }
}

static void lkeyRightProcess(SYS_CMD_IO_DCPT* pCmdIO, const KEY_SEQ_DCPT* pSeqDcpt)
{   // right arrow
    const SYS_CMD_API* pCmdApi = pCmdIO->devNode.pCmdApi;
    const void* cmdIoParam = pCmdIO->devNode.cmdIoParam;

    if(pCmdIO->cmdPnt < pCmdIO->cmdEnd)
    {   // just advance
        (*pCmdApi->msg)(cmdIoParam, pSeqDcpt->keyCode);
        pCmdIO->cmdPnt++;
    }
}

static void lkeyLeftProcess(SYS_CMD_IO_DCPT* pCmdIO, const KEY_SEQ_DCPT* pSeqDcpt)
{   // left arrow
    const SYS_CMD_API* pCmdApi = pCmdIO->devNode.pCmdApi;
    const void* cmdIoParam = pCmdIO->devNode.cmdIoParam;

    if(pCmdIO->cmdPnt > pCmdIO->cmdBuff)
    {
        pCmdIO->cmdPnt--;
        (*pCmdApi->msg)(cmdIoParam, pSeqDcpt->keyCode);
    }
}

static void lkeyHomeProcess(SYS_CMD_IO_DCPT* pCmdIO, const KEY_SEQ_DCPT* pSeqDcpt)
{   // home key
    const SYS_CMD_API* pCmdApi = pCmdIO->devNode.pCmdApi;
    const void* cmdIoParam = pCmdIO->devNode.cmdIoParam;
    int nChars = pCmdIO->cmdPnt - pCmdIO->cmdBuff;
    if(nChars != 0)
    {
        // <ESC>[{COUNT}D
        char homeBuff[ 10 + 1];
        (void) sprintf(homeBuff, "\x1b[%dD", nChars);
        (*pCmdApi->msg)(cmdIoParam, homeBuff);
        pCmdIO->cmdPnt = pCmdIO->cmdBuff;
    }
}

static void lkeyEndProcess(SYS_CMD_IO_DCPT* pCmdIO, const KEY_SEQ_DCPT* pSeqDcpt)
{   // end key
    const SYS_CMD_API* pCmdApi = pCmdIO->devNode.pCmdApi;
    const void* cmdIoParam = pCmdIO->devNode.cmdIoParam;

    int nChars = pCmdIO->cmdEnd - pCmdIO->cmdPnt;
    if(nChars != 0)
    {
        // "<ESC>[{COUNT}C"
        char endBuff[ 10 + 1];
        (void) sprintf(endBuff, "\x1b[%dC", nChars);
        (*pCmdApi->msg)(cmdIoParam, endBuff);
        pCmdIO->cmdPnt = pCmdIO->cmdEnd;
    }

}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 4.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 17.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 21.3"
#pragma coverity compliance end_block "MISRA C-2012 Rule 21.6"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */

static void DisplayNodeMsg(SYS_CMD_IO_DCPT* pCmdIO, histCmdNode* pNext)
{
    int oCmdLen, nCmdLen;
    const SYS_CMD_API* pCmdApi = pCmdIO->devNode.pCmdApi;
    const void* cmdIoParam = pCmdIO->devNode.cmdIoParam;

    if((nCmdLen = (int32_t)strlen(pNext->cmdBuff)) != 0)
    {   // something there
        oCmdLen = pCmdIO->cmdEnd - pCmdIO->cmdBuff;
        while(oCmdLen > nCmdLen)
        {
            (*pCmdApi->msg)(cmdIoParam, "\b \b");     // clear the old command
            oCmdLen--;
        }
        while(oCmdLen != 0)
        {
            (*pCmdApi->msg)(cmdIoParam, "\b");
            oCmdLen--;
        }
        (void) strcpy(pCmdIO->cmdBuff, pNext->cmdBuff);
        (*pCmdApi->msg)(cmdIoParam, "\r\n>");
        (*pCmdApi->msg)(cmdIoParam, pCmdIO->cmdBuff);
        pCmdIO->cmdPnt = pCmdIO->cmdBuff + nCmdLen;
        pCmdIO->cmdEnd = pCmdIO->cmdBuff + nCmdLen;
        pCmdIO->currHistN = pNext;
    }
}


static void CmdAddHead(histCmdList* pL, histCmdNode* pN)
{
    if(pL->head == NULL)
    { // empty list, first node
        pL->head = pN;
        pL->tail = pN;
        pN->next = pN;
        pN->prev = pN;
    }
    else
    {
        pN->next = pL->head;
        pN->prev = pL->tail;
        pL->tail->next = pN;
        pL->head->prev = pN;
        pL->head = pN;
    }
}


static histCmdNode* CmdRemoveTail(histCmdList* pL)
{
    histCmdNode* pN;
    if(pL->head == pL->tail)
    {
        pN = pL->head;
        pL->head = NULL;
        pL->tail = NULL;
    }
    else
    {
        pN = pL->tail;
        pL->tail = pN->prev;
        pL->tail->next = pL->head;
        pL->head->prev = pL->tail;
    }
    return pN;
}

static void CmdAdjustPointers(SYS_CMD_IO_DCPT* pCmdIO)
{
    if(pCmdIO->cmdPnt > pCmdIO->cmdEnd)
    {
        pCmdIO->cmdEnd = pCmdIO->cmdPnt;
    }
}


